<?php
declare(strict_types=1);

/**
 * v0.9.7 Petal sinks: things to spend Petals on at gnome level 15-28 (cosmetic or convenience, never stats).
 *  - the weekly Curio Cabinet (rare decor) at the Hedge & Hearth
 *  - building skins (chosen per building in the garden buildings panel)
 *  - hat and beard dyes from the Dye Pot, picked on My Gnome
 *  - garden signposts (one per garden)
 * Every price, count and limit is a setting (Admin -> Settings) or item data (Admin -> Items); nothing here changes a stat.
 * One-off purchases are remembered in sink_owned; weekly curio purchases in curio_buys.
 */

// ---------- Shared ----------

/** A comma separated setting as ints, padded from $fallback. */
function sink_ints(string $name, array $fallback): array
{
    $v = array_map('intval', array_map('trim', explode(',', (string)setting($name))));
    foreach ($fallback as $i => $f) if (!isset($v[$i]) || $v[$i] < 0) $v[$i] = $f;
    return $v;
}

/** Take Petals only if the gnome has them (one atomic UPDATE). */
function sink_pay(int $uid, int $cost): bool
{
    return q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $uid, $cost])->rowCount() === 1;
}

/** Remember a one-off purchase. False if it was owned already (the unique key stops a double buy). */
function sink_own(int $uid, string $kind, string $ref, int $plotId = 0): bool
{
    try {
        db_insert('sink_owned', ['user_id' => $uid, 'plot_id' => $plotId, 'kind' => $kind, 'ref' => $ref, 'at' => now()]);
        return true;
    } catch (PDOException $e) {
        return false;
    }
}

function sink_owns(int $uid, string $kind, string $ref, int $plotId = 0): bool
{
    return (bool)q_val('SELECT 1 FROM sink_owned WHERE user_id = ? AND plot_id = ? AND kind = ? AND ref = ?', [$uid, $plotId, $kind, $ref]);
}

// ---------- 1. The Curio Cabinet ----------

/** The yard code (decor tables, buildings) for callers that run before a page has loaded it. */
function sink_load(): void
{
    require_once __DIR__ . '/yard.php';
}

const CURIO_SHOP = 'hedge-and-hearth';

/** The ISO week in the Hollow's time, e.g. "2026-W42". Curios rotate when it changes (Monday). */
function curio_week(): string
{
    return hollow_date('o-\WW');
}

/** The week's curios: slugs. The pool (CURIO_DECOR, in yard.php) is dealt out in a shuffled order that changes each cycle, so every curio comes round. */
function curio_slugs(?string $week = null): array
{
    sink_load();
    $pool = array_keys(CURIO_DECOR);
    $n = max(1, min(count($pool), (int)setting('curio_count')));
    $per = (int)ceil(count($pool) / $n);          // weeks in one full cycle
    $idx = $week === null ? (int)hollow_date('o') * 53 + (int)hollow_date('W') : (int)substr($week, 0, 4) * 53 + (int)substr($week, 6);
    $cycle = intdiv($idx, $per);
    usort($pool, fn($a, $b) => crc32('curio|' . $cycle . '|' . $a) <=> crc32('curio|' . $cycle . '|' . $b));
    return array_slice($pool, ($idx % $per) * $n, $n);
}

/** Seconds until the curios change (Monday 00:00 in the Hollow). */
function curio_reset_in(): int
{
    $now = new DateTimeImmutable('@' . time());
    $next = $now->setTimezone(hollow_tz())->modify('monday next week')->setTime(0, 0);
    return max(60, $next->getTimestamp() - time());
}

/** This week's curios as rows: item, price, appeal, size, and how many this gnome has bought. */
function curio_stock(int $uid): array
{
    $week = curio_week();
    $bought = [];
    foreach (q('SELECT slug, qty FROM curio_buys WHERE user_id = ? AND week = ?', [$uid, $week])->fetchAll() as $r) $bought[$r['slug']] = (int)$r['qty'];
    $pct = max(1, (int)setting('curio_price_pct'));
    $limit = max(1, (int)setting('curio_item_limit'));
    $out = [];
    foreach (curio_slugs() as $slug) {
        $it = q_one("SELECT * FROM items WHERE slug = ? AND category = 'decor'", [$slug]);
        if (!$it) continue;
        $def = decor_def($it) ?? ['icon' => '🏡', 'appeal' => 0, 'w' => 1, 'h' => 1];
        $out[] = ['item' => $it, 'def' => $def, 'price' => max(1, (int)round((int)$it['base_price'] * $pct / 100)),
            'bought' => $bought[$slug] ?? 0, 'left' => max(0, $limit - ($bought[$slug] ?? 0)), 'limit' => $limit];
    }
    return $out;
}

function curio_buy(array $u, array $shop, string $slug): array
{
    $uid = (int)$u['id'];
    if (!shop_reachable($u, $shop)) return [false, 'You need to be in that town to shop here.'];
    if (!staff_on_duty((int)$shop['id'])) return [false, 'Nobody is at the counter right now.'];
    $row = null;
    foreach (curio_stock($uid) as $r) if ($r['item']['slug'] === $slug) $row = $r;
    if (!$row) return [false, 'That curio isn’t in the cabinet this week.'];
    if ($row['left'] < 1) return [false, 'You’ve already bought your ' . $row['item']['name'] . ' this week. The cabinet restocks on Monday.'];
    $week = curio_week();
    db()->beginTransaction();
    try {
        $changed = q('UPDATE curio_buys SET qty = qty + 1 WHERE user_id = ? AND week = ? AND slug = ? AND qty < ?', [$uid, $week, $slug, $row['limit']])->rowCount();
        if ($changed !== 1) {
            if (q_val('SELECT 1 FROM curio_buys WHERE user_id = ? AND week = ? AND slug = ?', [$uid, $week, $slug])) { db()->rollBack(); return [false, 'You’ve bought your limit of those this week.']; }
            db_insert('curio_buys', ['user_id' => $uid, 'week' => $week, 'slug' => $slug, 'qty' => 1]);
        }
        if (!sink_pay($uid, $row['price'])) { db()->rollBack(); return [false, 'You can’t afford the ' . $row['item']['name'] . ' (' . number_format($row['price']) . ' ' . setting('currency_name') . ').']; }
        give_item($uid, (int)$row['item']['id'], 1);
        db()->commit();
    } catch (PDOException $e) {
        if (db()->inTransaction()) db()->rollBack();
        return [false, 'Someone else got there first. Try again.'];
    }
    return [true, '🗝️ The shopkeeper unlocks the cabinet. You buy a ' . $row['item']['name'] . ' for ' . number_format($row['price']) . ' ' . setting('currency_name') . '. Place it with ✏️ Design yard.'];
}

// ---------- 2. Building skins ----------

// skin => [name, badge, what it looks like]
const SKIN_DEFS = [
    'mossy'   => ['Mossy', '🌿', 'Moss creeping up the walls.'],
    'painted' => ['Painted', '🎨', 'A fresh coat of cheerful paint.'],
    'lantern' => ['Lantern-lit', '🏮', 'Little lanterns hung all round.'],
];
// building => the skins it can wear (2-3 each)
const BUILDING_SKINS = [
    'kitchen' => ['mossy', 'painted', 'lantern'], 'rain_barrel' => ['mossy', 'painted'], 'tool_shed' => ['mossy', 'painted', 'lantern'],
    'compost_bin' => ['mossy', 'painted'], 'beehive' => ['painted', 'lantern'], 'greenhouse' => ['mossy', 'painted', 'lantern'],
    'root_cellar' => ['mossy', 'lantern'],
];

function skin_price(string $skin): int
{
    $i = (int)array_search($skin, array_keys(SKIN_DEFS), true);
    return sink_ints('skin_prices', [1500, 2500, 4000])[$i];
}

function skin_appeal(string $skin): int
{
    $i = (int)array_search($skin, array_keys(SKIN_DEFS), true);
    return sink_ints('skin_appeal', [1, 2, 3])[$i];
}

function skin_valid(string $building, string $skin): bool
{
    return in_array($skin, BUILDING_SKINS[$building] ?? [], true);
}

/** The picture for a skin if art has been dropped in (assets/img/skins/{building}-{skin}.png), else ''. */
function skin_image(string $building, string $skin, bool $ph = false): string
{
    foreach (['uploads/skins/', 'assets/img/skins/'] as $dir) {   // v0.9.8: Admin → Images saves into uploads/skins/
        $rel = $dir . $building . '-' . $skin . '.png';
        if (art_path($rel) !== '') return $rel;
    }
    return $ph ? ph_path($building . '-' . $skin) : '';   // v1.5.2: placeholder
}

/** building => skin worn, for one garden. */
function skin_map(int $plotId): array
{
    $out = [];
    foreach (q('SELECT building, skin FROM garden_buildings WHERE plot_id = ? AND skin IS NOT NULL', [$plotId])->fetchAll() as $r) {
        if (skin_valid((string)$r['building'], (string)$r['skin'])) $out[$r['building']] = (string)$r['skin'];
    }
    return $out;
}

function skin_refresh_appeal(int $plotId): void
{
    q('UPDATE plots SET appeal = ? WHERE id = ?', [yard_appeal($plotId), $plotId]);
}

function skin_buy(array $u, int $plotId, string $b, string $skin): array
{
    sink_load();
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]) || !building_level($plotId, $b)) return [false, 'You haven’t built that here.'];
    if (!skin_valid($b, $skin)) return [false, 'That building doesn’t come in that look.'];
    $price = skin_price($skin);
    db()->beginTransaction();
    if (!sink_own($uid, 'skin', $b . ':' . $skin)) { db()->rollBack(); return [false, 'You already own that look. Choose it instead.']; }
    if (!sink_pay($uid, $price)) { db()->rollBack(); return [false, 'You can’t afford the ' . SKIN_DEFS[$skin][0] . ' look (' . number_format($price) . ' ' . setting('currency_name') . ').']; }
    q('UPDATE garden_buildings SET skin = ? WHERE plot_id = ? AND building = ?', [$skin, $plotId, $b]);
    db()->commit();
    skin_refresh_appeal($plotId);
    return [true, SKIN_DEFS[$skin][1] . ' Your ' . strtolower(BUILDINGS[$b][0]) . ' is now ' . strtolower(SKIN_DEFS[$skin][0]) . ' (' . number_format($price) . ' ' . setting('currency_name') . '). Yours to use on any of your ' . strtolower(BUILDINGS[$b][0]) . 's.'];
}

/** Wear a skin you own on this garden's building ('' = plain). */
function skin_use(array $u, int $plotId, string $b, string $skin): array
{
    sink_load();
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]) || !building_level($plotId, $b)) return [false, 'You haven’t built that here.'];
    if ($skin !== '' && (!skin_valid($b, $skin) || !sink_owns($uid, 'skin', $b . ':' . $skin))) return [false, 'You don’t own that look yet.'];
    q('UPDATE garden_buildings SET skin = ? WHERE plot_id = ? AND building = ?', [$skin === '' ? null : $skin, $plotId, $b]);
    skin_refresh_appeal($plotId);
    return [true, $skin === '' ? 'Your ' . strtolower(BUILDINGS[$b][0]) . ' is plain again.' : 'Your ' . strtolower(BUILDINGS[$b][0]) . ' is now ' . strtolower(SKIN_DEFS[$skin][0]) . '.'];
}

/** The "Looks" section inside a built building's details in the buildings panel. */
function skin_panel_html(array $u, array $plot, string $b, ?string $worn): string
{
    if (empty(BUILDING_SKINS[$b])) return '';
    $uid = (int)$u['id'];
    $h = '<div class="skinbox"><b>🎨 Looks</b> <span class="muted">(bought once, then yours; +' . implode('/+', array_map(fn($s) => skin_appeal($s), BUILDING_SKINS[$b])) . ' curb appeal)</span><div class="skinrow">';
    $form = fn(string $do, string $skin, string $label, string $cls) => '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="' . $do . '">'
        . '<input type="hidden" name="building" value="' . e($b) . '"><input type="hidden" name="skin" value="' . e($skin) . '"><button class="btn small ' . $cls . '">' . $label . '</button></form>';
    $h .= $worn === null || $worn === '' ? '<span class="skinpick on">Plain ✔</span>' : $form('skin_use', '', 'Plain', 'alt');
    foreach (BUILDING_SKINS[$b] as $skin) {
        [$name, $badge] = SKIN_DEFS[$skin];
        if ($worn === $skin) $h .= '<span class="skinpick on">' . $badge . ' ' . e($name) . ' ✔</span>';
        elseif (sink_owns($uid, 'skin', $b . ':' . $skin)) $h .= $form('skin_use', $skin, $badge . ' ' . e($name), 'alt');
        else $h .= $form('skin_buy', $skin, $badge . ' ' . e($name) . ' · ' . money(skin_price($skin)), '');
    }
    return $h . '</div></div>';
}

// ---------- 3. Garden signposts ----------

// style => [name, icon, look]
const SIGN_STYLES = [
    'oak'    => ['Oak plank', '🪵', 'A plain carved oak plank on a post.'],
    'painted' => ['Painted board', '🎨', 'Hand-lettered on a bright painted board.'],
    'iron'   => ['Wrought iron', '⚒️', 'Curly black ironwork with a hanging plate.'],
    'gilded' => ['Gilded', '✨', 'Gold-leaf lettering on dark wood.'],
];

function sign_price(string $style): int
{
    return sink_ints('sign_prices', [1200, 2200, 3600, 6000])[(int)array_search($style, array_keys(SIGN_STYLES), true)];
}

function sign_buy(array $u, int $plotId, string $style): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid])) return [false, 'That isn’t your garden.'];
    if (!isset(SIGN_STYLES[$style])) return [false, 'Pick a sign from the list.'];
    $price = sign_price($style);
    db()->beginTransaction();
    if (!sink_own($uid, 'sign', $style, $plotId)) { db()->rollBack(); return [false, 'This garden already owns that sign. Choose it instead.']; }
    if (!sink_pay($uid, $price)) { db()->rollBack(); return [false, 'You can’t afford that sign (' . number_format($price) . ' ' . setting('currency_name') . ').']; }
    q('UPDATE plots SET sign_style = ? WHERE id = ?', [$style, $plotId]);
    db()->commit();
    return [true, '🪧 Your new ' . strtolower(SIGN_STYLES[$style][0]) . ' sign stands in the yard, and visitors will see your garden’s name on it (' . number_format($price) . ' ' . setting('currency_name') . ').'];
}

/** Put up a sign this garden owns, or take it down ('' = none). */
function sign_use(array $u, int $plotId, string $style): array
{
    $uid = (int)$u['id'];
    if (!q_val('SELECT 1 FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid])) return [false, 'That isn’t your garden.'];
    if ($style !== '' && (!isset(SIGN_STYLES[$style]) || !sink_owns($uid, 'sign', $style, $plotId))) return [false, 'This garden doesn’t own that sign.'];
    q('UPDATE plots SET sign_style = ? WHERE id = ?', [$style === '' ? null : $style, $plotId]);
    return [true, $style === '' ? 'The sign is taken down (you keep it).' : '🪧 The ' . strtolower(SIGN_STYLES[$style][0]) . ' sign is up.'];
}

/** The sign over the yard (own and visitor views). */
function sign_html(array $plot): string
{
    $s = (string)($plot['sign_style'] ?? '');
    if (!isset(SIGN_STYLES[$s])) return '';
    $name = trim((string)($plot['garden_name'] ?? '')) ?: 'A garden';
    return '<div class="ysign sg-' . e($s) . '" title="' . e(SIGN_STYLES[$s][0] . ' sign') . '"><span class="sgicon" aria-hidden="true">' . SIGN_STYLES[$s][1] . '</span><b>' . e($name) . '</b></div>';
}

function sign_panel_html(array $u, array $plot): string
{
    $uid = (int)$u['id'];
    $pid = (int)$plot['id'];
    $cur = (string)($plot['sign_style'] ?? '');
    $h = '<details class="fold box signfold"><summary>🪧 Signpost' . (isset(SIGN_STYLES[$cur]) ? ': ' . e(SIGN_STYLES[$cur][0]) : '') . '</summary>'
        . '<p class="help">A carved sign with this garden’s name, standing over the yard. Visitors see it too. Each garden buys its own, and you keep the ones you buy.</p>'
        . '<div class="signrow">';
    $form = fn(string $do, string $style, string $label, string $cls) => '<form method="post">' . csrf_field() . '<input type="hidden" name="do" value="' . $do . '">'
        . '<input type="hidden" name="style" value="' . e($style) . '"><button class="btn small ' . $cls . '">' . $label . '</button></form>';
    foreach (SIGN_STYLES as $style => [$name, $icon, $look]) {
        $own = sink_owns($uid, 'sign', $style, $pid);
        $h .= '<div class="signopt' . ($cur === $style ? ' on' : '') . '"><b>' . $icon . ' ' . e($name) . '</b><span class="help">' . e($look) . '</span>'
            . ($cur === $style ? $form('sign_use', '', 'Take down', 'alt')
              : ($own ? $form('sign_use', $style, 'Put up', 'alt') : $form('sign_buy', $style, 'Buy · ' . money(sign_price($style)), ''))) . '</div>';
    }
    return $h . '</div></details>';
}

// ---------- 4. Hat and beard dyes ----------

// part => tier => [colour => name]. Tier prices are the setting dye_prices (tier 1, 2, 3).
const DYES = [
    'hat' => [
        1 => ['#e75480' => 'Peony pink', '#20a39e' => 'Teal pool', '#8fbc3a' => 'Lime shoot', '#c46a2d' => 'Marmalade'],
        2 => ['#b8325a' => 'Burgundy', '#00897b' => 'Kingfisher', '#5e35b1' => 'Amethyst', '#e8572a' => 'Ember'],
        3 => ['#d4af37' => 'Gold leaf', '#0f1b3d' => 'Midnight ink', '#bfeaf5' => 'Frostglass', '#7a1f3d' => 'Wine velvet'],
    ],
    'beard' => [
        1 => ['#e6b8a2' => 'Blush', '#8aa17c' => 'Sage', '#7a5c99' => 'Lilac'],
        2 => ['#2a9d8f' => 'Seaglass', '#c1440e' => 'Fox red', '#4361ee' => 'Cornflower'],
        3 => ['#d4af37' => 'Gold', '#9ff0e0' => 'Aurora', '#ff4fa3' => 'Hot peony'],
    ],
];
const DYE_TIER_NAMES = [1 => 'Garden dyes', 2 => 'Rare dyes', 3 => 'Gilded dyes'];

/** [tier, name] of a dye colour for a part, or null if it isn't one. */
function dye_info(string $part, string $color): ?array
{
    foreach (DYES[$part] ?? [] as $tier => $list) if (isset($list[$color])) return [$tier, $list[$color]];
    return null;
}

function dye_valid(string $part, string $color): bool
{
    return dye_info($part, $color) !== null;
}

function dye_price(int $tier): int
{
    return sink_ints('dye_prices', [800, 2500, 6000])[max(1, min(3, $tier)) - 1];
}

function dye_buy(array $u, string $part, string $color): array
{
    $uid = (int)$u['id'];
    $color = strtolower($color);
    $info = dye_info($part, $color);
    if (!$info) return [false, 'The Dye Pot doesn’t stock that colour.'];
    $price = dye_price($info[0]);
    db()->beginTransaction();
    if (!sink_own($uid, 'dye', $part . ':' . $color)) { db()->rollBack(); return [false, 'You already own ' . $info[1] . '. Pick it on My Gnome.']; }
    if (!sink_pay($uid, $price)) { db()->rollBack(); return [false, 'You can’t afford ' . $info[1] . ' (' . number_format($price) . ' ' . setting('currency_name') . ').']; }
    db()->commit();
    return [true, '🎨 You buy a pot of ' . $info[1] . ' ' . $part . ' dye for ' . number_format($price) . ' ' . setting('currency_name') . '. Try it on My Gnome.'];
}

/** Wear a dye you own ('none' takes the hat dye off; for beards, a starting colour also works). */
function dye_use(array $u, string $part, string $color): array
{
    $uid = (int)$u['id'];
    $color = strtolower($color);
    if ($part === 'hat') {
        if ($color === 'none') { q('UPDATE users SET hat_dye = NULL WHERE id = ?', [$uid]); return [true, 'Your hat goes back to its usual colour.']; }
        if (!dye_valid('hat', $color) || !sink_owns($uid, 'dye', 'hat:' . $color)) return [false, 'You don’t own that hat dye.'];
        q('UPDATE users SET hat_dye = ? WHERE id = ?', [$color, $uid]);
        return [true, '🎩 Your hat is now ' . dye_info('hat', $color)[1] . '.'];
    }
    if ($part === 'beard') {
        if (isset(BEARD_COLORS[$color])) { q('UPDATE users SET beard_color = ? WHERE id = ?', [$color, $uid]); return [true, '🧔 Your beard is now ' . BEARD_COLORS[$color] . '.']; }
        if (!dye_valid('beard', $color) || !sink_owns($uid, 'dye', 'beard:' . $color)) return [false, 'You don’t own that beard dye.'];
        q('UPDATE users SET beard_color = ? WHERE id = ?', [$color, $uid]);
        return [true, '🧔 Your beard is now ' . dye_info('beard', $color)[1] . '.'];
    }
    return [false, 'Hat or beard?'];
}

function dye_swatch(string $color, int $r = 11): string
{
    return '<svg width="' . ($r * 2) . '" height="' . ($r * 2) . '" viewBox="0 0 ' . ($r * 2) . ' ' . ($r * 2) . '" aria-hidden="true">'
        . '<circle cx="' . $r . '" cy="' . $r . '" r="' . ($r - 1) . '" fill="' . e($color) . '" stroke="#6b4a2b" stroke-width="1"/></svg>';
}

/** The "Dye your gnome" box on My Gnome: pick among the dyes you own. */
function dye_editor_html(array $u): string
{
    $uid = (int)$u['id'];
    $own = array_fill_keys(q("SELECT ref FROM sink_owned WHERE user_id = ? AND kind = 'dye'", [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
    $hatNow = (string)($u['hat_dye'] ?? '');
    $beardNow = (string)($u['beard_color'] ?? '');
    $radio = fn(string $part, string $val, string $name, bool $on, bool $live = true) => '<label title="' . e($name) . '"><input type="radio" name="' . $part . '" value="' . e($val) . '"'
        . ($live ? ' data-part="' . $part . '"' : '') . ($on ? ' checked' : '') . '> ' . dye_swatch($live ? $val : '#8a8370') . ' <span>' . e($name) . '</span></label>';
    $hat = $radio('hat', 'none', 'No dye', $hatNow === '', false);
    $nHat = 0;
    foreach (DYES['hat'] as $list) foreach ($list as $c => $name) if (isset($own['hat:' . $c])) { $hat .= $radio('hat', $c, $name, $hatNow === $c); $nHat++; }
    $beard = '';
    foreach (BEARD_COLORS as $c => $name) $beard .= $radio('beard', $c, $name, $beardNow === $c);
    $nBeard = 0;
    foreach (DYES['beard'] as $list) foreach ($list as $c => $name) if (isset($own['beard:' . $c])) { $beard .= $radio('beard', $c, $name, $beardNow === $c); $nBeard++; }
    $shop = q_one('SELECT id FROM shops WHERE slug = ?', [DYE_SHOP]);
    return '<details class="fold box dyebox" id="dyes"' . (isset($_GET['dye']) ? ' open' : '') . '><summary>🎨 Hat and beard dyes' . ($nHat + $nBeard ? ' (' . ($nHat + $nBeard) . ' owned)' : '') . '</summary>'
        . '<form method="post" class="form dyeform" data-gnome-preview>' . csrf_field() . '<input type="hidden" name="do" value="dye">'
        . '<div class="avatarcol">' . gnome_avatar_pals($u, 96) . '</div><div>'
        . '<fieldset class="swatches"><legend>Hat</legend>' . $hat . '</fieldset>'
        . ($u['calling'] ? '<p class="help">A hat dye is worn over your calling’s colour.</p>' : '')
        . '<fieldset class="swatches"><legend>Beard</legend>' . $beard . '</fieldset>'
        . '<button class="btn">Dye my gnome</button></div></form>'
        . '<p class="help">' . ($nHat + $nBeard ? '' : 'You don’t own any dyes yet. ') . 'New colours are sold at the '
        . ($shop ? '<a href="' . e(url('shop.php?id=' . (int)$shop['id'])) . '">Dye Pot</a>' : 'Dye Pot') . ' in town: garden dyes, rare dyes and gilded dyes. You keep every pot you buy.</p></details>';
}

// ---------- 5. The shops' panels ----------

/**
 * v2.0.17: a one-click item as a shop tile + sheet with a plain confirm button (no quantity). Wraps shop_tile() (includes/shop_tiles.php).
 * Options: shop_tile's (id, item, price, dim, badge, badgeTitle, mini, tags) plus action, do, fields, verb, open (can buy now), note (shown instead of the button), icon (html replacing the item picture).
 */
function sink_tile(array $o): string
{
    require_once __DIR__ . '/shop_tiles.php';
    $hid = '<input type="hidden" name="do" value="' . e((string)$o['do']) . '">';
    foreach ((array)($o['fields'] ?? []) as $k => $v) $hid .= '<input type="hidden" name="' . e((string)$k) . '" value="' . e((string)$v) . '">';
    if (!empty($o['open'])) {
        $info = '<form method="post" class="confirmform" action="' . e((string)$o['action']) . '">' . csrf_field() . $hid
            . '<p class="sline"><b>' . money((int)$o['price']) . '</b></p><button class="btn sgo">' . e((string)($o['verb'] ?? 'Buy')) . '</button></form>';
    } else {
        $info = '<p class="sown">' . (($o['note'] ?? '') !== '' ? e((string)$o['note']) : 'Not at the counter right now.') . '</p>';
    }
    $o['info'] = $info;
    $o['open'] = false;
    $o['max'] = 1;
    if (!empty($o['dim']) && ($o['note'] ?? '') !== '' && !isset($o['offNote'])) $o['offNote'] = (string)$o['note'];   // v2.0.67: on the tile too
    return shop_tile($o);   // v2.0.67: shop_tile takes 'icon' itself (tile and sheet)
}


const DYE_SHOP = 'the-dye-pot';

/** Which special panel a shop has: 'curio', 'dye' or ''. */
function sink_shop_kind(array $shop): string
{
    return ($shop['slug'] ?? '') === CURIO_SHOP ? 'curio' : (($shop['slug'] ?? '') === DYE_SHOP ? 'dye' : '');
}

/** A POST from a shop's special panel. */
function sink_shop_post(array $u, array $shop, string $do, bool $reachable): array
{
    $kind = sink_shop_kind($shop);
    if ($kind === '') return [false, 'This shop doesn’t sell that.'];
    if (!$reachable) return [false, 'You need to be in that town to shop here.'];
    if (!staff_on_duty((int)$shop['id'])) return [false, 'Nobody is at the counter right now.'];
    if ($kind === 'curio' && $do === 'sink_curio') return curio_buy($u, $shop, (string)($_POST['slug'] ?? ''));
    if ($kind === 'dye' && $do === 'sink_dye') return dye_buy($u, (string)($_POST['part'] ?? ''), (string)($_POST['color'] ?? ''));
    return [false, 'This shop doesn’t sell that.'];
}

/** The ways to spend Petals, for shop help text. */
function sink_help_html(): string
{
    return '<details class="helpfold"><summary>❓ More ways to spend Petals</summary><ul class="help">'
        . '<li>🗝️ <b>Curio Cabinet</b> (Hedge &amp; Hearth): five rare yard pieces that change every Monday.</li>'
        . '<li>🎨 <b>Building looks</b>: Garden page → Garden buildings → tap a building.</li>'
        . '<li>🪧 <b>Signposts</b>: Garden page → Signpost, one per garden.</li>'
        . '<li>🎩 <b>Hat and beard dyes</b>: the Dye Pot, then My Gnome → Hat and beard dyes.</li>'
        . '<li>🍳 <b>Regional feasts</b>: need a level 3 Kitchen and treasure crops from far regions.</li></ul></details>';
}

function sink_shop_panel(array $u, array $shop, bool $open): string
{
    $kind = sink_shop_kind($shop);
    if ($kind === '') return '';
    $uid = (int)$u['id'];
    $action = e(url('shop.php?id=' . (int)$shop['id']));
    $h = '';
    require_once __DIR__ . '/shop_tiles.php';   // v2.0.17: same picture tiles + sheet as the other shops
    if ($kind === 'curio') {
        $stock = curio_stock($uid);
        $h .= '<section class="box curios" id="curios"><h2>🗝️ The Curio Cabinet</h2>'
            . '<p class="help">Rare pieces for a fine yard. Changes in <b>' . e(nice_time(curio_reset_in())) . '</b> (Mondays). Up to '
            . (int)setting('curio_item_limit') . ' of each a week.</p><div class="shopwrap"><div class="itmwrap"><div class="itms">';
        foreach ($stock as $r) {
            $it = $r['item'];
            $sold = $r['left'] < 1;
            $it['description'] = trim((string)preg_replace('/ Place it in your yard.*$/', '', (string)$it['description']));
            $h .= sink_tile(['id' => (int)$it['id'], 'item' => $it, 'price' => (int)$r['price'], 'action' => $action, 'verb' => 'Buy', 'do' => 'sink_curio',
                'fields' => ['slug' => $it['slug']], 'open' => $open && !$sold, 'dim' => $sold, 'coins' => $open ? (int)$u['coins'] : null, 'badge' => $sold ? '✔' : '', 'badgeTitle' => 'Bought',
                'note' => $sold ? '✔ Limit bought this week' : '', 'offNote' => $sold ? '✔ Bought' : '', 'mini' => '🌼+' . (int)$r['def']['appeal'],
                'tags' => ['<span class="tag">🌼 +' . (int)$r['def']['appeal'] . ' appeal</span>', '<span class="tag">' . (int)$r['def']['w'] . '×' . (int)$r['def']['h'] . '</span>']]);
        }
        if (!$stock) $h .= '<p class="muted">The cabinet is empty this week.</p>';
        $h .= '</div></div></div></section>';
    } else {
        $own = array_fill_keys(q("SELECT ref FROM sink_owned WHERE user_id = ? AND kind = 'dye'", [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
        $h .= '<section class="box dyes" id="dyepots"><h2>🎨 Dye pots</h2>'
            . '<p class="help">Buy a pot once; the colour is yours. Pick it on <a href="' . e(url('gnome.php?dye=1#dyes')) . '">My Gnome</a>.</p>';
        foreach (DYE_TIER_NAMES as $tier => $tname) {
            $h .= '<h3>' . e($tname) . ' <small class="muted">' . money(dye_price($tier)) . ' a pot</small></h3><div class="shopwrap"><div class="itmwrap"><div class="itms">';
            foreach (['hat' => '🎩 Hat', 'beard' => '🧔 Beard'] as $part => $plabel) {
                foreach (DYES[$part][$tier] as $c => $name) {
                    $have = isset($own[$part . ':' . $c]);
                    $h .= sink_tile(['id' => 0, 'item' => ['id' => 0, 'slug' => '', 'name' => $name, 'category' => 'other', 'description' => '', 'rarity' => [1 => 1, 2 => 30, 3 => 60][$tier]],
                        'price' => dye_price($tier), 'action' => $action, 'verb' => 'Buy', 'do' => 'sink_dye', 'fields' => ['part' => $part, 'color' => $c],
                        'open' => $open && !$have, 'dim' => $have, 'coins' => $open ? (int)$u['coins'] : null, 'badge' => $have ? '✔' : '', 'badgeTitle' => 'Owned', 'note' => $have ? '✔ Owned' : '',
                        'mini' => mb_substr($plabel, 0, 2), 'tags' => ['<span class="tag">' . e($plabel) . '</span>'], 'icon' => dye_swatch($c, 24)]);
                }
            }
            $h .= '</div></div></div>';
        }
        $h .= '</section>';
    }
    return $h . sink_help_html();
}

// ---------- Install / upgrade ----------

const SINKS_ALMANAC = "When your Petals pile up, there is plenty to spend them on. All of it is for looks and comfort: none of it changes your stats.\n\n"
    . "[b]🗝️ The Curio Cabinet[/b] at the Hedge & Hearth (Mossbottom Market) holds a handful of rare yard pieces that change every Monday. Each is worth more curb appeal than ordinary decor, and you can buy one of each per week.\n"
    . "[b]🎨 Building looks:[/b] on the Garden page, open Garden buildings and tap a building to give it a Mossy, Painted or Lantern-lit look. Buy a look once and you can use it on that building in any of your gardens. Each look adds a little curb appeal.\n"
    . "[b]🪧 Signposts:[/b] each garden can have a carved sign with its name, standing over the yard where visitors see it. Choose a style under Signpost on the Garden page.\n"
    . "[b]🎩 Hat and beard dyes:[/b] the Dye Pot at Mossbottom Market sells garden, rare and gilded dyes. Pick the ones you own on My Gnome. A hat dye is worn over your calling's colour.\n"
    . "[b]🍳 Regional feasts:[/b] eight grand dishes (one for each of eight regions) that need a level 3 Kitchen and one or two treasure crops from far-off regions.";

/**
 * v0.9.7 part B: Petal sinks. The tables and columns come from schema.php; this adds the curio decor items (ensure_decor_items), a line
 * on the Hedge & Hearth, the Dye Pot shop (three keepers, round the clock), and the Almanac page. The new feasts arrive with
 * ensure_crafts (recipes.txt). Idempotent: nothing that exists is changed.
 */
function upgrade_097_sinks(): void
{
    sink_load();
    ensure_decor_items();
    $hh = q_one('SELECT id, description FROM shops WHERE slug = ?', [CURIO_SHOP]);
    if ($hh && !str_contains((string)$hh['description'], 'Curio')) {
        q('UPDATE shops SET description = ? WHERE id = ?', [rtrim((string)$hh['description']) . ' Its locked Curio Cabinet holds rare pieces that change every Monday.', $hh['id']]);
    }
    $hub = (int)q_val("SELECT id FROM locations WHERE kind = 'hub' ORDER BY id LIMIT 1");
    if ($hub && !q_val('SELECT 1 FROM shops WHERE slug = ?', [DYE_SHOP])) {
        $shopId = db_insert('shops', ['name' => 'The Dye Pot', 'slug' => DYE_SHOP, 'location_id' => $hub, 'shop_type' => 'dyes', 'restock_minutes' => 60,
            'description' => 'Steaming vats of hat and beard dye in every colour of the Hollow. Buy a pot once and the colour is yours for good; pick it on My Gnome.']);
        $meadow = (int)q_val("SELECT id FROM locations WHERE slug = 'whispering-meadow'") ?: $hub;
        $burrows = (int)q_val("SELECT id FROM locations WHERE slug = 'rootling-burrows'") ?: $hub;
        $staff = [['Madder Quillfeather', 'Mouse', 'Cheerful', 'Stirs the vats at dawn. Always has at least one blue paw.'],
            ['Indigo Fennelwick', 'Hedgehog', 'Proud', 'Can name a hundred shades of green and thinks you should learn them.'],
            ['Woad', 'Moth', 'Dreamy', 'Works the night shift, dyeing wool by moonlight. Says moonlit colours keep better.']];
        foreach ($staff as $k => [$name, $species, $pers, $bio]) {
            $slug = slugify($name);
            $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$slug]);
            if (!$nid) $nid = db_insert('npcs', ['name' => $name, 'slug' => $slug, 'species' => $species, 'personality' => $pers, 'bio' => $bio, 'home_location_id' => $burrows]);
            [$s, $eh] = [[6, 14], [14, 22], [22, 6]][$k];
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $hub, 'shop_id' => $shopId, 'activity' => 'working', 'start_hour' => $s, 'end_hour' => $eh]);
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $meadow, 'shop_id' => null, 'activity' => 'wandering', 'start_hour' => $eh, 'end_hour' => ($eh + 3) % 24]);
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $burrows, 'shop_id' => null, 'activity' => 'resting', 'start_hour' => ($eh + 3) % 24, 'end_hour' => $s]);
        }
    }
    $title = 'Spending your Petals';
    if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE chapter = ? AND title = ?', ['General', $title])) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => $title, 'body' => SINKS_ALMANAC,
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 12]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
}

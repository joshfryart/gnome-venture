<?php
declare(strict_types=1);

/**
 * Gathering on adventures. On a "find" space the gnome gathers something from the landscape, as long as
 * they carry the right gathering tool. Tool tier sets what can be found (1 common, 2 uncommon, 3 rare);
 * a gathering basket and Sense bring home extra. No tool = a hint about what they could have gathered.
 */

require_once __DIR__ . '/tools.php';
require_once __DIR__ . '/adventure_data.php';   // v0.7.80: LANDSCAPES for the Gather here box
require_once __DIR__ . '/road_life.php';   // v1.9.3: cond tags (rain brings mushrooms, dusk brings fireflies)

const GATHER_RARITY = ['common' => [1, 60], 'uncommon' => [2, 30], 'rare' => [3, 15]];   // [tool tier needed, weight]

const GATHER_TOOL_NOUN = ['forage' => 'foraging knife', 'pick' => 'rock pick', 'net' => 'bug net', 'bucket' => 'tide bucket', 'axe' => 'axe', 'rod' => 'fishing rod'];   // axe, rod: v0.7.81
const GATHER_CHAPTER = ['forage' => 'Foraging', 'pick' => 'Rocks & Minerals', 'net' => 'Shed by Bugs', 'bucket' => 'Tide Pools', 'axe' => 'Logging', 'rod' => 'Fishing'];   // v0.7.81

/** Add any gatherables from includes/data/gatherables.txt that aren't in the game yet (items, rows, Almanac pages). */
function ensure_gatherables(): int
{
    $added = 0;
    $file = __DIR__ . '/data/gatherables.txt';
    if (!is_file($file)) return 0;
    foreach (file($file, FILE_IGNORE_NEW_LINES) as $line) {
        $line = trim($line);
        if ($line === '' || $line[0] === '#') continue;
        $f = array_map('trim', explode('|', $line));
        if (count($f) < 8) continue;
        [$slug, $name, $lands, $tool, $rarity, $price, $stat, $desc] = $f;
        $cond = $f[8] ?? '';   // v1.9.3: optional last column: when it turns up more often (or "!" = only then)
        if (!isset(TOOL_TYPES[$tool]) || !isset(GATHER_RARITY[$rarity])) continue;
        $itemId = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if (!$itemId) {
            $edible = $stat !== '-' && isset(GNOME_STATS_KEYS[$stat]);
            $itemId = db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'forage',
                'rarity' => ['common' => 15, 'uncommon' => 35, 'rare' => 70][$rarity], 'base_price' => (int)$price,
                'description' => $desc, 'edible' => $edible ? 1 : 0,
                'effects' => $edible ? json_encode(['temp' => [$stat => 1, 'minutes' => 60]]) : null]);   // v0.7.86: raw finds give no energy
            $added++;
        }
        if (!q_val('SELECT 1 FROM gatherables WHERE item_id = ?', [$itemId])) {
            db_insert('gatherables', ['item_id' => $itemId, 'landscapes' => $lands, 'tool' => $tool, 'rarity' => $rarity, 'cond' => $cond !== '' ? $cond : null]);
        }
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['gather:' . $slug])) {
            $where = implode(', ', array_map('ucfirst', array_map('trim', explode(',', $lands))));
            $need = TOOL_TIERS[GATHER_RARITY[$rarity][0]] . ' ' . strtolower(TOOL_TYPES[$tool][0]) . ' tool or better';
            db_insert('encyclopedia_entries', ['chapter' => 'Gathering', 'category' => GATHER_CHAPTER[$tool] ?? 'Gathering',
                'title' => $name, 'body' => $desc . "\n\n[b]Found in:[/b] $where · [b]Rarity:[/b] $rarity · [b]Needs:[/b] $need",
                'unlock_key' => 'gather:' . $slug, 'hint' => "Gather it on an adventure ($where).",
                'sort_order' => GATHER_RARITY[$rarity][0]]);
        }
    }
    return $added;
}

const GNOME_STATS_KEYS = ['grit' => 1, 'nimble' => 1, 'hardiness' => 1, 'lore' => 1, 'sense' => 1, 'charm' => 1, 'luck' => 1];

/**
 * v0.7.80: every active gatherable that turns up in this landscape, optionally only those for one tool type.
 * The item rows are read once per request.
 */
function gather_candidates(string $land, ?string $tool = null): array
{
    static $all = null;
    $all ??= q("SELECT g.*, i.name, i.slug FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1")->fetchAll();
    return array_values(array_filter($all, fn($g) => ($tool === null || $g['tool'] === $tool)
        && ($g['landscapes'] === 'any' || in_array($land, array_map('trim', explode(',', $g['landscapes'])), true))));
}

/**
 * Try to gather something in this landscape. Returns a journal line, or null if there's nothing to gather
 * here (then the caller gives an ordinary find). Without the right tool it sometimes returns a hint instead.
 * v0.7.80: $tool limits the search to gatherables that tool type finds; $sure always gives the hint when nothing can be gathered.
 * v2.0.67: no mini-game bands any more: one find a try (basket, Sense and a rainbow still add), the tool always wears.
 * $found gets [slug, name, rarity, qty, icon, tool, item_id] when something was gathered (for the satchel reveal).
 */
function gather_on_walk(array $u, string $land, ?string $tool = null, bool $sure = false, ?array &$found = null): ?string
{
    $found = null;
    $uid = (int)$u['id'];
    $here = gather_candidates($land, $tool);
    if (!$here) return null;
    $can = [];
    $missing = [];
    foreach ($here as $g) {
        $need = GATHER_RARITY[$g['rarity']][0] ?? 1;
        if (tool_tier($uid, $g['tool']) >= $need) $can[] = $g;
        else $missing[] = $g;
    }
    if (!$can) {
        if (!$missing || (!$sure && random_int(1, 100) > 40)) return null;
        $g = $missing[array_rand($missing)];
        $have = tool_tier($uid, $g['tool']);
        $tool = GATHER_TOOL_NOUN[$g['tool']] ?? 'tool';
        return '👀 You spot ' . $g['name'] . ', but you’d need ' . ($have ? 'a better ' . $tool : an($tool)) . ' to gather it.';
    }
    // Weighted pick: common things turn up most; Luck nudges rarer ones up.
    $luck = max(0, function_exists('eff_mod') ? eff_mod($u, 'luck') : 0);
    $palG = 0;
    if (setting('ppal_party') === '1') { require_once __DIR__ . '/puzzle_pals.php'; $palG = ppal_perks($u)['gather']; }
    $total = 0;
    $weights = [];
    $now = road_now();   // v1.9.3: the weather and time of day lean the pick (x3); a "!" cond is a must. Never changes what a find is worth.
    foreach ($can as $k => $g) {
        $cw = road_cond_weight($g, $now);
        if ($cw <= 0) continue;
        $w = GATHER_RARITY[$g['rarity']][1] + ($g['rarity'] !== 'common' ? 3 * $luck : 0);
        if ($g['rarity'] === 'rare' && $palG > 0) $w = (int)round($w * (1 + $palG / 100));   // v2.0.88: the Puzzle Pals gather perk (+1% per unit, cap +6%)
        $w = max(1, (int)round($w * $cw));
        $weights[$k] = $w;
        $total += $w;
    }
    if (!$weights) { foreach ($can as $k => $g) { $weights[$k] = 1; $total++; } }
    $roll = random_int(1, max(1, $total));
    $pick = null;
    foreach ($weights as $k => $w) {
        $roll -= $w;
        if ($roll <= 0) { $pick = $can[$k]; break; }
    }
    $pick ??= reset($can);
    $qty = 1;
    $basket = tool_tier($uid, 'basket');
    if ($basket > 0 && random_int(1, 3) <= min(3, $basket)) $qty++;
    $sense = function_exists('eff_mod') ? eff_mod($u, 'sense') : 0;
    if ($sense > 0 && random_int(1, 100) <= 5 * $sense) $qty++;
    $rainbow = q_val('SELECT ev_gather_until FROM users WHERE id = ?', [$uid]);
    if ($rainbow && strtotime($rainbow . ' UTC') > time()) $qty *= 2;   // a rainbow (v0.7.31)
    give_item($uid, (int)$pick['item_id'], $qty);
    if (function_exists('job_event')) job_event($uid, 'gather', (string)$pick['slug'], $qty);
    $line = (TOOL_TYPES[$pick['tool']][1] ?? '🧺') . ' You gather ' . $qty . ' × ' . $pick['name'] . ($pick['rarity'] === 'rare' ? ' (rare!)' : '') . '.';
    if (unlock_entries($uid, 'gather:' . $pick['slug'])) $line .= ' 📖 New Almanac page!';
    // Now and then, point out something a missing or better tool would have found here.
    if ($missing && random_int(1, 100) <= 25) {
        $m = $missing[array_rand($missing)];
        $tool = GATHER_TOOL_NOUN[$m['tool']] ?? 'tool';
        $line .= ' 👀 You also spot ' . $m['name'] . ', but you’d need ' . (tool_tier($uid, $m['tool']) ? 'a better ' : 'a ') . $tool . '.';
    }
    // v0.7.86: the tool that made the find wears a little (a missed try never gets here, so it costs nothing)
    if ($wear = tool_use($uid, (string)$pick['tool'])) $line .= ' ' . $wear;
    $found = ['slug' => (string)$pick['slug'], 'name' => (string)$pick['name'], 'rarity' => (string)$pick['rarity'], 'qty' => $qty,
        'icon' => gather_art_path((int)$pick['item_id'], (string)$pick['slug']), 'tool' => (string)$pick['tool'], 'item_id' => (int)$pick['item_id']];
    return $line;
}

/**
 * v0.7.80: the gathering tools that find something in this land. [tool, icon, label, has (carried), count of finds].
 * Tool types added to GATHER_TOOL_NOUN later appear here on their own.
 */
function gather_here_tools(array $u, string $land): array
{
    $uid = (int)$u['id'];
    $out = [];
    foreach (GATHER_TOOL_NOUN as $tool => $noun) {
        $cands = gather_candidates($land, $tool);
        $count = count($cands);
        if ($count < 1) continue;
        // v0.7.85: "has" means the tool's tier meets the lowest tier needed by something here (same test as gather_here)
        $least = min(array_map(fn($g) => GATHER_RARITY[$g['rarity']][0] ?? 1, $cands));
        $tier = tool_tier($uid, $tool);
        $out[] = ['tool' => $tool, 'icon' => TOOL_TYPES[$tool][1] ?? '🧺', 'label' => TOOL_TYPES[$tool][0] ?? $tool,
            'has' => $tier >= $least, 'carried' => $tier >= 1, 'least' => $least, 'count' => $count];
    }
    return $out;
}

/**
 * v0.7.80: gather on purpose, from a road stop, a place or a step off the path. Costs 1 energy a try.
 * Returns [ok, journal line]. With a good enough tool it always turns something up.
 * v2.0.67: the find is also kept for the satchel reveal (gather_reveal_take), shown once on the next Gather box.
 */
function gather_here(array $u, string $land, string $tool): array
{
    $uid = (int)$u['id'];
    $noun = GATHER_TOOL_NOUN[$tool] ?? null;
    if ($noun === null || !gather_candidates($land, $tool)) return [false, 'There’s nothing to find here with that.'];
    if (tool_tier($uid, $tool) < 1) return [false, 'You need a ' . $noun . ' for that.'];
    $tier = tool_tier($uid, $tool);
    $least = min(array_map(fn($g) => GATHER_RARITY[$g['rarity']][0] ?? 1, gather_candidates($land, $tool)));
    if ($tier < $least) return [false, 'Your ' . $noun . ' isn’t good enough for anything here. You need a ' . (TOOL_TIERS[$least] ?? 'better') . ' one.'];   // no energy spent
    $gFree = random_int(1, 100) <= calling_perk($u, 'gather_free_pct');   // v0.9.1: Wayfinder II+: sometimes free
    if (!$gFree && !spend_energy($uid, 1)) return [false, 'You need 1 energy to gather.'];
    $line = gather_on_walk($u, $land, $tool, true, $found);
    if ($found) gather_reveal_set($found);
    return [true, $line ?? '🧺 You search but find nothing this time.'];
}

// ---------- v2.0.67: the Gather tab satchel (scene, reveal, tool belt, felt cards, finds) ----------

const GATHER_REVEAL_TTL = 300;   // seconds a find waits to be shown; an older one is dropped unseen
const GATHER_RARITY_MARK = ['common' => '●', 'uncommon' => '◆', 'rare' => '★', 'legendary' => '✦'];   // rarity is told by colour, word AND mark
const GATHER_BELT = ['forage', 'net', 'axe', 'basket', 'pick', 'rod', 'bucket'];   // the seven belt slots (owned ones first)

/** Remember the latest find for the satchel reveal (read once by gather_reveal_take). */
function gather_reveal_set(array $find): void
{
    if (session_status() !== PHP_SESSION_ACTIVE) return;
    $_SESSION['gather_reveal'] = array_intersect_key($find, array_flip(['slug', 'name', 'rarity', 'qty', 'icon', 'tool'])) + ['at' => time()];
}

/** The find waiting to be revealed, or null. Reading it clears it, so the reveal plays once. */
function gather_reveal_take(): ?array
{
    if (session_status() !== PHP_SESSION_ACTIVE || !isset($_SESSION['gather_reveal'])) return null;
    $r = $_SESSION['gather_reveal'];
    unset($_SESSION['gather_reveal']);
    if (!is_array($r) || time() - (int)($r['at'] ?? 0) > GATHER_REVEAL_TTL || (string)($r['name'] ?? '') === '') return null;
    return $r;
}

/** An item's picture path (real art first, then the ph/{slug} placeholder), or ''. */
function gather_art_path(int $itemId, string $slug): string
{
    $img = (string)(item_art_map()['id'][$itemId] ?? '');
    $rel = $img === '' ? '' : art_path(str_replace('{shape}', 'straight', $img));
    return $rel !== '' ? $rel : ph_path($slug);
}

/** A same-origin gather art image (assets/img/gather/{file}); decorative unless $alt is given. */
function gather_ui_img(string $file, int $w, int $h, string $cls = 'pix', string $alt = ''): string
{
    return '<img class="' . e($cls) . '" src="' . e(url('assets/img/gather/' . $file)) . '" width="' . $w . '" height="' . $h . '" alt="' . e($alt) . '" decoding="async">';
}

/** The item picture for a find card or the reveal ('' when there is none). Decorative: the name sits next to it. */
function gather_item_img(string $rel, int $px, string $cls): string
{
    if ($rel === '' || art_path($rel) === '') return '';
    return '<img class="' . e($cls) . (str_ends_with($rel, '.png') ? ' pix' : '') . '" src="' . e(url($rel)) . '" width="' . $px . '" height="' . $px . '" alt="" decoding="async">';
}

/** One felt card (shared shape for the Gather tab: art, growing ribbon label, meta chunks). $attrs is trusted markup. */
function gather_card_html(string $art, string $label, array $meta, string $attrs): string
{
    $m = '';
    foreach ($meta as $chunk) $m .= '<span' . (is_array($chunk) ? ' id="' . e($chunk[1]) . '"' : '') . '>' . e(is_array($chunk) ? $chunk[0] : $chunk) . '</span>';
    return '<button ' . $attrs . '><span class="gcard__art">' . $art . '</span>'
        . '<span class="gcard__ribbon"><span class="gcard__label">' . e($label) . '</span></span><span class="gcard__meta">' . $m . '</span></button>';
}

/**
 * v2.0.67: the Gather box as the satchel scene (approved mockup claude/art-variants/mockup2): the scene hero with the
 * last find inside the open satchel (once, CSS-only), a rarity banner, the tool belt, one felt card per tool that finds
 * something here (posts do=gather, tool=... to $action) and the finds grid (??? for things not in the Almanac yet).
 * $hiddenHtml is extra hidden fields; $pick is the tool to mark as picked (the one being sought), if any.
 */
function gather_scene_html(array $u, string $land, string $action, string $hiddenHtml, string $pick = ''): string
{
    $uid = (int)$u['id'];
    $L = LANDSCAPES[$land] ?? ['🌱', ucfirst($land), ''];
    $tools = gather_here_tools($u, $land);
    $find = gather_reveal_take();
    $usable = array_values(array_filter($tools, fn($t) => $t['has']));
    $usableIds = array_column($usable, 'tool');
    $picked = $find && in_array($find['tool'] ?? '', $usableIds, true) ? (string)$find['tool'] : (in_array($pick, $usableIds, true) ? $pick : '');
    $active = $picked !== '' ? $picked : ($usableIds[0] ?? '');

    // the scene: back < flourish < found item < satchel front
    $rar = isset(GATHER_RARITY_MARK[$find['rarity'] ?? '']) ? (string)$find['rarity'] : 'common';
    $item = $find ? gather_item_img((string)($find['icon'] ?? ''), 64, 'aimg aimg-lg gx-item') : '';
    $max = function_exists('max_energy') ? max_energy($u) : 0;
    $h = '<section class="gx gatherbox" aria-label="Gather here"><div class="gx-hero"><div class="gx-stage">'
        . gather_ui_img((isset(LANDSCAPES[$land]) && is_file(__DIR__ . '/../assets/img/gather/scene-' . $land . '.png')) ? 'scene-' . $land . '.png' : 'scene.png', 480, 270, 'gx-scene pix')
        . ($item !== '' ? '<span class="gx-find"><span class="gx-spark gx-spark--' . $rar . '"></span>' . $item . '</span>' : '')
        . gather_ui_img('satchel-front.png', 480, 270, 'gx-front pix') . '</div>'
        . '<ul class="gx-hero__chips"><li class="gx-chip">' . $L[0] . ' ' . e($L[1]) . '</li>'
        . '<li class="gx-chip">⚡ ' . (int)($u['energy'] ?? 0) . ($max > 0 ? ' / ' . $max : '') . '</li></ul></div>';
    if ($find) {
        $tags = '<li class="gx-tag">×' . (int)$find['qty'] . '</li><li class="gx-tag gx-tag--rar">' . GATHER_RARITY_MARK[$rar] . ' ' . e(ucfirst($rar)) . '</li>';
        if (isset(GATHER_TOOL_NOUN[$find['tool'] ?? ''])) $tags .= '<li class="gx-tag">' . e(ucfirst(GATHER_TOOL_NOUN[$find['tool']])) . '</li>';
        $h .= '<div class="gx-banner gx-banner--' . $rar . '" role="status"><p class="gx-banner__kick">Into your satchel</p>'
            . '<p class="gx-banner__name">' . e((string)$find['name']) . '</p><ul class="gx-banner__meta">' . $tags . '</ul></div>';
    }
    if (!$tools) return $h . '<p class="gx-note">Nothing to gather in this land.</p></section>';

    // the tool belt: owned tools first, then locked slots
    $slots = ['own' => '', 'miss' => ''];
    foreach (GATHER_BELT as $t) {
        $tier = tool_tier($uid, $t);
        $name = $t === 'basket' ? 'Gathering pouch' : ucfirst(GATHER_TOOL_NOUN[$t] ?? $t);
        if ($tier < 1) {
            $slots['miss'] .= '<li class="belt__slot is-missing" title="' . e('No ' . strtolower($name) . ' yet') . '">' . gather_ui_img('slot-locked.png', 48, 48)
                . '<span class="vh">' . e('No ' . strtolower($name) . ' yet') . '</span><span class="belt__pips"></span></li>';
            continue;
        }
        $tierName = TOOL_TIERS[$tier] ?? '';
        $name = (string)(best_tool($uid, $t)['name'] ?? $name);
        $pips = '';
        for ($i = 1; $i <= 3; $i++) $pips .= '<span class="belt__pip' . ($i <= $tier ? ' on' : '') . '"></span>';
        $on = $t === $active;
        $inner = gather_ui_img('slot-' . $t . '.png', 48, 48)
            . '<span class="vh">' . e($name . ', ' . $tierName . ($on ? ', in use' : '')) . '</span><span class="belt__pips">' . $pips . '</span>';
        // a tool that finds something here is a button: a click gathers with it (same post as its felt card below)
        if (in_array($t, $usableIds, true)) {
            $inner = '<button type="submit" form="gx-gather-form" class="belt__btn" name="tool" value="' . e($t) . '" title="' . e('Gather with ' . $name . ' · ⚡1') . '">' . $inner . '</button>';
        }
        $slots['own'] .= '<li class="belt__slot' . ($on ? ' is-active' : '') . '" title="' . e($name . ' · ' . $tierName) . '">' . $inner . '</li>';
    }
    $h .= '<h3 class="gx-h gx-h--belt">Your tool belt</h3><ul class="belt">' . $slots['own'] . $slots['miss'] . '</ul>';
    if ($active !== '' && ($best = best_tool($uid, $active))) {
        $left = tool_left_text($uid, $active);
        $h .= '<p class="belt__now"><b>' . e((string)$best['name']) . '</b> · ' . e(TOOL_TIERS[tool_tier($uid, $active)] ?? '') . ($left !== '' ? ' · ' . e($left) : '') . '</p>';
    }

    // one felt card per tool that finds something here
    $cards = '';
    foreach ($tools as $t) {
        $tool = $t['tool'];
        $art = gather_ui_img('vig-' . $tool . '.png', 144, 108);
        if ($t['has']) {
            $meta = ['⚡1'];
            if (($left = tool_left_text($uid, $tool)) !== '') $meta[] = $left;
            $cards .= gather_card_html($art, $t['label'], $meta, 'type="submit" class="gcard" name="tool" value="' . e($tool) . '"' . ($tool === $picked ? ' aria-pressed="true"' : ''));
        } else {
            $why = $t['carried'] ? 'Needs ' . (TOOL_TIERS[$t['least']] ?? 'better') : 'Needs ' . an(GATHER_TOOL_NOUN[$tool]);
            $cards .= gather_card_html($art, $t['label'], [[$why, 'gx-why-' . $tool]], 'type="button" class="gcard" aria-disabled="true" aria-describedby="gx-why-' . e($tool) . '"');
        }
    }
    $h .= '<h3 class="gx-h">Gather here <span class="gx-h__sub">⚡1 a try</span></h3>'
        . '<form method="post" action="' . e($action) . '" class="gx-form" id="gx-gather-form">' . csrf_field() . '<input type="hidden" name="do" value="gather">' . $hiddenHtml
        . '<div class="gcards">' . $cards . '</div></form>';

    // what's here: every find in this land, ??? until it is in the Almanac
    $known = array_flip(q("SELECT en.unlock_key FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key LIKE 'gather:%'", [$uid])->fetchAll(PDO::FETCH_COLUMN));
    $rows = gather_candidates($land);
    usort($rows, fn($a, $b) => [GATHER_RARITY[$a['rarity']][0] ?? 1, $a['name']] <=> [GATHER_RARITY[$b['rarity']][0] ?? 1, $b['name']]);
    $finds = '';
    foreach ($rows as $g) {
        $need = GATHER_RARITY[$g['rarity']][0] ?? 1;
        $isKnown = isset($known['gather:' . $g['slug']]);
        $ok = tool_tier($uid, $g['tool']) >= $need;
        $tierName = TOOL_TIERS[$need] ?? 'Worn';
        $finds .= '<li class="find' . ($isKnown ? '' : ' is-unknown') . '">' . gather_item_img(gather_art_path((int)$g['item_id'], (string)$g['slug']), 40, 'aimg aimg-md')
            . '<span class="find__name">' . ($isKnown ? e($g['name']) : '???') . '</span>'
            . '<span class="find__need' . ($ok ? ' ok' : '') . '">' . (TOOL_TYPES[$g['tool']][1] ?? '') . ' ' . ($ok ? e($tierName) . ' ✔' : 'needs ' . e($tierName)) . '</span></li>';
    }
    return $h . '<h3 class="gx-h">What’s here <span class="gx-h__sub">' . e($L[1]) . '</span></h3><ul class="finds">' . $finds . '</ul></section>';
}

/** v0.7.80 name, kept for callers (the adventure page's step off the path): the satchel scene. $heading is no longer used. */
function gather_here_box(array $u, string $land, string $action, string $hiddenHtml, bool $heading = true): string
{
    return gather_scene_html($u, $land, $action, $hiddenHtml);
}

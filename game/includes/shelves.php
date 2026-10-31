<?php
declare(strict_types=1);
/**
 * "Shelves" (mockup design 3), shared by the Satchel tab (satchel_view.php) and the Crafting tabs other than the Pantry (craft_shelves.php).
 * One adapter per surface turns the page's rows into "entries"; one renderer draws foldable shelves of compact pills, and the picked pill
 * opens its panel inline, right under its row. Every panel is in the page (hidden), so site.js opens one without a reload; without script
 * a pill is a link (?open= on the Satchel, ?r= on Crafting) and the server opens that panel. Layout: .shelves in assets/style.css (it also
 * carries .pantry2, so the shipped Pantry pieces .p2head / .p2search / .p2ic / .p2big / .p2jar / .p2fit / .p2make apply as they are).
 *
 * entry = [ id, item (items row or null), name, count (?int), status ok|miss|unk|use|off|'', group (shelf key), flag (New / Rare taste! / ''),
 *           small (one line under the name on the pill, html), panel (the inside of the open panel, html), quick (html or null), hay (search text),
 *           + per surface: untasted, care (Satchel); short, ings, icons (Crafting) ]
 * Every form posts where it did before: inventory.php (eat / read / open_packet / mend) and crafting.php (make / collect / collect_all).
 */
require_once __DIR__ . '/items.php';
require_once __DIR__ . '/crafting.php';
require_once __DIR__ . '/tools.php';
require_once __DIR__ . '/almanac.php';
require_once __DIR__ . '/gardens.php';
require_once __DIR__ . '/item_square.php';
require_once __DIR__ . '/catalog.php';
require_once __DIR__ . '/alchemy.php';   // potion tiers (Drink buttons)

// the Satchel's types, in the order of its Show list (icon, label)
const SH_BAG_GROUPS = ['seed' => ['🌱', 'Seeds'], 'produce' => ['🥕', 'Crops'], 'flower' => ['🌸', 'Flowers'], 'food' => ['🍲', 'Food'], 'soil' => ['🪱', 'Soil'],
    'mulch' => ['🍂', 'Mulch'], 'forage' => ['🍄', 'Finds'], 'tool' => ['🧰', 'Tools'], 'decor' => ['🏡', 'Decor'], 'arrangement' => ['💐', 'Arrangements'], 'other' => ['📦', 'Other']];
const SH_TIERS = ['snack' => ['🥨', 'snack'], 'meal' => ['🍲', 'meal'], 'feast' => ['🍳', 'feast']];

/** an item's picture for a pill or panel: decorative (the name is right beside it), so an empty alt */
function sh_icon(array $item, string $size): string
{
    return str_replace(' alt="-"', ' alt=""', item_icon($item, $size, '-'));
}

/** the Satchel shelf an item sits on: Broken tools with the tools, seed packets with the seeds */
function sh_bag_group(array $i): string
{
    return $i['category'] === 'broken' ? 'tool' : ($i['category'] === 'packet' ? 'seed' : (isset(SH_BAG_GROUPS[$i['category']]) ? (string)$i['category'] : 'other'));
}

/** a one-button POST form to inventory.php (the fields the Satchel always sent; $quick: the quick bar, which does not open the item afterwards) */
function sh_bag_form(string $do, int $itemId, string $label, string $hid, string $cls = 'btn', bool $quick = false): string
{
    return '<form method="post" action="' . e(url('inventory.php')) . '" class="shf">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">' . $hid
        . '<input type="hidden" name="item_id" value="' . $itemId . '">' . ($quick ? '<input type="hidden" name="quick" value="1">' : '') . '<button class="' . e($cls) . '">' . $label . '</button></form>';
}

/** the mend button's words, the same as tool_wear_html() shows (free once a day with a Tool Shed) */
function sh_mend_label(int $uid, array $item): string
{
    $tool = ($item['category'] ?? '') === 'broken' ? tool_of_broken($item) : $item;
    if (!$tool) return '🔧 Mend';
    $fm = q_one('SELECT free_mend_day, free_mend_n FROM users WHERE id = ?', [$uid]) ?: [];
    $free = ($allow = tool_free_mends($uid)) > 0 && ((string)($fm['free_mend_day'] ?? '') !== hollow_date('Y-m-d') || (int)($fm['free_mend_n'] ?? 0) < $allow);
    return $free ? '🛠️ Mend free' : '🔧 Mend ' . money((int)tool_mend_cost((int)$tool['base_price']));
}

/** Satchel rows as entries. $items: user_items joined with items (qty > 0). $hid: the hidden cat / sort fields every form carries back. */
function sh_bag_entries(array $u, array $items, string $hid): array
{
    $uid = (int)$u['id'];
    $IL = item_lookups();
    $cookInto = [];   // v0.7.45: raw grains, beans and roots can't be eaten as they are; say what to cook them into
    foreach (q("SELECT r.ingredients, i.name FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'cooking' ORDER BY i.name")->fetchAll() as $r)
        foreach (array_keys(json_decode((string)$r['ingredients'], true) ?: []) as $slug) $cookInto[$slug][] = $r['name'];
    $hasKitchen = (bool)q_val("SELECT 1 FROM garden_buildings gb JOIN plots p ON p.id = gb.plot_id WHERE p.user_id = ? AND gb.building = 'kitchen'", [$uid]);   // v0.7.48
    $inUse = [];   // the tool of each job the gnome uses now
    foreach (array_keys(TOOL_TYPES) as $tt) if ($bt = best_tool($uid, $tt)) $inUse[(int)$bt['id']] = true;
    $newSince = gmdate('Y-m-d H:i:s', time() - 3600);   // "New": got in the last hour
    $out = [];
    foreach ($items as $i) {
        $id = (int)$i['id'];
        $g = sh_bag_group($i);
        [$rl, $rw] = item_rarity($i, $IL);
        $fx = json_decode((string)$i['effects'], true) ?: [];
        $isTool = $i['category'] === 'tool' && !empty($fx['tool']);
        $broken = $i['category'] === 'broken';
        $wear = (int)$i['wear'];
        $untasted = (int)$i['edible'] === 1 && !$i['tasted'];
        $perm = $untasted && !empty($fx['perm']);
        $status = $broken ? 'off' : ($isTool && isset($inUse[$id]) ? 'use' : '');
        $flag = $perm ? 'Rare taste!' : ((string)($i['got_at'] ?? '') >= $newSince ? 'New' : '');
        $price = (int)$i['base_price'];
        [$gIc, $gL] = SH_BAG_GROUPS[$g];
        $kind = $broken ? 'Broken tool' : ($i['category'] === 'packet' ? 'Seed packet' : ($i['category'] === 'guide' ? 'Guide' : ($g === 'other' ? ucfirst((string)$i['category']) : rtrim($gL, 's'))));
        // the panel: the same words and buttons the old pop-up had
        $b = '<div class="shdesc">' . desc_html((string)$i['description']) . '</div>';
        if ($i['category'] === 'seed' && ($sp = $IL['seed'][$id] ?? null) && plant_unstudied($u, $sp))
            $b .= '<p class="help unstudied">📕 Unstudied: you can plant it, but it grows ' . unstudied_slow_pct($u) . '% slower and gives ' . (100 - unstudied_yield_pct($u)) . '% less until you study ' . e(plant_home_name((int)$sp['id']) ?: 'its region') . ' or master it.</p>';
        if ($facts = item_facts($i, $IL)) $b .= '<ul class="ifacts shfacts">' . implode('', array_map(fn($f) => '<li>' . $f . '</li>', $facts)) . '</ul>';
        $b .= tool_wear_html($uid, $i, $wear, $hid);   // uses left, and the mend form for a worn or broken tool
        $acts = []; $quick = null;
        if ((int)$i['edible']) {
            $verb = !empty($fx['tea']) ? '☕ Drink' : ($i['category'] === 'supply' ? '🧪 Drink' : '😋 Eat');   // supply: Alchemy potions
            $b .= '<p class="help shnote">' . ($i['tasted'] ? '🍴 Tasted' : '✨ Never tasted') . ($perm ? ' — rare! Eating it raises a stat permanently.' : '') . '</p>';
            $acts[] = sh_bag_form('eat', $id, $verb, $hid);
            if ($untasted) $quick = sh_bag_form('eat', $id, $verb, $hid, 'btn small', true);
        } elseif (in_array($i['category'], ['produce', 'forage', 'flower'], true)) {
            $dishes = array_values(array_unique($cookInto[$i['slug']] ?? []));
            $b .= '<p class="help shnote">🍳 Can’t be eaten as it is' . ($i['category'] === 'flower' ? '' : ': it needs cooking first') . '.'
                . ($dishes ? ' Cook it into ' . e(implode(', ', array_slice($dishes, 0, 4))) . (count($dishes) > 4 ? ' and more' : '') . '.' : '') . '</p>';
            if ($dishes && !$hasKitchen) $b .= '<p class="help shnote">🔒 Cooking needs a <b>Kitchen</b> in your garden: build one on the garden page once your garden reaches level 2 (every harvest helps).</p>';
            elseif ($dishes) $acts[] = '<a class="btn alt" href="' . e(url('inventory.php?tab=craft&c=cooking&q=' . rawurlencode((string)$i['name']))) . '">🍳 Cook in Crafting</a>';
        }
        if ($i['category'] === 'arrangement' && ($comp = arrangement_of($i))) {
            $b .= '<div class="arrbig">' . arrangement_svg($comp, 'full', (string)$i['name']) . '</div>';
            $acts[] = '<a class="btn alt" href="' . e(url('arrange.php?t=show')) . '">🎗️ Enter the weekly show</a>';
        } elseif ($i['category'] === 'packet') {
            $acts[] = sh_bag_form('open_packet', $id, '📦 Open the packet', $hid);
            $quick = sh_bag_form('open_packet', $id, '📦 Open', $hid, 'btn small', true);
        }
        if (isset(ALCHEMY_HEAL[(string)$i['slug']])) {   // Alchemy healing tiers: drink one to heal (pals: Pal Jobs)
            $acts[] = sh_bag_form('drink_heal', $id, '🧪 Drink (+' . alchemy_gnome_pct((string)$i['slug']) . '% health)', $hid);
            $quick ??= sh_bag_form('drink_heal', $id, '🧪 Drink', $hid, 'btn small', true);
        } elseif ($i['slug'] === 'garden-tonic') {
            $acts[] = '<a class="btn" href="' . e(url('garden.php')) . '">🪴 Pour on a garden square</a>';
        }
        if ($i['category'] === 'decor') $acts[] = '<a class="btn" href="' . e(url('yard.php')) . '">✏️ Place it in your yard</a>';
        if ($i['category'] === 'guide') {
            $acts[] = sh_bag_form('read', $id, '📗 Read guide', $hid);
            $quick = sh_bag_form('read', $id, '📗 Read', $hid, 'btn small', true);
        }
        if ($broken) $quick = sh_bag_form('mend', $id, sh_mend_label($uid, $i), $hid, 'btn small', true);
        if (!$isTool && !$broken && (int)($i['tradable'] ?? 1) === 1) {
            $acts[] = '<a class="btn alt" href="' . e(url('market.php?t=stall')) . '">🏷️ Sell</a>';
            $acts[] = '<a class="btn alt" href="' . e(url('market.php?t=gifts')) . '">🎁 Gift</a>';
        }
        $tags = '<span class="tag">' . $gIc . ' ' . e($kind) . '</span>' . ($rl !== 'C' ? ' <span class="tag rarword r' . $rl . '">' . e($rw) . '</span>' : '')
              . ($status === 'use' ? ' <span class="tag shok">In use</span>' : ($isTool ? ' <span class="tag">Spare</span>' : '')) . ($flag !== '' ? ' <span class="tag shflag">' . e($flag) . '</span>' : '');
        $sub = 'You have <b>×' . number_format((int)$i['qty']) . '</b>' . ($price > 0 ? ' · worth ' . money($price) . ' each' : '');
        $small = '×' . number_format((int)$i['qty']) . ($status === 'use' ? ' · in use' : '') . ($broken ? ' · broken' : '') . ($untasted ? ' · ✨' . ($perm ? ' rare taste' : ' untasted') : '');
        $out[] = [
            'id' => $id, 'item' => $i, 'name' => (string)$i['name'], 'count' => (int)$i['qty'], 'status' => $status, 'group' => $g, 'flag' => $flag, 'rarity' => $rl,
            'small' => e($small), 'tags' => $tags, 'sub' => $sub, 'panel' => $b . ($acts ? '<div class="p2acts shacts">' . implode('', $acts) . '</div>' : ''),
            'quick' => $quick, 'hay' => (string)$i['name'], 'untasted' => $untasted, 'perm' => $perm, 'care' => $broken || ($isTool && $wear > 0),
        ];
    }
    return $out;
}

/** one line per ingredient: icon, name, have/need (the Pantry's slim lines) */
function sh_ing_line(array $i, array $icons): string
{
    $ok = (int)$i['have'] >= (int)$i['qty'];
    return '<li class="' . ($ok ? 'ok' : 'short') . '"><span class="p2ic" aria-hidden="true">' . (isset($icons[$i['slug']]) ? sh_icon($icons[$i['slug']], 'sm') : '❔') . '</span><span class="p2in">' . e((string)$i['name'])
        . '</span><b>' . ($ok ? '✔ ' : '✖ ') . number_format((int)$i['have']) . '/' . number_format((int)$i['qty']) . '</b><span class="vh">' . ($ok ? ' enough' : ' not enough') . '</span></li>';
}

/**
 * Crafting recipes as entries: every rule, number and POST of the old recipe card (craft_view.php's $card, v0.7.47 to v0.9.4): energy cost,
 * feast firewood fee, a level 3 Kitchen for feasts, pots (batch chunking, all busy), too tired, the building notice, the boost text, new!.
 */
function sh_craft_entries(array $u, string $tab, array $recipes, array $stations): array
{
    $uid = (int)$u['id'];
    $now = (int)($u['energy'] ?? 0);   // v0.7.88: energy left (refreshed by inventory.php)
    $coins = (int)($u['coins'] ?? 0);
    $kitchen3 = user_building_bonus($uid, 'kitchen')['feasts'];   // v0.7.96: feasts
    $slugs = [];
    foreach ($recipes as $r) foreach ($r['ings'] as $i) $slugs[$i['slug']] = true;
    $icons = [];   // slug => items row
    if ($slugs) { $ph = implode(',', array_fill(0, count($slugs), '?')); foreach (q("SELECT * FROM items WHERE slug IN ($ph)", array_keys($slugs))->fetchAll() as $it) $icons[$it['slug']] = $it; }
    $outItems = [];
    foreach (q('SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = ?', [$tab])->fetchAll() as $it) $outItems[(int)$it['id']] = $it;
    $potsOn = $tab === 'cooking' && cook_pots_on();   // v0.9.4: pots with timers (kitchen_pots 0 = instant)
    $potsFree = $potsOn ? max(0, cook_pot_limit($u) - cook_pots_busy($uid)) : 0;
    $verb = $tab === 'cooking' ? 'Cook' : 'Make';
    $out = [];
    foreach ($recipes as $r) {
        $known = (bool)$r['known'];
        $feast = str_starts_with((string)($r['slug'] ?? ''), 'feast-');
        $tier = $tab === 'cooking' ? (string)($r['tier'] ?: 'meal') : '';
        $item = $outItems[(int)$r['output_item_id']] ?? null;
        $shortN = array_sum(array_map(fn($i) => max(0, (int)$i['qty'] - (int)$i['have']), $r['ings']));
        $status = !$known ? 'unk' : ($r['can'] && !($feast && !$kitchen3) ? 'ok' : 'miss');
        $cost = craft_energy_cost($u, $tab, (int)$r['energy'], $tier);
        $fee = $tier === 'feast' ? max(0, (int)setting('feast_petal_fee')) : 0;
        $chunk = max(1, (int)$r['batch_max']);
        $secs = $tier ? cook_seconds($u, $r) : 0;
        $timeTxt = $tier ? ($secs > 0 ? cook_time_text($secs) : 'instant') : '';
        // the make block: the old card's rules, in the same order
        $acts = '';
        if (!$known) $acts = '<p class="muted p2note">Collect everything above to discover it.</p>';
        elseif ($feast && !$kitchen3) $acts = '<p class="muted p2note">🔒 Needs a level 3 Kitchen.</p>';
        elseif (!$r['can']) $acts = '<p class="ccneed p2note">Need ' . e(implode(', ', array_map(fn($i) => ($i['qty'] - $i['have']) . ' ' . $i['name'], array_filter($r['ings'], fn($i) => $i['have'] < $i['qty'])))) . '</p>';
        elseif ($stations[$tab] === 0) { $bl = BUILDINGS[CRAFT_CATEGORIES[$tab][2]] ?? null; $acts = '<p class="muted p2note">🔒 Needs a ' . e($bl ? $bl[1] . ' ' . $bl[0] : 'building') . ' (see above).</p>'; }
        else {
            $fit = craft_fit($r['ings'], $cost, $now);
            if ($fee > 0) $fit = min($fit, intdiv($coins, $fee));
            if ($potsOn) $fit = min($fit, $potsFree * $chunk);
            if ($fit >= 1) {
                $acts = '<form method="post" action="' . e(url('crafting.php?c=' . $tab)) . '" class="ccbtns p2make">' . csrf_field() . '<input type="hidden" name="recipe_id" value="' . (int)$r['id'] . '">';
                if ($potsOn && $chunk > 1) for ($n = 1; $n <= min($fit, $chunk); $n++) $acts .= '<button class="btn' . ($n > 1 ? ' alt' : '') . '" name="qty" value="' . $n . '">' . ($n === 1 ? $verb . ' ' : '') . '×' . $n . '</button>';
                else {
                    $acts .= '<button class="btn" name="qty" value="1">' . $verb . ' ×1' . ($cost > 0 ? ' <span class="cbcost">⚡' . $cost . '</span>' : '') . '</button>';
                    if ($fit >= 5) $acts .= '<button class="btn alt" name="qty" value="5">×5</button>'; elseif ($fit >= 2) $acts .= '<button class="btn alt" name="qty" value="2">×2</button>';
                    if ($fit >= 3) $acts .= '<button class="btn alt" name="qty" value="all">All ' . $fit . '</button>';
                }
                $acts .= '</form>';
            } elseif ($potsOn && $potsFree < 1) $acts = '<p class="ccneed p2note">All pots are busy.</p>';
            elseif ($fee > 0 && $coins < $fee) $acts = '<p class="ccneed p2note">Needs ' . e(money_txt($fee)) . ' for firewood and spices.</p>';
            elseif ($cost > 0 && $now < $cost) $acts = '<p class="ccneed p2note">Too tired: this takes ⚡' . $cost . ', you have ⚡' . $now . '.</p>';
        }
        $tw = $tier ? SH_TIERS[$tier] : null;
        $pic = $known && $item ? sh_icon($item, 'lg') : '❔';
        $head = '<div class="shdh"><span class="p2big" aria-hidden="true">' . $pic . '</span><span class="p2dt"><b class="p2name">' . ($known ? e((string)$r['name']) : '???') . '</b>'
              . '<span class="p2tags">' . ($tw ? '<span class="tag">' . $tw[0] . ' ' . e($tw[1]) . '</span>' : '<span class="tag">' . CRAFT_CATEGORIES[$tab][1] . ' ' . e(strtolower(CRAFT_CATEGORIES[$tab][0])) . '</span>')
              . (!empty($r['new']) ? ' <span class="tag">new!</span>' : '') . '</span>'
              . '<small class="p2sub">' . ($known ? ($tab === 'cooking' ? e(buff_text($r['effects'], $u, true)) : 'Makes ' . (int)$r['output_qty'] . ' × ' . e((string)$r['out_name'])) : 'Not discovered yet') . '</small></span>';
        if ($known) {
            $when = ($cost ? '⚡<b>' . $cost . '</b> each' : 'No energy') . ($fee ? ' · ' . money($fee) . ' each' : '') . ($timeTxt ? ' · ⏱ <b>' . e($timeTxt) . '</b>' : '')
                  . ($potsOn ? ' <span class="muted">· ' . ($potsFree > 0 ? $potsFree . ' pot' . ($potsFree === 1 ? '' : 's') . ' free' : 'no free pot right now') . ($chunk > 1 ? ', up to ' . $chunk . ' in one pot' : '') . '</span>' : '');
            $have = ''; $need = '';
            foreach ($r['ings'] as $i) { $li = sh_ing_line($i, $icons); if ((int)$i['have'] >= (int)$i['qty']) $have .= $li; else $need .= $li; }
            $body = '<p class="p2fit">' . $when . '</p><div class="shhn">'
                  . '<div class="shhave"><h4>✔ You have</h4>' . ($have !== '' ? '<ul class="p2ingcmp">' . $have . '</ul>' : '<p class="muted">Nothing yet.</p>') . '</div>'
                  . '<div class="shneed"><h4>✖ Still need</h4>' . ($need !== '' ? '<ul class="p2ingcmp">' . $need . '</ul>' : '<p class="muted">Nothing: ready to go.</p>') . '</div></div>';
        } else {   // not found yet: the ingredient squares say which ones you have found
            $sq = '';
            foreach ($r['ings'] as $i) {
                $it = $icons[$i['slug']] ?? ['name' => $i['name']];
                $sq .= $i['seen'] ? item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'states' => ['done'], 'chips' => [['note', 'Found']]])
                                  : item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'icon' => '❔', 'rarity' => 'C', 'states' => ['off'], 'chips' => [['note', 'Not found yet']]]);
            }
            $body = '<p class="ccingh p2ingh">Ingredients</p>' . item_grid($sq, 'itms--flush ccings p2ings');
        }
        $small = $known ? ($status === 'ok' ? ($timeTxt ? str_replace([' minutes', ' minute', ' hours', ' hour'], [' min', ' min', ' h', ' h'], $timeTxt) . ' · ' : '') . ($cost ? '⚡' . $cost : 'no ⚡')
                                            : ($feast && !$kitchen3 && $r['can'] ? '🔒 Kitchen 3' : 'short ' . $shortN))
                        : count(array_filter($r['ings'], fn($i) => $i['seen'])) . '/' . count($r['ings']) . ' found';
        $out[] = [
            'id' => (int)$r['id'], 'item' => $known ? $item : null, 'name' => $known ? (string)$r['name'] : '???', 'count' => null, 'status' => $status,
            'group' => $status === 'ok' ? 'ready' : ($status === 'unk' ? 'unk' : ($shortN > 0 && $shortN <= 2 ? 'close' : 'far')),
            'flag' => !empty($r['new']) ? 'New' : '', 'small' => e($small), 'head' => $head, 'panel' => $body . '<div class="p2acts shacts">' . $acts . '</div>',
            'quick' => null, 'hay' => $known ? $r['name'] . ' ' . implode(' ', array_column($r['ings'], 'name')) : '', 'short' => $shortN, 'ings' => $r['ings'], 'icons' => $icons,
        ];
    }
    return $out;
}

/**
 * The shelves: one <details> per shelf (open state kept by site.js for this tab), pills in a grid, each pill followed by its panel
 * (hidden unless it is the picked one). $defs: key => [icon, label]; $open: key => open by default; $link(int $id): the no-script pick link.
 */
function sh_shelves(array $entries, array $defs, array $open, int $selId, string $surface, callable $link, callable $close, bool $bagCounts): string
{
    $by = [];
    foreach ($entries as $e) $by[$e['group']][] = $e;
    $o = '';
    foreach ($defs as $k => [$si, $sl]) {
        if (empty($by[$k])) continue;
        $rows = $by[$k];
        $hasSel = $selId > 0 && in_array($selId, array_column($rows, 'id'), true);
        $o .= '<details class="shshelf sh-' . e($k) . '" data-shelf="' . e($surface . ':' . $k) . '"' . ($hasSel || !empty($open[$k]) ? ' open' : '') . '>'
            . '<summary class="shsum"><span class="shsi" aria-hidden="true">' . $si . '</span><b>' . e($sl) . '</b><small>' . count($rows)
            . ($bagCounts ? ' kind' . (count($rows) === 1 ? '' : 's') . ' · ×' . number_format(array_sum(array_column($rows, 'count'))) : '') . '</small>';
        if (!$bagCounts && $k !== 'unk') { $o .= '<span class="shpeek" aria-hidden="true">'; foreach (array_slice($rows, 0, 5) as $e) $o .= '<span class="p2ic">' . ($e['item'] ? sh_icon($e['item'], 'sm') : '❔') . '</span>'; $o .= '</span>'; }
        $o .= '<span class="shchev" aria-hidden="true">▾</span></summary>' . "\n" . '<div class="shpills">';
        foreach ($rows as $e) {
            $isSel = $selId === $e['id'];
            $pid = ($surface === 'bag' ? 'i' : 'r') . $e['id'];
            $o .= '<a class="shpill ' . e($e['status']) . ($isSel ? ' sel' : '') . '" id="' . $pid . '" href="' . e($isSel ? $close() : $link($e['id'])) . '" data-pick="shp-' . $pid . '"'
                . ' aria-controls="shp-' . $pid . '" aria-expanded="' . ($isSel ? 'true' : 'false') . '" data-hay="' . e(mb_strtolower($e['hay'])) . '">'
                . '<span class="p2ic" aria-hidden="true">' . ($e['item'] ? sh_icon($e['item'], 'sm') : '❔') . '</span>'
                . '<span class="shpt"><b>' . e($e['name']) . '</b><small>' . $e['small'] . '</small></span>'
                . ($e['flag'] !== '' ? '<i class="shnew' . ($e['flag'] === 'Rare taste!' ? ' taste' : '') . '" aria-hidden="true"></i><span class="vh"> (' . e($e['flag']) . ')</span>' : '') . "</a>\n";
            $head = $e['head'] ?? ('<div class="shdh"><span class="p2big" aria-hidden="true">' . sh_icon($e['item'], 'lg') . '</span><span class="p2dt"><b class="p2name">' . e($e['name']) . '</b>'
                  . '<span class="p2tags">' . $e['tags'] . '</span><small class="p2sub">' . $e['sub'] . '</small></span>');
            $o .= '<div class="shpanel ' . e($e['status']) . '" id="shp-' . $pid . '" role="region" aria-label="' . e($e['name']) . '"' . ($isSel ? '' : ' hidden') . '>'
                . $head . '<a class="shx" href="' . e($close()) . '" data-close aria-label="Close">✕</a></div>' . $e['panel'] . "</div>\n";
        }
        $o .= "</div></details>\n";
    }
    return $o;
}

/** the search box (a GET form; site.js also filters the pills as you type). $keep: hidden fields that keep the page's other choices. */
function sh_search(string $qs, string $keep, string $placeholder): string
{
    return '<form method="get" action="' . e(url('inventory.php')) . '" class="p2search shsearch" role="search">' . $keep
        . '<label class="vh" for="shq">Search</label><input id="shq" type="search" name="q" value="' . e($qs) . '" placeholder="' . e($placeholder) . '" autocomplete="off" data-shfilter></form>';
}

<?php
declare(strict_types=1);
/*
 * MOCKUP ONLY (Satchel + Crafting redesign, three designs). ONE adapter layer, shared by all three layouts and by both surfaces:
 * sm_bag() turns the Satchel's user_items into "entries", sm_craft() turns craft_recipes() into the same shape, sm_station() is the
 * one-row state strip (pots for Cooking, the Tool Shed for Tools, nothing to wait on elsewhere). A layout only ever reads entries.
 *
 * entry = [
 *   id, item (items row or null), name, count (?int), rarity C|U|R|L, group (chip / shelf key), status ok|miss|unk|use|off|'' ,
 *   flag ('New' / 'Rare taste!' / 'short 2'), meta (one small line, html), tags (html), sub (one line under the name in the detail, html),
 *   body (desktop detail: description, facts, ingredient squares; html), lines (phone sheet: slim lines; html), acts (buttons / forms; html),
 *   short (ingredients missing, craft), quick ([verb, form html] for the quick bar of design 3, or null), hay (search text)
 * ]
 * Every form posts where the live page posts today: inventory.php (eat / read / open_packet / mend) and crafting.php (make / collect).
 */
require_once __DIR__ . '/items.php';
require_once __DIR__ . '/crafting.php';
require_once __DIR__ . '/tools.php';
require_once __DIR__ . '/almanac.php';
require_once __DIR__ . '/gardens.php';
require_once __DIR__ . '/item_square.php';
require_once __DIR__ . '/catalog.php';

const SM_BAG_GROUPS = ['seed' => ['🌱', 'Seeds'], 'produce' => ['🥕', 'Crops'], 'flower' => ['🌸', 'Flowers'], 'food' => ['🍲', 'Food'], 'soil' => ['🪱', 'Soil'],
    'mulch' => ['🍂', 'Mulch'], 'forage' => ['🍄', 'Finds'], 'tool' => ['🧰', 'Tools'], 'decor' => ['🏡', 'Decor'], 'arrangement' => ['💐', 'Arrangements'], 'other' => ['📦', 'Other']];
const SM_TIERS = ['snack' => ['🥨', 'Snack'], 'meal' => ['🍲', 'Meal'], 'feast' => ['🍳', 'Feast']];

/** a one-button POST form to inventory.php (same fields the live Satchel sends) */
function sm_bag_form(string $do, int $itemId, string $label, string $cls = 'btn'): string
{
    return '<form method="post" action="' . e(url('inventory.php')) . '" class="smf">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">'
        . '<input type="hidden" name="cat" value="all"><input type="hidden" name="item_id" value="' . $itemId . '"><button class="' . e($cls) . '">' . $label . '</button></form>';
}

function sm_bag(array $u): array
{
    $uid = (int)$u['id'];
    $items = q('SELECT i.id, i.slug, i.name, i.category, i.description, i.edible, i.effects, i.rarity, i.base_price, i.image, ui.qty, ui.wear, ui.id AS uiid, ui.got_at,
                (SELECT 1 FROM user_tasted t WHERE t.user_id = ui.user_id AND t.item_id = i.id) AS tasted
                FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 ORDER BY i.category, i.name', [$uid])->fetchAll();
    $IL = item_lookups();
    $cookInto = [];
    foreach (q("SELECT r.ingredients, i.name FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'cooking' ORDER BY i.name")->fetchAll() as $r)
        foreach (array_keys(json_decode((string)$r['ingredients'], true) ?: []) as $slug) $cookInto[$slug][] = $r['name'];
    $inUse = [];
    foreach (array_keys(TOOL_TYPES) as $tt) if ($bt = best_tool($uid, $tt)) $inUse[(int)$bt['id']] = true;
    $newSince = gmdate('Y-m-d H:i:s', time() - 3600);
    $groupOf = fn(array $i): string => $i['category'] === 'broken' ? 'tool' : ($i['category'] === 'packet' ? 'seed' : (isset(SM_BAG_GROUPS[$i['category']]) ? $i['category'] : 'other'));
    $out = [];
    foreach ($items as $i) {
        $id = (int)$i['id'];
        $g = $groupOf($i);
        [$rl, $rw] = item_rarity($i, $IL);
        $fx = json_decode((string)$i['effects'], true) ?: [];
        $isTool = $i['category'] === 'tool' && !empty($fx['tool']);
        $broken = $i['category'] === 'broken';
        $untasted = (int)$i['edible'] === 1 && !$i['tasted'];
        $perm = $untasted && !empty($fx['perm']);
        $status = $broken ? 'off' : ($isTool && isset($inUse[$id]) ? 'use' : '');
        $flag = $perm ? 'Rare taste!' : ((string)($i['got_at'] ?? '') >= $newSince ? 'New' : '');
        $price = (int)$i['base_price'];
        // detail body: the same words the live pop-up shows
        $body = '<div class="smdesc">' . desc_html((string)$i['description']) . '</div>';
        if ($facts = item_facts($i, $IL)) $body .= '<ul class="ifacts smfacts">' . implode('', array_map(fn($f) => '<li>' . $f . '</li>', $facts)) . '</ul>';
        $acts = []; $quick = null;
        if ((int)$i['edible']) {
            $verb = !empty($fx['tea']) ? '☕ Drink' : '😋 Eat';
            $body .= '<p class="help smnote">' . ($i['tasted'] ? '🍴 Tasted' : '✨ Never tasted') . ($perm ? ': rare! Eating it raises a stat for good.' : '') . '</p>';
            $acts[] = sm_bag_form('eat', $id, $verb);
            if ($untasted) $quick = [$verb, sm_bag_form('eat', $id, $verb, 'btn small')];
        } elseif (in_array($i['category'], ['produce', 'forage', 'flower'], true)) {
            $dishes = array_values(array_unique($cookInto[$i['slug']] ?? []));
            $body .= '<p class="help smnote">🍳 Can’t be eaten as it is.' . ($dishes ? ' Cook it into ' . e(implode(', ', array_slice($dishes, 0, 3))) . (count($dishes) > 3 ? ' and ' . (count($dishes) - 3) . ' more' : '') . '.' : '') . '</p>';
            if ($dishes) $acts[] = '<a class="btn" href="' . e(url('inventory.php?tab=craft&c=cooking&q=' . rawurlencode((string)$i['name']))) . '">🍳 Cook</a>';
        }
        if ($i['category'] === 'packet') { $acts[] = sm_bag_form('open_packet', $id, '📦 Open'); $quick = ['📦 Open', sm_bag_form('open_packet', $id, '📦 Open', 'btn small')]; }
        if ($i['category'] === 'guide') { $acts[] = sm_bag_form('read', $id, '📗 Read'); $quick = ['📗 Read', sm_bag_form('read', $id, '📗 Read', 'btn small')]; }
        if ($i['category'] === 'decor') { $acts[] = '<a class="btn" href="' . e(url('yard.php')) . '">✏️ Place</a>'; }
        if ($broken || ($isTool && (int)$i['wear'] > 0)) {
            $w = tool_wear_html($uid, $i, (int)$i['wear'], '<input type="hidden" name="cat" value="all">');
            if ($w !== '') $body .= '<div class="smwear">' . $w . '</div>';
            if ($broken) $quick = ['🔧 Mend', '<a class="btn small" href="' . e(url('inventory.php?tab=belt&b=mend')) . '">🔧 Mend</a>'];
        }
        if (!$isTool && !$broken) {
            $acts[] = '<a class="btn alt" href="' . e(url('market.php?t=stall')) . '">🏷️ Sell</a>';
            $acts[] = '<a class="btn alt" href="' . e(url('market.php?t=gifts')) . '">🎁 Gift</a>';
        }
        [$gIc, $gL] = SM_BAG_GROUPS[$g];
        $kindWord = $broken ? 'Broken tool' : ($i['category'] === 'packet' ? 'Seed packet' : rtrim($gL, 's'));
        $meta = e($kindWord) . ($rl !== 'C' ? ' · <span class="rarword r' . $rl . '">' . e($rw) . '</span>' : '') . ($price > 0 ? ' · ' . money($price) . ' each' : '')
              . ($status === 'use' ? ' · <b class="smok">In use</b>' : '') . ($untasted ? ' · <span class="smtaste">✨ untasted</span>' : '');
        $out[] = [
            'id' => $id, 'item' => $i, 'name' => (string)$i['name'], 'count' => (int)$i['qty'], 'rarity' => $rl, 'group' => $g, 'status' => $status, 'flag' => $flag,
            'meta' => $meta, 'tags' => '<span class="tag">' . $gIc . ' ' . e($kindWord) . '</span>' . ($rl !== 'C' ? ' <span class="tag rarword r' . $rl . '">' . e($rw) . '</span>' : ''),
            'sub' => 'You have <b>×' . (int)$i['qty'] . '</b>' . ($price > 0 ? ' · worth ' . money($price) . ' each' : ''),
            'body' => $body, 'lines' => '', 'acts' => implode('', $acts), 'short' => 0, 'quick' => $quick, 'untasted' => $untasted,
            'new' => $flag === 'New', 'care' => $broken || ($isTool && (int)$i['wear'] > 0), 'hay' => (string)$i['name'],
        ];
    }
    return $out;
}

/** the groups that have entries, in the fixed order, with counts */
function sm_groups(array $entries, array $defs): array
{
    $n = [];
    foreach ($entries as $e) $n[$e['group']] = ($n[$e['group']] ?? 0) + 1;
    $g = [];
    foreach ($defs as $k => [$ic, $l]) if (!empty($n[$k])) $g[$k] = [$ic, $l, $n[$k]];
    foreach ($n as $k => $c) if (!isset($g[$k])) $g[$k] = ['📦', ucfirst((string)$k), $c];
    return $g;
}

/** Crafting recipes as entries: the same rules, numbers and POSTs as craft_view.php's $card */
function sm_craft(array $u, string $tab): array
{
    $uid = (int)$u['id'];
    $stations = craft_stations($uid);
    $recipes = craft_recipes($uid, $tab);
    usort($recipes, fn($a, $b) => [$b['known'], $b['known'] && $b['can']] <=> [$a['known'], $a['known'] && $a['can']] ?: strcmp($a['name'], $b['name']));
    $now = (int)($u['energy'] ?? 0);
    $coins = (int)($u['coins'] ?? 0);
    $kitchen3 = user_building_bonus($uid, 'kitchen')['feasts'];
    $slugs = [];
    foreach ($recipes as $r) foreach ($r['ings'] as $i) $slugs[$i['slug']] = true;
    $icons = [];
    if ($slugs) { $ph = implode(',', array_fill(0, count($slugs), '?')); foreach (q("SELECT * FROM items WHERE slug IN ($ph)", array_keys($slugs))->fetchAll() as $it) $icons[$it['slug']] = $it; }
    $outItems = [];
    foreach (q('SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = ?', [$tab])->fetchAll() as $it) $outItems[(int)$it['id']] = $it;
    $potsOn = $tab === 'cooking' && cook_pots_on();
    $potLimit = $potsOn ? cook_pot_limit($u) : 0;
    $potsFree = max(0, $potLimit - cook_pots_busy($uid));
    $out = [];
    foreach ($recipes as $r) {
        $known = (bool)$r['known'];
        $tier = $tab === 'cooking' ? (string)($r['tier'] ?: 'meal') : '';
        $feast = str_starts_with((string)($r['slug'] ?? ''), 'feast-');
        $item = $outItems[(int)$r['output_item_id']] ?? null;
        $shortN = array_sum(array_map(fn($i) => max(0, $i['qty'] - $i['have']), $r['ings']));
        $status = !$known ? 'unk' : ($r['can'] && !($feast && !$kitchen3) ? 'ok' : 'miss');
        $group = $tab === 'cooking' ? $tier : (string)($r['out_cat'] ?? 'other');
        // ingredients: big squares (desktop) and slim lines (phone), exactly as the Pantry does
        $sq = ''; $ln = ''; $have = ''; $need = '';
        foreach ($r['ings'] as $i) {
            $it = $icons[$i['slug']] ?? ['name' => $i['name']];
            $h = (int)$i['have']; $q = (int)$i['qty']; $ok = $h >= $q;
            if ($known) {
                $sq .= item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'count' => $h,
                    'chips' => [$ok ? ['ok', '✔ uses ' . $q] : ['short', '✖ short ' . ($q - $h)]], 'vh' => '<span class="vh">' . ($ok ? 'enough' : 'not enough') . ': you have ' . $h . ', the recipe needs ' . $q . '</span>']);
                $li = '<li class="' . ($ok ? 'ok' : 'short') . '"><span class="p2ic">' . (isset($icons[$i['slug']]) ? item_icon($icons[$i['slug']], 'sm', '-') : '❔') . '</span><span class="p2in">' . e((string)$i['name']) . '</span><b>' . ($ok ? '✔ ' : '✖ ') . $h . '/' . $q . '</b></li>';
                $ln .= $li;
                if ($ok) $have .= $li; else $need .= $li;
            } elseif ($i['seen']) {
                $sq .= item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'states' => ['done'], 'chips' => [['note', 'Found']]]);
            } else {
                $sq .= item_square(['item' => $it, 'name' => (string)$i['name'], 'tag' => 'div', 'class' => 'ccing', 'icon' => '❔', 'rarity' => 'C', 'states' => ['off'], 'chips' => [['note', 'Not found yet']]]);
            }
        }
        // make block (craft_view.php's rules)
        $acts = ''; $when = '';
        $cost = craft_energy_cost($u, $tab, (int)$r['energy'], $tier);
        $fee = $tier === 'feast' ? max(0, (int)setting('feast_petal_fee')) : 0;
        $chunk = max(1, (int)$r['batch_max']);
        $secs = $tier ? cook_seconds($u, $r) : 0;
        if (!$known) $acts = '<p class="muted p2note">Collect everything above to discover it.</p>';
        elseif ($feast && !$kitchen3) $acts = '<p class="muted p2note">🔒 Needs a level 3 Kitchen.</p>';
        elseif (!$r['can']) $acts = '<p class="ccneed p2note">Need ' . e(implode(', ', array_map(fn($i) => ($i['qty'] - $i['have']) . ' ' . $i['name'], array_filter($r['ings'], fn($i) => $i['have'] < $i['qty'])))) . '</p>';
        elseif ($stations[$tab] !== 0) {
            $fit = craft_fit($r['ings'], $cost, $now);
            if ($fee > 0) $fit = min($fit, intdiv($coins, $fee));
            if ($potsOn) $fit = min($fit, $potsFree * $chunk);
            if ($fit >= 1) {
                $acts = '<form method="post" action="' . e(url('crafting.php?c=' . $tab)) . '" class="ccbtns p2make">' . csrf_field() . '<input type="hidden" name="recipe_id" value="' . (int)$r['id'] . '">';
                if ($potsOn && $chunk > 1) for ($n = 1; $n <= min($fit, $chunk); $n++) $acts .= '<button class="btn' . ($n > 1 ? ' alt' : '') . '" name="qty" value="' . $n . '">' . ($n === 1 ? 'Cook ' : '') . '×' . $n . '</button>';
                else {
                    $acts .= '<button class="btn" name="qty" value="1">' . ($tab === 'cooking' ? 'Cook' : 'Make') . ' ×1' . ($cost > 0 ? ' <span class="cbcost">⚡' . $cost . '</span>' : '') . '</button>';
                    if ($fit >= 5) $acts .= '<button class="btn alt" name="qty" value="5">×5</button>'; elseif ($fit >= 2) $acts .= '<button class="btn alt" name="qty" value="2">×2</button>';
                    if ($fit >= 3) $acts .= '<button class="btn alt" name="qty" value="all">All ' . $fit . '</button>';
                }
                $acts .= '</form>';
            } elseif ($potsOn && $potsFree < 1) $acts = '<p class="ccneed p2note">All pots are busy.</p>';
            elseif ($fee > 0 && $coins < $fee) $acts = '<p class="ccneed p2note">Needs ' . e(money_txt($fee)) . ' for firewood and spices.</p>';
            elseif ($cost > 0 && $now < $cost) $acts = '<p class="ccneed p2note">Too tired: this takes ⚡' . $cost . ', you have ⚡' . $now . '.</p>';
        }
        $timeTxt = $tier ? ($secs > 0 ? cook_time_text($secs) : 'instant') : '';
        if ($known) $when = ($cost ? '⚡<b>' . $cost . '</b> each' : 'No energy') . ($fee ? ' · ' . money($fee) . ' each' : '') . ($timeTxt ? ' · ⏱ <b>' . e($timeTxt) . '</b>' : '')
            . ($potsOn ? ' <span class="muted">· ' . ($potsFree > 0 ? $potsFree . ' pot' . ($potsFree === 1 ? '' : 's') . ' free' . ($chunk > 1 ? ', up to ' . $chunk . ' in one' : '') : 'no free pot right now') . '</span>' : '');
        $tw = $tier ? SM_TIERS[$tier] : null;
        $sub = $known ? ($tab === 'cooking' ? e(buff_text($r['effects'], $u, true)) : 'Makes ' . (int)$r['output_qty'] . ' × ' . e($r['out_name'])) : 'Not discovered yet';
        $meta = $known ? (($tw ? e($tw[1]) . ' · ' : '') . ($timeTxt ? e($timeTxt) . ' · ' : '') . ($cost ? '⚡' . $cost : 'no ⚡') . ($r['can'] ? '' : ' · <span class="p2short">short ' . $shortN . '</span>'))
            : e(count(array_filter($r['ings'], fn($i) => $i['seen']))) . '/' . count($r['ings']) . ' ingredients found';
        $body = ($when ? '<p class="p2fit">' . $when . '</p>' : '') . '<p class="ccingh p2ingh">Ingredients</p>' . item_grid($sq, 'itms--flush ccings p2ings');
        $out[] = [
            'id' => (int)$r['id'], 'item' => $known ? $item : null, 'name' => $known ? (string)$r['name'] : '???', 'count' => null, 'rarity' => $item ? item_rarity($item, item_lookups())[0] : 'C',
            'group' => $group, 'status' => $status, 'flag' => !empty($r['new']) ? 'New' : ($known && $status === 'miss' ? 'short ' . $shortN : ''),
            'meta' => $meta, 'tags' => ($tw ? '<span class="tag">' . $tw[0] . ' ' . e(strtolower($tw[1])) . '</span>' : '<span class="tag">' . e(CRAFT_CATEGORIES[$tab][1] . ' ' . strtolower(CRAFT_CATEGORIES[$tab][0])) . '</span>'),
            'sub' => $sub, 'body' => $body, 'when' => $when, 'lines' => $known ? '<ul class="p2ingcmp" aria-label="Ingredients">' . $ln . '</ul>' : '',
            'have' => $have, 'need' => $need, 'acts' => $acts, 'short' => $known ? $shortN : 999, 'quick' => null, 'hay' => $known ? (string)$r['name'] : '',
            'ings' => $r['ings'], 'icons' => $icons, 'pmeta' => $known ? (($timeTxt ? str_replace([' minutes', ' minute', ' hours', ' hour'], [' min', ' min', ' h', ' h'], $timeTxt) . ' · ' : '') . ($cost ? '⚡' . $cost : 'no ⚡')) : '',
        ];
    }
    return $out;
}

/** the one-row state strip: pots (Cooking), the Tool Shed (Tools), energy and petals always. Pot chips keep .pot + data-potleft so site.js ticks them. */
function sm_station(array $u, string $tab): string
{
    $uid = (int)$u['id'];
    $o = '<span class="p2jar smstat"><span class="p2ic" aria-hidden="true">⚡</span><span class="p2jt"><b>' . (int)$u['energy'] . '</b> energy</span></span>'
       . '<span class="p2jar smstat"><span class="p2ic" aria-hidden="true">🌸</span><span class="p2jt">' . money((int)$u['coins']) . '</span></span>';
    if ($tab === 'cooking' && cook_pots_on()) {
        $pots = cook_pots_list($uid); $lim = cook_pot_limit($u);
        $outItems = [];
        foreach (q("SELECT i.* FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = 'cooking'")->fetchAll() as $it) $outItems[(int)$it['id']] = $it;
        foreach ($pots as $p) { $done = $p['left'] <= 0;
            $o .= '<div class="p2jar pot ' . ($done ? 'done' : 'busy') . '" title="' . e($p['name']) . '"><span class="p2ic">' . (isset($outItems[(int)$p['item_id']]) ? item_icon($outItems[(int)$p['item_id']], 'sm', '-') : '🍲') . '</span>'
                . '<span class="p2jt"><span class="smpn">' . e($p['name']) . ((int)$p['makes'] > 1 ? ' ×' . (int)$p['makes'] : '') . '</span> <span class="potleft" data-potleft="' . (int)$p['left'] . '">' . ($done ? 'Ready!' : e(energy_clock((int)$p['left']))) . '</span></span>'
                . '<form method="post" action="' . e(url('crafting.php?c=cooking')) . '" class="potcollect"' . ($done ? '' : ' hidden') . '>' . csrf_field() . '<input type="hidden" name="do" value="collect"><input type="hidden" name="pot_id" value="' . (int)$p['id'] . '"><button class="btn small">Collect</button></form></div>';
        }
        $free = max(0, $lim - count($pots));
        if ($free) $o .= '<div class="p2jar empty"><span class="p2ic" aria-hidden="true">🫕</span><span class="p2jt">+' . $free . ' free pot' . ($free > 1 ? 's' : '') . '</span></div>';
    } elseif ($tab === 'tools') {
        $o .= '<span class="p2jar smstat' . (craft_stations($uid)['tools'] !== 0 ? ' done' : '') . '"><span class="p2ic" aria-hidden="true">🔨</span><span class="p2jt">Tool Shed ' . (craft_stations($uid)['tools'] !== 0 ? 'ready' : 'needed') . '</span></span>';
    } elseif ($tab !== 'cooking') {
        $o .= '<span class="p2jar smstat empty"><span class="p2jt">No building needed</span></span>';
    }
    return '<section class="p2jars smstation" aria-label="Station"><div class="p2jarrow">' . $o . '</div></section>';
}

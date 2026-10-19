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
require_once __DIR__ . '/gather_game.php';   // v0.7.91 mini-games

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
 */
function gather_on_walk(array $u, string $land, ?string $tool = null, bool $sure = false, string $skill = ''): ?string
{
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
    $total = 0;
    $weights = [];
    $now = road_now();   // v1.9.3: the weather and time of day lean the pick (x3); a "!" cond is a must. Never changes what a find is worth.
    foreach ($can as $k => $g) {
        $cw = road_cond_weight($g, $now);
        if ($cw <= 0) continue;
        $w = GATHER_RARITY[$g['rarity']][1] + ($g['rarity'] !== 'common' ? 3 * $luck : 0);
        if ($skill === 'perfect' && $g['rarity'] !== 'common') $w *= 2;   // v0.7.91: a perfect mini-game makes rarer finds likelier
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
    $qty = in_array($skill, ['good', 'perfect'], true) ? 2 : 1;   // v0.7.91
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
    if ($skill !== 'perfect' && ($wear = tool_use($uid, (string)$pick['tool']))) $line .= ' ' . $wear;   // v0.7.91: a perfect strike doesn't wear the tool
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
 */
function gather_here(array $u, string $land, string $tool, string $skill = ''): array
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
    $line = gather_on_walk($u, $land, $tool, true, $skill);
    return [true, $line === null ? '🧺 You search but find nothing this time.' : gather_game_line($tool, $skill) . $line];
}

/**
 * v0.7.80: the "Gather here" box: one button per gathering tool that finds something in this land, a note for
 * the tools the gnome doesn't carry, and a fold listing every find here and the tool it needs.
 * $action is the page the buttons post to (do=gather, tool=...); $hiddenHtml is extra hidden fields.
 */
function gather_here_box(array $u, string $land, string $action, string $hiddenHtml, bool $heading = true): string
{
    $uid = (int)$u['id'];
    $L = LANDSCAPES[$land] ?? ['🌱', ucfirst($land), ''];
    $tools = gather_here_tools($u, $land);
    $h = '<div class="box gatherbox">' . ($heading ? '<h3>🧺 Gather here · ' . $L[0] . ' ' . e($L[1]) . '</h3>' : '');
    if (!$tools) {
        $h .= '<p class="help muted">Nothing to gather in this land.</p></div>';
    }
    // v0.7.91: one compact row of quick buttons, then one mini-game panel for all of them
    $open = fn(string $tool, string $cls) => '<form method="post" action="' . e($action) . '" class="' . $cls . '">' . csrf_field()
        . '<input type="hidden" name="do" value="gather"><input type="hidden" name="tool" value="' . e($tool) . '">' . $hiddenHtml;
    $usable = array_values(array_filter($tools, fn($t) => $t['has']));
    $lefts = [];
    if ($usable) {
        $h .= '<div class="gquick">';
        foreach ($usable as $t) {
            $h .= $open($t['tool'], 'inline') . '<button class="btn small" name="gquick" value="1">' . $t['icon'] . ' ' . e($t['label']) . ' ⚡1</button></form>';
            if (($left = tool_left_text($uid, $t['tool'])) !== '') $lefts[] = $t['icon'] . ' ' . e($left);
        }
        $h .= '</div>';
        if ($lefts) $h .= '<p class="help muted gleft">' . implode(' · ', $lefts) . '</p>';
        $h .= gather_game_html($u, array_column($usable, 'tool'), $open($usable[0]['tool'], 'mgform'));
    }
    $notes = [];
    foreach ($tools as $t) {
        if ($t['has']) continue;
        $notes[] = $t['carried'] ? 'Your ' . e(GATHER_TOOL_NOUN[$t['tool']]) . ' isn’t good enough here (needs ' . e(TOOL_TIERS[$t['least']] ?? 'better') . ').'
            : 'Bring ' . e(an(GATHER_TOOL_NOUN[$t['tool']])) . ' to gather here too.';
    }
    if ($notes) $h .= '<p class="help muted">' . implode(' ', $notes) . '</p>';
    if (!$tools) return $h;
    $rows = gather_candidates($land);
    usort($rows, fn($a, $b) => [GATHER_RARITY[$a['rarity']][0] ?? 1, $a['name']] <=> [GATHER_RARITY[$b['rarity']][0] ?? 1, $b['name']]);
    $h .= '<details class="helpfold"><summary>What’s here</summary><ul class="gatherlist">';
    foreach ($rows as $g) {
        $need = GATHER_RARITY[$g['rarity']][0] ?? 1;
        $known = (bool)q_val("SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id WHERE ue.user_id = ? AND en.unlock_key = ?",
            [$uid, 'gather:' . $g['slug']]);
        $h .= '<li>' . ($known ? '<b>' . e($g['name']) . '</b>' : '???') . ' · ' . e(GATHER_TOOL_NOUN[$g['tool']] ?? 'tool')
            . ' · needs ' . e(TOOL_TIERS[$need] ?? 'Worn') . ' or better' . (tool_tier($uid, $g['tool']) >= $need ? ' ✔' : '') . '</li>';
    }
    $h .= '</ul></details>'
        . '<p class="help">Each try costs ⚡1 and always turns something up if your tool is good enough.</p></div>';
    return $h;
}

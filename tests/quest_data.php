<?php
// 2026-11-28 Quest content of Wren's Journey v2: journey_v2_open off = none of it (no chapter, errand, thread, extra or line); on = the loaders parse
// every row, the counts are the quests doc's (28 main chapters, 80 side quests = 63 errands + 17 area threads, 20 cast threads, 14 happening acts),
// chapter XP is 40% of each band, and every slug named anywhere (townsfolk, items, crops, flowers, creatures, places, zones, stop types,
// happenings, chapters, extras) is in a real install with the v2 world. Every chapter's steps are read for a gnome who has reached every area.
// Run by quest_data.sh on a walk.sh install: php tests/quest_data.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/journey.php';
require_once APP_ROOT . '/includes/journey_v2.php';
require_once APP_ROOT . '/includes/quest_data.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/gnome.php';
require_once APP_ROOT . '/includes/tea.php';
require_once APP_ROOT . '/includes/world_v2.php';
require_once APP_ROOT . '/includes/creatures_v2.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$R = []; foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $R[$r['code']] = (int)$r['id'];
$has = fn(string $table, string $slug) => (bool)q_val("SELECT 1 FROM $table WHERE slug = ?", [$slug]);
/** every "item:slug:N" of a spec (slug may be a/b) */
$itemsOf = function (string $spec): array { $out = []; foreach (explode(',', $spec) as $p) { $x = explode(':', $p); if ($x[0] === 'item' && isset($x[1])) $out = array_merge($out, explode('/', $x[1])); } return $out; };
$specOf = function (string $spec): array { $o = []; foreach (explode(',', $spec) as $p) { $kv = explode(':', $p, 2); $o[$kv[0]] = $kv[1] ?? ''; } return $o; };
$placeIn = fn(string $code, string $name) => (bool)q_val('SELECT 1 FROM locations WHERE region_id = ? AND name = ?', [$R[$code] ?? 0, preg_replace('/\*\d+$/', '', $name)]);
/** a plant of that slug that is (or is not) a flower */
$plantIs = function (string $slug, bool $flower): bool { $k = q_val('SELECT kind FROM plants WHERE slug = ?', [$slug]); return $k !== false && $k !== null && ($k === 'flower') === $flower; };
$oldThreads = count(stops_file_rows('stop_threads.txt'));

echo "== journey_v2_open = 0: none of it\n";
ok('setting defaults to 0', setting('journey_v2_open') === '0');
ok('no errands, no extras', journey_errands() === [] && journey_side_errands() === [] && array_sum(array_map('count', journey_extras())) === 0);
ok('no stop-state text, no band lines', stop_state_text('market', false) === '' && stop_band_lines('NA') === ['A' => [], 'C' => [], 'P' => []]);
ok('stop_threads() is stop_threads.txt only', count(stop_threads()) === $oldThreads && !isset(stop_threads()['na-s05']) && !isset(stop_threads()['cast-pell-b2']), (string)count(stop_threads()));
ok('the 14 old chapters, no v2 chapter seeded', count(journey_chapters()) === 14 && !q_val('SELECT 1 FROM quest_chapters WHERE engine = 1'));

echo "== on, with the v2 world (its places and creatures)\n";
setg('world_v2_open', '1');
world_v2_boot();
creatures_v2_boot();
setg('journey_v2_open', '1');
ok('the v2 world is built', setting('world_v2_done') === '1' && $placeIn('NA', 'Ferry Landing') && $has('creatures', 'dhole-pack'));

echo "== main chapters (data/journey_chapters.txt)\n";
$data = journey_v2_data();
$chs = journey_chapters();
$bySlug = array_column($chs, null, 'slug');
ok('28 chapters in the file, 28 in play, every one v2 (all 14 old ones replaced)', count($data['C']) === 28 && count($chs) === 28 && count(array_filter($chs, 'journey_is_v2')) === 28, count($data['C']) . '/' . count($chs));
$tRows = []; foreach ($data['T'] as $t) $tRows[$t['chapter']][] = $t;
ok('every T row belongs to a chapter and every row of the file parsed', !array_diff(array_keys($tRows), array_keys($data['C']))
    && count($data['T']) === count(array_filter(catalog_lines('journey_chapters.txt'), fn($r) => $r[0] === 'T')));
$bad = [];
foreach ($data['C'] as $slug => $c) {
    $ch = $bySlug[$slug] ?? null;
    if (!$ch) { $bad[] = "$slug not in play"; continue; }
    $tasks = journey_tasks((int)$ch['id']);
    if (count($tasks) !== count($tRows[$slug] ?? [])) $bad[] = "$slug has " . count($tasks) . ' steps';
    if (!in_array($c['giver'], ['-', 'ottilie-kettlewick'], true) && !$has('npcs', $c['giver'])) $bad[] = "$slug giver {$c['giver']}";   // Ottilie (M5) is cast, not townsfolk yet: no portrait
    if ($c['item'] !== '-' && !$has('items', $c['item'])) $bad[] = "$slug item {$c['item']}";
    if ($c['replaces'] !== '-' && !$has('quest_chapters', $c['replaces'])) $bad[] = "$slug replaces {$c['replaces']}";
    foreach (array_filter(explode('/', $c['needs'] === '-' ? '' : $c['needs'])) as $n) if (!isset($data['C'][$n])) $bad[] = "$slug needs $n";
    $counting = array_values(array_filter($tasks, fn($t) => !(int)$t['opt']));
    if (!$counting || end($counting)['kind'] !== 'seal') $bad[] = "$slug does not end in a seal step";
    foreach ($tasks as $t) {
        foreach (array_filter([[$t['kind'], (string)$t['spec']], ($a = journey_v2_alt($t)) ? [$a[0], $a[1]] : null]) as [$kind, $spec]) {
            $sp = $specOf($spec);
            foreach ($itemsOf($spec) as $i) if (!$has('items', $i)) $bad[] = "$slug item $i";
            if (isset($sp['creature']) && !$has('creatures', $sp['creature'])) $bad[] = "$slug creature {$sp['creature']}";
            if (isset($sp['zone']) && !q_val('SELECT 1 FROM zones WHERE region_id = ? AND zone_num = ?', [$ch['region_id'], (int)$sp['zone']])) $bad[] = "$slug zone {$sp['zone']}";
            if ($kind === 'find' && $spec !== '') foreach (explode('/', $spec) as $n) if (!$placeIn($c['area'], $n)) $bad[] = "$slug place $n";
            if (in_array($kind, ['escort', 'deliver'], true)) foreach (['from', 'to'] as $k) if (isset($sp[$k]) && !in_array($sp[$k], ['stop', 'hearth', 'off'], true) && !$placeIn($c['area'], $sp[$k])) $bad[] = "$slug place {$sp[$k]}";
            if ($kind === 'plant') {
                [$what, $slugs] = explode(':', $spec) + [1 => ''];
                if ($what !== 'bed') foreach (explode('/', $slugs) as $p) if (!$plantIs($p, $what === 'flower')) $bad[] = "$slug $what $p";
            }
            if ($kind === 'help' && isset($sp['errand']) && (journey_errands()[$sp['errand']]['kind'] ?? '') !== 'helper') $bad[] = "$slug errand {$sp['errand']}";
        }
        if ($t['kind'] === 'defeat' && !journey_v2_alt($t)) $bad[] = "$slug has a defeat step with no peaceful way";
    }
}
ok('every giver, item, creature, zone, place, crop, flower, errand and chapter named by a chapter exists; each ends in a seal step; no fight without an alt', !$bad, implode('; ', array_slice($bad, 0, 12)));
$bandOf = fn(array $c) => $c['slug'] === 'the-last-page' ? 5 : ($c['slug'] === 'the-crossing' ? 2 : QUEST_BANDS[array_search((int)$c['region_id'], $R, true)]);
$xp = [1 => 0, 0, 0, 0, 0];
foreach ($chs as $c) $xp[$bandOf($c)] += journey_paid_xp($c);
$want = []; foreach ([1 => [1, 15], [15, 25], [25, 35], [35, 45], [45, 55]] as $b => [$lo, $hi]) $want[$b] = (int)round(0.4 * (xp_for_level($hi) - xp_for_level($lo)));
ok('chapter XP is 40% of each band (7,350 / 31,650 / 74,050 / 134,450 / 212,850)', $xp === $want && $xp === [1 => 7350, 31650, 74050, 134450, 212850], json_encode($xp));
ok('the last page pays 10,000 Petals and the title Roundwalker', (int)$bySlug['the-last-page']['reward_coins'] === 10000 && $bySlug['the-last-page']['reward_title'] === 'Roundwalker');
$seals = array_filter($chs, fn($c) => str_contains((string)$c['outro'], '{hearth}'));
ok('14 Seal letters (one an area), each with its benefit', count($seals) === 14 && count(array_unique(array_column($seals, 'region_id'))) === 14 && !array_filter($seals, fn($c) => (string)$c['benefit'] === ''));
ok('no letter mentions Tansy or the Hollowheart', !array_filter($chs, fn($c) => preg_match('/Tansy|Hollowheart/', $c['intro'] . $c['outro'])));

echo "== every chapter's steps read without error for a gnome who has been everywhere\n";
q('DELETE FROM user_quest_steps WHERE user_id = ?', [$uid]);
q('DELETE FROM user_quests WHERE user_id = ?', [$uid]);
foreach ($R as $rid) if (!q_val('SELECT 1 FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $rid])) db_insert('region_visits', ['user_id' => $uid, 'region_id' => $rid, 'first_at' => now()]);
$started = 0; $shown = 0;
foreach ($chs as $c) {
    $st = journey_status($u(), $c);
    if ($st['row']) $started++;
    foreach ($st['tasks'] as $t) { $shown++; journey_v2_alt_text($c, $t[0]); journey_v2_action($u(), $c, $t[0], null); }
}
ok('26 chapters start on arrival; The Crossing and The Last Page wait for the chapters they need', $started === 26 && !journey_row($uid, $bySlug['the-crossing']) && !journey_row($uid, $bySlug['the-last-page']), (string)$started);
ok('every step of every chapter was shown', $shown === count($data['T']), "$shown of " . count($data['T']));
[$cr, $crSt] = [$bySlug['maizehollow-c1-the-granary'], journey_status($u(), $bySlug['maizehollow-c1-the-granary'])];
ok('a new chapter is open, its visit step done, not complete', $crSt['row'] && $crSt['tasks'][0][3] && !$crSt['complete']);
ok('the Granary chapter took the old chapter\'s lock', (string)$cr['locks'] === (string)q_val("SELECT locks FROM quest_chapters WHERE slug = 'maizehollow-granary'"));

echo "== errands (data/journey_errands.txt)\n";
$errands = journey_errands();
$fileQ = count(array_filter(catalog_lines('journey_errands.txt'), fn($r) => $r[0] === 'Q'));
$fileS = count(array_filter(catalog_lines('journey_errands.txt'), fn($r) => $r[0] === 'S'));
ok('every Q and S row parsed', count($errands) === $fileQ && array_sum(array_map(fn($q) => count($q['steps']), $errands)) === $fileS, count($errands) . " of $fileQ");
$kinds = array_count_values(array_column($errands, 'kind'));
ok('63 errands that are side quests, 14 happening acts, 2 helpers', count(journey_side_errands()) === 63 && ($kinds['happening'] ?? 0) === 14 && ($kinds['helper'] ?? 0) === 2, json_encode($kinds));
ok('15 repeatable errands', count(array_filter($errands, fn($q) => $q['repeat'] === 'regular')) === 15);
$extras = journey_extras();
$unlockTable = ['place' => 'PLACE', 'theme' => 'THEME', 'recipe' => 'RECIPE', 'tea' => 'TEA', 'shop' => 'SHOP'];
$given = [];
/** the unknown names in an `extra` field; notes what it gives in $given */
$extraBad = function (string $extra) use (&$given, $extras, $unlockTable, $has, $plantIs): array {
    $bad = [];
    foreach (quest_extra_parts($extra) as [$k, $v]) {
        if ($k === 'page') { $given[] = "PAGE:$v"; if (!isset($extras['PAGE'][$v])) $bad[] = "page $v"; }
        elseif ($k === 'seed') { if (!$plantIs(explode(':', $v)[0], false)) $bad[] = "seed $v"; }
        elseif ($k === 'item') { if (!$has('items', explode(':', $v)[0])) $bad[] = "item $v"; }
        elseif ($k === 'unlock') {
            [$type, $slug] = explode(':', $v, 2) + [1 => ''];
            $table = $unlockTable[$type] ?? '';
            $given[] = "$table:$slug";
            if ($table === '' || (!isset($extras[$table][$slug]) && !($type === 'recipe' && $has('recipes', $slug)))) $bad[] = "unlock $v";
        } elseif (!in_array($k, ['c', 'xp', 'fp', 'title', 'mark'], true)) $bad[] = "extra $k";
    }
    return $bad;
};
$bad = [];
$stopTypes = array_column(q('SELECT DISTINCT stop_type FROM stop_tier_themes')->fetchAll(), 'stop_type');
foreach ($errands as $id => $q) {
    if (!isset($R[$q['area']])) { $bad[] = "$id area"; continue; }
    if ($q['zone'] !== '0' && !q_val('SELECT 1 FROM zones WHERE region_id = ? AND zone_num = ?', [$R[$q['area']], (int)$q['zone']])) $bad[] = "$id zone {$q['zone']}";
    if (!$q['steps'] || $q['title'] === '' || $q['intro'] === '' || $q['outro'] === '') $bad[] = "$id is incomplete";
    foreach ($extraBad($q['extra']) as $b) $bad[] = "$id $b";
    foreach ($itemsOf(str_replace('=', ':', $q['reward'])) as $i) if (!$has('items', $i)) $bad[] = "$id reward $i";
    if ($q['kind'] === 'creature' && substr_count($q['outro'], ';;') !== 2) $bad[] = "$id endings";
    foreach ($q['steps'] as $s) {
        foreach (array_filter([[$s['kind'], $s['spec']], $s['alt'] !== '-' ? array_slice(journey_v2_alt(['alt' => $s['alt'], 'kind' => $s['kind'], 'spec' => '', 'qty' => 1]), 0, 2) : null]) as [$kind, $spec]) {
            $sp = $specOf($spec);
            foreach ($itemsOf($spec) as $i) { if (isset($extras['ITEM'][$i])) $given[] = "ITEM:$i"; elseif (!$has('items', $i)) $bad[] = "$id item $i"; }
            if (isset($sp['creature']) && !$has('creatures', $sp['creature'])) $bad[] = "$id creature {$sp['creature']}";
            if (in_array($kind, ['escort', 'deliver'], true)) foreach (['from', 'to'] as $k) {
                if (isset($sp[$k]) && !in_array(preg_replace('/\*\d+$/', '', $sp[$k]), ['giver', 'stop', 'lit', 'stall', 'hall', 'bed', 'off', 'hearth'], true) && !$placeIn($q['area'], $sp[$k])) $bad[] = "$id place {$sp[$k]}";
            }
        }
        if ($s['kind'] === 'defeat' && $s['alt'] === '-') $bad[] = "$id fight without a peaceful way";
    }
    foreach (explode(',', $q['trigger']) as $part) {
        if (str_starts_with($part, 'chapter=') && !isset($data['C'][substr($part, 8)])) $bad[] = "$id trigger $part";
        if (str_starts_with($part, 'found=') && !q_val('SELECT 1 FROM locations WHERE region_id = ? AND slug = ?', [$R[$q['area']], substr($part, 6)])
            && !in_array(substr($part, 6), array_map('slugify', array_column(q('SELECT name FROM locations WHERE region_id = ?', [$R[$q['area']]])->fetchAll(), 'name')), true)) $bad[] = "$id trigger $part";
    }
}
ok('every area, zone, item, creature, place, chapter and extra named by an errand exists', !$bad, implode('; ', array_slice($bad, 0, 12)));

echo "== threads (data/stop_threads_v2.txt through stop_threads())\n";
$threads = stop_threads();
$v2Threads = array_filter($threads, fn($t) => isset(array_column(stops_file_rows('stop_threads_v2.txt'), null, 0)[$t['id']]));
$area = array_filter($v2Threads, fn($t) => !str_starts_with($t['id'], 'cast-'));
ok('37 more threads while on: 17 area threads + 20 cast threads', count($threads) === $oldThreads + 37 && count($v2Threads) === 37 && count($area) === 17, (string)count($threads));
ok('80 side quests: 63 errands + 17 area threads', count(journey_side_errands()) + count($area) === 80);
$bad = [];
foreach ($v2Threads as $id => $t) {
    if (count($t['beats']) < 4 || count($t['beats']) > 6 || array_filter($t['beats'], fn($b) => $b['title'] === '' || $b['text'] === '')) $bad[] = "$id beats";
    if (!$t['regions'] || array_diff($t['regions'], array_keys($R))) $bad[] = "$id regions";
    if ($t['types'] !== 'any' && array_diff(explode(',', $t['types']), $stopTypes)) $bad[] = "$id types";
    foreach ($extraBad($t['extra']) as $b) $bad[] = "$id $b";
    foreach ($itemsOf(str_replace('=', ':', $t['reward'])) as $i) if (!$has('items', $i)) $bad[] = "$id reward $i";
}
ok('every v2 thread has 4 to 6 beats, real regions, stop types, reward items and extras', !$bad, implode('; ', array_slice($bad, 0, 12)));
$inn = q_one("SELECT l.* FROM locations l WHERE l.region_id = ? AND l.kind = 'village' AND l.stop_type = 'inn' LIMIT 1", [$R['NWE']]);
$fit = array_filter($v2Threads, fn($t) => in_array('NWE', $t['regions'], true) && (in_array('inn', explode(',', $t['types']), true) || $t['types'] === 'any'));
ok('a Mistmoor inn has v2 threads to offer (the tearoom cup among them)', $inn && isset($fit['nwe-s02']) && count($fit) >= 3, (string)count($fit));

echo "== extras (data/journey_extras.txt)\n";
ok('13 places, 16 themes, 13 recipes, 4 teas, 11 stall lines', array_map('count', array_intersect_key($extras, $unlockTable + ['PLACE' => 1, 'THEME' => 1, 'RECIPE' => 1, 'TEA' => 1, 'SHOP' => 1])) === ['PLACE' => 13, 'THEME' => 16, 'RECIPE' => 13, 'TEA' => 4, 'SHOP' => 11],
    json_encode(array_map('count', $extras)));
$bad = [];
foreach ($extras as $type => $rows) foreach ($rows as $slug => $r) {
    if ($slug !== 'two-lamp-loaf' && !in_array("$type:$slug", $given, true)) $bad[] = "$type $slug is given by nothing";
    if ($type === 'RECIPE') {
        if ($has('recipes', $slug)) $bad[] = "recipe $slug exists";
        foreach (explode(',', $r['ingredients']) as $p) if (!$plantIs(explode(':', $p)[0], false)) $bad[] = "$slug ingredient $p";
    }
    if ($type === 'TEA') {
        $parts = explode(',', $r['components']);
        if (array_diff($parts, array_keys(tea_ingredients())) || tea_named_for($parts)) $bad[] = "tea $slug";
    }
    if ($type === 'PLACE' && (!q_val('SELECT 1 FROM zones WHERE region_id = ? AND zone_num = ?', [$R[$r['region']] ?? 0, (int)$r['zone']]) || $placeIn($r['region'], $r['name']))) $bad[] = "place $slug";
    if ($type === 'THEME' && (array_diff(explode(',', $r['types']), $stopTypes) || !in_array($r['tier'], ['1', '2', '3', '4'], true))) $bad[] = "theme $slug";
}
ok('every extra is given by an errand or a thread; recipes, teas, places and themes fit the game', !$bad, implode('; ', array_slice($bad, 0, 12)));
ok('no Puzzle Pal is a quest reward', !preg_match('/unlock=pal/', file_get_contents(APP_ROOT . '/includes/data/journey_errands.txt') . file_get_contents(APP_ROOT . '/includes/data/stop_threads_v2.txt')));

echo "== stop-state text and band lines\n";
$missing = array_filter($stopTypes, fn($t) => stop_state_text($t, false) === '' || stop_state_text($t, true) === '' || stop_state_text($t, false) === stop_state_text($t, true));
ok('each of the 12 stop types has a dark and a lit line', count($stopTypes) === 12 && !$missing, implode(',', $missing));
$bad = [];
foreach (array_keys($R) as $code) { $l = stop_band_lines($code); if (array_map('count', $l) !== ['A' => 6, 'C' => 4, 'P' => 3]) $bad[] = $code; }
ok('every area has its band\'s 6 ambience, 4 chat and 3 plaque lines', !$bad && count(QUEST_BANDS) === 14, implode(',', $bad));
ok('ambience is split dark and lit', count(array_filter(stop_band_lines('OC')['A'], fn($a) => str_ends_with($a[0], 'lit=0'))) === 3);

echo "== off again: gone\n";
setg('journey_v2_open', '0');
ok('errands, extras, lines and v2 threads are gone; the old chapters are back', journey_errands() === [] && stop_state_text('inn', true) === '' && count(stop_threads()) === $oldThreads && count(journey_chapters()) === 14);
q('DELETE FROM user_quest_steps WHERE user_id = ?', [$uid]);
q('DELETE FROM user_quests WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);

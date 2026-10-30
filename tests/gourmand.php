<?php
// The Gourmand: the data file lint, the spoon bars and the camp schedule (includes/gourmand.php). Run by gourmand.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/world.php';
require_once $argv[1] . '/includes/town.php';
require_once $argv[1] . '/includes/gourmand.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }

echo "== bars\n";
ok('plate 39/40/50/65 = 0/1/2/3', array_map(fn($q) => gourmand_spoons('plate', $q), [39, 40, 50, 65]) === [0, 1, 2, 3]);
ok('pot and grand use the plate bars', gourmand_spoons('pot', 49) === 1 && gourmand_spoons('grand', 64) === 2);
ok('jar 44/45/52/62 = 0/1/2/3', array_map(fn($q) => gourmand_spoons('jar', $q), [44, 45, 52, 62]) === [0, 1, 2, 3]);
ok('quick jam 41/42/49/55 = 0/1/2/3, a long jar keeps 44/45/52/62', array_map(fn($q) => gourmand_spoons('jar', $q, 'plum-jam'), [41, 42, 49, 55]) === [0, 1, 2, 3] && array_map(fn($q) => gourmand_spoons('jar', $q, 'sauerkraut'), [44, 45, 52, 62]) === [0, 1, 2, 3] && gourmand_bars('jar') === [45, 52, 62]);
ok('words', gourmand_word(1) === 'Honest' && gourmand_word(2) === 'Seconds, please' && gourmand_word(3) === 'Splendid' && gourmand_word(0) === '');

echo "== schedule\n";
$fests = array_map(fn($f) => $f[2], TOWN_FESTIVALS);
$errs = []; $dst = [];
for ($y = 2026; $y <= 2028; $y++) for ($m = 1; $m <= 12; $m++) {
    $ym = sprintf('%d-%02d', $y, $m);
    $dim = (int)(new DateTimeImmutable("$ym-01", hollow_tz()))->format('t');
    $win = gourmand_schedule($ym);
    $cover = array_fill(1, $dim, 0);
    foreach ($win as $i => $w) {
        for ($d = $w['from']; $d <= $w['to']; $d++) $cover[$d]++;
        if ($i > 0 && $w['starts'] !== $win[$i - 1]['ends']) $errs[] = "$ym: window $i does not start where the last ended";
        $h = ($w['ends'] - $w['starts']) / 3600; $days = $w['to'] - $w['from'] + 1;
        if (abs($h - 24 * $days) > 1) $errs[] = "$ym: {$w['town']} lasts {$h}h";
        if ($h != 24 * $days) $dst[] = "$ym {$w['town']}";
    }
    if (count(array_filter($cover, fn($c) => $c !== 1))) $errs[] = "$ym: a day is covered 0 or 2 times";
    if ($win[0]['town'] !== 'Mossbottom' || $win[0]['to'] !== 1) $errs[] = "$ym: day 1 is not Mossbottom";
    $last = $win[count($win) - 1];
    if ($last['town'] !== 'The Coralscatter' || $last['from'] !== 28 || $last['to'] !== $dim) $errs[] = "$ym: OC does not run 28 to the end";
    foreach ($win as $w) if ($w['town'] !== 'The Coralscatter' && $w['to'] !== $fests[$w['town']]) $errs[] = "$ym: {$w['town']} does not end on its festival";
    $wend = gourmand_schedule(hollow_date('Y-m', $last['ends']))[0];
    if ($wend['starts'] !== $last['ends']) $errs[] = "$ym: the month does not hand over to the next";
}
ok('2026-2028: every day one stop, windows chain, 24h per day (+-1h at DST), day 1 Mossbottom, OC 28 to the end' . ($errs ? ' [' . implode('; ', array_slice($errs, 0, 4)) . ']' : ''), !$errs);
ok('a DST change was seen in 2026-2028 (47 or 49 h windows)', count($dst) >= 2, implode(',', $dst));
$oc = fn(string $ym) => array_values(array_filter(gourmand_schedule($ym), fn($w) => $w['town'] === 'The Coralscatter'))[0];
ok('February 2027 gives OC 1 day, February 2028 gives 2', $oc('2027-02')['to'] - $oc('2027-02')['from'] + 1 === 1 && $oc('2028-02')['to'] - $oc('2028-02')['from'] + 1 === 2);
$moved = $fests; $moved['Spicepeak'] = 20;
$w = array_column(gourmand_schedule('2026-10', $moved), null, 'town');
ok('moving a festival day moves the windows (Spicepeak to 20 pulls Thornacre and Blossomreach with it)', [$w['Spicepeak']['from'], $w['Spicepeak']['to'], $w['Thornacre Savanna']['from'], $w['Thornacre Savanna']['to'], $w['Blossomreach']['from']] === [20, 20, 21, 21, 22]);
$w = array_column(gourmand_schedule('2026-10'), null, 'town');
ok('default windows: Maplewold 2-3, Mistmoor 10-11, Spicepeak 22-23', [$w['The Maplewold']['from'], $w['The Maplewold']['to'], $w['Mistmoor']['from'], $w['Mistmoor']['to'], $w['Spicepeak']['from'], $w['Spicepeak']['to']] === [2, 3, 10, 11, 22, 23]);

echo "== gourmand_stop\n";
$at = fn(string $d, string $t = '12:00:00') => (new DateTimeImmutable("$d $t", hollow_tz()))->getTimestamp();
$s = gourmand_stop($at('2026-10-01'));
ok('day 1: Mossbottom, hub-green, Long Table, festival', $s['town'] === 'Mossbottom' && $s['code'] === 'MB' && $s['camp'] === 'hub-green' && $s['long_table'] && $s['festival'] && $s['stop'] === '2026-10|MB' && $s['tour'] === '2026-10');
$s = gourmand_stop($at('2026-10-02'));
ok('day 2: the Maplewold camp, not yet its festival', $s['code'] === 'NA' && $s['camp'] === 'na-sugarshack' && !$s['festival'] && !$s['long_table'] && $s['next']['code'] === 'CA');
$s = gourmand_stop($at('2026-10-03'));
ok('day 3: festival true, next is Maizehollow', $s['festival'] && $s['code'] === 'NA' && $s['next']['code'] === 'CA' && $s['next']['starts'] === $s['ends']);
$s = gourmand_stop($at('2026-10-28')); $e = gourmand_stop($at('2026-10-31', '23:59:00'));
ok('day 28: OC with its festival, still OC on the 31st', $s['code'] === 'OC' && $s['festival'] && $e['code'] === 'OC' && !$e['festival'] && $e['next']['code'] === 'MB' && $e['next']['starts'] === $e['ends']);
$s = gourmand_stop($at('2026-10-06', '00:00:00')); $p = gourmand_stop($at('2026-10-05', '23:59:59'));
ok('midnight switches the camp', $p['code'] === 'CA' && $s['code'] === 'CB' && $p['ends'] === $s['starts'] && $s['starts'] === $at('2026-10-06', '00:00:00'));
cfg(['gourmand_force_date' => '2026-10-17']);
ok('gourmand_force_date moves him (noon)', gourmand_now() === $at('2026-10-17') && gourmand_stop()['code'] === 'MENA');
cfg(['gourmand_force_date' => '']);
ok('no force date = the clock', abs(gourmand_now() - time()) <= 2);

echo "== data lint: gourmand.txt\n";
$rows = gourmand_rows();
$codes = array_map(fn($r) => $r[0], stops_file_rows('regions.txt'));
$errs = [];
foreach (array_merge($codes, ['MB']) as $c) if (empty($rows['R'][$c])) $errs[] = "no R row for $c";
foreach ($rows['R'] as $c => $r) {
    if (!in_array($c, array_merge($codes, ['MB']), true)) $errs[] = "R row for unknown $c";
    if (!q_val('SELECT 1 FROM town_spots WHERE slug = ?', [$r['camp']])) $errs[] = "{$c}: camp spot {$r['camp']} missing";
    if (mb_strlen($r['line']) > 140) $errs[] = "$c: camp line too long";
}
ok('every region and Mossbottom has one R row with a real camp spot', !$errs && count($rows['R']) === 15, implode('; ', array_slice($errs, 0, 4)));
$errs = []; $jarOk = [];
$crops = [];
foreach (stops_file_rows('region_crops.txt') as $r) if (in_array($r[1] ?? '', ['staple', 'uncommon'], true)) foreach (explode(',', $r[2]) as $cr) $crops[$r[0]][] = trim($cr);
foreach ($codes as $c) {
    foreach (['plate', 'pot', 'jar'] as $course) if (empty($rows['M'][$c][$course][1])) $errs[] = "$c has no $course";
    if (count($rows['M'][$c]['pot'] ?? []) < 2) $errs[] = "$c has no second pot";
    foreach ($rows['M'][$c] ?? [] as $course => $vars) foreach ($vars as $v => $m) {
        $tag = "$c $course $v {$m['item']}";
        $it = q_one('SELECT id, category FROM items WHERE slug = ?', [$m['item']]);
        if (!$it) { $errs[] = "$tag: no such item"; continue; }
        if ($m['qty'] < 1 || $m['qty'] > 5) $errs[] = "$tag: qty {$m['qty']}";
        foreach (['ask', 'note'] as $f) {
            if (mb_strlen($m[$f]) > 140 || mb_strlen($m[$f]) < 20) $errs[] = "$tag: $f length " . mb_strlen($m[$f]);
            if (str_contains($m[$f], "'")) $errs[] = "$tag: straight apostrophe in $f";
        }
        if ($course === 'plate') {
            if ($it['category'] !== 'produce' || !in_array($m['item'], $crops[$c] ?? [], true)) $errs[] = "$tag: not a staple or uncommon crop of $c";
        } else {
            $rec = q_one('SELECT tier, cook_minutes, ingredients FROM recipes WHERE slug = ?', [$m['item']]);
            if (!$rec) { $errs[] = "$tag: no recipe"; continue; }
            if ($course === 'grand' && ($rec['tier'] !== 'feast' || !str_starts_with($m['item'], 'feast-'))) $errs[] = "$tag: tier {$rec['tier']}";
            if ($course === 'pot' && !in_array($rec['tier'], ['snack', 'meal'], true)) $errs[] = "$tag: tier {$rec['tier']}";
            if ($course === 'jar') {
                if ($rec['tier'] !== 'preserve') $errs[] = "$tag: tier {$rec['tier']}";
                $days = max(1, (int)round((int)$rec['cook_minutes'] / 1440));
                $hard = in_array($m['item'], ['hummus-jar', 'pickled-okra'], true);   // deliberately hard: exactly on the normal 62 bar
                $best = 38 + min(20, 2 * $days) + 9 + 3 * min(4, count(json_decode($rec['ingredients'], true) ?: [])) + 4 + 3;   // Kitchen III, max luck, max roll
                if (!$hard && gourmand_spoons('jar', $best, $m['item']) < 3) $errs[] = "$tag: cannot reach 3 spoons (max $best)";
                if ($hard && gourmand_bars('jar', $m['item']) !== [45, 52, 62]) $errs[] = "$tag: hard ask lost the normal bars";
                $jarOk[$c] = true;
            }
        }
    }
    if (!isset($jarOk[$c])) $errs[] = "$c has no jar ask";
}
ok('every region has plate, pot and jar rows that are real items of the right kind, two pots, and every jar ask able to reach 3 spoons at Kitchen III with max luck and roll (except hummus-jar and pickled-okra)', !$errs, implode('; ', array_slice($errs, 0, 4)));
foreach ($rows['M'] as $c => $x) foreach ($x as $course => $vars) if (!in_array($course, ['plate', 'pot', 'jar', 'grand'], true)) $errs[] = "$c: course $course";
$t0 = gourmand_menu('EE', '2026-10'); $t1 = gourmand_menu('EE', '2026-11'); $t2 = gourmand_menu('EE', '2026-12');
ok('menus rotate monthly through the jar variants', $t0['jar']['variant'] !== $t1['jar']['variant'] && $t1['jar']['variant'] !== $t2['jar']['variant'] && gourmand_menu('NA', '2026-10')['plate']['item'] === 'wild-rice');
ok('itinerary lists every stop with its camp', count(gourmand_itinerary('2026-10')) === 15 && array_filter(gourmand_itinerary('2026-10'), fn($w) => $w['camp'] === '') === []);
$errs = [];
$grandRegions = ['NA', 'CA', 'CB', 'NWE', 'SE', 'EE', 'MENA', 'CSA'];
foreach (stops_file_rows('regions.txt') as $r) { $t = gourmand_menu($r[0], '2026-10'); if (count($t) !== (in_array($r[0], $grandRegions, true) ? 4 : 3) || isset($t['grand']) !== in_array($r[0], $grandRegions, true)) $errs[] = $r[0]; }
ok('each region serves plate, pot and jar in a tour, and the 8 feast regions also a Grand', !$errs, implode(',', $errs));
$errs = [];
foreach ($grandRegions as $c) { $g = $rows['M'][$c]['grand'][1]['item'] ?? ''; if (!preg_match('/^feast-/', $g)) $errs[] = "$c grand $g"; }
ok('the 8 Grand courses are the regional feasts, one each, all distinct', !$errs && count(array_unique(array_map(fn($c) => $rows['M'][$c]['grand'][1]['item'], $grandRegions))) === 8, implode(',', $errs));
// P2 recipes: 14 regional dishes + chicha + poi, every ingredient a real item, pots in the Pot tiers, the two jars preserves
$newPots = ['wild-rice-hotdish', 'bean-tamales', 'rice-and-peas', 'quinoa-soup', 'colcannon', 'artichoke-fava-stew', 'buckwheat-kasha', 'falafel', 'egusi-soup', 'sukuma-wiki', 'khichdi', 'red-bean-buns', 'kangkong-stir-fry', 'palusami'];
$errs = [];
foreach (array_merge($newPots, ['chicha', 'poi']) as $slug) {
    $rec = q_one('SELECT tier, ingredients FROM recipes WHERE slug = ?', [$slug]);
    if (!$rec) { $errs[] = "$slug: no recipe"; continue; }
    if (in_array($slug, $newPots, true) ? !in_array($rec['tier'], ['snack', 'meal'], true) : $rec['tier'] !== 'preserve') $errs[] = "$slug: tier {$rec['tier']}";
    foreach (array_keys(json_decode($rec['ingredients'], true) ?: []) as $ing) if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$ing])) $errs[] = "$slug: ingredient $ing missing";
}
ok('the 16 P2 recipes exist with real ingredients and the right tiers', !$errs, implode('; ', array_slice($errs, 0, 4)));
$pots2 = array_filter(array_map(fn($x) => $x['pot'][2]['item'] ?? '', $rows['M'])); sort($pots2); $np = $newPots; sort($np);
ok('the v2 Pot rows are exactly the 14 new dishes, and SA and OC have chicha and poi as jars', $pots2 == $np && ($rows['M']['SA']['jar'][3]['item'] ?? '') === 'chicha' && ($rows['M']['OC']['jar'][2]['item'] ?? '') === 'poi');
// jar reachability at Kitchen III with no luck and no wobble: 38 + min(20, 2 days) + 9 + 3 kinds must reach the 62 bar. Hummus and okra land on it exactly (hard by design)
$jarBase = function (string $slug): int {
    $r = q_one('SELECT cook_minutes, ingredients FROM recipes WHERE slug = ?', [$slug]);
    return 38 + min(20, 2 * max(1, (int)round((int)$r['cook_minutes'] / 1440))) + 9 + 3 * min(4, count(json_decode($r['ingredients'], true) ?: []));
};
ok('chicha and poi clear the 3-spoon jar bar at Kitchen III with room to spare', $jarBase('chicha') > GOURMAND_BARS['jar'][2] && $jarBase('poi') > GOURMAND_BARS['jar'][2]);
ok('hummus-jar and pickled-okra land exactly on the bar (a -3 wobble costs the third spoon), by design', $jarBase('hummus-jar') === GOURMAND_BARS['jar'][2] && $jarBase('pickled-okra') === GOURMAND_BARS['jar'][2]);
foreach (['plum-jam', 'raspberry-jam', 'lingonberry-jam', 'guava-jam'] as $jam) {
    $maxQ = $jarBase($jam) + 4 + 3; $lowQ = $jarBase($jam) - 3;   // Kitchen III: max luck + best roll, and no luck + worst roll
    ok("$jam (quick jar) reaches 3 spoons only with a decent roll: max $maxQ >= 55, low roll $lowQ does not", $maxQ >= 55 && gourmand_spoons('jar', $maxQ, $jam) === 3 && gourmand_spoons('jar', $lowQ, $jam) < 3 && gourmand_bars('jar', $jam) === [42, 49, 55]);
}
ok('hummus-jar and pickled-okra stay on the normal 62 bar and stay hard (no-luck best roll lands only on it, a -3 wobble misses)', gourmand_bars('jar', 'hummus-jar') === [45, 52, 62] && gourmand_bars('jar', 'pickled-okra') === [45, 52, 62] && gourmand_spoons('jar', $jarBase('hummus-jar') - 3, 'hummus-jar') < 3);
ok('MENA and WCA each also have an easier jar, so the hard one is a choice', $jarBase('pomegranate-molasses') > GOURMAND_BARS['jar'][2] && $jarBase('hibiscus-cordial') > GOURMAND_BARS['jar'][2]);
ok('sauerkraut (EE/2 ask) still reaches 3 spoons at Kitchen III after its ingredients rose to 6 cabbage (same kinds, same timer)', $jarBase('sauerkraut') >= GOURMAND_BARS['jar'][2] && array_keys(json_decode((string)q_val("SELECT ingredients FROM recipes WHERE slug = 'sauerkraut'"), true)) === ['cabbage']);
ok('fermented-carrots is no longer a copy of pickled-carrots and gains a third kind (+3 jar score)', array_keys(json_decode((string)q_val("SELECT ingredients FROM recipes WHERE slug = 'fermented-carrots'"), true)) === ['carrot', 'ginger', 'garlic']);
$errs = [];
foreach ($rows['B'] as $k => $b) { if (str_contains($b['text'], "'")) $errs[] = "$k apostrophe"; if (mb_strlen($b['text']) > 400) $errs[] = "$k long"; }
ok('beats hello first four mid home finale, in order of tastes needed, no straight apostrophes', array_keys($rows['B']) === ['hello', 'first', 'four', 'mid', 'home', 'finale'] && array_column($rows['B'], 'tastes') === [0, 1, 4, 7, 10, 14] && !$errs, implode(',', $errs));
$raw = file_get_contents($argv[1] . '/includes/data/gourmand.txt');
ok('no straight apostrophes in any data line', !array_filter(preg_split('/\R/', $raw), fn($l) => $l !== '' && $l[0] !== '#' && str_contains($l, "'")));


// ================================================================ P1: the NPC, the switch, serving, the ledger, the finale, dish scores
$_SESSION = [];
require_once $argv[1] . '/includes/crafting.php';
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$U = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$pom = (int)q_val("SELECT id FROM npcs WHERE traveller = 'gourmand'");
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
$xp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$friend = fn() => (int)q_val('SELECT points FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$uid, $pom]);
$held = fn(string $slug) => (int)q_val('SELECT COALESCE(SUM(qty), 0) FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = ?)', [$uid, $slug]);
$led = fn(string $region, string $course) => q_one('SELECT * FROM gourmand_ledger WHERE user_id = ? AND region = ? AND course = ?', [$uid, $region, $course]);
$deals = fn() => (int)q_val('SELECT COUNT(*) FROM traveller_deals WHERE user_id = ? AND npc_id = ?', [$uid, $pom]);
$stock = function (string $slug, int $n, ?int $qual) use ($uid): void {   // $qual null = bought (no quality note)
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
    q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $id]);
    give_item($uid, $id, $n);
    if ($qual !== null) market_note_quality($uid, $id, $n, $qual);
};
$at = fn(string $loc) => q('UPDATE users SET location = ? WHERE id = ?', [$loc, $uid]);
$day = fn(string $d) => cfg(['gourmand_force_date' => $d]);
$serve = function (string $code, string $course, ?int $qual, string $tour) use ($stock, $U): array {   // stock the month's ask at $qual, then serve it
    $row = gourmand_menu($code, $tour)[$course];
    $stock($row['item'], $row['qty'], $qual);
    return gourmand_serve($U(), $course);
};
$prizes = fn() => count($_SESSION['prizes'] ?? []);
q('UPDATE users SET level = 10, coins = 0, guest = 0 WHERE id = ?', [$uid]);
// start from the shipped state, whatever gourmand.sh did over HTTP before this
cfg(['gourmand_open' => '0', 'gourmand_force_date' => '']); gourmand_sync_active();
q('DELETE FROM traveller_deals WHERE user_id = ?', [$uid]); q('DELETE FROM gourmand_ledger WHERE user_id = ?', [$uid]); q('DELETE FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$uid, $pom]);

echo "== the switch: off by default, and nothing of him shows\n";
ok('with the switch off the NPC row is inactive', setting('gourmand_open') === '0' && (int)q_val("SELECT active FROM npcs WHERE traveller = 'gourmand'") === 0 && $pom > 0);
ok('he is the Fussy dormouse Pomeroy Crumbworth', q_val('SELECT name FROM npcs WHERE id = ?', [$pom]) === 'Pomeroy Crumbworth' && q_val('SELECT species FROM npcs WHERE id = ?', [$pom]) === 'Dormouse');
require_once $argv[1] . '/includes/villagers.php';
require_once $argv[1] . '/includes/folk_list.php';
$seen = function () use ($U, $uid): string {
    $names = array_column(villagers_all($U()), 'name');
    $camp = q_one("SELECT * FROM town_spots WHERE slug = 'na-sugarshack'");
    $a = array_map(fn($n) => $n['name'], npcs_at_spot($camp));
    $tea = [];
    foreach (all_regions() as $r) $tea = array_merge($tea, teahouse_rumours($r['gnomish_name'], 20));
    $trav = array_column(q('SELECT name FROM npcs WHERE traveller IS NOT NULL AND active = 1')->fetchAll(), 'name');
    $folk = array_column(met_npcs($uid), 'name');
    return implode('|', array_merge($names, $a, $tea, $trav, $folk));
};
$day('2026-10-02');   // his camp is the Maplewold's
q('INSERT OR IGNORE INTO user_npc_met (user_id, npc_id, first_at) VALUES (?, ?, ?)', [$uid, $pom, now()]);
ok('off: not in the villagers list, the camp spot, the teahouse rumours, the travellers fold or the folk list', !str_contains($seen(), 'Pomeroy'));
ok('off: a player cannot serve (the gate), the admin-only page is not for players', !gourmand_open() && gourmand_serve($U(), 'plate')[0] === false);
cfg(['gourmand_open' => '1']); gourmand_sync_active();
ok('on: sync flips npcs.active to 1', (int)q_val("SELECT active FROM npcs WHERE traveller = 'gourmand'") === 1);
$s = $seen();
ok('on: he is in the villagers list, at the camp spot, the folk list and the travellers', substr_count($s, 'Pomeroy') >= 4, $s);
$camp = q_one("SELECT * FROM town_spots WHERE slug = 'na-sugarshack'"); $green = q_one("SELECT * FROM town_spots WHERE region = 'The Maplewold' AND kind = 'green'");
ok('on: at the camp spot and not on the Green', in_array('Pomeroy Crumbworth', array_column(npcs_at_spot($camp), 'name'), true) && !in_array('Pomeroy Crumbworth', array_column(npcs_at_spot($green), 'name'), true));
$gn = q_one('SELECT * FROM npcs WHERE id = ?', [$pom]);
ok('on: npc_now puts him at the camp, npc_routine and the offer do not say Green, the offer is a link', npc_now($gn)['spot']['slug'] === 'na-sugarshack' && !str_contains(implode(' ', npc_routine($gn)), 'Green') && traveller_offer($gn)['kind'] === 'link' && traveller_offer($gn)['url'] === 'gourmand.php');
ok('on: he is "here" for everyone (npc_here), and traveller_deal refuses him', npc_here($U(), $pom) && traveller_deal($U(), $pom)[0] === false);
ok('on: the teahouse says where he sits, not "the Green", and his ask is gossiped', (function () {
    $all = []; foreach (all_regions() as $r) $all = array_merge($all, teahouse_rumours($r['gnomish_name'], 30));
    $mine = array_filter($all, fn($l) => str_contains($l, 'Pomeroy'));
    return $mine && !array_filter($mine, fn($l) => str_contains($l, 'Green'));
})());
cfg(['gourmand_open' => '0']); gourmand_sync_active();
ok('off again: inactive and gone from the lists', (int)q_val("SELECT active FROM npcs WHERE traveller = 'gourmand'") === 0 && !str_contains($seen(), 'Pomeroy'));
cfg(['gourmand_open' => '1']); gourmand_sync_active();

echo "== serving: gates and the plain-stack guard\n";
$day('2026-10-14');   // a day in nobody's window for the Maplewold: serving is always open
$at('The Maplewold');
ok('title and region: standing in the Maplewold is region NA, Mossbottom has no courses', gourmand_here($U()) === 'NA');
$row = gourmand_menu('NA', '2026-10')['plate'];
$stock($row['item'], 3, null);
[$okk, $m] = gourmand_serve($U(), 'plate');
ok('a bought stack (quality 35) is refused: "shop counter", nothing taken, no claim made', !$okk && str_contains($m, 'shop counter') && $held('wild-rice') === 3 && $deals() === 0, $m);
$stock('wild-rice', 3, 70); $wid = (int)q_val("SELECT id FROM items WHERE slug = 'wild-rice'");
give_item($uid, $wid, -3); give_item($uid, $wid, 3);
ok('selling the good stack and buying plain ones does not keep the old quality (the give_item fix)', market_stack_q($uid, $wid) === 35);
$stock('wild-rice', 2, 70);
[$okk, $m] = gourmand_serve($U(), 'plate');
ok('too few held is refused with what he asked for', !$okk && str_contains($m, '3 × Wild Rice') && $held('wild-rice') === 2, $m);
q('UPDATE users SET level = 2 WHERE id = ?', [$uid]); $stock('wild-rice', 3, 70);
ok('below level 3 is refused', !gourmand_serve($U(), 'plate')[0] && $held('wild-rice') === 3);
q('UPDATE users SET level = 10 WHERE id = ?', [$uid]);
$adm = (int)q_val("SELECT id FROM users WHERE username = 'admin'");   // is_guest_uid caches per request, so use a row it has not seen
q('UPDATE users SET level = 10, guest = 1, location = ? WHERE id = ?', ['The Maplewold', $adm]);
$stock('wild-rice', 3, 70);
ok('a guest is refused', !gourmand_serve(q_one('SELECT * FROM users WHERE id = ?', [$adm]), 'plate')[0] && $held('wild-rice') === 3 && $deals() === 0);
q('UPDATE users SET guest = 0 WHERE id = ?', [$adm]);
ok('a course he does not serve is refused', !gourmand_serve($U(), 'grand')[0] && !gourmand_serve($U(), '')[0]);
$at('Mossbottom');
ok('Mossbottom has no courses', gourmand_here($U()) === '' && !gourmand_serve($U(), 'plate')[0] && $held('wild-rice') === 3);
$at('Maizehollow'); $stock('tomatillo', 0, null);
ok('serving the Maplewold menu from another region is refused (that region wants its own)', gourmand_here($U()) === 'CA' && !gourmand_serve($U(), 'plate')[0] && $held('wild-rice') === 3);
$at('The Maplewold');

echo "== the serve event: jobs, hollow jars and callings hear one event per paid serve\n";
require_once $argv[1] . '/includes/jobs.php';
require_once $argv[1] . '/includes/hollow_goals.php';
require_once $argv[1] . '/includes/calling_quests.php';
$JK = job_period_key('daily');
q('DELETE FROM user_jobs WHERE user_id = ?', [$uid]);
db_insert('user_jobs', ['user_id' => $uid, 'period' => 'daily', 'period_key' => $JK, 'kind' => 'serve', 'title' => 'Serve', 'text' => 'Serve', 'qty' => 99, 'progress' => 0, 'status' => 'active', 'taken_at' => now()]);
$jobN = fn() => (int)q_val("SELECT progress FROM user_jobs WHERE user_id = ? AND kind = 'serve'", [$uid]);
ok('serve is a calling event kind, and a spoons filter reads the ctx', in_array('serve', CALLING_EVENT_KINDS, true) && calling_match(calling_spec('spoons>=2'), 'NA', ['spoons' => 3]) && !calling_match(calling_spec('spoons>=2'), 'NA', ['spoons' => 1]));
ok('a Hollow serve jar counts 1 per event, and no other jar counts it', hollow_goal_adds(['kind' => 'serve', 'filter' => ''], 'serve', 'NA', 1, []) === 1 && hollow_goal_adds(['kind' => 'cook', 'filter' => ''], 'serve', 'NA', 1, []) === 0 && hollow_goal_adds(['kind' => 'any', 'filter' => ''], 'serve', 'NA', 1, []) === 0);
ok('every refusal so far fired nothing', $jobN() === 0);
echo "== serving: the first time pays every spoon level once\n";
$c0 = $coins(); $x0 = $xp(); $f0 = $friend(); $d0 = $deals(); $p0 = $prizes();
[$okk, $m] = gourmand_serve($U(), 'plate');
$L = $led('NA', 'plate');
ok('plate at quality 70 = 3 spoons, "Splendid"', $okk && str_contains($m, 'Splendid') && (int)$L['spoons'] === 3 && (int)$L['best_q'] === 70 && (int)$L['paid'] === 3 && (int)$L['served'] === 1, $m);
ok('0 -> 3 spoons pays 240 Petals (60 + 60 + 120)', $coins() - $c0 === 240, (string)($coins() - $c0));
ok('and 80 XP (20 + 20 + 40), the ask is taken, friendship +10, one claim, one prize card', $xp() - $x0 >= 80 && $held('wild-rice') === 0 && $friend() - $f0 === 10 && $deals() === $d0 + 1 && $prizes() === $p0 + 1, ($xp() - $x0) . '/' . $friend());
ok('the claim row is Y-m|CODE|course', (bool)q_val("SELECT 1 FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop = '2026-10|NA|plate'", [$uid, $pom]));
ok('the first paid serve fired the event once', $jobN() === 1, (string)$jobN());
$stock('wild-rice', 3, 70); $c1 = $coins();
[$okk, $m] = gourmand_serve($U(), 'plate');
ok('the same course twice in one tour is refused, nothing taken or paid', !$okk && str_contains($m, 'Already served') && $held('wild-rice') === 3 && $coins() === $c1, $m);
$d1 = $deals(); gourmand_serve($U(), 'plate'); gourmand_serve($U(), 'plate');
ok('and no extra claim rows', $deals() === $d1);
ok('and a refused repeat fires nothing', $jobN() === 1, (string)$jobN());

echo "== a Taste (full table) and a golden table pay once\n";
$c0 = $coins();
[$o1] = $serve('NA', 'pot', 70, '2026-10');
ok('pot at score 70 = 3 spoons, +240', $o1 && $coins() - $c0 === 240 && (int)$led('NA', 'pot')['spoons'] === 3, (string)($coins() - $c0));
$c0 = $coins(); $ws0 = $held('wild-rice-seed'); $pe0 = $held('pecan-seed');
[$o2, $m2] = $serve('NA', 'jar', 70, '2026-10');
ok('jar at quality 70 (62 for 3) = 3 spoons', $o2 && (int)$led('NA', 'jar')['spoons'] === 3, $m2);
ok('the jar completes the table: 240 + 150 (Taste) + 300 (golden) = 690 Petals', $coins() - $c0 === 690, (string)($coins() - $c0));
ok('+2 Wild Rice seeds and +1 Pecan seed (the NA treasure seed)', $held('wild-rice-seed') - $ws0 === 2 && $held('pecan-seed') - $pe0 === 1);
ok('table and gold claim rows exist, Tastes = 1', $led('NA', 'table') && $led('NA', 'gold') && gourmand_tastes($uid) === 1 && gourmand_progress($uid)['gold'] === 1);
ok('pot and jar fired once each (3 serves, 3 events), however many rewards they paid', $jobN() === 3, (string)$jobN());
ok('titles: Guest of the Gourmand, not yet Well Fed or Second Spoon', gourmand_titles($uid) === ['Guest of the Gourmand']);
echo "-- next month: the tip only, and the table is not paid twice\n";
$day('2026-11-14');
$c0 = $coins(); $f0 = $friend(); $ws0 = $held('wild-rice-seed');
[$o3] = $serve('NA', 'plate', 70, '2026-11');
ok('a repeat serve in a new month tips 25 Petals, friendship +10 (3 spoons), paid levels unchanged', $o3 && $coins() - $c0 === 25 && $friend() - $f0 === 10 && (int)$led('NA', 'plate')['served'] === 2 && (int)$led('NA', 'plate')['paid'] === 3);
$x0 = $xp();
[$o4] = $serve('NA', 'pot', 70, '2026-11'); $tipXp = $xp() - $x0;
$c0 = $coins();
[$o5] = $serve('NA', 'jar', 70, '2026-11');
ok('the full and golden tables did not pay again (jar tip 25 only), no new seeds', $o4 && $o5 && $coins() - $c0 === 25 && $held('wild-rice-seed') === $ws0 && gourmand_tastes($uid) === 1 && (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND region = 'NA' AND course IN ('table', 'gold')", [$uid]) === 2);
ok('the tip is 8 XP on an ordinary day', $tipXp >= 8, (string)$tipXp);

echo "== levels are paid once each, skipped levels pay\n";
$at('The Sunsprinkle Isles');
$day('2026-10-14'); $c0 = $coins();
$serve('CB', 'plate', 45, '2026-10');
ok('1 spoon first: 60 Petals', $coins() - $c0 === 60 && (int)$led('CB', 'plate')['paid'] === 1);
$day('2026-11-14'); $c0 = $coins();
$serve('CB', 'plate', 55, '2026-11');
ok('then 2 spoons the next month: only the second level, 60 (no tip on top)', $coins() - $c0 === 60 && (int)$led('CB', 'plate')['paid'] === 2 && (int)$led('CB', 'plate')['spoons'] === 2);
$day('2026-12-14'); $c0 = $coins();
$serve('CB', 'plate', 70, '2026-12');
ok('then 3 spoons: 120', $coins() - $c0 === 120 && (int)$led('CB', 'plate')['paid'] === 3);
$day('2027-01-14'); $c0 = $coins();
$serve('CB', 'plate', 45, '2027-01');
ok('a worse serve later is a tip, and the best quality and spoons stay', $coins() - $c0 === 25 && (int)$led('CB', 'plate')['spoons'] === 3 && (int)$led('CB', 'plate')['best_q'] === 70);
$day('2026-11-14'); $at('Thornacre Savanna'); $c0 = $coins();
$serve('ESA', 'plate', 20, '2026-11');
ok('quality 20 is under the bar: refused', $coins() === $c0 && !$led('ESA', 'plate'));

echo "== festival day: friendship doubles, Petals and first-time XP do not, tip XP doubles; no need to be at the camp\n";
$at('The Maplewold'); $day('2026-12-03');
ok('Dec 3 is the Maplewold festival and the camp is there', gourmand_stop()['festival'] && gourmand_festival('NA') && !gourmand_festival('CA'));
$c0 = $coins(); $f0 = $friend(); $x0 = $xp();
$serve('NA', 'plate', 70, '2026-12');
ok('3-spoon tip on the festival day: friendship +20 (10 doubled), Petals 25', $friend() - $f0 === 20 && $coins() - $c0 === 25, ($friend() - $f0) . '/' . ($coins() - $c0));
ok('tip XP doubles (8 -> 16)', $xp() - $x0 >= 16 && $xp() - $x0 >= 2 * $tipXp - 1, ($xp() - $x0) . ' vs ' . $tipXp);
$day('2026-12-20'); $f0 = $friend();
$serve('NA', 'pot', 55, '2026-12');
ok('an ordinary day, a 2-spoon tip: friendship +5', $friend() - $f0 === 5, (string)($friend() - $f0));

echo "== the Long Table seat\n";
q("DELETE FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop LIKE '2026-11|%'", [$uid, $pom]);
$day('2026-12-01');
ok('day 1 is the Long Table', gourmand_stop()['long_table'] && gourmand_stop()['code'] === 'MB');
for ($i = 0; $i < 6; $i++) q('INSERT INTO traveller_deals (user_id, npc_id, stop, at) VALUES (?, ?, ?, ?)', [$uid, $pom, '2026-11|NA|f' . $i, now()]);
$c0 = $coins();
[$okk, $m] = gourmand_seat($U());
ok('6 courses last tour is not enough', !$okk && str_contains($m, '6') && $coins() === $c0, $m);
q('INSERT INTO traveller_deals (user_id, npc_id, stop, at) VALUES (?, ?, ?, ?)', [$uid, $pom, '2026-11|NA|f6', now()]);
[$okk, $m] = gourmand_seat($U());
ok('7 courses earns the seat: 50 Petals and the charm boost', $okk && $coins() - $c0 === 50 && (bool)q_val("SELECT 1 FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop = '2026-11|LT|seat'", [$uid, $pom]), $m);
$c0 = $coins();
ok('a second try is refused and pays nothing', !gourmand_seat($U())[0] && $coins() === $c0);
$day('2026-12-02');
ok('the seat is only for day 1', !gourmand_seat($U())[0]);
$day('2026-12-14');

echo "== the finale: the next meeting after the 14th Taste, once\n";
$codes = array_map(fn($r) => $r[0], stops_file_rows('regions.txt'));
foreach ($codes as $c) if ($c !== 'EA') gourmand_claim($uid, $c, 'table');
foreach (['plate', 'pot'] as $co) q('INSERT OR REPLACE INTO gourmand_ledger (user_id, region, course, best_q, spoons, paid, served, first_at, last_at) VALUES (?, ?, ?, 70, 3, 3, 1, ?, ?)', [$uid, 'EA', $co, now(), now()]);
ok('13 Tastes so far, no finale yet', gourmand_tastes($uid) === 13 && count(gourmand_beats($U())) >= 4 && !$led('ALL', 'finale'));
$at('Blossomreach'); $c0 = $coins();
unset($_SESSION['gourmand_hold']);
[$okk, $m] = $serve('EA', 'jar', 70, '2026-12');
ok('the 14th serve earns the 14th Taste and pays the table and the golden table (EA plate and pot were already 3 spoons), but not the finale', $okk && gourmand_tastes($uid) === 14 && !$led('ALL', 'finale') && $coins() - $c0 === 240 + 150 + 300, (string)($coins() - $c0));
ok('and it tells the gnome to come back', str_contains(json_encode($_SESSION['prizes'] ?? []), 'Come back and sit down') && !empty($_SESSION['gourmand_hold']));
$c0 = $coins(); gourmand_beats($U());
ok('the page we land on straight after it does not play the finale', !$led('ALL', 'finale') && $coins() === $c0 && empty($_SESSION['gourmand_hold']));
$b = gourmand_beats($U());
ok('the next meeting plays it: 1,000 Petals, a Second Spoon, the title', (bool)$led('ALL', 'finale') && $coins() - $c0 === 1000 && $held('second-spoon') === 1 && in_array('Second Spoon', gourmand_titles($uid), true) && in_array('Well Fed', gourmand_titles($uid), true));
ok('the second spoon is a non-tradable decoration, made when first needed, not in the shop lists', (function () {
    $i = q_one("SELECT * FROM items WHERE slug = 'second-spoon'");
    return $i && (int)$i['tradable'] === 0 && $i['category'] === 'decor' && !in_array('second-spoon', array_keys(defined('DECOR') ? DECOR : []), true);
})());
ok('the finale and Home Plate beats show in the story at 14 Tastes', in_array('finale', array_column($b, 'key'), true) && in_array('home', array_column($b, 'key'), true));
$c0 = $coins(); gourmand_beats($U()); gourmand_beats($U());
ok('and never plays again', $coins() === $c0 && $held('second-spoon') === 1 && (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course = 'finale'", [$uid]) === 1);

echo "== the Grand course: Kitchen III, the first Taste, grandpay once, the Grand Diner title\n";
cfg(['gourmand_open' => '1']); gourmand_sync_active();
q('UPDATE users SET level = 20, guest = 0 WHERE id = ?', [$uid]);
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]);
$kitchen = function (int $lvl) use ($plot): void {
    q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'kitchen'", [$plot]);
    if ($lvl > 0) q("INSERT INTO garden_buildings (plot_id, building, level, built_at, last_collect) VALUES (?, 'kitchen', ?, ?, ?)", [$plot, $lvl, now(), now()]);
};
$day('2027-01-14'); $at('Spicepeak');
$grow = gourmand_menu('CSA', '2027-01')['grand'];
ok('the Grand menu rows exist for the 8 feast regions only, and each is a feast recipe', gourmand_grand_regions() === 8 && $grow['item'] === 'feast-spicepeak-thali' && !isset(gourmand_menu('SA', '2027-01')['grand']));
$kitchen(2); $stock($grow['item'], 1, 70); $d0 = $deals(); $c0 = $coins();
[$okk, $m] = gourmand_serve($U(), 'grand');
ok('Grand is refused below Kitchen III: nothing taken, nothing paid, no claim', !$okk && str_contains($m, 'Kitchen') && $held($grow['item']) === 1 && $coins() === $c0 && $deals() === $d0 && !$led('CSA', 'grand'), $m);
$kitchen(0);
ok('and with no Kitchen at all', !gourmand_serve($U(), 'grand')[0] && $held($grow['item']) === 1);
$kitchen(3);
q("DELETE FROM gourmand_ledger WHERE user_id = ? AND region = 'CSA' AND course = 'table'", [$uid]);
[$okk, $m] = gourmand_serve($U(), 'grand');
ok('Grand is refused before that region\'s first Taste: nothing taken, nothing paid, no claim', !$okk && str_contains($m, 'Taste') && $held($grow['item']) === 1 && $coins() === $c0 && $deals() === $d0 && !$led('CSA', 'grand') && !$led('CSA', 'grandpay'), $m);
gourmand_claim($uid, 'CSA', 'table');
$stock($grow['item'], 1, 20);
[$okk, $m] = gourmand_serve($U(), 'grand');
ok('a poor feast (quality 20) earns no spoon: refused, nothing taken', !$okk && str_contains($m, 'not enough for a spoon') && $held($grow['item']) === 1 && !$led('CSA', 'grandpay'), $m);
$stock($grow['item'], 1, 70); $c0 = $coins(); $x0 = $xp(); $f0 = $friend(); $d0 = $deals();
[$okk, $m] = gourmand_serve($U(), 'grand');
$L = $led('CSA', 'grand');
ok('Kitchen III and a Taste: 70 serves 3 spoons ("Splendid"), the feast is taken', $okk && str_contains($m, 'Splendid') && (int)$L['spoons'] === 3 && $held($grow['item']) === 0, $m);
ok('it pays the grandpay once: 200 Petals and 40 XP (not the spoon ladder), friendship +10, one claim row Y-m|CSA|grand', $coins() - $c0 === GOURMAND_GRAND_PAY[0] && $xp() - $x0 >= 40 && $xp() - $x0 < 80 && $friend() - $f0 === 10 && $deals() === $d0 + 1 && (bool)$led('CSA', 'grandpay') && (bool)q_val("SELECT 1 FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop = '2027-01|CSA|grand'", [$uid, $pom]), $coins() - $c0 . '/' . ($xp() - $x0));
ok('Grand does not count toward Tastes or Spoons (3 courses only)', gourmand_tastes($uid) === 14 && gourmand_progress($uid)['grand'] === 1 && !in_array('Grand Diner', gourmand_titles($uid), true));
$stock($grow['item'], 1, 70); $c0 = $coins();
[$okk, $m] = gourmand_serve($U(), 'grand');
ok('a second Grand in the same tour is refused, nothing taken or paid', !$okk && str_contains($m, 'Already served') && $held($grow['item']) === 1 && $coins() === $c0, $m);
ok('a duplicate grandpay claim is refused (the UNIQUE row is the backstop)', gourmand_claim($uid, 'CSA', 'grandpay') === false);
$day('2027-02-14');
$stock(gourmand_menu('CSA', '2027-02')['grand']['item'], 1, 70); $c0 = $coins();
[$okk, $m] = gourmand_serve($U(), 'grand');
ok('next month it tips 25 Petals and never pays the grandpay again', $okk && $coins() - $c0 === 25 && (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND region = 'CSA' AND course = 'grandpay'", [$uid]) === 1 && (int)$led('CSA', 'grand')['served'] === 2, (string)($coins() - $c0));
echo "-- the Grand Diner: all eight\n";
foreach (['CA', 'CB', 'NWE', 'SE', 'EE', 'MENA'] as $gc) gourmand_claim($uid, $gc, 'grandpay');
ok('7 of 8 is not the title', gourmand_progress($uid)['grand'] === 7 && !in_array('Grand Diner', gourmand_titles($uid), true));
$at('The Maplewold'); $day('2027-03-14'); $c0 = $coins();
[$okk, $m] = $serve('NA', 'grand', 70, '2027-03');
ok('the eighth feast (the Maplewold) pays its grandpay and says so', $okk && $coins() - $c0 === GOURMAND_GRAND_PAY[0] && gourmand_progress($uid)['grand'] === 8 && str_contains(json_encode($_SESSION['prizes'] ?? [], JSON_UNESCAPED_UNICODE), 'Grand Diner'), $m);
ok('title: Grand Diner is granted (and the earlier titles stay)', in_array('Grand Diner', gourmand_titles($uid), true) && in_array('Second Spoon', gourmand_titles($uid), true));
ok('book.php hands titles to the picker through gourmand_titles (Grand Diner can be chosen)', str_contains((string)file_get_contents($argv[1] . '/book.php'), 'gourmand_titles($uid)'));

echo "== the Home Plate: 10 Tastes, a Pot dish with a home crop at 2 spoons, once, from anywhere\n";
$hv = (int)q_val("SELECT id FROM locations WHERE region = 'The Maplewold' AND kind = 'village' ORDER BY id LIMIT 1");
q('UPDATE users SET home_village_id = ? WHERE id = ?', [$hv, $uid]);
ok('the home region is NA', gourmand_home_code($U()) === 'NA');
ok('wild-rice-hotdish and apple-crumble use a Maplewold crop, falafel does not, a jar (chicha) is not a Pot dish',
    gourmand_home_dish('NA', 'wild-rice-hotdish') !== null && gourmand_home_dish('NA', 'apple-crumble') !== null && gourmand_home_dish('NA', 'falafel') === null && gourmand_home_dish('NA', 'chicha') === null && gourmand_home_dish('NA', 'feast-maplewold-table') === null);
$at('Mossbottom');   // anywhere, even the Green
$stock('wild-rice-hotdish', 2, 70); $c0 = $coins(); $d0 = $deals();
$saved = q('SELECT region FROM gourmand_ledger WHERE user_id = ? AND course = ? AND region IN (?, ?, ?, ?, ?)', [$uid, 'table', 'EA', 'SEA', 'OC', 'ESA', 'WCA'])->fetchAll(PDO::FETCH_COLUMN);
q("DELETE FROM gourmand_ledger WHERE user_id = ? AND course = 'table' AND region IN ('EA', 'SEA', 'OC', 'ESA', 'WCA')", [$uid]);
[$okk, $m] = gourmand_serve_home($U(), 'wild-rice-hotdish');
ok('refused below 10 Tastes (9 here): nothing taken or paid, no HOME row', gourmand_tastes($uid) === 9 && !$okk && $held('wild-rice-hotdish') === 2 && $coins() === $c0 && !$led('HOME', 'home'), $m);
foreach ($saved as $rc) gourmand_claim($uid, $rc, 'table');
ok('14 Tastes again', gourmand_tastes($uid) === 14);
$stock('falafel', 1, 70);
[$okk, $m] = gourmand_serve_home($U(), 'falafel');
ok('the wrong dish (no Maplewold crop) is refused, nothing taken', !$okk && str_contains($m, 'crop of The Maplewold') && $held('falafel') === 1 && !$led('HOME', 'home'), $m);
[$okk, $m] = gourmand_serve_home($U(), 'chicha');
ok('a jar is refused', !$okk && !$led('HOME', 'home'), $m);
$stock('wild-rice-hotdish', 2, 45);
[$okk, $m] = gourmand_serve_home($U(), 'wild-rice-hotdish');
ok('the right dish at one spoon (quality 45) is refused: it needs two. Nothing taken', !$okk && str_contains($m, 'two spoons') && $held('wild-rice-hotdish') === 2 && !$led('HOME', 'home') && $coins() === $c0, $m);
$stock('wild-rice-hotdish', 2, 50); $x0 = $xp(); $f0 = $friend();
ok('the options list offers it (quality 50 = 2 spoons)', (function () use ($U) { foreach (gourmand_home_options($U()) as $o) if ($o['slug'] === 'wild-rice-hotdish' && $o['spoons'] === 2) return true; return false; })());
$evBefore = $jobN();
[$okk, $m] = gourmand_serve_home($U(), 'wild-rice-hotdish');
$H = $led('HOME', 'home');
ok('at quality 50 (2 spoons) from Mossbottom it is served: one dish taken, ledger HOME/home, paid 1', $okk && $held('wild-rice-hotdish') === 1 && $H && (int)$H['paid'] === 1 && (int)$H['spoons'] === 2 && (int)$H['best_q'] === 50, $m);
ok('the Home Plate fired the event once, region NA', $jobN() === $evBefore + 1, (string)$jobN());
ok('it pays 200 Petals and 40 XP once, friendship +10', $coins() - $c0 === GOURMAND_HOME_PAY[0] && $xp() - $x0 >= 40 && $friend() - $f0 === 10, (string)($coins() - $c0));
$c0 = $coins();
[$okk, $m] = gourmand_serve_home($U(), 'wild-rice-hotdish');
ok('a second Home Plate is refused: nothing taken, nothing paid, one row', !$okk && str_contains($m, 'already') && $held('wild-rice-hotdish') === 1 && $coins() === $c0 && (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course = 'home'", [$uid]) === 1, $m);
ok('and the refused second one fired nothing', $jobN() === $evBefore + 1);
ok('and gourmand_claim on HOME/home is refused too', gourmand_claim($uid, 'HOME', 'home') === false);
ok('the Home Plate does not change Tastes or the Spoon totals', gourmand_tastes($uid) === 14 && gourmand_progress($uid)['spoons'] === (int)q_val("SELECT COALESCE(SUM(spoons), 0) FROM gourmand_ledger WHERE user_id = ? AND course IN ('plate', 'pot', 'jar')", [$uid]));
echo "-- the off switch also shuts the new courses\n";
cfg(['gourmand_open' => '0']); gourmand_sync_active();
$at('Spicepeak'); $day('2027-04-14'); $kitchen(3);
$stock(gourmand_menu('CSA', '2027-04')['grand']['item'], 1, 70); $c0 = $coins();
ok('off: Grand is refused for a player, nothing taken or paid', !gourmand_serve($U(), 'grand')[0] && $coins() === $c0 && (int)$led('CSA', 'grand')['served'] === 2);
ok('off: the Home Plate is refused (and the beat data never shows him)', !gourmand_serve_home($U(), 'wild-rice-hotdish')[0] && $held('wild-rice-hotdish') === 1);
cfg(['gourmand_open' => '1']); gourmand_sync_active();

echo "== dish scores: cook_pots.score and the quality of what comes out\n";
ok('cook_pots.score column exists and gourmand_ledger has its inline UNIQUE', (bool)q_val("SELECT 1 FROM pragma_table_info('cook_pots') WHERE name = 'score'") && str_contains((string)q_val("SELECT sql FROM sqlite_master WHERE name = 'gourmand_ledger'"), 'UNIQUE (user_id, region, course)'));
q('UPDATE users SET level = 20, energy = 100, coins = 5000, location = ?, guest = 0 WHERE id = ?', ['The Maplewold', $uid]);
$plot = (int)q_val('SELECT id FROM plots WHERE user_id = ? LIMIT 1', [$uid]);
q("DELETE FROM garden_buildings WHERE plot_id = ? AND building = 'kitchen'", [$plot]);
q("INSERT INTO garden_buildings (plot_id, building, level, built_at, last_collect) VALUES (?, 'kitchen', 3, ?, ?)", [$plot, now(), now()]);
$rec = q_one("SELECT * FROM recipes WHERE slug = 'apple-crumble'");
q('INSERT OR IGNORE INTO user_recipes (user_id, recipe_id, learned_at) VALUES (?, ?, ?)', [$uid, $rec['id'], now()]);
$outId = (int)$rec['output_item_id'];
$giveIng = function (?int $qual) use ($uid, $rec): void {
    foreach (json_decode($rec['ingredients'], true) as $slug => $n) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $id]);
        give_item($uid, $id, $n * 3);
        if ($qual !== null) market_note_quality($uid, $id, $n * 3, $qual);
    }
};
$cookOne = function () use ($U, $rec, $uid): array {   // cook one make, ready it, collect it: [craft result, pot row]
    $u = $U(); q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]); $u = $U();
    $r = craft($u, (int)$rec['id'], 1);
    $pot = q_one('SELECT * FROM cook_pots WHERE user_id = ? ORDER BY id DESC LIMIT 1', [$uid]);
    if ($pot && $pot['collected_at'] === null) { q('UPDATE cook_pots SET ready_at = ? WHERE id = ?', [gmdate('Y-m-d H:i:s', time() - 60), $pot['id']]); cook_collect_one($U(), (int)$pot['id']); }
    return [$r, q_one('SELECT * FROM cook_pots WHERE id = ?', [$pot['id'] ?? 0])];
};
q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $outId]); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $outId]);
$giveIng(null);
[$r, $pot] = $cookOne();
ok('cooking from all-plain ingredients at Kitchen III scores 1-50', $r[0] && (int)$pot['score'] >= 1 && (int)$pot['score'] <= 50, json_encode([$r, $pot['score'] ?? null]));
$qr = q_one('SELECT q, n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $outId]);
ok('collecting wrote the dish quality = the pot score', $qr && (int)$qr['q'] === (int)$pot['score'] && (int)$qr['n'] === (int)$pot['dishes'], json_encode($qr));
$giveIng(80);
[$r, $pot] = $cookOne();
ok('ingredients of quality 80 at Kitchen III score 73 or more', $r[0] && (int)$pot['score'] >= 73 && (int)$pot['score'] <= 100, (string)($pot['score'] ?? ''));
echo "-- a pot started before the upgrade (score 0) writes no quality\n";
q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $outId]); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $outId]);
$old = db_insert('cook_pots', ['user_id' => $uid, 'recipe_id' => (int)$rec['id'], 'makes' => 1, 'dishes' => 1, 'started_at' => now(), 'ready_at' => gmdate('Y-m-d H:i:s', time() - 60), 'score' => 0]);
[$okk] = cook_collect_one($U(), $old);
ok('collected, the dish arrived, and no item_quality row was made (not 0)', $okk && $held('apple-crumble') === 1 && !q_val('SELECT 1 FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $outId]));
ok('and a dish with no row counts as plain for Pomeroy, never below it', market_stack_q($uid, $outId) === MARKET_PLAIN_Q);
echo "-- kitchen_pots = 0 (instant cooking)\n";
cfg(['kitchen_pots' => '0']);
q('DELETE FROM cook_pots WHERE user_id = ?', [$uid]); q('DELETE FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $outId]); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $outId]);
$giveIng(80);
q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
[$r] = (function () use ($U, $rec) { $u = $U(); return [craft($u, (int)$rec['id'], 1)]; })();
$pot = q_one('SELECT * FROM cook_pots WHERE user_id = ? ORDER BY id DESC LIMIT 1', [$uid]);
$qr = q_one('SELECT q, n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $outId]);
ok('instant cooking: a score of 73+ was written to the pot and the dish quality', $r[0] && $pot && $pot['collected_at'] !== null && (int)$pot['score'] >= 73 && $qr && (int)$qr['q'] === (int)$pot['score'], json_encode([$r, $pot['score'] ?? null, $qr]));
cfg(['kitchen_pots' => settings_schema()['kitchen_pots']['default']]);
setting('__reload__');

echo "== fresh start clears the ledger and his claims\n";
ok('the gnome has ledger rows and claims first', (int)q_val('SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ?', [$uid]) > 10 && $deals() > 3);
ok('FRESH_USER_TABLES lists gourmand_ledger, traveller_deals and item_quality', (function () { require_once $GLOBALS['argv'][1] . '/includes/fresh_start.php'; return isset(FRESH_USER_TABLES['gourmand_ledger'], FRESH_USER_TABLES['traveller_deals'], FRESH_USER_TABLES['item_quality']); })());
$other = (int)q_val("SELECT id FROM users WHERE username = 'admin'");
q('INSERT OR REPLACE INTO gourmand_ledger (user_id, region, course, spoons) VALUES (?, ?, ?, 1)', [$other, 'NA', 'plate']);
[$okk] = fresh_start_player($uid);
ok('fresh start wipes this gnome\'s ledger and claim rows, and leaves another gnome\'s alone', $okk && (int)q_val('SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ?', [$uid]) === 0 && $deals() === 0 && (int)q_val('SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ?', [$other]) === 1);
q('DELETE FROM gourmand_ledger WHERE user_id = ?', [$other]);

echo "== the serve event: off-switch\n";
cfg(['gourmand_open' => '0']); gourmand_sync_active();
$off0 = $jobN(); $lead0 = (int)q_val('SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ?', [$uid]);
$day('2026-12-14'); $at('The Maplewold'); $rowO = gourmand_menu('NA', '2026-12')['plate']; $stock($rowO['item'], $rowO['qty'], 70);
ok('off: a serve is refused and fires nothing', !gourmand_serve($U(), 'plate')[0] && $jobN() === $off0 && (int)q_val('SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ?', [$uid]) === $lead0);
ok('off: the Hollow pool never offers the serve jar; on, it does', !in_array('serve', array_column(hollow_goal_pool(), 0), true) && (function () { cfg(['gourmand_open' => '1']); $r = in_array('serve', array_column(hollow_goal_pool(), 0), true); cfg(['gourmand_open' => '0']); return $r; })());

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);

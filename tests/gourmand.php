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
            if ($course === 'pot' && !in_array($rec['tier'], ['snack', 'meal'], true)) $errs[] = "$tag: tier {$rec['tier']}";
            if ($course === 'jar') {
                if ($rec['tier'] !== 'preserve') $errs[] = "$tag: tier {$rec['tier']}";
                $days = max(1, (int)round((int)$rec['cook_minutes'] / 1440));
                if (min(20, 2 * $days) + 3 * min(4, count(json_decode($rec['ingredients'], true) ?: [])) >= 15) $jarOk[$c] = true;
            }
        }
    }
    if (!isset($jarOk[$c]) && !in_array($c, ['SA', 'OC'], true)) $errs[] = "$c has no jar that can reach 3 spoons";
}
ok('every region has plate, pot and jar rows that are real items of the right kind, and a 3-spoon-capable jar (SA, OC exempt)', !$errs, implode('; ', array_slice($errs, 0, 4)));
foreach ($rows['M'] as $c => $x) foreach ($x as $course => $vars) if (!in_array($course, ['plate', 'pot', 'jar'], true)) $errs[] = "$c: course $course";
$t0 = gourmand_menu('EE', '2026-10'); $t1 = gourmand_menu('EE', '2026-11'); $t2 = gourmand_menu('EE', '2026-12');
ok('menus rotate monthly through the jar variants', $t0['jar']['variant'] !== $t1['jar']['variant'] && $t1['jar']['variant'] !== $t2['jar']['variant'] && gourmand_menu('NA', '2026-10')['plate']['item'] === 'wild-rice');
ok('itinerary lists every stop with its camp', count(gourmand_itinerary('2026-10')) === 15 && array_filter(gourmand_itinerary('2026-10'), fn($w) => $w['camp'] === '') === []);
$errs = [];
foreach (stops_file_rows('regions.txt') as $r) { $t = gourmand_menu($r[0], '2026-10'); if (count($t) !== 3) $errs[] = $r[0]; }
ok('each region serves exactly 3 courses in a tour', !$errs, implode(',', $errs));
$errs = [];
foreach ($rows['B'] as $k => $b) { if (str_contains($b['text'], "'")) $errs[] = "$k apostrophe"; if (mb_strlen($b['text']) > 400) $errs[] = "$k long"; }
ok('beats hello first four mid home finale, in order of tastes needed, no straight apostrophes', array_keys($rows['B']) === ['hello', 'first', 'four', 'mid', 'home', 'finale'] && array_column($rows['B'], 'tastes') === [0, 1, 4, 7, 10, 14] && !$errs, implode(',', $errs));
$raw = file_get_contents($argv[1] . '/includes/data/gourmand.txt');
ok('no straight apostrophes in any data line', !array_filter(preg_split('/\R/', $raw), fn($l) => $l !== '' && $l[0] !== '#' && str_contains($l, "'")));

echo $fails ? "\n$fails FAILED\n" : "\nall passed\n";
exit($fails ? 1 : 0);

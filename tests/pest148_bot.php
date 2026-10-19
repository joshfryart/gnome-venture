<?php
// v1.4.8 test helper for Pest Patrol. php pest148_bot.php GAMEDIR MODE [ROUNDJSON]
//   perfect  ROUNDJSON -> prints {"taps":[[t,leaf]..],"sim":{...}}  (flicks every pest promptly)
//   none     ROUNDJSON -> no taps
//   parity   -> 300 random rounds + random taps + the server's results, as JSON for the JS check
require $argv[1] . '/includes/pest.php';
$mode = $argv[2];
function setting_stub() {}
if ($mode === 'parity') {
    mt_srand(148);
    $out = [];
    for ($i = 0; $i < 300; $i++) {
        $n = mt_rand(8, 12); $dur = (30 + mt_rand(0, 3)) * 1000;
        $bf = mt_rand(0, 2) ? [mt_rand(5000, $dur - 9000), PEST_RULES['bfDur']] : null;
        $round = ['n' => $n, 'dur' => $dur, 'pests' => pest_schedule($n, $dur), 'bf' => $bf, 'net' => mt_rand(0, 1)];
        $taps = [];
        $m = mt_rand(0, 3);
        // aimed taps (at pests, a bit late), random taps, butterfly taps, bad leaves
        foreach ($round['pests'] as $p) {
            $l = $p['k'] === 'g' ? $p['h'][0][1] : $p['l']; $t0 = $p['k'] === 'g' ? $p['h'][0][0] : $p['t'];
            if (mt_rand(0, 9) < 7 - $m) { $k = PEST_RULES['kinds'][$p['k']]['hp'] + mt_rand(0, 1); for ($j = 0; $j < $k; $j++) $taps[] = [$t0 + mt_rand(100, 2400) + $j * mt_rand(60, 300), $l]; }
        }
        for ($j = 0; $j < mt_rand(0, 40); $j++) $taps[] = [mt_rand(0, $dur), mt_rand(-1, $n - 1)];
        if ($bf) $taps[] = [$bf[0] + mt_rand(0, 4600), -1];
        usort($taps, fn($a, $b) => $a[0] <=> $b[0]);
        $out[] = ['round' => $round, 'taps' => $taps, 'sim' => pest_sim($round, $taps)];
    }
    echo json_encode($out);
    exit;
}
$round = json_decode(file_get_contents($argv[3]), true);
$taps = [];
if ($mode === 'perfect') {
    foreach ($round['pests'] as $p) {
        $l = $p['k'] === 'g' ? $p['h'][0][1] : $p['l']; $t0 = $p['k'] === 'g' ? $p['h'][0][0] : $p['t'];
        for ($j = 0; $j < PEST_RULES['kinds'][$p['k']]['hp']; $j++) $taps[] = [$t0 + 260 + $j * 110, $l];
    }
    usort($taps, fn($a, $b) => $a[0] <=> $b[0]);
    for ($i = 1; $i < count($taps); $i++) if ($taps[$i][0] - $taps[$i - 1][0] < 100) $taps[$i][0] = $taps[$i - 1][0] + 100;
}
echo json_encode(['taps' => $taps, 'sim' => pest_sim($round, $taps)]);

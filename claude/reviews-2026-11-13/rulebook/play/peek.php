<?php
// What the fight PAGE shows besides the harness text: second aim (Bird), next piece (Boss), the creature's guard, Grudge, venom cells, poison on you.
$s = json_decode(file_get_contents($argv[1]), true); $p = $s['foe']['plan'] ?? null; $o = [];
$o[] = 'kind=' . ($s['foe']['kind'] ?? '') . ' foe_guard=' . $s['foe']['block'] . ' grudge=' . ($s['foe']['grudge'] ?? 0) . ' my_poison=' . ($s['me']['poison'] ?? 0) . 'x' . ($s['me']['poison_v'] ?? 0) . ' foe_evade=' . $s['foe']['evade'] . ' foe_thorns=' . (int)$s['foe']['thorns'] . ' soothe_pool=' . $s['foe']['agg'] . ' foe_poison=' . $s['foe']['poison'] . 'x' . $s['foe']['poison_v'] . ' foe_slow=' . $s['foe']['slow'];
if (!empty($p['alt'])) $o[] = 'SECOND AIM: ' . $p['alt']['n'] . ' ' . $p['alt']['t'] . ' ' . $p['alt']['v'] . ' at ' . $p['alt']['x'] . ',' . $p['alt']['y'];
if (!empty($p['next'])) $o[] = 'NEXT ROUND (forced): ' . $p['next']['n'] . ' ' . $p['next']['t'] . ' ' . $p['next']['v'] . ' ' . $p['next']['tag'];
if (!empty($s['ven'])) $o[] = 'VENOM: ' . json_encode($s['ven']);
echo implode("\n", $o) . "\n";

<?php
// Compact state: what the page shows (bars, board, aim with total, class extras, next environment piece) plus tryall's plan lines.
require __DIR__ . '/../../../../game/includes/pfboard.php'; require __DIR__ . '/../../../../game/includes/pfdeck.php';
$f = $argv[1]; $s = json_decode(file_get_contents($f), true);
printf("T%d %s (%s, %s) YIELD %.1f/%.1f (hurt %.1f charm %.1f) | me %d/%d guard %d%s\n", $s['turn'], $s['foe']['name'], $s['size'], $s['foe']['kind'] ?? '', $s['fh']['now'] + $s['bar']['now'], $s['fh']['max'], $s['fh']['now'], $s['bar']['now'], $s['me']['hp'], $s['me']['max'], $s['me']['block'], $s['over'] ? ' OVER: ' . $s['over'] : '');
$sh = fn($e) => implode('', array_map(fn($k) => $k . ':' . ($e[$k][0] === 'wild' ? 'W ' : ($e[$k][0] === 'flat' ? '- ' : ($e[$k][0][0] . substr($e[$k][1], 0, 1) . ' '))), ['L', 'R', 'T', 'B']));
$p = $s['foe']['plan'] ?? null;
for ($y = 0; $y < pfb_h($s); $y++) { $r = ''; for ($x = 0; $x < pfb_w($s); $x++) { $q = pfb_at($s, $x, $y); $aim = $p && $p['x'] === $x && $p['y'] === $y; $alt = $p && !empty($p['alt']) && $p['alt']['x'] === $x && $p['alt']['y'] === $y; $ven = isset($s['ven']["$x,$y"]);
    $r .= str_pad($q ? ($q['by'] === 'me' ? 'Y' : ($q['by'] === 'foe' ? 'C' : ($q['by'] === 'env' ? 'E' : '?'))) . ':' . substr($q['tile']['n'], 0, 9) : ($aim ? 'AIM' : ($alt ? 'aim2' : ($ven ? 'venom' : '.'))), 12); } echo "  $r\n"; }
foreach ($s['pcs'] as $q) if ($q['by'] !== 'none') printf("  %s %s %s %d %s @%d,%d left %d%s [%s]\n", $q['by'], $q['tile']['n'], $q['tile']['t'], $q['tile']['v'], $q['tile']['tag'], $q['x'], $q['y'], $q['born'] + pfb_life($s, $q) - $s['round'], $q['by'] === 'foe' ? ' fires ' . (2 - (int)($q['f'] ?? 0)) : '', trim($sh(pfb_edges($q['tile']))));
if ($p) { $t = $p['tot'] ?? null; printf("AIM %s %s %d %s @%d,%d: %s\n", $p['n'], $p['t'], $p['v'], $p['tag'], $p['x'], $p['y'], !$t ? '-' : (isset($t['broken']) ? 'broken ' . $t['broken'] : 'hits ' . $t['hp'] . ' guard-eaten ' . $t['g'] . ' bait ' . $t['bait'] . ' heal ' . $t['heal'] . ' (' . implode(', ', $t['why']) . ')'));
    if (!empty($p['alt'])) printf("  second aim: %s %s %d @%d,%d\n", $p['alt']['n'], $p['alt']['t'], $p['alt']['v'], $p['alt']['x'], $p['alt']['y']);
    if (!empty($p['next'])) printf("  next round (forced): %s %s %d %s\n", $p['next']['n'], $p['next']['t'], $p['next']['v'], $p['next']['tag']); } else echo "AIM none\n";
echo 'foe guard ' . $s['foe']['block'] . ' evade ' . $s['foe']['evade'] . ' thorns ' . (int)$s['foe']['thorns'] . ' grudge ' . ($s['foe']['grudge'] ?? 0) . ' slow ' . $s['foe']['slow'] . ' poison ' . $s['foe']['poison'] . 'x' . $s['foe']['poison_v'] . ' | me poison ' . ($s['me']['poison'] ?? 0) . 'x' . ($s['me']['poison_v'] ?? 0) . ' tripped ' . ($s['me']['tripped'] ?? 0) . ' | env next: ' . implode(',', array_map(fn($t) => $t['n'], $s['env']['next'] ?? [])) . "\n";
if (!empty($s['start'])) { foreach ($s['me']['hand'] as $i => $t) printf("  [%d] %s %s %d %s [%s]\n", $i, $t['n'], $t['t'], $t['v'], $t['tag'], trim($sh(pfb_edges($t)))); exit; }
if ($s['over']) exit;
foreach ($s['me']['hand'] as $i => $t) { printf("[%d] %s %s %d %s [%s]\n", $i, $t['n'], $t['t'], $t['v'], $t['tag'], trim($sh(pfb_edges($t))));
  foreach ([0, 1] as $fl) {
    $w = $s; if ($fl) { if (pfb_flip($w, $i, $w['turn']) !== null) continue; }
    foreach (pfb_cells($w, $w['me']['hand'][$i], 'me') as [$x, $y]) {
        $c = $w; $r = pfb_play($c, [[$i, $x, $y]], $c['turn'], null, true, true); if ($r['err']) continue;
        $a = $r['aim'] ?? null; $n = count(array_filter($r['ev'], fn($e) => isset($e['id'])));
        $names = implode('>', array_map(fn($e) => ($e['by'] === 'foe' ? 'C:' : ($e['by'] === 'env' ? 'E:' : '')) . $e['n'] . (!empty($e['combo']) ? '*' . $e['combo'] : ''), array_filter($r['ev'], fn($e) => isset($e['id']))));
        printf("   %s@%d,%d: yield %+.1f hp %+d g%d n%d%s%s | aim: %s | %s\n", $fl ? 'F' : ' ', $x, $y, $r['fh'] - $s['fh']['now'] + $r['bar'] - $s['bar']['now'], $r['hp'] - $s['me']['hp'], $r['block'], $n, !empty($r['ev'][0]['used']) ? ' USEUP' : '', $r['over'] ? ' END' : '',
            $a === null ? 'none' : (isset($a['broken']) ? 'BROKEN(' . $a['broken'] . ')' : 'hits ' . $a['hp'] . ($a['bait'] > 0 ? ' bait ' . $a['bait'] : '') . ($a['why'] ? ' (' . implode(', ', $a['why']) . ')' : '')), $names);
    } } }

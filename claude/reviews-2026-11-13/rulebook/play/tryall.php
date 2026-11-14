<?php
// For every hand piece (both ways up) and every legal cell: what the page's plan line shows after you put the piece down and before End turn:
// your chain (damage, charm, health it costs you, guard you end with, pieces fired, use-up) and the creature's aim total AFTER the placement (pfb_play dry + withAim).
require __DIR__ . '/../../../../game/includes/pfboard.php'; require __DIR__ . '/../../../../game/includes/pfdeck.php';
$s = json_decode(file_get_contents($argv[1]), true);
foreach ($s['me']['hand'] as $i => $t) foreach ([0, 1] as $fl) {
    $w = $s; if ($fl) { if (pfb_flip($w, $i, $w['turn']) !== null) continue; }
    foreach (pfb_cells($w, $w['me']['hand'][$i], 'me') as [$x, $y]) {
        $c = $w; $r = pfb_play($c, [[$i, $x, $y]], $c['turn'], null, true, true); if ($r['err']) continue;
        $a = $r['aim'] ?? null; $n = count(array_filter($r['ev'], fn($e) => isset($e['id'])));
        $names = implode('>', array_map(fn($e) => ($e['by'] === 'foe' ? 'C:' : ($e['by'] === 'env' ? 'E:' : '')) . $e['n'] . (isset($e['combo']) && $e['combo'] ? '*' . $e['combo'] : ''), array_filter($r['ev'], fn($e) => isset($e['id']))));
        printf("[%d]%s %s @%d,%d: dmg %+.1f charm %+.1f hp %+d guard %d n%d%s%s | aim after: %s | %s\n", $i, $fl ? 'F' : ' ', $t['n'], $x, $y, $r['fh'] - $s['fh']['now'], $r['bar'] - $s['bar']['now'], $r['hp'] - $s['me']['hp'], $r['block'], $n, !empty($r['ev'][0]['used']) ? ' USEUP' : '', $r['over'] ? ' END' : '',
            $a === null ? 'none' : (isset($a['broken']) ? 'BROKEN(' . $a['broken'] . ')' : 'hits ' . $a['hp'] . ($a['bait'] > 0 ? ' bait ' . $a['bait'] : '') . ($a['why'] ? ' (' . implode(', ', $a['why']) . ')' : '')), $names);
    }
}

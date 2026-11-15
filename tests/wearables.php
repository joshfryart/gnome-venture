<?php
// 2.7.00 wearables (includes/wearables.php): the six wearables as data, checked against what the engine really reads, the item slugs, the pieces a gnome's items make, and the Tailor math.
// php tests/wearables.php GAME_DIR   (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/pfight.php';
require_once $argv[1] . '/includes/wearables.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

echo "== the data against the engine\n";
$guardTags = ['hold', 'thorns', 'evade', 'mend']; $hurtTags = ['bash', 'pierce', 'poison', 'trip'];
$bad = []; $cuts = 0;
foreach (WEAR_DEFS as $base => $d) foreach ($d['cuts'] as $cut => [$pn, $t, $v, $tag, $mod, $words]) {
    $cuts++;
    if (!isset(PF_HOLE[$t])) $bad[] = "$base/$cut: type $t";
    if ($v < 2 || $v > 3) $bad[] = "$base/$cut: base $v is outside 2 to 3";
    if ($tag !== '' && !isset(PF_TAGS[$tag])) $bad[] = "$base/$cut: unknown tag $tag";
    if ($tag !== '' && $t === 'guard' && !in_array($tag, $guardTags, true)) $bad[] = "$base/$cut: a guard reads hold thorns evade mend, not $tag";
    if ($tag !== '' && $t === 'hurt' && !in_array($tag, $hurtTags, true)) $bad[] = "$base/$cut: hurt tag $tag";
    if ($tag !== '' && $t === 'trick' && $tag !== 'pluck') $bad[] = "$base/$cut: a trick reads only pluck, not $tag";
    if ($tag !== '' && in_array($t, ['soothe', 'charm'], true) && !in_array($t === 'charm' ? $tag : '', ['hum', 'lull', 'bond'], true)) $bad[] = "$base/$cut: $t takes no tag here ($tag)";
    if ($mod !== '' && (!isset(PF_MODS[$mod]) || !in_array($t, PF_MODS[$mod][4], true))) $bad[] = "$base/$cut: knack $mod does not fit $t";
    if (in_array($tag, ['keep', 'plenty', 'simmer'], true)) $bad[] = "$base/$cut: Keeper, Plenty and Simmer are the friend pieces' (Josh: no overlap)";
    if ($pn === '' || $words === '') $bad[] = "$base/$cut: no name or words";
}
ok('every cut: a real type, base 2-3, a tag or knack the engine reads for that type, no Keeper / Plenty / Simmer', !$bad, json_encode($bad));
ok('six wearables, eleven cuts', count(WEAR_DEFS) === 6 && $cuts === 11, "$cuts cuts");
$c = fn(string $b, string $k) => WEAR_DEFS[$b]['cuts'][$k];
ok("Josh's answers: Hat = Guard 2 thorns 'Brim Down'; Pack = a Trick (pluck); Scarf = Charm 3 with no tag and one cut; Boots = Guard 3 evade",
    $c('wayfarers-hat', 'a')[0] === 'Brim Down' && $c('wayfarers-hat', 'a')[1] === 'guard' && $c('wayfarers-hat', 'a')[2] === 2 && $c('wayfarers-hat', 'a')[3] === 'thorns'
    && $c('trail-pack', 'a')[1] === 'trick' && $c('trail-pack', 'a')[3] === 'pluck'
    && $c('yarn-scarf', 'a')[1] === 'charm' && $c('yarn-scarf', 'a')[2] === 3 && $c('yarn-scarf', 'a')[3] === '' && count(WEAR_DEFS['yarn-scarf']['cuts']) === 1
    && $c('flood-boots', 'a')[1] === 'guard' && $c('flood-boots', 'a')[3] === 'evade');
ok('the Hat and the Pack are bought (Twigg\'s), the Boots, Gloves and Cloak crafted, the Scarf from Cat Fish', WEAR_DEFS['wayfarers-hat']['get'] === 'shop' && WEAR_DEFS['trail-pack']['get'] === 'shop' && WEAR_DEFS['flood-boots']['get'] === 'craft' && WEAR_DEFS['work-gloves']['get'] === 'craft' && WEAR_DEFS['travel-cloak']['get'] === 'craft' && WEAR_DEFS['yarn-scarf']['get'] === 'catfish');

echo "== item slugs\n";
$items = wear_items();
ok('33 items: 11 cuts x 3 ranks, unique slugs', count($items) === 33, (string)count($items));
$rt = true; foreach ($items as $slug => $it) { $p = wear_parse($slug); if ($p === null || $p[0] !== $it['base'] || $p[1] !== $it['cut'] || $p[2] !== $it['rank'] || wear_slug($p[0], $p[1], $p[2]) !== $slug) { $rt = false; echo "    $slug\n"; } }
ok('every slug parses back to its wearable, cut and rank, and builds again', $rt);
ok('examples: flood-boots, work-gloves-b-lined, wayfarers-hat-fine, yarn-scarf-lined', wear_parse('flood-boots') === ['flood-boots', 'a', 1] && wear_parse('work-gloves-b-lined') === ['work-gloves', 'b', 2] && wear_parse('wayfarers-hat-fine') === ['wayfarers-hat', 'a', 3] && wear_parse('yarn-scarf-lined') === ['yarn-scarf', 'a', 2]);
ok('not wearables: camping-gear, flood-boots-c, yarn-scarf-b (the scarf has one cut), trail-pack-fine-lined', wear_parse('camping-gear') === null && wear_parse('flood-boots-c') === null && wear_parse('yarn-scarf-b') === null && wear_parse('trail-pack-fine-lined') === null);

echo "== the pieces a gnome's wearables make\n";
$pc = wear_pieces(['flood-boots' => 1, 'flood-boots-lined' => 1, 'flood-boots-b' => 1, 'work-gloves' => 0, 'camping-gear' => 3, 'trail-pack-fine' => 2]);
$keys = array_column($pc, 'key'); sort($keys);
ok('two cuts of one wearable are two pieces, the best rank of each cut is the one worn, nothing for qty 0 or non-wearables', $keys === ['w:flood-boots', 'w:flood-boots-b', 'w:trail-pack'], json_encode($keys));
$byKey = array_column($pc, null, 'key');
ok('the piece key does not change with the rank (the switch stays); the row has the fields pfdeck needs (src wear, body knob, rank, type, value, ref = the best item)', ($r = $byKey['w:flood-boots']) && $r['src'] === 'wear' && $r['r'] === 'body' && $r['rank'] === 2 && $r['t'] === 'guard' && $r['v'] === 3 && $r['tag'] === 'evade' && $r['n'] === 'Puddle Hop' && $r['ref'] === 'flood-boots-lined' && !isset($r['mod']) && $byKey['w:trail-pack']['rank'] === 3 && $byKey['w:trail-pack']['t'] === 'trick');
ok('no items, no pieces', wear_pieces([]) === []);

echo "== the Tailor\n";
ok('power is the sum of the levels (levels clamp to 0..3)', tailor_power_of([]) === 0 && tailor_power_of([1]) === 1 && tailor_power_of([3, 2]) === 5 && tailor_power_of([3, 3, 3, 3]) === 12 && tailor_power_of([7]) === 3);
ok('a lining attempt: 30% with none, +8% a point, 78% at 6 points, no better after', tailor_chance(0) === 30 && tailor_chance(1) === 38 && tailor_chance(4) === 62 && tailor_chance(6) === 78 && tailor_chance(12) === 78);
ok('points above 6 pay 5% commission each instead', tailor_commission_pct(6) === 0 && tailor_commission_pct(7) === 5 && tailor_commission_pct(12) === 30);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);

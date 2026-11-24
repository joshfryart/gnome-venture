<?php
// 2.7.00 wearables (includes/wearables.php): the six wearables as data, checked against what the engine really reads, the item slugs, the pieces a gnome's items make, and the Tailor math.
// php tests/wearables.php GAME_DIR   (an installed game; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/pfight.php';
require_once $argv[1] . '/includes/wearables.php';
set_setting('wear_open', '1'); setting('__reload__');   // 2.7.14: wearables are open to all unless the admin setting wear_open is Off
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
$items = array_filter(wear_items(), fn($it) => isset(WEAR_DEFS[$it['base']]));   // the six older wearables (the 280 Tailor ones are checked below)
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
ok('the piece key does not change with the rank (the switch stays); the row has the fields pfdeck needs (src wear, body knob, rank, type, value, ref = the best item)', ($r = $byKey['w:flood-boots']) && $r['src'] === 'wear' && $r['r'] === 'body' && $r['rank'] === 2 && $r['t'] === 'guard' && $r['v'] === 3 && $r['tag'] === 'evade' && $r['n'] === 'Puddle Hop' && $r['ref'] === 'flood-boots-lined' && ($r['mod'] ?? '') === 'spiky' && !isset($byKey['w:trail-pack']['mod']) && $byKey['w:trail-pack']['rank'] === 3 && $byKey['w:trail-pack']['t'] === 'trick');
ok('no items, no pieces', wear_pieces([]) === []);
// 2.7.01 retune (claude/sims-tailor-2.7.01.md): plain Guard cuts were played ~0.2 times a fight by the careless bot and raising their value moved nothing; every Guard cut now has Spiky
$gc = []; foreach (WEAR_DEFS as $base => $d) foreach ($d['cuts'] as $cut => $cc) if ($cc[1] === 'guard') $gc[$cc[0]] = $cc[4];
ok('every Guard cut carries the Spiky knack (2 on the creature when played): Puddle Hop, Sure Foot, Brim Down, Wrap Up, Hood Up', count($gc) === 5 && array_unique(array_values($gc)) === ['spiky'], json_encode($gc));
$gt = pf_make_tile('w:flood-boots', ['level' => 3], 0, ['n' => 'Puddle Hop', 't' => 'guard', 'v' => 3, 'r' => 'body', 'tag' => 'evade', 'mod' => (string)($byKey['w:flood-boots']['mod'] ?? '')]);
ok('the worn Guard piece reaches the engine with the knack (tile m = spiky)', $gt['m'] === 'spiky', json_encode($gt));
ok('Puddle Hop says what Evade does against poison', str_contains($c('flood-boots', 'a')[5], 'poison'), $c('flood-boots', 'a')[5]);

echo "== the 280 Tailor wearables (data/wear_items.txt + data/wear_items_pieces.txt)\n";
$T = wear_tailor_defs(); $ROOT = dirname($argv[1]);
ok('280 Tailor wearables defined; wear_defs = the 6 + the 280, no slug shared', count($T) === 280 && count(wear_defs()) === 286 && !array_intersect_key($T, WEAR_DEFS), (string)count($T));
ok('873 wearable items (33 + 280 x 3 ranks), every slug parses back', count($items) === 33 && count(wear_items()) === 873 && !array_filter(array_keys(wear_items()), fn($s) => wear_parse($s) === null));
$design = json_decode((string)@file_get_contents($ROOT . '/claude/wear-pieces/pieces.json'), true);
if (is_array($design)) {
    $miss = []; foreach ($design as $p) { $d = $T[$p['slug']] ?? null; if (!$d || $d['name'] !== $p['item'] || $d['cuts']['a'][0] !== $p['piece'] || $d['cuts']['a'][1] !== $p['type'] || $d['cuts']['a'][2] !== (int)$p['v'] || $d['petals'] !== (int)$p['petals'] || $d['tailor'] !== (int)$p['tailor'] || $d['energy'] !== (int)$p['energy'] || $d['region'] !== $p['region'] || $d['fa'] !== (int)$p['a'] || $d['fb'] !== (int)$p['b']) $miss[] = $p['slug']; }
    ok('every design row (claude/wear-pieces/pieces.json) is in the game as designed: name, piece, type, value, fee, Tailor level, energy, region, a, b', !$miss && count($design) === 280, json_encode(array_slice($miss, 0, 5)));
}
$noIcon = []; foreach (wear_items() as $slug => $it) if (!is_file($argv[1] . '/assets/img/ph/' . $slug . '.png')) $noIcon[] = $slug;
ok('every wearable item (the 33 old and the 840 new) has its picture in assets/img/ph', !$noIcon, count($noIcon) . ' missing, e.g. ' . json_encode(array_slice($noIcon, 0, 4)));
$gath = []; foreach (file($argv[1] . '/includes/data/gatherables.txt', FILE_IGNORE_NEW_LINES) as $l) if ($l !== '' && $l[0] !== '#') $gath[explode('|', $l)[0]] = 1;
$bad = [];
foreach ($T as $slug => $d) {
    if (!isset(REGION_LEVELS[$d['region']]) || !str_starts_with($slug, strtolower($d['region']) . '-')) $bad[] = "$slug: region {$d['region']}";
    if (!in_array($d['rarity'], ['Common', 'Uncommon', 'Rare'], true) || $d['tailor'] !== (['Common' => 1, 'Uncommon' => 2, 'Rare' => 3][$d['rarity']] ?? 0)) $bad[] = "$slug: rarity / Tailor level";
    if ($d['petals'] < 1 || $d['energy'] < 1 || !isset(WEAR_CAT_ICON[$d['cat']])) $bad[] = "$slug: fee, energy or category";
    if (!$d['mats']) $bad[] = "$slug: no materials";
    foreach ($d['mats'] as $m => $n) if (!isset($gath[$m]) && part_key((string)$m) === null) $bad[] = "$slug: material $m is not a gatherable";
    if (count($d['cuts']) !== 1) $bad[] = "$slug: one piece, no cuts";
    if (!preg_match('/^(R:[A-Z]+:[a-z]+|[A-Za-z0-9]+>[A-Za-z0-9]+)$/', $d['fx'])) $bad[] = "$slug: fx {$d['fx']}";
    if ($d['desc'] === '' || $d['cuts']['a'][5] === '') $bad[] = "$slug: no words";
}
ok('every Tailor wearable: a real region, rarity matches its Tailor level (1/2/3), a fee, energy, category, gatherable materials, one cut, an fx code, words', !$bad, json_encode(array_slice($bad, 0, 6)));
$bad = []; $keys = [];
foreach (file($argv[1] . '/includes/data/wear_items_pieces.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if (trim($l) === '' || $l[0] === '#') continue;
    $r = array_map('trim', explode('|', $l));
    if (count($r) !== 15) { $bad[] = substr($l, 0, 40) . ': 15 columns'; continue; }
    [$k, $n, $src, $ref, $t, $v, $kn, $tag, $life, $rar, $blurb, $mod, $fx, $fa, $fb] = $r; $keys[] = $k;
    if ($src !== 'wear' || $k !== 'w:' . $ref || !isset($T[$ref])) $bad[] = "$k: source / key / ref";
    if (!isset(PF_HOLE[$t])) $bad[] = "$k: type $t";
    if ((int)$v < 1 || (int)$v > 10) $bad[] = "$k: value $v";
    if (!in_array($kn, ['body', 'mind', 'craft'], true)) $bad[] = "$k: knob $kn";
    if ($tag !== '-' && !isset(PF_TAGS[$tag])) $bad[] = "$k: tag $tag";
    if ($mod !== '-' && !isset(PF_MODS[$mod])) $bad[] = "$k: knack $mod";
    if ($life !== '-' || $rar !== 'src') $bad[] = "$k: life / rarity";
    if ($n === '' || !str_starts_with($blurb, ($T[$ref]['name'] ?? '?') . ': ')) $bad[] = "$k: name or blurb";
    if (!ctype_digit($fa) || !ctype_digit($fb)) $bad[] = "$k: a / b";
}
ok('catalog rows (wear_items_pieces.txt) lint: 15 columns, src wear, key w:<item>, a real type, value 1-10, a knob, tag / knack the engine knows, life -, rarity src, blurb "<item>: ..."', !$bad && count($keys) === 280 && count(array_unique($keys)) === 280, json_encode(array_slice($bad, 0, 6)));
$pc = array_column(wear_pieces(['na-sugarbush-snow-boots' => 1, 'na-sugarbush-snow-boots-fine' => 1, 'na-birchwood-clog-lined' => 2]), null, 'key');
$r = $pc['w:na-sugarbush-snow-boots'] ?? [];
ok('a Tailor wearable makes one piece: the best rank worn, its own knob, fx / a / b carried', count($pc) === 2 && ($r['rank'] ?? 0) === 3 && ($r['ref'] ?? '') === 'na-sugarbush-snow-boots-fine' && ($r['n'] ?? '') === 'Snowdrift Trip' && ($r['t'] ?? '') === 'hurt' && ($r['v'] ?? 0) === 3
    && ($r['fx'] ?? '') === 'linkFoe>skip' && ($r['fa'] ?? 0) === 1 && ($r['fb'] ?? 0) === 2 && ($pc['w:na-birchwood-clog']['r'] ?? '') === 'mind' && ($pc['w:na-birchwood-clog']['rank'] ?? 0) === 2, json_encode($pc));
ok('no cut b, no rank beyond Fine for a Tailor wearable', wear_parse('na-birchwood-clog-b') === null && wear_parse('na-birchwood-clog-fine-lined') === null && wear_parse('na-birchwood-clog-fine') === ['na-birchwood-clog', 'a', 3]);
$it = wear_items();
ok('item: name, "<art> Piece: <piece>, <Type> <v>. <effect>", Lined / Fine named, base price half the Petal price (1200 / 1800 / 3000)', $it['na-sugarbush-snow-boots']['name'] === 'Sugarbush Snow Boots' && $it['na-sugarbush-snow-boots-lined']['name'] === 'Sugarbush Snow Boots, Lined'
    && str_contains($it['na-sugarbush-snow-boots']['desc'], 'Piece: Snowdrift Trip, Hurt 3. If a creature piece') && $it['na-sugarbush-snow-boots']['price'] === 600 && $it['na-sugarbush-snow-boots-lined']['price'] === 900 && $it['na-sugarbush-snow-boots-fine']['price'] === 1500, json_encode($it['na-sugarbush-snow-boots']));
ok('fees: Common x1, Lined x1.5, Fine x2.5', wear_fee($T['na-sugarbush-snow-boots'], 1) === 1200 && wear_fee($T['na-sugarbush-snow-boots'], 2) === 1800 && wear_fee($T['na-sugarbush-snow-boots'], 3) === 3000);
wear_ensure_items();
$have = (int)q_val("SELECT COUNT(*) FROM items WHERE category = 'supply' AND slug IN ('" . implode("','", array_keys(wear_items())) . "')");
ok('wear_ensure_items made all 873 items (supply, so wear_owned finds them)', $have === 873, (string)$have);

echo "== the Tailor\n";
ok('power is the sum of the levels (levels clamp to 0..3)', tailor_power_of([]) === 0 && tailor_power_of([1]) === 1 && tailor_power_of([3, 2]) === 5 && tailor_power_of([3, 3, 3, 3]) === 12 && tailor_power_of([7]) === 3);
ok('a lining attempt: 30% with none, +8% a point, 78% at 6 points, no better after', tailor_chance(0) === 30 && tailor_chance(1) === 38 && tailor_chance(4) === 62 && tailor_chance(6) === 78 && tailor_chance(12) === 78);
ok('points above 6 pay 5% commission each instead', tailor_commission_pct(6) === 0 && tailor_commission_pct(7) === 5 && tailor_commission_pct(12) === 30);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);

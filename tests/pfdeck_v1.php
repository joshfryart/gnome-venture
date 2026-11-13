<?php
// The v1 DECK MODEL (2.6.74 stage B, admin setting pfight_v1): data lint, creature layers and creature tags, the player's deck from its sources, starter, kits, belt, wear, flag-off parity.
// php tests/pfdeck_v1.php            the pure checks (no DB, no server)
// php tests/pfdeck_v1.php GAMEDIR    the database checks on an installed copy of the game (player "sprout"); tests/pfdeck_v1.sh runs both
$G = $argv[1] ?? '';
if ($G !== '') { $_SERVER['SCRIPT_NAME'] = '/puzzlebox.php'; require $G . '/includes/bootstrap.php'; require_once $G . '/includes/adventure.php'; require_once $G . '/includes/pfight_game.php'; require_once $G . '/includes/pfdeck.php'; require_once $G . '/includes/schema.php'; }
else { require __DIR__ . '/../game/includes/pfboard.php'; require __DIR__ . '/../game/includes/pfight_game.php'; require __DIR__ . '/../game/includes/pfdeck.php'; }
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$DATA = ($G !== '' ? $G : __DIR__ . '/../game') . '/includes/data/';
$die = ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10]; $rows = [];
foreach (file($DATA . 'creatures.txt', FILE_IGNORE_NEW_LINES) as $l) {
    if ($l === '' || $l[0] === '#') continue; $c = explode('|', $l); if (count($c) < 7) continue;
    $lv = max(1, (int)$c[4]); $rows[] = ['slug' => trim($c[0]), 'name' => trim($c[1]), 'size' => trim($c[2]), 'level' => $lv, 'dmg_die' => $die[trim($c[2])] ?? 6, 'dmg_bonus' => intdiv($lv, 4)];
}
function dk_stats(int $lv = 8): array { $m = max(0, intdiv($lv + 3, 14)); return ['grit' => $m, 'nimble' => $m, 'hardiness' => $m, 'charm' => $m, 'lore' => $m, 'luck' => $m, 'level' => $lv]; }
function dk_me(int $lv = 8, ?array $src = null): array
{
    $st = dk_stats($lv); $max = 20 + 3 * $lv + 5 * $st['grit']; $src ??= pfd_sources_blank($lv, 'thornblade');
    return ['hp' => $max, 'max_hp' => $max, 'stats' => $st, 'deck' => pfd_tiles(pfd_fight_entries($src), $st, [], (string)$src['calling'], (int)$src['ctier']), 'luck' => 0];
}
function dk_foe(string $size, int $lv = 8, string $slug = 'test-thing'): array { return ['slug' => $slug, 'name' => 'Test Thing', 'size' => $size, 'level' => $lv, 'dmg_die' => ['small' => 4, 'medium' => 6, 'large' => 8, 'boss' => 10][$size], 'dmg_bonus' => intdiv($lv, 4)]; }
/** A v1 fight with an empty board, no ground, no forecast and no aim. */
function dk_bare(array $over = [], string $size = 'medium'): array
{
    $s = pfb_new(dk_me(), dk_foe($size), 7, ['v1' => $over ?: true]);
    $s['pcs'] = []; $s['cell'] = []; $s['ter'] = []; $s['envs'] = []; $s['foe']['plan'] = null; $s['spent'] = []; $s['me']['hp'] = $s['me']['max'];
    return $s;
}
function dk_tile(array $s, string $k, string $t, int $v, string $tag = '', array $x = []): array
{
    return pfb_v1_tile($x + ['k' => $k, 'n' => ucfirst($k), 't' => $t, 'v' => $v, 'r' => 'body', 'tag' => $tag, 'm' => ''], $s['v1']);
}
/** Put a lone piece far from everything and fire it for its owner (cells are used in turn so nothing links). */
function dk_fire(array &$s, string $who, array $tile): array
{
    static $n = 0; $spots = [[0, 0], [2, 0], [4, 0], [0, 2], [2, 2], [4, 2], [0, 4], [2, 4], [4, 4]];
    foreach ($spots as [$x, $y]) if (!isset($s['cell']["$x,$y"]) && !array_filter(PFB_SIDE, fn($d) => isset($s['cell'][($x + $d[0]) . ',' . ($y + $d[1])]))) break;
    $id = ++$s['pid']; $s['seq']++;
    $s['pcs'][$id] = ['id' => $id, 'by' => $who, 'tile' => $tile, 'x' => $x, 'y' => $y, 'born' => $s['round'], 'seq' => $s['seq']]; $s['cell']["$x,$y"] = $id;
    $ev = pfb_fire($s, $id); pfb_spend($s);
    unset($s['cell']["$x,$y"], $s['pcs'][$id]);
    return $ev[0] ?? [];
}

if ($G === '') {
echo "== 1. data lint\n";
$C = pfd_catalog(); $K = pfd_classes(); $CM = pfd_class_map(); $U = pfd_uniques(); $R = pfd_region_pieces();
chk('the old tile library read from pf_pieces.txt is exactly the built-in one (same keys, order, fields)', pf_tiles() === PF_TILES_BUILTIN, array_keys(pf_tiles()));
chk('88 creatures in creatures.txt', count($rows) === 88, count($rows));
$raw = array_map(fn($r) => $r[0], pf_data_lines('pf_pieces.txt'));
chk('every piece key is unique', count($raw) === count(array_unique($raw)), array_diff_key($raw, array_unique($raw)));
$err = []; $bySrc = [];
foreach (pf_data_lines('pf_pieces.txt') as $r) {
    if (count($r) !== 11) { $err[] = $r[0] . ': 11 columns'; continue; }
    [$k, $n, $src, $ref, $t, $v, $kn, $tag, $life, $rar, $blurb] = $r; $bySrc[$src][] = $ref;
    if (!preg_match('/^[a-z0-9:A-Z-]+$/', $k) || $n === '' || $blurb === '') $err[] = "$k: key, name or blurb";
    if (!in_array($src, PFD_PLAYER_SRC, true)) $err[] = "$k: source $src";
    if (!isset(PF_HOLE[$t])) $err[] = "$k: type $t";
    if ((int)$v < 1 || (int)$v > 9) $err[] = "$k: value $v";
    $e = explode('/', $kn);
    if (!in_array($e[0], PFD_FAM, true) && !($e[0] === '-' && $k === 'offer')) $err[] = "$k: knob $kn";
    if (isset($e[1]) && !in_array($e[1], PFD_FAM, true)) $err[] = "$k: column $kn";
    if (isset($e[2]) && !in_array($e[2], ['up', 'down'], true)) $err[] = "$k: way up $kn";
    if ($tag !== '-' && $tag !== 'snack' && !isset(PF_TAGS[$tag])) $err[] = "$k: tag $tag";
    if ($life !== '-' && ((int)$life < PFB_LIFE_MIN || (int)$life > PFB_LIFE_MAX)) $err[] = "$k: life $life";
    if ($rar !== 'src' && !in_array($rar, ['0', '1', '2', '3', '4'], true)) $err[] = "$k: rarity $rar";
    if (in_array($src, ['tool', 'crop', 'craft', 'region'], true) && $k !== ['tool' => 't:', 'crop' => 'c:', 'craft' => 'k:', 'region' => 'r:'][$src] . $ref) $err[] = "$k: key does not match its source and ref";
}
chk('pf_pieces.txt: every row is well formed (source, type, value, knob / edges, tag, life 2-4, rarity)', !$err, $err);
// no orphan sources: every ref names something the game has, and every tool type, crop kind, craft category and region has its piece
$toolsSrc = (string)file_get_contents(dirname($DATA) . '/tools.php'); preg_match('/const TOOL_TYPES = \[(.*?)\n\];/s', $toolsSrc, $m); preg_match_all("/^\s+'([a-z]+)'\s+=> \[/m", $m[1] ?? '', $mm); $toolTypes = $mm[1];
$kinds = array_values(array_unique(array_filter(array_map(fn($r) => $r[2] ?? '', pf_data_lines('crops.txt')), fn($k) => $k !== '' && $k !== 'cover')));
$cats = (string)file_get_contents(dirname($DATA) . '/crafting.php'); preg_match('/const CRAFT_CATEGORIES = \[(.*?)\n\];/s', $cats, $m); preg_match_all("/^\s+'([a-z]+)'\s+=> \[/m", $m[1] ?? '', $mm); $craftCats = $mm[1];
$codes = array_map(fn($r) => $r[0], pf_data_lines('regions.txt'));
sort($toolTypes); sort($kinds); sort($craftCats); sort($codes);
$s2 = fn(string $src) => (function (array $a) { sort($a); return $a; })($bySrc[$src] ?? []);
chk('tools: one piece per tool type, no orphan (' . count($toolTypes) . ' types)', $s2('tool') === $toolTypes && count($toolTypes) >= 18, [$s2('tool'), $toolTypes]);
chk('crops: one piece per crop kind, no orphan (9 kinds)', $s2('crop') === $kinds && count($kinds) === 9, [$s2('crop'), $kinds]);
chk('crafts: one piece per recipe category, no orphan (' . count($craftCats) . ')', $s2('craft') === $craftCats && count($craftCats) >= 6, [$s2('craft'), $craftCats]);
chk('regions: one piece per region, no orphan (14)', $s2('region') === $codes && count($codes) === 14, [$s2('region'), $codes]);
chk('calling pieces: one per calling, as PF_CALLING_TILE', array_map(fn($k) => $C[$k]['ref'] ?? '', PF_CALLING_TILE) === array_combine(array_keys(PF_CALLING_TILE), array_keys(PF_CALLING_TILE)));
chk('knacks unlock at the levels pf_unlocks gives', (function () use ($C) { foreach ($C as $k => $p) if ($p['src'] === 'knack') { $at = (int)$p['ref']; if ($at < 2 || in_array($k, pf_unlocks($at - 1), true) || !in_array($k, pf_unlocks($at), true)) return false; } return true; })());
chk('the starter offer and the kits name real pieces; every kit is a legal starter for every calling', (function () {
    foreach (array_merge([''], array_keys(PF_CALLING_TILE)) as $cal) foreach (['NA', 'OC', 'XX'] as $home) {
        foreach (pfd_offer_keys($cal, $home) as $k) if (!pfd_piece($k)) return false;
        foreach (PFD_KITS as $kit) if (pfd_starter_check(pfd_offer_keys($cal, $home, $kit), $cal, $home) !== null) return false;
    }
    return count(PFD_OFFER) === 12 && count(PFD_CORE) === 4;
})());
// classes
$cn = ['Critter', 'Bird', 'Beast', 'Reptile/Amphibian', 'Water', 'Plant/Fungus'];
chk('class table: the 6 classes, each a base 4 of 2 Hurt, 1 Guard, 1 class trick, with two or three knob families and a lean', (function () use ($K, $cn) {
    if (array_keys($K['classes']) !== $cn) return false;
    foreach ($K['classes'] as $c) {
        if (count($c['P']) !== 4 || !in_array($c['lean'], PFD_FAM, true)) return false;
        $t = array_count_values(array_column($c['P'], 't')); if (($t['hurt'] ?? 0) !== 2 || ($t['guard'] ?? 0) !== 1 || ($t['trick'] ?? 0) !== 1) return false;
        if (count(array_unique(array_column($c['P'], 'r'))) < 2) return false;   // Water has body and mind only (the approved table); with its unique pieces every creature has all three (checked in 2)
        foreach ($c['P'] as $q) if ($q['t'] === 'trick' && $q['tag'] === '') return false;
    }
    return true;
})(), $K['classes']);
chk('class tricks: Critter quick, Bird evade, Beast bash, Reptile poison, Water trip, Plant heal (thorns on its guard)', array_map(fn($c) => $c['P'][3]['tag'], $K['classes']) === array_combine($cn, ['quick', 'evade', 'bash', 'poison', 'trip', 'heal']) && $K['classes']['Plant/Fungus']['P'][2]['tag'] === 'thorns');
chk('class leans: Critter mind, Bird craft, Beast body, Reptile craft, Water body, Plant mind (and they match PFB_CLASS_LEAN)', array_map(fn($c) => $c['lean'], $K['classes']) === array_combine($cn, ['mind', 'craft', 'body', 'craft', 'body', 'mind']) && !array_filter($cn, fn($c) => pfb_lean(['class' => $c]) !== $K['classes'][$c]['lean']));
chk('size extras: large 1 piece, boss 2, small and medium none', array_map('count', $K['extra']) === ['small' => 0, 'medium' => 0, 'large' => 1, 'boss' => 2]);
$slugs = array_column($rows, 'slug');
chk('every creature has a class, and no class row names an unknown creature', !array_diff($slugs, array_keys($CM)) && !array_diff(array_keys($CM), $slugs) && !array_diff(array_unique(array_values($CM)), $cn), [array_diff($slugs, array_keys($CM)), array_diff(array_keys($CM), $slugs)]);
chk('class sizes as decided: Critter 17, Bird 11, Beast 28, Reptile/Amphibian 15, Water 13, Plant/Fungus 4', array_count_values($CM) == ['Critter' => 17, 'Bird' => 11, 'Beast' => 28, 'Reptile/Amphibian' => 15, 'Water' => 13, 'Plant/Fungus' => 4], array_count_values($CM));
chk('decided calls: sea otter, sea lion, bog leech = Water; reef turtle = Reptile; jade jaguar = Beast; thistle beast, wisp, bramblehorn = Plant', [$CM['sea-otter-bandit'], $CM['salt-sea-lion'], $CM['bog-leech'], $CM['reef-turtle'], $CM['jade-jaguar'], $CM['thistle-beast'], $CM['will-o-wisp'], $CM['old-bramblehorn']] === ['Water', 'Water', 'Water', 'Reptile/Amphibian', 'Beast', 'Plant/Fungus', 'Plant/Fungus', 'Plant/Fungus']);
// creature pieces
$foeRow = function (array $q, string $what) use (&$err): void {
    if (!in_array($q['t'], ['hurt', 'guard', 'trick', 'heal'], true)) { $err[] = "$what: type {$q['t']}"; return; }
    if ($q['n'] === '' || $q['r'] === null) $err[] = "$what: name or knob";
    if ($q['m'] < 0.3 || $q['m'] > 1.4) $err[] = "$what: v_mult {$q['m']}";
    if ($q['tag'] !== '' && !in_array($q['tag'], PFD_FOE_TAGS[$q['t']], true)) $err[] = "$what: tag {$q['tag']} on a {$q['t']} piece";
    if ($q['life'] < PFB_LIFE_MIN || $q['life'] > PFB_LIFE_MAX) $err[] = "$what: life";
};
$err = [];
foreach ($K['classes'] as $cl => $c) foreach ($c['P'] as $q) $foeRow($q, "$cl {$q['n']}");
foreach ($K['extra'] as $sz => $ps) foreach ($ps as $q) $foeRow($q, "@$sz {$q['n']}");
foreach ($R as $code => $pair) foreach ($pair as $slot => $q) { $foeRow($q, "$code {$q['n']}"); if (($slot === 'hurt') !== ($q['t'] === 'hurt')) $err[] = "$code $slot: the hurt slot holds the Hurt piece, the other slot does not"; }
$names = [];
foreach ($U as $slug => $u) {
    if (count($u['P']) !== 3) $err[] = "$slug: 3 unique pieces";
    if (!in_array($u['lean'], PFD_FAM, true)) $err[] = "$slug: lean";
    if (!in_array('hurt', array_column($u['P'], 't'), true)) $err[] = "$slug: no Hurt piece among its unique 3";
    if (count(array_unique(array_column($u['P'], 'r'))) < 2) $err[] = "$slug: knobs all one family";
    foreach ($u['P'] as $q) { $foeRow($q, "$slug {$q['n']}"); $names[] = $q['n']; }
}
chk('creature data: every base, size, region and unique piece is well formed (type, v_mult, knob, a tag its type can carry, life 2-4)', !$err, $err);
chk('all 88 creatures have 3 unique pieces (264), none for an unknown creature', !array_diff($slugs, array_keys($U)) && !array_diff(array_keys($U), $slugs) && count($names) === 264, count($names));
chk('unique piece names are unique across all creatures, and none repeats a class, size or region piece name', count($names) === count(array_unique($names)) && !array_intersect($names, array_merge(...array_map(fn($c) => array_column($c['P'], 'n'), array_values($K['classes'])), ...array_map(fn($p) => array_column($p, 'n'), array_values($R)), ...array_map(fn($p) => array_column($p, 'n'), array_values($K['extra'])))), array_diff_key($names, array_unique($names)));
chk('region pieces: 14 regions x 2 (a Hurt piece and another), codes as regions.txt; the player\'s region piece is the creature\'s "other" one', (function () use ($R, $codes, $C) { $k = array_keys($R); sort($k); if ($k !== $codes) return false; foreach ($R as $code => $p) if (count($p) !== 2 || $C['r:' . $code]['n'] !== $p['other']['n'] || $C['r:' . $code]['t'] !== $p['other']['t']) return false; return true; })());
chk('every creature tag is used by some piece (pierce, poison, quick, trip, bash, hold, thorns, evade, heal)', (function () use ($K, $U, $R) { $t = []; foreach ($K['classes'] as $c) foreach ($c['P'] as $q) $t[$q['tag']] = 1; foreach ($U as $u) foreach ($u['P'] as $q) $t[$q['tag']] = 1; foreach ($R as $p) foreach ($p as $q) $t[$q['tag']] = 1; return !array_diff(['pierce', 'poison', 'quick', 'trip', 'bash', 'hold', 'thorns', 'evade', 'heal'], array_keys($t)); })());

echo "== 2. creature deck layers\n";
$sz = []; $bad2 = [];
foreach ($rows as $c) foreach (['', 'NA', 'MENA'] as $reg) {
    $r = pfd_foe_row($c, $reg); $d = $r['deck']; $lay = array_count_values(array_column($d, 'layer')) + ['base' => 0, 'reg' => 0, 'rar' => 0, 'uni' => 0];
    $big = in_array($c['size'], ['large', 'boss'], true);
    $want = ['base' => 4, 'reg' => $reg === '' ? 0 : ($big ? 2 : 1), 'rar' => ['small' => 0, 'medium' => 0, 'large' => 1, 'boss' => 2][$c['size']], 'uni' => 3];
    if ($lay != $want) $bad2[] = $c['slug'] . " $reg layers " . json_encode($lay);
    if (count(array_unique(array_column($d, 'k'))) !== count($d)) $bad2[] = $c['slug'] . ' keys repeat';
    if (count(array_unique(array_column($d, 'n'))) !== count($d)) $bad2[] = $c['slug'] . " $reg names repeat";
    if (count(array_unique(array_column($d, 'r'))) !== 3) $bad2[] = $c['slug'] . ' does not have a knob in each family';
    foreach ($d as $p) if ($p['v'] < 1 || !in_array($p['col'], PFD_FAM, true) || !str_starts_with($p['k'], 'f:')) $bad2[] = $c['slug'] . ' piece ' . $p['n'];
    if ($r['lean'] !== $K['classes'][$CM[$c['slug']]]['lean'] || $r['class'] !== $CM[$c['slug']]) $bad2[] = $c['slug'] . ' lean or class';
    if ($reg === 'NA') $sz[$c['size']] = count($d);
}
chk('all 88 creatures, with and without a region: 4 base + region (small / medium 1, large / boss 2) + size extras (large 1, boss 2) + 3 unique; keys and names unique; a knob in each family', !$bad2, array_slice($bad2, 0, 5));
chk('deck sizes in a region: small 8, medium 8, large 10, boss 11', $sz === ['small' => 8, 'medium' => 8, 'large' => 10, 'boss' => 11], $sz);
$bd = pfd_foe_row(dk_foe('large', 18, 'badger'), 'NWE')['deck'];
chk('Badger in Mistmoor: Claw, Maul, Brace, Shoulder Barge + Bog Grip, Mist Veil + Slam + Dig In, Badger Maul, Bash Back', array_column($bd, 'n') === ['Claw', 'Maul', 'Brace', 'Shoulder Barge', 'Bog Grip', 'Mist Veil', 'Slam', 'Dig In', 'Badger Maul', 'Bash Back'], array_column($bd, 'n'));
chk('values are v_mult x the archetype value (Badger, level 18: v 12 -> Claw 12, Maul 13, Brace 8, Badger Maul 16)', pfd_foe_v(dk_foe('large', 18)) === 12 && array_column($bd, 'v', 'n')['Claw'] === 12 && array_column($bd, 'v', 'n')['Maul'] === 13 && array_column($bd, 'v', 'n')['Brace'] === 8 && array_column($bd, 'v', 'n')['Badger Maul'] === 16, array_column($bd, 'v', 'n'));
chk('the lean: 3 pieces in 5 (deck order) stack in the class family (Beast: body), the others in their type family', array_column($bd, 'col') === ['body', 'body', 'body', 'craft', 'body', 'body', 'body', 'body', 'body', 'body'], array_column($bd, 'col'));
$wy = pfd_foe_row(dk_foe('boss', 30, 'dune-wyrm'), 'MENA')['deck'];
chk('a boss plays a set order: one set-up piece, then two Hurt pieces, and again', array_slice(array_map(fn($p) => $p['t'] === 'hurt' ? 'H' : 's', $wy), 0, 9) === ['s', 'H', 'H', 's', 'H', 'H', 's', 'H', 'H'] && count($wy) === 11, array_column($wy, 't'));
$s = pfb_new(dk_me(18), pfd_foe_row(dk_foe('large', 18, 'badger'), 'NWE'), 3, ['v1' => ['life' => 1], 'blank' => true]);   // 2.6.95: a new fight has no per-piece life; this check is about the 2.6.94 rule
$all = array_merge($s['foe']['hand'], $s['foe']['draw'], $s['foe']['discard']);
chk('a v1 fight deals the layered deck: 10 creature pieces, each with authored edges in its column family, its life and layer', count($all) === 10 && !array_filter($all, fn($t) => !isset($t['ed'], $t['life'], $t['layer']) || $t['ed']['T'][1] !== $t['col'] || $t['src'] !== 'creature'), array_column($all, 'n'));
chk('Dig In (hold) stays 4 rounds, Skitter-like quick pieces 2', (function () use ($all) { foreach ($all as $t) if ($t['n'] === 'Dig In') return $t['life'] === 4; return false; })() && pfd_foe_pieces(dk_foe('small', 1, 'aphid-swarm'))[3]['life'] === 2);
chk('pf_foe_deck without a deck in the row is the old archetype deck (flag off: unchanged)', array_column(pf_foe_deck(dk_foe('large', 18, 'badger')), 'k') === ['f:hit1', 'f:hit2', 'f:guard', 'f:feint', 'f:rest', 'f:hit3', 'f:hit4', 'f:guard3']);

echo "== 3. creature tags in the engine\n";
$s = dk_bare(); $s['me']['block'] = 10; $hp = $s['me']['hp'];
$e = dk_fire($s, 'foe', dk_tile($s, 'f:a', 'hurt', 5));
chk('a plain creature Hurt is soaked by your guard', $s['me']['hp'] === $hp && $s['me']['block'] === 5 && $e['blocked'] === 5, [$s['me']['hp'], $s['me']['block']]);
$e = dk_fire($s, 'foe', dk_tile($s, 'f:b', 'hurt', 5, 'pierce'));
chk('PIERCE: the creature\'s hit ignores your guard', $s['me']['hp'] === $hp - 5 && $s['me']['block'] === 5 && $e['blocked'] === 0 && $e['dmg'] === 5, [$s['me']['hp'], $s['me']['block']]);
$s = dk_bare(); $hp = $s['me']['hp'];
$e = dk_fire($s, 'foe', dk_tile($s, 'f:a', 'hurt', 6, 'poison'));
chk('POISON (Hurt): 2 ticks wait on you, each a third of the hit', $s['me']['poison'] === 2 && $s['me']['poison_v'] === 2 && $s['me']['hp'] === $hp - 6 && $e['poisoned'] === 2, $s['me']);
dk_fire($s, 'foe', dk_tile($s, 'f:b', 'trick', 7, 'poison'));
chk('POISON stacks to at most 3 ticks; the stronger dose counts (a trick: half its value)', $s['me']['poison'] === 3 && $s['me']['poison_v'] === 4, [$s['me']['poison'], $s['me']['poison_v']]);
dk_fire($s, 'foe', dk_tile($s, 'f:c', 'hurt', 3, 'poison'));
chk('POISON cap: a third dose changes nothing', $s['me']['poison'] === 3 && $s['me']['poison_v'] === 4);
$hp = $s['me']['hp']; $s['foe']['hand'] = []; $s['foe']['draw'] = []; $s['foe']['discard'] = []; pfb_end_round($s);
chk('POISON ticks at the end of the round, after the terrain (health lost, one tick gone, a note in the terrain log)', $s['me']['hp'] === $hp - 4 && $s['me']['poison'] === 2 && end($s['envlog'])['k'] === 'poison' && end($s['envlog'])['me'] === 4, [$s['me']['hp'], $hp, $s['envlog']]);
$ev = pfb_env_events($s);
chk('the poison tick is a replay event with a line', end($ev)['env'] === 'poison' && end($ev)['n'] === 'Poison' && str_contains(pfight_line(end($ev), 'Thing'), 'poison works on you: you lose 4 health'), pfight_line(end($ev), 'Thing'));
pfb_end_round($s); pfb_end_round($s);
chk('POISON runs out after its ticks', $s['me']['poison'] === 0 && $s['me']['poison_v'] === 0 && $s['me']['hp'] === $hp - 12, [$s['me']['poison'], $s['me']['hp'], $hp]);
$s = dk_bare(); $s['me']['hp'] = 3; dk_fire($s, 'foe', dk_tile($s, 'f:a', 'trick', 8, 'poison')); $s['foe']['hand'] = []; $s['foe']['draw'] = []; pfb_end_round($s);
chk('POISON can end the fight', $s['over'] === 'defeat' && $s['me']['hp'] === 0, [$s['over'], $s['me']['hp']]);
$s = dk_bare(); $s['me']['hand'] = array_slice($s['me']['hand'], 0, 1);
dk_fire($s, 'foe', dk_tile($s, 'f:a', 'hurt', 2, 'trip')); dk_fire($s, 'foe', dk_tile($s, 'f:b', 'trick', 2, 'trip'));
$s['foe']['hand'] = []; $s['foe']['draw'] = []; $n0 = count($s['me']['hand']); pfb_end_round($s);
chk('TRIP: you draw one piece fewer next round, once however many trips landed', count($s['me']['hand']) === $n0 + PF_DRAW - 1 && $s['me']['slowdraw'] === 0, count($s['me']['hand']));
$n0 = count($s['me']['hand']); $s['me']['hand'] = array_slice($s['me']['hand'], 0, 1); pfb_end_round($s);
chk('TRIP lasts one round only', count($s['me']['hand']) === 1 + PF_DRAW, count($s['me']['hand']));
$mkTurn = function (array $tags) {   // the creature's turn with this hand of Hurt pieces (no aim): how many pieces does it put down?
    $s = dk_bare(['aim' => 0]); $s['foe']['hand'] = []; foreach ($tags as $i => $tg) $s['foe']['hand'][] = dk_tile($s, 'f:q' . $i, 'hurt', 4 - $i, $tg);
    $s['me']['hand'] = [dk_tile($s, 'swing', 'hurt', 1)]; pfb_place($s, 'me', 0, 2, 2);
    pfb_foe_turn($s, 0); return [count($s['lastfoe']), $s];
};
chk('a plain creature piece: it puts down one piece a turn', $mkTurn(['', '', ''])[0] === 1);
[$n, $s] = $mkTurn(['quick', '', '']);
chk('QUICK: the creature puts down one more piece that turn', $n === 2, $n);
chk('QUICK: once a turn, even when the second piece is Quick too', $mkTurn(['quick', 'quick', 'quick'])[0] === 2 && empty($s['foe']['again']));
$s = dk_bare(); $s['foe']['block'] = 6; $hp = $s['me']['hp'];
$e = dk_fire($s, 'foe', dk_tile($s, 'f:a', 'hurt', 5, 'bash'));
chk('BASH (Hurt): the creature\'s guard goes into the hit and is spent', $s['me']['hp'] === $hp - 11 && $s['foe']['block'] === 0 && $e['bashed'] === 6, [$s['me']['hp'], $hp, $s['foe']['block']]);
$s = dk_bare(); $s['foe']['block'] = 6; $hp = $s['me']['hp'];
dk_fire($s, 'foe', dk_tile($s, 'f:a', 'trick', 3, 'bash')); $e = dk_fire($s, 'foe', dk_tile($s, 'f:b', 'hurt', 5)); dk_fire($s, 'foe', dk_tile($s, 'f:c', 'hurt', 5));
chk('BASH (Shoulder Barge, a trick): its next hit carries its guard once, and the guard stays', $s['me']['hp'] === $hp - 11 - 5 && $s['foe']['block'] === 6 && $e['bashed'] === 6, [$s['me']['hp'], $hp]);
$s = dk_bare(); $fh = $s['fh']['now'];
dk_fire($s, 'foe', dk_tile($s, 'f:a', 'trick', 2, 'evade')); $e = dk_fire($s, 'me', dk_tile($s, 'swing', 'hurt', 6)); $e2 = dk_fire($s, 'me', dk_tile($s, 'jab', 'hurt', 6));
chk('EVADE (Flutter Off): your first Hurt misses the creature, the next one lands', ($e['evaded'] ?? 0) === 6 && $e['dmg'] === 0 && $e2['dmg'] === 6 && $s['fh']['now'] > $fh, [$e, $e2]);
$s = dk_bare(); $hp = $s['me']['hp'];
dk_fire($s, 'foe', dk_tile($s, 'f:a', 'guard', 4, 'thorns')); $e = dk_fire($s, 'me', dk_tile($s, 'swing', 'hurt', 6));
chk('THORNS (Bramble Coat): a hit its guard blocks pricks you (4% of your health, at least 2)', $s['me']['hp'] === $hp - max(2, (int)round(0.04 * $s['me']['max'])) && $e['pricked'] > 0 && $e['blocked'] === 4, [$s['me']['hp'], $hp, $e]);
$s = dk_bare(); $s['fh']['now'] = 10.0; dk_fire($s, 'foe', dk_tile($s, 'f:a', 'trick', 4, 'heal'));
chk('HEAL (Sap Mend, a trick): the creature recovers', $s['fh']['now'] === 6.0, $s['fh']['now']);
$s = dk_bare(['tags' => 0]); $s['me']['block'] = 10; $hp = $s['me']['hp']; dk_fire($s, 'foe', dk_tile($s, 'f:b', 'hurt', 5, 'pierce')); dk_fire($s, 'foe', dk_tile($s, 'f:c', 'hurt', 2, 'poison'));
chk('rule switch tags = 0: creature tags do nothing, and the state has no poison fields', $s['me']['hp'] === $hp && !isset($s['me']['poison']) && !isset(pfb_view($s)['status']), $s['me']['hp']);
$o = pfb_new(dk_me(), dk_foe('medium'), 7, []); $o['me']['block'] = 10; $hp = $o['me']['hp'];
$o['pcs'] = []; $o['cell'] = []; $t = ['k' => 'f:z', 'n' => 'Z', 't' => 'hurt', 'v' => 5, 'r' => 'body', 'tag' => 'pierce', 'm' => '']; $o['pid']++; $o['seq']++; $o['pcs'][$o['pid']] = ['id' => $o['pid'], 'by' => 'foe', 'tile' => $t, 'x' => 0, 'y' => 0, 'born' => 1, 'seq' => $o['seq']]; $o['cell']['0,0'] = $o['pid']; pfb_fire($o, $o['pid']);
chk('an old fight (flag off): a creature tag does nothing, as before', $o['me']['hp'] === $hp && $o['me']['block'] === 5 && !isset($o['me']['poison'], $o['wear'], $o['v1']), [$o['me']['hp'], $o['me']['block']]);
$v = pfb_view(pfb_new(dk_me(), pfd_foe_row(dk_foe('medium', 8, 'shore-crab'), 'SE'), 5, ['v1' => true]));
chk('the view carries what waits on each side (status) and the tool wear so far', isset($v['status']['poison'], $v['status']['slowdraw'], $v['status']['foe_evade'], $v['status']['foe_thorns'], $v['status']['foe_bash']) && isset($v['wear']), array_keys($v));
// whole fights against every creature: invariants
$tot = ['n' => 0, 'over' => [], 'tags' => []];
foreach ($rows as $ci => $c) {
    $s = pfb_new(dk_me($c['level']), pfd_foe_row($c, array_keys($R)[$ci % 14]), 900 + $ci, ['v1' => true]); $t = 0;
    while (!$s['over'] && $t++ < 40) {
        $m = pfb_search($s, 'me');
        if (!$m) foreach (array_keys($s['me']['hand']) as $i) { if (!pfb_can_flip($s, $i)) continue; pfb_flip($s, $i, $s['turn']); if ($m = pfb_search($s, 'me')) break; pfb_flip($s, $i, $s['turn']); }   // stuck: a flip may unstick it
        $r = $m ? pfb_play($s, [[$m[0], $m[1], $m[2]]], $s['turn']) : pfb_pass($s, $s['turn']);
        if ($r['err']) { $tot['bad'] = $c['slug'] . ': ' . $r['err']; break 2; }
        foreach ($r['ev'] as $e) foreach (['poisoned', 'tripped', 'bashed', 'evaded', 'pricked'] as $k) if (!empty($e[$k]) && (($e['by'] ?? '') === 'foe' || in_array($k, ['evaded', 'pricked'], true))) $tot['tags'][$k] = ($tot['tags'][$k] ?? 0) + 1;
        if ($s['me']['poison'] > PF_POISON_CAP || $s['me']['slowdraw'] > 1 || count($s['me']['hand']) > PF_HAND_CAP || count($s['lastfoe'] ?? []) > 2) { $tot['bad'] = $c['slug']; break 2; }
        $cnt = count($s['foe']['hand']) + count($s['foe']['draw']) + count($s['foe']['discard']) + count(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe'));
        if ($cnt !== count(pfd_foe_pieces($c, array_keys($R)[$ci % 14]))) { $tot['bad'] = $c['slug'] . ' lost a piece'; break 2; }
    }
    $tot['n']++; $tot['over'][(string)$s['over']] = ($tot['over'][(string)$s['over']] ?? 0) + 1;
}
chk('88 whole fights against the layered decks: every fight ends, no piece is lost, poison never above 3, at most 2 creature pieces a turn', $tot['n'] === 88 && !isset($tot['bad']) && !isset($tot['over']['']), $tot);
chk('in those fights poison, trip, bash, evade and thorns all happened', !array_diff(['poisoned', 'tripped', 'bashed', 'evaded', 'pricked'], array_keys($tot['tags'])), $tot['tags']);
echo '     ' . json_encode($tot['over']) . ' ' . json_encode($tot['tags']) . "\n";

echo "== 4. the player's deck from its sources\n";
$src = pfd_sources_blank(1, 'thornblade', 'NWE'); $b = pfd_build($src);
chk('no starter chosen: the default kit plays (4 core + the Bold kit), 10 pieces, nothing saved', !$b['starter'] && array_column($b['deck'], 'key') === ['swing', 'dodge', 'rest', 'charm', 'thorn', 'jab', 'swing#2', 'pierce', 'snack', 'c:grain'] && $b['err'] === null, array_column($b['deck'], 'key'));
chk('the offer: 12 pieces with the calling piece and the home region piece; three one-tap kits of 6', count($b['offer']) === 12 && in_array('thorn', $b['offer'], true) && in_array('r:NWE', $b['offer'], true) && array_map('count', $b['kits']) === ['bold' => 6, 'steady' => 6, 'kind' => 6], $b['offer']);
chk('no calling: Taunt stands in for the calling piece; an unknown home: the Maplewold piece', in_array('taunt', pfd_offer_keys('', 'ZZ'), true) && in_array('r:NA', pfd_offer_keys('', 'ZZ'), true));
$off = pfd_offer_keys('thornblade', 'NWE');
chk('starter check: 6 picks from the offer', pfd_starter_check(array_slice($off, 0, 6), 'thornblade', 'NWE') === null);
chk('starter check: 5 picks, a repeat, a piece not on offer are refused', pfd_starter_check(array_slice($off, 0, 5), 'thornblade', 'NWE') !== null && pfd_starter_check(['jab', 'jab', 'snack', 'hide', 'brace', 'hum'], 'thornblade', 'NWE') !== null && pfd_starter_check(['smash', 'jab', 'snack', 'hide', 'brace', 'hum'], 'thornblade', 'NWE') !== null);
chk('starter check: fewer than 3 Hurt pieces is refused (core Swing + none)', pfd_starter_check(['snack', 'hide', 'brace', 'soothe', 'hum', 'c:grain'], 'rootwarden', 'NWE') === 'Bring at least three Hurt pieces.');
$src['starter'] = array_merge(PFD_CORE, pfd_offer_keys('thornblade', 'NWE', PFD_KITS['bold'])); $b = pfd_build($src);
chk('the Bold kit: a second Swing is in the deck (10 pieces, 5 Hurt)', $b['starter'] && count($b['deck']) === 10 && $b['counts']['hurt'] === 5 && in_array('swing#2', array_column($b['deck'], 'key'), true) && array_count_values(array_column(pfd_tiles($b['deck'], dk_stats(1)), 'k'))['swing'] === 2, $b['counts']);
chk('a starter piece is owned even without its source (Oat Cake with no grain grown: rank Common)', (function () use ($b) { foreach ($b['pieces'] as $e) if ($e['key'] === 'c:grain') return $e['starter'] && $e['rank'] === 1 && $e['on']; return false; })());
chk('level 1 owns no knack beyond the starter; level 16 owns all 17 (off until switched on)', count(array_filter($b['pieces'], fn($e) => $e['src'] === 'knack' && !$e['starter'])) === 0 && (function () { $b = pfd_build(['level' => 16] + pfd_sources_blank(16, 'thornblade')); $k = array_filter($b['pieces'], fn($e) => $e['src'] === 'knack'); return count($k) === 17 && count(array_filter($k, fn($e) => $e['on'])) === 2; })());
$src = pfd_sources_blank(12, 'bloomcaller', 'EA'); $src['crops'] = ['spice' => 3, 'fruit' => 1]; $src['crafts'] = ['potions' => 2]; $src['regions'] = ['EA' => 1, 'OC' => 1]; $b = pfd_build($src); $keys = array_column($b['deck'], 'key');
chk('crop, craft and region pieces the gnome owns are in the deck by default (no maximum deck size)', !array_diff(['c:spice', 'c:fruit', 'k:potions', 'r:EA', 'r:OC'], $keys) && count($keys) === 15 && $b['err'] === null, $keys);
chk('a piece of a source the gnome does not have is not owned (no tuber, no garden craft, no Dunewhisper guide)', !array_filter($b['pieces'], fn($e) => in_array($e['key'], ['c:tuber', 'k:garden', 'r:MENA'], true)));
chk('the rank comes from the source: spice mastery 3 = Rare, potions 2 = Uncommon', array_column($b['pieces'], 'rank', 'key')['c:spice'] === 3 && array_column($b['pieces'], 'rank', 'key')['k:potions'] === 2);
chk('another calling\'s piece is not owned; your own is', !in_array('thorn', array_column($b['pieces'], 'key'), true) && in_array('bloom', array_column($b['pieces'], 'key'), true));
$src['state'] = ['c:fruit' => false, 'lull' => true, 'smash' => true]; $b2 = pfd_build($src); $k2 = array_column($b2['deck'], 'key');
chk('switching: a crop piece off, an owned knack on; a knack above your level stays out', !in_array('c:fruit', $k2, true) && in_array('lull', $k2, true) && !in_array('smash', $k2, true), $k2);
$src['state'] = array_fill_keys(['dodge', 'rest', 'charm', 'c:grain', 'snack', 'swing#2', 'pierce', 'c:fruit', 'k:potions'], false); $b3 = pfd_build($src);
chk('validate: fewer than 8 kit pieces is refused', $b3['counts']['kit'] === 6 && $b3['err'] === 'Pack at least 8 kit pieces.', $b3['counts']);
chk('a fight with an illegal deck falls back to the default kit (never an illegal deck in a fight)', count(pfd_fight_entries($src)) >= PFD_KIT_MIN && pfd_validate(pfd_build(['starter' => null, 'state' => []] + $src)) === null);
$src = pfd_sources_blank(12, 'rootwarden'); $src['state'] = ['swing' => false, 'jab' => false, 'swing#2' => false, 'pierce' => false, 'taunt' => true, 'soothe' => true, 'hum' => true]; $b4 = pfd_build($src);
chk('validate: no Hurt piece is refused', $b4['counts']['hurt'] === 0 && str_starts_with((string)$b4['err'], 'Bring at least one Hurt piece'), $b4['counts']);
$src = pfd_sources_blank(20, 'thornblade'); $src['crops'] = ['spice' => 3, 'fruit' => 3, 'nut' => 3, 'herb' => 3]; $b5 = pfd_build($src);
chk('rarity cap: a 4th Rare piece is over the cap (refused; in a fight it is left out)', $b5['counts']['rare'] === 4 && $b5['err'] === 'At most 3 Rare pieces a deck. Take one out first.' && count(array_filter($b5['pieces'], fn($e) => $e['out'] === 'cap')) === 1 && count(array_filter($b5['deck'], fn($e) => $e['rank'] === 3)) === 3, $b5['counts']);
$src = pfd_sources_blank(20, 'thornblade'); $src['tools'] = ['axe' => 4, 'till' => 4]; $b6 = pfd_build($src);
chk('rarity cap: a 2nd Masterwork is over the cap', $b6['counts']['mw'] === 2 && $b6['err'] === 'At most 1 Masterwork piece a deck. Take the other one out first.' && count(array_filter($b6['deck'], fn($e) => $e['rank'] === 4)) === 1, $b6['counts']);
$src = pfd_sources_blank(20, 'thornblade'); $src['tools'] = ['axe' => 3, 'till' => 4]; $src['crops'] = ['spice' => 3, 'fruit' => 3]; $src['pals'] = [['n' => 'Moth Glow', 't' => 'charm', 'v' => 8, 'r' => 'body', 'rank' => 2]];
$src['state'] = ['brace' => true, 'snack' => false]; $b7 = pfd_build($src);
chk('3 Rare + 1 Masterwork is legal (kit + gear together)', $b7['counts']['rare'] === 3 && $b7['counts']['mw'] === 1 && $b7['err'] === null, $b7['counts']);
chk('gear: tool pieces from the belt and the party pal\'s piece are ADDED (source tool / pal); Teamwork sources counted', $b7['counts']['belt'] === 2 && $b7['counts']['pals'] === 1 && $b7['counts']['team'] === 3 && $b7['counts']['n'] === 15, $b7['counts']);
$tiles = pfd_tiles($b7['deck'], dk_stats(20)); $byK = array_column($tiles, null, 'k');
chk('tiles: a Masterwork tool piece gets +5 and life 4, a Fine one +4, its tool type and source; a pal piece its own value', $byK['t:till']['v'] === 3 + 1 + 6 + 5 && $byK['t:till']['life'] === 4 && $byK['t:till']['tool'] === 'till' && $byK['t:till']['src'] === 'tool' && $byK['t:till']['rank'] === 4 && $byK['t:axe']['v'] === 4 + 1 + 6 + 4 && $byK['pal:Moth Glow']['v'] === 8 + 1 + 6 && $byK['pal:Moth Glow']['src'] === 'pal', [$byK['t:till'], $byK['t:axe']['v'], $byK['pal:Moth Glow']['v']]);
chk('tiles: piece life is 2-4 (Quick 2, Hold 4, Juicy Bite 2, others 3)', $byK['jab']['life'] === 2 && $byK['brace']['life'] === 4 && $byK['c:fruit']['life'] === 2 && $byK['swing']['life'] === 3 && !array_filter($tiles, fn($t) => $t['life'] < 2 || $t['life'] > 4));
chk('tiles: the calling piece grows with the calling tier; no snack to eat gives a Breather', pfd_tiles([$b7['deck'][4]], dk_stats(20), [], 'thornblade', 3)[0]['v'] === $byK['thorn']['v'] + 4 && pfd_tiles([['k' => 'snack', 't' => 'item', 'src' => 'basic']], dk_stats(1), [], '', 1, false)[0]['k'] === 'breather');
$s = pfb_new(dk_me(20, $src), pfd_foe_row(dk_foe('large', 20, 'wild-boar'), 'NA'), 9, ['v1' => true, 'blank' => true]);
$mine = array_merge($s['me']['hand'], $s['me']['draw']); $bk = array_column($mine, null, 'k');
chk('in the fight: the hand is drawn from the deck (15 pieces); tool pieces stack in craft, crop pieces in mind, the pal in body', count($mine) === 15 && $bk['t:axe']['ed']['T'][1] === 'craft' && $bk['c:spice']['ed']['T'][1] === 'mind' && $bk['pal:Moth Glow']['ed']['T'][1] === 'body' && $bk['swing']['ed']['T'][1] === 'body', array_column($mine, 'k'));

echo "== 5. the fight belt\n";
$src = pfd_sources_blank(5, 'thornblade'); $src['tools'] = ['plant' => 1, 'axe' => 2, 'till' => 3, 'rod' => 1];
chk('a belt never set: the best tools fill the 2 slots', array_column(pfd_belt($src), 'type') === ['till', 'axe'], pfd_belt($src));
$src['slots'] = 3; chk('3 slots (Stitched belt): three tools', array_column(pfd_belt($src), 'type') === ['till', 'axe', 'plant']);
$src['slots'] = 4; chk('4 slots (Masterwork belt): four tools', count(pfd_belt($src)) === 4 && pfd_build($src)['counts']['belt'] === 4);
chk('belt tiers: 2 / 3 / 4 slots, bought only, at levels 1 / 8 / 18', array_map(fn($b) => [$b[0], $b[2]], PFD_BELTS) === [1 => [2, 1], 2 => [3, 8], 3 => [4, 18]] && PFD_BELTS[1][1] === null && isset(PFD_BELT_ITEMS[PFD_BELTS[2][1]], PFD_BELT_ITEMS[PFD_BELTS[3][1]]));
$src['slots'] = 2; $src['belt'] = ['rod', 'axe', 'till']; $bl = pfd_belt($src);
chk('a belt you set is kept in order; a tool past the last slot does not count', array_column($bl, 'state') === ['ok', 'ok', 'over'] && array_column(array_filter(pfd_build($src)['deck'], fn($e) => $e['gear']), 'key') === ['t:rod', 't:axe'], $bl);
$src['belt'] = ['rod', 'net']; chk('a tool you no longer have leaves the deck', array_column(pfd_belt($src), 'state') === ['ok', 'none'] && pfd_build($src)['counts']['belt'] === 1);
chk('durability: 20, +4 per rank (20 / 24 / 28 / 32)', array_map('pfd_dur_max', [1, 2, 3, 4]) === [20, 24, 28, 32]);
$src['belt'] = ['rod', 'axe']; $src['wear'] = ['rod' => 20, 'axe' => 22];
chk('a worn-out tool (wear = durability) is broken and leaves the deck; a worn one stays', array_column(pfd_belt($src), 'state') === ['broken', 'ok'] && array_column(pfd_belt($src), 'left') === [0, 2] && pfd_build($src)['counts']['belt'] === 1, pfd_belt($src));
$src['belt'] = null; chk('a broken tool is not picked for a belt that was never set', !in_array('rod', array_column(pfd_belt($src), 'type'), true));

echo "== 6. tool wear in a fight\n";
$s = dk_bare(['events' => 0]); $axe = dk_tile($s, 't:axe', 'hurt', 4, '', ['tool' => 'axe', 'src' => 'tool']); $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2);
$clear = function (array &$s) { $s['pcs'] = []; $s['cell'] = []; $s['foe']['plan'] = null; };   // an empty board: the centre is the one legal cell
chk('no tool piece played yet: no wear', empty($s['wear']));
$s['me']['hand'] = [dk_tile($s, 'swing', 'hurt', 4)]; $e1 = pfb_play($s, [[0, $cx, $cy]], $s['turn'])['err'];
chk('a kit piece costs no wear', $e1 === null && empty($s['wear']), $e1);
$clear($s); $s['me']['hand'] = [$axe]; $w = $s; $dry = pfb_play($w, [[0, $cx, $cy]], $w['turn'], null, true);
chk('a dry run (lit-cell numbers) costs no wear', $dry['err'] === null && empty($s['wear']));
$e2 = pfb_play($s, [[0, $cx, $cy]], $s['turn'])['err'];
chk('the axe\'s piece played once: the axe loses 2', $e2 === null && ($s['wear'] ?? []) === ['axe' => 2], [$e2, $s['wear'] ?? null]);
for ($k = 0; $k < 2; $k++) { $clear($s); $s['me']['hand'] = [$axe]; pfb_play($s, [[0, $cx, $cy]], $s['turn']); }
chk('played 3 times: 6; a tool whose piece was never played has none', ($s['wear'] ?? []) === ['axe' => 6], $s['wear'] ?? null);
chk('the wear travels with the saved fight (JSON) and shows in the view', json_decode(json_encode($s), true)['wear'] === ['axe' => 6] && (array)pfb_view($s)['wear'] === ['axe' => 6]);
$g = dk_bare(['events' => 0]); $a = dk_tile($g, 't:axe', 'hurt', 4, '', ['tool' => 'axe', 'src' => 'tool']); $bq = dk_tile($g, 't:till', 'hurt', 3, '', ['tool' => 'till', 'src' => 'tool']);
$g['me']['hand'] = [$a, $bq];
$ce = pfb_connect($g, 'me', 0, 1, 'B'); $held0 = empty($g['wear']); $sp = $ce === null ? pfb_group_spots($g, $g['me']['held']) : [];
if ($sp) pfb_place_group($g, 'me', $sp[0][0], $sp[0][1]);
chk('a set-aside group: each tool piece in it costs its tool 2 when the group is placed (not when it is set aside)', $ce === null && $held0 && $sp && ($g['wear'] ?? []) == ['axe' => 2, 'till' => 2], [$ce, $g['wear'] ?? null]);

echo "== 7. kits: four Hurt each, Bold by default, no harmony meter\n";
chk('PFD_KIT_DEFAULT is bold', PFD_KIT_DEFAULT === 'bold');
$lowH = 99; foreach (array_merge([''], array_keys(PF_CALLING_TILE)) as $cal) foreach (array_keys(PFD_KITS) as $kit) foreach (['NA', 'CB', 'SEA'] as $home) { $sr = pfd_sources_blank(1, $cal, $home); $sr['starter'] = array_merge(PFD_CORE, pfd_offer_keys($cal, $home, PFD_KITS[$kit])); $lowH = min($lowH, pfd_build($sr)['counts']['hurt']); }
chk('every kit with the core holds at least 4 Hurt pieces for every calling and home (lowest ' . $lowH . ')', $lowH >= 4, $lowH);
chk('a 2-Hurt pick is refused, a 3-Hurt pick is not', pfd_starter_check(['jab', 'snack', 'hide', 'brace', 'soothe', 'hum'], 'rootwarden', 'NWE') === 'Bring at least three Hurt pieces.' && pfd_starter_check(['jab', 'pierce', 'hide', 'brace', 'soothe', 'hum'], 'rootwarden', 'NWE') === null);
chk('the deck model has no harmony key and no pfd_harmony', !function_exists('pfd_harmony') && !array_key_exists('harmony', pfd_build(pfd_sources_blank(1, 'thornblade'))));
chk('edges of an entry are the board\'s (Oat Cake: left hole body, right knob craft, top hole mind, bottom knob mind)', pfd_edges(pfd_build(pfd_sources_blank(1, 'thornblade'))['deck'][9]) === ['L' => ['hole', 'body'], 'R' => ['knob', 'craft'], 'T' => ['hole', 'mind'], 'B' => ['knob', 'mind']]);

echo "== 8. flag off: nothing changed\n";
$me0 = ['hp' => 40, 'max_hp' => 40, 'stats' => dk_stats(8), 'deck' => pf_player_deck(dk_stats(8), 'thornblade', 1, [], pf_unlocks(8)), 'luck' => 0];
$o = pfb_new($me0, dk_foe('large', 18, 'badger'), 11, []); $t = 0; $log = [];
while (!$o['over'] && $t++ < 30) { $m = pfb_search($o, 'me'); $r = $m ? pfb_play($o, [[$m[0], $m[1], $m[2]]], $o['turn']) : pfb_pass($o, $o['turn']); if ($r['err']) break; foreach ($r['ev'] as $e) $log[] = [$e['by'], $e['k'] ?? '', $e['v'] ?? 0, $e['hpnow'] ?? null, $e['fhnow'] ?? null]; }
chk('an old board fight (no v1): the archetype creature deck, no deck-model keys in the state or its pieces', !isset($o['v1'], $o['wear'], $o['me']['poison'], $o['me']['slowdraw'], $o['foe']['again'], $o['foe']['bashnext']) && !array_filter(array_merge($o['me']['hand'], $o['me']['draw'], $o['me']['discard'], $o['foe']['hand'], $o['foe']['draw'], $o['foe']['discard']), fn($t) => isset($t['src']) || isset($t['rank']) || isset($t['tool']) || isset($t['layer']) || isset($t['ed'])), array_keys($o));
chk('that old fight plays to the same transcript as before stage B (md5 of every event: recorded at commit 9f297fc3)', md5(json_encode($log)) === 'dc98f65f7651445c2305ec61d2fad774', md5(json_encode($log)));
$o2 = pf_new($me0, dk_foe('medium', 8, 'paper-wasp'), 5, []); pf_play($o2, [0], 1);
chk('an old strip fight still starts and plays (signature pieces as before)', in_array('Sting', array_column(pf_foe_deck(dk_foe('medium', 8, 'paper-wasp')), 'n'), true) && $o2['turn'] === 2);
chk('the old Puzzle box is untouched: collection, capacity and the default box', pf_collection(8, 'thornblade') === ['swing', 'dodge', 'rest', 'charm', 'snack', 'hide', 'thorn', 'soothe', 'jab', 'brace', 'hum', 'pluck', 'pierce'] && pf_box_capacity(8) === 10 && count(pf_box(8, 'thornblade', null)) === 10);
echo $bad ? "$bad FAILED\n" : "pure checks: all ok\n";
exit($bad ? 1 : 0);
}

// ================================================================= with a database (an installed copy; player sprout)
echo "== 9. the deck model in the database\n";
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$re = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$item = fn(string $slug, int $n = 1) => give_item($uid, item_id_by_slug($slug), $n);
// 2.6.74 release: the belts, the kit and its recipe are only made once the setting is on (the flag-off check is in pfdeck_v1.sh, before the setting is switched on)
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', '0')"); setting('__reload__'); pfd_ensure_content();
chk('setting off: pfd_live() is false', !pfd_live());
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__');
chk('the tables are made on first use', pfd_ensure() && q_val('SELECT COUNT(*) FROM pf_decks') !== false && q_val('SELECT COUNT(*) FROM pf_deck_pieces') !== false && q_val('SELECT COUNT(*) FROM pf_belts') !== false && q_val('SELECT COUNT(*) FROM pf_tool_wear') !== false);
chk('the schema (Upgrade database) lists the four tables', count(array_filter(schema_statements('sqlite')[0], fn($t) => preg_match('/CREATE TABLE IF NOT EXISTS pf_(decks|deck_pieces|belts|tool_wear) /', $t))) === 4 && count(array_filter(schema_statements('mysql')[0], fn($t) => preg_match('/CREATE TABLE IF NOT EXISTS pf_(decks|deck_pieces|belts|tool_wear) .*InnoDB/s', $t))) === 4);
chk('setting on: the first use makes the content once (marker setting pfd_content)', setting('pfd_content') === '1', setting('pfd_content'));
$nItems = (int)q_val('SELECT COUNT(*) FROM items'); $nRec = (int)q_val('SELECT COUNT(*) FROM recipes'); $nStock = (int)q_val('SELECT COUNT(*) FROM shop_stock');
require_once APP_ROOT . '/includes/crafting.php'; pfd_ensure_content(); ensure_crafts();
chk('content: a second run adds nothing', [(int)q_val('SELECT COUNT(*) FROM items'), (int)q_val('SELECT COUNT(*) FROM recipes'), (int)q_val('SELECT COUNT(*) FROM shop_stock')] === [$nItems, $nRec, $nStock]);
chk('content: the two fight belts and the Tool Repair Kit exist; the belts are on Twigg\'s shelf; the kit has a recipe', item_id_by_slug('stitched-fight-belt') > 0 && item_id_by_slug('masterwork-fight-belt') > 0 && item_id_by_slug(PFD_REPAIR) > 0
    && (int)q_val("SELECT COUNT(*) FROM shop_stock ss JOIN items i ON i.id = ss.item_id WHERE i.slug IN ('stitched-fight-belt', 'masterwork-fight-belt')") === 2
    && (int)q_val('SELECT output_item_id FROM recipes WHERE slug = ?', [PFD_REPAIR]) === item_id_by_slug(PFD_REPAIR), [item_id_by_slug('stitched-fight-belt'), item_id_by_slug(PFD_REPAIR), q_val('SELECT COUNT(*) FROM recipes WHERE slug = ?', [PFD_REPAIR])]);
chk('the repair kit\'s ingredients are real items', (function () { foreach (json_decode((string)q_val('SELECT ingredients FROM recipes WHERE slug = ?', [PFD_REPAIR]), true) ?: ['x' => 1] as $slug => $n) if (!item_id_by_slug($slug)) return false; return true; })());
chk('placeholder art for the three new items', !array_filter(['stitched-fight-belt', 'masterwork-fight-belt', PFD_REPAIR], fn($s) => !is_file($G . '/assets/img/ph/' . $s . '.svg')));
q("DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE category = 'tool')", [$uid]); tool_cache_reset();
$d = pfd_deck($uid);
chk('a new gnome: no starter chosen, the default kit of 10, not locked, auto off, 2 belt slots', !$d['starter'] && count($d['deck']) === 10 && !$d['locked'] && !$d['auto'] && $d['slots'] === 2 && $d['belt_tier'] === 1 && $d['err'] === null, [count($d['deck']), $d['slots']]);
chk('pfd_deck carries the offer and no harmony meter', !isset($d['harmony']) && count($d['offer']) === 12);
chk('starter: 5 picks refused', pfd_set_starter($uid, array_slice($d['offer'], 0, 5)) === 'Pick exactly 6 pieces.');
chk('starter: an unknown kit refused', pfd_set_starter($uid, 'fancy') === 'There is no such kit.');
chk('starter: a piece that is not on offer refused, nothing saved', pfd_set_starter($uid, ['smash', 'jab', 'snack', 'hide', 'brace', 'hum']) !== null && (int)q_val('SELECT COUNT(*) FROM pf_deck_pieces WHERE user_id = ?', [$uid]) === 0);
chk('starter: the Kind kit is packed (10 rows, the chosen flag)', pfd_set_starter($uid, 'kind') === null && (int)q_val('SELECT COUNT(*) FROM pf_deck_pieces WHERE user_id = ? AND starter = 1', [$uid]) === 10 && (int)q_val('SELECT starter FROM pf_decks WHERE user_id = ?', [$uid]) === 1);
$d = pfd_deck($uid);
chk('the deck is now the chosen starter, in the order packed', $d['starter'] && array_column($d['deck'], 'key') === array_merge(PFD_CORE, $d['kits']['kind']), array_column($d['deck'], 'key'));
chk('starter: once only', pfd_set_starter($uid, 'bold') === 'You have already packed your first Puzzle box.');
chk('toggle: a piece you do not own is refused', pfd_toggle($uid, 'smash') === 'You do not own that piece.' && pfd_toggle($uid, 'c:tuber') === 'You do not own that piece.');
chk('toggle: a starter piece off (10 -> 9), and back on', pfd_toggle($uid, 'soothe') === null && count(pfd_deck($uid)['deck']) === 9 && pfd_toggle($uid, 'soothe', true) === null && count(pfd_deck($uid)['deck']) === 10);
pfd_toggle($uid, 'soothe', false); pfd_toggle($uid, 'hum', false);
chk('toggle: the kit may not drop under 8', pfd_toggle($uid, 'jab', false) === 'Pack at least 8 kit pieces.' && count(pfd_deck($uid)['deck']) === 8);
pfd_toggle($uid, 'soothe', true); pfd_toggle($uid, 'hum', true);
q('UPDATE users SET level = 9 WHERE id = ?', [$uid]);
chk('level 9: Pierce is owned (off), and can be switched on', pfd_toggle($uid, 'pierce', true) === null && in_array('pierce', array_column(pfd_deck($uid)['deck'], 'key'), true));
// sources from the game
$tomato = item_id_by_slug('tomato'); if ($tomato) q('INSERT INTO user_food_mastery (user_id, item_id, eaten, grown) VALUES (?, ?, 0, 3)', [$uid, $tomato]);
chk('crops: growing a tomato (a vegetable) gives Garden Greens, on by default', $tomato > 0 && in_array('c:vegetable', array_column(pfd_deck($uid)['deck'], 'key'), true), array_column(pfd_deck($uid)['deck'], 'key'));
$rid = (int)q_val('SELECT id FROM recipes WHERE slug = ?', [PFD_REPAIR]); q('INSERT INTO user_recipes (user_id, recipe_id, learned_at, made) VALUES (?, ?, ?, 2)', [$uid, $rid, now()]);
chk('crafts: making something in Garden supplies gives Compost Lob', in_array('k:garden', array_column(pfd_deck($uid)['deck'], 'key'), true));
q('INSERT INTO user_guides (user_id, guide_key, read_at) VALUES (?, ?, ?)', [$uid, 'region:MENA', now()]);
chk('regions: reading the Dunewhisper guide gives Heat Shimmer', in_array('r:MENA', array_column(pfd_deck($uid)['deck'], 'key'), true));
chk('toggle: an owned crop piece can be switched off again', pfd_toggle($uid, 'c:vegetable', false) === null && !in_array('c:vegetable', array_column(pfd_deck($uid)['deck'], 'key'), true));
// belt
$item('hatchet'); $item('worn-trowel'); $item('willow-fishing-rod'); tool_cache_reset();
$d = pfd_deck($uid);
chk('tools in the satchel: the belt (never set) takes the best two; their pieces are in the deck', $d['counts']['belt'] === 2 && count($d['belt']) === 2 && !array_diff(array_column($d['belt'], 'type'), ['axe', 'till', 'rod']), $d['belt']);
chk('equip: a tool you do not have is refused; something that is not a tool too', pfd_equip_tool($uid, 'lantern') === 'You do not have that tool.' && pfd_equip_tool($uid, 'spoon') === 'That is not a fight tool.');
$on = array_column($d['belt'], 'type'); $free = array_values(array_diff(['axe', 'till', 'rod'], $on))[0];
chk('equip: a full belt refuses a third tool', pfd_equip_tool($uid, $free) === 'Your belt is full (2 tools). Take one off first.');
chk('unequip, then equip the other one', pfd_unequip($uid, $on[0]) === null && pfd_equip_tool($uid, $free) === null && array_column(pfd_deck($uid)['belt'], 'type') === [$on[1], $free], array_column(pfd_deck($uid)['belt'], 'type'));
chk('equip into a slot: that slot\'s tool comes off', pfd_equip_tool($uid, $on[0], 0) === null && array_column(pfd_deck($uid)['belt'], 'type') === [$on[0], $free]);
chk('unequip: a tool that is not on the belt is refused', pfd_unequip($uid, $on[1]) === 'That tool is not on your belt.');
$item('stitched-fight-belt');
chk('the Stitched Fight Belt in the satchel at level 9: 3 slots, a third tool fits', pfd_belt_slots($re()) === 3 && pfd_equip_tool($uid, $on[1]) === null && pfd_deck($uid)['counts']['belt'] === 3);
$item('masterwork-fight-belt');
chk('the Masterwork belt needs level 18: still 3 slots at level 9', pfd_belt_slots($re()) === 3);
q('UPDATE users SET level = 18 WHERE id = ?', [$uid]); chk('at level 18: 4 slots', pfd_belt_slots($re()) === 4 && pfd_deck($uid)['slots'] === 4 && pfd_deck($uid)['belt_tier'] === 3);
q('UPDATE users SET level = 5 WHERE id = ?', [$uid]); chk('at level 5 neither belt counts: 2 slots, the third tool waits (state over)', pfd_belt_slots($re()) === 2 && array_column(pfd_deck($uid)['belt'], 'state')[2] === 'over' && pfd_deck($uid)['counts']['belt'] === 2);
q('UPDATE users SET level = 9 WHERE id = ?', [$uid]);
// wear, break, fix
chk('wear starts at 0 of 20 for a Worn tool', pfd_wear($uid)['axe'] == ['tier' => 1, 'max' => 20, 'wear' => 0, 'left' => 20, 'broken' => false], pfd_wear($uid)['axe'] ?? null);
chk('a fight\'s wear is saved (axe 6): 14 left, not broken', pfd_wear_add($uid, ['axe' => 6]) === [] && pfd_wear($uid)['axe']['left'] === 14);
$lines = pfd_end_fight($re(), ['wear' => ['axe' => 14, 'till' => 2]]);
chk('the wear that uses it up breaks the tool: a log line, and its piece leaves the deck', count($lines) === 1 && str_contains($lines[0], 'Chop') && pfd_wear($uid)['axe']['broken'] && !in_array('t:axe', array_column(pfd_deck($uid)['deck'], 'key'), true) && in_array('broken', array_column(pfd_deck($uid)['belt'], 'state'), true), $lines);
chk('a broken tool cannot be put on the belt', (function () use ($uid) { pfd_unequip($uid, 'axe'); return pfd_equip_tool($uid, 'axe'); })() === 'That tool is worn out. Fix it with a Tool Repair Kit first.');
chk('fix: needs a Tool Repair Kit', str_starts_with((string)pfd_fix($uid, 'axe'), 'You need a Tool Repair Kit'));
$item(PFD_REPAIR, 2);
chk('fix: one kit is used, the tool is whole again and can go back on the belt', pfd_fix($uid, 'axe') === null && pfd_wear($uid)['axe']['left'] === 20 && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, item_id_by_slug(PFD_REPAIR)]) === 1 && pfd_equip_tool($uid, 'axe') === null && in_array('t:axe', array_column(pfd_deck($uid)['deck'], 'key'), true));
chk('fix: a tool with no wear needs no fixing (no kit used)', pfd_fix($uid, 'axe') === 'That tool needs no fixing.' && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, item_id_by_slug(PFD_REPAIR)]) === 1);
// auto, post
chk('auto-use my current deck: remembered per gnome', pfd_set_auto($uid, true) === null && pfd_deck($uid)['auto'] === true && pfd_set_auto($uid, false) === null && pfd_deck($uid)['auto'] === false);
chk('POST actions: pfd_toggle, pfd_auto, pfd_unequip, pfd_equip, pfd_fix answer [ok, message]', pfd_post($re(), 'pfd_toggle', ['key' => 'c:vegetable', 'on' => '1']) === [true, 'Deck changed.'] && pfd_post($re(), 'pfd_auto', ['on' => '1'])[0] && pfd_post($re(), 'pfd_unequip', ['tool' => 'axe'])[0] && pfd_post($re(), 'pfd_equip', ['tool' => 'axe', 'slot' => '1'])[0] && pfd_post($re(), 'pfd_fix', ['tool' => 'nothing']) === [false, 'That tool needs no fixing.'] && pfd_post($re(), 'pfd_nope', []) === [false, 'Unknown action.']);
chk('POST pfd_starter: refused the second time', pfd_post($re(), 'pfd_starter', ['kit' => 'bold']) === [false, 'You have already packed your first Puzzle box.']);

echo "== 10. the fight hookup\n";
q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_open', '1')"); q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__');
if (!active_expedition($uid)) explore_start($re());
$exp = active_expedition($uid); $c = q_one("SELECT * FROM creatures WHERE slug = 'badger'");
$enc0 = ['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false];
$enc = $enc0; $s = pfight_state($re(), $exp, $enc, $c);
chk('flag = admin, a player: the old fight (old deck, archetype creature, no v1)', !isset($s['v1']) && count($s['me']['hand']) + count($s['me']['draw']) === count(pf_box(9, (string)$u['calling'], null)) && !array_filter(array_merge($s['foe']['hand'], $s['foe']['draw']), fn($t) => isset($t['layer'])), array_keys($s));
q("UPDATE users SET role = 'admin' WHERE id = ?", [$uid]);
$enc = $enc0; $s = pfight_state($re(), $exp, $enc, $c); $want = pfd_deck($uid); $mine = array_merge($s['me']['hand'], $s['me']['draw']); $foe = array_merge($s['foe']['hand'], $s['foe']['draw'], $s['foe']['discard'], array_column(array_filter($s['pcs'], fn($p) => $p['by'] === 'foe'), 'tile'));
$wk = array_map(fn($e) => $e['k'] === 'snack' && !in_array('snack', array_column($mine, 'k'), true) ? 'breather' : $e['k'], $want['deck']); $mk = array_column($mine, 'k'); sort($wk); sort($mk);
chk('flag = admin, an admin: the fight is dealt from the gnome\'s deck (' . count($mk) . ' pieces, tool pieces with their tool)', isset($s['v1']) && $mk === $wk && count(array_filter($mine, fn($t) => isset($t['tool']))) === $want['counts']['belt'], [$mk, $wk]);
$region = pfd_exp_region($exp);
chk('the creature is layered: Beast base 4 + the region\'s pieces (' . ($region ?: 'no region') . ') + Slam + the Badger\'s 3', count($foe) === 4 + ($region !== '' ? 2 : 0) + 1 + 3 && !array_diff(['Claw', 'Maul', 'Brace', 'Shoulder Barge', 'Slam', 'Dig In', 'Badger Maul', 'Bash Back'], array_column($foe, 'n')) && ($region === '' || in_array(pfd_region_pieces()[$region]['other']['n'], array_column($foe, 'n'), true)), array_column($foe, 'n'));
chk('the board is the large one (7x5)', $s['w'] === 7 && $s['h'] === 5);
$exp['encounter'] = json_encode($enc); save_exp($exp);
chk('during the fight the deck is locked: toggle, equip, unequip and starter are refused', pfd_locked($uid) && pfd_deck($uid)['locked'] && pfd_toggle($uid, 'soothe') === 'You are in a fight. The deck is locked until it is over.' && pfd_unequip($uid, 'axe') !== null && pfd_equip_tool($uid, 'rod') !== null && pfd_post($re(), 'pfd_toggle', ['key' => 'hum'])[0] === false);
chk('auto-use can still be changed during a fight (it is a setting, not the deck)', pfd_set_auto($uid, true) === null);
$enc['pf']['over'] = 'run'; $exp['encounter'] = json_encode($enc); save_exp($exp);
chk('the fight is over: unlimited swaps again', !pfd_locked($uid) && pfd_toggle($uid, 'soothe') === null && pfd_toggle($uid, 'soothe') === null);
$exp['encounter'] = null; save_exp($exp);
echo $bad ? "$bad FAILED\n" : "database checks: all ok\n";
exit($bad ? 1 : 0);

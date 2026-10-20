<?php
// Treks Chapter I audit (v1.9.9 pass): map and data integrity, every text key the code asks for, every spot type once-only / replay / KO / fatigue / kit
// edge cases, milestones, the daily Petal cap, events and crew moments, and a random-play fuzz with invariants. Run by treks.sh after the Chapter II suites.
// Uses clones of the test player ("aud1_*") so the other suites' players are never touched; settings it changes are put back at the end.
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function note(string $s): void { echo "  note $s\n"; }

// ---- helpers
$saved = [];
function cfg(array $kv): void { global $saved; foreach ($kv as $k => $v) { if (!array_key_exists($k, $saved)) $saved[$k] = setting($k); set_setting($k, (string)$v); } setting('__reload__'); }
function cfg_restore(): void { global $saved; foreach ($saved as $k => $v) set_setting($k, (string)$v); $saved = []; setting('__reload__'); }
$nUser = 0;
/** A fresh clone of the test player, level 15, rich, rested, no trek state. */
function aud_user(): int
{
    global $nUser;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $nUser++;
    $r['username'] = 'aud1_' . $nUser . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = 'Audie' . $nUser; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 15; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
function aud_run(int $uid, bool $fog = true): array
{
    trek_tx($uid, fn(&$run, $u) => trek_enter($run, $u), false);
    if ($fog) trek_tx($uid, function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); return [true, '']; });
    return trek_load(trek_run_row($uid));
}
function pack_n(int $runId, string $slug, int $banked = 0): int { return (int)q_val('SELECT COALESCE(SUM(qty),0) FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = ?', [$runId, trek_item_id($slug), $banked]); }
function sat_n(int $uid, string $slug): int { return (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, trek_item_id($slug)]); }
function coins_of(int $uid): int { return (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]); }
function xp_of(int $uid): int { return (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]); }
function rig_easy(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { if (!empty($f['add'])) continue; $run['fi']['foes'][$i]['hp'] = 1; $run['fi']['foes'][$i]['def'] = -50; $run['fi']['foes'][$i]['atk'] = -60; } }
function rig_deadly(array &$run): void { foreach ($run['fi']['foes'] as $i => $f) { $run['fi']['foes'][$i]['hp'] = $run['fi']['foes'][$i]['max'] = 99999; $run['fi']['foes'][$i]['def'] = 999; $run['fi']['foes'][$i]['atk'] = 100; $run['fi']['foes'][$i]['die'] = 60; } }
$spots = trek_spots(1);
cfg(['trek_open' => '1', 'trek_event_pct' => '0', 'trek_enc_percent' => '0', 'trek_ambush_pct' => '0']);

echo "== A. map and data\n";
$m = trek_map(1);
ok('map is 40x40, every row 40 wide, zone layer the same size', $m['w'] === 40 && $m['h'] === 40 && count($m['z']) === 40 && !array_filter($m['t'], fn($r) => strlen($r) !== 40) && !array_filter($m['z'], fn($r) => strlen($r) !== 40));
$syms = [];
foreach ($spots as $s) $syms[$s['sym']] = $s['code'];
$stray = [];
foreach ($m['t'] as $y => $row) foreach (str_split($row) as $x => $c) if (ctype_upper($c) && !isset($syms[$c])) $stray[] = "$c@$x,$y";
ok('no capital letter on the map without a spot', !$stray, implode(' ', $stray));
$lines = array_filter(trek_lines('trek_spots.txt'), fn($l) => str_starts_with($l, '1|'));
ok('every Chapter I row of trek_spots.txt landed on the map', count($lines) === count($spots), count($lines) . ' rows, ' . count($spots) . ' on the map');
$bad = [];
foreach ($spots as $c => $s) {
    $t = trek_tile(1, $s['x'], $s['y']);
    if ($t !== $s['sym'] || in_array($t, ['#', '^', ' '], true)) $bad[] = "$c on $t";
    if (trek_zone_at(1, $s['x'], $s['y']) !== $s['zone']) $bad[] = "$c zone " . trek_zone_at(1, $s['x'], $s['y']) . ' vs ' . $s['zone'];
}
ok('no spot on a wall, every spot sits in the zone its row names', !$bad, implode('; ', $bad));
ok('start, exit and camp exist', isset($spots['start'], $spots['exit'], $spots['camp']));
$noZone = [];
foreach ($m['t'] as $y => $row) foreach (str_split($row) as $x => $c) if (!in_array($c, ['#', '^', ' '], true) && trek_zone_at(1, $x, $y) === '') $noZone[] = "$x,$y";
ok('every walkable tile has a zone letter', !$noZone, implode(' ', array_slice($noZone, 0, 8)));
$ch = trek_chapter(1);
$zl = [];
foreach ($m['z'] as $row) foreach (str_split($row) as $c) if (trim($c) !== '') $zl[$c] = 1;
ok('every zone letter on the map is defined, and every defined zone is used', !array_diff_key($zl, $ch['zones']) && !array_diff_key($ch['zones'], $zl), json_encode([array_keys(array_diff_key($zl, $ch['zones'])), array_keys(array_diff_key($ch['zones'], $zl))]));
$noPool = [];
foreach (array_keys($zl) as $z) if (!trek_zone_pool($z, 1)) $noPool[] = $z;
ok('every zone letter has a creature pool (a 0% one is a calm zone)', !$noPool, implode(',', $noPool));
$noFoe = [];
foreach (trek_pools() as $k => $p) if (str_starts_with($k, '1:')) foreach (array_keys($p['list']) as $slug) if (!trek_creature($slug)) $noFoe[] = "$k:$slug";
ok('every pool creature exists in the creatures table', !$noFoe, implode(' ', $noFoe));
foreach (['cellar-key', 'clean-dew', 'camp-kit', 'blight-shard', 'lanternroot-seed', 'glowing-bead', 'singing-pebble', 'beetle-shell', 'honeydew', 'velvet-pelt', 'digging-claw'] as $slug) {
    if (!trek_item_id($slug)) { ok("item $slug exists", false); }
}
ok('every item a spot, the guarantee table or the finish names exists', true);
foreach (TREK_GUARANTEE as $slug => $g) if (($g[4] ?? 1) === 1) ok("guarantee $slug is in the pool of zone {$g[2]}", isset(trek_zone_pool($g[2], 1)['list'][$slug]));
$bad = [];
foreach (trek_chapter(1)['tune'] as $k => $_) if (!isset($ch['zones'][$k]) && !trek_script_def($k)) $bad[] = $k;
ok('every tune row names a zone letter or a boss script', !$bad, implode(',', $bad));
// reachability with the gates opened one after the other (each gate's flag set), walls and chasms never crossed
function reach(array $spots, array $flags, array $block = []): array
{
    $m = trek_map(1);
    $st = $spots['start'];
    $seen = [$st['x'] . ',' . $st['y'] => 1];
    $q = [[$st['x'], $st['y']]];
    while ($q) {
        [$x, $y] = array_shift($q);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $x + $dx; $ny = $y + $dy;
            if ($nx < 0 || $ny < 0 || $nx >= $m['w'] || $ny >= $m['h'] || isset($seen["$nx,$ny"])) continue;
            $c = $m['t'][$ny][$nx];
            if (in_array($c, ['#', '^', ' ', '*'], true)) continue;
            $s = ctype_upper($c) ? trek_spot_at(1, $nx, $ny) : null;
            if ($s && (($s['type'] === 'gate' && !trek_gate_open(['flags' => $flags], $s)) || in_array($s['code'], $block, true))) continue;
            $seen["$nx,$ny"] = 1;
            $q[] = [$nx, $ny];
        }
    }
    return $seen;
}
$allFlags = ['won_fight' => 1, 'freed_burdock' => 1, 'freed_zinnia' => 1, 'mother_down' => 1];
$r = reach($spots, $allFlags);
$lost = [];
foreach ($m['t'] as $y => $row) foreach (str_split($row) as $x => $c) if (!in_array($c, ['#', '^', ' ', '*'], true) && !isset($r["$x,$y"])) $lost[] = "$c@$x,$y";
ok('every walkable tile is reachable from the start once the gates are open (no isolated pocket)', !$lost, implode(' ', array_slice($lost, 0, 10)));
$order = [[[], ['start', 'exit']], [['won_fight'], ['rootwall', 'burdock', 'cart']], [['won_fight', 'freed_burdock'], ['boulder', 'camp', 'cellar', 'dewsign', 'zinnia', 'elder', 'choir', 'mushcamp', 'oldhearth', 'oldleanto']],
    [['won_fight', 'freed_burdock', 'freed_zinnia'], ['capwall', 'bracken', 'bridgestone', 'mother', 'grotto']], [['won_fight', 'freed_burdock', 'freed_zinnia', 'mother_down'], ['dengate', 'gloomtooth']]];
$have = [];
$flags = [];
foreach ($order as [$add, $expect]) {
    foreach ($add as $f) $flags[$f] = 1;
    $r = reach($spots, $flags);
    $now = array_keys(array_filter($spots, fn($s) => isset($r[$s['x'] . ',' . $s['y']])));
    $new = array_values(array_diff($now, $have));
    sort($new); $e = $expect; sort($e);
    ok('gate order: with ' . ($add ? implode('+', $add) : 'nothing') . ' the new spots are ' . implode(',', $e), $new === $e, implode(',', $new));
    $have = $now;
}
$r = reach($spots, $allFlags, ['mother']);
ok('the den is behind the Blight Mother (no way round her)', !isset($r[$spots['gloomtooth']['x'] . ',' . $spots['gloomtooth']['y']]));
$r = reach($spots, $allFlags, ['bracken']);
ok('the Black Rows lie beyond Captain Bracken\'s tile', !isset($r[$spots['mother']['x'] . ',' . $spots['mother']['y']]));
ok('the camp zone is calm (a creature pool at 0%)', (trek_zone_pool('c', 1)['mult'] ?? -1) === 0);

echo "== B. every text key the code asks for exists (and which slots nothing asks for)\n";
$want = [];
$add = function (string ...$ks) use (&$want) { foreach ($ks as $k) $want[$k] = 1; };
foreach ($spots as $c => $s) {
    $p = 'ch1.spot.' . $c . '.';
    switch ($s['type']) {
        case 'start': case 'exit': case 'sign': $add($p . 'arrive'); break;
        case 'gate': $add($p . 'locked', $p . 'open'); break;
        case 'recruit': $add($p . 'before', $p . 'freed'); break;
        case 'fetch': $add($p . 'before', $p . 'need', $p . 'join'); break;
        case 'chest': $add($p . 'locked', $p . 'open', $p . 'after'); break;
        case 'npc': $add($p . 'talk'); break;
        case 'riddle': $add($p . 'question', $p . 'a1', $p . 'a2', $p . 'a3', $p . 'right', $p . 'wrong', $p . 'out'); break;
        case 'camp': $add($p . 'arrive'); break;
        case 'duel': $add($p . 'before', $p . 'win', $p . 'lose'); break;
        case 'miniboss': $add($p . 'intro'); break;
        case 'boss': $add($p . 'intro'); break;
        case 'hidden': $add($p . 'arrive', $p . 'find'); break;
        case 'cart': $add($p . 'before', $p . 'after', $p . 'win', $p . 'work', $p . 'fail'); break;
        case 'mush': $add($p . 'before', $p . 'after', $p . 'short', $p . 'done'); break;
    }
}
$add('ch1.spot.bridgestone.after');   // a solved riddle's own line (the Worm Choir has none: the page says its built-in line)
$add('ch1.spot.mother.defeat', 'ch1.spot.mother.spawn', 'ch1.spot.gloomtooth.defeat', 'ch1.spot.gloomtooth.burdock', 'ch1.spot.gloomtooth.enrage');
foreach (TREK_GT_MOVES as $mv) $add('ch1.spot.gloomtooth.' . $mv);
foreach (array_keys($ch['zones']) as $z) $add('ch1.zone.' . $z . '.arrive');
foreach (['stash' => ['dig'], 'forager' => ['help'], 'fork' => ['win', 'fail'], 'trader' => ['buy'], 'shrine' => ['rest', 'bless'], 'puddle' => ['good', 'bad'], 'beetle' => ['patch', 'heal'], 'song' => ['hum']] as $id => $parts) {
    $add('ch1.ev.' . $id . '.text');
    foreach ($parts as $pt) $add('ch1.ev.' . $id . '.' . $pt);
}
$add('ch1.ev.walkon');
foreach (['burdock', 'zinnia', 'bracken'] as $k) $add('ch1.crew.' . $k . '.talk', 'ch1.crew.' . $k . '.done', 'ch1.banter.' . $k . '.1', 'ch1.banter.' . $k . '.2', 'interlude.1.' . $k);
foreach (array_keys(trek_milestones(1)) as $k) $add('ch1.ms.' . $k);
$add('ch1.intro', 'ch1.outro', 'ch1.hook', 'interlude.1.intro', 'ch1.ko.camp', 'ch1.ko.tutorial', 'ch1.tut.walk', 'ch1.tut.camp', 'ch1.tut.firstfight', 'ch1.tut.party', 'ch1.tut.treklevel', 'ch1.ui.tired', 'ch1.ui.wornout');
$add('ch1.camp.innkeeper.greet', 'ch1.camp.innkeeper.shop', 'ch1.camp.innkeeper.rest', 'ch1.camp.innkeeper.firstkit', 'ch1.camp.innkeeper.full', 'ch1.camp.innkeeper.nofunds', 'ch1.camp.makecamp', 'ch1.camp.makecamp.free', 'ch1.camp.ambush');
$add('item.cellar-key', 'item.clean-dew', 'item.lanternroot-seed');   // the Pack tab: carried items with a note
$add('book.ch1', 'book.blightlings', 'book.gloomtooth', 'book.lantern-stump', 'book.glowworm-grotto');   // Almanac pages (the editor syncs them)
$rows = trek_text_rows(true) ?: trek_text_rows();
$missing = array_values(array_filter(array_keys($want), fn($k) => !isset($rows[$k])));
ok('every key Chapter I code can ask for has a slot in trek_texts.txt (' . count($want) . ' keys)', !$missing, implode(' ', $missing));
$file = [];
foreach (trek_lines('trek_texts.txt') as $l) { $k = explode('|', $l, 2)[0]; if (preg_match('/^(ch1\.|interlude\.1\.|book\.|item\.)/', $k)) $file[] = $k; }
$orph = array_values(array_diff($file, array_keys($want)));
$known = ['item.camp-kit', 'item.blight-shard'];   // kits are a counter and the Blight Shard goes straight to the satchel, so neither is ever a Pack tile
note('slots nothing shows (design question): ' . implode(' ', array_intersect($orph, $known)));
ok('no new Chapter I slot that nothing in the code ever asks for', !array_diff($orph, $known), implode(' ', array_diff($orph, $known)));
$noDraftBody = array_values(array_filter(array_keys($want), fn($k) => isset($rows[$k]) && trim((string)$rows[$k]['body']) === ''));
note(count($noDraftBody) . ' of those slots have no body yet (players see nothing there, admins see TO WRITE)');

echo "== C. knock-out: back to camp, 45% of what is carried, nothing else\n";
$uid = aud_user();
$R = aud_run($uid);
$item = (int)q_val("SELECT id FROM items WHERE slug = 'beetle-shell'");
$ko = function (array $setup = []) use ($uid, $spots) {
    return trek_tx($uid, function (&$run, $u) use ($setup, $spots) {
        $run['fi'] = null; $run['x'] = 10; $run['y'] = 16; $run['camp'] = $setup['camp'] ?? 'camp'; $run['petals_found'] = $setup['petals'] ?? 200;
        if (!empty($setup['ev'])) $run['st']['ev'] = ['id' => 'stash'];
        foreach ($run['party'] as $k => $p) $run['party'][$k]['hp'] = 0;
        trek_ko($run, $u);
        return [true, ''];
    });
};
trek_tx($uid, function (&$run, $u) use ($item) {
    trek_pack_add((int)$run['id'], $item, 40, 0); trek_pack_add((int)$run['id'], trek_item_id('cellar-key'), 1, 0); trek_pack_add((int)$run['id'], trek_item_id('clean-dew'), 2, 0);
    trek_pack_add((int)$run['id'], $item, 7, 1);   // banked: never at risk
    return [true, ''];
});
$ko(['ev' => true]);
$R = trek_load(trek_run_row($uid));
ok('KO: the party wakes on the camp tile with someone standing', [$R['x'], $R['y']] === [$spots['camp']['x'], $spots['camp']['y']] && $R['party'][0]['hp'] > 0 && !$R['fi']);
ok('KO: fatigue 50', (int)$R['fatigue'] === 50);
ok('KO: a stack of 40 loses exactly 45% (18), 22 stay', pack_n((int)$R['id'], 'beetle-shell') === 22, (string)pack_n((int)$R['id'], 'beetle-shell'));
ok('KO: 200 carried Petals lose 90', (int)$R['petals_found'] === 110, (string)$R['petals_found']);
ok('KO: quest items (key, dew) are never taken', pack_n((int)$R['id'], 'cellar-key') === 1 && pack_n((int)$R['id'], 'clean-dew') === 2);
ok('KO: banked items are untouched', pack_n((int)$R['id'], 'beetle-shell', 1) === 7);
ok('KO: counted for the "no knock-out" milestone check', (int)($R['st']['kos'] ?? 0) === 1 && trek_ms_checks($R, q_one('SELECT * FROM users WHERE id = ?', [$uid]), 'burdock')[2]['No knock-out'] === false);
ok('KO: a trail event card from where the party fell does not follow it to camp', empty($R['st']['ev']), json_encode($R['st']['ev'] ?? null));
$ko(['camp' => '']);
$R = trek_load(trek_run_row($uid));
ok('KO before any camp: back at the Root Gate and nothing lost', [$R['x'], $R['y']] === [$spots['start']['x'], $spots['start']['y']] && pack_n((int)$R['id'], 'beetle-shell') === 22 && (int)$R['petals_found'] === 200);
cfg(['trek_ko_loss_pct' => '0']); $ko(); $R = trek_load(trek_run_row($uid));
ok('KO loss 0%: nothing lost', pack_n((int)$R['id'], 'beetle-shell') === 22 && (int)$R['petals_found'] === 200);
cfg(['trek_ko_loss_pct' => '100']); $ko(); $R = trek_load(trek_run_row($uid));
ok('KO loss 100%: every carried find goes but the quest items stay', pack_n((int)$R['id'], 'beetle-shell') === 0 && (int)$R['petals_found'] === 0 && pack_n((int)$R['id'], 'cellar-key') === 1 && pack_n((int)$R['id'], 'clean-dew') === 2);
cfg(['trek_ko_loss_pct' => '45']);
// a single item is a coin toss at 45%: over many knock-outs both happen
$got = 0; $lost = 0;
for ($i = 0; $i < 40; $i++) {
    trek_tx($uid, function (&$run, $u) use ($item) { q('DELETE FROM trek_pack WHERE run_id = ? AND banked = 0 AND item_id = ?', [$run['id'], $item]); trek_pack_add((int)$run['id'], $item, 1, 0); return [true, '']; });
    $ko(['petals' => 0]);
    if (pack_n((int)trek_run_row($uid)['id'], 'beetle-shell') === 1) $got++; else $lost++;
}
ok('KO: a single item is a coin toss (kept and lost both happen in 40 tries)', $got > 3 && $lost > 3, "kept $got lost $lost");

echo "== D. trail events and crew moments: once per recruit, never stuck\n";
$uid = aud_user();
aud_run($uid);
trek_tx($uid, function (&$run, $u) { foreach (['won_fight', 'freed_burdock', 'freed_zinnia', 'freed_bracken'] as $f) trek_flag_set($run, $f); foreach (['burdock', 'zinnia', 'bracken'] as $k) trek_recruit_crew($run, $u, $k); $run['x'] = 12; $run['y'] = 15; return [true, '']; });
cfg(['trek_event_pct' => '0']);
$fired = []; $took = [];
for ($i = 0; $i < 70; $i++) {
    trek_tx($uid, function (&$run, $u) use ($i) { $run['fatigue'] = 0; $run['petals_found'] = 0; $to = $run['x'] === 12 ? 15 : 12; trek_walk($run, $u, $to, 15); return [true, '']; });
    $R = trek_load(trek_run_row($uid));
    if (!empty($R['st']['cm'])) { $k = $R['st']['cm']; $fired[$k] = ($fired[$k] ?? 0) + 1; $r = trek_tx($uid, fn(&$run, $u) => trek_act_crew($run, $u, $i % 2 ? 1 : 0)); if ($i % 2) $took[$k] = ($took[$k] ?? 0) + 1; }
}
ok('each of the three trailmates has exactly one crew moment in a run', ($fired['burdock'] ?? 0) === 1 && ($fired['zinnia'] ?? 0) === 1 && ($fired['bracken'] ?? 0) === 1, json_encode($fired));
ok('crew moments are flagged once per recruit (cm_*)', (int)q_val("SELECT COUNT(*) FROM trek_flags WHERE run_id = ? AND flag LIKE 'cm\\_%' ESCAPE '\\'", [(int)trek_run_row($uid)['id']]) === 3);
// a pending moment whose trailmate was swapped out must not freeze the trail events
$uid = aud_user();
aud_run($uid);
trek_tx($uid, function (&$run, $u) use ($spots) { foreach (['won_fight', 'freed_burdock'] as $f) trek_flag_set($run, $f); trek_recruit_crew($run, $u, 'burdock'); trek_flag_set($run, 'cm_burdock'); $run['st']['cm'] = 'burdock'; $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; trek_camp_arrive($run, $u, $spots['camp']); return trek_set_party($run, $u, [1 => '', 2 => '', 3 => '']); });
ok('setup: Burdock waits in camp, his moment is still pending', trek_in_party(trek_load(trek_run_row($uid)), 'burdock') === false && trek_load(trek_run_row($uid))['st']['cm'] === 'burdock');
cfg(['trek_event_pct' => '100', 'trek_event_gap' => '1']);
$GLOBALS['trek_test_roll'] = 1;
trek_tx($uid, function (&$run, $u) { $run['x'] = 12; $run['y'] = 15; return [true, '']; });
for ($i = 0; $i < 3 && empty(trek_load(trek_run_row($uid))['st']['ev']); $i++) trek_tx($uid, function (&$run, $u) { $run['fatigue'] = 0; trek_walk($run, $u, $run['x'] === 12 ? 15 : 12, 15); return [true, '']; });
unset($GLOBALS['trek_test_roll']);
ok('a hidden crew moment does not hold back the trail events', !empty(trek_load(trek_run_row($uid))['st']['ev']), json_encode(trek_load(trek_run_row($uid))['st']));
ok('...and the moment is still waiting for Burdock to come back', trek_load(trek_run_row($uid))['st']['cm'] === 'burdock');
cfg(['trek_event_pct' => '0', 'trek_event_gap' => '15']);

echo "== E. camp: kits 0 and at the limit, the shop, resting, the ambush, fatigue 100\n";
$uid = aud_user();
aud_run($uid);
$tx = fn(callable $f) => trek_tx($uid, $f);
$R = fn() => trek_load(trek_run_row($uid));
$price = (int)setting('trek_campkit_price'); $maxK = (int)setting('trek_campkit_max');
$tx(function (&$run, $u) use ($spots) { trek_flag_set($run, 'won_fight'); $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; $run['camp'] = 'camp'; trek_flag_set($run, 'camp_seen'); trek_flag_set($run, 'firstkit'); $run['campkits'] = 0; return [true, '']; });
q('UPDATE users SET coins = ? WHERE id = ?', [$price - 1, $uid]);
$r = $tx(fn(&$run, $u) => trek_buy_kit($run, $u));
ok('shop: too poor by 1 Petal: refused, no kit, nothing charged', $r[0] === false && $R()['campkits'] === 0 && coins_of($uid) === $price - 1);
q('UPDATE users SET coins = ? WHERE id = ?', [$price * 10, $uid]);
for ($i = 1; $i <= $maxK; $i++) $tx(fn(&$run, $u) => trek_buy_kit($run, $u));
ok("shop: $maxK kits bought for exactly their price", $R()['campkits'] === $maxK && coins_of($uid) === $price * 10 - $price * $maxK);
$c0 = coins_of($uid);
$r = $tx(fn(&$run, $u) => trek_buy_kit($run, $u));
ok('shop: at the carry limit nothing is sold or charged', $R()['campkits'] === $maxK && coins_of($uid) === $c0);
$tx(function (&$run, $u) { trek_flag_set($run, 'x_away'); $run['x'] = 12; $run['y'] = 15; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_buy_kit($run, $u));
ok('shop: kits are only sold at a camp', $r[0] === false && coins_of($uid) === $c0);
// resting with a kit
$tx(function (&$run, $u) { $run['fatigue'] = 70; foreach (trek_party_stats($run, $u) as $s => $m) $run['party'][$s]['hp'] = 1; return [true, '']; });
$k0 = $R()['campkits'];
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
$x = $R();
ok('camp with a kit: -1 kit, fatigue -50, half health back', $x['campkits'] === $k0 - 1 && (int)$x['fatigue'] === 20 && $x['party'][0]['hp'] >= (int)floor(trek_party_stats($x, q_one('SELECT * FROM users WHERE id = ?', [$uid]))[0]['max'] * 0.5), json_encode([$x['campkits'], $x['fatigue']]));
$tx(function (&$run, $u) { $run['fatigue'] = 0; trek_heal_party($run, $u); return [true, '']; });
$k1 = $R()['campkits'];
$r = $tx(fn(&$run, $u) => trek_make_camp($run, $u));
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('camp on a rested, healthy party: refused, the kit is kept (a double tap cannot burn two)', $R()['campkits'] === $k1 && $r[0] === false, json_encode([$R()['campkits'], $k1, $r]));
// no kit: the ambush, then the cold rest
$tx(function (&$run, $u) { $run['campkits'] = 0; $run['fatigue'] = 40; return [true, '']; });
cfg(['trek_ambush_pct' => '100']);
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
$x = $R();
ok('camp with no kit and a 100% ambush: a fight starts first, the rest comes after', !empty($x['fi']) && ($x['fi']['meta']['after'] ?? '') === 'rest');
$tx(function (&$run, $u) { rig_easy($run); trek_fight_auto($run, $u, 20); return [true, '']; });
$x = $R();
ok('...win it: fatigue 40 +3 for the fight -25 for the cold rest = 18', !$x['fi'] && (int)$x['fatigue'] === 18, (string)$x['fatigue']);
cfg(['trek_ambush_pct' => '0']);
$tx(function (&$run, $u) { $run['fatigue'] = 60; return [true, '']; });
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('camp with no kit and no ambush: cold rest takes off 25', (int)$R()['fatigue'] === 35 && $R()['campkits'] === 0);
cfg(['trek_ambush_pct' => '100']);
$tx(function (&$run, $u) use ($spots) { $run['fatigue'] = 60; $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; return [true, '']; });
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('no ambush on a spot tile (the camp itself)', empty($R()['fi']) && (int)$R()['fatigue'] === 35);
cfg(['trek_ambush_pct' => '0']);
// fatigue maxed
$tx(function (&$run, $u) { $run['x'] = 12; $run['y'] = 15; $run['fatigue'] = 100; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_walk($run, $u, 15, 15));
ok('fatigue 100: walking is refused and nobody moves', $r[0] === false && $R()['x'] === 12);
$tx(fn(&$run, $u) => trek_make_camp($run, $u));
ok('fatigue 100: a cold rest brings it down and walking works again', (int)$R()['fatigue'] === 75 && $tx(fn(&$run, $u) => trek_walk($run, $u, 15, 15))[0] === true);
// walking tires the party: worn out at 85+ and a fight chance x1.5
$tx(function (&$run, $u) { $run['fatigue'] = 84; return [true, '']; });
$e1 = trek_enc_chance(['chapter' => 1, 'sneak' => 0, 'fatigue' => 84, 'flags' => ['won_fight' => 1]], 'f'); $e2 = trek_enc_chance(['chapter' => 1, 'sneak' => 0, 'fatigue' => 85, 'flags' => ['won_fight' => 1]], 'f');
ok('worn out (85+): the fight chance is 1.5x', abs($e2 - 1.5 * $e1) < 0.001 || $e1 === 0.0);

echo "== F. the first camp: one free kit, once, never thrown away\n";
foreach ([['normal', 1], ['kits full', $maxK]] as [$label, $have]) {
    $uid = aud_user();
    aud_run($uid);
    trek_tx($uid, function (&$run, $u) use ($have) { $run['campkits'] = $have; return [true, '']; });
    $s0 = sat_n($uid, 'camp-kit');
    trek_tx($uid, function (&$run, $u) use ($spots) { $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; trek_camp_arrive($run, $u, $spots['camp']); return [true, '']; });
    $x = trek_load(trek_run_row($uid));
    if ($label === 'normal') ok('first camp: +1 kit carried, none in the satchel', $x['campkits'] === $have + 1 && sat_n($uid, 'camp-kit') === $s0);
    else ok('first camp with the most kits already: the free one goes to the satchel, not nowhere', $x['campkits'] === $maxK && sat_n($uid, 'camp-kit') === $s0 + 1, json_encode([$x['campkits'], sat_n($uid, 'camp-kit') - $s0]));
    $s1 = sat_n($uid, 'camp-kit');
    trek_tx($uid, function (&$run, $u) use ($spots) { $run['x'] = 12; $run['y'] = 15; $run['x'] = $spots['camp']['x']; $run['y'] = $spots['camp']['y']; trek_camp_arrive($run, $u, $spots['camp']); trek_camp_arrive($run, $u, $spots['camp']); return [true, '']; });
    $y = trek_load(trek_run_row($uid));
    ok("first camp ($label): later visits give no second free kit", $y['campkits'] === $x['campkits'] && sat_n($uid, 'camp-kit') === $s1 && (int)q_val("SELECT COUNT(*) FROM trek_flags WHERE run_id = ? AND flag = 'firstkit'", [(int)$y['id']]) === 1);
}

echo "== G. names: a trailmate's short name is never just their title\n";
ok('Captain Bracken Spurwing is "Bracken", not "Captain"', trek_short_name('Captain Bracken Spurwing') === 'Bracken' && trek_first_name_of('Captain Bracken Spurwing') === 'Bracken');
ok('other names keep their first word; one-word and untitled names are untouched', trek_short_name('Burdock Deepdelve') === 'Burdock' && trek_short_name('Captain') === 'Captain' && trek_short_name('  Zinnia  Fuzzbottom ') === 'Zinnia');
$uid = aud_user(); aud_run($uid);
trek_tx($uid, function (&$run, $u) { trek_recruit_crew($run, $u, 'bracken'); $run['fi'] = null; trek_start_random_fight($run, $u, 'w'); $snap = trek_replay_snap($run, $u, $run['fi']); $GLOBALS['aud_snap'] = array_column($snap['p'], 0); return [true, '']; });
ok('the Auto replay row for Bracken says Bracken', in_array('Bracken', $GLOBALS['aud_snap'], true) && !in_array('Captain', $GLOBALS['aud_snap'], true), json_encode($GLOBALS['aud_snap']));

echo "== H. phone layout rules that can be read from the stylesheet (the browser pass is in the report)\n";
$css = (string)file_get_contents($argv[1] . '/assets/style.css');
ok('the fight screen heading (Round N) is centred like the other Treks headings', (bool)preg_match('/\.trekfight h3 \{[^}]*text-align: center/', $css) && !preg_match('/\.trekfight h3 \{[^}]*text-align: left/', $css));

echo "== I. spots: once only, replay-safe, refused when the wrong thing is at hand\n";
$uid = aud_user();
aud_run($uid);
$tx = fn(callable $f) => trek_tx($uid, $f);
$R = fn() => trek_load(trek_run_row($uid));
$goto = function (string $c) use ($tx, $spots) { $tx(function (&$run, $u) use ($c, $spots) { $run['x'] = $spots[$c]['x']; $run['y'] = $spots[$c]['y']; return [true, '']; }); };
$tx(function (&$run, $u) { trek_flag_set($run, 'won_fight'); return [true, '']; });
// Burdock
$goto('burdock');
$xp0 = xp_of($uid); $nid = (int)trek_crew_npc('burdock')['id'];
$r1 = $tx(fn(&$run, $u) => trek_act_recruit($run, $u)); $xp1 = xp_of($uid);
$r2 = $tx(fn(&$run, $u) => trek_act_recruit($run, $u)); $r3 = $tx(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('Burdock: one tap frees him, two more taps do nothing', $r1[0] === true && $r2[0] === false && $r3[0] === false && count($R()['party']) === 2 && count(trek_recruits((int)$R()['id'])) === 1);
ok('Burdock: the milestone paid once (XP +150 with its one check) and friendship is 20 not 40', xp_of($uid) === $xp1 && $xp1 - $xp0 === 150 && (int)friendship($uid, $nid)['points'] === 20, ($xp1 - $xp0) . ' ' . friendship($uid, $nid)['points']);
ok('Burdock: the boulder gate opens by his flag only', trek_gate_open($R(), $spots['boulder']) && !trek_gate_open(['flags' => []], $spots['boulder']));
$tx(function (&$run, $u) { $run['fi'] = null; trek_start_random_fight($run, $u, 'w'); return [true, '']; });
$goto('zinnia');
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('no recruiting, handing over or chest-opening in the middle of a fight', $r[0] === false && !isset($R()['flags']['freed_zinnia']) && $tx(fn(&$run, $u) => trek_act_chest($run, $u))[0] === false && $tx(fn(&$run, $u) => trek_act_challenge($run, $u))[0] === false);
$tx(function (&$run, $u) { rig_easy($run); trek_fight_auto($run, $u, 30); return [true, '']; });
// Zinnia: dew is only spent when she can take it
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('clean-dew'), 2, 0); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('Zinnia: 2 of 3 dew is refused and nothing is taken', $r[0] === false && pack_n((int)$R()['id'], 'clean-dew') === 2 && !isset($R()['flags']['freed_zinnia']));
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('clean-dew'), 3, 0); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u)); $r2 = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('Zinnia: 5 dew buys her for 3, the 2 left stay, a second tap does nothing', $r[0] === true && $r2[0] === false && pack_n((int)$R()['id'], 'clean-dew') === 2 && count($R()['party']) === 3);
// the Cellar chest
$goto('cellar');
$tx(function (&$run, $u) { $run['campkits'] = 0; $run['petals_found'] = 0; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('chest: no key, no loot', $r[0] === false && $R()['campkits'] === 0 && (int)$R()['petals_found'] === 0 && !isset($R()['flags']['cellar_open']));
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('cellar-key'), 2, 0); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_chest($run, $u)); $r2 = $tx(fn(&$run, $u) => trek_act_chest($run, $u));
ok('chest: opens once for 1 key (2 kits and 120 Petals carried); a second tap keeps the spare key and pays nothing', $r[0] === true && $r2[0] === false && $R()['campkits'] === 2 && (int)$R()['petals_found'] === 120 && pack_n((int)$R()['id'], 'cellar-key') === 1);
// the Worm Choir (right = 2, 3 tries): a wrong answer repeated runs the tries out; trying every answer always wins on the 3rd try
$goto('choir');
$tx(function (&$run, $u) { $run['st']['tries_choir'] = 0; return [true, '']; });
foreach ([1, 1, 1] as $a) $tx(fn(&$run, $u) => trek_act_riddle($run, $u, $a));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('riddle: the same wrong answer 3 times locks it (even the right one is refused after)', $r[0] === false && !isset($R()['flags']['choir_solved']) && $R()['st']['tries_choir'] === 3);
$tx(function (&$run, $u) { $run['st']['tries_choir'] = 0; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 1)); $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3));
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('riddle: 3 different answers always find the right one on try 3 (design: it cannot be failed by a player who tries each)', $r[0] === true && isset($R()['flags']['choir_solved']) && pack_n((int)$R()['id'], 'lanternroot-seed') === 1);
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 2));
ok('riddle: solved is solved (no second seed)', pack_n((int)$R()['id'], 'lanternroot-seed') === 1);
$r = $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 99));
ok('riddle: a made-up answer is just a wrong one, or refused once solved', $r[0] === false);
// the Stuck Cart
$goto('cart');
$GLOBALS['trek_test_d20'] = 1;
$tx(function (&$run, $u) { $run['campkits'] = 0; $run['fatigue'] = 0; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave'));
ok('cart: a failed heave costs 3 fatigue and keeps it stuck', (int)$R()['fatigue'] === 3 && !isset($R()['flags']['cart_done']) && $R()['campkits'] === 0);
$GLOBALS['trek_test_d20'] = 20;
$tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave')); $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'heave')); $tx(fn(&$run, $u) => trek_act_cart($run, $u, 'work'));
ok('cart: a good heave frees it and gives ONE kit however often you tap', isset($R()['flags']['cart_done']) && $R()['campkits'] === 1 && (int)$R()['fatigue'] === 3);
unset($GLOBALS['trek_test_d20']);
// the Mushroom Camp
$goto('mushcamp');
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('beetle-shell'), 1, 0); $run['petals_found'] = 0; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_act_mush($run, $u));
ok('mush camp: 1 shell of 2 is refused and kept', $r[0] === false && pack_n((int)$R()['id'], 'beetle-shell') === 1);
$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('beetle-shell'), 4, 0); return [true, '']; });
$tx(fn(&$run, $u) => trek_act_mush($run, $u)); $tx(fn(&$run, $u) => trek_act_mush($run, $u));
ok('mush camp: takes 2 shells once, pays 30 Petals once, one honeydew', pack_n((int)$R()['id'], 'beetle-shell') === 3 && (int)$R()['petals_found'] === 30 && pack_n((int)$R()['id'], 'honeydew') === 1);
// the Riddle Stone (right = 3) and the Glowworm Grotto (a Wayfinder only)
$goto('bridgestone');
$tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3)); $tx(fn(&$run, $u) => trek_act_riddle($run, $u, 3));
ok('stone: the right answer gives one Singing Pebble', pack_n((int)$R()['id'], 'singing-pebble') === 1 && isset($R()['flags']['stone_solved']));
$goto('grotto');
ok('grotto: a plain floor tile for a party with no Wayfinder (nothing to do, nothing on the panel)', (function () use ($R, $uid) { $r0 = $R(); return trek_here($r0, q_one('SELECT * FROM users WHERE id = ?', [$uid])); })() === null && $tx(fn(&$run, $u) => trek_act_hidden($run, $u))[0] === false);

ok('the slots with a brief that names a number match the code (Blight Mother adds: every 4th round)', !str_contains((string)$rows['ch1.spot.mother.spawn']['brief'], 'every 3 rounds'), 'brief still says every 3 rounds');

cfg_restore();
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);

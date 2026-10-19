<?php
// Treks v1.8.6: tactics + the Auto AI. Run on an installed copy: php tests/trek_tactics.php GAME_DIR  (treks.sh does).
// The old hard-coded AI is ported below as the reference: with default tactics the new AI must choose exactly the same.
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }

// ---- the old trek_fight_ai() (v1.8.5), kept as the reference
function trek_fight_ai_old(array &$run, array $u): array
{
    $stats = trek_party_stats($run, $u);
    $fi = $run['fi'];
    $acts = [];
    $boss = trek_boss_moves($fi);
    $big = $boss && in_array($boss[0], ['burst', 'quake'], true);
    $foesOk = trek_targetable_foes($fi);
    $weak = $foesOk ? trek_foe_target($fi, '') : null;
    foreach ($stats as $slot => $m) {
        if ((int)$run['party'][$slot]['hp'] <= 0) continue;
        $cd = (int)($fi['mem'][$slot]['cd'] ?? 0);
        $a = ['a' => 'attack', 't' => $weak !== null ? 'f:' . $weak : ''];
        if (!$foesOk) $a = ['a' => 'guard'];
        $lowest = null;
        foreach ($stats as $s2 => $m2) {
            $hp = (int)$run['party'][$s2]['hp'];
            if ($hp > 0 && ($lowest === null || $hp / $m2['max'] < (int)$run['party'][$lowest]['hp'] / $stats[$lowest]['max'])) $lowest = $s2;
        }
        if ($slot === 0 && (int)$run['party'][0]['hp'] * 100 < $m['max'] * 40 && !empty($snacks = fight_snacks($u)) && (int)$fi['snacks'] < snack_limit($u)) {
            $a = ['a' => 'snack', 'item' => $snacks[0]['id']];
        } elseif ($m['calling'] === 'bloomcaller' && $cd === 0 && $lowest !== null && (int)$run['party'][$lowest]['hp'] * 100 < $stats[$lowest]['max'] * 40) {
            $a = ['a' => 'ability', 't' => 'a:' . $lowest];
        } elseif ($m['calling'] === 'rootwarden' && $cd === 0 && ($big || $boss === null && count($foesOk) >= 2)) {
            $a = ['a' => 'ability', 't' => 'a:' . ($lowest ?? $slot)];
        } elseif ($m['calling'] === 'seedkeeper' && $cd === 0 && count($foesOk) >= 2) {
            $a = ['a' => 'ability'];
        } elseif (in_array($m['calling'], ['thornblade', 'wayfinder', 'brewroot', ''], true) && $cd === 0 && $foesOk) {
            $a = ['a' => 'ability', 't' => 'f:' . $weak];
        }
        $acts[$slot] = $a;
    }
    return $acts;
}


$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$U = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$U['level'] = 16;
$snackId = (int)q_val("SELECT i.id FROM items i JOIN recipes r ON r.output_item_id = i.id WHERE r.category = 'cooking' AND r.tier = 'snack' AND i.edible = 1 AND i.slug NOT LIKE 'bought-%' ORDER BY i.id LIMIT 1");
if ($snackId) give_item($uid, $snackId, 5);
$haveSnacks = (bool)fight_snacks($U);
$UNo = $U; $UNo['id'] = 999999;   // a gnome with no snacks
echo "== setup\n";
ok('a snack exists for the snack tests', $haveSnacks);

const CREW = [1 => 'zinnia', 2 => 'burdock', 3 => 'bracken'];   // bloomcaller, rootwarden, thornblade
function foe(int $hp, int $max = 20, array $o = []): array
{
    return $o + ['slug' => 'x', 'name' => 'Aphid', 'size' => 'small', 'lv' => 5, 'hp' => $hp, 'max' => $max, 'atk' => 2, 'def' => 10, 'die' => 4, 'bonus' => 0, 'xp' => 1, 'cid' => 1, 'pz' => 0, 'under' => 0, 'add' => 0, 'blight' => 0, 'icon' => '🐛'];
}
/**
 * A fight state. $mem = slot => [hp fraction, cd, bark]; slot 0 is the gnome, 1-3 the trailmates (CREW). $o: gcalling, round, script, duel, snacks, tac, user.
 * Returns [run, user].
 */
function mk(array $mem, array $foes, array $o = []): array
{
    global $U;
    $u = $o['user'] ?? $U;
    $u['calling'] = $o['gcalling'] ?? '';
    $run = ['id' => 0, 'fatigue' => 0, 'chapter' => 1, 'st' => ['tac' => $o['tac'] ?? []], 'party' => [], 'fi' => null];
    foreach ($mem as $slot => $_) $run['party'][$slot] = ['crew_key' => $slot === 0 ? 'gnome' : CREW[$slot], 'hp' => 9999];
    $stats = trek_party_stats($run, $u);
    $fm = [];
    foreach ($mem as $slot => $m) {
        $run['party'][$slot]['hp'] = (int)round($stats[$slot]['max'] * $m[0]);
        $fm[$slot] = ['bark' => $m[2] ?? 0, 'cd' => $m[1] ?? 0, 'guard' => 0, 'pz' => 0];
    }
    $run['fi'] = ['round' => $o['round'] ?? 2, 'foes' => array_values($foes), 'mem' => $fm, 'snacks' => $o['snacks'] ?? 0,
        'meta' => ['kind' => 'random', 'zone' => '', 'spot' => null, 'script' => $o['script'] ?? '', 'duel' => $o['duel'] ?? 0, 'after' => '']];
    return [$run, $u];
}
function ai(array $mem, array $foes, array $o = []): array { [$run, $u] = mk($mem, $foes, $o); return trek_fight_ai($run, $u); }

/** Would the round accept this? (shape, cooldown, targets) */
function valid_acts(array $run, array $u, array $acts): string
{
    $stats = trek_party_stats($run, $u);
    $fi = $run['fi'];
    $foes = trek_targetable_foes($fi);
    foreach ($stats as $slot => $m) {
        $alive = (int)$run['party'][$slot]['hp'] > 0;
        if (!$alive) { if (isset($acts[$slot])) return "dead $slot has a move"; continue; }
        if (!isset($acts[$slot])) return "living $slot has no move";
        $a = $acts[$slot];
        $kind = $a['a'] ?? '';
        $t = (string)($a['t'] ?? '');
        $ab = TREK_ABILITIES[$m['calling']] ?? TREK_ABILITIES[''];
        if (!in_array($kind, ['attack', 'ability', 'snack', 'guard'], true)) return "bad kind $kind";
        if ($kind === 'attack' && !(preg_match('/^f:(\d+)$/', $t, $mm) && in_array((int)$mm[1], $foes, true))) return "attack target '$t' ($slot)";
        if ($kind === 'ability') {
            if ((int)$fi['mem'][$slot]['cd'] > 0) return "ability on cooldown ($slot)";
            if ($ab[2] === 'foe' && !(preg_match('/^f:(\d+)$/', $t, $mm) && in_array((int)$mm[1], $foes, true))) return "ability foe target '$t' ($slot)";
            if ($ab[2] === 'ally' && !(preg_match('/^a:(\d+)$/', $t, $mm) && (int)($run['party'][(int)$mm[1]]['hp'] ?? 0) > 0)) return "ability ally target '$t' ($slot)";
            if ($ab[2] === 'none' && !$foes) return "spores with no foe ($slot)";
        }
        if ($kind === 'snack' && ($slot !== 0 || empty($a['item']))) return 'bad snack';
    }
    return '';
}

// ------------------------------------------------------------------ random states
function rnd_state(bool $plain): array
{
    global $U, $UNo;
    $callings = ['', 'rootwarden', 'bloomcaller', 'thornblade', 'seedkeeper', 'wayfinder', 'brewroot'];
    $g = $callings[array_rand($callings)];
    $n = random_int(1, 4);
    $slots = [0];
    $pool = [1, 2, 3];
    shuffle($pool);
    foreach (array_slice($pool, 0, $n - 1) as $s) $slots[] = $s;
    sort($slots);
    if ($plain && $g === 'bloomcaller' && in_array(1, $slots, true)) $g = 'thornblade';   // two healers / two Bark Skins are conflict cases: tested apart
    if ($plain && $g === 'rootwarden' && in_array(2, $slots, true)) $g = 'thornblade';
    $mem = [];
    foreach ($slots as $s) {
        $r = random_int(1, 10);
        $frac = $r <= 1 ? 0.0 : (random_int(1, 100) / 100);
        $mem[$s] = [$frac, random_int(0, 3) === 0 ? random_int(1, 3) : 0, ($plain || random_int(0, 3) > 0) ? 0 : random_int(1, 3)];
    }
    if (!array_filter($mem, fn($m) => $m[0] > 0)) $mem[0][0] = 0.5;
    $foes = [];
    $nf = random_int(0, 4);
    for ($i = 0; $i < $nf; $i++) {
        $max = random_int(5, 60);
        $foes[] = foe(random_int(0, 3) === 0 ? 0 : random_int(1, $max), $max, ['under' => random_int(0, 5) === 0 ? 1 : 0, 'pz' => ($plain || random_int(0, 2) > 0) ? 0 : random_int(1, 3), 'add' => random_int(0, 6) === 0 ? 1 : 0]);
    }
    $script = ['', '', 'gloomtooth', 'blight-mother'][random_int(0, 3)];
    $duel = random_int(0, 7) === 0 ? 1 : 0;
    $o = ['gcalling' => $g, 'round' => random_int(1, 9), 'script' => $script, 'duel' => $duel, 'snacks' => random_int(0, 3), 'user' => random_int(0, 1) ? $U : $UNo];
    return [$mem, $foes, $o];
}

echo "== defaults reproduce the old AI\n";
$bad = 0; $n = 0; $kinds = [];
for ($i = 0; $i < 2500; $i++) {
    [$mem, $foes, $o] = rnd_state(true);
    [$run, $u] = mk($mem, $foes, $o);
    $old = trek_fight_ai_old($run, $u);
    $new = trek_fight_ai($run, $u);
    $n++;
    foreach ($new as $a) $kinds[$a['a'] . (isset($a['t']) ? ':' . $a['t'][0] : '')] = 1;
    if ($old != $new) { if ($bad++ < 3) echo '   DIFF ' . json_encode($old) . ' vs ' . json_encode($new) . ' state ' . json_encode([$mem, $o['gcalling'], $o['round'], $o['script'], $o['duel'], array_map(fn($f) => [$f['hp'], $f['under']], $foes)]) . "\n"; }
}
ok("new AI == old AI on $n random states (bosses, duels, underground, down members, cooldowns)", $bad === 0, "$bad differ");
ok('the random states covered snack, attack, ability on foes and allies', isset($kinds['snack']) && isset($kinds['attack:f']) && isset($kinds['ability:f']) && isset($kinds['ability:a']) && isset($kinds['ability']) && isset($kinds['guard']), implode(',', array_keys($kinds)));

echo "== every move is one the round accepts (conflict cases included)\n";
$bad = 0;
for ($i = 0; $i < 2500; $i++) {
    [$mem, $foes, $o] = rnd_state(false);
    // random tactics too
    $tac = [];
    foreach (['gnome', 'zinnia', 'burdock', 'bracken'] as $k) $tac[$k] = ['open' => ['auto', 'ability', 'attack', 'guard', 'zz'][random_int(0, 4)], 'rule' => ['auto', 'big', 'foes2', 'friendlow', 'ready', 'foes3', 'healthy', 'boss', 'heal', 'x'][random_int(0, 9)], 'pct' => [30, 40, 50, 60, 77][random_int(0, 4)], 'shield' => ['lowest', 'self', 'gnome'][random_int(0, 2)], 'target' => ['weak', 'strong', 'focus'][random_int(0, 2)], 'snack' => [30, 40, 50][random_int(0, 2)]];
    $o['tac'] = $tac;
    [$run, $u] = mk($mem, $foes, $o);
    $acts = trek_fight_ai($run, $u);
    $why = valid_acts($run, $u, $acts);
    if ($why !== '' && $bad++ < 3) echo "   INVALID: $why " . json_encode($acts) . "\n";
}
ok('2500 random states with random tactics: no refused move', $bad === 0, "$bad bad");

echo "== tactics are cleaned\n";
$d = trek_tac_clean('bloomcaller', false, []);
ok('defaults: open auto, heal line 40, weak', $d['open'] === 'auto' && $d['pct'] === 40 && $d['target'] === 'weak' && $d['rule'] === 'heal');
$c = trek_tac_clean('thornblade', false, ['open' => 'dance', 'rule' => 'heal', 'pct' => 99, 'target' => ['x'], 'snack' => 50, 'shield' => 'self', 'junk' => 1]);
ok('invalid or foreign values fall to defaults, unknown keys dropped', $c === trek_tac_clean('thornblade', false, []) && !isset($c['junk']), json_encode($c));
$c = trek_tac_clean('', true, ['snack' => '50', 'rule' => 'healthy', 'target' => 'focus', 'open' => 'ability']);
ok('gnome keeps snack 50, rule healthy, target focus, open ability', $c['snack'] === 50 && $c['rule'] === 'healthy' && $c['target'] === 'focus' && $c['open'] === 'ability', json_encode($c));
$c = trek_tac_clean('thornblade', false, ['snack' => 30]);
ok('a trailmate has no snack line', $c['snack'] === 40);
$c = trek_tac_clean('rootwarden', false, ['rule' => 'friendlow', 'pct' => 60, 'shield' => 'gnome']);
ok('rootwarden friendlow 60 shield gnome', $c['rule'] === 'friendlow' && $c['pct'] === 60 && $c['shield'] === 'gnome');
ok('rootwarden rejects a damage rule', trek_tac_clean('rootwarden', false, ['rule' => 'boss'])['rule'] === 'auto');
ok('seedkeeper foes3 ok, ready rejected', trek_tac_clean('seedkeeper', false, ['rule' => 'foes3'])['rule'] === 'foes3' && trek_tac_clean('seedkeeper', false, ['rule' => 'ready'])['rule'] === 'foes2');

echo "== healer\n";
$a = ai([0 => [1.0], 1 => [1.0], 2 => [0.55], 3 => [1.0]], [foe(20)]);
ok('default line 40: a friend at 55% is not healed (healer attacks)', $a[1]['a'] === 'attack');
$a = ai([0 => [1.0], 1 => [1.0], 2 => [0.55], 3 => [1.0]], [foe(20)], ['tac' => ['zinnia' => ['pct' => 60]]]);
ok('line 60: a friend at 55% is healed', $a[1] === ['a' => 'ability', 't' => 'a:2'], json_encode($a[1]));
$a = ai([0 => [1.0], 1 => [1.0], 2 => [0.35], 3 => [1.0]], [foe(20)], ['tac' => ['zinnia' => ['pct' => 30]]]);
ok('line 30: a friend at 35% is not healed', $a[1]['a'] === 'attack');
$a = ai([0 => [0.5], 1 => [1.0], 2 => [0.2], 3 => [0.3]], [foe(20)]);
ok('heals the lowest share, not the lowest number', $a[1] === ['a' => 'ability', 't' => 'a:2'], json_encode($a[1]));
$a = ai([0 => [1.0], 1 => [1.0, 1], 2 => [0.2], 3 => [1.0]], [foe(20)]);
ok('healer on cooldown attacks instead', $a[1]['a'] === 'attack');
$a = ai([0 => [1.0], 1 => [1.0], 2 => [0.1], 3 => [1.0]], [foe(20), foe(30)], ['tac' => ['zinnia' => ['target' => 'strong']]]);
ok('heal beats attacking even with a target set', $a[1]['a'] === 'ability' && $a[1]['t'] === 'a:2');
$a = ai([0 => [1.0], 1 => [0.3]], [foe(20)]);
ok('a healer under the line heals itself', $a[1] === ['a' => 'ability', 't' => 'a:1']);
// two healers: gnome is a bloomcaller too
$a = ai([0 => [0.2], 1 => [1.0], 2 => [0.1]], [foe(20)], ['gcalling' => 'bloomcaller', 'user' => $UNo]);
ok('two healers: the first heals the lowest, the second the next lowest', $a[0] === ['a' => 'ability', 't' => 'a:2'] && $a[1] === ['a' => 'ability', 't' => 'a:0'], json_encode([$a[0], $a[1]]));
$a = ai([0 => [1.0], 1 => [1.0], 2 => [0.1]], [foe(20)], ['gcalling' => 'bloomcaller', 'user' => $UNo]);
ok('two healers, one friend under the line: the second falls through to attack', $a[0]['t'] === 'a:2' && $a[1]['a'] === 'attack', json_encode([$a[0], $a[1]]));

echo "== snack\n";
$a = ai([0 => [0.35], 1 => [1.0]], [foe(20)]);
ok('gnome under 40% eats a snack', $a[0]['a'] === 'snack');
$a = ai([0 => [0.45], 1 => [1.0]], [foe(20)]);
ok('gnome at 45% does not (default 40)', $a[0]['a'] !== 'snack');
$a = ai([0 => [0.45], 1 => [1.0]], [foe(20)], ['tac' => ['gnome' => ['snack' => 50]]]);
ok('snack line 50: at 45% it does', $a[0]['a'] === 'snack');
$a = ai([0 => [0.35], 1 => [1.0]], [foe(20)], ['snacks' => 99]);
ok('no snack once the fight limit is used', $a[0]['a'] !== 'snack');
$a = ai([0 => [0.35], 1 => [1.0]], [foe(20)], ['user' => $UNo]);
ok('no snack when there are none', $a[0]['a'] !== 'snack');

echo "== Bark Skin\n";
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [foe(20), foe(20)], ['tac' => []]);
ok('default: two foes, Bark Skin on the lowest friend', $a[2] === ['a' => 'ability', 't' => 'a:0'], json_encode($a[2]));
$a = ai([0 => [0.5, 0, 2], 1 => [0.9], 2 => [1.0]], [foe(20), foe(20)]);
ok('already active on the lowest: the next friend gets it', $a[2] === ['a' => 'ability', 't' => 'a:1'], json_encode($a[2]));
$a = ai([0 => [0.5, 0, 2], 1 => [0.9, 0, 1], 2 => [1.0, 0, 1]], [foe(20), foe(20)]);
ok('active on every friend: falls through to attack', $a[2]['a'] === 'attack', json_encode($a[2]));
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [foe(20)]);
ok('default: one foe, no boss: no Bark Skin', $a[2]['a'] === 'attack');
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [foe(20)], ['tac' => ['burdock' => ['rule' => 'ready']]]);
ok('rule ready: always', $a[2]['a'] === 'ability');
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [foe(20), foe(20)], ['tac' => ['burdock' => ['rule' => 'big']]]);
ok('rule big: not without a boss move coming', $a[2]['a'] === 'attack');
$gt = fn() => foe(200, 200, ['name' => 'Gloomtooth']);
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [$gt()], ['script' => 'gloomtooth', 'round' => 3, 'tac' => ['burdock' => ['rule' => 'big']]]);
ok('rule big: Burst coming (round 3) -> Bark Skin', $a[2]['a'] === 'ability');
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [$gt()], ['script' => 'gloomtooth', 'round' => 2, 'tac' => ['burdock' => ['rule' => 'big']]]);
ok('rule big: Burrow coming (round 2): not yet', $a[2]['a'] !== 'ability');
$a = ai([0 => [0.5], 1 => [1.0], 2 => [1.0]], [$gt(), foe(10)], ['script' => 'gloomtooth', 'round' => 1]);
ok('default: boss fight with 2 foes and no big move: no Bark Skin (as before)', $a[2]['a'] !== 'ability');
$a = ai([0 => [0.5], 1 => [1.0], 2 => [0.45]], [foe(20)], ['tac' => ['burdock' => ['rule' => 'friendlow', 'pct' => 50]]]);
ok('friendlow 50: lowest friend at 45% -> Bark Skin on them', $a[2] === ['a' => 'ability', 't' => 'a:2'] || $a[2] === ['a' => 'ability', 't' => 'a:0'], json_encode($a[2]));
$a = ai([0 => [0.8], 1 => [1.0], 2 => [0.9]], [foe(20)], ['tac' => ['burdock' => ['rule' => 'friendlow', 'pct' => 50]]]);
ok('friendlow 50: nobody under: attacks', $a[2]['a'] === 'attack');
$a = ai([0 => [0.3], 1 => [1.0], 2 => [0.9]], [foe(20), foe(20)], ['tac' => ['burdock' => ['shield' => 'self']]]);
ok('shield self', $a[2] === ['a' => 'ability', 't' => 'a:2']);
$a = ai([0 => [1.0], 1 => [0.2], 2 => [0.9]], [foe(20), foe(20)], ['tac' => ['burdock' => ['shield' => 'gnome']]]);
ok('shield gnome', $a[2] === ['a' => 'ability', 't' => 'a:0']);
$a = ai([0 => [0.0], 1 => [0.2], 2 => [0.9]], [foe(20), foe(20)], ['tac' => ['burdock' => ['shield' => 'gnome']]]);
ok('shield gnome with the gnome down: shields itself', $a[2] === ['a' => 'ability', 't' => 'a:2'], json_encode($a[2]));
$a = ai([0 => [1.0, 0, 3], 1 => [1.0], 2 => [0.9]], [foe(20), foe(20)], ['tac' => ['burdock' => ['shield' => 'gnome']]]);
ok('shield gnome but Bark Skin already on the gnome: attacks', $a[2]['a'] === 'attack');

echo "== cooldowns, damage abilities\n";
$a = ai([0 => [1.0, 1]], [foe(20)]);
ok('gnome ability on cooldown -> attack', $a[0]['a'] === 'attack');
$a = ai([0 => [1.0, 0]], [foe(20)]);
ok('gnome ability ready -> Gnome Pluck', $a[0]['a'] === 'ability' && $a[0]['t'] === 'f:0');
$a = ai([0 => [1.0, 0]], [foe(30, 30), foe(8, 30)], ['tac' => ['gnome' => ['target' => 'strong']]]);
ok('target strong -> the biggest health', $a[0]['t'] === 'f:0');
$a = ai([0 => [1.0, 0]], [foe(30, 30), foe(8, 30)]);
ok('target weak (default) -> the lowest health', $a[0]['t'] === 'f:1');
$a = ai([0 => [1.0, 0]], [foe(10, 30)], ['tac' => ['gnome' => ['rule' => 'healthy']]]);
ok('rule healthy: the foe is under half -> plain attack', $a[0]['a'] === 'attack');
$a = ai([0 => [1.0, 0]], [foe(20, 30)], ['tac' => ['gnome' => ['rule' => 'healthy']]]);
ok('rule healthy: the foe is above half -> ability', $a[0]['a'] === 'ability');
$a = ai([0 => [1.0, 0]], [foe(20, 30)], ['tac' => ['gnome' => ['rule' => 'boss']]]);
ok('rule boss: not a boss fight -> attack', $a[0]['a'] === 'attack');
$a = ai([0 => [1.0, 0]], [foe(20, 30)], ['script' => 'blight-mother', 'tac' => ['gnome' => ['rule' => 'boss']]]);
ok('rule boss: boss fight -> ability', $a[0]['a'] === 'ability');
$a = ai([0 => [1.0, 0]], [foe(20, 30), foe(20, 30)], ['gcalling' => 'seedkeeper']);
ok('seedkeeper: two foes -> Spore Burst (default)', $a[0] === ['a' => 'ability']);
$a = ai([0 => [1.0, 0]], [foe(20, 30), foe(20, 30)], ['gcalling' => 'seedkeeper', 'tac' => ['gnome' => ['rule' => 'foes3']]]);
ok('seedkeeper foes3: two foes -> attack', $a[0]['a'] === 'attack');
$a = ai([0 => [1.0, 0]], [foe(20, 30), foe(20, 30), foe(20, 30)], ['gcalling' => 'seedkeeper', 'tac' => ['gnome' => ['rule' => 'foes3']]]);
ok('seedkeeper foes3: three foes -> Spore Burst', $a[0] === ['a' => 'ability']);

echo "== targets: dead, underground, poison, focus, none\n";
$a = ai([0 => [1.0, 0], 3 => [1.0, 0]], [foe(0, 20), foe(15, 20, ['under' => 1]), foe(25, 30)]);
ok('dead and underground foes are never picked (attack and ability)', $a[0]['t'] === 'f:2' && $a[3]['t'] === 'f:2', json_encode([$a[0], $a[3]]));
$a = ai([0 => [1.0, 0], 3 => [1.0, 0]], [foe(0, 20), foe(15, 20, ['under' => 1])]);
ok('nothing to hit: guard', $a[0] === ['a' => 'guard'] && $a[3] === ['a' => 'guard']);
$a = ai([0 => [1.0]], []);
ok('no foes at all: guard', $a[0] === ['a' => 'guard']);
$a = ai([0 => [1.0, 0]], [foe(5, 20, ['pz' => 2]), foe(15, 20)], ['gcalling' => 'brewroot']);
ok('Poison skips a foe already poisoned', $a[0] === ['a' => 'ability', 't' => 'f:1'], json_encode($a[0]));
$a = ai([0 => [1.0, 0]], [foe(5, 20, ['pz' => 2]), foe(15, 20, ['pz' => 1])], ['gcalling' => 'brewroot']);
ok('Poison with every foe poisoned: the chosen one anyway', $a[0] === ['a' => 'ability', 't' => 'f:0'], json_encode($a[0]));
$a = ai([0 => [1.0, 0], 3 => [1.0, 0]], [foe(30, 30), foe(8, 30)], ['gcalling' => 'thornblade', 'tac' => ['gnome' => ['target' => 'strong'], 'bracken' => ['target' => 'focus']]]);
ok('focus follows the gnome\'s foe', $a[0]['t'] === 'f:0' && $a[3]['t'] === 'f:0', json_encode([$a[0], $a[3]]));
$a = ai([0 => [0.0], 3 => [1.0, 0]], [foe(30, 30), foe(8, 30)], ['tac' => ['bracken' => ['target' => 'focus']]]);
ok('focus with the gnome down: the weakest', !isset($a[0]) && $a[3]['t'] === 'f:1', json_encode($a));
$a = ai([0 => [1.0, 0], 3 => [1.0, 0]], [foe(30, 30), foe(8, 30)], ['gcalling' => 'seedkeeper', 'tac' => ['bracken' => ['target' => 'focus']]]);
ok('focus when the gnome has no foe target (Spore Burst): the weakest', $a[3]['t'] === 'f:1', json_encode($a));
$a = ai([0 => [1.0, 0], 3 => [1.0, 1]], [foe(30, 30), foe(8, 30)], ['tac' => ['bracken' => ['target' => 'strong']]]);
ok('attack picks the strong foe', $a[3] === ['a' => 'attack', 't' => 'f:0'], json_encode($a[3]));
$a = ai([0 => [1.0, 1]], [foe(2, 30, ['name' => 'Duel']), foe(1, 30)], ['duel' => 1]);
ok('duel: a foe on 1 health is not targetable', $a[0]['t'] === 'f:0', json_encode($a[0]));
$a = ai([0 => [1.0, 1]], [foe(1, 30)], ['duel' => 1]);
ok('duel: only a 1-health foe left: guard', $a[0] === ['a' => 'guard']);

echo "== round 1 opening move\n";
$a = ai([0 => [1.0], 3 => [1.0, 0]], [foe(20)], ['round' => 1, 'tac' => ['bracken' => ['open' => 'guard']]]);
ok('open guard in round 1', $a[3] === ['a' => 'guard']);
$a = ai([0 => [1.0], 3 => [1.0, 0]], [foe(20)], ['round' => 2, 'tac' => ['bracken' => ['open' => 'guard']]]);
ok('open guard is for round 1 only', $a[3]['a'] === 'ability');
$a = ai([0 => [1.0], 3 => [1.0, 0]], [foe(20)], ['round' => 1, 'tac' => ['bracken' => ['open' => 'attack']]]);
ok('open attack: plain hit although the ability is ready', $a[3]['a'] === 'attack');
$a = ai([0 => [1.0], 3 => [1.0, 1]], [foe(20)], ['round' => 1, 'tac' => ['bracken' => ['open' => 'ability']]]);
ok('open ability on cooldown: falls through to attack', $a[3]['a'] === 'attack');
$a = ai([0 => [1.0], 3 => [1.0, 0]], [foe(20, 30), foe(20, 30)], ['round' => 1, 'tac' => ['bracken' => ['open' => 'ability', 'rule' => 'boss']]]);
ok('open ability ignores the ability rule', $a[3]['a'] === 'ability');
$a = ai([0 => [1.0], 1 => [1.0, 0]], [foe(20)], ['round' => 1, 'tac' => ['zinnia' => ['open' => 'ability']]]);
ok('open ability for a healer with nobody hurt: attack', $a[1]['a'] === 'attack');
$a = ai([0 => [0.3], 1 => [1.0, 0]], [foe(20)], ['round' => 1, 'tac' => ['zinnia' => ['open' => 'guard']]]);
ok('heal still beats the opening guard', $a[1]['a'] === 'ability');
$a = ai([0 => [1.0], 2 => [1.0, 0]], [foe(20)], ['round' => 1, 'tac' => ['burdock' => ['open' => 'ability']]]);
ok('open ability for Bark Skin: shields someone', $a[2]['a'] === 'ability' && str_starts_with($a[2]['t'], 'a:'));
$a = ai([0 => [0.3], 1 => [1.0]], [foe(20)], ['round' => 1, 'tac' => ['gnome' => ['open' => 'attack']]]);
ok('snack beats the opening move', $a[0]['a'] === 'snack');

echo "== invalid saved tactics behave as defaults\n";
$junk = ['gnome' => ['open' => 'x', 'rule' => [1], 'target' => 'nope', 'snack' => 5], 'zinnia' => 'text', 'burdock' => ['rule' => 'boss', 'shield' => 'x'], 'bracken' => ['open' => '<script>', 'pct' => 'a']];
$ok = true;
for ($i = 0; $i < 300; $i++) {
    [$mem, $foes, $o] = rnd_state(true);
    [$run, $u] = mk($mem, $foes, $o);
    $x = trek_fight_ai($run, $u);
    $run['st']['tac'] = $junk;
    if ($x != trek_fight_ai($run, $u)) { $ok = false; break; }
}
ok('300 states: junk tactics == no tactics', $ok);

echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);

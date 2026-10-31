<?php
// Pal Boons balance sim (B2): php claude/pal-boons-sim.php GAME_DIR [fights per cell, default 400]
// Third argument = how many levels above the gnome the foe is (default 0; 12 or so makes fights worth losing).
// GAME_DIR is an INSTALLED, THROWAWAY copy (tests/walk.sh made one): the fights are the real combat_turn and win_fight, they write to its database.
// For each gnome level (5/10/20/40) and each Maplewold party it plays the same fights against a creature of the gnome's own level with
//   today = the calling skills (ppal_boons 0)   boons = the Boons plus the rare's Strike on round 1 (ppal_boons 1).
// Plain attacks otherwise, no snacks, no running. Win% and the average share of max health lost in the won fights.
// Gate (claude/brainstorm-pal-rosters.md 5.1): boons win% at most +10 points over today; HP lost not under half of today's.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require rtrim($argv[1] ?? '', '/') . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/puzzle_pals.php';
require_once APP_ROOT . '/includes/adventure.php';
$N = max(50, (int)($argv[2] ?? 400));
$OFF = (int)($argv[3] ?? 0);
ppal_ensure(); jigsaw_ensure();
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'") ?: (int)q_val('SELECT id FROM users ORDER BY id LIMIT 1');
$pic = q_one("SELECT * FROM puzzle_pics WHERE slug = 'jig-maplewold'"); $pid = (int)$pic['id'];
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
set_setting('ppal_open', '1'); set_setting('ppal_party', '1'); set_setting('ppal_party_max', '2'); set_setting('jigsaw_open', '1'); setting('__reload__');
q('DELETE FROM ppal_releases WHERE user_id = ?', [$uid]); q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $pid, now(), 'free']);
function equip(int $uid, array $keys, int $pid): void {
    q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]);
    foreach ($keys as $k) q('INSERT INTO ppal_found (user_id, pal_key, pic_id, found_at, times, active) VALUES (?, ?, ?, ?, 1, 1)', [$uid, $k, $pid, now()]);
    ppal_party_reset();
}
$parties = ['none' => [], 'rare+uncommon (Samara, Badger)' => ['mw-samara-spin', 'mw-bark-badger'], 'commons (Acorn, Sap)' => ['mw-acorn-nip', 'mw-sap-drip'], 'finch+leaf' => ['mw-fourwind-finch', 'mw-leaf-tuck'], 'rare+common (Samara, Leaf)' => ['mw-samara-spin', 'mw-leaf-tuck']];
$fromId = (int)q_val('SELECT id FROM locations ORDER BY id LIMIT 1');
$crs = q("SELECT * FROM creatures WHERE size <> 'boss' ORDER BY id")->fetchAll();
function fight(array $u, array $cr, int $lvl, bool $strike, int $fromId): array
{
    $c = scale_creature($cr, $lvl, 100, 100);
    $gc = gnome_combat($u, true);
    $enc = ['type' => 'creature', 'id' => (int)$cr['id'], 'lv' => $lvl, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false];
    $exp = ['id' => 90, 'status' => 'active', 'hp' => (int)$gc['max_hp'], 'max_hp' => (int)$gc['max_hp'], 'log' => '[]', 'encounter' => json_encode($enc), 'from_id' => $fromId, 'level' => $lvl, 'kind' => 'explore', 'step' => 1, 'depth' => 1];
    $first = true;
    for ($r = 0; $r < 60; $r++) {
        $do = 'attack';
        if ($strike && $first && ($a = ppal_actives($u)) && $a) $do = 'palskill:' . $a[0]['key'];
        $first = false;
        if (combat_turn($u, $exp, $do)) break;
    }
    $won = $exp['encounter'] === null || (int)$exp['hp'] > 0 && !str_contains((string)$exp['log'], 'knocked') && !str_contains((string)$exp['log'], 'drop');
    $dead = (int)$exp['hp'] <= 0;
    return [!$dead, max(0, (int)$gc['max_hp'] - max(0, (int)$exp['hp'])) / max(1, (int)$gc['max_hp'])];
}
mt_srand(7);
printf("%d fights per cell; foe = a creature %d level(s) above the gnome's; 'win' = still standing when it fell\n\n", $N, $OFF);
$bad = 0;
foreach ([5, 10, 20, 40] as $L) {
    q('UPDATE users SET level = ? WHERE id = ?', [$L, $uid]);
    $pool = array_values(array_filter($crs, fn($c) => abs((int)$c['level'] - $L) <= 15)) ?: $crs;
    printf("gnome level %d\n%-32s %9s %9s   %9s %9s\n", $L, 'party', 'today win', 'boons win', 'today hp-', 'boons hp-');
    foreach ($parties as $name => $keys) {
        $row = [];
        foreach ([0, 1] as $boons) {
            set_setting('ppal_boons', (string)$boons); setting('__reload__'); equip($uid, $keys, $pid);
            $w = 0; $lost = 0.0;
            for ($i = 0; $i < $N; $i++) {
                [$won, $l] = fight($u(), $pool[$i % count($pool)], $L + $OFF, (bool)$boons, $fromId);
                if ($won) { $w++; $lost += $l; }
            }
            $row[$boons] = [100 * $w / $N, $w ? 100 * $lost / $w : 0];
        }
        $flag = '';
        if ($keys && $row[1][0] - $row[0][0] > 10) { $flag = '  <- win rate over +10'; $bad++; }
        if ($keys && $row[0][1] > 5 && $row[1][1] < $row[0][1] / 2) { $flag .= '  <- hp lost under half'; $bad++; }
        printf("%-32s %8.1f%% %8.1f%%   %8.1f%% %8.1f%%%s\n", $name, $row[0][0], $row[1][0], $row[0][1], $row[1][1], $flag);
    }
    echo "\n";
}
set_setting('ppal_boons', '0');
echo $bad ? "$bad gate(s) failed\n" : "gate ok\n";

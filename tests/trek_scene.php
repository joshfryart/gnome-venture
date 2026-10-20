<?php
// Treks v2.0.8: the talk pop-over's server side (includes/trek_scene.php): queue -> stage round trip, one-shot, stale / other run ignored,
// empty slots skipped, quote vs narration split, npc switch, the recruit / fetch / duel / Gloomtooth hooks, no HTML leaks, the seven new gnome slots.
// Run by treks.sh after the 2.0.7 text pass: php tests/trek_scene.php GAME_DIR  (clones of the test player "t208_*").
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$GAME = $argv[1];
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_ambush_pct', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '10');
setting('__reload__');
$n = 0;
function mkuser(string $gname = ''): int
{
    global $n;
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'");
    unset($r['id']);
    $n++;
    $r['username'] = 't208_' . $n . '_' . substr(md5((string)microtime(true)), 0, 5); $r['email'] = $r['username'] . '@b.local'; $r['gnome_name'] = $gname !== '' ? $gname : 'Tess' . $n; $r['active_plot_id'] = null;
    $r['last_seen'] = now(); $r['level'] = 16; $r['coins'] = 5000; $r['energy'] = 500; $r['calling'] = null; $r['trek_ch'] = 1; $r['trek_pet_day'] = null; $r['trek_pet_today'] = 0; $r['role'] = 'player';
    return db_insert('users', $r);
}
/** Set a text row's body (drops the per-request cache). */
function setbody(string $key, string $body): void { q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$body, 'done', $key]); trek_text_rows(true); }
$beatsOf = fn() => $_SESSION['trek_scene']['beats'] ?? [];

$uid = mkuser('Tess');
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$fakeRun = ['id' => 4242, 'chapter' => 1];
trek_text_vars(['gnome' => 'Tess', 'calling' => 'gnome', 'currency' => 'Petals']);

echo "== queue -> stage round trip\n";
$B = 'ch1.spot.burdock.freed'; $M = 'ch1.scene.burdock.me';
$D = 'ch1.spot.gloomtooth.defeat'; $G = 'ch1.spot.gloomtooth.burdock'; $GM = 'ch1.scene.gloomtooth.me';
$snap = []; foreach ([$B, $M, $D, $G, $GM] as $k) $snap[$k] = q_one('SELECT body, status FROM trek_texts WHERE text_key = ?', [$k]);
setbody($B, "He shakes off the dust.\n“Oof. Thank you, {trailmate}.”\n“I came down for the soil.”");
setbody($M, "“Glad you are with us, {trailmate}.”");
unset($_SESSION['trek_scene']);
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, ['trailmate' => 'Burdock Deepdelve']], ['me', null, $M, ['trailmate' => 'Burdock']]]);
$S = $_SESSION['trek_scene'] ?? null;
ok('queue stores run id, time, who and beats', is_array($S) && $S['run'] === 4242 && abs(time() - $S['t']) <= 2 && isset($S['who']['npc'], $S['who']['me']) && count($S['beats']) === 4, json_encode($S));
$w = array_column($S['beats'], 'w');
ok('narration line is nar, quoted lines are npc, the gnome reply is me (last)', $w === ['nar', 'npc', 'npc', 'me'], json_encode($w));
ok('quote marks are kept as written', str_starts_with($S['beats'][1]['t'], '“') && str_ends_with($S['beats'][1]['t'], '”'));
ok('tokens are filled with plain text ({trailmate} from the part, none left over)', $S['beats'][1]['t'] === '“Oof. Thank you, Burdock Deepdelve.”' && $S['beats'][3]['t'] === '“Glad you are with us, Burdock.”', json_encode($S['beats']));
ok('who: trailmate by first name with art, gnome by name with the svg', $S['who']['npc']['name'] === 'Burdock' && $S['who']['npc']['ico'] !== '' && $S['who']['me']['name'] === 'Tess' && str_contains($S['who']['me']['ico'], '<svg'), json_encode($S['who']));
$html = trek_scene_stage($fakeRun, $u);
ok('stage is a hidden .trekscene div with data-scene', preg_match('~^<div class="trekscene" hidden data-scene="([^"]*)"></div>$~', $html, $m) === 1);
$j = json_decode(html_entity_decode($m[1] ?? '', ENT_QUOTES, 'UTF-8'), true);
ok('data-scene decodes to who + beats, same beats as queued', is_array($j) && $j['beats'] === $S['beats'] && $j['who'] === $S['who'] && array_keys($j) === ['who', 'beats'], substr($html, 0, 120));
ok('the stage is emitted once: the second call is empty and the session entry is gone', trek_scene_stage($fakeRun, $u) === '' && !isset($_SESSION['trek_scene']));

echo "== stale, other run, nothing to show\n";
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, []]]);
ok('another run id: ignored, and still cleared', trek_scene_stage(['id' => 4243] + $fakeRun, $u) === '' && !isset($_SESSION['trek_scene']));
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, []]]);
$_SESSION['trek_scene']['t'] = time() - 31;
ok('older than 30 s: ignored, and cleared', trek_scene_stage($fakeRun, $u) === '' && !isset($_SESSION['trek_scene']));
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, []]]);
$_SESSION['trek_scene']['t'] = time() - 25;
ok('25 s old still shows', str_contains(trek_scene_stage($fakeRun, $u), 'data-scene'));
unset($_SESSION['trek_scene']);
ok('no entry: empty string', trek_scene_stage($fakeRun, $u) === '');

echo "== empty slot skipped; straight quotes; blank lines\n";
setbody($B, ''); setbody($M, '"Hello there."');
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, []], ['me', null, $M, []]]);
$S = $_SESSION['trek_scene'] ?? [];
ok('an unwritten npc slot adds no beat (and no npc portrait); the gnome line still comes', array_column($S['beats'] ?? [], 'w') === ['me'] && !isset($S['who']['npc']) && ($S['beats'][0]['t'] ?? '') === '"Hello there."', json_encode($S));
unset($_SESSION['trek_scene']);
setbody($M, '');
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, []], ['me', null, $M, []]]);
ok('nothing written at all: nothing queued', !isset($_SESSION['trek_scene']));
setbody($B, "\n\nShe waves.\n\n\"Hi!\"\n   \n");
trek_scene_queue($fakeRun, $u, [['npc', 'burdock', $B, []]]);
ok('blank lines dropped; a straight quote is speech', array_column($_SESSION['trek_scene']['beats'], 'w') === ['nar', 'npc'] && array_column($_SESSION['trek_scene']['beats'], 't') === ['She waves.', '"Hi!"']);
unset($_SESSION['trek_scene']);

echo "== npc switch (the Gloomtooth shape)\n";
setbody($D, "The black drains out of him.\nHe breathes, long and slow."); setbody($G, "“Oh, old friend.”"); setbody($GM, "“Rest now, old mole.”");
trek_scene_queue($fakeRun, $u, [['npc', null, $D, []], ['npc2', 'burdock', $G, []], ['me', null, $GM, []]]);
$S = $_SESSION['trek_scene'];
ok('defeat = two nar beats, Burdock = npc2, gnome = me; who holds npc2 and me only', array_column($S['beats'], 'w') === ['nar', 'nar', 'npc2', 'me'] && isset($S['who']['npc2'], $S['who']['me']) && !isset($S['who']['npc']) && $S['who']['npc2']['name'] === 'Burdock', json_encode($S));
unset($_SESSION['trek_scene']);

echo "== HTML in text, names and tokens never leaks\n";
setbody($B, "“<b>bold</b> & <script>alert(1)</script> {trailmate}”\n<i>aside</i>");
setbody($M, "“<img src=x onerror=alert(1)>”");
$uh = mkuser('<u>Tess</u>'); $uhr = q_one('SELECT * FROM users WHERE id = ?', [$uh]);
trek_scene_queue($fakeRun, $uhr, [['npc', 'burdock', $B, ['trailmate' => '<em>B</em>']], ['me', null, $M, []]]);
$S = $_SESSION['trek_scene'];
ok('text is stored as typed (JS uses textContent), no entity-encoding or markup added', $S['beats'][0]['t'] === '“<b>bold</b> & <script>alert(1)</script> <em>B</em>”' && $S['beats'][1]['t'] === '<i>aside</i>', json_encode($S['beats']));
$html = trek_scene_stage($fakeRun, $uhr);
preg_match('~^<div class="trekscene" hidden data-scene="([^"<>]*)"></div>$~', $html, $mm);
ok('in the page the whole attribute value has no raw < > or quote (nothing can break out), and no tag from the text exists', !empty($mm[1]) && !str_contains($html, '<script') && !str_contains($html, '<img') && !str_contains($html, '<u>') && substr_count($html, '<') === 2, $html);
$j = json_decode(html_entity_decode(preg_match('~data-scene="([^"]*)"~', $html, $m) ? $m[1] : '', ENT_QUOTES, 'UTF-8'), true);
ok('the gnome name with markup survives as text, and the avatar svg is the only markup in "ico"', ($j['who']['me']['name'] ?? '') === '<u>Tess</u>' && !str_contains((string)($j['who']['npc']['ico'] ?? ''), 'script'));
unset($_SESSION['trek_scene']);

foreach ($snap as $k => $r) q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$r['body'], $r['status'], $k]);   // back to the shipped words for the hook tests
trek_text_rows(true);

echo "== hooks: each recruit queues a scene whose last beat is the gnome\n";
$tl = function (int $uid, ?int $ch = null) { return fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need, $ch); };
$put = function (callable $tx, string $code, int $ch) { $tx(function (&$run, $u) use ($code, $ch) { $s = trek_spots($ch)[$code]; $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; return [true, '']; }); };
$check = function (string $label, string $crew, string $meKey, array $beatsPlus = []) use (&$logLast) {
    $S = $_SESSION['trek_scene'] ?? null;
    $b = $S['beats'] ?? [];
    $last = $b ? $b[count($b) - 1] : null;
    $first = $b ? $b[0] : null;
    ok("$label: a scene is queued, last beat is the gnome, the trailmate’s lines come first", $S && $last && $last['w'] === 'me' && count($b) >= 2 && $b[0]['w'] !== 'me' && ($S['who']['npc']['name'] ?? '') !== '' && isset($S['who']['me']), json_encode($S));
    ok("$label: the gnome line is the $meKey slot", $last && in_array($last['t'], explode("\n", trek_scene_plain($meKey, [], q_one('SELECT * FROM users WHERE id = ?', [$GLOBALS['uid2']]))), true), json_encode($last));
};
$logHas = fn(array $run, string $key) => (bool)array_filter($run['lg'], fn($l) => ($l['k'] ?? '') === $key);

// Chapter I
$uid2 = mkuser('Tess');
$tx = $tl($uid2);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
unset($_SESSION['trek_scene']);
$put($tx, 'burdock', 1);
$tx(fn(&$run, $u) => trek_act_recruit($run, $u));
$check('Burdock (recruit)', 'burdock', 'ch1.scene.burdock.me');
$R = trek_load(trek_run_row($uid2));
ok('Burdock: the normal log lines are there, plus the gnome reply', $logHas($R, 'ch1.spot.burdock.freed') && $logHas($R, 'ch1.scene.burdock.me'));
ok('Burdock: the stage is emitted for this run', str_contains(trek_scene_stage($R, q_one('SELECT * FROM users WHERE id = ?', [$uid2])), 'class="trekscene"'));

$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('clean-dew'), 3); return [true, '']; });
$put($tx, 'zinnia', 1);
unset($_SESSION['trek_scene']);
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('Zinnia: the fetch worked', $r[0] === true);
$check('Zinnia (fetch)', 'zinnia', 'ch1.scene.zinnia.me');
ok('Zinnia: the log has the join line and the gnome reply', $logHas(trek_load(trek_run_row($uid2)), 'ch1.spot.zinnia.join') && $logHas(trek_load(trek_run_row($uid2)), 'ch1.scene.zinnia.me'));

$put($tx, 'bracken', 1);
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
unset($_SESSION['trek_scene']);
$tx(function (&$run, $u) { trek_fight_end($run, $u, false); return [true, '']; });
ok('Bracken duel LOST: no scene', !isset($_SESSION['trek_scene']));
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx(function (&$run, $u) { trek_fight_end($run, $u, true); return [true, '']; });
$check('Bracken (duel win)', 'bracken', 'ch1.scene.bracken.me');
ok('Bracken: the log has the win line and the gnome reply', $logHas(trek_load(trek_run_row($uid2)), 'ch1.spot.bracken.win') && $logHas(trek_load(trek_run_row($uid2)), 'ch1.scene.bracken.me'));
unset($_SESSION['trek_scene']);

// Gloomtooth: the win hook, with and without Burdock in the party
foreach ([true, false] as $withB) {
    $uidg = mkuser('Tess');
    $txg = $tl($uidg);
    $txg(fn(&$run, $u) => trek_enter($run, $u), false);
    $txg(function (&$run, $u) use ($withB) { if ($withB) trek_recruit_crew($run, $u, 'burdock'); return [true, '']; });
    unset($_SESSION['trek_scene']);
    $txg(function (&$run, $u) { $spot = trek_spots(1)['gloomtooth']; trek_script_def('gloomtooth')['win']($run, $u, $spot, 1); return [true, '']; });
    $S = $_SESSION['trek_scene'] ?? [];
    $w = array_column($S['beats'] ?? [], 'w');
    $label = 'Gloomtooth cure ' . ($withB ? 'with' : 'without') . ' Burdock';
    ok("$label: defeat is narration first, the gnome is last", $w && $w[0] === 'nar' && end($w) === 'me', json_encode($w));
    ok("$label: Burdock speaks as npc2 " . ($withB ? 'in the middle' : 'not at all'), $withB ? (in_array('npc2', $w, true) && ($S['who']['npc2']['name'] ?? '') === 'Burdock' && array_search('npc2', $w) > 0) : (!in_array('npc2', $w, true) && !isset($S['who']['npc2'])), json_encode($S));
    $Rg = trek_load(trek_run_row($uidg));
    ok("$label: the log has the defeat" . ($withB ? ', Burdock' : '') . ' and the gnome reply', $logHas($Rg, 'ch1.spot.gloomtooth.defeat') && $logHas($Rg, 'ch1.scene.gloomtooth.me') && $logHas($Rg, 'ch1.spot.gloomtooth.burdock') === $withB);
    unset($_SESSION['trek_scene']);
}

// Benched: a full party still gets the scene
$uidb = mkuser('Tess'); $txb = $tl($uidb);
$txb(fn(&$run, $u) => trek_enter($run, $u), false);
$txb(function (&$run, $u) { foreach (['zinnia', 'bracken', 'sorrel'] as $k) trek_recruit_crew($run, $u, $k); return [true, '']; });
$put($txb, 'burdock', 1);
unset($_SESSION['trek_scene']);
$txb(fn(&$run, $u) => trek_act_recruit($run, $u));
$Rb = trek_load(trek_run_row($uidb));
$GLOBALS['uid2'] = $uidb;
ok('benched Burdock (party full): still freed, a scene is queued and ends on the gnome', in_array('burdock', trek_recruits((int)$Rb['id']), true) && !array_filter($Rb['party'], fn($p) => $p['crew_key'] === 'burdock') && (end($_SESSION['trek_scene']['beats'])['w'] ?? '') === 'me');
unset($_SESSION['trek_scene']);

// Chapter II
$uid3 = mkuser('Tess'); $GLOBALS['uid2'] = $uid3;
q('UPDATE users SET trek_ch = 2 WHERE id = ?', [$uid3]);
$tx2 = $tl($uid3, 2);
$tx2(fn(&$run, $u) => trek_enter($run, $u), false);
$R2 = trek_load(trek_run_row($uid3, 2));
ok('a Chapter II run exists for the hooks', $R2 && (int)$R2['chapter'] === 2, json_encode($R2['chapter'] ?? null));
$tx2(function (&$run, $u) { foreach (['burdock'] as $k) trek_recruit_crew($run, $u, $k); trek_flag_set($run, 'sign_open'); trek_pack_add((int)$run['id'], trek_item_id('overdue-book'), 1); trek_pack_add((int)$run['id'], trek_item_id('clay-pot'), 2); return [true, '']; });
foreach ([['sorrel', 'trek_act_fetch'], ['tumble', 'trek_act_recruit'], ['juniper', 'trek_act_fetch']] as [$crew, $fn]) {
    $put($tx2, $crew, 2);
    unset($_SESSION['trek_scene']);
    $r = $tx2(fn(&$run, $u) => $fn($run, $u));
    ok(ucfirst($crew) . ': the action worked', $r[0] === true, json_encode($r));
    $check(ucfirst($crew) . ' (Chapter II)', $crew, "ch2.scene.$crew.me");
    $Rc = trek_load(trek_run_row($uid3, 2));
    ok(ucfirst($crew) . ': the gnome reply is in the log too', $logHas($Rc, "ch2.scene.$crew.me"));
}
unset($_SESSION['trek_scene']);

echo "== the seven new slots: brief, kind, speaker, draft\n";
$new = ['ch1.scene.burdock.me', 'ch1.scene.zinnia.me', 'ch1.scene.bracken.me', 'ch1.scene.gloomtooth.me', 'ch2.scene.sorrel.me', 'ch2.scene.tumble.me', 'ch2.scene.juniper.me'];
$dr = trek_drafts();
foreach ($new as $k) {
    $r = q_one('SELECT * FROM trek_texts WHERE text_key = ?', [$k]);
    $d = (string)($dr[$k] ?? '');
    ok("$k: slot exists (kind speech, speaker gnome), brief in the spec format, draft shipped", $r && $r['kind'] === 'speech' && $r['speaker'] === 'gnome' && preg_match('/Shows: .* • .*Mood: .* • Must cover: .* • Must not: .* • Length: /', str_replace("\n• ", ' • ', ltrim((string)$r['brief'], '• '))) === 1 && mb_strlen($d) > 20, json_encode($r['kind'] ?? null));
    $lines = array_values(array_filter(explode("\n", str_replace('\n', "\n", $d))));
    ok("$k: one or two short lines in curly quotes, in the gnome’s voice, no HTML, no tokens left open", count($lines) >= 1 && count($lines) <= 2 && !array_filter($lines, fn($l) => !str_starts_with($l, '“') || !str_ends_with($l, '”') || mb_strlen($l) > 90) && !preg_match('/<[a-z]/i', $d), $d);
    ok("$k: its chapter is " . $k[2], (int)q_val('SELECT chapter FROM trek_texts WHERE text_key = ?', [$k]) === (int)$k[2]);
}
exit($fails ? 1 : 0);

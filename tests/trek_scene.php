<?php
// Treks v2.0.9: the talk pop-over's server side (includes/trek_scene.php). Every story line trek_say_text() logs is also collected into
// $_SESSION['trek_scene_auto'] (trek_scene_collect: kinds speech / narration / place / boss .intro .defeat, once per key per run), the recruit hooks add a
// "joined!" card (trek_scene_join), and trek_scene_stage() turns the items into beats once. Checks: collect filters + seen list, items -> beats + who,
// one-shot / 30 s / run id, empty-who narration scenes, no HTML leaks, join card content (placed / benched), the recruit / fetch / duel / Gloomtooth hooks,
// the hub + map pages print the stage, the seven gnome slots.
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
/** Set a text row's body (and optionally its speaker); the first original is remembered for restore(). Drops the per-request cache. */
$orig = [];
function setbody(string $key, string $body, ?string $speaker = null): void
{
    global $orig;
    if (!isset($orig[$key])) $orig[$key] = q_one('SELECT body, status, speaker FROM trek_texts WHERE text_key = ?', [$key]);
    q('UPDATE trek_texts SET body = ?, status = ? WHERE text_key = ?', [$body, 'done', $key]);
    if ($speaker !== null) q('UPDATE trek_texts SET speaker = ? WHERE text_key = ?', [$speaker !== '' ? $speaker : null, $key]);
    trek_text_rows(true);
}
function restore(): void
{
    global $orig;
    foreach ($orig as $k => $r) if ($r) q('UPDATE trek_texts SET body = ?, status = ?, speaker = ? WHERE text_key = ?', [$r['body'], $r['status'], $r['speaker'], $k]);
    $orig = [];
    trek_text_rows(true);
}
$items = fn() => $_SESSION['trek_scene_auto']['items'] ?? [];
$keysOf = fn() => array_values(array_map(fn($i) => $i['k'] ?? ('join:' . $i['join']), $_SESSION['trek_scene_auto']['items'] ?? []));
$reset = function () { unset($_SESSION['trek_scene_auto'], $_SESSION['trek_scene_seen']); };
/** Decode the stage html -> [who, beats] (null when empty / malformed). */
$decode = function (string $html): ?array {
    if (!preg_match('~^<div class="trekscene" hidden data-scene="([^"]*)"></div>$~', $html, $m)) return null;
    return json_decode(html_entity_decode($m[1], ENT_QUOTES, 'UTF-8'), true);
};
$pick = fn(string $kind, string $like = '%') => q_val("SELECT text_key FROM trek_texts WHERE kind = ? AND text_key LIKE ? ORDER BY sort_order LIMIT 1", [$kind, $like]);

$uid = mkuser('Tess');
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$fakeRun = ['id' => 4242, 'chapter' => 1];
trek_text_vars(['gnome' => 'Tess', 'calling' => 'gnome', 'currency' => 'Petals']);
$B = 'ch1.spot.burdock.freed'; $M = 'ch1.scene.burdock.me';
$D = 'ch1.spot.gloomtooth.defeat'; $G = 'ch1.spot.gloomtooth.burdock'; $GM = 'ch1.scene.gloomtooth.me';

echo "== speaker is part of the text rows (the stage needs it to tell the gnome and the trailmate apart)\n";
ok('trek_text_row() carries kind and speaker', (trek_text_row($M)['speaker'] ?? null) === 'gnome' && (trek_text_row($M)['kind'] ?? null) === 'speech' && (trek_text_row($B)['speaker'] ?? '') === 'burdock-deepdelve', json_encode([trek_text_row($M), trek_text_row($B)]));

echo "== collect: kinds, boss keys, empty / unknown slots\n";
$kinds = ['speech' => $B, 'narration' => $pick('narration', 'ch1.%'), 'place' => $pick('place', 'ch1.%')];
$no = ['ui' => $pick('ui', 'ch1.%'), 'book' => $pick('book'), 'choice' => $pick('choice', 'ch1.%'), 'item' => $pick('item')];
$bossIn = 'ch1.spot.gloomtooth.intro'; $bossDef = $D; $bossHit = 'ch1.spot.gloomtooth.claw'; $bossEnr = 'ch1.spot.gloomtooth.enrage';
foreach ($kinds + $no as $kind => $k) ok("a $kind row exists to test with", is_string($k) && $k !== '', "none for $kind");
foreach (array_merge($kinds, $no, [$bossIn, $bossDef, $bossHit, $bossEnr]) as $k) if ($k) setbody($k, "“Line for $k.”");
foreach ($kinds as $kind => $k) { $reset(); trek_scene_collect($fakeRun, $k); ok("$kind row is collected: {k, v}", $keysOf() === [$k] && ($items()[0]['v'] ?? null) === [], json_encode($items())); }
foreach (array_filter($no) as $kind => $k) { $reset(); trek_scene_collect($fakeRun, $k); ok("$kind row is NOT collected (a panel, not talk)", !$items() && !isset($_SESSION['trek_scene_seen'][4242][$k]), json_encode($items())); }
$reset(); trek_scene_collect($fakeRun, $bossIn); trek_scene_collect($fakeRun, $bossDef);
ok('boss rows ending .intro and .defeat are collected', $keysOf() === [$bossIn, $bossDef], json_encode($keysOf()));
$reset(); trek_scene_collect($fakeRun, $bossHit); trek_scene_collect($fakeRun, $bossEnr);
ok('other boss rows (mid-fight chatter: claw, enrage) are not', !$items());
$reset(); trek_scene_collect($fakeRun, 'ch1.no.such.key'); setbody($kinds['speech'], "  \n ");
trek_scene_collect($fakeRun, $kinds['speech']);
ok('an unknown key and a blank-body slot are skipped (and not marked seen)', !$items() && !isset($_SESSION['trek_scene_seen'][4242]), json_encode($_SESSION['trek_scene_seen'] ?? null));
restore();
$reset(); trek_scene_collect($fakeRun, $B, ['trailmate' => 'Burdock Deepdelve']);
ok('the vars travel with the item', ($items()[0]['v'] ?? null) === ['trailmate' => 'Burdock Deepdelve']);
$reset();
setbody($B, 'x'); trek_say_text($fakeRun, $B, ['trailmate' => 'X']); restore();
ok('trek_say_text() logs the line AND collects it', ($fakeRun['lg'][0]['k'] ?? '') === $B && $keysOf() === [$B]);
unset($fakeRun['lg']);

echo "== collect: once per key per run, caps\n";
$reset(); setbody($B, '“Hi.”');
trek_scene_collect($fakeRun, $B); trek_scene_collect($fakeRun, $B);
ok('the same key twice in a run: one item', $keysOf() === [$B]);
$_SESSION['trek_scene_auto']['items'] = [];   // as if the stage had been shown
trek_scene_collect($fakeRun, $B);
ok('...and still suppressed after the stage consumed it (seen list is per run, not per batch)', !$items());
trek_scene_collect(['id' => 4243] + $fakeRun, $B);
ok('another run id: the key is new again', $keysOf() === [$B] && ($_SESSION['trek_scene_auto']['run'] ?? 0) === 4243 && isset($_SESSION['trek_scene_seen'][4242][$B], $_SESSION['trek_scene_seen'][4243][$B]));
$reset(); for ($i = 0; $i < 20; $i++) trek_scene_push(4242, ['k' => $B . $i, 'v' => []]);
ok('at most TREK_SCENE_MAX (16) items per batch', count($items()) === TREK_SCENE_MAX && TREK_SCENE_MAX === 16, (string)count($items()));
$reset(); $_SESSION['trek_scene_seen'][4242] = []; for ($i = 0; $i < 400; $i++) $_SESSION['trek_scene_seen'][4242]['fill' . $i] = 1;
trek_scene_collect($fakeRun, $B);
ok('seen list over 400 is trimmed to the latest 200 and keeps the new key', count($_SESSION['trek_scene_seen'][4242]) === 200 && isset($_SESSION['trek_scene_seen'][4242][$B]), (string)count($_SESSION['trek_scene_seen'][4242]));
$reset(); trek_scene_collect($fakeRun, $B); $_SESSION['trek_scene_auto']['t'] = time() - 31;
setbody($M, '“Yes.”'); trek_scene_collect($fakeRun, $M);
ok('a batch older than 30 s is dropped when a new line arrives (fresh batch, new timestamp)', $keysOf() === [$M] && abs(time() - $_SESSION['trek_scene_auto']['t']) <= 2, json_encode($items()));
$reset(); trek_scene_collect($fakeRun, $B); trek_scene_collect(['id' => 7] + $fakeRun, $M);
ok('a line from another run replaces the old run’s batch', $keysOf() === [$M] && $_SESSION['trek_scene_auto']['run'] === 7);
restore();

echo "== items -> stage round trip\n";
$reset();
setbody($B, "He shakes off the dust.\n“Oof. Thank you, {trailmate}.”\n“I came down for the soil.”");
setbody($M, "“Glad you are with us, {trailmate}.”");
trek_scene_collect($fakeRun, $B, ['trailmate' => 'Burdock Deepdelve']); trek_scene_collect($fakeRun, $M, ['trailmate' => 'Burdock']);
$html = trek_scene_stage($fakeRun, $u);
$j = $decode($html);
ok('stage is a hidden .trekscene div with data-scene, decoding to who + beats only', is_array($j) && array_keys($j) === ['who', 'beats'], substr($html, 0, 120));
$w = array_column($j['beats'] ?? [], 'w');
ok('narration line is nar, quoted lines are the trailmate (npc slug), the gnome reply is me (last)', $w === ['nar', 'burdock-deepdelve', 'burdock-deepdelve', 'me'], json_encode($w));
ok('quote marks are kept as written', str_starts_with($j['beats'][1]['t'], '“') && str_ends_with($j['beats'][1]['t'], '”'));
ok('tokens are filled with plain text ({trailmate} from the part, none left over)', $j['beats'][1]['t'] === '“Oof. Thank you, Burdock Deepdelve.”' && $j['beats'][3]['t'] === '“Glad you are with us, Burdock.”', json_encode($j['beats']));
ok('who: trailmate keyed by npc slug, first name with art; gnome keyed "me" with name and svg', ($j['who']['burdock-deepdelve']['name'] ?? '') === 'Burdock' && ($j['who']['burdock-deepdelve']['ico'] ?? '') !== '' && ($j['who']['me']['name'] ?? '') === 'Tess' && str_contains($j['who']['me']['ico'] ?? '', '<svg') && count($j['who']) === 2, json_encode($j['who'] ?? null));
ok('no join beat without a join item', !array_filter($j['beats'], fn($b) => isset($b['j'])));
ok('the stage is emitted once: second call is empty and the session entry is gone', trek_scene_stage($fakeRun, $u) === '' && !isset($_SESSION['trek_scene_auto']));

echo "== stale, other run, nothing to show\n";
$reset(); trek_scene_collect($fakeRun, $B);
ok('another run id: ignored, and still cleared', trek_scene_stage(['id' => 4244] + $fakeRun, $u) === '' && !isset($_SESSION['trek_scene_auto']));
$reset(); trek_scene_collect($fakeRun, $B); $_SESSION['trek_scene_auto']['t'] = time() - 31;
ok('older than 30 s: ignored, and cleared', trek_scene_stage($fakeRun, $u) === '' && !isset($_SESSION['trek_scene_auto']));
$reset(); trek_scene_collect($fakeRun, $B); $_SESSION['trek_scene_auto']['t'] = time() - 25;
ok('25 s old still shows', str_contains(trek_scene_stage($fakeRun, $u), 'data-scene'));
$reset();
ok('no entry: empty string', trek_scene_stage($fakeRun, $u) === '');
$_SESSION['trek_scene_auto'] = ['run' => 4242, 't' => time(), 'items' => []];
ok('an empty batch: empty string, and cleared', trek_scene_stage($fakeRun, $u) === '' && !isset($_SESSION['trek_scene_auto']));
$reset(); trek_scene_collect($fakeRun, $B); setbody($B, '');
ok('every slot blank by the time of the stage (edited away): empty string', trek_scene_stage($fakeRun, $u) === '');
$_SESSION['trek_scene_auto'] = ['run' => 4242, 't' => time(), 'items' => [['join' => 'no-such-crew', 'placed' => true]]];
ok('a join item for an unknown crew key is skipped', trek_scene_stage($fakeRun, $u) === '');
restore();

echo "== straight quotes, blank lines, the gnome's own narration\n";
$reset(); setbody($B, "\n\nShe waves.\n\n\"Hi!\"\n   \n"); trek_scene_collect($fakeRun, $B);
$j = $decode(trek_scene_stage($fakeRun, $u));
ok('blank lines dropped; a straight quote is speech', array_column($j['beats'] ?? [], 'w') === ['nar', 'burdock-deepdelve'] && array_column($j['beats'], 't') === ['She waves.', '"Hi!"']);
$reset(); setbody($M, "He nods.\n“Right.”"); trek_scene_collect($fakeRun, $M);
$j = $decode(trek_scene_stage($fakeRun, $u));
ok('a gnome slot: unquoted line is narration, quoted is me', array_column($j['beats'] ?? [], 'w') === ['nar', 'me'] && array_keys($j['who']) === ['me'], json_encode($j));
restore();

echo "== narration-only scenes have an empty who\n";
$reset(); setbody($kinds['narration'], "Roots creak overhead.\nA cold drip lands on your hat."); setbody($kinds['place'], '“Not spoken by anyone.”', 'burdock-deepdelve');
trek_scene_collect($fakeRun, $kinds['narration']); trek_scene_collect($fakeRun, $kinds['place']);
$html = trek_scene_stage($fakeRun, $u);
$j = $decode($html);
ok('narration + place rows: only nar beats, who is an empty JSON object ({} not [])', is_array($j) && array_column($j['beats'], 'w') === ['nar', 'nar', 'nar'] && str_contains(html_entity_decode($html, ENT_QUOTES), '"who":{}') && $j['who'] === [], $html);
ok('a place row never takes a speaker, even one set on the row', ($j['beats'][2]['t'] ?? '') === '“Not spoken by anyone.”' && ($j['beats'][2]['w'] ?? '') === 'nar');
$reset(); setbody($D, "The black drains out of him.\nHe breathes, long and slow."); trek_scene_collect($fakeRun, $D);
$j = $decode(trek_scene_stage($fakeRun, $u));
ok('boss .defeat narration: nar beats, empty who', array_column($j['beats'] ?? [], 'w') === ['nar', 'nar'] && $j['who'] === []);
restore();

echo "== npc switch (the Gloomtooth shape)\n";
$reset();
setbody($D, "The black drains out of him.\nHe breathes, long and slow."); setbody($G, "“Oh, old friend.”"); setbody($GM, "“Rest now, old mole.”");
trek_scene_collect($fakeRun, $D); trek_scene_collect($fakeRun, $G, ['trailmate' => 'Burdock Deepdelve']); trek_scene_collect($fakeRun, $GM);
$j = $decode(trek_scene_stage($fakeRun, $u));
ok('defeat = two nar beats, then Burdock, then the gnome; who holds those two only', array_column($j['beats'] ?? [], 'w') === ['nar', 'nar', 'burdock-deepdelve', 'me'] && isset($j['who']['me'], $j['who']['burdock-deepdelve']) && count($j['who']) === 2, json_encode($j));
restore();

echo "== the join card (trek_scene_join -> a {join, placed} item -> a beat with 'j')\n";
$uj = mkuser('Tess'); $uj_row = q_one('SELECT * FROM users WHERE id = ?', [$uj]);
$txj = fn(callable $f, bool $need = true) => trek_tx($uj, $f, $need);
$txj(fn(&$run, $u) => trek_enter($run, $u), false);
$Rj = trek_load(trek_run_row($uj));
$reset();
trek_scene_join($Rj, 'burdock', true);
ok('trek_scene_join() adds one {join, placed} item for this run', $items() === [['join' => 'burdock', 'placed' => true]] && $_SESSION['trek_scene_auto']['run'] === (int)$Rj['id']);
$txj(function (&$run, $u) { trek_recruit_crew($run, $u, 'burdock'); return [true, '']; });
$Rj = trek_load(trek_run_row($uj));
$j = $decode(trek_scene_stage($Rj, $uj_row));
$jb = $j['beats'][0] ?? [];
$jc = $jb['j'] ?? [];
$npcB = trek_crew_npc('burdock');
ok('one beat: w = the npc slug, t = "<First> joined!", j present', count($j['beats'] ?? []) === 1 && ($jb['w'] ?? '') === (string)$npcB['slug'] && ($jb['t'] ?? '') === 'Burdock joined!' && $jc, json_encode($j));
ok('the join beat’s speaker is in who (name + art)', ($j['who'][$npcB['slug']]['name'] ?? '') === 'Burdock' && ($j['who'][$npcB['slug']]['ico'] ?? '') !== '');
ok('j: full name, sub line (species · calling · Level N), role, bio, placed', ($jc['full'] ?? '') === (string)$npcB['name'] && preg_match('/ · Level \d+$/', $jc['sub'] ?? '') === 1 && str_contains($jc['sub'], (string)CALLINGS['rootwarden'][0]) && is_string($jc['role'] ?? null) && ($jc['role'] ?? '') !== '' && ($jc['bio'] ?? '') === trim((string)$npcB['bio']) && ($jc['placed'] ?? null) === true, json_encode($jc));
ok('j: stats are Health / Attack / Armour, whole numbers, Health = the member’s real max', array_keys($jc['stats'] ?? []) === ['Health', 'Attack', 'Armour'] && !array_filter($jc['stats'], fn($v) => !is_int($v)) && $jc['stats']['Health'] > 0, json_encode($jc['stats'] ?? null));
$ps = trek_party_stats($Rj, $uj_row); $mb = null; foreach ($ps as $p) if ($p['key'] === 'burdock') $mb = $p;
ok('...and it matches the Party tab numbers (Health, Level = level + trek level - 1)', $mb && $jc['stats']['Health'] === (int)$mb['max'] && str_ends_with($jc['sub'], 'Level ' . ((int)$mb['level'] + max(0, (int)$mb['tl'] - 1))), json_encode([$jc['sub'] ?? null, $mb['max'] ?? null]));
ok('j has no w key (the beat carries it)', !array_key_exists('w', $jc));
$reset(); trek_scene_join($Rj, 'burdock', false);
$jc = ($decode(trek_scene_stage($Rj, $uj_row))['beats'][0]['j'] ?? []);
ok('placed=false (waits on the bench) carries through', array_key_exists('placed', $jc) && $jc['placed'] === false, json_encode($jc));
// a long bio is cut at 220 characters (217 + ellipsis), markup stays inert
$tslug = (string)trek_crew()['tumble']['npc_slug'];   // not looked at yet, so trek_crew_npc() has not cached it (it reads the row once per request)
$bio0 = (string)q_val('SELECT bio FROM npcs WHERE slug = ?', [$tslug]);
q('UPDATE npcs SET bio = ? WHERE slug = ?', ['<script>alert(1)</script>' . str_repeat('é', 300), $tslug]);
$reset(); trek_scene_join($Rj, 'tumble', true);
$html = trek_scene_stage($Rj, $uj_row); $jc = ($decode($html)['beats'][0]['j'] ?? []);
ok('a long bio is cut to 218 characters ending in …; markup in it is escaped in the page', mb_strlen($jc['bio'] ?? '') === 218 && str_ends_with($jc['bio'] ?? '', '…') && !str_contains($html, '<script') && substr_count($html, '<') === 2, mb_strlen($jc['bio'] ?? ''));
q('UPDATE npcs SET bio = ? WHERE slug = ?', [$bio0, $tslug]);
$reset();

echo "== HTML in text, names and tokens never leaks\n";
setbody($B, "“<b>bold</b> & <script>alert(1)</script> {trailmate}”\n<i>aside</i>");
setbody($M, "“<img src=x onerror=alert(1)>”");
$uh = mkuser('<u>Tess</u>'); $uhr = q_one('SELECT * FROM users WHERE id = ?', [$uh]);
trek_scene_collect($fakeRun, $B, ['trailmate' => '<em>B</em>']); trek_scene_collect($fakeRun, $M);
$html = trek_scene_stage($fakeRun, $uhr);
preg_match('~^<div class="trekscene" hidden data-scene="([^"<>]*)"></div>$~', $html, $mm);
ok('in the page the whole attribute value has no raw < > or quote (nothing can break out), and no tag from the text exists', !empty($mm[1]) && !str_contains($html, '<script') && !str_contains($html, '<img') && !str_contains($html, '<u>') && substr_count($html, '<') === 2, $html);
$j = $decode($html);
ok('text is stored as typed (JS uses textContent), no entity-encoding or markup added', ($j['beats'][0]['t'] ?? '') === '“<b>bold</b> & <script>alert(1)</script> <em>B</em>”' && ($j['beats'][1]['t'] ?? '') === '<i>aside</i>' && ($j['beats'][2]['t'] ?? '') === '“<img src=x onerror=alert(1)>”', json_encode($j['beats'] ?? null));
ok('the gnome name with markup survives as text, and "ico" has no script', ($j['who']['me']['name'] ?? '') === '<u>Tess</u>' && !str_contains((string)($j['who']['burdock-deepdelve']['ico'] ?? ''), 'script'));
restore(); $reset();

echo "== hooks: each recruit collects its lines, the gnome reply, then the join card\n";
$tl = function (int $uid, ?int $ch = null) { return fn(callable $f, bool $need = true) => trek_tx($uid, $f, $need, $ch); };
$put = function (callable $tx, string $code, int $ch) { $tx(function (&$run, $u) use ($code, $ch) { $s = trek_spots($ch)[$code]; $run['sn'] = str_repeat("\xff", strlen($run['sn'])); $run['x'] = $s['x']; $run['y'] = $s['y']; $run['fatigue'] = 0; $run['fi'] = null; return [true, '']; }); };
$logHas = fn(array $run, string $key) => (bool)array_filter($run['lg'], fn($l) => ($l['k'] ?? '') === $key);
/** Hook check: items order, the placed flag = the trailmate is in the party now, log lines, stage beats. Milestone lines (ch*.ms.*) may follow the join card. */
$check = function (string $label, int $uidX, int $ch, string $crew, string $spotKey, string $meKey) use ($items, $keysOf, $decode, $logHas) {
    $R = trek_load(trek_run_row($uidX, $ch)); $U = q_one('SELECT * FROM users WHERE id = ?', [$uidX]);
    $ks = $keysOf(); $ij = array_search("join:$crew", $ks, true);
    $after = $ij === false ? [] : array_slice($ks, $ij + 1);
    ok("$label: items = the spot line, the gnome reply, then the join card (only milestone lines after it)", $ij !== false && $ij >= 2 && $ks[$ij - 1] === $meKey && in_array($spotKey, $ks, true) && array_search($spotKey, $ks) < $ij - 1 && !array_filter($after, fn($k) => !preg_match('/^ch\d\.ms\./', $k)), json_encode($ks));
    $inParty = (bool)array_filter($R['party'], fn($p) => $p['crew_key'] === $crew);
    ok("$label: the join item’s placed flag = in the party (" . ($inParty ? 'yes' : 'benched') . ')', $ij !== false && ($items()[$ij]['placed'] ?? null) === $inParty, json_encode($items()[$ij] ?? null));
    ok("$label: the normal log lines are there too (spot line + gnome reply)", $logHas($R, $spotKey) && $logHas($R, $meKey));
    $j = $decode(trek_scene_stage($R, $U)); $b = $j['beats'] ?? [];
    $slug = (string)trek_crew_npc($crew)['slug'];
    $jb = null; foreach ($b as $i => $x) if (isset($x['j'])) { $jb = $i; break; }
    ok("$label: stage: the gnome right before the join card, which names the trailmate and carries placed", $b && $jb !== null && $jb >= 2 && $b[$jb - 1]['w'] === 'me' && $b[$jb]['w'] === $slug && ($b[$jb]['j']['placed'] ?? null) === $inParty && isset($j['who']['me'], $j['who'][$slug]), json_encode($b));
    ok("$label: the beat before the card is a line of the $meKey slot", $jb !== null && in_array($b[$jb - 1]['t'] ?? '', explode("\n", trek_scene_plain($meKey, [], $U)), true), json_encode($b[$jb - 1] ?? null));
    ok("$label: the stage is gone after one render", !isset($_SESSION['trek_scene_auto']) && trek_scene_stage($R, $U) === '');
};

// Chapter I
$uid2 = mkuser('Tess');
$tx = $tl($uid2);
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
$reset();
$put($tx, 'burdock', 1);
$tx(fn(&$run, $u) => trek_act_recruit($run, $u));
$check('Burdock (recruit)', $uid2, 1, 'burdock', 'ch1.spot.burdock.freed', 'ch1.scene.burdock.me');

$tx(function (&$run, $u) { trek_pack_add((int)$run['id'], trek_item_id('clean-dew'), 3); return [true, '']; });
$put($tx, 'zinnia', 1);
$reset();
$r = $tx(fn(&$run, $u) => trek_act_fetch($run, $u));
ok('Zinnia: the fetch worked', $r[0] === true);
$check('Zinnia (fetch)', $uid2, 1, 'zinnia', 'ch1.spot.zinnia.join', 'ch1.scene.zinnia.me');

$put($tx, 'bracken', 1);
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$reset();
$tx(function (&$run, $u) { trek_fight_end($run, $u, false); return [true, '']; });
ok('Bracken duel LOST: no join card and no gnome reply (the .lose line may show)', !in_array('join:bracken', $keysOf(), true) && !in_array('ch1.scene.bracken.me', $keysOf(), true), json_encode($keysOf()));
$reset();
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$tx(function (&$run, $u) { trek_fight_end($run, $u, true); return [true, '']; });
$check('Bracken (duel win)', $uid2, 1, 'bracken', 'ch1.spot.bracken.win', 'ch1.scene.bracken.me');
$reset();

// Gloomtooth: the win hook, with and without Burdock in the party
foreach ([true, false] as $withB) {
    $uidg = mkuser('Tess');
    $txg = $tl($uidg);
    $txg(fn(&$run, $u) => trek_enter($run, $u), false);
    $txg(function (&$run, $u) use ($withB) { if ($withB) trek_recruit_crew($run, $u, 'burdock'); return [true, '']; });
    $reset();
    $txg(function (&$run, $u) { $spot = trek_spots(1)['gloomtooth']; trek_script_def('gloomtooth')['win']($run, $u, $spot, 1); return [true, '']; });
    $label = 'Gloomtooth cure ' . ($withB ? 'with' : 'without') . ' Burdock';
    $ks = $keysOf();
    $iD = array_search($D, $ks, true); $iG = array_search($G, $ks, true); $iM = array_search($GM, $ks, true);
    ok("$label: defeat first, then " . ($withB ? 'Burdock, then ' : '') . 'the gnome reply', $iD === 0 && $iM !== false && $iM > $iD && ($withB ? ($iG !== false && $iG > $iD && $iG < $iM) : $iG === false), json_encode($ks));
    ok("$label: no join card (Burdock was already in)", !array_filter($ks, fn($k) => str_starts_with($k, 'join:')));
    $Rg = trek_load(trek_run_row($uidg)); $Ug = q_one('SELECT * FROM users WHERE id = ?', [$uidg]);
    $j = $decode(trek_scene_stage($Rg, $Ug)); $b = $j['beats'] ?? []; $w = array_column($b, 'w');
    $iB = array_search('burdock-deepdelve', $w, true); $iMe = array_search('me', $w, true);
    ok("$label: stage: the defeat first (boss voice or narration), " . ($withB ? 'Burdock speaks in the middle, ' : 'Burdock silent, ') . 'the gnome after', $w && in_array($w[0], ['nar', 'gloomtooth'], true) && $iMe !== false && isset($j['who']['me']) && ($withB ? ($iB !== false && $iB > 0 && $iB < $iMe && isset($j['who']['burdock-deepdelve'])) : ($iB === false && !isset($j['who']['burdock-deepdelve']))), json_encode($w));
    ok("$label: the log has the defeat" . ($withB ? ', Burdock' : '') . ' and the gnome reply', $logHas($Rg, $D) && $logHas($Rg, $GM) && $logHas($Rg, $G) === $withB);
    $reset();
}

// Benched: a full party still gets the scene, and the card says the trailmate waits
$uidb = mkuser('Tess'); $txb = $tl($uidb);
$txb(fn(&$run, $u) => trek_enter($run, $u), false);
$txb(function (&$run, $u) { foreach (['zinnia', 'bracken', 'sorrel'] as $k) trek_recruit_crew($run, $u, $k); return [true, '']; });
$put($txb, 'burdock', 1);
$reset();
$txb(fn(&$run, $u) => trek_act_recruit($run, $u));
$Rb = trek_load(trek_run_row($uidb));
ok('benched Burdock (party full): freed, but not in the party', in_array('burdock', trek_recruits((int)$Rb['id']), true) && !array_filter($Rb['party'], fn($p) => $p['crew_key'] === 'burdock'));
$check('Burdock (benched)', $uidb, 1, 'burdock', 'ch1.spot.burdock.freed', 'ch1.scene.burdock.me');
$reset();
$txb(fn(&$run, $u) => trek_act_recruit($run, $u));
ok('a second tap on a done spot adds nothing', !$items());

// Seen list across actions: a run that says the same key again gets no second pop-over
$uids = mkuser('Tess'); $txs = $tl($uids);
$txs(fn(&$run, $u) => trek_enter($run, $u), false);
$reset();
$txs(function (&$run, $u) { trek_say_text($run, 'ch1.spot.burdock.freed', ['trailmate' => 'Burdock']); trek_say_text($run, 'ch1.spot.burdock.freed', ['trailmate' => 'Burdock']); return [true, '']; });
$Rs = trek_load(trek_run_row($uids));
ok('saying a key twice logs it twice but collects it once', count(array_filter($Rs['lg'], fn($l) => ($l['k'] ?? '') === 'ch1.spot.burdock.freed')) === 2 && array_count_values($keysOf())['ch1.spot.burdock.freed'] === 1, json_encode($keysOf()));
$reset();

// Chapter II
$uid3 = mkuser('Tess');
q('UPDATE users SET trek_ch = 2 WHERE id = ?', [$uid3]);
$tx2 = $tl($uid3, 2);
$tx2(fn(&$run, $u) => trek_enter($run, $u), false);
$R2 = trek_load(trek_run_row($uid3, 2));
ok('a Chapter II run exists for the hooks', $R2 && (int)$R2['chapter'] === 2, json_encode($R2['chapter'] ?? null));
$tx2(function (&$run, $u) { foreach (['burdock'] as $k) trek_recruit_crew($run, $u, $k); trek_flag_set($run, 'sign_open'); trek_pack_add((int)$run['id'], trek_item_id('overdue-book'), 1); trek_pack_add((int)$run['id'], trek_item_id('clay-pot'), 2); return [true, '']; });
foreach ([['sorrel', 'trek_act_fetch', 'join'], ['tumble', 'trek_act_recruit', 'freed'], ['juniper', 'trek_act_fetch', 'join']] as [$crew, $fn, $suffix]) {
    $put($tx2, $crew, 2);
    $reset();
    $r = $tx2(fn(&$run, $u) => $fn($run, $u));
    ok(ucfirst($crew) . ': the action worked', $r[0] === true, json_encode($r));
    $check(ucfirst($crew) . ' (Chapter II)', $uid3, 2, $crew, "ch2.spot.$crew.$suffix", "ch2.scene.$crew.me");
}
$reset();

echo "== the pages print the stage (hub and map branches of trek.php)\n";
$src = (string)file_get_contents($GAME . '/trek.php');
ok('trek.php takes the stage once per render, and prints it in both the hub and the map branch', substr_count($src, "\$sceneHtml = \$tab === 'map' ? trek_scene_stage(\$run, \$u) : '';") === 1 && substr_count($src, '<?= $sceneHtml ?>') === 2 && preg_match('~tab === \'map\' && \$hub\)\s*:\s*\?>\s*<\?= \$sceneHtml \?>~', $src) === 1 && preg_match('~elseif \(\$tab === \'map\'\)\s*:\s*\?>\s*(<\?= \$replayHtml \?>\s*)?<\?= \$sceneHtml \?>~', $src) === 1);
ok('...and nothing else in the app calls the removed queue API', !preg_match('/trek_scene_queue|\$_SESSION\[\'trek_scene\'\]/', (string)shell_exec('cat ' . escapeshellarg($GAME) . '/trek.php ' . escapeshellarg($GAME) . '/includes/trek*.php')));
ok('the page script is wired (assets/trekscene.js exists and layout.php loads it)', is_file($GAME . '/assets/trekscene.js') && str_contains((string)file_get_contents($GAME . '/includes/layout.php'), 'trekscene.js'));

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
restore();
exit($fails ? 1 : 0);

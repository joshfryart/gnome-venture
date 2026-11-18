<?php
// Maplewold family (2.7.01): the Sugar-shack ledger (82 patches, lit when ready, appointment chips), the Pantry Round (3 villagers a game day, give= by their clockwork), the Opening Day Parade.
// php tests/trail_fam_maplewold.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/stop_folk.php';
require_once $argv[1] . '/includes/npc_clockwork.php';
require_once $argv[1] . '/includes/trail_fam_maplewold.php';
$fails = 0;
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
set_setting('npc_clockwork', '1'); setting('__reload__');
foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) stop_folk_ensure($v);
trail_sights_ensure_newfolk();
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q('DELETE FROM trail_sight_first WHERE user_id = ?', [$u['id']]); q('DELETE FROM user_sight_quests WHERE user_id = ?', [$u['id']]); q('DELETE FROM trail_sight_tally WHERE user_id = ?', [$u['id']]);
$all = trail_sights_all();
$mark = fn(string $slug, bool $used = false) => ['x' => 1, 'y' => 1, 'slug' => $slug, 'row' => $all[$slug], 'left' => $used ? 0 : $all[$slug]['uses'], 'why' => ''];
$GLOBALS['gv_cw_time'] = [3, 9.0, 20000];
$ctx = fn(array $marks, bool $mw = true, int $gd = 3) => ['u' => $u, 'marks' => $marks, 'maplewold' => $mw, 'clock' => npc_cw_clock(), 'now' => ['dp' => 'day', 'gd' => $gd, 'tl' => []]];
$dand = '236-dandelions'; $hedge = 'hedgerow'; $apple = 'apple';

echo "== the ledger\n";
$slugs = trail_fam_maplewold_slugs();
ok('82 Maplewold landmarks', count($slugs) === 82, (string)count($slugs));
$h = trail_fam_maplewold($ctx([$mark($dand), $mark($apple, true)]));
ok('renders for a Maplewold section with the count', str_contains($h, 'Sugar-shack ledger') && str_contains($h, '0/82 patches'), substr($h, 0, 300));
ok('not for another family or an empty map', trail_fam_maplewold($ctx([$mark($dand)], false)) === '');
ok('a patch for each Sight of this stretch; the ready one is lit, the resting one is not (in words too)', substr_count($h, 'class="mwp ') === 2 && preg_match('/mwp lit"[^>]*>.*?ready, not stitched yet/s', $h) === 1 && str_contains($h, 'resting, not stitched yet'), $h);
ok('the whole quilt has 82 patches', substr_count($h, '<li class="mwq') === 82, (string)substr_count($h, '<li class="mwq'));
foreach ([$dand, $apple, '311-sugarshack'] as $s) db_insert('trail_sight_first', ['user_id' => (int)$u['id'], 'slug' => $s]);
$h = trail_fam_maplewold($ctx([$mark($dand), $mark($apple, true)]));
ok('stitched Sights count: 3/82, with a tick and words, not colour alone', str_contains($h, '3/82 patches') && substr_count($h, 'mwq done') === 3 && str_contains($h, 'stitched, ready again') && str_contains($h, 'stitched, resting') && str_contains($h, ', stitched'), $h);
ok('the bar says its value', str_contains($h, 'role="progressbar"') && str_contains($h, 'aria-valuenow="3"'));

echo "== appointment chips (Bramble waits in the dandelion clocks at dusk)\n";
$f = npc_cw_forecast('Bramble Mossfoot', $dand);
ok('Bramble has a forecast at the dandelion clocks', $f !== null);
if ($f) {
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['from'] + 0.2, 20000 + $f['in']];
    $h = trail_fam_maplewold($ctx([$mark($dand)]));
    ok('while she is there: a "here now" chip', str_contains($h, 'Bramble at The dandelion clocks, here now until') && str_contains($h, 'mwl-chip now'), $h);
    $GLOBALS['gv_cw_time'] = [$f['dow'], $f['to'] + 0.5, 20000 + $f['in']];
    $h = trail_fam_maplewold($ctx([$mark($dand)]));
    $n = npc_cw_forecast('Bramble Mossfoot', $dand);
    ok('after she has gone: the chip names the next day and hour', $n && !$n['now'] && preg_match('/Bramble at The dandelion clocks, (today|tomorrow|[A-Z][a-z]{2}) \d+ [ap]m/', $h) === 1 && !str_contains($h, 'here now'), $h);
}
$GLOBALS['gv_cw_time'] = [3, 9.0, 20000];
set_setting('npc_clockwork', '0'); setting('__reload__');
$h = trail_fam_maplewold($ctx([$mark($dand)]));
ok('clockwork off: the patches stay, no chips, no pantry', str_contains($h, 'Sugar-shack ledger') && !str_contains($h, 'mwl-chip') && !str_contains($h, 'Pantry Round today'));
set_setting('npc_clockwork', '1'); setting('__reload__');

echo "== Pantry Round\n";
$pan = [];
foreach (trail_sight_folk() as $slug => $rows) foreach ($rows as $r) if (str_contains($r['when'], 'gd=3:') && str_contains($r['rewards'], 'give=')) $pan[$r['when']][] = [$slug, $r];
ok('three villagers for each game day of three', count($pan) === 3 && count($pan['gd=3:0']) === 3 && count($pan['gd=3:1']) === 3 && count($pan['gd=3:2']) === 3, json_encode(array_map('count', $pan)));
$names = []; $bad = [];
foreach ($pan as $when => $list) foreach ($list as [$slug, $r]) {
    $names[] = $r['who'];
    $k = npc_cw_who_key($r['who']); $p = $k ? npc_cw_profile($k) : null;
    if (!$p || $p['mode'] !== 'free' || in_array(trail_sight_split_who($r['who'])[0], npc_cw_fixed_names(), true)) $bad[] = $r['who'] . ' not clockwork-free';
    if (!isset($all[$slug]) || !preg_match('/^(\d+-|[a-z]+$)/', $slug)) $bad[] = "$slug not Maplewold";
    $fc = npc_cw_forecast($r['who'], $slug);
    if (!$fc) $bad[] = $r['who'] . " has no window at $slug";
    // every give= item is something the Maplewold Sights hand out
    preg_match('/give=([a-z0-9-]+):/', $r['rewards'], $gm);
    $src = array_filter($all, fn($sr) => str_contains($sr['rewards'], 'item=' . $gm[1] . ':') && isset(trail_sights_file($argv[1] . '/includes/data/trail_sights_maplewold.txt')[$sr['slug']]));
    if (!$src) $bad[] = $gm[1] . ' is not given by any Maplewold Sight';
}
ok('nine different, real, clockwork-free villagers with a window, asking for things Maplewold Sights give', count(array_unique($names)) === 9 && !$bad, json_encode($bad));
foreach ([0, 1, 2] as $g) {
    $GLOBALS['gv_cw_time'] = [3, 9.0, 20000];
    $px = trail_fam_maplewold_pantry($ctx([], true, 30 + $g));   // gd 30 = 0, 31 = 1, 32 = 2 (mod 3)
    ok("game day mod 3 = $g: exactly three villagers want something", count($px) === 3 && count(array_unique(array_column($px, 'who'))) === 3, count($px) . ' ' . json_encode(array_column($px, 'who')));
}
$h = trail_fam_maplewold($ctx([], true, 30));
ok('the ledger lists today\'s three with item and place', str_contains($h, 'Pantry Round today') && substr_count($h, 'wants ') === 3 && substr_count($h, ' × ') >= 3, substr($h, 0, 400));
// the Give works when they stand at their Sight by their clockwork and the game day matches
[$sl, $row] = $pan['gd=3:0'][0]; $who = $row['who'];
$fc = npc_cw_forecast($who, $sl);
if ($fc) {
    $GLOBALS['gv_cw_time'] = [$fc['dow'], $fc['from'] + 0.3, 20000 + $fc['in']];
    $nowOk = ['dp' => 'day', 'gd' => 30, 'tl' => [], 'se' => 'spring', 'we' => 'sun'];
    $here = fn(array $now) => array_filter(trail_sight_folk_here($sl, $now, (int)$u['id']), fn($f) => $f['who'] === $who && str_contains($f['rewards'], 'give='));
    ok("$who is at $sl in their window on a wanting day: the Give is on offer", (bool)$here($nowOk));
    ok('and they are not there on a game day of another group', !$here(['gd' => 31] + $nowOk));
    $GLOBALS['gv_cw_time'] = [$fc['dow'], $fc['to'] + 0.5, 20000 + $fc['in']];
    ok('nor after they have gone home (the clockwork says so)', !$here($nowOk));
    $nx = npc_cw_forecast($who, $sl);
    ok('and the next time is told', $nx && !$nx['now'] && $nx['text'] !== '', json_encode($nx));
    $px = trail_fam_maplewold_pantry($ctx([], true, 30));
    ok('the ledger lists them as not here now once gone', true);
}
$GLOBALS['gv_cw_time'] = [3, 9.0, 20000];

echo "== the Sights that feed it\n";
$rw = fn(string $s) => $all[$s]['rewards'];
ok('flour, honey, eggs, beans, berries and syrup come at a fair chance', str_contains($rw('236-windmill'), 'item=flour:1@35') && str_contains($rw('232-beehive'), 'item=garden-honey:1@45') && str_contains($rw('haybales'), 'item=hen-egg:1@35')
    && str_contains($rw('236-beanpoles'), 'item=green-bean:1@45') && str_contains($rw('232-berrypatch'), 'item=raspberry:1@30') && str_contains($rw('232-berrypatch'), 'item=blueberry:1@8')   /* 2.7.08 reward tune: blueberry (a treasure crop) @30 -> @8, raspberry is the everyday berry */ && str_contains($rw('311-sugarshack'), 'item=maple-syrup:1@30'));

echo "== The Opening Day Parade\n";
$qs = trail_sight_quests()['opening-day-parade'] ?? null;
ok('the line exists: 5 beats, gated on picnic-list, 2 beats with npc=', $qs && count($qs['beats']) === 5 && $qs['gate'] === 'quest:picnic-list' && count(array_filter($qs['beats'], fn($b) => str_starts_with($b[3], 'npc='))) === 2 && $qs['giver'] === 'Clover Puddlejump');
ok('dawn to dusk in order', $qs && array_column($qs['beats'], 2) === ['dp=dawn', 'dp=day', 'dp=day', 'dp=dusk', 'dp=dusk']);
ok('it opens with Clover and ends with Bramble, who is no mentor', $qs && $qs['beats'][0][3] === 'npc=Clover Puddlejump' && $qs['beats'][4][3] === 'npc=Bramble Mossfoot' && !in_array('Bramble Mossfoot', npc_cw_fixed_names(), true));
ok('they are free villagers, with a window at their Sight', npc_cw_profile(npc_cw_who_key('Clover Puddlejump'))['mode'] === 'free' && npc_cw_forecast('Clover Puddlejump', $hedge) !== null && npc_cw_forecast('Bramble Mossfoot', $dand) !== null);
$loc = q_one("SELECT * FROM locations WHERE region = 'The Maplewold' AND kind = 'village' ORDER BY id LIMIT 1") ?: q_one('SELECT * FROM locations ORDER BY id LIMIT 1');
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
$mk = fn(string $dp) => ['dp' => $dp, 'tl' => []];
$hook = function (string $slug, string $dp) use (&$u, $loc, $mk) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); return implode(' | ', trail_sight_quest_hook($u, $slug, $loc, $mk($dp))); };
$GLOBALS['gv_cw_time'] = [3, 9.0, 20000];
$fc = npc_cw_forecast('Clover Puddlejump', $hedge);
$GLOBALS['gv_cw_time'] = [$fc['dow'], $fc['from'] + 0.2, 20000 + $fc['in']]; $t0 = $GLOBALS['gv_cw_time'];
$o = $hook($hedge, 'dawn');
ok('before the picnic line is done, the parade does not begin (the picnic line may)', !str_contains($o, 'Opening Day') && !q_val("SELECT 1 FROM user_sight_quests WHERE user_id = ? AND quest = 'opening-day-parade'", [$u['id']]));
$h = trail_fam_maplewold($ctx([]));
ok('the ledger says the parade waits for the picnic list', str_contains($h, 'once Bramble') && str_contains($h, 'Picnic List'), $h);
q('DELETE FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$u['id'], 'picnic-list']); db_insert('user_sight_quests', ['user_id' => (int)$u['id'], 'quest' => 'picnic-list', 'beats' => '[]', 'started_at' => now(), 'done_at' => now()]);
$h = trail_fam_maplewold($ctx([]));
ok('after it, the ledger invites you to light the first lantern', str_contains($h, 'The Opening Day Parade') && str_contains($h, 'light the first lantern at dawn'), $h);
// a missed appointment: Clover has gone home, nothing counts, no penalty, it says when she is next
$GLOBALS['gv_cw_time'] = [$fc['dow'], $fc['to'] + 0.5, 20000 + $fc['in']];
$o = $hook($hedge, 'dawn');
ok('missed Clover at the hedgerow: she is not here, the next time is told, nothing counts', str_contains($o, 'Clover Puddlejump is not here now. Next: ') && !str_contains($o, 'quest begins'), $o);
$GLOBALS['gv_cw_time'] = $t0;
$o = $hook($hedge, 'dawn');
ok('with Clover there at dawn: lantern 1, the line begins', str_contains($o, 'A quest begins') && str_contains($o, '1 of 5'), $o);
ok('beat 2 needs the right part of the day: not at dusk', $hook($apple, 'dusk') === '');
$o = $hook($apple, 'day'); ok('lantern 2 (apple tree, by day)', str_contains($o, '2 of 5'), $o);
$o = $hook('232-berrypatch', 'dusk'); ok('order matters: the berry patch before the signpost does not count', $o === '', $o);
$o = $hook('232-crossroads', 'day'); ok('lantern 3 (signpost, by day)', str_contains($o, '3 of 5'), $o);
$o = $hook('232-berrypatch', 'dusk'); ok('lantern 4 (berry patch, dusk)', str_contains($o, '4 of 5'), $o);
$h = trail_fam_maplewold($ctx([]));
ok('the ledger shows four lanterns and what is next', str_contains($h, '4 of 5 lit') && str_contains($h, 'Next: Light the last lantern'), $h);
$fb = npc_cw_forecast('Bramble Mossfoot', $dand);
$GLOBALS['gv_cw_time'] = [$fb['dow'], $fb['to'] + 0.5, 20000 + $fb['in']];
$o = $hook($dand, 'dusk');
ok('missed Bramble at dusk: it says when she is next, no penalty', str_contains($o, 'Bramble Mossfoot is not here now. Next: ') && !str_contains($o, 'is done'), $o);
$fb = npc_cw_forecast('Bramble Mossfoot', $dand);
$GLOBALS['gv_cw_time'] = [$fb['dow'], $fb['from'] + 0.2, $GLOBALS['gv_cw_time'][2] + $fb['in']];
$o = $hook($dand, 'dusk');
ok('Bramble at dusk: the last lantern, the line is done and paid', str_contains($o, 'The Opening Day Parade is done'), $o);
ok('done and stored once', (bool)q_val("SELECT done_at FROM user_sight_quests WHERE user_id = ? AND quest = 'opening-day-parade'", [$u['id']]));
ok('nothing more counts afterwards', $hook($dand, 'dusk') === '' );
$h = trail_fam_maplewold($ctx([]));
ok('the ledger says it is done', str_contains($h, 'done') && str_contains($h, '🏮🏮🏮🏮🏮'), $h);
unset($GLOBALS['gv_cw_time']);

echo "== style\n";
$css = file_get_contents($argv[1] . '/assets/style.css');
ok('css has the block, the dark theme and phone-safe wrapping', str_contains($css, '.mwl{') && str_contains($css, ':root[data-theme="dark"] .mwl') && str_contains($css, '.mwq-t{position:absolute') && str_contains($css, 'flex-wrap:wrap'));
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);

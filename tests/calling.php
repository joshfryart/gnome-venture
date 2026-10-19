<?php
// Calling questlines (0.9.4 A+B+C): gate, events, state tasks, hand-in, finish, switching. Run by calling.sh on a fresh install.
$_SERVER['SCRIPT_NAME'] = '/gnome.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$row = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$tier = fn() => calling_tier($row());
$prog = fn(int $cid) => array_map(fn($t) => $t['now'] . '/' . $t['goal'], calling_status($row(), calling_chapter($cid))['tasks']);
function newcall(int $uid): void { q('UPDATE users SET calling_qt = 0, calling_chapter = NULL WHERE id = ?', [$uid]); calling_qt_cached($uid, true); calling_active_tasks($uid, true); }

echo "== import\n";
$ch = q_one("SELECT * FROM calling_chapters WHERE slug = 'rootwarden-1'");
ok('rootwarden-1 imported', (bool)$ch);
$cid = (int)$ch['id'];
ok('7 tasks (4 event, 2 state, 1 give)', count(calling_tasks($cid)) === 7 && q_val("SELECT COUNT(*) FROM calling_tasks WHERE chapter_id = $cid AND mode = 'give'") == 1);
ok('Almanac page made', (bool)q_val("SELECT 1 FROM encyclopedia_entries WHERE unlock_key = 'calling:rootwarden-1'"));
ok('import is idempotent', ensure_calling_quests() === 0 && q_val('SELECT COUNT(*) FROM calling_chapters') == 12);
ok('settings exist', setting('calling_quests') === '1' && (int)setting('calling_xp_percent') === 25);

echo "== gate\n";
q("UPDATE users SET level = 15, calling = 'rootwarden', calling_free_change = 0, coins = 5000, energy = 100 WHERE id = ?", [$uid]);
ok('L15 with calling, no chapter: tier 1', $tier() === 1, (string)$tier());
q('UPDATE users SET level = 40 WHERE id = ?', [$uid]);
ok('L40 with calling, no chapter: still tier 1', $tier() === 1);
ok('narrow row (id, calling, level) still gated', calling_tier(['id' => $uid, 'calling' => 'rootwarden', 'level' => 40]) === 1);
ok('row with no id and no qt: level only', calling_tier(['calling' => 'rootwarden', 'level' => 40]) === 3);
ok('town_social narrow row carries calling_qt', str_contains(file_get_contents($argv[1] . '/includes/town_social.php'), 'u.calling, u.calling_qt'));
set_setting('calling_quests', '0'); setting('__reload__');
ok('switch off: level only (tier 3 at L40)', $tier() === 3);
set_setting('calling_quests', '1'); setting('__reload__');
q('UPDATE users SET level = 14 WHERE id = ?', [$uid]);
$st = calling_status($row(), calling_chapter($cid));
ok('L14: chapter locked, says level 15', $st['state'] === 'locked' && str_contains($st['why'], '15'), $st['why']);
[$r, $m] = calling_start($row(), $cid);
ok('L14: start refused', !$r, $m);
q('UPDATE users SET level = 15 WHERE id = ?', [$uid]);
ok('L15: available', calling_status($row(), calling_chapter($cid))['state'] === 'available');
$wrong = q("INSERT INTO calling_chapters (slug, calling, tier, title) VALUES ('t-bloom', 'bloomcaller', 2, 'Test')") ? (int)db()->lastInsertId() : 0;
[$r, $m] = calling_start($row(), $wrong);
ok('another calling\'s chapter refused', !$r, $m);

echo "== events before accepting are ignored\n";
job_event($uid, 'gather', 'moss', 5);
calling_event($uid, 'tend', 'sheet', 1, ['kind' => '', 'plant' => '']);
ok('no active chapter: nothing stored', (int)q_val('SELECT COUNT(*) FROM user_calling_tasks WHERE user_id = ?', [$uid]) === 0);

echo "== start\n";
[$r, $m] = calling_start($row(), $cid);
ok('start ok', $r, $m);
ok('calling_chapter set', (int)$row()['calling_chapter'] === $cid);
[$r2, ] = calling_start($row(), $cid);
ok('start twice is harmless', $r2 && (int)q_val('SELECT COUNT(*) FROM user_calling_tasks WHERE user_id = ?', [$uid]) === 5);
ok('tier still 1 while working', $tier() === 1);
echo '  progress: ', implode(' ', $prog($cid)), "\n";

echo "== events advance tasks\n";
calling_event($uid, 'tend', 'plant', 1, ['kind' => 'vegetable']);
calling_event($uid, 'tend', 'sheet', 3, ['kind' => '']);   // n is ignored by nothing: adds 3
job_event($uid, 'harvest', 'radish', 4, ['kind' => 'vegetable', 'plant' => 'radish', 'bedgrade' => 3, 'helper' => false]);   // grade D: too low
job_event($uid, 'harvest', 'radish', 10, ['kind' => 'vegetable', 'plant' => 'radish', 'bedgrade' => 5, 'helper' => false]);
job_event($uid, 'harvest', 'radish', 4, ['kind' => 'vegetable', 'plant' => 'radish', 'bedgrade' => 5, 'helper' => true]);   // a helper: ignored
job_event($uid, 'craft', 'rock-dust', 2, ['cat' => 'garden']);
job_event($uid, 'craft', 'garden-hoe', 5, ['cat' => 'tools']);   // wrong category
job_event($uid, 'gather', 'moss', 7);
echo '  progress: ', implode(' ', $prog($cid)), "\n";
$p = $prog($cid);
ok('sheet 3/4', $p[1] === '3/4', $p[1]);
ok('harvest 10/15 (low grade and helper ignored)', $p[2] === '10/15', $p[2]);
ok('craft garden 2/3', $p[3] === '2/3', $p[3]);
ok('gather 7/12', $p[4] === '7/12', $p[4]);
calling_event($uid, 'tend', 'sheet', 1, ['kind' => '']);
job_event($uid, 'harvest', 'radish', 20, ['kind' => 'vegetable', 'plant' => 'radish', 'bedgrade' => 9, 'helper' => false]);
job_event($uid, 'craft', 'rock-dust', 9, ['cat' => 'garden']);
job_event($uid, 'gather', 'moss', 99);
$p = $prog($cid);
ok('capped at the goal', $p[1] === '4/4' && $p[2] === '15/15' && $p[3] === '3/3' && $p[4] === '12/12', implode(' ', $p));

echo "== state tasks\n";
$st = calling_status($row(), calling_chapter($cid));
ok('grade task not done yet', !$st['tasks'][0]['done']);
$tile = (int)q_val('SELECT id FROM plot_tiles WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
q("UPDATE plot_tiles SET method = 'notill', bed_score = ? WHERE id = ?", [4 * GRADE_STEP, $tile]);
$st = calling_status($row(), calling_chapter($cid));
ok('grade C bed ticks the state task at once', $st['tasks'][0]['done'], json_encode($st['tasks'][0]['now']));
$npc = q_one("SELECT n.id FROM npcs n JOIN town_spots s ON s.id = n.fav_spot_id WHERE s.region = 'Birchbramble Steppe' LIMIT 1");
ok('a Birchbramble local exists', (bool)$npc);
$st = calling_status($row(), calling_chapter($cid));
ok('friend task not done', !$st['tasks'][5]['done']);
if ($npc) q('INSERT INTO npc_friends (user_id, npc_id, points) VALUES (?, ?, 20)', [$uid, $npc['id']]);
$st = calling_status($row(), calling_chapter($cid));
ok('Acquaintance with a local ticks it', $st['tasks'][5]['done']);
ok('work done, give task next', $st['work_done'] && $st['give_next'] && !$st['complete']);

echo "== hand in\n";
[$r, $m] = calling_hand_in($row(), $cid);
ok('hand-in refused without the goods', !$r, $m);
[$r, $m] = calling_finish($row(), $cid);
ok('finish refused before the hand-in', !$r, $m);
$dust = (int)q_val("SELECT id FROM items WHERE slug = 'rock-dust'"); $comp = (int)q_val("SELECT id FROM items WHERE slug = 'plain-compost'");
ok('hand-in items exist', $dust > 0 && $comp > 0);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $dust, $comp]);   // starter stock would muddy the count
give_item($uid, $dust, 4); give_item($uid, $comp, 2);
[$r, $m] = calling_hand_in($row(), $cid);
ok('2 of 3 compost refused', !$r, $m);
give_item($uid, $comp, 1);
$coins0 = (int)$row()['coins'];
[$r, $m] = calling_hand_in($row(), $cid);
ok('hand-in ok', $r, $m);
ok('items taken', (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id IN (?, ?)', [$uid, $dust, $comp]) === 0);
[$r, $m] = calling_hand_in($row(), $cid);
ok('second hand-in refused', !$r, $m);

echo "== finish\n";
$xp0 = (int)$row()['xp'] ?? 0;
[$r, $m] = calling_finish($row(), $cid);
ok('finish ok', $r, $m);
[$r, $m] = calling_finish($row(), $cid);
ok('finish twice refused', !$r, $m);
$u = $row();
ok('calling_qt = 1', (int)$u['calling_qt'] === 1);
ok('calling_chapter cleared', $u['calling_chapter'] === null);
ok('tier II at L15', calling_tier($u) === 2, (string)calling_tier($u));
q('UPDATE users SET level = 40 WHERE id = ?', [$uid]);
ok('tier stays II at L40 (no tier III chapter yet)', $tier() === 2);
ok('coins paid (+800)', (int)$row()['coins'] === $coins0 + 800, (string)$row()['coins']);
ok('rich-loam x3 paid', (int)q_val("SELECT qty FROM user_items WHERE user_id = ? AND item_id = (SELECT id FROM items WHERE slug = 'rich-loam')", [$uid]) >= 3);
ok('title earned', calling_titles($uid) === ['Soil Tender'], json_encode(calling_titles($uid)));
ok('Almanac page unlocked', (bool)q_val("SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key = 'calling:rootwarden-1'", [$uid]));
ok('tier announced (seen = 2)', (int)$row()['calling_tier_seen'] === 2);
ok('prize queued', !empty($_SESSION['prizes']) && str_contains($_SESSION['prizes'][0]['title'], 'Deep Roots'));
ok('finished chapter: status done', calling_status($row(), calling_chapter($cid))['state'] === 'done');
$p = calling_perk($row(), 'sheet_discount');
ok('tier II perk now live (sheet discount 1)', $p === 1, (string)$p);

echo "== switching callings keeps progress per calling\n";
[$r, $m] = choose_calling($row(), 'bloomcaller');
ok('switch to bloomcaller paid', $r, $m);
ok('bloomcaller: qt 0, tier 1', (int)$row()['calling_qt'] === 0 && $tier() === 1);
[$r, $m] = choose_calling($row(), 'rootwarden');
ok('switch back to rootwarden', $r, $m);
ok('rootwarden: qt back to 1, tier 2', (int)$row()['calling_qt'] === 1 && $tier() === 2);

echo "== other event kinds and filters (test chapter)\n";
q("UPDATE users SET calling = 'bloomcaller', calling_qt = 0, calling_chapter = NULL WHERE id = ?", [$uid]);
q("UPDATE calling_chapters SET title = 'Test bloom', mentor_slug = NULL WHERE id = ?", [$wrong]);
$T = fn(string $mode, string $kind, string $spec, int $qty) => db_insert('calling_tasks', ['chapter_id' => $wrong, 'sort_order' => 1 + (int)q_val('SELECT COUNT(*) FROM calling_tasks WHERE chapter_id = ?', [$wrong]), 'mode' => $mode, 'kind' => $kind, 'spec' => $spec, 'qty' => $qty, 'label' => "$kind $spec"]);
$tPage = $T('event', 'page', 'slug^=creature:,distinct=1', 2);
$tDish = $T('event', 'cook', 'tier=meal/feast,distinct=1', 3);
$tEat = $T('event', 'eat', 'homecooked=1', 2);
$tDepth = $T('event', 'depth', '', 5);
$tDrink = $T('event', 'townact', 'slug$=-drink', 2);
$tSell = $T('event', 'sell', 'cat=flower', 10);
$tBig = $T('event', 'defeat', 'size=large/boss,peaceful=0', 2);
$tWalk = $T('event', 'walk', 'kind=road', 3);
$tRegion = $T('state', 'regions', '', 1);
$tRec = $T('state', 'recipes', '', 1);
q('UPDATE users SET level = 40 WHERE id = ?', [$uid]);
[$r, $m] = calling_start($row(), $wrong);
ok('test chapter starts', $r, $m);
db_insert('encyclopedia_entries', ['chapter' => 'Creatures', 'category' => 'Creatures', 'title' => 'Mole', 'body' => '', 'unlock_key' => 'creature:t-mole', 'hint' => '', 'sort_order' => 1]);
db_insert('encyclopedia_entries', ['chapter' => 'Creatures', 'category' => 'Creatures', 'title' => 'Vole', 'body' => '', 'unlock_key' => 'creature:t-vole', 'hint' => '', 'sort_order' => 2]);
db_insert('encyclopedia_entries', ['chapter' => 'Gathering', 'category' => 'Gathering', 'title' => 'Moss', 'body' => '', 'unlock_key' => 'gather:t-moss', 'hint' => '', 'sort_order' => 1]);
unlock_entries($uid, 'creature:t-mole'); unlock_entries($uid, 'gather:t-moss'); unlock_entries($uid, 'creature:t-mole');
$g = fn(int $tid) => (int)q_val('SELECT progress FROM user_calling_tasks WHERE user_id = ? AND task_id = ?', [$uid, $tid]);
ok('page: only creature: keys, once each', $g($tPage) === 1, (string)$g($tPage));
unlock_entries($uid, 'creature:t-vole');
ok('page: second creature', $g($tPage) === 2);
job_event($uid, 'cook', 'stew', 1, ['tier' => 'meal']); job_event($uid, 'cook', 'stew', 1, ['tier' => 'meal']); job_event($uid, 'cook', 'tea', 3, ['tier' => 'snack']); job_event($uid, 'cook', 'pie', 1, ['tier' => 'feast']);
ok('cook: distinct meals, snacks never count', $g($tDish) === 2, (string)$g($tDish));
job_event($uid, 'eat', 'stew', 1, ['homecooked' => true, 'tier' => 'meal']); job_event($uid, 'eat', 'radish', 1, ['homecooked' => false, 'tier' => null]); job_event($uid, 'eat', 'tea', 1, ['homecooked' => true, 'tier' => 'snack']);
ok('eat: only a home-cooked meal', $g($tEat) === 1, (string)$g($tEat));
calling_event($uid, 'depth', '', 2); calling_event($uid, 'depth', '', 4); calling_event($uid, 'depth', '', 3);
ok('depth keeps the highest', $g($tDepth) === 4, (string)$g($tDepth));
calling_event($uid, 'townact', 'ma-dance', 1, []); calling_event($uid, 'townact', 'mm-drink', 1, []);
ok('townact suffix filter', $g($tDrink) === 1, (string)$g($tDrink));
calling_event($uid, 'sell', 'rose', 6, ['cat' => 'flower']); calling_event($uid, 'sell', 'bun', 6, ['cat' => 'food']);
ok('sell category filter', $g($tSell) === 6, (string)$g($tSell));
job_event($uid, 'defeat', 'bear', 1, ['size' => 'large', 'peaceful' => 0]); job_event($uid, 'defeat', 'bear', 1, ['size' => 'large', 'peaceful' => 1]); job_event($uid, 'defeat', 'rat', 1, ['size' => 'small', 'peaceful' => 0]);
ok('defeat: size + fights only', $g($tBig) === 1, (string)$g($tBig));
calling_event($uid, 'walk', 'road', 1, ['kind' => 'road']); calling_event($uid, 'walk', 'side', 1, ['kind' => 'side']);
ok('walk: road legs only', $g($tWalk) === 1, (string)$g($tWalk));
$st = calling_status($row(), calling_chapter($wrong));
ok('state: regions + recipes read live', isset($st['tasks'][8]) && $st['tasks'][8]['goal'] === 1, json_encode($st['tasks'][8] ?? null));

echo "== real garden path emits events\n";
$tTend = $T('event', 'tend', 'slug=plant,kind=vegetable', 1);
$tWater = $T('event', 'water', '', 1);
[$r, $m] = calling_start($row(), $wrong);   // re-start adds rows for the new tasks
$seed = (int)q_val("SELECT id FROM items WHERE slug = 'radish-seed'");
give_item($uid, $seed, 2);
q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
$x = (int)q_val('SELECT x FROM plot_tiles WHERE user_id = ? AND id <> ? ORDER BY id LIMIT 1', [$uid, $tile]); $y = (int)q_val('SELECT y FROM plot_tiles WHERE user_id = ? AND id <> ? ORDER BY id LIMIT 1', [$uid, $tile]);
foreach ([['till', 0], ['plant', $seed], ['water', 0]] as [$act, $item]) { [$okA, $mA] = garden_action($uid, $act, $x, $y, $item); if (!$okA) echo "    $act: ", implode(' ', $mA), "\n"; }
ok('garden plant emits tend (kind vegetable)', $g($tTend) === 1, (string)$g($tTend));
ok('garden water emits water', $g($tWater) === 1, (string)$g($tWater));

echo "== migration (veterans lose the tier, no grace)\n";
q("UPDATE users SET calling = 'rootwarden', calling_qt = 2, calling_tier_seen = 3, level = 30, calling_chapter = $cid WHERE id = ?", [$uid]);
upgrade_094_callings(); calling_qt_cached($uid, true);
ok('qt 0, no open chapter, tier 1, announced tier reset', (int)$row()['calling_qt'] === 0 && $row()['calling_chapter'] === null && $tier() === 1 && (int)$row()['calling_tier_seen'] === 1);
echo "== content: all 12 chapters, no unknown kinds, mentors\n";
$fileT = []; $fileC = [];
foreach (catalog_lines('calling_quests.txt') as $r) { if ($r[0] === 'C') $fileC[$r[1]] = $r; elseif ($r[0] === 'T') $fileT[$r[1]][] = $r; }
ok('12 chapters in the file and the game', count($fileC) === 12 && (int)q_val("SELECT COUNT(*) FROM calling_chapters WHERE slug <> 't-bloom'") === 12, (string)count($fileC));
$callings = []; $badKinds = []; $badItems = [];
foreach ($fileC as $slug => $r) {
    $c = q_one('SELECT * FROM calling_chapters WHERE slug = ?', [$slug]);
    $callings[$r[2]][] = (int)$r[3];
    $n = count($fileT[$slug] ?? []);
    if (!$c || count(calling_tasks((int)$c['id'])) !== $n || $n < 6) $badKinds[] = $slug . ' (' . ($c ? count(calling_tasks((int)$c['id'])) : 'missing') . '/' . $n . ')';
    foreach ($fileT[$slug] ?? [] as $t) {
        if ($t[3] === 'give') foreach (journey_needs((string)$t[5]) as [$type, $islug]) if ($type === 'item' && !q_val('SELECT 1 FROM items WHERE slug = ?', [$islug])) $badItems[] = $slug . ':' . $islug;
    }
    if ($c && $c['reward_item_slug'] && !q_val('SELECT 1 FROM items WHERE slug = ?', [$c['reward_item_slug']])) $badItems[] = $slug . ' reward ' . $c['reward_item_slug'];
    // the last task is the only give task
    $last = end($fileT[$slug]);
    if ($last[2] !== 'give' || count(array_filter($fileT[$slug], fn($t) => $t[2] === 'give')) !== 1) $badKinds[] = $slug . ' give-last';
    if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['calling:' . $slug])) $badKinds[] = $slug . ' no Almanac page';
}
ok('every task imported (no unknown kind or mode)', !$badKinds, implode(', ', $badKinds));
ok('every hand-in and reward item exists', !$badItems, implode(', ', $badItems));
ok('each calling has a tier II and a tier III chapter', count($callings) === 6 && !array_filter($callings, fn($t) => $t !== [2, 3]), json_encode($callings));
$mfail = [];
foreach (CALLING_MENTORS as $calling => $m) {
    $npc = calling_mentor($calling);
    $chs = q('SELECT DISTINCT mentor_slug FROM calling_chapters WHERE calling = ? AND slug <> ?', [$calling, 't-bloom'])->fetchAll(PDO::FETCH_COLUMN);
    $spot = q_one('SELECT * FROM town_spots WHERE slug = ?', [$m[6]]);
    $sch = $npc ? q_one('SELECT * FROM npc_schedules WHERE npc_id = ?', [$npc['id']]) : null;
    $link = $spot ? q_one("SELECT * FROM town_actions WHERE spot_id = ? AND kind = 'link'", [$spot['id']]) : null;
    $town = (string)q_val('SELECT gnomish_name FROM regions WHERE code = ?', [$m[5]]);
    if (!$npc || $chs !== [$m[1]] || !$spot || $spot['region'] !== $town || !$sch || (int)$sch['start_hour'] !== (int)$sch['end_hour'] || (int)$sch['spot_id'] !== (int)$spot['id'] || !$link || !str_contains((string)$link['link'], 'mentor.php')) $mfail[] = $calling;
}
ok('6 mentors: NPC, lodge in their town, all-day schedule, link, chapters point to them', !$mfail, implode(',', $mfail));
$before = [(int)q_val('SELECT COUNT(*) FROM npcs'), (int)q_val('SELECT COUNT(*) FROM town_spots'), (int)q_val('SELECT COUNT(*) FROM npc_schedules'), (int)q_val('SELECT COUNT(*) FROM town_actions')];
ok('ensure_calling_mentors is idempotent', ensure_calling_mentors() === 0 && $before === [(int)q_val('SELECT COUNT(*) FROM npcs'), (int)q_val('SELECT COUNT(*) FROM town_spots'), (int)q_val('SELECT COUNT(*) FROM npc_schedules'), (int)q_val('SELECT COUNT(*) FROM town_actions')]);
require_once $argv[1] . '/includes/npc_life.php';
$bur = calling_mentor('rootwarden');
ok('mentor is at the lodge now (npc_now)', str_contains(npc_now($bur)['what'], 'Root Cellar'), npc_now($bur)['what']);
ok('ensure_npc_lives leaves mentors alone', (function () use ($bur) { ensure_npc_lives(); return (int)q_val('SELECT COUNT(*) FROM npc_schedules WHERE npc_id = ?', [$bur['id']]) === 1; })());
require_once $argv[1] . '/includes/calling_view.php';
require_once $argv[1] . '/includes/npc_life.php';
ok('Today and My Gnome lines render', is_string(calling_today_line($row())) && str_contains(calling_gnome_line($row()), 'Burdock'));
$news = file_get_contents($argv[1] . '/includes/update_news.php');
ok('news post 0.9.4 exists (callings + cooking)', str_contains($news, "'0.9.4' => [") && str_contains($news, 'Brewroot III') && str_contains($news, 'Burdock Deepdelve'));

echo "\n", $fails ? "$fails FAILED" : 'all passed', "\n";
exit($fails ? 1 : 0);

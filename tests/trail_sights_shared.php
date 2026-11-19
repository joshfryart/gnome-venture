<?php
// Sights sixth pass B: Sights shared across players (game/includes/trail_sights_6.php): the cairn count, notes between players in the message bottle, chalk words on the stones.
// php tests/trail_sights_shared.php GAME_DIR   (an installed game, player "sprout"; ci_suites.sh installs one first). A second and third player are cloned from sprout.
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/shelves.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; echo "FAILED\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function clone_user(string $name): int {
    $r = q_one("SELECT * FROM users WHERE username = 'sprout'"); unset($r['id']);
    $r['username'] = $name; $r['email'] = $name . '@b.local'; $r['gnome_name'] = 'Gnome ' . $name; $r['active_plot_id'] = null; $r['last_seen'] = now();
    return db_insert('users', $r);
}
$row = fn(int $id) => q_one('SELECT * FROM users WHERE id = ?', [$id]);
$A = (int)q_val("SELECT id FROM users WHERE username = 'sprout'"); $B = clone_user('sgB'); $C = clone_user('sgC');
sights6_ensure(); trail_sights_ensure_items();
$bottle = (int)item_id_by_slug('message-bottle');
$qty = fn(int $uid, string $slug) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)item_id_by_slug($slug)]);
$setBottles = function (int $uid, int $n) use ($bottle) { q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $bottle]); if ($n) give_item($uid, $bottle, $n); };
$wipe = function () use ($A, $B, $C, $setBottles) { foreach ([$A, $B, $C] as $x) $setBottles($x, 5); q('DELETE FROM sights_shared_items'); q('DELETE FROM sights_shared_reports'); q('DELETE FROM sights_shared_tally'); };

echo "== the feature is off by default\n";
$wipe();
ok('setting sights_shared_on defaults to 0', setting('sights_shared_on') === '0' && !sights6_on());
[$a, $m] = sights6_note_send($row($A), 'hello there');
ok('off: a note cannot be sent, no bottle used', !$a && $qty($A, 'message-bottle') === 5, $m);
ok('off: the cairn hook adds nothing', sights6_tally_hook($row($A), 'cairn-stones') === [] && sights6_tally('cairn-pass') === 0);
ok('off: the Satchel and Trail show nothing', sights6_satchel_acts(['slug' => 'message-bottle'], '', $A) === [] && sights6_chalk_input() === '' && sights6_chalk_after($row($A), 'x', 'hi') === '');
set_setting('sights_shared_on', '1'); setting('__reload__');

echo "== the shared cairn\n";
$l1 = sights6_tally_hook($row($A), 'cairn-stones'); $l2 = sights6_tally_hook($row($B), 'cairn-stones');
ok('each stone from any player adds one to the shared count, shown to both', sights6_tally('cairn-pass') === 2 && str_contains($l1[0], 'number 1') && str_contains($l2[0], 'number 2') && sights6_cairn_count() === 2);
ok('another tally key is not shared', sights6_tally_hook($row($A), 'cairns') === [] && sights6_tally('cairn-pass') === 2);
ok('the real cairn Sight row pays the tally key and the engine calls the hook', str_contains(trail_sights_all()['mountain-the-cairn-pass']['rewards'], 'tally=cairn-stones') && str_contains((string)file_get_contents($argv[1] . '/includes/trail_sights.php'), 'sights6_tally_hook'));

echo "== a note travels to another player\n";
[$a, $m] = sights6_note_send($row($A), 'Be kind to the toads <b>today</b>');
ok('A sends a note: a bottle is used, tags are stripped', $a && $qty($A, 'message-bottle') === 4 && q_val("SELECT body FROM sights_shared_items WHERE kind = 'note'") === 'Be kind to the toads today', $m);
[$a, $m] = sights5_use_item($row($A), $bottle);
ok('A opening a bottle does NOT get their own note (falls back to the old bottle post)', $a && !str_contains($m, 'stranger') && $qty($A, 'stranger-note') === 0 && (int)q_val('SELECT COUNT(*) FROM sights_shared_items WHERE to_user IS NOT NULL') === 0, $m);
ok('A cannot take their own note', sights6_note_take($A) === null && sights6_bottle_stranger($row($A), 100) === []);
[$a, $m] = sights5_use_item($row($B), $bottle);
ok('B opening a bottle reads A\'s note, as a stranger, with no name', $a && str_contains($m, 'Be kind to the toads today') && str_contains($m, 'stranger') && !str_contains($m, 'sprout') && !str_contains($m, 'Gnome ') && $qty($B, 'stranger-note') === 1, $m);
ok('the note is delivered once: C finds nothing, the old bottle post runs', sights6_note_take($C) === null && (int)q_val('SELECT to_user FROM sights_shared_items') === $B);
$acts = implode('', sights6_satchel_acts(['slug' => 'stranger-note'], '', $B));
ok('B\'s Satchel lists the note with a Report button; A\'s does not', str_contains($acts, 'Be kind to the toads today') && str_contains($acts, 'name="do" value="report"') && !implode('', sights6_satchel_acts(['slug' => 'stranger-note'], '', $A)));
ok('the message bottle has a send form in the Satchel', str_contains(implode('', sights6_satchel_acts(['slug' => 'message-bottle'], '', $A)), 'name="text"'));
$wipe(); sights6_note_send($row($A), 'a coast note');
ok('the coast bottle=1 Sight can deliver a stranger note too (pct 100)', ($ln = sights6_bottle_stranger($row($B), 100)) && str_contains($ln[0], 'a coast note') && !sights6_bottle_stranger($row($C), 100));

echo "== length, escape, links, words\n";
$wipe(); $before = $qty($A, 'message-bottle');
[$a, $m] = sights6_note_send($row($A), str_repeat('x', 81));
ok('81 characters: refused, no bottle used, nothing stored', !$a && $qty($A, 'message-bottle') === $before && (int)q_val('SELECT COUNT(*) FROM sights_shared_items') === 0, $m);
ok('80 characters is fine', sights6_note_send($row($A), str_repeat('y', 80))[0]);
foreach (['visit http://spam.example', 'mail me a@b.co', 'call 5551234567', 'you are a bitch', '   '] as $bad) ok('refused: ' . trim($bad), !sights6_note_send($row($B), $bad)[0]);
[$t, $e] = sights6_clean("<script>alert(1)</script>Hi\n\n  there\x07"); ok('tags, control characters and spaces are cleaned', $e === '' && $t === 'alert(1)Hi there', $t);
$wipe(); sights6_note_send($row($A), '"quoted" & <i>fine</i>');
sights6_note_take($B); $acts = implode('', sights6_satchel_acts(['slug' => 'stranger-note'], '', $B));
ok('output is escaped', str_contains($acts, '&quot;quoted&quot; &amp; fine') && !str_contains($acts, '<i>'));

echo "== rate limit\n";
$wipe(); $setBottles($C, 9); $okN = 0; for ($i = 0; $i < 5; $i++) if (sights6_note_send($row($C), 'note ' . $i)[0]) $okN++;
ok('3 notes a day, then refused (bottles kept)', $okN === SIGHTS6_NOTES_PER_DAY && $qty($C, 'message-bottle') === 9 - SIGHTS6_NOTES_PER_DAY);
[$a, $m] = sights6_note_send($row($C), 'one more'); ok('the message says why', !$a && str_contains($m, 'tomorrow'), $m);
q('UPDATE sights_shared_items SET created_at = ?', [gmdate('Y-m-d H:i:s', time() - 2 * 86400)]);
ok('the next day it works again', sights6_note_send($row($C), 'fresh day')[0]);
$setBottles($B, 0); ok('no bottle, no note', !sights6_note_send($row($B), 'hi')[0]);
$setBottles($B, 5);

echo "== report and hide\n";
$wipe(); sights6_note_send($row($A), 'unkind-ish words'); $n = sights6_note_take($B); $id = (int)$n['id'];
ok('only the receiver may report a note (C and the author cannot)', !sights6_report($row($C), $id)[0] && !sights6_report($row($A), $id)[0]);
[$a, $m] = sights6_report($row($B), $id);
ok('B reports: the note hides at once and is not listed any more', $a && (int)q_val('SELECT hidden FROM sights_shared_items WHERE id = ?', [$id]) === 1 && !sights6_notes_for($B), $m);
ok('a second report by the same gnome is harmless', sights6_report($row($B), $id)[0] && (int)q_val('SELECT COUNT(*) FROM sights_shared_reports') === 1);
sights6_note_send($row($A), 'hidden waiting'); q("UPDATE sights_shared_items SET hidden = 1 WHERE body = 'hidden waiting'");
ok('a hidden note is never delivered', sights6_note_take($C) === null);
ok('admin: unhide makes it deliverable, delete removes it, clear removes the reports', str_contains(sights6_admin_act($id, 'unhide'), 'Done') && (int)q_val('SELECT hidden FROM sights_shared_items WHERE id = ?', [$id]) === 0
    && str_contains(sights6_admin_act($id, 'clear'), 'Done') && (int)q_val('SELECT COUNT(*) FROM sights_shared_reports') === 0 && (int)q_val('SELECT reports FROM sights_shared_items WHERE id = ?', [$id]) === 0
    && str_contains(sights6_admin_act($id, 'delete'), 'Done') && !q_val('SELECT 1 FROM sights_shared_items WHERE id = ?', [$id]));
$wipe(); sights6_note_send($row($A), 'for review'); sights6_note_take($B); sights6_report($row($B), (int)q_val('SELECT id FROM sights_shared_items'));
$rows = sights6_admin_rows('reported'); ok('admin reported list: the item, with author and receiver names', count($rows) === 1 && $rows[0]['author'] === 'sprout' && $rows[0]['receiver'] === 'sgB');
$held = $qty($B, 'stranger-note');
ok('put away removes one note item and marks the note', sights6_putaway($row($B), (int)$rows[0]['id'])[0] && $qty($B, 'stranger-note') === $held - 1 && !sights6_putaway($row($B), (int)$rows[0]['id'])[0]);

echo "== chalk words\n";
$wipe(); $P = SIGHTS5_STONES;
$m1 = sights6_chalk_after($row($A), $P, 'Look up, friend'); sights6_chalk_after($row($B), $P, ''); sights6_chalk_after($row($B), $P, 'see you <b>here</b>');
ok('chalking counts for everyone and writes the words', str_contains($m1, '1 gnomes in all') && sights6_tally('chalk-' . $P) === 3 && (int)q_val("SELECT COUNT(*) FROM sights_shared_items WHERE kind = 'mark'") === 2);
$seenC = array_column(sights6_marks_at($C, $P), 'body'); $seenA = array_column(sights6_marks_at($A, $P), 'body');
ok('C sees both marks; A does not see their own', in_array('Look up, friend', $seenC) && in_array('see you here', $seenC) && !in_array('Look up, friend', $seenA) && in_array('see you here', $seenA));
$mid = (int)q_val("SELECT id FROM sights_shared_items WHERE body = 'Look up, friend'");
sights6_report($row($B), $mid); ok('one report on a mark: still shown, two: hidden', in_array('Look up, friend', array_column(sights6_marks_at($C, $P), 'body'))); sights6_report($row($C), $mid);
ok('two reports hide the mark for everyone', !in_array('Look up, friend', array_column(sights6_marks_at($C, $P), 'body')));
ok('a bad word is not written but the chalk still counts', str_contains(sights6_chalk_after($row($C), $P, 'you bitch'), 'not written') && sights6_tally('chalk-' . $P) === 4 && (int)q_val("SELECT COUNT(*) FROM sights_shared_items WHERE kind = 'mark'") === 2);
$k = 0; for ($i = 0; $i < 8; $i++) sights6_chalk_after($row($C), $P, 'word ' . $i);
ok('marks are rate limited per day', (int)q_val("SELECT COUNT(*) FROM sights_shared_items WHERE kind = 'mark' AND user_id = ?", [$C]) === SIGHTS6_MARKS_PER_DAY);

echo "== the text switch\n";
set_setting('sights_shared_text', '0'); setting('__reload__');
ok('text off: no send, no marks shown, no chalk input; counts still work', !sights6_note_send($row($A), 'hi')[0] && sights6_marks_at($C, $P) === [] && sights6_chalk_input() === '' && sights6_tally_hook($row($A), 'cairn-stones') !== []);
$wipe(); set_setting('sights_shared_text', '1'); set_setting('sights_shared_on', '0'); setting('__reload__');
ok('master off again: a bottle with no stranger falls back (bottle open is null)', sights6_bottle_open($row($A), $bottle) === null);
set_setting('sights_shared_on', '1'); setting('__reload__');
ok('single player: no other note waiting means the old bottle post runs', sights6_bottle_open($row($A), $bottle) === null);

echo "== wiring and files\n";
$src = fn(string $f) => (string)file_get_contents($argv[1] . '/' . $f);
ok('hooks are in place', str_contains($src('includes/trail_sights_5.php'), 'sights6_chalk_after') && str_contains($src('includes/trail_sights_5.php'), 'sights6_bottle_open') && str_contains($src('includes/trail_sights_5.php'), 'sights6_trailfoot_html')
    && str_contains($src('includes/trail_sight_third_b.php'), 'sights6_bottle_stranger') && str_contains($src('includes/shelves.php'), 'sights6_satchel_acts') && str_contains($src('includes/schema.php'), 'sights6_schema') && str_contains($src('includes/functions.php'), 'sights6_settings'));
ok('the endpoint, the admin page and the menu entry exist', is_file($argv[1] . '/sights_shared.php') && is_file($argv[1] . '/admin/sights_shared.php') && str_contains($src('includes/admin_menu.php'), 'sights_shared.php'));
ok('no inline style in the new markup', !str_contains($src('includes/trail_sights_6.php'), 'style=') && !str_contains($src('admin/sights_shared.php'), 'style='));
[$t] = sights6_schema('INTEGER PRIMARY KEY AUTOINCREMENT', 'INTEGER', ''); ok('schema gives three tables', count($t) === 3);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);

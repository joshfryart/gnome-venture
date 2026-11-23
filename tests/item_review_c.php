<?php
// Item review leftovers (2.7.58): EC4 yearly festival, Tool Repair Kit text, Job Board part-family rows (deliver_part), family icons on recipe ingredients, augment emoji fallback.
// php tests/item_review_c.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/jobs.php';
require $argv[1] . '/includes/bootstrap.php';
foreach (['festival', 'jobs', 'parts', 'crafting', 'items', 'upgrade2758', 'pfdeck', 'augments'] as $f) require_once $argv[1] . '/includes/' . $f . '.php';
$fails = 0;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function mk(string $slug, string $cat, int $rar, int $price): int { return item_id_by_slug($slug) ?: (int)db_insert('items', ['name' => ucwords(str_replace('-', ' ', $slug)), 'slug' => $slug, 'category' => $cat, 'rarity' => $rar, 'base_price' => $price, 'description' => 'test', 'edible' => 0, 'tradable' => 1]); }
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id'];
$today = gclock_my_date(); $day = fn(int $n) => gmdate('Y-m-d', strtotime($today . ' UTC') + $n * 86400);

function sset(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
echo "== EC4 yearly festival\n";
ok('shift keeps month and day', festival_shift_year('2026-03-05', 1) === '2027-03-05' && festival_shift_year('2024-02-29', 1) === '2025-02-28' && festival_shift_year('2024-02-29', 4) === '2028-02-29');
sset('fest_opening_day_yearly', '1');
sset('fest_opening_day_start', $day(-400)); sset('fest_opening_day_end', $day(-394));
$w = festival_window('opening_day');
$len = (strtotime($w[1] . ' UTC') - strtotime($w[0] . ' UTC')) / 86400;
ok('a finished window comes round again, next occurrence not in the past', $w && $w[1] >= $today && $len == 6 && substr($w[0], 5) === substr($day(-400), 5), json_encode($w));
ok('and it is within a year', $w[0] <= $day(366), json_encode($w));
$p = festival_window('opening_day', true);
ok('the past occurrence is the one before', $p && $p[1] < $today && festival_shift_year($p[1], 1) === $w[1], json_encode($p));
sset('fest_opening_day_start', $day(-3)); sset('fest_opening_day_end', $day(3));
ok('a window in progress is unchanged', festival_window('opening_day') === [$day(-3), $day(3)] && festival_window('opening_day', true) === null);
sset('fest_opening_day_start', $day(10)); sset('fest_opening_day_end', $day(12));
ok('a future window is unchanged', festival_window('opening_day') === [$day(10), $day(12)]);
sset('fest_opening_day_start', $day(-400)); sset('fest_opening_day_end', $day(-394)); sset('fest_opening_day_yearly', '0');
ok('yearly off: the old window stays old', festival_window('opening_day') === [$day(-400), $day(-394)] && festival_window('opening_day', true) === [$day(-400), $day(-394)]);
ok('the admin has a yearly setting', isset(social100_settings()['fest_opening_day_yearly']));
sset('fest_opening_day_yearly', '1');
// a run a year on is a new run key
$a = festival_window('opening_day');
sset('fest_opening_day_run', festival_shift_year($a[0], -1) . '|opening_day');
ok('the next year is a new run key', festival_run_key(['slug' => 'opening_day', 'starts' => $a[0]]) === 'opening_day@' . $a[0]);
sset('fest_opening_day_start', $day(-3)); sset('fest_opening_day_end', $day(5)); sset('fest_opening_day_run', '');

echo "== Tool Repair Kit text\n";
ok('the kit text names garden and gathering tools and the order', str_contains(PFD_REPAIR_ITEM[3], 'garden and gathering tools') && strpos(PFD_REPAIR_ITEM[3], 'Tool Shed') < strpos(PFD_REPAIR_ITEM[3], 'kits') && strpos(PFD_REPAIR_ITEM[3], 'kits') < strpos(PFD_REPAIR_ITEM[3], 'Petals'));
$old = 'Flint, resin and a twist of fibre. Fixes one fight tool on your Puzzle box belt: its piece is worn out by fights (2 each time it is played) and comes back at full strength.';
pfd_ensure_content();
q("UPDATE items SET description = ? WHERE slug = 'tool-repair-kit'", [$old]);
upgrade_2758_kit_text();
ok('an old-text world is updated', (string)q_val("SELECT description FROM items WHERE slug = 'tool-repair-kit'") === PFD_REPAIR_ITEM[3]);
q("UPDATE items SET description = 'Admin wording' WHERE slug = 'tool-repair-kit'");
upgrade_2758_kit_text();
ok('an admin edit is kept', (string)q_val("SELECT description FROM items WHERE slug = 'tool-repair-kit'") === 'Admin wording');
q("UPDATE items SET description = ? WHERE slug = 'tool-repair-kit'", [PFD_REPAIR_ITEM[3]]);

echo "== Job Board part rows\n";
ensure_jobs();
$rows = q("SELECT * FROM job_templates WHERE kind = 'deliver_part'")->fetchAll();
ok('deliver_part rows exist with valid tokens', count($rows) >= 3 && !array_filter($rows, fn($r) => part_key((string)$r['part_token']) === null), json_encode(array_column($rows, 'part_token')));
$n0 = (int)q_val('SELECT COUNT(*) FROM job_templates');
ensure_jobs();
ok('ensure_jobs is insert-only (a second run adds nothing)', (int)q_val('SELECT COUNT(*) FROM job_templates') === $n0);
ok('a bad token is refused', !job_part_token_ok('any-bogus') && !job_part_token_ok('wolf-pelt') && job_part_token_ok('rare-wing'));
$p1 = mk('zj-pelt', 'part', 10, 5); $p2 = mk('zj-fur', 'part', 20, 9); $p3 = mk('zj-hide', 'part', 60, 3);
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?,?,?)', [$uid, $p1, $p2, $p3]);
q("DELETE FROM user_jobs WHERE user_id = ? AND period = 'daily'", [$uid]);
$tpl = q_one("SELECT * FROM job_templates WHERE kind = 'deliver_part' AND part_token = 'any-hide'");
$ctx = ['seen' => [], 'npcs' => ['Wren'], 'early' => false, 'scale' => 1.0];
ok('not offered before the gnome has met a part of the family', job_from_template($tpl, $ctx, new JobRng('a')) === null);
$ctx['seen'] = ['zj-pelt' => true];
$job = job_from_template($tpl, $ctx, new JobRng('a'));
ok('offered once met, naming the family', $job && $job['kind'] === 'deliver_part' && $job['target'] === 'any-hide' && $job['target_name'] === 'any Hide part' && $job['target_item_id'] === 0 && str_contains($job['text'], '× any Hide part'), json_encode($job));
// take it and hand parts in: cheapest first, rare last
give_item($uid, $p1, 2); give_item($uid, $p2, 1); give_item($uid, $p3, 1);
db_insert('user_jobs', ['user_id' => $uid, 'period' => 'daily', 'period_key' => job_board_key('daily', $uid), 'template_id' => (int)$tpl['id'], 'kind' => 'deliver_part', 'title' => 'T', 'text' => 't', 'npc' => 'Wren',
    'target' => 'any-hide', 'target_item_id' => null, 'target_name' => 'any Hide part', 'qty' => 3, 'progress' => 0, 'stages' => 1, 'reward_coins' => 10, 'reward_xp' => 1, 'status' => 'active', 'taken_at' => now()]);
$cj = current_job($uid, 'daily');
ok('the board counts the family', job_deliver_stock($uid, $cj)['have'] === 4);
$c0 = (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
[$okd, $msg] = deliver_job($uid, 'daily');
$h = fn(int $id) => (int)q_val('SELECT COALESCE(SUM(qty),0) FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
ok('handing in takes 3, cheapest first, rare kept', $okd && $h($p1) === 0 && $h($p2) === 0 && $h($p3) === 1, $msg . ' ' . json_encode([$h($p1), $h($p2), $h($p3)]));
ok('the job is done and paid', (string)q_val("SELECT status FROM user_jobs WHERE user_id = ? AND period = 'daily'", [$uid]) === 'done' && (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]) === $c0 + 10);
[$okd2] = deliver_job($uid, 'daily');
ok('nothing more to hand in', !$okd2);
q("DELETE FROM user_jobs WHERE user_id = ? AND period = 'daily'", [$uid]);

echo "== family icons\n";
ok('every family has an icon', array_keys(PART_FAMILY_ICONS) === array_keys(PART_FAMILIES) && !in_array('', PART_FAMILY_ICONS, true));
ok('any-/rare- keys get the family icon, normal slugs none', part_family_icon('any-hide') === '🐾' && part_family_icon('rare-wing') === '🪶' && part_family_icon('flint') === null && part_family_icon('any-bogus') === null);
$src = (string)file_get_contents($argv[1] . '/includes/pantry_view.php') . (string)file_get_contents($argv[1] . '/includes/shelves.php');
ok('the recipe cards use the family icon before the placeholder', substr_count($src, 'part_family_icon(') >= 5);

echo "== augment emoji\n";
foreach (AUG_DEFS as $slug => $d) {
    $e = item_emoji(['id' => 0, 'slug' => $slug, 'name' => $d[0], 'category' => 'supply']);
    ok("$slug shows its family icon", $e === PART_FAMILY_ICONS[$d[1]], $e);
}
ok('other supplies are unchanged', item_emoji(['id' => 0, 'slug' => 'zz-box', 'name' => 'Zz Box', 'category' => 'supply']) !== '');

echo $fails ? "FAILED ($fails)\n" : "ok\n";
exit($fails ? 1 : 0);

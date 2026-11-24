<?php
// Item review leftovers (2.7.58): EC4 yearly festival, Tool Repair Kit text, Job Board part-family rows (deliver_part), family icons on recipe ingredients, augment emoji fallback.
// php tests/item_review_c.php GAME_DIR (installed game with player "sprout").
$_SERVER['SCRIPT_NAME'] = '/jobs.php';
require $argv[1] . '/includes/bootstrap.php';
foreach (['festival', 'jobs', 'parts', 'crafting', 'items', 'upgrade2758', 'pfdeck', 'augments', 'tea', 'stops'] as $f) require_once $argv[1] . '/includes/' . $f . '.php';
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

echo "== group C: R8 / R15 merged parts\n";
$data = fn(string $f) => (string)file_get_contents($argv[1] . '/includes/data/' . $f);
$allData = $data('pf_creatures.txt') . $data('creatures.txt') . $data('trek_creatures_ch3.txt') . $data('road_events.txt') . $data('stop_acts_waves.txt') . $data('stop_acts_regional.txt') . $data('trail_sights_maplewold.txt')
    . (string)file_get_contents($argv[1] . '/includes/adventure_data.php') . (string)file_get_contents($argv[1] . '/includes/pfight_data.php');
foreach (['skink-scale', 'Skink Scale', 'Glass Wyrm Scale', 'Giant Otter Pelt', 'Kelp Frond', 'kelp-frond', 'Shale Chip', 'shale-chip', 'Sawdust Heap'] as $gone) ok("no data row still names $gone", !str_contains($allData, $gone));
ok('the skink shoal drops one Lizard Scale entry', preg_match('/^sandfish-skink-shoal\|.*\|Lizard Scale:55,Pink Sand/m', $data('pf_creatures.txt')) === 1);
ok('the sea slug has one Bladderwrack entry (the gated twin is gone)', preg_match('/^sea-slug-drift\|.*Frill:55,Bladderwrack:40,Seed Pearl/m', $data('pf_creatures.txt')) === 1);
$mkc = fn(string $slug) => (int)(q_val('SELECT id FROM creatures WHERE slug = ?', [$slug]) ?: db_insert('creatures', ['slug' => $slug, 'name' => ucwords(str_replace('-', ' ', $slug)), 'size' => 'small', 'landscapes' => 'coast', 'level' => 3, 'hp' => 9, 'attack' => 1, 'defense' => 9, 'dmg_die' => 4, 'dmg_bonus' => 0, 'xp' => 5, 'description' => 'test']));
$cA = $mkc('zz-merge-a'); $cB = $mkc('zz-merge-b'); $cC = $mkc('zz-merge-c');
$old = mk('skink-scale', 'part', 40, 20); $new = mk('lizard-scale', 'part', 40, 20);
$kelp = mk('kelp-frond', 'forage', 15, 12); $brad = mk('bladderwrack', 'forage', 15, 12);
$sh = mk('shale-chip', 'part', 30, 10);   // no slate-shard row yet in this test world? (it is a gatherable; mk keeps an existing one)
$saw = mk('sawdust-heap', 'part', 30, 10);
q('DELETE FROM creature_drops WHERE creature_id IN (?, ?, ?)', [$cA, $cB, $cC]);
db_insert('creature_drops', ['creature_id' => $cA, 'item_id' => $old, 'chance' => 55]);
db_insert('creature_drops', ['creature_id' => $cA, 'item_id' => $new, 'chance' => 40]);   // both on one creature: one row, the higher chance
db_insert('creature_drops', ['creature_id' => $cB, 'item_id' => $kelp, 'chance' => 40]);
db_insert('creature_drops', ['creature_id' => $cB, 'item_id' => $brad, 'chance' => 22, 'reg' => 'CB/SE']);   // the old row is ungated: the merged one is too
db_insert('creature_drops', ['creature_id' => $cC, 'item_id' => $kelp, 'chance' => 25, 'reg' => 'CB']);      // only the old one: moves with its gate
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (?, ?, ?, ?)', [$uid, $old, $new, $kelp, $brad]);
give_item($uid, $old, 3); give_item($uid, $new, 2); give_item($uid, $kelp, 4);
q("UPDATE stop_acts SET spec = 'kelp-frond:3>kelp-meal:1' WHERE slug = 'w1_dry_kelp'");
q("UPDATE stop_acts SET spec = 'river-clay:2,slate-shard:1>rock-dust:7' WHERE slug = 'w5_mineral_silt'");   // an admin's own edit
q("DELETE FROM settings WHERE name = 'merge_items_2758'"); setting('__reload__');
upgrade_2758_merge_items();
$qty = fn(int $i) => (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $i]);
ok('R8: stacks of the old part land on the generic one', $qty($new) === 5 && $qty($old) === 0, $qty($new) . '/' . $qty($old));
ok('R15: kelp-frond stack is bladderwrack now', $qty($kelp) === 0 && $qty($brad) >= 4);
$rowsA = q('SELECT item_id, chance FROM creature_drops WHERE creature_id = ?', [$cA])->fetchAll();
ok('R8: one Lizard Scale row at the higher chance', count($rowsA) === 1 && (int)$rowsA[0]['item_id'] === $new && (int)$rowsA[0]['chance'] === 55, json_encode($rowsA));
$rowsB = q('SELECT item_id, chance, reg FROM creature_drops WHERE creature_id = ?', [$cB])->fetchAll();
ok('R15: duplicate merged into one ungated Bladderwrack row', count($rowsB) === 1 && (int)$rowsB[0]['item_id'] === $brad && (int)$rowsB[0]['chance'] === 40 && $rowsB[0]['reg'] === null, json_encode($rowsB));
$rowsC = q('SELECT item_id, chance, reg FROM creature_drops WHERE creature_id = ?', [$cC])->fetchAll();
ok('R15: a lone old row moves with its gate', count($rowsC) === 1 && (int)$rowsC[0]['item_id'] === $brad && $rowsC[0]['reg'] === 'CB', json_encode($rowsC));
ok('a stop craft at the old spec is re-pointed, an admin edit is kept', (string)q_val("SELECT spec FROM stop_acts WHERE slug = 'w1_dry_kelp'") === 'bladderwrack:3>kelp-meal:1' && (string)q_val("SELECT spec FROM stop_acts WHERE slug = 'w5_mineral_silt'") === 'river-clay:2,slate-shard:1>rock-dust:7');
q("UPDATE stop_acts SET spec = 'river-clay:2,slate-shard:1>rock-dust:1' WHERE slug = 'w5_mineral_silt'");
$cnt = (int)q_val('SELECT COUNT(*) FROM user_items');
upgrade_2758_merge_items(); setting('__reload__');
ok('the step is once (marker)', (int)q_val('SELECT COUNT(*) FROM user_items') === $cnt && setting('merge_items_2758') === '1');
// a world with no row of the new item yet: the old row is renamed (stacks stay)
$zo = mk('zz-old-part', 'part', 10, 5); give_item($uid, $zo, 2);
merge_item_2758('zz-old-part', 'zz-new-part', 'Zz New Part');
ok('no target row: the old row is renamed in place', (int)q_val("SELECT id FROM items WHERE slug = 'zz-new-part'") === $zo && (string)q_val('SELECT name FROM items WHERE id = ?', [$zo]) === 'Zz New Part' && $qty($zo) === 2);
ok('merging an item that does not exist is a no-op', merge_item_2758('zz-nothing', 'lizard-scale', 'Lizard Scale') === 0);

echo "== group C: R14 kettle keys\n";
$named = tea_named();
ok('no kettle tea key is a kitchen recipe or item slug', !array_filter(array_keys($named), fn($s) => q_val('SELECT 1 FROM recipes WHERE slug = ?', [$s]) || q_val('SELECT 1 FROM items WHERE slug = ?', [$s])));
ok('the three renamed keys exist, the old ones do not', isset($named['kettle-mint-tea'], $named['kettle-meadowsweet-tea'], $named['kettle-desert-sage-tea']) && !isset($named['mint-tea']) && !isset($named['meadowsweet-tea']) && !isset($named['desert-sage-tea']) && count($named) === 20);
$u2 = (int)q_val("SELECT id FROM users WHERE username <> 'sprout' ORDER BY id LIMIT 1") ?: $uid;
q('DELETE FROM user_tea_journal WHERE user_id IN (?, ?)', [$uid, $u2]);
q('INSERT INTO user_tea_journal (user_id, tea_slug, first_day, times) VALUES (?, ?, ?, ?)', [$uid, 'mint-tea', '2026-03-01', 4]);
q('INSERT INTO user_tea_journal (user_id, tea_slug, first_day, times) VALUES (?, ?, ?, ?)', [$uid, 'desert-sage-tea', '2026-03-02', 1]);
q('INSERT INTO user_tea_journal (user_id, tea_slug, first_day, times) VALUES (?, ?, ?, ?)', [$uid, 'kettle-desert-sage-tea', '2026-02-20', 2]);   // both keys: summed, earlier day
q('INSERT INTO user_tea_journal (user_id, tea_slug, first_day, times) VALUES (?, ?, ?, ?)', [$uid, 'oswego-tea', '2026-03-03', 7]);
q("DELETE FROM settings WHERE name = 'kettle_keys_2758'"); setting('__reload__');
upgrade_2758_kettle_keys();
$j = []; foreach (q('SELECT tea_slug, first_day, times FROM user_tea_journal WHERE user_id = ?', [$uid])->fetchAll() as $r) $j[$r['tea_slug']] = [$r['first_day'], (int)$r['times']];
ok('journal rows move to the kettle keys, others stay', ($j['kettle-mint-tea'] ?? null) === ['2026-03-01', 4] && ($j['oswego-tea'] ?? null) === ['2026-03-03', 7] && !isset($j['mint-tea']) && !isset($j['desert-sage-tea']), json_encode($j));
ok('a gnome with both keys keeps the sum and the earlier day', ($j['kettle-desert-sage-tea'] ?? null) === ['2026-02-20', 3], json_encode($j));
$f = tea_journal($uid);
ok('the journal shows them found', isset($f['found']['kettle-mint-tea']) && $f['n'] === 3, json_encode($f['found'] ?? null));
q('DELETE FROM user_tea_journal WHERE user_id = ?', [$uid]);

echo "== group C: B6 stop acts, H4 note\n";
foreach ([['r_ea_perilla_pickled_leaves', 'perilla', 'EA'], ['r_sa_tamarillo_chutney', 'tamarillo', 'SA'], ['r_sa_naranjilla_cordial', 'naranjilla', 'SA'], ['r_oc_noni_juice', 'noni', 'OC']] as [$slug, $crop, $reg]) {
    stops_import_regional();
    $a = q_one('SELECT spec, region, kind FROM stop_acts WHERE slug = ?', [$slug]);
    ok("$slug is a craft that takes $crop", $a && $a['kind'] === 'craft' && str_starts_with((string)$a['spec'], $crop . ':') && $a['region'] === $reg, json_encode($a));
    $out = explode(':', explode('>', (string)($a['spec'] ?? '>'))[1] ?? '')[0];
    ok("$slug makes an item that exists ($out)", $out !== '' && (bool)item_id_by_slug($out));
}
ok('the Gourmand setting says the Second Spoon needs it', str_contains((string)(settings_schema()['gourmand_open']['label'] ?? ''), 'Second Spoon'));
ok('the admin Gourmand page says it too', str_contains((string)file_get_contents($argv[1] . '/admin/gourmand.php'), 'Second Spoon</b> decoration'));

echo $fails ? "FAILED ($fails)\n" : "ok\n";
exit($fails ? 1 : 0);

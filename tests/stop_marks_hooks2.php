<?php
// Lasting marks, hooks part 2 (includes/stop_mark_charges.php): place-scoped number perks by scope kind and the place-stack ceiling,
// the daily charges A1-A3 at their sites (once a game day, back after a sleep, only where they fit), hook=todo perks never fire,
// flags A5/A6 render on their pages, and with stop_marks_open = 0 nothing changes. Run by stop_marks_hooks2.sh on a walk.sh install.
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/stop_pass.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/landmarks.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$GLOBALS['CURRENT_USER'] = $u();   // the gnome's own clock (gclock_my_date) reads the current user
$sleep = function () use ($uid): void { q('UPDATE users SET game_day = game_day + 1 WHERE id = ?', [$uid]); };
$cat = mark_catalogue();
$fake = 900000;
$latch = function (string $key) use ($uid, $cat, &$fake): void {
    $p = $cat[$key] ?? null;
    if (!$p) { ok("catalogue has $key", false); return; }
    db_insert('stop_marks', ['user_id' => $uid, 'location_id' => $p['loc_id'] ?: ++$fake, 'bar' => $p['bar'], 'perk_key' => $key, 'filled_on' => gclock_my_date(), 'latched_at' => now(), 'kept' => 0]);
    mark_held($uid, true);
};
$reset = function () use ($uid): void {
    foreach (['stop_marks', 'stop_mark_use'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
    mark_held($uid, true);
};
$qty = fn(string $slug) => (int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]);
$loc = fn(int $id) => q_one('SELECT * FROM locations WHERE id = ?', [$id]);
$R = []; foreach (q('SELECT id, code FROM regions')->fetchAll() as $r) $R[$r['code']] = (int)$r['id'];
$naTown = (int)q_val("SELECT id FROM locations WHERE slug = 'market-na'");
q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
q('UPDATE users SET location_id = ?, coins = 100000, energy = 50 WHERE id = ?', [$naTown, $uid]);

echo "== catalogue: a hook column; the todo perks are daily charges\n";
$todo = array_keys(array_filter($cat, fn($p) => $p['hook'] === 'todo'));
ok('every perk has a hook (site / page / todo)', !array_filter($cat, fn($p) => !in_array($p['hook'], ['site', 'page', 'todo'], true)));
ok('6 todo, all daily charges: ' . implode(', ', $todo), count($todo) === 6 && !array_filter($todo, fn($k) => $cat[$k]['class'] !== 'D'));
ok('every flag is a page hook', !array_filter($cat, fn($p) => $p['class'] === 'F' && $p['hook'] !== 'page'));

$clover = (int)$cat['oatcake_for_the_road']['loc_id'];
$fern = (int)$cat['dry_kindling_under_cover']['loc_id'];
$hazel = (int)$cat['stile_over_the_hedge']['loc_id'];
ok('Cloverholt, Fernden and Hazelmere are in this world', $clover > 0 && $fern > 0 && $hazel > 0, "$clover $fern $hazel");

echo "== off: nothing fires, nothing renders, the sites are unchanged\n";
$reset();
foreach (['oatcake_for_the_road', 'dry_kindling_under_cover', 'known_at_the_stalls', 'meltwater_can', 'two_from_one_stone'] as $k) $latch($k);
setg('stop_marks_open', '0');
$oats0 = $qty('oats');
stop_stamp($uid, $loc($clover));
ok('a first visit gives nothing', $qty('oats') === $oats0);
ok('charges: none ready, act energy unchanged', mark_charges_ready($uid, 'watering', []) === [] && mark_act_charges($uid, [], 2) === [2, []]);
ok('flags: no strip', mark_flags_html($uid, 'shop.php') === '' && mark_flags_on($uid, 'shops') === []);
ok('no stop_mark_use row was written', !q_val('SELECT 1 FROM stop_mark_use WHERE user_id = ?', [$uid]));

setg('stop_marks_open', '1');
echo "== place perks by scope kind (mark_pct with the site's context)\n";
$byScope = function (string $key) use ($cat): array { return array_keys($cat[$key]['scope']); };
$pick = function (string $fam, string $k) use ($cat): string {
    foreach ($cat as $key => $p) if ($p['class'] === 'P' && $p['family'] === $fam && isset($p['scope'][$k]) && $p['loc_id'] > 0) return $key;
    return '';
};
$walkKey = $pick('F05', 'from');
if ($walkKey !== '') {
    $reset(); $latch($walkKey);
    $p = $cat[$walkKey];
    $other = $p['loc_id'] === $naTown ? $clover : $naTown;
    $fit = ['we' => $p['scope']['we'] ?? [], 'dp' => $p['scope']['dp'] ?? [], 'se' => $p['scope']['se'] ?? []];   // its weather / day part / season, whatever the clock says now
    $from = mark_ctx_walk($p['loc_id'], $other) + $fit;
    $into = ['from' => $other, 'at' => $other, 'to' => $p['loc_id']] + mark_ctx_walk($other, $p['loc_id']) + $fit;
    ok("walk perk from=here ($walkKey): a walk from its stop " . abs($p['size']) . '%, a walk to it 0', mark_pct($uid, 'walk', $from) === abs($p['size']) && mark_pct($uid, 'walk', $into) === 0,
        json_encode([mark_pct($uid, 'walk', $from), mark_pct($uid, 'walk', $into)]));
    ok('...and never a walk between two other places', mark_pct($uid, 'walk', mark_ctx_walk($naTown === $p['loc_id'] ? $clover : $naTown, $fern === $p['loc_id'] ? $hazel : $fern)) === 0);
} else echo "   (no F05 from=here perk in this world: skipped)\n";
$cropKey = $pick('F10', 'items');
$reset(); $latch($cropKey);
$crop = $cat[$cropKey]['scope']['items'][0];
ok("crop perk items= ($cropKey): fits $crop, not tomato", mark_pct($uid, 'harvest', ['items' => [$crop]]) === abs($cat[$cropKey]['size'])
    && mark_pct($uid, 'harvest', ['items' => ['tomato']]) === 0, implode(',', $byScope($cropKey)));
$atKey = $pick('F15', 'at');
if ($atKey !== '') {
    $reset(); $latch($atKey);
    $p = $cat[$atKey];
    ok("act perk at=here ($atKey): at its stop only", mark_pct($uid, 'stopcoin', mark_ctx_loc($p['loc_id']) + ['group' => ['energy'], 'kind' => 'check']) > 0
        && mark_pct($uid, 'stopcoin', mark_ctx_loc($p['loc_id'] === $naTown ? $clover : $naTown) + ['group' => ['energy']]) === 0);
}
echo "== place-stack ceiling: world cap + 4 (XP + 2) at one event\n";
foreach (['F03' => 2, 'F05' => 4, 'F10' => 4] as $fam => $stack) {
    $reset();
    foreach ($cat as $k => $p) if ($p['family'] === $fam && $p['class'] === 'P') $latch($k);
    $most = 0;
    foreach ($cat as $p) if ($p['family'] === $fam && $p['class'] === 'P') {
        $ctx = ['items' => $p['scope']['items'] ?? [], 'region' => $p['scope']['region'][0] ?? $p['region'], 'land' => $p['scope']['land'] ?? [], 'group' => ['food', 'fish', 'energy']];
        if ($p['loc_id'] > 0) $ctx += ['at' => $p['loc_id'], 'from' => $p['loc_id'], 'to' => $p['loc_id']];
        $most = max($most, mark_place($uid, $fam, $ctx));
    }
    ok("$fam: place part at most $stack ($most)", $most > 0 && $most <= $stack);
}

echo "== A3 gift on the first visit (stop_stamp), once a game day, back after a sleep\n";
$reset(); $latch('oatcake_for_the_road');
$o = $qty('oats');
[, $m1] = stop_stamp($uid, $loc($clover));
[, $m2] = stop_stamp($uid, $loc($clover));
ok('first visit: +1 oats and a line', $qty('oats') === $o + 1 && (bool)preg_grep('/Oatcake for the Road/', $m1), json_encode($m1));
ok('second visit the same game day: nothing', $qty('oats') === $o + 1 && !preg_grep('/Oatcake/', $m2));
stop_stamp($uid, $loc($fern));
ok('a visit to another stop: nothing', $qty('oats') === $o + 1);
$sleep();
stop_stamp($uid, $loc($clover));
ok('after a sleep (the next game day): again', $qty('oats') === $o + 2);

echo "== A1 first act of a kind (stop_do's charge step)\n";
$reset(); $latch('dry_kindling_under_cover');
$fctx = mark_ctx_loc($fern);
ok('a lore act at Fernden: not a check act, energy 2 stays 2', mark_act_charges($uid, $fctx + ['kind' => 'lore'], 2)[0] === 2);
ok('a free check act: the charge is kept, not spent', mark_act_charges($uid, $fctx + ['kind' => 'check'], 0)[0] === 0 && mark_daily_available($uid, 'dry_kindling_under_cover'));
[$e1, $l1] = mark_act_charges($uid, $fctx + ['kind' => 'check'], 2);
ok('the first check act: 1 energy less, with a line', $e1 === 1 && $l1 !== [], json_encode($l1));
ok('the next check act: full cost', mark_act_charges($uid, $fctx + ['kind' => 'check'], 2)[0] === 2);
ok('a check act at another stop: full cost (after a sleep)', ($sleep() ?? true) && mark_act_charges($uid, mark_ctx_loc($clover) + ['kind' => 'check'], 2)[0] === 2);

echo "== A1 walks: a walk that starts or ends at the stop\n";
$reset(); $latch('stile_over_the_hedge');
$ready = mark_charges_ready($uid, 'first_walk_from_to_the_stop', mark_ctx_walk($naTown, $hazel));
ok('a walk to Hazelmere: ready, 2 energy -> 1', count($ready) === 1 && mark_charge_energy($ready, 2) === 1);
$ready0 = $ready;
ok('a free walk: dropped, not spent', mark_charge_energy($ready0, 0) === 0 && $ready0 === []);
ok('a walk between two other places: none', mark_charges_ready($uid, 'first_walk_from_to_the_stop', mark_ctx_walk($naTown, $clover)) === []);
mark_charges_take($uid, $ready);
ok('taken: gone until the next game day', mark_charges_ready($uid, 'first_walk_from_to_the_stop', mark_ctx_walk($hazel, $naTown)) === []);

echo "== A1 fast travel (travel_to): 1 energy less, once\n";
$reset(); $latch('signallers_ration');
$ca = $R['CA'];
q('DELETE FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $ca]);
db_insert('region_visits', ['user_id' => $uid, 'region_id' => $ca, 'first_at' => now()]);
setg('travel_energy', '3');
$travel = function () use ($u, $uid, $ca, $naTown): int {
    q('UPDATE users SET location_id = ?, location = ?, energy = 50 WHERE id = ?', [$naTown, 'The Maplewold', $uid]);
    [$okT, $msg] = travel_to($u(), $ca);
    if (!$okT) echo "   travel: $msg\n";
    return 50 - (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
};
$t1 = $travel(); $t2 = $travel();
setg('stop_marks_open', '0'); $t0 = $travel(); setg('stop_marks_open', '1');
ok("energy: off $t0, first on $t1, second on $t2", $t0 > 0 && $t1 === $t0 - 1 && $t2 === $t0, "$t0 $t1 $t2");
q('UPDATE users SET location_id = ?, location = ? WHERE id = ?', [$naTown, 'The Maplewold', $uid]);

echo "== A3 one extra on a shop buy (food only)\n";
$reset(); $latch('bakers_thirteenth');
$tomato = (int)q_val("SELECT id FROM items WHERE slug = 'tomato'");
$tq = $qty('tomato');
ok('a tool: no extra', mark_buy_charges($uid, 0, $tomato, 'tool', 'Tomato') === '' && $qty('tomato') === $tq);
ok('food: one extra, once', mark_buy_charges($uid, 0, $tomato, 'produce', 'Tomato') !== '' && $qty('tomato') === $tq + 1
    && mark_buy_charges($uid, 0, $tomato, 'produce', 'Tomato') === '');

echo "== A3 first harvest of a named crop: scope items fit\n";
$reset(); $latch('two_from_one_stone');
$tomP = q_one("SELECT * FROM plants WHERE slug = 'tomato'");
ok('a tomato harvest: no', mark_charges_fire($uid, 'first_harvest_of_a_named_crop', mark_ctx_crop($tomP)) === []);
ok('an avocado harvest: yes, once', count(mark_charges_fire($uid, 'first_harvest_of_a_named_crop', ['items' => ['avocado']])) === 1
    && mark_charges_fire($uid, 'first_harvest_of_a_named_crop', ['items' => ['avocado']]) === []);

echo "== A2 tool wear skipped (tool_use), A2 wonder re-roll in the perk's region and stat\n";
$reset(); $latch('birch_bark_patch');
setg('tool_wear_on', '1');
$staff = q_one("SELECT * FROM items WHERE effects LIKE '%\"tool\":\"staff\"%' ORDER BY id LIMIT 1");
if ($staff) {
    give_item($uid, (int)$staff['id'], 1);
    $wear = fn() => (int)q_val('SELECT wear FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$staff['id']]);
    $w0 = $wear();
    $line = tool_use($uid, 'staff');
    $w1 = $wear();
    tool_use($uid, 'staff');
    ok("the first staff wear today is skipped, the next counts ($w0 $w1 {$wear()})", $w1 === $w0 && $wear() === $w0 + 1 && str_contains((string)$line, 'lasting mark'));
} else echo "   (no staff item: skipped)\n";
$reset(); $latch('head_in_the_clouds');
$hr = $cat['head_in_the_clouds']['region'];
ok("a failed Grit check in $hr: no; a Lore check elsewhere: no; a Lore check in $hr: yes",
    mark_charges_fire($uid, 'failed_check_at_a_wonder', ['kind' => 'grit', 'region' => $hr]) === []
    && mark_charges_fire($uid, 'failed_check_at_a_wonder', ['kind' => 'lore', 'region' => 'NA']) === []
    && count(mark_charges_fire($uid, 'failed_check_at_a_wonder', ['kind' => 'lore', 'region' => $hr])) === 1);

echo "== hook=todo never fires\n";
$reset(); $latch('bakers_peel'); $latch('fire_watch_basket');
ok('bakers_peel and fire_watch_basket: nothing ready', mark_charges_ready($uid, 'first_dish_cooked_with_a_named_crop', ['items' => ['rye']]) === []
    && mark_charges_ready($uid, 'torch_step_in_a_named_delve', ['region' => $cat['fire_watch_basket']['region']]) === []);

echo "== flags: the strip on its pages only\n";
$reset(); $latch('known_at_the_stalls'); $latch('the_bees_know_you');
$shopH = mark_flags_html($uid, 'shop.php');
$gardenH = mark_flags_html($uid, 'garden.php');
ok('shop page: Known at the Stalls (info), not the bee', str_contains($shopH, 'Known at the Stalls') && str_contains($shopH, 'mk-info') && !str_contains($shopH, 'Bees'));
ok('garden page: The Bees Know You (looks)', str_contains($gardenH, 'The Bees Know You') && str_contains($gardenH, 'mk-looks'));
ok('a page with no flags held: nothing', mark_flags_html($uid, 'passport.php') === '' && mark_flags_html($uid, 'nowhere.php') === '');
ok('mark_flag by family', mark_flag($uid, 'info') && mark_flag($uid, 'looks'));
ob_start(); page_header('Test'); $page = ob_get_clean();
setg('stop_marks_open', '0');
ob_start(); page_header('Test'); $pageOff = ob_get_clean();
ok('page_header renders no strip on index.php (no flag for Today held), and none when off', !str_contains($page, 'mk-flags') && !str_contains($pageOff, 'mk-flags'));
$_SERVER['SCRIPT_NAME'] = '/shop.php';
setg('stop_marks_open', '1');
ob_start(); page_header('Test'); $shopPage = ob_get_clean();
setg('stop_marks_open', '0');
ob_start(); page_header('Test'); $shopOff = ob_get_clean();
ok('shop.php header: the strip on, none off', str_contains($shopPage, 'Known at the Stalls') && !str_contains($shopOff, 'mk-flags'));
$_SERVER['SCRIPT_NAME'] = '/index.php';

$reset();
setg('stop_marks_open', '0');
q('UPDATE users SET location_id = ? WHERE id = ?', [$naTown, $uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);

<?php
// The Hovel tea kettle (includes/tea.php, tea_view.php, assets/tea.js). Run by tea.sh on an installed copy (player "sprout").
// Usage: php tests/tea.php GAME [PARITY.json]   (PARITY.json: cups + what PHP makes of them, for tests/tea_parity.js)
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/gnome.php';
require_once APP_ROOT . '/includes/events.php';
require_once APP_ROOT . '/includes/home_slim.php';
require_once APP_ROOT . '/includes/fresh_start.php';
require_once APP_ROOT . '/includes/tea_view.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$row = fn(): array => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$qty = fn(string $slug): int => (int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]);
$stock = function (array $slugs, int $n = 5) use ($uid): void { foreach ($slugs as $s) { $id = item_id_by_slug($s); q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]); give_item($uid, $id, $n); } };
$reset = function () use ($uid): void { q('UPDATE users SET tea = NULL, tea_day = NULL, tea_name = NULL, kettle = 0, buff = NULL, buff_until = NULL, ev_stat = NULL, ev_amt = 0, ev_until = NULL, ev_day = NULL, town_stat = NULL, town_amt = 0, town_until = NULL, ev2_stat = NULL, ev2_amt = 0, ev2_until = NULL, ev2_day = NULL WHERE id = ?', [$uid]); q('DELETE FROM user_tea_journal WHERE user_id = ?', [$uid]); };
$pts = fn(array $c): string => json_encode($c['buff']);
$ING = tea_ingredients(); $NAMED = tea_named();

echo "== schema\n";
ok('users.tea / tea_day / tea_name / kettle exist', (function () { try { q('SELECT tea, tea_day, tea_name, kettle FROM users LIMIT 1'); return true; } catch (Throwable $e) { return false; } })());
ok('user_tea_journal exists', (function () { try { q('SELECT user_id, tea_slug, first_day, times FROM user_tea_journal LIMIT 1'); return true; } catch (Throwable $e) { return false; } })());
$r2 = db_migrate(db(), 'sqlite');
ok('db_migrate again adds nothing and fails nothing', !array_filter((array)$r2, fn($x) => is_string($x) && preg_match('/users\.(tea|kettle)/', $x)) && empty($GLOBALS['gv_migrate_errors']), json_encode($r2));
$tmp = new PDO('sqlite::memory:'); $tmp->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION); $tmp->exec('CREATE TABLE users (id INTEGER PRIMARY KEY, buff TEXT NULL)'); $tmp->exec('INSERT INTO users (id) VALUES (1)');
foreach (tea_schema('', '', '')[2] as [$t, $c, $d]) $tmp->exec("ALTER TABLE $t ADD COLUMN $c $d");   // the statement db_migrate runs on an old save
foreach (tea_schema('', '', '')[0] as $sql) $tmp->exec($sql);
$old = $tmp->query('SELECT * FROM users')->fetch(PDO::FETCH_ASSOC);
ok('an old save gains the columns: no tea, the tin kettle', $old['tea'] === null && $old['tea_day'] === null && (int)$old['kettle'] === 0, json_encode($old));
$fc = fresh_start_columns();
ok('fresh start clears the cup and the kettle', array_key_exists('tea', $fc) && $fc['tea'] === null && array_key_exists('tea_day', $fc) && array_key_exists('tea_name', $fc) && $fc['kettle'] === 0);
ok('fresh start empties the journal', (FRESH_LAZY_TABLES['user_tea_journal'] ?? '') === 'user_id');
ok('tea_ensure is a no-op on an upgraded copy', tea_ensure() === true);

echo "== data: ingredients and named teas\n";
ok('31 ingredients', count($ING) === 31, (string)count($ING));
$bad = [];
foreach ($ING as $s => $g) {
    $real = 0;
    foreach ($g['items'] as [$it, $opt]) { $has = item_id_by_slug($it) > 0; if ($has) $real++; elseif (!$opt) $bad[] = "$s: item $it missing"; }
    if (!$real) $bad[] = "$s: no item exists";
    if (!isset(TEA_KINDS[$g['kind']])) $bad[] = "$s: kind";
    if (in_array($g['role'], ['steep', 'add'], true) ? (!isset(GNOME_STATS[$g['stat']]) || $g['power'] < 1 || $g['power'] > 2) : ($g['stat'] !== '' || $g['power'] !== 0)) $bad[] = "$s: stat / power";
}
ok('every ingredient slug is a real item (optional "?" items may be made later), with a real stat and power', !$bad, implode('; ', $bad));
ok('TEA_STATS are the gnome stats', array_keys(TEA_STATS) === array_keys(GNOME_STATS) && !array_filter(TEA_STATS, fn($n, $k) => GNOME_STATS[$k][0] !== $n, ARRAY_FILTER_USE_BOTH));
ok('20 named teas', count($NAMED) === 20, (string)count($NAMED));
$bad = []; $keys = [];
foreach ($NAMED as $s => $t) {
    foreach ($t['parts'] as $p) if (!isset($ING[$p])) $bad[] = "$s: unknown part $p";
    if (isset($keys[$t['key']])) $bad[] = "$s: same set as " . $keys[$t['key']];
    $keys[$t['key']] = $s;
    $base = ''; foreach ($t['parts'] as $p) if (($ING[$p]['role'] ?? '') === 'steep') { $base = $p; break; }
    $c = $base !== '' ? tea_cup(array_merge([$base], array_diff($t['parts'], [$base])), 3) : ['ok' => false, 'error' => 'no base', 'name' => ''];
    if (!$c['ok'] || $c['name'] !== $t['name'] || !$c['buff']) $bad[] = "$s: cannot be brewed (" . ($c['error'] ?? '') . ')';
    if ($t['note'] === '' || $t['name'] === '') $bad[] = "$s: name / note";
}
ok('every named tea: known parts, a base, a unique set, a legal cup that gives a boost', !$bad, implode('; ', $bad));
ok('the Kitchen snack teas and Pantry drinks are untouched (still recipes, still food items)', (int)q_val("SELECT COUNT(*) FROM recipes WHERE slug IN ('mint-tea', 'meadowsweet-tea', 'desert-sage-tea', 'chai-blend', 'iced-tea-concentrate', 'kombucha')") === 6 && (int)q_val("SELECT COUNT(*) FROM items WHERE slug IN ('mint-tea', 'meadowsweet-tea', 'desert-sage-tea')") === 3);
ok('no kettle or cup item was made', (int)q_val("SELECT COUNT(*) FROM items WHERE slug LIKE '%kettle%' OR slug LIKE '%samovar%' OR slug = 'house-blend'") === 0);

echo "== formula: the proposal's worked cups (Plan 2)\n";
$c = tea_cup(['chamomile'], 0);
ok('Dented Tin, chamomile: Luck 1 x 2 = 2 -> floor(2 x 4 / 8) = 1', $c['ok'] && $c['buff'] === ['luck' => 1] && $c['steep']['main']['steep'] === 2 && $c['steep']['K'] === 4 && $c['name'] === TEA_HOUSE, json_encode($c));
$c = tea_cup(['mint', 'lavender', 'lemon'], 1);
ok('Copper, mint + lavender + lemon: Sense 4 -> floor(20 / 8) = 2', $c['buff'] === ['sense' => 2] && $c['steep']['main']['steep'] === 4 && $c['side'] === '', json_encode($c));
$c = tea_cup(['rooibos', 'clove', 'lemon', 'garden-honey'], 2);
ok('Cast-Iron, rooibos + clove + lemon + honey: Hardiness 7 -> 5, cap 2; Sense 2 -> 1', $c['buff'] === ['hardiness' => 2, 'sense' => 1] && $c['steep']['main']['steep'] === 7 && $c['steep']['main']['raw'] === 5 && $c['steep']['side']['steep'] === 2, json_encode($c));
$c = tea_cup(['tea', 'ginseng', 'ginger', 'garden-honey'], 3);
ok('Silver Samovar, tea + ginseng + ginger + honey: Lore 7 -> 6, cap 3; Nimble 3 -> 2', $c['buff'] === ['lore' => 3, 'nimble' => 2] && $c['steep']['main']['raw'] === 6 && $c['steep']['side']['steep'] === 3, json_encode($c));
ok('K is 4 / 5 / 6 / 7 and the caps 1-1 / 2-1 / 2-2 / 3-2', array_map(fn($t) => array_slice(tea_kettle($t), 1), [0, 1, 2, 3]) === [[4, 1, 1], [5, 2, 1], [6, 2, 2], [7, 3, 2]]);
ok('Tea Leaves alone reach the copper cap', tea_cup(['tea'], 1)['buff'] === ['lore' => 2]);
ok('milk adds 2 steep to the main stat', tea_cup(['mint', 'goat-milk'], 3)['steep']['main']['steep'] === 4);
ok('a sweetener adds 1 to main and 1 to side', (function () { $c = tea_cup(['mint', 'cinnamon', 'cane-syrup'], 3); return $c['steep']['main']['steep'] === 3 && $c['steep']['side']['steep'] === 3; })());
ok('side tie: the stat added first', tea_cup(['tea', 'cardamom', 'cinnamon'], 3)['side'] === 'charm' && tea_cup(['tea', 'cinnamon', 'cardamom'], 3)['side'] === 'grit');
ok('a cup can be too weak for a boost and is still a cup', (function () { $c = tea_cup(['mint'], 0, [3, 2]); return $c['ok'] && $c['named'] && $c['steep']['main']['steep'] === 3 && $c['buff'] === ['sense' => 1]; })() && tea_cup(['lavender'], 0)['buff'] === ['sense' => 1] && tea_cup(['lavender', 'lemon'], 0, [0, 0])['buff'] === []);

echo "== rules and limits\n";
$err = fn(array $s, int $t = 3): string => tea_cup($s, $t)['error'];
ok('nothing picked', $err([]) === 'Pick a base to steep.' && $err(['', '']) === 'Pick a base to steep.');
ok('5 components refused', $err(['tea', 'mint', 'ginger', 'lemon', 'vanilla']) === 'A cup holds 4 components at most.');
ok('4 components fine', tea_cup(['tea', 'mint', 'ginger', 'lemon'], 3)['ok']);
ok('the same ingredient twice refused', $err(['tea', 'mint', 'mint']) === 'Mint is in the cup twice. Each ingredient goes in once.');
ok('the base must steep (a spice, fruit, sweetener or milk cannot)', $err(['cinnamon', 'tea']) === 'The base must be a leaf, herb, flower or root.' && !tea_cup(['lemon'], 3)['ok'] && !tea_cup(['garden-honey'], 3)['ok'] && !tea_cup(['goat-milk'], 3)['ok']);
ok('one sweetener', $err(['tea', 'garden-honey', 'cane-syrup']) === 'One sweetener per cup.');
ok('unknown ingredient', $err(['tea', 'nettle']) === 'Unknown ingredient.');
ok('a refused cup gives nothing', tea_cup(['cinnamon'], 3)['buff'] === [] && tea_cup(['cinnamon'], 3)['name'] === '');
ok('tea_pick: the base first, the rest in card order; no base named = the first that steeps', tea_pick(['base' => 'mint', 'c' => ['lemon', 'tea', 'mint']]) === ['mint', 'tea', 'lemon'] && tea_pick(['c' => 'lemon,ginger']) === ['ginger', 'lemon'] && tea_pick(['base' => 'x', 'c' => ['lemon']]) === ['lemon'] && tea_pick([]) === []);
cfg(['tea_cap_main' => 2, 'tea_cap_side' => 1]);
ok('settings tea_cap_main / tea_cap_side lower the best cup', tea_cup(['tea', 'ginseng', 'ginger', 'garden-honey'], 3)['buff'] === ['lore' => 2, 'nimble' => 1] && tea_kettle(0) === ['Dented Tin Kettle', 4, 1, 1]);
cfg(['tea_cap_main' => 0, 'tea_cap_side' => 0]);
ok('... down to nothing', tea_cup(['tea', 'ginseng', 'ginger', 'garden-honey'], 3)['buff'] === []);
q("DELETE FROM settings WHERE name IN ('tea_cap_main', 'tea_cap_side')"); setting('__reload__');
ok('defaults: 3 and 2', tea_caps() === [3, 2] && setting('tea_cap_main') === '3' && setting('tea_cap_side') === '2');

echo "== named teas\n";
$c = tea_cup(['tea', 'cardamom', 'cinnamon', 'ginger'], 1);
ok('Masala Chai on Copper: named, +1 steep (Lore 5), Lore +2 and Charm +1', $c['name'] === 'Masala Chai' && $c['slug'] === 'masala-chai' && $c['named'] && $c['steep']['main']['steep'] === 5 && $c['buff'] === ['lore' => 2, 'charm' => 1], json_encode($c));
ok('the set is order-free', tea_cup(['ginger', 'cinnamon', 'tea', 'cardamom'], 1)['name'] === 'Masala Chai' && tea_cup(['tea', 'ginger', 'cinnamon', 'cardamom'], 1)['name'] === 'Masala Chai');
ok('a part more or less is a House Blend with the plain formula', tea_cup(['tea', 'cardamom', 'cinnamon'], 1)['name'] === TEA_HOUSE && !tea_cup(['tea', 'cardamom', 'cinnamon'], 1)['named'] && tea_cup(['tea', 'cardamom', 'cinnamon'], 1)['steep']['main']['steep'] === 4 && tea_cup(['mint', 'lemon'], 1)['name'] === TEA_HOUSE);
ok('single-part named teas', tea_cup(['mint'], 0)['name'] === 'Mint Tea' && tea_cup(['bee-balm'], 0)['name'] === 'Oswego Tea');
ok('Golden Milk on Cast-Iron: Hardiness +2, Nimble +1', $pts(tea_cup(['turmeric', 'ginger', 'black-pepper', 'goat-milk'], 2)) === '{"hardiness":2,"nimble":1}', $pts(tea_cup(['turmeric', 'ginger', 'black-pepper', 'goat-milk'], 2)));

echo "== who sees it\n";
$me = $row(); $adm = ['role' => 'admin'] + $me; $guest = ['guest' => 1] + $adm;
q("DELETE FROM settings WHERE name = 'tea_open'"); setting('__reload__');
ok('default is Admins only', setting('tea_open') === 'admin' && !tea_open_for($me) && tea_open_for($adm) && !tea_open_for($guest) && !tea_open_for(null));
cfg(['tea_open' => 'off']); ok('off: nobody', !tea_open_for($me) && !tea_open_for($adm));
ok('closed: brewing and buying are refused', tea_brew($me, ['mint'])[0] === false && tea_kettle_buy($me)[0] === false);
$chosen = hovel_decor_chosen($uid);
foreach (['crop', 'full'] as $mode) {
    $svg = hovel_room_svg($me, $chosen, $mode, ['taps' => $mode === 'full']);
    ok("closed: the $mode room has no kettle hit box", !str_contains($svg, 'hd-kettle') && !str_contains($svg, 'htea') && ($mode === 'full' || str_contains($svg, 'role="img"')));
}
cfg(['tea_open' => 'everyone']); ok('everyone: players yes, guests never', tea_open_for($me) && tea_open_for($adm) && !tea_open_for($guest));
foreach (['crop', 'full'] as $mode) {
    $svg = hovel_room_svg($me, $chosen, $mode, ['taps' => $mode === 'full']);
    $m = [];
    $hit = preg_match('~<a class="hd hd-kettle" href="[^"]*gnome\.php\?tea=1#htea" data-hdlg="htea"[^>]*>.*?<rect class="hd-hit" x="(\d+)" y="(\d+)" width="(\d+)" height="(\d+)"/></a>~s', $svg, $m);
    ok("open: the $mode room has the kettle link, a hit box of 56+ around the painted kettle, inside the banner crop", $hit && $m[3] >= 56 && $m[4] >= 56 && $m[1] <= 320 && $m[1] + $m[3] >= 350 && $m[2] <= 163 && $m[2] + $m[4] >= 185 && $m[2] >= 104 && $m[2] + $m[4] <= 224, json_encode($m));
    ok("... and no inline style", !str_contains($svg, 'style='));
}
ok('a guest gets plain art', !str_contains(hovel_room_svg($guest, $chosen, 'crop'), 'hd-kettle'));

echo "== brewing\n";
cfg(['game_clock_on' => 1]);
$reset(); q('UPDATE users SET game_day = 20 WHERE id = ?', [$uid]);
$stock(['tea', 'mint', 'cardamom', 'cinnamon', 'ginger', 'lemon', 'garden-honey', 'goat-milk', 'cut-chamomile'], 5);
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, item_id_by_slug('vanilla')]);
$u0 = $row(); $base = []; foreach (array_keys(GNOME_STATS) as $s) $base[$s] = eff_stat($u0, $s);
[$ok, $msg] = tea_brew($u0, ['tea', 'vanilla']);
ok('an ingredient you do not hold: refused, nothing spent', !$ok && str_contains($msg, 'Vanilla') && $qty('tea') === 5 && $row()['tea'] === null, $msg);
[$ok, $msg] = tea_brew($u0, ['cinnamon', 'tea']);
ok('an illegal cup: refused, nothing spent', !$ok && $qty('tea') === 5 && $qty('cinnamon') === 5, $msg);
[$ok, $msg, $cup] = tea_brew($u0, ['mint', 'cinnamon']);
$u1 = $row();
ok('a House Blend: brewed, one of each spent', $ok && $qty('mint') === 4 && $qty('cinnamon') === 4 && $qty('tea') === 5 && $cup['name'] === TEA_HOUSE, $msg);
ok('the cup is in its slot: tea JSON, tea_day = the game day, the name', json_decode((string)$u1['tea'], true) === ['sense' => 1, 'grit' => 1] && (string)$u1['tea_day'] === '20' && $u1['tea_name'] === TEA_HOUSE, json_encode([$u1['tea'], $u1['tea_day'], $u1['tea_name']]));
ok('eff_stat reads it', eff_stat($u1, 'sense') === $base['sense'] + 1 && eff_stat($u1, 'grit') === $base['grit'] + 1 && eff_stat($u1, 'lore') === $base['lore']);
$fx = array_values(array_filter(active_effects($u1), fn($e) => $e[1] === 'Tea'));
ok('active_effects: "Tea · Sense +1, Grit +1 · until you sleep"', count($fx) === 1 && $fx[0][2] === 'Sense +1, Grit +1 · until you sleep' && effect_left($fx[0]) === '', json_encode($fx));
ok('the message says what it gave', str_contains($msg, 'House Blend') && str_contains($msg, 'Sense +1, Grit +1 until you sleep'), $msg);
ok('a House Blend is not stamped', tea_journal($uid)['n'] === 0);
ok('the cup never becomes an item', (int)q_val("SELECT COUNT(*) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND (i.slug LIKE '%house%' OR i.name LIKE '%House Blend%')", [$uid]) === 0);
ok('brewing takes no energy and no game time', (int)$u1['energy'] === (int)$u0['energy'] && (int)$u1['game_minute'] === (int)$u0['game_minute'] && (int)$u1['coins'] === (int)$u0['coins']);

echo "== its own slot: nothing is clobbered either way\n";
q('UPDATE users SET buff = ?, buff_until = ?, town_stat = ?, town_amt = 2, town_until = ? WHERE id = ?', [json_encode(['sense' => 3]), gmdate('Y-m-d H:i:s', time() + 3600), 'sense', gmdate('Y-m-d H:i:s', time() + 3600), $uid]);
apply_event_effect($row(), 'buff:sense:1:60'); apply_event_effect($row(), 'buff2:sense:1:60');
$u2 = $row();
ok('meal + lucky moment + second lucky moment + town drink + tea all add up', eff_stat($u2, 'sense') === $base['sense'] + 3 + 1 + 1 + 2 + 1 && eff_stat($u2, 'grit') === $base['grit'] + 1, (string)eff_stat($u2, 'sense'));
ok('... and the tea is still in its slot', (string)$u2['tea'] === (string)$u1['tea'] && (string)$u2['tea_day'] === '20');
$keep = fn(array $u): string => json_encode(array_intersect_key($u, array_flip(['buff', 'buff_until', 'buff2', 'buff2_until', 'ev_stat', 'ev_amt', 'ev_until', 'ev_day', 'ev_scope', 'ev2_stat', 'ev2_amt', 'ev2_until', 'ev2_day', 'ev2_scope', 'town_stat', 'town_amt', 'town_until'])));
[$ok, $msg] = tea_brew($u2, ['mint'], true);
ok('a brew leaves the meal, both lucky moments and the town drink alone', $ok && $keep($row()) === $keep($u2), $msg);
ok('five boosts listed, the tea among them', count(array_filter(active_effects($row()), fn($e) => in_array($e[1], ['Meal', 'A lucky moment', 'A second lucky moment', 'Town outing', 'Tea'], true))) === 5);

echo "== a second brew the same day\n";
$reset(); $stock(['tea', 'mint', 'lemon'], 5);
tea_brew($row(), ['tea', 'lemon']);
[$ok, $msg] = tea_brew($row(), ['mint']);
ok('without the confirm: refused, says what it pours out, nothing spent', !$ok && str_contains($msg, 'pours out your House Blend') && $qty('mint') === 5 && $row()['tea_name'] === TEA_HOUSE, $msg);
[$ok, $msg] = tea_brew($row(), ['mint'], true);
$u3 = $row();
ok('with the confirm: the new cup REPLACES the first', $ok && $u3['tea_name'] === 'Mint Tea' && json_decode((string)$u3['tea'], true) === ['sense' => 1] && eff_stat($u3, 'lore') === $base['lore'] && eff_stat($u3, 'sense') === $base['sense'] + 1, $msg . ' ' . $u3['tea']);
ok('... the ingredients are spent each brew', $qty('mint') === 4 && $qty('tea') === 4 && $qty('lemon') === 4);
ok('... and the message says the first was poured out', str_contains($msg, 'pour out the House Blend'), $msg);

echo "== it lasts until the next sleep\n";
ok('today: there is a cup', tea_today($row()) !== null && gnome_tea_buff($row()) === ['sense' => 1]);
q('UPDATE users SET game_day = 21 WHERE id = ?', [$uid]); $u4 = $row();
ok('the game day moved on: no cup, no boost, not in the effects list', tea_today($u4) === null && gnome_tea_buff($u4) === [] && eff_stat($u4, 'sense') === $base['sense'] && !array_filter(active_effects($u4), fn($e) => $e[1] === 'Tea'));
[$ok, $msg] = tea_brew($u4, ['mint']);
ok('a new day: a new cup, no confirm needed', $ok && (string)$row()['tea_day'] === '21', $msg);
$d0 = (int)$row()['game_day'];
[$sok, $smsg] = gclock_rest($uid, 'home_sleep');
$u5 = $row();
ok('a real sleep (gclock_rest home_sleep) ends it', $sok && (int)$u5['game_day'] === $d0 + 1 && tea_today($u5) === null && eff_stat($u5, 'sense') === $base['sense'], $smsg . ' day ' . $u5['game_day']);
cfg(['game_clock_on' => 0]);
$reset(); $stock(['mint'], 5);
[$ok] = tea_brew($row(), ['mint']); $u6 = $row();
ok('game clock off: the day is the Hollow date', $ok && $u6['tea_day'] === hollow_date('Y-m-d') && gnome_tea_buff($u6) === ['sense' => 1] && tea_ends() === 'until tomorrow', (string)$u6['tea_day']);
q('UPDATE users SET tea_day = ? WHERE id = ?', [gmdate('Y-m-d', time() - 3 * 86400), $uid]);
ok('... and yesterday\'s cup is over', gnome_tea_buff($row()) === [] && tea_today($row()) === null);
cfg(['game_clock_on' => 1]);
ok('a cup kept from the other clock mode does not count', gnome_tea_buff(['tea' => '{"lore":2}', 'tea_day' => hollow_date('Y-m-d'), 'game_day' => 5]) === [] && gnome_tea_buff(['tea' => '{"lore":2}', 'tea_day' => '5', 'game_day' => 5]) === ['lore' => 2]);
ok('a broken slot is harmless', gnome_tea_buff(['tea' => 'x', 'tea_day' => '5', 'game_day' => 5]) === [] && gnome_tea_buff(['tea' => '{"bogus":9,"lore":0}', 'tea_day' => '5', 'game_day' => 5]) === [] && gnome_tea_buff([]) === []);

echo "== the journal and the kettles\n";
$reset(); q('UPDATE users SET game_day = 30, coins = 100 WHERE id = ?', [$uid]);
$stock(['tea', 'mint', 'cardamom', 'cinnamon', 'ginger', 'lemon', 'garden-honey', 'goat-milk', 'cane-syrup'], 9);
[$ok, $msg] = tea_brew($row(), ['tea', 'cardamom', 'cinnamon', 'ginger']);
$j = tea_journal($uid);
ok('a named tea is stamped: first day, once', $ok && $j['n'] === 1 && $j['total'] === 20 && $j['found']['masala-chai'] === ['first_day' => '30', 'times' => 1] && str_contains($msg, 'New in your Tea Journal: Masala Chai (1 of 20)'), $msg . json_encode($j));
[$ok, $msg] = tea_brew($row(), ['ginger', 'cinnamon', 'cardamom', 'tea'], true);
$j = tea_journal($uid);
ok('the same tea again (any order): counted, not new', $ok && $j['n'] === 1 && $j['found']['masala-chai']['times'] === 2 && !str_contains($msg, 'New in your'), $msg);
ok('one row per gnome and tea', (int)q_val('SELECT COUNT(*) FROM user_tea_journal WHERE user_id = ?', [$uid]) === 1);
$nx = tea_kettle_next($row());
ok('next kettle: Copper, 150 Petals', $nx['tier'] === 1 && $nx['name'] === 'Copper Kettle' && $nx['buy'] === 150 && $nx['have'] === 1);
[$ok, $msg] = tea_kettle_buy($row());
ok('not enough Petals: no kettle, nothing taken', !$ok && (int)$row()['kettle'] === 0 && (int)$row()['coins'] === 100, $msg);
q('UPDATE users SET coins = 400 WHERE id = ?', [$uid]);
[$ok, $msg] = tea_kettle_buy($row());
ok('bought: Copper Kettle, 150 Petals taken', $ok && (int)$row()['kettle'] === 1 && (int)$row()['coins'] === 250, $msg);
ok('... once only', tea_kettle_buy($row())[0] === false && (int)$row()['coins'] === 250);
ok('the copper cup is stronger', tea_brew($row(), ['tea'], true)[2]['buff'] === ['lore' => 2]);
$nx = tea_kettle_next($row());
ok('next kettle: Cast-Iron at 8 named teas', $nx['tier'] === 2 && $nx['buy'] === 0 && $nx['need'] === 8);
$slugs = array_keys($NAMED); $add = function (int $upTo) use ($uid, $slugs): void { for ($i = 0; $i < $upTo; $i++) tea_journal_stamp($uid, $slugs[$i], '30'); };
q('DELETE FROM user_tea_journal WHERE user_id = ?', [$uid]);
$add(7);
ok('7 named teas: still Copper', tea_kettle_unlocks($uid) === [] && (int)$row()['kettle'] === 1 && tea_journal($uid)['n'] === 7);
q('DELETE FROM user_tea_journal WHERE user_id = ? AND tea_slug = ?', [$uid, 'moroccan-mint']);   // make sure the 8th is found by a brew
$have = array_keys(tea_journal($uid)['found']);
if (count($have) < 7) tea_journal_stamp($uid, $slugs[10], '30');
[$ok, $msg] = tea_brew($row(), ['tea', 'mint', 'cane-syrup'], true);
ok('the 8th named tea, brewed: the Cast-Iron Kettle unlocks free', $ok && tea_journal($uid)['n'] === 8 && (int)$row()['kettle'] === 2 && str_contains($msg, 'Cast-Iron Kettle') && (int)$row()['coins'] === 250, $msg . ' n=' . tea_journal($uid)['n']);
$add(15);
ok('15 named teas: still Cast-Iron', tea_kettle_unlocks($uid) === [] && (int)$row()['kettle'] === 2 && tea_journal($uid)['n'] === 15, (string)tea_journal($uid)['n']);
$add(16);
ok('16: the Silver Samovar unlocks free', tea_kettle_unlocks($uid) === ['Silver Samovar'] && (int)$row()['kettle'] === 3);
ok('... and that is the top', tea_kettle_next($row()) === null && tea_kettle_unlocks($uid) === [] && (int)$row()['kettle'] === 3);
ok('the samovar brews the top cup', tea_cup(['tea', 'ginseng', 'ginger', 'garden-honey'], (int)$row()['kettle'])['buff'] === ['lore' => 3, 'nimble' => 2]);
q('UPDATE users SET kettle = 0 WHERE id = ?', [$uid]);
ok('a straight ladder: 16 teas but no Copper Kettle = still the tin one', tea_kettle_unlocks($uid) === [] && (int)$row()['kettle'] === 0);
q('UPDATE users SET coins = 150 WHERE id = ?', [$uid]);
[$ok, $msg] = tea_kettle_buy($row());
ok('... buying Copper then climbs as far as the journal allows', $ok && (int)$row()['kettle'] === 3 && str_contains($msg, 'Silver Samovar'), $msg);
ok('stamping an unknown tea does nothing', tea_journal_stamp($uid, 'nope', '1') === false && (int)q_val("SELECT COUNT(*) FROM user_tea_journal WHERE tea_slug = 'nope'") === 0);

echo "== the popover\n";
$reset(); q('UPDATE users SET game_day = 40, coins = 10 WHERE id = ?', [$uid]);
$stock(['tea', 'mint', 'cardamom', 'garden-honey', 'goat-milk', 'cut-chamomile'], 2);
foreach (array_keys($ING) as $s) if (!in_array($s, ['tea', 'mint', 'cardamom', 'garden-honey', 'goat-milk', 'chamomile'], true)) foreach ($ING[$s]['items'] as [$it]) if ($id = item_id_by_slug($it)) q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$_GET = [];
$h = tea_dialog_html($row(), false);
ok('a dialog the kettle link opens (data-hdlg="htea"), closed until then', str_starts_with($h, '<dialog class="hpick htea" id="htea" aria-labelledby="htea-h">') && str_contains($h, 'data-hdlg-close'));
ok('cards only for what the satchel holds (6), the cut flower counts as chamomile', substr_count($h, 'data-tea-ing=') === 6 && str_contains($h, 'data-tea-ing="chamomile" title="Uses your Cut Chamomile"') && !str_contains($h, 'data-tea-ing="ginger"'));
ok('the base can only be something that steeps (3 Base choices)', substr_count($h, 'name="base"') === 3 && !str_contains($h, 'name="base" value="cardamom"'));
ok('Brew posts do=brew to hovel.php with CSRF', (bool)preg_match('~<form method="post" action="[^"]*hovel\.php" class="tea-form"~', $h) && str_contains($h, 'name="csrf"') && str_contains($h, 'name="do" value="brew" data-tea-brew'));
ok('the kettle line and the next kettle', str_contains($h, 'Dented Tin Kettle') && str_contains($h, 'Next: <b>Copper Kettle</b> · 150 Petals (you have 10)') && str_contains($h, 'name="do" value="kettle_buy"'));
ok('the journal: 0 of 20, twenty "???", no names shown', str_contains($h, 'Tea Journal · 0 of 20 found') && substr_count($h, '>???</li>') === 20 && !str_contains($h, 'Masala Chai') && str_contains($h, '20 named teas still to find'));
ok('no inline styles (CSP style-src self)', !preg_match('/\sstyle=/', $h));
$_GET = ['tea' => '1', 'base' => 'tea', 'c' => 'mint,cardamom'];
$h = tea_dialog_html($row(), true);
ok('?tea=1&base=&c=: drawn open, the cards ticked, the base marked', str_contains($h, 'id="htea" aria-labelledby="htea-h" open>') && str_contains($h, '<div class="tea-card on base" data-tea-ing="tea"') && str_contains($h, 'name="base" value="tea" checked') && substr_count($h, ' checked>') === 4, (string)substr_count($h, ' checked>'));
ok('the preview is made by the function that brews', str_contains($h, tea_preview_html(tea_cup(['tea', 'mint', 'cardamom'], 0))) && str_contains(tea_preview_html(tea_cup(['tea', 'mint', 'cardamom'], 0)), 'Lore: steep 4 × 4 ÷ 8 = 2, cap 1'));
ok('a named tea in the preview', str_contains(tea_preview_html(tea_cup(['mint'], 0)), '<b>Mint Tea</b> <span class="tea-stamp">named tea · +1 steep</span>'));
ok('an illegal cup in the preview', str_contains(tea_preview_html(tea_cup(['cardamom'], 0)), 'The base must be a leaf, herb, flower or root.') && str_contains(tea_preview_html(null), 'Pick a base'));
tea_brew($row(), ['mint']);
$_GET = [];
$h = tea_dialog_html($row(), false);
ok('after a brew: today\'s cup, the confirm box, the stamped tea in the journal', str_contains($h, 'Today’s cup: Mint Tea</b> · Sense +1 · until you sleep') && str_contains($h, 'name="confirm" value="1"> Pour out my Mint Tea') && str_contains($h, 'data-tea-pour="This pours out your Mint Tea. Brew again?"') && str_contains($h, 'Tea Journal · 1 of 20 found') && substr_count($h, '>???</li>') === 19 && str_contains($h, '<li class="got"><b>Mint Tea</b>'));
foreach (array_keys($ING) as $s) foreach ($ING[$s]['items'] as [$it]) if ($id = item_id_by_slug($it)) q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $id]);
$h = tea_dialog_html($row(), false);
ok('an empty satchel: no form, a hint, the kettle and the journal still show', !str_contains($h, 'tea-form') && str_contains($h, 'Nothing to steep') && str_contains($h, 'tea-kettle') && str_contains($h, 'tea-journal'));
$d = tea_js_data(1);
ok('the data for the JS twin: every ingredient, 20 teas, the kettle', count($d['ing']) === 31 && count($d['named']) === 20 && $d['k'] === [5, 2, 1] && $d['max'] === 4);
ok('... trimmed to the satchel for the page', array_keys(tea_js_data(0, null, ['tea', 'mint'])['ing']) === ['tea', 'mint'] && array_column(tea_js_data(0, null, ['tea', 'mint'])['named'], 0) === ['Mint Tea']);

if (!empty($argv[2])) {   // cups for the JS twin (tests/tea_parity.js): every named tea, the worked cups, and random legal and illegal cups, in every kettle and under lowered caps
    mt_srand(20261119);
    $all = array_keys($ING); $cups = [];
    $norm = function (array $c): array { return $c['ok'] ? ['name' => $c['name'], 'named' => $c['named'], 'main' => $c['main'], 'mainPts' => $c['steep']['main']['points'], 'side' => $c['side'], 'sidePts' => $c['steep']['side']['points'] ?? 0, 'mainSteep' => $c['steep']['main']['steep'], 'sideSteep' => $c['steep']['side']['steep'] ?? 0, 'K' => $c['steep']['K'], 'capMain' => $c['steep']['main']['cap'], 'capSide' => $c['steep']['side']['cap'] ?? tea_kettle(0, [9, 9])[3]] : ['err' => $c['error']]; };
    $push = function (array $slugs, int $tier, array $caps) use (&$cups, $norm): void { $c = tea_cup($slugs, $tier, $caps); $n = $norm($c); if ($c['ok'] && !$c['steep']['side']) $n['capSide'] = tea_kettle($tier, $caps)[3]; $cups[] = ['slugs' => $slugs, 'tier' => $tier, 'caps' => $caps, 'want' => $n]; };
    foreach ([[3, 2], [2, 1], [1, 0]] as $caps) for ($t = 0; $t < 4; $t++) {
        foreach ($NAMED as $n) { $p = $n['parts']; usort($p, fn($a, $b) => ($ING[$a]['role'] === 'steep' ? 0 : 1) <=> ($ING[$b]['role'] === 'steep' ? 0 : 1)); $push($p, $t, $caps); }
        foreach ([['chamomile'], ['mint', 'lavender', 'lemon'], ['rooibos', 'clove', 'lemon', 'garden-honey'], ['tea', 'ginseng', 'ginger', 'garden-honey'], [], ['', 'mint'], ['tea', 'nettle']] as $w) $push($w, $t, $caps);
    }
    for ($i = 0; $i < 1500; $i++) {
        $n = mt_rand(1, 5); $s = [];
        for ($k = 0; $k < $n; $k++) $s[] = $all[mt_rand(0, count($all) - 1)];
        if (mt_rand(0, 3)) { $st = array_values(array_filter($all, fn($x) => $ING[$x]['role'] === 'steep')); $s[0] = $st[mt_rand(0, count($st) - 1)]; if (mt_rand(0, 2)) $s = array_values(array_unique($s)); }
        $push($s, mt_rand(0, 3), [[3, 2], [3, 2], [2, 1]][mt_rand(0, 2)]);
    }
    $data = [];
    foreach ([[3, 2], [2, 1], [1, 0]] as $caps) for ($t = 0; $t < 4; $t++) $data[$t . ':' . implode(',', $caps)] = tea_js_data($t, $caps);
    file_put_contents($argv[2], json_encode(['data' => $data, 'cups' => $cups], JSON_UNESCAPED_UNICODE));
    ok('wrote ' . count($cups) . ' cups for the JS twin (' . count(array_filter($cups, fn($c) => !isset($c['want']['err']))) . ' legal)', count($cups) > 1500 && count(array_filter($cups, fn($c) => !isset($c['want']['err']))) > 500);
}

$reset(); q("DELETE FROM settings WHERE name IN ('tea_open', 'game_clock_on')"); setting('__reload__');
echo $fails ? "$fails FAILED\n" : "ok\n";

<?php
// 2.7.00 Trail Sights engine gaps: every-Nth-game-day timing (gd=M:R), choose-your-reward (choose=A;B), shop / inn discounts (disc=), tool-tier odds (@a/b/c/d), a villager's own stat check (check=).
// php tests/trail_sights_270.php GAME_DIR   (an installed game, player "sprout"; walk.sh installs one). Route 240 section 1 has the clover patch (as tests/trail_sights.php).
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/adventure.php';
require_once $argv[1] . '/includes/trail_tiles.php';
require_once $argv[1] . '/includes/trail_sights.php';
require_once $argv[1] . '/includes/tools.php';
$fails = 0;
set_setting('npc_clockwork', '0');
$GLOBALS['gv_sights_nocache'] = true;
set_exception_handler(function (Throwable $e) { echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$all = trail_sights_all(); $base = $all['grassland-the-clover-patch'];

echo "== conditions: gd = every Mth game day\n";
ok('gd=7:3 holds on day 3, 10, 24 and not on day 4', trail_sight_cond_ok('gd=7:3', ['gd' => 3]) && trail_sight_cond_ok('gd=7:3', ['gd' => 10]) && trail_sight_cond_ok('gd=7:3', ['gd' => 24]) && !trail_sight_cond_ok('gd=7:3', ['gd' => 4]));
ok('several values: any one', trail_sight_cond_ok('gd=7:0,7:3', ['gd' => 14]) && trail_sight_cond_ok('gd=7:0,7:3', ['gd' => 17]) && !trail_sight_cond_ok('gd=7:0,7:3', ['gd' => 15]));
ok('it combines with another condition', trail_sight_cond_ok('gd=7:3/dp=dusk', ['gd' => 3, 'dp' => 'dusk']) && !trail_sight_cond_ok('gd=7:3/dp=dusk', ['gd' => 3, 'dp' => 'dawn']));
ok('the card text says it', str_contains(trail_sight_cond_text('gd=7:3'), 'every 7th game day'), trail_sight_cond_text('gd=7:3'));
ok('lint takes gd and refuses a bad one', !trail_sight_lint(['when' => 'gd=7:3'] + $base) && (bool)trail_sight_lint(['when' => 'gd=7'] + $base) && (bool)trail_sight_lint(['when' => 'gd=a:b'] + $base));

echo "== lint of the new tokens\n";
$bad = fn(string $rw, array $more = []) => (bool)trail_sight_lint(['rewards' => $rw] + $more + $base);
ok('choose= needs 2 to 4 plain rewards', !$bad('choose=c=5:1;en=2') && $bad('choose=c=5:1') && $bad('choose=c=5:1;en=2;xp=3;xp=4;xp=5') && $bad('choose=c=5:1;title=Boss'));
ok('choose= cannot go with a pick check', $bad('choose=c=5:1;en=2', ['check' => 'pick:3']));
ok('disc= needs rest|shop:percent:minutes', !$bad('disc=rest:10:120') && !$bad('disc=shop:15:60') && $bad('disc=inn:10:60') && $bad('disc=rest:0:60') && $bad('disc=rest:10'));
ok('tier odds need a tool column', $bad('xp=5@5/10', ['tool' => '-']) === true && !$bad('xp=5@5/10/20/40', ['tool' => 'forage:1']) && $bad('xp=5@5/10/200', ['tool' => 'forage:1']));
ok('check= needs stat:dc', !$bad('check=grit:12') && $bad('check=grit') );

echo "== tier odds\n";
ok('a tier picks its number, none or tier 1 the first, past the end the last', trail_sight_tier_chance('item=x:1@5/15/30', 2) === 'item=x:1@15' && trail_sight_tier_chance('item=x:1@5/15/30', 0) === 'item=x:1@5' && trail_sight_tier_chance('item=x:1@5/15/30', 4) === 'item=x:1@30' && trail_sight_tier_chance('xp=3@50', 3) === 'xp=3@50');

echo "== rewards pass (approved: 3% a level by default)\n";
ok('the default is 3 (Josh approved 2026-11-15)', (string)setting('sights_flat_pct_per_level') === '3', (string)setting('sights_flat_pct_per_level'));
set_setting('sights_flat_pct_per_level', '0'); setting('__reload__');
ok('set to 0: nothing changes', trail_sight_flat_scale('xp=10', 35) === 'xp=10');
set_setting('sights_flat_pct_per_level', '3'); setting('__reload__');
ok('on: a flat reward grows 3% a level above 1 (level 35: 10 -> 20)', trail_sight_flat_scale('xp=10', 35) === 'xp=20' && trail_sight_flat_scale('xp=10', 1) === 'xp=10' && trail_sight_flat_scale('c=20@20', 11) === 'c=26@20', trail_sight_flat_scale('xp=10', 35));
ok('a reward with a per-level part, and other tokens, are left alone', trail_sight_flat_scale('xp=3:1', 35) === 'xp=3:1' && trail_sight_flat_scale('item=x:1', 35) === 'item=x:1' && trail_sight_flat_scale('en=3', 35) === 'en=3');
set_setting('sights_flat_pct_per_level', '0'); setting('__reload__');

echo "== a walk on route 240, standing at the clover patch\n";
set_setting('gnav_on', '1'); set_setting('gnav_tiles', '1'); set_setting('game_clock_on', '1'); setting('__reload__');
$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
q("UPDATE expeditions SET status = 'done' WHERE user_id = ?", [$u['id']]);
q("UPDATE routes SET kind = 'road' WHERE id = 240");
$r = q_one('SELECT * FROM routes WHERE id = 240');
q("UPDATE users SET location_id = ?, level = 30, energy = 90, coins = 500, ev_quickwalk = 0, game_day = 10, game_minute = 360 WHERE id = ?", [$r['a_id'], $u['id']]);
q('DELETE FROM trail_sight_uses WHERE user_id = ?', [$u['id']]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]);
[$sok] = start_expedition($u, 240); ok('the walk starts', $sok);
$exp = active_expedition((int)$u['id']); $sc = trail_scene($exp);
$lm = array_values(array_filter($sc['map']['art']['objs'], fn($o) => $o[2] === 'lm-grassland-the-clover-patch'));
$spot = null; foreach ([[-1, 0], [1, 0], [0, -1], [0, 1], [0, 0]] as [$dx, $dy]) if (in_array(tm_tile($sc['map'], $lm[0][0] + $dx, $lm[0][1] + $dy), ['.', ',', 'S'], true)) { $spot = [$lm[0][0] + $dx, $lm[0][1] + $dy]; break; }
$sc['x'] = $spot[0]; $sc['y'] = $spot[1]; trail_save($sc);
trail_sights_ensure_tables();
$put = function (array $chg) use ($base) {
    $r = $chg + $base; q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
    db_insert('trail_sight_rows', ['slug' => $base['slug'], 'verb' => $r['verb'], 'icon' => $r['icon'], 'energy' => $r['energy'], 'cd' => $r['cd'], 'uses' => $r['uses'], 'cond' => $r['when'], 'chk' => $r['check'], 'rewards' => $r['rewards'], 'win' => $r['win'], 'lose' => $r['lose'], 'tool' => $r['tool'], 'fail_en' => $r['fail_en'], 'active' => 1]);
    q('DELETE FROM trail_sight_uses'); $GLOBALS['gv_sights_reload'] = true; trail_sights_all();
};
$fresh = function () use (&$u, &$exp) { $u = q_one('SELECT * FROM users WHERE id = ?', [$u['id']]); $exp = active_expedition((int)$u['id']); $GLOBALS['gv_sights_reload'] = true; };
$go = function (array $opt = []) use (&$u, &$exp, $base) { $x = trail_sight_do($u, $exp, $base['slug'], $opt); save_exp($exp); return $x; };
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$u['id']]);
$xp = fn() => (int)q_val('SELECT xp FROM users WHERE id = ?', [$u['id']]);
$energy = fn() => (int)q_val('SELECT energy FROM users WHERE id = ?', [$u['id']]);

echo "== timing: gd\n";
$put(['when' => 'gd=7:3', 'energy' => 0, 'rewards' => 'xp=2:1']); $fresh();   // game day 10 = 10 mod 7 = 3
[$a] = $go(); ok('on game day 10 (10 mod 7 = 3) the Sight works', $a);
q('UPDATE users SET game_day = 11 WHERE id = ?', [$u['id']]); $put(['when' => 'gd=7:3', 'energy' => 0, 'rewards' => 'xp=2:1']); $fresh();
[$a, $m] = $go(); ok('on game day 11 it is not the right time, and says every 7th game day', !$a && str_contains((string)$m, 'every 7th game day'), (string)$m);
q('UPDATE users SET game_day = 10 WHERE id = ?', [$u['id']]);

echo "== choose your reward\n";
$put(['energy' => 0, 'rewards' => 'choose=c=40:1;en=4', 'check' => '-']); $fresh();
$ci = trail_sight_choose_info(trail_sights_all()[$base['slug']]);
ok('the card gets two options with names', count($ci) === 2 && str_contains($ci[0][1], '40') && str_contains($ci[1][1], '4 energy'), json_encode($ci));
[$a, $m] = $go(); ok('using it without a choice is refused', !$a && str_contains((string)$m, 'Choose your reward'), (string)$m);
[$a, $m] = $go(['reward' => 5]); ok('a choice that is not on offer is refused', !$a);
q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$u['id']]); $fresh(); $c0 = $coins(); $e0 = $energy();
[$a] = $go(['reward' => 0]);
ok('choosing the Petals pays Petals and no energy', $a && $coins() > $c0 && $energy() === $e0, "coins $c0 -> " . $coins() . ", energy $e0 -> " . $energy());
$put(['energy' => 0, 'rewards' => 'choose=c=40:1;en=4']); q('UPDATE users SET energy = 50, coins = 500 WHERE id = ?', [$u['id']]); $fresh(); $c0 = $coins(); $e0 = $energy();
[$a] = $go(['reward' => 1]);
ok('choosing the energy pays energy and no Petals', $a && $energy() === $e0 + 4 && $coins() === $c0, "coins $c0 -> " . $coins() . ", energy $e0 -> " . $energy());
ok('the card form offers the options as buttons', str_contains(trail_sights_cards_html($u, trail_scene($exp), trail_sights_marks($u, trail_scene($exp))), 'name="reward"'));

echo "== discounts\n";
$put(['energy' => 0, 'rewards' => 'disc=rest:25:120,disc=shop:20:60']); $fresh();
[$a] = $go(); ok('the Sight gives both discounts', $a && trail_sight_disc_pct((int)$u['id'], 'rest') === 25 && trail_sight_disc_pct((int)$u['id'], 'shop') === 20);
ok('the inn room is 25% cheaper', gclock_inn_fee((int)$u['id']) === (int)round(gclock_setting_int('inn_fee_petals', 110) * 0.75), (string)gclock_inn_fee((int)$u['id']));
$p0 = shop_price(array_replace($u, ['id' => (int)$u['id']]), 100, 1, 0);
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$u['id']]); $p1 = shop_price($u, 100, 1, 0);
ok('shops charge less while it lasts (20 points off)', $p0 < $p1 && $p1 - $p0 >= 15, "$p0 vs $p1");
trail_sight_disc_set((int)$u['id'], 'shop', 20, 60); q('UPDATE users SET ev_disc = ? WHERE id = ?', [json_encode(['shop' => [20, time() - 5]]), $u['id']]);
ok('a run-out discount counts for nothing', trail_sight_disc_pct((int)$u['id'], 'shop') === 0);
trail_sight_disc_set((int)$u['id'], 'rest', 10, 60); trail_sight_disc_set((int)$u['id'], 'rest', 5, 60);
ok('a smaller discount never replaces a bigger one', trail_sight_disc_pct((int)$u['id'], 'rest') === 10);
q('UPDATE users SET ev_disc = NULL WHERE id = ?', [$u['id']]);

echo "== tool-tier odds\n";
$mk = function (int $tier) use ($u) { $slug = "sg-test-forage-$tier"; if (!item_id_by_slug($slug)) db_insert('items', ['name' => "Test forage $tier", 'slug' => $slug, 'category' => 'tool', 'rarity' => 5, 'base_price' => 1, 'description' => 't', 'edible' => 0, 'effects' => json_encode(['tool' => 'forage', 'tier' => $tier]), 'tradable' => 0]); give_item((int)$u['id'], item_id_by_slug($slug), 1); tool_cache_reset(); };
q('DELETE FROM user_items WHERE user_id = ? AND item_id IN (SELECT id FROM items WHERE effects LIKE ?)', [$u['id'], '%"tool":"forage"%']); tool_cache_reset();
$mk(1);
$put(['energy' => 0, 'tool' => 'forage:1', 'rewards' => 'xp=50:1@0/100']); $fresh(); $x0 = $xp();
[$a] = $go(); ok('with a tier 1 tool the 0% chance never pays', $a && $xp() === $x0, "xp $x0 -> " . $xp());
$mk(2); $put(['energy' => 0, 'tool' => 'forage:1', 'rewards' => 'xp=50:1@0/100']); $fresh(); $x0 = $xp();
[$a] = $go(); ok('with a tier 2 tool the 100% chance always pays', $a && $xp() > $x0, "xp $x0 -> " . $xp());

echo "== a villager's own stat check\n";
$loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: []; $loc['landscape'] = 'grassland';
$x0 = $xp(); $lines = trail_sight_pay($u, $loc, 'check=grit:99,xp=40:1', 'Someone');
ok('a check they cannot pass pays nothing and says so', $xp() === $x0 && str_contains(implode(' ', $lines), 'ask more of you'), implode(' | ', $lines));
$x0 = $xp(); $lines = trail_sight_pay($u, $loc, 'check=grit:0,xp=40:1', 'Someone');
ok('a check of difficulty 0 pays', $xp() > $x0, implode(' | ', $lines));
q('DELETE FROM trail_sight_rows WHERE slug = ?', [$base['slug']]);
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);

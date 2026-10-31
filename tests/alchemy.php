<?php
// Alchemy Table potions (includes/alchemy.php). Run by craft.sh on its install (gnome "sprout"): php tests/alchemy.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/pal_jobs.php';
require_once APP_ROOT . '/includes/crafting.php';
require_once APP_ROOT . '/includes/health.php';
require_once APP_ROOT . '/includes/garden_logic.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
function have(int $uid, string $slug): int { return (int)q_val('SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]); }

$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");

echo "== items and recipes\n";
pj_ensure_content(); ensure_crafts(); pj_ensure_content(); ensure_crafts();
foreach (ALCHEMY_ITEMS as $slug => [$name, $cat, , $price]) {
    $it = q_one('SELECT * FROM items WHERE slug = ?', [$slug]);
    ok("$slug item", $it && $it['name'] === $name && $it['category'] === $cat && (int)$it['base_price'] === $price, json_encode($it));
    ok("$slug made once", (int)q_val('SELECT COUNT(*) FROM items WHERE slug = ?', [$slug]) === 1);
    ok("$slug recipe in potions", q_val('SELECT category FROM recipes WHERE slug = ?', [$slug]) === 'potions');
}
$n = (int)q_val("SELECT COUNT(*) FROM recipes WHERE category = 'potions'");
ok('8 potion recipes', $n === 8, (string)$n);
// value check: every potion sells for more than its ingredients cost, and less than twice
foreach (q("SELECT r.slug, r.ingredients, r.output_qty, i.base_price FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE r.category = 'potions'")->fetchAll() as $r) {
    $cost = 0;
    foreach (json_decode($r['ingredients'], true) as $s => $q) $cost += $q * (int)q_val('SELECT base_price FROM items WHERE slug = ?', [$s]);
    $out = (int)$r['base_price'] * (int)$r['output_qty'];
    ok("price {$r['slug']}: ingredients $cost, makes $out", $cost > 0 && $out > $cost && $out < 2 * $cost);
}
ok('emoji: potions are 🧪', name_emoji('Strong Healing Potion') === '🧪' && name_emoji('Lucky Draught') === '🧪' && name_emoji('Stoneskin Brew') === '🧪' && name_emoji('Swiftfoot Elixir') === '🧪');
ok('emoji: Cold Brew Coffee still ☕', name_emoji('Cold Brew Coffee') === '☕');

echo "== garden tonic is a soil improver\n";
$ton = q_one("SELECT * FROM items WHERE slug = 'garden-tonic'");
[$af, $al] = amendment($ton);
ok('tonic fertility and life', $af === 10 && $al === 4);
ok('tonic N, P, K', amendment_npk($ton) === ['n' => 10, 'p' => 10, 'k' => 10]);

echo "== drinks\n";
$lucky = (int)q_val("SELECT id FROM items WHERE slug = 'lucky-draught'");
give_item($uid, $lucky, 2);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$e1, $em] = eat_item($u, $lucky);
$buff = json_decode((string)q_val('SELECT buff FROM users WHERE id = ?', [$uid]), true) ?: [];
ok('drink a Lucky Draught', $e1 === true && ($buff['luck'] ?? 0) === 6, json_encode([$em, $buff]));
ok('it says drink', str_contains(implode(' ', $em), 'drink the Lucky Draught'), implode(' ', $em));
ok('one left', have($uid, 'lucky-draught') === 1);

echo "== gnome healing tiers\n";
cfg(['hp_persist' => 1]);
q('UPDATE expeditions SET status = \'done\' WHERE user_id = ? AND status = \'active\'', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[, $max] = hp_get($u);
$strong = alchemy_item_id('strong-healing-potion'); $grand = alchemy_item_id('grand-healing-elixir');
give_item($uid, $strong, 1); give_item($uid, $grand, 1);
q('UPDATE users SET hp = 1, hp_at = ? WHERE id = ?', [now(), $uid]); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$s1, $sm] = hp_use($u, 'potion', $strong);
[$hpS] = hp_get(q_one('SELECT * FROM users WHERE id = ?', [$uid]));
ok('Strong heals 75%', $s1 === true && $hpS === min($max, 1 + (int)ceil($max * 0.75)), "$sm hp $hpS/$max");
q('UPDATE users SET hp = 1, hp_at = ? WHERE id = ?', [now(), $uid]); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$g1] = hp_use($u, 'potion', $grand);
[$hpG] = hp_get(q_one('SELECT * FROM users WHERE id = ?', [$uid]));
ok('Grand heals fully', $g1 === true && $hpG === $max, "hp $hpG/$max");
q('UPDATE users SET hp = 1, hp_at = ? WHERE id = ?', [now(), $uid]); $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
[$g2] = hp_use($u, 'potion', $grand);
ok('none left: refused', $g2 === false);
[$g3] = hp_use($u, 'potion', $lucky);
ok('a draught is not a healing potion', $g3 === false);
give_item($uid, $strong, 2);
$hb = hp_card_html($u); ok('Health box lists the tier', str_contains($hb, 'Strong Healing Potion ×' . have($uid, 'strong-healing-potion') . ' (+75%)'), strip_tags($hb));
q('UPDATE users SET hp = NULL, hp_at = NULL WHERE id = ?', [$uid]);

echo "== pals: healing tiers and a Lucky Draught on a trip\n";
cfg(['puzzles_open' => 1, 'jigsaw_open' => 1, 'ppal_open' => 1, 'pj_open' => 1, 'pj_min_level' => 10, 'pj_max_away' => 3, 'pj_runs_per_day' => 6]);
require_once APP_ROOT . '/includes/jigsaw.php'; jigsaw_ensure(); ppal_ensure();
q('UPDATE users SET level = 10 WHERE id = ?', [$uid]);
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
$MAP = (int)q_val("SELECT id FROM puzzle_pics WHERE slug = 'jig-maplewold'");
if (!q_val('SELECT 1 FROM ppal_releases WHERE user_id = ? AND pic_id = ?', [$uid, $MAP])) q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $MAP, now(), 'free']);
$keys = array_map(fn($p) => $p['key'], ppal_roster(ppal_pic($MAP)));
ppal_claim($u, $keys[0], $MAP); ppal_claim($u, $keys[1], $MAP);
$P = array_values(pj_pals($uid));
$pa = $P[0]['uid']; $pb = $P[1]['uid'];
q('UPDATE ppal_found SET hp = 1, hp_at = ?, active = 0 WHERE user_id = ? AND pal_uid = ?', [now(), $uid, $pa]);
[$h1] = pj_heal($u, $pa, 'strong-healing-potion');
$pal = pj_pal($uid, $pa);
ok('Strong: +24 HP for a pal', $h1 === true && $pal['hp'] === min($pal['max'], 25), json_encode([$pal['hp'], $pal['max']]));
give_item($uid, $grand, 1);
q('UPDATE ppal_found SET hp = 1, hp_at = ? WHERE user_id = ? AND pal_uid = ?', [now(), $uid, $pa]);
[$h2] = pj_heal($u, $pa, 'grand-healing-elixir');
$pal = pj_pal($uid, $pa);
ok('Grand: full HP for a pal', $h2 === true && $pal['hp'] === $pal['max']);
q('UPDATE ppal_found SET hp = 1, hp_at = ? WHERE user_id = ? AND pal_uid = ?', [now(), $uid, $pa]);
[$h3] = pj_heal($u, $pa, 'grand-healing-elixir');
ok('no Grand left: refused', $h3 === false);
[$h4] = pj_heal($u, $pa, 'lucky-draught');
ok('a draught falls back to the Healing Potion (none held: refused)', $h4 === (pj_potion_count($uid) > 0));
q('UPDATE ppal_found SET hp = -1 WHERE user_id = ? AND pal_uid = ?', [$uid, $pa]);   // -1 = full
$tool = q_one("SELECT id FROM items WHERE effects LIKE '%\"tool\":\"forage\"%' ORDER BY id LIMIT 1");
give_item($uid, (int)$tool['id'], 1);
$land = 'forest';
q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $lucky]);
[$t0, $tm0] = pj_trip_send($u, $pa, $land, 'forage', 1, 0, false, true);
ok('no Lucky Draught: refused', $t0 === false && str_contains($tm0, 'Lucky Draught'), $tm0);
ok('pal still home', pj_pal($uid, $pa)['status'] === 'home');
give_item($uid, $lucky, 1);
[$t1, $tm1] = pj_trip_send($u, $pa, $land, 'forage', 1, 0, false, true);
ok('trip with a Lucky Draught', $t1 === true && str_contains($tm1, 'Lucky Draught'), $tm1);
ok('the draught is used', have($uid, 'lucky-draught') === 0);
$res = json_decode((string)q_val("SELECT result FROM ppal_jobs WHERE user_id = ? AND pal_uid = ? AND kind = 'trip' ORDER BY id DESC LIMIT 1", [$uid, $pa]), true);
ok('trip result notes the luck', ($res['luck'] ?? 0) === ALCHEMY_LUCK_PAL);
$pb2 = pj_pal($uid, $pb); $a = $b = 0;
for ($i = 0; $i < 60; $i++) {
    foreach (pj_roll_trip($pb2, $land, 'forage', 3, 8, 0, 'L' . $i)['items'] as $it) $a += $it[1];
    foreach (pj_roll_trip($pb2, $land, 'forage', 3, 8, 0, 'L' . $i, ALCHEMY_LUCK_PAL)['items'] as $it) $b += $it[1];
}
ok("luck finds more over 60 trips ($a plain, $b lucky)", $b > $a);

echo "== every potion has a player use\n";
$u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
foreach (array_keys(ALCHEMY_ITEMS) + ['x' => 'healing-potion'] as $slug) {
    $it = q_one('SELECT * FROM items WHERE slug = ?', [$slug]);
    ok("$slug icon is the installed png", str_contains(item_icon($it), 'assets/img/ph/' . $slug . '.png'), item_icon($it));
    $use = isset(ALCHEMY_HEAL[$slug]) ? 'heal' : (!empty(ALCHEMY_ITEMS[$slug][4]) ? 'drink' : ($it['category'] === 'soil' ? 'soil' : ''));
    ok("$slug has a use ($use)", $use !== '');
}
foreach (['sages-draught', 'stoneskin-brew', 'swiftfoot-elixir', 'lucky-draught'] as $slug) {
    give_item($uid, alchemy_item_id($slug), 1);
    [$dk, $dm] = alchemy_drink($u, alchemy_item_id($slug));
    $buff = json_decode((string)q_val('SELECT buff FROM users WHERE id = ?', [$uid]), true) ?: [];
    ok("drink $slug from My Gnome", $dk && $buff === array_diff_key(ALCHEMY_ITEMS[$slug][5]['temp'], ['minutes' => 1]), $dm . ' ' . json_encode($buff));
}
[$dk] = alchemy_drink($u, alchemy_item_id('strong-healing-potion'));
ok('alchemy_drink refuses a healing tier (Health box does those)', $dk === false);
[$dk] = alchemy_drink($u, (int)q_val("SELECT id FROM items WHERE slug = 'chanterelle'"));
ok('alchemy_drink refuses a non-potion', $dk === false);
give_item($uid, alchemy_item_id('sages-draught'), 1); give_item($uid, alchemy_item_id('garden-tonic'), 1);
$card = alchemy_card_html($u);
ok('My Gnome Potions box: drink button and tonic link', str_contains($card, 'Sage’s Draught ×') && str_contains($card, 'name="do" value="drink"') && str_contains($card, 'Garden Tonic ×'), strip_tags($card));
// Garden Tonic on the gnome's own plot
$tonic = alchemy_item_id('garden-tonic');
$t = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND user_id = ? AND plant_id IS NULL ORDER BY y, x LIMIT 1', [active_plot_id($uid), $uid]);
q('UPDATE plot_tiles SET tilled = 1, feed_hours = 0, fertility = 40, n = 40, p = 40, k = 40 WHERE id = ?', [$t['id']]);
q('UPDATE users SET energy = 100 WHERE id = ?', [$uid]);
$before = have($uid, 'garden-tonic');
[$gk, $gm] = garden_action($uid, 'soil', (int)$t['x'], (int)$t['y'], $tonic);
ok('pour Garden Tonic on a square', $gk === true && have($uid, 'garden-tonic') === $before - 1, implode(' ', (array)$gm));
ok('the square is feeding', (int)q_val('SELECT feed_hours FROM plot_tiles WHERE id = ?', [$t['id']]) > 0);

echo "== scene hotspots: every potions object finds a recipe, every recipe has an object\n";
$hot = (require APP_ROOT . '/includes/data/craft_scenes.php')['potions']['hot'];
$names = q("SELECT name FROM recipes WHERE category = 'potions'")->fetchAll(PDO::FETCH_COLUMN);
$hit = [];
foreach ($hot as [$id, , , , , , $to]) {
    $w = substr($to, 2);
    $m = array_filter($names, fn($nm) => mb_stripos($nm, $w) !== false);
    ok("$id ($to) matches a recipe", str_starts_with($to, 'q=') && $m);
    foreach ($m as $nm) $hit[$nm] = true;
}
ok('every potion recipe is behind an object', count($hit) === count($names), implode(', ', array_diff($names, array_keys($hit))));

echo $fails ? "ALCHEMY FAILS: $fails\n" : "alchemy: all ok\n";
exit($fails ? 1 : 0);

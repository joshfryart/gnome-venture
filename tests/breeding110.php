<?php
// v1.1.0: crop breeding (hybrids). Run by breeding110.sh on a fresh install (temp copy, SQLite).
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/garden_logic.php';
require_once $argv[1] . '/includes/breeding110.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }

$u = q_one("SELECT * FROM users WHERE username = 'sprout'");
$uid = (int)$u['id'];
$region = (int)q_val('SELECT region_id FROM plots WHERE user_id = ? ORDER BY id LIMIT 1', [$uid]);
q('UPDATE users SET coins = 1000000, level = 20, energy = 500 WHERE id = ?', [$uid]);
cfg(['hybrid_on' => 1, 'hybrid_min_level' => 10, 'hybrid_chance_pct' => 100, 'hybrid_chance_max_pct' => 100, 'hybrid_beehive_pct' => 2, 'seed_save_chance' => 100]);
function plant(string $slug): array { return q_one('SELECT * FROM plants WHERE slug = ?', [$slug]); }
function mkplot(): int { global $uid, $region; $id = create_garden($uid, $region, null, 'B' . mt_rand(1000, 9999)); q('UPDATE plots SET garden_level = 12 WHERE id = ?', [$id]); return $id; }
function put(int $plot, int $x, int $y, string $slug): array {
    $p = plant($slug);
    q('UPDATE plot_tiles SET plant_id = ?, tilled = 1, planted_at = ?, growth_seconds = ?, growth_updated_at = ?, yx = NULL, yy = NULL WHERE plot_id = ? AND x = ? AND y = ?',
        [$p['id'], gmdate('Y-m-d H:i:s', time() - 99999), (int)$p['grow_minutes'] * 60 + 100, now(), $plot, $x, $y]);
    return [annotate_tile(q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND x = ? AND y = ?', [$plot, $x, $y]), $p), $p];
}
function master(int $uid, string $slug, bool $on = true): void {
    $p = plant($slug);
    q('DELETE FROM user_plant_knowledge WHERE user_id = ? AND plant_id = ?', [$uid, $p['id']]);
    if ($on) db_insert('user_plant_knowledge', ['user_id' => $uid, 'plant_id' => $p['id'], 'knowledge' => $p['knowledge_max']]);
}
function qty(int $uid, string $slug): int { return (int)q_val('SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]); }
function fresh(int $uid): array { return q_one('SELECT * FROM users WHERE id = ?', [$uid]); }
function harvest(int $plot, int $x, int $y, string $slug): array { global $uid; [$t, $p] = put($plot, $x, $y, $slug); return do_harvest(fresh($uid), $t, $p); }

echo "== import\n";
$n = (int)q_val('SELECT COUNT(*) FROM hybrids');
ok("hybrids imported ($n)", $n >= 20);
ok('every hybrid has plant + seed + produce', (int)q_val('SELECT COUNT(*) FROM hybrids h JOIN plants p ON p.id = h.plant_id JOIN items s ON s.id = p.seed_item_id JOIN items pr ON pr.id = p.produce_item_id') === $n);
ok('at least 3 flower hybrids', (int)q_val("SELECT COUNT(*) FROM hybrids h JOIN plants p ON p.id = h.plant_id WHERE p.kind = 'flower'") >= 3);
$pom = plant('pomato'); $pt = plant('potato'); $tm = plant('tomato');
ok('stats: grow = avg x 0.85', (int)$pom['grow_minutes'] === (int)round(((int)$pt['grow_minutes'] + (int)$tm['grow_minutes']) / 2 * 0.85), (string)$pom['grow_minutes']);
ok('stats: yield max = max parent + 1', (int)$pom['yield_max'] === max((int)$pt['yield_max'], (int)$tm['yield_max']) + 1);
$pp = (int)q_val('SELECT base_price FROM items WHERE id = ?', [$pom['produce_item_id']]);
$best = max((int)q_val('SELECT base_price FROM items WHERE id = ?', [$pt['produce_item_id']]), (int)q_val('SELECT base_price FROM items WHERE id = ?', [$tm['produce_item_id']]));
ok('produce price = 1.5 x higher parent', $pp === (int)round(1.5 * $best), "$pp vs $best");
ok('hybrid seeds not in any NPC shop', (int)q_val("SELECT COUNT(*) FROM shop_stock ss WHERE ss.item_id IN (SELECT p.seed_item_id FROM hybrids h JOIN plants p ON p.id = h.plant_id)") === 0);
ok('hybrid seeds tradable', (int)q_val("SELECT MIN(i.tradable) FROM hybrids h JOIN plants p ON p.id = h.plant_id JOIN items i ON i.id = p.seed_item_id") === 1);
[$a2, $s2] = breeding110_import();
ok('re-import adds nothing', $a2 === 0);
q("UPDATE hybrids SET trait = 'EDITED', chance_bonus = 0 WHERE slug = 'triticale'"); breeding110_import();
ok('re-import keeps admin edits', q_val("SELECT trait FROM hybrids WHERE slug = 'triticale'") === 'EDITED');
q("UPDATE hybrids SET trait = 'Tough, high-yield grain' WHERE slug = 'triticale'");

echo "== breeding\n";
$plot = mkplot();
master($uid, 'potato'); master($uid, 'tomato');
put($plot, 1, 0, 'tomato');   // the neighbour must be growing at harvest time
$before = qty($uid, 'pomato-seed');
$msgs = harvest($plot, 0, 0, 'potato');
ok('neighbours + mastered + 100%: hybrid seed given', qty($uid, 'pomato-seed') === $before + 1, implode(' | ', $msgs));
ok('flash says A hybrid', (bool)array_filter($msgs, fn($m) => str_contains($m, '🧬 A hybrid!')));
ok('discovery recorded', (int)q_val('SELECT count FROM user_hybrids uh JOIN hybrids h ON h.id = uh.hybrid_id WHERE h.slug = ? AND uh.user_id = ?', ['pomato', $uid]) === 1);
ok('Almanac page unlocked', (bool)q_val("SELECT 1 FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'plant:pomato' AND ue.user_id = ?", [$uid]));
harvest($plot, 0, 0, 'potato');
ok('second find bumps count', (int)q_val('SELECT count FROM user_hybrids uh JOIN hybrids h ON h.id = uh.hybrid_id WHERE h.slug = ? AND uh.user_id = ?', ['pomato', $uid]) === 2);

echo "== double harvest\n";
[$t, $p] = put($plot, 0, 0, 'potato');
$before = qty($uid, 'pomato-seed');
do_harvest(fresh($uid), $t, $p);
$threw = false;
try { do_harvest(fresh($uid), $t, $p); } catch (UserError $e) { $threw = true; }
ok('second submit of the same harvest is refused', $threw);
ok('only one roll (one seed at most)', qty($uid, 'pomato-seed') === $before + 1);

echo "== not mastered / not neighbours\n";
master($uid, 'tomato', false);
$before = qty($uid, 'pomato-seed');
harvest($plot, 0, 0, 'potato');
ok('one parent not mastered: no seed', qty($uid, 'pomato-seed') === $before);
master($uid, 'tomato');
q('UPDATE plot_tiles SET plant_id = NULL WHERE plot_id = ?', [$plot]);
put($plot, 1, 1, 'tomato');   // diagonal
harvest($plot, 0, 0, 'potato');
ok('diagonal: no seed', qty($uid, 'pomato-seed') === $before);
q('UPDATE plot_tiles SET plant_id = NULL WHERE plot_id = ?', [$plot]);
put($plot, 2, 0, 'tomato');   // two apart
harvest($plot, 0, 0, 'potato');
ok('two squares apart: no seed', qty($uid, 'pomato-seed') === $before);

echo "== level lock and settings\n";
q('UPDATE plot_tiles SET plant_id = NULL WHERE plot_id = ?', [$plot]);
put($plot, 1, 0, 'tomato');
q('UPDATE users SET level = 5 WHERE id = ?', [$uid]);
harvest($plot, 0, 0, 'potato');
ok('below level 10: no roll', qty($uid, 'pomato-seed') === $before);
[$st, $sp] = put($plot, 0, 0, 'potato');
ok('garden note shows the lock', str_contains(breeding110_garden_note(fresh($uid), $st, $sp), 'Breeding opens at gnome level 10'));
ok('Almanac page shows the lock', str_contains(breeding110_notes(fresh($uid)), 'Breeding opens at gnome level 10'));
q('UPDATE users SET level = 20 WHERE id = ?', [$uid]);
ok('garden note: could cross', str_contains(breeding110_garden_note(fresh($uid), $st, $sp), 'could cross'));
master($uid, 'tomato', false);
ok('garden note: master both', str_contains(breeding110_garden_note(fresh($uid), $st, $sp), 'master both'));
master($uid, 'tomato');
cfg(['hybrid_min_level' => 25]);
harvest($plot, 0, 0, 'potato');
ok('hybrid_min_level setting is read', qty($uid, 'pomato-seed') === $before);
cfg(['hybrid_min_level' => 10]);
cfg(['hybrid_on' => 0]);
put($plot, 1, 0, 'tomato'); harvest($plot, 0, 0, 'potato');
ok('hybrid_on = 0: no roll', qty($uid, 'pomato-seed') === $before);
cfg(['hybrid_on' => 1]);
q("UPDATE hybrids SET enabled = 0 WHERE slug = 'pomato'");
put($plot, 1, 0, 'tomato'); harvest($plot, 0, 0, 'potato');
ok('admin disabled hybrid: no roll', qty($uid, 'pomato-seed') === $before);
q("UPDATE hybrids SET enabled = 1 WHERE slug = 'pomato'");
cfg(['hybrid_chance_pct' => 6, 'hybrid_chance_max_pct' => 20]);
$h = q_one("SELECT * FROM hybrids WHERE slug = 'pomato'");
ok('chance: base 6', breeding110_chance($plot, $h) === 6);
$h['chance_bonus'] = 40;
ok('chance: capped at max 20', breeding110_chance($plot, $h) === 20);
cfg(['hybrid_chance_pct' => 100, 'hybrid_chance_max_pct' => 100]);

echo "== HARD: a hybrid never returns its own seed\n";
$own = qty($uid, 'pomato-seed'); $ps = qty($uid, 'potato-seed') + qty($uid, 'tomato-seed');
for ($i = 0; $i < 25; $i++) { $m = harvest($plot, 3, 3, 'pomato'); }
ok('25 hybrid harvests: 0 hybrid seeds', qty($uid, 'pomato-seed') === $own);
ok('parent seeds came back instead', qty($uid, 'potato-seed') + qty($uid, 'tomato-seed') > $ps);
ok('hybrid produce is given', qty($uid, 'pomato') > 0);

echo "== Almanac notes\n";
$html = breeding110_notes(fresh($uid));
ok('discovered hybrid shown in full', str_contains($html, 'Pomato') && str_contains($html, 'Potato × Tomato'));
ok('undiscovered hybrid does not reveal parents', !str_contains($html, 'Triticale') && !str_contains($html, 'Rye'));
ok('Breeding notes page exists', (bool)q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Breeding notes'"));
echo "== visit.php cross hint (v1.2.3)\n";
$vp = mkplot(); $tr = q_one("SELECT pa.slug AS a, pb.slug AS b FROM hybrids h JOIN plants pa ON pa.id = h.parent_a_plant_id JOIN plants pb ON pb.id = h.parent_b_plant_id WHERE h.slug = 'triticale'");
put($vp, 0, 0, 'potato'); put($vp, 1, 0, 'tomato'); put($vp, 0, 1, $tr['a']); put($vp, 1, 1, $tr['b']);
q('UPDATE users SET level = 50 WHERE id = ?', [$uid]);
$vn = breeding110_visit_note(fresh($uid), $vp);
ok('visit hint: only the discovered cross is counted', str_contains($vn, '1 possible cross here') && str_contains($vn, 'Pomato') && !str_contains($vn, 'Triticale'), $vn);
q('UPDATE users SET level = 1 WHERE id = ?', [$uid]);
ok('visit hint: hidden below the hybrid min level', breeding110_visit_note(fresh($uid), $vp) === '');
q('UPDATE users SET level = 50 WHERE id = ?', [$uid]);
$vp2 = mkplot(); put($vp2, 0, 0, 'potato'); put($vp2, 2, 2, 'tomato');
ok('visit hint: not side by side = no hint', breeding110_visit_note(fresh($uid), $vp2) === '');
require_once $argv[1] . '/includes/fair.php';
ok('fair bonus for hybrid only', breeding110_fair_bonus(plant('pomato')) > 0 && breeding110_fair_bonus(plant('potato')) === 0);
echo $fails ? "FAILED: $fails\n" : "ALL OK\n";
exit($fails ? 1 : 0);

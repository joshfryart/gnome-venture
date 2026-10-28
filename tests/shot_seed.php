<?php
// v2.0.73: make the demo account (default "sprout", installed by walk.sh) look lived-in for the front-page screenshots (tests/shots.sh).
// Usage: php tests/shot_seed.php GAME_DIR [username]. SQLite only (a test copy). Tills the plot, plants a mixed bed in several growth stages, fills the satchel.
$GAME = $argv[1]; $name = $argv[2] ?? 'sprout';
$p = new PDO('sqlite:' . $GAME . '/data/game.sqlite'); $p->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
$uid = (int)$p->query("SELECT id FROM users WHERE username = " . $p->quote($name))->fetchColumn();
$plot = (int)$p->query("SELECT id FROM plots WHERE user_id = $uid")->fetchColumn();
if (!$uid || !$plot) { fwrite(STDERR, "no such account\n"); exit(1); }
$now = gmdate('Y-m-d H:i:s');
$plants = $p->query("SELECT id, grow_minutes FROM plants WHERE slug IN ('radish','carrot','sunflower','tomato','lettuce','marigold','pumpkin','strawberry','pea','bean') ORDER BY id LIMIT 8")->fetchAll(PDO::FETCH_ASSOC);
if (!$plants) $plants = $p->query("SELECT id, grow_minutes FROM plants ORDER BY id LIMIT 8")->fetchAll(PDO::FETCH_ASSOC);
$tiles = $p->query("SELECT id FROM plot_tiles WHERE plot_id = $plot ORDER BY y, x")->fetchAll(PDO::FETCH_COLUMN);
$fr = [1.2, 0.95, 0.6, 0.35, 0.8, 0.15, 1.2, 0.5];   // share of grow time done (>=1 = ready)
foreach ($tiles as $i => $tid) {
    $pl = $plants[$i % count($plants)]; $f = $fr[$i % count($fr)];
    if ($i % 5 === 4) { $p->exec("UPDATE plot_tiles SET tilled = 1, plant_id = NULL, fertility = 55, soil_life = 45 WHERE id = $tid"); continue; }   // a few empty tilled beds
    $gs = (int)($pl['grow_minutes'] * 60 * $f);
    $p->exec("UPDATE plot_tiles SET tilled = 1, plant_id = {$pl['id']}, planted_at = '$now', last_watered = '$now', growth_seconds = $gs, growth_updated_at = '$now', moisture = 80, fertility = 60, soil_life = 50 WHERE id = $tid");
}
$p->exec("UPDATE users SET coins = 1240, energy = 10 WHERE id = $uid");
$items = $p->query("SELECT id FROM items WHERE category IN ('seed','crop','produce','tool','food','dish','ingredient') ORDER BY id LIMIT 24")->fetchAll(PDO::FETCH_COLUMN);
if (!$items) $items = $p->query("SELECT id FROM items ORDER BY id LIMIT 24")->fetchAll(PDO::FETCH_COLUMN);
foreach ($items as $k => $iid) {
    $have = (int)$p->query("SELECT COUNT(*) FROM user_items WHERE user_id = $uid AND item_id = $iid")->fetchColumn();
    if ($have) $p->exec("UPDATE user_items SET qty = " . (2 + $k % 5) . " WHERE user_id = $uid AND item_id = $iid");
    else try { $p->exec("INSERT INTO user_items (user_id, item_id, qty) VALUES ($uid, $iid, " . (2 + $k % 5) . ")"); } catch (Throwable $e) {}
}
echo "seeded " . count($tiles) . " tiles, " . count($items) . " items\n";

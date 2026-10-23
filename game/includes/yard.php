<?php
declare(strict_types=1);

/**
 * The yard (v0.7.32–0.7.35): every garden sits in a yard a little bigger than its beds. Buildings, decor
 * and the bed squares themselves are placed on it, and where things go matters: hives, rain barrels,
 * hedges, birdbaths, shade trees and paths help the beds near them. Decor adds curb appeal for the
 * Garden of the Month, and other gnomes can visit (view only).
 *
 * Positions are yard squares, 0-based. Bed squares keep their x/y (their identity) and get a yard spot
 * in plot_tiles.yx / yy. Buildings and decor live in garden_objects with their footprint (w × h after
 * rotation). Everything sent from the designer is checked again here: nothing from the browser is trusted.
 */

require_once __DIR__ . '/gardens.php';
require_once __DIR__ . '/items.php';   // v0.9.8: art_path / item_pic
require_once __DIR__ . '/sinks.php';   // v0.9.7: skins, signs, curios

const YARD_MAX_SIDE = 40;

// building => [width, height, bonus]
const YARD_BUILDINGS = [
    'kitchen' => [2, 2, ''], 'rain_barrel' => [1, 1, 'barrel'], 'tool_shed' => [2, 2, ''],
    'compost_bin' => [1, 1, ''], 'beehive' => [1, 1, 'hive'], 'greenhouse' => [3, 2, ''], 'root_cellar' => [2, 1, ''],
    'worm_farm' => [1, 1, ''], 'ladybird_lodge' => [1, 1, 'lodge'], 'frog_pond' => [2, 2, 'pond'],   // v1.0.0: garden animals
    'quail_coop' => [2, 1, ''], 'silk_shelf' => [1, 1, ''], 'tortoise_run' => [2, 2, ''],   // v1.2.0
    'butterfly_bush' => [1, 1, 'bush'], 'snail_jar' => [1, 1, ''],   // v1.4.0
];

// What each bonus does, and how far it reaches (squares, counting diagonals)
const YARD_BONUSES = [
    'hive'   => ['🐝', 'Beehive', 2, 'Beds within 2 squares get a bigger pollinator chance.'],
    'barrel' => ['🛢️', 'Rain barrel', 1, 'Beds next to it stay watered longer.'],
    'shade'  => ['🌳', 'Shade tree', 1, 'Beds next to it hold water longer in the cool shade.'],
    'hedge'  => ['🌿', 'Hedge', 1, 'Beds next to it grow weeds half as fast (no blown-in seed).'],
    'birds'  => ['🐦', 'Birds', 2, 'Beds within 2 squares sometimes give an extra crop (the birds eat the slugs).'],
    'path'   => ['🪨', 'Path', 1, 'Beds next to a path are easier to reach: area actions sometimes cost no energy.'],
    'lodge'  => ['🐞', 'Ladybird Lodge', 2, 'Ladybirds keep aphids off beds within 2 squares (once someone lives there).'],
    'pond'   => ['🐸', 'Frog Pond', 3, 'Frogs keep slugs, snails and gnats off beds within 3 squares (once someone lives there).'],
    'bush'   => ['🦋', 'Butterfly Bush', 2, 'Flowers within 2 squares sometimes give an extra stem at harvest (once a butterfly lives there).'],   // v1.4.0
];

const DECOR_TYPES = ['path' => 'Paths', 'fence' => 'Fences & walls', 'hedge' => 'Hedges', 'tree' => 'Trees',
    'water' => 'Birds & water', 'seat' => 'Seats', 'light' => 'Lights', 'ornament' => 'Ornaments'];

// slug => [name, icon, type, w, h, appeal, price, bonus, description, sold in the shop (0 = crafted only)]
const DECOR = [
    'stone-path'      => ['Flagstone Path', '', 'path', 1, 1, 0, 15, 'path', 'Grey flagstones, one square.', 1],
    'bark-path'       => ['Bark Path', '', 'path', 1, 1, 0, 10, 'path', 'Soft shredded bark underfoot, one square.', 1],
    'gravel-path'     => ['Gravel Path', '', 'path', 1, 1, 0, 12, 'path', 'Crunchy pea gravel, one square.', 1],
    'brick-path'      => ['Brick Path', '', 'path', 1, 1, 1, 25, 'path', 'Warm red bricks in a herringbone, one square.', 1],
    'stepping-stones' => ['Stepping Stones', '', 'path', 1, 1, 1, 18, 'path', 'Round stones set in the grass. Made from dressed stone.', 0],
    'picket-fence'    => ['Picket Fence', '', 'fence', 1, 1, 1, 20, '', 'A white picket panel. Rotate it to run across or up and down.', 1],
    'garden-gate'     => ['Garden Gate', '', 'fence', 1, 1, 1, 30, '', 'A little gate that joins fences and walls. Rotate it to line it up.', 1],   // v0.9.5
    'wattle-fence'    => ['Wattle Fence', '', 'fence', 1, 1, 1, 15, '', 'Woven hurdles of timber and rope. Rotate it to turn it.', 0],
    'stone-wall'      => ['Dry Stone Wall', '', 'fence', 1, 1, 2, 35, '', 'Stacked stone, no mortar. Lizards love it.', 0],
    'box-hedge'       => ['Box Hedge', '', 'hedge', 1, 1, 1, 40, 'hedge', 'Clipped evergreen.', 1],
    'holly-hedge'     => ['Holly Hedge', '', 'hedge', 1, 1, 2, 55, 'hedge', 'Glossy and prickly, with red berries.', 1],
    'lavender-border' => ['Lavender Border', '', 'hedge', 1, 1, 3, 60, 'hedge', 'Low, scented and buzzing.', 1],
    'silver-birch'    => ['Silver Birch', '🌳', 'tree', 1, 1, 3, 150, 'shade', 'A slender tree with dappled shade.', 1],
    'blossom-cherry'  => ['Blossom Cherry', '🌸', 'tree', 1, 1, 5, 320, 'shade', 'Clouds of pink petals.', 1],
    'garden-oak'      => ['Garden Oak', '🌳', 'tree', 2, 2, 6, 600, 'shade', 'A broad old oak, 2 × 2.', 1],
    'weeping-willow'  => ['Weeping Willow', '🌿', 'tree', 2, 2, 7, 750, 'shade', 'Trailing green curtains, 2 × 2.', 1],
    'birdbath'        => ['Birdbath', '🐦', 'water', 1, 1, 3, 120, 'birds', 'A stone bowl the birds queue for.', 1],
    'bird-box'        => ['Bird Box', '🐤', 'water', 1, 1, 2, 60, 'birds', 'A snug nest box on a post.', 0],
    'garden-pond'     => ['Garden Pond', '🐸', 'water', 2, 2, 8, 900, 'birds', 'Lily pads, frogs and dragonflies, 2 × 2.', 1],
    'fountain'        => ['Fountain', '⛲', 'water', 2, 2, 10, 1500, 'birds', 'A tinkling stone fountain, 2 × 2.', 1],
    'garden-bench'    => ['Garden Bench', '🪑', 'seat', 2, 1, 3, 180, '', 'Somewhere to sit and admire it all, 2 × 1.', 1],
    'log-seat'        => ['Log Seat', '🪵', 'seat', 1, 1, 2, 40, '', 'A sawn log, just the right height.', 0],
    'hammock'         => ['Hammock', '🛏️', 'seat', 2, 1, 4, 260, '', 'Strung between two posts, 2 × 1.', 1],
    'stone-lantern'   => ['Stone Lantern', '🏮', 'light', 1, 1, 3, 140, '', 'A warm glow after dark.', 1],
    'firefly-jar'     => ['Firefly Jar', '✨', 'light', 1, 1, 2, 45, '', 'Borrowed glow in a clay jar.', 0],
    'beeswax-candles' => ['Beeswax Candles', '🕯️', 'light', 1, 1, 3, 90, '', 'Honey-scented candles in a clay dish, made from your own hive’s wax.', 0],   // v0.7.95
    'flower-pot'      => ['Flower Pot', '🪴', 'ornament', 1, 1, 2, 35, '', 'A fat terracotta pot of greenery.', 1],
    'wind-chime'      => ['Wind Chime', '🎐', 'ornament', 1, 1, 2, 70, '', 'Tinkles in the slightest breeze.', 1],
    'scarecrow'       => ['Pumpkin Scarecrow', '🎃', 'ornament', 1, 1, 3, 90, '', 'Scares nobody, but looks the part.', 1],
    'sundial'         => ['Sundial', '☀️', 'ornament', 1, 1, 4, 220, '', 'Only tells the time when it’s sunny.', 1],
    'rose-arch'       => ['Rose Arch', '🌹', 'ornament', 1, 1, 4, 260, '', 'Walk under it for luck.', 1],
    'gnome-statue'    => ['Gnome Statue', '🗿', 'ornament', 1, 1, 5, 400, '', 'A very handsome likeness of somebody.', 1],
    'toadstool-ring'  => ['Toadstool Ring', '🍄', 'ornament', 1, 1, 3, 50, '', 'A little ring of mushrooms. Don’t step inside.', 0],
    'fairy-house'     => ['Fairy House', '🏡', 'ornament', 1, 1, 5, 120, '', 'A tiny door at the foot of a stump.', 0],
    'rock-garden'     => ['Rock Garden', '🪨', 'ornament', 1, 1, 3, 80, '', 'Stones and alpine flowers.', 0],
    'log-pile'        => ['Log Pile', '🪵', 'ornament', 1, 1, 1, 30, 'hedge', 'Beetles live under it and eat weed seeds.', 0],
];

// v0.9.7 rare decor for the weekly Curio Cabinet (Hedge & Hearth): slug => [name, icon, type, w, h, appeal, price, bonus, description]. Never sold on the open shelves;
// no placement bonuses (they look lovely and that is all). Appeal runs a little above ordinary decor for the money. Admin → Items can change price and appeal.
const CURIO_DECOR = [
    'wind-harp'          => ['Aeolian Wind Harp', '🎼', 'ornament', 1, 1, 7, 1500, '', 'Strings sing in the breeze: no two evenings sound alike.'],
    'hanging-planter'    => ['Hanging Moon Planter', '🌙', 'ornament', 1, 1, 7, 1600, '', 'A crescent of silver trailing with night-blooming jasmine.'],
    'amber-lamppost'     => ['Amber Lamppost', '🪔', 'light', 1, 1, 8, 2000, '', 'Wrought iron topped with a bubble of honey-coloured glass.'],
    'glowstone-lantern'  => ['Glowstone Lantern', '💡', 'light', 1, 1, 8, 2200, '', 'A lantern of glowing river stone. It never needs a candle.'],
    'gazing-ball'        => ['Silver Gazing Ball', '🔮', 'ornament', 1, 1, 8, 2300, '', 'Shows your whole garden, upside down and a little bigger.'],
    'gilded-sundial'     => ['Gilded Sundial', '🌞', 'ornament', 1, 1, 9, 2600, '', 'Gold numerals on green marble. Still only works when it is sunny.'],
    'carved-heron'       => ['Carved Heron', '🦢', 'ornament', 1, 1, 9, 2700, '', 'One-legged and endlessly patient, carved from a single block of pale stone.'],
    'giant-toadstool'    => ['Giant Toadstool', '🍄', 'ornament', 1, 1, 10, 3000, '', 'Red cap, white spots, and a faint smell of rain. Fairies use the stem as a door.'],
    'mossy-throne'       => ['Mossy Throne', '👑', 'seat', 1, 1, 10, 3600, '', 'A carved stone chair so old the moss has become part of it.'],
    'stained-glass-arbor' => ['Stained Glass Arbor', '🌈', 'ornament', 1, 1, 12, 4800, '', 'Colours fall across the path when the sun comes through.'],
    'starlight-hammock'  => ['Starlight Hammock', '🌌', 'seat', 2, 1, 12, 4400, '', 'Woven with fine silver thread that twinkles at dusk, 2 × 1.'],
    'wishing-well'       => ['Wishing Well', '🪣', 'water', 1, 1, 12, 4200, '', 'Drop in a pebble and make a wish. The well keeps the pebbles.'],
    'dragon-topiary'     => ['Topiary Dragon', '🐲', 'ornament', 1, 1, 13, 5200, '', 'Clipped from yew by a patient hedgehog over eleven years.'],
    'meteorite-garden'   => ['Meteorite Garden', '☄️', 'ornament', 2, 2, 14, 6000, '', 'A fallen star ringed with silver sedum, 2 × 2.'],
    'koi-pond'           => ['Koi Pond', '🐟', 'water', 2, 2, 15, 6500, '', 'Gold and white koi drift under a little red bridge, 2 × 2.'],
    'tea-shrine'         => ['Tea Shrine', '⛩️', 'ornament', 2, 2, 15, 7000, '', 'A tiny gate and a stone basin. Visitors tend to whisper, 2 × 2.'],
    'butterfly-house'    => ['Butterfly House', '🦋', 'ornament', 2, 2, 15, 6800, '', 'A glass pavilion full of fluttering colour, 2 × 2.'],
    'marble-cascade'     => ['Marble Cascade', '⛲', 'water', 2, 2, 16, 7500, '', 'Three marble bowls spilling into one another, 2 × 2.'],
    'lantern-tree'       => ['Lantern Tree', '🏮', 'tree', 2, 2, 17, 8200, '', 'A grand old tree hung with a hundred paper lanterns, 2 × 2.'],
    'gnome-bandstand'    => ['Gnome Bandstand', '🎻', 'ornament', 2, 2, 18, 9000, '', 'A round little stage with a tin roof. Somebody always seems to be tuning up, 2 × 2.'],
];

// ---------- Decor items ----------

/** Make the decor items (adds only what's missing; the admin can edit them afterwards). */
function ensure_decor_items(): void
{
    foreach (DECOR + CURIO_DECOR as $slug => [$name, $icon, $type, $w, $h, $appeal, $price, $bonus, $desc]) {   // v0.9.7: + the Curio Cabinet pieces
        if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
        $how = $bonus !== '' ? ' ' . YARD_BONUSES[$bonus][3] : '';
        db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'decor', 'rarity' => 5, 'base_price' => $price,
            'description' => $desc . $how . ' Place it in your yard with the yard designer.',
            'effects' => json_encode(['decor' => ['type' => $type, 'w' => $w, 'h' => $h, 'icon' => $icon, 'appeal' => $appeal, 'bonus' => $bonus]], JSON_UNESCAPED_UNICODE)]);
    }
}

/** An item's decor details, or null if it isn't decor. */
function decor_def(array $item): ?array
{
    $fx = json_decode((string)($item['effects'] ?? ''), true);
    $d = is_array($fx) ? ($fx['decor'] ?? null) : null;
    if (!is_array($d)) return null;
    $bonus = (string)($d['bonus'] ?? '');
    return [
        'type' => isset(DECOR_TYPES[(string)($d['type'] ?? '')]) ? (string)$d['type'] : 'ornament',
        'w' => max(1, min(4, (int)($d['w'] ?? 1))), 'h' => max(1, min(4, (int)($d['h'] ?? 1))),
        'icon' => mb_substr((string)($d['icon'] ?? ''), 0, 8), 'appeal' => max(0, min(50, (int)($d['appeal'] ?? 0))),
        'bonus' => isset(YARD_BONUSES[$bonus]) ? $bonus : '',
    ];
}

/** Decor in a gnome's satchel: [item_id => row with def and qty]. */
function decor_owned(int $uid): array
{
    $out = [];
    foreach (q("SELECT i.id, i.name, i.slug, i.effects, i.description, i.image, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
                WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'decor' ORDER BY i.name", [$uid])->fetchAll() as $r) {
        if ($def = decor_def($r)) $out[(int)$r['id']] = $r + ['def' => $def];
    }
    return $out;
}

// ---------- Yard size and layout ----------

/** [width, height] of a garden's yard: the beds plus room around them, plus any extensions bought. */
function yard_size(array $plot): array
{
    return [min(YARD_MAX_SIDE, max(10, (int)$plot['width'] + 6) + (int)($plot['yard_xw'] ?? 0)),
            min(YARD_MAX_SIDE, max(8, (int)$plot['height'] + 4) + (int)($plot['yard_xh'] ?? 0))];
}

function yard_extend_cost(array $plot): int
{
    return (int)setting('yard_extend_cost') * (1 + (int)($plot['yard_xw'] ?? 0) + (int)($plot['yard_xh'] ?? 0));
}

/** Mark a w × h footprint on an occupancy grid. */
function yard_mark(array &$grid, int $x, int $y, int $w, int $h, string $what = '1'): void
{
    for ($j = 0; $j < $h; $j++) for ($i = 0; $i < $w; $i++) $grid[($x + $i) . ',' . ($y + $j)] = $what;
}

function yard_fits(array $grid, int $x, int $y, int $w, int $h, int $yw, int $yh): bool
{
    if ($x < 0 || $y < 0 || $x + $w > $yw || $y + $h > $yh) return false;
    for ($j = 0; $j < $h; $j++) for ($i = 0; $i < $w; $i++) if (isset($grid[($x + $i) . ',' . ($y + $j)])) return false;
    return true;
}

/** The nearest free spot for a w × h thing (nearest to $pref, or the first going along the rows). */
function yard_free_spot(array $grid, int $yw, int $yh, int $w, int $h, ?array $pref = null): ?array
{
    $best = null;
    $bestD = PHP_INT_MAX;
    for ($y = 0; $y + $h <= $yh; $y++) {
        for ($x = 0; $x + $w <= $yw; $x++) {
            $d = $pref ? max(abs($x - $pref[0]), abs($y - $pref[1])) * 1000 + abs($x - $pref[0]) + abs($y - $pref[1]) : $y * 1000 + $x;
            if ($d < $bestD && yard_fits($grid, $x, $y, $w, $h, $yw, $yh)) {
                $best = [$x, $y];
                $bestD = $d;
            }
        }
    }
    return $best;
}

/**
 * Keep a yard tidy: every bed square has a spot, every building has a place (if there's room), objects
 * for buildings that are gone are removed, and anything left outside a shrunken yard is moved back in
 * (decor that doesn't fit goes back to the satchel). Cheap when nothing needs doing.
 */
function yard_sync(int $plotId): void
{
    static $done = [];
    if (isset($done[$plotId])) return;
    $done[$plotId] = true;
    $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
    if (!$plot) return;
    [$yw, $yh] = yard_size($plot);
    $grid = [];
    $tiles = q('SELECT id, x, y, yx, yy FROM plot_tiles WHERE plot_id = ? ORDER BY y, x', [$plotId])->fetchAll();
    $objs = q('SELECT * FROM garden_objects WHERE plot_id = ? ORDER BY id', [$plotId])->fetchAll();
    $loose = [];
    $anchor = null;
    foreach ($tiles as $t) {
        $ok = $t['yx'] !== null && $t['yy'] !== null && (int)$t['yx'] >= 0 && (int)$t['yy'] >= 0 && (int)$t['yx'] < $yw && (int)$t['yy'] < $yh
            && !isset($grid[(int)$t['yx'] . ',' . (int)$t['yy']]);
        if ($ok) {
            yard_mark($grid, (int)$t['yx'], (int)$t['yy'], 1, 1, 't');
            if ((int)$t['x'] === 0 && (int)$t['y'] === 0) $anchor = [(int)$t['yx'], (int)$t['yy']];
        } else {
            $loose[] = $t;
        }
    }
    $looseObjs = [];
    foreach ($objs as $o) {
        if ((int)$o['x'] < 0) { $looseObjs[] = $o; continue; }
        if (yard_fits($grid, (int)$o['x'], (int)$o['y'], (int)$o['w'], (int)$o['h'], $yw, $yh)) {
            yard_mark($grid, (int)$o['x'], (int)$o['y'], (int)$o['w'], (int)$o['h'], 'o');
        } else {
            $looseObjs[] = $o;
        }
    }
    if ($loose) {
        $ox = $anchor ? $anchor[0] : intdiv($yw - (int)$plot['width'], 2);
        $oy = $anchor ? $anchor[1] : intdiv($yh - (int)$plot['height'], 2);
        foreach ($loose as $t) {
            $spot = yard_free_spot($grid, $yw, $yh, 1, 1, [$ox + (int)$t['x'], $oy + (int)$t['y']]);
            if (!$spot) {   // full up: give the yard another row
                q('UPDATE plots SET yard_xh = yard_xh + 1 WHERE id = ?', [$plotId]);
                $yh++;
                $spot = yard_free_spot($grid, $yw, $yh, 1, 1, [$ox + (int)$t['x'], $oy + (int)$t['y']]);
            }
            q('UPDATE plot_tiles SET yx = ?, yy = ? WHERE id = ?', [$spot[0], $spot[1], $t['id']]);
            yard_mark($grid, $spot[0], $spot[1], 1, 1, 't');
        }
    }
    // Buildings: one object each
    $built = q('SELECT building FROM garden_buildings WHERE plot_id = ?', [$plotId])->fetchAll(PDO::FETCH_COLUMN);
    $have = [];
    foreach ($objs as $o) if ($o['kind'] === 'building') $have[$o['ref']] = $o;
    foreach ($have as $key => $o) {
        if (!in_array($key, $built, true) || !isset(YARD_BUILDINGS[$key])) {
            q('DELETE FROM garden_objects WHERE id = ?', [$o['id']]);
            $looseObjs = array_filter($looseObjs, fn($l) => (int)$l['id'] !== (int)$o['id']);
        }
    }
    $beds = q('SELECT AVG(yx) AS cx, AVG(yy) AS cy FROM plot_tiles WHERE plot_id = ? AND yx IS NOT NULL', [$plotId])->fetch();
    foreach ($built as $key) {
        if (isset($have[$key]) || !isset(YARD_BUILDINGS[$key])) continue;
        [$w, $h, $bonus] = YARD_BUILDINGS[$key];
        // A hive or rain barrel starts right by the beds, where it helps; the rest start along the top
        $pref = $bonus !== '' && $beds && $beds['cx'] !== null ? [(int)round((float)$beds['cx']), (int)round((float)$beds['cy'])] : null;
        $spot = yard_free_spot($grid, $yw, $yh, $w, $h, $pref);
        db_insert('garden_objects', ['plot_id' => $plotId, 'kind' => 'building', 'ref' => $key, 'item_id' => null,
            'x' => $spot ? $spot[0] : -1, 'y' => $spot ? $spot[1] : -1, 'w' => $w, 'h' => $h, 'rot' => 0, 'placed_at' => now()]);
        if ($spot) yard_mark($grid, $spot[0], $spot[1], $w, $h, 'o');
    }
    // Things that lost their place: buildings wait for a spot, decor goes back in the satchel if there's no room
    foreach ($looseObjs as $o) {
        $spot = yard_free_spot($grid, $yw, $yh, (int)$o['w'], (int)$o['h']);
        if ($spot) {
            q('UPDATE garden_objects SET x = ?, y = ? WHERE id = ?', [$spot[0], $spot[1], $o['id']]);
            yard_mark($grid, $spot[0], $spot[1], (int)$o['w'], (int)$o['h'], 'o');
        } elseif ($o['kind'] === 'decor') {
            q('DELETE FROM garden_objects WHERE id = ?', [$o['id']]);
            if ($o['item_id']) give_item((int)$plot['user_id'], (int)$o['item_id'], 1);
        } elseif ((int)$o['x'] >= 0) {
            q('UPDATE garden_objects SET x = -1, y = -1 WHERE id = ?', [$o['id']]);
        }
    }
}

/** Everything placed in a yard, ready to draw: buildings and decor with names, icons and bonuses. */
function yard_objects(int $plotId): array
{
    $out = [];
    $skins = skin_map($plotId);   // v0.9.7: building looks
    foreach (q('SELECT o.*, i.name AS item_name, i.slug AS item_slug, i.effects, i.image AS item_image FROM garden_objects o
                LEFT JOIN items i ON i.id = o.item_id WHERE o.plot_id = ? ORDER BY o.id', [$plotId])->fetchAll() as $o) {
        if ($o['kind'] === 'building') {
            if (!isset(BUILDINGS[$o['ref']])) continue;
            [$bw, $bh, $bonus] = YARD_BUILDINGS[$o['ref']] ?? [1, 1, ''];
            $o += ['name' => BUILDINGS[$o['ref']][0], 'icon' => BUILDINGS[$o['ref']][1], 'type' => 'building', 'look' => $o['ref'],
                'bonus' => $bonus, 'appeal' => 2, 'bw' => $bw, 'bh' => $bh, 'skin' => $skins[$o['ref']] ?? ''];
        } else {
            $def = decor_def($o) ?? ['type' => 'ornament', 'w' => 1, 'h' => 1, 'icon' => '❔', 'appeal' => 0, 'bonus' => ''];
            $o += ['name' => (string)($o['item_name'] ?? 'Ornament'), 'icon' => $def['icon'], 'type' => $def['type'],
                'look' => (string)($o['item_slug'] ?? ''), 'bonus' => $def['bonus'], 'appeal' => $def['appeal'], 'bw' => $def['w'], 'bh' => $def['h'],
                'image' => yard_decor_image((string)($o['item_slug'] ?? ''), (string)($o['item_image'] ?? ''))];   // v1.5.2: or its placeholder
        }
        $out[] = $o;
    }
    return $out;
}

/** Distance (squares, diagonals count as 1) from a square to a rectangle. 0 = inside. */
function yard_reach(int $x, int $y, array $o): int
{
    $dx = max((int)$o['x'] - $x, 0, $x - ((int)$o['x'] + (int)$o['w'] - 1));
    $dy = max((int)$o['y'] - $y, 0, $y - ((int)$o['y'] + (int)$o['h'] - 1));
    return max($dx, $dy);
}

/** Placement bonuses for every yard square of a garden: ["x,y" => ['hive' => true, ...]]. */
function yard_bonus_map(int $plotId): array
{
    static $cache = [];
    if (isset($cache[$plotId])) return $cache[$plotId];
    $sources = [];
    foreach (q('SELECT o.*, i.effects FROM garden_objects o LEFT JOIN items i ON i.id = o.item_id WHERE o.plot_id = ? AND o.x >= 0', [$plotId])->fetchAll() as $o) {
        $bonus = $o['kind'] === 'building' ? (YARD_BUILDINGS[$o['ref']][2] ?? '') : (decor_def($o)['bonus'] ?? '');
        if ($bonus !== '') $sources[] = [$bonus, $o];
    }
    $map = [];
    if ($sources) {
        foreach (q('SELECT yx, yy FROM plot_tiles WHERE plot_id = ? AND yx IS NOT NULL', [$plotId])->fetchAll() as $t) {
            foreach ($sources as [$bonus, $o]) {
                if (yard_reach((int)$t['yx'], (int)$t['yy'], $o) <= YARD_BONUSES[$bonus][2]) $map[$t['yx'] . ',' . $t['yy']][$bonus] = true;
            }
        }
    }
    return $cache[$plotId] = $map;
}

/** The bonuses one bed square gets from what's around it. */
function yard_tile_bonuses(array $t): array
{
    if (!isset($t['yx']) || $t['yx'] === null) return [];
    return yard_bonus_map((int)$t['plot_id'])[$t['yx'] . ',' . $t['yy']] ?? [];
}

/** Curb appeal: decor (each kind counts up to 4 times), variety, buildings, and flowers in bloom. */
function yard_appeal(int $plotId, ?array $objects = null): int
{
    $objects ??= yard_objects($plotId);
    $n = 0;
    $seen = [];
    foreach ($objects as $o) {
        if ((int)$o['x'] < 0) continue;
        $k = $o['kind'] . ':' . ($o['item_id'] ?: $o['ref']);
        $seen[$k] = ($seen[$k] ?? 0) + 1;
        if ($seen[$k] <= 4) $n += (int)$o['appeal'];
        if ($o['kind'] === 'building' && !empty($o['skin'])) $n += skin_appeal((string)$o['skin']);   // v0.9.7: a building look
    }
    $n += 2 * count(array_filter(array_keys($seen), fn($k) => str_starts_with($k, 'decor:')));   // variety
    $n += min(20, (int)q_val("SELECT COUNT(*) FROM plot_tiles t JOIN plants p ON p.id = t.plant_id WHERE t.plot_id = ? AND p.kind = 'flower'", [$plotId]));
    $n += critter_appeal($plotId) + (building_level($plotId, 'frog_pond') > 0 ? 3 : 0) + animals120_appeal($plotId);   // v1.0.0: animals and a pond make a yard lovelier
    return $n;
}

function appeal_word(int $n): string
{
    return $n < 5 ? 'Plain' : ($n < 15 ? 'Tidy' : ($n < 30 ? 'Charming' : ($n < 55 ? 'Delightful' : ($n < 90 ? 'Enchanting' : 'Legendary'))));
}

// ---------- Joining fences, walls and hedges (v0.9.5) ----------

const YARD_JOIN_SHAPES = ['end', 'straight', 'corner', 'tee', 'cross'];
// Arms at rotation 0 (bits: N 1, E 2, S 4, W 8). Turning a quarter clockwise moves every arm one step round.
const YARD_SHAPE_MASK = ['end' => 2, 'straight' => 10, 'corner' => 6, 'tee' => 14, 'cross' => 15];
const YARD_UNDO_KEEP = 10;

/** v0.9.8: the picture for a building at its level ({building}-{level}.png in uploads/buildings/ or assets/img/buildings/), else ''. */
function building_image(string $building, int $level, bool $ph = false): string
{
    foreach (['uploads/buildings/', 'assets/img/buildings/'] as $dir) {
        $rel = $dir . $building . '-' . max(1, $level) . '.png';
        if (art_path($rel) !== '') return $rel;
    }
    if (critter_is_home($building) && is_file(APP_ROOT . '/assets/img/animals/' . $building . '.svg')) return 'assets/img/animals/' . $building . '.svg';   // v1.0.0: the animal homes' own art
    return $ph ? ph_path($building . '-' . max(1, min(3, $level))) : '';   // v1.5.2: placeholder
}

/** v1.5.2: a decor piece's picture: its own art, else the placeholder (fence pieces: assets/img/ph/{slug}-{shape}.svg), else ''. */
function yard_decor_image(string $slug, string $raw): string
{
    if (($img = yard_image($raw)) !== '') return $img;
    require_once __DIR__ . '/items.php';
    if (ph_path($slug . '-straight') !== '') return 'assets/img/ph/' . $slug . '-{shape}.svg';
    return ph_path($slug);
}

/** An item image path that is safe to show, or ''. (May contain {shape}, which becomes end/straight/corner/tee/cross/gate.) */
function yard_image(string $img): string
{
    $img = trim($img);
    return $img !== '' && preg_match('#^[A-Za-z0-9_./{}-]+\.(png|jpe?g|webp|gif|svg)$#i', $img) && !str_contains($img, '..') ? $img : '';
}

/** Which family a placed thing belongs to for joining: fence, wall, hedge or gate ('' = it doesn't join). One square only. */
function yard_family(array $o): string
{
    if (($o['kind'] ?? '') !== 'decor' || (int)$o['bw'] !== 1 || (int)$o['bh'] !== 1) return '';
    $look = (string)$o['look'];
    if (str_contains($look, 'gate') && $o['type'] === 'fence') return 'gate';
    if ($o['type'] === 'fence') return str_contains($look, 'wall') ? 'wall' : 'fence';
    return $o['type'] === 'hedge' ? 'hedge' : '';
}

function yard_joins(string $a, string $b): bool
{
    return $a === $b || ($a === 'gate' && in_array($b, ['fence', 'wall'], true)) || ($b === 'gate' && in_array($a, ['fence', 'wall'], true));
}

/** Turn an arm mask a number of quarter turns clockwise. */
function yard_turn(int $mask, int $quarters): int
{
    for ($i = 0, $n = $quarters % 4; $i < $n; $i++) $mask = (($mask << 1) | ($mask >> 3)) & 15;
    return $mask;
}

function yard_shape_of(int $mask): string
{
    $n = ($mask & 1) + (($mask >> 1) & 1) + (($mask >> 2) & 1) + (($mask >> 3) & 1);
    return $n <= 1 ? 'end' : ($n === 2 ? (in_array($mask, [5, 10], true) ? 'straight' : 'corner') : ($n === 3 ? 'tee' : 'cross'));
}

/**
 * Work out every joinable piece's arms from its neighbours: [object id => [family, mask, shape, chosen]]. A piece with a chosen shape
 * (the override column) uses it, turned by its rotation; a lone piece is a straight run turned by its rotation; otherwise the arms
 * are whichever of the four sides have a piece of the same family.
 */
function yard_join_info(array $objects): array
{
    $cells = [];
    $fam = [];
    foreach ($objects as $o) {
        if ((int)$o['x'] < 0 || ($f = yard_family($o)) === '') continue;
        $fam[(int)$o['id']] = $f;
        $cells[(int)$o['x'] . ',' . (int)$o['y']] = $f;
    }
    $out = [];
    foreach ($objects as $o) {
        $id = (int)$o['id'];
        if (!isset($fam[$id])) continue;
        $x = (int)$o['x'];
        $y = (int)$o['y'];
        $pick = (string)($o['shape'] ?? '');
        if (isset(YARD_SHAPE_MASK[$pick])) {
            $mask = yard_turn(YARD_SHAPE_MASK[$pick], intdiv((int)$o['rot'], 90));
        } else {
            $pick = '';
            $mask = 0;
            foreach ([1 => [0, -1], 2 => [1, 0], 4 => [0, 1], 8 => [-1, 0]] as $bit => [$dx, $dy]) {
                $n = $cells[($x + $dx) . ',' . ($y + $dy)] ?? '';
                if ($n !== '' && yard_joins($fam[$id], $n)) $mask |= $bit;
            }
            if ($mask === 0) $mask = yard_turn(10, intdiv((int)$o['rot'], 90));
        }
        $out[$id] = ['fam' => $fam[$id], 'mask' => $mask, 'shape' => yard_shape_of($mask), 'chosen' => $pick];
    }
    return $out;
}

/** The drawing of a joined piece: arms to the joined sides and a post (or a gate leaf) in the middle. Same drawing as site.js. */
function yard_join_svg(string $fam, int $mask): string
{
    $s = '<svg class="fz fz-' . $fam . '" viewBox="0 0 100 100" aria-hidden="true" focusable="false">';
    foreach ([1 => 'M50 50V0', 2 => 'M50 50H100', 4 => 'M50 50V100', 8 => 'M50 50H0'] as $bit => $d) {
        if ($mask & $bit) $s .= '<path class="rl" d="' . $d . '"/><path class="pk" d="' . $d . '"/>';
    }
    if ($fam === 'gate') {
        $up = ($mask & 5) && !($mask & 10);
        $s .= $up ? '<rect class="gt" x="34" y="22" width="32" height="56" rx="3"/><path class="gb" d="M50 26V74M38 36H62M38 50H62M38 64H62"/><circle class="po" cx="50" cy="20" r="7"/><circle class="po" cx="50" cy="80" r="7"/>'
                  : '<rect class="gt" x="22" y="34" width="56" height="32" rx="3"/><path class="gb" d="M26 50H74M36 38V62M50 38V62M64 38V62"/><circle class="po" cx="20" cy="50" r="7"/><circle class="po" cx="80" cy="50" r="7"/>';
    } else {
        $s .= '<circle class="po" cx="50" cy="50" r="' . (['hedge' => 20, 'wall' => 18][$fam] ?? 11) . '"/>';
    }
    return $s . '</svg>';
}

/** What a joined piece shows: the item's own image if it has one ({shape} picks the file), otherwise the drawing. [html, extra classes] */
function yard_join_inner(array $o, array $info): array
{
    if (($o['image'] ?? '') !== '') {
        $name = $info['fam'] === 'gate' ? 'gate' : $info['shape'];
        $base = YARD_SHAPE_MASK[$info['fam'] === 'gate' ? 'straight' : $info['shape']];
        $q = 0;
        while ($q < 3 && yard_turn($base, $q) !== $info['mask']) $q++;
        return ['<img class="yimg" src="' . e(url(str_replace('{shape}', $name, $o['image']))) . '" alt="" loading="lazy">', ' fj fi ra' . ($q * 90)];
    }
    return [yard_join_svg($info['fam'], $info['mask']), ' fj'];
}

// ---------- Drawing ----------

/** v1.5.2: a bed icon: an emoji (escaped) or a placeholder <img> built by tile_view. */
function tile_icon_html(string $icon): string
{
    return str_starts_with($icon, '<img class="phtile') ? $icon : e($icon);
}

/** How one bed square looks: [classes, icon, label, badge html]. */
function tile_view(array $t, array $plants, bool $owner = true): array
{
    $cls = 'wild';
    $icon = '';
    $label = 'Untilled ground';
    $badge = '';
    if ($t['plant_id'] && isset($plants[(int)$t['plant_id']])) {
        $p = $plants[(int)$t['plant_id']];
        $info = tile_info($t, $p);
        $cls = 'planted' . ($info['ready'] ? ' ready' : '') . ($info['thirsty'] && $owner ? ' thirsty' : '');
        $icon = $info['ready'] ? catalog_kind_icon((string)$p['kind']) : ($info['stage'] <= 1 ? '🌱' : '🌿');
        $sn = $info['ready'] ? 4 : ($info['stage'] <= 1 ? 1 : ($info['stage'] === 2 ? 2 : 3));   // v1.5.2: a crop-stage placeholder, if drawn
        if (($sp = ph_img('stage-' . (string)$p['kind'] . '-' . $sn, 28, '', 'phtile')) !== '') $icon = $sp;
        $label = $p['name'] . ($info['ready'] ? ' (ready!)' : ($owner ? ($info['thirsty'] ? ' (thirsty)' : ' (' . nice_time($info['time_left']) . ' left)') : ' (growing)'));
    } elseif ((int)$t['tilled']) {
        $cls = $t['method'] === 'notill' ? 'notill' : 'tilled';
        $label = $t['method'] === 'notill' ? 'No-till bed' : 'Tilled soil';
        if ($owner && ts($t['settle_until']) > time()) $label .= ' (settling)';
    }
    if ($t['method'] === 'notill') {
        $cls .= ' nt';
        $gi = grade_index($t);
        $badge = '<b class="grade g' . $gi . '">' . e(grade_name($gi)) . ($owner && (int)$t['checkpoint'] > 0 ? '🛡' : '') . '</b>'
            . ($owner && bed_problems($t) ? '<s>⚠️</s>' : '');
        $label .= ' · grade ' . grade_name($gi) . ($owner && bed_problems($t) ? ' · needs care' : '');
    }
    elseif (($cs = care_stars($t)) > 0) {   // v0.8.7: soil care stars on tilled (or wild) squares
        $badge = '<b class="grade care">★' . $cs . '</b>';
        $label .= ' · soil care ' . care_star_text($cs);
    }
    if ($owner && !empty($t['pest']) && $t['plant_id'] && ($pd = pest_defs()[(string)$t['pest']] ?? null)) {   // v1.0.0: a pest on the bed
        $badge .= '<em class="pestb" aria-hidden="true">' . e($pd['icon']) . '</em>';
        $label .= ' · ' . e((string)$pd['name']) . ' (slowing it down)';
    }
    if ($owner) $label .= ' · fertility ' . (int)$t['fertility'];
    if ($cls !== 'wild' || $icon !== '') {
        if (str_contains($cls, 'thirsty')) $badge .= '<i>💧</i>';
    }
    if ($icon === '' && !str_contains($cls, 'planted') && ($gp = ph_img('tile-' . (str_contains($cls, 'notill') ? 'notill' : (str_contains($cls, 'tilled') ? 'tilled' : 'wild')), 28, '', 'phtile')) !== '') $icon = $gp;   // v1.5.2: ground placeholder
    return [$cls, $icon, $label, $badge];
}

/** Grid placement classes (no inline styles: the security policy forbids them). */
function yard_pos(int $x, int $y, int $w, int $h): string
{
    return 'gx' . ($x + 1) . ' gy' . ($y + 1) . ' gw' . $w . ' gh' . $h;
}

/** Text for the bonuses one square gets, for its tooltip. */
function bonus_words(array $b): string
{
    return $b ? ' · ' . implode(' ', array_map(fn($k) => YARD_BONUSES[$k][0], array_keys($b))) : '';
}

/**
 * Draw a yard. $mode: 'own' (bed squares link to tending), 'visit' (look only), 'edit' (the designer),
 * 'mini' (a small picture for lists).
 */
function render_yard(array $plot, array $tiles, array $plants, array $objects, string $mode = 'own', ?array $sel = null, array $extra = []): string
{
    [$yw, $yh] = yard_size($plot);
    $owner = $mode === 'own' || $mode === 'edit';
    $bonus = $mode === 'own' ? yard_bonus_map((int)$plot['id']) : [];
    $html = '<div class="yard yc' . $yw . ' yr' . $yh . ($mode === 'mini' ? ' mini' : '') . ($mode === 'edit' ? ' editing' : '') . '"'
        . ($mode === 'edit' ? ' data-yard-edit data-w="' . $yw . '" data-h="' . $yh . '"' : '') . '>';
    $joins = yard_join_info($objects);   // v0.9.5: fences, walls and hedges take their shape from their neighbours
    foreach ($objects as $o) {
        if ((int)$o['x'] < 0 && $mode !== 'edit') continue;
        $ji = $joins[(int)$o['id']] ?? null;
        $cls = 'yo ' . ($o['kind'] === 'building' ? 'bld' : 'dec') . ' t-' . e($o['type']) . ' d-' . e($o['look'])
            . ((int)$o['rot'] ? ' r' . (int)$o['rot'] : '') . ((int)$o['x'] < 0 ? ' off' : ' ' . yard_pos((int)$o['x'], (int)$o['y'], (int)$o['w'], (int)$o['h']));
        $title = $o['name'] . ($o['bonus'] !== '' ? ' · ' . YARD_BONUSES[$o['bonus']][3] : '');
        $inner = $o['icon'] !== '' ? '<span class="oi">' . e($o['icon']) . '</span>' : '';
        $fx = '';
        if ($ji) {
            [$inner, $more] = yard_join_inner($o, $ji);
            $cls .= $more;
            $fx = ' data-fam="' . e($ji['fam']) . '" data-shape="' . e($ji['chosen']) . '" data-img="' . e($o['image'] !== '' ? url($o['image']) : '') . '"';
        } elseif (($o['image'] ?? '') !== '' && $o['kind'] === 'decor') {   // image hook: an item with a picture shows it
            $inner = '<img class="yimg" src="' . e(url(str_replace('{shape}', 'straight', $o['image']))) . '" alt="" loading="lazy">';
            $cls .= ' fi';
        }
        if ($o['kind'] === 'building' && ($bimg = building_image((string)$o['ref'], building_level((int)$o['plot_id'], (string)$o['ref']), true)) !== '') {   // v0.9.8: art for this level
            $inner = '<img class="yimg" src="' . e(url($bimg)) . '" alt="" loading="lazy">'; $cls .= ' fi';
        }
        if ($o['kind'] === 'building' && !empty($o['skin'])) {   // v0.9.7: a building look: tint and badge until there is art (assets/img/skins/{building}-{skin}.png)
            $cls .= ' sk sk-' . e($o['skin']);
            if (($simg = skin_image((string)$o['ref'], (string)$o['skin'], true)) !== '') { $inner = '<img class="yimg" src="' . e(url($simg)) . '" alt="" loading="lazy">'; $cls .= ' fi'; }
            elseif ($mode !== 'mini') $inner .= '<i class="skb" aria-hidden="true">' . e(SKIN_DEFS[$o['skin']][1]) . '</i>';
            $title .= ' · ' . SKIN_DEFS[$o['skin']][0];
        }
        if ($o['kind'] === 'building' && $mode !== 'mini') $inner .= '<small>' . e($o['name']) . '</small>';
        if ($mode === 'edit') {
            $html .= '<div class="' . $cls . '" title="' . e($title) . '" data-k="o' . (int)$o['id'] . '" data-id="' . (int)$o['id'] . '" data-kind="' . e($o['kind'])
                . '" data-x="' . (int)$o['x'] . '" data-y="' . (int)$o['y'] . '" data-w="' . (int)$o['w'] . '" data-h="' . (int)$o['h'] . '" data-rot="' . (int)$o['rot']
                . '" data-move="1" data-item="' . (int)($o['item_id'] ?? 0) . '" data-name="' . e($o['name']) . '"' . $fx . '>' . $inner . '</div>';
        } elseif ($mode === 'own' && $o['kind'] === 'building') {
            $ready = !empty($extra['ready'][$o['ref']]);
            if ($ready) {   // v0.7.99: tap to collect
                $html .= '<form method="post" class="' . $cls . ' ready" title="' . e($title . ' · tap to collect!') . '">' . csrf_field()
                    . '<input type="hidden" name="do" value="collect"><input type="hidden" name="from" value="yard"><input type="hidden" name="building" value="' . e($o['ref']) . '"><button class="yobtn" aria-label="' . e($title . ' · tap to collect!') . '">' . $inner . '</button></form>';
            } else {
                $html .= '<a class="' . $cls . '" href="' . e(url('garden.php?bld=' . $o['ref'] . '#b-' . $o['ref'])) . '" title="' . e($title) . '" aria-label="' . e($title) . '">' . $inner . '</a>';
            }
        } elseif ($mode === 'visit' && $o['kind'] === 'building') {   // v0.7.99: peek at a neighbour's building
            $html .= '<a class="' . $cls . '" href="' . e(url('visit.php?g=' . (int)$plot['id'] . '&bld=' . $o['ref'] . '#bldpeek')) . '" title="' . e($title . ' · tap to look') . '" aria-label="' . e($title . ' · tap to look') . '">' . $inner . '</a>';
        } else {
            $html .= '<div class="' . $cls . '" role="img" aria-label="' . e($title) . '" title="' . e($title) . '">' . $inner . '</div>';
        }
    }
    foreach ($tiles as $row) {
        foreach ($row as $t) {
            if ($t['yx'] === null) continue;
            [$cls, $icon, $label, $badge] = tile_view($t, $plants, $owner);
            $pos = yard_pos((int)$t['yx'], (int)$t['yy'], 1, 1);
            $tx = (int)$t['x'];
            $ty = (int)$t['y'];
            if ($mode === 'own') {
                $b = $bonus[$t['yx'] . ',' . $t['yy']] ?? [];
                $isSel = $sel && (int)$sel['x'] === $tx && (int)$sel['y'] === $ty;
                $html .= '<a class="tile ' . $cls . ($isSel ? ' sel' : '') . ' ' . $pos . '" href="' . e(url("garden.php?sel=$tx-$ty")) . '" data-inplace title="' . e($label . bonus_words($b)) . '" aria-label="' . e($label . bonus_words($b)) . '">'
                    . $badge . tile_icon_html($icon) . '</a>';
            } elseif ($mode === 'edit') {
                $fixed = (bool)$t['plant_id'];
                $html .= '<div class="tile ' . $cls . ' ' . $pos . ($fixed ? ' fixed' : '') . '" title="' . e($label . ($fixed ? ' · can’t move while something grows here' : ' · drag to move this bed')) . '"'
                    . ' data-k="t' . $tx . '_' . $ty . '" data-kind="bed" data-tx="' . $tx . '" data-ty="' . $ty . '" data-x="' . (int)$t['yx'] . '" data-y="' . (int)$t['yy'] . '"'
                    . ' data-w="1" data-h="1" data-rot="0" data-move="' . ($fixed ? '0' : '1') . '" data-name="Bed square">' . $badge . tile_icon_html($icon) . '</div>';
            } else {
                $html .= '<span class="tile ' . $cls . ' ' . $pos . '" role="img" aria-label="' . e($label) . '" title="' . e($label) . '">' . ($mode === 'mini' ? '' : $badge) . tile_icon_html($icon) . '</span>';
            }
        }
    }
    return ($mode === 'own' || $mode === 'visit' ? sign_html($plot) : '') . $html . '</div>';   // v0.9.7: the garden's signpost, if it has one
}

// ---------- Saving a design ----------

/**
 * Save a yard layout from the designer. $json: {"o": [[object id, x, y, rot], …], "n": [[item id, x, y, rot], …],
 * "t": [[bed x, bed y, yard x, yard y], …]}. Placed objects left out are put away (decor back to the satchel).
 * The whole layout is checked before anything changes.
 */
function yard_save(array $u, int $plotId, string $json): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if (strlen($json) > 100000) return [false, 'That layout is too big to save.'];
    $d = json_decode($json, true);
    if (!is_array($d)) return [false, 'Couldn’t read that layout. Nothing was changed.'];
    if (rate_limited('yard:' . $uid, 40, 10)) return [false, 'That’s a lot of saving! Wait a few minutes and try again.'];
    record_attempt('yard:' . $uid);
    yard_sync($plotId);
    [$yw, $yh] = yard_size($plot);
    $objs = [];
    foreach (yard_objects($plotId) as $o) $objs[(int)$o['id']] = $o;
    $tiles = [];
    foreach (q('SELECT id, x, y, yx, yy, plant_id FROM plot_tiles WHERE plot_id = ?', [$plotId])->fetchAll() as $t) $tiles[$t['x'] . '_' . $t['y']] = $t;
    $ints = fn($row, int $n) => is_array($row) && count($row) >= $n ? array_map('intval', array_slice(array_values($row), 0, $n)) : null;
    $rotate = fn(int $bw, int $bh, int $rot) => $rot % 180 ? [$bh, $bw] : [$bw, $bh];
    $place = [];      // [what, x, y, w, h]
    $moves = [];      // object id => [x, y, w, h, rot]
    foreach ((array)($d['o'] ?? []) as $row) {
        $r = $ints($row, 4);
        if (!$r) return [false, 'Couldn’t read that layout. Nothing was changed.'];
        [$id, $x, $y, $rot] = $r;
        if (!isset($objs[$id])) return [false, 'Something in that layout isn’t in your yard any more. Reload the page and try again.'];
        if (isset($moves[$id])) return [false, 'Couldn’t read that layout. Nothing was changed.'];
        $rot = in_array($rot, [0, 90, 180, 270], true) ? $rot : 0;
        [$w, $h] = $rotate((int)$objs[$id]['bw'], (int)$objs[$id]['bh'], $rot);
        $moves[$id] = [$x, $y, $w, $h, $rot, yard_clean_shape($row[4] ?? '', yard_family($objs[$id]))];
        $place[] = [$objs[$id]['name'], $x, $y, $w, $h];
    }
    $away = [];
    foreach ($objs as $id => $o) {
        if (isset($moves[$id])) continue;
        if ($o['kind'] === 'building') {
            if ((int)$o['x'] >= 0) return [false, 'Buildings can’t be put away, only moved.'];
            continue;   // still waiting for a spot
        }
        $away[] = $o;
    }
    $new = [];
    $need = [];
    $owned = decor_owned($uid);
    $newRows = (array)($d['n'] ?? []);
    if (count($newRows) > 300) return [false, 'That’s too many new things at once. Save part of it first.'];
    foreach ($newRows as $row) {
        $r = $ints($row, 4);
        if (!$r) return [false, 'Couldn’t read that layout. Nothing was changed.'];
        [$itemId, $x, $y, $rot] = $r;
        if (!isset($owned[$itemId])) return [false, 'You don’t have that decoration any more. Reload the page and try again.'];
        $rot = in_array($rot, [0, 90, 180, 270], true) ? $rot : 0;
        $def = $owned[$itemId]['def'];
        [$w, $h] = $rotate($def['w'], $def['h'], $rot);
        $need[$itemId] = ($need[$itemId] ?? 0) + 1;
        $new[] = [$itemId, $x, $y, $w, $h, $rot, yard_clean_shape($row[4] ?? '', yard_family(['kind' => 'decor', 'bw' => $def['w'], 'bh' => $def['h'], 'look' => $owned[$itemId]['slug'], 'type' => $def['type']]))];
        $place[] = [$owned[$itemId]['name'], $x, $y, $w, $h];
    }
    foreach ($need as $itemId => $n) {
        if ((int)$owned[$itemId]['qty'] < $n) return [false, 'You only have ' . (int)$owned[$itemId]['qty'] . ' × ' . $owned[$itemId]['name'] . '.'];
    }
    $tileMoves = [];
    foreach ((array)($d['t'] ?? []) as $row) {
        $r = $ints($row, 4);
        if (!$r) return [false, 'Couldn’t read that layout. Nothing was changed.'];
        [$tx, $ty, $x, $y] = $r;
        $k = $tx . '_' . $ty;
        if (!isset($tiles[$k]) || isset($tileMoves[$k])) return [false, 'Couldn’t read that layout. Nothing was changed.'];
        if ($x === (int)$tiles[$k]['yx'] && $y === (int)$tiles[$k]['yy']) continue;
        if ($tiles[$k]['plant_id']) return [false, 'A bed with something growing in it can’t be moved. Harvest or dig it up first.'];
        $tileMoves[$k] = [$x, $y];
    }
    foreach ($tiles as $k => $t) {
        [$x, $y] = $tileMoves[$k] ?? [(int)$t['yx'], (int)$t['yy']];
        $place[] = ['A bed square', $x, $y, 1, 1];
    }
    $grid = [];
    foreach ($place as [$what, $x, $y, $w, $h]) {
        if ($x < 0 || $y < 0 || $x + $w > $yw || $y + $h > $yh) return [false, $what . ' doesn’t fit inside the yard there.'];
        if (!yard_fits($grid, $x, $y, $w, $h, $yw, $yh)) return [false, $what . ' overlaps something else. Nothing was changed.'];
        yard_mark($grid, $x, $y, $w, $h);
    }

    $before = yard_snapshot($plotId);
    db()->beginTransaction();
    try {
        foreach ($new as [$itemId, $x, $y, $w, $h, $rot, $shape]) {
            if (!give_item($uid, $itemId, -1)) throw new RuntimeException('You don’t have enough of that decoration any more.');
            db_insert('garden_objects', ['plot_id' => $plotId, 'kind' => 'decor', 'ref' => null, 'item_id' => $itemId,
                'x' => $x, 'y' => $y, 'w' => $w, 'h' => $h, 'rot' => $rot, 'shape' => $shape, 'placed_at' => now()]);
        }
        foreach ($away as $o) {
            if (q('DELETE FROM garden_objects WHERE id = ? AND plot_id = ?', [$o['id'], $plotId])->rowCount() === 1 && $o['item_id']) {
                give_item($uid, (int)$o['item_id'], 1);
            }
        }
        foreach ($moves as $id => [$x, $y, $w, $h, $rot, $shape]) {
            q('UPDATE garden_objects SET x = ?, y = ?, w = ?, h = ?, rot = ?, shape = ? WHERE id = ? AND plot_id = ?', [$x, $y, $w, $h, $rot, $shape, $id, $plotId]);
        }
        foreach ($tileMoves as $k => [$x, $y]) {
            if (q('UPDATE plot_tiles SET yx = ?, yy = ? WHERE id = ? AND plant_id IS NULL', [$x, $y, $tiles[$k]['id']])->rowCount() !== 1) {
                throw new RuntimeException('Something was planted in a bed you moved. Reload the page and try again.');
            }
        }
        db()->commit();
    } catch (RuntimeException $e) {
        db()->rollBack();
        return [false, $e->getMessage()];
    }
    $appeal = yard_appeal($plotId);
    q('UPDATE plots SET appeal = ? WHERE id = ?', [$appeal, $plotId]);
    unlock_entries($uid, 'yard');
    if ($before !== yard_snapshot($plotId)) yard_history_push($plotId, $before);   // v0.9.5: undo remembers what it looked like
    $bits = array_filter([count($new) ? count($new) . ' placed' : '', count($away) ? count($away) . ' put away' : '',
        count($tileMoves) ? count($tileMoves) . ' bed square' . (count($tileMoves) === 1 ? '' : 's') . ' moved' : '']);
    return [true, '🏡 Yard saved' . ($bits ? ' (' . implode(', ', $bits) . ')' : '') . '. Curb appeal: ' . $appeal . ' (' . appeal_word($appeal) . ').'];
}

// ---------- Undo (v0.9.5) ----------

/** A shape the designer sent, kept only for pieces that join (and only a known shape). NULL = joins by itself. */
function yard_clean_shape($shape, string $family): ?string
{
    return $family !== '' && is_string($shape) && in_array($shape, YARD_JOIN_SHAPES, true) ? $shape : null;
}

/** The whole layout as JSON: every object's spot and shape, and where each bed square sits. */
function yard_snapshot(int $plotId): string
{
    $o = q('SELECT id, kind, ref, item_id, x, y, w, h, rot, shape FROM garden_objects WHERE plot_id = ? ORDER BY id', [$plotId])->fetchAll(PDO::FETCH_NUM);
    $t = q('SELECT x, y, yx, yy FROM plot_tiles WHERE plot_id = ? ORDER BY y, x', [$plotId])->fetchAll(PDO::FETCH_NUM);
    return json_encode(['o' => $o, 't' => $t]);
}

function yard_history_push(int $plotId, string $snap): void
{
    db_insert('yard_history', ['plot_id' => $plotId, 'snap' => $snap, 'created_at' => now()]);
    foreach (q('SELECT id FROM yard_history WHERE plot_id = ? ORDER BY id DESC LIMIT 1000 OFFSET ' . YARD_UNDO_KEEP, [$plotId])->fetchAll(PDO::FETCH_COLUMN) as $id) {
        q('DELETE FROM yard_history WHERE id = ?', [$id]);
    }
}

function yard_history_count(int $plotId): int
{
    return (int)q_val('SELECT COUNT(*) FROM yard_history WHERE plot_id = ?', [$plotId]);
}

/**
 * Put the yard back how it was before the last save. Decor added since goes back to the satchel; decor put away since is taken out of
 * the satchel again (it must still be there); buildings built since stay where they are; a bed square with something growing stays put.
 * Checked as a whole first: if it can't all fit, nothing changes.
 */
function yard_undo(array $u, int $plotId): array
{
    $uid = (int)$u['id'];
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if (rate_limited('yard:' . $uid, 40, 10)) return [false, 'That’s a lot of saving! Wait a few minutes and try again.'];
    record_attempt('yard:' . $uid);
    yard_sync($plotId);
    $h = q_one('SELECT * FROM yard_history WHERE plot_id = ? ORDER BY id DESC LIMIT 1', [$plotId]);
    $snap = $h ? json_decode((string)$h['snap'], true) : null;
    if (!$h || !is_array($snap)) return [false, 'Nothing to undo.'];
    [$yw, $yh] = yard_size($plot);
    $cur = [];
    foreach (q('SELECT * FROM garden_objects WHERE plot_id = ?', [$plotId])->fetchAll() as $o) $cur[(int)$o['id']] = $o;
    $old = [];
    foreach ((array)($snap['o'] ?? []) as $r) if (is_array($r) && count($r) >= 10) $old[(int)$r[0]] = $r;
    $place = [];                                    // [what, x, y, w, h]
    $keep = [];                                     // id => [x, y, w, h, rot, shape]
    $readd = [];                                    // snapshot rows to create again
    $drop = [];                                     // current decor to put back in the satchel
    $need = [];
    foreach ($cur as $id => $o) {
        if (!isset($old[$id])) {
            if ($o['kind'] === 'decor') { $drop[] = $o; continue; }
            if ((int)$o['x'] >= 0) $place[] = ['A building', (int)$o['x'], (int)$o['y'], (int)$o['w'], (int)$o['h']];   // built since: stays
            continue;
        }
        [, , , , $x, $y, $w, $hh, $rot, $shape] = $old[$id];
        $keep[$id] = [(int)$x, (int)$y, (int)$w, (int)$hh, (int)$rot, $shape === null ? null : (string)$shape];
        if ((int)$x >= 0) $place[] = ['Something', (int)$x, (int)$y, (int)$w, (int)$hh];
    }
    foreach ($old as $id => $r) {
        if (isset($cur[$id]) || $r[1] !== 'decor' || !$r[3] || (int)$r[4] < 0) continue;
        $readd[] = $r;
        $need[(int)$r[3]] = ($need[(int)$r[3]] ?? 0) + 1;
        $place[] = ['Something', (int)$r[4], (int)$r[5], (int)$r[6], (int)$r[7]];
    }
    $back = [];
    foreach ($drop as $o) if ($o['item_id']) $back[(int)$o['item_id']] = ($back[(int)$o['item_id']] ?? 0) + 1;
    foreach ($need as $itemId => $n) {
        $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $itemId]) + ($back[$itemId] ?? 0);
        if ($have < $n) return [false, 'You no longer have all the decoration that was in place before. Nothing was changed.'];
    }
    $tiles = [];
    foreach (q('SELECT id, x, y, yx, yy, plant_id FROM plot_tiles WHERE plot_id = ?', [$plotId])->fetchAll() as $t) $tiles[(int)$t['x'] . '_' . (int)$t['y']] = $t;
    $tileMoves = [];
    foreach ((array)($snap['t'] ?? []) as $r) {
        if (!is_array($r) || count($r) < 4) continue;
        $k = (int)$r[0] . '_' . (int)$r[1];
        if (!isset($tiles[$k]) || $tiles[$k]['plant_id'] || $r[2] === null || $r[3] === null) continue;
        if ((int)$r[2] !== (int)$tiles[$k]['yx'] || (int)$r[3] !== (int)$tiles[$k]['yy']) $tileMoves[$k] = [(int)$r[2], (int)$r[3]];
    }
    foreach ($tiles as $k => $t) {
        [$x, $y] = $tileMoves[$k] ?? [(int)$t['yx'], (int)$t['yy']];
        $place[] = ['A bed square', $x, $y, 1, 1];
    }
    $grid = [];
    foreach ($place as [$what, $x, $y, $w, $hh]) {
        if (!yard_fits($grid, $x, $y, $w, $hh, $yw, $yh)) return [false, 'The yard has changed too much to undo that now. Nothing was changed.'];
        yard_mark($grid, $x, $y, $w, $hh);
    }
    db()->beginTransaction();
    try {
        foreach ($drop as $o) {
            if (q('DELETE FROM garden_objects WHERE id = ? AND plot_id = ?', [$o['id'], $plotId])->rowCount() === 1 && $o['item_id']) give_item($uid, (int)$o['item_id'], 1);
        }
        foreach ($readd as $r) {
            if (!give_item($uid, (int)$r[3], -1)) throw new RuntimeException('You no longer have all the decoration that was in place before.');
            db_insert('garden_objects', ['plot_id' => $plotId, 'kind' => 'decor', 'ref' => null, 'item_id' => (int)$r[3], 'x' => (int)$r[4], 'y' => (int)$r[5],
                'w' => (int)$r[6], 'h' => (int)$r[7], 'rot' => (int)$r[8], 'shape' => $r[9] === null ? null : (string)$r[9], 'placed_at' => now()]);
        }
        foreach ($keep as $id => [$x, $y, $w, $hh, $rot, $shape]) {
            q('UPDATE garden_objects SET x = ?, y = ?, w = ?, h = ?, rot = ?, shape = ? WHERE id = ? AND plot_id = ?', [$x, $y, $w, $hh, $rot, $shape, $id, $plotId]);
        }
        foreach ($tileMoves as $k => [$x, $y]) {
            q('UPDATE plot_tiles SET yx = ?, yy = ? WHERE id = ? AND plant_id IS NULL', [$x, $y, $tiles[$k]['id']]);
        }
        q('DELETE FROM yard_history WHERE id = ?', [$h['id']]);
        db()->commit();
    } catch (RuntimeException $e) {
        db()->rollBack();
        return [false, $e->getMessage()];
    }
    $appeal = yard_appeal($plotId);
    q('UPDATE plots SET appeal = ? WHERE id = ?', [$appeal, $plotId]);
    return [true, '↶ Undone: the yard is how it was before your last save. Curb appeal: ' . $appeal . '.'];
}

/** Buy one more column or row of yard. */
function yard_extend(array $u, int $plotId, string $dir): array
{
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $u['id']]);
    if (!$plot || !in_array($dir, ['w', 'h'], true)) return [false, 'That isn’t your garden.'];
    [$yw, $yh] = yard_size($plot);
    if (($dir === 'w' ? $yw : $yh) >= YARD_MAX_SIDE || (int)$plot['yard_x' . $dir] >= (int)setting('yard_extend_max')) {
        return [false, 'Your yard can’t grow any further that way.'];
    }
    $cost = yard_extend_cost($plot);
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$cost, $u['id'], $cost])->rowCount() !== 1) {
        return [false, 'Extending the yard costs ' . number_format($cost) . ' ' . setting('currency_name') . '.'];
    }
    q('UPDATE plots SET yard_x' . $dir . ' = yard_x' . $dir . ' + 1 WHERE id = ?', [$plotId]);
    return [true, '📐 Your yard grows by a ' . ($dir === 'w' ? 'column' : 'row') . ' (−' . number_format($cost) . ' ' . setting('currency_name') . ').'];
}

/** A moderator clearing a reported yard design: every decoration goes back to its owner's satchel. */
function yard_clear(int $plotId): void
{
    $owner = (int)q_val('SELECT user_id FROM plots WHERE id = ?', [$plotId]);
    foreach (q("SELECT * FROM garden_objects WHERE plot_id = ? AND kind = 'decor'", [$plotId])->fetchAll() as $o) {
        if (q('DELETE FROM garden_objects WHERE id = ?', [$o['id']])->rowCount() === 1 && $o['item_id'] && $owner) give_item($owner, (int)$o['item_id'], 1);
    }
    q('UPDATE plots SET appeal = 0 WHERE id = ?', [$plotId]);
}

// ---------- Visits, admiring and Garden of the Month ----------

/** Can this viewer look at that garden? */
function garden_visible(array $plot, ?array $viewer): bool
{
    $owner = q_one('SELECT id, garden_public, deleted_at, banned_until FROM users WHERE id = ?', [$plot['user_id']]);
    if (!$owner || $owner['deleted_at']) return false;
    if ($viewer && ((int)$viewer['id'] === (int)$owner['id'] || in_array($viewer['role'], ['admin', 'mod'], true))) return true;
    // v0.7.85: a gnome in a time-out has no gardens open to visitors
    if (!q_val('SELECT 1 FROM users u WHERE u.id = ? AND ' . gnome_in_play_sql('u'), [$plot['user_id']])) return false;
    return (int)$owner['garden_public'] === 1;
}

function admire_garden(array $u, int $plotId): array
{
    $plot = q_one('SELECT * FROM plots WHERE id = ?', [$plotId]);
    if (!$plot || !garden_visible($plot, $u)) return [false, 'You can’t visit that garden.'];
    if ((int)$plot['user_id'] === (int)$u['id']) return [false, 'Admiring your own garden is lovely, but it doesn’t count!'];
    // v0.9.0: once per garden, ever (older rows carry a date; new ones are stored as 'once' so the unique key stops a double tap)
    if (q_val('SELECT 1 FROM garden_admires WHERE plot_id = ? AND user_id = ? LIMIT 1', [$plotId, $u['id']])) return [false, 'You’ve already admired this garden.'];
    try {
        db_insert('garden_admires', ['plot_id' => $plotId, 'user_id' => $u['id'], 'day' => 'once', 'admired_at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve already admired this garden.'];
    }
    q('UPDATE plots SET admired = admired + 1 WHERE id = ?', [$plotId]);
    require_once __DIR__ . '/trade.php';
    notify((int)$plot['user_id'], '🌼 ' . gnome_name($u) . ' visited ' . ($plot['garden_name'] ?: 'your garden') . ' and admired it.');
    return [true, '🌼 You admire ' . ($plot['garden_name'] ?: 'the garden') . '. Its gardener will hear about it.'];
}

function gotm_month(): string
{
    return hollow_date('Y-m');
}

function gotm_entry(int $plotId, ?string $month = null): ?array
{
    return q_one('SELECT * FROM gotm_entries WHERE plot_id = ? AND month = ?', [$plotId, $month ?? gotm_month()]) ?: null;
}

function gotm_enter(array $u, int $plotId): array
{
    $plot = q_one('SELECT * FROM plots WHERE id = ? AND user_id = ?', [$plotId, $u['id']]);
    if (!$plot) return [false, 'That isn’t your garden.'];
    if (fresh_hold($u) !== '') return [false, 'New gnomes can’t enter the contest yet. Give it a few days.'];   // v1.2.2: alt farming
    if ((int)$u['garden_public'] !== 1) return [false, 'Your gardens are private. Open them to visitors on your Account page first.'];
    $appeal = yard_appeal($plotId);
    if ($appeal < (int)setting('gotm_min_appeal')) return [false, 'Gardens need a curb appeal of at least ' . (int)setting('gotm_min_appeal') . ' to enter. Add some decor!'];
    if (q_val('SELECT 1 FROM gotm_entries WHERE user_id = ? AND month = ?', [$u['id'], gotm_month()])) return [false, 'One garden per gnome each month.'];
    try {
        db_insert('gotm_entries', ['month' => gotm_month(), 'plot_id' => $plotId, 'user_id' => $u['id'], 'votes' => 0, 'appeal' => $appeal, 'entered_at' => now()]);
    } catch (PDOException $e) {
        return [false, 'That garden is already entered.'];
    }
    return [true, '🏆 ' . ($plot['garden_name'] ?: 'Your garden') . ' is entered for Garden of the Month!'];
}

function gotm_votes_left(array $u): int
{
    return max(0, (int)setting('gotm_votes') - (int)q_val('SELECT COUNT(*) FROM gotm_votes WHERE user_id = ? AND month = ?', [$u['id'], gotm_month()]));
}

/** Why this gnome can't vote yet ('' = they can). */
function gotm_vote_block(array $u): string
{
    if ((int)$u['level'] < (int)setting('gotm_vote_level')) return 'Voting opens at gnome level ' . (int)setting('gotm_vote_level') . '.';
    if (ts($u['created_at']) > time() - 2 * 86400) return 'New gnomes can vote after their first two days.';
    if (fresh_hold($u) !== '') return 'New gnomes can’t vote yet. Give it a few days.';   // v1.2.2: alt farming
    return '';
}

function gotm_vote(array $u, int $entryId): array
{
    if ($why = gotm_vote_block($u)) return [false, $why];
    // v0.7.85: a timed-out gnome's garden can't be voted for
    $e = q_one('SELECT e.* FROM gotm_entries e JOIN users u ON u.id = e.user_id WHERE e.id = ? AND e.month = ? AND ' . gnome_in_play_sql('u'), [$entryId, gotm_month()]);
    if (!$e) return [false, 'That garden isn’t in this month’s contest.'];
    if ((int)$e['user_id'] === (int)$u['id']) return [false, 'No voting for your own garden!'];
    require_once __DIR__ . '/mentors120.php';
    if (mentors120_same_origin((int)$u['id'], (int)$e['user_id'])) return [false, 'You can’t vote for that garden.'];   // v1.2.2: same sign-up address
    if (gotm_votes_left($u) < 1) return [false, 'You’ve used all ' . (int)setting('gotm_votes') . ' of your votes this month.'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [(int)$u['id']]);   // v1.2.2: lock, then count again so the vote cap can't be raced
    if (gotm_votes_left($u) < 1) {
        db()->rollBack();
        return [false, 'You’ve used all ' . (int)setting('gotm_votes') . ' of your votes this month.'];
    }
    try {
        db_insert('gotm_votes', ['month' => gotm_month(), 'entry_id' => $entryId, 'user_id' => $u['id'], 'voted_at' => now()]);
    } catch (PDOException $ex) {
        db()->rollBack();
        return [false, 'You’ve already voted for that garden.'];
    }
    q('UPDATE gotm_entries SET votes = votes + 1 WHERE id = ?', [$entryId]);
    db()->commit();
    return [true, '🗳️ Vote counted. ' . gotm_votes_left($u) . ' left this month.'];
}

/** Once a month is over, rank its gardens and pay the top three (once). */
function settle_gotm(): void
{
    $now = gotm_month();
    $months = q('SELECT DISTINCT month FROM gotm_entries WHERE placed IS NULL AND month < ?', [$now])->fetchAll(PDO::FETCH_COLUMN);
    if (!$months) return;
    require_once __DIR__ . '/trade.php';
    $prizes = array_map('intval', explode(',', setting('gotm_prizes') . ',,'));
    foreach ($months as $m) {
        $rank = 0;
        // v0.7.85: gnomes in a time-out are left out of the ranking (their entry stays open until they're back)
        foreach (q('SELECT e.* FROM gotm_entries e JOIN users u ON u.id = e.user_id WHERE e.month = ? AND e.placed IS NULL AND ' . gnome_in_play_sql('u')
                   . ' ORDER BY e.votes DESC, e.appeal DESC, e.entered_at', [$m])->fetchAll() as $e) {
            $rank++;
            $appeal = q_val('SELECT 1 FROM plots WHERE id = ?', [$e['plot_id']]) ? yard_appeal((int)$e['plot_id']) : (int)$e['appeal'];
            if (q('UPDATE gotm_entries SET placed = ?, appeal = ? WHERE id = ? AND placed IS NULL', [$rank, $appeal, $e['id']])->rowCount() !== 1) continue;
            $coins = $rank <= 3 ? max(0, $prizes[$rank - 1] ?? 0) : ((int)$e['votes'] > 0 ? (int)setting('gotm_thanks') : 0);   // v1.2.2: no thanks Petals for a 0-vote entry
            q('UPDATE users SET coins = coins + ?' . ($rank <= 3 ? ', ribbons = ribbons + 1' : '') . ' WHERE id = ?', [$coins, $e['user_id']]);
            add_xp((int)$e['user_id'], [1 => 30, 2 => 20, 3 => 10][$rank] ?? 5);
            if ($rank <= 3) unlock_entries((int)$e['user_id'], 'gotm');
            notify((int)$e['user_id'], ($rank <= 3 ? '🏆' : '🌼') . ' Garden of the Month (' . $m . '): your garden came #' . $rank . ' with ' . (int)$e['votes']
                . ' vote' . ((int)$e['votes'] === 1 ? '' : 's') . '. ' . ($coins ? 'Prize: ' . money($coins) . '.' : '') . ($rank <= 3 ? ' You win a ribbon!' : ''));
        }
    }
}

// ---------- Install / upgrade ----------

const YARD_ALMANAC_EXTRA = "[b]Fences, walls and hedges[/b] join up by themselves: each piece becomes an end, a straight run, a corner, a T or a cross depending on what is beside it, and gates join fences and walls. "
    . "Pick a piece and press [b]🔀 Shape[/b] to choose a shape by hand (press again to go round; the last choice is automatic). [b]↻ Rotate[/b] turns a lone piece or a chosen shape.\n"
    . "[b]Grid[/b] shows the squares. [b]Snap to beds[/b] slides a decoration that is one square away from a bed up against it. "
    . "[b]↶ Undo[/b] steps back while you arrange; after saving, [b]Undo last save[/b] puts the yard back how it was (the last 10 saves are remembered).";

/**
 * v0.9.5 yard: the Garden Gate (a new decor item, added by ensure_decor_items) goes on sale at the Hedge & Hearth, and the
 * Almanac page on designing a yard gets the new controls. The shape column and yard_history table come from schema.php. Idempotent.
 */
function upgrade_095_yard(): void
{
    ensure_decor_items();
    $shop = (int)q_val('SELECT id FROM shops WHERE slug = ?', ['hedge-and-hearth']);
    if ($shop) {
        foreach (DECOR as $slug => $d) {
            if (!$d[9]) continue;
            $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
            if (!$iid || q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, $iid])) continue;
            $p = (int)$d[6];
            db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => $iid, 'price_min' => max(1, (int)floor($p * 0.9)), 'price_max' => (int)ceil($p * 1.2),
                'max_stock' => in_array($d[2], ['path', 'fence', 'hedge'], true) ? 30 : ($p >= 500 ? 2 : 6), 'restock_chance' => $p >= 500 ? 35 : 80, 'current_stock' => 0, 'current_price' => $p]);
        }
    }
    $page = q_one("SELECT id, body FROM encyclopedia_entries WHERE chapter = 'General' AND title = 'Designing your yard'");
    if ($page && !str_contains((string)$page['body'], 'Fences, walls and hedges[/b] join')) {
        $body = (string)$page['body'];
        $at = strpos($body, "\n\n[b]What you can move:");
        q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$at === false ? $body . "\n\n" . YARD_ALMANAC_EXTRA : substr($body, 0, $at) . "\n\n" . YARD_ALMANAC_EXTRA . substr($body, $at), $page['id']]);
    }
}

function ensure_yards(): void
{
    ensure_decor_items();
    // The Hedge & Hearth: garden decor at the Mossbottom hub, staffed around the clock
    $hub = (int)q_val("SELECT id FROM locations WHERE kind = 'hub' ORDER BY id LIMIT 1");
    if ($hub && !q_val('SELECT 1 FROM shops WHERE slug = ?', ['hedge-and-hearth'])) {
        $shopId = db_insert('shops', ['name' => 'Hedge & Hearth', 'slug' => 'hedge-and-hearth', 'location_id' => $hub, 'shop_type' => 'decor',
            'description' => 'Paths, fences, hedges, trees and ornaments for your yard. Place them with the yard designer on your garden page.',
            'restock_minutes' => 45]);
        foreach (DECOR as $slug => $d) {
            if (!$d[9]) continue;
            $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
            if (!$iid) continue;
            $p = (int)$d[6];
            db_insert('shop_stock', ['shop_id' => $shopId, 'item_id' => $iid, 'price_min' => max(1, (int)floor($p * 0.9)), 'price_max' => (int)ceil($p * 1.2),
                'max_stock' => $d[2] === 'path' || $d[2] === 'fence' || $d[2] === 'hedge' ? 30 : ($p >= 500 ? 2 : 6),
                'restock_chance' => $p >= 500 ? 35 : 80, 'current_stock' => 0, 'current_price' => $p]);
        }
        $meadow = (int)q_val("SELECT id FROM locations WHERE slug = 'whispering-meadow'") ?: $hub;
        $burrows = (int)q_val("SELECT id FROM locations WHERE slug = 'rootling-burrows'") ?: $hub;
        $staff = [['Bramble Thornwick', 'Hedgehog', 'Fussy', 'Clips every hedge in the Hollow by eye. Has opinions about edging.'],
            ['Clementine Moss', 'Snail', 'Patient', 'Lays paths one flagstone at a time. They are always perfectly level.'],
            ['Gloam', 'Bat', 'Quiet', 'Works nights, hanging lanterns. Says a garden is best seen by firefly light.']];
        foreach ($staff as $k => [$name, $species, $pers, $bio]) {
            $slug = slugify($name);
            $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$slug]);
            if (!$nid) $nid = db_insert('npcs', ['name' => $name, 'slug' => $slug, 'species' => $species, 'personality' => $pers, 'bio' => $bio, 'home_location_id' => $burrows]);
            [$s, $eh] = [[6, 14], [14, 22], [22, 6]][$k];
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $hub, 'shop_id' => $shopId, 'activity' => 'working', 'start_hour' => $s, 'end_hour' => $eh]);
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $meadow, 'shop_id' => null, 'activity' => 'wandering', 'start_hour' => $eh, 'end_hour' => ($eh + 3) % 24]);
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $burrows, 'shop_id' => null, 'activity' => 'resting', 'start_hour' => ($eh + 3) % 24, 'end_hour' => $s]);
        }
    }
    // Almanac pages
    $pages = [
        ['General', 'Getting started', 'Designing your yard', 'start', '', 10,
            "Every garden sits in a [b]yard[/b] a little bigger than its beds. Press [b]✏️ Design yard[/b] on your garden page to arrange it: "
            . "drag things about (or tap one, then tap where it should go), rotate them, and drag decor back to the tray to put it away. Undo if you change your mind, then Save.\n\n"
            . YARD_ALMANAC_EXTRA . "\n\n"
            . "[b]What you can move:[/b] your buildings, decorations, and empty bed squares (a bed with something growing stays put). Tick [b]Pick several[/b] to move a group of beds together.\n"
            . "[b]Where to get decor:[/b] the Hedge & Hearth at Mossbottom Market, and the Yard & decor page of Crafting.\n\n"
            . "[b]Where things go matters:[/b]\n"
            . "🐝 A beehive helps beds within 2 squares: a bigger pollinator chance.\n"
            . "🛢️ A rain barrel makes watering last longer in the beds next to it.\n"
            . "🌳 Shade trees keep the beds beside them watered longer.\n"
            . "🌿 Hedges (and log piles) halve weed growth in no-till beds beside them.\n"
            . "🐦 A birdbath, bird box, pond or fountain brings birds that eat slugs in beds within 2 squares: sometimes an extra crop.\n"
            . "🪨 Beds beside a path are easy to reach: when you work several squares at once, some of them cost no energy.\n\n"
            . "Hover over a bed to see which bonuses it gets."],
        ['General', 'Getting started', 'Curb appeal and Garden of the Month', 'start', '', 11,
            "[b]Curb appeal[/b] is how lovely your yard looks: every decoration adds some (the same kind counts up to four times), variety adds more, "
            . "and so do buildings and flowers in bloom.\n\n[b]Visiting:[/b] other gnomes can look round your gardens (never touch them) from your profile, and admire each garden once. "
            . "You can make your gardens private on the Account page.\n\n"
            . "🏆 [b]Garden of the Month:[/b] enter one garden a month from the Games & Contests page. Everyone gets a few votes. When the month ends, "
            . "the top three win Petals and a ribbon, and everyone who entered gets a little thank-you."],
    ];
    foreach ($pages as [$ch, $cat, $title, $key, $hint, $sort, $body]) {
        if (q_val('SELECT 1 FROM encyclopedia_entries WHERE title = ? AND chapter = ?', [$title, $ch])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => $ch, 'category' => $cat, 'title' => $title, 'body' => $body,
            'unlock_key' => $key, 'hint' => $hint, 'sort_order' => $sort]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
    // Give every existing garden its yard
    foreach (q('SELECT id FROM plots')->fetchAll(PDO::FETCH_COLUMN) as $pid) yard_sync((int)$pid);
}

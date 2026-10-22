<?php
declare(strict_types=1);

/**
 * v0.7.59: rarity and fuller descriptions for the Satchel.
 * Rarity: crops by their tier in the regions (staple = Common, uncommon = Uncommon, treasure = Legendary), finds by
 * their gathering rarity, tools by tier, everything else from items.rarity (1–100, higher = rarer).
 */
require_once __DIR__ . '/adventure_data.php';
require_once __DIR__ . '/flower_art.php';   // v0.9.9: SVG pictures for flowers, packets and arrangements

const RARITY_WORDS = ['C' => 'Common', 'U' => 'Uncommon', 'R' => 'Rare', 'L' => 'Legendary'];

/** Everything the Satchel needs to describe items, looked up once per page. */
function item_lookups(): array
{
    $L = ['seed' => [], 'produce' => [], 'tier' => [], 'regions' => [], 'gather' => [], 'used' => []];
    foreach (q('SELECT * FROM plants')->fetchAll() as $p) {
        if ($p['seed_item_id']) $L['seed'][(int)$p['seed_item_id']] = $p;
        if ($p['produce_item_id']) $L['produce'][(int)$p['produce_item_id']] = $p;
    }
    $rank = ['staple' => 1, 'flower' => 2, 'uncommon' => 3, 'treasure' => 4];
    foreach (q('SELECT pr.plant_id, pr.tier, r.gnomish_name FROM plant_regions pr JOIN regions r ON r.id = pr.region_id')->fetchAll() as $r) {
        $pid = (int)$r['plant_id'];
        if (!isset($L['tier'][$pid]) || ($rank[$r['tier']] ?? 9) < ($rank[$L['tier'][$pid]] ?? 9)) $L['tier'][$pid] = $r['tier'];
        $L['regions'][$pid][] = $r['gnomish_name'];
        $L['regtier'][$pid][$r['tier']][] = $r['gnomish_name'];   // v0.9.0: "Staple: The Maplewold"
    }
    foreach (q('SELECT * FROM gatherables WHERE active = 1')->fetchAll() as $g) $L['gather'][(int)$g['item_id']] = $g;
    foreach (q('SELECT r.ingredients, r.category, i.name FROM recipes r JOIN items i ON i.id = r.output_item_id ORDER BY i.name')->fetchAll() as $r) {
        foreach (array_keys(json_decode((string)$r['ingredients'], true) ?: []) as $slug) $L['used'][$slug][$r['name']] = true;
    }
    return $L;
}

/** [letter, word] for an item. */
function item_rarity(array $i, array $L): array
{
    $id = (int)$i['id'];
    $plant = $L['seed'][$id] ?? $L['produce'][$id] ?? null;
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    if ($plant) {
        $t = $L['tier'][(int)$plant['id']] ?? 'staple';
        $l = ['staple' => 'C', 'flower' => 'U', 'uncommon' => 'U', 'treasure' => 'L'][$t] ?? 'C';
    } elseif (isset($L['gather'][$id])) {
        $l = ['common' => 'C', 'uncommon' => 'U', 'rare' => 'R'][$L['gather'][$id]['rarity']] ?? 'C';
    } elseif ($i['category'] === 'tool' && isset($fx['tier'])) {
        $l = [1 => 'C', 2 => 'C', 3 => 'U', 4 => 'R'][(int)$fx['tier']] ?? 'C';
    } else {
        $r = (int)($i['rarity'] ?? 1);
        $l = $r >= 80 ? 'L' : ($r >= 45 ? 'R' : ($r >= 20 ? 'U' : 'C'));
    }
    return [$l, RARITY_WORDS[$l]];
}

/** Plain facts about an item, one short line each (already escaped HTML). */
/** v0.9.0: a crop's tier and region(s), e.g. "Staple: The Maplewold · Uncommon: Mistmoor". '' if it isn't a regional crop. */
function item_origin(array $i, array $L): string
{
    $id = (int)$i['id'];
    if (!in_array($i['category'] ?? '', ['seed', 'produce', 'flower'], true)) return '';
    $p = $L['seed'][$id] ?? $L['produce'][$id] ?? null;
    if (!$p || empty($L['regtier'][(int)$p['id']])) return '';
    $words = ['staple' => 'Staple', 'uncommon' => 'Uncommon', 'treasure' => 'Treasure', 'flower' => 'Flower'];
    $out = [];
    foreach ($words as $tier => $word) {
        if (empty($L['regtier'][(int)$p['id']][$tier])) continue;
        $rg = array_values(array_unique($L['regtier'][(int)$p['id']][$tier]));
        $out[] = $word . ': ' . implode(', ', array_slice($rg, 0, 3)) . (count($rg) > 3 ? ' +' . (count($rg) - 3) . ' more' : '');
    }
    return implode(' · ', $out);
}

/** v0.9.0: the same as a line for item pop-ups (shops). */
function item_origin_html(array $i, array $L): string
{
    $o = item_origin($i, $L);
    return $o === '' ? '' : '<p class="iorigin">🌍 <b>' . e($o) . '</b></p>';
}

function item_facts(array $i, array $L): array
{
    $id = (int)$i['id'];
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    $f = [];
    if ($i['category'] === 'seed' && ($p = $L['seed'][$id] ?? null)) {
        $grow = '🌱 Grows in ' . nice_minutes((int)$p['grow_minutes']) . ' of watered growing';
        if ((int)$p['perennial']) $grow .= '; 🔄 perennial, comes back every ' . nice_minutes((int)$p['regrow_minutes']);
        $f[] = e($grow . '.');
        $need = [];
        if ((int)$p['min_soil'] > 0) $need[] = 'Needs fertility ' . (int)$p['min_soil'] . '+.';
        if (isset(NUTRIENTS[(string)($p['nutrient'] ?? '')])) $need[] = 'Feeds on ' . strtolower(NUTRIENTS[(string)$p['nutrient']][0]) . ' (' . NUTRIENTS[(string)$p['nutrient']][1] . ').';
        if ($need) $f[] = e('🪴 ' . implode(' ', $need));
    }
    if (($o = item_origin($i, $L)) !== '') $f[] = '<b>' . e('🌍 ' . $o) . '</b>' . e(' · grows ' . (int)setting('native_bonus_percent') . '% faster there.');   // v0.9.0
    if (in_array($i['category'], ['soil', 'mulch'], true) && function_exists('amend_summary') && ($s = amend_summary($i)) !== '') $f[] = e('🪱 ' . $s . '.');
    if ($i['category'] === 'tool' && isset($fx['tool'], TOOL_TYPES[$fx['tool']])) {
        $tier = (int)($fx['tier'] ?? 1);
        [$label, $icon, $what] = TOOL_TYPES[$fx['tool']];
        $reach = tool_reach($tier);
        $f[] = e($icon . ' ' . $label . ' tool, ' . (TOOL_TIERS[$tier] ?? 'tier ' . $tier) . ': ' . rtrim($what, '.') . '.');
        $bits = [];
        if (!empty(TOOL_TYPES[$fx['tool']][4])) $bits[] = $reach >= 99 ? 'reaches a whole row' : ($reach === 3 ? 'reaches 3 squares' : 'one square at a time');
        if (tool_free_chance($tier)) $bits[] = tool_free_chance($tier) . '% chance a use costs no energy';
        if ($bits) $f[] = e('⚙️ ' . ucfirst(implode(', ', $bits)) . '. Used automatically, no need to equip.');
    }
    if ($i['category'] === 'tool' && ($wf = tool_wear_fact($i)) !== '') $f[] = e($wf);   // v0.7.86
    if ($i['category'] === 'broken') $f[] = e('💥 Broken. Mend it in your Satchel to use it again.');   // v0.7.86
    if ((int)($i['edible'] ?? 0) && function_exists('buff_text') && ($b = buff_text((string)$i['effects'], current_user(), home_dish_tier((int)($i['id'] ?? 0)) !== '')) !== '') $f[] = e('😋 Eating it: ' . $b . '.');
    if ((int)($i['edible'] ?? 0) && in_array($i['category'], ['produce', 'forage'], true) && empty($fx['energy'])) $f[] = e('⚡ Raw, it restores no energy. Cook it into a dish.');   // v0.7.86, v0.9.4
    if (!empty($fx['perm'])) {
        $pp = [];
        foreach ($fx['perm'] as $k => $v) if (isset(GNOME_STATS[$k])) $pp[] = GNOME_STATS[$k][0] . ' +' . (int)$v;
        if ($pp) $f[] = e('✨ The first time you eat one: ' . implode(', ', $pp) . ' for good.');
    }
    if (function_exists('flower_item_facts')) foreach (flower_item_facts($i) as $ff) $f[] = $ff;   // v0.9.9
    if (isset($L['gather'][$id])) {
        $g = $L['gather'][$id];
        $lands = $g['landscapes'] === 'any' ? 'anywhere' : implode(', ', array_map(fn($k) => strtolower(LANDSCAPES[$k][1] ?? $k), explode(',', (string)$g['landscapes'])));
        $f[] = e('🧺 Found while walking: ' . $lands . ' (needs a ' . strtolower(TOOL_TYPES[$g['tool']][0] ?? $g['tool']) . ' tool).');
    }
    $used = array_keys($L['used'][(string)($i['slug'] ?? '')] ?? []);
    if ($used && $i['category'] !== 'produce') $f[] = e('🛠️ Used to make ' . implode(', ', array_slice($used, 0, 4)) . (count($used) > 4 ? ' and ' . (count($used) - 4) . ' more' : '') . '.');
    if ((int)($i['base_price'] ?? 0) > 0) $f[] = e('💰 Worth about ' . number_format((int)$i['base_price']) . ' ' . setting('currency_name') . '.');
    return $f;
}


// ---------- v0.9.8: pictures ----------
// Art goes under uploads/ (Admin → Images) or assets/img/. Anything else, or a missing file, shows the emoji as before.
const ART_SIZES = ['sm' => 24, 'md' => 40, 'lg' => 64];   // CSS pixels; draw the art at 2x (48, 80, 128)

/** A safe, existing art path (relative to the game folder) or ''. No '..', png/jpg/webp only, under uploads/ or assets/img/. */
function art_path(string $p): string
{
    static $cache = [];
    if (isset($cache[$p])) return $cache[$p];
    // v1.5.2: assets/img/ph/*.svg are the red-outlined placeholders
    $ok = $p !== '' && strlen($p) <= 255 && !str_contains($p, '..') && !str_contains($p, '//')
        && (preg_match('#^(uploads|assets/img)/[A-Za-z0-9_][A-Za-z0-9_./-]*\.(png|jpe?g|webp)$#i', $p) || preg_match('#^assets/img/animals/[A-Za-z0-9_-]+\.svg$#', $p)
            || preg_match('#^assets/img/ph/[a-z0-9][a-z0-9_-]*\.(svg|png)$#', $p) || preg_match('#^assets/img/animals/[A-Za-z0-9_-]+\.png$#', $p)) && is_file(APP_ROOT . '/' . $p);
    return $cache[$p] = $ok ? $p : '';
}

/** An <img> for art at $rel (already checked with art_path), sized sm/md/lg. */
function art_img(string $rel, string $size, string $alt, string $cls = 'aimg'): string
{
    $pix = str_ends_with($rel, '.png') ? ' pix' : '';   // v2.0.31 pixel art
    $px = ART_SIZES[$size] ?? ART_SIZES['md'];
    return '<img class="' . e($cls) . ' ' . e($cls) . '-' . e(isset(ART_SIZES[$size]) ? $size : 'md') . $pix . '" src="' . e(url($rel))   /* v1.5.2: url() adds ?v= itself */ . '" width="' . $px . '" height="' . $px
        . '" alt="' . e($alt) . '" loading="lazy" decoding="async">';
}

/** v1.5.2: a placeholder drawing (assets/img/ph/{name}.svg; no outline since v1.6.8) or ''. Real art always wins; use this only after the real lookup came up empty. */
function ph_path(string $name): string
{
    return preg_match('/^[a-z0-9][a-z0-9_-]{0,100}$/', $name) ? (art_path('assets/img/ph/' . $name . '.png') ?: art_path('assets/img/ph/' . $name . '.svg')) : '';
}

/** v1.5.2: a placeholder as <img> at $px CSS pixels, or '' when there is none. */
function ph_img(string $name, int $px, string $alt = '', string $cls = 'phimg'): string
{
    $rel = ph_path($name);
    if (str_ends_with($rel, '.png')) $cls .= ' pix';
    return $rel === '' ? '' : '<img class="' . e($cls) . '" src="' . e(url($rel)) . '" width="' . $px . '" height="' . $px . '" alt="' . e($alt) . '" loading="lazy" decoding="async">';
}

/** v1.5.2: a placeholder picture if one is drawn, else the emoji (already escaped). */
function ph_or_emoji(string $name, string $emoji, int $px = 20, string $alt = ''): string
{
    return ph_img($name, $px, $alt) ?: e($emoji);
}

/** menu icons: the menu entries that have an icon, nav-{slug} (placeholder assets/img/ph/nav-{slug}.svg; real art uploaded in Admin → Images as nav-{slug}.png). slug => label */
const NAV_ICONS = ['gnome' => 'My Gnome', 'almanac' => 'Almanac', 'satchel' => 'Satchel', 'crafting' => 'Crafting', 'garden' => 'Garden', 'arranging' => 'Arranging',
    'world' => 'World', 'town' => 'Town', 'villagers' => 'Villagers', 'seasons' => 'Seasons', 'passport' => 'Passport', 'games' => 'Games', 'trading' => 'Trading',
    'together' => 'Together', 'tasks' => 'Tasks', 'friends' => 'Gnome friends', 'account' => 'Account', 'today' => 'Today', 'festival' => 'Festival',
    'start' => 'Getting started', 'feedback' => 'Send feedback'];

/** menu icons: a menu icon as HTML: uploaded art (uploads/nav/{slug}.png) wins, then the placeholder, then the emoji. */
function nav_icon(string $slug, string $emoji, int $px = 20): string
{
    $rel = art_path('uploads/nav/' . $slug . '.png');
    if ($rel !== '' && isset(NAV_ICONS[$slug])) return '<img class="phimg" src="' . e(url($rel)) . '" width="' . $px . '" height="' . $px . '" alt="" decoding="async">';
    return ph_or_emoji('nav-' . $slug, $emoji, $px);
}

/** v0.9.8: the picture for a creature (creature-{slug}.png in uploads/creatures/ or assets/img/creatures/), else ''. $ph: v1.5.2 fall back to the placeholder. */
function creature_image(string $slug, bool $ph = false): string
{
    foreach (['uploads/creatures/', 'assets/img/creatures/'] as $dir) {
        $rel = $dir . $slug . '.png';
        if (art_path($rel) !== '') return $rel;
    }
    return $ph ? ph_path('creature-' . $slug) : '';
}

/** id => [slug, image] for items that have a picture (one query per request; $reset after an upload). */
function item_art_map(bool $reset = false): array
{
    static $map = null;
    if ($map === null || $reset) {
        $map = ['id' => [], 'slug' => []];
        foreach (q("SELECT id, slug, image FROM items WHERE image IS NOT NULL AND image <> ''")->fetchAll() as $r) {
            $map['id'][(int)$r['id']] = (string)$r['image'];
            $map['slug'][(string)$r['slug']] = (string)$r['image'];
        }
    }
    return $map;
}

/** v1.5.2: item id => slug (for placeholder lookups when only an id is known). */
function item_slug_of(array $i): string
{
    static $map = null;
    $s = (string)($i['slug'] ?? '');
    if ($s !== '' || empty($i['id'])) return $s;
    if ($map === null) $map = q('SELECT id, slug FROM items')->fetchAll(PDO::FETCH_KEY_PAIR);
    return (string)($map[(int)$i['id']] ?? '');
}

/** The picture for an item as <img>, or '' when it has none (for lists that show no emoji today). v1.5.2: $ph adds the placeholder when there is no real art. */
function item_pic(array $i, string $size = 'md', string $alt = '', bool $ph = true): string
{
    $img = trim((string)($i['image'] ?? ''));
    if ($img === '') {
        $m = item_art_map();
        $img = (string)(($m['id'][(int)($i['id'] ?? 0)] ?? '') ?: ($m['slug'][(string)($i['slug'] ?? '')] ?? ''));
    }
    $rel = $img === '' ? '' : art_path(str_replace('{shape}', 'straight', $img));
    if ($rel === '' && $ph && ($slug = item_slug_of($i)) !== '') $rel = ph_path($slug);   // v1.5.2: placeholder, real art (and flower art) first
    return $rel === '' ? '' : art_img($rel, $size, $alt !== '' ? $alt : (string)($i['name'] ?? ''));
}

/** v0.7.61: the Satchel icon for an item (shared by the Satchel and the shops): its picture if it has one, else the emoji. Already escaped. */
function item_icon(array $i, string $size = 'md', string $alt = ''): string
{
    if (($pic = item_pic($i, $size, $alt, false)) !== '') return $pic;
    if (($svg = flower_icon($i, $size, $alt)) !== '') return $svg;   // v0.9.9: cut and dried flowers, seed packets, arrangements
    if (($pic = item_pic($i, $size, $alt)) !== '') return $pic;   // v1.5.2: a placeholder drawing, before the emoji
    return item_emoji($i);
}

/** The emoji icon for an item (the fallback when there is no picture). */
function item_emoji(array $i): string
{
    static $kinds = null;
    if ($kinds === null) {
        $kinds = [];
        foreach (q('SELECT produce_item_id, kind FROM plants WHERE produce_item_id IS NOT NULL')->fetchAll() as $r) $kinds[(int)$r['produce_item_id']] = $r['kind'];
    }
    require_once __DIR__ . '/catalog.php';
    // v0.8.5: a picture that fits the thing itself (Strawberry 🍓, Berry Tart 🥧, Hatchet 🪓) before the general one for its kind
    if (in_array($i['category'], ['food', 'produce', 'forage', 'part', 'tool', 'supply', 'broken'], true) && ($n = name_emoji((string)($i['name'] ?? ''))) !== '') return $n;
    if ($i['category'] === 'produce' && isset($kinds[(int)$i['id']])) return catalog_kind_icon($kinds[(int)$i['id']]);
    if ($i['category'] === 'decor') return e(((json_decode((string)($i['effects'] ?? ''), true) ?: [])['decor']['icon'] ?? '') ?: '🏡');
    return ['seed' => '🌱', 'flower' => '🌸', 'food' => '🍲', 'soil' => '🪱', 'mulch' => '🍂', 'tool' => '🧰', 'forage' => '🍄',
        'part' => '🦴', 'guide' => '📗', 'sapling' => '🌳', 'supply' => '📦', 'broken' => '🔩', 'arrangement' => '💐', 'packet' => '📦'][$i['category']] ?? '🎁';   // broken: v0.7.86
}


/**
 * v0.8.5: an emoji from words in a name, first match wins (so "Berry Tart" is a tart, not a berry). '' when nothing fits.
 * Dishes first, then ingredients, then tools and parts.
 */
const NAME_EMOJI = [
    // names that contain another word come first
    'sweet potato' => '🍠', 'eggplant' => '🍆', 'peanut' => '🥜', 'grapefruit' => '🍊', 'candle' => '🕯️', 'watering can' => '🚿', 'crystal' => '💎', 'gall' => '🌰', 'sea glass' => '🔮',
    // dishes
    'feast' => '🍽️', 'pie' => '🥧', 'tart' => '🥧', 'crumble' => '🥧', 'cake' => '🍰', 'muffin' => '🧁', 'cookie' => '🍪', 'biscuit' => '🍪',
    'bread' => '🍞', 'loaf' => '🍞', 'flatbread' => '🫓', 'toast' => '🍞', 'pancake' => '🥞', 'fritter' => '🥞', 'dumpling' => '🥟',
    'soup' => '🍲', 'stew' => '🍲', 'chowder' => '🍲', 'curry' => '🍛', 'dal' => '🍛', 'rice and' => '🍚', 'risotto' => '🍚', 'porridge' => '🥣',
    'salad' => '🥗', 'tea' => '🍵', 'juice' => '🧃', 'cordial' => '🧃', 'lemonade' => '🍋', 'smoothie' => '🥤', 'cocoa' => '☕', 'coffee' => '☕',
    'jam' => '🍯', 'honey' => '🍯', 'pickle' => '🥒', 'bowl' => '🥣', 'pasta' => '🍝', 'noodle' => '🍜', 'taco' => '🌮', 'wrap' => '🌯',
    'pizza' => '🍕', 'sushi' => '🍣', 'skewer' => '🍢', 'roast' => '🍖', 'bake' => '🥘', 'smoked' => '🐟', 'grilled' => '🍢', 'popcorn' => '🍿',
    'candy' => '🍬', 'sweet' => '🍬', 'ice' => '🍨', 'pudding' => '🍮', 'custard' => '🍮', 'chocolate' => '🍫',
    // fish and wild things
    'trout' => '🐟', 'perch' => '🐟', 'salmon' => '🐟', 'fish' => '🐟', 'eel' => '🐟', 'crab' => '🦀', 'shrimp' => '🦐', 'oyster' => '🦪', 'clam' => '🐚', 'shell' => '🐚',
    'mushroom' => '🍄', 'chanterelle' => '🍄', 'morel' => '🍄', 'truffle' => '🍄', 'feather' => '🪶', 'egg' => '🥚', 'nest' => '🪺',
    'driftwood' => '🪵', 'cottongrass' => '🌾', 'sardine' => '🐟', 'anchov' => '🐟', 'cod' => '🐟', 'carp' => '🐟', 'pike' => '🐟', 'tuna' => '🐟',
    'flint' => '🪨', 'nodule' => '🪨', 'slate' => '🪨', 'pebble' => '🪨', 'rock' => '🪨', 'ore' => '🪨', 'granite' => '🪨', 'marble' => '🪨',
    'crystal' => '💎', 'quartz' => '💎', 'gem' => '💎', 'geode' => '💎', 'amethyst' => '💎', 'jade' => '💎', 'opal' => '💎', 'amber' => '🟠',
    'pearl' => '🦪', 'coral' => '🪸', 'starfish' => '⭐', 'sand dollar' => '🐚', 'sea glass' => '🔮', 'salt' => '🧂', 'sand' => '🏖️',
    'clover' => '🍀', 'fern' => '🌿', 'fiddlehead' => '🌿', 'moss' => '🌿', 'lichen' => '🌿', 'kelp' => '🌿', 'seaweed' => '🌿', 'wrack' => '🌿',
    'reed' => '🌾', 'cattail' => '🌾', 'grass' => '🌾', 'leaf' => '🍃', 'leaves' => '🍃', 'bark' => '🪵', 'birch' => '🪵', 'oak' => '🪵',
    'pine cone' => '🌲', 'pinecone' => '🌲', 'resin' => '🍯', 'sap' => '🍯', 'gall' => '🌰', 'fossil' => '🦴', 'bone' => '🦴', 'beetle' => '🪲',
    'butterfl' => '🦋', 'moth' => '🦋', 'cicada' => '🪲', 'dragonfl' => '🦋', 'bee' => '🐝', 'snail' => '🐌', 'worm' => '🪱', 'ramson' => '🌿',
    // fruit
    'strawberr' => '🍓', 'blueberr' => '🫐', 'bilberr' => '🫐', 'raspberr' => '🍓', 'cherr' => '🍒', 'apple' => '🍎', 'pear' => '🍐', 'peach' => '🍑',
    'apricot' => '🍑', 'plum' => '🍑', 'grape' => '🍇', 'melon' => '🍈', 'watermelon' => '🍉', 'banana' => '🍌', 'plantain' => '🍌', 'pineapple' => '🍍',
    'mango' => '🥭', 'coconut' => '🥥', 'kiwi' => '🥝', 'lemon' => '🍋', 'lime' => '🍋', 'yuzu' => '🍋', 'orange' => '🍊', 'grapefruit' => '🍊',
    'tangerine' => '🍊', 'olive' => '🫒', 'avocado' => '🥑', 'fig' => '🟣', 'date' => '🟤', 'berr' => '🍓',
    // vegetables, grains, herbs
    'tomato' => '🍅', 'carrot' => '🥕', 'potato' => '🥔', 'sweet potato' => '🍠', 'yam' => '🍠', 'onion' => '🧅', 'leek' => '🧅', 'garlic' => '🧄',
    'maize' => '🌽', 'corn' => '🌽', 'pepper' => '🫑', 'chili' => '🌶️', 'chilli' => '🌶️', 'cucumber' => '🥒', 'courgette' => '🥒', 'zucchini' => '🥒',
    'marrow' => '🥒', 'pumpkin' => '🎃', 'squash' => '🎃', 'eggplant' => '🍆', 'aubergine' => '🍆', 'broccoli' => '🥦', 'lettuce' => '🥬',
    'cabbage' => '🥬', 'kale' => '🥬', 'spinach' => '🥬', 'pea' => '🫛', 'bean' => '🫘', 'lentil' => '🫘', 'chickpea' => '🫘', 'peanut' => '🥜',
    'hazelnut' => '🌰', 'chestnut' => '🌰', 'walnut' => '🌰', 'almond' => '🌰', 'acorn' => '🌰', 'nut' => '🥜', 'wheat' => '🌾', 'barley' => '🌾',
    'oat' => '🌾', 'rye' => '🌾', 'rice' => '🍚', 'ginger' => '🫚', 'mint' => '🌿', 'basil' => '🌿', 'parsley' => '🌿', 'dill' => '🌿',
    'thyme' => '🌿', 'rosemary' => '🌿', 'sage' => '🌿', 'herb' => '🌿', 'radish' => '🔴', 'beet' => '🟣', 'turnip' => '⚪', 'sugar' => '🍬',
    // tools and parts
    'hatchet' => '🪓', 'axe' => '🪓', 'rod' => '🎣', 'net' => '🦋', 'bucket' => '🪣', 'pick' => '⛏️', 'hoe' => '⛏️', 'spade' => '🪏', 'shovel' => '🪏',
    'trowel' => '🪏', 'fork' => '🔱', 'watering' => '🚿', 'shears' => '✂️', 'knife' => '🔪', 'scoop' => '🥄', 'basket' => '🧺',
    'staff' => '🦯', 'lantern' => '🏮', 'stone' => '🧱', 'brick' => '🧱', 'plank' => '🪵', 'timber' => '🪵', 'log' => '🪵', 'wood' => '🪵',
    'rope' => '🪢', 'twine' => '🧵', 'string' => '🧵', 'wax' => '🕯️', 'candle' => '🕯️', 'clay' => '🟫', 'glass' => '🔮', 'cardboard' => '📦',
];

function name_emoji(string $name): string
{
    static $cache = [];
    $n = mb_strtolower($name);
    if (isset($cache[$n])) return $cache[$n];
    foreach (NAME_EMOJI as $word => $emoji) {
        if (preg_match('/\b' . preg_quote($word, '/') . '/u', $n)) return $cache[$n] = $emoji;
    }
    return $cache[$n] = '';
}

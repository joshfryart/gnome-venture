<?php
// v1.5.2: draws a red-outlined SVG placeholder for every item with no real art -> assets/img/ph/{slug}.svg
// Run on a fresh install:  php -f tests/gen_ph_items.php /path/to/game   (deterministic: same slug, same picture)
$_SERVER['SCRIPT_NAME'] = '/index.php';
$G = rtrim($argv[1] ?? dirname(__DIR__) . '/game', '/');
require $G . '/includes/bootstrap.php';
require_once $G . '/includes/items.php';
require_once $G . '/includes/tools.php';

const P = ['soil9' => '#3d2a1c', 'soil7' => '#7a4a1f', 'soil5' => '#9a6b3f', 'soil3' => '#c9a96e', 'soil1' => '#f1ece0',
    'moss8' => '#2f5a2a', 'moss6' => '#4f9a45', 'moss4' => '#7ab55c', 'moss2' => '#a4b86a', 'gold7' => '#b07a10', 'gold5' => '#e8a317', 'gold3' => '#f5cf6a',
    'ember7' => '#a8241f', 'ember5' => '#d6322b', 'ember4' => '#e0501f', 'ember3' => '#f08a24', 'petal5' => '#e46a9b', 'petal3' => '#f6b8cf',
    'water7' => '#25637d', 'water5' => '#3f8fb0', 'water3' => '#a9d6ea', 'dusk7' => '#4e3a8a', 'dusk5' => '#7a5cc0', 'dusk3' => '#c3b2ea',
    'stone7' => '#5b6470', 'stone5' => '#8b8f96', 'stone3' => '#c9c5bc', 'ink' => '#2b2b2b', 'cream' => '#f4f0e0'];

/** name word => [main, shade] colour for crops and foods (first match wins; order matters). */
const COLS = [
    'tomatillo' => ['moss4', 'moss6'], 'tomato' => ['ember5', 'ember7'], 'strawberr' => ['ember5', 'ember7'], 'raspberr' => ['petal5', 'ember7'], 'cherry' => ['ember5', 'ember7'], 'cherri' => ['ember5', 'ember7'],
    'pomegranate' => ['ember5', 'ember7'], 'cranberr' => ['ember5', 'ember7'], 'lingonberr' => ['ember5', 'ember7'], 'cloudberr' => ['gold5', 'gold7'], 'chili' => ['ember5', 'ember7'], 'pepper' => ['ember4', 'ember7'], 'radish' => ['petal5', 'ember7'],
    'apple' => ['ember5', 'ember7'], 'rhubarb' => ['petal5', 'ember7'], 'beet' => ['dusk5', 'dusk7'], 'plum' => ['dusk5', 'dusk7'], 'grape' => ['dusk5', 'dusk7'], 'eggplant' => ['dusk5', 'dusk7'], 'elderberr' => ['dusk7', 'ink'],
    'blueberr' => ['water5', 'water7'], 'bilberr' => ['water5', 'water7'], 'blackcurrant' => ['dusk7', 'ink'], 'mulberr' => ['dusk7', 'ink'], 'acai' => ['dusk7', 'ink'], 'jostaberr' => ['dusk7', 'ink'], 'nessberr' => ['dusk5', 'dusk7'], 'crowberr' => ['ink', 'dusk7'],
    'carrot' => ['ember3', 'ember4'], 'orange' => ['ember3', 'ember4'], 'mandarin' => ['ember3', 'ember4'], 'tang' => ['ember3', 'ember4'], 'pumpkin' => ['ember3', 'ember4'], 'papaya' => ['ember3', 'ember4'], 'persimmon' => ['ember3', 'ember4'], 'apricot' => ['ember3', 'ember4'],
    'peach' => ['ember3', 'petal5'], 'mango' => ['gold5', 'ember3'], 'lemon' => ['gold3', 'gold5'], 'lime' => ['moss4', 'moss6'], 'yuzu' => ['gold3', 'gold5'], 'banana' => ['gold3', 'gold5'], 'plantain' => ['gold3', 'gold5'], 'pineapple' => ['gold5', 'gold7'],
    'corn' => ['gold3', 'gold5'], 'maize' => ['gold3', 'gold5'], 'sunflower' => ['gold5', 'gold7'], 'wheat' => ['gold3', 'soil3'], 'barley' => ['gold3', 'soil3'], 'oat' => ['gold3', 'soil3'], 'rye' => ['soil3', 'soil5'], 'millet' => ['gold3', 'soil3'], 'rice' => ['soil1', 'soil3'],
    'potato' => ['soil3', 'soil5'], 'yam' => ['ember4', 'soil7'], 'cassava' => ['soil3', 'soil5'], 'taro' => ['dusk3', 'soil5'], 'onion' => ['gold3', 'soil5'], 'garlic' => ['soil1', 'soil3'], 'leek' => ['moss2', 'moss6'], 'ginger' => ['soil3', 'soil5'], 'turmeric' => ['gold5', 'ember3'],
    'turnip' => ['soil1', 'petal5'], 'daikon' => ['soil1', 'stone3'], 'parsnip' => ['soil1', 'soil3'], 'cauliflower' => ['soil1', 'stone3'], 'coconut' => ['soil7', 'soil9'], 'cacao' => ['soil7', 'soil9'], 'coffee' => ['soil7', 'soil9'],
    'kiwi' => ['soil5', 'moss6'], 'avocado' => ['moss8', 'moss6'], 'olive' => ['moss6', 'moss8'], 'fig' => ['dusk5', 'dusk7'], 'date' => ['soil7', 'soil9'], 'melon' => ['moss4', 'moss6'], 'watermelon' => ['moss6', 'ember5'], 'dragon' => ['petal5', 'moss6'],
    'peanut' => ['soil3', 'soil5'], 'hazelnut' => ['soil5', 'soil7'], 'chestnut' => ['soil7', 'soil9'], 'walnut' => ['soil5', 'soil7'], 'almond' => ['soil3', 'soil5'], 'pecan' => ['soil7', 'soil9'], 'brazil' => ['soil7', 'soil9'], 'cashew' => ['soil3', 'gold5'], 'pistachio' => ['moss2', 'soil3'], 'macadamia' => ['soil3', 'soil5'],
    'bean' => ['soil7', 'soil9'], 'lentil' => ['ember3', 'soil7'], 'chickpea' => ['gold3', 'soil3'], 'pea' => ['moss4', 'moss6'], 'soy' => ['moss4', 'moss6'],
    'honey' => ['gold5', 'gold7'], 'saffron' => ['ember4', 'ember7'], 'cinnamon' => ['soil5', 'soil7'], 'nutmeg' => ['soil5', 'soil7'], 'clove' => ['soil7', 'soil9'], 'vanilla' => ['soil7', 'soil9'], 'cumin' => ['soil5', 'soil7'], 'pepper' => ['ink', 'stone7'],
    'cocoa' => ['soil7', 'soil9'], 'chocolate' => ['soil7', 'soil9'], 'carrot' => ['ember3', 'ember4'], 'cheese' => ['gold3', 'gold5'], 'egg' => ['soil1', 'soil3'], 'milk' => ['soil1', 'stone3'], 'cream' => ['cream', 'soil3'],
    'berry' => ['ember5', 'ember7'], 'mushroom' => ['soil3', 'soil5'], 'mint' => ['moss4', 'moss6'], 'tea' => ['moss4', 'soil5'], 'sage' => ['moss2', 'moss6'], 'trout' => ['water5', 'water7'], 'carp' => ['gold5', 'gold7'], 'salmon' => ['petal5', 'ember5'],
];
const FALL = [['moss4', 'moss6'], ['gold5', 'gold7'], ['ember3', 'ember4'], ['petal5', 'ember7'], ['dusk5', 'dusk7'], ['water5', 'water7'], ['moss2', 'moss6'], ['soil3', 'soil5']];

function hh(string $s): int { return hexdec(substr(md5($s), 0, 8)); }
function pick(array $a, string $s, int $salt = 0) { return $a[(hh($s) >> ($salt * 3)) % count($a)]; }
function col(string $k): string { return P[$k] ?? $k; }
function has(string $s, string $w): bool { return str_contains($s, $w); }
function hasany(string $s, array $w): bool { foreach ($w as $x) if (str_contains($s, $x)) return true; return false; }

/** [main, shade] colours for a slug/name (both as hex). */
function colours(string $slug): array
{
    $t = str_replace('-', ' ', $slug);
    foreach (COLS as $w => $c) if (str_contains($t, $w)) return [col($c[0]), col($c[1])];
    $c = pick(FALL, $slug);
    return [col($c[0]), col($c[1])];
}

function svg(string $body, string $slug, bool $shadow = true): string
{
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="' . htmlspecialchars($slug) . ' (placeholder)">'
        . ($shadow ? '<ellipse cx="32" cy="57" rx="17" ry="3.5" fill="#000" opacity=".15"/>' : '') . $body
        . '</svg>';
}
function hi(string $d): string { return '<path d="' . $d . '" fill="#fff" opacity=".4"/>'; }
function leaf(int $x, int $y, int $rot = 0, string $c = '#4f9a45'): string
{
    return '<path transform="rotate(' . $rot . ' ' . $x . ' ' . $y . ')" d="M' . $x . ' ' . $y . 'q-3-9 4-12 5 7-4 12z" fill="' . $c . '"/>';
}

// ---------- produce: crop shapes ----------
function crop_shape(string $slug, ?string $kind): string
{
    $t = $slug;
    if (hasany($t, ['berry', 'berries', 'currant', 'grape', 'acai', 'elderberr', 'goji', 'cranberr'])) return 'cluster';
    if (hasany($t, ['carrot', 'daikon', 'radish', 'beet', 'turnip', 'parsnip', 'cassava', 'potato', 'yam', 'taro', 'ginger', 'turmeric', 'ginseng', 'horseradish', 'wasabi', 'lotus', 'kohlrabi'])) return 'root';
    if (hasany($t, ['cucumber', 'zucchini', 'courgette', 'eggplant', 'banana', 'plantain', 'okra', 'asparagus', 'leek', 'celery', 'rhubarb', 'bamboo', 'lemongrass', 'chayote', 'bitter-melon', 'cinnamon', 'sugarcane', 'vanilla', 'cardamom', 'fennel'])) return 'long';
    if (hasany($t, ['bean', 'pea', 'peanut', 'pod', 'carob', 'tamarind', 'lentil', 'chickpea', 'soy', 'cacao', 'ackee', 'kava', 'sago'])) return 'pod';
    if (hasany($t, ['nut', 'almond', 'acorn', 'chestnut', 'pecan', 'pistachio', 'cashew', 'coconut', 'kola', 'shea', 'macadamia'])) return 'nut';
    if (hasany($t, ['lettuce', 'kale', 'cabbage', 'spinach', 'chard', 'collard', 'bok-choy', 'sprouts', 'basil', 'mint', 'parsley', 'dill', 'thyme', 'oregano', 'rosemary', 'sorrel', 'coriander', 'perilla', 'fenugreek', 'moringa', 'amaranth', 'greens', 'leaf', 'broccoli', 'cauliflower', 'broccoflower', 'artichoke', 'tea', 'rooibos', 'mate', 'hops', 'kangkong', 'kalette', 'napa'])) return 'leafy';
    if (hasany($t, ['wheat', 'barley', 'oats', 'rye', 'rice', 'millet', 'corn', 'sorghum', 'teff', 'fonio', 'quinoa', 'buckwheat', 'triticale', 'tritordeum', 'sesame', 'sunflower'])) return 'grain';
    return match ($kind) { 'grain' => 'grain', 'legume' => 'pod', 'nut' => 'nut', 'herb' => 'leafy', 'spice' => 'pod', 'tuber' => 'root', default => 'round' };
}

function draw_crop(string $shape, string $slug, string $m, string $s): string
{
    $h = hh($slug);
    $g = col('moss6');
    switch ($shape) {
        case 'cluster':
            $b = '';
            foreach ([[24, 38], [40, 38], [32, 30], [20, 48], [34, 48], [47, 48]] as $k => [$x, $y]) $b .= '<circle cx="' . $x . '" cy="' . $y . '" r="8" fill="' . ($k % 2 ? $s : $m) . '"/>';
            return $b . hi('M18 44a4 4 0 0 1 4-4M30 26a4 4 0 0 1 4-1') . '<path d="M32 22v-8" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/>' . leaf(33, 18, 40, $g);
        case 'root':
            $w = 8 + $h % 6;
            return '<path d="M' . (32 - $w) . ' 20h' . 2 * $w . 'q2 18-' . ($w) . ' 36q-' . ($w + 2) . '-18-' . $w . '-36z" fill="' . $m . '"/><path d="M' . (32 - $w + 3) . ' 30h6M' . (32 + 2) . ' 38h5" stroke="' . $s . '" stroke-width="2" stroke-linecap="round"/>'
                . hi('M25 24q0 8 2 14') . '<path d="M32 20c-6-4-8-9-5-13 4 2 6 6 5 13zM32 20c6-4 8-9 5-13-4 2-6 6-5 13z" fill="' . $g . '"/>';
        case 'long':
            return '<g transform="rotate(-35 32 32)"><rect x="8" y="23" width="48" height="18" rx="9" fill="' . $m . '"/><rect x="8" y="33" width="48" height="8" rx="4" fill="' . $s . '" opacity=".5"/><rect x="50" y="26" width="9" height="12" rx="3" fill="' . col('moss8') . '"/></g>' . hi('M16 28l12-10');
        case 'pod':
            return '<path d="M10 40Q18 12 54 18Q50 50 10 40z" fill="' . $m . '"/><path d="M14 38Q26 24 50 22" fill="none" stroke="' . $s . '" stroke-width="2.4" stroke-linecap="round"/><circle cx="24" cy="32" r="3.4" fill="' . $s . '"/><circle cx="33" cy="28" r="3.4" fill="' . $s . '"/><circle cx="42" cy="25" r="3.4" fill="' . $s . '"/><path d="M10 40l-4 5" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/>' . hi('M18 30q6-8 14-10');
        case 'nut':
            return '<ellipse cx="32" cy="36" rx="15" ry="17" fill="' . $m . '"/><path d="M17 30Q32 14 47 30Q32 24 17 30z" fill="' . $s . '"/><path d="M32 20v-6" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/><path d="M26 42q6 5 12 0" fill="none" stroke="' . $s . '" stroke-width="2" stroke-linecap="round"/>' . hi('M22 38q0-6 4-9');
        case 'leafy':
            $c = (hh($slug . 'l') % 2) ? col('moss6') : col('moss4');
            return '<path d="M32 54C10 50 8 24 32 8c24 16 22 42 0 46z" fill="' . $c . '"/><path d="M32 52V16M32 38l-10-8M32 30l9-8M32 44l-8-6" fill="none" stroke="' . col('moss8') . '" stroke-width="2.4" stroke-linecap="round"/>' . hi('M20 24q4-9 10-13');
        case 'grain':
            $o = '<path d="M32 58V24" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/>';
            foreach ([[0, 22], [1, 29], [2, 36]] as [$i, $y]) $o .= '<ellipse cx="25" cy="' . $y . '" rx="4.5" ry="7" transform="rotate(-25 25 ' . $y . ')" fill="' . $m . '"/><ellipse cx="39" cy="' . $y . '" rx="4.5" ry="7" transform="rotate(25 39 ' . $y . ')" fill="' . $s . '"/>';
            return $o . '<ellipse cx="32" cy="15" rx="4.5" ry="8" fill="' . $m . '"/>' . leaf(32, 52, -50, $g);
        default: // round fruit
            $r = 15 + $h % 3;
            return '<circle cx="32" cy="' . (36) . '" r="' . $r . '" fill="' . $m . '"/><path d="M' . (32 - $r + 3) . ' ' . (40) . 'a' . ($r - 3) . ' ' . ($r - 3) . ' 0 0 0 ' . 2 * ($r - 3) . ' 0q-' . ($r - 3) . ' 8-' . 2 * ($r - 3) . ' 0z" fill="' . $s . '" opacity=".5"/>'
                . hi('M21 31q2-7 8-9') . '<path d="M32 21v-7" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/>' . leaf(33, 18, 50, $g);
    }
}

// ---------- seed packets ----------
function draw_seed(string $slug, ?string $kind, string $m, string $s): string
{
    // v1.6.2: the packet shows its crop (shape from the plant kind / name, colour from the crop) so radish, carrot, lettuce and tomato seeds look different
    $base = preg_replace('/-seed$/', '', $slug);
    $b = '<path d="M16 12h32l3 6v38H13V18z" fill="' . col('soil1') . '"/><path d="M13 18h38" stroke="' . col('soil3') . '" stroke-width="2"/>'
        . '<rect x="18" y="22" width="28" height="28" rx="6" fill="' . col('cream') . '" stroke="' . $m . '" stroke-width="2"/>'
        . '<g transform="translate(19.6 23.6) scale(.4375)">' . draw_crop(crop_shape($base, $kind), $base, $m, $s) . '</g>';
    $b .= '<circle cx="26" cy="53" r="1.6" fill="' . col('soil7') . '"/><circle cx="32" cy="53" r="1.6" fill="' . col('soil7') . '"/><circle cx="38" cy="53" r="1.6" fill="' . col('soil7') . '"/>' . hi('M17 14h12l-1 4H15z');
    if ($kind === 'tree') $b .= '<path d="M45 9l5 8h-10z" fill="' . col('moss8') . '"/>';
    return $b;
}

// ---------- food and dishes ----------
function draw_food(string $slug, string $m, string $s): string
{
    $t = $slug;
    $steam = '<path d="M26 14q-3 4 0 8M34 12q-3 4 0 8" fill="none" stroke="#fff" stroke-width="2.2" stroke-linecap="round" opacity=".5"/>';
    if (str_starts_with($t, 'feast')) {
        return '<ellipse cx="32" cy="44" rx="27" ry="10" fill="' . col('stone3') . '"/><ellipse cx="32" cy="42" rx="22" ry="7.5" fill="' . col('cream') . '"/><path d="M14 40q4-18 18-18t18 18q-18 6-36 0z" fill="' . $m . '"/><circle cx="24" cy="34" r="4" fill="' . $s . '"/><circle cx="39" cy="32" r="4.5" fill="' . col('moss4') . '"/><circle cx="32" cy="27" r="3.5" fill="' . col('gold5') . '"/>' . hi('M20 36q2-6 8-8') . '<path d="M32 10l2 4 4 .5-3 3 1 4-4-2-4 2 1-4-3-3 4-.5z" fill="' . col('gold5') . '"/>';
    }
    if (hasany($t, ['tea', 'cordial', 'cocoa', 'juice', 'lemonade', 'smoothie', 'milk'])) {
        return '<path d="M16 24h28v18q0 12-14 12T16 42z" fill="' . col('stone3') . '"/><path d="M44 28h5q5 0 5 6t-9 8" fill="none" stroke="' . col('stone3') . '" stroke-width="4" stroke-linecap="round"/><path d="M16 24h28v10q-14 6-28 0z" fill="' . $m . '"/><path d="M16 24h28" stroke="' . col('stone5') . '" stroke-width="2.4"/>' . $steam . hi('M20 36v8');
    }
    if (hasany($t, ['jam', 'chutney', 'pickle', 'kimchi', 'sauerkraut', 'pesto', 'honey', 'pickled', 'preserve', 'marmalade', 'cheese-jar'])) {
        return '<rect x="18" y="22" width="28" height="32" rx="7" fill="' . col('water3') . '" opacity=".7"/><rect x="20" y="30" width="24" height="22" rx="5" fill="' . $m . '"/><rect x="17" y="14" width="30" height="10" rx="4" fill="' . col('gold5') . '"/><rect x="22" y="36" width="20" height="9" rx="2" fill="' . col('cream') . '"/>' . hi('M22 28v18');
    }
    if (hasany($t, ['pie', 'tart', 'crumble', 'quiche', 'cake', 'frittata', 'tortilla', 'sorbet'])) {
        if (has($t, 'cake') || has($t, 'sorbet')) return '<rect x="12" y="32" width="40" height="20" rx="5" fill="' . col('soil3') . '"/><path d="M12 36q6-9 10-1t10-1 10 1 10-1v-5a5 5 0 0 0-5-5H17a5 5 0 0 0-5 5z" fill="' . $m . '"/><rect x="30" y="14" width="4" height="12" rx="2" fill="' . col('petal3') . '"/><path d="M32 8q3 3 0 6-3-3 0-6z" fill="' . col('gold5') . '"/>' . hi('M16 34h10');
        return '<ellipse cx="32" cy="42" rx="26" ry="12" fill="' . col('soil5') . '"/><ellipse cx="32" cy="38" rx="26" ry="12" fill="' . col('soil3') . '"/><ellipse cx="32" cy="38" rx="19" ry="8" fill="' . $m . '"/><path d="M22 36l20 4M42 36l-20 4" stroke="' . col('soil3') . '" stroke-width="2.4" stroke-linecap="round"/>' . hi('M14 36q4-6 12-8');
    }
    if (hasany($t, ['bread', 'toast', 'flatbread', 'pancake', 'fritter', 'biscuit', 'muffin', 'cookie', 'pasty', 'cornbread'])) {
        if (hasany($t, ['pancake', 'fritter'])) return '<ellipse cx="32" cy="46" rx="22" ry="7" fill="' . col('soil5') . '"/><ellipse cx="32" cy="41" rx="22" ry="7" fill="' . col('soil3') . '"/><ellipse cx="32" cy="35" rx="20" ry="6.5" fill="' . col('gold3') . '"/><path d="M24 33q8-3 16 0v3q-8 2-16 0z" fill="' . $m . '"/>' . hi('M16 35q4-3 9-3');
        return '<path d="M10 42q0-20 22-20t22 20q0 8-8 8H18q-8 0-8-8z" fill="' . col('soil3') . '"/><path d="M16 36q6-9 12-4M30 30q6-8 12-2M40 40q4-6 8-3" fill="none" stroke="' . col('soil5') . '" stroke-width="2.6" stroke-linecap="round"/>' . hi('M14 38q2-8 8-12');
    }
    if (hasany($t, ['stew', 'soup', 'curry', 'dal', 'chowder', 'broth', 'pilaf', 'mole', 'shakshuka', 'risotto', 'pot'])) {
        return '<ellipse cx="32" cy="24" rx="22" ry="6" fill="' . col('stone7') . '"/><path d="M10 24q0 28 22 28t22-28z" fill="' . col('stone5') . '"/><ellipse cx="32" cy="24" rx="19" ry="4.5" fill="' . $m . '"/><circle cx="26" cy="23.5" r="2" fill="' . $s . '"/><circle cx="37" cy="24" r="2.2" fill="' . col('moss4') . '"/><path d="M8 24h-3M56 24h3" stroke="' . col('stone7') . '" stroke-width="4" stroke-linecap="round"/>' . $steam . hi('M14 30q2 10 8 15');
    }
    if (hasany($t, ['salad', 'porridge', 'rice', 'bowl', 'sunflower-snack', 'peanut', 'roasted', 'sardines', 'trout', 'eggs', 'fried'])) {
        return '<path d="M8 28h48q0 24-24 24T8 28z" fill="' . col('cream') . '"/><path d="M8 28h48" stroke="' . col('stone3') . '" stroke-width="2"/><path d="M12 28q4-14 20-14t20 14z" fill="' . $m . '"/><circle cx="24" cy="22" r="3.4" fill="' . $s . '"/><circle cx="35" cy="20" r="3.4" fill="' . col('moss4') . '"/><circle cx="43" cy="24" r="2.8" fill="' . col('gold5') . '"/>' . hi('M12 34q2 8 8 11');
    }
    if (hasany($t, ['cheese'])) return '<path d="M8 44L36 18l20 8v18z" fill="' . col('gold3') . '"/><path d="M8 44h48v8H8z" fill="' . col('gold5') . '"/><circle cx="38" cy="34" r="3" fill="' . col('gold7') . '"/><circle cx="28" cy="43" r="2.4" fill="' . col('gold7') . '"/>' . hi('M12 42l20-18');
    // plate
    return '<ellipse cx="32" cy="42" rx="26" ry="11" fill="' . col('stone3') . '"/><ellipse cx="32" cy="40" rx="20" ry="8" fill="' . col('cream') . '"/><ellipse cx="32" cy="36" rx="13" ry="9" fill="' . $m . '"/><ellipse cx="29" cy="33" rx="5" ry="3" fill="' . $s . '" opacity=".6"/><circle cx="40" cy="38" r="3.2" fill="' . col('moss4') . '"/>' . hi('M22 34q3-5 8-6');
}

// ---------- forage: mushroom, herb, berry, shell, feather, stone, wood, fish ----------
function draw_forage(string $slug, string $m, string $s): string
{
    $t = $slug;
    if (hasany($t, ['chanterelle', 'morel', 'mushroom', 'toadstool', 'truffle'])) return '<rect x="26" y="34" width="12" height="20" rx="5" fill="' . col('soil1') . '"/><path d="M8 38Q10 10 32 10t24 28q-24 6-48 0z" fill="' . $m . '"/><circle cx="22" cy="26" r="3.4" fill="#fff" opacity=".7"/><circle cx="36" cy="20" r="3" fill="#fff" opacity=".7"/><circle cx="44" cy="30" r="2.6" fill="#fff" opacity=".7"/>' . hi('M14 30q2-10 10-14');
    if (hasany($t, ['trout', 'char', 'carp', 'mackerel', 'minnow', 'moonfish', 'rainbow-fish', 'reef-fish', 'sardine', 'perch', 'fish'])) return '<path d="M8 32q14-18 34-2l12-8v20l-12-8Q22 56 8 32z" fill="' . $m . '"/><path d="M18 36q12 8 24-6" fill="' . col('cream') . '" opacity=".5"/><circle cx="17" cy="31" r="2" fill="' . col('ink') . '"/><path d="M28 24v14M34 25v12" stroke="' . $s . '" stroke-width="2" stroke-linecap="round"/>' . hi('M14 28q8-8 18-4');
    if (hasany($t, ['shell', 'cowrie', 'urchin', 'conch', 'clam', 'oyster', 'mussel', 'spiral', 'scute', 'coral', 'sea-glass', 'pearl'])) {
        if (has($t, 'glass')) return '<path d="M14 40l8-20 20-4 10 18-10 20-20 2z" fill="' . col('water3') . '" opacity=".85"/><path d="M22 20l-4 14" fill="none" stroke="#fff" stroke-width="3" opacity=".6"/>';
        if (hasany($t, ['coral', 'urchin'])) return '<path d="M32 56V34M32 44l-12-14M32 40l12-14M20 30V18M44 26V14" stroke="' . col('petal5') . '" stroke-width="6" stroke-linecap="round" fill="none"/>' . hi('M30 52V36');
        return '<path d="M32 54C10 50 6 28 16 18q16-10 32 0c10 10 6 32-16 36z" fill="' . col('petal3') . '"/><path d="M32 52V18M32 52L20 20M32 52l12-32M32 52L12 28M32 52l20-24" fill="none" stroke="' . col('soil3') . '" stroke-width="2.2"/>' . hi('M18 24q6-6 12-7');
    }
    if (hasany($t, ['feather', 'plume', 'down', 'quill'])) return '<path d="M16 54C8 34 22 12 50 8 52 34 36 52 16 54z" fill="' . $m . '"/><path d="M14 56L44 16" stroke="' . $s . '" stroke-width="2.6" stroke-linecap="round"/><path d="M26 40l8-2M32 32l8-2M22 46l6-1" stroke="' . $s . '" stroke-width="1.8" stroke-linecap="round"/>' . hi('M24 30q6-10 16-14');
    if (hasany($t, ['crystal', 'quartz', 'geode', 'gem', 'glass', 'rose-stone', 'ochre', 'flint', 'clay', 'iron', 'peat', 'ash'])) {
        if (hasany($t, ['crystal', 'quartz', 'geode', 'rose'])) return '<path d="M32 6l12 14-6 34H26L20 20z" fill="' . col('water3') . '"/><path d="M20 20l12 8 12-8M32 28v26" fill="none" stroke="' . col('water5') . '" stroke-width="2"/><path d="M14 54l8-16 6 16zM42 54l6-14 8 14z" fill="' . col('dusk3') . '"/>' . hi('M26 18l4-8');
        return '<path d="M8 46Q8 26 28 22t26 22q0 10-22 10T8 46z" fill="' . ((hasany($t, ['clay', 'ochre', 'iron'])) ? $m : col('stone5')) . '"/><path d="M12 48q20 6 40 0" fill="none" stroke="' . col('stone7') . '" stroke-width="3" stroke-linecap="round" opacity=".5"/>' . hi('M16 38q4-8 12-10');
    }
    if (hasany($t, ['log', 'trunk', 'bark', 'heartwood', 'driftwood', 'cork', 'coir', 'husk', 'root', 'resin', 'sap', 'cap', 'cone'])) {
        return '<rect x="6" y="24" width="52" height="24" rx="12" fill="' . col('soil7') . '"/><ellipse cx="50" cy="36" rx="9" ry="12" fill="' . col('soil3') . '"/><ellipse cx="50" cy="36" rx="5" ry="7" fill="none" stroke="' . col('soil5') . '" stroke-width="2"/><path d="M14 30h20M12 40h24" stroke="' . col('soil9') . '" stroke-width="2.4" stroke-linecap="round" opacity=".6"/>' . hi('M12 28h22');
    }
    if (hasany($t, ['berries', 'strawberries', 'bilberries', 'crowberries', 'honeycomb'])) {
        if (has($t, 'honey')) return '<path d="M32 8l20 11v24L32 54 12 43V19z" fill="' . col('gold5') . '"/><path d="M32 18l11 6v13l-11 6-11-6V24z" fill="' . col('gold3') . '"/>' . hi('M18 22l12-8');
        return draw_crop('cluster', $slug, $m, $s);
    }
    if (hasany($t, ['clover', 'fern', 'frond', 'kelp', 'lichen', 'sphagnum', 'moss', 'samphire', 'meadowsweet', 'ramsons', 'sage', 'edelweiss', 'cattail', 'cottongrass', 'seed-pod', 'bromeliad'])) {
        $v = hh($slug) % 3;
        if ($v === 1) return '<path d="M32 56V30" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/>' . implode('', array_map(fn($a) => '<ellipse cx="32" cy="22" rx="5" ry="13" transform="rotate(' . $a . ' 32 34)" fill="' . ($a % 40 ? col('moss4') : col('moss6')) . '"/>', [-70, -35, 0, 35, 70])) . '<circle cx="32" cy="32" r="5" fill="' . $m . '"/>' . hi('M20 24q2-6 8-8');
        if ($v === 2) return implode('', array_map(fn($x) => '<path d="M' . $x . ' 56Q' . ($x - 4) . ' 32 ' . ($x < 32 ? $x - 12 : ($x > 32 ? $x + 12 : 32)) . ' 12" fill="none" stroke="' . ($x % 3 ? col('moss6') : col('moss4')) . '" stroke-width="5" stroke-linecap="round"/>', [18, 26, 32, 38, 46])) . '<ellipse cx="32" cy="56" rx="16" ry="3" fill="' . col('soil7') . '"/><circle cx="32" cy="14" r="4" fill="' . $m . '"/>';
        return '<path d="M32 56V20" stroke="' . col('moss8') . '" stroke-width="3" stroke-linecap="round"/>' . implode('', array_map(fn($y) => '<path d="M32 ' . $y . 'q-12 0-16-8 12-2 16 8zM32 ' . $y . 'q12 0 16-8-12-2-16 8z" fill="' . ($y % 2 ? col('moss6') : col('moss4')) . '"/>', [46, 36, 26])) . '<circle cx="32" cy="16" r="5" fill="' . $m . '"/>' . hi('M20 36q4-3 8-2');
    }
    if (hasany($t, ['beetle', 'dust', 'scales', 'wing', 'moth', 'cricket', 'firefly'])) return '<path d="M32 30C20 8 6 14 10 30c4 14 18 14 22 0zM32 30c12-22 26-16 22 0-4 14-18 14-22 0z" fill="' . $m . '" opacity=".9"/><rect x="30" y="22" width="4" height="26" rx="2" fill="' . col('ink') . '"/><circle cx="19" cy="28" r="4" fill="#fff" opacity=".5"/><circle cx="45" cy="28" r="4" fill="#fff" opacity=".5"/>';
    return '<path d="M8 46Q8 28 26 24t30 22q0 8-24 8T8 46z" fill="' . $m . '"/><path d="M20 40q8-8 20-2" fill="none" stroke="' . $s . '" stroke-width="3" stroke-linecap="round"/>' . hi('M14 40q4-8 12-10');
}

// ---------- soil and mulch ----------
function draw_soil(string $slug, string $cat): string
{
    $t = $slug;
    $c = hasany($t, ['ash', 'rock', 'shell']) ? [col('stone5'), col('stone7')] : (hasany($t, ['tea', 'fern', 'kelp']) ? [col('moss6'), col('moss8')] : (has($t, 'straw') ? [col('gold3'), col('gold5')] : (has($t, 'leaf') ? [col('ember3'), col('soil7')] : [col('soil7'), col('soil9')])));
    if (has($t, 'worm') || has($t, 'earthworm')) {
        if (has($t, 'tea')) return '<path d="M16 22h32l-3 30H19z" fill="' . col('water3') . '"/><path d="M18 34h28l-1 18H19z" fill="' . col('soil7') . '"/>' . hi('M20 24v22');
        return '<path d="M10 48Q10 34 32 34t22 14z" fill="' . col('soil7') . '"/><path d="M14 30q6-12 14-2t8-6 12 2" fill="none" stroke="' . col('petal5') . '" stroke-width="5" stroke-linecap="round"/><circle cx="46" cy="28" r="1.5" fill="' . col('ink') . '"/>' . hi('M14 42q6-5 14-5');
    }
    if (hasany($t, ['tea', 'wood-chips', 'chips']) && !has($t, 'wood')) return '<path d="M16 20h32l-3 32H19z" fill="' . $c[0] . '"/><rect x="14" y="14" width="36" height="8" rx="3" fill="' . col('soil5') . '"/>' . hi('M20 26v22');
    if ($cat === 'mulch' || has($t, 'compost') || has($t, 'loam') || has($t, 'dust') || has($t, 'meal') || has($t, 'ash')) {
        return '<path d="M14 18l8-6h20l8 6 4 32q0 6-8 6H18q-8 0-8-6z" fill="' . col('soil5') . '"/><path d="M22 12l-3 8h26l-3-8z" fill="' . col('soil3') . '"/><ellipse cx="32" cy="36" rx="12" ry="10" fill="' . $c[0] . '"/><path d="M26 34l6 8 6-8" fill="none" stroke="' . $c[1] . '" stroke-width="2.6" stroke-linecap="round"/>' . hi('M16 24l-2 22');
    }
    return '<path d="M6 50Q8 24 32 22t26 28q0 6-26 6T6 50z" fill="' . $c[0] . '"/><path d="M14 46q8-6 14-2M34 42q8-4 14 2" fill="none" stroke="' . $c[1] . '" stroke-width="3" stroke-linecap="round"/><circle cx="24" cy="36" r="2" fill="' . $c[1] . '"/><circle cx="40" cy="38" r="2" fill="' . $c[1] . '"/>' . hi('M12 42q4-10 14-14');
}

// ---------- tools and broken tools ----------
const TIER_COL = [1 => ['soil7', 'soil5'], 2 => ['stone5', 'stone7'], 3 => ['stone3', 'stone5'], 4 => ['gold5', 'gold7']];
function tool_kind(string $t): string
{
    foreach (['lantern' => 'lantern', 'watering' => 'can', 'sprinkler' => 'can', 'rain-wand' => 'wand', 'knife' => 'knife', 'hori' => 'knife', 'pick' => 'pick', 'hammer' => 'pick', 'axe' => 'axe', 'hatchet' => 'axe', 'rod' => 'rod',
        'net' => 'net', 'bucket' => 'bucket', 'pail' => 'bucket', 'trowel' => 'trowel', 'dibber' => 'trowel', 'hoe' => 'hoe', 'shears' => 'shears', 'secateurs' => 'shears', 'snips' => 'shears', 'fork' => 'fork',
        'spade' => 'spade', 'scoop' => 'scoop', 'basket' => 'basket', 'trug' => 'basket', 'sack' => 'basket', 'pouch' => 'basket', 'pack' => 'basket', 'creel' => 'basket', 'staff' => 'staff', 'stick' => 'staff',
        'barrow' => 'barrow', 'cart' => 'barrow', 'drill' => 'drill', 'seeder' => 'drill', 'probe' => 'probe', 'kit' => 'probe'] as $w => $k) if (str_contains($t, $w)) return $k;
    return 'trowel';
}
function draw_tool(string $kind, string $m, string $s, string $slug): string
{
    $wd = col('soil7'); $wl = col('soil5');
    $h = fn(string $d) => '<path d="' . $d . '" stroke="' . $wd . '" stroke-width="5" stroke-linecap="round" fill="none"/>';
    switch ($kind) {
        case 'knife': return '<g transform="rotate(40 32 32)"><rect x="29" y="34" width="7" height="22" rx="3" fill="' . $wd . '"/><path d="M29 36V10q8 4 7 26z" fill="' . $m . '"/><path d="M33 12v22" stroke="#fff" stroke-width="2" opacity=".4"/></g>';
        case 'pick': return $h('M32 22L48 54') . '<path d="M8 26Q32 4 56 26Q32 16 8 26z" fill="' . $m . '"/><path d="M12 25Q32 12 52 25" fill="none" stroke="#fff" stroke-width="2" opacity=".4"/>';
        case 'axe': return $h('M22 56L40 12') . '<path d="M36 10Q56 10 54 30Q44 28 38 26z" fill="' . $m . '"/><path d="M41 14q8 2 9 10" fill="none" stroke="#fff" stroke-width="2" opacity=".4"/>';
        case 'rod': return '<path d="M10 56L50 10" stroke="' . $wd . '" stroke-width="4" stroke-linecap="round"/><path d="M50 10q8 10 0 26" fill="none" stroke="' . col('stone3') . '" stroke-width="1.6"/><circle cx="50" cy="38" r="3.5" fill="' . $m . '"/><circle cx="20" cy="44" r="5" fill="' . $s . '"/>';
        case 'net': return '<path d="M12 56L36 30" stroke="' . $wd . '" stroke-width="5" stroke-linecap="round"/><circle cx="42" cy="22" r="14" fill="' . col('water3') . '" opacity=".6"/><circle cx="42" cy="22" r="14" fill="none" stroke="' . $m . '" stroke-width="3.5"/><path d="M32 22h20M42 12v20" stroke="' . $s . '" stroke-width="1.4"/>';
        case 'bucket': return '<path d="M14 24h36l-4 30H18z" fill="' . $m . '"/><path d="M14 24h36" stroke="' . $s . '" stroke-width="4"/><path d="M16 24Q32 2 48 24" fill="none" stroke="' . $s . '" stroke-width="3"/>' . hi('M20 28l2 20');
        case 'can': return '<path d="M12 28h28l-3 24H15z" fill="' . $m . '"/><path d="M40 34L56 22" stroke="' . $s . '" stroke-width="5" stroke-linecap="round"/><path d="M14 28Q26 8 38 28" fill="none" stroke="' . $s . '" stroke-width="3"/><circle cx="58" cy="20" r="2" fill="' . col('water3') . '"/>' . hi('M17 32l2 14');
        case 'trowel': return $h('M44 56L36 36') . '<path d="M36 36Q20 36 18 14Q40 10 44 36z" fill="' . $m . '"/><path d="M26 18l10 14" stroke="#fff" stroke-width="2" opacity=".4"/>';
        case 'hoe': return $h('M16 56L40 8') . '<path d="M36 10h18l-2 10H34z" fill="' . $m . '"/>';
        case 'shears': return '<path d="M30 34L16 8M34 34L48 8" stroke="' . $m . '" stroke-width="5" stroke-linecap="round"/><path d="M30 34L20 56M34 34l10 22" stroke="' . $wd . '" stroke-width="6" stroke-linecap="round"/><circle cx="32" cy="34" r="3" fill="' . $s . '"/>';
        case 'fork': return $h('M32 30V58') . '<path d="M16 8v18q0 8 16 8t16-8V8M32 8v26" fill="none" stroke="' . $m . '" stroke-width="4.5" stroke-linecap="round"/>';
        case 'spade': return $h('M32 6V34') . '<path d="M18 30h28q0 24-14 26Q18 54 18 30z" fill="' . $m . '"/>' . hi('M22 34q0 8 4 14');
        case 'scoop': return $h('M48 56L38 32') . '<path d="M10 22Q30 52 42 28Q26 10 10 22z" fill="' . $m . '"/>';
        case 'basket': return '<path d="M10 28h44l-5 26H15z" fill="' . col('gold7') . '"/><path d="M14 36h36M13 44h38" stroke="' . col('gold3') . '" stroke-width="2.4"/><path d="M14 28Q32 -2 50 28" fill="none" stroke="' . col('gold7') . '" stroke-width="4"/><circle cx="26" cy="26" r="4" fill="' . $m . '"/>';
        case 'staff': return '<path d="M20 58L44 8" stroke="' . $wd . '" stroke-width="5" stroke-linecap="round"/><circle cx="44" cy="10" r="6" fill="' . $m . '"/><path d="M26 44l-6 2" stroke="' . $s . '" stroke-width="3" stroke-linecap="round"/>';
        case 'barrow': return '<path d="M8 22h34l-8 20H20z" fill="' . $m . '"/><path d="M42 22L58 14M30 42l24 10" stroke="' . $wd . '" stroke-width="4" stroke-linecap="round"/><circle cx="22" cy="48" r="7" fill="' . col('ink') . '"/><circle cx="22" cy="48" r="2.4" fill="' . $s . '"/>';
        case 'lantern': return '<path d="M32 4v8" stroke="' . $s . '" stroke-width="3"/><rect x="20" y="12" width="24" height="6" rx="3" fill="' . $m . '"/><rect x="22" y="18" width="20" height="28" rx="4" fill="' . col('gold3') . '" opacity=".9"/><circle cx="32" cy="32" r="6" fill="' . col('gold5') . '"/><rect x="20" y="46" width="24" height="6" rx="3" fill="' . $m . '"/>';
        case 'wand': return '<path d="M14 54L44 12" stroke="' . $wd . '" stroke-width="4.5" stroke-linecap="round"/><path d="M46 6l3 6 6 1-5 4 2 6-6-4-6 4 2-6-5-4 6-1z" fill="' . $m . '"/><circle cx="20" cy="30" r="2" fill="' . col('water3') . '"/><circle cx="26" cy="22" r="1.6" fill="' . col('water3') . '"/>';
        case 'drill': return '<rect x="12" y="22" width="40" height="18" rx="5" fill="' . $m . '"/><path d="M20 40v14M44 40v14" stroke="' . $s . '" stroke-width="4" stroke-linecap="round"/><circle cx="32" cy="31" r="5" fill="' . $s . '"/><path d="M52 28l8-6" stroke="' . $wd . '" stroke-width="4" stroke-linecap="round"/>';
        default: return '<rect x="26" y="8" width="12" height="40" rx="4" fill="' . $m . '"/><path d="M32 48v10" stroke="' . $s . '" stroke-width="3" stroke-linecap="round"/><path d="M26 18h12M26 26h12M26 34h12" stroke="' . $s . '" stroke-width="2"/>';
    }
}
function crack(): string { return '<path d="M30 14l5 10-6 6 7 9-4 8" fill="none" stroke="' . col('ink') . '" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round"/><path d="M44 46l5 4M12 40l-4 2" stroke="' . col('ink') . '" stroke-width="2" stroke-linecap="round"/>'; }

// ---------- crafting parts ----------
function draw_part(string $slug, string $m, string $s): string
{
    $t = $slug;
    if (hasany($t, ['plank', 'timber', 'birch-log'])) return '<rect x="6" y="20" width="52" height="12" rx="3" fill="' . col('soil5') . '"/><rect x="10" y="34" width="48" height="12" rx="3" fill="' . col('soil7') . '"/><path d="M14 26h14M36 25h12M16 40h18" stroke="' . col('soil9') . '" stroke-width="2" stroke-linecap="round" opacity=".5"/>' . hi('M8 22h30');
    if (hasany($t, ['rope', 'thread', 'silk-thread', 'string'])) return '<ellipse cx="32" cy="34" rx="20" ry="16" fill="none" stroke="' . col('soil3') . '" stroke-width="9"/><ellipse cx="32" cy="34" rx="20" ry="16" fill="none" stroke="' . col('soil5') . '" stroke-width="2" stroke-dasharray="4 4"/><path d="M50 40q8 6 4 14" fill="none" stroke="' . col('soil3') . '" stroke-width="5" stroke-linecap="round"/>';
    if (hasany($t, ['pelt', 'hide', 'fur', 'skin', 'velvet', 'hair', 'tuft', 'fluff'])) return '<path d="M12 14q10 4 20 0t20 0l6 12-8 8 6 12-10 6q-8-4-14 0t-14 0L10 46l6-12-8-8z" fill="' . $m . '"/><path d="M20 24q4 4 0 8M34 28q4 4 0 8M26 40q4 3 8 0" fill="none" stroke="' . $s . '" stroke-width="2.4" stroke-linecap="round"/>' . hi('M14 20q6 3 12 0');
    if (hasany($t, ['scale', 'scute', 'plate', 'shell', 'chitin', 'carapace'])) return '<path d="M32 8l22 12-4 26-18 10-18-10-4-26z" fill="' . $m . '"/><path d="M32 14l14 8-3 18-11 7-11-7-3-18z" fill="' . $s . '" opacity=".6"/><path d="M32 8v44" stroke="' . $s . '" stroke-width="2"/>' . hi('M18 20l10-6');
    if (hasany($t, ['crystal', 'gem', 'jade', 'pearl', 'bead', 'jewel', 'bauble', 'trinket', 'eye', 'glow', 'wisp', 'spark', 'stone'])) {
        if (has($t, 'building-stone')) return '<rect x="8" y="30" width="22" height="14" rx="2" fill="' . col('stone5') . '"/><rect x="32" y="30" width="24" height="14" rx="2" fill="' . col('stone3') . '"/><rect x="18" y="14" width="26" height="14" rx="2" fill="' . col('stone7') . '"/>' . hi('M10 32h14');
        if (hasany($t, ['pearl', 'bead'])) return '<circle cx="32" cy="34" r="16" fill="' . col('cream') . '"/><circle cx="32" cy="34" r="16" fill="' . $m . '" opacity=".25"/>' . hi('M22 28q2-8 10-9');
        return '<path d="M32 6L52 24 32 58 12 24z" fill="' . $m . '"/><path d="M12 24h40M32 6l-8 18 8 34 8-34z" fill="none" stroke="' . $s . '" stroke-width="2" stroke-linejoin="round"/>' . hi('M18 22l8-10');
    }
    if (hasany($t, ['cloth', 'silk', 'cocoon', 'web', 'paper', 'comb'])) return '<path d="M10 16h44v34l-8-5-7 6-7-6-7 6-8-6-7 5z" fill="' . ((hasany($t, ['silk', 'cocoon', 'web'])) ? col('cream') : $m) . '"/><path d="M18 24h28M18 32h28M18 40h20" stroke="' . col('stone3') . '" stroke-width="2" stroke-linecap="round"/>' . hi('M12 18h30');
    if (hasany($t, ['wax', 'candle', 'slime', 'honey', 'sap', 'rubber', 'glaze', 'pellet', 'dung', 'sac'])) return '<path d="M32 8Q14 32 14 42a18 16 0 0 0 36 0Q50 32 32 8z" fill="' . $m . '"/>' . hi('M24 38q0 8 6 10') . '<ellipse cx="32" cy="46" rx="10" ry="3" fill="' . $s . '" opacity=".4"/>';
    if (hasany($t, ['bone', 'fang', 'tooth', 'claw', 'talon', 'stinger', 'spine', 'pincer', 'antler', 'horn'])) return '<path d="M16 54Q10 30 30 8q8 14 6 30-2 14-20 16z" fill="' . col('soil3') . '"/><path d="M30 8q8 14 6 30-2 14-20 16 8-8 10-20 2-12-4-24z" fill="' . col('soil5') . '" opacity=".55"/><path d="M19 48q-3-10 4-24" fill="none" stroke="' . col('soil1') . '" stroke-width="3" stroke-linecap="round"/>' . hi('M24 20q-4 12-4 24');
    if (hasany($t, ['feather', 'plume'])) return draw_forage('feather', $m, $s);
    if (hasany($t, ['salt', 'dust', 'sand'])) return '<path d="M8 52Q10 30 32 24t24 28z" fill="' . col('soil1') . '"/><path d="M14 48q18-14 36 0" fill="none" stroke="' . col('stone3') . '" stroke-width="3"/><circle cx="26" cy="38" r="1.6" fill="#fff"/><circle cx="38" cy="36" r="1.6" fill="#fff"/><circle cx="32" cy="44" r="1.6" fill="#fff"/>';
    if (hasany($t, ['moss', 'root', 'weed', 'frond', 'fiddlehead', 'bladderwrack', 'cattail', 'cottongrass', 'thistle', 'leaf', 'sea-grape', 'pod', 'oak-gall'])) return draw_forage('fern', $m, $s);
    if (hasany($t, ['perch', 'sardine', 'mussel'])) return draw_forage('fish', $m, $s);
    return '<path d="M10 40q0-20 22-20t22 20-22 12-22-12z" fill="' . $m . '"/><path d="M20 38q12-10 24 0" fill="none" stroke="' . $s . '" stroke-width="3" stroke-linecap="round"/>' . hi('M16 36q4-8 12-10');
}

// ---------- decor ----------
function draw_decor(string $slug, string $m, string $s): string
{
    $t = $slug;
    $gold = col('gold5');
    if (hasany($t, ['hedge', 'topiary'])) return '<path d="M8 52V30q0-12 12-12h24q12 0 12 12v22z" fill="' . col('moss6') . '"/><circle cx="20" cy="26" r="6" fill="' . col('moss4') . '"/><circle cx="38" cy="30" r="7" fill="' . col('moss8') . '"/><circle cx="46" cy="24" r="5" fill="' . col('moss4') . '"/>' . hi('M12 28q2-6 8-8');
    if (hasany($t, ['tree', 'oak', 'birch', 'willow', 'blossom', 'topiary', 'lantern-tree'])) return '<rect x="28" y="34" width="8" height="22" rx="3" fill="' . col('soil7') . '"/><circle cx="32" cy="26" r="20" fill="' . (has($t, 'blossom') ? col('petal5') : col('moss6')) . '"/><circle cx="22" cy="30" r="9" fill="' . (has($t, 'blossom') ? col('petal3') : col('moss4')) . '"/><circle cx="42" cy="22" r="7" fill="' . (has($t, 'blossom') ? col('petal3') : col('moss8')) . '"/>' . hi('M20 20q4-8 12-9');
    if (hasany($t, ['lamp', 'lantern', 'candle', 'jar', 'glow'])) return '<rect x="29" y="30" width="6" height="26" rx="2" fill="' . col('stone7') . '"/><rect x="20" y="10" width="24" height="22" rx="5" fill="' . col('gold3') . '"/><path d="M18 12L32 4l14 8z" fill="' . col('stone7') . '"/><circle cx="32" cy="22" r="6" fill="' . $gold . '"/>' . hi('M23 16v10');
    if (hasany($t, ['pond', 'fountain', 'bath', 'cascade', 'well'])) return '<ellipse cx="32" cy="44" rx="26" ry="11" fill="' . col('stone5') . '"/><ellipse cx="32" cy="42" rx="22" ry="8" fill="' . col('water5') . '"/><path d="M32 40V16M26 24q6-10 12 0" fill="none" stroke="' . col('water3') . '" stroke-width="3" stroke-linecap="round"/>' . hi('M16 42q6-3 12-2');
    if (hasany($t, ['bench', 'seat', 'throne', 'hammock'])) return '<rect x="8" y="26" width="48" height="8" rx="3" fill="' . col('soil5') . '"/><rect x="10" y="36" width="44" height="7" rx="3" fill="' . col('soil7') . '"/><rect x="12" y="44" width="6" height="12" rx="2" fill="' . col('soil9') . '"/><rect x="46" y="44" width="6" height="12" rx="2" fill="' . col('soil9') . '"/>' . hi('M10 28h30');
    if (hasany($t, ['path', 'stepping', 'gravel'])) return '<ellipse cx="20" cy="42" rx="12" ry="8" fill="' . col('stone5') . '"/><ellipse cx="44" cy="34" rx="12" ry="8" fill="' . col('stone3') . '"/><ellipse cx="28" cy="22" rx="10" ry="7" fill="' . col('stone7') . '"/>' . hi('M12 38q4-4 10-4');
    if (hasany($t, ['fence', 'wall', 'gate', 'arch', 'arbor'])) return '<rect x="8" y="22" width="48" height="6" rx="2" fill="' . col('soil5') . '"/><rect x="8" y="38" width="48" height="6" rx="2" fill="' . col('soil5') . '"/><path d="M14 16v40M32 16v40M50 16v40" stroke="' . col('soil7') . '" stroke-width="7" stroke-linecap="round"/>' . hi('M12 18v18');
    if (hasany($t, ['bunting', 'chime', 'harp'])) return '<path d="M6 14Q32 30 58 14" fill="none" stroke="' . col('soil7') . '" stroke-width="2.4"/><path d="M14 20l5 12 5-10zM27 25l5 12 5-12zM42 22l5 12 5-14z" fill="' . $m . '"/><path d="M27 25l5 12 5-12z" fill="' . col('gold5') . '"/>';
    if (hasany($t, ['sundial', 'statue', 'ball', 'gazing', 'meteorite', 'scarecrow', 'rock'])) return '<path d="M16 54l4-14h24l4 14z" fill="' . col('stone5') . '"/><circle cx="32" cy="28" r="14" fill="' . ((has($t, 'gazing')) ? col('water5') : col('stone3')) . '"/>' . hi('M24 22q2-6 8-7');
    if (hasany($t, ['house', 'box', 'bandstand', 'shrine', 'butterfly'])) return '<rect x="14" y="26" width="36" height="28" rx="4" fill="' . col('soil5') . '"/><path d="M8 28L32 8l24 20z" fill="' . $m . '"/><circle cx="32" cy="40" r="7" fill="' . col('soil9') . '"/>' . hi('M12 30l16-14');
    if (hasany($t, ['pot', 'planter', 'border', 'ring', 'toadstool', 'garden'])) return '<path d="M16 30h32l-4 24H20z" fill="' . col('ember4') . '"/><rect x="14" y="26" width="36" height="8" rx="3" fill="' . col('ember5') . '"/><path d="M32 26V14M32 20q-8-2-8-10 8 0 8 10zM32 18q8-2 8-10-8 0-8 10z" fill="' . col('moss6') . '"/>' . hi('M20 36l2 12');
    return '<path d="M10 52Q12 20 32 14t22 38z" fill="' . $m . '"/><circle cx="32" cy="30" r="8" fill="' . $s . '"/>' . hi('M16 40q4-12 14-16');
}

// ---------- guide, sapling, supply ----------
function draw_guide(string $slug): string
{
    $c = pick(['moss6', 'water5', 'dusk5', 'ember5', 'gold7', 'petal5'], $slug);
    return '<path d="M14 8h34a4 4 0 0 1 4 4v40a4 4 0 0 1-4 4H14z" fill="' . col($c) . '"/><rect x="10" y="8" width="6" height="48" rx="2" fill="' . col('soil9') . '" opacity=".35"/><rect x="22" y="16" width="24" height="14" rx="3" fill="' . col('cream') . '"/><path d="M26 22h16M26 26h10" stroke="' . col('soil5') . '" stroke-width="2" stroke-linecap="round"/><path d="M40 44l3 4 4 1-3 3 .5 4-4.5-2-4 2 1-4-3-3 4-.5z" fill="' . col('gold3') . '"/>' . hi('M18 10h20');
}
function draw_sapling(string $slug, string $m): string
{
    return '<path d="M16 38h32l-5 18H21z" fill="' . col('ember4') . '"/><rect x="14" y="34" width="36" height="7" rx="3" fill="' . col('ember5') . '"/><rect x="30" y="18" width="4" height="18" rx="2" fill="' . col('soil7') . '"/><circle cx="32" cy="14" r="10" fill="' . col('moss6') . '"/><circle cx="26" cy="19" r="6" fill="' . col('moss4') . '"/><circle cx="38" cy="10" r="3.4" fill="' . $m . '"/>' . hi('M24 10q3-4 8-4');
}
function draw_supply(string $slug): string
{
    if (has($slug, 'cardboard')) return '<path d="M10 22l22-8 22 8v26l-22 8-22-8z" fill="' . col('soil3') . '"/><path d="M10 22l22 8 22-8M32 30v26" fill="none" stroke="' . col('soil5') . '" stroke-width="2.4"/><rect x="26" y="20" width="12" height="6" fill="' . col('soil1') . '" opacity=".7" transform="rotate(12 32 23)"/>' . hi('M14 24l14-5');
    return '<path d="M16 24Q8 54 32 56t16-32z" fill="' . col('moss6') . '"/><path d="M22 24h20" stroke="' . col('soil5') . '" stroke-width="4" stroke-linecap="round"/><circle cx="26" cy="40" r="4" fill="' . col('ember5') . '"/><circle cx="38" cy="44" r="4" fill="' . col('gold5') . '"/><path d="M30 34q8 2 6 10" fill="none" stroke="' . col('soil9') . '" stroke-width="2.4" stroke-linecap="round"/>' . hi('M18 30q-2 8 2 14');
}

// ---------- main ----------
$out = $G . '/assets/img/ph';
@mkdir($out, 0775, true);
$counts = [];
$rows = q('SELECT i.*, (SELECT kind FROM plants p WHERE p.produce_item_id = i.id OR p.seed_item_id = i.id OR p.sapling_item_id = i.id LIMIT 1) AS pkind FROM items i ORDER BY i.category, i.slug')->fetchAll();
foreach ($rows as $i) {
    $slug = (string)$i['slug'];
    if (!preg_match('/^[a-z0-9][a-z0-9_-]*$/', $slug)) continue;
    if (flower_icon($i) !== '' || item_pic($i, 'md', '', false) !== '') continue;   // flower SVGs and real art keep their own
    $cat = (string)$i['category'];
    $kind = $i['pkind'] ?: null;
    $fx = json_decode((string)($i['effects'] ?? ''), true) ?: [];
    $base = preg_replace('/-seed$/', '', $slug);
    [$m, $s] = colours($base);
    switch ($cat) {
        case 'seed':    $b = draw_seed($slug, $kind, $m, $s); break;
        case 'produce': $b = draw_crop(crop_shape($slug, $kind), $slug, $m, $s); break;
        case 'food':    $b = draw_food($slug, $m, $s); break;
        case 'forage':  $b = draw_forage($slug, $m, $s); break;
        case 'soil': case 'mulch': $b = draw_soil($slug, $cat); break;
        case 'tool': case 'broken':
            $core = preg_replace('/^broken-/', '', $slug);
            $tier = (int)($fx['tier'] ?? 0) ?: (str_contains($core, 'masterwork') ? 4 : (str_contains($core, 'fine') ? 3 : (hasany($core, ['steel', 'tin', 'sturdy', 'iron']) ? 2 : 1)));
            $tc = TIER_COL[max(1, min(4, $tier))];
            $b = draw_tool(tool_kind($core), col($tc[0]), col($tc[1]), $core);
            if ($cat === 'broken') $b = '<g opacity=".72">' . $b . '</g>' . crack();
            break;
        case 'part':    $b = draw_part($slug, $m, $s); break;
        case 'decor':   $b = draw_decor($slug, $m, $s); break;
        case 'guide':   $b = draw_guide($slug); break;
        case 'sapling': $b = draw_sapling($slug, $m); break;
        case 'supply':  $b = draw_supply($slug); break;
        default:        $b = draw_supply($slug);
    }
    $x = svg($b, $slug);
    file_put_contents($out . '/' . $slug . '.svg', $x);
    $counts[$cat] = ($counts[$cat] ?? 0) + 1;
    if (strlen($x) > 3072) echo "big: $slug " . strlen($x) . "\n";
}
ksort($counts);
echo json_encode($counts), ' total ', array_sum($counts), "\n";

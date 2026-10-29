<?php
declare(strict_types=1);
/**
 * Cat Fish (Lazy Rod), build step 1: data, cat generator, shelter, tick, upgrades. Plan: claude/plan-catfish.md.
 * Every name here starts catfish_ (cf_ for tables). Behind the setting catfish_open (admins always).
 *
 * A cat is ONE integer seed; every trait comes from a seeded RNG, so a cat is never stored beyond (user_id, seed, name).
 * The shelter shows 3 cats a day per gnome: seed = crc32(user_id|date|slot), re-derived on the server at adoption time.
 * Kibble is earned on the server clock only (catfish_tick): 100% while the page is polling, 50% when away, capped at CATFISH_OFFLINE_CAP seconds.
 */

const CATFISH_BASE_KPH = 600;           // kibble per hour with nothing bought
const CATFISH_OFFLINE_CAP = 8 * 3600;   // seconds of away time that count
const CATFISH_AWAY_AFTER = 300;         // a gap longer than this since the last tick counts as away (50%)
const CATFISH_GROWTH = 1.18;            // cost = base * growth^owned
const CATFISH_MILESTONES = [10, 25, 50];   // owned counts that double an upgrade's effect
const CATFISH_SHELTER = 3;              // cats on show per day
const CATFISH_MAX_CATS = 4;
const CATFISH_NAME_MAX = 20;
const CATFISH_SLOT_COSTS = [5, 20];     // Yarn for the 3rd and 4th place in the home
const CATFISH_AWAY_COSTS = [4, 8, 16];  // Yarn for Longer naps away levels 1 to 3: each adds one hour to the away cap
const CATFISH_BULK_COST = 3;            // Yarn to unlock Buy x10 on upgrades (one-off)
/** Titles Yarn can buy (one-off), offered in the Almanac title picker: key => [title, Yarn]. */
const CATFISH_TITLES = ['catperson' => ['Cat Person', 15], 'napmaster' => ['Napmaster', 30]];
const CATFISH_HOLD_COST = 2;            // Yarn to hold one of today's shelter cats for tomorrow (one hold a day)
const CATFISH_STAKE_COST = 3;           // Yarn to stake out a pattern or colour for tomorrow's shelter (one a day)
const CATFISH_STAKE_TRIES = 8;          // extra look-alike candidates a stakeout draws per spot
const CATFISH_SHOW2_COST = 5;           // Yarn to unlock a second Cat Show entry (the better result of the two counts)
const CATFISH_BUDDY_COST = 12;          // Yarn to unlock a Buddy cat
const CATFISH_BUDDY_PCT = 0.10;         // Kibble bonus while a Buddy (an owned cat other than the playing one) keeps the main cat company
const CATFISH_KEEP_COSTS = [10, 20, 40];   // Keepsake levels: a Nap keeps this many levels of the first upgrade in each branch
const CATFISH_KEEP_UPS = ['fish', 'string', 'sunbeam', 'bowl'];
const CATFISH_BALL_COST = 1;            // Yarn per ball colour (one-off). key => [label, CSS filter id used by catfish.css as .cfball-<key>]
const CATFISH_BALLS = ['rose' => 'Rose', 'mint' => 'Mint', 'violet' => 'Violet', 'gold' => 'Gold'];
const CATFISH_BUNTING_COST = 1;         // Yarn per bunting hung in the festival jar while a festival runs
const CATFISH_BUNTING_ADD = 3;          // jar points per bunting
const CATFISH_BUNTING_DAILY = 3;        // buntings per gnome per Hollow day
const CATFISH_SCARF_COST = 12;          // Yarn for the scarf the gnome wears (drawn in gnome_avatar); colours are then free
const CATFISH_SCARVES = ['red' => ['Poppy red', '#c0392b'], 'green' => ['Moss green', '#2e7d4f'], 'blue' => ['Bluebell', '#2f5d9e'], 'gold' => ['Buttercup', '#e0a526'], 'cream' => ['Wool cream', '#f1e6c8']];
const CATFISH_RARE_COSTS = [3, 10];     // Yarn for Rare Shelter levels 1 and 2 (the shelter shows the best of 2, then 3, candidates per slot)
const CATFISH_REROLL_COST = 1;          // Yarn to swap one shelter cat for another
const CATFISH_REROLL_MAX = 3;           // rerolls per slot per day
/** Active play (tap a dangling fish): one accepted tap pays max(1, floor(present kph * PLAY_SECS / 3600 * tier)) Kibble. Tiers are by Hollow day: taps 1..120 x1, 121..240 x0.5, 241..360 x0.25, then 0.
 *  Server token bucket (no jitter): PLAY_CAP tokens, one more every PLAY_REFILL seconds; a batch holds 0..PLAY_BATCH taps (more = refused whole). State lives in catfish_state.meta: pb pt pd pc pq pe. */
const CATFISH_PLAY_SECS = 5;
const CATFISH_PLAY_TIERS = [[120, 1.0], [240, 0.5], [360, 0.25]];   // [last tap number of the tier, multiplier]
const CATFISH_PLAY_CAP = 15;
const CATFISH_PLAY_REFILL = 2;
const CATFISH_PLAY_BATCH = 40;
const CATFISH_PLAY_UP = [];             // hook for later upgrades that change play (none in 2.1.04)
/** Petal milestones: key => [label, base Petals (then scaled by game_petals())]. Each pays once, inside the weekly cap (setting catfish_petal_cap). */
const CATFISH_MILESTONES_PETALS = [
    'adopt1'    => ['Brought your first cat home', 20],
    'nap1'      => ['Took your first Nap', 40],
    'book12'    => ['12 coats in the Cat Book', 30],
    'nap5'      => ['Took five Naps', 80],
    'full4'     => ['Four cats at home', 60],
    'book_half' => ['Half the Cat Book', 100],
];

/** Branch key => label, in display order. */
const CATFISH_BRANCHES = ['fish' => '🐟 Fish', 'rod' => '🎣 Rod', 'room' => '🛋️ Room', 'cat' => '🐾 Cat'];
/** key => [name, icon, base cost, Kibble/hour added per level, share of the total added per level (0.05 = +5%), branch] */
const CATFISH_UPGRADES = [
    'fish'    => ['Plushie fish',   '🐟', 10,     48,   0.0,  'fish'],
    'silk'    => ['Silk tail',      '🎀', 150,    220,   0.0,  'fish'],
    'catnip'  => ['Catnip stuffing', '🌿', 2200,  1040,  0.0,  'fish'],
    'glitter' => ['Glitter scales', '✨', 30000,  4800, 0.0,  'fish'],
    'string'  => ['Longer string',  '🧵', 80,     160,   0.0,  'rod'],
    'spring'  => ['Springy rod',    '🪀', 600,    600,  0.0,  'rod'],
    'motor'   => ['Rod motor',      '⚙️', 4000,   2400,  0.0,  'rod'],
    'double'  => ['Double rod',     '🎣', 60000,  11200, 0.0,  'rod'],
    'sunbeam' => ['Sunbeam',        '☀️', 300,    0,    0.01, 'room'],
    'rug'     => ['Cosy rug',       '🧶', 2500,   0,    0.015, 'room'],
    'scratch' => ['Scratch post',   '🪵', 15000,  0,    0.02, 'room'],
    'window'  => ['Window bird',    '🐦', 90000,  0,    0.03, 'room'],
    'bowl'    => ['Fancy bowl',     '🥣', 1200,   0,    0.012, 'cat'],
    'toybox'  => ['Toy box',        '🧸', 9000,   0,    0.018, 'cat'],
    'cattree' => ['Cat tree',       '🌳', 55000,  0,    0.024, 'cat'],
    'catflap' => ['Cat flap',       '🚪', 320000, 0,    0.036, 'cat'],
];
const CATFISH_YARN_STEP = 0.10;        // Kibble multiplier = 1 + STEP * Yarn^POW
const CATFISH_YARN_POW = 0.6;          // below 1 so a huge pile of Yarn keeps paying, but ever more slowly
const CATFISH_NAP_ROOT = 3.0;          // Yarn from a Nap = floor((run / base)^(1/ROOT))
const CATFISH_MAX_KPH = 1.0e12;        // hard ceiling on Kibble/hour, so the sums can never reach the BIGINT edge
const CATFISH_MAX_COST = 1.0e15;
const CATFISH_NAP_BASE = 500;          // a Nap needs this much Kibble earned in the run
const CATFISH_RARE_PER_HOUR = 0.5;     // Sneaky cats: expected rare fish per hour, each worth a tenth of an hour's Kibble

/** trait => [value => weight]. Rarer value = smaller weight. */
const CATFISH_TRAITS = [
    'pattern' => ['solid' => 30, 'tabby' => 28, 'tuxedo' => 18, 'calico' => 12, 'pointed' => 8, 'spotted' => 4],
    'colour'  => ['ginger' => 22, 'black' => 20, 'grey' => 20, 'cream' => 14, 'white' => 12, 'brown' => 8, 'lilac' => 3, 'silver' => 1],
    'eyes'    => ['amber' => 30, 'green' => 30, 'blue' => 20, 'hazel' => 18, 'odd' => 2],
    'ears'    => ['upright' => 85, 'folded' => 15],
    'tail'    => ['long' => 85, 'bobtail' => 15],
    'mood'    => ['lazy' => 20, 'hyper' => 20, 'sneaky' => 20, 'greedy' => 20, 'dreamy' => 20],
];
const CATFISH_QUIRKS = ['sleeps in a box', 'hates cucumbers', 'chirps at birds', 'knocks things off shelves', 'loves a sunbeam', 'steals one sock'];
const CATFISH_QUIRK_CHANCE = 6;   // 1 in 6 cats has one
const CATFISH_NAMES = ['Biscuit', 'Pickle', 'Mochi', 'Nutmeg', 'Clover', 'Pebble', 'Maple', 'Tansy', 'Fennel', 'Sorrel', 'Thimble', 'Bramble', 'Juniper', 'Poppy', 'Marmalade', 'Whisk', 'Truffle', 'Cricket', 'Dumpling', 'Sprout'];
/** Rarity bands on the summed -log2(probability) of a cat's traits (tuned by tests/catfish.sh's distribution check). */
const CATFISH_RARITY = ['common' => 0.0, 'uncommon' => 10.8, 'rare' => 12.6, 'legendary' => 16.3];   // about 50 / 30 / 18.5 / 1.5 percent of cats

/** URL of one art file (cf-*.png) under the art folder, with the cache-busting version. */
function catfish_art_url(string $file): string
{
    $base = defined('CATFISH_ART_URL') ? CATFISH_ART_URL : 'assets/img/catfish';
    return url($base . '/' . $file . '?v=' . APP_VERSION);
}

/** A Cat Fish picture: the real PNG (assets/img/catfish/cf-<name>.png) when it exists, else the emoji placeholder. See claude/catfish-art-brief.md for the names. $h = 0 means square. */
function catfish_img(string $name, string $fallback, string $alt = '', int $px = 48, int $h = 0): string
{
    if (!preg_match('/^[a-z0-9_-]+$/', $name) || !catfish_art_has('cf-' . $name . '.png')) return '<span aria-hidden="true">' . $fallback . '</span>';
    return '<img class="cfimg" src="' . e(catfish_art_url('cf-' . $name . '.png')) . '" alt="' . e($alt) . '" width="' . $px . '" height="' . ($h > 0 ? $h : $px) . '">';
}

/** A small decorative icon (cf-ico-kibble, cf-ico-yarn) followed by a space, or '' while there is no art, so the page is unchanged. */
function catfish_ico(string $name, int $px = 32): string
{
    return catfish_art_has('cf-' . $name . '.png') ? catfish_img($name, '', '', $px) . ' ' : '';
}

/** Fish kinds hanging on the rod (cf-fish-1..5: plain, silk, catnip, glitter, golden for a Sneaky cat's rare fish), for the owned upgrade levels. Up to 3, the newest kinds. */
function catfish_fish_kinds(array $owned, ?array $cat = null): array
{
    $k = [1];
    foreach ([2 => 'silk', 3 => 'catnip', 4 => 'glitter'] as $n => $key) if ((int)($owned[$key] ?? 0) > 0) $k[] = $n;
    if (($cat['mood'] ?? '') === 'sneaky') $k[] = 5;
    $k = array_slice($k, -3);
    $out = [];
    for ($i = 0; $i < 3; $i++) $out[] = $k[$i % count($k)];
    return $out;
}

/**
 * The swaying rod. No rod and no fish art: today's emoji markup, byte for byte. Otherwise the wand art (cf-rod, 48 x 64) and a plushie fish on a string
 * (the string is a CSS line) for each kind from catfish_fish_kinds(); a piece with no PNG keeps its emoji. $owned = upgrade key => level.
 */
function catfish_rod_html(array $owned, ?array $cat = null): string
{
    $kinds = catfish_fish_kinds($owned, $cat);
    $any = catfish_art_has('cf-rod.png');
    foreach ($kinds as $n) $any = $any || catfish_art_has("cf-fish-$n.png");
    if (!$any) return '<div class="cfrod" aria-hidden="true"><span class="cfwand">🎣</span><span class="cffish f1">🐟</span><span class="cffish f2">🐠</span><span class="cffish f3">🐡</span></div>';
    $h = '<div class="cfrod cfrod-art" aria-hidden="true"><span class="cfwand">' . catfish_img('rod', '🎣', '', 48, 64) . '</span>';
    foreach ($kinds as $i => $n) $h .= '<span class="cfdrop d' . ($i + 1) . '"><i class="cfstr"></i>' . catfish_img("fish-$n", ['🐟', '🐠', '🐡'][$i], '', 48) . '</span>';
    return $h . '</div>';
}

/** Room upgrades that have an overlay, in stacking order (back to front). */
const CATFISH_ROOM_LAYERS = ['window', 'sunbeam', 'rug', 'catflap', 'cattree', 'scratch', 'toybox', 'bowl'];
/** 2.1.08 Rod upgrades that show on the stage: upgrade key => class on .cfstage (string: longer strings, spring: the fish bob, motor: the wand turns, double: a second wand). */
const CATFISH_ROD_CLASSES = ['string' => 'cfrs', 'spring' => 'cfrsp', 'motor' => 'cfrmo', 'double' => 'cfrdb'];

/** The stage classes (with a leading space, '' with none) for the owned Rod upgrades. */
function catfish_rod_classes(array $owned): string
{
    $h = '';
    foreach (CATFISH_ROD_CLASSES as $key => $cls) if ((int)($owned[$key] ?? 0) > 0) $h .= ' ' . $cls;
    return $h;
}

/**
 * The room: cf-room (320 x 200) with an overlay for each owned Room upgrade, and the home's cats (up to 4, 64 x 64) standing on the floor band.
 * '' while there is no cf-room.png (the page then shows no room, as before). Positions are CSS classes (cfrc n<count> i<index>), no inline style.
 */
function catfish_room_html(array $cats, array $owned): string
{
    if (!catfish_art_has('cf-room.png')) return '';
    $h = '<div class="cfroomwrap"><div class="cfroom" role="img" aria-label="Your home' . ($cats ? ' with ' . count($cats) . (count($cats) === 1 ? ' cat' : ' cats') : '') . '">' . catfish_room_base_html($owned);
    $cats = array_slice(array_values($cats), 0, CATFISH_MAX_CATS); $n = count($cats);
    foreach ($cats as $i => $c) $h .= '<span class="cfrc n' . $n . ' i' . ($i + 1) . '">' . catfish_cat_html($c, 64, 'idleA', false) . '</span>';
    return $h . '</div></div>';
}

/** The room base (cf-room) and the overlay of each owned Room upgrade, back to front. Shared by catfish_room_html and catfish_stage_html. */
function catfish_room_base_html(array $owned): string
{
    $h = '<img class="cfroom-bg" src="' . e(catfish_art_url('cf-room.png')) . '" alt="" width="320" height="200">';
    foreach (CATFISH_ROOM_LAYERS as $key) {
        if ((int)($owned[$key] ?? 0) > 0 && catfish_art_has("cf-room-$key.png")) $h .= '<img class="cfroom-layer cfl-' . $key . '" src="' . e(catfish_art_url("cf-room-$key.png")) . '" alt="" width="320" height="200">';
    }
    return $h;
}

/**
 * 2.1.06 room extras of the play scene, drawn right after the room base (under every cat): the window bird (cf-bird-1..3, 12 x 10 shown at 2x on the perch of
 * room-layout.json "bird"; catfish.js swaps the window overlay's robin for it, so without JS or with reduced motion the static cf-room-window.png stays) and the yarn ball roll
 * (the patch cf-room-yarnpatch.png, 38 x 20, clears the ball at room-layout.json "yarn"; the rolling cf-yarn-1..4, 16 x 16, are shown only while it rolls). Hidden by CSS until catfish.js starts them.
 */
function catfish_room_extras_html(array $owned): string
{
    $h = '';
    if ((int)($owned['window'] ?? 0) > 0 && catfish_art_has('cf-room-window.png') && catfish_art_has('cf-room-window-nobird.png') && catfish_art_has('cf-bird-1.png') && catfish_art_has('cf-bird-2.png') && catfish_art_has('cf-bird-3.png')) {
        $h .= '<span class="cfbird f1" aria-hidden="true">' . implode('', array_map(fn($n) => '<img class="b' . $n . '" src="' . e(catfish_art_url("cf-bird-$n.png")) . '" alt="" width="24" height="20">', [1, 2, 3])) . '</span>';
    }
    if (catfish_art_has('cf-room-yarnpatch.png') && catfish_art_has('cf-yarn-1.png') && catfish_art_has('cf-yarn-2.png') && catfish_art_has('cf-yarn-3.png') && catfish_art_has('cf-yarn-4.png')) {
        $h .= '<span class="cfyarn" aria-hidden="true"><img class="yp" src="' . e(catfish_art_url('cf-room-yarnpatch.png')) . '" alt="" width="38" height="20"><span class="yb">'
            . implode('', array_map(fn($n) => '<img class="y' . $n . '" src="' . e(catfish_art_url("cf-yarn-$n.png")) . '" alt="" width="16" height="16">', [1, 2, 3, 4])) . '</span></span>';
    }
    return $h;
}

/** 2.1.06 code-only ambience over the scene: six dust motes drifting in the sunbeam (only with the owned Room upgrade 'sunbeam'; CSS steps animation, none under reduced motion). */
function catfish_ambience_html(array $owned): string
{
    if ((int)($owned['sunbeam'] ?? 0) < 1 || !catfish_art_has('cf-room-sunbeam.png')) return '';
    return '<span class="cfdust" aria-hidden="true"><i class="m1"></i><i class="m2"></i><i class="m3"></i><i class="m4"></i><i class="m5"></i><i class="m6"></i></span>';
}

/**
 * Side spots of the play scene: [frame, x, y] in room pixels (top left of the 64 x 64 cat), from aseprite-source/catfish/room-layout.json "cats"
 * (role side). The active cat stands at CATFISH_STAGE_ACTIVE (role active). catfish.css has one .cfpos-x<X>-y<Y> class per spot (tests/catfish.sh checks both against the JSON).
 */
const CATFISH_STAGE_SPOTS = [['nap', 0, 124], ['idleA', 40, 98], ['bored', 236, 116]];
const CATFISH_STAGE_ACTIVE = [128, 120];
/** Frames a side cat carries by its spot frame (others are one still frame): the awake one alternates idleA and idleB and can stalk. */
const CATFISH_SIDE_FRAMES = ['idleA' => ['idleA', 'idleB', 'stalk']];

/**
 * The play scene: one 320 x 200 stage with the room (base and owned overlays), the wand hung at the ceiling hook, a line to three dangling fish
 * (catfish_fish_kinds), the other cats (up to 3) as still frames at the side spots, and the active cat in the centre with all 8 frame groups
 * (body, pattern, ears, tail and eyes layers each; catfish.js shows one at a time by class fr-<frame> and data-frame). Everything is positioned by
 * CSS classes (no inline style). Each fish is a button (tap = play, see catfish_play); the stage is a group, not an image, because buttons cannot sit in role=img. $hint shows the first-visit bubble. '' while there is no cf-room.png: the page then keeps the old rod box and cat card. $napping starts the active cat asleep.
 */
function catfish_stage_html(array $cats, array $active, array $owned, bool $napping = false, bool $hint = false): string
{
    if (!catfish_art_has('cf-room.png')) return '';
    $h = '<div class="cfstagewrap"><div class="cfstage' . catfish_rod_classes($owned) . '" role="group" aria-label="' . e($active['name'] ?? 'Your cat') . ' plays under the toy rod at home' . (count($cats) > 1 ? ', with ' . (count($cats) - 1) . ' other ' . (count($cats) === 2 ? 'cat' : 'cats') : '') . '" data-play-pending="0" data-combo="0">' . catfish_room_base_html($owned);
    $h .= catfish_room_extras_html($owned);
    $h .= '<span class="cfswand">' . catfish_img('rod', '🎣', '', 48, 64) . '</span><i class="cfsline"></i>';
    if ((int)($owned['double'] ?? 0) > 0) $h .= '<span class="cfswand cfswand2" aria-hidden="true">' . catfish_img('rod', '🎣', '', 48, 64) . '</span>';   // 2.1.08 Double rod: a second wand at the right end of the line
    foreach (catfish_fish_kinds($owned, $active) as $i => $n) $h .= '<button type="button" class="cfsdrop sd' . ($i + 1) . ' cfk-' . (int)$n . '" data-fish="' . ($i + 1) . '" aria-label="Bat the plush fish (' . ($i + 1) . ' of 3)"><i class="cfstr"></i>' . catfish_img("fish-$n", ['🐟', '🐠', '🐡'][$i], '', 48) . '</button>';
    $others = [];
    foreach ($cats as $c) if (($c['id'] ?? null) !== ($active['id'] ?? null)) $others[] = $c;
    usort($others, fn($a, $b) => (($b['mood'] ?? '') === 'lazy') <=> (($a['mood'] ?? '') === 'lazy'));   // a lazy cat takes the cushion (stable order otherwise)
    $spots = [];
    $zimg = catfish_art_has('cf-z.png') ? '<img class="cfz cfz-s" src="' . e(catfish_art_url('cf-z.png')) . '" alt="" width="8" height="8">' : '';
    foreach (array_slice($others, 0, count(CATFISH_STAGE_SPOTS)) as $i => $c) {
        [$f, $x, $y] = CATFISH_STAGE_SPOTS[$i];
        $sf = CATFISH_SIDE_FRAMES[$f] ?? null;
        if ($sf !== null) {   // an awake side cat: idleA, idleB and stalk, catfish.js alternates them and lets it stalk when the active cat pounces
            $g = '';
            foreach ($sf as $fr) {
                $gh = catfish_cat_html($c, 64, $fr, false);
                if (str_contains($gh, 'class="cfcat ')) { $g = ''; break; }
                $g .= '<span class="cfframe ff-' . $fr . '" data-f="' . $fr . '">' . $gh . '</span>';
            }
            if ($g !== '') { $spots[] = [$y, '<span class="cfspot cfside cfpos-x' . $x . '-y' . $y . ' fr-' . $f . '" data-frame="' . $f . '" data-seed="' . (int)($c['seed'] ?? 0) . '">' . $g . '</span>']; continue; }
        }
        $spots[] = [$y, '<span class="cfspot cfpos-x' . $x . '-y' . $y . '">' . catfish_cat_html($c, 64, $f, false) . ($f === 'nap' ? $zimg : '') . '</span>'];
    }
    [$ax, $ay] = CATFISH_STAGE_ACTIVE;
    $start = $napping ? 'nap' : 'idleA';
    $groups = '';
    foreach (CATFISH_FRAMES as $f) {
        $g = catfish_cat_html($active, 64, $f, false);
        if (str_contains($g, 'class="cfcat ')) { if ($f === 'idleA') $groups .= '<span class="cfframe ff-idleA" data-f="idleA">' . $g . '</span>'; continue; }   // no art for this coat or frame
        $groups .= '<span class="cfframe ff-' . $f . '" data-f="' . $f . '">' . $g . '</span>';
    }
    $spots[] = [$ay, '<span class="cfactive cfpos-x' . $ax . '-y' . $ay . ' fr-' . $start . '" data-frame="' . $start . '" data-seed="' . (int)($active['seed'] ?? 0) . '"' . ($napping ? ' data-nap="1"' : '') . '>' . $groups . '</span>'];
    usort($spots, fn($a, $b) => $a[0] <=> $b[0]);   // lower on the floor is drawn in front
    foreach ($spots as $sp) $h .= $sp[1];
    if ($zimg !== '') $h .= str_replace('cfz-s', 'cfz-a' . ($napping ? ' is-on' : ''), $zimg);   // the active cat's z: catfish.js shows it while the cat naps
    $man = catfish_frame_manifest($active);
    if ($man['frames']) $h .= '<script type="application/json" id="cf-frames">' . json_encode($man, JSON_UNESCAPED_SLASHES | JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) . '</script>';
    if (catfish_art_has('cf-sparkle-1.png')) $h .= '<span class="cfspark" aria-hidden="true">' . implode('', array_map(fn($n) => '<img class="sp' . $n . '" src="' . e(catfish_art_url("cf-sparkle-$n.png")) . '" alt="" width="8" height="8">', [1, 2, 3])) . '</span>';
    $h .= catfish_ambience_html($owned);
    $h .= '<span class="cfpop p1" aria-hidden="true"></span><span class="cfpop p2" aria-hidden="true"></span><span class="cfpop p3" aria-hidden="true"></span><span id="cf-combo" class="cfcombo" aria-hidden="true"></span>';
    if ($hint) $h .= '<span class="cfhint" id="cf-hint" aria-hidden="true">Tap a fish to play!</span>';
    return $h . '<span id="cf-playlive" class="cfsr" aria-live="polite"></span></div></div>';
}

/**
 * 2.1.07 live scene: a short key of everything the stage draws that an upgrade or a cat change can alter (room overlays, extras, ambience, the fish kinds,
 * which cat is active, which cats are at home). The page carries it in the JSON block and sends it back with a tick or a buy; the API answers with the new
 * stage markup only when the key differs, so catfish.js swaps the scene in place without a reload.
 */
function catfish_scene_key(array $cats, ?array $active, array $owned): string
{
    return substr(md5(catfish_room_base_html($owned) . '|' . catfish_room_extras_html($owned) . '|' . catfish_ambience_html($owned) . '|' . implode(',', catfish_fish_kinds($owned, $active)) . '|' . catfish_rod_classes($owned)
        . '|' . (int)($active['id'] ?? 0) . '|' . implode(',', array_map(fn($c) => (int)($c['id'] ?? 0), $cats))), 0, 12);
}

/** The stage for a view from catfish_view(): [scene key, markup]. The markup is exactly what catfish.php prints ('' with no cat or no room art). */
function catfish_scene(int $uid, array $v): array
{
    $cats = catfish_cats($uid); $cat = $v['cat'];
    if (!$cat) return ['', ''];
    $owned = array_column($v['ups'], 'owned', 'key');
    return [catfish_scene_key($cats, $cat, $owned), catfish_stage_html($cats, $cat, $owned, $v['naps'] > 0 && $v['run'] === 0, (int)$v['play']['ever'] === 0)];
}

/** One Cat Book cell. $st: 1 adopted, 0 seen, -1 not found yet. Art (cf-bookhead-<coat>, cf-bookhead-unknown, 32 x 32) when it exists, else the coloured circle. */
function catfish_book_cell(string $colour, int $st, string $label): string
{
    $coat = CATFISH_ART_COATS[$colour] ?? null;
    $file = $st < 0 ? 'cf-bookhead-unknown.png' : ($coat !== null ? "cf-bookhead-$coat.png" : '');
    if ($file === '' || !catfish_art_has($file)) {
        return '<span class="cfbcell ' . ($st >= 0 ? 'got c-' . e($colour) : 'none') . '" role="img" aria-label="' . e($label) . '" title="' . e($label) . '">' . ($st === 1 ? '🐱' : '') . '</span>';
    }
    return '<span class="cfbcell art ' . ($st < 0 ? 'none' : ($st === 1 ? 'got adopted' : 'got seen')) . '" role="img" aria-label="' . e($label) . '" title="' . e($label) . '"><img class="cfimg" src="' . e(catfish_art_url($file)) . '" alt="" width="32" height="32"></span>';
}

/**
 * Layered cat. Real art: a stack of absolutely positioned 64 x 64 PNG layers in a wrapper, no inline style (CSP). Order, bottom to top:
 * body, ears/tail replacement parts, pattern, eyes (see tools/catfish_recolor.py --compose, which draws the same stack).
 * Folded ears / bobtail replace part of the body: the body and pattern layers sit inside <span class="cfmk cfmk-ears-F"> / cfmk-tail-F groups,
 * and catfish.css erases those regions with CSS mask-image (cf-ears-mask-F.png / cf-tail-mask-F.png, alpha 255 = erase; mask-composite exclude).
 * Nothing is pre-baked, so the art folder stays at body + pattern + part + eyes files per coat. A part with no mask for the frame is not drawn.
 * Art location: constant CATFISH_ART_DIR (disk) and CATFISH_ART_URL (web path, relative to the app), default assets/img/catfish.
 * No body PNG for this coat and frame = the old emoji placeholder, byte for byte. Every file is checked once per request.
 * $size snaps to 64, 128 or 192 px (integer scales, CSS classes cf-s64 / cf-s128 / cf-s192). $eyeClass only affects the emoji fallback.
 */
const CATFISH_FRAMES = ['idleA', 'idleB', 'wiggle', 'stalk', 'pounce', 'catch', 'nap', 'bored'];
const CATFISH_ART_COATS = ['ginger' => 'orange', 'black' => 'black', 'grey' => 'grey', 'cream' => 'cream', 'white' => 'white', 'brown' => 'brown', 'silver' => 'silver-blue', 'lilac' => 'lilac'];   // game coat => art coat (tools/catfish_recolor.py COATS)
const CATFISH_PATTERN_FRAMES = ['idleA', 'idleB', 'wiggle', 'stalk', 'pounce', 'catch', 'nap', 'bored'];
const CATFISH_EYE_COLOURS = ['amber', 'green', 'blue', 'hazel'];
function catfish_art_has(string $file): bool
{
    static $have = [];
    $dir = defined('CATFISH_ART_DIR') ? CATFISH_ART_DIR : APP_ROOT . '/assets/img/catfish';
    return $have[$dir . '/' . $file] ??= is_file($dir . '/' . $file);
}
/**
 * Frames beyond the 8 inline ones (2.1.05). Full frames carry every layer under their own name. Alias frames (CATFISH_FRAME_BASE) own only some layers;
 * every other layer is the base frame's file (blink, tailflick and eartwitch are idleA with a few layers swapped). CATFISH_FRAME_OWN mirrors the "own" lists of
 * aseprite-source/catfish/frames-alias-s2.json and frames-alias-s3.json (tests/catfish.sh checks they are equal, so they cannot drift). Role names: body, pat-<pattern>,
 * ears-folded, ears-mask, tail-bobtail, tail-mask, eyes-<colour> ('eyes' alone owns all four colours).
 * CATFISH_FRAMES_LAZY are the ones the play scene animates now: catfish.js creates their layers on first need from the manifest block (catfish_frame_manifest);
 * 2.1.06 adds yawn, stretch, washA and washB (full frames, the idle variety).
 */
const CATFISH_FRAMES_EXTRA = ['swatA', 'swatB', 'blink', 'jump', 'happy', 'tailflick', 'eartwitch', 'yawn', 'stretch', 'washA', 'washB'];
const CATFISH_FRAMES_LAZY = ['swatA', 'swatB', 'blink', 'jump', 'happy', 'tailflick', 'eartwitch', 'yawn', 'stretch', 'washA', 'washB'];
const CATFISH_FRAME_BASE = ['blink' => 'idleA', 'tailflick' => 'idleA', 'eartwitch' => 'idleA'];
const CATFISH_FRAME_OWN = [
    'blink' => ['body', 'eyes'],
    'tailflick' => ['body', 'pat-tabby', 'pat-pointed', 'pat-spotted', 'tail-bobtail', 'tail-mask'],
    'eartwitch' => ['body', 'pat-tabby', 'pat-calico', 'pat-pointed', 'ears-folded', 'ears-mask'],
];
/** The frame whose file supplies layer $role of $frame (the frame itself, or the base frame of an alias that does not own the layer). */
function catfish_role_frame(string $frame, string $role): string
{
    $base = CATFISH_FRAME_BASE[$frame] ?? null;
    if ($base === null) return $frame;
    $own = CATFISH_FRAME_OWN[$frame] ?? [];
    return (in_array($role, $own, true) || (str_starts_with($role, 'eyes-') && in_array('eyes', $own, true))) ? $frame : $base;
}
/**
 * The layer list of one cat frame, bottom to top: [file, masks, clip]. masks = names of the cfmk groups that wrap the layer (ears, tail), clip = 'L-<frame>' / 'R-<frame>'
 * for an odd-eyed half. null = no art for this coat and frame (the emoji fallback). A layer with a missing file, or a part with no mask, is left out.
 */
function catfish_cat_layers(array $cat, string $frame): ?array
{
    $coat = CATFISH_ART_COATS[$cat['colour'] ?? ''] ?? null;
    if ($coat === null || !catfish_art_has("cf-cat-$coat-$frame.png")) return null;
    $parts = []; $masks = [];
    foreach ([['ears', 'folded', 'ears'], ['tail', 'bobtail', 'tail']] as [$kind, $val, $trait]) {
        if (($cat[$trait] ?? '') !== $val) continue;
        $pf = catfish_role_frame($frame, "$kind-$val"); $mf = catfish_role_frame($frame, "$kind-mask");
        if (!catfish_art_has("cf-$kind-$val-$coat-$pf.png") || !catfish_art_has("cf-$kind-mask-$mf.png")) continue;
        $parts[] = ["cf-$kind-$val-$coat-$pf.png", [], '']; $masks[] = "$kind-$mf";
    }
    $out = [["cf-cat-$coat-$frame.png", $masks, '']];
    foreach ($parts as $pt) $out[] = $pt;
    $pat = (string)($cat['pattern'] ?? 'solid');
    if ($pat !== 'solid' && preg_match('/^[a-z]+$/', $pat)) {
        $pf = catfish_role_frame($frame, "pat-$pat");
        if (catfish_art_has("cf-pat-$pat-$coat-$pf.png")) $out[] = ["cf-pat-$pat-$coat-$pf.png", $masks, ''];
    }
    $eye = (string)($cat['eyes'] ?? 'amber');
    if ($eye === 'odd') {   // left and right halves, two different colours, chosen by the seed
        $sd = (int)($cat['seed'] ?? 0); $l = CATFISH_EYE_COLOURS[$sd % 4]; $r = CATFISH_EYE_COLOURS[($sd % 4 + 1 + intdiv($sd, 4) % 3) % 4];
        foreach ([[$l, 'L'], [$r, 'R']] as [$c, $side]) {
            $ef = catfish_role_frame($frame, "eyes-$c");
            if (catfish_art_has("cf-eyes-$c-$ef.png")) $out[] = ["cf-eyes-$c-$ef.png", [], "$side-$ef"];
        }
    } elseif (in_array($eye, CATFISH_EYE_COLOURS, true)) {
        $ef = catfish_role_frame($frame, "eyes-$eye");
        if (catfish_art_has("cf-eyes-$eye-$ef.png")) $out[] = ["cf-eyes-$eye-$ef.png", [], ''];
    }
    return $out;
}
function catfish_cat_html(array $cat, int $size = 64, string $frame = 'idleA', bool $eyeClass = true): string
{
    $fallback = '<span class="cfcat c-' . e($cat['colour'] ?? '') . ' p-' . e($cat['pattern'] ?? '') . ($eyeClass ? ' e-' . e($cat['eyes'] ?? '') : '') . '" aria-hidden="true">🐱</span>';
    if (!in_array($frame, CATFISH_FRAMES, true) && !in_array($frame, CATFISH_FRAMES_EXTRA, true)) $frame = 'idleA';
    $layers = catfish_cat_layers($cat, $frame);
    if ($layers === null) return $fallback;
    $h = '';
    foreach ($layers as [$file, $masks, $clip]) {
        $inner = '<img src="' . e(catfish_art_url($file)) . '" alt="" width="64" height="64">';
        if ($clip !== '') $inner = '<span class="cfclip cfclip-' . $clip . '">' . $inner . '</span>';
        foreach ($masks as $m) $inner = '<span class="cfmk cfmk-' . $m . '">' . $inner . '</span>';
        $h .= $inner;
    }
    $s = $size >= 192 ? 192 : ($size >= 128 ? 128 : 64);
    return '<span class="cfart cf-s' . $s . '" aria-hidden="true">' . $h . '</span>';
}
/**
 * Manifest of the lazily built frames of one cat for catfish.js: url prefix p and suffix s (cache-busting version), and frame => [[file, masks, clip], ...] as
 * catfish_cat_layers() lists them (aliases already resolved to the base layers' files). Frames with no art are left out. Same-origin images only.
 */
function catfish_frame_manifest(array $cat, array $frames = CATFISH_FRAMES_LAZY): array
{
    $u = catfish_art_url('@'); $i = strpos($u, '@');
    $m = ['p' => substr($u, 0, $i), 's' => substr($u, $i + 1), 'frames' => []];
    foreach ($frames as $f) {
        $l = catfish_cat_layers($cat, $f);
        if ($l === null) continue;
        $m['frames'][$f] = array_map(fn($r) => $r[2] !== '' ? $r : ($r[1] ? [$r[0], $r[1]] : [$r[0]]), $l);
    }
    return $m;
}

/** Today's date in the Hollow's time zone (setting game_timezone, America/Halifax). Every Cat Fish day and week turns over at its local midnight, like the rest of the game (jobs.php). */
function catfish_today(?int $ts = null): string
{
    return hollow_date('Y-m-d', $ts);
}

/** The day before a 'Y-m-d' date (plain calendar arithmetic, so DST cannot skip or repeat a day). */
function catfish_yesterday(?string $today = null): string
{
    return gmdate('Y-m-d', strtotime(($today ?? catfish_today()) . ' UTC') - 86400);
}

/** ISO week key like '2026-W44' in the Hollow's time zone (Monday to Sunday). The show, the Petal cap and job_period_key('weekly') all agree. */
function catfish_week(?int $ts = null): string
{
    return hollow_date('o-\\WW', $ts);
}

/** Is Cat Fish open to this viewer? (Admins always; players need the catfish_open setting.) */
function catfish_open(): bool
{
    return is_admin() || setting('catfish_open') === '1';
}

/** Create the tables the first time they're needed, and patch columns on databases made by earlier builds (same lazy pattern as puzzles_ensure()). */
function catfish_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    if (PHP_INT_SIZE < 8) return $ok = false;   // seeds and the RNG need 64-bit integers
    try { q('SELECT 1 FROM cats LIMIT 1'); q('SELECT adopted FROM cat_book LIMIT 1'); q('SELECT run_kibble, total_kibble, meta FROM catfish_state LIMIT 1'); q('SELECT 1 FROM cat_ribbons LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $s = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        $PK = $s ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY';
        $ID = $s ? 'INTEGER' : 'INT UNSIGNED';
        $END = $s ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci';
        db()->exec("CREATE TABLE IF NOT EXISTS cats (
            id $PK, user_id $ID NOT NULL, seed $ID NOT NULL, name VARCHAR(30) NOT NULL, adopted_at DATETIME NOT NULL,
            UNIQUE (user_id, seed)
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS catfish_state (
            user_id $ID NOT NULL PRIMARY KEY, kibble BIGINT NOT NULL DEFAULT 0, yarn $ID NOT NULL DEFAULT 0, upgrades TEXT NULL,
            active_cat_id $ID NULL, last_tick $ID NOT NULL DEFAULT 0, naps $ID NOT NULL DEFAULT 0, run_kibble BIGINT NOT NULL DEFAULT 0, total_kibble BIGINT NOT NULL DEFAULT 0, meta TEXT NULL, created_at DATETIME NOT NULL
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS cat_book (
            user_id $ID NOT NULL, pattern VARCHAR(12) NOT NULL, colour VARCHAR(12) NOT NULL, adopted $ID NOT NULL DEFAULT 0, found_at DATETIME NOT NULL,
            PRIMARY KEY (user_id, pattern, colour)
        )$END");
        db()->exec("CREATE TABLE IF NOT EXISTS cat_ribbons (
            id $PK, user_id $ID NOT NULL, week VARCHAR(8) NOT NULL, theme VARCHAR(60) NOT NULL, cat_name VARCHAR(30) NOT NULL, tier VARCHAR(10) NOT NULL, score $ID NOT NULL DEFAULT 0, created_at DATETIME NOT NULL,
            UNIQUE (user_id, week)
        )$END");
        foreach ([['catfish_state', 'run_kibble', 'BIGINT NOT NULL DEFAULT 0'], ['catfish_state', 'total_kibble', 'BIGINT NOT NULL DEFAULT 0'], ['catfish_state', 'meta', 'TEXT NULL'], ['cat_book', 'adopted', 'INT NOT NULL DEFAULT 0']] as [$t, $col, $def]) {
            try { q('SELECT ' . $col . ' FROM ' . $t . ' LIMIT 1'); } catch (Throwable $e) { try { db()->exec('ALTER TABLE ' . $t . ' ADD COLUMN ' . $col . ' ' . $def); } catch (Throwable $e2) {} }   // a second first request may have added it already
        }
        return $ok = true;
    } catch (Throwable $e) {
        error_log('catfish_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

// ---------- cat generator ----------

/** 32-bit unsigned multiply (Math.imul), done in 16-bit halves so PHP never overflows into a float. */
function catfish_mul32(int $a, int $b): int
{
    return ((($a & 0xFFFF) * $b) + (((($a >> 16) * $b) & 0xFFFF) << 16)) & 0xFFFFFFFF;
}

/** Seeded RNG (mulberry32, identical to the usual JS version). Returns a closure giving floats in [0, 1). */
function catfish_rng(int $seed): Closure
{
    $a = $seed & 0xFFFFFFFF;
    return function () use (&$a): float {
        $a = ($a + 0x6D2B79F5) & 0xFFFFFFFF;
        $t = catfish_mul32($a ^ ($a >> 15), 1 | $a);
        $t = (($t + catfish_mul32($t ^ ($t >> 7), 61 | $t)) & 0xFFFFFFFF) ^ $t;
        return (($t ^ ($t >> 14)) & 0xFFFFFFFF) / 4294967296;
    };
}

/** Weighted pick; also returns the pick's probability. */
function catfish_pick(array $weights, float $r): array
{
    $sum = array_sum($weights); $x = $r * $sum;
    foreach ($weights as $k => $w) { if ($x < $w) return [$k, $w / $sum]; $x -= $w; }
    $k = array_key_last($weights);
    return [$k, $weights[$k] / $sum];
}

/** Every trait of the cat with this seed, plus a rarity score and band. Pure: same seed, same cat, always. */
function catfish_cat(int $seed): array
{
    $seed &= 0xFFFFFFFF;
    $rng = catfish_rng($seed);
    $cat = ['seed' => $seed]; $bits = 0.0;
    foreach (CATFISH_TRAITS as $trait => $weights) {
        [$v, $p] = catfish_pick($weights, $rng());
        $cat[$trait] = $v; $bits += -log($p, 2);
    }
    $cat['quirk'] = '';
    if ($rng() < 1 / CATFISH_QUIRK_CHANCE) {
        $cat['quirk'] = CATFISH_QUIRKS[(int)floor($rng() * count(CATFISH_QUIRKS))];
        $bits += log(CATFISH_QUIRK_CHANCE, 2);
    } else {
        $rng();   // keep the stream the same length either way
    }
    $cat['name'] = CATFISH_NAMES[(int)floor($rng() * count(CATFISH_NAMES))];
    $cat['score'] = round($bits, 2);
    $band = 'common';
    foreach (CATFISH_RARITY as $b => $min) if ($bits >= $min) $band = $b;
    $cat['rarity'] = $band;
    return $cat;
}

/**
 * The day's shelter for a gnome: CATFISH_SHELTER cats, each ['slot' => n] + catfish_cat(). $day is 'Y-m-d' in the Hollow's time zone.
 * $rolls[slot] = rerolls bought today for that slot; $rare = Rare Shelter level (the best-scoring of 1 + $rare candidates is shown).
 * With no rolls and no Rare Shelter the seeds are the plain crc32(user|day|slot), so older shelters do not change.
 */
function catfish_shelter(int $uid, ?string $day = null, array $rolls = [], int $rare = 0, ?array $stake = null): array
{
    $day = $day ?? catfish_today();
    $out = [];
    for ($slot = 0; $slot < CATFISH_SHELTER; $slot++) {
        $n = (int)($rolls[$slot] ?? 0); $best = null;
        for ($c = 0; $c <= $rare; $c++) {
            $cand = catfish_cat(crc32($uid . '|' . $day . '|' . $slot . ($n > 0 ? '|r' . $n : '') . ($c > 0 ? '|c' . $c : '')));
            if ($best === null || $cand['score'] > $best['score']) $best = $cand;
        }
        if ($stake !== null && isset(CATFISH_TRAITS[$stake[0]][$stake[1]]) && in_array($stake[0], ['pattern', 'colour'], true)) {   // a stakeout: the best-scoring look-alike beats a cat that does not match
            for ($c = 0; $c < CATFISH_STAKE_TRIES; $c++) {
                $cand = catfish_cat(crc32($uid . '|' . $day . '|' . $slot . '|s' . $c));
                if (($cand[$stake[0]] ?? '') === $stake[1] && (($best[$stake[0]] ?? '') !== $stake[1] || $cand['score'] > $best['score'])) $best = $cand;
            }
        }
        $best['slot'] = $slot;
        $out[] = $best;
    }
    return $out;
}

/** Today's shelter for a gnome with their rerolls and Rare Shelter level applied. */
function catfish_shelter_now(int $uid, ?array $meta = null): array
{
    $meta = $meta ?? catfish_state($uid)['meta'];
    $today = catfish_today();
    $rolls = ($meta['roll']['day'] ?? '') === $today ? (array)($meta['roll']['n'] ?? []) : [];
    $st = $meta['stake'] ?? null;
    $out = catfish_shelter($uid, $today, $rolls, (int)($meta['rare'] ?? 0), is_array($st) && ($st['for'] ?? '') === $today ? [(string)$st['trait'], (string)$st['value']] : null);
    $h = $meta['hold'] ?? null;   // a cat held yesterday takes its old spot again today
    if (is_array($h) && ($h['for'] ?? '') === $today && isset($out[(int)$h['slot']])) {
        $c = catfish_cat((int)$h['seed']); $c['slot'] = (int)$h['slot']; $c['held'] = true;
        $out[(int)$h['slot']] = $c;
    }
    return $out;
}

/** 'Y-m-d' of the next Hollow day. */
function catfish_tomorrow(): string
{
    return (new DateTimeImmutable(catfish_today()))->modify('+1 day')->format('Y-m-d');
}

/** Kibble price of the next adoption for a gnome who owns $owned cats. The first is free. */
function catfish_adopt_cost(int $owned): int
{
    return $owned <= 0 ? 0 : (int)(500 * 4 ** ($owned - 1));
}

/** Cats a gnome may own: 2, plus one per bigger-home upgrade (up to CATFISH_MAX_CATS). */
function catfish_slots(int $uid, ?array $state = null): int
{
    return min(CATFISH_MAX_CATS, 2 + (int)(($state ?? catfish_state($uid))['meta']['extra'] ?? 0));
}

// ---------- state and tick ----------

/** Run $fn inside a per-gnome lock (a transaction that touches the users row), so two tabs cannot double-spend. */
function catfish_locked(int $uid, callable $fn)
{
    $own = !db()->inTransaction();
    if ($own) db()->beginTransaction();
    try {
        q('UPDATE users SET id = id WHERE id = ?', [$uid]);
        $r = $fn();
        if ($own) db()->commit();
        return $r;
    } catch (Throwable $e) {
        if ($own && db()->inTransaction()) db()->rollBack();
        throw $e;
    }
}

/** The gnome's Cat Fish row, created on first sight. */
function catfish_state(int $uid): array
{
    $s = q_one('SELECT * FROM catfish_state WHERE user_id = ?', [$uid]);
    if (!$s) {
        try { db_insert('catfish_state', ['user_id' => $uid, 'kibble' => 0, 'yarn' => 0, 'upgrades' => '{}', 'active_cat_id' => null, 'last_tick' => time(), 'naps' => 0, 'run_kibble' => 0, 'total_kibble' => 0, 'meta' => '{}', 'created_at' => now()]); }
        catch (Throwable $e) {}   // a second tab created it first
        $s = q_one('SELECT * FROM catfish_state WHERE user_id = ?', [$uid]);
    }
    $up = json_decode((string)($s['upgrades'] ?? ''), true);
    $s['up'] = is_array($up) ? array_map('intval', $up) : [];
    $meta = json_decode((string)($s['meta'] ?? ''), true);
    $s['meta'] = is_array($meta) ? $meta : [];
    return $s;
}

function catfish_cost(string $key, int $owned): int
{
    return (int)ceil(min(CATFISH_MAX_COST, CATFISH_UPGRADES[$key][2] * CATFISH_GROWTH ** $owned));
}

/** Effect multiplier of an upgrade: x2 at each milestone owned count reached. */
function catfish_milestone_mult(int $owned): int
{
    $m = 1;
    foreach (CATFISH_MILESTONES as $at) if ($owned >= $at) $m *= 2;
    return $m;
}

const CATFISH_PAL_STEP = 0.02;          // Puzzle Pals: +2% Kibble per pal found (needs Puzzle Pals open; no gnome level, as Pals themselves need none since 2.0.91)
const CATFISH_PAL_MAX = 10;             // ...for up to this many pals (+20%)

/** Extra Kibble multiplier outside the Yarn maths: Puzzle Pals found (ppal_open). 1.0 when none. One cheap count per call, cached per request. */
function catfish_extra_mult(int $uid): float
{
    static $cache = [];
    if (isset($cache[$uid])) return $cache[$uid];
    $m = 1.0;
    try {
        require_once __DIR__ . '/puzzle_pals.php';
        if (ppal_open()) {   // no ppal_ensure() here: this runs inside the tick lock, and creating tables there would end the transaction. A missing table is caught below.
            $found = (int)q_val('SELECT COUNT(*) FROM ppal_found WHERE user_id = ?', [$uid]);
            $m += CATFISH_PAL_STEP * min($found, CATFISH_PAL_MAX);
        }
    } catch (Throwable $e) {}
    try {   // a Buddy: an owned cat that is not the playing one
        $r = q_one('SELECT meta, active_cat_id FROM catfish_state WHERE user_id = ?', [$uid]);
        $meta = $r ? json_decode((string)$r['meta'], true) : null;
        $b = is_array($meta) && !empty($meta['buddyon']) ? (int)($meta['buddy'] ?? 0) : 0;
        if ($b > 0 && $b !== (int)$r['active_cat_id'] && q_val('SELECT 1 FROM cats WHERE id = ? AND user_id = ?', [$b, $uid])) $m *= 1 + CATFISH_BUDDY_PCT;
    } catch (Throwable $e) {}
    return $cache[$uid] = $m;
}

/** 2 while a festival is running (Yarn from a Nap doubles), else 1. */
function catfish_festival_mult(): int
{
    try { require_once __DIR__ . '/festival.php'; return festival_active() ? 2 : 1; } catch (Throwable $e) { return 1; }
}

/** Kibble multiplier from Yarn. */
function catfish_yarn_mult(int $yarn): float
{
    return 1 + CATFISH_YARN_STEP * max(0, $yarn) ** CATFISH_YARN_POW;
}

/** Kibble per hour for these owned levels and this cat (null = no cat yet). */
function catfish_kph(array $up, ?array $cat = null, bool $present = false, int $yarn = 0, float $extra = 1.0): float
{
    $add = CATFISH_BASE_KPH; $pct = 0.0;
    foreach (CATFISH_UPGRADES as $key => [, , , $a, $p]) {
        $n = (int)($up[$key] ?? 0);
        if ($n <= 0) continue;
        $mm = catfish_milestone_mult($n);
        $add += $a * $n * $mm;
        $pct += $p * $n * $mm;
    }
    $kph = $add * (1 + $pct) * catfish_yarn_mult($yarn) * max(1.0, $extra);
    $mood = $cat['mood'] ?? '';
    if ($mood === 'greedy') $kph *= 1.10;
    if ($mood === 'hyper' && $present) $kph *= 1.15;
    return min($kph, CATFISH_MAX_KPH);
}

/** Seconds of away time that count for this cat. */
function catfish_offline_cap(?array $cat, int $away = 0): int
{
    return (int)((CATFISH_OFFLINE_CAP + 3600 * max(0, min($away, count(CATFISH_AWAY_COSTS)))) * (($cat['mood'] ?? '') === 'lazy' ? 1.25 : 1));
}

/** The gnome's active cat as a full trait array, or null. */
function catfish_active(int $uid, array $s): ?array
{
    if (empty($s['active_cat_id'])) return null;
    $row = q_one('SELECT * FROM cats WHERE id = ? AND user_id = ?', [(int)$s['active_cat_id'], $uid]);
    if (!$row) return null;
    $c = catfish_cat((int)$row['seed']);
    $c['id'] = (int)$row['id']; $c['name'] = (string)$row['name'];
    return $c;
}

/** Pay out kibble earned since the last tick (server clock only). Returns the fresh state, plus 'gained'. */
function catfish_tick(int $uid): array
{
    return catfish_locked($uid, function () use ($uid) {
        $s = catfish_state($uid);
        $cat = catfish_active($uid, $s);
        $now = time(); $gap = max(0, $now - (int)$s['last_tick']);
        $s['gained'] = 0;
        if (!$cat || $gap < 1) return $s;
        $away = $gap > CATFISH_AWAY_AFTER;
        $secs = $away ? min($gap, catfish_offline_cap($cat, (int)($s['meta']['away'] ?? 0))) : $gap;
        $eff = catfish_kph($s['up'], $cat, !$away, (int)$s['yarn'], catfish_extra_mult($uid)) * ($away ? 0.5 : 1);   // Kibble per hour actually paid
        $base = (int)floor(min($eff * $secs / 3600, PHP_INT_MAX >> 4));
        if ($base < 1) return $s;   // nothing whole earned yet: leave last_tick alone so the part-earned fraction is kept
        $gain = $base + (($cat['mood'] ?? '') === 'sneaky' ? catfish_rare_fish($eff, $secs, mt_rand() / (mt_getrandmax() + 1)) : 0);
        $tick = $secs < $gap ? $now : min($now, (int)$s['last_tick'] + (int)ceil($base * 3600 / $eff));   // clamped away time is dropped; otherwise move the clock only by the seconds paid
        $claim = q('UPDATE catfish_state SET kibble = kibble + ?, run_kibble = run_kibble + ?, total_kibble = total_kibble + ?, last_tick = ? WHERE user_id = ? AND last_tick = ?', [$gain, $gain, $gain, $tick, $uid, (int)$s['last_tick']])->rowCount();
        if ($claim === 1) { $s['kibble'] = (int)$s['kibble'] + $gain; $s['run_kibble'] = (int)$s['run_kibble'] + $gain; $s['last_tick'] = $tick; $s['gained'] = $gain; }
        return $s;
    });
}

/** Tier multiplier of the $k-th tap of a Hollow day (1-based): 1, 0.5, 0.25, then 0 after the last tier. */
function catfish_play_tier(int $k): float
{
    foreach (CATFISH_PLAY_TIERS as [$last, $mul]) if ($k <= $last) return $mul;
    return 0.0;
}

/** Kibble for one tap at tap number $k with present income $kph (the figure the page shows). */
function catfish_play_value(float $kph, int $k): int
{
    $t = catfish_play_tier($k);
    return $t > 0 ? max(1, (int)floor($kph * CATFISH_PLAY_SECS / 3600 * $t)) : 0;
}

/**
 * Pay a batch of $n taps ($seq = the client's increasing batch id) inside the lock. Returns [got taps accepted, paid Kibble].
 * A batch whose seq is not above meta.pq is a replay (a retry after a lost reply): nothing is paid. n must be an integer 0..PLAY_BATCH; anything else pays 0.
 * Accepted = min(n, whole tokens in the bucket, taps left today). Play Kibble goes to kibble, run_kibble and total_kibble in ONE update with meta.
 */
function catfish_play(int $uid, $n, $seq): array
{
    return catfish_locked($uid, function () use ($uid, $n, $seq) {
        $s = catfish_tick($uid);
        $cat = catfish_active($uid, $s);
        if (!$cat) return [0, 0];
        $m = $s['meta']; $now = time(); $today = catfish_today();
        $seq = is_int($seq) ? $seq : (is_string($seq) && preg_match('/^\d{1,15}$/', $seq) ? (int)$seq : 0);
        if ($seq < 1 || $seq <= (int)($m['pq'] ?? 0)) return [0, 0];   // a replay or no batch id
        $n = is_int($n) ? $n : (is_string($n) && preg_match('/^\d{1,6}$/', $n) ? (int)$n : 0);
        $m['pq'] = $seq;
        $pc = ($m['pd'] ?? '') === $today ? (int)($m['pc'] ?? 0) : 0;
        $m['pd'] = $today;
        $tokens = min((float)CATFISH_PLAY_CAP, (float)($m['pb'] ?? CATFISH_PLAY_CAP) + max(0, $now - (int)($m['pt'] ?? $now)) / CATFISH_PLAY_REFILL);
        $last = CATFISH_PLAY_TIERS[count(CATFISH_PLAY_TIERS) - 1][0];
        $got = ($n < 1 || $n > CATFISH_PLAY_BATCH) ? 0 : (int)min($n, floor($tokens), max(0, $last - $pc));
        $paid = 0;
        if ($got > 0) {
            $kph = catfish_kph($s['up'], $cat, true, (int)$s['yarn'], catfish_extra_mult($uid));
            for ($i = 1; $i <= $got; $i++) $paid += catfish_play_value($kph, $pc + $i);
            $tokens -= $got;
            $m['pe'] = (int)($m['pe'] ?? 0) + $got;
        }
        $m['pb'] = $tokens; $m['pt'] = $now; $m['pc'] = $pc + $got;
        q('UPDATE catfish_state SET kibble = kibble + ?, run_kibble = run_kibble + ?, total_kibble = total_kibble + ?, meta = ? WHERE user_id = ?', [$paid, $paid, $paid, json_encode($m), $uid]);
        return [$got, $paid];
    });
}

/** The play block of the view: v = Kibble the next tap would pay (0 when today's taps are used up), left = taps left today, got and paid = the batch just accepted, ever = lifetime taps (0 = show the hint). */
function catfish_play_view(array $s, ?array $cat, float $kph, int $got = 0, int $paid = 0): array
{
    $m = $s['meta']; $pc = ($m['pd'] ?? '') === catfish_today() ? (int)($m['pc'] ?? 0) : 0;
    $last = CATFISH_PLAY_TIERS[count(CATFISH_PLAY_TIERS) - 1][0];
    return ['v' => $cat ? catfish_play_value($kph, $pc + 1) : 0, 'left' => max(0, $last - $pc), 'got' => $got, 'paid' => $paid, 'ever' => (int)($m['pe'] ?? 0)];
}

/** Sneaky cats: a rare fish now and then, worth a tenth of an hour's Kibble. $r is a roll in [0, 1); pure, so the tests can pin it. */
function catfish_rare_fish(float $effKph, int $secs, float $r): int
{
    $chance = min(0.9, CATFISH_RARE_PER_HOUR * $secs / 3600);
    return $r < $chance ? (int)floor($effKph / 10) : 0;
}

/** Yarn a Nap would give for this run's Kibble (Dreamy cats add 10% before rounding down). 0 means the run is too short. */
function catfish_nap_yarn(int $runKibble, ?array $cat): int
{
    $y = max(0, $runKibble) / CATFISH_NAP_BASE;
    $y = $y >= 1 ? $y ** (1 / CATFISH_NAP_ROOT) : 0.0;
    if (($cat['mood'] ?? '') === 'dreamy') $y *= 1.10;
    return (int)floor(min($y, 1.0e9) + 1e-9);   // 64 ** (1/3) is 3.9999999999999996
}

// ---------- actions (each returns [ok, message]) ----------

/** Cost of the next $n levels of an upgrade in one go (each level costs more than the last). */
function catfish_cost_n(string $key, int $owned, int $n): int
{
    $sum = 0.0;
    for ($i = 0; $i < $n; $i++) $sum += catfish_cost($key, $owned + $i);
    return (int)min(CATFISH_MAX_COST, $sum);
}

/** $n is 1, or 10 once Buy x10 is unlocked (anything else counts as 1). All ten or none. */
function catfish_buy(int $uid, string $key, int $n = 1): array
{
    if (!isset(CATFISH_UPGRADES[$key])) return [false, 'No such upgrade.'];
    return catfish_locked($uid, function () use ($uid, $key, $n) {
        $s = catfish_tick($uid);
        $n = $n === 10 && !empty($s['meta']['bulk']) ? 10 : 1;
        $owned = (int)($s['up'][$key] ?? 0); $cost = catfish_cost_n($key, $owned, $n);
        if ((int)$s['kibble'] < $cost) return [false, 'Not enough Kibble.'];
        $s['up'][$key] = $owned + $n;
        $paid = q('UPDATE catfish_state SET kibble = kibble - ?, upgrades = ? WHERE user_id = ? AND kibble >= ?', [$cost, json_encode($s['up']), $uid, $cost])->rowCount();
        return $paid === 1 ? [true, CATFISH_UPGRADES[$key][0] . ($n > 1 ? ' ×' . $n : '') . ' bought.'] : [false, 'Not enough Kibble.'];
    });
}

function catfish_clean_name(string $name, string $fallback): string
{
    $name = trim(preg_replace('/[^\p{L}\p{N} \'-]/u', '', $name) ?? '');
    $name = mb_substr($name, 0, CATFISH_NAME_MAX);
    return $name !== '' ? $name : $fallback;
}

function catfish_adopt(int $uid, int $slot, string $name, string $day = '', int $seed = 0): array
{
    if ($slot < 0 || $slot >= CATFISH_SHELTER) return [false, 'No such cat.'];
    return catfish_locked($uid, function () use ($uid, $slot, $name, $seed) {
        $s = catfish_tick($uid);
        $owned = (int)q_val('SELECT COUNT(*) FROM cats WHERE user_id = ?', [$uid]);
        if ($owned >= catfish_slots($uid)) return [false, 'Your home is full.'];
        $cat = catfish_shelter_now($uid, $s['meta'])[$slot];
        if ($seed > 0 && $cat['seed'] !== $seed) {
            // a form from before midnight still adopts the cat it showed, but only in the first hour of the new day
            if ((int)hollow_date('G') >= 1) return [false, 'The shelter changed. Reload the page and try again.'];
            $old = catfish_shelter($uid, catfish_yesterday(), [], (int)($s['meta']['rare'] ?? 0))[$slot];
            if ($old['seed'] !== $seed) return [false, 'The shelter changed. Reload the page and try again.'];
            $cat = $old;
        }
        if (q_val('SELECT 1 FROM cats WHERE user_id = ? AND seed = ?', [$uid, $cat['seed']])) return [false, 'You already adopted that cat.'];
        $cost = catfish_adopt_cost($owned);
        if ($cost > 0 && q('UPDATE catfish_state SET kibble = kibble - ? WHERE user_id = ? AND kibble >= ?', [$cost, $uid, $cost])->rowCount() !== 1) return [false, 'Not enough Kibble.'];
        $clean = catfish_clean_name($name, $cat['name']);
        $id = db_insert('cats', ['user_id' => $uid, 'seed' => $cat['seed'], 'name' => $clean, 'adopted_at' => now()]);
        if (empty($s['active_cat_id'])) q('UPDATE catfish_state SET active_cat_id = ?, last_tick = ? WHERE user_id = ?', [$id, time(), $uid]);
        catfish_book_add($uid, $cat['pattern'], $cat['colour'], 1);
        catfish_claim_petals($uid);
        return [true, 'Welcome home, ' . $clean . '!'];
    });
}

// ---------- shelter upgrades (Yarn) and Petal milestones ----------

/** Yarn the gnome can still spend: all Yarn ever earned minus what shelter upgrades cost. Spending never lowers the Kibble bonus (that follows Yarn earned). */
function catfish_spendable(array $s): int
{
    return max(0, (int)$s['yarn'] - (int)($s['meta']['ys'] ?? 0));
}

function catfish_meta_save(int $uid, array $meta): void
{
    q('UPDATE catfish_state SET meta = ? WHERE user_id = ?', [json_encode($meta), $uid]);
}

/** Run one Yarn purchase: $fn(&$meta, $s) returns [cost, message] or a [false, message] refusal, inside the lock. */
function catfish_yarn_spend(int $uid, callable $fn): array
{
    return catfish_locked($uid, function () use ($uid, $fn) {
        $s = catfish_state($uid); $meta = $s['meta'];
        $r = $fn($meta, $s);
        if ($r[0] === false) return $r;
        [$cost, $msg] = $r;
        if (catfish_spendable($s) < $cost) return [false, 'Not enough Yarn.'];
        $meta['ys'] = (int)($meta['ys'] ?? 0) + $cost;
        catfish_meta_save($uid, $meta);
        return [true, $msg];
    });
}

function catfish_reroll(int $uid, int $slot): array
{
    if ($slot < 0 || $slot >= CATFISH_SHELTER) return [false, 'No such cat.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($slot) {
        $today = catfish_today();
        $n = ($meta['roll']['day'] ?? '') === $today ? (array)($meta['roll']['n'] ?? []) : [];
        $n = array_replace([0, 0, 0], $n);
        if ($n[$slot] >= CATFISH_REROLL_MAX) return [false, 'That spot has had its swaps for today.'];
        $n[$slot]++;
        $meta['roll'] = ['day' => $today, 'n' => $n];
        return [CATFISH_REROLL_COST, 'A new cat is waiting.'];
    });
}

function catfish_buy_slot(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        $extra = (int)($meta['extra'] ?? 0);
        if ($extra >= count(CATFISH_SLOT_COSTS)) return [false, 'Your home is as big as it gets.'];
        $meta['extra'] = $extra + 1;
        return [CATFISH_SLOT_COSTS[$extra], 'Room for ' . (2 + $extra + 1) . ' cats.'];
    });
}

function catfish_buy_bulk(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        if (!empty($meta['bulk'])) return [false, 'You already have Buy ×10.'];
        $meta['bulk'] = 1;
        return [CATFISH_BULK_COST, 'Buy ×10 is on. Pick ×10 above the upgrades.'];
    });
}

function catfish_buy_away(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        $lvl = (int)($meta['away'] ?? 0);
        if ($lvl >= count(CATFISH_AWAY_COSTS)) return [false, 'Your cat already naps as long as it can.'];
        $meta['away'] = $lvl + 1;
        return [CATFISH_AWAY_COSTS[$lvl], 'Your cat now fishes for ' . (8 + $lvl + 1) . ' hours while you are away.'];
    });
}

function catfish_buy_title(int $uid, string $key): array
{
    if (!isset(CATFISH_TITLES[$key])) return [false, 'No such title.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($key) {
        $have = (array)($meta['titles'] ?? []);
        if (in_array($key, $have, true)) return [false, 'You already have that title.'];
        $meta['titles'] = array_values(array_merge($have, [$key]));
        return [CATFISH_TITLES[$key][1], '“' . CATFISH_TITLES[$key][0] . '” is yours. Choose it in the Almanac (Milestones).'];
    });
}

/** Titles this gnome bought with Yarn (for the Almanac title picker). */
function catfish_titles(int $uid): array
{
    if (!catfish_ensure()) return [];
    $meta = json_decode((string)q_val('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]), true);
    $out = [];
    foreach ((array)($meta['titles'] ?? []) as $k) if (isset(CATFISH_TITLES[$k])) $out[] = CATFISH_TITLES[$k][0];
    return $out;
}

/** Hold today's cat in a shelter spot: tomorrow it is back in the same spot. One hold a day; an owned cat is not worth holding. */
function catfish_hold(int $uid, int $slot): array
{
    if ($slot < 0 || $slot >= CATFISH_SHELTER) return [false, 'No such cat.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($uid, $slot) {
        $tomorrow = catfish_tomorrow();
        if (($meta['hold']['for'] ?? '') === $tomorrow) return [false, 'You are already holding a cat for tomorrow.'];
        $cat = catfish_shelter_now($uid, $meta)[$slot];
        if (q_val('SELECT 1 FROM cats WHERE user_id = ? AND seed = ?', [$uid, $cat['seed']])) return [false, 'That cat is already yours.'];
        $meta['hold'] = ['for' => $tomorrow, 'seed' => (int)$cat['seed'], 'slot' => $slot];
        return [CATFISH_HOLD_COST, $cat['name'] . ' will wait for you tomorrow.'];
    });
}

/** Stake out a pattern or a colour: tomorrow's shelter looks harder for it. One a day. */
function catfish_stake(int $uid, string $pick): array
{
    [$trait, $value] = array_pad(explode(':', $pick, 2), 2, '');
    if (!in_array($trait, ['pattern', 'colour'], true) || !isset(CATFISH_TRAITS[$trait][$value])) return [false, 'Pick a pattern or a colour.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($trait, $value) {
        $tomorrow = catfish_tomorrow();
        if (($meta['stake']['for'] ?? '') === $tomorrow) return [false, 'You have already staked out tomorrow.'];
        $meta['stake'] = ['for' => $tomorrow, 'trait' => $trait, 'value' => $value];
        return [CATFISH_STAKE_COST, 'Tomorrow the shelter looks for ' . $value . '.'];
    });
}

function catfish_buy_show2(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        if (!empty($meta['show2on'])) return [false, 'You already have a second entry.'];
        $meta['show2on'] = 1;
        return [CATFISH_SHOW2_COST, 'You can enter two cats in the Cat Show.'];
    });
}

function catfish_buy_buddy(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        if (!empty($meta['buddyon'])) return [false, 'You already have a Buddy cat.'];
        $meta['buddyon'] = 1;
        return [CATFISH_BUDDY_COST, 'Pick a Buddy under Your cats.'];
    });
}

/** Choose (or, with 0, clear) the Buddy cat. Free once unlocked. */
function catfish_set_buddy(int $uid, int $catId): array
{
    return catfish_locked($uid, function () use ($uid, $catId) {
        $s = catfish_state($uid); $meta = $s['meta'];
        if (empty($meta['buddyon'])) return [false, 'Unlock Buddy cat with Yarn first.'];
        if ($catId > 0 && !q_val('SELECT 1 FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid])) return [false, 'No such cat.'];
        if ($catId > 0 && $catId === (int)$s['active_cat_id']) return [false, 'The playing cat cannot be its own Buddy.'];
        $meta['buddy'] = $catId; catfish_meta_save($uid, $meta);
        return [true, $catId > 0 ? 'Buddy chosen.' : 'No Buddy now.'];
    });
}

function catfish_buy_keep(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        $lvl = (int)($meta['keepsake'] ?? 0);
        if ($lvl >= count(CATFISH_KEEP_COSTS)) return [false, 'Keepsake is as strong as it gets.'];
        $meta['keepsake'] = $lvl + 1;
        return [CATFISH_KEEP_COSTS[$lvl], 'After a Nap you keep ' . ($lvl + 1) . ' level' . ($lvl ? 's' : '') . ' of the first upgrade in each branch.'];
    });
}

function catfish_buy_ball(int $uid, string $key): array
{
    if (!isset(CATFISH_BALLS[$key])) return [false, 'No such colour.'];
    return catfish_yarn_spend($uid, function (&$meta) use ($key) {
        $have = (array)($meta['balls'] ?? []);
        if (in_array($key, $have, true)) return [false, 'You already have that colour.'];
        $meta['balls'] = array_values(array_merge($have, [$key])); $meta['ball'] = $key;
        return [CATFISH_BALL_COST, CATFISH_BALLS[$key] . ' yarn ball bought and in use.'];
    });
}

/** Switch the yarn ball colour ('' = the plain one). Free for colours you own. */
function catfish_set_ball(int $uid, string $key): array
{
    return catfish_locked($uid, function () use ($uid, $key) {
        $meta = catfish_state($uid)['meta'];
        if ($key !== '' && !in_array($key, (array)($meta['balls'] ?? []), true)) return [false, 'You do not have that colour.'];
        $meta['ball'] = $key; catfish_meta_save($uid, $meta);
        return [true, $key === '' ? 'Plain yarn ball.' : CATFISH_BALLS[$key] . ' yarn ball.'];
    });
}

/** True while a festival with a jar is running (so the bunting row shows). */
function catfish_festival_on(): bool
{
    try { require_once __DIR__ . '/festival.php'; $f = festival_active(); return $f !== null && festival_goal($f) !== null; } catch (Throwable $e) { return false; }
}

/** Hang yarn bunting in the running festival's jar: 1 Yarn for +3, three a day. Only Yarn leaves; nothing here pays Petals. */
function catfish_hang_bunting(int $uid): array
{
    require_once __DIR__ . '/festival.php'; require_once __DIR__ . '/hollow_goals.php';
    hollow_goals_active();   // makes the festival's jar the first time anyone looks
    $f = festival_active();
    $goal = $f ? festival_goal($f) : null;
    if (!$goal) return [false, 'No festival is running.'];
    return catfish_yarn_spend($uid, function (&$meta, $s) use ($uid, $goal) {
        if (catfish_spendable($s) < CATFISH_BUNTING_COST) return [false, 'Not enough Yarn.'];
        $today = catfish_today();
        $n = ($meta['bunting']['day'] ?? '') === $today ? (int)$meta['bunting']['n'] : 0;
        if ($n >= CATFISH_BUNTING_DAILY) return [false, 'All of today\'s bunting is hung.'];
        $meta['bunting'] = ['day' => $today, 'n' => $n + 1];
        if (q('UPDATE hollow_goal_contrib SET amount = amount + ? WHERE goal_id = ? AND user_id = ?', [CATFISH_BUNTING_ADD, $goal['id'], $uid])->rowCount() === 0) {
            try { db_insert('hollow_goal_contrib', ['goal_id' => $goal['id'], 'user_id' => $uid, 'amount' => CATFISH_BUNTING_ADD]); }
            catch (PDOException $e) { q('UPDATE hollow_goal_contrib SET amount = amount + ? WHERE goal_id = ? AND user_id = ?', [CATFISH_BUNTING_ADD, $goal['id'], $uid]); }
        }
        return [CATFISH_BUNTING_COST, 'Bunting is up: +' . CATFISH_BUNTING_ADD . ' in the festival jar.'];
    });
}

function catfish_buy_scarf(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        if (!empty($meta['scarfown'])) return [false, 'You already have the scarf.'];
        $meta['scarfown'] = 1; $meta['scarf'] = 'red';
        return [CATFISH_SCARF_COST, 'Your gnome is wearing a scarf. Pick a colour any time.'];
    });
}

/** Choose the scarf colour, or '' to take it off. Free once bought. */
function catfish_set_scarf(int $uid, string $key): array
{
    return catfish_locked($uid, function () use ($uid, $key) {
        $meta = catfish_state($uid)['meta'];
        if (empty($meta['scarfown'])) return [false, 'Buy the scarf with Yarn first.'];
        if ($key !== '' && !isset(CATFISH_SCARVES[$key])) return [false, 'No such colour.'];
        $meta['scarf'] = $key; catfish_meta_save($uid, $meta);
        return [true, $key === '' ? 'Scarf off.' : CATFISH_SCARVES[$key][0] . ' scarf on.'];
    });
}

/** Hex colour of the scarf this gnome wears, or ''. Read-only and cached per request (the gnome avatar asks for every gnome on a page). */
function catfish_scarf_color(int $uid): string
{
    static $cache = [];
    if (isset($cache[$uid])) return $cache[$uid];
    $c = '';
    try {
        $meta = json_decode((string)q_val('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]), true);
        if (is_array($meta) && !empty($meta['scarfown']) && isset(CATFISH_SCARVES[$meta['scarf'] ?? ''])) $c = CATFISH_SCARVES[$meta['scarf']][1];
    } catch (Throwable $e) {}
    return $cache[$uid] = $c;
}

function catfish_buy_rare(int $uid): array
{
    return catfish_yarn_spend($uid, function (&$meta) {
        $lvl = (int)($meta['rare'] ?? 0);
        if ($lvl >= count(CATFISH_RARE_COSTS)) return [false, 'The shelter already sends its best.'];
        $meta['rare'] = $lvl + 1;
        return [CATFISH_RARE_COSTS[$lvl], 'The shelter will show better cats.'];
    });
}

/** Which Petal milestones this gnome has reached. */
function catfish_milestones_reached(int $uid, array $s): array
{
    $cats = (int)q_val('SELECT COUNT(*) FROM cats WHERE user_id = ?', [$uid]);
    $book = count(catfish_book($uid));
    $half = (int)(count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']) / 2);
    return ['adopt1' => $cats >= 1, 'nap1' => (int)$s['naps'] >= 1, 'book12' => $book >= 12, 'nap5' => (int)$s['naps'] >= 5, 'full4' => $cats >= 4, 'book_half' => $book >= $half];
}

/** Pay reached milestones that have not been paid, as long as this ISO week's total stays inside the cap. Returns Petals paid. Safe to call often. */
function catfish_claim_petals(int $uid): int
{
    $cap = (int)setting('catfish_petal_cap');
    if ($cap <= 0) return 0;
    $seen = json_decode((string)q_val('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]), true);
    if (is_array($seen) && count((array)($seen['ms'] ?? [])) >= count(CATFISH_MILESTONES_PETALS)) return 0;   // all paid: no lock, no extra queries
    return catfish_locked($uid, function () use ($uid, $cap) {
        $s = catfish_state($uid); $meta = $s['meta'];
        $week = catfish_week();
        $paid = ($meta['pw']['week'] ?? '') === $week ? (int)$meta['pw']['paid'] : 0;
        $done = (array)($meta['ms'] ?? []); $total = 0;
        foreach (catfish_milestones_reached($uid, $s) as $key => $hit) {
            if (!$hit || in_array($key, $done, true)) continue;
            $amount = min(game_petals(CATFISH_MILESTONES_PETALS[$key][1]), $cap);   // never bigger than the cap, so a milestone can always be paid in some week
            if ($paid + $total + $amount > $cap) continue;   // waits for next week
            $done[] = $key; $total += $amount;
        }
        if ($total > 0) {
            $meta['ms'] = $done; $meta['pw'] = ['week' => $week, 'paid' => $paid + $total];
            catfish_meta_save($uid, $meta);
            give_petals($uid, $total, 'catfish');
        }
        return $total;
    });
}

/** Nap: spend the run for Yarn. Upgrades and Kibble reset; cats, Yarn, the Cat Book and badges stay. */
function catfish_nap(int $uid): array
{
    return catfish_locked($uid, function () use ($uid) {
        $s = catfish_tick($uid);
        $cat = catfish_active($uid, $s);
        $y = catfish_nap_yarn((int)$s['run_kibble'], $cat) * catfish_festival_mult();
        if ($y < 1) return [false, 'Not enough Kibble earned this run to nap yet.'];
        $kept = []; $keep = min((int)($s['meta']['keepsake'] ?? 0), count(CATFISH_KEEP_COSTS));
        if ($keep > 0) foreach (CATFISH_KEEP_UPS as $k) $kept[$k] = $keep;   // Keepsake: the first upgrade of each branch survives the Nap
        $done = q('UPDATE catfish_state SET yarn = yarn + ?, naps = naps + 1, kibble = 0, run_kibble = 0, upgrades = ?, last_tick = ? WHERE user_id = ? AND run_kibble = ?', [$y, $kept ? json_encode($kept) : '{}', time(), $uid, (int)$s['run_kibble']])->rowCount();
        if ($done === 1) catfish_claim_petals($uid);
        return $done === 1 ? [true, 'Nap time! +' . $y . ' Yarn.'] : [false, 'Try that again.'];
    });
}

function catfish_switch(int $uid, int $catId): array
{
    return catfish_locked($uid, function () use ($uid, $catId) {
        if (!q_val('SELECT 1 FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid])) return [false, 'No such cat.'];
        catfish_tick($uid);   // pay the old cat first
        q('UPDATE catfish_state SET active_cat_id = ?, last_tick = ? WHERE user_id = ?', [$catId, time(), $uid]);
        return [true, 'Switched.'];
    });
}

function catfish_rename(int $uid, int $catId, string $name): array
{
    $row = q_one('SELECT seed FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid]);
    if (!$row) return [false, 'No such cat.'];
    q('UPDATE cats SET name = ? WHERE id = ? AND user_id = ?', [catfish_clean_name($name, catfish_cat((int)$row['seed'])['name']), $catId, $uid]);
    return [true, 'Renamed.'];
}

/** A gnome's cats as full trait arrays. */
function catfish_cats(int $uid): array
{
    $out = [];
    foreach (q('SELECT * FROM cats WHERE user_id = ? ORDER BY id', [$uid])->fetchAll() as $r) {
        $c = catfish_cat((int)$r['seed']); $c['id'] = (int)$r['id']; $c['name'] = (string)$r['name'];
        $out[] = $c;
    }
    return $out;
}

/** Everything the page and the JS need for one gnome, after paying out the tick. */
function catfish_view(int $uid, int $got = 0, int $paid = 0): array
{
    $s = catfish_tick($uid);
    $cat = catfish_active($uid, $s);
    $ups = [];
    foreach (CATFISH_UPGRADES as $key => [$name, $icon, , $a, $p, $branch]) {
        $n = (int)($s['up'][$key] ?? 0); $cost = catfish_cost($key, $n);
        $ups[] = ['key' => $key, 'branch' => $branch, 'name' => $name, 'icon' => $icon, 'owned' => $n, 'cost' => $cost, 'cost10' => catfish_cost_n($key, $n, 10), 'can' => (int)$s['kibble'] >= $cost,
            'gives' => $a > 0 ? '+' . $a . ' Kibble/h each' : '+' . rtrim(rtrim(number_format($p * 100, 1), '0'), '.') . '% each', 'mult' => catfish_milestone_mult($n)];
    }
    $kphNow = $cat ? catfish_kph($s['up'], $cat, true, (int)$s['yarn'], catfish_extra_mult($uid)) : 0.0;
    return ['bulk' => !empty($s['meta']['bulk']), 'kibble' => (int)$s['kibble'], 'yarn' => (int)$s['yarn'], 'spend' => catfish_spendable($s), 'naps' => (int)$s['naps'], 'gained' => (int)$s['gained'],
        'kph' => $cat ? round($kphNow, 1) : 0, 'play' => catfish_play_view($s, $cat, $kphNow, $got, $paid), 'run' => (int)$s['run_kibble'], 'nap_yarn' => catfish_nap_yarn((int)$s['run_kibble'], $cat) * catfish_festival_mult(), 'cat' => $cat, 'ups' => $ups, 'now' => time()];
}

/** Badges, worked out from what the gnome has (nothing stored): [key => [icon, label]]. */
function catfish_badges(int $uid): array
{
    if (!catfish_ensure()) return [];
    $out = [];
    $cats = catfish_cats($uid);
    if ($cats) $out['first_cat'] = ['🐱', 'First adoption'];
    if (count($cats) >= 2) $out['full_house'] = ['🏠', 'Full house'];
    foreach ($cats as $c) {
        if ($c['eyes'] === 'odd') $out['odd_eyed'] = ['👀', 'Odd-eyed finder'];
        if ($c['rarity'] === 'legendary') $out['legendary'] = ['🌟', 'Legendary cat'];
    }
    $naps = (int)q_val('SELECT naps FROM catfish_state WHERE user_id = ?', [$uid]);
    if ($naps >= 1) $out['nap1'] = ['😴', 'First nap'];
    if ($naps >= 5) $out['nap5'] = ['💤', 'Five naps'];
    $book = catfish_book($uid);
    $entries = count($book); $all = count(CATFISH_TRAITS['pattern']) * count(CATFISH_TRAITS['colour']);
    if ($entries >= 12) $out['book12'] = ['📖', 'Cat Book: 12 coats'];
    if ($entries >= (int)($all / 2)) $out['book_half'] = ['📚', 'Cat Book: half full'];
    if ($entries >= $all) $out['book_full'] = ['🏅', 'Cat Book: every coat'];
    return $out;
}

/** Put a pattern and colour in the Cat Book ($adopted 1 = taken home, 0 = only seen at the shelter). Never downgrades an adopted entry. */
function catfish_book_add(int $uid, string $pattern, string $colour, int $adopted): void
{
    $row = q_one('SELECT adopted FROM cat_book WHERE user_id = ? AND pattern = ? AND colour = ?', [$uid, $pattern, $colour]);
    if (!$row) { try { db_insert('cat_book', ['user_id' => $uid, 'pattern' => $pattern, 'colour' => $colour, 'adopted' => $adopted, 'found_at' => now()]); return; } catch (Throwable $e) {} }   // a second tab won the insert: fall through to the update
    if ($adopted && (!$row || !(int)$row['adopted'])) q('UPDATE cat_book SET adopted = 1 WHERE user_id = ? AND pattern = ? AND colour = ?', [$uid, $pattern, $colour]);
}

/** The Cat Book: list of [pattern, colour, adopted] the gnome has seen at the shelter or taken home. */
function catfish_book(int $uid): array
{
    return array_map(fn($r) => [$r['pattern'], $r['colour'], (int)$r['adopted']], q('SELECT pattern, colour, adopted FROM cat_book WHERE user_id = ?', [$uid])->fetchAll());
}

// ---------- Cat Show (weekly, cosmetic ribbons) ----------

/** Ribbon tiers: tier => [min score, icon, label]. Highest first. A cat that scores under the last one still gets "Took part". */
const CATFISH_RIBBONS = ['best' => [40, '🏆', 'Best in Show'], 'blue' => [32, '🥇', 'Blue ribbon'], 'red' => [25, '🥈', 'Red ribbon'], 'white' => [18, '🥉', 'White ribbon']];
const CATFISH_RIBBON_PART = ['part', '🎗️', 'Took part'];
const CATFISH_SHOW_THEME_MATCH = 12;   // score for a cat that fits the week's theme
const CATFISH_SHOW_RARITY = ['common' => 0, 'uncommon' => 3, 'rare' => 6, 'legendary' => 10];

/** The show's week key: same as catfish_week(), kept as its own name for readers of the Cat Show code. */
function catfish_show_week(?int $ts = null): string
{
    return catfish_week($ts);
}

/** This week's theme: ['trait' => 'pattern', 'value' => 'tabby', 'label' => 'Best tabby coat']. Only fairly common values, so every gnome can hope to match. */
function catfish_show_theme(string $week): array
{
    $traits = ['pattern' => 'Best %s coat', 'colour' => 'Best %s cat', 'eyes' => 'Best %s eyes', 'mood' => 'Most %s cat'];
    $rng = catfish_rng(crc32('show|' . $week));
    $keys = array_keys($traits);
    $trait = $keys[(int)floor($rng() * count($keys))];
    $values = array_keys(array_filter(CATFISH_TRAITS[$trait], fn($w) => $w >= 8));
    $value = $values[(int)floor($rng() * count($values))];
    return ['trait' => $trait, 'value' => $value, 'label' => sprintf($traits[$trait], $value)];
}

/**
 * Three judges (0 to 10 each, seeded by gnome, week and cat so a refresh cannot re-roll them) plus the theme and rarity bonuses.
 * Kibble, Yarn and play time are not part of it. Pure: returns ['score' => n, 'tier' => 'blue', 'judges' => [..]].
 */
function catfish_show_judge(int $uid, string $week, array $cat, array $theme): array
{
    $rng = catfish_rng(crc32('judge|' . $uid . '|' . $week . '|' . $cat['seed']));
    $judges = [(int)floor($rng() * 11), (int)floor($rng() * 11), (int)floor($rng() * 11)];
    $score = array_sum($judges) + (($cat[$theme['trait']] ?? '') === $theme['value'] ? CATFISH_SHOW_THEME_MATCH : 0) + (CATFISH_SHOW_RARITY[$cat['rarity']] ?? 0);
    return ['score' => $score, 'tier' => catfish_show_tier($score), 'judges' => $judges];
}

/** The ribbon tier a score earns. */
function catfish_show_tier(int $score): string
{
    foreach (CATFISH_RIBBONS as $t => [$min]) if ($score >= $min) return $t;
    return CATFISH_RIBBON_PART[0];
}

/** Enter (or swap) a cat for this week's show. One entry per gnome per week. */
function catfish_show_enter(int $uid, int $catId, int $slot = 1): array
{
    $row = q_one('SELECT id FROM cats WHERE id = ? AND user_id = ?', [$catId, $uid]);
    if (!$row) return [false, 'No such cat.'];
    return catfish_locked($uid, function () use ($uid, $catId, $slot) {
        catfish_show_settle($uid);   // an old entry gets its ribbon before a new one replaces it
        $s = catfish_state($uid); $meta = $s['meta'];
        $week = catfish_show_week();
        $now = ($meta['show']['week'] ?? '') === $week ? (array)$meta['show'] : ['week' => $week];
        if ($slot === 2) {
            if (empty($meta['show2on'])) return [false, 'Unlock the second entry with Yarn first.'];
            if ((int)($now['cat'] ?? 0) === 0) return [false, 'Enter your first cat before the second.'];
            if ((int)$now['cat'] === $catId) return [false, 'That cat is already entered.'];
            $now['cat2'] = $catId;
        } else {
            if ((int)($now['cat2'] ?? 0) === $catId) unset($now['cat2']);   // swapping the second entry in as the first
            $now['cat'] = $catId;
        }
        $meta['show'] = $now;
        catfish_meta_save($uid, $meta);
        return [true, 'Entered. The judges decide when the week ends.'];
    });
}

/** Judge an entry from a finished week and hand out its ribbon (one row per gnome and week; the unique key is the claim). Returns the ribbon row or null. Safe to call often. */
function catfish_show_settle(int $uid): ?array
{
    $seen = json_decode((string)q_val('SELECT meta FROM catfish_state WHERE user_id = ?', [$uid]), true);
    $e = is_array($seen) ? ($seen['show'] ?? null) : null;
    if (!is_array($e) || ($e['week'] ?? '') >= catfish_show_week()) return null;   // nothing entered, or the week is still running
    return catfish_locked($uid, function () use ($uid) {
        $s = catfish_state($uid); $meta = $s['meta'];
        $e = $meta['show'] ?? null;
        if (!is_array($e) || ($e['week'] ?? '') >= catfish_show_week()) return null;
        unset($meta['show']);
        catfish_meta_save($uid, $meta);
        $theme = catfish_show_theme((string)$e['week']);
        $row = null; $j = null;
        foreach ([(int)$e['cat'], (int)($e['cat2'] ?? 0)] as $cid) {   // the better of up to two entries wins the one ribbon for the week
            if ($cid < 1) continue;
            $r2 = q_one('SELECT * FROM cats WHERE id = ? AND user_id = ?', [$cid, $uid]);
            if (!$r2) continue;
            $j2 = catfish_show_judge($uid, (string)$e['week'], catfish_cat((int)$r2['seed']), $theme);
            if ($j === null || $j2['score'] > $j['score']) { $row = $r2; $j = $j2; }
        }
        if (!$row) return null;
        $r = ['user_id' => $uid, 'week' => (string)$e['week'], 'theme' => $theme['label'], 'cat_name' => (string)$row['name'], 'tier' => $j['tier'], 'score' => $j['score'], 'created_at' => now()];
        try { db_insert('cat_ribbons', $r); } catch (Throwable $ex) { return null; }   // already judged
        return $r;
    });
}

/** A gnome's ribbons, newest first. */
function catfish_ribbons(int $uid, int $limit = 20): array
{
    if (!catfish_ensure()) return [];
    return q('SELECT * FROM cat_ribbons WHERE user_id = ? ORDER BY week DESC LIMIT ' . (int)$limit, [$uid])->fetchAll();
}

/** Profile ribbon shelf: one slot per tier with a count, best tier first, and the latest ribbon under it. '' with no ribbons. */
function catfish_ribbon_shelf_html(int $uid): string
{
    if (!catfish_ensure()) return '';
    $n = q('SELECT tier, COUNT(*) FROM cat_ribbons WHERE user_id = ? GROUP BY tier', [$uid])->fetchAll(PDO::FETCH_KEY_PAIR);
    if (!$n) return '';
    $h = '';
    foreach (array_merge(array_keys(CATFISH_RIBBONS), [CATFISH_RIBBON_PART[0]]) as $t) {
        if (empty($n[$t])) continue;
        [$icon, $label] = catfish_ribbon_face($t);
        $h .= '<li class="cfbadge cfribbon" title="' . e($label) . '">' . catfish_img('ribbon-' . $t, $icon, '', 32) . '<small>' . e($label) . ' ×' . (int)$n[$t] . '</small></li>';
    }
    $last = catfish_ribbons($uid, 1)[0] ?? null;
    return '<p class="cfshelftitle"><b>🎀 Ribbon shelf</b></p><ul class="pzbadges cfbadges cfribbonshelf">' . $h . '</ul>'
        . ($last ? '<p class="muted"><small>Latest: ' . e($last['cat_name'] . ' · ' . $last['theme']) . '</small></p>' : '');
}

/** [icon, label] for a ribbon tier. */
function catfish_ribbon_face(string $tier): array
{
    return isset(CATFISH_RIBBONS[$tier]) ? [CATFISH_RIBBONS[$tier][1], CATFISH_RIBBONS[$tier][2]] : [CATFISH_RIBBON_PART[1], CATFISH_RIBBON_PART[2]];
}

/** The active cat on the garden page: a small tinted block and a line of flavour from its personality. '' when there is no cat or Cat Fish is closed. */
function catfish_garden_html(int $uid): string
{
    if (!catfish_open() || !catfish_ensure()) return '';
    $s = q_one('SELECT active_cat_id FROM catfish_state WHERE user_id = ?', [$uid]);   // read only: just visiting the garden must not create a Cat Fish row
    $cat = $s ? catfish_active($uid, $s) : null;
    if (!$cat) return '';
    $spot = ['lazy' => 'dozing on a warm bed', 'hyper' => 'zooming between the beds', 'sneaky' => 'hiding in the leaves', 'greedy' => 'guarding the harvest basket', 'dreamy' => 'watching the clouds'][$cat['mood']] ?? 'sitting in the garden';
    return '<p class="cfgarden">' . catfish_cat_html($cat, 64, 'idleA', false) . ' <small>' . e($cat['name']) . ' is ' . e($spot) . '. <a href="' . e(url('catfish.php')) . '">Cat Fish</a></small></p>';
}

/** Profile block: a gnome's Cat Fish badges as a list, '' if none or Cat Fish is closed. */
function catfish_badges_html(int $uid): string
{
    if (!catfish_open()) return '';
    $h = '';
    foreach (catfish_badges($uid) as $key => [$icon, $label]) $h .= '<li class="cfbadge" title="' . e($label) . '">' . catfish_img('badge-' . $key, $icon, '', 32) . '<small>' . e($label) . '</small></li>';
    $shelf = catfish_ribbon_shelf_html($uid);
    return $h === '' && $shelf === '' ? '' : ($h === '' ? '' : '<ul class="pzbadges cfbadges">' . $h . '</ul>') . $shelf;
}

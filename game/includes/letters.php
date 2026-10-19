<?php
declare(strict_types=1);
/**
 * Lost Letters: a daily riddle that sends the gnome to a real road stop (a town or a village).
 * - One target per gnome per day, chosen from road stops in regions the gnome can reach (never Mossbottom).
 *   The target is stored in game_state, so it stays put all day even if the gnome levels up.
 * - The riddle is built from the place's own facts (region, landscape, the land two steps out). Clues 1 and 2 show at once;
 *   clue 3 and the postmark's first letter come with the "Read the postmark" hint.
 * - Standing at the target and lifting the stone claims the letter: 80 Petals (+40 if the postmark was read), 15 XP,
 *   a warm letter, one a day (40 Petals instead if the postmark was read). Looking in the wrong place costs nothing.
 */

require_once __DIR__ . '/games.php';
require_once __DIR__ . '/roads.php';
require_once __DIR__ . '/adventure.php';
require_once __DIR__ . '/adventure_data.php';
require_once __DIR__ . '/explore.php';   // stop_near_land()

const LETTER_PETALS = 80;
const LETTER_HINT_PETALS = 40;   // the reward when the postmark hint was used (reading it halves the prize)
const LETTER_XP = 15;

/** Riddle lines about the region (%s = the region's Gnomish name). */
const LETTER_REGION = [
    'It lies in the land of %s.',
    'Somewhere in %s, where the roads run gentle.',
    'Out in %s, a fair walk from any hearth.',
];

/** What the landscape looks like, around the place itself (2+ per landscape). */
const LETTER_LANDS = [
    'coast' => ['where the sea breathes on every side', 'where the salt wind never stops talking'],
    'mountain' => ['where the paths climb steep and the stone remembers everything', 'where the air runs thin and the echoes are loud'],
    'forest' => ['where green shade hides something rustling', 'under leaves so thick the sun is only a rumour'],
    'desert' => ['where the heat shimmers and the sand keeps its secrets', 'under a sky that burns by day and glitters by night'],
    'rainforest' => ['where the leaves drip and wild birds call', 'among flowers bigger than a gnome, in a soft endless drizzle'],
    'grassland' => ['where grass waves on every side', 'where the grass stands taller than any gnome'],
    'wetland' => ['where the reeds whisper and the mist hangs low', 'where something plops in the reeds, unseen'],
    'tundra' => ['where the snow lies wide and quiet', 'where lichen crunches underfoot and the auroras dance'],
    'island' => ['where warm sand meets the coral shallows', 'where the palms sway and the breeze smells of coconut'],
];

/** What the land two steps off the road is like (clue 3). */
const LETTER_NEAR = [
    'coast' => 'the sea rolls in',
    'mountain' => 'mountains rise',
    'forest' => 'the forest closes in',
    'desert' => 'the dunes stretch away',
    'rainforest' => 'the rainforest thickens',
    'grassland' => 'the grass rolls on for miles',
    'wetland' => 'the reeds and the mist begin',
    'tundra' => 'the snowfields begin',
    'island' => 'the warm shallows begin',
];

const LETTER_KIND_VILLAGE = ['a quiet village', 'a sleepy village of hedges and chimneys'];
const LETTER_KIND_TOWN = ['a busy little town', 'a bustling town with a market bell'];

/** Warm letters from townsfolk, found at the target. {who} = the sender, {place} = the place name. */
const LETTER_NOTES = [
    'Dearest friend, the sun came out this morning just for us. Keep your boots dry and your kettle on. With love from all of {place}. — {who}',
    'I’ve been meaning to write since the thaw. The apples are in, the lanterns are lit, and everyone asks after you. Do visit. — {who}, {place}',
    'If you’re reading this, you found my note at last! I hid it under the stone so the wind wouldn’t carry it off. Thank you for coming all this way. — {who}',
    'A little thank-you from {place}: a warm loaf, a kind word, and the best seat by the fire kept for you. — {who}',
    'Hello, stranger! Word from {place} is that the clover is thick and the bees are merry. Come and see us sometime. — {who}',
    'Forgive the smudged ink, I was laughing at a frog. The road to {place} is gentle, and we keep a light on for travellers. — {who}',
    'My dear, I feared this letter would go astray in the wild, so I am glad it reached you. Tea is waiting in {place}. — {who}',
    'Good news from {place}: the wishing well is full, the children have learned to whistle, and you are missed. — {who}',
];
const LETTER_SENDERS = ['Tansy', 'Old Hobb', 'Marigold', 'Dunstan', 'Fennel', 'Oriel', 'Pippa', 'Sorrel'];

/** Pick one entry, stable for the same seed and salt. */
function letters_pick(array $list, int $seed, string $salt): string
{
    return (string)$list[(crc32($seed . '|' . $salt) & 0x7fffffff) % count($list)];
}

/** Riddle clues for one place: ['one' => region, 'two' => landscape and kind, 'three' => the land two steps out]. */
function letters_clues(array $loc, array $region, int $seed): array
{
    $land = (string)($loc['landscape'] ?? '');
    if (!isset(LETTER_LANDS[$land])) $land = 'grassland';
    $near = stop_near_land($loc);
    if (!isset(LETTER_NEAR[$near])) $near = 'grassland';
    $kind = $loc['kind'] === 'market' ? LETTER_KIND_TOWN : LETTER_KIND_VILLAGE;
    return [
        'one' => sprintf(letters_pick(LETTER_REGION, $seed, 'region'), (string)$region['gnomish_name']),
        'two' => ucfirst(letters_pick(LETTER_LANDS[$land], $seed, 'land')) . '. It is ' . letters_pick($kind, $seed, 'kind') . '.',
        'three' => 'Two steps out, ' . LETTER_NEAR[$near] . '.',
    ];
}

/** The first letter of a place's name, for the postmark. */
function letters_initial(string $name): string
{
    return mb_strtoupper(mb_substr($name, 0, 1));
}

/** Letters the gnome can still claim today (the setting, less today's finds). Counts only finished letters, not an open one. */
function letters_left(int $uid): int
{
    $max = (int)setting('letters_per_day');
    $used = (int)q_val('SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = ? AND day = ?', [$uid, 'letters', game_day()]);
    return max(0, $max - $used);
}

/**
 * The road stop chosen for this gnome today: deterministic per (user, day). Road stops (villages or towns) in regions
 * whose min_level the gnome has reached; never Mossbottom. Null if there's nowhere to send them.
 */
function letters_pick_target(array $u): ?int
{
    $uid = (int)$u['id'];
    $level = (int)($u['level'] ?? 1);
    $regions = q('SELECT id, min_level FROM regions WHERE gnomish_name <> ? ORDER BY sort_order, id', [HUB_REGION])->fetchAll();
    $reach = array_values(array_filter($regions, fn($r) => (int)$r['min_level'] <= $level));   // v0.9.1a: locked regions never
    if (!$reach && $regions) {
        usort($regions, fn($a, $b) => (int)$a['min_level'] <=> (int)$b['min_level']);
        $reach = [$regions[0]];   // a brand-new world or a very low level: the nearest region
    }
    if (!$reach) return null;
    $ids = array_map(fn($r) => (int)$r['id'], $reach);
    $ph = implode(',', array_fill(0, count($ids), '?'));
    $stops = array_map('intval', q("SELECT id FROM locations WHERE kind IN ('village', 'market') AND region_id IN ($ph) ORDER BY id", $ids)->fetchAll(PDO::FETCH_COLUMN));
    $stops = array_values(array_filter($stops, fn($id) => on_road($id)));
    if (!$stops) return null;
    return $stops[(crc32($uid . '|' . game_day()) & 0x7fffffff) % count($stops)];
}

/**
 * Today's state for this gnome: ['day', 'target', 'hint', 'found', 'letter']. A new day (or no state yet) picks a new target and saves it.
 * Null only when the world has no road stops to send anyone to.
 */
function letters_today(array $u): ?array
{
    $uid = (int)$u['id'];
    $day = game_day();
    $s = game_state($uid, 'letters');
    if ($s && ($s['day'] ?? '') === $day && !empty($s['target'])) return $s;
    $target = letters_pick_target($u);
    if (!$target) return null;
    $s = ['day' => $day, 'target' => $target, 'hint' => false, 'found' => false, 'letter' => ''];
    game_save($uid, 'letters', $s);
    return $s;
}

/** Everything the page and the World box need about today's letter, or null. */
function letters_info(array $u): ?array
{
    $s = letters_today($u);
    if (!$s) return null;
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)$s['target']]);
    if (!$loc) return null;
    $region = $loc['region_id'] ? q_one('SELECT * FROM regions WHERE id = ?', [(int)$loc['region_id']]) : null;
    $region ??= ['gnomish_name' => 'the Hollow'];
    $seed = crc32((int)$u['id'] . '|' . game_day());
    return ['state' => $s, 'loc' => $loc, 'region' => $region, 'clues' => letters_clues($loc, $region, $seed)];
}

/** Read the postmark: the first letter of the place's name (clue 3 shows with it). The reward drops to 40 Petals. */
function letters_hint(array $u): array
{
    $uid = (int)$u['id'];
    $s = letters_today($u);
    if (!$s) return [false, 'The post is quiet today. Come back after the daily reset.'];
    if ($s['found']) return [false, 'You already have today’s letter.'];
    if ($s['hint']) return [false, 'You’ve already read the postmark.'];
    $s['hint'] = true;
    game_save($uid, 'letters', $s);
    $loc = q_one('SELECT name FROM locations WHERE id = ?', [(int)$s['target']]);
    return [true, 'The postmark begins with “' . letters_initial((string)($loc['name'] ?? '?')) . '”.'];
}

/**
 * Lift the stone. At the target: claim the letter (once a day). Anywhere else: a gentle nudge, no cost.
 */
function letters_look(array $u): array
{
    $uid = (int)$u['id'];
    $s = letters_today($u);
    if (!$s) return [false, 'The post is quiet today. Come back after the daily reset.'];
    if ($s['found']) return [false, 'You’ve already read today’s letter. Another one comes tomorrow.'];
    $here = player_node($u);
    if ((int)$here['id'] !== (int)$s['target']) {
        $info = letters_info($u);
        return [false, 'Not here. The letter mentions ' . ($info['region']['gnomish_name'] ?? 'the Hollow') . ', so keep looking.'];
    }
    // The open letter is saved as a game_state row, which game_plays_left would count as a play, so count finished letters directly.
    if (letters_left($uid) <= 0) return [false, 'You’ve already had today’s letter. Another one comes after the daily reset.'];

    $loc = q_one('SELECT name FROM locations WHERE id = ?', [(int)$s['target']]);
    $place = (string)($loc['name'] ?? 'the Hollow');
    $note = str_replace(['{who}', '{place}'], [LETTER_SENDERS[random_int(0, count(LETTER_SENDERS) - 1)], $place], LETTER_NOTES[random_int(0, count(LETTER_NOTES) - 1)]);
    $petals = game_petals($s['hint'] ? LETTER_HINT_PETALS : LETTER_PETALS);
    $xp = (string)setting('games_give_xp') === '1' ? LETTER_XP : 0;   // v0.9.1: game XP only when games_give_xp is on

    db()->beginTransaction();
    try {
        $old = (string)q_val('SELECT state FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'letters']);
        $s['found'] = true;
        $s['letter'] = $note;
        if (q('UPDATE game_state SET state = ?, updated_at = ? WHERE user_id = ? AND game = ? AND state = ?', [json_encode($s), now(), $uid, 'letters', $old])->rowCount() !== 1
            || !str_contains($old, '"found":false')) {   // a double tap: the other request already claimed it
            db()->rollBack();
            return [false, 'You’ve already read today’s letter.'];
        }
        q('UPDATE users SET coins = coins + ? WHERE id = ?', [$petals, $uid]);
        if ($xp) add_xp($uid, $xp);
        game_score($uid, 'letters', 1);
        db()->commit();
        $en = game_energy($uid, true);   // v1.4.7: every game gives a little energy
    } catch (Throwable $e) {
        db()->rollBack();
        throw $e;
    }
    prize('📬', 'A letter at last!', '+' . money($petals), array_values(array_filter([$note, $xp ? '+' . $xp . ' XP' : '', ($en ?? '') !== '' ? trim($en) . ' energy' : ''])));
    return [true, 'You found the letter at ' . $place . '.'];
}

/**
 * The small box for the World page (echo it there). At the target: a stone to lift. Pending elsewhere: a reminder. Else ''.
 */
function letters_box(array $u): string
{
    $info = letters_info($u);
    if (!$info || $info['state']['found']) return '';
    $here = player_node($u);
    $url = e(url('letters.php'));
    if ((int)$here['id'] === (int)$info['state']['target']) {
        return '<div class="box letterbox letter-find">'
            . '<p class="letter-seal" aria-hidden="true">📬</p>'
            . '<p>📬 Something’s tucked under a stone here…</p>'
            . '<form method="post" action="' . $url . '" class="inline">' . csrf_field()
            . '<input type="hidden" name="do" value="look"><button class="btn small">Lift the stone</button></form>'
            . '</div>';
    }
    return '<p class="box letter-reminder">📬 A Lost Letter is still waiting somewhere in the Hollow. <a href="' . $url . '">Read today’s riddle</a>.</p>';
}

/**
 * v1.4.7: render-only. The lost letter as an inline SVG envelope. Closed and sealed while it is lost; flap open and paper
 * lifted once found. $initial = the postmark's first letter once the hint was read ('' = still a question mark).
 */
function letters_envelope_svg(bool $open, string $initial = ''): string
{
    $pm = $initial !== '' ? '<text class="pmtxt" x="150" y="114" text-anchor="middle">' . e($initial) . '</text>' : '<text class="pmtxt q" x="150" y="114" text-anchor="middle">?</text>';
    return '<svg class="envsvg" viewBox="0 -12 220 148" role="img" aria-label="' . ($open ? 'An opened letter' : 'A sealed letter') . '">'
        . '<ellipse cx="110" cy="132" rx="84" ry="6" fill="#000" opacity=".15"/>'
        . '<circle class="envglow" cx="110" cy="48" r="74" fill="#ffe28a"/>'
        . '<rect x="20" y="42" width="180" height="86" rx="6" fill="#d9bf86"/>'
        . '<path class="envflapo" d="M20 42H200L110 -6Z" fill="#e6cf98" stroke="#cdb170" stroke-width="1.5" stroke-linejoin="round"/>'
        . '<g class="envpaper"><rect x="34" y="54" width="152" height="74" rx="3" fill="#fffaf0" stroke="#e6d9b8"/><g fill="#d9cfb4"><rect x="48" y="66" width="84" height="4" rx="2"/><rect x="48" y="77" width="112" height="4" rx="2"/><rect x="48" y="88" width="96" height="4" rx="2"/></g><path d="M150 62l4 3.500 4-3.500v9l-4-2-4 2z" fill="#d94a3a"/></g>'
        . '<path d="M20 46L110 100L200 46V122a6 6 0 0 1-6 6H26a6 6 0 0 1-6-6Z" fill="#f1e2bd"/>'
        . '<path d="M20 126L90 80M200 126L130 80" stroke="#d6bb82" stroke-width="1.500" fill="none"/>'
        . '<g fill="#cdb170"><rect x="40" y="104" width="52" height="4" rx="2"/><rect x="40" y="114" width="36" height="4" rx="2"/></g>'
        . '<rect x="161" y="88" width="28" height="32" rx="1.500" fill="#fff" stroke="#c97a3a" stroke-width="1.200" stroke-dasharray="2 1.200"/><rect x="165" y="92" width="20" height="24" fill="#6aa84f"/><path d="M175 112c-6-1-7-8-1-13 6 3 7 10 1 13z" fill="#d8efb5"/>'
        . '<g class="envpm' . ($initial !== '' ? ' got' : '') . '"><circle cx="150" cy="108" r="14" fill="none" stroke="#7a6a4a" stroke-width="1.400"/><path d="M130 104q5-4 10 0t10 0M130 111q5-4 10 0t10 0" fill="none" stroke="#7a6a4a" stroke-width="1" opacity=".55"/>' . $pm . '</g>'
        . '<g class="envflapc"><path d="M20 42H200L110 100Z" fill="#ecd9a6" stroke="#cdb170" stroke-width="1.500" stroke-linejoin="round"/><path d="M28 45H192" stroke="#fff6dc" stroke-width="1.500" opacity=".7"/><circle cx="110" cy="88" r="11.500" fill="#b8312a"/><circle cx="110" cy="88" r="8" fill="none" stroke="#e86a5c" stroke-width="1.200"/><path d="M110 93c-5-1-6-6-1-10 5 2 6 7 1 10z" fill="#f3a89d"/></g>'
        . '</svg>';
}

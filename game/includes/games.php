<?php
declare(strict_types=1);
/**
 * Mini-games (v0.7.11+). Every game is played on the server: the page only ever sees what the
 * player has uncovered, and moves are checked here, so the browser can't cheat.
 * - Plays per day reset with the Job Board day (midnight Hollow time).
 * - Scores go into game_scores; the hub shows this week's best.
 * - A game in progress lives in game_state (one row per player and game).
 */

/** key => [name, icon, page, blurb, plays-per-day setting] */
const GAMES = [
    'worms' => ['Worm Hunting', '🪱', 'worms.php', 'Dig the old mine’s soft ground for worms, fossils and gems. Wriggle clues show where worms are hiding, and worms wander between digs.', 'worm_rounds_per_day'],
    'memory' => ['Seed Memory', '🃏', 'memory.php', 'Find the matching seed packets. Easy is a quick 4 × 4; hard is a 6 × 6 brain-bender with a bigger prize.', 'memory_plays_per_day'],
    'race' => ['Snail Race', '🐌', 'race.php', 'A race every hour on the hour. Back a snail with a few Petals and cheer it home with the whole Hollow.', 'race_bets_per_day'],
    'spit' => ['Seed Spitting', '🍉', 'spit.php', 'Aim, check the wind and spit a melon seed as far as you can. Three goes a day. Grit gives you puff, Nimble steadies you against the wind.', 'spit_plays_per_day'],
    'mushroom' => ['Mushroom Sweeper', '🍄', 'mushroom.php', 'Clear the forest floor without stepping on a toadstool. The numbers tell you how many are hiding nearby.', 'mush_plays_per_day'],   // v0.8.1
    'letters' => ['Lost Letters', '🗺️', 'letters.php', 'A daily riddle: work out which town or village it describes, go there, and lift the stone to find the letter.', 'letters_per_day'],   // v0.8.1
    'pest' => ['Pest Patrol', '🪰', 'pest.php', 'Flick aphids, gnats, caterpillars and slugs off a growing plant before they chew its leaves away. Keep a bug net handy for butterflies.', 'pest_plays_per_day'],   // v1.4.8:
    'marrow' => ['Guess the Weight', '⚖️', 'marrow.php', 'Old Moss grows a giant crop every day. Guess its weight EXACTLY to win the growing jackpot.', 'marrow_guesses_per_day'],
];

function game_day(): string
{
    return job_period_key('daily');
}

/** v0.9.1a: a little energy for playing: +1 (+2 for a good game), at most games_energy_cap a game day. Returns ' ⚡+1' or ''. */
/** v2.0.88: game XP with the Puzzle Pals tinker perk (+1% per unit, cap +6%). The same number when take-along is off. */
function games_pal_xp(int $uid, int $xp): int
{
    if ($xp <= 0 || setting('ppal_party') !== '1') return $xp;
    require_once __DIR__ . '/puzzle_pals.php';
    return ppal_xp($uid, $xp);
}

function game_energy(int $uid, bool $good): string
{
    $cap = (int)setting('games_energy_cap');
    if ($cap <= 0) return '';
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return '';
    $day = game_day();
    $cur = (string)($u['game_energy_day'] ?? '');
    $got = 0;
    if (strncmp($cur, $day . ':', strlen($day) + 1) === 0) $got = (int)substr($cur, strlen($day) + 1);
    $n = $cap >= 100 ? ($good ? 2 : 1) : min($good ? 2 : 1, $cap - $got);   // v1.6.2: 100+ = no daily limit (a full bar still takes none)
    if ($n <= 0) return '';
    $max = max_energy($u);
    // whole numbers written into the SQL so the comparison is numeric (SQLite compares bound values as text)
    // only when below max (a full bar spends no cap), and guarded by the day total read (two games at once can't beat the cap)
    $rows = q('UPDATE users SET game_energy_day = ?, energy = CASE WHEN energy + ' . $n . ' > ' . (int)$max . ' THEN ' . (int)$max . ' ELSE energy + ' . $n . ' END
               WHERE id = ? AND energy < ' . (int)$max . " AND COALESCE(game_energy_day, '') = ?", [$day . ':' . ($got + $n), $uid, $cur])->rowCount();
    return $rows > 0 ? ' ⚡+' . $n : '';
}

function game_plays_left(int $uid, string $game): int
{
    $max = (int)setting(GAMES[$game][4]);
    if ($game === 'race') return max(0, $max - (int)q_val('SELECT COUNT(*) FROM snail_bets WHERE user_id = ? AND day = ?', [$uid, game_day()]));
    if ($game === 'letters') { require_once __DIR__ . '/letters.php'; return letters_left($uid); }   // v0.8.1: an open letter isn't a used play
    if ($game === 'marrow') return max(0, $max - (int)q_val('SELECT COUNT(*) FROM marrow_guesses WHERE user_id = ? AND day = ?', [$uid, game_day()]));
    $used = (int)q_val('SELECT COUNT(*) FROM game_scores WHERE user_id = ? AND game = ? AND day = ?', [$uid, $game, game_day()]);
    $live = game_state($uid, $game) ? 1 : 0;   // a round in progress counts as a play
    return max(0, $max - $used - $live);
}

function game_state(int $uid, string $game): ?array
{
    $s = q_val('SELECT state FROM game_state WHERE user_id = ? AND game = ?', [$uid, $game]);
    return $s ? (json_decode((string)$s, true) ?: null) : null;
}

function game_save(int $uid, string $game, array $state): void
{
    if (q('UPDATE game_state SET state = ?, updated_at = ? WHERE user_id = ? AND game = ?', [json_encode($state), now(), $uid, $game])->rowCount() === 0) {
        db_insert('game_state', ['user_id' => $uid, 'game' => $game, 'state' => json_encode($state), 'updated_at' => now()]);
    }
}

function game_clear(int $uid, string $game): void
{
    q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, $game]);
}

function game_score(int $uid, string $game, int $score): void
{
    db_insert('game_scores', ['user_id' => $uid, 'game' => $game, 'score' => $score, 'day' => game_day(), 'week' => job_period_key('weekly'), 'played_at' => now()]);
}

/** This week's best score per player, top N. */
function game_top(string $game, int $n = 5): array
{
    return q("SELECT COALESCE(u.gnome_name, u.username) AS name, MAX(s.score) AS best FROM game_scores s JOIN users u ON u.id = s.user_id
              WHERE s.game = ? AND s.week = ? AND u.banned = 0 GROUP BY s.user_id, u.gnome_name, u.username ORDER BY best DESC LIMIT " . (int)$n,
        [$game, job_period_key('weekly')])->fetchAll();
}

function game_best(int $uid, string $game): int
{
    return (int)q_val('SELECT MAX(score) FROM game_scores WHERE user_id = ? AND game = ?', [$uid, $game]);
}

/* v1.4.1: every game page has two tabs, Play (default) and Rules (?t=rules). The Rules tab is a short list of rows: [emoji, label, one short sentence]. */
function game_tab(): string
{
    return ($_GET['t'] ?? '') === 'rules' ? 'rules' : 'play';
}

/** The Play / Rules tab bar for a game page (loads in place like the other tabs). */
function game_tabs_html(string $page): string
{
    $t = game_tab();
    return '<nav class="tabs gametabs" aria-label="Game">'
        . '<a href="' . e(url($page)) . '"' . ($t === 'play' ? ' class="on" aria-current="page"' : '') . '>🎮 Play</a>'
        . '<a href="' . e(url($page . '?t=rules')) . '"' . ($t === 'rules' ? ' class="on" aria-current="page"' : '') . '>📖 Rules</a></nav>';
}

/** The Rules tab: rows of [emoji, label, text] (all plain text, escaped here). Empty rows (null / false) are skipped. */
function game_rules_html(array $rules): string
{
    $h = '<div class="box rulesbox"><ul class="rules">';
    foreach ($rules as $r) {
        if (!$r) continue;
        $h .= '<li><span class="ricon" aria-hidden="true">' . e($r[0]) . '</span><span class="rtext"><b>' . e($r[1]) . '</b> ' . e($r[2]) . '</span></li>';
    }
    return $h . '</ul></div>';
}

/** The "a little energy" rule row, or null when games give none. $good = what counts as a good game. */
function game_energy_rule(string $good): ?array
{
    $cap = (int)setting('games_energy_cap');
    if ($cap <= 0) return null;
    return ['⚡', 'Energy.', 'Playing gives you +1 energy, or +2 ' . $good . ($cap >= 100 ? '.' : ' (up to ' . $cap . ' a day).')];   // v1.6.2
}

// ---------------- Worm Hunting ----------------

const GAMES_PAGE = "When the garden is growing on its own, try the [b]Games[/b] page. Each game has a few plays a day and a weekly high-score table.\n\n"
    . "🪱 [b]Worm Hunting:[/b] dig the old mine’s soft ground. Each square you dig shows how many worms are in the squares around it. Worms wander a square now and then; a shivering square has one next to it. Fossils and crystals lie deeper: tap once to loosen, again to pull them out. "
    . "A rock pick gives you more digs and breaks boulders; a fine one even finds geodes. Earthworms improve soil life, or make worm castings in a worm bin.\n"
    . "🃏 [b]Seed Memory:[/b] find the matching seed packets in as few turns as you can. Easy or hard.\n"
    . "🐌 [b]Snail Race:[/b] a race every hour on the hour. Back a snail with a few Petals; long shots pay more.\n"
    . "🍉 [b]Seed Spitting:[/b] drag back like a slingshot (or use the sliders) to set angle and power, mind the wind, and spit. 30, 45 and 60 cm pay more. Three goes a day. Grit gives you puff, Nimble steadies you against the wind.\n"
    . "🍄 [b]Mushroom Sweeper:[/b] clear the forest floor without stepping on a toadstool. The numbers tell you how many are hiding nearby.\n"
    . "🗺️ [b]Lost Letters:[/b] a daily riddle describes a town or village. Work out which, walk there and lift the stone to find the letter.\n"
    . "🪰 [b]Pest Patrol:[/b] a plant grows and pests pop up on its leaves. Tap to flick them off before they chew a leaf away, and don't tap bare leaves: they bruise. Quick clean flicks build a combo. A bug net in your satchel lets you catch a passing butterfly.\n"   // v1.4.8:
    . "⚖️ [b]Guess the Weight:[/b] Old Moss grows a giant crop every day. Guess its weight exactly to win the growing jackpot.\n\n"
    . "The [b]🏆 Contests[/b] tab has the Village Show, Garden of the Month, the Grand Harvest Fair and, in October, pumpkin carving.";   // v0.8.8: all seven games

const WORM_SIZE = 6;
/** What can be in a square: [label, icon, item slug or null, score] */
const WORM_FINDS = [
    'worm' => ['Earthworm', '🪱', 'earthworm', 1],
    'night' => ['Nightcrawler (3 worms!)', '🐛', 'earthworm', 3],
    'rock' => ['Boulder', '🪨', 'flint', 0],
    'clay' => ['River clay', '🟫', 'river-clay', 0],
    'fossil' => ['Fossil shell', '🐚', 'fossil-shell', 5],
    'gem' => ['Rock crystal', '💎', 'rock-crystal', 8],
    'geode' => ['Geode', '🔮', 'geode', 12],
    'empty' => ['Just soil', '·', null, 0],
];

function worm_new_board(int $uid): array
{
    $n = WORM_SIZE;
    $cells = array_fill(0, $n * $n, 'empty');
    // Worms live in 2-3 little clusters
    $worms = (int)setting('worm_count');
    $clusters = random_int(2, 3);
    $placed = 0;
    for ($c = 0; $c < $clusters && $placed < $worms; $c++) {
        $x = random_int(0, $n - 1);
        $y = random_int(0, $n - 1);
        $tries = 0;
        while ($placed < (int)ceil($worms * ($c + 1) / $clusters) && $tries++ < 60) {
            $xx = max(0, min($n - 1, $x + random_int(-1, 1)));
            $yy = max(0, min($n - 1, $y + random_int(-1, 1)));
            if ($cells[$yy * $n + $xx] === 'empty') {
                $cells[$yy * $n + $xx] = 'worm';
                $placed++;
            }
            if (random_int(1, 3) === 1) { $x = $xx; $y = $yy; }   // clusters wander a little
        }
    }
    $pick = tool_tier($uid, 'pick');
    $add = ['night' => 1, 'rock' => 4, 'clay' => 2, 'fossil' => 1, 'gem' => random_int(0, 1), 'geode' => $pick >= 3 && random_int(1, 3) === 1 ? 1 : 0];
    foreach ($add as $what => $count) {
        for ($i = 0; $i < $count; $i++) {
            $f = array_keys($cells, 'empty', true);
            if ($f) $cells[$f[array_rand($f)]] = $what;
        }
    }
    return ['cells' => $cells, 'dug' => [], 'digs' => worm_digs($uid), 'score' => 0, 'found' => [],
        'seed' => random_int(1, 2147483646), 'step' => 0, 'loose' => [], 'shiver' => null, 'last' => null];   // v1.4.0: seed for the wandering worms, loosened squares, the square that shivers, the last dug
}

/** Digs per round: base + 2 per rock pick tier. */
function worm_digs(int $uid): int
{
    return (int)setting('worm_digs') + 2 * tool_tier($uid, 'pick');
}

/** Worms (and nightcrawlers) in the 8 squares around one square. */
function worm_clue(array $cells, int $i): int
{
    $n = WORM_SIZE;
    $x = $i % $n;
    $y = intdiv($i, $n);
    $c = 0;
    for ($dy = -1; $dy <= 1; $dy++) for ($dx = -1; $dx <= 1; $dx++) {
        if (!$dx && !$dy) continue;
        $xx = $x + $dx;
        $yy = $y + $dy;
        if ($xx >= 0 && $yy >= 0 && $xx < $n && $yy < $n && in_array($cells[$yy * $n + $xx], ['worm', 'night'], true)) $c++;
    }
    return $c;
}

/** v1.4.0: finds that lie in the deeper layer: the first dig only loosens the soil (and costs the dig), the second pulls the find out (free). */
const WORM_DEEP = ['fossil', 'gem', 'geode'];

/**
 * v1.4.0: between digs one worm may wriggle one square (never onto a dug square or another find). Chance per worm is worm_wander %,
 * decided by the board's own seed and the dig number, so it is repeatable and the page can't predict it. The square it left
 * shivers on the next page ($s['shiver']): a hint that a worm is right next to it. Clues already given are not redrawn: worms wander.
 */
function worm_wander(array &$s): void
{
    $s['shiver'] = null;
    $pct = max(0, min(100, (int)setting('worm_wander')));
    if ($pct <= 0 || !isset($s['seed']) || (int)($s['step'] ?? 0) <= 0) return;   // (a dig begun before 1.4.0 has no seed: its worms stay put)
    $n = WORM_SIZE;
    $dirs = [[0, -1], [1, 0], [0, 1], [-1, 0]];
    foreach ($s['cells'] as $i => $what) {
        if ($what !== 'worm' || isset($s['dug'][$i])) continue;
        $h = crc32($s['seed'] . ':' . $s['step'] . ':' . $i);
        if ($h % 100 >= $pct) continue;
        $x = $i % $n; $y = intdiv($i, $n);
        for ($d = 0; $d < 4; $d++) {
            [$dx, $dy] = $dirs[(intdiv($h, 100) + $d) % 4];
            $xx = $x + $dx; $yy = $y + $dy;
            if ($xx < 0 || $yy < 0 || $xx >= $n || $yy >= $n) continue;
            $j = $yy * $n + $xx;
            if ($s['cells'][$j] !== 'empty' || isset($s['dug'][$j])) continue;
            $s['cells'][$j] = 'worm';
            $s['cells'][$i] = 'empty';
            $s['shiver'] = $i;
            return;   // one wriggle a dig
        }
    }
}

function worm_start(array $u): array
{
    $uid = (int)$u['id'];
    if (game_state($uid, 'worms')) return [true, 'Your dig is still waiting for you.'];
    if (game_plays_left($uid, 'worms') <= 0) return [false, 'The mine’s soft ground needs to rest. Come back after the daily reset.'];
    game_save($uid, 'worms', worm_new_board($uid));
    return [true, '⛏️ You climb down into the soft ground of the old mine. ' . worm_digs($uid) . ' digs before your arms give out!'];
}

function worm_dig(array $u, int $i): array
{
    $uid = (int)$u['id'];
    if ($i < 0 || $i >= WORM_SIZE * WORM_SIZE) return [false, 'That’s outside the dig.'];
    // v1.2.2: lock this gnome, then read the board inside the transaction (two logins can't dig the same square / double-collect)
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    $s = game_state($uid, 'worms');
    if (!$s) { db()->rollBack(); return [false, 'Start a dig first.']; }
    if (isset($s['dug'][$i])) { db()->rollBack(); return [false, 'You’ve already dug there.']; }
    worm_wander($s);   // v1.4.0: a worm may have wriggled since the last dig
    $s['step'] = (int)($s['step'] ?? 0) + 1;
    $what = $s['cells'][$i];
    $cost = 1;
    if ($what === 'rock' && !tool_tier($uid, 'pick')) $cost = 2;   // boulders are hard work without a rock pick
    // v1.4.0: deeper layer. A fossil, crystal or geode takes two taps: loosen it (this is the dig), then pull it out (free). Not when it was the last dig.
    if (in_array($what, WORM_DEEP, true)) {
        if (empty($s['loose'][$i]) && $s['digs'] - $cost > 0) {
            $s['loose'][$i] = true;
            $s['digs'] -= $cost;
            $s['last'] = $i;
            game_save($uid, 'worms', $s);
            db()->commit();
            return [true, '⛏️ The soil gives way and something hard glints below. Tap it again to pull it out (that one is free)!'];
        }
        if (!empty($s['loose'][$i])) $cost = 0;
    }
    $s['digs'] -= $cost;
    $s['last'] = $i;
    $s['dug'][$i] = worm_clue($s['cells'], $i);
    [$label, $icon, $slug, $points] = WORM_FINDS[$what];
    $qty = $what === 'night' ? 3 : 1;
    $msg = $icon . ' ' . $label . '.';
    if ($slug && !($what === 'rock' && !tool_tier($uid, 'pick'))) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if ($id) {
            give_item($uid, $id, $qty);
            $s['found'][$slug] = ($s['found'][$slug] ?? 0) + $qty;
        }
    } elseif ($what === 'rock') {
        $msg = '🪨 A boulder! Without a rock pick it takes two digs and breaks into nothing useful.';
    }
    $s['score'] += $points;
    if ($s['digs'] <= 0) {
        $r = worm_finish($u, $s, $msg);
        if ($r[0]) db()->commit(); else db()->rollBack();
        return $r;
    }
    game_save($uid, 'worms', $s);
    db()->commit();
    return [true, $msg];
}

function worm_finish(array $u, array $s, string $last = ''): array
{
    $uid = (int)$u['id'];
    // v1.2.2: the state row is the claim: only the call that deletes it pays out. Inside worm_dig's transaction the caller commits/rolls back.
    $own = !db()->inTransaction();
    if ($own) db()->beginTransaction();
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'worms'])->rowCount() !== 1) {
        if ($own) db()->rollBack();
        return [false, 'That dig is already over.'];
    }
    game_score($uid, 'worms', (int)$s['score']);
    $coins = game_petals((int)$s['score'] * (int)setting('worm_coins_per_point'));
    if ($coins) give_petals((int)$uid, (int)$coins);
    $xp = (string)setting('games_give_xp') === '1' ? max(1, intdiv((int)$s['score'], 2)) : 0;   // v0.9.1: game XP only when games_give_xp is on
    if ($xp) add_xp($uid, games_pal_xp((int)$uid, (int)$xp));
    $en = game_energy($uid, (int)$s['score'] >= 10);   // v0.9.1a
    if ($own) db()->commit();
    $found = [];
    foreach ($s['found'] as $slug => $n) $found[] = $n . ' × ' . q_val('SELECT name FROM items WHERE slug = ?', [$slug]);
    prize('🪱', 'Your arms are done digging!', 'Score: ' . (int)$s['score'],
        array_merge($found ?: ['Nothing but soil this time'], ['+' . money($coins)], $xp ? ['+' . $xp . ' XP'] : [], $en !== '' ? [trim($en) . ' energy'] : []));
    return [true, $last];
}

/** The earthworm item, a recipe that uses it, and the Almanac page. Adds only. */
function ensure_games(): void
{
    ensure_race_secret();
    // v0.7.12: the Games page now covers all three games
    q("UPDATE encyclopedia_entries SET body = ? WHERE title = 'Games' AND chapter = 'General' AND body NOT LIKE '%Snail%'", [GAMES_PAGE]);
    q("UPDATE encyclopedia_entries SET body = ? WHERE title = 'Games' AND chapter = 'General' AND body LIKE 'When the garden is growing on its own%' AND body LIKE '%Mushroom%' AND body NOT LIKE '%Pest Patrol%'", [GAMES_PAGE]);   // v1.4.8: the Games page lists Pest Patrol too
    if (!q_val("SELECT 1 FROM items WHERE slug = 'earthworm'")) {
        db_insert('items', ['name' => 'Earthworm', 'slug' => 'earthworm', 'category' => 'soil', 'rarity' => 5, 'base_price' => 6,
            'description' => 'A wriggly friend from the old mine. Let it go in a garden square: soil life +8 over a few hours. Or keep a few for a worm bin.',
            'effects' => json_encode(['life' => 8, 'hours' => 6])]);
    }
    if (!q_val("SELECT 1 FROM recipes WHERE slug = 'worm-bin'")) {
        $out = (int)q_val("SELECT id FROM items WHERE slug = 'worm-castings'");
        if ($out) db_insert('recipes', ['name' => 'Worm Bin', 'slug' => 'worm-bin', 'category' => 'garden', 'output_item_id' => $out, 'output_qty' => 2,
            'ingredients' => json_encode(['earthworm' => 3, 'plain-compost' => 1]), 'energy' => 1, 'cook_minutes' => 0]);
    }
    if (!q_val("SELECT 1 FROM encyclopedia_entries WHERE title = 'Games' AND chapter = 'General'")) {
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => 'Games',
            'body' => GAMES_PAGE,
            'unlock_key' => 'start', 'hint' => '', 'sort_order' => 6]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]);
        }
    }
}

// ---------------- Seed Memory ----------------

const MEMORY_FACES = ['🌽', '🥕', '🍅', '🥔', '🧅', '🧄', '🌶️', '🍆', '🥒', '🥬', '🫑', '🍓', '🫐', '🍇', '🍉', '🍋', '🍑', '🍒', '🥥', '🍍', '🌻', '🌷', '🌹', '🍄'];
/** mode => [side, pairs, best score, points lost per extra turn] */
const MEMORY_MODES = ['easy' => [4, 8, 100, 5], 'hard' => [6, 18, 300, 6]];

function memory_start(array $u, string $mode): array
{
    $uid = (int)$u['id'];
    if (!isset(MEMORY_MODES[$mode])) return [false, 'Pick easy or hard.'];
    if (game_state($uid, 'memory')) return [true, 'Your game is still on the table.'];
    if (game_plays_left($uid, 'memory') <= 0) return [false, 'You’ve played enough Seed Memory for today. Come back after the reset.'];
    [, $pairs] = MEMORY_MODES[$mode];
    $faces = MEMORY_FACES;
    shuffle($faces);
    $cards = array_merge(array_slice($faces, 0, $pairs), array_slice($faces, 0, $pairs));
    shuffle($cards);
    game_save($uid, 'memory', ['mode' => $mode, 'cards' => $cards, 'matched' => [], 'first' => null, 'shown' => [], 'turns' => 0]);
    return [true, '🃏 The seed packets are face down. Find the pairs in as few turns as you can!'];
}

function memory_flip(array $u, int $i): array
{
    $uid = (int)$u['id'];
    $s = game_state($uid, 'memory');
    if (!$s) return [false, 'Start a game first.'];
    if ($i < 0 || $i >= count($s['cards']) || in_array($i, $s['matched'], true) || $s['first'] === $i) return [false, 'Pick a face-down packet.'];
    $s['shown'] = [];   // last turn's mismatch turns back over
    if ($s['first'] === null) {
        $s['first'] = $i;
        game_save($uid, 'memory', $s);
        return [true, ''];
    }
    $a = $s['first'];
    $s['first'] = null;
    $s['turns']++;
    if ($s['cards'][$a] === $s['cards'][$i]) {
        $s['matched'][] = $a;
        $s['matched'][] = $i;
        if (count($s['matched']) === count($s['cards'])) return memory_finish($u, $s);
        game_save($uid, 'memory', $s);
        return [true, '✨ A pair of ' . $s['cards'][$i] . '!'];
    }
    $s['shown'] = [$a, $i];
    game_save($uid, 'memory', $s);
    return [true, ''];
}

/** v1.2.2: give up a game. The state row is the claim, so it counts as one play exactly once. */
function memory_quit(int $uid): array
{
    db()->beginTransaction();
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'memory'])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'There’s no game to give up.'];
    }
    game_score($uid, 'memory', 0);
    db()->commit();
    return [true, 'You sweep the packets back into the box.'];
}

function memory_score(array $s): int
{
    [, $pairs, $best, $lose] = MEMORY_MODES[$s['mode']];
    return max(10, $best - max(0, (int)$s['turns'] - $pairs) * $lose);
}

function memory_finish(array $u, array $s): array
{
    $uid = (int)$u['id'];
    $score = memory_score($s);
    db()->beginTransaction();
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'memory'])->rowCount() !== 1) {   // v1.2.2: the state row is the claim
        db()->rollBack();
        return [false, 'That game is already over.'];
    }
    game_score($uid, 'memory', $score);
    $coins = game_petals(intdiv($score, $s['mode'] === 'hard' ? 3 : 2));   // v0.7.90: hard paid ~97 a game with no energy
    q('UPDATE users SET coins = coins + ? WHERE id = ?', [$coins, $uid]);
    $xp = (string)setting('games_give_xp') === '1' ? ($s['mode'] === 'hard' ? 15 + intdiv($score, 30) : 5 + intdiv($score, 20)) : 0;   // v0.7.42: better games, more XP (easy 5–10, hard 15–25). v0.9.1: only when games_give_xp is on
    if ($xp) add_xp($uid, games_pal_xp((int)$uid, (int)$xp));
    $en = game_energy($uid, $s['mode'] === 'hard' || $score >= 40);   // v0.9.1a
    db()->commit();
    prize('🃏', 'All pairs found in ' . (int)$s['turns'] . ' turns!', 'Score: ' . $score, array_merge(['+' . money($coins)], $xp ? ['+' . $xp . ' XP'] : [], $en !== '' ? [trim($en) . ' energy'] : []));
    return [true, ''];
}

// ---------------- Snail Race ----------------

/** [name, icon colour word, win chance %] — payouts are worked out from the chances, less a 10% fee. */
const SNAILS = [
    ['Speedy Sue', 'green', 36],
    ['Old Gary', 'brown', 26],
    ['Twinkle', 'pink', 18],
    ['Mossback', 'grey', 12],
    ['Lightning Larry', 'gold', 8],
];

function snail_payout(int $i): float
{
    return floor(90 / SNAILS[$i][2] * 10) / 10;   // e.g. 36% → 2.5×
}

/** The race key for the hour starting at $t (UTC), e.g. 2026101014. */
function race_key(int $t): string
{
    return gmdate('YmdH', $t);
}

/** Next race: the top of the coming hour. Bets close when it starts. */
function next_race(): array
{
    $start = (intdiv(time(), 3600) + 1) * 3600;
    return [race_key($start), $start];
}

/** Finishing order for a race, fixed by a secret so nobody can predict it. Winner picked by the snails' chances. */
function race_result(string $race): array
{
    $secret = setting('race_secret');
    $order = [];
    $left = array_keys(SNAILS);
    $n = 0;
    while ($left) {
        $h = hexdec(substr(hash_hmac('sha256', $race . '|' . $n++, $secret), 0, 7)) / 0xFFFFFFF;
        $total = array_sum(array_map(fn($i) => SNAILS[$i][2], $left));
        $roll = $h * $total;
        foreach ($left as $k => $i) {
            $roll -= SNAILS[$i][2];
            if ($roll <= 0 || $k === array_key_last($left)) {
                $order[] = $i;
                unset($left[$k]);
                break;
            }
        }
    }
    return $order;
}

function place_bet(array $u, int $snail, int $amount): array
{
    $uid = (int)$u['id'];
    if (!isset(SNAILS[$snail])) return [false, 'Pick a snail.'];
    $max = (int)setting('race_max_bet');
    if ($amount < 1 || $amount > $max) return [false, 'Bet between 1 and ' . money($max) . '.'];
    if (game_plays_left($uid, 'race') <= 0) return [false, 'That’s enough betting for today. Come back after the reset.'];
    [$race] = next_race();
    if (q_val('SELECT 1 FROM snail_bets WHERE user_id = ? AND race = ?', [$uid, $race])) return [false, 'You’ve already backed a snail in this race.'];
    db()->beginTransaction();
    if (!take_petals((int)$uid, (int)$amount)) {
        db()->rollBack();
        return [false, 'You don’t have that many Petals.'];
    }
    db_insert('snail_bets', ['user_id' => $uid, 'race' => $race, 'snail' => $snail, 'amount' => $amount, 'paid' => 0, 'winnings' => 0, 'day' => game_day(), 'placed_at' => now()]);
    db()->commit();
    return [true, '🐌 ' . money($amount) . ' on ' . SNAILS[$snail][0] . ' (pays ' . snail_payout($snail) . '×). The race starts in ' . nice_time(next_race()[1] - time()) . '.'];
}

/** Pay out every finished race. Runs when anyone opens the race page or the hub. */
function settle_races(): void
{
    $now = race_key(time());   // the race that started this hour is over the moment it starts (snails are quick when nobody watches)
    foreach (q('SELECT * FROM snail_bets WHERE paid = 0 AND race <= ? ORDER BY id LIMIT 500', [$now])->fetchAll() as $b) {
        $win = race_result((string)$b['race'])[0] === (int)$b['snail'];
        $pay = $win ? (int)floor((int)$b['amount'] * snail_payout((int)$b['snail'])) : 0;
        db()->beginTransaction();
        if (q('UPDATE snail_bets SET paid = 1, winnings = ? WHERE id = ? AND paid = 0', [$pay, $b['id']])->rowCount() === 1) {
            if ($pay) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$pay, $b['user_id']]);
            $gx = (string)setting('games_give_xp') === '1';   // v0.9.1: game XP only when games_give_xp is on
            if ($gx) add_xp((int)$b['user_id'], $win ? 5 : 1);   // v0.7.42: a little XP for cheering, more for winning
            $rEn = game_energy((int)$b['user_id'], $win);   // v1.4.7: every game gives a little energy
            db_insert('game_scores', ['user_id' => $b['user_id'], 'game' => 'race', 'score' => $pay, 'day' => $b['day'],
                'week' => job_period_key('weekly'), 'played_at' => now()]);
            $cu = current_user();
            if ($cu && (int)$cu['id'] === (int)$b['user_id']) {   // the player is here: show it big
                prize($win ? '🏆' : '🐌', $win ? SNAILS[(int)$b['snail']][0] . ' wins the race!' : SNAILS[(int)$b['snail']][0] . ' didn’t win this time',
                    $win ? '+' . money($pay) : '', $win ? array_values(array_filter(['Your ' . money((int)$b['amount']) . ' bet paid ' . snail_payout((int)$b['snail']) . '×', $gx ? '+5 XP' : '', $rEn !== '' ? trim($rEn) . ' energy' : ''])) : array_values(array_filter(['Better luck next race!', $gx ? '+1 XP' : ''])));
            } else {
                require_once __DIR__ . '/trade.php';
                notify((int)$b['user_id'], $win ? '🏁 ' . SNAILS[(int)$b['snail']][0] . ' won the snail race! You win ' . money($pay) . '.'
                                                : '🏁 ' . SNAILS[(int)$b['snail']][0] . ' didn’t win the snail race this time.');
            }
        }
        db()->commit();
    }
}

function ensure_race_secret(): void
{
    if (setting('race_secret') === '') {
        set_setting('race_secret', bin2hex(random_bytes(16)));   // hidden: not in Game settings, so results can't be worked out
        setting('__reload__');
    }
}

// ---------------- Seed Spitting (v0.7.31) ----------------

/**
 * v1.4.0: Seed Spitting is a physics game. The server starts a round (a wind, a token, a start time) in game_state; the player
 * picks an angle and power; the server works out the distance ITSELF with spit_sim() (assets/spit.js runs the same steps to
 * animate the flight and show the dotted guide, but the number that counts is always the server's). One fire per round,
 * no sooner than spit_min_ms after the round began. Distances are whole millimetres so PHP and JS agree exactly.
 * Units: cm, seconds. Wind pushes the seed through the air (drag towards the wind speed). Grit adds launch speed,
 * Nimble steadies the seed against the wind. After landing the seed bounces twice at most, then rolls to a stop.
 */
const SPIT_PHYS = ['g' => 300, 'k' => 0.6, 'vmin' => 35, 'vmax' => 120, 'h0' => 8, 'dt' => 1 / 120, 'grit' => 0.02, 'nim' => 0.05,
    'rest' => 0.3, 'fric' => 0.6, 'bmin' => 25, 'roll' => 200, 'amin' => 5, 'amax' => 85];

/** Flight of one spit. Returns [distance in mm, path [[x cm, y cm] every 4th step, and the roll]]. Mirrored by spitSim() in assets/spit.js. */
function spit_sim(int $angle, int $power, int $wind, int $grit, int $nim, bool $path = false): array
{
    $P = SPIT_PHYS;
    $angle = max($P['amin'], min($P['amax'], $angle));
    $power = max(0, min(100, $power));
    $v = ($P['vmin'] + ($P['vmax'] - $P['vmin']) * $power / 100) * (1 + $P['grit'] * max(0, $grit));
    $a = $angle * M_PI / 180;
    $vx = $v * cos($a);
    $vy = $v * sin($a);
    $w = $wind * max(0.5, 1 - $P['nim'] * max(0, $nim));
    $x = 0.0; $y = (float)$P['h0']; $dt = $P['dt']; $bounces = 0;
    $pts = $path ? [[0.0, $y]] : [];
    for ($i = 0; $i < 6000; $i++) {
        $ax = -$P['k'] * ($vx - $w);
        $ay = -$P['g'] - $P['k'] * $vy;
        $vx += $ax * $dt; $vy += $ay * $dt;
        $x += $vx * $dt; $y += $vy * $dt;
        if ($y <= 0) {
            $y = 0.0;
            if ($vy < -$P['bmin'] && $bounces < 2) { $vy = -$vy * $P['rest']; $vx *= $P['fric']; $bounces++; }
            else { $x += ($vx > 0 ? 1 : -1) * $vx * $vx / (2 * $P['roll']); if ($path) $pts[] = [$x, 0.0]; break; }
        }
        if ($path && $i % 4 === 3) $pts[] = [$x, $y];
    }
    return [max(0, (int)round($x * 10)), $pts];
}

/** Start a round: the wind blows, the clock starts. Costs a play (a live round counts as one, like worms). */
function spit_start(array $u): array
{
    $uid = (int)$u['id'];
    if (setting('spit_game_on') !== '1') return [false, 'The seed-spitting field is closed today.'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (game_state($uid, 'spit')) { db()->rollBack(); return [true, 'Your seed is still in your cheek. Fire away!']; }
    if (game_plays_left($uid, 'spit') <= 0) { db()->rollBack(); return [false, 'Your mouth is dry. Three spits a day!']; }
    $max = max(0, (int)setting('spit_wind_max'));
    $gust = random_int(1, 20) === 1;   // the old lucky gust: a strong tailwind
    $wind = $gust ? (int)round($max * 1.5) : random_int(-$max, $max);
    game_save($uid, 'spit', ['tok' => bin2hex(random_bytes(8)), 't0' => microtime(true), 'wind' => $wind, 'gust' => $gust,
        'grit' => max(0, eff_mod($u, 'grit')), 'nim' => max(0, eff_mod($u, 'nimble'))]);
    db()->commit();
    return [true, '🍉 Seed loaded. Check the wind, pick your angle and power, then spit!'];
}

/** Fire: angle (degrees) and power (0-100) from the player, everything else from the stored round. */
function spit_fire(array $u, string $tok, int $angle, int $power): array
{
    $uid = (int)$u['id'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    $s = game_state($uid, 'spit');
    if (!$s || !isset($s['tok'])) { db()->rollBack(); return [false, 'Load a seed first.']; }
    if (!hash_equals((string)$s['tok'], $tok)) { db()->rollBack(); return [false, 'That was an old seed. Try again.']; }
    if ((microtime(true) - (float)$s['t0']) * 1000 < max(0, (int)setting('spit_min_ms'))) { db()->rollBack(); return [false, 'Too quick! Take a proper breath first.']; }
    // the round row is the claim: only the call that deletes it scores
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'spit'])->rowCount() !== 1) { db()->rollBack(); return [false, 'That seed is already gone.']; }
    [$mm] = spit_sim($angle, $power, (int)$s['wind'], (int)$s['grit'], (int)$s['nim']);
    $pay = spit_pay($u, $mm / 10);
    db()->commit();
    spit_prize($pay, (int)$s['wind'], $angle, $power);
    return [true, ''];
}

/** Score, coins, XP and energy for a spit of $cm centimetres (inside the caller's transaction). The same payouts as ever: 30 / 45 / 60 cm. */
function spit_pay(array $u, float $cm): array
{
    $uid = (int)$u['id'];
    $cm = round($cm, 1);
    game_score($uid, 'spit', (int)round($cm * 10));
    $coins = game_petals($cm >= 60 ? 30 : ($cm >= 45 ? 15 : ($cm >= 30 ? 5 : 0)));
    if ($coins) give_petals((int)$uid, (int)$coins);
    $xp = (string)setting('games_give_xp') === '1' ? 1 + intdiv((int)$cm, 15) : 0;   // v0.7.42: every game pays a little XP. v0.9.1: only when games_give_xp is on
    if ($xp) add_xp($uid, games_pal_xp((int)$uid, (int)$xp));
    $en = game_energy($uid, $cm >= 45);   // v0.9.1a
    return ['uid' => $uid, 'cm' => $cm, 'coins' => $coins, 'xp' => $xp, 'en' => $en];
}

function spit_prize(array $p, ?int $wind = null, ?int $angle = null, ?int $power = null): void
{
    $cm = $p['cm'];
    $best = game_best($p['uid'], 'spit');
    prize('🍉', $cm >= 60 ? 'An enormous spit!' : ($cm >= 30 ? 'Pthoo!' : 'A bit of a dribble…'), number_format($cm, 1) . ' cm',
        array_filter([$p['coins'] ? '+' . money($p['coins']) : '', $p['xp'] ? '+' . $p['xp'] . ' XP' : '', $p['en'] !== '' ? trim($p['en']) . ' energy' : '',
            (int)round($cm * 10) >= $best ? '🏅 Your best this week!' : '',
            $wind !== null ? 'Wind ' . ($wind === 0 ? 'calm' : abs($wind) . ($wind > 0 ? ' with you' : ' against you')) . ' · ' . $angle . '° at ' . $power . '% power' : '',
            'Weekly record: ' . number_format(spit_record() / 10, 1) . ' cm']));
}

/** The quick spit (no aiming): luck of the day plus a little Grit and Nimble, as before v1.4.0. Takes over a round that was started but not fired. */
function spit_go(array $u): array
{
    $uid = (int)$u['id'];
    // v1.2.2: lock, count plays, insert: one transaction, so two logins can't both take the last spit
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (game_state($uid, 'spit')) q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'spit']);   // v1.4.0: the loaded seed is spat quickly instead (its play is used here)
    if (game_plays_left($uid, 'spit') <= 0) { db()->rollBack(); return [false, 'Your mouth is dry. Three spits a day!']; }
    $cm = random_int(80, 520) / 10 + 1.5 * max(0, eff_mod($u, 'grit')) + 1.0 * max(0, eff_mod($u, 'nimble'));
    if (random_int(1, 20) === 1) $cm += random_int(100, 250) / 10;   // a gust of wind!
    $pay = spit_pay($u, $cm);
    db()->commit();
    spit_prize($pay);
    return [true, ''];
}

function spit_record(): int
{
    return (int)q_val("SELECT MAX(score) FROM game_scores WHERE game = 'spit' AND week = ?", [job_period_key('weekly')]);
}

// ---------------- Guess the Giant Marrow (v0.7.31) ----------------

/** Today's giant crop's weight in grams, in 100 g steps: secret until the day ends (keyed with the race secret so it can't be worked out). */
function marrow_weight(string $day): int
{
    ensure_race_secret();
    $h = hexdec(substr(hash_hmac('sha256', 'marrow|' . $day, setting('race_secret')), 0, 8));
    return (80 + $h % 321) * 100;   // 8.0 to 40.0 kg (v0.8.0: tenths of a kilo, so an exact guess is possible)
}

/** v0.8.0: the giant crop on show today, picked from the Hollow's crops for flavour: [name, icon]. */
function marrow_crop(string $day): array
{
    static $cache = [];
    if (isset($cache[$day])) return $cache[$day];
    $crops = q("SELECT name, kind FROM plants WHERE kind IN ('vegetable', 'fruit', 'tuber', 'tree', 'nut') ORDER BY id")->fetchAll();
    if (!$crops) return $cache[$day] = ['Marrow', '🥒'];
    $c = $crops[crc32('crop|' . $day) % count($crops)];
    require_once __DIR__ . '/catalog.php';
    return $cache[$day] = [(string)$c['name'], catalog_kind_icon((string)$c['kind'])];
}

/** A hint gnomes can see: its length, which goes with its weight (roughly), and how plump it looks.
 *  Noise is keyed with the race secret and the length is clamped, so any hint fits 100+ weights; plumpness follows the length (no extra clue). */
function marrow_hint(string $day): string
{
    $g = marrow_weight($day);
    $noise = hexdec(substr(hash_hmac('sha256', 'len|' . $day, setting('race_secret')), 0, 8)) % 13 - 6;
    $len = max(54, min(74, (int)round(40 + $g / 1000 + $noise)));
    return 'It’s about ' . $len . ' cm across and ' . ($len > 68 ? 'very' : ($len > 58 ? 'quite' : 'a bit')) . ' plump.';
}

/** v0.8.0: the jackpot for an exact guess (it grows every day nobody hits it). */
function marrow_pot(): int
{
    $pot = (int)q_val("SELECT value FROM settings WHERE name = 'marrow_pot'");   // straight from the table: setting() caches, and several days can settle at once
    return $pot > 0 ? $pot : max(0, (int)setting('marrow_jackpot'));
}

/** Who may guess (alt accounts covering every number would spoil an exact-guess jackpot). '' = yes. */
function marrow_block(array $u): string
{
    $lv = (int)setting('marrow_min_level');
    if ((int)$u['level'] < $lv) return 'Guessing opens at gnome level ' . $lv . '.';
    $days = (int)setting('marrow_min_days');
    if ($days > 0 && ts($u['created_at']) > time() - $days * 86400) return 'New gnomes can guess after ' . $days . ' day' . ($days === 1 ? '' : 's') . ' in the Hollow.';
    return '';
}

function marrow_guess(array $u, float $kg): array
{
    $uid = (int)$u['id'];
    if ($why = marrow_block($u)) return [false, $why];
    if ($kg < 8 || $kg > 40) return [false, 'Guess between 8 and 40 kg.'];
    if (game_plays_left($uid, 'marrow') <= 0) return [false, 'One guess a day. Come back tomorrow!'];
    try {
        db_insert('marrow_guesses', ['day' => game_day(), 'user_id' => $uid, 'grams' => (int)round($kg * 10) * 100, 'placed' => null, 'at' => now()]);
    } catch (PDOException $e) {
        return [false, 'You’ve already guessed today.'];
    }
    $gx = (string)setting('games_give_xp') === '1';   // v0.9.1: game XP only when games_give_xp is on
    if ($gx) add_xp($uid, 2);
    $en = game_energy($uid, false);   // v0.9.1a
    return [true, '⚖️ Your guess of ' . number_format($kg, 1) . ' kg is written on the board' . ($gx ? ' (+2 XP)' : '') . $en . '. Results after the daily reset!'];
}

/**
 * Pay out finished days (v0.8.0): only an EXACT guess wins the jackpot (split between exact guessers). With no exact guess the
 * jackpot grows, and the closest guess gets a small consolation prize. Safe to call often.
 */
function settle_marrows(): void
{
    $today = game_day();
    foreach (q('SELECT DISTINCT day FROM marrow_guesses WHERE day <> ? AND placed IS NULL ORDER BY day', [$today])->fetchAll(PDO::FETCH_COLUMN) as $day) {
        $w = marrow_weight((string)$day);
        [$crop] = marrow_crop((string)$day);
        $rows = q('SELECT g.* FROM marrow_guesses g JOIN users u ON u.id = g.user_id WHERE g.day = ? AND g.placed IS NULL AND ' . gnome_in_play_sql('u'), [$day])->fetchAll();
        if (!$rows) { q('UPDATE marrow_guesses SET placed = 0 WHERE day = ? AND placed IS NULL', [$day]); continue; }
        usort($rows, fn($a, $b) => [abs((int)$a['grams'] - $w), $a['at']] <=> [abs((int)$b['grams'] - $w), $b['at']]);
        // Claim the whole day first, so two page loads can't pay it twice
        $claimed = [];
        foreach ($rows as $i => $r) if (q('UPDATE marrow_guesses SET placed = ? WHERE id = ? AND placed IS NULL', [$i + 1, $r['id']])->rowCount() === 1) $claimed[] = $r + ['rank' => $i + 1];
        if (!$claimed) continue;
        $exact = array_values(array_filter($claimed, fn($r) => (int)$r['grams'] === $w));
        $pot = marrow_pot();
        require_once __DIR__ . '/trade.php';
        $kg = number_format($w / 1000, 1) . ' kg';
        if ($exact) {
            $share = intdiv($pot, count($exact));
            $gxp = (string)setting('games_give_xp') === '1';   // v0.9.1: game XP only when games_give_xp is on
            foreach ($exact as $r) {
                q('UPDATE users SET coins = coins + ? WHERE id = ?', [$share, $r['user_id']]);
                if ($gxp) add_xp((int)$r['user_id'], 50);
                notify((int)$r['user_id'], '⚖️🎉 EXACTLY right! The giant ' . $crop . ' weighed ' . $kg . '. You win the jackpot' . (count($exact) > 1 ? ' (shared ' . count($exact) . ' ways)' : '') . ': ' . money($share) . ($gxp ? ' and 50 XP' : '') . '!');
            }
            set_setting('marrow_pot', (string)max(0, (int)setting('marrow_jackpot')));
        } else {
            set_setting('marrow_pot', (string)min(max(0, (int)setting('marrow_jackpot_max')), $pot + max(0, (int)setting('marrow_jackpot_grow'))));
        }
        $close = max(0, (int)setting('marrow_close_prize'));
        foreach ($claimed as $r) {
            if ($exact && (int)$r['grams'] === $w) continue;
            $first = !$exact && $r['rank'] === 1;
            if ($first && $close) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$close, $r['user_id']]);
            notify((int)$r['user_id'], '⚖️ The giant ' . $crop . ' weighed ' . $kg . '. You guessed ' . number_format((int)$r['grams'] / 1000, 1) . ' kg'
                . ($first ? ', the closest of anyone' . ($close ? ': ' . money($close) . ' as a consolation' : '') . '. Nobody hit it exactly, so the jackpot grows!' : '. ' . ($exact ? 'Someone hit it exactly!' : 'Nobody hit it exactly, so the jackpot grows!')));
        }
    }
}

// ---------------- v1.4.7: render-only helpers for the Snail Race / Guess the Weight pages (no game logic) ----------------

/** A snail picture in its shell colour (decorative: the name always sits next to it). */
function snail_img(int $i, string $cls = 'scimg'): string
{
    return '<img class="' . e($cls) . '" src="' . e(url('assets/img/games/snail-' . SNAILS[$i][1] . '.svg')) . '" alt="" width="48" height="48" loading="lazy">';
}

/** "1st", "2nd" ... for a finishing place (0 = first). */
function race_place(int $pos): string
{
    return ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th'][$pos] ?? (($pos + 1) . 'th');
}

/** The scale dial angle for a weight in grams: 8 kg at -120 degrees, 40 kg at +120. */
function marrow_angle(int $grams): float
{
    return round(-120 + (max(8.0, min(40.0, $grams / 1000)) - 8) / 32 * 240, 1);
}

/**
 * The fair-stall weighing scale as inline SVG, with today's (or a past day's) crop on the tray.
 * $needle = grams the needle points to (null = resting at the start). $marks = [[css class, grams, label]] dots on the rim.
 */
function marrow_scale_html(string $icon, ?int $needle, array $marks = [], string $cls = ''): string
{
    $kind = ['🥬' => 'vegetable', '🥔' => 'tuber', '🍓' => 'fruit', '🌳' => 'tree', '🌰' => 'nut'][$icon] ?? 'vegetable';
    $cx = 120; $cy = 120;
    $pt = fn(float $a, float $r) => [round($cx + $r * sin(deg2rad($a)), 2), round($cy - $r * cos(deg2rad($a)), 2)];
    $ticks = $labels = '';
    for ($kg = 8; $kg <= 40; $kg += 2) {
        $a = marrow_angle($kg * 1000);
        $major = $kg % 8 === 0;
        [$x1, $y1] = $pt($a, 38);
        [$x2, $y2] = $pt($a, $major ? 30 : 34);
        $ticks .= 'M' . $x1 . ' ' . $y1 . 'L' . $x2 . ' ' . $y2;
        if ($major) {
            [$tx, $ty] = $pt($a, 22);
            $labels .= '<text x="' . $tx . '" y="' . ($ty + 3) . '">' . $kg . '</text>';
        }
    }
    $dots = '';
    foreach ($marks as [$mc, $g, $label]) {
        [$mx, $my] = $pt(marrow_angle((int)$g), 43.5);
        $dots .= '<circle class="dmark ' . e($mc) . '" cx="' . $mx . '" cy="' . $my . '" r="4.4"><title>' . e($label) . '</title></circle>';
    }
    $a = $needle === null ? -120 : marrow_angle($needle);
    return '<div class="scalestage ' . e($cls) . '" data-a="' . $a . '"><svg class="scalesvg" viewBox="0 0 240 200" role="img" aria-label="A wooden weighing scale">'
        . '<ellipse cx="120" cy="193" rx="96" ry="5" fill="#000" opacity=".16"/>'
        . '<path d="M26 156a6 6 0 0 1 6-6h176a6 6 0 0 1 6 6v28a6 6 0 0 1-6 6H32a6 6 0 0 1-6-6z" fill="#9a6a3a"/>'
        . '<path d="M26 174h188v10a6 6 0 0 1-6 6H32a6 6 0 0 1-6-6z" fill="#7e5430"/>'
        . '<rect x="32" y="153" width="176" height="4" rx="2" fill="#c48e55" opacity=".7"/><path d="M26 171h188" stroke="#6e4726" stroke-width="1.5" opacity=".5"/>'
        . '<rect x="68" y="162" width="104" height="20" rx="3" fill="#f1e2bd" stroke="#c9aa6a" stroke-width="1"/><text class="dplate" x="120" y="176">OLD MOSS’S SCALES</text>'
        . '<rect x="112" y="68" width="16" height="12" fill="#8f949a"/>'
        . '<ellipse cx="120" cy="72" rx="54" ry="7" fill="#aeb3b9"/><ellipse cx="120" cy="70" rx="54" ry="6" fill="#cdd1d6"/><path d="M80 69q20-4 44-4" stroke="#fff" stroke-width="1.5" fill="none" opacity=".7" stroke-linecap="round"/>'
        . '<image class="dcrop" href="' . e(url('assets/img/games/crop-' . $kind . '.svg')) . '" x="82" y="0" width="76" height="76"/>'
        . '<circle cx="120" cy="120" r="48" fill="#b8862b"/><circle cx="120" cy="120" r="48" fill="none" stroke="#e2b13c" stroke-width="2"/><circle cx="120" cy="120" r="42" fill="#fbf3da"/><circle cx="120" cy="120" r="42" fill="none" stroke="#8a6212" stroke-width="1.2"/>'
        . '<path d="' . $ticks . '" stroke="#5e3b1c" stroke-width="1.4" stroke-linecap="round" fill="none"/><g class="dlabels">' . $labels . '</g>'
        . '<text class="dunit" x="120" y="146">kg</text>'
        . '<g class="dnd" data-a="' . $a . '" transform="rotate(' . $a . ')"><path d="M118.4 126L120 80L121.6 126Z" fill="#b8312a"/><path d="M118.2 120l1.8 12 1.8-12z" fill="#8a2a22"/></g>'
        . '<circle cx="120" cy="120" r="5" fill="#5e3b1c"/><circle cx="119" cy="119" r="1.6" fill="#b98450"/>'
        . $dots
        . '<circle class="dmark ghost" cx="120" cy="76.500" r="4.400"><title>Your guess</title></circle>'
        . '</svg></div>';
}

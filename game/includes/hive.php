<?php
declare(strict_types=1);
/**
 * Honey Hive Harvest: lift the hive’s 8 frames one by one, listen to the hum, bank before a swarm wakes.
 * The kind of every closed frame lives in game_state only; the page sees the hum (1 quiet, 2 humming, 3 loud) of each frame and
 * the kind of a frame only once it is lifted or peeked with smoke.
 * State: v, frames (kinds, hidden), hum (1-3 each), lifted, peeked, puffs, mode (lift|smoke), basket, combs, season, swarms, t0.
 */

const HIVE_N = 8;
const HIVE_VALUE = ['clear' => 6, 'golden' => 12, 'amber' => 20, 'heather' => 30, 'drowsy' => 0, 'swarm' => 0];
const HIVE_NAMES = ['clear' => 'clear comb', 'golden' => 'golden comb', 'amber' => 'deep amber comb', 'heather' => 'heather comb', 'drowsy' => 'drowsy bee', 'swarm' => 'swarm'];
const HIVE_HUM_WORD = [1 => 'Quiet', 2 => 'Humming', 3 => 'Loud'];
const HIVE_SWARM_PETALS = 4;
const HIVE_GOOD_BASKET = 40;
const HIVE_SCORE_CAP = 100;

/** The 8 kinds for a season (before Hardiness). */
function hive_mix(string $season): array
{
    $m = ['swarm', 'swarm', 'drowsy', 'clear', 'clear', 'golden', 'amber', 'heather'];
    if ($season === 'summer') $m[2] = 'golden';     // a busy hive: no drowsy bee
    if ($season === 'winter') $m[7] = 'golden';     // a sleepy hive: no heather
    return $m;
}

/** Roll a hum for one kind. Swarms and heather are always Loud; Quiet and Humming frames are never swarms. */
function hive_roll_hum(string $kind): int
{
    return match ($kind) {
        'clear' => random_int(1, 2),
        'golden' => 2,
        'amber' => random_int(2, 3),
        'heather', 'swarm' => 3,
        default => 1,   // drowsy
    };
}

/** A fresh layout. $hardy: one swarm becomes a drowsy bee (the other swarm always stays). Returns [frames, hum]. */
function hive_layout(string $season, bool $hardy): array
{
    $f = hive_mix($season);
    if ($hardy) { $k = array_search('swarm', $f, true); if ($k !== false) $f[$k] = 'drowsy'; }
    for ($i = HIVE_N - 1; $i > 0; $i--) { $j = random_int(0, $i); [$f[$i], $f[$j]] = [$f[$j], $f[$i]]; }
    $h = array_map('hive_roll_hum', $f);
    return [$f, $h];
}

/** The buzz meter: [Loud frames left, swarms among them] over closed, unpeeked frames. */
function hive_meter(array $s): array
{
    $L = 0; $S = 0;
    for ($i = 0; $i < HIVE_N; $i++) {
        if (in_array($i, $s['lifted'], true) || in_array($i, $s['peeked'], true)) continue;
        if ((int)$s['hum'][$i] === 3) { $L++; if ($s['frames'][$i] === 'swarm') $S++; }
    }
    return [$L, $S];
}

/** What the page may see: no kind for a closed, unpeeked frame. */
function hive_view(array $s): array
{
    $cells = [];
    for ($i = 0; $i < HIVE_N; $i++) {
        $lift = in_array($i, $s['lifted'], true);
        $peek = in_array($i, $s['peeked'], true);
        $cells[$i] = ['hum' => (int)$s['hum'][$i], 'lifted' => $lift, 'peeked' => $peek, 'kind' => ($lift || $peek) ? $s['frames'][$i] : null];
    }
    [$L, $S] = hive_meter($s);
    return ['cells' => $cells, 'basket' => (int)$s['basket'], 'combs' => (int)$s['combs'], 'puffs' => (int)$s['puffs'], 'mode' => $s['mode'], 'loud' => $L, 'swarms' => $S, 'season' => $s['season']];
}

function hive_season_line(string $season): string
{
    return match ($season) {
        'summer' => '🌻 Summer hive: busy and rich',
        'winter' => '❄️ Winter hive: sleepy and quiet',
        'autumn' => '🍂 Autumn hive: steady',
        default => '🌸 Spring hive: steady',
    };
}

/** Open a hive: roll the frames and the hum, read the stats once. */
function hive_start(array $u): array
{
    $uid = (int)$u['id'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (game_state($uid, 'hive')) { db()->rollBack(); return [true, 'Your hive is still open.']; }
    if (game_plays_left($uid, 'hive') <= 0) { db()->rollBack(); return [false, 'The bees need a rest. Come back after the daily reset.']; }
    $season = (string)hollow_season();
    [$frames, $hum] = hive_layout($season, eff_mod($u, 'hardiness') >= 3);
    game_save($uid, 'hive', ['v' => 1, 'frames' => $frames, 'hum' => $hum, 'lifted' => [], 'peeked' => [], 'puffs' => 1 + (eff_mod($u, 'sense') >= 2 ? 1 : 0),
        'mode' => 'lift', 'basket' => 0, 'combs' => 0, 'season' => $season, 'swarms' => count(array_keys($frames, 'swarm', true)), 't0' => time()]);
    db()->commit();
    return [true, '🍯 You puff a little smoke and lift the lid. The frames are warm and humming.'];
}

/** Read the round inside a transaction with the gnome row locked. Null (already rolled back) when there is none. */
function hive_locked(int $uid): ?array
{
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    $s = game_state($uid, 'hive');
    if (!$s || !isset($s['frames'])) { db()->rollBack(); return null; }
    return $s;
}

function hive_mode(array $u, string $mode): array
{
    $uid = (int)$u['id'];
    if (!in_array($mode, ['lift', 'smoke'], true)) return [false, 'Lift or smoke.'];
    $s = hive_locked($uid);
    if (!$s) return [false, 'Open the hive first.'];
    $s['mode'] = $mode;
    game_save($uid, 'hive', $s);
    db()->commit();
    return [true, ''];
}

function hive_lift(array $u, int $i): array
{
    $uid = (int)$u['id'];
    $s = hive_locked($uid);
    if (!$s) return [false, 'Open the hive first.'];
    if ($i < 0 || $i >= HIVE_N) { db()->rollBack(); return [false, 'That frame isn’t in the hive.']; }
    if (in_array($i, $s['lifted'], true)) { db()->rollBack(); return [false, 'That frame’s already lifted.']; }
    $kind = $s['frames'][$i];
    if ($kind === 'swarm' && in_array($i, $s['peeked'], true)) { db()->rollBack(); return [false, 'A swarm is napping there. Best leave it be.']; }
    $s['lifted'][] = $i;
    if ($kind === 'swarm') return hive_settle($u, $s, true);
    $v = HIVE_VALUE[$kind];
    $s['basket'] += $v;
    if ($v > 0) $s['combs']++;
    if (count($s['lifted']) >= HIVE_N - (int)$s['swarms']) return hive_settle($u, $s, false);   // every safe frame lifted: banked for you
    game_save($uid, 'hive', $s);
    db()->commit();
    return [true, match ($kind) {
        'clear' => '🍯 A clear comb. Light and sweet: +6.',
        'golden' => '🍯 Golden comb! +12.',
        'amber' => '🍯 Deep amber comb! +20.',
        'heather' => '🍯 Heather comb, the rarest of all! +30.',
        default => '🐝 Just a drowsy bee. She yawns and goes back to sleep.',
    }];
}

function hive_smoke(array $u, int $i): array
{
    $uid = (int)$u['id'];
    $s = hive_locked($uid);
    if (!$s) return [false, 'Open the hive first.'];
    if ($i < 0 || $i >= HIVE_N) { db()->rollBack(); return [false, 'That frame isn’t in the hive.']; }
    if (in_array($i, $s['lifted'], true)) { db()->rollBack(); return [false, 'That frame’s already lifted.']; }
    if (in_array($i, $s['peeked'], true)) { db()->rollBack(); return [false, 'You’ve already peeked at that one.']; }
    if ((int)$s['puffs'] <= 0) { db()->rollBack(); return [false, 'No smoke left.']; }
    $s['puffs']--;
    $s['peeked'][] = $i;
    game_save($uid, 'hive', $s);
    db()->commit();
    $k = $s['frames'][$i];
    return [true, $k === 'swarm' ? '💨 A gentle puff… a swarm is napping there. Best leave it be.' : '💨 A gentle puff… it’s a ' . HIVE_NAMES[$k] . '.'];
}

function hive_bank(array $u): array
{
    $s = hive_locked((int)$u['id']);
    if (!$s) return [false, 'That round is already over.'];
    if (!$s['lifted']) { db()->rollBack(); return [false, 'Lift a frame before you bank.']; }
    return hive_settle($u, $s, false);
}

/**
 * Ends the round. Call inside the open transaction with the gnome row locked: deleting the state is the claim,
 * so a double bank, or a bank racing a swarm, pays once. Commits (or rolls back).
 */
function hive_settle(array $u, array $s, bool $swarm): array
{
    $uid = (int)$u['id'];
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'hive'])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That round is already over.'];
    }
    $basket = $swarm ? 0 : (int)$s['basket'];
    $petals = game_petals($swarm ? HIVE_SWARM_PETALS : $basket);
    $xp = (!$swarm && (string)setting('games_give_xp') === '1') ? max(1, intdiv($basket, 10)) : 0;
    game_score($uid, 'hive', min(HIVE_SCORE_CAP, $basket));
    if ($petals) give_petals($uid, $petals);
    if ($xp) add_xp($uid, $xp);
    // honey: the first qualifying bank of the day (4 or more combs), capped by hive_gifts_per_day
    $gifts = [];
    if (!$swarm && (int)$s['combs'] >= 4) {
        $g = game_state($uid, 'hive_gift');
        $n = ($g && ($g['day'] ?? '') === game_day()) ? (int)$g['n'] : 0;
        if ($n < (int)setting('hive_gifts_per_day')) {
            $hid = (int)q_val("SELECT id FROM items WHERE slug = 'garden-honey'");
            if ($hid && give_item($uid, $hid, 1)) $gifts[] = '1 × Garden Honey';
            $heather = false;
            foreach ($s['lifted'] as $i) if ($s['frames'][$i] === 'heather') $heather = true;
            $wid = (int)q_val("SELECT id FROM items WHERE slug = 'beeswax'");
            if ($heather && $wid && give_item($uid, $wid, 1)) $gifts[] = '1 × Beeswax';
            if ($gifts) game_save($uid, 'hive_gift', ['day' => game_day(), 'n' => $n + 1]);
        }
    }
    db()->commit();
    $en = game_energy($uid, !$swarm && $basket >= HIVE_GOOD_BASKET);
    $_SESSION['hive_last'] = ['frames' => $s['frames'], 'hum' => $s['hum'], 'lifted' => $s['lifted'], 'peeked' => $s['peeked']];
    if ($swarm) {
        prize('💥', '💥 The swarm woke up!', 'Your basket tumbles back into the hive',
            [$petals ? '+' . money($petals) . ' for being brave' : '', $en !== '' ? trim($en) . ' energy' : '']);
    } else {
        $c = (int)$s['combs'];
        prize('🧺', '🧺 Basket banked!', $c . ' comb' . ($c === 1 ? '' : 's') . ' · ' . $basket . ' sweetness',
            [$petals ? '+' . money($petals) : '', $gifts ? '🍯 Also: ' . implode(', ', $gifts) : '', $xp ? '+' . $xp . ' XP' : '', $en !== '' ? trim($en) . ' energy' : '']);
    }
    return [true, ''];
}

/** Adds the Honey Hive line to the Almanac Games page once. Runs from ensure_games(). */
function hive_almanac(): void
{
    $line = "🍯 [b]Honey Hive Harvest:[/b] lift a hive’s frames one by one. Each frame hums Quiet, Humming or Loud; swarms are always Loud, and so are the best combs. Bank your basket before a swarm wakes. A puff of smoke shows what’s inside one frame.";
    $row = q_one("SELECT id, body FROM encyclopedia_entries WHERE title = 'Games' AND chapter = 'General' AND body LIKE 'When the garden is growing on its own%' AND body NOT LIKE '%Honey Hive%'");
    if (!$row) return;
    $body = (string)$row['body'];
    $at = strpos($body, "\n\nThe [b]🏆 Contests");
    $body = $at === false ? rtrim($body) . "\n" . $line : substr($body, 0, $at) . "\n" . $line . substr($body, $at);
    q('UPDATE encyclopedia_entries SET body = ? WHERE id = ?', [$body, (int)$row['id']]);
}

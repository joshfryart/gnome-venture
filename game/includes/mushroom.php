<?php
declare(strict_types=1);
/**
 * Mushroom Sweeper: a cosy Minesweeper on a 6 × 6 forest floor. The toadstools are kept in game_state only,
 * so the page never sees where they are until the round is over.
 * State: toads (hidden, set after the first pick), placed, open (safe squares uncovered), flags, mode (pick|flag).
 */

const MUSH_SIZE = 6;
const MUSH_TOADS = 6;
const MUSH_SAFE = MUSH_SIZE * MUSH_SIZE - MUSH_TOADS;   // 30 safe squares make a clean sweep
const MUSH_PETALS_PER_SQUARE = 2;
const MUSH_PETALS_MAX = 60;
const MUSH_SWEEP_PETALS = 40;

/** The squares around square $i (fewer at the edges). */
function mush_neighbours(int $i): array
{
    $n = MUSH_SIZE;
    $x = $i % $n;
    $y = intdiv($i, $n);
    $out = [];
    for ($dy = -1; $dy <= 1; $dy++) for ($dx = -1; $dx <= 1; $dx++) {
        if (!$dx && !$dy) continue;
        $xx = $x + $dx;
        $yy = $y + $dy;
        if ($xx >= 0 && $yy >= 0 && $xx < $n && $yy < $n) $out[] = $yy * $n + $xx;
    }
    return $out;
}

/** How many toadstools touch square $i. */
function mush_clue(array $toads, int $i): int
{
    $c = 0;
    foreach (mush_neighbours($i) as $j) if (in_array($j, $toads, true)) $c++;
    return $c;
}

/** Toadstools go on random squares, never on the first pick or its neighbours. */
function mush_place(int $safe): array
{
    $ring = array_merge([$safe], mush_neighbours($safe));
    $free = array_values(array_diff(range(0, MUSH_SIZE * MUSH_SIZE - 1), $ring));
    shuffle($free);
    $toads = array_slice($free, 0, MUSH_TOADS);
    sort($toads);
    return $toads;
}

/** Uncover square $i. A square with no toadstools next to it opens its neighbours too. Flagged squares stay shut. */
function mush_open(array &$s, int $i): void
{
    $todo = [$i];
    while ($todo) {
        $j = array_pop($todo);
        if (in_array($j, $s['open'], true) || in_array($j, $s['flags'], true)) continue;
        $s['open'][] = $j;
        if (mush_clue($s['toads'], $j) === 0) {
            foreach (mush_neighbours($j) as $k) $todo[] = $k;
        }
    }
}

function mush_start(array $u): array
{
    $uid = (int)$u['id'];
    if (game_state($uid, 'mushroom')) return [true, 'Your forest walk is still on.'];
    if (game_plays_left($uid, 'mushroom') <= 0) return [false, 'The forest floor needs a rest. Come back after the daily reset.'];
    game_save($uid, 'mushroom', ['toads' => [], 'placed' => false, 'open' => [], 'flags' => [], 'mode' => 'pick']);
    return [true, '🍄 The forest floor is covered in leaves. Your first pick is always safe!'];
}

function mush_pick(array $u, int $i): array
{
    $uid = (int)$u['id'];
    $s = game_state($uid, 'mushroom');
    if (!$s) return [false, 'Start a walk first.'];
    if ($i < 0 || $i >= MUSH_SIZE * MUSH_SIZE) return [false, 'That’s outside the forest floor.'];
    if (in_array($i, $s['open'], true)) return [false, 'You’ve already foraged there.'];
    if (in_array($i, $s['flags'], true)) return [false, 'Take the 🚩 off that square first.'];
    if (!$s['placed']) {
        $s['toads'] = mush_place($i);
        $s['placed'] = true;
    }
    if (in_array($i, $s['toads'], true)) {
        return mush_finish($u, $s, $i);
    }
    mush_open($s, $i);
    if (count($s['open']) >= MUSH_SAFE) return mush_finish($u, $s, null, true);
    game_save($uid, 'mushroom', $s);
    return [true, ''];
}

function mush_flag(array $u, int $i): array
{
    $uid = (int)$u['id'];
    $s = game_state($uid, 'mushroom');
    if (!$s) return [false, 'Start a walk first.'];
    if ($i < 0 || $i >= MUSH_SIZE * MUSH_SIZE) return [false, 'That’s outside the forest floor.'];
    if (in_array($i, $s['open'], true)) return [false, 'That square is already foraged.'];
    if (in_array($i, $s['flags'], true)) {
        $s['flags'] = array_values(array_diff($s['flags'], [$i]));
    } else {
        $s['flags'][] = $i;
    }
    game_save($uid, 'mushroom', $s);
    return [true, ''];
}

function mush_mode(array $u, string $mode): array
{
    $uid = (int)$u['id'];
    $s = game_state($uid, 'mushroom');
    if (!$s) return [false, 'Start a walk first.'];
    if (!in_array($mode, ['pick', 'flag'], true)) return [false, 'Pick or flag.'];
    $s['mode'] = $mode;
    game_save($uid, 'mushroom', $s);
    return [true, ''];
}

function mush_stop(array $u): array
{
    $s = game_state((int)$u['id'], 'mushroom');
    if (!$s) return [false, 'No walk to stop.'];
    return mush_finish($u, $s, null);
}

/** A random common forage item for a clean sweep. Returns its name, or null if there is nothing to find. */
function mush_forage_find(int $uid): ?string
{
    $ids = q("SELECT g.item_id FROM gatherables g WHERE g.rarity = 'common' AND g.tool = 'forage' AND g.active = 1")->fetchAll(PDO::FETCH_COLUMN);
    if (!$ids) return null;
    $id = (int)$ids[array_rand($ids)];
    if (!give_item($uid, $id, 1)) return null;
    return (string)q_val('SELECT name FROM items WHERE id = ?', [$id]);
}

/**
 * Ends the round: pays the foraged squares, the clean sweep bonus and a forage find, and keeps the
 * board for one more look (the toadstools show up on the next page).
 */
function mush_finish(array $u, array $s, ?int $boom, bool $clean = false): array
{
    $uid = (int)$u['id'];
    $safe = count($s['open']);
    $petals = game_petals(min(MUSH_PETALS_MAX, MUSH_PETALS_PER_SQUARE * $safe) + ($clean ? MUSH_SWEEP_PETALS : 0));
    $xp = (string)setting('games_give_xp') === '1' ? ($clean ? 10 : 3) : 0;   // v0.9.1: game XP only when games_give_xp is on
    db()->beginTransaction();
    // Only the request that removes the round may pay, so a double click can't pay twice
    if (q('DELETE FROM game_state WHERE user_id = ? AND game = ?', [$uid, 'mushroom'])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That walk is already over.'];
    }
    game_score($uid, 'mushroom', $safe);
    if ($petals) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$petals, $uid]);
    if ($xp) add_xp($uid, $xp);
    db()->commit();
    $en = game_energy($uid, $clean);   // v1.4.7: every game gives a little energy
    $find = $clean ? mush_forage_find($uid) : null;
    $_SESSION['mush_last'] = ['toads' => $s['toads'], 'open' => $s['open'], 'flags' => $s['flags'], 'boom' => $boom];

    $title = $clean ? '🍄 Clean sweep! Every safe square foraged'
        : ($boom !== null ? '☠️ Oops, a toadstool!' : '🧺 Back home with your finds');
    prize($clean ? '🏆' : ($boom !== null ? '☠️' : '🧺'), $title,
        $safe . ' safe square' . ($safe === 1 ? '' : 's') . ' foraged',
        [
            $petals ? '+' . money($petals) : '',
            $clean ? 'Clean sweep bonus included: +' . money(MUSH_SWEEP_PETALS) : ($boom !== null ? 'No clean sweep bonus this time' : ''),
            $find ? '🌿 Also found: 1 × ' . $find : '',
            $xp ? '+' . $xp . ' XP' : '',
            $en !== '' ? trim($en) . ' energy' : '',
        ]);
    return [true, ''];
}

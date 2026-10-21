<?php
declare(strict_types=1);
/**
 * Player jobs (v0.7.9) on the same Job Board as NPC jobs.
 *   tend    – "tend my garden" for 1, 3 or 7 days. The taker may only water, weed and harvest there.
 *             Harvests go to the owner, minus the helper's cut, which goes to the taker. Owner gets reduced XP.
 *   deliver – "bring me N of an item". Items go straight to the poster.
 * The wage is held in escrow when posted and paid to the taker bit by bit as the work is done (pro rata).
 * Whatever isn't earned goes back to the poster: if nobody takes it, if the taker gives up, or at the deadline.
 * A one-day job uses the taker's daily slot; longer ones use the weekly slot.
 */

const PJOB_TEND_DAYS = [1, 3, 7];

function pjob_period(array $pj): string
{
    return (int)$pj['days'] <= 1 ? 'daily' : 'weekly';
}

/** Can this player post or take player jobs? */
function pjob_allowed(array $u): ?string
{
    $need = (int)setting('player_jobs_min_level');
    return (int)$u['level'] < $need ? 'Player jobs open up at gnome level ' . $need . '.' : null;
}

/** Tidy up: refund unclaimed postings and settle jobs past their deadline. Cheap; runs on board and tend pages. */
function settle_player_jobs(): void
{
    foreach (q("SELECT * FROM player_jobs WHERE (status = 'open' AND expires_at < ?) OR (status = 'taken' AND ends_at < ?)", [now(), now()])->fetchAll() as $pj) {
        pjob_close($pj, $pj['status'] === 'open' ? 'expired' : ((int)$pj['progress'] >= (int)$pj['qty'] ? 'done' : 'expired'));
    }
}

/** Close a posting: refund what's left in escrow to the poster, and close the taker's job card. */
function pjob_close(array $pj, string $status): void
{
    // v1.2.2: callers pass stale rows. Lock the poster, re-read the job inside the transaction, refund what is really in escrow.
    $own = !db()->inTransaction();
    if ($own) db()->beginTransaction();
    for ($try = 0; $try < 3; $try++) {
        q('UPDATE users SET id = id WHERE id = ?', [$pj['poster_id']]);
        $cur = q_one('SELECT * FROM player_jobs WHERE id = ?', [$pj['id']]);
        if (!$cur || !in_array($cur['status'], ['open', 'taken'], true)) break;   // already closed by someone else
        $esc = (int)$cur['escrow'];
        if (q("UPDATE player_jobs SET status = ?, escrow = 0, closed_at = ? WHERE id = ? AND status IN ('open', 'taken') AND escrow = ?", [$status, now(), $pj['id'], $esc])->rowCount() !== 1) continue;   // escrow moved under us: re-read
        if ($esc > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$esc, $cur['poster_id']]);
        if ($status !== 'cancelled') {
            require_once __DIR__ . '/trade.php';
            notify((int)$cur['poster_id'], '📋 Your job ' . ['done' => 'is done', 'expired' => 'has ended', 'abandoned' => 'was given up'][$status]
                . '. Paid out: ' . money((int)$cur['paid']) . '; returned to you: ' . money($esc) . '.');
        }
        if ($cur['user_job_id']) {
            q("UPDATE user_jobs SET status = ?, done_at = ? WHERE id = ? AND status = 'active'",
                [$status === 'done' ? 'done' : ($status === 'abandoned' ? 'abandoned' : 'expired'), now(), $cur['user_job_id']]);
        }
        break;
    }
    if ($own) db()->commit();
}

function post_player_job(array $u, array $in): array
{
    $uid = (int)$u['id'];
    if ($why = pjob_allowed($u)) return [false, $why];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold
    $max = (int)setting('player_jobs_max_posted');
    if ((int)q_val("SELECT COUNT(*) FROM player_jobs WHERE poster_id = ? AND status IN ('open', 'taken')", [$uid]) >= $max) {
        return [false, "You can have $max jobs posted at a time."];
    }
    $kind = (string)($in['kind'] ?? '');
    $wage = (int)($in['wage'] ?? 0);
    $note = mb_substr(trim(preg_replace('/\s+/u', ' ', (string)($in['note'] ?? ''))), 0, 140);
    require_once __DIR__ . '/moderation.php';
    if ($bad = text_problem($u, $note)) return [false, $bad];
    $row = ['poster_id' => $uid, 'kind' => $kind, 'wage' => $wage, 'escrow' => $wage, 'note' => $note !== '' ? $note : null,
        'progress' => 0, 'paid' => 0, 'status' => 'open', 'posted_at' => now()];
    if ($kind === 'tend') {
        $days = (int)($in['days'] ?? 0);
        $plotId = (int)($in['plot_id'] ?? 0);
        if (!in_array($days, PJOB_TEND_DAYS, true)) return [false, 'Pick 1, 3 or 7 days.'];
        $plot = q_one('SELECT id, garden_name FROM plots WHERE id = ? AND user_id = ?', [$plotId, $uid]);
        if (!$plot) return [false, 'Pick one of your gardens.'];
        if (q_val("SELECT 1 FROM player_jobs WHERE plot_id = ? AND kind = 'tend' AND status IN ('open', 'taken')", [$plotId])) {
            return [false, 'That garden already has a tending job posted.'];
        }
        $min = (int)setting('player_job_min_wage') * $days;
        $row += ['days' => $days, 'plot_id' => $plotId, 'qty' => $days * max(1, (int)setting('player_tend_actions_per_day'))];
    } elseif ($kind === 'deliver') {
        $days = ($in['size'] ?? '') === 'weekly' ? 7 : 1;
        $qty = (int)($in['qty'] ?? 0);
        $item = q_one('SELECT id, name, slug, category, tradable FROM items WHERE id = ?', [(int)($in['item_id'] ?? 0)]);
        if (!$item || in_array($item['category'], ['tool', 'guide'], true) || !(int)$item['tradable']) return [false, 'Pick something to ask for.'];
        if ($qty < 1 || $qty > 500) return [false, 'Ask for between 1 and 500.'];
        $min = (int)setting('player_job_min_wage');
        $row += ['days' => $days, 'item_id' => (int)$item['id'], 'qty' => $qty];
    } else {
        return [false, 'Pick a kind of job.'];
    }
    if ($wage < $min) return [false, 'Offer at least ' . money($min) . '.'];
    if ($wage > 1000000) return [false, 'That’s a very generous wage. Too generous.'];
    $row['expires_at'] = gmdate('Y-m-d H:i:s', time() + max(1, (int)setting('player_job_listing_days')) * 86400);
    db()->beginTransaction();
    if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$wage, $uid, $wage])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You don’t have ' . money($wage) . ' to put up as the wage.'];
    }
    db_insert('player_jobs', $row);
    db()->commit();
    return [true, '📌 Your job is pinned to the board. The wage (' . money($wage) . ') is held until the work is done.'];
}

function cancel_player_job(array $u, int $id): array
{
    $pj = q_one("SELECT * FROM player_jobs WHERE id = ? AND poster_id = ?", [$id, $u['id']]);
    if (!$pj || $pj['status'] !== 'open') return [false, 'Only jobs nobody has taken yet can be taken down.'];
    pjob_close($pj, 'cancelled');
    return [true, 'You take your job down. The wage comes back to you.'];
}

/** Open jobs from other players for this slot. */
function open_player_jobs(array $u, string $period): array
{
    $rows = q("SELECT pj.*, COALESCE(us.gnome_name, us.username) AS poster, i.name AS item_name, pl.garden_name
               FROM player_jobs pj JOIN users us ON us.id = pj.poster_id
               LEFT JOIN items i ON i.id = pj.item_id LEFT JOIN plots pl ON pl.id = pj.plot_id
               WHERE pj.status = 'open' AND pj.poster_id <> ? AND pj.expires_at >= ? AND " . gnome_in_play_sql('us') . "
               ORDER BY pj.posted_at LIMIT 40", [$u['id'], now()])->fetchAll();
    return array_slice(array_values(array_filter($rows, fn($r) => pjob_period($r) === $period)), 0, 8);
}

function pjob_title(array $pj): string
{
    return $pj['kind'] === 'tend'
        ? 'Tend ' . ($pj['garden_name'] ?: 'a garden') . ' for ' . (int)$pj['days'] . ' day' . ((int)$pj['days'] > 1 ? 's' : '')
        : 'Bring ' . (int)$pj['qty'] . ' × ' . $pj['item_name'];
}

function pjob_text(array $pj): string
{
    $t = $pj['kind'] === 'tend'
        ? $pj['poster'] . ' is going away. Water, weed and harvest in their garden. Each job done earns part of the wage (' . (int)$pj['qty'] . ' jobs for the full pay), and you keep a share of what you harvest.'
        : $pj['poster'] . ' needs ' . (int)$pj['qty'] . ' × ' . $pj['item_name'] . '. You’re paid for each one you hand in. Deadline: ' . ((int)$pj['days'] > 1 ? 'a week' : 'a day') . ' after you take it.';
    return $t . ($pj['note'] ? ' “' . $pj['note'] . '”' : '');
}

function take_player_job(array $u, int $id): array
{
    $uid = (int)$u['id'];
    if ($why = pjob_allowed($u)) return [false, $why];
    settle_player_jobs();
    $pj = q_one("SELECT pj.*, COALESCE(us.gnome_name, us.username) AS poster, i.name AS item_name, pl.garden_name FROM player_jobs pj
                 JOIN users us ON us.id = pj.poster_id LEFT JOIN items i ON i.id = pj.item_id LEFT JOIN plots pl ON pl.id = pj.plot_id
                 WHERE pj.id = ?", [$id]);
    if (!$pj || $pj['status'] !== 'open') return [false, 'Someone got there first.'];
    if ((int)$pj['poster_id'] === $uid) return [false, 'You can’t take your own job.'];
    $period = pjob_period($pj);
    if (current_job($uid, $period)) return [false, 'You already have a ' . strtolower(JOB_PERIODS[$period][0]) . ' job ' . job_period_phrase($period) . '.'];
    // v0.7.85: one tending job at a time. A second one would leave the first garden untendable (active_tend_job takes one).
    if ($pj['kind'] === 'tend' && active_tend_job($uid)) return [false, 'Finish your tending job first.'];
    // Anti-farming: one job from the same gnome per week
    if (q_val("SELECT 1 FROM player_jobs WHERE taker_id = ? AND poster_id = ? AND taken_at > ?", [$uid, $pj['poster_id'], gmdate('Y-m-d H:i:s', time() - 7 * 86400)])) {
        return [false, 'You’ve already worked for ' . $pj['poster'] . ' this week. Give someone else a turn.'];
    }
    $ends = gmdate('Y-m-d H:i:s', time() + (int)$pj['days'] * 86400);
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.2.2: lock, then re-check the slot
    if (current_job($uid, $period) || ($pj['kind'] === 'tend' && active_tend_job($uid))) {
        db()->rollBack();
        return [false, 'You already have a ' . strtolower(JOB_PERIODS[$period][0]) . ' job ' . job_period_phrase($period) . '.'];
    }
    if (q("UPDATE player_jobs SET status = 'taken', taker_id = ?, taken_at = ?, ends_at = ? WHERE id = ? AND status = 'open'", [$uid, now(), $ends, $id])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Someone got there first.'];
    }
    $jid = db_insert('user_jobs', ['user_id' => $uid, 'period' => $period, 'period_key' => job_period_key($period), 'template_id' => null,
        'kind' => $pj['kind'] === 'tend' ? 'p_tend' : 'p_deliver', 'title' => pjob_title($pj), 'text' => pjob_text($pj), 'npc' => $pj['poster'],
        'target' => '', 'target_item_id' => $pj['item_id'] ?: null, 'target_name' => (string)($pj['item_name'] ?? ''),
        'qty' => (int)$pj['qty'], 'progress' => 0, 'stages' => 1, 'stages_paid' => 0, 'reward_coins' => (int)$pj['wage'], 'reward_xp' => 0,
        'reward_qty' => 0, 'status' => 'active', 'taken_at' => now(), 'player_job_id' => $id]);
    q('UPDATE player_jobs SET user_job_id = ? WHERE id = ?', [$jid, $id]);
    require_once __DIR__ . '/trade.php';
    notify((int)$pj['poster_id'], '📋 ' . pname($u) . ' took your job: ' . pjob_title($pj) . '.');
    db()->commit();
    return [true, '📋 You take ' . $pj['poster'] . '’s job: ' . pjob_title($pj) . '.'];
}

/** Work done on a player job: pay the earned share of the wage from escrow; finish when complete. */
function pjob_progress(int $takerId, array $pj, int $add): ?string
{
    $pj = q_one('SELECT * FROM player_jobs WHERE id = ?', [$pj['id']]);
    if (!$pj || $pj['status'] !== 'taken' || (int)$pj['taker_id'] !== $takerId) return null;
    $progress = min((int)$pj['qty'], (int)$pj['progress'] + $add);
    $earned = intdiv((int)$pj['wage'] * $progress, max(1, (int)$pj['qty']));
    $pay = max(0, min((int)$pj['escrow'], $earned - (int)$pj['paid']));
    // v1.2.2: only while still taken and escrow can cover the pay (pjob_close may have zeroed it)
    if (q("UPDATE player_jobs SET progress = ?, paid = paid + ?, escrow = escrow - ? WHERE id = ? AND progress = ? AND status = 'taken' AND escrow >= ?",
            [$progress, $pay, $pay, $pj['id'], $pj['progress'], $pay])->rowCount() !== 1) return null;
    if ($pay) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$pay, $takerId]);
    q('UPDATE user_jobs SET progress = ? WHERE id = ?', [$progress, $pj['user_job_id']]);
    if ($progress >= (int)$pj['qty']) {
        $xp = (int)setting('player_job_xp') * ((int)$pj['days'] > 1 ? 3 : 1);
        add_xp($takerId, $xp);
        pjob_close(q_one('SELECT * FROM player_jobs WHERE id = ?', [$pj['id']]), 'done');
        return '✅ Job done! You’ve earned the full wage' . ($pay ? ' (' . money($pay) . ' just now)' : '') . ' and ' . $xp . ' XP.';
    }
    return $pay ? '+' . money($pay) . ' from the wage.' : null;
}

function pjob_deliver(array $u, array $job): array
{
    $uid = (int)$u['id'];
    if ($why = fresh_hold($u)) return [false, $why];   // v1.0.1: fresh gnome hold
    $pj = q_one('SELECT * FROM player_jobs WHERE id = ?', [$job['player_job_id']]);
    if (!$pj || $pj['status'] !== 'taken' || (int)$pj['taker_id'] !== $uid) return [false, 'That job has ended.'];
    $give = min((int)$pj['qty'] - (int)$pj['progress'], (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $pj['item_id']]));
    if ($give <= 0) return [false, 'You don’t have any ' . $job['target_name'] . ' to hand in.'];
    db()->beginTransaction();
    if (!give_item($uid, (int)$pj['item_id'], -$give)) {
        db()->rollBack();
        return [false, 'You don’t have that many.'];
    }
    give_item((int)$pj['poster_id'], (int)$pj['item_id'], $give);
    db()->commit();
    $msg = pjob_progress($uid, $pj, $give);
    return [true, '📦 You send ' . $give . ' × ' . $job['target_name'] . ' to ' . $job['npc'] . '. ' . ($msg ?? '')];
}

/** The taker's active tending job, if any: [player_job, user_job]. */
function active_tend_job(int $uid): ?array
{
    $j = q_one("SELECT uj.*, pj.plot_id, pj.poster_id, pj.id AS pj_id FROM user_jobs uj JOIN player_jobs pj ON pj.id = uj.player_job_id
                WHERE uj.user_id = ? AND uj.kind = 'p_tend' AND uj.status = 'active' AND pj.status = 'taken' ORDER BY uj.id DESC LIMIT 1", [$uid]);
    return $j ?: null;
}

/**
 * Water, weed or harvest one square of the garden you're tending. Returns [ok, [messages]].
 * Only these three actions exist here, and only on the job's garden.
 */
function tend_action(array $u, array $job, string $action, int $x, int $y): array
{
    $uid = (int)$u['id'];
    if (!in_array($action, ['water', 'weed', 'harvest'], true)) return [false, ['You can only water, weed and harvest here.']];
    $t = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND x = ? AND y = ?', [$job['plot_id'], $x, $y]);
    if (!$t) return [false, ['That square isn’t part of this garden.']];
    $owner = q_one('SELECT * FROM users WHERE id = ?', [$job['poster_id']]);
    $p = $t['plant_id'] ? q_one('SELECT * FROM plants WHERE id = ?', [$t['plant_id']]) : null;
    $t = annotate_tile($t, $p);
    $t = feed_tick(bed_tick(tile_grow($t, $p), $owner));   // v0.9.1: owner's perks
    $cost = ENERGY_COST[$action];
    db()->beginTransaction();
    try {
        $msgs = [];
        switch ($action) {
            case 'water':
                if (!$p) throw new UserError('Nothing to water there.');
                if (!tool_tier($uid, 'water')) throw new UserError('You need a watering can of your own.');
                $info = tile_info($t, $p);
                if ($info['ready']) throw new UserError('It’s ready to harvest!');
                if (!$info['thirsty']) throw new UserError('It doesn’t need water yet.');
                break;
            case 'weed':
                if ($t['method'] !== 'notill' || (int)$t['weeds'] < 5) throw new UserError('No weeds to pull there.');
                break;
            case 'harvest':
                if (!$p || $p['kind'] === 'cover' || !tile_info($t, $p)['ready']) throw new UserError('Nothing ready to harvest there.');
                break;
        }
        if (!spend_energy($uid, $cost)) throw new UserError('You’re too tired. Rest a bit and your energy will come back.' . tired_hint($uid));
        save_growth($t);
        if ($action === 'water') {
            q('UPDATE plot_tiles SET last_watered = ?, growth_updated_at = ? WHERE id = ?', [now(), now(), $t['id']]);
            $msgs[] = 'You water ' . $owner['gnome_name'] . '’s ' . $p['name'] . '.';
        } elseif ($action === 'weed') {
            q('UPDATE plot_tiles SET weeds = 0 WHERE id = ?', [$t['id']]);
            $msgs[] = '🌿 You pull the weeds.';
        } else {
            $hm = do_harvest($owner, $t, $p, gnome_name($u), $uid);
            $msgs[] = $hm[0] ?? 'You harvest it.';
        }
        add_xp($uid, max(0, (int)setting('player_tend_xp')));
        db()->commit();
    } catch (UserError $e) {
        if (db()->inTransaction()) db()->rollBack();
        return [false, [$e->getMessage()]];
    }
    if ($m = pjob_progress($uid, ['id' => $job['pj_id']], 1)) $msgs[] = $m;
    return [true, $msgs];
}

<?php
declare(strict_types=1);

/**
 * v0.9.5.2 Admin "Fresh start": put ONE player back to the very beginning, in a single transaction (MySQL + SQLite).
 * The account (id, name, email, password, role, ban/mute state, created_at, log-in times) and everything they've written
 * for staff (feedback, reports, news, admin log, password resets) stay. Everything that is gameplay progress goes.
 * The garden and starter kit are NOT made here: onboarded = 0 sends the gnome through the welcome flow again, whose
 * last step runs setup_new_player() (garden + starter items + home seeds + village pack), exactly like a new sign-up.
 */

/** users columns that are identity / security / moderation / a pure preference. Every other column is reset (see fresh_start_columns). */
const FRESH_KEEP_COLS = [
    'id', 'username', 'email', 'password_hash', 'role', 'banned', 'ban_reason', 'banned_until', 'muted_until', 'deleted_at',
    'created_at', 'agreed_at', 'last_login', 'last_seen', 'garden_public', 'pulse_show',
];

/** What a brand-new sign-up has in every other users column (register.php sets coins/energy/onboarded; the rest are schema defaults). */
function fresh_start_columns(): array
{
    return [
        'coins' => (int)setting('starting_coins'), 'level' => 1, 'xp' => 0, 'energy' => (int)setting('max_energy'),
        'stat_grit' => 10, 'stat_nimble' => 10, 'stat_hardiness' => 10, 'stat_lore' => 10, 'stat_sense' => 10, 'stat_charm' => 10, 'stat_luck' => 10,
        'stat_points' => 4, 'calling' => null, 'buff' => null, 'buff_until' => null, 'buff2' => null, 'buff2_until' => null,
        'location_id' => null, 'home_village_id' => null, 'active_plot_id' => null, 'energy_updated_at' => null, 'title' => null,
        'region_id' => null, 'location' => null, 'gnome_name' => null, 'hat_color' => null, 'beard_color' => null, 'hat_dye' => null,
        'onboarded' => 0, 'tour_step' => 0, 'job_dailies' => 0, 'sapling_day' => null, 'sapling_count' => 0,
        'community_day' => null, 'community_shift_until' => null, 'shift_actions' => 0, 'community_rep' => 0, 'ribbons' => 0,
        'event_at' => null, 'event_day' => null, 'event_count' => 0, 'ev_stat' => null, 'ev_amt' => 0, 'ev_until' => null,
        'easy_roads' => 1, 'ev_harvest_bonus' => 0, 'ev_quickwalk' => 0, 'ev_gather_until' => null, 'ev_sale_until' => null,
        'free_mend_n' => 0, 'free_mend_day' => null,
        'dest_id' => null, 'dest_auto' => 1, 'dest_pause_towns' => 0, 'dest_chain' => 0, 'dest_legs' => 0, 'dest_trail' => null,
        'last_cooked_id' => null, 'town_stat' => null, 'town_amt' => 0, 'town_until' => null, 'lore_read' => 0,
        'town_spot_id' => null, 'town_seen' => null, 'town_hidden' => 0, 'rps_wins' => 0,
        'calling_free_change' => 1, 'calling_tier_seen' => 0, 'calling_changes' => 0, 'calling_qt' => 0, 'calling_chapter' => null,
        'game_energy_day' => null, 'arrived_at' => null,
        'fw_start' => null, 'away_from' => null,   // v1.0.0 wave 3
    ];
}

/** Tables whose rows are deleted by a plain "user column = this player". */
const FRESH_USER_TABLES = [
    'user_items' => 'user_id', 'user_recipes' => 'user_id', 'user_encyclopedia' => 'user_id', 'user_milestones' => 'user_id',
    'user_plant_knowledge' => 'user_id', 'user_guides' => 'user_id', 'user_quests' => 'user_id', 'user_jobs' => 'user_id',
    'user_calling_chapters' => 'user_id', 'user_calling_tasks' => 'user_id', 'user_food_bonus' => 'user_id', 'user_tasted' => 'user_id',
    'user_npc_met' => 'user_id', 'npc_friends' => 'user_id', 'npc_favours' => 'user_id', 'expeditions' => 'user_id', 'walk_scene' => 'user_id',
    'region_visits' => 'user_id', 'landmark_clears' => 'user_id', 'landmark_uses' => 'user_id', 'landmark_repairs' => 'user_id', 'road_journal' => 'user_id',
    'landmark_rebuilds' => 'user_id', 'xp_log' => 'user_id', 'game_scores' => 'user_id', 'game_state' => 'user_id',
    'snail_bets' => 'user_id', 'marrow_guesses' => 'user_id', 'stall_listings' => 'seller_id', 'job_rerolls' => 'user_id',
    'town_uses' => 'user_id', 'traveller_deals' => 'user_id', 'local_deals' => 'user_id', 'stop_log' => 'user_id', 'stop_friend' => 'user_id', 'stop_errands' => 'user_id', 'stop_stamps' => 'user_id', 'stop_set_claims' => 'user_id', 'community_log' => 'user_id',
    'compost_turns' => 'user_id', 'cook_pots' => 'user_id', 'pantry_jars' => 'user_id', 'cellar_plants' => 'user_id', 'garden_hires' => 'user_id',
    'fair_best' => 'user_id', 'fair_entries' => 'user_id', 'fair_ribbons' => 'user_id', 'show_entries' => 'user_id',
    'gotm_entries' => 'user_id', 'notices' => 'user_id', 'gifts' => 'from_id', 'sink_owned' => 'user_id', 'curio_buys' => 'user_id',   // v0.9.7
    'dry_racks' => 'user_id', 'florist_shifts' => 'user_id', 'arrangement_entries' => 'user_id', 'flower_daily' => 'user_id',   // v0.9.9
    'item_quality' => 'user_id', 'gourmand_ledger' => 'user_id',   // next version
];

/**
 * Wipe one player's progress. Returns [true, summary] or [false, why]. Never touches other players' own data
 * apart from cancelling/refunding what the reset player had open with them.
 */
function fresh_start_player(int $uid): array
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return [false, 'No such player.'];
    require_once __DIR__ . '/trade.php';   // notify(), offer_refund()
    $name = (string)($u['gnome_name'] ?: $u['username']);
    $mine = 'SELECT id FROM plots WHERE user_id = ?';
    $n = [];
    $del = function (string $sql, array $p = []) use (&$n): void {
        $st = q($sql, $p);
        if (preg_match('/DELETE FROM (\w+)/', $sql, $m)) $n[$m[1]] = ($n[$m[1]] ?? 0) + $st->rowCount();
    };

    db()->beginTransaction();
    try {
        // ---- Open dealings with other players: give THEM their side back, then close ----
        foreach (q("SELECT * FROM trade_offers WHERE status = 'open' AND (from_id = ? OR to_id = ?)", [$uid, $uid])->fetchAll() as $o) {
            q("UPDATE trade_offers SET status = 'cancelled', closed_at = ? WHERE id = ? AND status = 'open'", [now(), $o['id']]);
            if ((int)$o['to_id'] === $uid) {   // someone else's held offer to this player goes back to them
                offer_refund($o);
                notify((int)$o['from_id'], 'A trade offer to ' . $name . ' was cancelled (they started a fresh gnome). Your items are back in your satchel.');
            }                                  // this player's own held side is wiped with the rest
        }
        q("UPDATE town_rps SET status = 'cancelled', done_at = ? WHERE status = 'open' AND (from_id = ? OR to_id = ?)", [now(), $uid, $uid]);
        foreach (q("SELECT * FROM player_jobs WHERE status IN ('open', 'taken') AND (poster_id = ? OR taker_id = ?)", [$uid, $uid])->fetchAll() as $pj) {
            $status = (int)$pj['poster_id'] === $uid ? 'cancelled' : 'abandoned';
            if (q("UPDATE player_jobs SET status = ?, escrow = 0, closed_at = ? WHERE id = ? AND status IN ('open', 'taken')", [$status, now(), $pj['id']])->rowCount() !== 1) continue;
            if ((int)$pj['poster_id'] !== $uid) {   // the wage held for another poster goes back to them
                if ((int)$pj['escrow'] > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$pj['escrow'], $pj['poster_id']]);
                notify((int)$pj['poster_id'], '📋 Your job was given up (the gnome who took it started afresh). Returned to you: ' . money((int)$pj['escrow']) . '.');
            } elseif ($pj['taker_id'] && (int)$pj['taker_id'] !== $uid) {
                notify((int)$pj['taker_id'], '📋 A job you took was taken down by its poster.');
            }
            if ($pj['user_job_id'] && (int)$pj['taker_id'] !== $uid) {
                q("UPDATE user_jobs SET status = 'expired', done_at = ? WHERE id = ? AND status = 'active'", [now(), $pj['user_job_id']]);
            }
        }
        // Votes this player cast count on other players' entries: take them back off
        foreach (q('SELECT entry_id, COUNT(*) AS c FROM gotm_votes WHERE user_id = ? GROUP BY entry_id', [$uid])->fetchAll() as $v) {
            q('UPDATE gotm_entries SET votes = CASE WHEN votes > ? THEN votes - ? ELSE 0 END WHERE id = ?', [(int)$v['c'], (int)$v['c'], $v['entry_id']]);
        }
        foreach (q('SELECT carving_id, COUNT(*) AS c FROM carving_votes WHERE user_id = ? GROUP BY carving_id', [$uid])->fetchAll() as $v) {
            q('UPDATE carvings SET votes = CASE WHEN votes > ? THEN votes - ? ELSE 0 END WHERE id = ?', [(int)$v['c'], (int)$v['c'], $v['carving_id']]);
        }
        foreach (q('SELECT plot_id, COUNT(*) AS c FROM garden_admires WHERE user_id = ? GROUP BY plot_id', [$uid])->fetchAll() as $v) {
            q('UPDATE plots SET admired = CASE WHEN admired > ? THEN admired - ? ELSE 0 END WHERE id = ?', [(int)$v['c'], (int)$v['c'], $v['plot_id']]);
        }

        market_fresh_start($uid);   // v1.0.0 wave 2b: item quality, orders, market buys, baskets
        social_fresh_start($uid);   // v1.0.0 wave 3: friends, blocks, stamps, goal shares, First Week, festival rows (before the gardens go)
        // ---- Votes / admires on or by this player ----
        $del('DELETE FROM gotm_votes WHERE user_id = ? OR entry_id IN (SELECT id FROM gotm_entries WHERE user_id = ?)', [$uid, $uid]);
        $del('DELETE FROM carving_votes WHERE user_id = ? OR carving_id IN (SELECT id FROM carvings WHERE user_id = ?)', [$uid, $uid]);
        $del('DELETE FROM carvings WHERE user_id = ?', [$uid]);
        $del("DELETE FROM garden_admires WHERE user_id = ? OR plot_id IN ($mine)", [$uid, $uid]);

        // ---- Their gardens, and everything standing in them ----
        foreach (['plot_tiles', 'garden_buildings', 'garden_objects', 'garden_hires', 'cellar_plants', 'yard_history', 'compost_turns', 'gotm_entries', 'garden_critters', 'garden_visitors'] as $t) {
            $del("DELETE FROM $t WHERE plot_id IN ($mine)", [$uid]);
        }
        try { q('UPDATE stop_adoptions SET user_id = NULL WHERE user_id = ?', [$uid]); } catch (Throwable $e) {}   // v1.0.0: a gnome starting over lets go of their stop
        $del('DELETE FROM plot_tiles WHERE user_id = ?', [$uid]);
        $del('DELETE FROM plots WHERE user_id = ?', [$uid]);

        // ---- Everything else keyed on the player ----
        foreach (FRESH_USER_TABLES as $t => $col) $del("DELETE FROM $t WHERE $col = ?", [$uid]);
        $del('UPDATE stop_adoptions SET user_id = NULL WHERE user_id = ?', [$uid]);   // v1.0.0: the stop keeps its upgrades; the next adopter carries on
        $del('DELETE FROM town_meets WHERE a_id = ? OR b_id = ?', [$uid, $uid]);
        // Jobs they posted stay as closed history only if someone else took them; otherwise gone
        $del("DELETE FROM player_jobs WHERE poster_id = ? AND (taker_id IS NULL OR taker_id = ?)", [$uid, $uid]);

        // ---- The account itself: back to what a new sign-up has ----
        db_update('users', fresh_start_columns(), 'id = ?', [$uid]);

        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        throw $e;
    }
    // Their own session (when an admin resets themselves) must not carry old welcome / pending-page state
    if ((int)($_SESSION['uid'] ?? 0) === $uid) unset($_SESSION['welcome'], $_SESSION['new_pages']);
    return [true, $n];
}

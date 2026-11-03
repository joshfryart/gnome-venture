<?php
declare(strict_types=1);
require_once __DIR__ . '/admin_menu.php';   // v1.6.3: the Admin menu and breadcrumbs

/** For one shop: [day 0-6][hour 0-23] => list of NPC names working then. */
function shop_coverage(int $shopId): array
{
    $grid = array_fill(0, 7, array_fill(0, 24, []));
    $rows = q("SELECT s.*, n.name FROM npc_schedules s JOIN npcs n ON n.id = s.npc_id
               WHERE s.shop_id = ? AND s.activity = 'working' AND n.active = 1", [$shopId])->fetchAll();
    foreach ($rows as $s) {
        foreach (schedule_days($s['days']) as $d) {
            foreach (schedule_hours((int)$s['start_hour'], (int)$s['end_hour']) as $h) {
                $grid[$d][$h][] = $s['name'];
            }
        }
    }
    return $grid;
}

function coverage_gaps(array $grid): int
{
    $gaps = 0;
    foreach ($grid as $hours) {
        foreach ($hours as $who) {
            if (!$who) $gaps++;
        }
    }
    return $gaps;
}

function render_shop_coverage(int $shopId): void
{
    $grid = shop_coverage($shopId);
    $gaps = coverage_gaps($grid);
    $days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    echo '<div class="box"><h3>Staffing coverage</h3>';
    echo $gaps ? "<p class=\"flash err\">$gaps unstaffed hour(s) a week (red). Add working schedules to fill them.</p>"
               : '<p class="flash ok">Staffed around the clock, every day.</p>';
    echo '<div class="scroll"><table class="cover"><tr><th></th>';
    for ($h = 0; $h < 24; $h++) echo '<th>' . $h . '</th>';
    echo '</tr>';
    foreach ($grid as $d => $hours) {
        echo '<tr><th>' . $days[$d] . '</th>';
        foreach ($hours as $h => $who) {
            $cls = $who ? (count($who) > 1 ? 'many' : 'one') : 'none';
            echo '<td class="' . $cls . '" title="' . e(sprintf('%s %02d:00 — %s', $days[$d], $h, $who ? implode(', ', $who) : 'nobody')) . '"></td>';
        }
        echo '</tr>';
    }
    echo '</table></div><p class="help">Hover a square to see who is working. Times are server time (UTC).</p></div>';
}

// ---- v2.4.93: "Start counting again" for the XP sources, Usage and Retention pages ----
/** UTC datetime the area was last reset, or '' for never. Usage and Retention count only from then on; nothing else is touched. */
function stats_baseline(string $area): string
{
    return (string)setting('stats_reset_' . $area);
}

/** Run at the top of the page: handles the Reset button's POST (admins only; csrf checked). XP wipes its log, the others set the date. */
function stats_reset_handle(string $area, string $page): void
{
    if (!is_post() || (string)($_POST['do'] ?? '') !== 'stats_reset') return;
    csrf_check();
    if ($area === 'xp') {
        q('DELETE FROM xp_log');   // the log is only a report; gnome XP and levels are not touched
    } elseif ($area === 'usage') {
        // tables with no date column cannot be filtered, so remember their row counts now and show the difference
        $snap = [];
        foreach (usage_feature_list() as $list) {
            foreach ($list as [$label, $table, $ucol, $tcol]) {
                if ($tcol !== '') continue;
                try { $snap[$table . '|' . $ucol] = (int)q_val("SELECT COUNT(*) FROM $table WHERE $ucol IN (SELECT id FROM users WHERE banned = 0 AND guest = 0 AND role NOT IN ('admin','mod'))"); } catch (Throwable $e) {}
            }
        }
        set_setting('stats_usage_snap', json_encode($snap));
    }
    set_setting('stats_reset_' . $area, now());
    setting('__reload__');
    flash('Done. Counting again from now.');
    redirect('admin/' . $page);
}

/** The Reset box at the bottom of the page. */
function stats_reset_box(string $area, string $what, string $warn): void
{
    $at = stats_baseline($area);
    echo '<div class="box"><h2>Start counting again</h2><p class="help">' . e($what) . ($at !== '' ? ' Last reset: ' . e($at) . ' UTC.' : '') . '</p>';
    echo '<form method="post" data-confirm="' . e($warn) . '">' . csrf_field() . '<input type="hidden" name="do" value="stats_reset">'
       . '<button class="btn small alt">🧹 Reset these numbers</button></form></div>';
}

/** Usage page features: group => [[label, table, user column, time column or '', time kind dt|day], ...]. */
function usage_feature_list(): array
{
    return [
    'Tasks & requests' => [
        ['Daily/weekly/monthly jobs', 'user_jobs', 'user_id', '', ''],
        ['Posted jobs (player to player)', 'player_jobs', 'poster_id', '', ''],
        ['Townsfolk orders done', 'npc_orders', 'user_id', 'done_at', 'dt'],
        ['Favours done', 'npc_favours', 'user_id', 'done_at', 'dt'],
        ['Rest stop errands', 'stop_errands', 'user_id', 'created_at', 'dt'],
        ['Journey (quest chapters)', 'user_quests', 'user_id', 'started_at', 'dt'],
        ['Calling tasks done', 'user_calling_tasks', 'user_id', 'done_at', 'dt'],
        ['Hollow Goal claims', 'hollow_goal_claims', 'user_id', 'claimed_at', 'dt'],
        ['First Week claims', 'first_week_claims', 'user_id', 'claimed_at', 'dt'],
        ['Daily card (days seen)', 'daily_ticks', 'user_id', 'day', 'day'],
    ],
    'Helpers & social' => [
        ['Hired garden help', 'garden_hires', 'user_id', 'started_at', 'dt'],
        ['Helper side of hires', 'garden_hires', 'helper_id', 'started_at', 'dt'],
        ['Helping water', 'garden_waterings', 'helper_id', 'created_at', 'dt'],
        ['Gifts sent', 'gifts', 'from_id', 'sent_at', 'dt'],
        ['Friend requests', 'player_friends', 'user_id', 'created_at', 'dt'],
        ['Player mentor links', 'pmentor_links', 'newcomer_id', 'created_at', 'dt'],
        ['Trade offers', 'trade_offers', 'from_id', 'created_at', 'dt'],
        ['Stall listings', 'stall_listings', 'seller_id', 'listed_at', 'dt'],
        ['Community garden log', 'community_log', 'user_id', 'at', 'dt'],
    ],
    'Villagers & places' => [
        ['Rest stop log (visits, acts)', 'stop_log', 'user_id', 'at', 'dt'],
        ['Stop villager friendships', 'stop_friend', 'user_id', 'last_talk', 'dt'],
        ['Named NPC friendships', 'npc_friends', 'user_id', '', ''],
        ['Adopted stops', 'stop_adoptions', 'user_id', 'adopted_at', 'dt'],
        ['Landmark uses', 'landmark_uses', 'user_id', 'at', 'dt'],
        ['Town action uses', 'town_uses', 'user_id', 'day', 'day'],
        ['Local deals (stops)', 'local_deals', 'user_id', 'at', 'dt'],
        ['Traveller deals', 'traveller_deals', 'user_id', 'at', 'dt'],
    ],
    'Buying & selling' => [
        ['Market day buys', 'market_buys', 'user_id', 'day', 'day'],
        ['Curio buys', 'curio_buys', 'user_id', '', ''],
        ['Dye pot / skins owned', 'sink_owned', 'user_id', 'at', 'dt'],
        ['Festival stall buys', 'festival_buys', 'user_id', '', ''],
    ],
    'Contests' => [
        ['Harvest Fair entries', 'fair_entries', 'user_id', 'at', 'dt'],
        ['Village Show entries', 'show_entries', 'user_id', 'entered_at', 'dt'],
        ['Garden of the Month entries', 'gotm_entries', 'user_id', 'entered_at', 'dt'],
        ['Pumpkin carvings', 'carvings', 'user_id', 'carved_at', 'dt'],
        ['Guess the Weight', 'marrow_guesses', 'user_id', 'at', 'dt'],
        ['Snail Race bets', 'snail_bets', 'user_id', 'placed_at', 'dt'],
    ],
    'Adventuring' => [
        ['Road walks and wanders', 'expeditions', 'user_id', '', ''],
        ['Treks started (admins excluded)', 'trek_runs', 'user_id', '', ''],
    ],
    ];
}

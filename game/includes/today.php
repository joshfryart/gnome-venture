<?php
declare(strict_types=1);
/**
 * v2.6.40: the Hovel "Today" tab: what changed since the gnome slept. Three groups: needs you (!), overnight, in the village.
 * Every item is [icon, title, small line, link or '']. Each group is built in its own try/catch: a missing table never breaks the page.
 * Village: only villagers the gnome knows (Acquaintance, 20 points, and up) are named; "away" uses the same rule as gclock_npc_away() for today and yesterday.
 */
require_once __DIR__ . '/pal_crew.php';

function today_known_npcs(int $uid): array
{
    return q('SELECT n.*, f.points FROM npc_friends f JOIN npcs n ON n.id = f.npc_id WHERE f.user_id = ? AND f.points >= ? ORDER BY n.name', [$uid, FRIEND_LEVELS[1][0]])->fetchAll();
}

/** Same rule as gclock_npc_away(), for any date. */
function today_npc_away(array $npc, string $date): bool
{
    static $mentors = null;
    if ($mentors === null) {
        require_once __DIR__ . '/calling_quests.php';
        $slugs = array_column(CALLING_MENTORS, 1);
        $mentors = $slugs ? array_map('intval', q('SELECT id FROM npcs WHERE slug IN (' . implode(',', array_fill(0, count($slugs), '?')) . ')', $slugs)->fetchAll(PDO::FETCH_COLUMN)) : [];
    }
    if (in_array((int)$npc['id'], $mentors, true)) return false;
    $v = setting('npc_away_pct'); $pct = $v === '' ? 25 : max(0, min(90, (int)$v));
    return $pct > 0 && hollow_unit('away|n' . $npc['id'] . '|' . $date) * 100 < $pct;
}

function today_data(array $u): array
{
    $uid = (int)$u['id'];
    $need = []; $night = []; $vill = [];
    $link = fn(string $p) => url($p);
    try {   // garden: ripe crops (what the crew did not pick), tired pals, empty-bed warnings
        $ripe = 0;
        $plants = [];
        foreach (q('SELECT * FROM plot_tiles WHERE user_id = ? AND plant_id IS NOT NULL', [$uid])->fetchAll() as $raw) {
            $pid = (int)$raw['plant_id'];
            $p = $plants[$pid] ??= q_one('SELECT * FROM plants WHERE id = ?', [$pid]);
            if (!$p || $p['kind'] === 'cover') continue;
            $t = gclock_tile_grow(annotate_tile($raw, $p), $p);
            if (tile_info($t, $p)['ready']) $ripe++;
        }
        if ($ripe > 0) $need[] = ['🌱', $ripe . ' crop' . ($ripe > 1 ? 's' : '') . ' ripe', 'Ready to harvest in your garden', $link('garden.php')];
    } catch (Throwable $e) {}
    try {
        foreach (q('SELECT * FROM garden_pal_slots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll() as $s) {
            if (!pcrew_tired($s)) continue;
            $pp = pj_pal($uid, (string)$s['pal_uid']);
            $need[] = ['🧩', ($pp['name'] ?? 'A pal') . ' is tired of ' . PCREW_ROLES[$s['role']][1], 'Night ' . ((int)$s['done'] + 1) . ' · working at ' . round(pcrew_eff((int)$s['done'] + 1) * 100) . '%', $link('garden.php?t=help')];
        }
        $rep = pcrew_latest_report($uid);
        foreach (($rep[1]['crew'] ?? []) as $c) if (!empty($c['warn'])) $need[] = ['🌰', 'Plant: ' . $c['warn'], $c['plot'], $link('garden.php?t=help')];
    } catch (Throwable $e) {}
    try {
        require_once __DIR__ . '/quests_view.php';
        $cnt = tasks_counts($u, false);
        if (!empty($cnt['jobs'])) $need[] = ['📋', $cnt['jobs'] . ' job' . ($cnt['jobs'] > 1 ? 's' : '') . ' ready to hand in', '', $link('jobs.php')];
        if (!empty($cnt['journey'])) $need[] = ['📜', 'Journey: ' . $cnt['journey'] . ' ready', '', $link('jobs.php?t=journey')];
        if (!empty($cnt['requests'])) $need[] = ['📌', $cnt['requests'] . ' request' . ($cnt['requests'] > 1 ? 's' : '') . ' to hand in or carry', '', $link('jobs.php?t=requests')];
        require_once __DIR__ . '/jobs.php';
        if (!current_job($uid, 'daily')) $need[] = ['📋', 'New daily job', 'Your job board changed when you slept', $link('jobs.php')];
    } catch (Throwable $e) {}
    try { if (function_exists('msg_unread') && msg_unread($uid) > 0) $need[] = ['💬', 'Reply from the game keeper', '', $link('community.php?t=msgs')]; } catch (Throwable $e) {}
    try {
        $out = (int)q_val("SELECT COUNT(*) FROM ppal_jobs WHERE user_id = ? AND state = 'ready'", [$uid]);
        if ($out > 0) $need[] = ['🌲', $out . ' pal trip' . ($out > 1 ? 's' : '') . ' ready to collect', '', $link('paljobs.php')];
    } catch (Throwable $e) {}

    try {   // overnight: weather today and tomorrow, the crew, pots and jars
        $s = gclock_state($u);
        $now = hollow_now(hollow_user_region($u), null, $s);
        $next = hollow_now(hollow_user_region($u), null, gclock_state(['game_day' => (int)$u['game_day'] + 1, 'game_minute' => GAME_WAKE_MINUTE]));
        $night[] = [$now['weather_emoji'], $now['weather_label'] . ' today', 'Tomorrow: ' . $next['weather_emoji'] . ' ' . $next['weather_label'], ''];
    } catch (Throwable $e) {}
    try {
        $rep = pcrew_latest_report($uid);
        if ($rep && (int)$rep[0] === (int)$u['game_day'] && !empty($rep[1]['crew'])) {
            $bits = [];
            foreach ($rep[1]['crew'] as $c) if ($c['text'] !== '') $bits[] = $c['text'];
            $night[] = ['🧩', 'Garden crew', implode(' · ', $bits), $link('hovel.php?t=pals')];
        }
    } catch (Throwable $e) {}
    try {
        [$pw, $pa] = gclock_pot_ready($uid);
        $pots = (int)q_val('SELECT COUNT(*) FROM cook_pots WHERE user_id = ? AND collected_at IS NULL AND ' . $pw, array_merge([$uid], $pa));
        if ($pots > 0) $night[] = ['🍳', $pots . ' pot' . ($pots > 1 ? 's' : '') . ' done', 'Ready in your kitchen', $link('inventory.php?tab=craft&c=cooking')];
        [$jw, $ja] = gclock_jar_ready($uid);
        $jars = (int)q_val('SELECT COUNT(*) FROM pantry_jars WHERE user_id = ? AND collected_at IS NULL AND ' . $jw, array_merge([$uid], $ja));
        if ($jars > 0) $night[] = ['🫙', $jars . ' jar' . ($jars > 1 ? 's' : '') . ' ready', 'In your pantry', $link('inventory.php?tab=craft&c=pantry')];
    } catch (Throwable $e) {}

    try {   // village: birthdays, who is away or back (known villagers only), market day
        $today = gclock_my_date();
        $yday = hollow_date_add($today, -1);
        $known = today_known_npcs($uid);
        $away = []; $back = []; $bd = [];
        foreach ($known as $n) {
            $a1 = today_npc_away($n, $today); $a0 = today_npc_away($n, $yday);
            if ($a1) $away[] = (string)$n['name']; elseif ($a0) $back[] = (string)$n['name'];
            if (npc_birthday_today($n)) $bd[] = (string)$n['name'];
        }
        foreach ($bd as $nm) $vill[] = ['🎂', $nm . '’s birthday', 'A friend’s day', ''];
        if ($away || $back) $vill[] = ['🚶', $away ? 'Away today: ' . implode(', ', $away) : 'Everyone you know is about', $back ? 'Back: ' . implode(', ', $back) : '', ''];
        elseif ($known) $vill[] = ['🚶', 'Everyone you know is about.', '', ''];
        if (function_exists('market_day_on') && market_day_on($today)) $vill[] = ['🛒', 'Market day today', 'The stalls are open', $link('market.php')];
    } catch (Throwable $e) {}
    return ['need' => $need, 'night' => $night, 'village' => $vill];
}

<?php
/**
 * Living stops (v2.5.72): state that acts read and change.
 *  - meters (per player per stop, in stop_prog "meter:<name>"): acts fill them, time drains them, a full one gives that stop a perk for a few days
 *  - familiarity (per player per stop, from how many things you have done there)
 *  - calendar (data/stop_calendar.txt): real dates force a happening (market day, festivals)
 *  - threads (data/stop_threads.txt): little stories of a few beats over several days
 *  - notice board (what is coming up, what needs help, what others did lately)
 * See claude/plan-living-stops.md. Nothing here is random per view; everything derives from (player, stop, UTC day).
 */

const STOP_METERS = [
    'repairs' => ['🔨', 'Repairs', 'needs mending'],
    'larder'  => ['🧺', 'Larder', 'is running low'],
    'cheer'   => ['🎈', 'Cheer', 'could do with some fun'],
];
const STOP_METER_OF_TAG = ['fix' => 'repairs', 'craft' => 'repairs', 'cook' => 'larder', 'gather' => 'larder', 'tend' => 'larder',
    'play' => 'cheer', 'lore' => 'cheer', 'trade' => 'cheer', 'rest' => 'cheer'];
const STOP_METER_GAIN = 10;    // per thing done
const STOP_METER_DECAY = 3;    // per day, worked out when read (no cron)
const STOP_METER_AFTER = 30;   // where a meter restarts after it fills
const STOP_PERK_DAYS = 7;
const STOP_FAMILIARITY = ['stranger' => 0, 'regular' => 3, 'local' => 20, 'pillar' => 60];

function stop_days_between(string $from, string $to): int
{
    $a = strtotime($from . ' 00:00:00 UTC');
    $b = strtotime($to . ' 00:00:00 UTC');
    return ($a === false || $b === false) ? 0 : max(0, (int)floor(($b - $a) / 86400));
}

// ---------------------------------------------------------------- meters

/** A meter now, 0 to 99 (a full one is spent into a perk at once). */
function stop_meter_get(int $uid, int $locId, string $name): int
{
    [$n, $d] = stop_prog_get($uid, $locId, 'meter:' . $name);
    $since = (string)($d['d'] ?? '');
    $age = $since !== '' ? stop_days_between($since, hollow_date('Y-m-d')) : 0;
    return max(0, min(99, $n - STOP_METER_DECAY * $age));
}

/** Move a meter. Returns [new value, perk meter name filled or '']. */
function stop_meter_add(int $uid, int $locId, string $name, int $amt): array
{
    if (!isset(STOP_METERS[$name])) return [0, ''];
    $v = stop_meter_get($uid, $locId, $name) + $amt;
    $filled = '';
    if ($v >= 100) {
        $filled = $name;
        $v = STOP_METER_AFTER;
        $until = gmdate('Y-m-d', strtotime(hollow_date('Y-m-d') . ' 12:00:00 UTC +' . (STOP_PERK_DAYS - 1) . ' days'));
        stop_prog_set($uid, $locId, 'perk:' . $name, 1, ['until' => $until]);
    }
    stop_prog_set($uid, $locId, 'meter:' . $name, max(0, $v), ['d' => hollow_date('Y-m-d')]);
    return [max(0, $v), $filled];
}

/** @return array<string,string> perks running for this player at this stop: meter name => last day */
function stop_perks(int $uid, int $locId): array
{
    if ($uid < 1) return [];
    $out = [];
    $today = hollow_date('Y-m-d');
    foreach (q("SELECT k, data FROM stop_prog WHERE user_id = ? AND location_id = ? AND k LIKE 'perk:%'", [$uid, $locId])->fetchAll() as $r) {
        $until = (string)(json_decode((string)$r['data'], true)['until'] ?? '');
        if ($until !== '' && $until >= $today) $out[substr((string)$r['k'], 5)] = $until;
    }
    return $out;
}

/** Each running perk is one more thing per visit and one more turn a day at that stop (they stack). */
function stop_perk_bonus(int $uid, int $locId): int
{
    return count(stop_perks($uid, $locId));
}

// ---------------------------------------------------------------- familiarity

function stop_fam_count(int $uid, int $locId): int
{
    return $uid < 1 ? 0 : (int)q_val('SELECT COUNT(*) FROM stop_log WHERE user_id = ? AND location_id = ?', [$uid, $locId]);
}

/** stranger / regular / local / pillar (an adopter is a pillar). */
function stop_fam_level(int $uid, int $locId): string
{
    require_once __DIR__ . '/stop_adopt.php';
    $ad = stop_adoption($locId);
    if ($ad && (int)$ad['user_id'] === $uid && $uid > 0) return 'pillar';
    $n = stop_fam_count($uid, $locId);
    $lv = 'stranger';
    foreach (STOP_FAMILIARITY as $k => $min) if ($n >= $min) $lv = $k;
    return $lv;
}

// ---------------------------------------------------------------- act state (needs / moves)

/** @return array<string,array{needs:string,moves:string}> data/stop_act_state.txt: slug | needs | moves (overrides; other acts move a meter by their tag) */
function stop_act_state(): array
{
    static $s = null;
    if ($s === null) {
        $s = [];
        foreach (stops_file_rows('stop_act_state.txt') as $r) if (count($r) >= 3 && $r[0] !== '') $s[$r[0]] = ['needs' => $r[1] === '-' ? '' : $r[1], 'moves' => $r[2] === '-' ? '' : $r[2]];
    }
    return $s;
}

/** Needs: parts joined by "/": meter:NAME<N  meter:NAME>=N  fam>=LEVEL. Empty = no needs. */
function stop_needs_ok(string $needs, int $uid, int $locId): bool
{
    foreach (array_filter(array_map('trim', explode('/', $needs))) as $p) {
        if (preg_match('/^meter:([a-z]+)(<|>=)(\d+)$/', $p, $m)) {
            $v = stop_meter_get($uid, $locId, $m[1]);
            if ($m[2] === '<' ? !($v < (int)$m[3]) : !($v >= (int)$m[3])) return false;
        } elseif (preg_match('/^fam>=([a-z]+)$/', $p, $m)) {
            $have = array_search(stop_fam_level($uid, $locId), array_keys(STOP_FAMILIARITY), true);
            $want = array_search($m[1], array_keys(STOP_FAMILIARITY), true);
            if ($want === false || $have < $want) return false;
        }
    }
    return true;
}

/** "meter:repairs+15,meter:cheer+3" for an act: its own row, else one meter by its tag. Returns [[meter, amount], ...]. */
function stop_act_moves(array $a): array
{
    $st = stop_act_state()[(string)$a['slug']] ?? null;
    $out = [];
    if ($st && $st['moves'] !== '') {
        foreach (array_filter(array_map('trim', explode(',', $st['moves']))) as $p) if (preg_match('/^meter:([a-z]+)([+-]\d+)$/', $p, $m) && isset(STOP_METERS[$m[1]])) $out[] = [$m[1], (int)$m[2]];
        return $out;
    }
    foreach (stop_act_tags($a) as $t) if (isset(STOP_METER_OF_TAG[$t])) return [[STOP_METER_OF_TAG[$t], STOP_METER_GAIN]];
    return [];
}

/** After a done act: move its meters, return lines to show. A festival day doubles the gain. */
function stop_living_after(array $u, array $loc, array $a): array
{
    $uid = (int)$u['id'];
    $lid = (int)$loc['id'];
    $lines = [];
    $fest = !empty(stop_happenings()[(string)(stop_now($loc)['hp'] ?? '')]['cal']);
    foreach (stop_act_moves($a) as [$m, $amt]) {
        if ($amt > 0 && $fest) $amt *= 2;
        [$v, $filled] = stop_meter_add($uid, $lid, $m, $amt);
        $lines[] = STOP_METERS[$m][0] . ' ' . STOP_METERS[$m][1] . ' ' . ($amt >= 0 ? '+' : '') . $amt;
        if ($filled !== '') $lines[] = '🌟 ' . STOP_METERS[$filled][1] . ' is full! ' . $loc['name'] . ' gives you one more thing to do for ' . STOP_PERK_DAYS . ' days';
    }
    return $lines;
}

// ---------------------------------------------------------------- calendar

/** Does a calendar rule fall on this date? weekly:sat  monthly:first:sun  monthly:last:sun  date:06-21  range:12-20..12-26 */
function stop_cal_match(string $rule, string $ymd): bool
{
    $t = strtotime($ymd . ' 12:00:00 UTC');
    if ($t === false) return false;
    $dow = strtolower(gmdate('D', $t));
    $md = gmdate('m-d', $t);
    $p = explode(':', $rule, 3);
    switch ($p[0]) {
        case 'weekly': return $dow === ($p[1] ?? '');
        case 'monthly':
            if ($dow !== ($p[2] ?? '')) return false;
            $dom = (int)gmdate('j', $t);
            return ($p[1] ?? '') === 'first' ? $dom <= 7 : (($p[1] ?? '') === 'last' ? $dom + 7 > (int)gmdate('t', $t) : false);
        case 'date': return $md === ($p[1] ?? '');
        case 'range':
            [$a, $b] = array_pad(explode('..', (string)($p[1] ?? '')), 2, '');
            return $a !== '' && $b !== '' && ($a <= $b ? ($md >= $a && $md <= $b) : ($md >= $a || $md <= $b));
    }
    return false;
}

/** @return list<array> data/stop_calendar.txt: rule | id | icon | name | headline | types | regions | tags | goal */
function stop_calendar(): array
{
    static $c = null;
    if ($c === null) {
        $c = [];
        foreach (stops_file_rows('stop_calendar.txt') as $r) {
            if (count($r) < 8) continue;
            $c[] = ['rule' => $r[0], 'id' => 'c_' . $r[1], 'icon' => $r[2], 'name' => $r[3], 'headline' => $r[4], 'types' => $r[5],
                'regions' => array_values(array_filter(array_map('trim', explode(',', $r[6])))), 'cond' => '-',
                'tags' => array_values(array_filter(array_map('trim', explode(',', $r[7])))), 'weight' => 1, 'cal' => true, 'goal' => $r[8] ?? ''];
        }
    }
    return $c;
}

function stop_cal_fits(array $ev, array $loc): bool
{
    $ts = array_map('trim', explode(',', (string)$ev['types']));
    if (!in_array('any', $ts, true) && !in_array(stop_type_of($loc), $ts, true)) return false;
    return !$ev['regions'] || in_array(stop_region_code($loc), $ev['regions'], true);
}

/** The calendar event happening at this stop on a date, or null. */
function stop_cal_event(array $loc, string $ymd): ?array
{
    foreach (stop_calendar() as $ev) if (stop_cal_match($ev['rule'], $ymd) && stop_cal_fits($ev, $loc)) return $ev;
    return null;
}

/** The next events at a stop after today: [[date, event], ...]. */
function stop_cal_next(array $loc, int $count = 3, int $days = 21): array
{
    $out = [];
    $d = hollow_date('Y-m-d');
    for ($i = 1; $i <= $days && count($out) < $count; $i++) {
        $day = gmdate('Y-m-d', strtotime($d . ' 12:00:00 UTC +' . $i . ' days'));
        if ($ev = stop_cal_event($loc, $day)) $out[] = [$day, $ev];
    }
    return $out;
}

// ---------------------------------------------------------------- threads

/** @return array<string,array> data/stop_threads.txt: id | icon | name | stop types | regions | reward | beat1 ;; beat2 ... (a beat is "title ~ story") */
function stop_threads(): array
{
    static $t = null;
    if ($t === null) {
        $t = [];
        foreach (stops_file_rows('stop_threads.txt') as $r) {
            if (count($r) < 7) continue;
            $beats = [];
            foreach (array_filter(array_map('trim', explode(';;', $r[6]))) as $b) { [$ti, $tx] = array_pad(array_map('trim', explode('~', $b, 2)), 2, ''); $beats[] = ['title' => $ti, 'text' => $tx]; }
            if ($beats) $t[$r[0]] = ['id' => $r[0], 'icon' => $r[1], 'name' => $r[2], 'types' => $r[3], 'regions' => array_values(array_filter(array_map('trim', explode(',', $r[4])))), 'reward' => $r[5], 'beats' => $beats];
        }
    }
    return $t;
}

/** The thread offered to this player here today (one beat a day, Regulars and up): the act row to show, or null. */
function stop_thread_offer(int $uid, array $loc): ?array
{
    if ($uid < 1 || !stop_needs_ok('fam>=regular', $uid, (int)$loc['id'])) return null;
    $act = stop_acts()['thread_go'] ?? null;
    if (!$act) return null;
    $type = stop_type_of($loc);
    $rc = stop_region_code($loc);
    $today = hollow_date('Y-m-d');
    $fit = [];
    foreach (stop_threads() as $th) {
        $ts = array_map('trim', explode(',', $th['types']));
        if (!in_array('any', $ts, true) && !in_array($type, $ts, true)) continue;
        if ($th['regions'] && !in_array($rc, $th['regions'], true)) continue;
        $fit[] = $th;
    }
    usort($fit, fn($x, $y) => crc32('thr|' . $loc['slug'] . '|' . $x['id']) <=> crc32('thr|' . $loc['slug'] . '|' . $y['id']));
    foreach ($fit as $th) {
        [$n, $d] = stop_prog_get($uid, (int)$loc['id'], 'thread:' . $th['id']);
        if ($n >= count($th['beats'])) continue;                        // finished
        if (($d['day'] ?? '') === $today) return null;                  // today's beat is done; no other thread jumps in
        $b = $th['beats'][$n];
        return array_merge($act, ['name' => $th['icon'] . ' ' . $th['name'] . ': ' . $b['title'], 'blurb' => $b['text'], 'icon' => $th['icon'], 'thread' => $th['id'], 'beat' => $n + 1, 'beats' => count($th['beats'])]);
    }
    return null;
}

/** Do the thread's next beat. Returns the lines to show. */
function stop_thread_do(array $u, array $loc, string $threadId): array
{
    $uid = (int)$u['id'];
    $th = stop_threads()[$threadId] ?? null;
    if (!$th) throw new UserError('That story has ended.');
    [$n, $d] = stop_prog_get($uid, (int)$loc['id'], 'thread:' . $threadId);
    if ($n >= count($th['beats']) || ($d['day'] ?? '') === hollow_date('Y-m-d')) throw new UserError('That is done for today.');
    stop_prog_set($uid, (int)$loc['id'], 'thread:' . $threadId, $n + 1, ['day' => hollow_date('Y-m-d')]);
    $lines = [$th['icon'] . ' ' . $th['name'] . ': part ' . ($n + 1) . ' of ' . count($th['beats'])];
    if ($n + 1 >= count($th['beats'])) {
        $lines[] = '🎉 The end of “' . $th['name'] . '”!';
        $lines = array_merge($lines, stop_rewards($u, $loc, $th['reward'], 1.0, ''));
    } else {
        $lines = array_merge($lines, stop_rewards($u, $loc, 'xp=3:1', 1.0, ''));
    }
    return $lines;
}

// ---------------------------------------------------------------- notice board

/** The meters as small bars (for the Do tab). */
function stop_meters_html(int $uid, int $locId): string
{
    $h = '<ul class="st-meters">';
    foreach (STOP_METERS as $k => [$ico, $lab]) {
        $v = stop_meter_get($uid, $locId, $k);
        $h .= '<li><label>' . $ico . ' ' . e($lab) . ' <meter min="0" max="100" low="30" high="70" optimum="100" value="' . $v . '">' . $v . '%</meter></label></li>';
    }
    $h .= '</ul>';
    foreach (stop_perks($uid, $locId) as $m => $until) {
        $h .= '<p class="st-perk">🌟 <b>' . e(STOP_METERS[$m][1]) . ' is full</b> · one more thing to do here until ' . e(date('j M', strtotime($until))) . '</p>';
    }
    return $h;
}

/** The notice board card: coming up, needs help, done lately. */
function stop_board_html(array $u, array $loc): string
{
    $uid = (int)$u['id'];
    $lid = (int)$loc['id'];
    $h = '<div class="st-board"><h3 class="st-h">📋 Notice board</h3>';
    $next = stop_cal_next($loc);
    $h .= '<h4>Coming up</h4>';
    if ($next) {
        $h .= '<ul>';
        foreach ($next as [$day, $ev]) $h .= '<li>' . e($ev['icon'] . ' ' . $ev['name']) . ' <small class="muted">' . e(date('D j M', strtotime($day))) . '</small></li>';
        $h .= '</ul>';
    } else $h .= '<p class="muted">Nothing planned yet.</p>';
    $need = [];
    foreach (STOP_METERS as $k => [$ico, $lab, $says]) if (stop_meter_get($uid, $lid, $k) < 40) $need[] = '<li>' . $ico . ' ' . e($lab) . ' ' . e($says) . '</li>';
    $h .= '<h4>Needs help</h4>' . ($need ? '<ul>' . implode('', $need) . '</ul>' : '<p class="muted">Everything is in good shape.</p>');
    $rows = q('SELECT l.act, l.day, u.gnome_name, u.username FROM stop_log l JOIN users u ON u.id = l.user_id WHERE l.location_id = ? ORDER BY l.id DESC LIMIT 5', [$lid])->fetchAll();
    $h .= '<h4>Done lately</h4>';
    if ($rows) {
        $h .= '<ul>';
        foreach ($rows as $r) {
            $a = stop_acts()[$r['act']] ?? null;
            if (!$a) continue;
            $h .= '<li><b>' . e((string)($r['gnome_name'] ?: $r['username'])) . '</b> · ' . e($a['icon'] . ' ' . $a['name']) . ' <small class="muted">' . e(date('j M', strtotime((string)$r['day']))) . '</small></li>';
        }
        $h .= '</ul>';
    } else $h .= '<p class="muted">Quiet so far.</p>';
    return $h . '<p class="help">Your standing here: <b>' . e(ucfirst(stop_fam_level($uid, $lid))) . '</b> · ' . stop_fam_count($uid, $lid) . ' things done at this stop.</p></div>';
}

/** What the perk list shows for a place: [perks (meter => last day), meters with a value (meter => 0..99)]. */
function stop_perk_data(array $u, array $node): array
{
    if (($node['kind'] ?? '') !== 'village') return [[], []];
    $uid = (int)$u['id'];
    $lid = (int)$node['id'];
    $meters = [];
    foreach (STOP_METERS as $k => $m) if (($v = stop_meter_get($uid, $lid, $k)) > 0) $meters[$k] = $v;
    return [stop_perks($uid, $lid), $meters];
}

/** The inside of the perk list (name, perks, meters), or '' when there is nothing to show. */
function stop_perk_body(array $u, array $node): string
{
    [$perks, $meters] = stop_perk_data($u, $node);
    if (!$perks && !$meters) return '';
    $h = '<p><b>' . e((string)$node['name']) . '</b></p><h4>Perks</h4>';
    if ($perks) {
        $h .= '<ul>';
        foreach ($perks as $m => $until) $h .= '<li>' . STOP_METERS[$m][0] . ' ' . e(STOP_METERS[$m][1]) . ' is full: one more thing to do here <small class="muted">until ' . e(date('j M', strtotime($until))) . '</small></li>';
        $h .= '</ul>';
    } else $h .= '<p class="muted">None yet. Fill a bar to earn one.</p>';
    $h .= '<h4>Meters</h4><ul>';
    foreach (STOP_METERS as $k => [$ico, $lab]) $h .= '<li>' . $ico . ' ' . e($lab) . ' <meter min="0" max="100" value="' . ($meters[$k] ?? 0) . '">' . ($meters[$k] ?? 0) . '%</meter></li>';
    return $h . '</ul>';
}

/** The round Perks button for the row under the picture (next to World) as a hub_navbar "extra" entry, or null when there is nothing to show. */
function stop_perk_nav(array $u, array $node): ?array
{
    return stop_perk_body($u, $node) === '' ? null : ['id' => 'perks', 'label' => 'Perks', 'icon' => 'ico-medal-gold.png', 'href' => url('town.php')];
}

/**
 * A small circle by the 🌍 in the page trail of the plain stop page (town.php): shows once acts here have moved a meter or a perk runs, and opens a list of the perks
 * (and meters) at this place. The picture page (here.php) has the round Perks button instead. '' when nothing to show. A plain <details>, so it works without script.
 */
function stop_perk_chip(array $u, array $node): string
{
    $body = stop_perk_body($u, $node);
    if ($body === '') return '';
    $n = count(stop_perk_data($u, $node)[0]);
    return '<details class="pkchip"><summary aria-label="' . ($n ? $n . ' perk' . ($n === 1 ? '' : 's') . ' here' : 'Your progress here') . '"><span class="pkdot' . ($n ? ' on' : '') . '">' . ($n ?: '') . '</span></summary><div class="pkpop">' . $body . '</div></details>';
}

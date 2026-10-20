<?php
declare(strict_types=1);

/**
 * v1.2.0, player mentors. (includes/../mentor.php is the NPC calling lodge: unrelated. Everything here is prefixed pmentor_ / mentors120_.)
 *
 * A gnome at level >= pmentor_min_level who ticked "Happy to mentor" can guide up to pmentor_max newcomers (level < pmentor_until_level).
 * The newcomer asks, the mentor accepts or declines, either can end it. While linked the newcomer earns +pmentor_xp_bonus_pct % XP and the
 * mentor earns pmentor_share_pct % of the newcomer's XP (at most pmentor_daily_cap per day). At pmentor_until_level the link graduates:
 * both get a one-time reward + an Almanac page, once per newcomer ever. The mentor's reward is capped per week.
 *
 * Wiring: mentors120_settings() merged by settings_schema(); mentors120_schema() by schema.php; add_xp() calls mentors120_xp_bonus()
 * before and mentors120_after_xp() after the XP is saved; pal_block() calls mentors120_on_block(); mentors120_upgrade() is idempotent.
 *
 * Alt accounts: users.reg_ip_hash (a salted hash of the sign-up IP, set by register.php) must differ between mentor and newcomer; the mentor
 * must also be past the fresh-gnome hold (fresh_hold()); the daily share cap and the weekly graduation cap limit what any farm could earn.
 */

const PMENTOR_REQUEST_PENDING_MAX = 3;    // most requests one newcomer can have waiting
const PMENTOR_MENTOR_PENDING_MAX = 10;    // most requests waiting for one mentor
const PMENTOR_RETRY_DAYS = 7;             // after a decline or an ended link, the same pair waits this long

function mentors120_settings(): array
{
    $int = fn(string $label, int $def, int $min, int $max) => ['label' => $label, 'type' => 'int', 'default' => (string)$def, 'min' => $min, 'max' => $max];
    return [
        'pmentor_on'              => ['label' => 'Player mentors: experienced gnomes can guide newcomers', 'type' => 'bool', 'default' => '1'],
        'pmentor_min_level'       => $int('Player mentors: gnome level needed to be a mentor', 20, 2, 200),
        'pmentor_until_level'     => $int('Player mentors: a newcomer below this gnome level can have a mentor (they graduate on reaching it)', 8, 2, 100),
        'pmentor_max'             => $int('Player mentors: most newcomers one mentor guides at once', 2, 1, 10),
        'pmentor_xp_bonus_pct'    => $int('Player mentors: bonus XP (%) the newcomer earns while linked', 10, 0, 100),
        'pmentor_share_pct'       => $int('Player mentors: the mentor earns this % of the newcomer’s XP', 5, 0, 100),
        'pmentor_daily_cap'       => $int('Player mentors: most share XP a mentor can earn per Hollow day', 100, 0, 100000),
        'pmentor_grad_petals'     => $int('Player mentors: Petals the newcomer gets on graduating', 150, 0, 100000),
        'pmentor_grad_petals_mentor' => $int('Player mentors: Petals the mentor gets for each graduate', 250, 0, 100000),
        'pmentor_grad_week_cap'   => $int('Player mentors: most graduate rewards one mentor gets per 7 days', 3, 0, 100),
        'pmentor_cooldown_hours'  => $int('Player mentors: hours a newcomer waits between mentor requests', 2, 0, 168),
        'pmentor_online_days'     => $int('Player mentors: a willing mentor is listed if seen within this many days', 3, 1, 60),
    ];
}

/** [tables, indexes, columns] for schema_statements(). */
function mentors120_schema(string $PK, string $ID, string $END): array
{
    $t = [];
    $t[] = "CREATE TABLE IF NOT EXISTS pmentor_links (
        id $PK,
        mentor_id $ID NOT NULL,
        newcomer_id $ID NOT NULL,
        status VARCHAR(12) NOT NULL DEFAULT 'pending',
        created_at DATETIME NOT NULL,
        closed_at DATETIME NULL,
        closed_by $ID NULL,
        xp_given INT NOT NULL DEFAULT 0,
        xp_bonus INT NOT NULL DEFAULT 0,
        UNIQUE (mentor_id, newcomer_id)
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS pmentor_grads (
        newcomer_id $ID NOT NULL PRIMARY KEY,
        mentor_id $ID NOT NULL,
        graduated_at DATETIME NOT NULL,
        mentor_rewarded INT NOT NULL DEFAULT 0
    )$END";
    $t[] = "CREATE TABLE IF NOT EXISTS pmentor_days (
        mentor_id $ID NOT NULL,
        day VARCHAR(10) NOT NULL,
        xp INT NOT NULL DEFAULT 0,
        PRIMARY KEY (mentor_id, day)
    )$END";
    $i = [
        'CREATE INDEX idx_pmentor_links_newcomer ON pmentor_links (newcomer_id, status)',
        'CREATE INDEX idx_pmentor_links_mentor ON pmentor_links (mentor_id, status)',
        'CREATE INDEX idx_pmentor_grads_mentor ON pmentor_grads (mentor_id, graduated_at)',
    ];
    $c = [
        ['users', 'pmentor_open', 'INT NOT NULL DEFAULT 0'],      // 1 = "Happy to mentor"
        ['users', 'reg_ip_hash', 'VARCHAR(64) NULL'],             // salted hash of the sign-up IP (alt-account guard for mentors)
    ];
    return [$t, $i, $c];
}

function mentors120_on(): bool
{
    return setting('pmentor_on') === '1';
}

/** Idempotent. Makes the tables/columns if missing (db_migrate normally does) and the two Almanac pages. */
function mentors120_upgrade(): void
{
    $driver = db()->getAttribute(PDO::ATTR_DRIVER_NAME);
    $sqlite = $driver === 'sqlite';
    [$t, $i, $c] = mentors120_schema($sqlite ? 'INTEGER PRIMARY KEY AUTOINCREMENT' : 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY', $sqlite ? 'INTEGER' : 'INT UNSIGNED',
        $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
    foreach ($t as $sql) { try { db()->exec($sql); } catch (PDOException $e) { error_log('mentors120 table: ' . $e->getMessage()); } }
    foreach ($c as [$table, $col, $def]) {
        try { db()->query("SELECT $col FROM $table LIMIT 1"); }
        catch (PDOException $e) { try { db()->exec("ALTER TABLE $table ADD COLUMN $col $def"); } catch (PDOException $e2) { error_log('mentors120 column: ' . $e2->getMessage()); } }
    }
    foreach ($i as $sql) { try { db()->exec($sql); } catch (PDOException $e) { /* exists */ } }
    mentors120_pages();
}

/** The two Almanac pages (a stamp each for the newcomer who graduated and the mentor who guided one). */
function mentors120_pages(): void
{
    $pages = [
        'pmentor:graduate' => ['Mentor’s Guidance', 'A mentor showed you the ropes. You reached the level where a newcomer stands on their own two boots, and the Hollow noticed.', 'Ask an experienced gnome to be your mentor (Gnome friends → Gnome mentor).', 61],
        'pmentor:mentor' => ['A Newcomer Grown', 'You guided a newcomer all the way to their own feet. Every Hollow garden was once somebody’s first.', 'Mentor a newcomer until they graduate.', 62],
    ];
    foreach ($pages as $key => [$title, $body, $hint, $sort]) {
        if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', [$key])) continue;
        try { db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Mentors', 'title' => $title, 'sort_order' => $sort, 'body' => $body, 'unlock_key' => $key, 'hint' => $hint]); }
        catch (PDOException $e) { /* made at the same moment */ }
    }
}

// ---------------- Helpers ----------------

function mentors120_name(array $r): string
{
    return trim((string)($r['gnome_name'] ?? '')) ?: (string)($r['username'] ?? 'Gnome');
}

/** Salted hash of an IP, for the alt-account guard. Never stores the address. */
function mentors120_ip_hash(string $ip): string
{
    $salt = '';
    try { global $CONFIG; $salt = hash('sha256', (string)json_encode($CONFIG['db'] ?? [])); } catch (Throwable $e) {}
    return hash('sha256', 'gv-pmentor|' . $salt . '|' . $ip);
}

/** Called by register.php right after the account is made. Never breaks sign-up. */
function mentors120_note_signup(int $uid): void
{
    try { q('UPDATE users SET reg_ip_hash = ? WHERE id = ?', [mentors120_ip_hash(client_ip()), $uid]); } catch (Throwable $e) { /* column not there yet */ }
}

function mentors120_active_count(int $mentorId): int
{
    return (int)q_val("SELECT COUNT(*) FROM pmentor_links WHERE mentor_id = ? AND status = 'active'", [$mentorId]);
}

/** The active link where this gnome is the newcomer, or null. */
function mentors120_link_of(int $newcomerId): ?array
{
    return q_one("SELECT * FROM pmentor_links WHERE newcomer_id = ? AND status = 'active' ORDER BY id LIMIT 1", [$newcomerId]) ?: null;
}

function mentors120_graduated(int $uid): bool
{
    return (bool)q_val('SELECT 1 FROM pmentor_grads WHERE newcomer_id = ?', [$uid]);
}

/** Same sign-up address on both sides (when both are known)? */
function mentors120_same_origin(int $a, int $b): bool
{
    $h = q('SELECT reg_ip_hash FROM users WHERE id IN (?, ?)', [$a, $b])->fetchAll(PDO::FETCH_COLUMN);
    return count($h) === 2 && $h[0] !== null && $h[0] !== '' && $h[0] === $h[1];
}

/** Why this gnome can't be a newcomer right now ('' = can). */
function mentors120_newcomer_problem(array $u): string
{
    if (!mentors120_on()) return 'Mentors are resting right now.';
    if ((int)$u['level'] >= (int)setting('pmentor_until_level')) return 'Mentors guide gnomes below level ' . (int)setting('pmentor_until_level') . '.';
    if (mentors120_graduated((int)$u['id'])) return 'You have already graduated from a mentor.';
    if (mentors120_link_of((int)$u['id'])) return 'You already have a mentor.';
    return '';
}

/** A mentor row (users) if this gnome could take requests, else null. */
function mentors120_mentor_row(int $id): ?array
{
    $m = q_one('SELECT * FROM users u WHERE u.id = ? AND u.deleted_at IS NULL AND u.onboarded = 1 AND ' . gnome_in_play_sql('u'), [$id]);
    if (!$m) return null;
    if ((int)$m['level'] < (int)setting('pmentor_min_level')) return null;
    if (fresh_hold($m) !== '') return null;   // a brand-new account is never a mentor
    return $m;
}

// ---------------- Requests ----------------

function mentors120_request(array $u, int $mentorId): array
{
    $me = (int)$u['id'];
    if ($mentorId === $me) return [false, 'You can’t be your own mentor.'];
    if ($p = mentors120_newcomer_problem($u)) return [false, $p];
    if (user_muted($u)) return [false, 'A moderator has paused your writing for now, which includes requests. You can still play.'];
    $m = mentors120_mentor_row($mentorId);
    require_once __DIR__ . '/pals.php';
    if (!$m || (int)$m['pmentor_open'] !== 1 || pal_blocked($me, $mentorId) || mentors120_same_origin($me, $mentorId)) return [false, 'That gnome isn’t taking mentees right now.'];
    $name = mentors120_name($m);
    if (mentors120_active_count($mentorId) >= (int)setting('pmentor_max')) return [false, $name . ' is guiding as many gnomes as they can.'];
    if ((int)q_val("SELECT COUNT(*) FROM pmentor_links WHERE mentor_id = ? AND status = 'pending'", [$mentorId]) >= PMENTOR_MENTOR_PENDING_MAX) return [false, $name . ' has a lot of requests waiting. Try another mentor.'];
    if ((int)q_val("SELECT COUNT(*) FROM pmentor_links WHERE newcomer_id = ? AND status = 'pending'", [$me]) >= PMENTOR_REQUEST_PENDING_MAX) return [false, 'You have ' . PMENTOR_REQUEST_PENDING_MAX . ' requests waiting. Let them be answered first.'];
    $cool = (int)setting('pmentor_cooldown_hours');
    if ($cool > 0 && q_val('SELECT 1 FROM pmentor_links WHERE newcomer_id = ? AND created_at > ?', [$me, gmdate('Y-m-d H:i:s', time() - $cool * 3600)]))
        return [false, 'Give it a little while before asking another mentor (' . $cool . ' hour' . ($cool === 1 ? '' : 's') . ' between requests).'];
    $old = q_one('SELECT id, status, closed_at FROM pmentor_links WHERE mentor_id = ? AND newcomer_id = ?', [$mentorId, $me]);
    if ($old) {
        if ($old['status'] === 'pending') return [false, 'Your request is already waiting.'];
        if ($old['status'] === 'active') return [false, 'You already have this mentor.'];
        if (in_array($old['status'], ['declined', 'ended'], true) && strtotime((string)$old['closed_at'] . ' UTC') > time() - PMENTOR_RETRY_DAYS * 86400)
            return [false, 'Try a different mentor, or ask this one again in a few days.'];
        if (q("UPDATE pmentor_links SET status = 'pending', created_at = ?, closed_at = NULL, closed_by = NULL WHERE id = ? AND status NOT IN ('pending', 'active')", [now(), $old['id']])->rowCount() !== 1)
            return [false, 'Your request is already waiting.'];
    } else {
        try { db_insert('pmentor_links', ['mentor_id' => $mentorId, 'newcomer_id' => $me, 'status' => 'pending', 'created_at' => now()]); }
        catch (PDOException $e) { return [false, 'Your request is already waiting.']; }
    }
    require_once __DIR__ . '/trade.php';
    notify($mentorId, '🎓 ' . gnome_name($u) . ' (level ' . (int)$u['level'] . ') asks you to be their mentor. Answer under Gnome friends → Gnome mentor.');
    return [true, '🎓 Request sent to ' . $name . '.'];
}

/** The mentor answers: accept | decline. $linkId is the pmentor_links id. */
function mentors120_answer(array $u, int $linkId, string $answer): array
{
    $me = (int)$u['id'];
    $l = q_one("SELECT * FROM pmentor_links WHERE id = ? AND mentor_id = ? AND status = 'pending'", [$linkId, $me]);
    if (!$l) return [false, 'That request is no longer there.'];
    $nid = (int)$l['newcomer_id'];
    require_once __DIR__ . '/pals.php';
    if ($answer === 'decline') {
        q("UPDATE pmentor_links SET status = 'declined', closed_at = ?, closed_by = ? WHERE id = ? AND status = 'pending'", [now(), $me, $linkId]);
        return [true, 'Request declined. They won’t be told.'];
    }
    if (!mentors120_on()) return [false, 'Mentors are resting right now.'];
    if (!mentors120_mentor_row($me) || (int)$u['level'] < (int)setting('pmentor_min_level')) return [false, 'You aren’t able to mentor right now.'];
    $n = q_one('SELECT * FROM users u WHERE u.id = ? AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u'), [$nid]);
    if (!$n || pal_blocked($me, $nid) || mentors120_same_origin($me, $nid)) {
        q("UPDATE pmentor_links SET status = 'cancelled', closed_at = ? WHERE id = ? AND status = 'pending'", [now(), $linkId]);
        return [false, 'That request is no longer there.'];
    }
    if ($p = mentors120_newcomer_problem($n)) {
        q("UPDATE pmentor_links SET status = 'cancelled', closed_at = ? WHERE id = ? AND status = 'pending'", [now(), $linkId]);
        return [false, 'They can’t take a mentor now: ' . $p];
    }
    if (mentors120_active_count($me) >= (int)setting('pmentor_max')) return [false, 'You are already guiding ' . (int)setting('pmentor_max') . ' newcomers.'];
    if (q("UPDATE pmentor_links SET status = 'active', closed_at = NULL WHERE id = ? AND status = 'pending'", [$linkId])->rowCount() !== 1) return [false, 'That request is no longer there.'];
    // two answers at once could overshoot: check again and step back if so
    $tooMany = mentors120_active_count($me) > (int)setting('pmentor_max')
        || (int)q_val("SELECT COUNT(*) FROM pmentor_links WHERE newcomer_id = ? AND status = 'active'", [$nid]) > 1;
    if ($tooMany) {
        q("UPDATE pmentor_links SET status = 'cancelled', closed_at = ? WHERE id = ? AND status = 'active'", [now(), $linkId]);
        return [false, 'That didn’t work out. Try again.'];
    }
    q("UPDATE pmentor_links SET status = 'cancelled', closed_at = ? WHERE newcomer_id = ? AND status = 'pending'", [now(), $nid]);   // one mentor only: their other asks are withdrawn
    require_once __DIR__ . '/trade.php';
    notify($nid, '🎓 ' . gnome_name($u) . ' is now your mentor! You earn +' . (int)setting('pmentor_xp_bonus_pct') . '% XP until level ' . (int)setting('pmentor_until_level') . '.');
    return [true, '🎓 You are now mentoring ' . mentors120_name($n) . '.'];
}

/** The newcomer takes a waiting request back. */
function mentors120_cancel(array $u, int $linkId): array
{
    $n = q("UPDATE pmentor_links SET status = 'cancelled', closed_at = ?, closed_by = ? WHERE id = ? AND newcomer_id = ? AND status = 'pending'", [now(), (int)$u['id'], $linkId, (int)$u['id']])->rowCount();
    return $n ? [true, 'Request taken back.'] : [false, 'There was no waiting request.'];
}

/** Either side ends an active link. */
function mentors120_end(array $u, int $linkId): array
{
    $me = (int)$u['id'];
    $l = q_one("SELECT * FROM pmentor_links WHERE id = ? AND status = 'active' AND (mentor_id = ? OR newcomer_id = ?)", [$linkId, $me, $me]);
    if (!$l) return [false, 'That mentoring has already ended.'];
    if (q("UPDATE pmentor_links SET status = 'ended', closed_at = ?, closed_by = ? WHERE id = ? AND status = 'active'", [now(), $me, $linkId])->rowCount() !== 1) return [false, 'That mentoring has already ended.'];
    $other = (int)$l['mentor_id'] === $me ? (int)$l['newcomer_id'] : (int)$l['mentor_id'];
    require_once __DIR__ . '/trade.php';
    notify($other, '🎓 ' . gnome_name($u) . ' ended your mentoring. Thank you for the time together.');
    return [true, 'Mentoring ended.'];
}

/** The "Happy to mentor" tick. */
function mentors120_set_open(array $u, bool $on): array
{
    if ($on && (int)$u['level'] < (int)setting('pmentor_min_level')) return [false, 'Mentors are gnomes of level ' . (int)setting('pmentor_min_level') . ' and up.'];
    q('UPDATE users SET pmentor_open = ? WHERE id = ?', [$on ? 1 : 0, (int)$u['id']]);
    return [true, $on ? '🎓 You are listed as happy to mentor.' : 'You are no longer listed. Current mentees stay with you.'];
}

/** A block ends every link and request between the two. */
function mentors120_on_block(int $a, int $b): void
{
    try {
        q("UPDATE pmentor_links SET status = 'ended', closed_at = ?, closed_by = ? WHERE status IN ('active', 'pending') AND ((mentor_id = ? AND newcomer_id = ?) OR (mentor_id = ? AND newcomer_id = ?))", [now(), $a, $a, $b, $b, $a]);
    } catch (Throwable $e) { /* table not made yet */ }
}

// ---------------- XP ----------------

/** add_xp(): extra XP the newcomer earns on top of $n. 0 for most gnomes (one indexed query). */
function mentors120_xp_bonus(int $uid, int $n, string $source): int
{
    if ($n <= 0 || $source === 'mentor_share') return 0;
    try {
        if (!mentors120_on()) return 0;
        $pct = (int)setting('pmentor_xp_bonus_pct');
        if ($pct <= 0) return 0;
        $l = mentors120_link_of($uid);
        if (!$l) return 0;
        $bonus = (int)round($n * $pct / 100);
        if ($bonus > 0) q('UPDATE pmentor_links SET xp_bonus = xp_bonus + ? WHERE id = ?', [$bonus, $l['id']]);
        return $bonus;
    } catch (Throwable $e) { return 0; }
}

/** add_xp(): after the XP is saved. $earned = what the newcomer got before the bonus. $level = their level now. */
function mentors120_after_xp(int $uid, int $earned, string $source, int $level): void
{
    if ($source === 'mentor_share') return;
    try {
        if (!mentors120_on()) return;
        $l = mentors120_link_of($uid);
        if (!$l) return;
        $share = (int)round($earned * (int)setting('pmentor_share_pct') / 100);
        if ($share > 0 && mentors120_share($l, $share) > 0) { /* paid */ }
        if ($level >= (int)setting('pmentor_until_level')) mentors120_graduate((int)$l['id']);
    } catch (Throwable $e) {
        error_log('mentors120_after_xp: ' . $e->getMessage());
    }
}

/** Pay the mentor up to the daily cap. Returns the XP paid. */
function mentors120_share(array $l, int $share): int
{
    $mid = (int)$l['mentor_id'];
    $cap = (int)setting('pmentor_daily_cap');
    $day = hollow_date('Y-m-d');
    $mentor = q_one('SELECT id FROM users u WHERE u.id = ? AND u.deleted_at IS NULL AND ' . gnome_in_play_sql('u'), [$mid]);
    if (!$mentor || $cap <= 0) return 0;
    $give = 0;
    for ($try = 0; $try < 3 && $give === 0; $try++) {
        $used = q_val('SELECT xp FROM pmentor_days WHERE mentor_id = ? AND day = ?', [$mid, $day]);
        if ($used === false || $used === null) {
            $g = min($share, $cap);
            try { db_insert('pmentor_days', ['mentor_id' => $mid, 'day' => $day, 'xp' => $g]); $give = $g; }
            catch (PDOException $e) { /* made at the same moment: read again */ }
            continue;
        }
        $g = min($share, $cap - (int)$used);
        if ($g <= 0) return 0;
        if (q('UPDATE pmentor_days SET xp = xp + ? WHERE mentor_id = ? AND day = ? AND xp = ?', [$g, $mid, $day, (int)$used])->rowCount() === 1) $give = $g;
    }
    if ($give <= 0) return 0;
    q('UPDATE pmentor_links SET xp_given = xp_given + ? WHERE id = ?', [$give, $l['id']]);
    add_xp($mid, $give, 'mentor_share');
    return $give;
}

// ---------------- Graduation ----------------

/** Close an active link whose newcomer has reached the level. Rewards are paid once per newcomer, ever. Returns true if this call graduated it. */
function mentors120_graduate(int $linkId): bool
{
    $l = q_one("SELECT * FROM pmentor_links WHERE id = ? AND status = 'active'", [$linkId]);
    if (!$l) return false;
    $nid = (int)$l['newcomer_id'];
    $mid = (int)$l['mentor_id'];
    $lvl = (int)q_val('SELECT level FROM users WHERE id = ?', [$nid]);
    if ($lvl < (int)setting('pmentor_until_level')) return false;
    mentors120_pages();
    $paidMentor = false;
    $won = db_tx(function () use ($l, $linkId, $nid, $mid, &$paidMentor) {
        if (q("UPDATE pmentor_links SET status = 'graduated', closed_at = ? WHERE id = ? AND status = 'active'", [now(), $linkId])->rowCount() !== 1) return false;   // someone else did it
        try { db_insert('pmentor_grads', ['newcomer_id' => $nid, 'mentor_id' => $mid, 'graduated_at' => now(), 'mentor_rewarded' => 0]); }
        catch (PDOException $e) { return false; }   // this newcomer graduated before: link closes, no second reward
        $week = (int)q_val('SELECT COUNT(*) FROM pmentor_grads WHERE mentor_id = ? AND mentor_rewarded = 1 AND graduated_at > ?', [$mid, gmdate('Y-m-d H:i:s', time() - 7 * 86400)]);
        $mentorOk = $week < (int)setting('pmentor_grad_week_cap') && !mentors120_same_origin($mid, $nid);
        $np = (int)setting('pmentor_grad_petals');
        if ($np > 0) give_petals((int)$nid, (int)$np);
        if ($mentorOk) {
            q('UPDATE pmentor_grads SET mentor_rewarded = 1 WHERE newcomer_id = ?', [$nid]);
            $mp = (int)setting('pmentor_grad_petals_mentor');
            if ($mp > 0) give_petals((int)$mid, (int)$mp);
            unlock_entries($mid, 'pmentor:mentor');
            $paidMentor = true;
        }
        unlock_entries($nid, 'pmentor:graduate');
        return true;
    });
    if (!$won) return false;
    require_once __DIR__ . '/trade.php';
    $cur = setting('currency_name');
    $nname = (string)q_val('SELECT COALESCE(gnome_name, username) FROM users WHERE id = ?', [$nid]);
    $mname = (string)q_val('SELECT COALESCE(gnome_name, username) FROM users WHERE id = ?', [$mid]);
    notify($nid, '🎓 You graduated! ' . $mname . ' sends a cheer. +' . (int)setting('pmentor_grad_petals') . ' ' . $cur . ' and a new Almanac page.');
    notify($mid, '🎓 ' . $nname . ' graduated at level ' . (int)setting('pmentor_until_level') . '! ' . ($paidMentor ? '+' . (int)setting('pmentor_grad_petals_mentor') . ' ' . $cur . ' and a new Almanac page.' : 'You have had your mentor rewards for this week, but the thanks are real.'));
    return true;
}

/** Graduate anyone whose level rose some other way (admin tools, old data). Cheap; called when the Mentor tab opens. */
function mentors120_sweep(int $uid): void
{
    try {
        foreach (q("SELECT l.id FROM pmentor_links l JOIN users n ON n.id = l.newcomer_id WHERE l.status = 'active' AND (l.newcomer_id = ? OR l.mentor_id = ?) AND n.level >= ?",
            [$uid, $uid, (int)setting('pmentor_until_level')])->fetchAll(PDO::FETCH_COLUMN) as $id) mentors120_graduate((int)$id);
    } catch (Throwable $e) { error_log('mentors120_sweep: ' . $e->getMessage()); }
}

// ---------------- Views ----------------

/** Links for a gnome: as newcomer (the active one and waiting asks) and as mentor (active + requests). */
function mentors120_mine(int $uid): array
{
    $sel = "SELECT l.*, COALESCE(u.gnome_name, u.username) AS name, u.level, u.last_seen FROM pmentor_links l JOIN users u ON u.id = l.%s
            WHERE l.%s = ? AND l.status = ? AND u.deleted_at IS NULL ORDER BY l.id";
    return [
        'my_mentor' => q(sprintf($sel, 'mentor_id', 'newcomer_id'), [$uid, 'active'])->fetchAll(),
        'my_asks'   => q(sprintf($sel, 'mentor_id', 'newcomer_id'), [$uid, 'pending'])->fetchAll(),
        'mentees'   => q(sprintf($sel, 'newcomer_id', 'mentor_id'), [$uid, 'active'])->fetchAll(),
        'requests'  => q(sprintf($sel, 'newcomer_id', 'mentor_id'), [$uid, 'pending'])->fetchAll(),
    ];
}

/** Willing mentors seen lately, not blocked either way, with room: up to 20. */
function mentors120_willing(array $viewer): array
{
    $me = (int)$viewer['id'];
    $since = gmdate('Y-m-d H:i:s', time() - max(1, (int)setting('pmentor_online_days')) * 86400);
    $rows = q("SELECT u.* FROM users u WHERE u.pmentor_open = 1 AND u.id <> ? AND u.level >= ? AND u.deleted_at IS NULL AND u.onboarded = 1 AND " . gnome_in_play_sql('u')
        . ' AND u.last_seen > ? AND NOT EXISTS (SELECT 1 FROM player_blocks b WHERE (b.blocker_id = u.id AND b.blocked_id = ?) OR (b.blocker_id = ? AND b.blocked_id = u.id))'
        . ' AND (SELECT COUNT(*) FROM pmentor_links a WHERE a.mentor_id = u.id AND a.status = \'active\') < ? ORDER BY u.last_seen DESC LIMIT 40',
        [$me, (int)setting('pmentor_min_level'), $since, $me, $me, (int)setting('pmentor_max')])->fetchAll();
    $out = [];
    foreach ($rows as $r) {
        if (fresh_hold($r) !== '' || mentors120_same_origin($me, (int)$r['id'])) continue;
        $r['name'] = mentors120_name($r);
        $out[] = $r;
        if (count($out) >= 20) break;
    }
    return $out;
}

function mentors120_form(string $do, int $id, string $label, string $cls = 'btn small', string $back = 'pals.php?tab=mentor', string $confirm = ''): string
{
    return '<form method="post" action="' . e(url('pals.php')) . '" class="inline"' . ($confirm !== '' ? ' data-confirm="' . e($confirm) . '"' : '') . '>' . csrf_field()
        . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="id" value="' . $id . '"><input type="hidden" name="back" value="' . e($back) . '"><button class="' . e($cls) . '">' . $label . '</button></form>';
}

function mentors120_progress(int $level): string
{
    $to = (int)setting('pmentor_until_level');
    return '<progress max="' . $to . '" value="' . min($level, $to) . '"></progress> <small class="muted">level ' . $level . ' / ' . $to . '</small>';
}

/** The whole Mentor tab. */
function mentors120_tab_html(array $u): string
{
    $me = (int)$u['id'];
    mentors120_sweep($me);
    $on = mentors120_on();
    $min = (int)setting('pmentor_min_level');
    $until = (int)setting('pmentor_until_level');
    $m = mentors120_mine($me);
    $h = '';
    if (!$on) $h .= '<div class="box"><p class="muted">🎓 Mentors are resting right now.</p></div>';
    $h .= '<details class="box"><summary><b>How mentoring works</b></summary><p class="help">Below level ' . $until . ': ask a gnome of level ' . $min . '+ to mentor you. You earn +' . (int)setting('pmentor_xp_bonus_pct')
        . '% XP. Your mentor earns ' . (int)setting('pmentor_share_pct') . '% of your XP. At level ' . $until . ' you graduate and you both get a reward and an Almanac page. Either of you can end it any time.</p></details>';

    // newcomer side
    if ((int)$u['level'] < $until && !mentors120_graduated($me)) {
        $h .= '<div class="box"><h2>🎓 Your mentor</h2>';
        if ($m['my_mentor']) {
            foreach ($m['my_mentor'] as $r) {
                $h .= '<div class="palreq"><span><b><a href="' . e(url('profile.php?id=' . (int)$r['mentor_id'])) . '">' . e($r['name']) . '</a></b> <small class="muted">level ' . (int)$r['level'] . '</small><br>'
                    . mentors120_progress((int)$u['level']) . '</span>' . mentors120_form('pm_end', (int)$r['id'], 'End', 'btn small ghost', 'pals.php?tab=mentor', 'End mentoring with ' . $r['name'] . '?') . '</div>';
            }
        } else {
            $h .= '<p class="muted">No mentor yet. Pick one below.</p>';
            foreach ($m['my_asks'] as $r) {
                $h .= '<div class="palreq"><span>⏳ Asked <b>' . e($r['name']) . '</b></span>' . mentors120_form('pm_cancel', (int)$r['id'], 'Take it back', 'btn small ghost') . '</div>';
            }
        }
        $h .= '</div>';
    }

    // mentor side
    if ((int)$u['level'] >= $min) {
        $h .= '<div class="box"><h2>🧑‍🏫 Your newcomers <small class="muted">' . count($m['mentees']) . ' / ' . (int)setting('pmentor_max') . '</small></h2>';
        $h .= '<form method="post" action="' . e(url('pals.php')) . '" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pm_open"><input type="hidden" name="back" value="pals.php?tab=mentor">'
            . '<label><input type="checkbox" name="open" value="1"' . ((int)($u['pmentor_open'] ?? 0) === 1 ? ' checked' : '') . '> Happy to mentor</label> <button class="btn small">Save</button></form>';
        if (!$m['mentees']) $h .= '<p class="muted">None right now.</p>';
        foreach ($m['mentees'] as $r) {
            $h .= '<div class="palreq"><span><b><a href="' . e(url('profile.php?id=' . (int)$r['newcomer_id'])) . '">' . e($r['name']) . '</a></b><br>'
                . mentors120_progress((int)$r['level']) . ' <small class="muted">· you earned ' . (int)$r['xp_given'] . ' XP</small></span>'
                . mentors120_form('pm_end', (int)$r['id'], 'End', 'btn small ghost', 'pals.php?tab=mentor', 'End mentoring with ' . $r['name'] . '?') . '</div>';
        }
        $h .= '<h3>Asking you</h3>';
        if (!$m['requests']) $h .= '<p class="muted">Nobody is waiting.</p>';
        foreach ($m['requests'] as $r) {
            $h .= '<div class="palreq"><span><b><a href="' . e(url('profile.php?id=' . (int)$r['newcomer_id'])) . '">' . e($r['name']) . '</a></b> <small class="muted">level ' . (int)$r['level'] . '</small></span><span class="palbtns">'
                . mentors120_form('pm_accept', (int)$r['id'], 'Accept') . mentors120_form('pm_decline', (int)$r['id'], 'Not now', 'btn small ghost') . '</span></div>';
        }
        $h .= '</div>';
    }

    // willing mentors
    if ((int)$u['level'] < $until && !mentors120_link_of($me) && !mentors120_graduated($me) && $on) {
        $list = mentors120_willing($u);
        $asked = array_column($m['my_asks'], 'mentor_id');
        $h .= '<div class="box"><h2>🔎 Willing mentors</h2>';
        if (!$list) $h .= '<p class="muted">Nobody is listed just now. Check back soon.</p>';
        foreach ($list as $r) {
            $h .= '<div class="palreq"><span><b><a href="' . e(url('profile.php?id=' . (int)$r['id'])) . '">' . e($r['name']) . '</a></b> <small class="muted">level ' . (int)$r['level'] . ' · ' . e(pal_about_text($r['last_seen'])) . '</small></span>'
                . (in_array((int)$r['id'], array_map('intval', $asked), true) ? '<small class="muted">⏳ asked</small>' : mentors120_form('pm_request', (int)$r['id'], 'Ask')) . '</div>';
        }
        $h .= '</div>';
    } elseif ((int)$u['level'] >= $until && (int)$u['level'] < $min) {
        $h .= '<div class="box"><p class="muted">You can become a mentor at level ' . $min . '.</p></div>';
    }
    return $h;
}

/** Profile page: ask this gnome to be your mentor. '' when not applicable. */
function mentors120_profile_button(array $me, array $g): string
{
    if (!mentors120_on() || (int)$me['id'] === (int)$g['id']) return '';
    if ((int)$g['pmentor_open'] !== 1 || (int)$g['level'] < (int)setting('pmentor_min_level')) return '';
    if (mentors120_newcomer_problem($me) !== '' || !mentors120_mentor_row((int)$g['id'])) return '';
    require_once __DIR__ . '/pals.php';
    if (pal_blocked((int)$me['id'], (int)$g['id']) || mentors120_same_origin((int)$me['id'], (int)$g['id'])) return '';
    if (q_val("SELECT 1 FROM pmentor_links WHERE mentor_id = ? AND newcomer_id = ? AND status = 'pending'", [(int)$g['id'], (int)$me['id']])) return '<span class="tag">⏳ Mentor asked</span>';
    return mentors120_form('pm_request', (int)$g['id'], '🎓 Ask to be my mentor', 'btn small ghost', 'profile.php?id=' . (int)$g['id']);
}

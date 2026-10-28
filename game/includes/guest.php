<?php
declare(strict_types=1);
/**
 * v2.0.75: guest gardens. A visitor can "Play as a guest" (guest.php): a real users row with guest = 1, a ready-made gnome and garden, no email, deleted
 * after guest_ttl_hours idle. They can explore most of the game. Everything that touches other players is blocked (guest_gate), they never show on a
 * board or in a draw (gnome_in_play_sql), and making their own gnome means registering (register.php turns the same row into a real account).
 * Setting guest_open (default off) switches it on.
 */
require_once __DIR__ . '/onboard.php';

/** Pages a guest cannot open at all (they put the gnome in front of other players, or write shared data). */
const GUEST_BLOCKED_PAGES = ['account.php', 'community.php', 'feedback.php', 'market.php', 'pals.php', 'report.php', 'mentor.php', 'trek.php',
    'fair.php', 'show.php', 'gotm.php', 'tend.php', 'modtools.php', 'forgot.php', 'reset.php'];
/** Pages a guest may look at but not act on (a POST is turned back). */
const GUEST_POST_BLOCKED_PAGES = ['visit.php', 'profile.php', 'puzzles_api.php'];
const GUEST_NAMES = ['Sprout', 'Pip', 'Moss', 'Bramble', 'Clover', 'Thimble', 'Nettle', 'Fern', 'Burdock', 'Tansy'];

/** Called from require_login() for a guest. Blocks or turns back anything that reaches other players; returns when the page is fine. */
function guest_gate(string $page): void
{
    $post = ($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST';
    $block = in_array($page, GUEST_BLOCKED_PAGES, true)
        || ($post && in_array($page, GUEST_POST_BLOCKED_PAGES, true))
        || ($page === 'jobs.php' && (($post && in_array((string)($_POST['do'] ?? ''), ['post', 'cancel', 'take_player'], true)) || (($_GET['p'] ?? '') === 'post')))
        || ($page === 'marketday.php' && $post && (string)($_POST['do'] ?? '') === 'basket')
        || (in_array($page, ['gifsaw.php', 'jigsaw.php'], true) && (int)($_GET['t'] ?? 0) > 0);   // v2.0.87: jigsaw.php?t= too
    if (!$block) return;
    if ($post) { flash('Guests can look around, but making your own gnome is needed for that.', 'err'); redirect($page === 'puzzles_api.php' ? 'puzzles.php' : $page); }
    guest_block_page();
}

/** The friendly "needs an account" card (Jeff holds a key). Ends the request. */
function guest_block_page(): void
{
    require_once __DIR__ . '/puzzles.php';
    http_response_code(403);
    page_header('Make your gnome');
    ?>
<div class="box narrow guestcard">
  <?= puzzle_cast('jeff-key', 'Jeff holding a key', 'lp-jeffface') ?>
  <p class="say"><b>Jeff:</b> “That one is for gnomes with an account. Guests can look around and try things, but making your own gnome is how you join in. It’s free, and your guest garden comes with you.”</p>
  <p><a class="btn" href="<?= e(url('register.php')) ?>">Make my gnome</a></p>
  <p><a href="<?= e(url('index.php')) ?>">← Back to my garden</a></p>
</div>
<?php
    page_footer();
    exit;
}

/** Make a guest garden and return its user id, or an error text. [uid|null, error] */
function guest_create(): array
{
    if (setting('guest_open') !== '1') return [null, 'Guest gardens aren’t open right now.'];
    $ip = substr((string)($_SERVER['REMOTE_ADDR'] ?? ''), 0, 45);
    guest_purge();
    if ((int)q_val('SELECT COUNT(*) FROM users WHERE guest = 1') >= max(1, (int)setting('guest_max_total'))) return [null, 'The guest gardens are full right now. Please try again later, or join for free.'];
    if (rate_limited('guest', max(1, (int)setting('guest_max_per_ip_day')), 1440)) return [null, 'That’s enough guest gardens from this connection for today. Join for free to keep going!'];
    record_attempt('guest');
    $start = start_region_id();
    $vills = onboard_start_villages($start);
    if (!$vills) return [null, 'Guest gardens aren’t ready yet.'];
    $tag = bin2hex(random_bytes(5));
    $uid = db_insert('users', [
        'username' => 'guest_' . $tag, 'email' => $tag . '@guest.invalid', 'password_hash' => password_hash(bin2hex(random_bytes(24)), PASSWORD_DEFAULT),
        'role' => 'player', 'coins' => (int)setting('starting_coins'), 'energy' => (int)setting('max_energy'), 'created_at' => now(), 'onboarded' => 0,
        'email_nudges' => 0, 'guest' => 1, 'guest_ip' => $ip,
    ]);
    $hats = array_keys(HAT_COLORS); $beards = array_keys(BEARD_COLORS);
    onboard_create($uid, GUEST_NAMES[random_int(0, count(GUEST_NAMES) - 1)], $hats[random_int(0, count($hats) - 1)], $beards[random_int(0, count($beards) - 1)],
        $start, $vills[random_int(0, count($vills) - 1)], 'Guest Patch', 0);
    set_setting('guest_made_total', (string)((int)setting('guest_made_total') + 1));
    log_in_user(['id' => $uid]);
    if ($ct = theme_clean((string)($_COOKIE['gvtheme'] ?? ''))) q('UPDATE users SET theme = ? WHERE id = ?', [$ct, $uid]);
    return [$uid, ''];
}

/** user_id-style columns that hold a gnome's own rows, found from the live schema (so a table added later is still cleaned). */
function guest_tables(): array
{
    $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
    $out = [];
    if ($sqlite) {
        foreach (q("SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'")->fetchAll(PDO::FETCH_COLUMN) as $t) {
            foreach (q('PRAGMA table_info(' . $t . ')')->fetchAll() as $c) if (in_array($c['name'], GUEST_COLUMNS, true)) $out[] = [(string)$t, (string)$c['name']];
        }
    } else {
        $in = "'" . implode("','", GUEST_COLUMNS) . "'";
        foreach (q("SELECT TABLE_NAME AS t, COLUMN_NAME AS c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME IN ($in)")->fetchAll() as $r) $out[] = [(string)$r['t'], (string)$r['c']];
    }
    return array_values(array_filter($out, fn($tc) => $tc[0] !== 'users'));
}
const GUEST_COLUMNS = ['user_id', 'from_id', 'to_id', 'seller_id', 'mentor_id', 'taker_id', 'friend_id', 'poster_id', 'owner_id', 'author_id', 'sender_id', 'recipient_id'];

/** Delete guest gardens idle longer than guest_ttl_hours, and every row they own. Returns how many guests went. Safe to call often (it is cheap when nothing is due). */
function guest_purge(bool $force = false): int
{
    if (!$force && random_int(1, 20) !== 1) return 0;
    $cut = gmdate('Y-m-d H:i:s', time() - max(1, (int)setting('guest_ttl_hours')) * 3600);
    $ids = array_map('intval', q('SELECT id FROM users WHERE guest = 1 AND COALESCE(last_seen, created_at) < ? LIMIT 200', [$cut])->fetchAll(PDO::FETCH_COLUMN));
    if (!$ids) return 0;
    $in = implode(',', $ids);
    foreach (guest_tables() as [$t, $c]) {
        try { q("DELETE FROM `$t` WHERE `$c` IN ($in)"); } catch (Throwable $e) { error_log('guest_purge ' . $t . ': ' . $e->getMessage()); }
    }
    q("DELETE FROM users WHERE guest = 1 AND id IN ($in)");
    return count($ids);
}

/** Turn this guest into a real account (same row: the garden comes along). Returns an error text or ''. */
function guest_convert(array $u, string $username, string $email, string $pass, bool $nudges): string
{
    $n = q('UPDATE users SET username = ?, email = ?, password_hash = ?, guest = 0, guest_ip = NULL, created_at = ?, agreed_at = ?, email_nudges = ? WHERE id = ? AND guest = 1',
        [$username, $email, password_hash($pass, PASSWORD_DEFAULT), now(), now(), $nudges ? 1 : 0, (int)$u['id']])->rowCount();
    if ($n !== 1) return 'That guest garden is already gone. Please start again.';
    set_setting('guest_converted_total', (string)((int)setting('guest_converted_total') + 1));
    $_SESSION['customise_gnome'] = 1;
    return '';
}

/** The slim strip under the header on every page while playing as a guest. */
function guest_strip_html(array $u): string
{
    require_once __DIR__ . '/puzzles.php';
    $left = max(1, (int)setting('guest_ttl_hours'));
    return '<div class="gueststrip">' . puzzle_cast('jeff-key', 'Jeff', 'gueststripface')
        . '<span><b>Guest garden.</b> It’s deleted after ' . $left . ' hours idle. <a href="' . e(url('register.php')) . '">Make your own gnome</a> to keep it.</span></div>';
}

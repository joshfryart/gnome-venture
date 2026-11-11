<?php
declare(strict_types=1);
/**
 * Slim Home (mockup B3 "Slim home, three tabs"). Flag: home_slim (bool, default 0; admins always preview, like the gnav flags).
 * Off = the home page (gnome.php) and the Hovel (hovel.php) are exactly as before.
 * On: gnome.php is one page: a slim hovel banner (a 480x120 crop, y104-224, of the 480x270 room picture) with Go to sleep and Nap,
 * then three tabs, plain links: TODAY (one "Needs you" list + the news row), FURNISH (the room's decor slots) and GNOME (level,
 * health, pals along, the six sub-page tiles). hovel.php still does the sleeping (POST, CSRF) and sends a GET to the right tab.
 *
 * Picture rules (DESIGN.md "Here, door and treehouse pictures"): one inline SVG, positions are SVG attributes, state is classes,
 * every image pixelated, art optional (a drawn wall and floor when scenes/hovel-room.png is missing; a missing layer is a soft box).
 * Decor catalogue: includes/data/hovel_decor.json. Choices: table user_hovel_decor (user_id, slot, item).
 */
require_once __DIR__ . '/here_schema.php';   // hub_seen_get/set: the per-gnome "last saw the news" time (scene 'news')

/** Is the slim home on for this viewer? Players need the setting; admins always preview. */
function home_slim_on(): bool
{
    return is_admin() || setting('home_slim') === '1';
}

/** Tables. Returns [tables, indexes, columns] like the other *_schema() functions (wired in schema.php). */
function home_slim_schema(string $PK, string $ID, string $END): array
{
    return [["CREATE TABLE IF NOT EXISTS user_hovel_decor (
        user_id INT NOT NULL,
        slot VARCHAR(16) NOT NULL,
        item VARCHAR(24) NOT NULL,
        updated_at DATETIME NULL,
        PRIMARY KEY (user_id, slot)
    )$END"], [], []];
}

/** Make user_hovel_decor if the upgrade has not yet (the days between uploading files and running the upgrade). Never fatal. */
function hovel_decor_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT 1 FROM user_hovel_decor LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t] = home_slim_schema('', '', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) db()->exec($sql);
        return $ok = true;
    } catch (Throwable $e) {
        error_log('hovel_decor_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

/** The decor catalogue, slots and items keyed by their keys: ['canvas' => [...], 'gnome' => [...], 'slots' => [k => [..., 'items' => [k => item]]]]. */
function hovel_decor_catalog(): array
{
    static $c = null;
    if ($c !== null) return $c;
    $j = json_decode((string)@file_get_contents(__DIR__ . '/data/hovel_decor.json'), true);
    $c = ['canvas' => ['w' => 480, 'h' => 270, 'crop' => [104, 224], 'floor' => 220], 'gnome' => ['x' => 214, 'y' => 172, 'w' => 32, 'h' => 48], 'slots' => []];
    if (!is_array($j)) return $c;
    $c['canvas'] = (array)($j['canvas'] ?? []) + $c['canvas'];
    $c['gnome'] = (array)($j['gnome'] ?? []) + $c['gnome'];
    foreach ((array)($j['slots'] ?? []) as $s) {
        $k = (string)($s['k'] ?? '');
        if (!preg_match('/^[a-z]{1,16}$/', $k) || empty($s['items'])) continue;
        $items = [];
        foreach ((array)$s['items'] as $it) {
            $ik = (string)($it['k'] ?? '');
            if (!preg_match('/^[a-z]{1,24}$/', $ik)) continue;
            $items[$ik] = ['k' => $ik, 'name' => (string)($it['name'] ?? $ik), 'cosy' => max(0, min(2, (int)($it['cosy'] ?? 0))), 'own' => !empty($it['own']), 'where' => (string)($it['where'] ?? '')];
        }
        if (!$items) continue;
        $c['slots'][$k] = ['k' => $k, 'name' => (string)($s['name'] ?? $k), 'x' => (int)$s['x'], 'y' => (int)$s['y'], 'w' => max(1, (int)$s['w']), 'h' => max(1, (int)$s['h']), 'items' => $items];
    }
    return $c;
}

/**
 * Which items this gnome owns: [slot => [item => true]]. v1: the defaults ('own' in the catalogue) and nothing else.
 * This is the one place to add new sources (a market stall, a Journey step, a festival prize): add the item key to its slot here.
 */
function hovel_decor_owned(int $uid): array
{
    $o = [];
    foreach (hovel_decor_catalog()['slots'] as $sk => $s) foreach ($s['items'] as $ik => $it) if ($it['own']) $o[$sk][$ik] = true;
    return $o;
}

/** What is in each slot now: [slot => item]. A slot never chosen (or holding something no longer owned) shows its first owned item. */
function hovel_decor_chosen(int $uid): array
{
    $cat = hovel_decor_catalog();
    $own = hovel_decor_owned($uid);
    $rows = [];
    try { foreach (q('SELECT slot, item FROM user_hovel_decor WHERE user_id = ?', [$uid])->fetchAll() as $r) $rows[(string)$r['slot']] = (string)$r['item']; } catch (Throwable $e) {}
    $out = [];
    foreach ($cat['slots'] as $sk => $s) {
        $pick = $rows[$sk] ?? '';
        if (!isset($own[$sk][$pick])) $pick = (string)array_key_first($own[$sk] ?? []) ?: (string)array_key_first($s['items']);
        $out[$sk] = $pick;
    }
    return $out;
}

/** Put an owned item in a slot. Returns [ok, message, the item that was there before]. */
function hovel_decor_set(int $uid, string $slot, string $item): array
{
    $cat = hovel_decor_catalog();
    $s = $cat['slots'][$slot] ?? null;
    if (!$s) return [false, 'There is no such spot in your hovel.', ''];
    $it = $s['items'][$item] ?? null;
    if (!$it) return [false, 'That does not go there.', ''];
    if (empty(hovel_decor_owned($uid)[$slot][$item])) return [false, $it['name'] . ' is locked' . ($it['where'] !== '' ? ': ' . $it['where'] . '.' : '.'), ''];
    $prev = hovel_decor_chosen($uid)[$slot] ?? '';
    if (!hovel_decor_ensure()) return [false, 'Your hovel cannot be changed just now. Try again soon.', ''];
    if (q('UPDATE user_hovel_decor SET item = ?, updated_at = ? WHERE user_id = ? AND slot = ?', [$item, now(), $uid, $slot])->rowCount() < 1) {
        try { q('INSERT INTO user_hovel_decor (user_id, slot, item, updated_at) VALUES (?, ?, ?, ?)', [$uid, $slot, $item, now()]); }
        catch (Throwable $e) { q('UPDATE user_hovel_decor SET item = ?, updated_at = ? WHERE user_id = ? AND slot = ?', [$item, now(), $uid, $slot]); }   // a second tab got there first
    }
    return [true, $it['name'] . ' is in place.', $prev];
}

/** [cosiness now, the most there can be] = the chosen items' cosy points, and the sum of each slot's best item. */
function hovel_cosy(array $chosen): array
{
    $n = 0; $max = 0;
    foreach (hovel_decor_catalog()['slots'] as $sk => $s) {
        $n += (int)($s['items'][$chosen[$sk] ?? '']['cosy'] ?? 0);
        $max += max(array_map(fn($i) => (int)$i['cosy'], $s['items']));
    }
    return [$n, max(1, $max)];
}

/** Picture file (under assets/img/) as a URL, or '' when it is not drawn yet. */
function hovel_art(string $rel): string
{
    return is_file(APP_ROOT . '/assets/img/' . $rel) ? url('assets/img/' . $rel) : '';
}

/** The furnish address for a slot (the no-script picker). */
function hovel_slot_url(string $slot, array $x = []): string
{
    return url('gnome.php?' . http_build_query(['tab' => 'furnish'] + ($slot !== '' ? ['slot' => $slot] : []) + $x));
}

/** The gnome standing at home: sprite/gnome-home.png (optional grey gnome-home-hat / -beard layers are tinted), else the layered avatar. */
function hovel_gnome_svg(array $u, array $g): string
{
    $x = (int)$g['x']; $y = (int)$g['y']; $w = (int)$g['w']; $h = (int)$g['h'];
    $src = hovel_art('sprite/gnome-home.png');
    if ($src !== '') {
        require_once __DIR__ . '/pixel_art.php';
        $uid = '-h' . bin2hex(random_bytes(3));
        $hat = pixel_hex(gnome_hat_color($u));
        $bc = (string)($u['beard_color'] ?? '');
        $beard = pixel_hex(isset(BEARD_COLORS[$bc]) || dye_valid('beard', $bc) ? $bc : '#f4f1ea');
        $layers = '';
        $defs = '';
        foreach (['hat' => $hat, 'beard' => $beard] as $part => $hex) {
            $lsrc = hovel_art('sprite/gnome-home-' . $part . '.png');
            if ($lsrc === '' || $hex === '') continue;
            if (!str_contains($defs, 'tint-' . $hex . $uid)) $defs .= pixel_tint_filter($hex, 1.25, $uid);
            $layers .= '<image href="' . e($lsrc) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated" filter="url(#tint-' . $hex . $uid . ')"/>';
        }
        return ($defs !== '' ? '<defs>' . $defs . '</defs>' : '') . '<g class="hr-gnome"><image href="' . e($src) . '" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" image-rendering="pixelated"/>' . $layers . '</g>';
    }
    $av = gnome_avatar($u, $w);   // no sprite yet: the same layered (tinted) gnome as the avatar, standing in the gnome's box, feet on the floor
    return '<g class="hr-gnome">' . (string)preg_replace('/^<svg class="gnomeart" width="\d+" height="\d+"/', '<svg class="gnomeart" x="' . $x . '" y="' . $y . '" width="' . $w . '" height="' . $h . '" preserveAspectRatio="xMidYMax meet"', $av, 1) . '</g>';
}

/**
 * The room as one SVG. $mode 'crop' = the banner (y104-224, 480x120), 'full' = the whole 480x270 room.
 * $o: 'taps' => true makes each slot a link that opens its picker (dialog with script, ?slot= without), 'sel' => slot key to mark.
 */
function hovel_room_svg(array $u, array $chosen, string $mode = 'crop', array $o = []): string
{
    $cat = hovel_decor_catalog();
    $W = (int)$cat['canvas']['w']; $H = (int)$cat['canvas']['h']; $fl = (int)$cat['canvas']['floor'];
    [$c0, $c1] = array_map('intval', $cat['canvas']['crop']);
    $full = $mode === 'full';
    $vb = $full ? '0 0 ' . $W . ' ' . $H : '0 ' . $c0 . ' ' . $W . ' ' . max(1, $c1 - $c0);
    $taps = $full && !empty($o['taps']);
    $sel = (string)($o['sel'] ?? '');
    $names = [];
    foreach ($cat['slots'] as $sk => $s) $names[] = $s['name'] . ': ' . ($s['items'][$chosen[$sk] ?? '']['name'] ?? '');
    $dp = (string)($o['daypart'] ?? '');
    $svg = '<svg class="hroom hroom-' . ($full ? 'full' : 'crop') . ($dp !== '' ? ' dp-' . e(preg_replace('/[^a-z]/', '', $dp)) : '') . '" viewBox="' . $vb . '"'
        . ($taps ? ' role="group" aria-label="' . e('Your room. ' . implode(', ', $names) . '. Tap a thing to change it.') . '"' : ' role="img" aria-label="' . e('Your hovel. ' . implode(', ', $names)) . '"') . ' focusable="false">';
    $back = hovel_art('scenes/hovel-room.png');
    if ($back !== '') {
        $svg .= '<image class="hr-back" href="' . e($back) . '" x="0" y="0" width="' . $W . '" height="' . $H . '" image-rendering="pixelated"/>';
    } else {   // no picture yet: a drawn wall, floor, skirting and bed, so the room still reads and the slots still line up
        $svg .= '<rect class="hr-wall" x="0" y="0" width="' . $W . '" height="' . $fl . '"/><rect class="hr-floor" x="0" y="' . $fl . '" width="' . $W . '" height="' . max(1, $H - $fl) . '"/>'
            . '<rect class="hr-beam" x="0" y="40" width="' . $W . '" height="8"/><rect class="hr-bed" x="384" y="176" width="88" height="44"/><rect class="hr-pillow" x="444" y="168" width="24" height="12"/>'
            . '<line class="hr-skirt" x1="0" y1="' . $fl . '" x2="' . $W . '" y2="' . $fl . '"/>';
    }
    foreach ($cat['slots'] as $sk => $s) {
        $ik = $chosen[$sk] ?? '';
        $src = hovel_art('scenes/hovel-' . $sk . '-' . $ik . '.png');
        $box = 'x="' . $s['x'] . '" y="' . $s['y'] . '" width="' . $s['w'] . '" height="' . $s['h'] . '"';
        $lay = $src !== '' ? '<image href="' . e($src) . '" ' . $box . ' image-rendering="pixelated"/>' : '<rect class="hd-ph" ' . $box . '/>';
        $cls = 'hd hd-' . $sk . ($sk === $sel ? ' sel' : '');
        if ($taps) {   // the tap area is the slot's box, at least 56 units each way (44 px at 412 wide), centred on it
            $hw = max(56, $s['w']); $hh = max(56, $s['h']);
            $hx = max(0, min($W - $hw, $s['x'] - intdiv($hw - $s['w'], 2))); $hy = max(0, min($H - $hh, $s['y'] - intdiv($hh - $s['h'], 2)));
            if ($sk === 'floor') { $hy = $s['y']; $hh = $s['h']; }
            $label = $s['name'] . ': ' . ($s['items'][$ik]['name'] ?? '') . '. Change';
            $svg .= '<a class="' . $cls . '" href="' . e(hovel_slot_url($sk)) . '" data-hdlg="hpick-' . e($sk) . '" aria-label="' . e($label) . '"><title>' . e($label) . '</title>' . $lay
                . '<rect class="hd-hit" x="' . $hx . '" y="' . $hy . '" width="' . $hw . '" height="' . $hh . '"/></a>';
        } else {
            $svg .= '<g class="' . $cls . '">' . $lay . '</g>';
        }
    }
    $svg .= hovel_gnome_svg($u, $cat['gnome']);
    $svg .= '<rect class="hr-tint" x="0" y="0" width="' . $W . '" height="' . $H . '" aria-hidden="true"/>';
    return $svg . '</svg>';
}

/** The latest post (News or Release notes) and whether this gnome has seen it: ['post' => row|null, 'unread' => bool]. */
function home_slim_news(int $uid): array
{
    static $memo = [];
    if (isset($memo[$uid])) return $memo[$uid];
    $p = null;
    try { $p = q_one('SELECT title, kind, created_at FROM news WHERE published = 1 ORDER BY created_at DESC, id DESC LIMIT 1'); } catch (Throwable $e) {}
    $unread = false;
    if ($p) {
        $at = (int)strtotime($p['created_at'] . ' UTC');
        $seen = hub_seen_get($uid, 'news');
        $unread = $seen === null ? $at > time() - 14 * 86400 : $at > (int)strtotime($seen . ' UTC');   // never opened the news: only a post from the last two weeks counts as new
    }
    return $memo[$uid] = ['post' => $p, 'unread' => $unread];
}

/** The address of the news list (the latest post's tab). */
function home_slim_news_url(?array $p): string
{
    return url('index.php?news=all' . ($p && ($p['kind'] ?? '') === 'notes' ? '&tab=notes' : '') . '#news');
}

/** A short "where it goes" word for a Needs you row, from its link. */
function home_slim_go(string $href): string
{
    $p = (string)parse_url($href, PHP_URL_PATH);
    $qs = (string)parse_url($href, PHP_URL_QUERY);
    return match (basename($p)) {
        'garden.php' => str_contains($qs, 't=help') ? 'Crew' : 'Garden', 'jobs.php' => 'Tasks', 'community.php' => 'Read', 'paljobs.php' => 'Collect',
        'inventory.php' => str_contains($qs, 'pantry') ? 'Pantry' : 'Kitchen', 'villagers.php' => 'Visit', 'market.php' => 'Market', 'festival.php' => 'Festival',
        'firstweek.php' => 'First Week', 'back.php' => 'Look', 'book.php' => 'Almanac', default => 'Open',
    };
}

/**
 * The TODAY tab's one list: the home cards' helper (welcome back, First Week, the daily card, a festival), the Hovel's "needs you",
 * what finished overnight (pots, jars) and friends' birthdays. Returns ['need' => [[icon, title, small, href]], 'quiet' => [text]]:
 * the crew report and who is away go in the quiet line under the list.
 */
function home_slim_needs(array $u): array
{
    require_once __DIR__ . '/today.php';
    $need = []; $quiet = [];
    try {
        require_once __DIR__ . '/tour.php';
        $slot = helper_slot($u);
        if ($slot === 'back') $need[] = ['👋', 'Welcome back!', 'See what grew while you were away.', url('back.php')];
        elseif ($slot === 'fw' && ($fw = first_week_today_card((int)$u['id']))) {
            $nDone = count(array_filter($fw['tasks'], fn($t) => $t[4]));
            $need[] = ['🐦', 'First Week', 'Day ' . (int)$fw['day'] . ': ' . $nDone . ' of ' . count($fw['tasks']) . ' done' . ($fw['done'] ? ' · a gift is ready' : ''), url('firstweek.php')];
        } elseif ($slot === 'daily' && ($dc = daily_card($u)) && empty($dc['done'])) $need[] = [(string)$dc['icon'], 'Today', (string)$dc['text'], url((string)$dc['link'])];
        elseif ($slot === 'fest' && ($fe = festival_active())) $need[] = [(string)$fe['icon'], (string)$fe['name'], 'Day ' . (int)$fe['day'] . ' of ' . (int)$fe['days'] . '. The Hollow is celebrating.', url('festival.php')];
    } catch (Throwable $e) {}
    $d = ['need' => [], 'night' => [], 'village' => []];
    try { $d = today_data($u); } catch (Throwable $e) {}
    foreach ($d['need'] as $n) $need[] = $n;
    foreach ($d['night'] as $n) {
        if ($n[3] === '') continue;   // the weather: it is on the banner's tag
        if (str_contains($n[3], 'hovel.php')) { if ($n[2] !== '') $quiet[] = 'Overnight the crew: ' . $n[2] . '.'; continue; }
        $need[] = $n;
    }
    foreach ($d['village'] as $n) {
        if (str_contains($n[1], 'birthday')) { $need[] = [$n[0], $n[1], $n[2], url('villagers.php')]; continue; }
        $quiet[] = rtrim($n[1], '.') . ($n[2] !== '' ? ' · ' . $n[2] : '') . '.';
    }
    return ['need' => $need, 'quiet' => $quiet];
}

/** Badges for the three tabs: ['today' => needs count, 'news' => unread, 'furnish' => new items, 'gnome' => stat points + a calling to choose]. */
function home_slim_badges(array $u, int $needN): array
{
    $g = (int)$u['stat_points'] + (!$u['calling'] && (int)$u['level'] >= (int)setting('calling_level') ? 1 : 0);
    return ['today' => $needN, 'news' => home_slim_news((int)$u['id'])['unread'], 'furnish' => 0, 'gnome' => $g];
}

/** A gold count badge, or '' for none. */
function home_slim_bang(int|string $n, string $label): string
{
    if ($n === 0 || $n === '') return '';
    return '<b class="hs-bang" role="img" aria-label="' . e($label) . '">' . e((string)$n) . '</b>';
}

/** The slim banner: the room crop (on FURNISH also the whole room, shown on a phone), the time tag, the greeting, Go to sleep and Nap. */
function home_slim_banner_html(array $u, array $chosen, string $tab, string $hello): string
{
    $s = gclock_on() ? gclock_state($u) : null;
    $now = hollow_now(hollow_user_region($u), null, $s);
    $tag = ($s ? sprintf('%02d:%02d', intdiv($s['minute'], 60) % 24, $s['minute'] % 60) : (string)$now['daypart_label'])
        . ' · ' . $now['season_label'] . ' ' . (int)$now['season_day'] . ' · ' . $now['weather_label'];
    $dp = (string)$now['daypart'];
    $tagHtml = '<span class="hs-tag">' . e($tag) . '</span>';
    $h = '<section class="hs-banner" aria-label="Your hovel">'
        . '<div class="hs-pic hs-crop">' . hovel_room_svg($u, $chosen, 'crop', ['daypart' => $dp]) . $tagHtml . '</div>';
    if ($tab === 'furnish') $h .= '<div class="hs-pic hs-full">' . hovel_room_svg($u, $chosen, 'full', ['taps' => true, 'sel' => (string)($_GET['slot'] ?? ''), 'daypart' => $dp]) . $tagHtml . '</div>';
    $h .= '<div class="hs-side"><h1>' . e($hello) . ', ' . e(gnome_name($u)) . '!</h1>';
    if ($s) {
        $opts = gclock_rest_options($u);
        $sleep = array_values(array_filter($opts, fn($o) => $o['kind'] !== 'nap'));
        $nap = array_values(array_filter($opts, fn($o) => $o['kind'] === 'nap'));
        $main = null; foreach ($sleep as $o) if ($o['ok']) { $main = $o; break; }
        $main ??= $sleep[0] ?? null;
        $n0 = $nap[0] ?? null;
        $back = in_array($tab, ['today', 'furnish', 'gnome'], true) ? $tab : 'today';
        $btn = fn(array $o, string $label, string $cls) => '<button class="btn big' . $cls . '" type="submit" name="do" value="' . e($o['key']) . '" title="' . e($o['label'] . ' · ' . $o['cost'] . ($o['ok'] ? '' : ' · ' . $o['why'])) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($label) . '</button>';
        $h .= '<form method="post" action="' . e(url('hovel.php')) . '" class="hs-rest">' . csrf_field() . '<input type="hidden" name="back" value="' . e($back) . '">'
            . '<div class="hs-acts">' . ($main ? $btn($main, 'Go to sleep', '') : '') . ($n0 ? $btn($n0, 'Nap', ' ghost') : '') . '</div>';
        if ($main) {
            $note = $main['key'] === 'home_sleep' ? 'Sleep: fresh start at 06:00' : $main['label'] . ' · ' . $main['cost'];
            if (!$main['ok']) $note = $main['label'] . ': ' . $main['why'];
            if ($s['tired']) $note = 'After 22:00 everything costs +' . game_surcharge_pct($u) . '% energy. Sleep to start fresh at 06:00.';
            $h .= '<p class="hs-note">' . e($note) . '</p>';
            if (($busy = gclock_busy_minutes((int)$u['id'])) > 0) $h .= '<p class="hs-note">' . e(round($busy / 60, 1) . ' h of work still to finish. Sleep, and it is done first thing in the morning.') . '</p>';
        }
        $others = array_values(array_filter($sleep, fn($o) => $o !== $main));
        if ($others) {
            $h .= '<details class="hs-more"><summary>Other beds</summary>';
            foreach ($others as $o) $h .= '<p><button class="btn small ghost" type="submit" name="do" value="' . e($o['key']) . '"' . ($o['ok'] ? '' : ' disabled') . '>' . e($o['label']) . '</button> <small>' . e($o['cost'] . ($o['ok'] ? '' : ' · ' . $o['why'])) . '</small></p>';
            $h .= '</details>';
        }
        $h .= '</form>';
    }
    return $h . '</div></section>';
}

/** The three tabs (plain links, so they load in place with AJAX_PAGES and work without script). $cur: 'today', 'furnish', 'gnome' or a Gnome sub-page. */
function home_slim_tabs_html(string $cur, array $b): string
{
    $T = ['today' => 'Today', 'furnish' => 'Furnish', 'gnome' => 'Gnome'];
    $on = isset($T[$cur]) ? $cur : 'gnome';
    $h = '<nav class="tabs hometabs hstabs" aria-label="Home">';
    foreach ($T as $k => $l) {
        $href = url($k === 'today' ? 'gnome.php' : 'gnome.php?tab=' . $k);
        $bang = home_slim_bang((int)($b[$k] ?? 0), ($b[$k] ?? 0) . ' new')
            . ($k === 'today' && !empty($b['news']) ? '<b class="hs-bang" role="img" aria-label="Unread news">!</b>' : '');
        $h .= '<a href="' . e($href) . '"' . ($k === $on ? ' class="on"' . ($k === $cur ? ' aria-current="page"' : '') : '') . '>' . e($l) . $bang . '</a>';
    }
    return $h . '</nav>';
}

/** The news row on TODAY: unread = paper with a gold "!", read = quiet felt. */
function home_slim_news_html(int $uid): string
{
    $n = home_slim_news($uid);
    $p = $n['post'];
    if (!$p) return '<p class="hs-newsl"><a href="' . e(url('index.php?news=all#news')) . '">News &amp; release notes →</a></p>';
    $when = gmdate('M j', (int)strtotime($p['created_at'] . ' UTC')) . ' · ' . ($p['kind'] === 'notes' ? 'release notes' : 'news');
    if ($n['unread']) {
        $h = '<a class="box hs-news unread" href="' . e(home_slim_news_url($p)) . '"><span class="hs-ni" aria-hidden="true">📰<b class="hs-bang">!</b></span>'
            . '<span class="hs-tx"><b>New: ' . e($p['title']) . '</b><small>' . e($when) . '</small></span><span class="hs-go">Read →</span></a>';
    } else {
        $h = '<a class="hs-news read" href="' . e(home_slim_news_url($p)) . '"><span class="hs-tx"><small>Latest news, read</small><b>' . e($p['title']) . '</b></span><span class="hs-go">All news →</span></a>';
    }
    return $h . '<p class="hs-newsl"><a href="' . e(url('index.php?news=all#news')) . '">News &amp; release notes →</a></p>';
}

/** The TODAY tab: Needs you, the news row; the Hollow line on the side. */
function home_slim_today_html(array $u, array $needs): string
{
    $uid = (int)$u['id'];
    $h = '<div class="hs-cols"><div class="hs-main">';
    require_once __DIR__ . '/puzzle_pals.php';
    if (ppal_open() && !is_guest($u)) { require_once __DIR__ . '/pal_jobs.php'; $h .= pj_home_notice_html($u); }   // pals back from a trip or delve
    $n = count($needs['need']);
    $h .= '<section class="box hs-needs" aria-labelledby="hs-needs-h"><h2 id="hs-needs-h">Needs you' . home_slim_bang($n, $n . ' thing' . ($n === 1 ? '' : 's')) . '</h2>';
    if ($needs['need']) {
        $h .= '<ul class="hs-nlist">';
        foreach ($needs['need'] as [$ic, $tt, $sm, $href]) {
            $in = '<span class="hs-ni" aria-hidden="true">' . e($ic) . '</span><span class="hs-tx"><b>' . e($tt) . '</b>' . ($sm !== '' ? '<small>' . e($sm) . '</small>' : '') . '</span>';
            $h .= '<li>' . ($href !== '' ? '<a href="' . e($href) . '">' . $in . '<span class="hs-go">' . e(home_slim_go($href)) . ' →</span></a>' : '<div>' . $in . '</div>') . '</li>';
        }
        $h .= '</ul>';
    } else {
        $h .= '<p class="hs-empty">Nothing needs you right now. A good day to wander.</p>';
    }
    if ($needs['quiet']) $h .= '<p class="hs-quiet">' . e(implode(' ', $needs['quiet'])) . '</p>';
    $h .= '</section>' . home_slim_news_html($uid) . '</div>';
    require_once __DIR__ . '/today_social.php';
    return $h . '<aside class="hs-rail" aria-label="The Hollow">' . today_social_html($u, 'line') . '</aside></div>';
}

/** The Cosiness meter: n of max as pips. */
function home_slim_cosy_html(array $chosen): string
{
    [$n, $max] = hovel_cosy($chosen);
    $p = '';
    for ($i = 0; $i < $max; $i++) $p .= '<i' . ($i < $n ? ' class="on"' : '') . '></i>';
    return '<section class="box hs-cosy" aria-label="Cosiness ' . $n . ' of ' . $max . '"><p class="hs-ctop"><b>Cosiness</b> <span>' . $n . '/' . $max . '</span></p>'
        . '<div class="hs-pips" aria-hidden="true">' . $p . '</div><small>Each item adds 0 to 2. Locked items lift it to ' . $max . '.</small></section>';
}

/** One slot's picker: a <dialog> (opened by script; with ?slot= in the address it is drawn open, in the page, for no-script and after a change). */
function home_slim_picker_html(int $uid, array $s, string $cur, bool $open, string $prev): string
{
    $own = hovel_decor_owned($uid)[$s['k']] ?? [];
    $sk = $s['k'];
    $tw = 84; $th = 52; $sc = min($tw / $s['w'], $th / $s['h'], 3);
    $iw = max(8, (int)round($s['w'] * $sc)); $ih = max(8, (int)round($s['h'] * $sc));
    $h = '<dialog class="hpick" id="hpick-' . e($sk) . '" aria-labelledby="hpick-h-' . e($sk) . '"' . ($open ? ' open' : '') . '>'
        . '<form method="post" action="' . e(url('gnome.php?tab=furnish')) . '">' . csrf_field() . '<input type="hidden" name="do" value="decor"><input type="hidden" name="slot" value="' . e($sk) . '">'
        . '<div class="hpick-h"><h3 id="hpick-h-' . e($sk) . '">' . e($s['name']) . '</h3><small>You own ' . count($own) . ' · tap one to put it in place</small></div><div class="hpick-tray">';
    foreach ($s['items'] as $ik => $it) {
        $src = hovel_art('scenes/hovel-' . $sk . '-' . $ik . '.png');
        $thumb = '<svg class="hpick-th" viewBox="0 0 ' . $s['w'] . ' ' . $s['h'] . '" width="' . $iw . '" height="' . $ih . '" aria-hidden="true" focusable="false">'
            . ($src !== '' ? '<image href="' . e($src) . '" x="0" y="0" width="' . $s['w'] . '" height="' . $s['h'] . '" image-rendering="pixelated"/>' : '<rect class="hd-ph" x="1" y="1" width="' . max(1, $s['w'] - 2) . '" height="' . max(1, $s['h'] - 2) . '"/>') . '</svg>';
        if (empty($own[$ik])) {
            $h .= '<div class="hpick-it lock" aria-disabled="true">' . $thumb . '<span class="nm">' . e($it['name']) . '</span><span class="wh">Locked: ' . e($it['where']) . '</span></div>';
            continue;
        }
        $on = $ik === $cur;
        $h .= '<button class="hpick-it" type="submit" name="item" value="' . e($ik) . '" aria-pressed="' . ($on ? 'true' : 'false') . '">' . $thumb . '<span class="nm">' . e($it['name']) . '</span>'
            . '<span class="cz">' . ($on ? '<span class="in">In place</span> · ' : '') . '+' . (int)$it['cosy'] . ' cosy</span></button>';
    }
    $h .= '</div><div class="hpick-act">';
    if ($prev !== '' && $prev !== $cur && !empty($own[$prev])) $h .= '<button class="btn ghost" type="submit" name="item" value="' . e($prev) . '">Undo</button>';
    $h .= '<a class="btn" href="' . e(hovel_slot_url('')) . '" data-hdlg-close>Done</a></div></form></dialog>';
    return $h;
}

/** The FURNISH tab: the slot tiles and their pickers; the live room and the Cosiness meter on the side. */
function home_slim_furnish_html(array $u, array $chosen): string
{
    $uid = (int)$u['id'];
    $cat = hovel_decor_catalog();
    $sel = (string)($_GET['slot'] ?? '');
    if (!isset($cat['slots'][$sel])) $sel = '';
    $prev = (string)($_GET['prev'] ?? '');
    $tiles = '<div class="hs-slots">';
    foreach ($cat['slots'] as $sk => $s) {
        $it = $s['items'][$chosen[$sk]] ?? reset($s['items']);
        $tiles .= '<a class="hs-slot' . ($sk === $sel ? ' on' : '') . '" href="' . e(hovel_slot_url($sk)) . '" data-hdlg="hpick-' . e($sk) . '"' . ($sk === $sel ? ' aria-current="true"' : '') . '>'
            . '<span class="sn">' . e($s['name']) . '</span><span class="cur">' . e($it['name']) . '</span><span class="ch">change</span></a>';
    }
    $tiles .= '<a class="hs-slot more" href="' . e(url('market.php')) . '"><span class="sn">More</span><span class="cur">Find decor</span><span class="ch">Market →</span></a></div>';
    $picks = '';
    foreach ($cat['slots'] as $sk => $s) $picks .= home_slim_picker_html($uid, $s, $chosen[$sk], $sk === $sel, $sk === $sel ? $prev : '');
    return '<div class="hs-cols hs-furnish"><div class="hs-main"><h2 class="hs-h">Furnish your hovel</h2>' . $tiles . $picks . '</div>'
        . '<aside class="hs-rail" aria-label="Your room"><section class="box hs-preview"><h3>Your room</h3><div class="hs-pic">' . hovel_room_svg($u, $chosen, 'full', ['taps' => true, 'sel' => $sel]) . '</div><small>Tap a thing in the room to change it.</small></section>'
        . home_slim_cosy_html($chosen) . '</aside></div>';
}

<?php
// 2.8.100 State banner (includes/town_states.php town_state_banner_html): the owner's "have the town or stop state clearly marked on the page".
// A big state word with its icon, a three-step ladder (earlier steps ticked, the current one filled), what it means for the shop, and the next step
// with the real R numbers; a small state tag in the header chip row. On the town page, the Here page and the town's shop page with town_states_open
// and stop_marks_open on; with the setting off the pages carry none of it. The banner function takes a plain state array, so the stop pages can reuse it.
// Usage: php tests/town_state_banner.php GAME_DIR [PORT]   (a walk.sh install: player "sprout"; with PORT a server for GAME_DIR answers on it)
$_SERVER['SCRIPT_NAME'] = '/index.php';
$GAME = $argv[1];
$PORT = (int)($argv[2] ?? 0);
require $GAME . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/stops.php';
require_once APP_ROOT . '/includes/stop_marks.php';
require_once APP_ROOT . '/includes/seals.php';
require_once APP_ROOT . '/includes/town_states.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
function setg(string $k, string $v): void { set_setting($k, $v); setting('__reload__'); }
function done(): void { global $fails; echo $fails ? "$fails FAILED\n" : "ok\n"; exit($fails ? 1 : 0); }

$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
ok('player sprout exists', $uid > 0);
$na = (int)q_val("SELECT id FROM regions WHERE code = 'NA'");
$town = q_one("SELECT * FROM locations WHERE region_id = ? AND kind = 'market' ORDER BY id LIMIT 1", [$na]);
$home = (int)q_val('SELECT home_village_id FROM users WHERE id = ?', [$uid]);
$vill = array_map('intval', q("SELECT id FROM locations WHERE region_id = ? AND kind = 'village' ORDER BY id", [$na])->fetchAll(PDO::FETCH_COLUMN));
$others = array_values(array_diff($vill, [$home]));
$shop = q_one("SELECT * FROM shops WHERE location_id = ? AND shop_type = 'seeds'", [(int)$town['id']]);
$hubShop = q_one("SELECT s.* FROM shops s JOIN locations l ON l.id = s.location_id WHERE l.kind = 'hub' AND s.shop_type = 'seeds'");
setg('npc_clockwork', '0');
q('UPDATE users SET location_id = ?, location = ?, region_id = ?, game_day = 10, game_minute = 600, guest = 0 WHERE id = ?', [(int)$town['id'], 'The Maplewold', $na, $uid]);
q("DELETE FROM expeditions WHERE user_id = ? AND status = 'active'", [$uid]);
$clean = function () use ($uid) {
    foreach (['stop_marks', 'region_seals', 'stop_mark_use'] as $t) q("DELETE FROM $t WHERE user_id = ?", [$uid]);
    q("DELETE FROM stop_prog WHERE user_id = ? AND k LIKE 'meter:%'", [$uid]);
    foreach (['town_state_best', 'town_backroom'] as $t) { try { q("DELETE FROM $t WHERE user_id = ?", [$uid]); } catch (Throwable $e) {} }
    town_states_reset();
};
$latch = fn(int $lid) => db_insert('stop_marks', ['user_id' => $uid, 'location_id' => $lid, 'bar' => 'repairs', 'perk_key' => '', 'filled_on' => gclock_my_date(), 'latched_at' => now(), 'kept' => 0]);
$meter = fn(int $lid, int $n) => stop_prog_set($uid, $lid, 'meter:repairs', $n, ['d' => gclock_my_date(), 'mk' => 1]);
/** Put the gnome's Maplewold town in a state: ruin (new gnome, R 5), work (home latched + one village at 40: R 15), fixed (a held Seal). */
$force = function (string $st) use ($clean, $latch, $meter, $home, $others, $uid, $na) {
    $clean();
    if ($st === 'work') { $latch($home); $meter($others[0], 40); }
    if ($st === 'fixed') db_insert('region_seals', ['user_id' => $uid, 'region_id' => $na, 'earned_at' => now()]);
    town_states_reset();
};
/** Which ladder step carries which mark: ['ruin' => 'done'|'now'|'todo', ...] from a banner's HTML. */
$marks = function (string $h): array {
    preg_match_all('~<li class="stb-step stb-step-([a-z]+) is-(done|now|todo)"~', $h, $m, PREG_SET_ORDER);
    $o = []; foreach ($m as $x) $o[$x[1]] = $x[2]; return $o;
};

echo "== the banner function takes any state array (reuse for the stop states later)\n";
ok('town_state_banner_html is there', function_exists('town_state_banner_html'));
if (!function_exists('town_state_banner_html')) done();
$stopState = ['key' => 'working', 'kicker' => 'Village state', 'steps' => ['ruined' => ['🏚️', 'Ruined'], 'working' => ['🔨', 'Being worked on'], 'fixed' => ['🌟', 'Fixed']],
    'means' => 'The well <works> again.', 'next' => 'Fill the Repairs bar to finish it.'];
$g = town_state_banner_html($stopState, 'Acorn & Co');
ok('a generic (stop) state: the big word and its icon', str_contains($g, '<p class="stb-word">Being worked on</p>') && str_contains($g, '🔨'), $g);
ok('...the place name and kicker, escaped', str_contains($g, 'Village state · Acorn &amp; Co'), $g);
ok('...the ladder: earlier ticked, current filled, later open', $marks($g) === ['ruined' => 'done', 'working' => 'now', 'fixed' => 'todo'], json_encode($marks($g)));
ok('...the current step says so to a screen reader', (bool)preg_match('~is-now" aria-current="step"~', $g));
ok('...the meaning line (escaped) and the next step', str_contains($g, 'The well &lt;works&gt; again.') && str_contains($g, 'Fill the Repairs bar to finish it.'));
ok('...coloured by state through its class', str_contains($g, 'class="stb stb-working"'));
ok('...no inline style or script (CSP)', !preg_match('~style=|<script|onclick~i', $g));
ok('the tag (header chip row)', str_contains(town_state_tag_html($stopState), 'stb-tag stb-tag-working') && str_contains(town_state_tag_html($stopState), 'Being worked on'));
ok('an unknown key: nothing', town_state_banner_html(['key' => 'x', 'steps' => ['a' => ['', 'A']]], 'P') === '' && town_state_tag_html([]) === '');

setg('stop_marks_open', '1'); setg('town_states_open', '1');
echo "== the town's state array with the real numbers\n";
$force('ruin');
$s = town_state_info($uid, $na);
ok('Run low: R 5, next step to Mending', $s['key'] === 'ruin' && $s['next'] === 'Mend 1 more village in The Maplewold to reach Mending (R 5 of 15).', json_encode($s));
ok('Run low: the shop line', $s['means'] === 'The shop door is always open. Back room: empty for now.', $s['means']);
$force('work');
$s = town_state_info($uid, $na);
ok('Mending: R 15, 7 more points = 4 villages to Thriving', $s['key'] === 'work' && $s['next'] === 'Mend 4 more villages in The Maplewold to reach Thriving (R 15 of 50).', json_encode($s));
ok('Mending: the shop line', $s['means'] === 'The shop door is always open. Back room: 5 staple seeds a day kept for you.', $s['means']);
$meter($others[1], 40); $meter($others[2], 40); $meter($others[3], 40); $meter($others[4], 40); $meter($others[5], 40); $meter($others[6], 40); $meter($others[7], 40); town_states_reset();
$s = town_state_info($uid, $na);
ok('villages already under repair count 1 each: F 1, W 8, R 50 = Thriving', $s['key'] === 'fixed', json_encode(town_region_parts($uid, $na)));
$clean(); $latch($home); foreach (range(0, 7) as $i) $meter($others[$i], 40); $latch($others[8]); q('DELETE FROM stop_prog WHERE user_id = ? AND location_id = ? AND k = ?', [$uid, $others[1], 'meter:repairs']); town_states_reset();
$p = town_region_parts($uid, $na);
$s = town_state_info($uid, $na);
ok('one village untouched left (+2), then +1 each: F 2, W 7, R 55: Thriving', $s['key'] === 'fixed', json_encode($p));
$force('fixed');
$s = town_state_info($uid, $na);
ok('Thriving: "The whole region is mended."', $s['key'] === 'fixed' && $s['next'] === 'The whole region is mended.', json_encode($s));
ok('Thriving: the shop line', str_starts_with($s['means'], 'The shop door is always open. Back room: 10 staple seeds'), $s['means']);
foreach (['ruin' => ['ruin' => 'now', 'work' => 'todo', 'fixed' => 'todo'], 'work' => ['ruin' => 'done', 'work' => 'now', 'fixed' => 'todo'], 'fixed' => ['ruin' => 'done', 'work' => 'done', 'fixed' => 'now']] as $st => $want) {
    $force($st);
    $b = town_banner_html($uid, $na, (string)$town['name']);
    ok("$st: the ladder marks the right pip", $marks($b) === $want, json_encode($marks($b)));
}
setg('town_states_open', '0'); town_states_reset();
ok('setting off: no banner, no tag', town_banner_html($uid, $na, 'X') === '' && town_tag_html($uid, $na) === '');
setg('town_states_open', '1');
setg('stop_marks_open', '0'); town_states_reset();
ok('lasting marks off: no banner', town_banner_html($uid, $na, 'X') === '');
setg('stop_marks_open', '1'); town_states_reset();
ok('the hub (no region): no banner', town_banner_html($uid, 0, 'Mossbottom') === '');

if ($PORT > 0) {
    $ck = tempnam(sys_get_temp_dir(), 'tsbck');
    $get = function (string $path) use ($PORT, $ck): string {
        $c = curl_init('http://127.0.0.1:' . $PORT . '/' . $path);
        curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $ck, CURLOPT_COOKIEFILE => $ck, CURLOPT_TIMEOUT => 60]);
        $h = (string)curl_exec($c); curl_close($c); return $h;
    };
    $lp = $get('login.php');
    preg_match('/name="csrf" value="([^"]*)"/', $lp, $m);
    $c = curl_init('http://127.0.0.1:' . $PORT . '/login.php');
    curl_setopt_array($c, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $ck, CURLOPT_COOKIEFILE => $ck, CURLOPT_POST => true, CURLOPT_POSTFIELDS => http_build_query(['csrf' => $m[1] ?? '', 'username' => 'sprout', 'password' => 'TestPass123!'])]);
    curl_exec($c); curl_close($c); unset($c);   // the cookie jar is written when the handle goes
    $pages = fn() => ['town' => $get('town.php'), 'here' => $get('here.php'), 'shop' => $get('shop.php?id=' . (int)$shop['id'])];
    $R = ['ruin' => 'R 5 of 15', 'work' => 'R 15 of 50', 'fixed' => 'The whole region is mended.'];
    $W = ['ruin' => 'Run low', 'work' => 'Mending', 'fixed' => 'Thriving'];
    foreach (['ruin', 'work', 'fixed'] as $st) {
        echo "== pages, $st\n";
        $force($st);
        foreach ($pages() as $pg => $h) {
            ok("$pg: one banner, coloured $st", substr_count($h, 'class="stb stb-' . $st . '"') === 1, substr(strip_tags($h), 0, 300));
            ok("$pg: the big word", str_contains($h, '<p class="stb-word">' . $W[$st] . '</p>'));
            ok("$pg: the real numbers", str_contains($h, $R[$st]));
            ok("$pg: the shop line", str_contains($h, 'The shop door is always open.'));
            ok("$pg: the ladder", $marks($h)[$st] === 'now' && count($marks($h)) === 3, json_encode($marks($h)));
            ok("$pg: no old small chip", !str_contains($h, 'tstate-chip'));
        }
        $P = $pages();
        ok('town: the banner sits right under the header', (bool)preg_match('~</header>\s*<section class="stb ~', $P['town']));
        ok('town: the state tag is in the header chip row', (bool)preg_match('~<p class="ph-chips">.*stb-tag stb-tag-' . $st . '.*?</p>~s', $P['town']));
        ok('here: the banner sits right under the name line, the tag in it', (bool)preg_match('~<p class="hereinfo">.*?stb-tag stb-tag-' . $st . '.*?</p>\s*<section class="stb ~s', $P['here']));
        if ($st === 'ruin') ok('town: the story line and Wren line are kept', str_contains($P['town'], 'They never shut.') && str_contains($P['town'], 'The shelves are thin but the door is open.'));
    }
    echo "== pages with the setting off; the hub\n";
    $hb = $get('town.php?hub=1') . $get('shop.php?id=' . (int)$hubShop['id']);
    ok('Mossbottom: no banner', !str_contains($hb, 'class="stb '));
    setg('town_states_open', '0'); town_states_reset();
    foreach ($pages() as $pg => $h) ok("$pg with town_states_open = 0: no banner, no tag", !str_contains($h, 'class="stb ') && !str_contains($h, 'stb-tag'));
    setg('town_states_open', '1'); setg('stop_marks_open', '0'); town_states_reset();
    foreach ($pages() as $pg => $h) ok("$pg with stop_marks_open = 0: no banner", !str_contains($h, 'class="stb '));
    setg('stop_marks_open', '1');
    @unlink($ck);
}
$clean();
done();

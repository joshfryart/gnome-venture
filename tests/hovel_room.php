<?php
// The interactive hovel room on the slim home's Today tab (includes/home_slim.php, includes/data/hovel_things.php, assets/hovelroom.js).
// Run by hovel_room.sh on an installed copy (player "sprout"). Usage: php tests/hovel_room.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/gnome.php';
require_once APP_ROOT . '/includes/home_slim.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
function cfg(array $kv): void { foreach ($kv as $k => $v) set_setting($k, (string)$v); setting('__reload__'); }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$row = fn(): array => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
cfg(['game_clock_on' => 1, 'home_slim' => 1, 'tea_open' => 'everyone']);
$home = (int)q_val('SELECT home_village_id FROM users WHERE id = ?', [$uid]);
q('UPDATE users SET location_id = ?, game_minute = 600, coins = 500 WHERE id = ?', [$home, $uid]);

echo "== the data file\n";
$raw = require APP_ROOT . '/includes/data/hovel_things.php';
$T = hovel_things();
$cv = hovel_decor_catalog()['canvas'];
ok('six things: window, bed, gnome, lamp, kettle, door', array_keys($T) === ['window', 'bed', 'gnome', 'lamp', 'kettle', 'door'], implode(',', array_keys($T)));
ok('no row was dropped by the loader', count($T) === count($raw));
ok('the room is 480 x 270', (int)$cv['w'] === 480 && (int)$cv['h'] === 270);
$bad = [];
foreach ($T as $id => $t) {
    if ($t['label'] === '' || $t['label'] === $id) $bad[] = "$id: no label";
    if ($t['x'] < 0 || $t['y'] < 0 || $t['x'] + $t['w'] > 480 || $t['y'] + $t['h'] > 270) $bad[] = "$id: tap box outside the room";
    if ($t['w'] < 62 || $t['h'] < 62) $bad[] = "$id: tap box under 62 units ({$t['w']} x {$t['h']})";   // 62 units = 44 px when the picture is 341 px wide (a 390 px phone shows it about 346 px wide)
    [$ox, $oy, $ow, $oh] = $t['out'];
    if ($ox < 0 || $oy < 0 || $ow < 1 || $oh < 1 || $ox + $ow > 480 || $oy + $oh > 270) $bad[] = "$id: outline outside the room";
    if (!in_array($t['act'], ['pop', 'go', 'tea', 'lamp', 'say'], true)) $bad[] = "$id: unknown act {$t['act']}";
}
ok('every thing has a label, a known act, a tap box inside the room and 62 units or more each way', !$bad, implode('; ', $bad));
$hit = fn(array $a, array $b): bool => $a[0] < $b[0] + $b[2] && $b[0] < $a[0] + $a[2] && $a[1] < $b[1] + $b[3] && $b[1] < $a[1] + $a[3];
$over = []; $overOut = []; $ids = array_keys($T);
foreach ($ids as $i => $a) foreach (array_slice($ids, $i + 1) as $b) {
    if ($hit([$T[$a]['x'], $T[$a]['y'], $T[$a]['w'], $T[$a]['h']], [$T[$b]['x'], $T[$b]['y'], $T[$b]['w'], $T[$b]['h']])) $over[] = "$a/$b";
    if ($hit($T[$a]['out'], $T[$b]['out'])) $overOut[] = "$a/$b";
}
ok('no two tap boxes overlap', !$over, implode(', ', $over));
ok('no two outlines overlap', !$overOut, implode(', ', $overOut));
ok('the kettle box is the tea kettle box (HOVEL_KETTLE_HIT)', [$T['kettle']['x'], $T['kettle']['y'], $T['kettle']['w'], $T['kettle']['h']] === HOVEL_KETTLE_HIT);
$slots = hovel_decor_catalog()['slots']; $g = hovel_decor_catalog()['gnome'];
$in = fn(array $box, array $t): bool => $box[0] >= $t['x'] && $box[1] >= $t['y'] && $box[0] + $box[2] <= $t['x'] + $t['w'] && $box[1] + $box[3] <= $t['y'] + $t['h'];
ok('the window thing covers the window decor layer', $in([$slots['window']['x'], $slots['window']['y'], $slots['window']['w'], $slots['window']['h']], $T['window']));
ok('the lamp thing covers the lamp decor layer', $in([$slots['lamp']['x'], $slots['lamp']['y'], $slots['lamp']['w'], $slots['lamp']['h']], $T['lamp']));
ok('the gnome thing covers the gnome', $in([(int)$g['x'], (int)$g['y'], (int)$g['w'], (int)$g['h']], $T['gnome']));
ok('the bed does not cover the pet corner', !$hit([$T['bed']['x'], $T['bed']['y'], $T['bed']['w'], $T['bed']['h']], [$slots['pet']['x'], $slots['pet']['y'], $slots['pet']['w'], $slots['pet']['h']]));

echo "== the room picture\n";
$u = $row(); $chosen = hovel_decor_chosen($uid);
$_GET = [];
$ban = home_slim_banner_html($u, $chosen, 'today', 'Good morning');
ok('Today: the whole room, with things', str_contains($ban, '<svg class="hroom hroom-full hroom-things dp-') && str_contains($ban, 'viewBox="0 0 480 270"'));
ok('...no cropped banner on Today', !str_contains($ban, 'hroom-crop') && !str_contains($ban, 'hs-crop'));
ok('...the real room art', str_contains($ban, 'assets/img/scenes/hovel-room.png'));
ok('...the tag is over the picture', (bool)preg_match('~</svg><span class="hs-tag">10:00 · [^<]+</span>~', $ban));
ok('...the decor slots are plain art (no picker links)', !str_contains($ban, 'data-hdlg="hpick-') && substr_count($ban, '<g class="hd hd-') === count($slots));
foreach (['window' => 'data-hdlg="hp-window"', 'bed' => 'data-hdlg="hp-bed"', 'gnome' => 'data-hsay=', 'lamp' => 'data-hlamp', 'door' => 'href="/'] as $id => $hook) {
    $t = $T[$id];
    $ok = (bool)preg_match('~<a class="ht ht-' . $id . '[^"]*" href="[^"#]+[^"]*"[^>]* aria-label="([^"]+)"><title>\1</title><rect class="ht-out"[^>]*/><rect class="ht-hit" x="' . $t['x'] . '" y="' . $t['y'] . '" width="' . $t['w'] . '" height="' . $t['h'] . '"/></a>~', $ban, $m);
    ok("...$id: a link with a label, a title and the data file's tap box", $ok && str_contains($m[0], $hook), $ok ? $m[0] : 'no link');
}
ok('...the kettle keeps its own link and box', str_contains($ban, '<a class="hd hd-kettle" href="/gnome.php?tea=1#htea" data-hdlg="htea"') && str_contains($ban, '<rect class="hd-hit" x="312" y="142" width="64" height="64"/></a>'));
ok('...steam, the lamp glow and the night tint are in the picture', str_contains($ban, 'class="hr-steam"') && str_contains($ban, 'class="hr-lampglow"') && str_contains($ban, 'class="hr-tint"'));
ok('...the tap boxes are drawn last (on top)', strrpos($ban, 'class="hr-tint"') < strpos($ban, '<a class="ht '));
ok('...no z\'s over the bed in the daytime', !str_contains($ban, 'class="hr-zz"'));
ok('...first look: the bed pulses and the hint shows', str_contains($ban, '<a class="ht ht-bed pulse"') && str_contains($ban, '<span class="hs-hint">Tap things in the room</span>'));
$_SESSION = [];   // with a session: once a game day
$look1 = home_slim_banner_html($u, $chosen, 'today', 'Good morning'); $look2 = home_slim_banner_html($u, $chosen, 'today', 'Good morning');
ok('...with a session the first look of the day pulses and hints', str_contains($look1, 'ht-bed pulse"') && str_contains($look1, 'class="hs-hint"'));
ok('...the second look the same day does neither', !str_contains($look2, 'pulse') && !str_contains($look2, 'hs-hint') && str_contains($look2, '<a class="ht ht-bed"'), 'second look still pulses or hints');
$look3 = home_slim_banner_html(['game_day' => (int)$u['game_day'] + 1] + $u, $chosen, 'today', 'Good morning');
ok('...the next game day it pulses and hints again', str_contains($look3, 'ht-bed pulse"') && str_contains($look3, 'class="hs-hint"'));
unset($_SESSION);
ok('...one greeting line with the first name', str_contains($ban, '<h1 class="hs-hi">Good morning, ' . e((string)strtok(gnome_name($u), ' ')) . '!</h1>') && substr_count($ban, '<h1') === 1);
ok('...the bubble is there, hidden', str_contains($ban, '<span class="hs-say" role="status" hidden></span>'));
ok('...no inline style', !preg_match('/\sstyle=/', $ban));
ok('the door goes to the Here page', str_contains($ban, '<a class="ht ht-door" href="' . url(gnav_on() ? 'here.php' : 'town.php') . '"'));
$loc = q_one('SELECT * FROM locations WHERE id = ?', [$home]);
ok('...and is named after where the gnome is', str_contains($ban, 'aria-label="' . e('The door. Step out to ' . $loc['name']) . '"'), (string)$loc['name']);
cfg(['tea_open' => 'off']);
$ban0 = home_slim_banner_html($u, $chosen, 'today', 'Good morning');
ok('tea closed: no kettle link, the other things stay', !str_contains($ban0, 'hd-kettle') && substr_count($ban0, '<a class="ht ') === 5);
cfg(['tea_open' => 'everyone']);
ok('the lamp: off by day, a link to switch it on', str_contains($ban, 'href="/gnome.php?lamp=on" data-hlamp role="button" aria-pressed="false"') && !str_contains($ban, 'lamp-on'));
ok('...lit by itself at dusk and at night', hovel_lamp_on('dusk') && hovel_lamp_on('night') && !hovel_lamp_on('day') && !hovel_lamp_on('dawn'));
$_GET = ['lamp' => 'on'];
$banL = home_slim_banner_html($u, $chosen, 'today', 'Good morning');
ok('...?lamp=on lights it without script', str_contains($banL, 'hroom-things lamp-on') && str_contains($banL, 'href="/gnome.php?lamp=off" data-hlamp role="button" aria-pressed="true"'));
$_GET = ['lamp' => 'off'];
ok('...?lamp=off wins over the evening', !hovel_lamp_on('night'));
$_GET = [];
q('UPDATE users SET game_minute = 1290 WHERE id = ?', [$uid]);
$banN = home_slim_banner_html($row(), $chosen, 'today', 'Good evening');
ok('...z\'s over the bed once it is bedtime', str_contains($banN, 'class="hr-zz"'));
ok('...in the evening the room is lit and tinted', (bool)preg_match('/hroom-things lamp-on dp-(dusk|night)"/', $banN));
q('UPDATE users SET game_minute = 600 WHERE id = ?', [$uid]);
$mx = max_energy($u);
$say = fn(int $e, ?array $s = null): string => hovel_gnome_lines(['energy' => $e] + $u, 'Good morning', $s)[1];
ok('the gnome: the greeting first', hovel_gnome_lines($u, 'Good morning', null)[0] === 'Good morning!');
ok('...rested when energy is high', $say($mx) === 'Rested and ready!');
ok('...tired when energy is low', $say(0) === 'Tired: a nap?');
ok('...sleepy after 22:00', $say($mx, ['tired' => true]) === 'Sleepy... bed soon?');
ok('...every line is short', max(array_map('strlen', [$say($mx), $say(0), $say(intdiv($mx, 2)), $say($mx, ['tired' => true])])) <= 26);

echo "== Furnish and the other tabs are as they were\n";
$fur = home_slim_banner_html($u, $chosen, 'furnish', 'Good morning');
ok('Furnish: the crop and the whole room with a picker link per slot', str_contains($fur, 'class="hs-pic hs-crop"') && str_contains($fur, 'class="hs-pic hs-full"') && substr_count($fur, 'data-hdlg="hpick-') === count($slots));
foreach ($slots as $sk => $sl) if (!str_contains($fur, '<a class="hd hd-' . $sk . '" href="/gnome.php?tab=furnish&amp;slot=' . $sk . '" data-hdlg="hpick-' . $sk . '"')) ok("Furnish: the $sk slot link", false);
ok('...the lamp slot keeps its 56-unit picker box', str_contains($fur, '<rect class="hd-hit" x="256" y="172" width="56" height="56"/></a>'));
ok('...no things on Furnish', !str_contains($fur, 'hroom-things') && !str_contains($fur, 'class="ht '));
ok('...the big buttons stay on the other tabs', str_contains($fur, '<div class="hs-acts"><button class="btn big" type="submit" name="do" value="home_sleep"') && str_contains($fur, '>Go to sleep</button>') && str_contains($fur, 'name="back" value="furnish"'));
$gn = home_slim_banner_html($u, $chosen, 'gnome', 'Good morning');
ok('Gnome tab: the crop banner with the full name', str_contains($gn, 'hroom-crop') && !str_contains($gn, 'hroom-full') && str_contains($gn, '<h1>Good morning, ' . e(gnome_name($u)) . '!</h1>'));
$side = home_slim_furnish_html($u, $chosen);
ok('the Furnish side preview keeps its taps', substr_count($side, 'data-hdlg="hpick-') === 2 * count($slots) && !str_contains($side, 'hroom-things'));

echo "== the sleep row and the bed's card: the same options, prices and disabled states\n";
// what the old big buttons offered, from the same source
$check = function (string $name) use ($uid, $row, $chosen): void {
    $u = $row();
    $opts = gclock_rest_options($u);
    $ban = home_slim_banner_html($u, $chosen, 'today', 'Good morning');
    $dlg = home_slim_things_html($u);
    $old = home_slim_banner_html($u, $chosen, 'gnome', 'Good morning');   // the big buttons, still on the other tabs
    $sleep = array_values(array_filter($opts, fn($o) => $o['kind'] !== 'nap')); $nap = array_values(array_filter($opts, fn($o) => $o['kind'] === 'nap'));
    $main = null; foreach ($sleep as $o) if ($o['ok']) { $main = $o; break; } $main ??= $sleep[0];
    $btn = fn(string $html, string $key): ?string => preg_match('~<button class="[^"]*" type="submit" name="do" value="' . $key . '"[^>]*>~', $html, $m) ? $m[0] : null;
    $row1 = substr($ban, (int)strpos($ban, '<div class="hs-btns">'));
    ok("$name: the row is a form to hovel.php that comes back to Today", str_contains($ban, '<form method="post" action="/hovel.php" class="hs-rest"><input type="hidden" name="csrf"') && str_contains($ban, '<input type="hidden" name="back" value="today"><div class="hs-btns">'));
    ok("$name: the row's first button is the same rest as the old Go to sleep", ($b = $btn($row1, $main['key'])) !== null && $btn($old, $main['key']) !== null && str_contains($b, 'disabled') === !$main['ok'], (string)$b);
    ok("$name: ...and Nap is the same nap", !$nap || (($b = $btn($row1, $nap[0]['key'])) !== null && $btn($old, $nap[0]['key']) !== null && str_contains($b, 'disabled') === !$nap[0]['ok']));
    ok("$name: no big buttons on Today", !str_contains($ban, 'btn big') && !str_contains($ban, 'hs-acts') && !str_contains($ban, 'hs-more'));
    $miss = [];
    foreach ($sleep as $o) {   // every sleep is in the bed's card, with its price and its disabled state; the nap is the first nap, as before
        $b = $btn($dlg, $o['key']);
        if ($b === null || str_contains($b, 'disabled') === $o['ok']) $miss[] = $o['key'];
        elseif ($o !== $main && !str_contains($dlg, e($o['label']) . '</button> <small>' . e($o['cost'] . ($o['ok'] ? '' : ' · ' . $o['why'])) . '</small>')) $miss[] = $o['key'] . ' (price)';
        if ($o !== $main && ($ob = $btn($old, $o['key'])) !== null && str_contains($ob, 'disabled') !== str_contains((string)$b, 'disabled')) $miss[] = $o['key'] . ' (differs from the old button)';
    }
    ok("$name: the bed's card has every sleep with its price and state", !$miss, implode(', ', $miss));
    ok("$name: ...and names what Go to sleep and Nap do", str_contains($dlg, e($main['label'] . ' · ' . $main['cost'])) && (!$nap || str_contains($dlg, e($nap[0]['label'] . ' · ' . $nap[0]['cost']))));
    $others = array_values(array_filter($sleep, fn($o) => $o !== $main && $o['key'] !== 'inn_pay'));
    ok("$name: Other beds is a link to the bed's card exactly when there are other beds", str_contains($row1, '<a class="btn small ghost hs-sb" href="/gnome.php?thing=bed#hp-bed" data-hdlg="hp-bed">Other beds</a>') === (count($others) > 0));
    ok("$name: no inline style in the card", !preg_match('/\sstyle=/', $dlg));
};
$check('at home');
$ban = home_slim_banner_html($row(), $chosen, 'today', 'Good morning');
ok('at home: Sleep and Nap only, no line under them', str_contains($ban, 'value="home_sleep" title="Sleep in your hovel · free">🌙 Sleep</button>') && str_contains($ban, '>💤 Nap</button>') && !str_contains($ban, 'Inn ·') && !str_contains($ban, 'hs-note'));
$town = (int)q_val("SELECT id FROM locations WHERE kind IN ('market', 'hub') AND id <> ? ORDER BY id LIMIT 1", [$home]);
q('UPDATE users SET location_id = ? WHERE id = ?', [$town, $uid]);
$check('in a town');
$fee = gclock_inn_fee($uid);
$ban = home_slim_banner_html($row(), $chosen, 'today', 'Good morning');
ok('in a town: the inn with its price is the first button', (bool)preg_match('~<div class="hs-btns"><button class="btn small hs-sb" type="submit" name="do" value="inn_pay" title="Rent a room at the inn · ' . $fee . ' [^"]+">🛏️ Inn · ' . $fee . '</button>~u', $ban), (string)$fee);
ok('...with the line that says what it costs', str_contains($ban, '<p class="hs-note">Rent a room at the inn · ' . $fee . ' '));
q('UPDATE users SET coins = 0 WHERE id = ?', [$uid]);
$check('in a town, no Petals');
$ban = home_slim_banner_html($row(), $chosen, 'today', 'Good morning');
ok('no Petals: Sleep is the chores bed, the inn shows its price and is disabled', str_contains($ban, 'value="inn_chores"') && (bool)preg_match('~value="inn_pay" title="[^"]+" disabled>🛏️ Inn · ' . $fee . '</button>~u', $ban));
q('UPDATE users SET game_minute = 1350, coins = 500 WHERE id = ?', [$uid]);
$check('after 22:00');
$ban = home_slim_banner_html($row(), $chosen, 'today', 'Good evening');
ok('after 22:00: the tired line is under the row', str_contains($ban, '<p class="hs-note">After 22:00 everything costs +'));
q('UPDATE users SET location_id = ?, game_minute = 600 WHERE id = ?', [$home, $uid]);
$_GET = ['thing' => 'bed'];
ok('?thing=bed draws the bed\'s card open (no script)', str_contains(home_slim_things_html($row()), '<dialog class="hpick hpop" id="hp-bed" aria-labelledby="hp-bed-h" open>'));
$_GET = ['thing' => 'window'];
$dlg = home_slim_things_html($row());
ok('?thing=window draws the weather card open', str_contains($dlg, '<dialog class="hpick hpop" id="hp-window" aria-labelledby="hp-window-h" open>') && !str_contains($dlg, 'id="hp-bed" aria-labelledby="hp-bed-h" open'));
$_GET = [];
$now = hollow_now(hollow_user_region($row()), null, gclock_state($row())); $fc = hollow_forecast(hollow_user_region($row()), 2);
ok('the window: today\'s and tomorrow\'s weather, and Seasons', str_contains($dlg, '<small>Today</small>') && str_contains($dlg, e((string)$now['weather_label']) . '</b>') && str_contains($dlg, '<small>Tomorrow</small>') && str_contains($dlg, e((string)$fc[1]['wlabel']) . '</b>') && str_contains($dlg, 'href="/seasons.php"'));
cfg(['game_clock_on' => 0]);
$ban = home_slim_banner_html($row(), $chosen, 'today', 'Good morning');
ok('game clock off: no bed thing and no row (as before: nothing to sleep in), the rest works', !str_contains($ban, 'ht-bed') && !str_contains($ban, 'hs-btns') && str_contains($ban, 'ht-door') && !str_contains(home_slim_things_html($row()), 'hp-bed'));
cfg(['game_clock_on' => 1]);

echo "== style and script\n";
$css = (string)file_get_contents(APP_ROOT . '/assets/style.css');
ok('reduced motion switches the room\'s animations off', (bool)preg_match('~@media \(prefers-reduced-motion: reduce\) \{[^}]*\.hroom \.hr-steam[^}]*\.hr-zz[^}]*\.hr-gnome[^}]*\.hr-lampglow[^}]*\.ht\.pulse \.ht-out \{ animation: none; \}~', $css));
foreach (['hr-pulse', 'hr-rise', 'hr-zz', 'hr-bob', 'hr-hop', 'hr-flick'] as $k) if (!str_contains($css, '@keyframes ' . $k . ' ')) ok("keyframes $k", false);
ok('a dotted outline shows on hover and on focus', str_contains($css, '.hroom a:hover .ht-out, .hroom a:focus-visible .ht-out { opacity: 1; }') && (bool)preg_match('/\.hroom \.ht-out \{[^}]*stroke-dasharray/', $css));
ok('the night tint follows the daypart', str_contains($css, '.hroom.dp-night .hr-tint'));
$js = (string)file_get_contents(APP_ROOT . '/assets/hovelroom.js');
ok('hovelroom.js: the lamp, the gnome, the hint and the cards\' place only; text set as text, no style but a card\'s left / top', str_contains($js, 'a[data-hlamp]') && str_contains($js, 'a[data-hsay]') && str_contains($js, 'textContent') && !str_contains($js, 'innerHTML') && !preg_match('/\.style\b(?!\.(left|top)\b)/', $js));
ok('the hint fades by itself and a card opened from the picture can be placed', str_contains($css, '@keyframes hr-hint ') && (bool)preg_match('/\.hs-hint \{[^}]*pointer-events: none[^}]*animation: hr-hint/', $css) && str_contains($css, 'dialog.hpop.hpop-at { position: fixed; margin: 0; }'));
cfg(['game_clock_on' => '', 'home_slim' => '', 'tea_open' => '']);
q("DELETE FROM settings WHERE name IN ('game_clock_on', 'home_slim', 'tea_open')");
echo $fails ? "$fails FAILED\n" : "ok\n";
exit($fails ? 1 : 0);

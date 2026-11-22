<?php
// The creature's guard meter (Josh: "add a block meter for the creature. Player has one but creature doesn't."). No DB, no server.
// php tests/pf_foeguard_meter.php
// pfight_bar_html draws a blue guard bar (.pf-fguard) next to the creature's bars in every layout that uses it (board card and stage mode); it is dimmed (class pf-fguard-0, like the player's) at foe.block 0 and
// shows the number when foe.block > 0. The replay carries the creature's guard (fgnow in the events, 'fg' in the replay steps and chips, 'fguard' in the page data) and both
// board scripts (pfboard.js and its fork pfboardv1.js) move it with setFoeGuard.
require __DIR__ . '/../game/includes/pfboard.php';
require __DIR__ . '/../game/includes/pfight_game.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
function e(string $s): string { return htmlspecialchars($s, ENT_QUOTES); }
if (!function_exists('url')) { function url(string $p = ''): string { return '/' . $p; } }
$me = ['hp' => 50, 'max_hp' => 50, 'stats' => ['level' => 8], 'deck' => pf_player_deck(['grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'level' => 8], 'thornblade', 1, [], pf_unlocks(8)), 'luck' => 0];
$foe = ['slug' => 'test-thing', 'name' => 'Test Thing', 'size' => 'medium', 'level' => 9, 'hp' => 999, 'dmg_die' => 6, 'dmg_bonus' => 1, 'attack' => 2, 'defense' => 10, 'temper' => 'wary'];

foreach (['one bar (onebar)' => ['v1' => true], '2.6.94 bars (onebar off)' => ['v1' => true, 'onebar' => 0]] as $nm => $o) {
    $s = pfb_new($me, $foe, 7, $o);
    $h0 = pfight_bar_html(pfb_view($s));
    chk("$nm: foe.block 0: the guard meter is in the markup, dimmed", preg_match('/<span class="pf-fguard pf-fguard-0"[^>]*>/', $h0) === 1 && !str_contains($h0, ' hidden') && str_contains($h0, '<b>0</b>'), $h0);
    $s['foe']['block'] = 7;
    $h7 = pfight_bar_html(pfb_view($s));
    chk("$nm: foe.block 7: the guard meter shows 7, not dimmed", preg_match('/<span class="pf-fguard[^"]*"[^>]*>/', $h7, $m) === 1 && !str_contains($m[0], 'pf-fguard-0') && str_contains($h7, '<b>7</b>') && str_contains($h7, 'guard 7'), $h7);
    chk("$nm: it sits inside the creature's bars, after the bars", preg_match('/^<div class="pf-bars">.*<span class="pf-fguard".*<\/div>$/s', $h7) === 1, $h7);
}
chk('the player\'s own guard markup is untouched (.pf-guard, not .pf-fguard)', str_contains(pfight_guard_html(5), 'class="pf-guard"') && !str_contains(pfight_guard_html(5), 'pf-fguard'), '');

// the engine: events carry the creature's guard after each step, so the replay can move the meter
$s = pfb_new($me, $foe, 7, ['v1' => true]); $s['foe']['block'] = 4;
$n = pfb_abnote($s, 'plated', '4');
chk('an ability note carries fgnow (the creature guard as it stands)', ($n['fgnow'] ?? null) === 4, $n);
chk('the bars-now tuple has the creature guard as its 5th number', pfb_env_now($s)[4] === 4, pfb_env_now($s));
$c = pfight_chip_event(['barnow' => 0.0, 'fhnow' => 10.0, 'hpnow' => 50, 'gnow' => 0, 'fgnow' => 3, 't' => 'hurt', 'by' => 'me', 'v' => 3, 'dmg' => 3, 'n' => 'x', 'tag' => '', 'k' => 'x'], 1);
chk('a history chip carries the creature guard as fg', ($c['fg'] ?? null) === 3, $c);

// the page scripts (pfboardv1.js is a fork of pfboard.js; both must move it with the replay, a rewind chip and the page data)
foreach (['pfboard.js', 'pfboardv1.js'] as $f) {
    $js = (string)file_get_contents(__DIR__ . '/../game/assets/' . $f);
    chk("$f: setFoeGuard dims the meter at 0 and writes the number", str_contains($js, 'function setFoeGuard') && str_contains($js, "classList.toggle('pf-fguard-0', g <= 0)"), '');
    chk("$f: the replay step, the opening state, a rewind chip and the page data all feed it", str_contains($js, 'setFoeGuard(ev.fg)') && str_contains($js, 'setFoeGuard(data.replay0.fg)') && str_contains($js, 'setFoeGuard(c.dataset.fg)') && str_contains($js, 'setFoeGuard(data.fguard)'), '');
}
$css = (string)file_get_contents(__DIR__ . '/../game/assets/pfight.css');
chk('pfight.css: .pf-fguard is styled and pf-fguard-0 dims it', str_contains($css, '.pf-fguard {') && str_contains($css, '.pf-fguard-0 { opacity: .45; }'), '');
echo $bad ? "$bad FAILED\n" : "pf_foeguard_meter ok\n"; exit($bad ? 1 : 0);

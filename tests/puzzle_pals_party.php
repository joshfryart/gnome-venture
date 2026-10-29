<?php
// v2.0.88 Puzzle Pals step 4: take along (equip), passive perks, the avatar companions, the Expert-trophy buff maths. Run by puzzle_pals.sh on a walk.sh install: php tests/puzzle_pals_party.php GAME
$_SERVER['SCRIPT_NAME'] = '/index.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/puzzle_pals.php';
require_once APP_ROOT . '/includes/games.php';
require_once APP_ROOT . '/includes/adventure.php';
$fails = 0;
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? 'ok   ' : 'FAIL ') . $what . ($cond ? '' : "  ($extra)") . "\n"; if (!$cond) $fails++; }
jigsaw_ensure(); ppal_ensure();
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$pic = q_one("SELECT * FROM puzzle_pics WHERE slug = 'jig-maplewold'");
$pid = (int)$pic['id'];
$u = fn() => q_one('SELECT * FROM users WHERE id = ?', [$uid]);
function reset_all(): void { ppal_party_reset(); }
function equip(int $uid, array $keys, int $pid): void {
    q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]);
    foreach (['mw-acorn-nip', 'mw-leaf-tuck', 'mw-sap-drip', 'mw-bark-badger', 'mw-fourwind-finch', 'mw-samara-spin'] as $k)
        q('INSERT INTO ppal_found (user_id, pal_key, pic_id, found_at, times, active) VALUES (?, ?, ?, ?, 1, ?)', [$uid, $k, $pid, now(), in_array($k, $keys, true) ? 1 : 0]);
    ppal_party_reset();
}
q('DELETE FROM ppal_releases WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_trophies WHERE user_id = ?', [$uid]);
q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, $pid, now(), 'free']);
q('UPDATE users SET level = 15 WHERE id = ?', [$uid]);
set_setting('puzzles_open', '1'); set_setting('jigsaw_open', '1'); set_setting('ppal_open', '1'); set_setting('ppal_party', '0'); set_setting('ppal_party_max', '2'); setting('__reload__');

$ph = APP_ROOT . '/assets/img/puzzles/pals/'; @mkdir($ph, 0777, true);
$made = [];
foreach (['mw-acorn-nip', 'mw-leaf-tuck'] as $k) if (!is_file($ph . $k . '.png')) { file_put_contents($ph . $k . '.png', 'x' . $k); $made[] = $k; }   // stand-in art (only the file's presence matters here)
echo "== off by default: no change for players\n";
equip($uid, ['mw-samara-spin', 'mw-bark-badger'], $pid);
ok('ppal_party 0: nothing equipped, no perks', ppal_equipped($u()) === [] && ppal_perks($u())['road'] === 0 && ppal_perks($u())['lines'] === []);
ok('ppal_party 0: cannot take along', ppal_set_active($u(), 'mw-acorn-nip', true)[0] === false);
ok('ppal_party 0: gnome_avatar_pals = gnome_avatar, no gpw', !str_contains(gnome_avatar_pals($u(), 90), 'gpw') && preg_replace('/-[0-9a-f]{6}/', '', gnome_avatar_pals($u(), 90)) === preg_replace('/-[0-9a-f]{6}/', '', gnome_avatar($u(), 90)));
ok('ppal_party 0: tinker xp unchanged', games_pal_xp($uid, 10) === 10);
$base = gnome_combat($u(), true);
ok('ppal_party 0: gnome_combat identical with or without pals flag', $base === gnome_combat($u()));
ok('ppal_party 0: trophy unit is 0', ppal_trophy_unit($uid, $pid) === 0);

set_setting('ppal_party', '1'); setting('__reload__'); reset_all();
echo "== perk maths (common 1 / uncommon 2 / rare 3 units)\n";
$pp = fn() => ppal_perks($u());
ok('road: rare 3 + uncommon 2 = 5 units, 5 intdiv 2 = +2', $pp()['units'] === ['road' => 5] && $pp()['road'] === 2, json_encode($pp()['units']));
equip($uid, ['mw-fourwind-finch', 'mw-acorn-nip'], $pid);
ok('finder uncommon 2u = +10%, tinker common 1u = +1%', $pp()['finder'] === 10 && $pp()['tinker'] === 1 && $pp()['road'] === 0, json_encode($pp()));
equip($uid, ['mw-sap-drip', 'mw-leaf-tuck'], $pid);
ok('gather 1u = +1%, bloom 1u = +1%', $pp()['gather'] === 1 && $pp()['bloom'] === 1);
ok('perk lines are sentences', count($pp()['lines']) === 2 && str_contains(implode(' ', $pp()['lines']), '+1% rare finds when you gather'), json_encode($pp()['lines']));
equip($uid, ['mw-samara-spin', 'mw-bark-badger', 'mw-leaf-tuck'], $pid);
ok('party max 2: a third active row is ignored', count(ppal_equipped($u())) === 2);
echo "== Expert trophy: +1 unit per equipped pal of that picture, then the caps\n";
equip($uid, ['mw-samara-spin', 'mw-bark-badger'], $pid);
q('INSERT INTO ppal_trophies (user_id, pic_id, earned_at, src) VALUES (?, ?, ?, ?)', [$uid, $pid, now(), 'free']); reset_all();
ok('trophy unit 1 while party on', ppal_trophy_unit($uid, $pid) === 1);
ok('road 5 units + 2 (one per pal) = 7 intdiv 2 = 3 (the cap)', $pp()['units'] === ['road' => 7] && $pp()['road'] === 3);
equip($uid, ['mw-fourwind-finch', 'mw-acorn-nip'], $pid);
ok('with the trophy: finder 3u = +15%, tinker 2u = +2%', $pp()['finder'] === 15 && $pp()['tinker'] === 2, json_encode($pp()));
equip($uid, ['mw-sap-drip', 'mw-leaf-tuck'], $pid);
ok('with the trophy: gather 2u = +2%, bloom 2u = +2%', $pp()['gather'] === 2 && $pp()['bloom'] === 2);
ok('a pal listed in the book shows its units line with the trophy', ppal_perk_line(ppal_find_pal($pic, 'mw-sap-drip'), 1 + ppal_trophy_unit($uid, $pid)) === 'Brings +2% rare finds when you gather');
q('DELETE FROM ppal_trophies WHERE user_id = ?', [$uid]); reset_all();
ok('no trophy: back to 1u', $pp()['gather'] === 1);
ok('caps hold (units far past the cap)', min(PPAL_PERK_CAP['finder'], 5 * 40) === 30 && min(PPAL_PERK_CAP['road'], intdiv(40, 2)) === 3);
echo "== gates\n";
q('UPDATE users SET level = 14 WHERE id = ?', [$uid]); reset_all();
ok('level 14: can take along since 2.0.91 (no level gate)', ppal_can_party($u()) && count(ppal_equipped($u())) === 2);
q('UPDATE users SET level = 15 WHERE id = ?', [$uid]); reset_all();
ok('level 15: can take along', ppal_can_party($u()) && count(ppal_equipped($u())) === 2);
q('UPDATE ppal_found SET pal_key = ? WHERE user_id = ? AND pal_key = ?', ['mw-gone-pal', $uid, 'mw-sap-drip']); reset_all();
ok('an unknown pal key plays as nothing (no error, one pal left)', count(ppal_equipped($u())) === 1 && ppal_perks($u())['bloom'] === 1);
equip($uid, [], $pid);
echo "== take along / send home\n";
ok('take along #1', ppal_set_active($u(), 'mw-samara-spin', true)[0] === true && count(ppal_equipped($u())) === 1);
ok('take along #2', ppal_set_active($u(), 'mw-bark-badger', true)[0] === true && count(ppal_equipped($u())) === 2);
[$o3, $m3] = ppal_set_active($u(), 'mw-acorn-nip', true);
ok('a third is refused ("party is full")', $o3 === false && str_contains($m3, 'full') && (int)q_val('SELECT COUNT(*) FROM ppal_found WHERE user_id = ? AND active = 1', [$uid]) === 2, $m3);
ok('a pal not found yet is refused', ppal_set_active($u(), 'nope-key', true)[0] === false);
ok('taking the same pal again is harmless', ppal_set_active($u(), 'mw-samara-spin', true)[0] === true && count(ppal_equipped($u())) === 2);
ok('send home frees a place', ppal_set_active($u(), 'mw-samara-spin', false)[0] === true && count(ppal_equipped($u())) === 1 && ppal_set_active($u(), 'mw-acorn-nip', true)[0] === true);
ok('perks follow the party (acorn: tinker 1%, bark: road 2u = +1)', $pp()['tinker'] === 1 && $pp()['road'] === 1, json_encode($pp()['units']));
echo "== where the perks land\n";
$n = 0; for ($i = 0; $i < 400; $i++) $n += ppal_scale(10, 1) - 10;   // 1% of 10 XP = 0.1: about 40 extras in 400 tries
ok('ppal_scale rolls fractions fairly (about 10%)', $n > 15 && $n < 80, (string)$n);
ok('ppal_scale: 250 at 2% = 255 exactly', ppal_scale(250, 2) === 255 && ppal_scale(7, 0) === 7);
$a = gnome_combat($u(), false); $b = gnome_combat($u(), true);
ok('road perk (+1): max_hp +5 and attack +1 with the flag, identical without', $b['max_hp'] === $a['max_hp'] + 5 && $b['atk'] === $a['atk'] + 1 && $b['ac'] === $a['ac'] + 1 && $a === gnome_combat($u()), json_encode([$a, $b]));
equip($uid, ['mw-fourwind-finch'], $pid);
ok('finder: shorter odds (1 in 60 becomes 1 in 55 at +10%)', (int)round(60 / (1 + ppal_perks($u())['finder'] / 100)) === 55);
echo "== the avatar companions\n";
equip($uid, ['mw-acorn-nip', 'mw-leaf-tuck'], $pid);
$h = gnome_avatar_pals($u(), 90);
ok('two companions beside the gnome, class-only (no inline style)', substr_count($h, 'class="gpal gpal-') === 2 && str_contains($h, 'gpal-l') && str_contains($h, 'gpal-r') && !str_contains($h, 'style='), $h);
ok('the wrapper holds the plain avatar svg', str_starts_with($h, '<span class="gpw') && str_contains($h, '<svg class="gnomeart"'));
$keep = is_file($ph . 'mw-acorn-nip.png') ? file_get_contents($ph . 'mw-acorn-nip.png') : null;
@unlink($ph . 'mw-acorn-nip.png'); reset_all();
ok('a pal with no art draws nothing (never a broken image)', substr_count(gnome_avatar_pals($u(), 90), 'class="gpal gpal-') === 1);
if ($keep !== null) file_put_contents($ph . 'mw-acorn-nip.png', $keep);
ok('tiny avatars (under 30 px) stay plain', !str_contains(gnome_avatar_pals($u(), 24), 'gpw'));
ok('trek renderers keep the plain avatar (gnome_avatar has no wrapper)', !str_contains(gnome_avatar($u(), 24), 'gpw'));
q('UPDATE users SET level = 14 WHERE id = ?', [$uid]); reset_all();
ok('level under 15: companions show too', str_contains(gnome_avatar_pals($u(), 90), 'gpw'));
q('UPDATE users SET level = 15 WHERE id = ?', [$uid]); reset_all();
set_setting('ppal_open', '0'); setting('__reload__'); reset_all();
ok('ppal_open off: perks and companions off', ppal_perks($u())['units'] === [] && !str_contains(gnome_avatar_pals($u(), 90), 'gpw') && games_pal_xp($uid, 10) === 10);
set_setting('ppal_open', '1'); set_setting('ppal_party', '0'); setting('__reload__');
foreach ($made as $k) @unlink($ph . $k . '.png');
q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]); q('DELETE FROM ppal_releases WHERE user_id = ?', [$uid]);
echo $fails ? "$fails FAILED\n" : "all ok\n";
exit($fails ? 1 : 0);

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
echo "== perk maths (common 8 / uncommon 15 / rare 30 percent; road 1 / 2 / 4 points)\n";
$pp = fn() => ppal_perks($u());
ok('road: rare 4 + uncommon 2 = 6 points, capped at +5', $pp()['units'] === ['road' => 6] && $pp()['road'] === 5, json_encode($pp()['units']));
equip($uid, ['mw-fourwind-finch', 'mw-acorn-nip'], $pid);
ok('finder uncommon = +15%, tinker common = +8%', $pp()['finder'] === 15 && $pp()['tinker'] === 8 && $pp()['road'] === 0, json_encode($pp()));
equip($uid, ['mw-sap-drip', 'mw-leaf-tuck'], $pid);
ok('gather common = +8%, bloom common = +8%', $pp()['gather'] === 8 && $pp()['bloom'] === 8);
ok('perk lines are sentences', count($pp()['lines']) === 2 && str_contains(implode(' ', $pp()['lines']), '+8% rare finds when you gather'), json_encode($pp()['lines']));
equip($uid, ['mw-samara-spin', 'mw-bark-badger', 'mw-leaf-tuck'], $pid);
ok('party max 2: a third active row is ignored', count(ppal_equipped($u())) === 2);
echo "== Expert trophy: +4 percent (+1 road point) per equipped pal of that picture, then the caps\n";
equip($uid, ['mw-samara-spin', 'mw-bark-badger'], $pid);
q('INSERT INTO ppal_trophies (user_id, pic_id, earned_at, src) VALUES (?, ?, ?, ?)', [$uid, $pid, now(), 'free']); reset_all();
ok('trophy unit 4 (road 1) while party on', ppal_trophy_unit($uid, $pid) === 4 && ppal_trophy_unit($uid, $pid, 'road') === 1);
ok('road 6 points + 2 (one per pal) = 8, capped at +5', $pp()['units'] === ['road' => 8] && $pp()['road'] === 5, json_encode($pp()['units']));
equip($uid, ['mw-fourwind-finch', 'mw-acorn-nip'], $pid);
ok('with the trophy: finder 19%, tinker 12%', $pp()['finder'] === 19 && $pp()['tinker'] === 12, json_encode($pp()));
equip($uid, ['mw-sap-drip', 'mw-leaf-tuck'], $pid);
ok('with the trophy: gather 12%, bloom 12%', $pp()['gather'] === 12 && $pp()['bloom'] === 12);
ok('a pal listed in the book shows its units line with the trophy', ppal_perk_line(ppal_find_pal($pic, 'mw-sap-drip'), ppal_pal_units(ppal_find_pal($pic, 'mw-sap-drip'), $uid, $pid)) === 'Brings +12% rare finds when you gather');
q('DELETE FROM ppal_trophies WHERE user_id = ?', [$uid]); reset_all();
ok('no trophy: back to 8%', $pp()['gather'] === 8);
ok('caps hold (units far past the cap)', min(PPAL_PERK_CAP['finder'], 80) === 50 && min(PPAL_PERK_CAP['road'], 40) === 5);
echo "== gates\n";
q('UPDATE users SET level = 14 WHERE id = ?', [$uid]); reset_all();
ok('level 14: can take along since 2.0.91 (no level gate)', ppal_can_party($u()) && count(ppal_equipped($u())) === 2);
q('UPDATE users SET level = 15 WHERE id = ?', [$uid]); reset_all();
ok('level 15: can take along', ppal_can_party($u()) && count(ppal_equipped($u())) === 2);
q('UPDATE ppal_found SET pal_key = ? WHERE user_id = ? AND pal_key = ?', ['mw-gone-pal', $uid, 'mw-sap-drip']); reset_all();
ok('an unknown pal key plays as nothing (no error, one pal left)', count(ppal_equipped($u())) === 1 && ppal_perks($u())['bloom'] === 8);
equip($uid, [], $pid);
echo "== take along / send home\n";
ok('take along #1', ppal_set_active($u(), 'mw-samara-spin', true)[0] === true && count(ppal_equipped($u())) === 1);
ok('take along #2', ppal_set_active($u(), 'mw-bark-badger', true)[0] === true && count(ppal_equipped($u())) === 2);
[$o3, $m3] = ppal_set_active($u(), 'mw-acorn-nip', true);
ok('a third is refused ("party is full")', $o3 === false && str_contains($m3, 'full') && (int)q_val('SELECT COUNT(*) FROM ppal_found WHERE user_id = ? AND active = 1', [$uid]) === 2, $m3);
ok('a pal not found yet is refused', ppal_set_active($u(), 'nope-key', true)[0] === false);
ok('taking the same pal again is harmless', ppal_set_active($u(), 'mw-samara-spin', true)[0] === true && count(ppal_equipped($u())) === 2);
ok('send home frees a place', ppal_set_active($u(), 'mw-samara-spin', false)[0] === true && count(ppal_equipped($u())) === 1 && ppal_set_active($u(), 'mw-acorn-nip', true)[0] === true);
ok('perks follow the party (acorn: tinker 8%, bark: road +2)', $pp()['tinker'] === 8 && $pp()['road'] === 2, json_encode($pp()['units']));
echo "== where the perks land\n";
$n = 0; for ($i = 0; $i < 400; $i++) $n += ppal_scale(10, 1) - 10;   // 1% of 10 XP = 0.1: about 40 extras in 400 tries
ok('ppal_scale rolls fractions fairly (about 10%)', $n > 15 && $n < 80, (string)$n);
ok('ppal_scale: 250 at 2% = 255 exactly', ppal_scale(250, 2) === 255 && ppal_scale(7, 0) === 7);
$a = gnome_combat($u(), false); $b = gnome_combat($u(), true);
ok('road perk (+2): max_hp +10 and attack +2 with the flag, identical without', $b['max_hp'] === $a['max_hp'] + 10 && $b['atk'] === $a['atk'] + 2 && $b['ac'] === $a['ac'] + 2 && $a === gnome_combat($u()), json_encode([$a, $b]));
equip($uid, ['mw-fourwind-finch'], $pid);
ok('finder: shorter odds (1 in 60 becomes 1 in 52 at +15%)', (int)round(60 / (1 + ppal_perks($u())['finder'] / 100)) === 52);
echo "== combat skills (passive, road/lair/delve fights only)\n";
$R = fn(string $rar, string $cal) => ['rarity' => $rar, 'calling' => $cal];
ok('skill: common Thorn Ward 1, uncommon 2, rare 3 (+ Fleet Foot 1 as its second)', ppal_pal_skills($R('common', 'rootwarden')) === ['ward' => 1] && ppal_pal_skills($R('uncommon', 'rootwarden')) === ['ward' => 2] && ppal_pal_skills($R('rare', 'rootwarden')) === ['ward' => 3, 'foot' => 1], json_encode(ppal_pal_skills($R('rare', 'rootwarden'))));
ok('skill: Sip 10 / 20 / 40 percent, Lucky Petal 1 / 2 / 4', ppal_pal_skills($R('common', 'brewroot')) === ['sip' => 10] && ppal_pal_skills($R('rare', 'brewroot'))['sip'] === 40 && ppal_pal_skills($R('rare', 'bloomcaller'))['petal'] === 4);
ok('skill line names the skill', str_contains(ppal_skill_line($R('rare', 'seedkeeper')), 'Mend: Heals you 3') && str_contains(ppal_skill_line($R('rare', 'seedkeeper')), 'Sip'));
$base = gnome_combat($u(), false);
equip($uid, [], $pid);
ok('no pals along: gnome_combat has no pal key and is the same with the flag', !isset(gnome_combat($u(), true)['pal']) && gnome_combat($u(), true) === $base);
equip($uid, ['mw-samara-spin', 'mw-bark-badger'], $pid);
$eqs = ppal_equipped($u()); $want = [];
foreach ($eqs as $e) foreach (ppal_pal_skills($e['pal']) as $k => $v) $want[$k] = ($want[$k] ?? 0) + $v;
$sk = ppal_skills($u());
$withP = gnome_combat($u(), true); $road = ppal_perks($u())['road'];
ok('the skills are the sum of the party (capped)', $sk && array_sum($sk) > 0 && $sk['ward'] === min(PPAL_SKILL_CAP['ward'], $want['ward'] ?? 0) && $sk['foot'] === min(PPAL_SKILL_CAP['foot'], $want['foot'] ?? 0), json_encode([$sk, $want]));
ok('armour, damage and crit chance carry the skills (road perk counted apart)', $withP['ac'] === $base['ac'] + $road + $sk['foot'] && $withP["dmg_bonus"] === $base["dmg_bonus"] + $road + $sk["edge"] && abs($withP['luck_crit'] - $base['luck_crit'] - $sk['petal']) < 0.0001 && $withP['pal'] === $sk, json_encode([$base, $withP]));
ok('without the flag (Treks, contests) there are no skills', gnome_combat($u(), false) === $base);
// whole combat_turn rounds: the skills as the fight uses them (Mend, Thorn Ward, Fleet Foot)
$cr = q_one('SELECT * FROM creatures ORDER BY id LIMIT 1'); $crId = (int)$cr['id'];
$fromId = (int)q_val('SELECT id FROM locations ORDER BY id LIMIT 1');
$round = function (array $user, string $action, int $lv = 0, int $hp = 900) use ($crId, $fromId): array {
    $enc = ['type' => 'creature', 'id' => $crId, 'lv' => $lv, 'sp' => 100, 'hpp' => 100, 'hp' => 900, 'max' => 900, 'bark' => 0, 'poison' => 0, 'used' => false];
    $exp = ['id' => 77, 'status' => 'active', 'hp' => $hp, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($enc), 'from_id' => $fromId, 'level' => 5, 'kind' => 'walk', 'step' => 1];
    $over = combat_turn($user, $exp, $action);
    return [$over, (int)$exp['hp'], implode(' | ', json_decode((string)$exp['log'], true) ?: [])];
};
q('UPDATE creatures SET attack = 200, dmg_die = 1, dmg_bonus = 9 WHERE id = ?', [$crId]);   // always hits for exactly 10
equip($uid, [], $pid);
[, , $log0] = $round($u(), 'attack');
ok('no pals: the creature hits for 10', str_contains($log0, 'hits you for 10'), $log0);
equip($uid, ['mw-bark-badger'], $pid);
[, , $log1] = $round($u(), 'attack');
ok('Thorn Ward 2 (uncommon rootwarden): the same hit does 8', str_contains($log1, 'hits you for 8'), $log1);
equip($uid, ['mw-acorn-nip'], $pid);
[, $hpM, $logM] = $round($u(), 'attack', 0, 500);
ok('Mend 1 (common seedkeeper): "mends you: +1" and health is 500 + 1 - 10', str_contains($logM, 'mends you: +1') && $hpM === 491, $logM . ' hp ' . $hpM);
[, $hpF, $logF] = $round($u(), 'attack', 0, 900);
ok('Mend never heals past full health', !str_contains($logF, 'mends you'), $logF);
q('UPDATE creatures SET attack = ?, dmg_die = ?, dmg_bonus = ? WHERE id = ?', [(int)$cr['attack'], (int)$cr['dmg_die'], (int)$cr['dmg_bonus'], $crId]);
$nim = (int)eff_mod($u(), 'nimble');
$lvF = 3 * ($nim + 4);   // a foe that needs 12 on the d20 plus Nimble: 45% to run away
$runs = function () use ($round, $u, $lvF): int { $n = 0; for ($i = 0; $i < 1000; $i++) { [, , $l] = $round($u(), 'flee', $lvF); if (str_contains($l, 'slip away')) $n++; } return $n; };
equip($uid, [], $pid); $r0 = $runs();
equip($uid, ['mw-fourwind-finch'], $pid); $r1 = $runs();
ok('Fleet Foot 2 (uncommon wayfinder): running away works more often (' . $r0 . ' -> ' . $r1 . ' of 1000)', $r1 - $r0 > 40);
equip($uid, [], $pid);
// Sip: a snack heals 10% more with a common brewroot pal along (needs a real snack: any cooked snack item in the game)
$snk = q_one("SELECT i.id FROM items i JOIN recipes r ON r.output_item_id = i.id AND r.category = 'cooking' AND r.tier = 'snack' WHERE i.edible = 1 AND i.slug NOT LIKE 'bought-%' ORDER BY i.id LIMIT 1");
if ($snk) {
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$snk['id']]); give_item($uid, (int)$snk['id'], 5);
    $heal = (fight_snacks($u())[0]['heal'] ?? 0);
    $eat = function () use ($u, $snk, $crId, $fromId): int {
        $enc = ['type' => 'creature', 'id' => $crId, 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => 900, 'max' => 900, 'bark' => 0, 'poison' => 0, 'used' => false];
        $exp = ['id' => 77, 'status' => 'active', 'hp' => 100, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($enc), 'from_id' => $fromId, 'level' => 5, 'kind' => 'walk', 'step' => 1];
        q('UPDATE creatures SET attack = -200 WHERE id = ?', [$crId]);   // it can never hit, so the health shown is the snack alone
        combat_turn($u(), $exp, 'snack', (int)$snk['id']);
        return (int)$exp['hp'] - 100;
    };
    $cr0 = q_one('SELECT attack FROM creatures WHERE id = ?', [$crId]);
    equip($uid, [], $pid); $plain = $eat();
    equip($uid, ['mw-sap-drip'], $pid); $sip = $eat();
    q('UPDATE creatures SET attack = ? WHERE id = ?', [(int)$cr['attack'], $crId]);
    ok('Sip 10% (common brewroot): the snack heals ' . $plain . ' plain and ' . $sip . ' with the pal', $heal > 0 && $plain === min(800, $heal) && $sip === min(800, (int)round($heal * 1.1)), "heal $heal");
    q('DELETE FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, (int)$snk['id']]);
} else echo "skip Sip fight (no cooked snack in this install)\n";
echo "== Boons (v2.3.8): a pal's own effect instead of its calling skill, only with ppal_boons on\n";
$P = fn(string $k) => ppal_find_pal($pic, $k);
set_setting('ppal_boons', '0'); setting('__reload__');
ok('Boons off: Samara Spin keeps Keen Edge 2 + Lucky Petal 1 (calling skills)', ppal_pal_skills($P('mw-samara-spin')) === ['edge' => 2, 'petal' => 1] && ppal_boon($P('mw-samara-spin')) === null);
set_setting('ppal_boons', '1'); setting('__reload__');
ok('Boons on: the six Maplewold pals have their effects', array_map(fn($k) => ppal_pal_skills($P($k)), ['mw-acorn-nip', 'mw-leaf-tuck', 'mw-sap-drip', 'mw-bark-badger', 'mw-fourwind-finch', 'mw-samara-spin'])
    === [['mend' => 1], ['guard' => 1], ['sip' => 10], ['ward' => 2], ['foot' => 2], ['edge' => 2]], json_encode(array_map(fn($k) => ppal_pal_skills($P($k)), ['mw-samara-spin'])));
ok('a row with no key (or no Boon row) still plays by its calling', ppal_pal_skills($R('rare', 'rootwarden')) === ['ward' => 3, 'foot' => 1]);
ok('the line shows the Boon name, text and the rare\'s skill', str_contains(ppal_skill_line($P('mw-leaf-tuck')), 'Leaf Pile: Halves the first 1 hit(s)') && str_contains(ppal_skill_line($P('mw-samara-spin')), 'Whirligig: Adds 2 damage') && str_contains(ppal_skill_line($P('mw-samara-spin')), 'Skill: Strike') && !str_contains(ppal_skill_line($P('mw-acorn-nip')), 'Skill:'), ppal_skill_line($P('mw-samara-spin')));
ok('short text uses the Boon name', ppal_skill_short($P('mw-sap-drip')) === 'Sticky Sweet 10%', ppal_skill_short($P('mw-sap-drip')));
equip($uid, ['mw-leaf-tuck', 'mw-bark-badger'], $pid);
$sk = ppal_skills($u());
ok('party sums: guard 1 and ward 2, no guard key without a guard Boon', ($sk['guard'] ?? 0) === 1 && $sk['ward'] === 2 && gnome_combat($u(), true)['pal'] === $sk);
equip($uid, ['mw-acorn-nip'], $pid);
ok('no guard key when no pal gives guard', !isset(ppal_skills($u())['guard']));
// whole rounds: the first hit of the fight is halved, the second is not
q('UPDATE creatures SET attack = 200, dmg_die = 1, dmg_bonus = 9 WHERE id = ?', [$crId]);   // always hits for exactly 10
equip($uid, ['mw-leaf-tuck'], $pid);
$encG = ['type' => 'creature', 'id' => $crId, 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => 900, 'max' => 900, 'bark' => 0, 'poison' => 0, 'used' => false];
$expG = ['id' => 78, 'status' => 'active', 'hp' => 900, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($encG), 'from_id' => $fromId, 'level' => 5, 'kind' => 'walk', 'step' => 1];
combat_turn($u(), $expG, 'attack'); $h1 = (int)$expG['hp'];
combat_turn($u(), $expG, 'attack'); $h2 = (int)$expG['hp'];
ok('Leaf Pile (guard 1): hit 1 does 5, hit 2 does 10 (health ' . $h1 . ' then ' . $h2 . ')', $h1 === 895 && $h2 === 885 && (json_decode((string)$expG['encounter'], true)['pg'] ?? 0) === 1, (string)$expG['log']);
equip($uid, ['mw-bark-badger'], $pid);
[, , $logB] = $round($u(), 'attack');
ok('Borrowed Coat (ward 2): the same hit does 8', str_contains($logB, 'hits you for 8'), $logB);
equip($uid, [], $pid);
q('UPDATE creatures SET attack = ?, dmg_die = ?, dmg_bonus = ? WHERE id = ?', [(int)$cr['attack'], (int)$cr['dmg_die'], (int)$cr['dmg_bonus'], $crId]);
// the other wired effects (a test row stands in for the Boon: $GLOBALS['ppal_boon_test'])
$T = fn(string $e) => ['name' => 'Test ' . $e, 'effect' => $e, 'active' => '', 'line' => ''];
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('bulwark')];
equip($uid, ['mw-acorn-nip'], $pid);
ok('bulwark (common 2): max health +2 on the road', gnome_combat($u(), true)['max_hp'] === $base['max_hp'] + ppal_perks($u())['road'] * 5 + 2, json_encode([$base['max_hp'], gnome_combat($u(), true)['max_hp']]));
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('rally')];
q('UPDATE creatures SET attack = 200, dmg_die = 1, dmg_bonus = 9 WHERE id = ?', [$crId]);   // hits for 10
$encR = ['type' => 'creature', 'id' => $crId, 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => 900, 'max' => 900, 'bark' => 0, 'poison' => 0, 'used' => false];
$expR = ['id' => 81, 'status' => 'active', 'hp' => 40, 'max_hp' => 100, 'log' => '[]', 'encounter' => json_encode($encR), 'from_id' => $fromId, 'level' => 5, 'kind' => 'walk', 'step' => 1];
combat_turn($u(), $expR, 'attack'); $hr1 = (int)$expR['hp'];   // 40 - 10 = 30: at 30% -> rally 4 once
combat_turn($u(), $expR, 'attack'); $hr2 = (int)$expR['hp'];   // 34 - 10 = 24, no second rally
ok('rally (common 4): once a fight at 30% health or less (' . $hr1 . ' then ' . $hr2 . ')', $hr1 === 34 && $hr2 === 24 && str_contains((string)$expR['log'], 'rallies you: +4'), (string)$expR['log']);
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('first')];
ok('first / slip / feast sum from the party like the rest', ppal_skills($u())['first'] === 2 && ($GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('slip')]) && ppal_skills($u())['slip'] === 1 && ($GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('feast')]) && ppal_skills($u())['feast'] === 1);
// kindle: Bark Skin lasts one round more; tonic: Grit and Nimble count more while a meal or potion boost is on; spoils and lesson sum
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('kindle')];
q('UPDATE creatures SET attack = -200 WHERE id = ?', [$crId]);
$bark = function () use ($u, $crId, $fromId): int {
    $uk = $u(); $uk['calling'] = 'rootwarden';
    $enc = ['type' => 'creature', 'id' => $crId, 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => 900, 'max' => 900, 'bark' => 0, 'poison' => 0, 'used' => false];
    $exp = ['id' => 82, 'status' => 'active', 'hp' => 900, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($enc), 'from_id' => $fromId, 'level' => 5, 'kind' => 'walk', 'step' => 1];
    combat_turn($uk, $exp, 'ability');
    return (int)json_decode((string)$exp['encounter'], true)['bark'];
};
$bk1 = $bark(); unset($GLOBALS['ppal_boon_test']); $bk0 = $bark();
ok('kindle (rootwarden Bark Skin): 3 rounds left after the turn with the pal, 2 without (' . $bk1 . ' / ' . $bk0 . ')', $bk1 === 3 && $bk0 === 2);
q('UPDATE creatures SET attack = ?, dmg_die = ?, dmg_bonus = ? WHERE id = ?', [(int)$cr['attack'], (int)$cr['dmg_die'], (int)$cr['dmg_bonus'], $crId]);
$keepBuff = q_one('SELECT buff, buff_until, buff2, buff2_until FROM users WHERE id = ?', [$uid]);
q('UPDATE users SET buff = NULL, buff_until = NULL, buff2 = NULL, buff2_until = NULL WHERE id = ?', [$uid]);
$noBuff = gnome_combat($u(), false)['atk'];
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('tonic')];
$tOff = gnome_combat($u(), true)['atk'] - ppal_perks($u())['road'];
q('UPDATE users SET buff = ?, buff_until = ? WHERE id = ?', ['{"luck":1}', gmdate('Y-m-d H:i:s', time() + 3600), $uid]);
$tOn = gnome_combat($u(), true)['atk'] - ppal_perks($u())['road'];
ok('tonic: nothing without a boost on, +1 Grit and Nimble with one (attack ' . $tOff . ' then ' . $tOn . ')', $tOff === $noBuff && $tOn === $tOff + 1, "$noBuff $tOff $tOn");
q('UPDATE users SET buff = ?, buff_until = ?, buff2 = ?, buff2_until = ? WHERE id = ?', [$keepBuff['buff'], $keepBuff['buff_until'], $keepBuff['buff2'], $keepBuff['buff2_until'], $uid]);
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('spoils')];
$sp = ppal_skills($u())['spoils'];
$GLOBALS['ppal_boon_test'] = ['mw-acorn-nip' => $T('lesson')];
ok('spoils 5 and lesson 5 (common)', $sp === 5 && ppal_skills($u())['lesson'] === 5);
unset($GLOBALS['ppal_boon_test']);
q('UPDATE creatures SET attack = ?, dmg_die = ?, dmg_bonus = ? WHERE id = ?', [(int)$cr['attack'], (int)$cr['dmg_die'], (int)$cr['dmg_bonus'], $crId]);
equip($uid, [], $pid);
// rare actives (B3): Strike 6 that cannot miss, once per fight, uses the turn
equip($uid, ['mw-samara-spin'], $pid);
$act = ppal_actives($u());
ok('Samara Spin offers Strike 6; commons offer none', count($act) === 1 && $act[0]['key'] === 'mw-samara-spin' && $act[0]['active'] === 'strike' && $act[0]['value'] === 6, json_encode($act));
$fb = ppal_fight_actives($u(), ['pa' => []]);
ok('fight button is palskill:KEY, then shown as used', $fb[0]['do'] === 'palskill:mw-samara-spin' && $fb[0]['used'] === false && ppal_fight_actives($u(), ['pa' => ['mw-samara-spin']])[0]['used'] === true);
q('UPDATE creatures SET attack = -200 WHERE id = ?', [$crId]);   // it never hits back
$encA = ['type' => 'creature', 'id' => $crId, 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => 900, 'max' => 900, 'bark' => 0, 'poison' => 0, 'used' => false];
$expA = ['id' => 79, 'status' => 'active', 'hp' => 900, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($encA), 'from_id' => $fromId, 'level' => 5, 'kind' => 'walk', 'step' => 1];
combat_turn($u(), $expA, 'palskill:mw-samara-spin'); $eA = json_decode((string)$expA['encounter'], true);
ok('Strike takes exactly 6 and is marked used', $eA['hp'] === 894 && $eA['pa'] === ['mw-samara-spin'], json_encode($eA));
$logBefore = (string)$expA['log'];
$r2 = combat_turn($u(), $expA, 'palskill:mw-samara-spin'); $eA2 = json_decode((string)$expA['encounter'], true);
ok('a second use is refused: no damage, no spend, a log line', $r2 === false && $eA2['hp'] === 894 && str_contains((string)$expA['log'], 'already helped'));
$r3 = combat_turn($u(), $expA, 'palskill:mw-nobody');
ok('a pal that is not along is refused', $r3 === false && str_contains((string)$expA['log'], 'not with you') && json_decode((string)$expA['encounter'], true)['hp'] === 894);
set_setting('ppal_boons', '0'); setting('__reload__');
ok('Boons off: no actives and the action is refused', ppal_actives($u()) === [] && combat_turn($u(), $expA, 'palskill:mw-samara-spin') === false);
set_setting('ppal_boons', '1'); setting('__reload__');
// Strike can finish a creature
$encK = $encA; $encK['hp'] = 5; $encK['max'] = 5;
$expK = ['id' => 80, 'status' => 'active', 'hp' => 900, 'max_hp' => 900, 'log' => '[]', 'encounter' => json_encode($encK), 'from_id' => $fromId, 'level' => 5, 'kind' => 'explore', 'step' => 1, 'depth' => 1];
$rK = combat_turn($u(), $expK, 'palskill:mw-samara-spin');
ok('Strike that finishes the creature wins the fight', $rK === true && str_contains((string)$expK['log'], 'defeated'), (string)$expK['log']);
q('UPDATE creatures SET attack = ?, dmg_die = ?, dmg_bonus = ? WHERE id = ?', [(int)$cr['attack'], (int)$cr['dmg_die'], (int)$cr['dmg_bonus'], $crId]);
equip($uid, [], $pid);
ok('Boons on, no pals along: gnome_combat unchanged', gnome_combat($u(), true) === $base);
set_setting('ppal_boons', '0'); setting('__reload__'); reset_all();
set_setting('ppal_party', '0'); setting('__reload__'); reset_all();
ok('ppal_party off: no skills', ppal_skills($u()) === [] && gnome_combat($u(), true) === $base);
set_setting('ppal_party', '1'); setting('__reload__'); reset_all();
equip($uid, ['mw-acorn-nip', 'mw-leaf-tuck'], $pid);
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

<?php
// The creature's bar is called YIELD (owner: "creatures still show HP, but we don't use their HP: find a better name for the Hurt/Charm bar"). No DB, no server.
// php tests/pf_yield_text.php
// New-rule fights (V1.onebar = 1): 'Yield 23/40' on the bar, 'Yield bar' in sentences, never health / HP / damage bar for the creature. 2.6.94 fights (onebar = 0) keep their words.
// A creature NOT in a fight (the almanac): its Yield bar as a typical fight sizes it (pfb_yield_max: size and level only), never its old HP.
require __DIR__ . '/../game/includes/pfboard.php';
require __DIR__ . '/../game/includes/pfight_game.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
function e(string $s): string { return htmlspecialchars($s, ENT_QUOTES); }
if (!function_exists('url')) { function url(string $p = ''): string { return '/' . $p; } }
$me = ['hp' => 50, 'max_hp' => 50, 'stats' => ['level' => 8], 'deck' => pf_player_deck(['grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'level' => 8], 'thornblade', 1, [], pf_unlocks(8)), 'luck' => 0];
function foe(string $size, int $lv): array { return ['slug' => 'test-thing', 'name' => 'Test Thing', 'size' => $size, 'level' => $lv, 'hp' => 999, 'dmg_die' => 6, 'dmg_bonus' => 1, 'attack' => 2, 'defense' => 10, 'temper' => 'wary']; }

chk('the word is one constant', defined('PF_YIELD') && PF_YIELD === 'Yield');
$s = pfb_new($me, foe('medium', 9), 7, ['v1' => true]); $v = pfb_view($s); $fm = (int)round($v['fh']['max']);
$h = pfight_bar_html($v);
chk('new fight: the bar reads "Yield 0/N" and its label "Yield 0 of N"', str_contains($h, '<b>0/' . $fm . '</b>') && str_contains($h, 'aria-label="Yield 0 of ' . $fm . ':') && str_contains($h, 'title="Yield 0/' . $fm . ':'), $h);
chk('new fight: "Yield bar" in the sentence', str_contains($h, 'Yield bar'), $h);
chk('new fight: no creature health, HP, damage bar or "Bar N of M"', !preg_match('/health|\bhp\b|damage|Bar \d/i', $h), $h);
$s2 = $s; $s2['fh']['now'] = 15.0; $s2['bar']['now'] = 8.0; $h2 = pfight_bar_html(pfb_view($s2));
chk('new fight, part full: "Yield 23/N" with hurt 15, charm 8', str_contains($h2, 'title="Yield 23/' . $fm . ': hurt 15, charm 8"') && str_contains($h2, '<b>23/' . $fm . '</b>'), $h2);
$old = pfb_new($me, foe('medium', 9), 7, ['v1' => ['team2' => PFB_TEAM2, 'team3' => PFB_TEAM3, 'life' => 1] + PFB_V1_PRE]); $ov = pfb_view($old);
chk('the 2.6.94 fight really is two bars', empty($ov['onebar']));
$ho = pfight_bar_html($ov);
chk('2.6.94 fight: keeps "Creature health" and the Charm bar, no Yield', str_contains($ho, 'Creature health') && str_contains($ho, 'Charm bar') && !str_contains($ho, 'Yield'), $ho);

// history chips and the lit-spot / plan words
$ch = pfight_chip_event(['by' => 'me', 't' => 'hurt', 'v' => 7, 'fh' => 7.0, 'bar' => 0, 'n' => 'Jab', 'fhnow' => 7.0, 'barnow' => 0.0], null, true);
chk('new fight chip: a Hurt piece reads "+7 hurt" (it fills the Yield bar), no damage / hp', str_contains($ch['txt'], '+7 hurt') && !preg_match('/damage|\bhp\b/', $ch['txt']), $ch['txt']);
$ce = pfight_chip_event(['env' => 'bramble', 'kind' => 'bramble', 'n' => 'Bramble', 'foe' => 3.0, 'me' => 0], null, true);
chk('new fight chip: environment on the creature reads "Yield +3"', str_contains($ce['txt'], 'Yield +3') && !str_contains($ce['txt'], 'bar +'), $ce['txt']);
$co = pfight_chip_event(['by' => 'me', 't' => 'hurt', 'v' => 7, 'fh' => 7.0, 'bar' => 0, 'n' => 'Jab', 'fhnow' => 7.0, 'barnow' => 0.0], null, false);
chk('2.6.94 chip keeps "-7 hp"', str_contains($co['txt'], '-7 hp'), $co['txt']);

// a creature not in a fight: its Yield bar is the bar of a fight (size and level only), the same number pfb_new makes
foreach ([['small', 2], ['small', 5], ['medium', 3], ['medium', 12], ['medium', 19], ['large', 11], ['large', 30], ['boss', 28]] as [$sz, $lv]) {
    $f = pfb_view(pfb_new($me, foe($sz, $lv), 5, ['v1' => true]))['fh']['max']; $y = pfb_yield_max(foe($sz, $lv));
    chk("pfb_yield_max($sz lv $lv) = the Yield bar of a new fight ($f)", abs($y - $f) < 0.51 && $y === (int)round($f), $y);
}
chk('pfb_yield_max ignores the old hp column', pfb_yield_max(foe('medium', 9) + ['hp' => 1]) === pfb_yield_max(foe('medium', 9)));
$ph = pf_yield_phrase(foe('medium', 9));
chk('the almanac phrase: "Yield bar N", no health', preg_match('/^Yield bar \d+$/', $ph) === 1, $ph);

chk('almanac numbers, new rules: Yield bar, attack, defence; no health', pf_foe_numbers(foe('medium', 9), true) === 'Yield bar 75, attack +2, defence 10.', pf_foe_numbers(foe('medium', 9), true));
chk('almanac numbers, old rules: the old health', pf_foe_numbers(foe('medium', 9), false) === 'health 999, attack +2, defence 10.', pf_foe_numbers(foe('medium', 9), false));

// the browser script: v1 words
$js = file_get_contents(__DIR__ . '/../game/assets/pfboardv1.js');
chk('pfboardv1.js: one YIELD word read from the page data', str_contains($js, "data.yieldw || 'Yield'") && str_contains($js, 'YIELD + ') , '');
chk("pfboardv1.js: no 'Bar N of M', 'damage +' or 'The bar' words for the creature's bar", !preg_match("/'Bar '|'damage \\+'|n: 'The bar'|of the bar as damage|The bar takes/", $js), '');
chk('pfboardv1.js: the tip and the help row say Yield bar', str_contains($js, 'Yield bar'), '');
chk('pfboardv1.js: the 2.6.94 words stay for a 2.6.94 fight', str_contains($js, 'Creature health') && str_contains($js, 'the creature loses '), '');
echo $bad ? "$bad FAILED\n" : "pf_yield_text ok\n"; exit($bad ? 1 : 0);

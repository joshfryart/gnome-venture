<?php
// The words the game uses to tell the player what a piece does: one short plain sentence for every type, tag, special and upgrade (2.6.96 notation pass).
// php tests/pf_piece_text.php
require __DIR__ . '/../game/includes/pfboard.php'; require __DIR__ . '/../game/includes/pfight_game.php'; require __DIR__ . '/../game/includes/pfdeck.php'; require __DIR__ . '/../game/includes/pfdeck_view.php';
$bad = 0;
function chk(string $name, bool $ok, $got = ''): void { global $bad; echo ($ok ? 'ok   ' : 'FAIL ') . $name . ($ok ? '' : ' (got ' . (is_string($got) ? $got : json_encode($got)) . ')') . "\n"; if (!$ok) $bad++; }
$types = ['hurt', 'guard', 'heal', 'charm', 'soothe', 'trick', 'item'];
chk('PF_TYPE_TEXT exists with all 7 types', defined('PF_TYPE_TEXT') && array_keys(PF_TYPE_TEXT) === $types);
if (!defined('PF_TYPE_TEXT') || !function_exists('pf_type_text')) { echo "FAILED (no texts yet)\n"; exit(1); }
$all = [];
foreach ($types as $t) $all['type ' . $t] = PF_TYPE_TEXT[$t];
chk('PF_TAGS_V1 has every tag PF_TAGS has', array_keys(PF_TAGS_V1) === array_keys(PF_TAGS));
foreach (PF_TAGS_V1 as $k => $v) $all['tag ' . $k] = $v[1];
foreach (PF_SPECIAL as $k => $v) $all['special ' . $k] = $v;
foreach (PF_MODS as $k => $v) $all['mod ' . $k] = PF_MODS_V1[$k] ?? $v[2];
foreach (['PFV_FOE_TAG' => PFV_FOE_TAG] as $n => $m) foreach ($m as $k => $v) $all['creature tag ' . $k] = $v;
foreach ($all as $k => $v) {
    chk("$k: 1-69 characters", is_string($v) && strlen($v) >= 3 && strlen($v) < 70, $v);
    chk("$k: no 'health' for a creature bar, no 'resolve'", !preg_match('/creature.{0,20}health|its health|resolve/i', $v), $v);
}
chk('Soothe names its effect (the creature\'s next hits, cut)', preg_match('/next hit/i', PF_TYPE_TEXT['soothe']) && preg_match('/less|cut|soften|reduc/i', PF_TYPE_TEXT['soothe']), PF_TYPE_TEXT['soothe']);
chk('Soothe with a value: "Soothe 4: ..." says the 4', strpos(pf_type_text('soothe', 4), '4') !== false && !strpos(pf_type_text('soothe', 4), '#'), pf_type_text('soothe', 4));
chk('Hurt and Charm fill the Yield bar', stripos(PF_TYPE_TEXT['hurt'], 'Yield bar') !== false && stripos(PF_TYPE_TEXT['charm'], 'Yield bar') !== false);
chk('Heavy says it has no rule on the board', preg_match('/no (extra|catch)|nothing extra|just/i', PF_TAGS_V1['heavy'][1]) && !preg_match('/last/i', PF_TAGS_V1['heavy'][1]), PF_TAGS_V1['heavy'][1]);
chk('Trip and Lull say the creature skips its turn', preg_match('/skip/i', PF_TAGS_V1['trip'][1]) && preg_match('/skip/i', PF_TAGS_V1['lull'][1]), [PF_TAGS_V1['trip'][1], PF_TAGS_V1['lull'][1]]);
chk('PF_TAGS (strip fights, v1 off) keeps the old Heavy rule words', stripos(PF_TAGS['heavy'][1], 'last') !== false);
chk('the piece text has no Teamwork or set-aside', !preg_match('/teamwork|set aside|set-aside/i', implode(' ', $all)));
$js = (string)file_get_contents(__DIR__ . '/../game/assets/pfv1box.js'); $miss = [];
foreach (PF_TYPE_TEXT as $t => $x) if (strpos($js, "$t: '" . $x . "'") === false) $miss[] = $t;
chk('the box script (pfv1box.js) has the same type texts', !$miss, $miss);
foreach (PFV_FOE_TAG as $k => $x) if (strpos((string)file_get_contents(__DIR__ . '/../tools/pfboardv1_part.js'), "$k: '" . $x . "'") === false) $miss[] = 'foe ' . $k;
chk('the fight script (pfboardv1_part.js) has the same creature tag texts', !$miss, $miss);
echo $bad ? "$bad FAILED\n" : "all ok\n";
exit($bad ? 1 : 0);

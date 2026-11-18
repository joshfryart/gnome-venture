<?php
// 32: 2.7.08 COUNTER PIECES (required by pfboard_v1.php; claude/engine-2.7.08-notes.md "Counter piece per type"). A counter knack (pf_pieces.txt ref LEVEL:CLASS) carries tile field 'cnt' = the class;
// when it fires for you against a creature of that class (pfb_kind, the class rule of a new fight) it counts PFB_COUNTER_ADD more. Mirrored in tools/pfengine.js (fire).
require_once __DIR__ . '/../game/includes/pfdeck.php';   // pfd_fight_entries / pfd_tiles (the deck model)
echo "== 32. counter pieces: +" . PFB_COUNTER_ADD . " against their own class (2.7.08)\n";
$cf = function (string $kind, array $over = []) { $s = v1_bare('medium', $over); $s['foe']['hand'] = []; $s['foe']['kind'] = $kind; v1_put($s, 'me', v1_tile($s, 'dodge', 'guard', 2, 'body'), 1, 2); return $s; };
$fireV = function (array $s, array $t): ?array { $c = pfb_cells($s, $t, 'me')[0] ?? null; if (!$c) return null; $s['me']['hand'] = [$t]; $r = pfb_place($s, 'me', 0, $c[0], $c[1]); foreach ($r ?? [] as $e) if (($e['k'] ?? '') === $t['k']) return $e; return null; };
$scare = function (array $s) { return v1_tile($s, 'scarecrow', 'hurt', 4, 'mind', 'knack', ['cnt' => 'bird']); };
$e = $fireV($cf('bird'), $scare($cf('bird')));
chk('a Bird counter fired against a Bird: value 4 + ' . PFB_COUNTER_ADD . ', marked as a counter', $e && (int)$e['v'] === 4 + PFB_COUNTER_ADD && !empty($e['cntr']), $e);
$e = $fireV($cf('beast'), $scare($cf('beast')));
chk('the same piece against a Beast: plain 4, no mark', $e && (int)$e['v'] === 4 && empty($e['cntr']), $e);
$e = $fireV($cf('bird', ['kinds' => 0]), $scare($cf('bird', ['kinds' => 0])));
chk('a fight without class rules (kinds 0): plain 4', $e && (int)$e['v'] === 4 && empty($e['cntr']), $e);
$s = $cf('bird'); $t = $scare($s); $c = pfb_cells($s, $t, 'foe')[0]; $s['foe']['hand'] = [$t]; $r = pfb_place($s, 'foe', 0, $c[0], $c[1]);
chk('a counter piece never helps the creature', $r && (int)$r[0]['v'] === 4 && empty($r[0]['cntr']), $r[0] ?? null);
chk('the log line says the counter worked', str_contains(pfight_line(['by' => 'me', 'id' => 3, 'k' => 'scarecrow', 'n' => 'Scarecrow Flap', 't' => 'hurt', 'v' => 6, 'tag' => 'trip', 'fit' => false, 'combo' => null, 'cntr' => 1, 'root' => true], 'Owl'), 'counter +' . PFB_COUNTER_ADD), pfight_line(['by' => 'me', 'id' => 3, 'k' => 'scarecrow', 'n' => 'Scarecrow Flap', 't' => 'hurt', 'v' => 6, 'tag' => 'trip', 'fit' => false, 'combo' => null, 'cntr' => 1, 'root' => true], 'Owl'));
$ent = array_values(array_filter(pfd_fight_entries(['state' => ['scarecrow' => true]] + pfd_sources_blank(12, 'thornblade')), fn($e) => $e['k'] === 'scarecrow'));
$tl = $ent ? pfd_tiles($ent, ['grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'charm' => 0, 'lore' => 0, 'luck' => 0, 'level' => 12])[0] : [];
chk('the deck model gives the counter knack its class as tile field cnt (pf_pieces.txt ref 8:bird)', ($tl['cnt'] ?? '') === 'bird', $tl);

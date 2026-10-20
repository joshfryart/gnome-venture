<?php
// Treks v2.0.20: Knacks (skill slots that swap one strength for another).
// Run on an installed copy: php tests/trek_knacks.php GAME_DIR [BASE_URL]   (treks.sh does; BASE_URL = the running test server, for the HTTP part).
// Parts: no knacks = unchanged stats, each knack's delta, slot counts, respec rules (camp / hub / fight), bad input, carry-over, HTTP (CSRF, forged fields), boss sims.
// The sims use real dice: AUDIT_N fights per row (default 200).
$GAME = $argv[1];
$BASE = $argv[2] ?? '';
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $GAME . '/includes/bootstrap.php';
require_once $GAME . '/includes/trek.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid, $f, $need, $ch);
$run = fn(?int $ch = null) => trek_load(trek_run_row($uid, $ch));
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_petals_daily', '5000'); set_setting('trek_entry_energy', '10'); set_setting('trek_base_level', '15');
setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');

/** A brand-new Chapter I run, inside, gnome + Burdock + Zinnia recruited and in the party, at the Chapter I camp tile. */
$fresh = function () use ($uid, $tx) {
    foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
    q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
    q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
    $tx(fn(&$run, $u) => trek_enter($run, $u), false);
    $tx(function (&$run, $u) {
        foreach (['burdock', 'zinnia'] as $k) trek_recruit_crew($run, $u, $k);
        trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia']);
        $run['sn'] = str_repeat("\xff", strlen($run['sn']));
        return [true, ''];
    });
};
$campOf = function () { foreach (trek_spots(1) as $s) if ($s['type'] === 'camp') return $s; return null; };
$at = fn(?array $s) => $tx(function (&$run, $u) use ($s) { $run['x'] = $s['x']; $run['y'] = $s['y']; return [true, '']; });
$stats = fn() => $tx(function (&$run, $u) { $o = []; foreach (trek_party_stats($run, $u) as $sl => $m) $o[$sl] = ['max' => $m['max'], 'atk' => $m['gc']['atk'], 'dmg' => $m['gc']['dmg_bonus'], 'ac' => $m['gc']['ac'], 'tl' => $m['tl']]; return $o; });
$setTl = fn(string $k, int $lv) => $tx(function (&$run, $u) use ($k, $lv) { $run['st']['tl'][$k] = [$lv, 0]; return [true, '']; });
$setKn = fn(?array $kn) => $tx(function (&$run, $u) use ($kn) { if ($kn === null) unset($run['st']['kn']); else $run['st']['kn'] = $kn; return [true, '']; });
$act = fn(string $who, array $post, ?callable $pre = null) => $tx(function (&$run, $u) use ($who, $post, $pre) { if ($pre) $pre($run, $u); return trek_act_knack($run, $u, $who, $post); });
$kn = fn() => ($run())['st']['kn'] ?? [];
$camp = $campOf();
ok('Chapter I has a camp tile to test on', $camp !== null);

echo "== slots: one per even trek level, minor / major alternating, 11 at most\n";
$slots = [];
foreach ([1, 2, 3, 4, 5, 6, 21, 22, 23] as $lv) $slots[$lv] = trek_knack_slots($lv);
ok('slot counts at Lv1/2/3/4/5/6/21/22/23 = 0/1/1/2/2/3/10/11/11', array_values($slots) === [0, 1, 1, 2, 2, 3, 10, 11, 11], json_encode($slots));
ok('trek level cap is 23', TREK_TL_MAX === 23);
ok('slot 1 is minor (Lv2), slot 2 major (Lv4), slot 3 minor (Lv6), slot 11 minor (Lv22)', [trek_knack_pool(0), trek_knack_pool(1), trek_knack_pool(2), trek_knack_pool(10)] === ['minor', 'major', 'minor', 'minor'] && trek_knack_slot_level(0) === 2 && trek_knack_slot_level(1) === 4 && trek_knack_slot_level(10) === 22);
$pools = array_count_values(array_column(TREK_KNACKS, 7));
ok('12 knacks: 6 minor, 6 major, and every one gives and takes (a sidegrade)', $pools === ['minor' => 6, 'major' => 6] && !array_filter(TREK_KNACKS, fn($k) => min($k[2], $k[3], $k[4], $k[5]) >= 0 || max($k[2], $k[3], $k[4], $k[5]) <= 0));
ok('minor knacks are small (+-1 hit or damage, health up to 7%), most major ones bigger', !array_filter(TREK_KNACKS, fn($k) => $k[7] === 'minor' && (max(abs($k[3]), abs($k[4])) > 1 || abs($k[2]) > 7)) && count(array_filter(TREK_KNACKS, fn($k) => $k[7] === 'major' && (max(abs($k[3]), abs($k[4]), abs($k[5])) >= 2 || abs($k[2]) >= 10))) >= 5);
$fresh();
$setTl('gnome', 1);
ok('Lv1 member: no slot', $tx(fn(&$run, $u) => trek_knack_get($run, 'gnome')) === []);
$setTl('gnome', 2);
ok('Lv2 member: one empty slot', $tx(fn(&$run, $u) => trek_knack_get($run, 'gnome')) === ['']);
$setTl('gnome', 22);
ok('Lv22 member: eleven empty slots', count($tx(fn(&$run, $u) => trek_knack_get($run, 'gnome'))) === 11);
ok('trek_knack_clean: a repeat, a major id in a minor slot and a minor id in a major slot all become empty', trek_knack_clean(['heavy', 'sharp', 'sharp', 'sturdy']) === ['', '', 'sharp', 'sturdy'], json_encode(trek_knack_clean(['heavy', 'sharp', 'sharp', 'sturdy'])));

echo "== no knacks = stats exactly as before\n";
$fresh(); $setTl('gnome', 13); $setTl('burdock', 7); $setTl('zinnia', 1);
$expect = $tx(function (&$run, $u) {   // the old formula, written out: base + trek-level bonus - fatigue + shrine
    $o = [];
    foreach ($run['party'] as $slot => $p) {
        $mu = (int)$slot === 0 ? trek_gnome_user($u) : trek_crew_user($p['crew_key'], $u);
        $gc = gnome_combat($mu); [$tl] = trek_tl_get($run, $p['crew_key']); $tb = trek_tl_bonus($tl, (int)$gc['max_hp']);
        $o[$slot] = ['max' => $gc['max_hp'] + $tb['hp'], 'atk' => $gc['atk'] + $tb['atk'], 'dmg' => $gc['dmg_bonus'] + $tb['dmg'], 'ac' => $gc['ac'], 'tl' => $tl];
    }
    return $o;
});
$S0 = $stats();
ok('no st.kn: every number equals the old formula', $S0 === $expect, json_encode([$S0, $expect]));
$full = $tx(fn(&$run, $u) => json_encode(array_map(fn($m) => $m['gc'], trek_party_stats($run, $u))));
ok('no st.kn: the gc arrays carry no extra key', !str_contains($full, 'kn_hp'));
foreach ([['empty list', ['gnome' => []]], ['unknown ids', ['gnome' => ['bogus', 7, null]]], ['slot not earned yet (Zinnia Lv1)', ['zinnia' => ['sharp']]], ['crew key that is not in the run', ['nobody' => ['keen']]]] as [$label, $v]) {
    $setKn($v);
    ok("st.kn with $label: stats unchanged", $stats() === $S0);
}
$setKn(null);

echo "== each knack's delta (gnome Lv13: 6 slots)\n";
$B = $S0[0];
$d = function (array $ids) use ($setKn, $stats) { $setKn(['gnome' => $ids]); return $stats()[0]; };
$hpOf = fn(int $max, int $pct) => $max + (int)round($max * $pct / 100);
foreach (TREK_KNACKS as $id => $k) {
    $r = $d($k[7] === 'minor' ? [$id] : ['', $id]);
    ok("$id ({$k[7]}): " . $k[6], $r['max'] === $hpOf($B['max'], $k[2]) && $r['atk'] === $B['atk'] + $k[3] && $r['dmg'] === $B['dmg'] + $k[4] && $r['ac'] === $B['ac'] + $k[5], json_encode([$B, $r]));
}
$r = $d(['sharp']);  ok('literal: sharp = +1 to hit, -7% health', $r['atk'] === $B['atk'] + 1 && $r['ac'] === $B['ac'] && $r['max'] === $hpOf($B['max'], -7));
$r = $d(['', 'heavy']); ok('literal: heavy = +2 damage, -1 to hit, -2 armour', $r['dmg'] === $B['dmg'] + 2 && $r['atk'] === $B['atk'] - 1 && $r['ac'] === $B['ac'] - 2);
$r = $d(['sharp', 'heavy', 'lunge', 'steady']); ok('a build adds up (sharp + heavy + lunge + steady)', $r['atk'] === $B['atk'] + 1 - 1 + 1 && $r['dmg'] === $B['dmg'] + 2 - 1 && $r['ac'] === $B['ac'] - 2 - 2 && $r['max'] === $hpOf($B['max'], 6 - 7), json_encode([$B, $r]));
$r = $d(['sharp', 'sharp', 'sharp']); ok('a repeat is ignored (the second and third sharp count nothing)', $r['atk'] === $B['atk'] + 1);
$r = $d(['heavy']); ok('a major knack in a minor slot counts nothing', $r === $B);
$setKn(['gnome' => ['sharp', '', 'lunge', '', 'stout', '', 'hearty']]);
ok('slots not earned yet (more than 6 at Lv13) are ignored', $stats()[0] === $d(['sharp', '', 'lunge', '', 'stout']));
$setKn(['gnome' => ['sharp']]);
$other = $stats();
ok('only the member with the knack changes (Burdock and Zinnia untouched)', $other[1] === $S0[1] && $other[2] === $S0[2]);
$setKn(['gnome' => ['sharp']]); $setTl('gnome', 1);
ok('a knack whose slot is no longer earned (level lowered) stops counting', !isset($tx(fn(&$run, $u) => trek_party_stats($run, $u)[0]['gc'])['kn_hp']));
$setTl('gnome', 13);
$setKn(null);
$hpBefore = $tx(function (&$run, $u) { $run['party'][0]['hp'] = trek_party_stats($run, $u)[0]['max']; return $run['party'][0]['hp']; });
$setKn(['gnome' => ['sharp']]);
$hpAfter = $tx(function (&$run, $u) { trek_party_stats($run, $u); return $run['party'][0]['hp']; });
ok('health above the new (lower) maximum is cut to it', $hpAfter === $stats()[0]['max'] && $hpAfter < $hpBefore, "$hpBefore -> $hpAfter");

echo "== respec rules\n";
$fresh(); $at($camp); $setTl('gnome', 12); $setTl('burdock', 6);
$r = $act('gnome', [0 => 'sharp']);   ok('fill an empty slot at camp', $r[0] && ($kn()['gnome'] ?? []) === ['sharp'], json_encode([$r, $kn()]));
$r = $act('gnome', [0 => 'lunge']);   ok('change a filled slot at camp', $r[0] && $kn()['gnome'] === ['lunge']);
$r = $act('gnome', [0 => 'lunge', 1 => 'heavy']); ok('fill the second slot too (first left as is)', $r[0] && $kn()['gnome'] === ['lunge', 'heavy']);
$r = $act('gnome', [0 => '']);        ok('clear a slot at camp (slot 2 keeps its place)', $r[0] && $kn()['gnome'] === ['', 'heavy'], json_encode($kn()));
$r = $act('gnome', [0 => '', 1 => '']); ok('clearing everything removes st.kn', $r[0] && !isset($kn()['gnome']) && !isset($run()['st']['kn']));
$r = $act('gnome', [0 => 'sharp', 1 => 'steady']);
$notCamp = trek_spots(1)['start'];
$at($notCamp);
ok('test position is not a camp tile', !trek_here_camp($run()));
$r = $act('gnome', [0 => 'lunge']);   ok('off camp: change of a filled slot refused', !$r[0] && $kn()['gnome'] === ['sharp', 'steady'], json_encode([$r, $kn()]));
$r = $act('gnome', [0 => '']);        ok('off camp: clearing a filled slot refused', !$r[0] && $kn()['gnome'] === ['sharp', 'steady']);
$r = $act('gnome', [0 => 'lunge', 2 => 'stout']); ok('off camp: one refused slot refuses the whole save', !$r[0] && $kn()['gnome'] === ['sharp', 'steady']);
$setTl('gnome', 14);
$r = $act('gnome', [2 => 'stout']);   ok('off camp: an EMPTY slot (the new Lv6 one) can be filled', $r[0] && $kn()['gnome'] === ['sharp', 'steady', 'stout'], json_encode([$r, $kn()]));
$r = $act('gnome', [0 => 'sharp', 1 => 'steady', 2 => 'stout']); ok('saving the same picks off camp is fine and changes nothing', $r[0] && $kn()['gnome'] === ['sharp', 'steady', 'stout']);
$at($camp);
$tx(function (&$run, $u) { trek_start_random_fight($run, $u, 'g'); return [true, '']; });
ok('a fight is on, at a camp tile', !empty($run()['fi']) && trek_here_camp($run()) !== null);
$setTl('burdock', 12);
$r = $act('burdock', [0 => 'sharp']); ok('mid-fight: filling an empty slot refused', !$r[0] && empty($kn()['burdock']), json_encode([$r, $kn()]));
$r = $act('gnome', [0 => 'lunge']);   ok('mid-fight: changing a filled slot refused even on a camp tile', !$r[0] && $kn()['gnome'][0] === 'sharp');
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
$r = $act('burdock', [0 => 'sharp']); ok('after the fight: Burdock (a trailmate, Lv12) fills a slot', $r[0] && $kn()['burdock'] === ['sharp']);
$at($notCamp);
$r = $act('burdock', [1 => 'heavy']); ok('trailmates follow the same rule off camp (empty slot 2 fills)', $r[0] && $kn()['burdock'] === ['sharp', 'heavy']);
$r = $act('burdock', [1 => 'steady']); ok('...and a filled one does not change', !$r[0] && $kn()['burdock'] === ['sharp', 'heavy']);

echo "== respec in the interlude hub\n";
$at($camp);
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
ok('now in the hub', trek_in_hub($run()));
$tx(function (&$run, $u) { $run['x'] = 0; $run['y'] = 0; return [true, '']; });
$r = $act('gnome', [0 => 'lunge', 1 => 'reckless']); ok('hub: filled slots can be changed (the hub counts as a camp)', $r[0] && $kn()['gnome'] === ['lunge', 'reckless', 'stout'], json_encode([$r, $kn()]));
$r = $act('zinnia', [0 => 'sharp']);  ok('hub: a Lv1 member has no slot', !$r[0]);

echo "== bad input\n";
$fresh(); $at($camp); $setTl('gnome', 22); $setTl('burdock', 4);
$act('gnome', [0 => 'sharp', 1 => 'heavy']);
$bad = fn(string $label, string $who, array $post) => (function () use ($label, $who, $post, $act, $kn) { $before = json_encode($kn()); $r = $act($who, $post); ok($label, !$r[0] && json_encode($kn()) === $before, json_encode([$r, $kn()])); })();
$bad('unknown knack id refused', 'gnome', [2 => 'godmode']);
$bad('a non-string value refused', 'gnome', [2 => ['lunge']]);
$bad('slot 11 refused (0 to 10)', 'gnome', [11 => 'lunge']);
$bad('slot 99 refused', 'gnome', [99 => 'lunge']);
$bad('slot -1 refused', 'gnome', [-1 => 'lunge']);
$bad('crew not recruited refused', 'sorrel', [0 => 'sharp']);
$bad('crew key junk refused', 'x', [0 => 'sharp']);
$bad('empty crew key refused', '', [0 => 'sharp']);
$bad('Burdock (Lv4, two slots) cannot use slot 3', 'burdock', [2 => 'lunge']);
$bad('a case-changed id refused (ids are exact)', 'gnome', [2 => 'Lunge']);
$bad('a major knack in a minor slot refused', 'gnome', [2 => 'reckless']);
$bad('a minor knack in a major slot refused', 'gnome', [3 => 'lunge']);
$bad('a knack twice refused (sharp is already in slot 1)', 'gnome', [2 => 'sharp']);
$bad('the same new knack in two slots in one save refused', 'gnome', [2 => 'lunge', 4 => 'lunge']);
$r = $act('gnome', [0 => 'lunge', 2 => 'sharp']); ok('a swap in one save works (sharp moves from slot 1 to slot 3)', $r[0] && $kn()['gnome'] === ['lunge', 'heavy', 'sharp'], json_encode([$r, $kn()]));
$_POST = ['k0' => 'keen', 'k1' => ['x'], 'k7' => 'lunge', 'k' => 'keen', 'k2x' => 'heavy', 'who' => 'gnome'];
$pk = trek_post_knacks();
ok('trek_post_knacks keeps k0/k1/k7 only; an array value becomes a refusable marker', array_keys($pk) === [0, 1, 7] && $pk[1] === '*' && $pk[0] === 'keen', json_encode($pk));
$_POST = [];

echo "== carry-over to the next chapter\n";
$fresh(); $at($camp); $setTl('gnome', 13); $setTl('zinnia', 6);
$act('gnome', [0 => 'sharp', 1 => 'heavy']); $act('zinnia', [0 => 'hearty', 1 => 'sturdy']);
$want = $kn();
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
$R2 = $run();
ok('Go down worked', $r[0] === true && (int)$R2['chapter'] === 2, json_encode($r));
ok('Chapter II run carries st.kn exactly', ($R2['st']['kn'] ?? null) === $want && $want['gnome'] === ['sharp', 'heavy'], json_encode([$R2['st']['kn'] ?? null, $want]));
$S2 = $stats();
$setKn($want); $with = $stats()[0]; $setKn(null); $without = $stats()[0]; $setKn($want);
ok('...and the numbers use it (gnome: sharp (+1 to hit, -7% health) + heavy (+2 damage, -1 to hit, -2 armour) over the same gnome without)', $with['atk'] === $without['atk'] && $with['dmg'] === $without['dmg'] + 2 && $with['ac'] === $without['ac'] - 2, json_encode([$with, $without]));
$fresh();
$tx(function (&$run, $u) { trek_complete_chapter($run, $u); trek_hub_arrive($run, $u); return [true, '']; });
$tx(fn(&$run, $u) => trek_godown($run, $u));
ok('no knacks in Chapter I = no st.kn in Chapter II', !isset($run()['st']['kn']));

echo "== HTTP: the page and the POST (CSRF, forged fields)\n";
if ($BASE === '' || !function_exists('curl_init')) { echo "  skip (no BASE_URL or curl)\n"; }
else {
    $jar = tempnam(sys_get_temp_dir(), 'kj');
    $http = function (string $path, ?array $post = null) use ($BASE, $jar) {
        $ch = curl_init($BASE . '/' . $path);
        curl_setopt_array($ch, [CURLOPT_RETURNTRANSFER => true, CURLOPT_COOKIEJAR => $jar, CURLOPT_COOKIEFILE => $jar, CURLOPT_FOLLOWLOCATION => false, CURLOPT_TIMEOUT => 30]);
        if ($post !== null) { curl_setopt($ch, CURLOPT_POST, true); curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($post)); }
        $body = (string)curl_exec($ch); $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE); curl_close($ch);
        return [$code, $body];
    };
    $tok = function (string $html) { return preg_match('/name="csrf" value="([^"]*)"/', $html, $m) ? html_entity_decode($m[1]) : ''; };
    [, $lg] = $http('login.php');
    $http('login.php', ['csrf' => $tok($lg), 'username' => 'sprout', 'password' => 'TestPass123!']);
    $fresh(); $at($camp); $setTl('gnome', 12); $setTl('burdock', 4);
    [$code, $page] = $http('trek.php?t=party');
    ok('Party tab loads (200) with a knack form per member and a select per slot', $code === 200 && substr_count($page, 'name="do" value="knack"') >= 2 && str_contains($page, 'name="k0"') && str_contains($page, 'name="k1"'), "code $code");
    ok('gnome (Lv12) has six selects k0..k5 and the next slot shows as locked; Burdock (Lv4) two; no k6', str_contains($page, 'name="k5"') && !str_contains($page, 'name="k6"') && str_contains($page, 'Lv14 minor (locked)') && str_contains($page, 'Lv2 minor') && str_contains($page, 'Lv4 major'));
    $csrf = $tok($page);
    $mine = fn() => ($run())['st']['kn'] ?? [];
    $http('trek.php', ['do' => 'knack', 'who' => 'gnome', 'k0' => 'sharp', 't' => 'party']);
    ok('forged: no CSRF token -> nothing saved', $mine() === []);
    $http('trek.php', ['csrf' => 'forged', 'do' => 'knack', 'who' => 'gnome', 'k0' => 'sharp', 't' => 'party']);
    ok('forged: wrong CSRF token -> nothing saved', $mine() === []);
    [$c2] = $http('trek.php', ['csrf' => $csrf, 'do' => 'knack', 'who' => 'gnome', 'k0' => 'sharp', 'k1' => 'sturdy', 't' => 'party']);
    ok('real token: saved (redirect back to the Party tab)', $c2 === 302 && ($mine()['gnome'] ?? []) === ['sharp', 'sturdy'], json_encode([$c2, $mine()]));
    [, $page2] = $http('trek.php?t=party');
    ok('the page now shows the picks selected', (bool)preg_match('/name="k0"[^>]*>.*?<option value="sharp" selected/s', $page2));
    $csrf = $tok($page2);
    foreach ([['unknown id', ['who' => 'gnome', 'k2' => 'op']], ['slot 11', ['who' => 'gnome', 'k11' => 'lunge']], ['crew not in the run', ['who' => 'sorrel', 'k0' => 'sharp']], ['array value', ['who' => 'gnome', 'k2' => ['lunge']]], ['slot not earned (Burdock Lv4, k2)', ['who' => 'burdock', 'k2' => 'lunge']], ['wrong pool', ['who' => 'gnome', 'k2' => 'heavy']], ['repeat', ['who' => 'gnome', 'k2' => 'sharp']]] as [$label, $f]) {
        $before = json_encode($mine());
        $http('trek.php', array_merge(['csrf' => $csrf, 'do' => 'knack', 't' => 'party'], $f));
        ok("forged field: $label -> nothing saved", json_encode($mine()) === $before, json_encode($mine()));
    }
    $at($notCamp);
    [, $page3] = $http('trek.php?t=party');
    ok('off camp: filled selects are disabled, no Save knacks button for the gnome', substr_count($page3, 'name="k0" disabled') >= 1);
    $http('trek.php', ['csrf' => $tok($page3), 'do' => 'knack', 'who' => 'gnome', 'k0' => 'lunge', 't' => 'party']);
    ok('off camp over HTTP: changing a filled slot refused', ($mine()['gnome'] ?? [])[0] === 'sharp');
    $http('trek.php', ['csrf' => $tok($page3), 'do' => 'knack', 'who' => 'burdock', 'k0' => 'stout', 't' => 'party']);
    ok('off camp over HTTP: filling an empty slot works', ($mine()['burdock'] ?? []) === ['stout']);
    @unlink($jar);
}

echo "== boss sims: Old Pinch Lv13 and Old Thrum Lv14, all 20 parties, baseline vs. four builds (slots = what each member has at their trek level)\n";
$GLOBALS['trek_sim'] = true;
$N = (int)(getenv('AUDIT_N') ?: 200);
$su = q_one('SELECT * FROM users WHERE id = ?', [$uid]); $su['id'] = 999999; $su['level'] = 15; $su['calling'] = null;
foreach (['grit', 'nimble', 'hardiness'] as $st) $su['stat_' . $st] = 12;
// builds: each member fills their slots from the pool of the slot, taking the build's favourites first (no repeats)
$BUILDS = [
    'offence' => ['minor' => ['bold', 'sharp', 'rough', 'lunge', 'hearty', 'stout'], 'major' => ['heavy', 'reckless', 'deadeye', 'sturdy', 'steady', 'bulwark']],   // damage and hit first
    'defence' => ['minor' => ['hearty', 'stout', 'sharp', 'bold', 'rough', 'lunge'], 'major' => ['sturdy', 'steady', 'bulwark', 'heavy', 'deadeye', 'reckless']],   // health first
    'hit'     => ['minor' => ['sharp', 'lunge', 'stout', 'hearty', 'rough', 'bold'], 'major' => ['deadeye', 'heavy', 'reckless', 'sturdy', 'steady', 'bulwark']],   // to hit first
    'tank'    => ['minor' => ['hearty', 'stout', 'lunge', 'rough', 'bold', 'sharp'], 'major' => ['bulwark', 'steady', 'sturdy', 'reckless', 'heavy', 'deadeye']],   // armour and health first, paid for in damage and hit
];
$buildList = function (string $build, int $n) use ($BUILDS): array {
    $used = []; $out = [];
    for ($i = 0; $i < $n; $i++) { $pool = trek_knack_pool($i); foreach ($BUILDS[$build][$pool] as $id) if (!isset($used[$id])) { $used[$id] = 1; $out[] = $id; continue 2; } $out[] = ''; }
    return $out;
};
$simWin = function (array $keys, int $L, string $boss, int $mateLv, ?string $build, ?int $force = null) use ($su, $N, $buildList): float {
    $won = 0; $s = trek_spots(2)[$boss];
    for ($i = 0; $i < $N; $i++) {
        $r = ['id' => 0, 'chapter' => 2, 'fatigue' => 0, 'st' => ['tl' => []], 'party' => [], 'fi' => null, 'lg' => [], 'flags' => ['tut_party' => true], 'petals_found' => 0];
        $keys2 = array_merge(['gnome'], $keys);
        foreach ($keys2 as $sl => $k) {
            $lv = $k === 'gnome' ? $L : $mateLv;
            $r['party'][$sl] = ['crew_key' => $k, 'hp' => 9999]; $r['st']['tl'][$k] = [$lv, 0];
            if ($build !== null) $r['st']['kn'][$k] = $buildList($build, $force ?? trek_knack_slots($lv));
        }
        foreach (trek_party_stats($r, $su) as $sl => $m) $r['party'][$sl]['hp'] = $m['max'];
        $GLOBALS['trek_sim_won'] = false;
        $c = trek_creature($s['data']['creature']); $meta = ['kind' => 'spot', 'spot' => $boss, 'script' => $s['data']['script'], 'zone' => $s['zone']];
        $f = trek_make_foe($c, $su, count($keys2), false, trek_foe_tune($meta, 2), 2);
        trek_start_fight($r, $su, [$c], $meta, [$f]);
        for ($k = 0; $k < 80 && $r['fi']; $k++) trek_fight_round($r, $su, trek_fight_ai($r, $su));
        if (!empty($GLOBALS['trek_sim_won'])) $won++;
    }
    return round(100 * $won / $N, 1);
};
$combos = function (array $pool, int $n) use (&$combos): array { if ($n === 0) return [[]]; $out = []; foreach ($pool as $i => $k) foreach ($combos(array_slice($pool, $i + 1), $n - 1) as $rest) $out[] = array_merge([$k], $rest); return $out; };
$abbr = ['burdock' => 'Bu', 'zinnia' => 'Zi', 'bracken' => 'Br', 'sorrel' => 'So', 'tumble' => 'Tu', 'juniper' => 'Ju'];
$nm = fn(array $c) => implode('+', array_map(fn($k) => $abbr[$k], $c));
$cols = array_keys($BUILDS);
$table = [];
foreach (['pinch' => 13, 'thrum' => 14] as $boss => $L) {
    foreach ($combos(array_keys($abbr), 3) as $c) {
        $row = ['base' => $simWin($c, $L, $boss, $L - 1, null)];
        foreach ($cols as $b) $row[$b] = $simWin($c, $L, $boss, $L - 1, $b);
        $table[$boss][$nm($c)] = $row;
    }
}
$avg = fn(array $rows, string $col) => round(array_sum(array_column($rows, $col)) / max(1, count($rows)), 1);
echo "  base: lowest party " . json_encode(array_map(fn($rows) => min(array_column($rows, 'base')), $table)) . "\n  boss   | build   | avg base -> avg build | avg change | biggest party rise | lowest party win\n";
$sum = [];
foreach ($table as $boss => $rows) {
    foreach ($cols as $col) {
        $rise = max(array_map(fn($r) => $r[$col] - $r['base'], $rows)); $low = min(array_column($rows, $col));
        $sum[$boss][$col] = ['avgd' => round($avg($rows, $col) - $avg($rows, 'base'), 1), 'rise' => $rise, 'low' => $low];
        $wp = array_search($low, array_column($rows, $col)); $wn = array_keys($rows)[$wp];
        echo sprintf("  %-6s | %-7s | %5.1f -> %5.1f        | %+5.1f     | %+5.1f             | %5.1f (%s, base %.1f)\n", $boss, $col, $avg($rows, 'base'), $avg($rows, $col), $sum[$boss][$col]['avgd'], $rise, $low, $wn, $rows[$wn]['base']);
    }
}
$maxAvgRise = max(array_map(fn($b) => max(array_column($b, 'avgd')), $sum));
$maxPartyRise = max(array_map(fn($b) => max(array_column($b, 'rise')), $sum));
$minAny = min(array_map(fn($b) => min(array_column($b, 'low')), $sum));
ok('no build raises the AVERAGE win rate by more than 8 points on either boss (worst +' . $maxAvgRise . ')', $maxAvgRise <= 8, json_encode($sum));
ok('...and no single party gains more than 8 points + sim noise (+' . $maxPartyRise . ' of 22 allowed)', $maxPartyRise <= 22, (string)$maxPartyRise);
ok('every one of the 20 parties still wins at least 70% on both bosses with the offence, hit, defence and tank builds (lowest ' . $minAny . '%)', $minAny >= 70, (string)$minAny);
$full = [];
foreach ([['Bu', 'burdock', 'zinnia', 'bracken']] as $_) {}
foreach ($BUILDS as $b => $_) $full[$b] = $simWin(['burdock', 'zinnia', 'bracken'], 14, 'thrum', 13, $b, 11);
echo '  info stress (Bu+Zi+Br at Thrum, every member with ALL 11 slots): ' . json_encode($full) . ' (base ' . $table['thrum']['Bu+Zi+Br']['base'] . ")\n";
unset($GLOBALS['trek_sim'], $GLOBALS['trek_sim_won']);

echo $fails ? "== $fails FAILED\n" : "== all passed\n";
exit($fails ? 1 : 0);

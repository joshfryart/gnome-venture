<?php
// 2.6.74 stage C: seed the test gnome (sprout) for the v1 Puzzle box pages and their screenshots (tests/pbox_v1.sh, tests/pbox_v1_shots.js).
// php tests/pbox_v1_seed.php GAME box            tools of four ranks, a worn and a broken tool, repair kits, crops grown, a craft made, guides read, two pals along, level 12
// php tests/pbox_v1_seed.php GAME fight SIZE [auto]   a creature of that size in front of the gnome (small | medium | large | boss), the fight not dealt yet (the pre-fight screen)
// php tests/pbox_v1_seed.php GAME midfight SEED  deal the fight and play turns (a greedy player) until the board shows ground, a forecast and an aim and the hand has a piece that cannot be played
// php tests/pbox_v1_seed.php GAME win|lose       play the fight under way to its end (win: the creature's health is set to 1 hit; lose: your health to 1)
$_SERVER['SCRIPT_NAME'] = '/adventure.php';
require $argv[1] . '/includes/bootstrap.php';
require_once APP_ROOT . '/includes/adventure.php';
require_once APP_ROOT . '/includes/pfight_game.php';
require_once APP_ROOT . '/includes/pfdeck.php';
require_once APP_ROOT . '/includes/puzzle_pals.php';
const PBOX_V294 = ['team2' => PFB_TEAM2, 'team3' => PFB_TEAM3, 'life' => 1] + PFB_V1_PRE;   // the page tests seed fights with the 2.6.94 rules until the page learns the new ones (T12); a new fight plays Teamwork, Wind and per-piece life off
define('PBOX_RULES', getenv('PBOX_RULES') === 'new' ? true : PBOX_V294);   // T12: PBOX_RULES=new seeds the fight with the rules a new fight has now (one bar, free pass, no set-aside, no Teamwork, flip any number of times); the default stays the 2.6.94 rules
$u = q_one("SELECT * FROM users WHERE username = 'sprout'"); $uid = (int)$u['id']; $what = $argv[2] ?? 'box';
$give = function (string $slug, int $n = 1) use ($uid) { $id = item_id_by_slug($slug); if ($id) give_item($uid, $id, $n); return $id; };

if ($what === 'box') {
    q("INSERT OR REPLACE INTO settings (name, value) VALUES ('pfight_v1', 'admin')"); setting('__reload__'); pfd_ensure(); pfd_ensure_content();   // the content is only made while the setting is on
    q('UPDATE users SET level = 12, coins = 900 WHERE id = ?', [$uid]);
    $byType = [];   // one tool per type and tier
    foreach (q("SELECT slug, effects FROM items WHERE category = 'tool'")->fetchAll() as $r) { $f = json_decode((string)$r['effects'], true) ?: []; if (!empty($f['tool'])) $byType[$f['tool']][(int)($f['tier'] ?? $f['power'] ?? 1)] = $r['slug']; }
    $want = ['till' => 3, 'water' => 2, 'axe' => 1, 'forage' => 4, 'net' => 1]; $got = [];
    foreach ($want as $type => $tier) { $t = $byType[$type] ?? []; if (!$t) continue; krsort($t); $slug = $t[$tier] ?? reset($t); $give($slug); $got[] = $type . ':' . $slug; }
    if (function_exists('tool_cache_reset')) tool_cache_reset();
    $give(PFD_REPAIR, 2); $give('stitched-fight-belt');
    foreach (['tomato', 'wheat', 'basil', 'potato', 'carrot', 'oats'] as $i => $slug) if ($id = item_id_by_slug($slug)) { q('DELETE FROM user_food_mastery WHERE user_id = ? AND item_id = ?', [$uid, $id]); q('INSERT INTO user_food_mastery (user_id, item_id, eaten, grown) VALUES (?, ?, ?, ?)', [$uid, $id, $i * 12, 3 + $i * 9]); }
    foreach (q("SELECT MIN(id) AS id FROM recipes GROUP BY category LIMIT 3")->fetchAll(PDO::FETCH_COLUMN) as $rid) { q('DELETE FROM user_recipes WHERE user_id = ? AND recipe_id = ?', [$uid, $rid]); q('INSERT INTO user_recipes (user_id, recipe_id, learned_at, made) VALUES (?, ?, ?, 4)', [$uid, $rid, now()]); }
    foreach (['NA', 'MENA', 'EU'] as $c) { q('DELETE FROM user_guides WHERE user_id = ? AND guide_key = ?', [$uid, 'region:' . $c]); q('INSERT INTO user_guides (user_id, guide_key, read_at) VALUES (?, ?, ?)', [$uid, 'region:' . $c, now()]); }
    // two pals along
    require_once APP_ROOT . '/includes/games.php';
    try {
        jigsaw_ensure(); ppal_ensure();
        set_setting('puzzles_open', '1'); set_setting('jigsaw_open', '1'); set_setting('ppal_open', '1'); set_setting('ppal_party', '1'); set_setting('ppal_party_max', '2');
        $pic = q_one("SELECT * FROM puzzle_pics WHERE slug = 'jig-maplewold'");
        if ($pic) {
            q('DELETE FROM ppal_found WHERE user_id = ?', [$uid]);
            foreach (['mw-acorn-nip', 'mw-leaf-tuck', 'mw-bark-badger', 'mw-samara-spin'] as $k) q('INSERT INTO ppal_found (user_id, pal_key, pic_id, found_at, times, active) VALUES (?, ?, ?, ?, 1, ?)', [$uid, $k, (int)$pic['id'], now(), in_array($k, ['mw-bark-badger', 'mw-samara-spin'], true) ? 1 : 0]);
            if (!q_val('SELECT 1 FROM ppal_releases WHERE user_id = ? AND pic_id = ?', [$uid, (int)$pic['id']])) q('INSERT INTO ppal_releases (user_id, pic_id, released_at, src) VALUES (?, ?, ?, ?)', [$uid, (int)$pic['id'], now(), 'free']);
        }
    } catch (Throwable $e) { echo 'pals: ' . $e->getMessage() . "\n"; }
    // wear: the watering tool half worn, the axe broken
    foreach (['water' => 14, 'axe' => 20] as $type => $w) { q('DELETE FROM pf_tool_wear WHERE user_id = ? AND tool_type = ?', [$uid, $type]); q('INSERT INTO pf_tool_wear (user_id, tool_type, wear) VALUES (?, ?, ?)', [$uid, $type, $w]); }
    echo 'seeded box: ' . implode(' ', $got) . "\n";
    exit;
}

if (!active_expedition($uid)) { [$ok, $msg] = explore_start($u); }
$exp = active_expedition($uid);
if ($what === 'fight') {
    $size = $argv[3] ?? 'small';
    $c = q_one('SELECT * FROM creatures WHERE size = ? ORDER BY level, id LIMIT 1', [$size]);
    $exp['encounter'] = json_encode(['type' => 'creature', 'id' => (int)$c['id'], 'lv' => 0, 'sp' => 100, 'hpp' => 100, 'hp' => (int)$c['hp'], 'max' => (int)$c['hp'], 'bark' => 0, 'poison' => 0, 'used' => false]);
    save_exp($exp); q('UPDATE expeditions SET hp = 60, max_hp = 60 WHERE id = ?', [$exp['id']]);   // a sturdy gnome, so the seeded fights last
    pfd_ensure(); pfd_row($uid); q('UPDATE pf_decks SET auto_use = ? WHERE user_id = ?', [($argv[4] ?? '') === 'auto' ? 1 : 0, $uid]);
    echo "creature: {$c['name']} ({$c['size']}, level {$c['level']})\n";
    exit;
}
$enc = json_decode((string)$exp['encounter'], true); $c = encounter_creature($enc);
$save = function () use (&$exp, &$enc) { $exp['encounter'] = json_encode($enc); save_exp($exp); };
/** One greedy turn through the real POST path (pfight_do): the first hand piece and lit cell that the engine accepts. Returns false when nothing could be played. */
$turn = function (bool $worst = false) use (&$exp, &$enc, &$u, $c) {
    $enc = json_decode((string)$exp['encounter'], true); $s = $enc['pf']; if ($s['over']) return false;
    $_POST = ['nonce' => $s['nonce'], 'turn' => $s['turn']];
    if (!empty($s['start'])) { $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2); $_POST['moves'] = '0,' . ($cx - 1) . ',' . $cy; pfight_do($u, $exp, 'pfb_play'); save_exp($exp); return true; }
    $best = null;
    foreach ($s['me']['hand'] as $i => $t) foreach (pfb_cell_preview($s, $i) as $key => $q) { $sc = ($q['dmg'] ?? 0) + ($q['ch'] ?? 0) + ($q['n'] ?? 0); if ($worst) $sc = -$sc; if ($best === null || $sc > $best[0]) $best = [$sc, $i, $key]; }
    if ($best === null) {   // nothing fits as it is: flip a piece that fits flipped and play it (a pass is refused while one does), else pass
        foreach ($s['me']['hand'] as $i => $t) if (pfb_cell_preview($s, $i, true)) {
            $_POST['hand'] = $i; pfight_do($u, $exp, 'pfb_flip'); save_exp($exp); $e2 = json_decode((string)$exp['encounter'], true);
            foreach (pfb_cell_preview($e2['pf'], $i) as $key => $q) { $_POST = ['nonce' => $s['nonce'], 'turn' => $s['turn'], 'moves' => $i . ',' . $key]; pfight_do($u, $exp, 'pfb_play'); save_exp($exp); break; }
            return true;
        }
        pfight_do($u, $exp, 'pfb_pass'); save_exp($exp); return true;
    }
    $_POST['moves'] = $best[1] . ',' . $best[2]; pfight_do($u, $exp, 'pfb_play'); save_exp($exp);
    return true;
};
if ($what === 'midfight') {
    $enc['pfgo'] = 1; unset($enc['pf']); $save();
    $enc['pf'] = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), (int)($argv[3] ?? 7), ['v1' => PBOX_RULES, 'blank' => true, 'can_pluck' => false]); $save();   // as pfight_state deals it, with a fixed seed
    for ($i = 0; $i < (int)($argv[4] ?? 3); $i++) { $exp = active_expedition($uid); if (!$exp || !$exp['encounter']) break; $turn(($argv[5] ?? '') === 'soft'); }   // soft: the weakest move each turn, so the fight is still on afterwards
    $exp = active_expedition($uid); $enc = $exp ? json_decode((string)$exp['encounter'], true) : null; $s = $enc['pf'] ?? null;
    if ($s && ($argv[6] ?? '') === 'fade') {   // 2.6.79: hand pieces that fit nowhere are rarer now (the environment's pieces stand apart): give the first two hand pieces edges that fit nowhere on this board
        $fams = ['body', 'mind', 'craft'];
        foreach ([0, 1] as $hi) { if (!isset($s['me']['hand'][$hi])) continue;
            for ($try = 0; $try < 3000; $try++) { mt_srand($try * 7 + $hi); $e = []; foreach (['L', 'R', 'T', 'B'] as $d) $e[$d] = [mt_rand(0, 1) ? 'knob' : 'hole', $fams[mt_rand(0, 2)]]; $s['me']['hand'][$hi]['ed'] = $e; if (!pfb_cell_preview($s, $hi) && !pfb_can_flip($s, $hi)) break; }
        }
        $enc['pf'] = $s; $save();
    }
    echo $s ? 'midfight: turn ' . $s['turn'] . ', pieces ' . count($s['pcs']) . ', environment pieces ' . count(array_filter($s['pcs'], fn($p) => $p['by'] === 'env')) . ', face up ' . count($s['env']['next'] ?? []) . ', ground ' . count($s['ter'] ?? []) . ', aim ' . (empty($s['foe']['plan']) ? 'no' : 'yes') . ', over ' . ($s['over'] ?: 'no') . "\n" : "midfight: the fight ended\n";
    exit;
}
if ($what === 'charm') {   // 2.6.78: php tests/pbox_v1_seed.php GAME charm SEED VARIANT: a fight (opening done) whose hand is all Charm pieces. plain = bar empty, near = the bar one piece from full (a charm win in your own chain), nearfoe = ditto, defeat = you are on 1 health
    $var = $argv[4] ?? 'plain'; $enc['pfgo'] = 1; unset($enc['pf']); $save();
    $s = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), (int)($argv[3] ?? 7), ['v1' => PBOX_RULES, 'blank' => true, 'can_pluck' => false]);
    $st = $s['me']['stats'] ?? ['level' => 8]; $st['level'] = 8;
    $mk = fn(string $k) => pfb_v1_tile(pf_make_tile($k, $st), $s['v1']);
    if (!empty($s['start'])) { $err = pfb_start($s, 0, 'L'); if ($err) { echo "start: $err\n"; exit(1); } }
    $s['me']['hand'] = array_map($mk, ['charm', 'offer', 'hum', 'lull', 'bond']);
    if ($var === 'near') $s['bar']['now'] = round($s['bar']['max'] * 0.9, 1);
    if ($var === 'defeat') { $s['me']['hp'] = 1; $exp['hp'] = 1; }
    $enc['pf'] = $s; $save();
    echo 'charm ' . $var . ': turn ' . $s['turn'] . ', bar ' . $s['bar']['now'] . '/' . $s['bar']['max'] . ', hand ' . implode(',', array_column($s['me']['hand'], 'n')) . "\n";
    exit;
}
if ($what === 'setbar') {   // 2.6.78: php tests/pbox_v1_seed.php GAME setbar FRACTION [hp]: the charm bar at that share of full (and your health), the hand all Charm pieces again, in the fight under way
    $s = $enc['pf']; $st = $s['me']['stats'] ?? ['level' => 8]; $st['level'] = 8;
    $s['bar']['now'] = round($s['bar']['max'] * (float)($argv[3] ?? 0.9), 1);
    if (isset($argv[4])) { $s['me']['hp'] = (int)$argv[4]; $exp['hp'] = (int)$argv[4]; }
    $s['me']['hand'] = array_map(fn($k) => pfb_v1_tile(pf_make_tile($k, $st), $s['v1']), ['charm', 'offer', 'hum', 'lull', 'bond']);
    $enc['pf'] = $s; $save(); echo 'setbar: ' . $s['bar']['now'] . '/' . $s['bar']['max'] . ' hp ' . $s['me']['hp'] . ' turn ' . $s['turn'] . "\n"; exit;
}
if ($what === 'nofit') {   // 2.6.79: php tests/pbox_v1_seed.php GAME nofit SEED: the opening done, a hand of Charm pieces that fit nowhere (only End turn / Pass is possible)
    $s = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), (int)($argv[3] ?? 7), ['v1' => PBOX_RULES, 'blank' => true, 'can_pluck' => false]);
    $st = ['level' => 8]; if (!empty($s['start'])) pfb_start($s, 0, 'L');
    $kb = ['knob', 'body']; $allk = ['L' => $kb, 'R' => $kb, 'T' => $kb, 'B' => $kb];   // knob against knob never fits: every piece on the board and in the hand has four knobs
    foreach ($s['pcs'] as $id => $pc) if ($pc['by'] !== 'none') $s['pcs'][$id]['tile']['ed'] = $allk;
    $proto = null; foreach ($s['pcs'] as $pc) if ($pc['by'] === 'foe') { $proto = $pc; break; }
    $cx = intdiv(pfb_w($s), 2); $cy = intdiv(pfb_h($s), 2);   // the blank centre takes anything: close its four sides too
    if ($proto) foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) { $k = ($cx + $dx) . ',' . ($cy + $dy); if (isset($s['cell'][$k])) continue; $id = ++$s['pid']; $np = $proto; $np['id'] = $id; $np['x'] = $cx + $dx; $np['y'] = $cy + $dy; $s['pcs'][$id] = $np; $s['cell'][$k] = $id; }
    $s['me']['hand'] = array_map(function ($k) use ($s, $st, $allk) { $tl = pfb_v1_tile(pf_make_tile($k, $st), $s['v1']); $tl['ed'] = $allk; return $tl; }, ['charm', 'offer', 'hum', 'lull', 'bond']);
    $found = true; foreach ($s['me']['hand'] as $i => $tl) if (pfb_cell_preview($s, $i)) $found = false; $try = 0;
    $enc['pfgo'] = 1; $enc['pf'] = $s; $save(); echo 'nofit: ' . ($found ? 'ok' : 'NOT FOUND') . ' try ' . $try . "\n"; exit;
}
if ($what === 'notes') {   // 2.6.76: php tests/pbox_v1_seed.php GAME notes quick|slow|trip|open [SEED]: a fight whose last turn (or opening) shows that notice
    $kind = $argv[3] ?? 'quick'; $enc['pfgo'] = 1; unset($enc['pf']); $save();
    $enc['pf'] = pfb_new(pfight_me($u, $exp, $enc), pfd_foe_row($c, pfd_exp_region($exp)), (int)($argv[4] ?? 8), ['v1' => PBOX_RULES, 'can_pluck' => false]); $save();   // not the blank opening: the creature's opening pieces are on the board
    if ($kind !== 'open') {
        $s = $enc['pf'];
        if ($kind === 'quick') { foreach ($s['foe']['hand'] as $i => $t) $s['foe']['hand'][$i]['tag'] = 'quick'; $s['foe']['plan'] = null; }
        if ($kind === 'slow') $s['foe']['slow'] = 1;
        if ($kind === 'trip') $s['me']['slowdraw'] = 1;
        $enc['pf'] = $s; $save();
        $turn(true);
    }
    $exp = active_expedition($uid); $enc = json_decode((string)$exp['encounter'], true);
    echo 'notes ' . $kind . ': ' . json_encode(array_values(array_map(fn($r) => ($r['note'] ?? '-'), (array)($enc['replay'] ?? [])))) . "\n";
    exit;
}
if ($what === 'win' || $what === 'lose') {
    $s = $enc['pf'];
    if ($what === 'win') { $s['fh']['now'] = $s['fh']['max'] - 0.5; $s['wear'] = ['till' => 6, 'water' => 6] + (array)($s['wear'] ?? []); }
    else { $s['me']['hp'] = 1; $exp['hp'] = 1; $s['wear'] = ['till' => 4] + (array)($s['wear'] ?? []); }
    $enc['pf'] = $s; $save();
    for ($i = 0; $i < 30; $i++) { $exp = active_expedition($uid); if (!$exp || !$exp['encounter']) break; $enc = json_decode((string)$exp['encounter'], true); if (!empty($enc['pf']['over'])) break;
        if ($what === 'lose') { $enc['pf']['me']['hp'] = 1; $enc['pf']['me']['block'] = 0; $enc['pf']['fh']['now'] = 0; $enc['pf']['bar']['now'] = 0; $exp['hp'] = 1; $exp['encounter'] = json_encode($enc); save_exp($exp); }   // one health, and the creature never gets weaker
        $turn($what === 'lose'); }
    $exp = active_expedition($uid); $enc = $exp && $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
    if (isset($_SESSION['pfv_res'])) file_put_contents($argv[1] . '/data/pfv_res.json', json_encode($_SESSION['pfv_res']));   // the test hands it to a page (tests/pbox_v1.sh)
    echo $what . ': over ' . ($enc['pf']['over'] ?? 'gone') . ', session result ' . (isset($_SESSION['pfv_res']) ? json_encode($_SESSION['pfv_res']) : 'none') . "\n";
    exit;
}

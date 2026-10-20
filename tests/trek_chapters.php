<?php
// Treks v1.9.1: chapters. Per-chapter runs, the interlude between chapters (no replay, no going back), carry-over, the chapter registry
// (zones, milestones, tune, boss scripts), the per-player Petal cap and the map loader. Run on an installed copy: php tests/trek_chapters.php GAME_DIR (treks.sh does).
// A tiny STUB chapter 2 is written into the copy's includes/data for this run only (and removed at the end): no real Chapter II ships.
$GAME = $argv[1];
$D = $GAME . '/includes/data/';
$stub = [
    'trek_chapters_zstub.txt' => "# stub\nchapter|2|II|Stub Depths\nzone|2|j|Stub Gate|🧪|u|single\nzone|2|k|Stub Fields|🌱|o|\nzone|2|m|Stub Pools|💧|o|pool\n"
        . "ms|2|ch2_a|Stub A|trek_ms_ch2_a|StubA|100\nms|2|ch2_b|Stub B|trek_ms_ch2_b|StubB|200\ncheck|2|Stub flag|flag|stub_flag|0\ncheck|2|Stub events|evn|2|1\n"
        . "tune|2|j|120|2|2|4\ntune|2|stubboss|150|5|5|9\nfinish|2||ch2_b||||Chapter II\n",
    'trek_creatures_zstub.txt' => "# stub pools\n@pool|j|100|withered-aphid:1|2\n@pool|k|100|withered-aphid:1,earthworm-bully:1|2\n@pool|m|0|withered-aphid:1|2\n",
    'trek_spots_ch2.txt' => "2|start|start|Stub start|j|sym=Q\n2|exit|exit|Stub exit|j|sym=E\n2|camp|camp|Stub camp|k|sym=C;obj=1\n2|boss|boss|Stub Boss|k|sym=B;script=stubboss;creature=withered-aphid;flag=stub_boss;obj=2\n",
];
// a 40 x 72 map: comments of both kinds, a wall row that is exactly 40 long, an all-wall row, then the zone layer
$rows = [];
for ($y = 0; $y < 72; $y++) {
    $row = $y === 0 || $y === 71 ? str_repeat('#', 40) : '#' . str_repeat('.', 38) . '#';
    if ($y === 1) $row = '#Q' . str_repeat('.', 36) . 'E#';
    if ($y === 3) $row = '#C' . str_repeat('.', 36) . 'B#';
    $rows[] = $row;
}
$zones = [];
for ($y = 0; $y < 72; $y++) $zones[] = str_repeat($y < 36 ? 'j' : 'k', 40);
$stub['trek_map_ch2.txt'] = "; stub map 40x72 (semicolon comment)\n# hash-space comment, also fine\n#\n" . implode("\n", $rows) . "\n---\n; zones\n" . implode("\n", $zones) . "\n";
$written = []; $moved = [];
// the real Chapter II files are set aside for this run (the stub reuses chapter 2) and put back at the end
foreach (['trek_chapters_ch2.txt', 'trek_chapters_ch2b.txt', 'trek_creatures_ch2.txt', 'trek_creatures_ch2b.txt', 'trek_map_ch2.txt', 'trek_spots_ch2.txt'] as $f) if (is_file($D . $f)) { rename($D . $f, $D . $f . '.real'); $moved[] = $D . $f; }
foreach ($stub as $f => $body) { file_put_contents($D . $f, $body); $written[] = $D . $f; }
register_shutdown_function(function () use ($written, $moved) { foreach ($written as $f) @unlink($f); foreach ($moved as $f) if (is_file($f . '.real')) rename($f . '.real', $f); });

$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $GAME . '/includes/bootstrap.php';
require_once $GAME . '/includes/trek.php';
require_once $GAME . '/includes/trek_art.php';
if (session_status() !== PHP_SESSION_ACTIVE) session_start();
$fails = 0;
set_exception_handler(function (Throwable $e) { if (db()->inTransaction()) db()->rollBack(); echo '  EXCEPTION ' . get_class($e) . ': ' . $e->getMessage() . ' @ ' . basename($e->getFile()) . ':' . $e->getLine() . "\n"; exit(1); });
function ok(string $what, bool $cond, string $extra = ''): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . ($cond ? '' : "  $extra") . "\n"; if (!$cond) $fails++; }
$uid = (int)q_val("SELECT id FROM users WHERE username = 'sprout'");
$tx = fn(callable $f, bool $need = true, ?int $ch = null) => trek_tx($uid, $f, $need, $ch);
$run = fn(?int $ch = null) => trek_load(trek_run_row($uid, $ch));
$coins = fn() => (int)q_val('SELECT coins FROM users WHERE id = ?', [$uid]);
set_setting('trek_open', '1'); set_setting('trek_event_pct', '0'); set_setting('trek_enc_percent', '0'); set_setting('trek_petals_daily', '150'); set_setting('trek_entry_energy', '10'); setting('__reload__');
q('UPDATE creature_drops SET chance = 0 WHERE 1 = 1');

echo "== chapter data and the map loader\n";
ok('Chapter I defined: 9 zones, 6 milestones', count(trek_chapter(1)['zones']) === 9 && array_keys(trek_milestones(1)) === ['burdock', 'zinnia', 'bracken', 'mother', 'gloomtooth', 'chapter']);
ok('Chapter I milestone settings are the old ones', trek_milestones(1)['mother'][1] === 'trek_ms_mother' && (int)setting('trek_ms_mother') === 500);
ok('Chapter I map still 40x40 with 20 spots', trek_map(1)['w'] === 40 && trek_map(1)['h'] === 40 && count(array_filter(trek_spots(1), fn($s) => $s['type'] !== 'oldcamp')) === 20);   // (v2.0.1: the old campsites are counted in tests/trek_oldcamp.php)
ok('Chapter I tune rows = the old table', trek_foe_tune(['zone' => 'd']) === [110, 1, 1, 3] && trek_foe_tune(['script' => 'gloomtooth', 'zone' => 'x']) === [160, 6, 4, 12] && trek_foe_tune(['zone' => 'g']) === [100, 0, 0, 0]);
$m2 = trek_map(2);
ok('stub map parses: 40 wide, 72 tall, comments skipped, zones aligned', $m2['w'] === 40 && $m2['h'] === 72 && count($m2['z']) === 72 && $m2['t'][0] === str_repeat('#', 40), $m2['w'] . 'x' . $m2['h'] . ' zrows=' . count($m2['z']));
ok('a 40-wide wall row is not taken for a comment', $m2['t'][71] === str_repeat('#', 40) && $m2['t'][1][1] === 'Q');
ok('trek_map_comment rules', trek_map_comment('; x') && trek_map_comment('# x') && trek_map_comment('#') && !trek_map_comment('####') && !trek_map_comment('#.#') && !trek_map_comment('#Q..'));
ok('stub spots read from trek_spots_ch2.txt', array_keys(trek_spots(2)) === ['start', 'exit', 'camp', 'boss'] && trek_spots(2)['boss']['y'] === 3);
ok('chapter 2 exists (stub) and chapter 3 does not', trek_chapter_exists(2) && !trek_chapter_exists(3) && trek_next_chapter(1) === 2 && trek_next_chapter(2) === null);
ok('pools are per chapter', trek_zone_pool('j', 2) !== null && trek_zone_pool('j', 1) === null && trek_zone_pool('g', 1) !== null && trek_zone_pool('g', 2) === null);
ok('a later chapter\'s milestones make their own settings', isset(settings_schema()['trek_ms_ch2_a']) && (int)setting('trek_ms_ch2_a') === 100);
ok('zone data: info, style, single', trek_zone_info(2, 'j') === ['Stub Gate', '🧪'] && trek_chapter(2)['zones']['j']['style'] === 'u' && !empty(trek_chapter(2)['zones']['j']['single']) && trek_zone_info(2, 'z') === null);
$singles = 0; $multi = 0;
for ($i = 0; $i < 300; $i++) { $singles += count(trek_pick_foes('j', 2)) === 1 ? 1 : 0; $multi += count(trek_pick_foes('k', 2)) > 1 ? 1 : 0; }
ok('a zone marked single always gives one foe; an unmarked one sometimes more', $singles === 300 && $multi > 20, "$singles $multi");
ok('trailmate lore defaults to the old 10', trek_crew_user('burdock', ['level' => 16])['stat_lore'] === 10 && trek_crew()['burdock']['lore'] === 0);
ok('the interlude texts exist and are written (drafts)', trek_text_written('interlude.1.intro') && trek_text_written('interlude.1.burdock') && trek_text_written('interlude.1.zinnia') && trek_text_written('interlude.1.bracken'));

echo "== a finished Chapter I, the interlude\n";
$reset = function () use ($uid) {
    foreach (['trek_flags', 'trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
    q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
    q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
    q('UPDATE users SET level = 16, energy = 100, coins = 1000, calling = NULL, trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
};
$reset();
$tx(fn(&$run, $u) => trek_enter($run, $u), false);
ok('the first run is Chapter I and the gnome is in chapter 1', (int)$run()['chapter'] === 1 && trek_active_ch($uid) === 1);
$tx(function (&$run, $u) {
    $run['sn'] = str_repeat("\xff", strlen($run['sn']));
    trek_flag_set($run, 'won_fight'); trek_flag_set($run, 'seen_cart');
    trek_recruit_crew($run, $u, 'burdock'); trek_recruit_crew($run, $u, 'zinnia');
    $run['st']['tl']['gnome'] = [5, 10]; $run['st']['tl']['burdock'] = [4, 3]; $run['st']['tl']['zinnia'] = [3, 0];
    $run['st']['tac']['burdock'] = ['open' => 'guard']; $run['st']['tac']['gnome'] = ['target' => 'strong'];
    $run['campkits'] = 2; $run['petals_found'] = 25;
    trek_pack_add((int)$run['id'], trek_item_id('glowing-bead'), 2);
    trek_pack_add((int)$run['id'], trek_item_id('cellar-key'), 1);
    return [true, ''];
});
$beads0 = (int)q_val("SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'glowing-bead'", [$uid]);
$c0 = $coins();
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Go down refused while Chapter I is not finished', $r[0] === false && !trek_run_done($run()) && !trek_in_hub($run()));
$tx(fn(&$run, $u) => trek_complete_chapter($run, $u));
$R = $run();
ok('finishing sets ch1_done (and the old gloomtooth_cured), the reward screen', trek_run_done($R) && !empty($R['flags']['gloomtooth_cured']) && !empty($R['st']['show_done']) && !empty($R['finished']));
ok('a finished run still inside is "pending" for the interlude, not yet in it', trek_hub_pending($R) && !trek_in_hub($R));
$r = $tx(fn(&$run, $u) => trek_hub_talk($run, $u, 'burdock'));
ok('talk refused until the party is at the rest stop', $r[0] === false);
$tx(function (&$run, $u) { if (trek_hub_pending($run)) trek_hub_arrive($run, $u); return [true, '']; });
$R = $run();
ok('arriving closes the run, rests the party and banks everything', trek_in_hub($R) && (int)$R['inside'] === 0 && (int)$R['fatigue'] === 0 && (int)$R['petals_found'] === 0 && !trek_hub_pending($R));
$beads1 = (int)q_val("SELECT COALESCE(SUM(ui.qty),0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'glowing-bead'", [$uid]);
ok('the 25 carried Petals and the beads were banked; the quest item stayed in the pack', $coins() - $c0 >= 25 && $beads1 === $beads0 + 2 && trek_pack_qty((int)$R['id'], trek_item_id('cellar-key')) === 1, ($coins() - $c0) . ' / ' . ($beads1 - $beads0));
ok('the interlude is a camp: kit shop, party and rest work', trek_at_camp($R));
$k0 = (int)$R['campkits'];
set_setting('trek_campkit_max', '3'); setting('__reload__');
$r = $tx(fn(&$run, $u) => trek_buy_kit($run, $u));
ok('buy a Camp Kit at the rest stop', $r[0] === true && (int)$run()['campkits'] === $k0 + 1, json_encode($r));
$r = $tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'zinnia']));
ok('swap the party at the rest stop', $r[0] === true && ($run()['party'][1]['crew_key'] ?? '') === 'zinnia' && !isset($run()['party'][2]));
$tx(fn(&$run, $u) => trek_set_party($run, $u, [1 => 'burdock', 2 => 'zinnia']));
$tx(function (&$run, $u) { $run['party'][0]['hp'] = 1; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_hub_rest($run, $u));
ok('rest heals the party', $r[0] === true && $run()['party'][0]['hp'] > 1);
// talk
$nid = (int)trek_crew_npc('burdock')['id'];
$f0 = (int)friendship($uid, $nid)['points'];
$r = $tx(fn(&$run, $u) => trek_hub_talk($run, $u, 'burdock'));
$f1 = (int)friendship($uid, $nid)['points'];
ok('talk to Burdock: his line shows (st.talk), +1 friendship', $r[0] === true && $run()['st']['talk'] === 'burdock' && $f1 === $f0 + 1 && !empty($run()['flags']['itlk_burdock']), "$f0 -> $f1");
$tx(fn(&$run, $u) => trek_hub_talk($run, $u, 'burdock'));
$tx(fn(&$run, $u) => trek_hub_talk($run, $u, 'burdock'));
ok('the friendship point is once only', (int)friendship($uid, $nid)['points'] === $f1);
$r = $tx(fn(&$run, $u) => trek_hub_talk($run, $u, 'bracken'));
ok('cannot talk to someone you never recruited', $r[0] === false && $run()['st']['talk'] === 'burdock');
$r = $tx(fn(&$run, $u) => trek_hub_talk($run, $u, '../x'));
ok('a forged crew key is refused', $r[0] === false);

echo "== Go down: the stub Chapter II, with the party carried over\n";
$before = $run(1);
$e0 = (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]);
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('Go down works with chapter 2 data', $r[0] === true, json_encode($r));
$R2 = $run();
$R1 = $run(1);
ok('two run rows now, one per chapter; the gnome is in chapter 2', (int)q_val('SELECT COUNT(*) FROM trek_runs WHERE user_id = ?', [$uid]) === 2 && (int)$R2['chapter'] === 2 && trek_active_ch($uid) === 2 && (int)$R1['chapter'] === 1);
ok('entry energy was spent', (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) === $e0 - 10);
$st2 = trek_spots(2)['start'];
ok('the new run is inside, at the Chapter II start, fresh fog', (int)$R2['inside'] === 1 && [$R2['x'], $R2['y']] === [$st2['x'], $st2['y']] && strlen($R2['sn']) === intdiv(40 * 72 + 7, 8) && trek_seen_get($R2, $st2['x'], $st2['y']) && !trek_seen_get($R2, 20, 60));
ok('carried over: trek levels', $R2['st']['tl'] === $before['st']['tl'] && $R2['st']['tl']['gnome'] === [5, 10] && $R2['st']['tl']['burdock'] === [4, 3], json_encode($R2['st']['tl']));
ok('carried over: tactics', $R2['st']['tac'] === $before['st']['tac']);
ok('carried over: Camp Kits', (int)$R2['campkits'] === (int)$before['campkits']);
ok('carried over: recruits and party places', trek_recruits((int)$R2['id']) === trek_recruits((int)$R1['id']) && array_column($R2['party'], 'crew_key') === array_column($before['party'], 'crew_key'));
$stats = $tx(fn(&$run, $u) => array_map(fn($m) => [$m['hp'], $m['max']], trek_party_stats($run, $u)));
ok('the party starts at full health', !array_filter($stats, fn($s) => $s[0] !== $s[1]));
ok('NOT carried: flags, pack, carried Petals, fight, log, fatigue', array_keys($R2['flags']) === [] && !trek_pack_rows((int)$R2['id']) && (int)$R2['petals_found'] === 0 && $R2['fi'] === null && (int)$R2['fatigue'] === 0 && empty($R2['st']['ms']) && empty($R2['st']['kos']));
ok('Chapter I\'s run is untouched (finished, flags kept, its pack kept)', trek_run_done($R1) && !empty($R1['flags']['seen_cart']) && trek_pack_qty((int)$R1['id'], trek_item_id('cellar-key')) === 1);
ok('Chapter I is recorded done for the player', trek_chapter_done($uid, 1) && !trek_chapter_done($uid, 2));
$r = $tx(fn(&$run, $u) => trek_godown($run, $u));
ok('a second Go down from the new run does nothing', $r[0] === false && (int)q_val('SELECT COUNT(*) FROM trek_runs WHERE user_id = ?', [$uid]) === 2);
// separate fog and flags: act in Chapter II, Chapter I is unchanged
$tx(function (&$run, $u) { $run['sn'] = str_repeat("\xff", strlen($run['sn'])); trek_flag_set($run, 'ch2_only'); return [true, '']; });
$R1b = $run(1);
ok('fog and flags are per chapter', empty($R1b['flags']['ch2_only']) && $R1b['sn'] === $R1['sn'] && !empty($run()['flags']['ch2_only']));
// no way back to the Chapter I map through the engine's own run lookup
ok('the active run is the Chapter II one for every action', (int)trek_run_row($uid)['chapter'] === 2);
$tx(function (&$run, $u) { trek_flag_set($run, 'won_fight'); $run['x'] = 5; $run['y'] = 5; return [true, '']; });
$r = $tx(fn(&$run, $u) => trek_walk($run, $u, 6, 5));
ok('walking works on the Chapter II stub map', $r[0] === true && ($run()['x'] !== 5 || $run()['y'] !== 5));
$ar = trek_art_svg(2, $run(), 0, 0, 15, 11, [], null, '');
ok('the map art draws the stub chapter (zone styles from data)', str_starts_with($ar, '<svg') && strlen($ar) > 500);

echo "== per-chapter milestones, checks, tune\n";
$m0 = (int)q_val('SELECT xp FROM users WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { trek_flag_set($run, 'stub_flag'); trek_ms_award($run, $u, 'ch2_a'); trek_ms_award($run, $u, 'ch2_a'); return [true, '']; });
$ms = (int)q_val("SELECT xp FROM trek_ms WHERE user_id = ? AND ms_key = ?", [$uid, 'withering:ch2_a']);
ok('a Chapter II milestone pays its own setting once (2 checks apply to the first one, both pass)', $ms === 100 && (int)q_val('SELECT COUNT(*) FROM trek_ms WHERE user_id = ? AND ms_key = ?', [$uid, 'withering:ch2_a']) === 1, (string)$ms);
ok('the milestone key is unique to the chapter (Chapter I keys are untouched)', !isset(trek_milestones(1)['ch2_a']) && isset(trek_milestones(2)['ch2_a']));
[$d, $t] = $tx(fn(&$run, $u) => array_slice(trek_ms_checks($run, $u, 'ch2_b'), 0, 2));
ok('data checks apply from their "from" milestone on', $t === 3 && $d === 2, "$d/$t");
ok('Chapter II tune is its own', trek_foe_tune(['zone' => 'j'], 2) === [120, 2, 2, 4] && trek_foe_tune(['zone' => 'j'], 1) === [100, 0, 0, 0]);

echo "== the Petal limit is the player's, across chapters\n";
set_setting('trek_petals_daily', '50'); setting('__reload__');
q('UPDATE users SET trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$a = $tx(function (&$run, $u) { return trek_petals_capped($run, 30); }, true, 1);
$b = $tx(function (&$run, $u) { return trek_petals_capped($run, 30); }, true, 2);
$c = $tx(function (&$run, $u) { return trek_petals_capped($run, 30); }, true, 1);
ok('30 in Chapter I, then only 20 left in Chapter II, then 0 in Chapter I again', [$a, $b, $c] === [30, 20, 0], json_encode([$a, $b, $c]));
ok('the count is on the users row', (int)q_val('SELECT trek_pet_today FROM users WHERE id = ?', [$uid]) === 50 && q_val('SELECT trek_pet_day FROM users WHERE id = ?', [$uid]) === hollow_date('Y-m-d'));
q('UPDATE users SET trek_pet_day = ?, trek_pet_today = 50 WHERE id = ?', ['2000-01-01', $uid]);
ok('a new Hollow day starts the count again', $tx(function (&$run, $u) { return trek_petals_capped($run, 30); }, true, 2) === 30);
// migration from the old place (the run's state)
q('UPDATE users SET trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { $run['st']['pet_day'] = hollow_date('Y-m-d'); $run['st']['pet_today'] = 40; return [true, '']; }, true, 1);
trek_pet_migrate();
ok('trek_pet_migrate copies today\'s old run count to the player', (int)q_val('SELECT trek_pet_today FROM users WHERE id = ?', [$uid]) === 40);
q('UPDATE users SET trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
$tx(function (&$run, $u) { $run['st']['pet_day'] = hollow_date('Y-m-d'); $run['st']['pet_today'] = 45; return [true, '']; }, true, 2);
ok('...and trek_petals_capped takes an old count over by itself (45 used, 50 cap: 5 paid)', $tx(function (&$run, $u) { return trek_petals_capped($run, 30); }, true, 2) === 5);
set_setting('trek_petals_daily', '150'); setting('__reload__');

echo "== boss scripts by data (a stub boss in the registry)\n";
$GLOBALS['stub_hits'] = ['act' => 0, 'win' => 0, 'start' => 0, 'end' => 0];
trek_script_register('stubboss', [
    'code' => 'stubby',
    'moves' => fn(array $fi) => ['thump', 'roar'],
    'big' => ['roar'],
    'round_start' => function (array &$run, array $stats): void { $GLOBALS['stub_hits']['start']++; },
    'act' => function (array &$run, array $stats): void { $GLOBALS['stub_hits']['act']++; trek_say($run, 'The stub boss thumps.'); },
    'round_end' => function (array &$run, array $stats): void { $GLOBALS['stub_hits']['end']++; },
    'win' => function (array &$run, array $u, array $spot, int $n): void { $GLOBALS['stub_hits']['win']++; trek_flag_set($run, (string)$spot['data']['flag']); },
]);
ok('the registry knows the stub script and its code', trek_script_def('stubboss') !== null && trek_script_code('stubboss') === 'stubby' && trek_script_code('gloomtooth') === 'gloomtooth' && trek_script_code('blight-mother') === 'mother');
ok('Chapter I\'s three scripts are registered', trek_script_def('gloomtooth') !== null && trek_script_def('blight-mother') !== null && trek_script_def('duel_bracken') !== null && trek_script_def('') === null && trek_script_def('nope') === null);
$bs = trek_spots(2)['boss'];
$tx(function (&$run, $u) use ($bs) { $run['x'] = $bs['x']; $run['y'] = $bs['y']; $run['fi'] = null; return [true, '']; });
$tx(fn(&$run, $u) => trek_act_challenge($run, $u));
$fi = $run()['fi'];
ok('the fight uses the spot\'s script and the chapter\'s tune (health +50%)', $fi && $fi['meta']['script'] === 'stubboss' && trek_boss_moves($fi) === ['thump', 'roar']);
$base = trek_creature('withered-aphid');
ok('...tune: attack +5, damage bonus +9 on the creature\'s', (int)$fi['foes'][0]['atk'] === (int)$base['attack'] + 5 && (int)$fi['foes'][0]['bonus'] === (int)$base['dmg_bonus'] + 9);
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = $run['fi']['foes'][0]['max'] = 99999; $run['fi']['foes'][0]['atk'] = -60; return [true, '']; });
$tx(function (&$run, $u) { trek_fight_round($run, $u, [0 => ['a' => 'guard'], 1 => ['a' => 'guard'], 2 => ['a' => 'guard']]); return [true, '']; });
ok('act, round_start and round_end handlers ran', $GLOBALS['stub_hits']['act'] === 1 && $GLOBALS['stub_hits']['start'] === 1 && $GLOBALS['stub_hits']['end'] === 1, json_encode($GLOBALS['stub_hits']));
$tx(function (&$run, $u) { $run['fi']['foes'][0]['hp'] = 1; $run['fi']['foes'][0]['def'] = -50; return [true, '']; });
for ($i = 0; $i < 10 && $run()['fi']; $i++) $tx(function (&$run, $u) { trek_fight_round($run, $u, [0 => ['a' => 'attack', 't' => 'f:0'], 1 => ['a' => 'attack', 't' => 'f:0'], 2 => ['a' => 'attack', 't' => 'f:0']]); return [true, '']; });
$R = $run();
ok('the win handler ran: the spot\'s flag is set, the fight is over', !$R['fi'] && $GLOBALS['stub_hits']['win'] === 1 && !empty($R['flags']['stub_boss']));
// the Auto AI reads "big" from the registry: with a ready Bark Skin and a big move coming it shields (like it does before Gloomtooth's Burst)
$tx(function (&$run, $u) { $run['fi'] = null; trek_start_random_fight($run, $u, 'k'); $run['fi']['meta']['script'] = 'stubboss'; return [true, '']; });
$withBig = $tx(fn(&$run, $u) => trek_fight_ai($run, $u));
trek_script_register('stubboss', ['moves' => fn(array $fi) => ['thump', 'roar'], 'big' => []]);
$noBig = $tx(fn(&$run, $u) => trek_fight_ai($run, $u));
ok('the Auto AI plans from the registry (a big move changes its picks, or at least it runs)', is_array($withBig) && is_array($noBig));
$tx(function (&$run, $u) { $run['fi'] = null; return [true, '']; });
trek_script_register('stubboss', null);
ok('a script can be removed again', trek_script_def('stubboss') === null);

echo "== schema\n";
$uq = trek_runs_uniques(db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite');
ok('trek_runs is unique per player, trek, mode AND chapter (the old 3-column key is gone)', in_array(['user_id', 'trek_key', 'mode', 'chapter'], $uq, true) && !in_array(['user_id', 'trek_key', 'mode'], $uq, true), json_encode($uq));
ok('the users columns exist', (bool)q_one('SELECT trek_ch, trek_pet_day, trek_pet_today FROM users LIMIT 1'));

// leave the copy as the other tests expect it
q('DELETE FROM trek_flags WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)', [$uid]);
foreach (['trek_pack', 'trek_party', 'trek_recruits'] as $t) q("DELETE FROM $t WHERE run_id IN (SELECT id FROM trek_runs WHERE user_id = ?)", [$uid]);
q('DELETE FROM trek_runs WHERE user_id = ?', [$uid]);
q('DELETE FROM trek_ms WHERE user_id = ?', [$uid]);
q('UPDATE users SET trek_ch = 1, trek_pet_day = NULL, trek_pet_today = 0 WHERE id = ?', [$uid]);
echo $fails ? "\n$fails FAILED\n" : "\nall ok\n";
exit($fails ? 1 : 0);

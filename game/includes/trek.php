<?php
declare(strict_types=1);

require_once __DIR__ . '/adventure.php';   // gnome_combat, scale_creature, outlevel_*, snack helpers
require_once __DIR__ . '/friends.php';     // friendship(), friend_add()
require_once __DIR__ . '/trek_data.php';
require_once __DIR__ . '/trek_fight.php';
require_once __DIR__ . '/trek_oldcamp.php';   // v2.0.1: old campsites
require_once __DIR__ . '/trek_events.php';   // v1.8.8: trail events, crew moments, the side stops
require_once __DIR__ . '/trek_scene.php';   // v2.0.8: the talk pop-over (scene) queue and stage
require_once __DIR__ . '/trek_camp_ui.php';   // v2.0.11: the camp pop-over
require_once __DIR__ . '/trek_levels.php';   // v1.8.9: trek levels, milestone XP, migration

/**
 * v1.8.0 Treks, the engine: one run per gnome (trek_runs), a party, a pack, flags, a map to walk, camps, bank and knock-outs.
 * Every state change runs inside trek_tx(): a transaction, the gnome's users row locked, then the run RE-READ (as adventure.php v1.2.2).
 * The fight maths is in trek_fight.php. Story text is always trek_text(); mechanical labels are plain strings.
 * v1 slice: Gentle mode, Chapter I only. TODO later: Chapters II-VI, Thorny/Bramble, skill points, fast travel, mini-map, hats.
 */

/** Items that belong to a quest: they stay in the pack (never banked) and a knock-out never takes them. */
const TREK_QUEST_ITEMS = ['cellar-key', 'clean-dew', 'wet-clay', 'clay-pot', 'overdue-book', 'kiln-key', 'cistern-pearl'];   // v1.9.2: Chapter II-a's four; v1.9.4: the Cistern Pearl

/** A kill count that guarantees a quest drop: creature slug => [item slug, kills, zone, flag that ends it]. */
const TREK_GUARANTEE = ['grub-beetle' => ['cellar-key', 3, 'f', 'cellar_open'], 'dew-leech' => ['clean-dew', 2, 'd', 'freed_zinnia'],
    'spadefoot-toad' => ['kiln-key', 3, 'm', 'kiln_open', 2]];   // v1.9.2: the 5th field is the chapter (default 1)

const TREK_MAX_STEPS = 40;     // tiles walked by one tap
const TREK_LOG_KEEP = 30;
const TREK_FLOG_KEEP = 160;    // v1.8.8: lines kept of the latest fight (the "Show all" box and the Log tab)

// ------------------------------------------------------------------ the run

/** Can this gnome use Treks? [true, ''] or [false, why]. */
function trek_gate(array $u): array
{
    if ((int)$u['level'] < (int)setting('trek_level')) return [false, 'Treks open at gnome level ' . (int)setting('trek_level') . '.'];
    if (setting('trek_open') !== '1' && ($u['role'] ?? '') !== 'admin') return [false, 'Treks are not open yet. Soon!'];
    return [true, ''];
}

/** v1.9.1: the chapter the gnome is in (users.trek_ch): its run, or the interlude after it once that run is finished. 1 if the column is not there yet. */
function trek_active_ch(int $uid): int
{
    try {
        return max(1, (int)q_val('SELECT trek_ch FROM users WHERE id = ?', [$uid]));
    } catch (Throwable $e) {
        return 1;
    }
}

/** A gnome's run row: of $chapter, or of the chapter they are in now. One row per player and chapter. */
function trek_run_row(int $uid, ?int $chapter = null): ?array
{
    return q_one('SELECT * FROM trek_runs WHERE user_id = ? AND trek_key = ? AND mode = ? AND chapter = ?', [$uid, TREK_KEY, 'gentle', $chapter ?? trek_active_ch($uid)]) ?: null;
}

/** Every run row of a gnome, chapter by chapter. */
function trek_runs_of(int $uid): array
{
    return q('SELECT * FROM trek_runs WHERE user_id = ? AND trek_key = ? AND mode = ? ORDER BY chapter', [$uid, TREK_KEY, 'gentle'])->fetchAll();
}

/** Has this player finished the chapter? (its run has the chN_done flag) */
function trek_chapter_done(int $uid, int $chapter): bool
{
    return (bool)q_val('SELECT 1 FROM trek_flags f JOIN trek_runs r ON r.id = f.run_id WHERE r.user_id = ? AND r.chapter = ? AND f.flag = ?', [$uid, $chapter, 'ch' . $chapter . '_done']);
}

/** The chapter that comes after this one, if its data exists; null while it is "coming soon". */
function trek_next_chapter(int $chapter): ?int
{
    return trek_chapter_exists($chapter + 1) ? $chapter + 1 : null;
}

/** Is this run finished (its chapter complete)? A finished run is never walked again: the gnome is in the interlude. */
function trek_run_done(array $run): bool
{
    return !empty($run['flags']['ch' . (int)$run['chapter'] . '_done']);
}

/** The interlude: a finished run that is not inside (one screen, no map; camp services and talks). */
function trek_in_hub(array $run): bool
{
    return trek_run_done($run) && !(int)$run['inside'];
}

/** Unpack a trek_runs row: ['st' state, 'lg' log, 'fi' fight, 'sn' seen bits, 'flags', 'party' slot => [crew_key, hp]]. */
function trek_load(array $row): array
{
    $st = json_decode((string)($row['state'] ?? ''), true);
    $lg = json_decode((string)($row['log'] ?? ''), true);
    $fi = !empty($row['fight']) ? json_decode((string)$row['fight'], true) : null;
    $row['st'] = is_array($st) ? $st : [];   // audit 1.9.8: a state that is not an array (a damaged row) starts again instead of a fatal error
    $row['lg'] = is_array($lg) ? $lg : [];
    $row['fi'] = (is_array($fi) && is_array($fi['foes'] ?? null) && $fi['foes'] && is_array($fi['meta'] ?? null)) ? $fi + ['mem' => [], 'round' => 1, 'snacks' => 0] : null;   // a broken fight is dropped
    $m = trek_map((int)$row['chapter']);
    $bytes = intdiv($m['w'] * $m['h'] + 7, 8);
    $hex = (string)($row['st']['seen'] ?? '');
    $bin = ($hex !== '' && strlen($hex) % 2 === 0 && ctype_xdigit($hex)) ? (string)hex2bin($hex) : '';
    $row['sn'] = str_pad($bin, $bytes, "\0");
    $row['flags'] = array_fill_keys(q('SELECT flag FROM trek_flags WHERE run_id = ?', [$row['id']])->fetchAll(PDO::FETCH_COLUMN), true);
    $row['party'] = [];
    foreach (q('SELECT slot, crew_key, hp FROM trek_party WHERE run_id = ? ORDER BY slot', [$row['id']])->fetchAll() as $p) {
        $row['party'][(int)$p['slot']] = ['crew_key' => (string)$p['crew_key'], 'hp' => (int)$p['hp']];
    }
    return $row;
}

function trek_save(array $run): void
{
    $st = $run['st'];
    $st['seen'] = bin2hex($run['sn']);
    q('UPDATE trek_runs SET x = ?, y = ?, camp = ?, inside = ?, fatigue = ?, sneak = ?, petals_found = ?, campkits = ?, fight = ?, log = ?, state = ?, xp_day = ?, xp_today = ?, finished = ? WHERE id = ?',
        [(int)$run['x'], (int)$run['y'], $run['camp'] ?? null, (int)$run['inside'], max(0, min(100, (int)$run['fatigue'])), (int)$run['sneak'], max(0, (int)$run['petals_found']),
         max(0, (int)$run['campkits']), $run['fi'] ? json_encode($run['fi']) : null, json_encode(array_slice($run['lg'], -TREK_LOG_KEEP), JSON_UNESCAPED_UNICODE),
         json_encode($st), $run['xp_day'] ?? null, (int)$run['xp_today'], $run['finished'] ?? null, (int)$run['id']]);
    foreach ($run['party'] as $slot => $p) {
        q('UPDATE trek_party SET hp = ? WHERE run_id = ? AND slot = ?', [max(0, (int)$p['hp']), (int)$run['id'], (int)$slot]);
    }
}

/**
 * Run $fn(&$run, $u) in a transaction with the gnome locked and the run re-read (so two quick taps cannot both act on the same state).
 * $run is null if the gnome has no run yet (only trek_begin wants that). Returns what $fn returns, or null when a run was needed and is missing.
 */
function trek_tx(int $uid, callable $fn, bool $needRun = true, ?int $chapter = null)
{
    $sceneSave = [$_SESSION['trek_scene_auto'] ?? null, $_SESSION['trek_scene_seen'] ?? null];   // v2.0.9: a rolled-back action must not leave its pop-up behind
    db()->beginTransaction();
    try {
        q('UPDATE users SET id = id WHERE id = ?', [$uid]);
        $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
        $row = trek_run_row($uid, $chapter);
        $run = $row ? trek_load($row) : null;
        if (!$u || ($needRun && !$run)) { db()->rollBack(); return null; }
        if ($run) $run['st']['turn'] = (int)($run['st']['turn'] ?? 0) + 1;
        if ($run) trek_tl_migrate($run, $u);   // v1.8.9: a run from before trek levels gets its level once (guarded by st.tl)
        $res = $fn($run, $u);
        if ($run) trek_save($run);
        db()->commit();
        return $res;
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        foreach (['trek_scene_auto', 'trek_scene_seen'] as $i => $k) { if ($sceneSave[$i] === null) unset($_SESSION[$k]); else $_SESSION[$k] = $sceneSave[$i]; }
        throw $e;
    }
}

// ------------------------------------------------------------------ flags, log, fog

function trek_flag(array $run, string $flag): bool
{
    return !empty($run['flags'][$flag]);
}

function trek_flag_set(array &$run, string $flag): void
{
    if (!empty($run['flags'][$flag])) return;
    try { db_insert('trek_flags', ['run_id' => (int)$run['id'], 'flag' => $flag]); } catch (PDOException $e) { /* already there */ }
    $run['flags'][$flag] = true;
}

/** A plain log line (escaped when shown). */
function trek_say(array &$run, string $line): void
{
    $GLOBALS['trek_said'] = (int)($GLOBALS['trek_said'] ?? 0) + 1;   // v1.8.5: lets the Auto replay tell which lines a round added
    trek_flog($run, ['n' => (int)($run['st']['turn'] ?? 0), 's' => $line]);
}

/** A story line: a trek_text key (rendered when shown, so an admin edit shows at once). */
function trek_say_text(array &$run, string $key, array $vars = []): void
{
    $GLOBALS['trek_said'] = (int)($GLOBALS['trek_said'] ?? 0) + 1;
    trek_flog($run, ['n' => (int)($run['st']['turn'] ?? 0), 'k' => $key, 'v' => $vars]);
    if (function_exists('trek_scene_collect')) trek_scene_collect($run, $key, $vars);   // v2.0.9: story lines also open as the talk pop-over
}

/** Append one line to the run log, and to the latest fight's own log while a fight is being recorded (st.flog_on, set when a fight starts, dropped on the next action after it ends). */
function trek_flog(array &$run, array $entry): void
{
    $run['lg'][] = $entry;
    $run['lg'] = array_slice($run['lg'], -TREK_LOG_KEEP);
    if (!empty($run['st']['flog_on'])) {
        unset($entry['n']);
        $run['st']['flog'][] = $entry;
        if (count($run['st']['flog']) > TREK_FLOG_KEEP) $run['st']['flog'] = array_slice($run['st']['flog'], -TREK_FLOG_KEEP);
    }
}

/** The latest fight's whole log as safe HTML strings (unwritten lines skipped). */
function trek_flog_html(array $run): array
{
    $out = [];
    foreach ((array)($run['st']['flog'] ?? []) as $l) { $t = trek_line_html((array)$l); if ($t !== '') $out[] = $t; }
    return $out;
}

/** The log lines of the latest action (same turn number), as safe HTML strings. */
function trek_latest_html(array $run, bool $keep = false): array
{
    $turn = (int)($run['st']['turn'] ?? 0);
    $out = [];
    foreach ($run['lg'] as $l) if ((int)($l['n'] ?? -1) === $turn) { $t = trek_line_html($l); if ($t !== '') $out[] = $t; }   // v1.8.3: skip unwritten (empty) lines
    if ($out || !$keep) return $out;
    // v2.0.20: on the Map a quiet step (plain walking says nothing) used to empty the feed, so it vanished after the first walk (e.g. after the Clay Slide): keep the lines of the last action that said something.
    for ($i = count($run['lg']) - 1; $i >= 0; $i--) {
        $n = (int)($run['lg'][$i]['n'] ?? -1);
        if ($n >= $turn) continue;
        foreach ($run['lg'] as $l) if ((int)($l['n'] ?? -1) === $n) { $t = trek_line_html($l); if ($t !== '') $out[] = $t; }
        if ($out) break;
    }
    return $out;
}

function trek_line_html(array $l): string
{
    return isset($l['k']) ? trek_text((string)$l['k'], (array)($l['v'] ?? [])) : e((string)($l['s'] ?? ''));
}

function trek_seen_get(array $run, int $x, int $y): bool
{
    $m = trek_map((int)$run['chapter']);
    if ($x < 0 || $y < 0 || $x >= $m['w'] || $y >= $m['h']) return false;
    $i = $y * $m['w'] + $x;
    return (ord($run['sn'][$i >> 3]) & (1 << ($i & 7))) !== 0;
}

/** Light up every tile within $r of (x, y) (a square, so a corridor corner is seen too). */
function trek_seen_reveal(array &$run, int $x, int $y, int $r = 2): void
{
    $m = trek_map((int)$run['chapter']);
    for ($yy = max(0, $y - $r); $yy <= min($m['h'] - 1, $y + $r); $yy++) {
        for ($xx = max(0, $x - $r); $xx <= min($m['w'] - 1, $x + $r); $xx++) {
            $i = $yy * $m['w'] + $xx;
            $run['sn'][$i >> 3] = chr(ord($run['sn'][$i >> 3]) | (1 << ($i & 7)));
        }
    }
}

// ------------------------------------------------------------------ items and pack

function trek_item_id(string $slug): int
{
    static $ids = [];
    return $ids[$slug] ??= (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
}

function trek_item_name(int $itemId): string
{
    static $names = [];
    return $names[$itemId] ??= (string)q_val('SELECT name FROM items WHERE id = ?', [$itemId]);
}

function trek_is_quest_item(int $itemId): bool
{
    foreach (TREK_QUEST_ITEMS as $slug) if (trek_item_id($slug) === $itemId) return true;
    return false;
}

/** Add to the pack: $banked 0 = carried (at risk), 1 = a running total of what was banked (for the Pack tab). */
function trek_pack_add(int $runId, int $itemId, int $qty, int $banked = 0): void
{
    if ($qty <= 0 || $itemId <= 0) return;
    if (q('UPDATE trek_pack SET qty = qty + ? WHERE run_id = ? AND item_id = ? AND banked = ?', [$qty, $runId, $itemId, $banked])->rowCount() === 1) return;
    try {
        db_insert('trek_pack', ['run_id' => $runId, 'item_id' => $itemId, 'qty' => $qty, 'banked' => $banked]);
    } catch (PDOException $e) {
        q('UPDATE trek_pack SET qty = qty + ? WHERE run_id = ? AND item_id = ? AND banked = ?', [$qty, $runId, $itemId, $banked]);
    }
}

function trek_pack_qty(int $runId, int $itemId): int
{
    return (int)q_val('SELECT qty FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0', [$runId, $itemId]);
}

/** Take carried items out; false (and nothing taken) if there are not enough. */
function trek_pack_take(int $runId, int $itemId, int $qty): bool
{
    $ok = q('UPDATE trek_pack SET qty = qty - ? WHERE run_id = ? AND item_id = ? AND banked = 0 AND qty >= ?', [$qty, $runId, $itemId, $qty])->rowCount() === 1;
    if ($ok) q('DELETE FROM trek_pack WHERE run_id = ? AND item_id = ? AND banked = 0 AND qty <= 0', [$runId, $itemId]);
    return $ok;
}

function trek_pack_rows(int $runId): array
{
    return q('SELECT i.*, p.item_id, p.qty, p.banked FROM trek_pack p JOIN items i ON i.id = p.item_id WHERE p.run_id = ? ORDER BY i.name', [$runId])->fetchAll();
}

// ------------------------------------------------------------------ party

/** The trailmate's NPC row (name, species), or a stand-in made from the key. */
function trek_crew_npc(string $crewKey): array
{
    static $cache = [];
    if (isset($cache[$crewKey])) return $cache[$crewKey];
    $c = trek_crew()[$crewKey] ?? null;
    $npc = $c ? q_one('SELECT * FROM npcs WHERE slug = ?', [$c['npc_slug']]) : null;
    return $cache[$crewKey] = $npc ?: ['id' => 0, 'name' => ucfirst($crewKey), 'species' => '', 'slug' => (string)($c['npc_slug'] ?? $crewKey)];
}

/** v1.9.5: the level every party member fights at before trek levels. The gnome's main level does NOT count in treks (it only gates entry). */
function trek_base_level(): int
{
    return max(1, (int)setting('trek_base_level'));
}

/** v1.9.5: the player's gnome as trek combat sees it: same build (stat points, calling, quests, buffs), but level = the trek base level
 *  (so no level-derived health, attack, armour, damage or calling tier from the main level). */
function trek_gnome_user(array $u): array
{
    $u['level'] = trek_base_level();
    return $u;
}

/** A user-shaped array for a trailmate, so gnome_combat() works on them: level = base level - 2, stats from the crew row. */
function trek_crew_user(string $crewKey, array $u): array
{
    $c = trek_crew()[$crewKey] ?? ['calling' => '', 'grit' => 0, 'nimble' => 0, 'hardiness' => 0, 'luck' => 0];   // audit 1.9.8: a crew row that is gone plays as a plain trailmate, with no warnings
    return ['id' => 0, 'level' => max(1, trek_base_level() - 2), 'calling' => $c['calling'], 'calling_qt' => 2, 'stat_grit' => 10 + 2 * $c['grit'],
        'stat_nimble' => 10 + 2 * $c['nimble'], 'stat_hardiness' => 10 + 2 * $c['hardiness'], 'stat_lore' => 10 + 2 * (int)($c['lore'] ?? 0), 'stat_sense' => 10,
        'stat_charm' => 10, 'stat_luck' => 10 + 2 * $c['luck']];
}

/** Fatigue penalty to attack and armour: 60+ Tired -1, 85+ Worn out -2. */
function trek_fatigue_pen(int $fatigue): int
{
    return $fatigue >= 85 ? 2 : ($fatigue >= 60 ? 1 : 0);
}

const TREK_CREW_ICONS = ['rootwarden' => '🛡️', 'bloomcaller' => '🐝', 'thornblade' => '🪲', 'seedkeeper' => '🐌', 'wayfinder' => '🐇', 'brewroot' => '🦔'];

/** v1.9.0: the player's own gnome as a tiny inline SVG, sized like the emoji it replaces (see .meico in style.css). Decorative: a name always sits next to it. */
function trek_me_ico(array $u): string
{
    if (!function_exists('gnome_avatar')) return '🧙';
    if (!preg_match('~<svg[^>]*>(.*)</svg>\s*$~s', gnome_avatar($u, 24), $m)) return '🧙';
    return '<svg class="meico" viewBox="0 0 80 100" aria-hidden="true" focusable="false">' . $m[1] . '</svg>';
}

/**
 * Everyone in the party with their numbers: slot => ['slot','key','name','calling','level','hp','max','gc','user','icon'].
 * gc is gnome_combat() (the fatigue penalty is already taken off attack and armour). hp is clamped to the max.
 */
function trek_party_stats(array &$run, array $u): array
{
    $pen = trek_fatigue_pen((int)$run['fatigue']);
    $bless = empty($run['st']['bless']) ? 0 : 1;   // v1.8.8: the little shrine's thanks, +1 to hit and armour until the next fight ends
    $out = [];
    $run['wf'] = false;   // v1.9.4: is a Wayfinder in the party? Loose clay (+) checks it in trek_passable(), which has no user row
    foreach ($run['party'] as $slot => $p) {
        $isGnome = (int)$slot === 0;
        $mu = $isGnome ? trek_gnome_user($u) : trek_crew_user($p['crew_key'], $u);   // v1.9.5: the gnome fights at the base level, not its main level
        $gc = gnome_combat($mu);
        [$tl, $txp] = trek_tl_get($run, (string)$p['crew_key']);   // v1.8.9: trek level bonuses on top of the base stats
        $tb = trek_tl_bonus($tl, (int)$gc['max_hp']);
        $gc['max_hp'] += $tb['hp'];
        $gc['atk'] += $tb['atk'] - $pen + $bless;
        $gc['dmg_bonus'] += $tb['dmg'];
        $gc['ac'] -= $pen - $bless;
        $run['party'][$slot]['hp'] = min((int)$p['hp'], (int)$gc['max_hp']);
        if ((string)($mu['calling'] ?? '') === 'wayfinder') $run['wf'] = true;
        $npc = $isGnome ? null : trek_crew_npc($p['crew_key']);
        $out[(int)$slot] = ['slot' => (int)$slot, 'key' => $p['crew_key'], 'name' => $isGnome ? gnome_name($u) : (string)$npc['name'], 'calling' => (string)($mu['calling'] ?? ''),
            'level' => (int)$mu['level'], 'hp' => $run['party'][$slot]['hp'], 'max' => (int)$gc['max_hp'], 'gc' => $gc, 'user' => $mu,
            'tl' => $tl, 'txp' => $txp, 'tb' => $tb,
            'icon' => $isGnome ? '🧙' : TREK_CREW_ICONS[$mu['calling']] ?? '🧑',
            'ico' => $isGnome ? trek_me_ico($u) : e(TREK_CREW_ICONS[$mu['calling']] ?? '🧑')];   // v1.9.0: 'ico' = markup (the player's own gnome drawing, or the trailmate's emoji)
    }
    return $out;
}

function trek_recruits(int $runId): array
{
    return q('SELECT crew_key FROM trek_recruits WHERE run_id = ? ORDER BY id', [$runId])->fetchAll(PDO::FETCH_COLUMN);
}

/** Heal every member to full (or by a share of their max). */
function trek_heal_party(array &$run, array $u, int $pct = 100): void
{
    foreach (trek_party_stats($run, $u) as $slot => $m) {
        $run['party'][$slot]['hp'] = $pct >= 100 ? $m['max'] : min($m['max'], $m['hp'] + (int)ceil($m['max'] * $pct / 100));
    }
}

function trek_has_wayfinder(array &$run, array $u): bool
{
    foreach (trek_party_stats($run, $u) as $m) if ($m['calling'] === 'wayfinder') return true;
    return false;
}

// ------------------------------------------------------------------ enter, leave

/** Why this gnome cannot go into a trek right now, or ''. */
function trek_entry_blocker(array $u): string
{
    [$ok, $why] = trek_gate($u);
    if (!$ok) return $why;
    if (active_expedition((int)$u['id'])) return 'You’re already out on the road. Finish that first.';
    if (ts($u['community_shift_until'] ?? null) > time()) return 'You’re on a tending shift at the community garden. Finish or end it first.';
    return '';
}

/**
 * v1.9.1: a brand-new run for $chapter at its start, inside. $from = the finished run of the chapter before, or null. Carried over from it: the trailmates
 * (recruits and party places), trek levels (st.tl), tactics (st.tac) and Camp Kits. NOT carried: position, fog, flags, pack, fights, log.
 */
function trek_new_run(array $u, int $chapter, ?array $from = null): array
{
    $uid = (int)$u['id'];
    $start = trek_spots($chapter)['start'];
    $rid = db_insert('trek_runs', ['user_id' => $uid, 'trek_key' => TREK_KEY, 'mode' => 'gentle', 'chapter' => $chapter, 'x' => $start['x'], 'y' => $start['y'],
        'camp' => null, 'inside' => 1, 'fatigue' => 0, 'sneak' => 0, 'petals_found' => 0, 'campkits' => $from ? max(0, (int)$from['campkits']) : 0, 'fight' => null, 'log' => '[]', 'state' => '{}',
        'xp_day' => null, 'xp_today' => 0, 'started' => now()]);
    $run = trek_load(q_one('SELECT * FROM trek_runs WHERE id = ?', [$rid]));
    $run['st']['turn'] = 1;
    db_insert('trek_party', ['run_id' => $rid, 'slot' => 0, 'crew_key' => 'gnome', 'hp' => 1]);
    $run['party'][0] = ['crew_key' => 'gnome', 'hp' => 1];
    $run['st']['tl'] = ['gnome' => [1, 0]];   // v1.8.9
    if ($from) {
        $run['st']['tl'] = (array)($from['st']['tl'] ?? $run['st']['tl']);
        if (!empty($from['st']['tac'])) $run['st']['tac'] = $from['st']['tac'];
        foreach (trek_recruits((int)$from['id']) as $k) {
            try { db_insert('trek_recruits', ['run_id' => $rid, 'crew_key' => $k]); } catch (PDOException $e) { /* there already */ }
        }
        foreach ($from['party'] as $slot => $p) {
            if ((int)$slot < 1) continue;
            db_insert('trek_party', ['run_id' => $rid, 'slot' => (int)$slot, 'crew_key' => $p['crew_key'], 'hp' => 1]);
            $run['party'][(int)$slot] = ['crew_key' => $p['crew_key'], 'hp' => 1];
        }
    }
    foreach (trek_party_stats($run, $u) as $slot => $m) $run['party'][$slot]['hp'] = $m['max'];
    trek_seen_reveal($run, $start['x'], $start['y'], 3);
    if ($chapter > 1) unlock_entries($uid, 'trek:ch' . $chapter);   // v1.9.2: the chapter's Almanac page
    trek_say($run, $chapter > 1 ? '🥾 You climb down, deeper than before.' : '🥾 You climb down into the crack.');
    return $run;
}

/** Start the trek (first time) or go back in (later): costs trek_entry_energy. [ok, message]. */
function trek_enter(?array &$run, array $u): array
{
    $uid = (int)$u['id'];
    [$ok, $why] = trek_gate($u);
    if (!$ok) return [false, $why];
    if ($run && (int)$run['inside'] === 1) return [true, ''];
    if ($why = trek_entry_blocker($u)) return [false, $why];
    $cost = max(0, (int)setting('trek_entry_energy'));
    if ($cost > 0 && !spend_energy($uid, $cost)) return [false, 'Not enough energy. A trek costs ' . $cost . ' to go in.'];
    if (!$run) {
        $ch = trek_active_ch($uid);
        if ($ch > 1 && !trek_chapter_exists($ch)) { $ch = 1; q('UPDATE users SET trek_ch = 1 WHERE id = ?', [$uid]); }   // (a chapter whose files are gone: start at the beginning)
        $prev = $ch > 1 ? trek_run_row($uid, $ch - 1) : null;   // (a reset chapter restarts with the party of the one before)
        $run = trek_new_run($u, $ch, $prev ? trek_load($prev) : null);
        return [true, ''];
    }
    $run['inside'] = 1;
    trek_say($run, '🥾 You step back in.');
    return [true, ''];
}

// ------------------------------------------------------------------ the interlude (between chapters)

/**
 * v1.9.1: the chapter is finished and the gnome is back in the Hollow's rest stop: everything carried is banked, the party is rested, the run is closed.
 * Safe to run again (it only acts if something is still inside or carried).
 */
function trek_hub_arrive(array &$run, array $u): void
{
    $run['inside'] = 0;
    $run['fi'] = null;
    $run['fatigue'] = 0;
    $run['st']['fh'] = 0;
    trek_heal_party($run, $u);
    foreach (trek_bank($run, $u) as $l) trek_say($run, $l);
    unset($run['st']['ev'], $run['st']['cm'], $run['st']['bless']);
}

/** Does a finished run still need to be brought to the interlude (still inside, or still carrying finds)? */
function trek_hub_pending(array $run): bool
{
    return trek_run_done($run) && ((int)$run['inside'] === 1 || (int)$run['petals_found'] > 0
        || (bool)q_val('SELECT 1 FROM trek_pack p JOIN items i ON i.id = p.item_id WHERE p.run_id = ? AND p.banked = 0 AND p.qty > 0 AND i.slug NOT IN (' . implode(', ', array_map(fn($q) => "'" . $q . "'", TREK_QUEST_ITEMS)) . ')', [$run['id']]));
}

/** Rest at the interlude: full health, no fatigue, bank anything left. */
function trek_hub_rest(array &$run, array $u): array
{
    if (!trek_in_hub($run)) return [false, 'Not now.'];
    trek_hub_arrive($run, $u);
    trek_say($run, '🛌 The party rests.');
    return [true, ''];
}

/** Talk to a trailmate you recruited: shows their line (st.talk); the first time, +1 friendship with them (once only, flag itlk_<crew>). */
function trek_hub_talk(array &$run, array $u, string $crewKey): array
{
    if (!trek_in_hub($run)) return [false, 'Not now.'];
    if (!in_array($crewKey, trek_recruits((int)$run['id']), true)) return [false, 'They aren’t with you.'];
    $run['st']['talk'] = $crewKey;
    if (!trek_flag($run, 'itlk_' . $crewKey)) {
        trek_flag_set($run, 'itlk_' . $crewKey);
        $npc = trek_crew_npc($crewKey);
        if ((int)$npc['id'] > 0) friend_add((int)$u['id'], (int)$npc['id'], 1);
    }
    return [true, ''];
}

/**
 * "Go down to the next chapter": from the interlude, start the next chapter's run with the party carried over, and make it the gnome's place.
 * The finished run is saved first and stays as a record (its Log and Milestones). Costs the normal entry energy. $run becomes the new run.
 */
function trek_godown(array &$run, array $u): array
{
    if (!trek_in_hub($run)) return [false, 'Not now.'];
    $uid = (int)$u['id'];
    $next = trek_next_chapter((int)$run['chapter']);
    if ($next === null) return [false, 'The next chapter is coming soon.'];
    if ($why = trek_entry_blocker($u)) return [false, $why];
    $cost = max(0, (int)setting('trek_entry_energy'));
    if ($cost > 0 && !spend_energy($uid, $cost)) return [false, 'Not enough energy. A trek costs ' . $cost . ' to go in.'];
    $old = $run;
    trek_save($old);
    $row = trek_run_row($uid, $next);
    if ($row) {   // already made (a second tap in another tab): just go there
        $run = trek_load($row);
        $run['inside'] = 1;
    } else {
        $run = trek_new_run($u, $next, $old);
    }
    q('UPDATE users SET trek_ch = ? WHERE id = ?', [$next, $uid]);
    return [true, ''];
}

/** Leave the trek where you stand (not mid-fight). Position and pack are kept. */
function trek_leave(array &$run): array
{
    if ($run['fi']) return [false, 'Finish the fight first.'];
    $run['inside'] = 0;
    trek_say($run, '🪜 You climb back up to the Hollow.');
    return [true, ''];
}

function trek_set_sneak(array &$run, bool $sneak): void
{
    $run['sneak'] = $sneak ? 1 : 0;
}

// ------------------------------------------------------------------ the map

/** Is this tile walkable? A locked gate only counts as a goal (so it can be bumped); a hidden spot is plain floor. */
function trek_passable(array $run, int $x, int $y, bool $goal = false): bool
{
    $ch = (int)$run['chapter'];
    $c = trek_tile($ch, $x, $y);
    if ($c === '#' || $c === '^' || $c === ' ' || $c === '*') return false;   // v1.9.2: a glow crystal is a lump in the way
    if ($c === 'w') return trek_flag($run, 'drained_' . trek_zone_at($ch, $x, $y));   // v1.9.2: high water, until a sluice of its zone is turned
    if ($c === '+') return !empty($run['wf']);   // v1.9.4: loose clay: a Wayfinder in the party can push through to a nook (set by trek_party_stats)
    if (ctype_upper($c) || ctype_digit($c)) {
        $s = trek_spot_at($ch, $x, $y);
        if ($s && $s['type'] === 'gate' && !trek_gate_open($run, $s)) return $goal;
    }
    return true;
}

function trek_gate_open(array $run, array $spot): bool
{
    $need = (string)($spot['data']['needs'] ?? '');
    return $need === '' || trek_flag($run, $need);
}

/** Shortest walk from the party to a tile: the list of tiles to step on (empty = no way). Fog does not matter, walls and locked gates do. */
function trek_path(array $run, int $tx, int $ty): array
{
    $m = trek_map((int)$run['chapter']);
    $sx = (int)$run['x'];
    $sy = (int)$run['y'];
    if (($sx === $tx && $sy === $ty) || !trek_passable($run, $tx, $ty, true)) return [];
    $w = $m['w'];
    $prev = [$sy * $w + $sx => -1];
    $queue = [$sy * $w + $sx];
    $goal = $ty * $w + $tx;
    for ($qi = 0; $qi < count($queue); $qi++) {
        $cur = $queue[$qi];
        if ($cur === $goal) break;
        $cx = $cur % $w;
        $cy = intdiv($cur, $w);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $cx + $dx;
            $ny = $cy + $dy;
            if ($nx < 0 || $ny < 0 || $nx >= $w || $ny >= $m['h']) continue;
            $k = $ny * $w + $nx;
            if (isset($prev[$k]) || !trek_passable($run, $nx, $ny, $k === $goal)) continue;
            $prev[$k] = $cur;
            $queue[] = $k;
        }
    }
    if (!isset($prev[$goal])) return [];
    $path = [];
    for ($k = $goal; $k !== -1 && $k !== $sy * $w + $sx; $k = $prev[$k]) array_unshift($path, [$k % $w, intdiv($k, $w)]);
    return $path;
}

/** Fatigue cost of stepping onto a tile, in halves: floor 1 (so 1 fatigue per 2 tiles), mud and roots 2 (1 per tile). */
function trek_step_cost(string $tile): int
{
    return $tile === '~' || $tile === '%' || $tile === ':' || $tile === 'w' ? 2 : 1;   // v1.9.2: wet clay and drained water cost like mud
}

/**
 * v2.0.18: does this spot BLOCK the way on until it is dealt with? A duel, a mini-boss, a boss, a stuck cart (always solvable: "dig it out slowly" works) and a riddle door
 * that gives way after its last try. Optional side stops (pass=1: the Mushroom Camp, the riddle stones) never block. Gates are handled by trek_gate_open().
 */
function trek_spot_blocks(array $run, array $spot): bool
{
    if (!in_array($spot['type'], ['duel', 'miniboss', 'boss', 'cart', 'riddle'], true)) return false;
    if ($spot['type'] === 'riddle' && empty($spot['data']['failopen'])) return false;
    return !trek_spot_done($run, $spot);
}

/** Steps from the chapter's start to every tile the party could reach (index y * w + x), counting locked gates and walls as shut. */
function trek_dist_from_start(array $run): array
{
    $ch = (int)$run['chapter'];
    $m = trek_map($ch);
    $st = trek_spots($ch)['start'] ?? null;
    if (!$st) return [];
    $w = $m['w'];
    $dist = [(int)$st['y'] * $w + (int)$st['x'] => 0];
    $queue = [(int)$st['y'] * $w + (int)$st['x']];
    for ($qi = 0; $qi < count($queue); $qi++) {
        $cur = $queue[$qi];
        $cx = $cur % $w;
        $cy = intdiv($cur, $w);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) {
            $nx = $cx + $dx;
            $ny = $cy + $dy;
            if ($nx < 0 || $ny < 0 || $nx >= $w || $ny >= $m['h']) continue;
            $k = $ny * $w + $nx;
            if (isset($dist[$k]) || !trek_passable($run, $nx, $ny)) continue;
            $dist[$k] = $dist[$cur] + 1;
            $queue[] = $k;
        }
    }
    return $dist;
}

/**
 * v2.0.18: standing ON a blocking spot that is not dealt with (you backed out of its fight, text or pop-over, fled, reloaded), the only way off is back toward the start,
 * never on past it. Returns the reason ('' = free to go). Dealing with the spot sets its flag and lifts this.
 */
function trek_blocker_hold(array $run, array $first): string
{
    $spot = trek_spot_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']);
    if (!$spot || !trek_spot_blocks($run, $spot)) return '';
    $m = trek_map((int)$run['chapter']);
    $dist = trek_dist_from_start($run);
    $here = (int)$run['y'] * $m['w'] + (int)$run['x'];
    if (!isset($dist[$here])) return '';   // arrived some other way (a slide): nothing to measure against
    if (($dist[$first[1] * $m['w'] + $first[0]] ?? PHP_INT_MAX) < $dist[$here]) return '';
    return $spot['name'] . ' blocks the way on. Deal with it, or step back the way you came.';
}

/** Has this spot been dealt with? (its flag, or "seen_<code>" for spots with none; the camp counts once reached) */
function trek_spot_done(array $run, array $spot): bool
{
    if ($spot['type'] === 'camp') return trek_flag($run, trek_camp_flag($spot));
    return trek_flag($run, (string)($spot['data']['flag'] ?? 'seen_' . $spot['code']));
}

/** v1.9.4: the "reached" flag of a camp spot: its data flag= (the Brewhouse: camp2_seen), else camp_seen (Chapter I's Lantern Stump and II-a's Tin Lamp, as always). */
function trek_camp_flag(array $spot): string
{
    return (string)($spot['data']['flag'] ?? 'camp_seen');
}

/** The next spot of the chapter's story path (the "!" marker): the lowest obj= not yet done. */
function trek_objective(array $run): ?array
{
    $best = null;
    foreach (trek_spots((int)$run['chapter']) as $s) {
        if (!isset($s['data']['obj']) || trek_spot_done($run, $s)) continue;
        if (!$best || (int)$s['data']['obj'] < (int)$best['data']['obj']) $best = $s;
    }
    return $best;
}

/** Is a hidden spot showing? Only with a Wayfinder in the party. */
function trek_spot_visible(array &$run, array $u, array $spot): bool
{
    return empty($spot['data']['wayfinder']) || trek_has_wayfinder($run, $u);
}

/** The pool of foes for a zone and the chance multiplier, or null. */
function trek_zone_pool(string $zone, int $chapter = 1): ?array
{
    return trek_pools()[$chapter . ':' . $zone] ?? null;
}

/** Chance (percent, with decimals) of a fight on the next step. */
function trek_enc_chance(array $run, string $zone): float
{
    $ch = (int)$run['chapter'];
    $pool = trek_zone_pool($zone, $ch);
    if (!$pool || $pool['mult'] <= 0 || !$pool['list']) return 0.0;
    $pct = (float)setting('trek_enc_percent') * $pool['mult'] / 100;
    if (!empty(trek_chapter($ch)['zones'][$zone]['first30']) && !trek_flag($run, 'won_fight')) $pct = max($pct, 30.0);   // the tutorial: the first fight finds you quickly
    if (!empty($run['sneak'])) $pct *= max(0, (int)setting('trek_sneak_mult_pct')) / 100;
    if ((int)$run['fatigue'] >= 85) $pct *= 1.5;
    return min(100.0, $pct);
}

/**
 * Walk toward a tile, one step at a time, until: the target, an encounter, a spot with something to do, a locked gate,
 * 100 fatigue or TREK_MAX_STEPS. Returns [ok, message]; the story goes in the log.
 */
function trek_walk(array &$run, array $u, int $tx, int $ty): array
{
    if ($run['fi']) return [false, 'You’re in a fight.'];
    if (!(int)$run['inside']) return [false, 'You’re not on the trek.'];
    if (!trek_seen_get($run, $tx, $ty)) return [false, 'You can’t see that far yet.'];
    if ((int)$run['fatigue'] >= 100) return [false, 'Everyone is worn out. Make camp first.'];
    trek_party_stats($run, $u);   // v1.9.4: refreshes $run['wf'] (loose clay needs a Wayfinder)
    $path = trek_path($run, $tx, $ty);
    if (!$path) {
        $ch = (int)$run['chapter'];
        $c = trek_tile($ch, $tx, $ty);
        if ($c === 'w') return [false, 'High water. Somewhere near, a sluice wheel will drain it.'];
        if ($c === '+' || trek_near_tile($ch, $tx, $ty, '+')) { trek_say_text($run, 'ch' . $ch . '.ui.loose'); return [false, 'The clay is loose here. Something is tucked behind it, and a Wayfinder would find the way in.']; }   // v1.9.4
        return [false, ($c === '#' || $c === '^' || $c === '*') ? 'That way is blocked.' : 'There’s no way there from here (yet).'];
    }
    if ($why = trek_blocker_hold($run, $path[0])) return [false, $why];   // v2.0.18: no walking on past a blocker you backed out of
    $ch = (int)$run['chapter'];
    $steps = 0;
    $half = (int)($run['st']['fh'] ?? 0);
    unset($run['st']['ev']);   // v1.8.8: walking on leaves a trail event behind
    trek_crew_walk($run);
    $walked = [[(int)$run['x'], (int)$run['y']]];   // v1.8.10: the tiles actually stepped on, for the map's walk animation
    foreach ($path as [$x, $y]) {
        $tile = trek_tile($ch, $x, $y);
        $spot = (ctype_upper($tile) || ctype_digit($tile)) ? trek_spot_at($ch, $x, $y) : null;
        if ($spot && $spot['type'] === 'gate' && !trek_gate_open($run, $spot)) {   // bumped a locked gate: stand next to it and say why
            trek_say_text($run, 'ch' . $ch . '.spot.' . $spot['code'] . '.locked');
            if (!empty($spot['data']['ms']) && empty($spot['data']['noopen']) && !trek_flag($run, 'reached_' . $spot['code'])) {   // v1.9.2: a gate that is only reached (v2.0.1: not the Crossroads, which pays only when you go through) (the Crossroads in II-a) pays its milestone
                trek_flag_set($run, 'reached_' . $spot['code']);
                trek_ms_award($run, $u, (string)$spot['data']['ms']);
            }
            break;
        }
        if ($spot && $spot['type'] === 'hidden' && !trek_spot_visible($run, $u, $spot)) $spot = null;   // plain floor without a Wayfinder
        $before = (int)$run['fatigue'];
        $run['x'] = $x;
        $run['y'] = $y;
        $walked[] = [$x, $y];
        $half += trek_step_cost($tile);
        while ($half >= 2) { $run['fatigue'] = (int)$run['fatigue'] + 1; $half -= 2; }
        $steps++;
        trek_seen_reveal($run, $x, $y, 2);
        foreach ([[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]] as [$cdx, $cdy]) {   // v1.9.2: a glow crystal beside you lights the fog around it
            if (trek_tile($ch, $x + $cdx, $y + $cdy) === '*') trek_seen_reveal($run, $x + $cdx, $y + $cdy, 4);
        }
        if ($before < 60 && (int)$run['fatigue'] >= 60) trek_say_text($run, 'ch' . $ch . '.ui.tired');
        if ($before < 85 && (int)$run['fatigue'] >= 85) trek_say_text($run, 'ch' . $ch . '.ui.wornout');
        $zone = trek_zone_at($ch, $x, $y);
        trek_zone_enter($run, $zone);
        $isGoal = $x === $tx && $y === $ty;
        if ($spot) {
            if ($spot['type'] === 'gate') {
                if (!trek_flag($run, 'gateopen_' . $spot['code'])) {
                    trek_flag_set($run, 'gateopen_' . $spot['code']);
                    if (!empty($spot['data']['needs']) && empty($spot['data']['noopen'])) {
                        $who = preg_match('/^freed_(\w+)$/', (string)$spot['data']['needs'], $wm) ? $wm[1] : '';   // v2.0.4: "Burdock shoves it" only when Burdock is in the party; benched, a plain line
                        if ($who !== '' && !trek_in_party($run, $who)) trek_say($run, '🚪 ' . $spot['name'] . ' gives way. The way on is open.');
                        else trek_say_text($run, 'ch' . $ch . '.spot.' . $spot['code'] . '.open');
                    }   // (a gate that was never locked, the Crossroads since II-b, has no "it opens" line: the milestone card says it)
                    if (!empty($spot['data']['ms']) && !trek_flag($run, 'reached_' . $spot['code'])) {   // v1.9.4: a gate that is open from the start (the Crossroads since II-b) pays its milestone the first time you go through
                        trek_flag_set($run, 'reached_' . $spot['code']);
                        trek_ms_award($run, $u, (string)$spot['data']['ms']);
                    }
                }
            } elseif (trek_spot_stops($run, $u, $spot, $isGoal)) {
                break;
            }
        } elseif ((int)$run['fatigue'] < 100) {
            if (trek_step_extras($run, $u, $zone)) break;   // v1.8.8: a crew moment or a trail event (instead of the fight roll)
            if (($enc = trek_enc_chance($run, $zone)) > 0 && random_int(1, 100000) <= (int)round($enc * 1000)) {
                trek_start_random_fight($run, $u, $zone);
                break;
            }
        }
        if ((int)$run['fatigue'] >= 100) { trek_say($run, '😮‍💨 Everyone is worn out. Time to make camp.'); break; }
        if ($steps >= TREK_MAX_STEPS) break;
    }
    $run['st']['fh'] = $half;
    if (count($walked) > 1 && session_status() === PHP_SESSION_ACTIVE) $_SESSION['trek_walk'] = ['run' => (int)$run['id'], 't' => time(), 'p' => array_slice($walked, -41), 'd' => [$tx, $ty]];   // v1.8.10: one-shot, read by trek_walk_take()
    return [true, ''];
}

/** The first time into a zone: its description (and its hint line, if the zone has the hint flag). Safe to call for every step. */
function trek_zone_enter(array &$run, string $zone): void
{
    $ch = (int)$run['chapter'];
    if ($zone === '' || !isset(trek_chapter($ch)['zones'][$zone]) || trek_flag($run, 'zone_' . $zone)) return;
    trek_flag_set($run, 'zone_' . $zone);
    trek_say_text($run, 'ch' . $ch . '.zone.' . $zone . '.arrive');
    if (!empty(trek_chapter($ch)['zones'][$zone]['hint'])) trek_say_text($run, 'ch' . $ch . '.zone.' . $zone . '.hint');
}

/** Is there a tile of this kind right next to (x, y)? */
function trek_near_tile(int $ch, int $x, int $y, string $tile): bool
{
    foreach ([[1, 0], [-1, 0], [0, 1], [0, -1]] as [$dx, $dy]) if (trek_tile($ch, $x + $dx, $y + $dy) === $tile) return true;
    return false;
}

/** Stepping onto a spot: does the walk stop here? Also marks spots with no flag as seen, and rests at a camp. */
function trek_spot_stops(array &$run, array $u, array $spot, bool $isGoal): bool
{
    switch ($spot['type']) {
        case 'camp':
            if (!$isGoal && trek_flag($run, trek_camp_flag($spot))) return false;
            trek_camp_arrive($run, $u, $spot);
            return true;
        case 'start':
        case 'exit':
            return $isGoal;
        case 'oldcamp':   // v2.0.1: stops the walk the first time (its card shows the find text), then it is just a place you pass
            $first = !trek_flag($run, 'seen_' . $spot['code']);
            trek_flag_set($run, 'seen_' . $spot['code']);
            return $first || $isGoal;
        case 'npc':
        case 'sign':
            $first = !trek_flag($run, 'seen_' . $spot['code']);
            trek_flag_set($run, 'seen_' . $spot['code']);
            if (!empty($spot['data']['entry'])) unlock_entries((int)$u['id'], (string)$spot['data']['entry']);   // v1.9.2: a reading nook that adds an Almanac page
            return $first || $isGoal;
        default:
            if (trek_spot_blocks($run, $spot)) return true;   // v2.0.18: a blocker stops the walk every time (the cart used to halt it only once, via pass=1)
            if (!empty($spot['data']['pass'])) {   // v1.8.8: a stop on the way: it halts the walk the first time only
                $first = !trek_flag($run, 'seen_' . $spot['code']);
                trek_flag_set($run, 'seen_' . $spot['code']);
                return $first || $isGoal;
            }
            return $isGoal || !trek_spot_done($run, $spot);
    }
}

// ------------------------------------------------------------------ camps

/** Arriving at a camp spot: full rest, fatigue 0, remember it, bank everything carried, and the first Camp Kit is free. */
function trek_camp_arrive(array &$run, array $u, array $spot): void
{
    $ch = (int)$run['chapter'];
    $cf = trek_camp_flag($spot);   // v1.9.4: a second camp has its own flag
    $first = !trek_flag($run, $cf);
    $run['camp'] = $spot['code'];
    trek_flag_set($run, $cf);
    if ($first && !empty($spot['data']['entry'])) unlock_entries((int)$u['id'], (string)$spot['data']['entry']);   // v1.9.4: the Brewhouse's Almanac page
    $run['fatigue'] = 0;
    $run['st']['fh'] = 0;
    trek_heal_party($run, $u);
    $lines = trek_bank($run, $u);
    if ($first && !trek_flag($run, 'firstkit')) {
        trek_flag_set($run, 'firstkit');
        if ($ch === 1) {   // v1.9.2: the free first kit, the camp lesson and the Lantern Stump page are Chapter I's; a later chapter's first camp is just a camp
            $max = max(0, (int)setting('trek_campkit_max'));
            if ((int)$run['campkits'] < $max) {
                $run['campkits'] = (int)$run['campkits'] + 1;
                trek_say_text($run, 'ch' . $ch . '.camp.innkeeper.firstkit');
            } else {   // v1.9.9: already carrying the most: the free kit is not thrown away, it goes to the satchel like a chest's overflow
                give_item((int)$u['id'], trek_item_id('camp-kit'), 1);
                trek_say_text($run, 'ch' . $ch . '.camp.innkeeper.firstkit');
                trek_say($run, '🏕️ You already carry the most Camp Kits: the free one goes in your satchel.');
            }
            trek_say_text($run, 'ch' . $ch . '.tut.camp');
            unlock_entries((int)$u['id'], 'trek:lantern-stump');
        }
    }
    foreach ($lines as $l) trek_say($run, $l);
    trek_say_text($run, trek_camp_key($ch, $spot, 'rest'));
}

/** v1.9.4: the text key for a camp's keeper line (greet, shop, rest). A camp with keeper=<piece> in its spot data has its own (ch2.camp.cook.greet); the others use the innkeeper's. */
function trek_camp_key(int $ch, ?array $spot, string $part): string
{
    $k = (string)($spot['data']['keeper'] ?? '');
    return 'ch' . $ch . '.camp.' . ($k !== '' && trek_text_written_or_slot('ch' . $ch . '.camp.' . $k . '.' . $part) ? $k : 'innkeeper') . '.' . $part;
}

/** Does this key exist as a slot (written or not)? */
function trek_text_written_or_slot(string $key): bool
{
    return isset(trek_text_rows()[$key]);
}

/** Move everything carried into the satchel (quest items stay) and the found Petals into the purse. Returns log lines. */
function trek_bank(array &$run, array $u): array
{
    $uid = (int)$u['id'];
    $lines = [];
    $got = [];
    foreach (q('SELECT item_id, qty FROM trek_pack WHERE run_id = ? AND banked = 0 AND qty > 0', [$run['id']])->fetchAll() as $r) {
        $iid = (int)$r['item_id'];
        if (trek_is_quest_item($iid)) continue;
        if (!trek_pack_take((int)$run['id'], $iid, (int)$r['qty'])) continue;
        give_item($uid, $iid, (int)$r['qty']);
        trek_pack_add((int)$run['id'], $iid, (int)$r['qty'], 1);
        $got[] = (int)$r['qty'] . ' × ' . trek_item_name($iid);
    }
    if ($got) $lines[] = '🎒 Banked in your satchel: ' . implode(', ', $got) . '.';
    $p = (int)$run['petals_found'];
    if ($p > 0) {
        q('UPDATE users SET coins = coins + ? WHERE id = ?', [$p, $uid]);
        $run['petals_found'] = 0;
        $run['st']['petals_banked'] = (int)($run['st']['petals_banked'] ?? 0) + $p;
        $lines[] = '🪙 Banked ' . $p . ' ' . setting('currency_name') . '.';
    }
    return $lines;
}

/** The camp spot the party stands on, or null. */
function trek_here_camp(array $run): ?array
{
    $s = trek_spot_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']);
    return $s && $s['type'] === 'camp' ? $s : null;
}

/** On a camp tile, or in the interlude (which is a camp): kit shop and party swaps work. */
function trek_at_camp(array $run): bool
{
    return trek_here_camp($run) !== null || trek_in_hub($run);
}

/** Rest at the camp you are standing on (again). [ok, message] */
function trek_camp_rest(array &$run, array $u): array
{
    if (trek_in_hub($run)) return trek_hub_rest($run, $u);
    $camp = trek_here_camp($run);
    if (!$camp || $run['fi']) return [false, 'You need to be at a camp.'];
    trek_camp_arrive($run, $u, $camp);
    return [true, ''];
}

/** Buy one Camp Kit at a camp. */
function trek_buy_kit(array &$run, array $u): array
{
    if (!trek_at_camp($run) || $run['fi']) return [false, 'Kits are sold at a camp.'];
    $ch = (int)$run['chapter'];
    if ((int)$run['campkits'] >= max(0, (int)setting('trek_campkit_max'))) { trek_say_text($run, trek_camp_key($ch, trek_here_camp($run), 'full')); return [true, '']; }
    $price = max(0, (int)setting('trek_campkit_price'));
    if ($price > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$price, $u['id'], $price])->rowCount() !== 1) {
        trek_say_text($run, trek_camp_key($ch, trek_here_camp($run), 'nofunds'));
        return [false, 'Not enough ' . setting('currency_name') . '.'];
    }
    $run['campkits'] = (int)$run['campkits'] + 1;
    trek_say($run, '🏕️ You buy a Camp Kit (−' . $price . ' ' . setting('currency_name') . ').');
    return [true, ''];
}

/** What a rest anywhere does: fatigue -50, everyone heals half their health. */
function trek_apply_rest(array &$run, array $u, bool $cold = false): void
{
    $fat = $cold ? trek_cold_rest_fatigue() : 50;
    $run['fatigue'] = max(0, (int)$run['fatigue'] - $fat);
    $run['st']['fh'] = 0;
    trek_heal_party($run, $u, $cold ? 25 : 50);
}

/** v1.9.4: fatigue a cold rest (no kit) takes off. */
function trek_cold_rest_fatigue(): int
{
    return max(0, min(100, (int)setting('trek_cold_rest_fatigue')));
}

/** Make camp where you stand: with a Camp Kit, a good rest; without, free but maybe an ambush first (the rest comes after the fight). */
function trek_make_camp(array &$run, array $u): array
{
    if ($run['fi'] || !(int)$run['inside']) return [false, 'Not now.'];
    $ch = (int)$run['chapter'];
    $hurt = false;   // v1.9.9: a second tap (or a tap on a rested party) must not burn a kit, or draw an ambush, for nothing
    foreach (trek_party_stats($run, $u) as $s => $mm) if ((int)$run['party'][$s]['hp'] < (int)$mm['max']) $hurt = true;
    if ((int)$run['fatigue'] <= 0 && !$hurt) return [false, 'Everyone is rested already. Keep the kit for later.'];
    if ((int)$run['campkits'] > 0) {
        $run['campkits'] = (int)$run['campkits'] - 1;
        trek_apply_rest($run, $u);
        trek_say_text($run, 'ch' . $ch . '.camp.makecamp');
        trek_say($run, '🏕️ Camp Kit used. Fatigue −50, everyone heals half their health.');
        return [true, ''];
    }
    $zone = trek_zone_at($ch, (int)$run['x'], (int)$run['y']);
    $spot = trek_spot_at($ch, (int)$run['x'], (int)$run['y']);
    if (random_int(1, 100) <= max(0, (int)setting('trek_ambush_pct')) && !$spot && trek_zone_pool($zone, $ch) && trek_zone_pool($zone, $ch)['list']) {
        trek_say_text($run, 'ch' . $ch . '.camp.ambush');
        trek_start_random_fight($run, $u, $zone, 'rest');
        return [true, ''];
    }
    trek_apply_rest($run, $u, true);
    trek_say_text($run, 'ch' . $ch . '.camp.makecamp.free');
    trek_say($run, '🏕️ A cold rest. Fatigue −' . trek_cold_rest_fatigue() . ', everyone heals a quarter of their health.');
    return [true, ''];
}

// ------------------------------------------------------------------ knock-out

/** Everyone is down: back to the last camp (or the start), healed, fatigue 50. Past the first camp, carried finds are partly lost. */
function trek_ko(array &$run, array $u): void
{
    $ch = (int)$run['chapter'];
    $spots = trek_spots($ch);
    $oc = trek_oldcamp_ko_spot($run);   // v2.0.1: an old campsite rested at, further along than the last camp
    $spot = $oc ?: (($run['camp'] && isset($spots[$run['camp']])) ? $spots[$run['camp']] : $spots['start']);
    $tutorial = $run['camp'] === null || $run['camp'] === '';
    $run['st']['kos'] = (int)($run['st']['kos'] ?? 0) + 1;   // v1.8.9: a milestone check ("no knock-out so far")
    $run['fi'] = null;
    unset($run['st']['ev']);   // v1.9.9: an event card from where the party fell does not follow it back to camp
    $run['x'] = $spot['x'];
    $run['y'] = $spot['y'];
    trek_heal_party($run, $u);
    $run['fatigue'] = 50;
    $run['st']['fh'] = 0;
    trek_seen_reveal($run, $spot['x'], $spot['y'], 2);
    if ($tutorial) {
        if (!$oc) trek_say_text($run, 'ch' . $ch . '.ko.tutorial');   // v2.0.4: at an old campsite the log line below says it (the oldcamp text says "may be gone", which is not true before the first camp)
        trek_say($run, $oc ? '💫 You wake at the old campsite. Nothing was lost this time.' : '💫 You wake at the start. Nothing was lost this time.');
        return;
    }
    trek_say_text($run, 'ch' . $ch . ($oc ? '.ko.oldcamp' : '.ko.camp'));
    $pct = max(0, min(100, (int)setting('trek_ko_loss_pct')));
    $lost = [];
    foreach (q('SELECT item_id, qty FROM trek_pack WHERE run_id = ? AND banked = 0 AND qty > 0', [$run['id']])->fetchAll() as $r) {
        $iid = (int)$r['item_id'];
        if (trek_is_quest_item($iid)) continue;
        $qty = (int)$r['qty'];
        $take = $qty === 1 ? (random_int(1, 100) <= $pct ? 1 : 0) : intdiv($qty * $pct, 100);   // a single one is a coin toss; stacks lose a share, rounded down
        if ($take > 0 && trek_pack_take((int)$run['id'], $iid, $take)) $lost[] = $take . ' × ' . trek_item_name($iid);
    }
    $p = (int)$run['petals_found'];
    if ($p > 0 && $pct > 0) {
        $take = intdiv($p * $pct, 100);
        if ($take > 0) { $run['petals_found'] = $p - $take; $lost[] = $take . ' ' . setting('currency_name'); }
    }
    trek_say($run, $lost ? '💫 Knocked out. You lost: ' . implode(', ', $lost) . '.' : '💫 Knocked out. You kept everything you carried.');
}

// ------------------------------------------------------------------ spots you can act on

/** The spot the party stands on (a hidden one only with a Wayfinder), or null. */
function trek_here(array &$run, array $u): ?array
{
    $s = trek_spot_at((int)$run['chapter'], (int)$run['x'], (int)$run['y']);
    if ($s && $s['type'] === 'hidden' && !trek_spot_visible($run, $u, $s)) return null;
    return $s;
}

/**
 * Take a trailmate on: they join the party (if a slot is free), you become Acquaintance with them at least.
 * v2.0.7: returns false only when they joined the bench because all 3 places were taken (the caller then says so); true otherwise.
 */
function trek_recruit_crew(array &$run, array $u, string $crewKey): bool
{
    $crew = trek_crew()[$crewKey] ?? null;
    if (!$crew) return true;
    $rid = (int)$run['id'];
    try { db_insert('trek_recruits', ['run_id' => $rid, 'crew_key' => $crewKey]); } catch (PDOException $e) { return true; }
    $placed = false;
    trek_tl_join($run, $crewKey);   // v1.8.9: joins at the party's average trek level - 2 (at least 1)
    foreach ([1, 2, 3] as $slot) {
        if (isset($run['party'][$slot])) continue;
        db_insert('trek_party', ['run_id' => $rid, 'slot' => $slot, 'crew_key' => $crewKey, 'hp' => 1]);
        $run['party'][$slot] = ['crew_key' => $crewKey, 'hp' => 1];
        $run['party'][$slot]['hp'] = trek_party_stats($run, $u)[$slot]['max'];
        $placed = true;
        break;
    }
    $npc = trek_crew_npc($crewKey);
    if ((int)$npc['id'] > 0) {   // mentors are normal npcs rows: friendship works the same
        $have = (int)friendship((int)$u['id'], (int)$npc['id'])['points'];
        if ($have < 20) friend_add((int)$u['id'], (int)$npc['id'], 20 - $have);
        unlock_entries((int)$u['id'], 'npc:' . $npc['slug']);
    }
    return $placed;
}

/** v2.0.7: the log line for a trailmate who joined but found the party full. */
function trek_benched_line(string $npcName): string
{
    return '🧑‍🤝‍🧑 ' . trek_first_name_of($npcName) . ' waits with the other Trailmates: your party is full. Swap them in at a camp (Party tab).';
}

/** Free Burdock (recruit spot). */
function trek_act_recruit(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'recruit' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    if (!empty($s['data']['needs']) && !trek_flag($run, (string)$s['data']['needs'])) {   // v1.9.4: Tumble waits for the signpost to be sorted out
        trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.locked');
        return [false, 'Not yet. Something here needs sorting out first.'];
    }
    $npc = trek_crew_npc((string)$s['data']['crew']);
    trek_flag_set($run, (string)$s['data']['flag']);
    $in = trek_recruit_crew($run, $u, (string)$s['data']['crew']);
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.freed', ['trailmate' => $npc['name']]);
    if (!$in) trek_say($run, trek_benched_line((string)$npc['name']));
    trek_scene_recruit($run, $u, (string)$s['data']['crew'], 'ch' . $run['chapter'] . '.scene.' . $s['data']['crew'] . '.me', $in);   // v2.0.9
    if (!empty($s['data']['entry'])) unlock_entries((int)$u['id'], (string)$s['data']['entry']);   // v1.9.4
    trek_ms_award($run, $u, (string)($s['data']['ms'] ?? 'burdock'));
    return [true, ''];
}

/** Hand over the items a fetch spot needs (Clean Dew for Zinnia): she joins. */
function trek_act_fetch(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'fetch' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    [$slug, $qty] = array_pad(explode(':', (string)$s['data']['need'], 2), 2, '1');
    $iid = trek_item_id($slug);
    if (!$iid || trek_pack_qty((int)$run['id'], $iid) < (int)$qty) {
        trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.need');
        return [false, 'You need ' . (int)$qty . ' × ' . trek_item_name($iid) . ' in your pack.'];
    }
    trek_pack_take((int)$run['id'], $iid, (int)$qty);
    $npc = trek_crew_npc((string)$s['data']['crew']);
    trek_flag_set($run, (string)$s['data']['flag']);
    $in = trek_recruit_crew($run, $u, (string)$s['data']['crew']);
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.join', ['trailmate' => $npc['name']]);
    if (!$in) trek_say($run, trek_benched_line((string)$npc['name']));
    trek_scene_recruit($run, $u, (string)$s['data']['crew'], 'ch' . $run['chapter'] . '.scene.' . $s['data']['crew'] . '.me', $in);   // v2.0.9
    if (!empty($s['data']['entry'])) unlock_entries((int)$u['id'], (string)$s['data']['entry']);   // v1.9.4
    trek_ms_award($run, $u, (string)($s['data']['ms'] ?? 'zinnia'));
    return [true, ''];
}

/** Add Camp Kits (up to the carry limit; the rest go to the satchel as items). Returns a log line. */
function trek_give_kits(array &$run, array $u, int $n): string
{
    $room = max(0, (int)setting('trek_campkit_max') - (int)$run['campkits']);
    $carry = min($room, $n);
    $run['campkits'] = (int)$run['campkits'] + $carry;
    $over = $n - $carry;
    if ($over > 0) give_item((int)$u['id'], trek_item_id('camp-kit'), $over);
    return '🏕️ ' . $n . ' × Camp Kit' . ($over > 0 ? ' (' . $over . ' in your satchel, you carry ' . (int)setting('trek_campkit_max') . ' at most)' : '') . '.';
}

/** Open the Old Gnome Cellar chest with the Cellar Key. */
function trek_act_chest(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'chest' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    $key = trek_item_id((string)$s['data']['needs']);
    if (!$key || !trek_pack_take((int)$run['id'], $key, 1)) {
        trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.locked');
        return [false, 'You need the ' . trek_item_name($key) . '.'];
    }
    trek_flag_set($run, (string)$s['data']['flag']);
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.open');
    [$slug, $qty] = array_pad(explode(':', (string)($s['data']['item'] ?? 'camp-kit:1'), 2), 2, '1');
    if ($slug === 'camp-kit') trek_say($run, trek_give_kits($run, $u, (int)$qty));
    $petals = (int)($s['data']['petals'] ?? 0);
    if ($petals > 0) { $run['petals_found'] = (int)$run['petals_found'] + $petals; trek_say($run, '🪙 ' . $petals . ' ' . setting('currency_name') . ' (carried: bank them at a camp).'); }
    return [true, ''];
}

/**
 * Answer a riddle: 2 tries in all (v2.0.1; was 3). v1.9.2: a riddle may have no prize item (a door), may be answered by a Seedkeeper in the party instead ($how = 'seed', data
 * seedkeeper=1), and may open anyway after the last wrong answer (data failopen=1: "the clay gives way"; the flag in data open= is set, but the "solved" flag is not).
 */
function trek_act_riddle(array &$run, array $u, int $answer, string $how = ''): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'riddle' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    $ch = (int)$run['chapter'];
    $key = fn(string $part) => 'ch' . $ch . '.spot.' . $s['code'] . '.' . $part;
    $solved = (string)($s['data']['solved'] ?? $s['data']['flag']);
    if ($how === 'seed') {
        if (empty($s['data']['seedkeeper']) || !trek_has_calling($run, $u, 'seedkeeper')) return [false, 'Nobody in the party can read this.'];
        trek_flag_set($run, $solved);
        trek_flag_set($run, (string)$s['data']['flag']);
        trek_say_text($run, $key('seed'));
        return [true, ''];
    }
    $tries = (int)($run['st']['tries_' . $s['code']] ?? 0);
    $max = max(1, (int)($s['data']['tries'] ?? 2));
    if ($tries >= $max) return [false, 'No tries left.'];
    $run['st']['tries_' . $s['code']] = ++$tries;
    if ($answer === (int)$s['data']['right']) {
        trek_flag_set($run, $solved);
        trek_flag_set($run, (string)$s['data']['flag']);
        trek_say_text($run, $key('right'));
        if (!empty($s['data']['item'])) {
            [$slug, $qty] = array_pad(explode(':', (string)$s['data']['item'], 2), 2, '1');
            $iid = trek_item_id($slug);
            if ($iid) trek_pack_add((int)$run['id'], $iid, (int)$qty);   // TODO: Lanternroot is only an item for now (no crop yet)
            trek_say($run, '🎁 You receive ' . (int)$qty . ' × ' . trek_item_name($iid) . ' (carried).');
        }
        return [true, ''];
    }
    trek_say_text($run, $key($tries >= $max ? 'out' : 'wrong'));
    if ($tries >= $max && !empty($s['data']['failopen'])) trek_flag_set($run, (string)$s['data']['flag']);   // the clay gives way
    return [true, ''];
}

/** v2.0.1: riddle doors (failopen) whose tries are used up but whose way never opened (a run saved when riddles had 3 tries). */
function trek_riddle_stuck(array $run): bool
{
    foreach (trek_spots((int)$run['chapter']) as $s) {
        if ($s['type'] !== 'riddle' || empty($s['data']['failopen'])) continue;
        if ((int)($run['st']['tries_' . $s['code']] ?? 0) >= max(1, (int)($s['data']['tries'] ?? 2)) && !trek_flag($run, (string)$s['data']['flag'])) return true;
    }
    return false;
}

function trek_riddle_heal(array &$run): void
{
    foreach (trek_spots((int)$run['chapter']) as $s) {
        if ($s['type'] !== 'riddle' || empty($s['data']['failopen'])) continue;
        if ((int)($run['st']['tries_' . $s['code']] ?? 0) >= max(1, (int)($s['data']['tries'] ?? 2))) trek_flag_set($run, (string)$s['data']['flag']);
    }
}

/** v2.0.1: the item flavour text (item.<slug>) for each reward item that has one, as small centred notes. */
function trek_item_notes(array $slugs): string
{
    $h = '';
    foreach ($slugs as $slug) {
        if (is_string($slug) && isset(trek_text_rows()['item.' . $slug])) $h .= '<div class="trektext small tkitemnote">' . trek_text('item.' . $slug) . '</div>';
    }
    return $h;
}

/** Is there a living-or-not member of this calling in the party (the gnome's own calling counts)? */
function trek_has_calling(array &$run, array $u, string $calling): bool
{
    foreach (trek_party_stats($run, $u) as $m) if ($m['calling'] === $calling) return true;
    return false;
}

/** v1.9.2: turn a sluice wheel: the zone's high water drains (flag drained_<zone>), once. */
function trek_act_switch(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'switch' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    trek_flag_set($run, (string)$s['data']['flag']);
    trek_flag_set($run, 'drained_' . $s['zone']);
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.done');
    trek_add_fatigue($run, 2);
    trek_say($run, '⚙️ The water drains away. The way on is open (wet mud now). Fatigue +2.');
    return [true, ''];
}

/** v1.9.2: a free rest on a spot (once): fatigue -50 and half health back, like a Camp Kit. */
function trek_act_rest(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'rest' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    trek_flag_set($run, (string)$s['data']['flag']);
    trek_apply_rest($run, $u);
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.done');
    trek_say($run, '🛋️ A good sit. Fatigue −50, everyone heals half their health.');
    return [true, ''];
}

/**
 * v1.9.2: a side job that swaps carried goods for a prize: need=slug:qty, give=slug:qty, optional petals= and xp=. (The Potter's wheel: wet clay for a Clay Pot.)
 */
function trek_act_trade(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'trade' || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    $ch = (int)$run['chapter'];
    [$slug, $qty] = array_pad(explode(':', (string)$s['data']['need'], 2), 2, '1');
    $iid = trek_item_id($slug);
    if (!$iid || trek_pack_qty((int)$run['id'], $iid) < (int)$qty) {
        trek_say_text($run, 'ch' . $ch . '.spot.' . $s['code'] . '.short');
        return [false, 'You need ' . (int)$qty . ' × ' . trek_item_name($iid) . ' in your pack.'];
    }
    trek_pack_take((int)$run['id'], $iid, (int)$qty);
    trek_flag_set($run, (string)$s['data']['flag']);
    trek_say_text($run, 'ch' . $ch . '.spot.' . $s['code'] . '.done');
    [$gs, $gq] = array_pad(explode(':', (string)($s['data']['give'] ?? ''), 2), 2, '1');
    $gid = $gs !== '' ? trek_item_id($gs) : 0;
    if ($gid) { trek_pack_add((int)$run['id'], $gid, (int)$gq); trek_say($run, '🎁 You receive ' . (int)$gq . ' × ' . trek_item_name($gid) . ' (carried).'); }
    if ((int)($s['data']['petals'] ?? 0) > 0) trek_find_petals($run, (int)$s['data']['petals']);
    if ((int)($s['data']['xp'] ?? 0) > 0) trek_find_xp($run, $u, (int)$s['data']['xp']);
    return [true, ''];
}

/** Take the Glowworm Grotto's rare find (only with a Wayfinder). */
function trek_act_hidden(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || !in_array($s['type'], ['hidden', 'find'], true) || $run['fi'] || trek_spot_done($run, $s)) return [false, 'Nothing to do here.'];
    trek_flag_set($run, (string)$s['data']['flag']);
    [$slug, $qty] = array_pad(explode(':', (string)($s['data']['item'] ?? ''), 2), 2, '1');
    $iid = $slug !== '' ? trek_item_id($slug) : 0;
    $kits = $slug === 'camp-kit';   // v1.9.4: a find may be a Camp Kit (it goes to the kits you carry) and/or Petals (carried)
    if ($iid && !$kits) trek_pack_add((int)$run['id'], $iid, (int)$qty);
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.find');
    if ($kits) trek_say($run, trek_give_kits($run, $u, (int)$qty));
    elseif ($iid) trek_say($run, '✨ Rare find: ' . (int)$qty . ' × ' . trek_item_name($iid) . ' (carried).');
    if (!empty($s['data']['also'])) {   // v2.0.15: a second item with the find (nookB: a Clay Pot, so Juniper can be fetched without the wheel)
        [$s2, $q2] = array_pad(explode(':', (string)$s['data']['also'], 2), 2, '1');
        $i2 = trek_item_id($s2);
        if ($i2) { trek_pack_add((int)$run['id'], $i2, (int)$q2); trek_say($run, '✨ Rare find: ' . (int)$q2 . ' × ' . trek_item_name($i2) . ' (carried).'); }
    }
    if ((int)($s['data']['petals'] ?? 0) > 0) trek_find_petals($run, (int)$s['data']['petals']);
    if (!empty($s['data']['entry'])) unlock_entries((int)$u['id'], (string)$s['data']['entry']);
    return [true, ''];
}

/**
 * v1.9.4: the clay slide (a spot of type slide, data to=<spot code>): a one-way chute to another spot of the chapter. Once per use; it costs a little fatigue and the party
 * arrives bruised but fine. The slide is not a fast travel (you cannot slide back up).
 */
function trek_act_slide(array &$run, array $u): array
{
    $s = trek_here($run, $u);
    if (!$s || $s['type'] !== 'slide' || $run['fi']) return [false, 'Nothing to do here.'];
    $to = trek_spots((int)$run['chapter'])[(string)($s['data']['to'] ?? '')] ?? null;
    if (!$to) return [false, 'The slide goes nowhere.'];
    trek_flag_set($run, (string)($s['data']['flag'] ?? 'seen_' . $s['code']));
    trek_say_text($run, 'ch' . $run['chapter'] . '.spot.' . $s['code'] . '.done');
    $run['x'] = $to['x'];
    $run['y'] = $to['y'];
    $run['st']['fh'] = 0;
    trek_seen_reveal($run, $to['x'], $to['y'], 3);
    trek_add_fatigue($run, 3);
    trek_zone_enter($run, $to['zone']);
    trek_say($run, '🛝 Whoosh! You slide down to ' . $to['name'] . '. Fatigue +3.');
    return [true, ''];
}

/** v1.9.4: the other camps you have reached in this chapter: code => spot (not the one you stand on). */
function trek_travel_camps(array $run): array
{
    $out = [];
    foreach (trek_spots((int)$run['chapter']) as $c => $s) {
        if ($s['type'] === 'camp' && trek_flag($run, trek_camp_flag($s))) $out[$c] = $s;
    }
    return $out;
}

/**
 * v1.9.4: camp-to-camp travel inside a trek (the Tin Lamp and the Brewhouse): from a camp tile to another camp you have already reached, through the old tunnels.
 * It is not a rest: it costs fatigue (the long way round) and the party arrives where it left off. Not in a fight, not into a chapter's other camps you have not seen.
 */
function trek_act_travel(array &$run, array $u, string $to): array
{
    $here = trek_here_camp($run);
    if (!$here || $run['fi']) return [false, 'You need to be at a camp.'];
    $camps = trek_travel_camps($run);
    unset($camps[$here['code']]);
    if (!isset($camps[$to])) return [false, 'You haven’t reached that camp yet.'];
    $dest = $camps[$to];
    $run['x'] = $dest['x'];
    $run['y'] = $dest['y'];
    $run['camp'] = $dest['code'];
    $run['st']['fh'] = 0;
    trek_seen_reveal($run, $dest['x'], $dest['y'], 3);
    trek_add_fatigue($run, 12);
    trek_zone_enter($run, $dest['zone']);
    trek_say($run, '🚶 You take the old tunnel from ' . $here['name'] . ' to ' . $dest['name'] . '. Fatigue +12.');
    return [true, ''];
}

/** Dismiss a trailmate or put one in: $want = [slot 1..3 => crew key or '']. Only at a camp. Each key at most once, only recruited ones. */
function trek_set_party(array &$run, array $u, array $want): array
{
    if (!trek_at_camp($run) || $run['fi']) return [false, 'You can only swap trailmates at a camp.'];
    $have = trek_recruits((int)$run['id']);
    $seen = [];
    $new = [];
    foreach ([1, 2, 3] as $slot) {
        $k = (string)($want[$slot] ?? '');
        if ($k === '' || !in_array($k, $have, true) || isset($seen[$k])) continue;
        $seen[$k] = true;
        $new[] = $k;
    }
    q('DELETE FROM trek_party WHERE run_id = ? AND slot > 0', [$run['id']]);
    foreach ([1, 2, 3] as $slot) unset($run['party'][$slot]);
    foreach ($new as $i => $k) {
        $slot = $i + 1;
        db_insert('trek_party', ['run_id' => (int)$run['id'], 'slot' => $slot, 'crew_key' => $k, 'hp' => 1]);
        $run['party'][$slot] = ['crew_key' => $k, 'hp' => 1];
        $run['party'][$slot]['hp'] = trek_party_stats($run, $u)[$slot]['max'];
    }
    trek_say($run, '🧑‍🤝‍🧑 The party is ready.');
    return [true, ''];
}

/**
 * The end of a chapter (once): flags, the closing milestones, then the reward screen: direct Petals, items, Almanac pages. What each chapter pays is its
 * "finish" row in trek_chapters.txt. Flags: ch<N>_done, ch<N>_rewarded (Chapter I also sets gloomtooth_cured, as it always did).
 */
function trek_complete_chapter(array &$run, array $u): void
{
    $uid = (int)$u['id'];
    $n = (int)$run['chapter'];
    $fin = trek_chapter($n)['finish'] ?? ['flag' => '', 'ms' => [], 'petals' => '', 'items' => [], 'entries' => [], 'title' => 'Chapter ' . $n];
    if ($fin['flag'] !== '') trek_flag_set($run, $fin['flag']);
    trek_flag_set($run, 'ch' . $n . '_done');
    if (empty($run['finished'])) $run['finished'] = now();   // v1.8.1: admin page showed every run as not finished
    $run['st']['show_done'] = 1;
    foreach ($fin['ms'] as $name) trek_ms_award($run, $u, $name);   // v1.8.9: the last milestones, in this order (each is once only)
    if (trek_flag($run, 'ch' . $n . '_rewarded')) return;
    trek_flag_set($run, 'ch' . $n . '_rewarded');
    $petals = $fin['petals'] !== '' ? max(0, (int)setting($fin['petals'])) : 0;
    if ($petals > 0) q('UPDATE users SET coins = coins + ? WHERE id = ?', [$petals, $uid]);
    $names = []; $slugs = [];
    foreach ($fin['items'] as $slug) {
        $iid = trek_item_id($slug);
        if ($iid) { give_item($uid, $iid, 1); $names[] = trek_item_name($iid); $slugs[] = $slug; }
    }
    foreach ($fin['entries'] as $key) unlock_entries($uid, $key);
    $run['st']['rewards'] = ['petals' => $petals, 'items' => $names, 'slugs' => $slugs];
    trek_say($run, '🎉 ' . $fin['title'] . ' complete! +' . $petals . ' ' . setting('currency_name') . ', ' . implode(', ', $names) . '.');
}

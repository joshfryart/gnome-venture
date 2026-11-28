<?php
declare(strict_types=1);
/**
 * Journey v2 (2026-11-28; claude/PROPOSAL-HOLLOW-MASTER.md section 6, claude/proposal-story-2-quests.md 1.2 and 2.1). Behind the setting
 * `journey_v2_open` (default 0): while it is 0 nothing here runs, no v2 chapter is seeded or shown, and Wren's Journey is exactly as before.
 *
 * Once it is on:
 *  - the chapters of data/journey_chapters.txt are added to quest_chapters (engine = 1; only what is missing, never changed after) the
 *    first time the Journey is read; a v2 chapter that names an old one in `replaces` hides it, takes its locks, and counts its finished
 *    Repair as its own stages (nobody builds the Sugar Shack twice)
 *  - Wren's prologue comes from the file (the P row)
 *  - the steps of a v2 chapter use the kinds below. Every step latches (user_quest_steps.done_at): once done, done for good. A step can
 *    have an `alt`, a second way to finish it; every `adopt` step without one gets "Regular at a lit village" of the same spec.
 *    No step is timed or can fail; `opt` steps never block the chapter.
 *
 * Step kinds (spec parts joined by commas; a list inside one part is joined by "/"):
 *   visit grow friend find stage   as journey.php (find with a spec = those named places, e.g. "Aurora Camp/Cairnback Pass")
 *   adopt    zone:N                 you adopted (or founded) N villages of the zone, now or ever
 *   raise    tier:T[,zone:N][,hearth]  N villages at tier T+ where you are a Regular (hearth: that you adopted or founded)
 *            lit:P                  P% of the area's adoptable villages lit, you a Regular there (seals.php counts them the same way)
 *   regular  zone:N[,lit]           a Regular at N villages of the zone (lit: at tier 1+)
 *   plant    crop:a/b:N | flower:slug | bed:K   N of a crop harvested since the chapter began / the flower grown / Seed Bed hand-in K
 *   deliver  item:slug:N,meal:N,coins:N,fine:N,to:WHERE   handed over at WHERE (button on the chapter page)
 *   escort   who:Name,from:WHERE,to:WHERE   met at `from`, walked to `to` (buttons); they wait for ever
 *   defeat   creature:slug | lair:slug      beaten or charmed N times since the chapter began / the lair cleared
 *   help     area | zone:N | errand:id      N villagers' errands done there / the named errand (journey_v2_errand_done())
 *   puzzle   pic:slug,tier:advanced|expert  that jigsaw finished at that tier or better (hook: ppal_on_solve)
 *   seal     leaf | standing:P | seals:A/B | seals:N   all earlier steps / Standing (awards the Seal) / those Seals / N Seals
 *   act      slug                   (as an alt) that rest stop act done on N different game days
 * WHERE: a place name, "stop" (a village of the chapter's zone), "hearth" (a village you adopted or founded), "off" (any place off the road);
 * a named place this world does not have counts as anywhere in the area. A step whose places do not exist here (or whose feature is closed)
 * is shown as done, without latching.
 */

require_once __DIR__ . '/catalog.php';

/** Kinds finished with a button on the chapter page (the gnome has to be at the place). */
const JOURNEY_V2_ACTION_KINDS = ['deliver', 'escort'];
/** Kinds of journey.php that v2 reads the same way (find only without a spec). */
const JOURNEY_V2_OLD_KINDS = ['visit', 'grow', 'friend', 'find'];
/** C row fields after the "C". */
const JOURNEY_V2_C_COLS = ['slug', 'area', 'zone', 'sort', 'title', 'giver', 'lv', 'needs', 'coins', 'xp', 'item', 'qty', 'rtitle', 'benefit', 'btext', 'project', 'icon', 'intro', 'letter', 'replaces'];
/** T row fields after the "T". */
const JOURNEY_V2_T_COLS = ['chapter', 'kind', 'spec', 'qty', 'lv', 'opt', 'alt', 'label'];

function journey_v2_on(): bool
{
    return setting('journey_v2_open') === '1';
}

function journey_is_v2(array $ch): bool
{
    return (int)($ch['engine'] ?? 0) === 1;
}

/** [tables, indexes, columns] for schema_statements(). */
function journey_v2_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS user_quest_steps (
        user_id $ID NOT NULL,
        task_id $ID NOT NULL,
        progress INT NOT NULL DEFAULT 0,
        alt_progress INT NOT NULL DEFAULT 0,
        state VARCHAR(16) NULL,
        done_at DATETIME NULL,
        how VARCHAR(8) NULL,
        PRIMARY KEY (user_id, task_id)
    )$END"];
    $c = [
        ['quest_chapters', 'engine', 'INT NOT NULL DEFAULT 0'],      // 1 = a v2 chapter (data/journey_chapters.txt)
        ['quest_chapters', 'zone_num', 'INT NULL'],                  // the zone the chapter is in (0 = the whole area)
        ['quest_chapters', 'lv', 'VARCHAR(8) NULL'],                 // recommended levels, "1-4"
        ['quest_chapters', 'needs', 'VARCHAR(255) NULL'],            // chapter slugs that must be finished first ("/")
        ['quest_chapters', 'replaces', 'VARCHAR(80) NULL'],          // the old chapter this one stands in for
        ['quest_tasks', 'lv', 'VARCHAR(8) NULL'],
        ['quest_tasks', 'opt', 'INT NOT NULL DEFAULT 0'],
        ['quest_tasks', 'alt', 'VARCHAR(255) NULL'],
    ];
    return [$t, [], $c];
}

// ---------------------------------------------------------------- the data file

/** data/journey_chapters.txt: ['P' => prologue, 'C' => [slug => row], 'T' => [[row], ...]]. "\n" in a field is a new line. */
function journey_v2_data(): array
{
    static $d = null;
    if ($d !== null) return $d;
    $d = ['P' => '', 'C' => [], 'T' => []];
    $nl = fn(string $s) => str_replace('\n', "\n", $s);
    foreach (catalog_lines('journey_chapters.txt') as $r) {
        $kind = array_shift($r);
        if ($kind === 'P') $d['P'] = $nl((string)($r[0] ?? ''));
        elseif ($kind === 'C' && count($r) >= count(JOURNEY_V2_C_COLS)) $d['C'][$r[0]] = array_map($nl, array_combine(JOURNEY_V2_C_COLS, array_slice($r, 0, count(JOURNEY_V2_C_COLS))));
        elseif ($kind === 'T' && count($r) >= count(JOURNEY_V2_T_COLS)) $d['T'][] = array_combine(JOURNEY_V2_T_COLS, array_slice($r, 0, count(JOURNEY_V2_T_COLS)));
    }
    return $d;
}

/** Wren's prologue: the file's while v2 is on, else JOURNEY_PROLOGUE. */
function journey_prologue(): string
{
    return journey_v2_on() && ($p = journey_v2_data()['P']) !== '' ? $p : JOURNEY_PROLOGUE;
}

/** Add the file's chapters that are missing (never changes one that exists). Stamped by the file's hash, so a page read costs one setting. */
function journey_v2_seed(): void
{
    $stamp = (string)md5_file(__DIR__ . '/data/journey_chapters.txt');
    if (setting('journey_v2_seeded') === $stamp || db()->inTransaction()) return;
    $data = journey_v2_data();
    $complete = true;
    foreach ($data['C'] as $slug => $c) {
        $rid = (int)q_val('SELECT id FROM regions WHERE code = ?', [$c['area']]);
        if (!$rid) { $complete = false; continue; }
        if (q_val('SELECT 1 FROM quest_chapters WHERE slug = ?', [$slug])) continue;
        $old = $c['replaces'] !== '-' ? q_one('SELECT locks FROM quest_chapters WHERE slug = ?', [$c['replaces']]) : null;
        db()->beginTransaction();
        try {
            $cid = db_insert('quest_chapters', ['slug' => $slug, 'region_id' => $rid, 'sort_order' => (int)$c['sort'], 'title' => $c['title'],
                'npc_slug' => $c['giver'] !== '-' ? $c['giver'] : null, 'intro' => $c['intro'], 'outro' => $c['letter'], 'project_name' => $c['project'],
                'project_icon' => $c['icon'], 'benefit' => $c['benefit'] !== '-' ? $c['benefit'] : '', 'benefit_text' => $c['btext'] !== '-' ? $c['btext'] : '',
                'reward_coins' => (int)$c['coins'], 'reward_xp' => (int)$c['xp'], 'reward_item_slug' => $c['item'] !== '-' ? $c['item'] : null,
                'reward_qty' => max(1, (int)$c['qty']), 'reward_title' => $c['rtitle'] !== '-' ? $c['rtitle'] : '', 'active' => 1, 'locks' => $old['locks'] ?? null,
                'engine' => 1, 'zone_num' => (int)$c['zone'], 'lv' => $c['lv'], 'needs' => $c['needs'] !== '-' ? $c['needs'] : null,
                'replaces' => $c['replaces'] !== '-' ? $c['replaces'] : null]);
            $n = 0;
            foreach ($data['T'] as $t) {
                if ($t['chapter'] !== $slug) continue;
                db_insert('quest_tasks', ['chapter_id' => $cid, 'sort_order' => ++$n, 'kind' => $t['kind'], 'spec' => $t['spec'] !== '-' ? $t['spec'] : '',
                    'qty' => max(1, (int)$t['qty']), 'label' => $t['label'], 'lv' => $t['lv'], 'opt' => (int)$t['opt'] === 1 ? 1 : 0, 'alt' => $t['alt'] !== '-' ? $t['alt'] : null]);
            }
            db()->commit();
        } catch (PDOException $e) {
            db()->rollBack();   // another request seeded it a moment ago
        }
    }
    if ($complete) set_setting('journey_v2_seeded', $stamp);
}

/** The chapters in play while v2 is on: every active chapter but the old ones a v2 chapter replaces. */
function journey_v2_in_play(array $rows): array
{
    $gone = array_filter(array_map(fn($c) => journey_is_v2($c) ? (string)$c['replaces'] : '', $rows));
    return array_values(array_filter($rows, fn($c) => !in_array((string)$c['slug'], $gone, true)));
}

/** A v2 chapter starts once the chapters it needs are finished (and its area is reached, as every chapter). */
function journey_v2_needs_met(int $uid, array $ch): bool
{
    foreach (array_filter(explode('/', (string)($ch['needs'] ?? ''))) as $slug) {
        if (!q_val('SELECT 1 FROM user_quests uq JOIN quest_chapters c ON c.id = uq.chapter_id WHERE uq.user_id = ? AND c.slug = ? AND uq.done_at IS NOT NULL', [$uid, $slug])) return false;
    }
    return true;
}

/** True when the old chapter this one replaces was finished: its Repair is built, so this chapter's stages are too. */
function journey_v2_replaced_done(int $uid, array $ch): bool
{
    $old = (string)($ch['replaces'] ?? '');
    return $old !== '' && (bool)q_val('SELECT 1 FROM user_quests uq JOIN quest_chapters c ON c.id = uq.chapter_id WHERE uq.user_id = ? AND c.slug = ? AND uq.done_at IS NOT NULL', [$uid, $old]);
}

// ---------------------------------------------------------------- specs

/** "zone:1,tier:2,hearth" => ['zone' => '1', 'tier' => '2', 'hearth' => true] */
function journey_v2_spec(string $spec): array
{
    $out = [];
    foreach (array_filter(array_map('trim', explode(',', $spec)), 'strlen') as $part) {
        $kv = explode(':', $part, 2);
        $out[$kv[0]] = $kv[1] ?? true;
    }
    return $out;
}

/** A step's alt as [kind, spec, qty], or null. "kind:spec:qty" (the qty is the last ":" part when it is a number); adopt has a default. */
function journey_v2_alt(array $t): ?array
{
    $alt = trim((string)($t['alt'] ?? ''));
    if ($alt === '' || $alt === '-') {
        return $t['kind'] === 'adopt' ? ['regular', trim((string)$t['spec'] . ',lit', ','), max(1, (int)$t['qty'])] : null;
    }
    $p = explode(':', $alt);
    $kind = array_shift($p);
    $qty = count($p) > 1 && ctype_digit((string)end($p)) ? (int)array_pop($p) : 1;
    return [$kind, implode(':', $p), max(1, $qty)];
}

// ---------------------------------------------------------------- the world, read live

/** Villages of an area (of one zone when the spec names one). */
function journey_v2_villages(int $rid, array $sp): array
{
    $sql = "SELECT l.* FROM locations l LEFT JOIN zones z ON z.id = l.zone_id WHERE l.region_id = ? AND l.kind = 'village'";
    $args = [$rid];
    if (isset($sp['zone'])) { $sql .= ' AND z.zone_num = ?'; $args[] = (int)$sp['zone']; }
    return q($sql . ' ORDER BY l.id', $args)->fetchAll();
}

function journey_v2_mine(int $uid, int $locId): bool
{
    return (bool)q_val('SELECT 1 FROM stop_adoptions WHERE location_id = ? AND (user_id = ? OR founder_id = ?)', [$locId, $uid, $uid]);
}

function journey_v2_regular(int $uid, int $locId): bool
{
    require_once __DIR__ . '/stops.php';
    return stop_fam_level($uid, $locId) !== 'stranger';
}

/** The place a WHERE names: a location row, or null for "anywhere in the area" (also for a name this world does not have). */
function journey_v2_place(int $rid, string $where): ?array
{
    if (in_array($where, ['', 'stop', 'hearth', 'off'], true)) return null;
    return q_one('SELECT * FROM locations WHERE region_id = ? AND name = ? ORDER BY id LIMIT 1', [$rid, $where]) ?: null;
}

/** Is the gnome standing at WHERE (see the file header)? */
function journey_v2_at(array $u, array $ch, string $where): bool
{
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)($u['location_id'] ?? 0)]);
    $rid = (int)$ch['region_id'];
    if (!$loc || (int)$loc['region_id'] !== $rid) return false;
    if ($place = journey_v2_place($rid, $where)) return (int)$place['id'] === (int)$loc['id'];
    require_once __DIR__ . '/roads.php';
    return match ($where) {
        'stop' => $loc['kind'] === 'village' && ((int)$ch['zone_num'] < 1 || (int)q_val('SELECT zone_num FROM zones WHERE id = ?', [(int)$loc['zone_id']]) === (int)$ch['zone_num']),
        'hearth' => $loc['kind'] === 'village' && journey_v2_mine((int)$u['id'], (int)$loc['id']),
        'off' => !in_array($loc['kind'], ['market', 'hub'], true) && !on_road((int)$loc['id']),
        default => true,
    };
}

function journey_v2_where_text(array $ch, string $where): string
{
    $zone = (int)$ch['zone_num'] > 0 ? (string)q_val('SELECT name FROM zones WHERE region_id = ? AND zone_num = ?', [$ch['region_id'], $ch['zone_num']]) : '';
    if (journey_v2_place((int)$ch['region_id'], $where)) return $where;
    return match ($where) {
        'stop' => 'a village of ' . ($zone !== '' ? $zone : $ch['region']),
        'hearth' => 'a stop you adopted or founded',
        'off' => 'a place off the road in ' . $ch['region'],
        default => 'anywhere in ' . $ch['region'],
    };
}

/**
 * Live progress of one condition: [now, goal]. goal 0 = there is nothing here to do it with (feature closed, places missing): shown as done.
 * $p is the gnome's user_quest_steps row; $prog the counter for this condition (progress or alt_progress); $before = every earlier step is done.
 */
function journey_v2_eval(array $u, array $ch, ?array $row, string $kind, string $spec, int $qty, int $prog, bool $before): array
{
    $uid = (int)$u['id'];
    $rid = (int)$ch['region_id'];
    $sp = journey_v2_spec($spec);
    if (in_array($kind, JOURNEY_V2_OLD_KINDS, true) && !($kind === 'find' && $spec !== '')) {
        return journey_task_now($uid, $ch, ['kind' => $kind, 'spec' => $spec, 'qty' => $qty], $row);
    }
    switch ($kind) {
        case 'find':
            require_once __DIR__ . '/roads.php';
            $places = array_filter(array_map(fn($n) => journey_v2_place($rid, trim($n)), explode('/', $spec)));
            return [count(array_filter($places, fn($l) => place_known($uid, $l))), min($qty, count($places))];
        case 'adopt':
        case 'regular':
            $vs = journey_v2_villages($rid, $sp);
            require_once __DIR__ . '/stop_adopt.php';
            $f = $kind === 'adopt' ? fn($v) => journey_v2_mine($uid, (int)$v['id'])
                : fn($v) => journey_v2_regular($uid, (int)$v['id']) && (!isset($sp['lit']) || stop_tier((int)$v['id']) >= 1);   // lit: a lamp somebody lit
            return [count(array_filter($vs, $f)), min($qty, count($vs))];
        case 'raise':
            require_once __DIR__ . '/stop_adopt.php';
            if (isset($sp['lit'])) {
                require_once __DIR__ . '/seals.php';
                $vs = array_filter(journey_v2_villages($rid, []), fn($v) => !STANDING_N_ROAD_ONLY || on_road((int)$v['id']));
                $lit = count(array_filter($vs, fn($v) => stop_tier((int)$v['id']) >= 1 && journey_v2_regular($uid, (int)$v['id'])));
                return [$lit, $vs ? max(1, (int)round((int)$sp['lit'] / 100 * count($vs))) : 0];
            }
            $vs = journey_v2_villages($rid, $sp);
            $tier = max(1, (int)($sp['tier'] ?? 1));
            $f = isset($sp['hearth']) ? fn($v) => journey_v2_mine($uid, (int)$v['id']) : fn($v) => journey_v2_regular($uid, (int)$v['id']);
            return [count(array_filter($vs, fn($v) => stop_tier((int)$v['id']) >= $tier && $f($v))), min($qty, count($vs))];
        case 'plant':
            [$what, $slug, $n] = explode(':', $spec) + [1 => '', 2 => '1'];
            if ($what === 'crop') return [$prog, max(1, (int)$n)];
            if ($what === 'flower') {
                return [(int)(bool)q_val('SELECT 1 FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id WHERE k.user_id = ? AND p.slug = ? AND k.knowledge > 0', [$uid, $slug]), 1];
            }
            // bed:K. Seed Beds (build plan 8) provide seed_bed_handins(uid, region id); until then the step has nothing to do
            return function_exists('seed_bed_handins') ? [(int)seed_bed_handins($uid, $rid), max(1, (int)$slug)] : [0, 0];
        case 'defeat':
            if (isset($sp['lair'])) {
                $lairs = q("SELECT m.id, m.name FROM landmarks m WHERE m.region_id = ? AND m.kind = 'lair'", [$rid])->fetchAll();
                $lairs = array_filter($lairs, fn($m) => str_contains(slugify((string)$m['name']), (string)$sp['lair']));
                if (!$lairs) return [0, 0];
                $in = implode(',', array_map(fn($m) => (int)$m['id'], $lairs));
                return [(int)q_val("SELECT COUNT(*) FROM landmark_clears WHERE user_id = ? AND landmark_id IN ($in)", [$uid]), 1];
            }
            return [$prog, $qty];
        case 'help':
            if (isset($sp['errand'])) return [0, $qty];   // only journey_v2_errand_done() latches it
            $sql = "SELECT COUNT(*) FROM stop_errands e JOIN stop_folk f ON f.id = e.folk_id JOIN locations l ON l.id = f.location_id LEFT JOIN zones z ON z.id = l.zone_id
                    WHERE e.user_id = ? AND e.status = 'done' AND l.region_id = ?";
            $args = [$uid, $rid];
            if (isset($sp['zone'])) { $sql .= ' AND z.zone_num = ?'; $args[] = (int)$sp['zone']; }
            return [(int)q_val($sql, $args), $qty];
        case 'puzzle':
            return journey_v2_puzzle_done($uid, (string)($sp['pic'] ?? ''), (string)($sp['tier'] ?? 'advanced'));
        case 'seal':
            return journey_v2_seal_eval($uid, $rid, $sp, $before);
        case 'act':
            return [(int)q_val('SELECT COUNT(DISTINCT day) FROM stop_log WHERE user_id = ? AND act = ?', [$uid, $spec]), $qty];
        default:   // deliver, escort: only their button finishes them
            return [0, $qty];
    }
}

/** A jigsaw finished at a tier or better: [0|1, 1], or [0, 0] when jigsaws or Puzzle Pals are closed or the gnome is a guest (master doc 9). */
function journey_v2_puzzle_done(int $uid, string $picSlug, string $tier): array
{
    require_once __DIR__ . '/jigsaw.php';
    require_once __DIR__ . '/puzzle_pals.php';
    if (!jigsaw_open() || !ppal_open() || is_guest_uid($uid)) return [0, 0];
    $pic = (int)q_val('SELECT id FROM puzzle_pics WHERE slug = ?', [$picSlug]);
    if (!$pic) return [0, 0];
    $pieces = jigsaw_pieces(str_starts_with($tier, 'expert') ? 'expert' : 'advanced');
    $done = q_val("SELECT 1 FROM puzzle_runs WHERE user_id = ? AND pic_id = ? AND game = 'jigsaw' AND status = 'done' AND size >= ?", [$uid, $pic, $pieces])
        || q_val('SELECT 1 FROM ppal_trophies WHERE user_id = ? AND pic_id = ?', [$uid, $pic])
        || ($pieces < jigsaw_pieces('expert') && q_val('SELECT 1 FROM ppal_releases WHERE user_id = ? AND pic_id = ?', [$uid, $pic]));
    return [$done ? 1 : 0, 1];
}

/** seal leaf / standing:P / seals:A/B / seals:N. Standing at the mark awards the area's Seal (seals.php; only while seals_open is on). */
function journey_v2_seal_eval(int $uid, int $rid, array $sp, bool $before): array
{
    require_once __DIR__ . '/seals.php';
    if (isset($sp['standing'])) {
        if (seal_held($uid, $rid)) return [1, 1];
        $reached = region_standing($uid, $rid)['total'] >= min((float)$sp['standing'], (float)seal_threshold());
        if ($reached) region_seal_check($uid, $rid);
        return [$reached ? 1 : 0, 1];
    }
    if (isset($sp['seals'])) {
        $held = array_map(fn($id) => seal_region_code((int)$id), array_keys(array_filter(seal_regions(), fn($r) => seal_held($uid, (int)$r['id']))));
        $want = (string)$sp['seals'];
        return ctype_digit($want) ? [count($held), (int)$want] : [count(array_intersect(explode('/', $want), $held)), count(explode('/', $want))];
    }
    return [$before ? 1 : 0, 1];   // leaf
}

// ---------------------------------------------------------------- the gnome's steps

/** user_quest_steps rows of a chapter's tasks: task id => row. */
function journey_v2_progress(int $uid, int $chapterId): array
{
    $out = [];
    foreach (q('SELECT s.* FROM user_quest_steps s JOIN quest_tasks t ON t.id = s.task_id WHERE s.user_id = ? AND t.chapter_id = ?', [$uid, $chapterId])->fetchAll() as $r) $out[(int)$r['task_id']] = $r;
    return $out;
}

/** Make sure the gnome has a row for a step (progress counters start at 0). */
function journey_v2_touch(int $uid, int $taskId): void
{
    if (q_val('SELECT 1 FROM user_quest_steps WHERE user_id = ? AND task_id = ?', [$uid, $taskId])) return;
    try { db_insert('user_quest_steps', ['user_id' => $uid, 'task_id' => $taskId]); } catch (PDOException $e) {}   // made a moment ago
}

/** A step is done for good. */
function journey_v2_latch(int $uid, int $taskId, string $how): void
{
    journey_v2_touch($uid, $taskId);
    q('UPDATE user_quest_steps SET done_at = ?, how = ? WHERE user_id = ? AND task_id = ? AND done_at IS NULL', [now(), $how, $uid, $taskId]);
}

/**
 * One step: [now, goal, how]. how: '' (not done), 'main', 'alt' (the second way), 'na' (nothing to do it with here: counts as done, not latched).
 * Latched steps read as done without looking at the world again.
 */
function journey_v2_check(array $u, array $ch, ?array $row, array $t, ?array $p, bool $before): array
{
    $qty = max(1, (int)$t['qty']);
    if (!$row) return [0, $qty, ''];
    if ($row['done_at']) return [$qty, $qty, (string)($p['how'] ?? 'main') ?: 'main'];
    if ($p && $p['done_at']) return [$qty, $qty, (string)$p['how']];
    [$now, $goal] = journey_v2_eval($u, $ch, $row, (string)$t['kind'], (string)$t['spec'], $qty, (int)($p['progress'] ?? 0), $before);
    if ($goal > 0 && $now >= $goal) { journey_v2_latch((int)$u['id'], (int)$t['id'], 'main'); return [$goal, $goal, 'main']; }
    if ($alt = journey_v2_alt($t)) {
        [$an, $ag] = journey_v2_eval($u, $ch, $row, $alt[0], $alt[1], $alt[2], (int)($p['alt_progress'] ?? 0), $before);
        if ($ag > 0 && $an >= $ag) { journey_v2_latch((int)$u['id'], (int)$t['id'], 'alt'); return [$goal ?: 1, $goal ?: 1, 'alt']; }
    }
    if ($goal === 0) return [0, 0, 'na'];
    return [min($now, $goal), $goal, ''];
}

/** journey_status() for a v2 chapter: the same shape, each task with a fifth element ['how' => …]. Stages need nothing before them, only each other. */
function journey_v2_status(array $u, array $ch): array
{
    $uid = (int)$u['id'];
    $row = journey_row($uid, $ch);
    $out = ['row' => $row, 'tasks' => [], 'explore_done' => true, 'stages_done' => 0, 'next_stage' => null, 'complete' => false, 'v2' => true];
    $prog = $row ? journey_v2_progress($uid, (int)$ch['id']) : [];
    $built = $row && journey_v2_replaced_done($uid, $ch);
    $stageNo = 0;
    $before = true;   // every earlier non-optional step done
    foreach (journey_tasks((int)$ch['id']) as $t) {
        if ($t['kind'] === 'stage') {
            $stageNo++;
            $done = $row && ($built || $row['done_at'] || (int)$row['stage'] >= $stageNo);
            if ($done) $out['stages_done']++;
            elseif (!$out['next_stage']) $out['next_stage'] = $t + ['_n' => $stageNo];
            $out['tasks'][] = [$t, $done ? 1 : 0, 1, $done, ['how' => $done ? 'main' : '']];
        } else {
            [$now, $goal, $how] = journey_v2_check($u, $ch, $row, $t, $prog[(int)$t['id']] ?? null, $before);
            $done = $how !== '';
            if (!$done && !(int)$t['opt'] && $t['kind'] !== 'seal') $out['explore_done'] = false;
            $out['tasks'][] = [$t, $now, max(1, $goal), $done, ['how' => $how]];
        }
        if (!$done && !(int)$t['opt']) $before = false;
    }
    if ($built && $row && (int)$row['stage'] < $stageNo) {   // the old chapter's Repair counts: keep the stage counter in step
        q('UPDATE user_quests SET stage = ? WHERE id = ? AND stage < ?', [$stageNo, $row['id'], $stageNo]);
    }
    $out['complete'] = $row && $before;
    return $out;
}

// ---------------------------------------------------------------- hooks (events from the rest of the game)

/** Unfinished steps of started, unfinished v2 chapters that an event could move. */
function journey_v2_open_tasks(int $uid, array $kinds): array
{
    $in = implode(',', array_fill(0, count($kinds), '?'));
    $like = implode(' OR ', array_fill(0, count($kinds), 't.alt LIKE ?'));
    return q("SELECT t.* FROM quest_tasks t JOIN quest_chapters c ON c.id = t.chapter_id AND c.engine = 1 AND c.active = 1
              JOIN user_quests uq ON uq.chapter_id = c.id AND uq.user_id = ? AND uq.done_at IS NULL
              WHERE (t.kind IN ($in) OR $like) AND NOT EXISTS (SELECT 1 FROM user_quest_steps s WHERE s.user_id = ? AND s.task_id = t.id AND s.done_at IS NOT NULL)",
        array_merge([$uid], $kinds, array_map(fn($k) => $k . ':%', $kinds), [$uid]))->fetchAll();
}

/** Does an event (harvest of a plant slug, defeat of a creature slug) count for this condition? */
function journey_v2_event_matches(string $kind, string $evKind, string $spec, string $target): bool
{
    if ($kind === 'plant' && $evKind === 'harvest') {
        [$what, $slugs] = explode(':', $spec) + [1 => ''];
        return $what === 'crop' && in_array($target, explode('/', $slugs), true);
    }
    return $kind === 'defeat' && $evKind === 'defeat' && (journey_v2_spec($spec)['creature'] ?? '') === $target;
}

/** calling_event() passes every game event here (while v2 is on): harvests and fights (beaten or befriended) count for plant and defeat steps. */
function journey_v2_event(int $uid, string $kind, string $target, int $n): void
{
    $step = ['harvest' => 'plant', 'defeat' => 'defeat'][$kind] ?? '';
    if ($step === '' || $n <= 0 || $uid < 1) return;
    foreach (journey_v2_open_tasks($uid, [$step]) as $t) {
        $col = journey_v2_event_matches((string)$t['kind'], $kind, (string)$t['spec'], $target) ? 'progress'
            : (($alt = journey_v2_alt($t)) && journey_v2_event_matches($alt[0], $kind, $alt[1], $target) ? 'alt_progress' : '');
        if ($col === '') continue;
        journey_v2_touch($uid, (int)$t['id']);
        q("UPDATE user_quest_steps SET $col = $col + ? WHERE user_id = ? AND task_id = ?", [$n, $uid, (int)$t['id']]);
    }
}

/** ppal_on_solve() calls this when a jigsaw is finished at Advanced or Expert (free play or a tournament): matching puzzle steps latch. */
function journey_v2_puzzle_solved(int $uid, int $picId, string $tier): void
{
    $slug = (string)q_val('SELECT slug FROM puzzle_pics WHERE id = ?', [$picId]);
    foreach (journey_v2_open_tasks($uid, ['puzzle']) as $t) {
        $sp = journey_v2_spec((string)$t['spec']);
        $wantExpert = str_starts_with((string)($sp['tier'] ?? 'advanced'), 'expert');
        if (($sp['pic'] ?? '') === $slug && ($tier === 'expert' || !$wantExpert)) journey_v2_latch($uid, (int)$t['id'], 'main');
    }
}

/** For the errands of build plan 10: a named errand is done, so `help errand:id` steps latch. */
function journey_v2_errand_done(int $uid, string $errandId): void
{
    foreach (journey_v2_open_tasks($uid, ['help']) as $t) {
        if ((journey_v2_spec((string)$t['spec'])['errand'] ?? '') === $errandId) journey_v2_latch($uid, (int)$t['id'], 'main');
    }
}

// ---------------------------------------------------------------- buttons: escort and deliver

/** The condition of a step that is finished by a button: [kind, spec, how] (the step itself or its alt), or null. */
function journey_v2_action_part(array $t): ?array
{
    if (in_array($t['kind'], JOURNEY_V2_ACTION_KINDS, true)) return [(string)$t['kind'], (string)$t['spec'], 'main'];
    $alt = journey_v2_alt($t);
    return $alt && in_array($alt[0], JOURNEY_V2_ACTION_KINDS, true) ? [$alt[0], $alt[1], 'alt'] : null;
}

/**
 * What the button of an open escort or deliver step offers here: ['text' => what to do, 'button' => label or '', 'why' => why not now].
 * Null when the step has no button.
 */
function journey_v2_action(array $u, array $ch, array $t, ?array $p): ?array
{
    $part = journey_v2_action_part($t);
    if (!$part) return null;
    [$kind, $spec] = $part;
    $sp = journey_v2_spec($spec);
    if ($kind === 'escort') {
        $who = (string)($sp['who'] ?? 'them');
        if (($p['state'] ?? '') !== 'met') {
            $from = (string)($sp['from'] ?? '');
            return ['text' => '🧭 Find ' . $who . ' at ' . journey_v2_where_text($ch, $from) . '.', 'button' => journey_v2_at($u, $ch, $from) ? '👋 Meet ' . $who : '', 'why' => 'Go there first.'];
        }
        $to = (string)($sp['to'] ?? '');
        return ['text' => '🚶 ' . ucfirst($who) . ' walks with you, and waits wherever you stop. Bring them to ' . journey_v2_where_text($ch, $to) . '.',
            'button' => journey_v2_at($u, $ch, $to) ? '🏡 Walk ' . $who . ' in' : '', 'why' => 'Walk there first.'];
    }
    $to = (string)($sp['to'] ?? '');
    $have = !array_filter(journey_need_status($u, $spec), fn($x) => $x[2] < $x[1]);
    $here = journey_v2_at($u, $ch, $to);
    return ['text' => '📦 Bring ' . journey_v2_deliver_text($ch, $spec) . '.', 'button' => $here && $have ? '🤲 Hand over' : '',
        'why' => !$here ? 'Go there first.' : 'You are missing something.'];
}

/** The escort or deliver button. Returns [ok, message]. */
function journey_v2_step_act(array $u, int $taskId): array
{
    $uid = (int)$u['id'];
    $t = q_one('SELECT * FROM quest_tasks WHERE id = ?', [$taskId]);
    $ch = null;
    foreach (journey_chapters() as $c) if ($t && (int)$c['id'] === (int)$t['chapter_id'] && journey_is_v2($c)) $ch = $c;
    if (!$ch || !($part = journey_v2_action_part($t))) return [false, 'There’s no such step.'];
    $row = journey_row($uid, $ch);
    if (!$row || $row['done_at']) return [false, $row ? 'You’ve already finished this chapter.' : 'Reach ' . $ch['region'] . ' first.'];
    $p = journey_v2_progress($uid, (int)$ch['id'])[$taskId] ?? null;
    if ($p && $p['done_at']) return [false, 'That’s done already.'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: $u;
    $act = journey_v2_action($u, $ch, $t, $p);
    if (!$act || $act['button'] === '') return [false, $act['why'] ?? 'Not here.'];
    [$kind, $spec, $how] = $part;
    $sp = journey_v2_spec($spec);
    if ($kind === 'escort' && ($p['state'] ?? '') !== 'met') {
        journey_v2_touch($uid, $taskId);
        q("UPDATE user_quest_steps SET state = 'met' WHERE user_id = ? AND task_id = ?", [$uid, $taskId]);
        return [true, '👋 ' . ucfirst((string)($sp['who'] ?? 'They')) . ' falls in beside you. No hurry: they will wait wherever you stop.'];
    }
    if ($kind === 'deliver') {
        db()->beginTransaction();
        if (($err = journey_take_needs($uid, $spec)) !== '') { db()->rollBack(); return [false, $err]; }
        db()->commit();
    }
    journey_v2_latch($uid, $taskId, $how);
    return [true, '✅ ' . preg_replace('/\s*\(.*\)$/', '', (string)$t['label']) . ': done!'];
}

// ---------------------------------------------------------------- words

/** "Or: …" under a step with a second way to finish it. */
function journey_v2_alt_text(array $ch, array $t): string
{
    $alt = journey_v2_alt($t);
    if (!$alt) return '';
    [$kind, $spec, $qty] = $alt;
    $sp = journey_v2_spec($spec);
    $zone = isset($sp['zone']) ? (string)q_val('SELECT name FROM zones WHERE region_id = ? AND zone_num = ?', [$ch['region_id'], (int)$sp['zone']]) : '';
    return match ($kind) {
        'regular' => 'Or: be a Regular (three things done) at ' . ($qty > 1 ? $qty . ' lit villages' : 'a lit village') . ($zone !== '' ? ' of ' . $zone : '') . ', whoever lit it.',
        'deliver' => 'Or, peacefully: bring ' . journey_v2_deliver_text($ch, $spec) . '.',
        'act' => 'Or: ' . lcfirst((string)(q_val('SELECT name FROM stop_acts WHERE slug = ?', [$spec]) ?: $spec)) . ' at a stop on ' . $qty . ' different game days (one a day, after you sleep).',
        default => 'Or: ' . $kind . ' ' . $spec . ($qty > 1 ? ' ×' . $qty : '') . '.',
    };
}

/** "2 × Beeswax to Lighthouse of the Lost Lantern" */
function journey_v2_deliver_text(array $ch, string $spec): string
{
    $parts = [];
    foreach (journey_needs($spec) as [$type, $slug, $qty]) {
        $parts[] = $qty . ' × ' . match ($type) {
            'item' => (string)(q_val('SELECT name FROM items WHERE slug = ?', [$slug]) ?: $slug),
            'meal' => 'home-cooked meals',
            'fine' => 'uncommon or rare finds',
            'coins' => (string)setting('currency_name'),
        };
    }
    return implode(', ', $parts) . ' to ' . journey_v2_where_text($ch, (string)(journey_v2_spec($spec)['to'] ?? ''));
}

/** How to do an open step, in a few words, and where to go: [text, page]. */
function journey_v2_how(array $t): array
{
    return match ((string)$t['kind']) {
        'adopt' => ['Do three things at the stop, then adopt it from its card (your first adoption in an area is free).', 'world.php'],
        'raise' => ['Hand in materials on the stop’s card to build its next tier.', 'world.php'],
        'regular' => ['Do three things at the village (its acts, chat, errands) to become a Regular.', 'world.php'],
        'plant' => ['Plant and harvest it in any garden.', 'garden.php'],
        'deliver', 'escort' => ['Walk there, then use the button on this page.', 'world.php'],
        'defeat' => ['Beat it or charm it on an adventure; the peaceful way is below.', 'world.php'],
        'help' => ['Villagers at the stops ask for errands.', 'world.php'],
        'puzzle' => ['Games → Jigsaw: finish the picture on Advanced or Expert.', 'jigsaw.php'],
        'seal' => ['Keep going: Wren binds the page when everything above is done.', 'book.php?ch=Journey'],
        'find' => ['At a road stop choose 🌿 Wander off the path; side paths lead to it.', 'world.php'],
        default => ['', 'world.php'],
    };
}

/** A v2 letter with its tokens filled in: {hearth} (your best stop of the area), {plaque} (its plaque line), {friend} (a townsfolk friend). */
function journey_v2_letter(array $u, array $ch): string
{
    $uid = (int)$u['id'];
    require_once __DIR__ . '/stop_adopt.php';
    $hearth = q_one('SELECT l.* , a.tier FROM stop_adoptions a JOIN locations l ON l.id = a.location_id WHERE l.region_id = ? AND (a.user_id = ? OR a.founder_id = ?) ORDER BY a.tier DESC, a.id LIMIT 1',
        [$ch['region_id'], $uid, $uid]);
    $plaque = $hearth ? (string)(stop_tiers_for($hearth)[(int)$hearth['tier']]['plaque'] ?? '') : '';
    $friend = (string)q_val('SELECT n.name FROM npc_friends f JOIN npcs n ON n.id = f.npc_id JOIN town_spots s ON s.id = n.fav_spot_id WHERE f.user_id = ? AND s.region = ? ORDER BY f.points DESC LIMIT 1',
        [$uid, $ch['region']]);
    return strtr((string)$ch['outro'], ['{hearth}' => $hearth ? (string)$hearth['name'] : 'the first stop you lit', '{plaque}' => $plaque !== '' ? $plaque : 'A lamp, lit on purpose.',
        '{friend}' => $friend !== '' ? $friend : 'A friend of yours']);
}

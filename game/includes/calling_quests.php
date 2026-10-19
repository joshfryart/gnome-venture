<?php
declare(strict_types=1);

/**
 * v0.9.4: calling questlines. Tier II (Journeyman) and tier III (Master) need a chapter from the calling's mentor
 * on top of the gnome level: calling_tier() = min(level tier, 1 + users.calling_qt).
 *
 * Content lives in data/calling_quests.txt (imported once, rows already present are skipped so admin edits stick):
 *   C|slug|calling|tier(2|3)|title|mentor_slug|reward_coins|reward_xp|reward_item_slug|reward_qty|reward_title|intro|outro
 *   T|chapter_slug|mode|kind|spec|qty|label
 * Text uses a literal \n for a new line and never a pipe. Tasks keep file order.
 *
 * Task modes:
 *   event  counted from the moment the chapter is accepted, fed by calling_event() (job_event() forwards to it).
 *   state  read live from the game state, so it counts what a gnome did before (veterans see these tick at once).
 *   give   a hand-in at the mentor (spec like Wren's Journey: item:slug:N,coins:N,meal:N,fine:N), last and in order.
 * Event spec filters: "key=a/b,key>=3,key^=prefix,key$=suffix,distinct=1". The key "slug" is the event target, any other key
 * reads the event's ctx array. distinct=1 counts different targets. "depth" and "grade" events keep the highest value.
 * Progress is kept per chapter, and chapters belong to one calling, so every calling keeps its own progress.
 */

require_once __DIR__ . '/gnome.php';

const CALLING_EVENT_KINDS = ['harvest', 'water', 'gather', 'cook', 'craft', 'defeat', 'befriend', 'page', 'arrive', 'walk', 'depth',
    'wonder', 'haven', 'travel', 'eat', 'sell', 'talk', 'gift', 'tend', 'seed_saved', 'townact'];
const CALLING_STATE_KINDS = ['grade', 'beds', 'regions', 'places', 'clears', 'friends', 'mastered', 'known', 'guides', 'recipes', 'roads'];
const CALLING_MAX_KINDS = ['depth', 'grade'];   // events that keep the highest value instead of adding up

// ------------------------------------------------------------------ content import and migration

/** Import data/calling_quests.txt: chapters, tasks, and one Almanac page per chapter (unlocked when it is finished). */
function ensure_calling_quests(): int
{
    require_once __DIR__ . '/catalog.php';
    if (!is_file(__DIR__ . '/data/calling_quests.txt')) return 0;
    $chapters = [];
    $tasks = [];
    foreach (catalog_lines('calling_quests.txt') as $r) {
        if ($r[0] === 'C') {
            [, $slug, $calling, $tier, $title, $mentor, $coins, $xp, $item, $qty, $rtitle, $intro, $outro] = array_pad($r, 13, '');
            if ($slug === '' || !isset(CALLINGS[$calling]) || !in_array((int)$tier, [2, 3], true)) continue;
            $chapters[$slug] = ['slug' => $slug, 'calling' => $calling, 'tier' => (int)$tier, 'title' => $title, 'mentor_slug' => $mentor ?: null,
                'reward_coins' => (int)$coins, 'reward_xp' => (int)$xp, 'reward_item_slug' => $item === '' || $item === '-' ? null : $item,
                'reward_qty' => max(1, (int)$qty), 'reward_title' => $rtitle === '' || $rtitle === '-' ? null : $rtitle,
                'intro' => str_replace('\n', "\n", $intro), 'outro' => str_replace('\n', "\n", $outro), 'active' => 1];
        } elseif ($r[0] === 'T') {
            [, $cslug, $mode, $kind, $spec, $qty, $label] = array_pad($r, 7, '');
            $ok = match ($mode) {
                'event' => in_array($kind, CALLING_EVENT_KINDS, true),
                'state' => in_array($kind, CALLING_STATE_KINDS, true),
                'give' => $kind === 'give',
                default => false,
            };
            if ($ok && $label !== '') $tasks[$cslug][] = ['mode' => $mode, 'kind' => $kind, 'spec' => $spec === '-' ? '' : $spec, 'qty' => max(1, (int)$qty), 'label' => $label];
        }
    }
    $added = 0;
    foreach ($chapters as $slug => $ch) {
        if (q_val('SELECT 1 FROM calling_chapters WHERE slug = ?', [$slug])) continue;
        $cid = db_insert('calling_chapters', $ch);
        foreach ($tasks[$slug] ?? [] as $i => $t) db_insert('calling_tasks', ['chapter_id' => $cid, 'sort_order' => $i + 1] + $t);
        if (!q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['calling:' . $slug])) {
            db_insert('encyclopedia_entries', ['chapter' => 'Callings', 'category' => 'Callings', 'title' => $ch['title'],
                'body' => $ch['outro'], 'unlock_key' => 'calling:' . $slug, 'hint' => 'Finish this chapter with your calling’s mentor.', 'sort_order' => $ch['tier']]);
        }
        $added++;
    }
    ensure_calling_mentors();
    return $added;
}

/** The six mentors: calling => [name, npc slug, species, personality, bio, region code, lodge slug, lodge icon, lodge name, lodge description]. */
const CALLING_MENTORS = [
    'rootwarden' => ['Burdock Deepdelve', 'burdock-deepdelve', 'Mole', 'Warm', 'A broad, patient mole who judges every garden by the smell of its soil. Keeps the Root Cellar for the Rootwardens of Birchbramble Steppe.',
        'EE', 'bb-rootcellar', '🕳️', 'The Root Cellar', 'A cool cellar under the market, shelves of jars, barrels of black earth, and a mole who is always sniffing something. Rootwardens come here to learn their trade.'],
    'bloomcaller' => ['Zinnia Fuzzbottom', 'zinnia-fuzzbottom', 'Bumblebee', 'Cheerful', 'A round, busy bumblebee who has never met a flower she did not like. Runs the Marigold Stall and mentors Bloomcallers.',
        'CA', 'ma-marigold', '🌼', 'The Marigold Stall', 'Buckets of orange marigolds, ribbons, and a faint hum. Bloomcallers come to share flowers and learn their craft.'],
    'thornblade' => ['Captain Bracken Spurwing', 'bracken-spurwing', 'Stag beetle', 'Proud', 'A gleaming stag beetle who keeps watch over Mistmoor from the Old Watchtower and trains Thornblades.',
        'NWE', 'mm-watch', '🗼', 'The Old Watchtower', 'A crooked stone tower with a wide view of the mist. Thornblades report here for training and orders.'],
    'seedkeeper' => ['Sorrel Inkcap', 'sorrel-inkcap', 'Snail', 'Shy', 'A quiet snail librarian with ink-stained eyestalks. Keeps the Seed Library and mentors Seedkeepers, slowly and thoroughly.',
        'SE', 'ow-seedlib', '📚', 'The Seed Library', 'Drawers upon drawers of labelled seeds, and a ladder that goes up further than you can see. Seedkeepers study here.'],
    'wayfinder' => ['Tumble Waymarsh', 'tumble-waymarsh', 'Hare', 'Curious', 'A long-legged hare who knows every crossroads and half the shortcuts. Keeps the Trailmarker’s Hut and mentors Wayfinders.',
        'SA', 'rr-hut', '🧭', 'The Trailmarker’s Hut', 'A little hut papered with maps, with a signpost outside that points in far too many directions. Wayfinders gather here.'],
    'brewroot' => ['Juniper Kettleby', 'juniper-kettleby', 'Hedgehog', 'Chatty', 'A cheerful hedgehog with a permanent apron and opinions about gravy. Runs the Brewhouse and mentors Brewroots.',
        'CB', 'ss-brewhouse', '🍲', 'The Brewhouse', 'Copper kettles, hanging herbs and the smell of something good. Brewroots come to cook and compare recipes.'],
];

/**
 * v0.9.4: the six calling mentors, each with an NPC, a lodge in the town square (a "special" place with a link to mentor.php) and an
 * all-day schedule there. Safe to run again: every piece is only made if it is missing. Returns how many pieces were made.
 */
function ensure_calling_mentors(): int
{
    $made = 0;
    foreach (CALLING_MENTORS as $calling => [$name, $nslug, $species, $pers, $bio, $code, $sslug, $icon, $sname, $sdesc]) {
        $region = q_one('SELECT * FROM regions WHERE code = ?', [$code]);
        if (!$region) continue;
        $town = (string)$region['gnomish_name'];
        $spotId = (int)q_val('SELECT id FROM town_spots WHERE slug = ?', [$sslug]);
        if (!$spotId) {
            $spotId = db_insert('town_spots', ['slug' => $sslug, 'region' => $town, 'kind' => 'special', 'icon' => $icon, 'name' => $sname, 'description' => $sdesc,
                'hours' => '', 'months' => '', 'sort_order' => 8, 'active' => 1]);
            $made++;
        }
        if (!q_val('SELECT 1 FROM town_actions WHERE slug = ?', [$sslug . '-link-mentor'])) {
            db_insert('town_actions', ['spot_id' => $spotId, 'slug' => $sslug . '-link-mentor', 'label' => '📜 Talk to ' . $name . ' (' . (CALLINGS[$calling][0] ?? $calling) . ' chapters)',
                'kind' => 'link', 'link' => 'mentor.php?m=' . $nslug, 'daily' => 0, 'sort_order' => 1, 'active' => 1]);
            $made++;
        }
        $loc = (int)q_val("SELECT id FROM locations WHERE region = ? AND kind = 'market' ORDER BY id LIMIT 1", [$town]);
        $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$nslug]);
        if (!$nid) {
            $nid = db_insert('npcs', ['name' => $name, 'slug' => $nslug, 'species' => $species, 'personality' => $pers, 'bio' => $bio, 'mood' => 70,
                'home_location_id' => $loc ?: null, 'fav_spot_id' => $spotId, 'active' => 1]);
            $made++;
        }
        if (!q_val('SELECT 1 FROM npc_schedules WHERE npc_id = ?', [$nid])) {
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $loc ?: null, 'shop_id' => null, 'spot_id' => $spotId, 'activity' => 'visiting',
                'days' => 'all', 'start_hour' => 0, 'end_hour' => 0]);   // equal hours = all 24
            $made++;
        }
        if (!q_val('SELECT fav_spot_id FROM npcs WHERE id = ?', [$nid])) q('UPDATE npcs SET fav_spot_id = ? WHERE id = ?', [$spotId, $nid]);   // so ensure_npc_lives leaves them alone
    }
    return $made;
}

/** A calling's mentor NPC row (or null if not made yet). */
function calling_mentor(string $calling): ?array
{
    $m = CALLING_MENTORS[$calling] ?? null;
    return $m ? (q_one('SELECT * FROM npcs WHERE slug = ?', [$m[1]]) ?: null) : null;
}

/** v0.9.4: tiers II and III now need the chapter. Nobody keeps a tier they haven't earned (no grace); progress starts at zero. */
function upgrade_094_callings(): void
{
    q('UPDATE users SET calling_qt = 0, calling_chapter = NULL');
    q("UPDATE users SET calling_tier_seen = 1 WHERE calling IS NOT NULL AND calling <> '' AND calling_tier_seen > 1");   // so the tier flash fires again when they earn it back
}

// ------------------------------------------------------------------ chapters and status

function calling_chapter(int $id): ?array
{
    return q_one('SELECT * FROM calling_chapters WHERE id = ?', [$id]) ?: null;
}

function calling_tasks(int $chapterId): array
{
    return q('SELECT * FROM calling_tasks WHERE chapter_id = ? ORDER BY sort_order, id', [$chapterId])->fetchAll();
}

/** A calling's chapters, Journeyman first. */
function calling_chapters_for(string $calling): array
{
    return q('SELECT * FROM calling_chapters WHERE calling = ? AND active = 1 ORDER BY tier, id', [$calling])->fetchAll();
}

/** The chapter this gnome would do next for their calling (the tier after their quest tiers), or null. */
function calling_next_chapter(array $u): ?array
{
    if (empty($u['calling'])) return null;
    return q_one('SELECT * FROM calling_chapters WHERE calling = ? AND tier = ? AND active = 1 ORDER BY id LIMIT 1', [$u['calling'], 2 + (int)($u['calling_qt'] ?? 0)]) ?: null;
}

function calling_level_for_tier(int $tier): int
{
    return (int)setting($tier >= 3 ? 'calling_tier3_level' : 'calling_tier2_level');
}

/** Why this gnome can't start the chapter now, or '' if they can. */
function calling_gate(array $u, array $ch): string
{
    if (setting('calling_quests') !== '1') return 'Calling chapters are switched off.';
    if (empty($u['calling']) || $u['calling'] !== $ch['calling']) return 'This chapter is for the ' . (CALLINGS[$ch['calling']][0] ?? 'another calling') . ' calling.';
    if (!(int)$ch['active']) return 'This chapter isn’t open.';
    $qt = (int)($u['calling_qt'] ?? 0);
    if ((int)$ch['tier'] <= $qt + 1) return 'You’ve already finished this chapter.';
    if ((int)$ch['tier'] > $qt + 2) return 'Finish the Journeyman chapter first.';
    if ((int)$u['level'] < calling_level_for_tier((int)$ch['tier'])) return 'Reach gnome level ' . calling_level_for_tier((int)$ch['tier']) . ' first.';
    $row = q_one('SELECT * FROM user_calling_chapters WHERE user_id = ? AND chapter_id = ?', [$u['id'], $ch['id']]);
    if ($row && $row['done_at']) return 'You’ve already finished this chapter.';
    if (!empty($u['calling_chapter']) && (int)$u['calling_chapter'] !== (int)$ch['id']) return 'Finish the chapter you’re on first.';
    return '';
}

/** Parse "key=a/b,key>=3,key^=pre,distinct=1" into [[key, op, [values]], …]. */
function calling_spec(string $spec): array
{
    $out = [];
    foreach (array_filter(array_map('trim', explode(',', $spec))) as $part) {
        if (preg_match('/^(\w+)(>=|\^=|\$=|=)(.*)$/', $part, $m)) $out[] = [$m[1], $m[2], $m[2] === '=' ? explode('/', $m[3]) : [$m[3]]];
    }
    return $out;
}

/** Does an event match a task's filters? "distinct" is not a filter (handled by the caller). */
function calling_match(array $filters, string $target, array $ctx): bool
{
    foreach ($filters as [$k, $op, $vals]) {
        if ($k === 'distinct') continue;
        $have = $k === 'slug' ? $target : ($ctx[$k] ?? null);
        if ($have === null) return false;
        if (is_bool($have)) $have = $have ? '1' : '0';
        $have = (string)$have;
        if ($op === '>=') { if ((float)$have < (float)$vals[0]) return false; }
        elseif ($op === '^=') { if (!str_starts_with($have, $vals[0])) return false; }
        elseif ($op === '$=') { if (!str_ends_with($have, $vals[0])) return false; }
        elseif (!in_array($have, $vals, true)) return false;
    }
    return true;
}

/** Task rows for the gnome's open chapter that still take events (cached for the request; $forget drops the cache). */
function calling_active_tasks(int $uid, bool $forget = false): array
{
    static $cache = [];
    if ($forget) { unset($cache[$uid]); return []; }
    if (!isset($cache[$uid])) {
        $cid = (int)q_val('SELECT calling_chapter FROM users WHERE id = ?', [$uid]);
        $cache[$uid] = $cid ? q("SELECT t.*, ut.progress, ut.seen FROM calling_tasks t
                                 JOIN user_calling_tasks ut ON ut.task_id = t.id AND ut.user_id = ?
                                 WHERE t.chapter_id = ? AND t.mode = 'event' AND ut.done_at IS NULL ORDER BY t.sort_order", [$uid, $cid])->fetchAll() : [];
    }
    return $cache[$uid];
}

function calling_note(string $msg): void
{
    if (session_status() === PHP_SESSION_ACTIVE) flash($msg);
}

/**
 * Something happened in the game (the same events as job_event(), plus the new hooks). Does nothing, with one cheap
 * query per request, unless the gnome has a calling chapter in progress. Hired helpers and visits don't count:
 * callers pass 'helper' => true in $ctx, or don't call it at all.
 * kinds: harvest water gather cook craft defeat befriend page arrive walk depth wonder haven travel eat sell talk gift tend seed_saved townact
 */
function calling_event(int $uid, string $kind, string $target = '', int $n = 1, array $ctx = []): void
{
    if ($uid <= 0 || !empty($ctx['helper'])) return;
    if ($n > 0 && $kind !== 'grade') { require_once __DIR__ . '/hollow_goals.php'; hollow_goal_event($uid, $kind, $target, $n, $ctx); }   // v1.0.0 wave 3: the Hollow's weekly jar (and any festival jar) listens to every event
    if ($n <= 0 && !in_array($kind, CALLING_MAX_KINDS, true)) return;
    // v0.9.4: meals only. A snack never counts; an eat needs a Meal or Feast tier (raw food has none); a cook without a tier is an older emitter
    $tier = $ctx['tier'] ?? null;
    if ($kind === 'cook' && $tier !== null && !in_array($tier, ['meal', 'feast'], true)) return;
    if ($kind === 'eat' && !in_array($tier, ['meal', 'feast'], true)) return;
    $changed = false;
    foreach (calling_active_tasks($uid) as $t) {
        if ($t['kind'] !== $kind) continue;
        $filters = calling_spec((string)$t['spec']);
        if (!calling_match($filters, $target, $ctx)) continue;
        $goal = max(1, (int)$t['qty']);
        $old = (int)$t['progress'];
        $seen = null;
        if (array_filter($filters, fn($f) => $f[0] === 'distinct')) {   // different targets, e.g. 4 different dishes
            if ($target === '') continue;
            $list = json_decode((string)$t['seen'], true) ?: [];
            if (in_array($target, $list, true)) continue;
            $list[] = $target;
            $seen = json_encode(array_slice($list, -300));
            $new = min($goal, count($list));
        } elseif (in_array($kind, CALLING_MAX_KINDS, true)) {
            $new = min($goal, max($old, $n));
        } else {
            $new = min($goal, $old + $n);
        }
        if ($new === $old && $seen === null) continue;
        q('UPDATE user_calling_tasks SET progress = ?, seen = COALESCE(?, seen), done_at = ? WHERE user_id = ? AND task_id = ? AND done_at IS NULL',
            [$new, $seen, $new >= $goal ? now() : null, $uid, $t['id']]);
        $changed = true;
        if ($new >= $goal) calling_note('📜 Calling task done: ' . $t['label']);
    }
    if ($changed) calling_active_tasks($uid, true);
}

/** [now, goal] for a state task, read from the game as it is. */
function calling_task_value(array $u, array $t): array
{
    $uid = (int)$u['id'];
    $goal = max(1, (int)$t['qty']);
    $spec = (string)$t['spec'];
    switch ($t['kind']) {
        case 'grade':   // the best no-till bed has reached grade index qty (4 = C, 8 = A, 10 = S)
            require_once __DIR__ . '/jobs.php';
            $now = max(0, best_bed_grade($uid)) ;
            return [min($now, $goal), $goal];
        case 'beds':   // qty no-till beds at grade index spec or better
            require_once __DIR__ . '/garden_logic.php';
            $now = (int)q_val("SELECT COUNT(*) FROM plot_tiles WHERE user_id = ? AND method = 'notill' AND bed_score >= ?", [$uid, (int)$spec * GRADE_STEP]);
            return [min($now, $goal), $goal];
        case 'regions':   // visited regions: qty of them, or all of the listed codes (spec "EA,SEA")
            require_once __DIR__ . '/progression.php';
            $been = visited_regions($uid);
            if ($spec !== '') {
                $codes = array_filter(array_map('trim', explode(',', $spec)));
                $now = 0;
                foreach ($codes as $c) if (in_array((int)q_val('SELECT id FROM regions WHERE code = ?', [strtoupper($c)]), $been, true)) $now++;
                return [$now, count($codes)];
            }
            return [min(count($been), $goal), $goal];
        case 'places':   // hidden places found (spec: any|village|haven|wonder|delve|lair)
            require_once __DIR__ . '/roads.php';
            $now = 0;
            foreach (q("SELECT DISTINCT l.*, lm.kind AS lm_kind FROM locations l JOIN routes r ON r.b_id = l.id AND r.kind = 'side'
                        LEFT JOIN landmarks lm ON lm.location_id = l.id")->fetchAll() as $l) {
                $kind = $l['kind'] === 'village' ? 'village' : (string)$l['lm_kind'];
                if (($spec === '' || $spec === 'any' || $spec === $kind) && place_known($uid, $l)) $now++;
            }
            return [min($now, $goal), $goal];
        case 'clears':   // different delves or lairs cleared (spec: delve|lair|any)
            $kinds = $spec === 'delve' || $spec === 'lair' ? [$spec] : ['delve', 'lair'];
            $now = (int)q_val("SELECT COUNT(*) FROM landmark_clears lc JOIN landmarks lm ON lm.id = lc.landmark_id
                               WHERE lc.user_id = ? AND lc.clears > 0 AND lm.kind IN ('" . implode("','", $kinds) . "')", [$uid]);
            return [min($now, $goal), $goal];
        case 'friends':   // folk at friend level N (spec "1" Acquaintance, "2" Friend, "3" Good friend; "2@Mistmoor" = only that region's folk)
            require_once __DIR__ . '/friends.php';
            [$lvl, $region] = array_pad(explode('@', $spec, 2), 2, '');
            $min = FRIEND_LEVELS[max(1, min(count(FRIEND_LEVELS) - 1, (int)$lvl ?: 1))][0];
            if ($region !== '') {
                $now = (int)q_val('SELECT COUNT(*) FROM npc_friends f JOIN npcs n ON n.id = f.npc_id JOIN town_spots s ON s.id = n.fav_spot_id
                                   WHERE f.user_id = ? AND f.points >= ? AND s.region = ?', [$uid, $min, $region]);
            } else {
                $now = (int)q_val('SELECT COUNT(*) FROM npc_friends WHERE user_id = ? AND points >= ?', [$uid, $min]);
            }
            return [min($now, $goal), $goal];
        case 'mastered':   // plants studied to full knowledge (spec: a plant kind, optional)
        case 'known':      // plants harvested at least once (spec: a plant kind, optional)
            $kindSql = $spec !== '' ? ' AND p.kind = ' . db()->quote($spec) : '';
            $cmp = $t['kind'] === 'mastered' ? 'k.knowledge >= p.knowledge_max' : 'k.knowledge > 0';
            $now = (int)q_val("SELECT COUNT(*) FROM user_plant_knowledge k JOIN plants p ON p.id = k.plant_id WHERE k.user_id = ? AND $cmp$kindSql", [$uid]);
            return [min($now, $goal), $goal];
        case 'guides':   // regional gardening guides studied
            return [min((int)q_val("SELECT COUNT(*) FROM user_guides WHERE user_id = ? AND guide_key LIKE 'region:%'", [$uid]), $goal), $goal];
        case 'recipes':
            return [min((int)q_val('SELECT COUNT(*) FROM user_recipes WHERE user_id = ?', [$uid]), $goal), $goal];
        case 'roads':   // whole roads walked: every stop known (spec: part of the road's name, optional)
            require_once __DIR__ . '/roads.php';
            $now = 0;
            foreach (q('SELECT * FROM roads' . ($spec !== '' ? ' WHERE name LIKE ?' : ''), $spec !== '' ? ['%' . $spec . '%'] : [])->fetchAll() as $road) {
                $all = true;
                foreach (json_decode((string)$road['nodes'], true) ?: [] as $lid) {
                    $loc = q_one('SELECT * FROM locations WHERE id = ?', [$lid]);
                    if (!$loc || !place_known($uid, $loc)) { $all = false; break; }
                }
                if ($all) $now++;
            }
            return [min($now, $goal), $goal];
    }
    return [0, $goal];
}

/**
 * Where a gnome stands in a chapter.
 * ['state' => locked|available|active|done, 'why' => gate reason, 'row' => user_calling_chapters|null,
 *  'tasks' => [['task' => row, 'now' => n, 'goal' => n, 'done' => bool], …], 'work_done' => bool (every event and state task),
 *  'give_next' => task|null, 'complete' => bool (everything done, ready to finish)]
 */
function calling_status(array $u, array $ch): array
{
    $uid = (int)$u['id'];
    $row = q_one('SELECT * FROM user_calling_chapters WHERE user_id = ? AND chapter_id = ?', [$uid, $ch['id']]) ?: null;
    $prog = [];
    foreach (q('SELECT * FROM user_calling_tasks WHERE user_id = ? AND task_id IN (SELECT id FROM calling_tasks WHERE chapter_id = ?)', [$uid, $ch['id']])->fetchAll() as $p) $prog[(int)$p['task_id']] = $p;
    $out = ['row' => $row, 'tasks' => [], 'work_done' => true, 'give_next' => null, 'complete' => false, 'why' => '', 'state' => 'locked'];
    foreach (calling_tasks((int)$ch['id']) as $t) {
        $p = $prog[(int)$t['id']] ?? null;
        $goal = max(1, (int)$t['qty']);
        if ($t['mode'] === 'give') {
            $done = $p && $p['done_at'];
            $out['tasks'][] = ['task' => $t, 'now' => $done ? 1 : 0, 'goal' => 1, 'done' => (bool)$done];
            if (!$done && !$out['give_next']) $out['give_next'] = $t;
            continue;
        }
        if ($t['mode'] === 'state') {
            [$now, $goal] = calling_task_value($u, $t);
            $done = $now >= $goal;
        } else {
            $now = $p ? min($goal, (int)$p['progress']) : 0;
            $done = $p ? ($p['done_at'] || $now >= $goal) : false;
        }
        if (!$done) $out['work_done'] = false;
        $out['tasks'][] = ['task' => $t, 'now' => $now, 'goal' => $goal, 'done' => (bool)$done];
    }
    $out['complete'] = $row && !$row['done_at'] && $out['work_done'] && !$out['give_next'];
    if ($row && $row['done_at']) $out['state'] = 'done';
    elseif ($row) $out['state'] = 'active';
    else {
        $out['why'] = calling_gate($u, $ch);
        $out['state'] = $out['why'] === '' ? 'available' : 'locked';
    }
    return $out;
}

// ------------------------------------------------------------------ starting, handing in, finishing

/** Accept a chapter from the mentor (or pick it back up after switching callings: progress was kept). */
function calling_start(array $u, int $chapterId): array
{
    $uid = (int)$u['id'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $ch = calling_chapter($chapterId);
    if (!$u || !$ch) return [false, 'There’s no such chapter.'];
    $why = calling_gate($u, $ch);
    if ($why !== '') return [false, $why];
    db()->beginTransaction();
    try {
        if (!q_val('SELECT 1 FROM user_calling_chapters WHERE user_id = ? AND chapter_id = ?', [$uid, $chapterId])) {
            db_insert('user_calling_chapters', ['user_id' => $uid, 'chapter_id' => $chapterId, 'started_at' => now()]);
        }
        foreach (calling_tasks($chapterId) as $t) {
            if ($t['mode'] === 'state') continue;
            if (!q_val('SELECT 1 FROM user_calling_tasks WHERE user_id = ? AND task_id = ?', [$uid, $t['id']])) {
                db_insert('user_calling_tasks', ['user_id' => $uid, 'task_id' => $t['id'], 'progress' => 0]);
            }
        }
        q('UPDATE users SET calling_chapter = ? WHERE id = ?', [$chapterId, $uid]);
        db()->commit();
    } catch (Throwable $e) {
        if (db()->inTransaction()) db()->rollBack();
        return [false, 'Something went wrong; try again.'];
    }
    calling_active_tasks($uid, true);
    return [true, '📜 You take on the chapter: ' . $ch['title'] . '.'];
}

/** Hand in the next give task (once every other task is done). */
function calling_hand_in(array $u, int $chapterId): array
{
    require_once __DIR__ . '/journey.php';   // the hand-in helpers are shared with Wren's Journey
    require_once __DIR__ . '/rebuild.php';
    $uid = (int)$u['id'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $ch = calling_chapter($chapterId);
    if (!$u || !$ch) return [false, 'There’s no such chapter.'];
    $st = calling_status($u, $ch);
    if (!$st['row']) return [false, 'Take the chapter on first.'];
    if ($st['row']['done_at']) return [false, 'You’ve already finished this chapter.'];
    if (!$st['work_done']) return [false, 'Finish the tasks above first.'];
    $give = $st['give_next'];
    if (!$give) return [false, 'There’s nothing left to hand in. Finish the chapter!'];
    foreach (journey_need_status($u, (string)$give['spec']) as [$label, $need, $have]) {
        if ($have < $need) return [false, 'You need ' . $need . ' × ' . $label . ' (you have ' . $have . ').'];
    }
    db()->beginTransaction();
    foreach (journey_needs((string)$give['spec']) as $need) {
        [$type, , $qty] = $need;
        if ($type === 'coins') {
            if (q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$qty, $uid, $qty])->rowCount() !== 1) { db()->rollBack(); return [false, 'You need ' . money($qty) . '.']; }
            continue;
        }
        $left = $qty;
        foreach (rebuild_supply($uid, $need) as $it) {
            $take = min($left, (int)$it['qty']);
            if ($take > 0 && !give_item($uid, (int)$it['id'], -$take)) { db()->rollBack(); return [false, 'Something went missing from your satchel.']; }
            $left -= $take;
            if ($left <= 0) break;
        }
        if ($left > 0) { db()->rollBack(); return [false, 'You don’t have enough for this.']; }
    }
    $ok = q('UPDATE user_calling_tasks SET progress = 1, done_at = ? WHERE user_id = ? AND task_id = ? AND done_at IS NULL', [now(), $uid, $give['id']])->rowCount() === 1;
    if (!$ok) { db()->rollBack(); return [false, 'That’s already handed in.']; }
    db()->commit();
    return [true, '📦 Handed in: ' . preg_replace('/\s*\(.*\)$/', '', (string)$give['label']) . '.'];
}

/** Finish a chapter: pay, earn the tier, title, Almanac page. */
function calling_finish(array $u, int $chapterId): array
{
    $uid = (int)$u['id'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $ch = calling_chapter($chapterId);
    if (!$u || !$ch) return [false, 'There’s no such chapter.'];
    $st = calling_status($u, $ch);
    if (!$st['complete']) return [false, 'There’s still something to do in this chapter.'];
    db()->beginTransaction();
    if (q('UPDATE user_calling_chapters SET done_at = ? WHERE id = ? AND done_at IS NULL', [now(), $st['row']['id']])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'You’ve already finished this chapter.'];
    }
    $lines = [];
    if ((int)$ch['reward_coins'] > 0) { q('UPDATE users SET coins = coins + ? WHERE id = ?', [(int)$ch['reward_coins'], $uid]); $lines[] = '+' . money((int)$ch['reward_coins']); }
    if ($ch['reward_item_slug'] && ($iid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$ch['reward_item_slug']]))) {
        give_item($uid, $iid, max(1, (int)$ch['reward_qty']));
        $lines[] = '+' . max(1, (int)$ch['reward_qty']) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]);
    }
    db()->commit();
    calling_resync($uid);   // calling_qt goes up, the open chapter is cleared
    $new = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    $tier = calling_tier($new);
    if ($tier > (int)$new['calling_tier_seen']) q('UPDATE users SET calling_tier_seen = ? WHERE id = ?', [$tier, $uid]);   // announced here, not again by the page header
    $xp = (int)round((int)$ch['reward_xp'] * (int)setting('calling_xp_percent') / 100);
    if ($xp > 0) { add_xp($uid, $xp, 'Calling chapters'); $lines[] = '+' . $xp . ' XP'; }
    unlock_entries($uid, 'calling:' . $ch['slug']);
    if ($ch['reward_title']) $lines[] = '🎩 New title: “' . $ch['reward_title'] . '” (choose it in your Almanac → Milestones)';
    prize('🎩', 'Chapter complete: ' . $ch['title'], 'You are now a ' . calling_tier_name($tier) . ' ' . (CALLINGS[$ch['calling']][0] ?? '') . '!', $lines);
    return [true, ''];
}

/**
 * Re-read this gnome's calling progress after a finish or a change of calling: calling_qt from the chapters finished for the
 * CURRENT calling (progress under other callings is kept, just not used), the open chapter of this calling, and the tier already announced.
 */
function calling_resync(int $uid): void
{
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]);
    if (!$u) return;
    $qt = 0;
    $open = null;
    if (!empty($u['calling'])) {
        $done = array_map('intval', q('SELECT c.tier FROM user_calling_chapters uc JOIN calling_chapters c ON c.id = uc.chapter_id
                                       WHERE uc.user_id = ? AND uc.done_at IS NOT NULL AND c.calling = ?', [$uid, $u['calling']])->fetchAll(PDO::FETCH_COLUMN));
        if (in_array(2, $done, true)) $qt = in_array(3, $done, true) ? 2 : 1;
        $open = q_val('SELECT c.id FROM user_calling_chapters uc JOIN calling_chapters c ON c.id = uc.chapter_id
                       WHERE uc.user_id = ? AND uc.done_at IS NULL AND c.calling = ? AND c.tier = ?', [$uid, $u['calling'], $qt + 2]) ?: null;
    }
    q('UPDATE users SET calling_qt = ?, calling_chapter = ? WHERE id = ?', [$qt, $open, $uid]);
    $u['calling_qt'] = $qt;
    $tier = calling_tier($u);
    if ((int)$u['calling_tier_seen'] > $tier) q('UPDATE users SET calling_tier_seen = ? WHERE id = ?', [$tier, $uid]);
    calling_qt_cached($uid, true);
    calling_active_tasks($uid, true);
}

/** Titles earned from finished calling chapters (offered alongside milestone and Journey titles). */
function calling_titles(int $uid): array
{
    return q("SELECT DISTINCT c.reward_title FROM user_calling_chapters uc JOIN calling_chapters c ON c.id = uc.chapter_id
              WHERE uc.user_id = ? AND uc.done_at IS NOT NULL AND c.reward_title IS NOT NULL AND c.reward_title <> ''", [$uid])->fetchAll(PDO::FETCH_COLUMN);
}

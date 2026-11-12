<?php
declare(strict_types=1);

/**
 * Trail Sights, the rest of the plan (P2b + P3; claude/plan-trail-sights.md): names and captions, the items the Sights hand out, the Almanac "Sights" chapter,
 * quest lines made of Sight uses, and villagers who turn up at a Sight.
 * Data files (all in includes/data/):
 *   trail_sight_info.txt    slug | Name | caption                                  (what the Sight card and the Almanac page say)
 *   trail_sight_items.txt   slug | Name | category | rarity | base_price | edible | description | effects (optional JSON: {"decor":{...}} for yard decor, {"temp":{"charm":1,"minutes":120}} for something you eat or use) | tradable (optional, 0 = a quest item that cannot be sold, listed or given as a present)
 *   trail_sight_quests.txt  Q|slug|title|giver|icon|order(seq|any)|reward|intro|outro      then      B|slug|sight slug|label|when
 *   trail_sight_folk.txt    sight slug | Villager name | when | chance % | line | rewards (the Sight's reward grammar; fp=N = N friendship with that villager)
 */

// ---------------------------------------------------------------- names, captions

/** The data files of one kind: data/trail_sight_<kind>.txt and every data/trail_sight_<kind>_*.txt (one per set: maplewold, shared, end), or the test override. */
function trail_sight_data_files(string $kind, ?string $file = null): array
{
    if ($file !== null) return [$file];
    if (!empty($GLOBALS['gv_sight_' . $kind . '_file'])) return [$GLOBALS['gv_sight_' . $kind . '_file']];
    return array_merge([__DIR__ . '/data/trail_sight_' . $kind . '.txt'], glob(__DIR__ . '/data/trail_sight_' . $kind . '_*.txt') ?: []);
}

function trail_sight_data_lines(string $kind, ?string $file = null): array
{
    $out = [];
    foreach (trail_sight_data_files($kind, $file) as $f) foreach (is_file($f) ? (file($f, FILE_IGNORE_NEW_LINES) ?: []) : [] as $l) { $l = trim($l); if ($l !== '' && $l[0] !== '#') $out[] = $l; }
    return $out;
}


/** [slug => [name, caption]] from data/trail_sight_info.txt; a Sight with no row gets a name made from its slug and no caption. */
function trail_sight_info(?string $file = null): array
{
    static $c = [];
    $key = implode(',', trail_sight_data_files('info', $file)); $key .= '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, trail_sight_data_files('info', $file)));
    if (isset($c[$key])) return $c[$key];
    $out = [];
    foreach (trail_sight_data_lines('info', $file) as $l) {
        $p = array_map('trim', explode('|', $l, 3));
        if (count($p) >= 2 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2] ?? ''];
    }
    return $c[$key] = $out;
}

/** The name and caption of a Sight (see trail_sight_info). */
function trail_sight_label(string $slug): array
{
    $i = trail_sight_info()[$slug] ?? null;
    if ($i) return $i;
    $n = preg_replace('/^(\d+|end|[a-z]+)-(the-)?/', '', $slug);
    return [ucfirst(str_replace('-', ' ', (string)$n)), ''];
}

// ---------------------------------------------------------------- items

/** Does an item with this slug exist, or will the Sights items file make it? (the lint uses this so a fresh install can be checked) */
function trail_sight_item_known(string $slug): bool
{
    if (isset(trail_sight_items_file()[$slug])) return true;
    try { return (bool)q_val('SELECT id FROM items WHERE slug = ?', [$slug]); } catch (Throwable $e) { return false; }
}

/** [slug => [name, category, rarity, price, edible, description]] from data/trail_sight_items.txt. */
function trail_sight_items_file(?string $file = null): array
{
    static $c = [];
    $key = implode(',', trail_sight_data_files('items', $file)); $key .= '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, trail_sight_data_files('items', $file)));
    if (isset($c[$key])) return $c[$key];
    $out = [];
    foreach (trail_sight_data_lines('items', $file) as $l) {
        $p = array_map('trim', explode('|', $l, 9));
        if (count($p) >= 7 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2], max(1, (int)$p[3]), max(0, (int)$p[4]), (int)$p[5] ? 1 : 0, $p[6], $p[7] ?? '', ($p[8] ?? '1') === '0' ? 0 : 1];
    }
    return $c[$key] = $out;
}

/** Make the items only Sights give. Adds only; an item that exists (or was edited in Admin) is left alone. Returns how many were added. */
function trail_sights_ensure_items(): int
{
    $sig = md5(implode(',', array_map(fn($f) => basename($f) . filemtime($f), glob(__DIR__ . '/data/trail_sight_items*.txt') ?: [])));
    if (empty($GLOBALS['gv_sight_items_file']) && setting('sight_items_sig') === $sig) return 0;   // already made for these files (a use does not look at 100 items each time)
    $n = 0;
    foreach (trail_sight_items_file() as $slug => [$name, $cat, $rar, $price, $edible, $desc, $fx, $trad]) {
        try {
            if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
            db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'rarity' => $rar, 'base_price' => $price, 'description' => $desc, 'edible' => $edible, 'effects' => $fx !== '' ? $fx : null, 'tradable' => $trad]);
            $n++;
        } catch (Throwable $e) { /* made by another request, or no items table */ }
    }
    if (empty($GLOBALS['gv_sight_items_file'])) { try { set_setting('sight_items_sig', $sig); } catch (Throwable $e) {} }
    return $n;
}

/** A short-lived lock in the settings (60 s): true if this request may do the work, false if another started it a moment ago. (The Almanac pages have no unique key: two requests would double them.) */
function trail_sight_claim(string $name): bool
{
    $now = time();
    try {   // atomic: only the request whose UPDATE (or first INSERT) really lands may go on; setting() is a per-request cache and would not see another request
        if (q('UPDATE settings SET value = ? WHERE name = ? AND (value = ? OR value < ?)', [(string)$now, $name, '', (string)($now - 60)])->rowCount() === 1) return true;
        if (q_val('SELECT 1 FROM settings WHERE name = ?', [$name])) return false;
        db_insert('settings', ['name' => $name, 'value' => (string)$now]);
        return true;
    } catch (Throwable $e) { return false; }
}

// ---------------------------------------------------------------- the Almanac "Sights" chapter

/** The Almanac category a Sight's page sits in. */
function trail_sight_category(string $slug): string
{
    if (str_starts_with($slug, 'end-')) return 'The way ahead';
    if (preg_match('/^(\d+)-/', $slug) || in_array($slug, ['haybales', 'scarecrow', 'ford', 'pondmill', 'apple', 'hedgerow'], true)) return 'Maplewold';
    return ucfirst(explode('-', $slug)[0]);
}

/**
 * One locked Almanac page per Sight (chapter "Sights", unlock key `sight:<slug>`), made once and again when the Sights list or its texts change.
 * The page opens the first time the Sight is used. Pages that exist are not rewritten, so an admin edit stands.
 */
function trail_sights_ensure_almanac(): void
{
    $sig = md5(implode(',', array_map(fn($f) => basename($f) . filemtime($f), array_merge(glob(__DIR__ . '/data/trail_sight*.txt') ?: [], [__FILE__]))));   // cheap: the data files and this file unchanged = nothing to do
    if (setting('almanac_sights') === $sig) return;
    if (!trail_sight_claim('almanac_sights_lock')) return;   // another request is making the pages
    require_once __DIR__ . '/gathering.php'; require_once __DIR__ . '/tools.php';   // GATHER_TOOL_NOUN, TOOL_TIERS
    $rows = trail_sights_all(null, false);
    $sort = 0;
    foreach ($rows as $r) {
        $sort++;
        try {
            if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['sight:' . $r['slug']])) continue;
            [$name, $cap] = trail_sight_label($r['slug']);
            $body = $r['icon'] . ' ' . ($cap !== '' ? $cap : $name) . "\n\n[b]What you can do:[/b] " . $r['verb'] . '.'
                . ($r['tool'] !== '-' ? ' You need a ' . (GATHER_TOOL_NOUN[explode(':', $r['tool'])[0]] ?? 'tool') . '.' : '')
                . ($r['check'] !== '-' ? ' It takes a steady hand (a ' . explode(':', $r['check'])[0] . ' check).' : '')
                . "\n\nStand next to it on the Trail to try.";
            db_insert('encyclopedia_entries', ['chapter' => 'Sights', 'category' => trail_sight_category($r['slug']), 'title' => $name, 'body' => $body,
                'unlock_key' => 'sight:' . $r['slug'], 'hint' => 'A big landmark on the Trail. Use it to learn about it.', 'sort_order' => $sort]);
        } catch (Throwable $e) { /* made by another request, or no Almanac yet */ }
    }
    set_setting('almanac_sights', $sig);
}

// ---------------------------------------------------------------- quest lines

/**
 * [quest slug => ['slug','title','giver','icon','order','reward','intro','outro','gate','beats' => [[sight slug | '@kind:arg', label, when, needs]]]] from data/trail_sight_quests.txt.
 * Q|slug|title|giver|icon|order (seq | any | anylast = any order, the last beat only when all the others are done)|reward|intro|outro|gate (optional: quest:<slug> = only after that line is done)
 * B|slug|Sight slug OR @kind:arg|label|when|needs (optional take=item:qty, used up when the beat counts)
 * @kinds: @boss (a lair boss defeated or befriended; arg = lair slug or blank for any), @meal (a home-cooked meal eaten), @friend:<Name[@village]> (that villager is at least an acquaintance).
 */
function trail_sight_quests(?string $file = null): array
{
    static $c = [];
    $key = implode(',', trail_sight_data_files('quests', $file)); $key .= '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, trail_sight_data_files('quests', $file)));
    if (isset($c[$key])) return $c[$key];
    $out = [];
    foreach (trail_sight_data_lines('quests', $file) as $l) {
        $p = array_map('trim', explode('|', $l));
        if ($p[0] === 'Q' && count($p) >= 9 && preg_match('/^[a-z0-9-]+$/', $p[1])) $out[$p[1]] = ['slug' => $p[1], 'title' => $p[2], 'giver' => $p[3], 'icon' => $p[4], 'order' => in_array($p[5], ['any', 'anylast'], true) ? $p[5] : 'seq',
            'reward' => $p[6], 'intro' => $p[7], 'outro' => $p[8], 'gate' => $p[9] ?? '', 'beats' => []];
        elseif ($p[0] === 'B' && count($p) >= 4 && isset($out[$p[1]])) $out[$p[1]]['beats'][] = [$p[2], $p[3], ($p[4] ?? '') === '' ? '-' : $p[4], $p[5] ?? ''];
    }
    return $c[$key] = $out;
}

/** Problems with a quest line: unknown Sight, empty line, bad reward, bad gate / beat kind / needs. */
function trail_sight_quest_lint(array $q, array $sights, array $allQuests = []): array
{
    $bad = [];
    if (count($q['beats']) < 2) $bad[] = 'fewer than 2 beats';
    foreach ($q['beats'] as [$s, $label, $when, $needs]) {
        if ($s !== '' && $s[0] === '@') { if (!preg_match('/^@(boss|meal|friend)(:[A-Za-z0-9@ \'-]*)?$/', $s)) $bad[] = 'bad beat kind ' . $s; }
        elseif (!isset($sights[$s])) $bad[] = 'beat on unknown Sight ' . $s;
        if ($label === '') $bad[] = 'a beat has no label';
        if ($when !== '-') foreach (explode('/', $when) as $part) if (!preg_match(TRAIL_SIGHT_COND_RE, trim($part))) $bad[] = 'bad beat condition ' . $part;
        if ($needs !== '' && !preg_match('/^take=[a-z0-9-]+(:\d+)?$/', $needs)) $bad[] = 'bad beat needs ' . $needs;
        elseif ($needs !== '' && !trail_sight_item_known(explode(':', substr($needs, 5))[0])) $bad[] = 'beat needs unknown item ' . $needs;
    }
    if ($q['gate'] !== '' && (!preg_match('/^quest:([a-z0-9-]+)$/', $q['gate'], $m) || ($allQuests && !isset($allQuests[$m[1]])))) $bad[] = 'bad gate ' . $q['gate'];
    elseif ($q['gate'] !== '' && $allQuests) {   // a gate loop (A waits for B waits for A) could never begin
        $seen = [$q['slug']]; $g = $q['gate'];
        while ($g !== '' && preg_match('/^quest:([a-z0-9-]+)$/', $g, $gm)) { if (in_array($gm[1], $seen, true)) { $bad[] = 'gate loop through ' . $gm[1]; break; } $seen[] = $gm[1]; $g = $allQuests[$gm[1]]['gate'] ?? ''; }
    }
    if ($q['title'] === '' || $q['intro'] === '' || $q['outro'] === '') $bad[] = 'title, intro and outro are all needed';
    $probe = ['slug' => 'x', 'verb' => 'x', 'icon' => 'x', 'energy' => 0, 'cd' => 55, 'uses' => 1, 'when' => '-', 'check' => '-', 'rewards' => $q['reward'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0];
    foreach (trail_sight_lint($probe, true) as $p) if (!str_starts_with($p, 'no landmark picture')) $bad[] = 'reward: ' . $p;
    return $bad;
}

function trail_sight_quest_row(int $uid, string $qslug): ?array
{
    try { return q_one('SELECT * FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$uid, $qslug]) ?: null; } catch (Throwable $e) { return null; }
}

/** A stable id per beat (the Sight or @kind, and which occurrence of it in the line): stored progress survives a data edit that adds, drops or moves beats. */
function trail_sight_beat_ids(array $q): array
{
    $ids = []; $seen = [];
    foreach ($q['beats'] as $i => $b) { $seen[$b[0]] = ($seen[$b[0]] ?? 0) + 1; $ids[$i] = $b[0] . '#' . $seen[$b[0]]; }
    return $ids;
}

/** The beats done so far (indexes into the line's beats). Stored as beat ids; an older row holding integer indexes or Sight slugs is understood; anything that no longer exists is dropped. */
function trail_sight_quest_done(array $q, ?array $row): array
{
    if (!$row) return [];
    $d = json_decode((string)$row['beats'], true) ?: [];
    $ids = trail_sight_beat_ids($q); $n = count($q['beats']); $out = [];
    foreach ($d as $v) {
        $i = null;
        if (is_int($v)) $i = $v < $n ? $v : null;
        elseif (is_string($v)) { $k = array_search($v, $ids, true); if ($k !== false) $i = (int)$k; else foreach ($q['beats'] as $bi => $b) if ($b[0] === $v) { $i = $bi; break; } }
        if ($i !== null && !in_array($i, $out, true)) $out[] = $i;
    }
    return $out;
}

/** The progress as stored: the ids of the done beats. */
function trail_sight_quest_store(array $q, array $done): string
{
    $ids = trail_sight_beat_ids($q);
    return json_encode(array_values(array_map(fn($i) => $ids[$i], $done)));
}

/** May beat $i count now? seq: it is the next (the first not done); anylast: any not-done, the last only after all others; any: any not-done. */
function trail_sight_beat_open(array $q, array $done, int $i): bool
{
    if (in_array($i, $done, true)) return false;
    $n = count($q['beats']);
    if ($q['order'] === 'seq') { $next = 0; while (in_array($next, $done, true)) $next++; return $i === $next; }
    return $q['order'] === 'anylast' ? ($i < $n - 1 || count($done) >= $n - 1) : true;
}

/** An item the beat asks for: [item id, qty, name] or null. */
function trail_sight_beat_need(array $b): ?array
{
    if ($b[3] === '') return null;
    [$sl, $qt] = array_pad(explode(':', substr($b[3], 5), 2), 2, '1');
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$sl]);
    return $id ? [$id, max(1, (int)$qt), (string)q_val('SELECT name FROM items WHERE id = ?', [$id])] : null;
}

/** Is the quest table there (before "Upgrade database" it is not: then nothing is counted and nothing is used up)? Once per request. */
function trail_sight_quest_table_ok(): bool
{
    static $ok = null;
    if ($ok === null) { try { q('SELECT 1 FROM user_sight_quests LIMIT 1'); $ok = true; } catch (Throwable $e) { $ok = false; } }
    return $ok;
}

/** Finish a line exactly once: only the request that really sets done_at pays. Returns the journal line or ''. */
function trail_sight_quest_finish(array $u, array $q, array $loc, ?array $now = null): string
{
    if (q('UPDATE user_sight_quests SET done_at = ? WHERE user_id = ? AND quest = ? AND done_at IS NULL', [now(), (int)$u['id'], $q['slug']])->rowCount() !== 1) return '';
    $lines = trail_sight_pay($u, $loc, $q['reward'], $q['giver'], $now);
    return '🎉 ' . $q['title'] . ' is done! ' . $q['outro'] . ($lines ? ' (' . implode(', ', $lines) . ')' : '');
}

/**
 * A Sight was used successfully (or a quest event happened: $slug = '@boss:lair-slug' ...): tick the quest lines it is a beat of. A line begins the first time one of its
 * beats counts (and its gate is done). Returns journal lines (a quest began, a beat done, a quest finished with its reward). Progress is written with a compare-and-set, the
 * beat's item is used up only after the write won, and a line is paid once.
 */
function trail_sight_quest_hook(array $u, string $slug, array $loc, array $now): array
{
    $out = [];
    if (!trail_sight_quest_table_ok()) return [];
    $uid = (int)$u['id'];
    $all = trail_sight_quests();
    if ($slug !== '' && $slug[0] !== '@') {   // @friend:<Name> beats count once that villager is an acquaintance: look at them whenever a Sight is used
        foreach ($all as $q2) foreach ($q2['beats'] as $b2) if (str_starts_with($b2[0], '@friend:') && trail_sight_friend_known($uid, substr($b2[0], 8))) { $extra = trail_sight_quest_hook($u, $b2[0], $loc, $now); if ($extra) $out = array_merge($out, $extra); }
    }
    foreach ($all as $q) {
        if ($q['gate'] !== '' && preg_match('/^quest:([a-z0-9-]+)$/', $q['gate'], $gm)) { $gr = trail_sight_quest_row($uid, $gm[1]); if (!$gr || $gr['done_at'] === null) continue; }
        $row = trail_sight_quest_row($uid, $q['slug']);
        if ($row && $row['done_at'] !== null) continue;
        $done = trail_sight_quest_done($q, $row);
        if ($row && count($done) >= count($q['beats'])) { $fl = trail_sight_quest_finish($u, $q, $loc, $now); if ($fl !== '') $out[] = $fl; continue; }   // a line whose beats were all done before a data edit: finish it now
        $idx = null; $needMissing = null;
        foreach ($q['beats'] as $i => $b) {
            $hit = $b[0] === $slug || ($b[0] !== '' && $b[0][0] === '@' && $slug !== '' && $slug[0] === '@' && trail_sight_event_match($b[0], $slug));
            if (!$hit || !trail_sight_beat_open($q, $done, $i)) continue;
            if ($b[2] !== '-' && !trail_sight_cond_ok($b[2], $now)) continue;
            if (($nd = trail_sight_beat_need($b)) && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $nd[0]]) < $nd[1]) { $needMissing = $needMissing ?? [$q['title'], $nd]; continue; }   // say what is missing, try another beat
            $idx = $i; break;
        }
        if ($idx === null) { if ($needMissing) $out[] = '📜 ' . $needMissing[0] . ': this step needs ' . $needMissing[1][1] . ' × ' . $needMissing[1][2] . '.'; continue; }
        $need = trail_sight_beat_need($q['beats'][$idx]);
        $new = array_merge($done, [$idx]); $oldJson = $row ? (string)$row['beats'] : '[]'; $newJson = trail_sight_quest_store($q, $new);
        try {
            if (!$row) { try { db_insert('user_sight_quests', ['user_id' => $uid, 'quest' => $q['slug'], 'beats' => '[]', 'started_at' => now(), 'done_at' => null]); $out[] = '📜 A quest begins: ' . $q['title'] . '. ' . $q['intro']; } catch (Throwable $e) { /* made by another request a moment ago */ } $oldJson = '[]'; }
            if (q('UPDATE user_sight_quests SET beats = ? WHERE user_id = ? AND quest = ? AND beats = ? AND done_at IS NULL', [$newJson, $uid, $q['slug'], $oldJson])->rowCount() !== 1) continue;   // another request moved this line: not counted twice
        } catch (Throwable $e) { continue; }
        $needLine = '';
        if ($need) {
            if (!give_item($uid, $need[0], -$need[1])) { q('UPDATE user_sight_quests SET beats = ? WHERE user_id = ? AND quest = ? AND beats = ?', [$oldJson, $uid, $q['slug'], $newJson]); continue; }
            $needLine = ' (used ' . $need[1] . ' × ' . $need[2] . ')';
        }
        if (count($new) >= count($q['beats'])) { $fl = trail_sight_quest_finish($u, $q, $loc, $now); if ($fl !== '') $out[] = $fl; }
        else $out[] = '📜 ' . $q['title'] . ': ' . $q['beats'][$idx][1] . $needLine . ' (' . count($new) . ' of ' . count($q['beats']) . ')';
    }
    return $out;
}

/** Is this villager (`Name` or `Name@village`) at least an acquaintance of the gnome? */
function trail_sight_friend_known(int $uid, string $who): bool
{
    try {
        $fid = trail_sight_folk_id($who);
        if ($fid) return trail_sight_friend_points_stop($uid, $fid) >= 1;
        [$name] = trail_sight_split_who($who); $nid = (int)q_val('SELECT id FROM npcs WHERE name = ? ORDER BY id LIMIT 1', [$name]);
        return $nid && (int)q_val('SELECT points FROM npc_friends WHERE user_id = ? AND npc_id = ?', [$uid, $nid]) >= 1;
    } catch (Throwable $e) { return false; }
}
function trail_sight_friend_points_stop(int $uid, int $folkId): int { require_once __DIR__ . '/stop_folk.php'; return stop_friend_points($uid, $folkId); }

/** Does an event ($ev like '@boss:lair-slug') match a beat kind ($beat like '@boss' or '@boss:lair-slug')? A beat with no argument matches any. */
function trail_sight_event_match(string $beat, string $ev): bool
{
    [$bk, $ba] = array_pad(explode(':', $beat, 2), 2, ''); [$ek, $ea] = array_pad(explode(':', $ev, 2), 2, '');
    return $bk === $ek && ($ba === '' || $ba === $ea);
}

/** A game event that quest lines may ask for: 'boss' (arg = the lair's slug), 'meal', 'friend' (arg = the villager's name). Returns journal lines for the caller to show. */
function trail_sight_quest_event(array $u, string $kind, string $arg = ''): array
{
    try {   // a quest line must never break a fight's end or a meal: any trouble here is silent
        if (!function_exists('trail_sight_quests') || !trail_sight_quests()) return [];
        require_once __DIR__ . '/stops.php';
        $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)($u['location_id'] ?? 0)]) ?: q_one('SELECT * FROM locations ORDER BY id LIMIT 1') ?: [];
        $loc += ['landscape' => 'grassland']; $loc['name'] = 'a quest';
        return trail_sight_quest_hook($u, '@' . $kind . ($arg !== '' ? ':' . $arg : ''), $loc, trail_sight_now($loc, null, $u));
    } catch (Throwable $e) { error_log('trail_sight_quest_event: ' . $e->getMessage()); return []; }
}

/** The quest lines a gnome has begun or finished, for the Tasks page: [[quest, done indexes, finished(bool)]]. */
function trail_sight_quests_of(int $uid): array
{
    $out = [];
    try { $rows = q('SELECT * FROM user_sight_quests WHERE user_id = ? ORDER BY id', [$uid])->fetchAll(); } catch (Throwable $e) { return []; }
    $all = trail_sight_quests();
    foreach ($rows as $r) if (isset($all[$r['quest']])) $out[] = [$all[$r['quest']], trail_sight_quest_done($all[$r['quest']], $r), $r['done_at'] !== null];
    return $out;
}

/** Which quest lines a Sight belongs to for this gnome: [[title, step n, of N, state 'next'|'later'|'done'|'new'|'locked']]. For the Sight card. */
function trail_sight_quest_notes(int $uid, string $slug): array
{
    $out = [];
    $all = trail_sight_quests();
    foreach ($all as $q) {
        foreach ($q['beats'] as $i => $b) if ($b[0] === $slug) {
            $row = trail_sight_quest_row($uid, $q['slug']);
            $done = trail_sight_quest_done($q, $row);
            $fin = $row && $row['done_at'] !== null;
            $locked = false;
            if ($q['gate'] !== '' && preg_match('/^quest:([a-z0-9-]+)$/', $q['gate'], $gm)) { $gr = trail_sight_quest_row($uid, $gm[1]); $locked = !$gr || $gr['done_at'] === null; }
            $st = in_array($i, $done, true) || $fin ? 'done' : ($locked ? 'locked' : (trail_sight_beat_open($q, $done, $i) ? ($row ? 'next' : 'new') : 'later'));
            $out[] = [$q['title'], $i + 1, count($q['beats']), $st];
        }
    }
    return $out;
}

// ---------------------------------------------------------------- villagers at a Sight

/** [[sight slug, villager, when, chance, line, rewards], ...] from data/trail_sight_folk.txt. */
function trail_sight_folk(?string $file = null): array
{
    static $c = [];
    $key = implode(',', trail_sight_data_files('folk', $file)); $key .= '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, trail_sight_data_files('folk', $file)));
    if (isset($c[$key])) return $c[$key];
    $out = [];
    foreach (trail_sight_data_lines('folk', $file) as $l) {
        $p = array_map('trim', explode('|', $l));
        if (count($p) >= 6 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]][] = ['slug' => $p[0], 'who' => $p[1], 'when' => $p[2] === '' ? '-' : $p[2], 'chance' => max(1, min(100, (int)$p[3])), 'line' => $p[4], 'rewards' => $p[5]];
    }
    return $c[$key] = $out;
}

/**
 * The villagers who are at a Sight today for this gnome: their condition holds, they are not away today (visiting family), they are not a hidden NPC (Pomeroy before the
 * Gourmand opens), and a daily roll against their chance succeeds. The roll is fixed per gnome, Sight, villager and game day, so the Sights card can say who is here and
 * the same answer comes at use time. [[folk row + 'idx']]
 */
function trail_sight_folk_here(string $slug, array $now, int $uid = 0): array
{
    $out = [];
    $day = function_exists('gclock_my_date') ? gclock_my_date() : date('Y-m-d');
    foreach (trail_sight_folk()[$slug] ?? [] as $i => $f) {
        if ($f['when'] !== '-' && !trail_sight_cond_ok($f['when'], $now)) continue;
        if (!trail_sight_folk_available($f['who'])) continue;
        if ($f['chance'] < 100 && hollow_unit('sgf|' . $uid . '|' . $slug . '|' . $f['who'] . '|' . $i . '|' . $day) * 100 >= $f['chance']) continue;
        $out[] = $f + ['idx' => $i];
    }
    return $out;
}

/** Is this named villager around today (a stop villager not away; a town NPC active and not away)? An unknown name is "available" (the lint and tests catch unknown names). */
function trail_sight_folk_available(string $who): bool
{
    [$name] = trail_sight_split_who($who);
    try {
        $fid = trail_sight_folk_id($who);
        if ($fid) return !(function_exists('gclock_npc_away') && gclock_npc_away('s' . $fid));
        $n = q_one('SELECT id, active FROM npcs WHERE name = ? ORDER BY id LIMIT 1', [$name]);
        if ($n) return (int)$n['active'] === 1 && !(function_exists('gclock_npc_away') && gclock_npc_away('n' . $n['id']));
    } catch (Throwable $e) {}
    return true;
}

/** "Nettle Cobblefield@cloverholt" => ['Nettle Cobblefield', 'cloverholt']: several villagers share a name in different villages, so a data row may say which one (the village's location slug). */
function trail_sight_split_who(string $who): array
{
    [$n, $v] = array_pad(explode('@', $who, 2), 2, '');
    return [trim($n), trim($v)];
}

/** A named villager's stop_folk id (made for the villages of the world on the way if needed; `Name@village-slug` picks the one in that village), or 0 if no villager has that name. */
function trail_sight_folk_id(string $who): int
{
    static $memo = [];
    if (isset($memo[$who]) && empty($GLOBALS['gv_sights_reload'])) return $memo[$who];
    return $memo[$who] = trail_sight_folk_id_lookup($who);
}

function trail_sight_folk_id_lookup(string $who): int
{
    [$name, $vslug] = trail_sight_split_who($who);
    try {
        require_once __DIR__ . '/stop_folk.php';
        trail_sights_ensure_newfolk();
        if ($vslug !== '') {
            $v = q_one("SELECT * FROM locations WHERE slug = ? AND kind = 'village'", [$vslug]);
            if (!$v) return 0;
            stop_folk_ensure($v);
            return (int)q_val('SELECT id FROM stop_folk WHERE name = ? AND location_id = ? ORDER BY id LIMIT 1', [$name, (int)$v['id']]);
        }
        $id = (int)q_val('SELECT id FROM stop_folk WHERE name = ? ORDER BY id LIMIT 1', [$name]);
        if ($id) return $id;
        if (q_val('SELECT 1 FROM npcs WHERE name = ?', [$name])) return 0;   // a town NPC or traveller: no need to make every village's folk to look for them
        foreach (q("SELECT * FROM locations WHERE kind = 'village' ORDER BY id")->fetchAll() as $v) {
            stop_folk_ensure($v);
            $id = (int)q_val('SELECT id FROM stop_folk WHERE name = ? ORDER BY id LIMIT 1', [$name]);
            if ($id) return $id;
        }
    } catch (Throwable $e) {}
    return 0;
}

/**
 * Pay a reward string (the Sights grammar: `first:` is not meaningful here; `?cond` and `@chance` are) as lines. `fp=N` gives N friendship to the named villager $who
 * (when $who is a villager's name; when blank it is the rest-stop "a random villager of the start place").
 */
function trail_sight_pay(array $u, array $loc, string $rewards, string $who = '', ?array $now = null): array
{
    require_once __DIR__ . '/stops.php';
    $plain = []; $lines = [];   // $now = the conditions of the use that pays (stance, pal ...); without it they are worked out here
    foreach (trail_sight_tokens($rewards) as $t) {
        if ($t['cond'] !== '') { $now ??= trail_sight_now($loc, null, $u); if (!trail_sight_cond_ok($t['cond'], $now)) continue; }
        $tok = $t['tok'];
        if (preg_match('/^(.*)@(\d+)$/', $tok, $cm) && preg_match('/^(fp|fpto|title|page|hint)=/', $tok)) { if (random_int(1, 100) > (int)$cm[2]) continue; $tok = $cm[1]; }   // a chance on one of OUR tokens (the others go to stop_rewards, which rolls its own)
        if (str_starts_with($tok, 'fp=') && $who !== '') $lines[] = trail_sight_befriend($u, $who, max(1, (int)substr($tok, 3)));
        elseif (str_starts_with($tok, 'fpto=')) { [$wn, $wp] = array_pad(explode(':', substr($tok, 5), 2), 2, '1'); $lines[] = trail_sight_befriend($u, $wn, max(1, (int)$wp)); }
        elseif (str_starts_with($tok, 'title=')) { if (trail_sight_give_title((int)$u['id'], substr($tok, 6))) $lines[] = '🏅 Title: ' . substr($tok, 6); }
        elseif (str_starts_with($tok, 'page=')) { if (unlock_entries((int)$u['id'], 'sightpage:' . substr($tok, 5)) > 0) $lines[] = '📖 A new Almanac page'; }
        elseif (str_starts_with($tok, 'hint=')) $lines[] = trail_sight_hint($u, $loc, substr($tok, 5));
        elseif (str_starts_with($tok, 'take=') || str_starts_with($tok, 'gather=') || str_starts_with($tok, 'unlock=') || str_starts_with($tok, 'give=') || $tok === 'nocheck') continue;
        else $plain[] = $tok;
    }
    return array_values(array_filter(array_merge($plain ? stop_rewards($u, $loc, implode(',', $plain), 1.0) : [], $lines), fn($l) => $l !== ''));
}

/** Friendship with a named villager (`Name` or `Name@village-slug`): a stop villager or a town NPC. Returns the journal fragment ('' if nobody has that name). */
function trail_sight_befriend(array $u, string $who, int $pts): string
{
    $fid = trail_sight_folk_id($who); [$name] = trail_sight_split_who($who);
    if ($fid) { require_once __DIR__ . '/stop_folk.php'; stop_friend_add((int)$u['id'], $fid, $pts); return '💛 ' . $name . ' likes you a little more'; }
    try { $nid = (int)q_val('SELECT id FROM npcs WHERE name = ? ORDER BY id LIMIT 1', [$name]); } catch (Throwable $e) { $nid = 0; }
    if ($nid) { require_once __DIR__ . '/friends.php'; friend_add((int)$u['id'], $nid, $pts); return '💛 ' . $name . ' likes you a little more'; }
    return '';
}

// ---------------------------------------------------------------- conditions, hints, titles, Almanac pages, new villagers

/** What the conditions are checked against: the rest-stop words (dp se we hp) plus `st` (the walk stance: sneak, hunt or normal) and `pal` (1 with a Puzzle Pal along). $sc = the trail scene or null. */
function trail_sight_now(array $loc, ?array $sc, ?array $u = null): array
{
    require_once __DIR__ . '/stops.php';
    $now = stop_now($loc);
    $now['st'] = (string)(($sc['st']['stance'] ?? '') ?: 'normal');
    $pal = 0;
    if ($u && function_exists('trail_pal_urls')) { try { $pal = count(trail_pal_urls($u)); } catch (Throwable $e) {} }
    $now['pal'] = $pal > 0 ? '1' : '0';
    $now['tl'] = $u ? trail_sight_tallies((int)$u['id']) : [];
    $now['qd'] = [];
    if ($u) { try { $now['qd'] = array_column(q('SELECT quest FROM user_sight_quests WHERE user_id = ? AND done_at IS NOT NULL', [(int)$u['id']])->fetchAll(), 'quest'); } catch (Throwable $e) {} }
    return $now;
}

/** "dp=dusk,night/st=sneak" against $now: every condition must hold, any ONE of its values. Unknown keys fail. */
function trail_sight_cond_ok(string $cond, array $now): bool
{
    if (trim($cond) === '' || trim($cond) === '-') return true;
    foreach (explode('/', $cond) as $part) {
        [$k, $v] = array_pad(explode('=', trim($part), 2), 2, '');
        if ($k === 'tl' || $k === 'tn') { [$tk, $tn] = array_pad(explode(':', $v, 2), 2, '0'); $have = (int)(($now['tl'] ?? [])[$tk] ?? 0); if ($k === 'tl' ? $have < (int)$tn : $have !== (int)$tn) return false; continue; }   // tl=<key>:N = a tally is at least N; tn=<key>:N = exactly N (pays once, on the use that reaches it)
        if ($k === 'qd') { if (!array_intersect(array_map('trim', explode(',', $v)), (array)($now['qd'] ?? []))) return false; continue; }   // qd=<quest slug>[,..] = that Sight quest line is done
        if (!in_array($k, ['dp', 'se', 'we', 'hp', 'st', 'pal'], true) || $v === '') return false;
        if (!in_array((string)($now[$k] ?? ''), array_values(array_filter(array_map('trim', explode(',', $v)))), true)) return false;
    }
    return true;
}

/** A private counter of a gnome (a cairn, a collection): [key => n]. */
function trail_sight_tallies(int $uid): array
{
    try { return array_map('intval', array_column(q('SELECT tkey, n FROM trail_sight_tally WHERE user_id = ?', [$uid])->fetchAll(), 'n', 'tkey')); } catch (Throwable $e) { return []; }
}
function trail_sight_tally_add(int $uid, string $key, int $n = 1): int
{
    try {
        if (q('UPDATE trail_sight_tally SET n = n + ? WHERE user_id = ? AND tkey = ?', [$n, $uid, $key])->rowCount() < 1) db_insert('trail_sight_tally', ['user_id' => $uid, 'tkey' => $key, 'n' => $n]);
        return (int)q_val('SELECT n FROM trail_sight_tally WHERE user_id = ? AND tkey = ?', [$uid, $key]);
    } catch (Throwable $e) { return 0; }
}

/** A short plain-words version of a condition for the Sights card: "at dusk or night, sneaking". */
function trail_sight_cond_text(string $cond): string
{
    $w = ['dp' => 'at ', 'se' => 'in ', 'we' => 'when it is ', 'st' => '', 'hp' => ''];
    $bits = [];
    foreach (explode('/', $cond) as $part) {
        [$k, $v] = array_pad(explode('=', trim($part), 2), 2, '');
        if ($k === 'pal') $bits[] = $v === '1' ? 'with a Puzzle Pal along' : 'on your own';
        elseif ($k === 'st') $bits[] = implode(' or ', array_map(fn($x) => $x === 'sneak' ? 'sneaking' : ($x === 'hunt' ? 'hunting' : 'walking normally'), explode(',', $v)));
        elseif ($k === 'tl' || $k === 'tn') { [$tk, $tn] = array_pad(explode(':', $v, 2), 2, '0'); $bits[] = 'after ' . $tn . ' ' . $tk; }
        elseif ($k === 'qd') $bits[] = 'once ' . str_replace('-', ' ', $v) . ' is done';
        elseif (isset($w[$k])) $bits[] = $w[$k] . implode(' or ', explode(',', $v));
    }
    return implode(', ', $bits);
}

/** A true hint from the game state (token hint=<kind>): weather (tomorrow's), away (who is visiting family today at the start place), creature (the lair ahead), season. */
function trail_sight_hint(array $u, array $loc, string $kind): string
{
    try {
        if ($kind === 'weather') {
            $d = function_exists('gclock_my_date') ? gclock_my_date() : date('Y-m-d');
            $tm = date('Y-m-d', strtotime($d . ' +1 day'));
            return '🌦️ The sky says tomorrow will be ' . hollow_weather(null, $tm) . '.';
        }
        if ($kind === 'season') return '🍂 It is ' . hollow_season() . ' now.';
        if ($kind === 'away') {
            if (($loc['kind'] ?? '') !== 'village') return '';   // only a village has folk to be away from
            require_once __DIR__ . '/stop_folk.php';
            $names = [];
            foreach (q('SELECT id, name FROM stop_folk WHERE location_id = ? ORDER BY slot', [(int)($loc['id'] ?? 0)])->fetchAll() as $f) if (gclock_npc_away('s' . $f['id'])) $names[] = $f['name'];
            return $names ? '🚶 Away visiting family today: ' . implode(', ', $names) . '.' : '🏡 Everybody is home today.';
        }
        if ($kind === 'creature') {
            $c = q_one("SELECT l.name, l.kind FROM locations l WHERE l.kind = 'lair' AND l.region_id = ? ORDER BY l.id LIMIT 1", [(int)($loc['region_id'] ?? 0)]);
            return $c ? '👣 Something large lives at ' . $c['name'] . '. Go gently.' : '👣 Nothing large has been seen lately.';
        }
    } catch (Throwable $e) {}
    return '';
}

/** Give a title (a Sight reward). Returns true if new. Shown with the other earned titles on the Almanac page (book.php). */
function trail_sight_give_title(int $uid, string $title): bool
{
    $title = trim(mb_substr($title, 0, 60)); if ($title === '') return false;
    try {
        if (q_val('SELECT 1 FROM user_sight_titles WHERE user_id = ? AND title = ?', [$uid, $title])) return false;
        db_insert('user_sight_titles', ['user_id' => $uid, 'title' => $title]); return true;
    } catch (Throwable $e) { return false; }
}

/** Titles earned from Sights and Sight quest lines (merged into the earned titles in book.php). */
function trail_sight_titles(int $uid): array
{
    try { return q('SELECT title FROM user_sight_titles WHERE user_id = ? ORDER BY id', [$uid])->fetchAll(PDO::FETCH_COLUMN); } catch (Throwable $e) { return []; }
}

/** [key => [chapter, category, title, body]] from data/trail_sight_pages.txt: extra Almanac pages the Sights and quest lines open with `page=<key>`. */
function trail_sight_pages(?string $file = null): array
{
    static $c = [];
    $key = implode(',', trail_sight_data_files('pages', $file)); $key .= '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, trail_sight_data_files('pages', $file)));
    if (isset($c[$key])) return $c[$key];
    $out = [];
    foreach (trail_sight_data_lines('pages', $file) as $l) {
        $p = array_map('trim', explode('|', $l, 5));
        if (count($p) === 5 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2], $p[3], str_replace('\\n', "\n", $p[4])];
    }
    return $c[$key] = $out;
}

/** Make the extra Almanac pages (locked until their key is given). Adds only. */
function trail_sights_ensure_pages(): void
{
    $sig = md5(json_encode(trail_sight_pages()));
    if (setting('almanac_sight_pages') === $sig) return;
    if (!trail_sight_claim('almanac_sight_pages_lock')) return;
    $n = 0;
    foreach (trail_sight_pages() as $key => [$chapter, $cat, $title, $body]) {
        $n++;
        try {
            if (q_val('SELECT 1 FROM encyclopedia_entries WHERE unlock_key = ?', ['sightpage:' . $key])) continue;
            db_insert('encyclopedia_entries', ['chapter' => $chapter, 'category' => $cat, 'title' => $title, 'body' => $body, 'unlock_key' => 'sightpage:' . $key, 'hint' => 'Something on the Trail may teach you this.', 'sort_order' => 500 + $n]);
        } catch (Throwable $e) {}
    }
    set_setting('almanac_sight_pages', $sig);
}

/** [[Name, species, personality, role, bio, village slug]] from data/trail_sight_newfolk.txt: villagers the Sights need that the world did not make (a lighthouse keeper ...). */
function trail_sight_newfolk(?string $file = null): array
{
    static $c = [];
    $key = implode(',', trail_sight_data_files('newfolk', $file)); $key .= '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, trail_sight_data_files('newfolk', $file)));
    if (isset($c[$key])) return $c[$key];
    $out = [];
    foreach (trail_sight_data_lines('newfolk', $file) as $l) {
        $p = array_map('trim', explode('|', $l));
        if (count($p) >= 6) $out[] = $p;
    }
    return $c[$key] = $out;
}

/** Add those villagers to their village's stop_folk (slot 9 and up; once; never changes one that exists). */
function trail_sights_ensure_newfolk(): void
{
    static $done = false;
    if ($done) return; $done = true;
    $sig = md5(implode(',', array_map(fn($f) => basename($f) . filemtime($f), glob(__DIR__ . '/data/trail_sight_newfolk*.txt') ?: [])));
    if (empty($GLOBALS['gv_sight_newfolk_file']) && setting('sight_newfolk_sig') === $sig) return;   // made already for these files
    try {
        foreach (trail_sight_newfolk() as [$name, $species, $pers, $role, $bio, $vslug]) {
            $v = q_one("SELECT * FROM locations WHERE slug = ? AND kind = 'village'", [$vslug]); if (!$v) continue;
            if (q_val('SELECT 1 FROM stop_folk WHERE name = ? AND location_id = ?', [$name, (int)$v['id']])) continue;
            require_once __DIR__ . '/stop_folk.php';
            stop_folk_ensure($v);
            $slot = max(9, (int)q_val('SELECT MAX(slot) FROM stop_folk WHERE location_id = ?', [(int)$v['id']]) + 1);
            db_insert('stop_folk', ['location_id' => (int)$v['id'], 'slot' => $slot, 'name' => $name, 'species' => $species, 'personality' => $pers, 'role' => $role, 'bio' => $bio]);
        }
    } catch (Throwable $e) { return; /* no table yet, or made by another request: try again next time */ }
    if (empty($GLOBALS['gv_sight_newfolk_file'])) { try { set_setting('sight_newfolk_sig', $sig); } catch (Throwable $e) {} }
}

// ---------------------------------------------------------------- what the Trail page shows (P3)

/** Every landmark of the section the gnome is in that has a Sight: [['x','y','slug','row','left','why']]. Used for the marks over the sprites and the Sights card. */
function trail_sights_marks(array $u, ?array $sc): array
{
    if (!$sc || ($sc['st']['phase'] ?? '') !== 'section') return [];
    return trail_sights_marks_build($u, $sc);
}

function trail_sights_marks_build(array $u, array $sc): array
{
    $all = trail_sights_all(); $out = []; $seen = [];
    foreach ((array)($sc['map']['art']['objs'] ?? []) as $ob) {
        $key = (string)($ob[2] ?? '');
        if (strncmp($key, 'lm-', 3) !== 0) continue;
        $slug = substr($key, 3);
        if (!isset($all[$slug]) || isset($seen[$slug])) continue;
        $seen[$slug] = true;
        [$left, $why] = trail_sight_state((int)$u['id'], $sc, $all[$slug]);
        $out[] = ['x' => (int)$ob[0], 'y' => (int)$ob[1], 'slug' => $slug, 'row' => $all[$slug], 'left' => $left, 'why' => $why];
    }
    return $out;
}

/** The cards of the "Sights here" pop-up: one per Sight of the section, with a Walk-there or Use button. $sc = the trail scene. */
function trail_sights_cards_html(array $u, array $sc, array $marks, ?array $exp = null): string
{
    require_once __DIR__ . '/gathering.php'; require_once __DIR__ . '/tools.php';
    $h = '';
    foreach ($marks as $m) {
        $row = $m['row']; [$name, $cap] = trail_sight_label($m['slug']);
        $near = max(abs($m['x'] - (int)$sc['x']), abs($m['y'] - (int)$sc['y'])) <= 1;
        $bits = ['⚡' . (int)$row['energy'], gclock_on() ? gclock_time_cost('sight') . ' min' : ''];
        if ($row['tool'] !== '-') { [$tt, $tr] = explode(':', $row['tool']); $bits[] = '🧰 ' . (TOOL_TIERS[(int)$tr] ?? '') . ' ' . (GATHER_TOOL_NOUN[$tt] ?? $tt); }
        if ($row['check'] !== '-') $bits[] = '🎲 ' . ucfirst(explode(':', $row['check'])[0]);
        if ($row['when'] !== '-') $bits[] = '🕰️ ' . trail_sight_cond_text($row['when']);
        $notes = '';
        foreach (trail_sight_quest_notes((int)$u['id'], $m['slug']) as [$qt, $n, $of, $st]) {
            $notes .= '<p class="sgq">📜 <b>' . e($qt) . '</b> · step ' . $n . ' of ' . $of . ' · ' . ['done' => 'done', 'next' => '<b>your next step</b>', 'later' => 'later', 'new' => 'starts here', 'locked' => 'not yet'][$st] . '</p>';
        }
        $loc = $exp ? (q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['from_id']]) ?: []) : [];
        $loc += ['landscape' => 'grassland', 'name' => $row['verb']];
        $now = trail_sight_now($loc, $sc, $u);
        $folkNote = '';
        foreach (trail_sight_folk_here($m['slug'], $now, (int)$u['id']) as $fh) {
            $gv = null; foreach (trail_sight_tokens($fh['rewards']) as $tk) if (str_starts_with($tk['tok'], 'give=')) $gv = explode(':', substr($tk['tok'], 5));
            $nm = trail_sight_split_who($fh['who'])[0];
            $folkNote .= '<p class="sgfolk">💬 <b>' . e($nm) . '</b> is here today.';
            if ($gv) {
                $gid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$gv[0]]); $gq = max(1, (int)($gv[1] ?? 1));
                $has = $gid && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $gid]) >= $gq;
                $folkNote .= ' They would like ' . $gq . ' × ' . e((string)q_val('SELECT name FROM items WHERE id = ?', [$gid])) . '. ' . ($has && $near
                    ? '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="sightgive"><input type="hidden" name="slug" value="' . e($m['slug']) . '"><input type="hidden" name="idx" value="' . (int)$fh['idx'] . '"><button class="btn small">🎁 Give</button></form>' : '<small class="muted">' . ($near ? 'You have none.' : 'Walk there to give it.') . '</small>');
            }
            $folkNote .= '</p>';
        }
        $pk = trail_sight_pick_info($row);
        $act = $m['left'] < 1
            ? '<button class="btn" disabled>' . e($row['icon']) . ' ' . e($row['verb']) . ' <small>' . e($m['why'] ?: 'again soon') . '</small></button>'
            : ($near
                ? ($pk
                    ? '<form method="post" class="inline sgpick">' . csrf_field() . '<input type="hidden" name="do" value="sight"><input type="hidden" name="slug" value="' . e($m['slug']) . '">' . implode('', array_map(fn($i, $lb) => '<button class="btn" name="pick" value="' . $i . '">' . e($row['icon']) . ' ' . e($lb) . '</button>', array_keys($pk[1]), $pk[1])) . '</form>'
                    : '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="sight"><input type="hidden" name="slug" value="' . e($m['slug']) . '"><button class="btn">' . e($row['icon']) . ' ' . e($row['verb']) . '</button></form>')
                : '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_go"><button class="btn alt" name="go" value="' . $m['x'] . ',' . $m['y'] . '">👣 Walk there</button></form>');
        $h .= '<div class="sgcard"><img class="sgpic" alt="" src="' . e(trail_art_url('obj/lm-' . $m['slug'] . '.png')) . '"><div class="sgbody"><h4>' . e($name) . '</h4>'
            . ($cap !== '' ? '<p class="help">' . e($cap) . '</p>' : '') . '<p class="muted sgdo">' . e($row['icon']) . ' ' . e($row['verb']) . ' · ' . e(implode(' · ', array_filter($bits))) . '</p>' . $notes . $folkNote . $act . '</div></div>';
    }
    return $h !== '' ? $h : '<p class="muted">Nothing to do at the big landmarks of this stretch.</p>';
}

/** The "📜 Sight quests" box of the Tasks page: lines begun and not finished (with their beats), and a count of finished ones. '' when none. */
function trail_sight_quests_box(array $u): string
{
    $mine = trail_sight_quests_of((int)$u['id']);
    if (!$mine) return '';
    $open = ''; $fin = 0;
    foreach ($mine as [$q, $done, $isDone]) {
        if ($isDone) { $fin++; continue; }
        $li = '';
        foreach ($q['beats'] as $i => $b) {
            $d = in_array($i, $done, true);
            $next = !$d && trail_sight_beat_open($q, $done, $i);
            $where = $b[0] !== '' && $b[0][0] === '@' ? '' : ' <small>(' . e(trail_sight_label($b[0])[0]) . ')</small>';
            $li .= '<li' . ($d ? ' class="muted"' : '') . '>' . ($d ? '✅ ' : ($next ? '👉 ' : '▫️ ')) . e($b[1]) . ($next ? $where : '') . '</li>';
        }
        $open .= '<details class="sgq" open><summary>' . e($q['icon']) . ' <b>' . e($q['title']) . '</b> <small class="muted">' . count($done) . '/' . count($q['beats']) . ' · ' . e(trail_sight_split_who($q['giver'])[0]) . '</small></summary><ul class="qlist">' . $li . '</ul></details>';
    }
    return '<section class="box qsec"><h3>🔎 Sight quests</h3>' . ($open ?: '<p class="muted">None on the go.</p>') . ($fin ? '<p class="muted">' . $fin . ' finished.</p>' : '') . '</section>';
}

/**
 * Villagers who are out and about at a Sight of this section RIGHT NOW (their row's time of day, season and weather hold, they are not away, the daily roll says yes), to draw on the map
 * beside the landmark: [[x, y, picture url, name, frames]]. One villager per landmark (the first that is here). The same answer the Sights card and trail_sight_do use.
 */
function trail_sights_folk_on_map(array $u, array $exp, array $sc, array $marks, bool $consume = false): array
{
    if (!$marks || ($sc['st']['phase'] ?? '') !== 'section') return [];
    $loc = q_one('SELECT * FROM locations WHERE id = ?', [(int)($exp['from_id'] ?? 0)]) ?: [];
    $loc += ['landscape' => 'grassland', 'name' => ''];
    $now = trail_sight_now($loc, $sc, $u);
    $out = []; $taken = [];
    foreach ($marks as $m) {
        foreach (trail_sight_folk_here($m['slug'], $now, (int)$u['id']) as $f) {
            [$name] = trail_sight_split_who($f['who']);
            $pic = trail_sight_folk_pic($f['who']);
            if (!$pic) continue;
            $spot = null;   // a free walkable tile beside the landmark (not under its sprite)
            foreach ([[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [-1, 1], [2, 0], [-2, 0]] as [$dx, $dy]) { $tx = $m['x'] + $dx; $ty = $m['y'] + $dy; if (($tx === (int)$sc['x'] && $ty === (int)$sc['y']) || isset($taken[$tx . ',' . $ty])) continue; if (in_array(tm_tile($sc['map'], $tx, $ty), ['.', ','], true) && trail_token_at($sc, $tx, $ty) < 0 && !trail_sight_tile_in_gate($sc['map']['art'] ?? [], $tx, $ty)) { $spot = [$tx, $ty]; break; } }   // never on the gnome's own tile
            if (!$spot) continue;   // no free tile beside the landmark: nobody stands there
            $taken[$spot[0] . ',' . $spot[1]] = true;
            $anim = false;   // walks in once per game day and place (the page swaps in place after every step: the session remembers they have arrived)
            if ($consume) { $key = (function_exists('gclock_my_date') ? gclock_my_date() : date('Y-m-d')) . '|' . $m['slug'] . '|' . $name; if (session_status() === PHP_SESSION_ACTIVE && empty($_SESSION['sgfk'][$key])) { $_SESSION['sgfk'][$key] = 1; $anim = true; if (count($_SESSION['sgfk']) > 60) $_SESSION['sgfk'] = array_slice($_SESSION['sgfk'], -30, null, true); } }
            $out[] = [$spot[0], $spot[1], $pic[0], $name, $pic[1], $pic[2], $pic[3], $anim, $m['slug'], $f['who']];
            break;
        }
    }
    return $out;
}

/** Is tile x, y one of the tiles of a tool gate of this section? (a villager does not stand in a gate) */
function trail_sight_tile_in_gate(array $art, int $x, int $y): bool
{
    foreach ((array)($art['gates'] ?? []) as $g) foreach ((array)($g['tiles'] ?? []) as $t) if ((int)$t[0] === $x && (int)$t[1] === $y) return true;
    return false;
}

/** A named villager's map picture: [url, frames, kind 's' stop villager | 'n' town NPC, id] (a 4-frame sprite sheet shows its first frame), or null. */
function trail_sight_folk_pic(string $who): ?array
{
    try {
        $fid = trail_sight_folk_id($who);
        if ($fid) {
            require_once __DIR__ . '/stop_folk.php';
            $folk = q_one('SELECT * FROM stop_folk WHERE id = ?', [$fid]);
            $rel = $folk ? stop_folk_art($folk, 'sprite') : '';
            return $rel !== '' ? [url($rel), 4, 's', $fid] : null;
        }
        [$name] = trail_sight_split_who($who);
        $npc = q_one('SELECT * FROM npcs WHERE name = ? ORDER BY id LIMIT 1', [$name]);
        if ($npc) { require_once __DIR__ . '/here_view.php'; $sp = here_sprite($npc); if ($sp['src'] !== '') return [$sp['src'], (int)($sp['frames'] ?? 1), 'n', (int)$npc['id']]; }
    } catch (Throwable $e) {}
    return null;
}

/** The card of a villager met on the road (the pop-up when you tap them on the map): who they are, how well you know them, Chat and Gift. $e = a trail_sights_folk_on_map entry. */
function trail_sight_folk_card_html(array $u, array $e): string
{
    [, , , $name, , $kind, $id, , $slug, $who] = $e;
    $uid = (int)$u['id'];
    $meta = ''; $bio = ''; $lvl = '';
    try {
        if ($kind === 's') {
            require_once __DIR__ . '/stop_folk.php';
            $f = q_one('SELECT * FROM stop_folk WHERE id = ?', [$id]);
            if ($f) { $meta = $f['species'] . ' · ' . $f['personality'] . ' · ' . $f['role']; $bio = (string)$f['bio']; $lvl = STOP_FRIEND_LEVELS[stop_friend_level(stop_friend_points($uid, $id))['index']][1] ?? ''; }
        } else {
            require_once __DIR__ . '/friends.php';
            $n = q_one('SELECT * FROM npcs WHERE id = ?', [$id]);
            if ($n) { $meta = trim(($n['species'] ?? '') . ' · ' . ($n['personality'] ?? ''), ' ·'); $bio = (string)($n['bio'] ?? ''); $lvl = friend_level((int)friendship($uid, $id)['points'])[1] ?? ''; }
        }
    } catch (Throwable $ex) {}
    $key = $kind . $id;
    $h = '<div class="sgcard sgfolkcard"><div class="sgbody"><h4>' . e($name) . '</h4><p class="muted">' . e($meta) . '</p>' . ($bio !== '' ? '<p class="help">' . e($bio) . '</p>' : '') . ($lvl !== '' ? '<p>💛 ' . e((string)$lvl) . '</p>' : '')
        . '<p class="help">' . e($name) . ' is out and about by ' . e(trail_sight_label($slug)[0]) . '.</p>'
        . '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="sightchat"><input type="hidden" name="fk" value="' . e($key) . '"><input type="hidden" name="slug" value="' . e($slug) . '"><button class="btn">💬 Chat</button></form>';
    $gifts = [];
    try { $gifts = array_slice(stop_giftable($uid), 0, 40); } catch (Throwable $ex) {}
    if ($gifts) {
        $h .= '<form method="post" class="inline sgrow">' . csrf_field() . '<input type="hidden" name="do" value="sightgift"><input type="hidden" name="fk" value="' . e($key) . '"><input type="hidden" name="slug" value="' . e($slug) . '"><select name="item_id" aria-label="Gift">';
        foreach ($gifts as $g) $h .= '<option value="' . (int)$g['id'] . '">' . e($g['name']) . ' × ' . (int)$g['qty'] . '</option>';
        $h .= '</select> <button class="btn alt">🎁 Give a present</button></form>';
    }
    return $h . '</div></div>';
}

/** Is the villager $fk ('s12' / 'n3') one who is out and about at a Sight of this section right now? Returns their map entry or null. */
function trail_sight_folk_entry(array $u, array $exp, array $sc, string $fk): ?array
{
    foreach (trail_sights_folk_on_map($u, $exp, $sc, trail_sights_marks($u, $sc)) as $e) if (($e[5] . $e[6]) === $fk) return $e;
    return null;
}

/** Chat with / give a present to a villager met on the road. $what = 'chat' | 'gift'. [ok, message]. Same rules as at a rest stop: once a day each, friendship. */
function trail_sight_folk_talk(array $u, array &$exp, string $what, string $fk, int $itemId = 0): array
{
    $sc = trail_scene($exp);
    if (!$sc || $exp['encounter']) return [false, 'Not now.'];
    $e = trail_sight_folk_entry($u, $exp, $sc, $fk);
    if (!$e) return [false, 'They have gone on their way.'];
    [, , , $name, , $kind, $id] = $e; $uid = (int)$u['id'];
    require_once __DIR__ . '/stop_folk.php'; require_once __DIR__ . '/friends.php';
    if ($kind === 's') {
        $f = q_one('SELECT * FROM stop_folk WHERE id = ?', [$id]); $vloc = $f ? q_one('SELECT * FROM locations WHERE id = ?', [(int)$f['location_id']]) : null;
        if (!$vloc) return [false, 'They have gone on their way.'];
        [$ok, $msg] = $what === 'chat' ? stop_chat($u, $vloc, $id) : trail_sight_stop_gift($u, $f, $id, $itemId);   // stop_gift opens its own transaction: not inside the walk's
    } else {
        $npc = q_one('SELECT * FROM npcs WHERE id = ?', [$id]); $today = gclock_my_date();
        if (!$npc) return [false, 'They have gone on their way.'];
        if ($what === 'chat') {
            if (!friend_claim($uid, $id, 'last_talk', $today)) { $ok = true; $msg = '💬 ' . $name . ' has already had a good chat with you today.'; }
            else { $g = max(1, 3 + (function_exists('eff_mod') ? eff_mod($u, 'charm') : 0)); friend_add($uid, $id, $g); $ok = true; $msg = '💬 You have a good chat with ' . $name . '. (💛 +' . $g . ')'; }
        } else {
            $item = q_one("SELECT * FROM items WHERE id = ? AND tradable = 1 AND category NOT IN ('tool', 'broken')", [$itemId]);
            if (!$item) return [false, 'Pick something to give.'];
            if ((int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $itemId]) < 1) return [false, 'You do not have one of those.'];
            if (!friend_claim($uid, $id, 'last_gift', $today)) return [false, $name . ' has already had a present from you today.'];
            if (!give_item($uid, $itemId, -1)) return [false, 'You do not have one of those.'];
            $pts = in_array($item['category'], ['food', 'flower', 'produce', 'arrangement'], true) ? 4 : 2; friend_add($uid, $id, $pts);
            $ok = true; $msg = '🎁 ' . $name . ' takes the ' . $item['name'] . ' with a grateful smile. (💛 +' . $pts . ')';
        }
    }
    if (!$ok) return [false, $msg];   // a refusal is a message, not a journal line
    exp_log($exp, $msg);
    return [true, ''];
}

/**
 * stop_gift() without its own transaction (adventure.php already holds one and a second beginTransaction throws): same rules, once a day each, +friendship (2, or 4 for food,
 * flowers, produce and arrangements, with a Charm boost). The claim is made only after the gnome is known to carry the item. [ok, message]
 */
function trail_sight_stop_gift(array $u, array $folk, int $folkId, int $itemId): array
{
    $uid = (int)$u['id'];
    $item = q_one("SELECT * FROM items WHERE id = ? AND tradable = 1 AND category NOT IN ('tool', 'broken')", [$itemId]);
    if (!$item) return [false, 'Pick something to give.'];
    if (gclock_npc_away('s' . $folkId)) return [false, $folk['name'] . ' is away today (visiting family). Try again after you sleep.'];
    if ((int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $itemId]) < 1) return [false, 'You don’t have one of those.'];
    $today = gclock_my_date();
    stop_friend_ensure($uid, $folkId);
    if (q('UPDATE stop_friend SET last_gift = ? WHERE user_id = ? AND folk_id = ? AND (last_gift IS NULL OR last_gift <> ?)', [$today, $uid, $folkId, $today])->rowCount() !== 1) return [false, $folk['name'] . ' has already had a present from you today.'];
    if (!give_item($uid, $itemId, -1)) { q('UPDATE stop_friend SET last_gift = NULL WHERE user_id = ? AND folk_id = ?', [$uid, $folkId]); return [false, 'You don’t have one of those.']; }
    $pts = in_array($item['category'], ['food', 'flower', 'produce', 'arrangement'], true) ? 4 : 2;
    $pts = (int)round($pts * (1 + 0.08 * max(0, function_exists('eff_mod') ? eff_mod($u, 'charm') : 0)));
    $before = stop_friend_points($uid, $folkId);
    $new = stop_friend_add($uid, $folkId, $pts);
    return [true, npc_icon($folk['species']) . ' ' . $folk['name'] . ' takes the ' . $item['name'] . ' with a grateful smile. (💛 +' . ($new - $before) . ')'];
}

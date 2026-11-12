<?php
declare(strict_types=1);

/**
 * Trail Sights, the rest of the plan (P2b + P3; claude/plan-trail-sights.md): names and captions, the items the Sights hand out, the Almanac "Sights" chapter,
 * quest lines made of Sight uses, and villagers who turn up at a Sight.
 * Data files (all in includes/data/):
 *   trail_sight_info.txt    slug | Name | caption                                  (what the Sight card and the Almanac page say)
 *   trail_sight_items.txt   slug | Name | category | rarity | base_price | edible | description     (items only Sights give; made once, never changed if they exist)
 *   trail_sight_quests.txt  Q|slug|title|giver|icon|order(seq|any)|reward|intro|outro      then      B|slug|sight slug|label|when
 *   trail_sight_folk.txt    sight slug | Villager name | when | chance % | line | rewards (the Sight's reward grammar; fp=N = N friendship with that villager)
 */

// ---------------------------------------------------------------- names, captions

/** [slug => [name, caption]] from data/trail_sight_info.txt; a Sight with no row gets a name made from its slug and no caption. */
function trail_sight_info(?string $file = null): array
{
    static $c = [];
    $file ??= __DIR__ . '/data/trail_sight_info.txt';
    if (isset($c[$file])) return $c[$file];
    $out = [];
    foreach (is_file($file) ? (file($file, FILE_IGNORE_NEW_LINES) ?: []) : [] as $l) {
        $l = trim($l);
        if ($l === '' || $l[0] === '#') continue;
        $p = array_map('trim', explode('|', $l, 3));
        if (count($p) >= 2 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2] ?? ''];
    }
    return $c[$file] = $out;
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
    $file ??= __DIR__ . '/data/trail_sight_items.txt';
    if (isset($c[$file])) return $c[$file];
    $out = [];
    foreach (is_file($file) ? (file($file, FILE_IGNORE_NEW_LINES) ?: []) : [] as $l) {
        $l = trim($l);
        if ($l === '' || $l[0] === '#') continue;
        $p = array_map('trim', explode('|', $l, 7));
        if (count($p) >= 7 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2], max(1, (int)$p[3]), max(0, (int)$p[4]), (int)$p[5] ? 1 : 0, $p[6]];
    }
    return $c[$file] = $out;
}

/** Make the items only Sights give. Adds only; an item that exists (or was edited in Admin) is left alone. Returns how many were added. */
function trail_sights_ensure_items(): int
{
    $n = 0;
    foreach (trail_sight_items_file() as $slug => [$name, $cat, $rar, $price, $edible, $desc]) {
        try {
            if (q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) continue;
            db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => $cat, 'rarity' => $rar, 'base_price' => $price, 'description' => $desc, 'edible' => $edible, 'tradable' => 1]);
            $n++;
        } catch (Throwable $e) { /* made by another request, or no items table */ }
    }
    return $n;
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

/** [quest slug => ['slug','title','giver','icon','order','reward','intro','outro','beats' => [[sight slug, label, when]]]] from data/trail_sight_quests.txt. */
function trail_sight_quests(?string $file = null): array
{
    static $c = [];
    $file ??= __DIR__ . '/data/trail_sight_quests.txt';
    if (isset($c[$file])) return $c[$file];
    $out = [];
    foreach (is_file($file) ? (file($file, FILE_IGNORE_NEW_LINES) ?: []) : [] as $l) {
        $l = trim($l);
        if ($l === '' || $l[0] === '#') continue;
        $p = array_map('trim', explode('|', $l));
        if ($p[0] === 'Q' && count($p) >= 9 && preg_match('/^[a-z0-9-]+$/', $p[1])) $out[$p[1]] = ['slug' => $p[1], 'title' => $p[2], 'giver' => $p[3], 'icon' => $p[4], 'order' => $p[5] === 'any' ? 'any' : 'seq',
            'reward' => $p[6], 'intro' => $p[7], 'outro' => $p[8], 'beats' => []];
        elseif ($p[0] === 'B' && count($p) >= 4 && isset($out[$p[1]])) $out[$p[1]]['beats'][] = [$p[2], $p[3], ($p[4] ?? '') === '' ? '-' : $p[4]];
    }
    return $c[$file] = $out;
}

/** Problems with the quest lines: unknown Sight, empty line, bad reward. */
function trail_sight_quest_lint(array $q, array $sights): array
{
    $bad = [];
    if (count($q['beats']) < 2) $bad[] = 'fewer than 2 beats';
    foreach ($q['beats'] as [$s, $label, $when]) {
        if (!isset($sights[$s])) $bad[] = 'beat on unknown Sight ' . $s;
        if ($label === '') $bad[] = 'a beat has no label';
        if ($when !== '-') foreach (explode('/', $when) as $part) if (!preg_match('/^(dp|se|we|hp)=[a-z,]+$/', trim($part))) $bad[] = 'bad beat condition ' . $part;
    }
    if ($q['title'] === '' || $q['intro'] === '' || $q['outro'] === '') $bad[] = 'title, intro and outro are all needed';
    $probe = ['slug' => 'x', 'verb' => 'x', 'icon' => 'x', 'energy' => 0, 'cd' => 0, 'uses' => 1, 'when' => '-', 'check' => '-', 'rewards' => $q['reward'], 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0];
    foreach (trail_sight_lint($probe, true) as $p) if (!str_starts_with($p, 'no landmark picture')) $bad[] = 'reward: ' . $p;
    return $bad;
}

function trail_sight_quest_row(int $uid, string $qslug): ?array
{
    try { return q_one('SELECT * FROM user_sight_quests WHERE user_id = ? AND quest = ?', [$uid, $qslug]) ?: null; } catch (Throwable $e) { return null; }
}

/**
 * A Sight was used successfully: tick the quest lines it is a beat of. A line begins the first time one of its beat Sights is used (in `seq` order only the
 * FIRST beat can begin it). Returns journal lines (a quest began, a beat done, a quest finished with its reward).
 */
function trail_sight_quest_hook(array $u, string $slug, array $loc, array $now): array
{
    $out = [];
    $uid = (int)$u['id'];
    foreach (trail_sight_quests() as $q) {
        $idx = null; foreach ($q['beats'] as $i => $b) if ($b[0] === $slug) { $idx = $i; break; }
        if ($idx === null) continue;
        $row = trail_sight_quest_row($uid, $q['slug']);
        if ($row && $row['done_at'] !== null) continue;
        $done = $row ? (json_decode((string)$row['beats'], true) ?: []) : [];
        if (in_array($slug, $done, true)) continue;
        $when = $q['beats'][$idx][2];
        if ($when !== '-' && !stop_cond_ok($when, $now)) continue;
        if ($q['order'] === 'seq' && $idx !== count($done)) continue;   // in order: only the next beat counts
        try {
            if (!$row) { db_insert('user_sight_quests', ['user_id' => $uid, 'quest' => $q['slug'], 'beats' => '[]', 'started_at' => now(), 'done_at' => null]); $out[] = '📜 A quest begins: ' . $q['title'] . '. ' . $q['intro']; }
            $done[] = $slug;
            q('UPDATE user_sight_quests SET beats = ? WHERE user_id = ? AND quest = ?', [json_encode($done), $uid, $q['slug']]);
        } catch (Throwable $e) { continue; }   // table missing before Upgrade database
        if (count($done) >= count($q['beats'])) {
            q('UPDATE user_sight_quests SET done_at = ? WHERE user_id = ? AND quest = ?', [now(), $uid, $q['slug']]);
            $lines = trail_sight_pay($u, $loc, $q['reward'], $q['giver']);
            $out[] = '🎉 ' . $q['title'] . ' is done! ' . $q['outro'] . ($lines ? ' (' . implode(', ', $lines) . ')' : '');
        } else $out[] = '📜 ' . $q['title'] . ': ' . $q['beats'][$idx][1] . ' (' . count($done) . ' of ' . count($q['beats']) . ')';
    }
    return $out;
}

/** The quest lines a gnome has begun or finished, for the Tasks page: [[quest, done slugs, finished(bool)]]. */
function trail_sight_quests_of(int $uid): array
{
    $out = [];
    try { $rows = q('SELECT * FROM user_sight_quests WHERE user_id = ? ORDER BY id', [$uid])->fetchAll(); } catch (Throwable $e) { return []; }
    $all = trail_sight_quests();
    foreach ($rows as $r) if (isset($all[$r['quest']])) $out[] = [$all[$r['quest']], json_decode((string)$r['beats'], true) ?: [], $r['done_at'] !== null];
    return $out;
}

/** Which quest lines a Sight belongs to for this gnome: [[title, step n, of N, state 'next'|'later'|'done'|'new']]. For the Sight card. */
function trail_sight_quest_notes(int $uid, string $slug): array
{
    $out = [];
    foreach (trail_sight_quests() as $q) {
        foreach ($q['beats'] as $i => $b) if ($b[0] === $slug) {
            $row = trail_sight_quest_row($uid, $q['slug']);
            $done = $row ? (json_decode((string)$row['beats'], true) ?: []) : [];
            $fin = $row && $row['done_at'] !== null;
            $st = in_array($slug, $done, true) || $fin ? 'done' : (!$row ? ($q['order'] === 'any' || $i === 0 ? 'new' : 'later') : ($q['order'] === 'any' || $i === count($done) ? 'next' : 'later'));
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
    $file ??= __DIR__ . '/data/trail_sight_folk.txt';
    if (isset($c[$file])) return $c[$file];
    $out = [];
    foreach (is_file($file) ? (file($file, FILE_IGNORE_NEW_LINES) ?: []) : [] as $l) {
        $l = trim($l);
        if ($l === '' || $l[0] === '#') continue;
        $p = array_map('trim', explode('|', $l));
        if (count($p) >= 6 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]][] = ['slug' => $p[0], 'who' => $p[1], 'when' => $p[2] === '' ? '-' : $p[2], 'chance' => max(1, min(100, (int)$p[3])), 'line' => $p[4], 'rewards' => $p[5]];
    }
    return $c[$file] = $out;
}

/** The villagers who may be at a Sight right now (their condition holds, they are not away today): [[folk row, ...]]. Whether they really turn up is a roll in trail_sight_do. */
function trail_sight_folk_here(string $slug, array $now): array
{
    $out = [];
    foreach (trail_sight_folk()[$slug] ?? [] as $f) {
        if ($f['when'] !== '-' && !stop_cond_ok($f['when'], $now)) continue;
        $out[] = $f;
    }
    return $out;
}

/** A named villager's stop_folk id (made for the villages of the world on the way if needed), or 0 if no villager has that name. */
function trail_sight_folk_id(string $name): int
{
    try {
        $id = (int)q_val('SELECT id FROM stop_folk WHERE name = ? ORDER BY id LIMIT 1', [$name]);
        if ($id) return $id;
        require_once __DIR__ . '/stop_folk.php';
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
function trail_sight_pay(array $u, array $loc, string $rewards, string $who = ''): array
{
    require_once __DIR__ . '/stops.php';
    $now = null; $plain = []; $lines = [];
    foreach (trail_sight_tokens($rewards) as $t) {
        if ($t['cond'] !== '') { $now ??= stop_now($loc); if (!stop_cond_ok($t['cond'], $now)) continue; }
        $tok = $t['tok'];
        if (str_starts_with($tok, 'fp=') && $who !== '') {   // a stop villager (stop_folk) or a town NPC / traveller (npcs: shopkeepers, Tobias, Lyra, Wren, Pomeroy ...) by name
            $fid = trail_sight_folk_id($who); $pts = max(1, (int)substr($tok, 3));
            if ($fid) { require_once __DIR__ . '/stop_folk.php'; stop_friend_add((int)$u['id'], $fid, $pts); $lines[] = '💛 ' . $who . ' likes you a little more'; }
            else { try { $nid = (int)q_val('SELECT id FROM npcs WHERE name = ? AND active = 1 ORDER BY id LIMIT 1', [$who]); } catch (Throwable $e) { $nid = 0; }
                if ($nid) { require_once __DIR__ . '/friends.php'; friend_add((int)$u['id'], $nid, $pts); $lines[] = '💛 ' . $who . ' likes you a little more'; } }
            continue;
        }
        if (str_starts_with($tok, 'take=') || str_starts_with($tok, 'gather=') || str_starts_with($tok, 'unlock=')) continue;
        $plain[] = $tok;
    }
    return array_merge($plain ? stop_rewards($u, $loc, implode(',', $plain), 1.0) : [], $lines);
}

// ---------------------------------------------------------------- what the Trail page shows (P3)

/** Every landmark of the section the gnome is in that has a Sight: [['x','y','slug','row','left','why']]. Used for the marks over the sprites and the Sights card. */
function trail_sights_marks(array $u, ?array $sc): array
{
    if (!$sc || ($sc['st']['phase'] ?? '') !== 'section') return [];
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
function trail_sights_cards_html(array $u, array $sc, array $marks): string
{
    require_once __DIR__ . '/gathering.php'; require_once __DIR__ . '/tools.php';
    $h = '';
    foreach ($marks as $m) {
        $row = $m['row']; [$name, $cap] = trail_sight_label($m['slug']);
        $near = max(abs($m['x'] - (int)$sc['x']), abs($m['y'] - (int)$sc['y'])) <= 1;
        $bits = ['⚡' . (int)$row['energy'], gclock_on() ? gclock_time_cost('sight') . ' min' : ''];
        if ($row['tool'] !== '-') { [$tt, $tr] = explode(':', $row['tool']); $bits[] = '🧰 ' . (TOOL_TIERS[(int)$tr] ?? '') . ' ' . (GATHER_TOOL_NOUN[$tt] ?? $tt); }
        if ($row['check'] !== '-') $bits[] = '🎲 ' . ucfirst(explode(':', $row['check'])[0]);
        if ($row['when'] !== '-') $bits[] = '🕰️ ' . stop_cond_text($row['when']);
        $notes = '';
        foreach (trail_sight_quest_notes((int)$u['id'], $m['slug']) as [$qt, $n, $of, $st]) {
            $notes .= '<p class="sgq">📜 <b>' . e($qt) . '</b> · step ' . $n . ' of ' . $of . ' · ' . ['done' => 'done', 'next' => '<b>your next step</b>', 'later' => 'later', 'new' => 'starts here'][$st] . '</p>';
        }
        $act = $m['left'] < 1
            ? '<button class="btn" disabled>' . e($row['icon']) . ' ' . e($row['verb']) . ' <small>' . e($m['why'] ?: 'again soon') . '</small></button>'
            : ($near
                ? '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="sight"><input type="hidden" name="slug" value="' . e($m['slug']) . '"><button class="btn">' . e($row['icon']) . ' ' . e($row['verb']) . '</button></form>'
                : '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_go"><button class="btn alt" name="go" value="' . $m['x'] . ',' . $m['y'] . '">👣 Walk there</button></form>');
        $h .= '<div class="sgcard"><img class="sgpic" alt="" src="' . e(trail_art_url('obj/lm-' . $m['slug'] . '.png')) . '"><div class="sgbody"><h4>' . e($name) . '</h4>'
            . ($cap !== '' ? '<p class="help">' . e($cap) . '</p>' : '') . '<p class="muted sgdo">' . e($row['icon']) . ' ' . e($row['verb']) . ' · ' . e(implode(' · ', array_filter($bits))) . '</p>' . $notes . $act . '</div></div>';
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
            $d = in_array($b[0], $done, true);
            $next = !$d && ($q['order'] === 'any' || $i === count($done));
            $li .= '<li' . ($d ? ' class="muted"' : '') . '>' . ($d ? '✅ ' : ($next ? '👉 ' : '▫️ ')) . e($b[1]) . ($next ? ' <small>(' . e(trail_sight_label($b[0])[0]) . ')</small>' : '') . '</li>';
        }
        $open .= '<details class="sgq" open><summary>' . e($q['icon']) . ' <b>' . e($q['title']) . '</b> <small class="muted">' . count($done) . '/' . count($q['beats']) . ' · ' . e($q['giver']) . '</small></summary><ul class="qlist">' . $li . '</ul></details>';
    }
    return '<section class="box qsec"><h3>🔎 Sight quests</h3>' . ($open ?: '<p class="muted">None on the go.</p>') . ($fin ? '<p class="muted">' . $fin . ' finished.</p>' : '') . '</section>';
}

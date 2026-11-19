<?php
declare(strict_types=1);

/**
 * Trail Sights 2.7.08, third pass B (claude/sights/GRAMMAR.md "2.7.08 third pass B"; test tests/trail_sights_281.php): the engine gaps that each needed another system,
 * built as the smallest working version. No schema change: everything lives in data files, satchel items, the plants table and the quest / tally tables that exist.
 * - Birthdays: data/trail_sight_birthdays*.txt (Name | season | day of the season | wish line), read on the gnome's own game day (game_clock.php + hollow_clock.php).
 *   Condition `bd=<name-slug>[,..]|any`; reward `bday=N` (wish everyone whose birthday it is: +N friendship each); the villager card says it is their birthday and a present
 *   on the day counts double.
 * - Letters: data/trail_sight_letters*.txt (key | from | title | body); reward `letter=<key>` hands over a satchel item letter-<key> whose description is the letter.
 * - Bottle post: data/trail_sight_bottles*.txt (key | name | message | rewards); reward `bottle=1` at a coast or island Sight: a random note (item bottle-note-<key>) + its rewards.
 * - Quest lines: beat kind `@green[:Town]` (counts when the gnome does something on a town's Green); Q column 12 `board` = the line starts only from a Notice Board
 *   (town spot of kind board) or from a Sight's `quest=<slug>` reward, never from a beat.
 * - Seeds that grow: data/trail_sight_seeds*.txt makes a seed item and a plants row; reward `seed=<seed slug | crop slug>[:qty]` gives that exact seed (`seed=1` is still a random one).
 * - Keepsake tool effects: data/trail_sight_keepsakes*.txt writes {"keepsake":{"gather":"axe","qty":1}} into the item's effects JSON; carrying it adds finds with that tool.
 */

const TRAIL_SIGHT_REWARD_TOKENS_B = ['bday', 'letter', 'bottle', 'quest'];   // seed= is an old token; seed=<slug> is new here
const TRAIL_SIGHT_BOTTLE_LANDS = ['coast', 'island'];

// ---------------------------------------------------------------- data files

/** A name as a condition value: "Mabel Pennywhistle@v-na-1-2" -> "mabel-pennywhistle". */
function trail_sight_b_slug(string $who): string
{
    return trim((string)preg_replace('/[^a-z0-9]+/', '-', strtolower(explode('@', $who, 2)[0])), '-');
}

/** [['who','slug','season','day','line'], ...] from data/trail_sight_birthdays*.txt. */
function trail_sight_birthdays(?string $file = null): array
{
    static $c = [];
    $k = implode(',', array_map(fn($f) => $f . (is_file($f) ? filemtime($f) . '/' . filesize($f) : ''), trail_sight_data_files('birthdays', $file)));
    if (isset($c[$k])) return $c[$k];
    $out = [];
    foreach (trail_sight_data_lines('birthdays', $file) as $l) {
        $p = array_map('trim', explode('|', $l));
        if (count($p) >= 3 && $p[0] !== '') $out[] = ['who' => $p[0], 'slug' => trail_sight_b_slug($p[0]), 'season' => strtolower($p[1]), 'day' => (int)$p[2], 'line' => $p[3] ?? ''];
    }
    return $c[$k] = $out;
}

/** [key => [from, title, body]] from data/trail_sight_letters*.txt. */
function trail_sight_letters(?string $file = null): array
{
    $out = [];
    foreach (trail_sight_data_lines('letters', $file) as $l) { $p = array_map('trim', explode('|', $l, 4)); if (count($p) === 4 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2], $p[3]]; }
    return $out;
}

/** [key => [name, message, rewards]] from data/trail_sight_bottles*.txt. */
function trail_sight_bottles(?string $file = null): array
{
    $out = [];
    foreach (trail_sight_data_lines('bottles', $file) as $l) { $p = array_map('trim', explode('|', $l, 4)); if (count($p) >= 3 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2], $p[3] ?? '']; }
    return $out;
}

/** [seed slug => [name, produce slug, kind, tier, description]] from data/trail_sight_seeds*.txt. */
function trail_sight_seeds(?string $file = null): array
{
    $out = [];
    foreach (trail_sight_data_lines('seeds', $file) as $l) { $p = array_map('trim', explode('|', $l, 6)); if (count($p) === 6 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], $p[2], $p[3], max(1, min(6, (int)$p[4])), $p[5]]; }
    return $out;
}

/** [item slug => [tool, qty, note]] from data/trail_sight_keepsakes*.txt. */
function trail_sight_keepsakes(?string $file = null): array
{
    $out = [];
    foreach (trail_sight_data_lines('keepsakes', $file) as $l) { $p = array_map('trim', explode('|', $l, 4)); if (count($p) >= 3 && preg_match('/^[a-z0-9-]+$/', $p[0])) $out[$p[0]] = [$p[1], (int)$p[2], $p[3] ?? '']; }
    return $out;
}

/**
 * Make what the data files describe (adds only, idempotent; a signature in the settings skips the work when the files are unchanged):
 * letter-<key> and bottle-note-<key> items, the seed items and their plants rows, and the keepsake key in the effects JSON of the keepsake items.
 */
function trail_sight_b_ensure(): void
{
    $files = glob(__DIR__ . '/data/trail_sight_{letters,bottles,seeds,keepsakes}*.txt', GLOB_BRACE) ?: [];
    $sig = md5(implode(',', array_map(fn($f) => basename($f) . filemtime($f), $files)) . '|b2');
    try { if (setting('sight_b_sig') === $sig) return; } catch (Throwable $e) { return; }
    try {
        trail_sights_ensure_items();   // a seed may grow an item only Sights give (lantern-fruit)
        $add = function (string $slug, array $row) { if (!q_val('SELECT 1 FROM items WHERE slug = ?', [$slug])) db_insert('items', $row + ['slug' => $slug]); return (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]); };
        foreach (trail_sight_letters() as $k => [$from, $title, $body]) $add('letter-' . $k, ['name' => $title, 'category' => 'misc', 'rarity' => 5, 'base_price' => 1, 'description' => 'A letter from ' . $from . ': ' . $body, 'edible' => 0, 'tradable' => 0]);
        foreach (trail_sight_bottles() as $k => [$name, $msg]) $add('bottle-note-' . $k, ['name' => $name, 'category' => 'misc', 'rarity' => 12, 'base_price' => 4, 'description' => 'A note from a bottle: ' . $msg, 'edible' => 0]);
        $grow = [1 => 15, 2 => 40, 3 => 90, 4 => 180, 5 => 360, 6 => 720]; $water = [1 => 360, 2 => 480, 3 => 720, 4 => 1080, 5 => 1440, 6 => 1440];   // as catalog.php
        foreach (trail_sight_seeds() as $s => [$name, $prod, $kind, $tier, $desc]) {
            $pid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$prod]);
            if (!$pid) continue;   // the lint names a missing produce item
            $sid = $add($s, ['name' => $name, 'category' => 'seed', 'rarity' => 30 + $tier * 5, 'base_price' => 8 + $tier * 4, 'description' => $desc, 'edible' => 0]);
            if (!q_val('SELECT 1 FROM plants WHERE seed_item_id = ?', [$sid])) db_insert('plants', ['name' => preg_replace('/\s+(Seed|Seeds)$/', '', $name), 'slug' => preg_replace('/-seeds?$/', '', $s), 'kind' => $kind,
                'perennial' => 0, 'regrow_minutes' => 0, 'common' => 0, 'soil_effect' => -8, 'seed_item_id' => $sid, 'produce_item_id' => $pid, 'grow_minutes' => $grow[$tier], 'water_interval_minutes' => $water[$tier],
                'stages' => 4, 'yield_min' => 1, 'yield_max' => 3, 'xp_per_harvest' => $tier * $tier * 2 + 3, 'knowledge_max' => 100, 'knowledge_per_harvest' => 8 + $tier * 2, 'min_soil' => 0, 'description' => $desc]);
        }
        foreach (trail_sight_keepsakes() as $slug => [$tool, $qty]) {
            $it = q_one('SELECT id, effects FROM items WHERE slug = ?', [$slug]);
            if (!$it) continue;
            $fx = json_decode((string)$it['effects'], true); $fx = is_array($fx) ? $fx : [];
            if (isset($fx['keepsake']['gather'])) continue;   // there already (or edited in Admin): left alone
            $fx['keepsake'] = ['gather' => $tool, 'qty' => max(1, min(2, $qty))];
            q('UPDATE items SET effects = ? WHERE id = ?', [json_encode($fx), (int)$it['id']]);
        }
        set_setting('sight_b_sig', $sig);
    } catch (Throwable $e) { error_log('trail_sight_b_ensure: ' . $e->getMessage()); }
}

// ---------------------------------------------------------------- birthdays

/** The date a gnome's birthdays are read on: their own game day with the sleep-days clock on, else today. */
function trail_sight_bd_date(?array $u): string
{
    if ($u && function_exists('gclock_on') && gclock_on() && isset($u['game_day'])) return gclock_state($u)['date'];
    return hollow_today();
}

/** The birthday entries that fall on this gnome's day. A day past the season's length counts on its last day. */
function trail_sight_bd_today(?array $u): array
{
    $date = trail_sight_bd_date($u);
    $season = hollow_season($date); $day = hollow_season_day($date); $len = max(1, hollow_season_days_total($date));
    return array_values(array_filter(trail_sight_birthdays(), fn($b) => $b['season'] === $season && min($len, max(1, $b['day'])) === $day));
}

/** Is it this villager's birthday today (by name; `Name@village` rows match the name)? Returns the entry or null. */
function trail_sight_bd_of(array $u, string $name): ?array
{
    $s = trail_sight_b_slug($name);
    foreach (trail_sight_bd_today($u) as $b) if ($b['slug'] === $s) return $b;
    return null;
}

/** "spring 3" -> "the 3rd day of spring" for the card. */
function trail_sight_bd_when(array $b): string
{
    $d = $b['day']; $suf = ($d % 100 >= 11 && $d % 100 <= 13) ? 'th' : (['th', 'st', 'nd', 'rd'][$d % 10] ?? 'th');
    return 'the ' . $d . $suf . ' day of ' . $b['season'];
}

/** The villager card's birthday line: today, or when it is (only for villagers with a birthday row). */
function trail_sight_bd_card_note(array $u, string $name): string
{
    try {
        if ($b = trail_sight_bd_of($u, $name)) return '<p class="sgbday">🎂 It is ' . e($name) . '’s birthday today!' . ($b['line'] !== '' ? ' ' . e($b['line']) : '') . ' A present counts double.</p>';
        foreach (trail_sight_birthdays() as $b) if ($b['slug'] === trail_sight_b_slug($name)) return '<p class="help">🎂 Birthday: ' . e(trail_sight_bd_when($b)) . '.</p>';
    } catch (Throwable $e) {}
    return '';
}

/** A present on a villager's birthday counts double: [points, note for the message]. */
function trail_sight_bd_gift(array $u, string $name, int $pts): array
{
    try { if (trail_sight_bd_of($u, $name)) return [$pts * 2, ' 🎂 A birthday present: it counts double!']; } catch (Throwable $e) {}
    return [$pts, ''];
}

// ---------------------------------------------------------------- reward tokens

/** Is this reward token one of ours (bday= letter= bottle= quest=, or seed= with a seed slug rather than a number)? */
function trail_sight_b_token(string $tok): bool
{
    $tok = (string)preg_replace('/@\d+$/', '', $tok);
    if (preg_match('/^(bday|letter|bottle|quest)=/', $tok)) return true;
    return (bool)preg_match('/^seed=[a-z][a-z0-9-]*(:\d+)?$/', $tok);
}

/** The seed item id a `seed=<slug>` names: a seed slug (the seeds file, or any item a plant grows from), else a crop slug (plants.slug). 0 = none. */
function trail_sight_b_seed_id(string $slug): int
{
    trail_sight_b_ensure();
    $id = (int)q_val('SELECT i.id FROM items i JOIN plants p ON p.seed_item_id = i.id WHERE i.slug = ? LIMIT 1', [$slug]);
    return $id ?: (int)q_val('SELECT seed_item_id FROM plants WHERE slug = ? ORDER BY id LIMIT 1', [$slug]);
}

/** Pay one of our tokens (a trailing @N chance is rolled here). Returns journal lines. $loc['landscape'] = the walk's land (a bottle washes up only at the coast / an island). */
function trail_sight_b_pay(array $u, array $loc, string $tok, ?array $now = null): array
{
    if (preg_match('/^(.*)@(\d{1,3})$/', $tok, $m)) { if (random_int(1, 100) > (int)$m[2]) return []; $tok = $m[1]; }
    [$k, $v] = array_pad(explode('=', $tok, 2), 2, '');
    $uid = (int)$u['id'];
    trail_sight_b_ensure();
    if ($k === 'bday') {   // wish everyone whose birthday it is today
        $out = [];
        foreach (trail_sight_bd_today($u) as $b) { $f = trail_sight_befriend($u, $b['who'], max(1, (int)$v)); $out[] = '🎂 Happy birthday, ' . trail_sight_split_who($b['who'])[0] . '!' . ($b['line'] !== '' ? ' ' . $b['line'] : '') . ($f !== '' ? ' (' . $f . ')' : ''); }
        return $out;
    }
    if ($k === 'letter') {
        $L = trail_sight_letters()[$v] ?? null; $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', ['letter-' . $v]);
        if (!$L || !$iid) return [];
        if ((int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $iid]) > 0) return ['✉️ ' . $L[0] . ' waves: you already have their letter'];
        give_item($uid, $iid, 1);
        return ['✉️ A letter from ' . trail_sight_split_who($L[0])[0] . ': “' . $L[1] . '” (read it in your Satchel)'];
    }
    if ($k === 'bottle') {
        if (!in_array((string)($loc['landscape'] ?? ''), TRAIL_SIGHT_BOTTLE_LANDS, true)) return [];
        if ($s6 = sights6_bottle_stranger($u)) return $s6;   // sixth pass B: sometimes a stranger's note
        $all = trail_sight_bottles(); if (!$all) return [];
        $keys = array_keys($all); $key = $keys[random_int(0, count($keys) - 1)]; [$name, $msg, $rw] = $all[$key];
        $iid = (int)q_val('SELECT id FROM items WHERE slug = ?', ['bottle-note-' . $key]);
        if ($iid) give_item($uid, $iid, 1);
        return array_merge(['🍾 A bottle washes up. The note inside says: “' . $msg . '”'], $rw !== '' ? trail_sight_pay($u, $loc, $rw, '', $now) : []);
    }
    if ($k === 'quest') { $q = trail_sight_quests()[$v] ?? null; $l = $q ? trail_sight_quest_begin($u, $q) : ''; return $l !== '' ? [$l] : []; }
    if ($k === 'seed') {
        [$s, $qn] = array_pad(explode(':', $v, 2), 2, '1');
        $sid = trail_sight_b_seed_id($s); if (!$sid) return [];
        give_item($uid, $sid, max(1, (int)$qn));
        return ['🌱 +' . max(1, (int)$qn) . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$sid]) . ' (plant it in your garden)'];
    }
    return [];
}

/** Lint of one of our tokens in a reward list ($k, $v without the @chance). */
function trail_sight_b_lint(string $k, string $v, bool $db = true): array
{
    $bad = [];
    if ($k === 'bday' && !preg_match('/^[1-9]$/', $v)) $bad[] = 'bday= needs points 1 to 9 (everyone whose birthday it is today)';
    if ($k === 'letter' && !isset(trail_sight_letters()[$v])) $bad[] = 'letter= needs a key in trail_sight_letters.txt';
    if ($k === 'bottle' && $v !== '1') $bad[] = 'bottle= takes 1 (a random note from trail_sight_bottles.txt)';
    if ($k === 'quest' && !isset(trail_sight_quests()[$v])) $bad[] = 'quest= needs a quest line slug';
    if ($k === 'seed' && !preg_match('/^\d+$/', $v)) {
        $s = explode(':', $v)[0];
        if (!preg_match('/^[a-z][a-z0-9-]*(:\d+)?$/', $v)) $bad[] = 'seed= needs 1 (a random seed of the region) or a seed slug[:qty]';
        elseif (!isset(trail_sight_seeds()[$s]) && $db && !(function () use ($s) { try { return (bool)q_val('SELECT 1 FROM plants p JOIN items i ON i.id = p.seed_item_id WHERE i.slug = ? OR p.slug = ?', [$s, $s]); } catch (Throwable $e) { return true; } })()) $bad[] = 'seed= "' . $s . '" is no seed (trail_sight_seeds.txt, a plant\'s seed or a crop slug)';
    }
    return $bad;
}

/** Lint of the data files of this pass and of the quest start column. Lines "where: problem". */
function trail_sight_b_data_lint(): array
{
    $bad = [];
    foreach (trail_sight_birthdays() as $b) {
        if (!isset(HOLLOW_SEASONS[$b['season']])) $bad[] = 'birthday ' . $b['who'] . ': season must be ' . implode(', ', array_keys(HOLLOW_SEASONS));
        if ($b['day'] < 1 || $b['day'] > 120) $bad[] = 'birthday ' . $b['who'] . ': day of the season must be 1 to 120';
        if (!trail_sight_folk_id($b['who']) && !q_val('SELECT 1 FROM npcs WHERE name = ?', [trail_sight_split_who($b['who'])[0]])) $bad[] = 'birthday: no villager named ' . $b['who'];
        if (str_contains($b['line'], '{') || str_contains($b['line'], '}')) $bad[] = 'birthday ' . $b['who'] . ': no { } in the wish line';
    }
    $seen = []; foreach (trail_sight_birthdays() as $b) { if (isset($seen[$b['slug']])) $bad[] = 'birthday: ' . $b['who'] . ' has two rows'; $seen[$b['slug']] = 1; }
    foreach (trail_sight_letters() as $k => [$from, $title, $body]) if ($from === '' || $title === '' || $body === '' || mb_strlen($title) > 60) $bad[] = 'letter ' . $k . ': from, title (max 60) and body are all needed';
    foreach (trail_sight_bottles() as $k => [$name, $msg, $rw]) {
        if ($name === '' || $msg === '' || mb_strlen($name) > 60) $bad[] = 'bottle ' . $k . ': a name (max 60) and a message are needed';
        if ($rw !== '') {
            $probe = ['slug' => 'x', 'verb' => 'x', 'icon' => 'x', 'energy' => 0, 'cd' => 55, 'uses' => 1, 'when' => '-', 'check' => '-', 'rewards' => $rw, 'win' => 'x', 'lose' => '', 'tool' => '-', 'fail_en' => 0];
            foreach (trail_sight_lint($probe) as $p) if (!str_starts_with($p, 'no landmark picture')) $bad[] = 'bottle ' . $k . ': ' . $p;
            foreach (trail_sight_tokens($rw) as $t) if (preg_match('/^(take|choose|give|nocheck|check|tally|streak|lend|repay|escort|gather|time|bottle)(=|$)/', $t['tok'])) $bad[] = 'bottle ' . $k . ': ' . explode('=', $t['tok'])[0] . '= is not a plain reward';
        }
    }
    foreach (trail_sight_seeds() as $s => [$name, $prod, $kind, $tier]) {
        if (!str_ends_with($s, '-seed') && !str_ends_with($s, '-seeds')) $bad[] = 'seed ' . $s . ': the slug must end with -seed';
        if (!trail_sight_item_known($prod)) $bad[] = 'seed ' . $s . ': grows "' . $prod . '", which is no item';
        if (!preg_match('/^[a-z]+$/', $kind)) $bad[] = 'seed ' . $s . ': bad plant kind';
        if ($name === '') $bad[] = 'seed ' . $s . ': no name';
    }
    foreach (trail_sight_keepsakes() as $slug => [$tool, $qty]) {
        if (!trail_sight_item_known($slug)) $bad[] = 'keepsake: no item ' . $slug;
        if (!in_array($tool, GATHER_TOOLS, true)) $bad[] = 'keepsake ' . $slug . ': tool must be one of ' . implode(', ', GATHER_TOOLS);
        if ($qty < 1 || $qty > 2) $bad[] = 'keepsake ' . $slug . ': extra finds 1 or 2';
    }
    foreach (trail_sight_quests() as $q) if (!in_array($q['start'] ?? '', ['', 'board'], true)) $bad[] = 'quest ' . $q['slug'] . ': start (column 12) must be empty or board';
    return $bad;
}

// ---------------------------------------------------------------- quest lines: begin from a Notice Board / quest=, the @green beat

/** Begin a quest line now (its gate done, not begun yet). Returns the journal line or '' (already begun, gate not done). */
function trail_sight_quest_begin(array $u, array $q): string
{
    $uid = (int)$u['id'];
    if (!trail_sight_quest_table_ok() || trail_sight_quest_row($uid, $q['slug'])) return '';
    if ($q['gate'] !== '' && preg_match('/^quest:([a-z0-9-]+)$/', $q['gate'], $gm)) { $gr = trail_sight_quest_row($uid, $gm[1]); if (!$gr || $gr['done_at'] === null) return ''; }
    try { db_insert('user_sight_quests', ['user_id' => $uid, 'quest' => $q['slug'], 'beats' => '[]', 'started_at' => now(), 'done_at' => null]); } catch (Throwable $e) { return ''; }
    if (($q['limit'] ?? 0) > 0) trail_sight_tally_set($uid, 'qstart#' . $q['slug'], max(1, function_exists('gclock_on') && gclock_on() ? (int)($u['game_day'] ?? 0) : (int)floor(time() / 86400)));
    return '📜 A quest begins: ' . $q['title'] . '. ' . $q['intro'] . (($q['limit'] ?? 0) > 0 ? ' (You have ' . (int)$q['limit'] . ' game days.)' : '');
}

/** The board lines this gnome may take now (start = board, gate done, not begun). */
function trail_sight_board_quests(int $uid): array
{
    $out = [];
    foreach (trail_sight_quests() as $q) {
        if (($q['start'] ?? '') !== 'board' || trail_sight_quest_row($uid, $q['slug'])) continue;
        if ($q['gate'] !== '' && preg_match('/^quest:([a-z0-9-]+)$/', $q['gate'], $gm)) { $gr = trail_sight_quest_row($uid, $gm[1]); if (!$gr || $gr['done_at'] === null) continue; }
        $out[] = $q;
    }
    return $out;
}

/** The Notice Board's "Requests for walkers" list (spot_card.php, a town spot of kind board). */
function trail_sight_board_html(array $u, int $spotId, bool $hub): string
{
    try { $qs = trail_sight_board_quests((int)$u['id']); } catch (Throwable $e) { return ''; }
    if (!$qs) return '';
    $h = '<div class="sgboard"><b>📜 Requests for walkers</b>';
    foreach ($qs as $q) $h .= '<form method="post" class="tact">' . csrf_field() . '<input type="hidden" name="do" value="sightquest"><input type="hidden" name="quest" value="' . e($q['slug']) . '"><input type="hidden" name="spot" value="' . $spotId . '">' . ($hub ? '<input type="hidden" name="hub" value="1">' : '')
        . '<p>' . e($q['icon'] . ' ' . $q['title']) . ' <small class="muted">from ' . e(trail_sight_split_who($q['giver'])[0]) . '</small><br><small>' . e($q['intro']) . '</small></p><button class="btn act">Take it on</button></form>';
    return $h . '</div>';
}

/** Take a board line (town.php do=sightquest). [ok, message] */
function trail_sight_board_take(array $u, string $slug): array
{
    $q = trail_sight_quests()[$slug] ?? null;
    if (!$q || ($q['start'] ?? '') !== 'board') return [false, 'That request is not on the board.'];
    $l = trail_sight_quest_begin($u, $q);
    return $l !== '' ? [true, $l] : [false, 'You cannot take that one on now.'];
}

/** Something was done on a town's Green (town.php): fire the quest event @green:<Town>. Returns the quest lines as one string to add to the message ('' = none). */
function trail_sight_green_visit(array $u, int $spotId, int $actionId): string
{
    try {
        $spot = $actionId > 0 ? q_one('SELECT s.* FROM town_actions a JOIN town_spots s ON s.id = a.spot_id WHERE a.id = ?', [$actionId]) : null;
        $spot = $spot ?: ($spotId > 0 ? q_one('SELECT * FROM town_spots WHERE id = ?', [$spotId]) : null);
        if (!$spot || (string)$spot['kind'] !== 'green') return '';
        $lines = trail_sight_quest_event($u, 'green', (string)$spot['region']);
        return $lines ? ' ' . implode(' ', $lines) : '';
    } catch (Throwable $e) { return ''; }
}

// ---------------------------------------------------------------- keepsakes

/** Extra finds for a gather with $tool from the keepsakes the gnome carries (items whose effects JSON has keepsake.gather = $tool; at most 2 in all): [qty, names]. */
function trail_sight_keepsake_bonus(int $uid, string $tool): array
{
    try {
        trail_sight_b_ensure();
        $n = 0; $names = [];
        foreach (q("SELECT i.name, i.effects FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.effects LIKE '%keepsake%'", [$uid])->fetchAll() as $r) {
            $k = (json_decode((string)$r['effects'], true) ?: [])['keepsake'] ?? null;
            if (is_array($k) && ($k['gather'] ?? '') === $tool) { $n += max(1, (int)($k['qty'] ?? 1)); $names[] = (string)$r['name']; }
        }
        return [min(2, $n), $names];
    } catch (Throwable $e) { return [0, []]; }
}

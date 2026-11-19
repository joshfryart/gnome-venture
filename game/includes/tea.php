<?php
declare(strict_types=1);
/**
 * The Hovel tea kettle (design: "Plan 2 Base and Three" + the Tea Journal; data: data/tea_ingredients.txt, data/teas.txt).
 * Flag: setting tea_open = off / admin / everyone (default admin). Guests never. No UI in this file (see tea_view.php).
 *
 * A cup: one BASE that can steep (leaf, herb, flower; it counts double) and up to three extras; no ingredient twice,
 * one sweetener, one milk, 4 components at most. The cup is drunk at once and never becomes an item.
 *   steep[stat] = sum of the power of the components with that stat, the base x 2
 *   main = the base's stat; side = the other stat with the most steep (tie: the one added first)
 *   sweetener: +1 steep to main, and +1 to side if there is one; milk: +2 steep to main; a named tea: +1 steep to main
 *   points = min(cap, floor(steep x K / 8))        K and caps (main / side) per kettle: TEA_KETTLES
 * The JS twin for the live preview is assets/tea.js (gvTeaCup); tests/tea.sh checks that both give the same cups.
 *
 * The tea has its own slot: users.tea (JSON stat => points), users.tea_day (the day it was drunk), users.tea_name.
 * It lasts until the next sleep: tea_day is users.game_day while the game clock is on, else the Hollow date 'Y-m-d'
 * (gnome_tea_day() in gnome.php, read by eff_stat() and active_effects()). One brew a day; a second one replaces the first.
 * Kettles: users.kettle 0..3, a straight ladder: 0 Dented Tin (everyone), 1 Copper (bought), 2 Cast-Iron (8 named teas), 3 Samovar (16).
 */

/** [name, K, main cap, side cap] by tier. */
const TEA_KETTLES = [
    ['Dented Tin Kettle', 4, 1, 1],
    ['Copper Kettle', 5, 2, 1],
    ['Cast-Iron Kettle', 6, 2, 2],
    ['Silver Samovar', 7, 3, 2],
];
const TEA_COPPER_PRICE = 150;          // Petals for the Copper Kettle
const TEA_KETTLE_NEED = [2 => 8, 3 => 16];   // distinct named teas in the journal for tiers 2 and 3
const TEA_MAX_PARTS = 4;
/** kind => role. steep = may be the base; add = extra only. */
const TEA_KINDS = ['leaf' => 'steep', 'herb' => 'steep', 'flower' => 'steep', 'spice' => 'add', 'fruit' => 'add', 'sweet' => 'sweet', 'milk' => 'milk'];
const TEA_STATS = ['grit' => 'Grit', 'nimble' => 'Nimble', 'hardiness' => 'Hardiness', 'lore' => 'Lore', 'sense' => 'Sense', 'charm' => 'Charm', 'luck' => 'Luck'];
const TEA_HOUSE = 'House Blend';

/** Tables and columns. Returns [tables, indexes, columns] like the other *_schema() functions (wired in schema.php). */
function tea_schema(string $PK, string $ID, string $END): array
{
    return [["CREATE TABLE IF NOT EXISTS user_tea_journal (
        user_id INT NOT NULL,
        tea_slug VARCHAR(40) NOT NULL,
        first_day VARCHAR(12) NULL,
        times INT NOT NULL DEFAULT 0,
        UNIQUE (user_id, tea_slug)
    )$END"], [], [
        ['users', 'tea', 'TEXT NULL'],                     // today's cup: JSON stat => points (its own slot, beside the meal, lucky moments and town drink)
        ['users', 'tea_day', 'VARCHAR(12) NULL'],          // the day it was drunk: users.game_day (game clock on) or the Hollow date Y-m-d
        ['users', 'tea_name', 'VARCHAR(60) NULL'],
        ['users', 'kettle', 'INT NOT NULL DEFAULT 0'],     // 0 Dented Tin, 1 Copper, 2 Cast-Iron, 3 Silver Samovar
    ]];
}

/** Make the journal table and the users columns if the upgrade has not yet (files uploaded, version not bumped). Never fatal. */
function tea_ensure(): bool
{
    static $ok = null;
    if ($ok !== null) return $ok;
    try { q('SELECT tea, tea_day, tea_name, kettle FROM users LIMIT 1'); q('SELECT 1 FROM user_tea_journal LIMIT 1'); return $ok = true; } catch (Throwable $e) {}
    try {
        $sqlite = db()->getAttribute(PDO::ATTR_DRIVER_NAME) === 'sqlite';
        [$t, , $cols] = tea_schema('', '', $sqlite ? '' : ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
        foreach ($t as $sql) db()->exec($sql);
        foreach ($cols as [$tb, $col, $def]) {
            try { q("SELECT $col FROM $tb LIMIT 1"); } catch (Throwable $e) { db()->exec("ALTER TABLE $tb ADD COLUMN $col $def"); }
        }
        return $ok = true;
    } catch (Throwable $e) {
        error_log('tea_ensure: ' . $e->getMessage());
        return $ok = false;
    }
}

/** May this viewer see and use the kettle? Guests never. */
function tea_open_for(?array $u): bool
{
    if (!$u || !empty($u['guest'])) return false;
    $v = strtolower(trim(setting('tea_open')));
    if ($v === 'everyone' || $v === '1') return true;
    return $v === 'admin' && ($u['role'] ?? '') === 'admin';
}

/** Rows of a pipe-separated data file, comments and blank lines dropped. */
function tea_data_rows(string $file): array
{
    $out = [];
    foreach (@file(__DIR__ . '/data/' . $file, FILE_IGNORE_NEW_LINES) ?: [] as $ln) {
        $ln = trim($ln);
        if ($ln === '' || $ln[0] === '#') continue;
        $out[] = array_map('trim', explode('|', $ln));
    }
    return $out;
}

/** slug => [slug, name, kind, role, stat, power, items => [[item slug, optional]]], in file order. */
function tea_ingredients(): array
{
    static $c = null;
    if ($c !== null) return $c;
    $c = [];
    foreach (tea_data_rows('tea_ingredients.txt') as $r) {
        $slug = (string)($r[0] ?? ''); $kind = (string)($r[2] ?? '');
        if ($slug === '' || !isset(TEA_KINDS[$kind])) continue;
        $items = [];
        foreach (array_filter(array_map('trim', explode(',', (string)($r[5] ?? '')))) as $it) $items[] = [rtrim($it, '?'), str_ends_with($it, '?')];
        $stat = (string)($r[3] ?? '');
        $c[$slug] = ['slug' => $slug, 'name' => (string)($r[1] ?? $slug), 'kind' => $kind, 'role' => TEA_KINDS[$kind],
            'stat' => isset(TEA_STATS[$stat]) ? $stat : '', 'power' => isset(TEA_STATS[$stat]) ? max(0, (int)($r[4] ?? 0)) : 0, 'items' => $items ?: [[$slug, false]]];
    }
    return $c;
}

/** The order-free key of a set of component slugs. */
function tea_key(array $slugs): string
{
    $s = array_values(array_unique(array_map('strval', $slugs)));
    sort($s, SORT_STRING);
    return implode('+', $s);
}

/** slug => [slug, name, parts, note, key], in file order. */
function tea_named(): array
{
    static $c = null;
    if ($c !== null) return $c;
    $c = [];
    foreach (tea_data_rows('teas.txt') as $r) {
        $slug = (string)($r[0] ?? '');
        $parts = array_values(array_filter(array_map('trim', explode(',', (string)($r[2] ?? '')))));
        if ($slug === '' || !$parts) continue;
        $c[$slug] = ['slug' => $slug, 'name' => (string)($r[1] ?? $slug), 'parts' => $parts, 'note' => (string)($r[3] ?? ''), 'key' => tea_key($parts)];
    }
    return $c;
}

/** The named tea these components make (order-free, the whole set), or null. */
function tea_named_for(array $slugs): ?array
{
    $k = tea_key($slugs);
    foreach (tea_named() as $t) if ($t['key'] === $k) return $t;
    return null;
}

/** The caps of the best cup, from the settings tea_cap_main (default 3) and tea_cap_side (default 2): [main, side]. */
function tea_caps(): array
{
    $m = 3; $s = 2;
    try {
        if (function_exists('setting')) {
            if (($v = setting('tea_cap_main')) !== '') $m = max(0, (int)$v);
            if (($v = setting('tea_cap_side')) !== '') $s = max(0, (int)$v);
        }
    } catch (Throwable $e) {}
    return [$m, $s];
}

/** A kettle tier as [name, K, main cap, side cap], the caps already held under the settings. */
function tea_kettle(int $tier, ?array $caps = null): array
{
    $k = TEA_KETTLES[max(0, min(count(TEA_KETTLES) - 1, $tier))];
    [$cm, $cs] = $caps ?? tea_caps();
    return [$k[0], $k[1], min($k[2], $cm), min($k[3], $cs)];
}

/**
 * The cup these components make in this kettle. $slugs: the base first, then up to 3 extras (empty entries are dropped).
 * Pure: reads only the data files (and the two cap settings unless $caps = [main, side] is given).
 * Returns ['ok', 'error', 'name', 'slug' (named tea or ''), 'named', 'buff' => [stat => points > 0], 'main', 'side',
 *          'steep' => ['K', 'main' => [stat, steep, raw, cap, points], 'side' => the same or null], 'parts'].
 */
function tea_cup(array $slugs, int $tier, ?array $caps = null): array
{
    $bad = fn(string $why): array => ['ok' => false, 'error' => $why, 'name' => '', 'slug' => '', 'named' => false, 'buff' => [], 'main' => '', 'side' => '', 'steep' => null, 'parts' => []];
    $ING = tea_ingredients();
    $slugs = array_values(array_filter(array_map('strval', $slugs), fn($s) => $s !== ''));
    if (!$slugs) return $bad('Pick a base to steep.');
    if (count($slugs) > TEA_MAX_PARTS) return $bad('A cup holds ' . TEA_MAX_PARTS . ' components at most.');
    $seen = []; $sweet = 0; $milk = 0;
    foreach ($slugs as $s) {
        if (!isset($ING[$s])) return $bad('Unknown ingredient.');
        if (isset($seen[$s])) return $bad($ING[$s]['name'] . ' is in the cup twice. Each ingredient goes in once.');
        $seen[$s] = 1;
        if ($ING[$s]['role'] === 'sweet') $sweet++;
        if ($ING[$s]['role'] === 'milk') $milk++;
    }
    if ($ING[$slugs[0]]['role'] !== 'steep') return $bad('The base must be a leaf, herb, flower or root.');
    if ($sweet > 1) return $bad('One sweetener per cup.');
    if ($milk > 1) return $bad('One milk per cup.');
    [, $K, $capM, $capS] = tea_kettle($tier, $caps);
    $main = $ING[$slugs[0]]['stat'];
    $steep = [];   // insertion order = the order the stats were added
    foreach ($slugs as $i => $s) {
        $g = $ING[$s];
        if ($g['stat'] === '') continue;
        $steep[$g['stat']] = ($steep[$g['stat']] ?? 0) + $g['power'] * ($i === 0 ? 2 : 1);
    }
    $side = '';
    foreach ($steep as $st => $v) if ($st !== $main && ($side === '' || $v > $steep[$side])) $side = $st;
    $nm = tea_named_for($slugs);
    if ($sweet) { $steep[$main]++; if ($side !== '') $steep[$side]++; }
    if ($milk) $steep[$main] += 2;
    if ($nm) $steep[$main]++;
    $rawM = intdiv($steep[$main] * $K, 8); $mp = min($capM, $rawM);
    $rawS = $side !== '' ? intdiv($steep[$side] * $K, 8) : 0; $sp = $side !== '' ? min($capS, $rawS) : 0;
    $buff = [];
    if ($mp > 0) $buff[$main] = $mp;
    if ($sp > 0) $buff[$side] = $sp;
    return ['ok' => true, 'error' => '', 'name' => $nm ? $nm['name'] : TEA_HOUSE, 'slug' => $nm ? $nm['slug'] : '', 'named' => (bool)$nm, 'buff' => $buff, 'main' => $main, 'side' => $side,
        'steep' => ['K' => $K, 'main' => ['stat' => $main, 'steep' => $steep[$main], 'raw' => $rawM, 'cap' => $capM, 'points' => $mp],
            'side' => $side !== '' ? ['stat' => $side, 'steep' => $steep[$side], 'raw' => $rawS, 'cap' => $capS, 'points' => $sp] : null],
        'parts' => $slugs];
}

/**
 * The cup a form asks for: $in['base'] (a slug) and $in['c'] (slugs: an array, or a comma list). Returns the slugs for tea_cup(): the base
 * first, then the others in the order of the cards (by role, then the data file's order). With no base named, the first thing that can steep is the base.
 */
function tea_pick(array $in): array
{
    $ING = tea_ingredients();
    $c = $in['c'] ?? [];
    if (!is_array($c)) $c = explode(',', (string)$c);
    $c = array_slice(array_values(array_unique(array_filter(array_map(fn($s) => is_string($s) ? trim($s) : '', $c), fn($s) => $s !== ''))), 0, 12);
    $base = is_string($in['base'] ?? null) ? trim($in['base']) : '';
    if ($base === '' || !isset($ING[$base])) { $base = ''; foreach ($ING as $s => $g) if ($g['role'] === 'steep' && in_array($s, $c, true)) { $base = $s; break; } }
    $rest = [];   // the order of the cards on the page (assets/tea.js reads them the same way): by role, then the file's order
    foreach (['steep', 'add', 'sweet', 'milk'] as $role) foreach ($ING as $s => $g) if ($g['role'] === $role && $s !== $base && in_array($s, $c, true)) $rest[] = $s;
    foreach ($c as $s) if (!isset($ING[$s])) $rest[] = $s;   // an unknown slug stays in, so tea_cup refuses the cup
    return array_merge($base !== '' ? [$base] : [], $rest);
}

/** "Lore +2, Charm +1" for a buff, or '' when it gives nothing. */
function tea_buff_text(array $buff): string
{
    $o = [];
    foreach ($buff as $st => $n) if (isset(TEA_STATS[$st]) && (int)$n > 0) $o[] = TEA_STATS[$st] . ' +' . (int)$n;
    return implode(', ', $o);
}

/** The day key a cup is drunk on (users.tea_day): the game day while the game clock is on, else the Hollow date. */
function tea_day_key(array $u): string
{
    return function_exists('gclock_on') && gclock_on() ? (string)(int)($u['game_day'] ?? 0) : hollow_date('Y-m-d');
}

/** Today's cup: ['name', 'buff'] or null (none yet today, or it ended with the last sleep). */
function tea_today(array $u): ?array
{
    if (!isset($u['tea_day']) || (string)$u['tea_day'] === '' || (string)$u['tea_day'] !== tea_day_key($u)) return null;
    $b = json_decode((string)($u['tea'] ?? ''), true);
    return ['name' => (string)($u['tea_name'] ?? '') !== '' ? (string)$u['tea_name'] : TEA_HOUSE, 'buff' => array_filter(array_map('intval', is_array($b) ? $b : []), fn($n, $s) => isset(TEA_STATS[$s]) && $n > 0, ARRAY_FILTER_USE_BOTH)];
}

/** The ingredients this gnome holds: ingredient slug => ['qty' (all its items), 'item' => the items row that would be spent]. */
function tea_satchel(int $uid): array
{
    $want = [];
    foreach (tea_ingredients() as $slug => $g) foreach ($g['items'] as [$it]) $want[$it] = true;
    if (!$want) return [];
    $rows = [];
    $ph = implode(',', array_fill(0, count($want), '?'));
    foreach (q("SELECT i.*, ui.qty AS held FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.slug IN ($ph)", array_merge([$uid], array_keys($want)))->fetchAll() as $r) $rows[(string)$r['slug']] = $r;
    $out = [];
    foreach (tea_ingredients() as $slug => $g) {
        $qty = 0; $first = null;
        foreach ($g['items'] as [$it]) if (isset($rows[$it])) { $qty += (int)$rows[$it]['held']; $first ??= $rows[$it]; }
        if ($first) $out[$slug] = ['qty' => $qty, 'item' => $first];
    }
    return $out;
}

/** The journal: ['found' => [tea slug => [first_day, times]], 'n' => found count, 'total' => named teas]. */
function tea_journal(int $uid): array
{
    $found = [];
    $named = tea_named();
    try {
        foreach (q('SELECT tea_slug, first_day, times FROM user_tea_journal WHERE user_id = ?', [$uid])->fetchAll() as $r) {
            if (isset($named[$r['tea_slug']])) $found[(string)$r['tea_slug']] = ['first_day' => (string)$r['first_day'], 'times' => (int)$r['times']];
        }
    } catch (Throwable $e) {}
    return ['found' => $found, 'n' => count($found), 'total' => count($named)];
}

/** Stamp a named tea. True when it is new to the journal. */
function tea_journal_stamp(int $uid, string $slug, string $day): bool
{
    if (!isset(tea_named()[$slug]) || !tea_ensure()) return false;
    if (q('UPDATE user_tea_journal SET times = times + 1 WHERE user_id = ? AND tea_slug = ?', [$uid, $slug])->rowCount() > 0) return false;
    try { q('INSERT INTO user_tea_journal (user_id, tea_slug, first_day, times) VALUES (?, ?, ?, 1)', [$uid, $slug, $day]); return true; }
    catch (Throwable $e) { q('UPDATE user_tea_journal SET times = times + 1 WHERE user_id = ? AND tea_slug = ?', [$uid, $slug]); return false; }   // another tab stamped it a moment ago
}

/**
 * Move the kettle up the ladder where the journal allows: Copper -> Cast-Iron at 8 named teas, Cast-Iron -> Samovar at 16.
 * (The Copper Kettle is bought: tea_kettle_buy.) Returns the names of the kettles unlocked just now.
 */
function tea_kettle_unlocks(int $uid): array
{
    if (!tea_ensure()) return [];
    $got = [];
    $n = tea_journal($uid)['n'];
    foreach (TEA_KETTLE_NEED as $tier => $need) {
        if ($n < $need) break;
        if (q('UPDATE users SET kettle = ? WHERE id = ? AND kettle = ?', [$tier, $uid, $tier - 1])->rowCount() === 1) $got[] = TEA_KETTLES[$tier][0];
    }
    return $got;
}

/** What the next kettle is and what it needs: ['tier', 'name', 'buy' => Petals or 0, 'need' => named teas or 0, 'have' => named teas found], or null at the top. */
function tea_kettle_next(array $u): ?array
{
    $t = max(0, (int)($u['kettle'] ?? 0)) + 1;
    if (!isset(TEA_KETTLES[$t])) return null;
    return ['tier' => $t, 'name' => TEA_KETTLES[$t][0], 'buy' => $t === 1 ? TEA_COPPER_PRICE : 0, 'need' => TEA_KETTLE_NEED[$t] ?? 0, 'have' => tea_journal((int)$u['id'])['n']];
}

/** Buy the Copper Kettle. [ok, message]. */
function tea_kettle_buy(array $u): array
{
    if (!tea_open_for($u)) return [false, 'The kettle is not ready yet.'];
    if (!tea_ensure()) return [false, 'The kettle could not be reached. Try again in a moment.'];
    $uid = (int)$u['id'];
    if ((int)q_val('SELECT kettle FROM users WHERE id = ?', [$uid]) !== 0) return [false, 'You already have a better kettle than the tin one.'];
    try { return db_tx(function () use ($uid) {
        if (!take_petals($uid, TEA_COPPER_PRICE, 'Copper Kettle')) return [false, 'The Copper Kettle costs ' . TEA_COPPER_PRICE . ' Petals. You do not have enough yet.'];
        if (q('UPDATE users SET kettle = 1 WHERE id = ? AND kettle = 0', [$uid])->rowCount() !== 1) throw new RuntimeException('kettle changed');
        $more = tea_kettle_unlocks($uid);
        return [true, '🫖 The Copper Kettle is on the side table. It steeps a stronger cup.' . ($more ? ' Your journal also earns you the ' . implode(' and the ', $more) . '!' : '')];
    }); } catch (RuntimeException $e) { return [false, 'That changed in another tab. Try again.']; }
}

/**
 * Brew and drink a cup. $slugs: the base first, then the extras. $confirm: the gnome agreed to pour out today's earlier cup.
 * Spends one of each ingredient, sets the tea slot, stamps the journal for a named tea and moves the kettle up when the journal allows.
 * Returns [ok, message, cup (tea_cup's array, or null)].
 */
function tea_brew(array $u, array $slugs, bool $confirm = false): array
{
    if (!tea_open_for($u)) return [false, 'The kettle is not ready yet.', null];
    if (!tea_ensure()) return [false, 'The kettle could not be reached. Try again in a moment.', null];
    $uid = (int)$u['id'];
    $u = q_one('SELECT * FROM users WHERE id = ?', [$uid]) ?: $u;   // the row as it is now (another tab may have brewed)
    $cup = tea_cup($slugs, (int)($u['kettle'] ?? 0));
    if (!$cup['ok']) return [false, $cup['error'], $cup];
    $day = tea_day_key($u);
    $old = tea_today($u);
    if ($old && !$confirm) return [false, 'You have had a cup today. Brewing again pours out your ' . $old['name'] . ': tick the box to agree, then brew.', $cup];
    $ING = tea_ingredients();
    $have = tea_satchel($uid);
    foreach ($cup['parts'] as $s) if (empty($have[$s])) return [false, 'You have no ' . $ING[$s]['name'] . ' in your satchel.', $cup];
    try {
        $new = db_tx(function () use ($uid, $cup, $have, $day, $ING) {
            foreach ($cup['parts'] as $s) {
                if (!give_item($uid, (int)$have[$s]['item']['id'], -1)) throw new RuntimeException('You have no ' . $ING[$s]['name'] . ' in your satchel.');
            }
            q('UPDATE users SET tea = ?, tea_day = ?, tea_name = ? WHERE id = ?', [json_encode((object)$cup['buff']), $day, $cup['name'], $uid]);
            return $cup['named'] ? tea_journal_stamp($uid, $cup['slug'], $day) : false;
        });
    } catch (RuntimeException $e) {
        return [false, $e->getMessage(), $cup];
    }
    $unlocked = tea_kettle_unlocks($uid);
    $bt = tea_buff_text($cup['buff']);
    $msg = '🫖 You brew a cup of ' . $cup['name'] . ' and drink it warm. ' . ($bt !== '' ? $bt . ' until you sleep.' : 'It is pleasant, but too weak for a boost.');
    if ($old) $msg = '🫖 You pour out the ' . $old['name'] . '. ' . substr($msg, strlen('🫖 '));
    if ($new) { $j = tea_journal($uid); $msg .= ' New in your Tea Journal: ' . $cup['name'] . ' (' . $j['n'] . ' of ' . $j['total'] . ').'; }
    foreach ($unlocked as $k) $msg .= ' Your journal earns you the ' . $k . '!';
    return [true, $msg, $cup];
}

/** The data the JS twin needs (assets/tea.js gvTeaCup): ingredients, named teas, the kettle with its caps. */
function tea_js_data(int $tier, ?array $caps = null, ?array $only = null): array
{
    $ing = [];   // $only = the ingredient slugs to send (the ones the gnome holds): a named tea that needs another cannot be made, so it is left out too
    foreach (tea_ingredients() as $s => $g) if ($only === null || in_array($s, $only, true)) $ing[$s] = [$g['name'], $g['role'], $g['stat'], $g['power']];
    $named = [];
    foreach (tea_named() as $t) if (!array_diff($t['parts'], array_keys($ing))) $named[] = [$t['name'], $t['parts']];
    [, $K, $cm, $cs] = tea_kettle($tier, $caps);
    return ['ing' => $ing, 'named' => $named, 'k' => [$K, $cm, $cs], 'stat' => TEA_STATS, 'max' => TEA_MAX_PARTS, 'house' => TEA_HOUSE];
}

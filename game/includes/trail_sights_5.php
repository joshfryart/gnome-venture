<?php
declare(strict_types=1);

/**
 * Sights engine gaps, fifth pass (claude/sights/GRAMMAR.md "Fifth pass"; test tests/trail_sights_283.sh). No schema change (a new tally key only; one new data file).
 *  1. An ITEM as a check alternative: `nimble:9+item:plank[:qty]`. The stat halves are rolled first; only when all of them fail is the item used up, and it wins.
 *  2. A villager's own check with a miss line: a folk row `line // miss line` with `check=stat:dc` among its rewards. A miss says the miss line and pays nothing.
 *     (A row with a check and no miss line keeps the old "They ask more of you than you can manage today".) A give= row rolls the check BEFORE it takes the item.
 *  3. Any-of takes and gives over a category: `take=any-seed:1`, `give=any-produce+flower:1` (a plant kind, a slug ending, or an item category; `+` joins kinds).
 *  4. A shop discount scoped to an item category: `disc=shop:20:60:seed` (the fourth part). Kept in users.ev_disc under the key "shop:<category>".
 *  5. Sight KINDS: data/trail_sight_kinds.txt (`slug|kind[,kind]`; crossing fishing rest) and the token `nextkind=<kind>:+N` (the next Sight of that kind on THIS walk
 *     gets +N on its stat check) or `nextkind=<kind>:fish=N` (it pays N more catches on a win). Waiting effects are private tallies holding walk id * 10 + N.
 *  6. A quest time limit of one season: the 11th Q column may say `season` (= the season length in game days, setting season_days).
 * Everything here is new functions; trail_sights.php, trail_sight_extras.php, world.php and the data only call them.
 */

const SIGHTS5_KINDS = ['crossing', 'fishing', 'rest'];
const SIGHTS5_DISC_SCOPES = ['seed' => 'seeds', 'produce' => 'crops', 'food' => 'food', 'flower' => 'flowers', 'supply' => 'supplies', 'soil' => 'soil', 'decor' => 'decor', 'part' => 'building materials'];
const SIGHTS5_ANY_CATS = ['seed', 'flower', 'food', 'produce'];   // an "any-<word>" that is an item category (the older any-<plant kind> / any-<slug ending> keep working)
const SIGHTS5_ANY_RE = '/^any-[a-z]+(?:\+[a-z]+)*$/';
const SIGHTS5_ITEM_ALT_RE = '/^item:([a-z0-9-]+)(?::([1-9]))?$/';
const SIGHTS5_NEXT_RE = '/^([a-z]+):(?:\+([1-3])|fish=([1-3]))$/';

// ---------------------------------------------------------------- 1. an item as a check alternative

/** `item:sardine` / `item:sardine:2` as [slug, qty], or null when $alt is not an item alternative. */
function sights5_item_alt(string $alt): ?array
{
    return preg_match(SIGHTS5_ITEM_ALT_RE, $alt, $m) ? [$m[1], (int)($m[2] ?? 1)] : null;
}

/** The check as the Sights card names it: `nimble:9+item:plank` = "Nimble or Plank" (the item's name). */
function sights5_check_label(string $check): string
{
    $parts = [];
    foreach (explode('+', $check) as $alt) {
        if ($ia = sights5_item_alt($alt)) { $n = (string)q_val('SELECT name FROM items WHERE slug = ?', [$ia[0]]); $parts[] = $n !== '' ? $n : $ia[0]; }
        else $parts[] = explode(':', $alt)[0];
    }
    return ucfirst(implode(' or ', $parts));
}

/**
 * Roll a stat check that may hold item alternatives. Every stat half is rolled (a $bonus from a nextkind tip lowers each difficulty); when none passes, an item half the
 * gnome carries is used up and wins. Returns [ok, journal notes].
 */
function sights5_check_roll(array $u, string $check, int $bonus = 0): array
{
    $ok = false; $notes = []; $items = [];
    foreach (explode('+', $check) as $alt) {
        if ($ia = sights5_item_alt($alt)) { $items[] = $ia; continue; }
        if ($ok) continue;
        [$stat, $dc] = array_pad(explode(':', $alt, 2), 2, '0'); [$one] = stop_check($u, $stat, max(0, (int)$dc - $bonus));
        if ($one) $ok = true;
    }
    if (!$ok) foreach ($items as [$slug, $qty]) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
        if ($id && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [(int)$u['id'], $id]) >= $qty && give_item((int)$u['id'], $id, -$qty)) {
            $ok = true; $notes[] = '🎒 used ' . $qty . ' × ' . (string)q_val('SELECT name FROM items WHERE id = ?', [$id]); break;
        }
    }
    return [$ok, $notes];
}

// ---------------------------------------------------------------- 3. any-of over a category

/** The item ids that count for `any-<spec>` (spec = word[+word...]): a category word (seed flower food produce) = every item of it, else the older kind / slug-ending rule. */
function sights5_any_items(string $spec): array
{
    $ids = [];
    foreach (explode('+', $spec) as $part) {
        if (!preg_match('/^[a-z]+$/', $part)) continue;
        if (in_array($part, SIGHTS5_ANY_CATS, true)) $ids = array_merge($ids, array_map('intval', q('SELECT id FROM items WHERE category = ?', [$part])->fetchAll(PDO::FETCH_COLUMN)));
        else $ids = array_merge($ids, trail_sight_any_items($part));
    }
    return array_values(array_unique(array_map('intval', $ids)));
}

/** "any seed" / "any produce or flower". */
function sights5_any_label(string $spec): string { return 'any ' . str_replace('+', ' or ', $spec); }

/** [stacks (item id => qty held, biggest first), total held] for an any-of spec. */
function sights5_any_have(int $uid, string $spec): array
{
    $stk = [];
    foreach (sights5_any_items($spec) as $cid) { $qy = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $cid]); if ($qy > 0) $stk[$cid] = $qy; }
    arsort($stk);
    return [$stk, array_sum($stk)];
}

/** Use up $qty of an any-of spec (biggest stacks first). False when the gnome does not hold enough (nothing is taken then). */
function sights5_any_use(int $uid, string $spec, int $qty): bool
{
    [$stk, $have] = sights5_any_have($uid, $spec);
    if ($have < $qty) return false;
    foreach ($stk as $cid => $qy) { $use = min($qty, $qy); if (!give_item($uid, (int)$cid, -$use)) return false; $qty -= $use; if ($qty <= 0) break; }
    return true;
}

// ---------------------------------------------------------------- 2. a villager's own check, with a miss line

/** Split a folk row's line column: [line, miss line ('' when none)]. */
function sights5_split_miss(string $line): array
{
    $p = explode(' // ', $line, 2);
    return [trim($p[0]), trim($p[1] ?? '')];
}

/** The villager's own check of a folk row (`check=stat:dc`, its ?cond holding): [stat, dc] or null when the row has none. */
function sights5_folk_check_of(array $f, array $now): ?array
{
    foreach (trail_sight_tokens((string)$f['rewards']) as $t) if (str_starts_with($t['tok'], 'check=') && ($t['cond'] === '' || trail_sight_cond_ok($t['cond'], $now))) {
        [$cs, $cdc] = array_pad(explode(':', substr($t['tok'], 6), 2), 2, '10');
        return [$cs, (int)$cdc];
    }
    return null;
}

/** Roll the villager's own check for a row that is at the Sight: null = the row has no check, true / false = passed / missed. */
function sights5_folk_roll(array $u, array $f, array $now): ?bool
{
    $c = sights5_folk_check_of($f, $now);
    if (!$c) return null;
    require_once __DIR__ . '/stops.php';
    return (bool)stop_check($u, $c[0], $c[1])[0];
}

/** What a missed villager check says: the row's miss line, else the old stock sentence. */
function sights5_folk_miss_text(array $f, array $now): string
{
    if (($f['miss'] ?? '') !== '') return $f['miss'];
    $c = sights5_folk_check_of($f, $now) ?? ['stat', 0];
    return 'They ask more of you than you can manage today (' . $c[0] . ' ' . $c[1] . ').';
}

/** " (a Grit check)" for the Sights card line of a villager who asks for something. */
function sights5_folk_card_note(array $f, array $now): string
{
    $c = sights5_folk_check_of($f, $now);
    return $c ? ' <small class="muted">(a ' . e((string)$c[0]) . ' check)</small>' : '';
}

// ---------------------------------------------------------------- 4. a shop discount scoped to an item category

/** The scoped shop discount percent for one item (0 when none): the key "shop:<item category>" of users.ev_disc. */
function sights5_disc_item_pct(int $uid, int $itemId): int
{
    if ($itemId <= 0) return 0;
    try { $cat = (string)q_val('SELECT category FROM items WHERE id = ?', [$itemId]); } catch (Throwable $e) { return 0; }
    return isset(SIGHTS5_DISC_SCOPES[$cat]) ? trail_sight_disc_pct($uid, 'shop:' . $cat) : 0;
}

// ---------------------------------------------------------------- 5. Sight kinds and the "next Sight of that kind" tips

/** The kinds of a Sight (data/trail_sight_kinds.txt, or the test override gv_sight_kinds_file): crossing / fishing / rest. [] for a Sight with none. */
function sights5_kinds(string $slug): array
{
    static $c = [];
    $files = trail_sight_data_files('kinds'); $key = implode(',', $files) . '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, $files));
    if (!isset($c[$key])) {
        $c[$key] = [];
        foreach (trail_sight_data_lines('kinds') as $l) { [$s, $k] = array_pad(array_map('trim', explode('|', $l, 2)), 2, ''); if ($s !== '' && $k !== '') $c[$key][$s] = array_values(array_filter(array_map('trim', explode(',', $k)))); }
    }
    return $c[$key][$slug] ?? [];
}

/** The walk this gnome is on (0 when none): a tip is good for this walk only. */
function sights5_walk_id(int $uid): int
{
    try { $e = function_exists('active_expedition') ? active_expedition($uid) : null; return $e ? (int)$e['id'] : 0; } catch (Throwable $e2) { return 0; }
}

/** `nextkind=<kind>:+N` / `<kind>:fish=N`: remember a tip for the next Sight of that kind on this walk. Returns the journal fragment ('' when there is no walk or the value is bad). */
function sights5_next_add(array $u, string $v): string
{
    if (!preg_match(SIGHTS5_NEXT_RE, $v, $m) || !in_array($m[1], SIGHTS5_KINDS, true)) return '';
    $wid = sights5_walk_id((int)$u['id']);
    if ($wid < 1) return '';
    $bonus = (int)($m[2] ?? 0); $fish = (int)($m[3] ?? 0);
    trail_sight_tally_set((int)$u['id'], 'nk#' . $m[1] . ($bonus ? '#b' : '#f'), $wid * 10 + ($bonus ?: $fish));
    return $bonus ? '🤝 Your next ' . $m[1] . ' Sight on this walk goes +' . $bonus . ' easier' : '🎣 Your next ' . $m[1] . ' Sight on this walk pays ' . $fish . ' more catch' . ($fish === 1 ? '' : 'es');
}

/** Take (and use up) a waiting tip of one sort for a Sight's kinds: the total N, 0 when none (or from an earlier walk: stale tips are ignored). */
function sights5_kind_take(array $u, string $slug, string $sort): int
{
    $kinds = sights5_kinds($slug);
    if (!$kinds) return 0;
    $uid = (int)$u['id']; $wid = sights5_walk_id($uid); $t = trail_sight_tallies($uid); $n = 0;
    foreach ($kinds as $k) {
        $key = 'nk#' . $k . '#' . $sort; $v = (int)($t[$key] ?? 0);
        if ($v < 1) continue;
        if ($wid > 0 && intdiv($v, 10) === $wid && q('UPDATE trail_sight_tally SET n = 0 WHERE user_id = ? AND tkey = ? AND n = ?', [$uid, $key, $v])->rowCount() === 1) $n += $v % 10;
    }
    return $n;
}
function sights5_kind_take_bonus(array $u, string $slug): int { return sights5_kind_take($u, $slug, 'b'); }
function sights5_kind_take_fish(array $u, string $slug): int { return sights5_kind_take($u, $slug, 'f'); }

// ---------------------------------------------------------------- 6. a quest limit of one season

/** The 11th Q column: a number of game days, or `season` (the season length, setting season_days). [limit, is a season]. */
function sights5_limit(string $v): array
{
    if (trim($v) === 'season') { require_once __DIR__ . '/hollow_clock.php'; return [hollow_season_length(), true]; }
    return [max(0, (int)$v), false];
}

// ---------------------------------------------------------------- lint

/** Problems with one alternative of a check when it is an item alternative; null when $alt is no item alternative. */
function sights5_lint_item_alt(string $alt, bool $db = true): ?array
{
    if (!str_starts_with($alt, 'item:')) return null;
    if (!($ia = sights5_item_alt($alt))) return ['check item alternative must be item:slug or item:slug:1-9'];
    if ($db && !trail_sight_item_known($ia[0])) return ['check item alternative: no item "' . $ia[0] . '"'];
    return [];
}

/** Problems with the fifth-pass tokens: take= / give= any-<kinds>, disc= scope, nextkind=. */
function sights5_lint_token(string $k, string $v, bool $db = true): array
{
    $bad = [];
    if (($k === 'take' || $k === 'give') && str_starts_with($v, 'any-')) {
        $spec = explode(':', $v)[0];
        if (!preg_match(SIGHTS5_ANY_RE, $spec)) $bad[] = $k . '= needs any-<kind>[+<kind>] in lower case letters, e.g. any-seed or any-produce+flower';
    }
    if ($k === 'disc') {
        $p = explode(':', $v);
        if (isset($p[3]) && ($p[0] !== 'shop' || !isset(SIGHTS5_DISC_SCOPES[$p[3]]))) $bad[] = 'disc= scope (a fourth part) works on shop only, with one of ' . implode(', ', array_keys(SIGHTS5_DISC_SCOPES));
    }
    if ($k === 'nextkind' && (!preg_match(SIGHTS5_NEXT_RE, $v, $m) || !in_array($m[1] ?? '', SIGHTS5_KINDS, true))) $bad[] = 'nextkind= needs <kind>:+1..3 or <kind>:fish=1..3 (kinds: ' . implode(', ', SIGHTS5_KINDS) . ')';
    return $bad;
}

/** Problems with the Sight kinds data: [line problems]. */
function sights5_lint_kinds(array $all): array
{
    $bad = [];
    foreach (trail_sight_data_lines('kinds') as $l) {
        [$s, $k] = array_pad(array_map('trim', explode('|', $l, 2)), 2, '');
        if (!isset($all[$s])) $bad[] = 'kinds: no Sight "' . $s . '"';
        foreach (array_filter(array_map('trim', explode(',', $k))) as $kk) if (!in_array($kk, SIGHTS5_KINDS, true)) $bad[] = 'kinds: ' . $s . ' has unknown kind "' . $kk . '"';
        if ($k === '') $bad[] = 'kinds: ' . $s . ' has no kind';
    }
    return $bad;
}

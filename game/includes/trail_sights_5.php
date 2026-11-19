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
        if (($wl = sights6a_word_list($part)) !== null) { foreach ($wl as $ws) { $wid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$ws]); if ($wid) $ids[] = $wid; } continue; }   // sixth pass A: a word list (any-bread, any-tea)
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
    try { $it = q_one('SELECT category, slug FROM items WHERE id = ?', [$itemId]); } catch (Throwable $e) { return 0; }
    if (!$it) return 0;
    $cat = (string)$it['category'];
    return (isset(SIGHTS5_DISC_SCOPES[$cat]) ? trail_sight_disc_pct($uid, 'shop:' . $cat) : 0) + trail_sight_disc_pct($uid, 'shop:' . (string)$it['slug']);   // sixth pass A: a discount scoped to one item slug (disc=shop:50:120:rope)
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
        else foreach (explode('+', substr($spec, 4)) as $wd) if (($wl = sights6a_word_list($wd)) !== null && $db) foreach ($wl as $ws) if (!trail_sight_item_known($ws)) $bad[] = 'word list "' . $wd . '": no item "' . $ws . '"';   // sixth pass A
    }
    if ($k === 'disc') {
        $p = explode(':', $v);
        if (isset($p[3]) && ($p[0] !== 'shop' || !(isset(SIGHTS5_DISC_SCOPES[$p[3]]) || ($p[3] !== '' && preg_match('/^[a-z][a-z0-9-]*$/', $p[3]) && (!$db || trail_sight_item_known($p[3])))))) $bad[] = 'disc= scope (a fourth part) works on shop only, with one of ' . implode(', ', array_keys(SIGHTS5_DISC_SCOPES)) . ' or an item slug';   // sixth pass A: an item slug
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

/**
 * Sights items that needed engine work (fifth pass; claude/sights/items-todo.md; test tests/sights_items.php). No schema change, no new table.
 *  1. fern-drip-hat-charm KEEPS RAIN OFF. Rain does two things to a gnome on the road and Trail: a "weather" road card can cost health when a roll is lost
 *     (explore_choose), and a Sight row can make a lost check cost time or a check harder in rain (`lose:time=15?we=rain;storm`, `sense:11?we=rain:14`). While the charm
 *     is in the satchel ("held") both are negated: the weather a penalty sees is cloud, not rain / storm, and a rain card's lost roll costs no health. A reward that
 *     LIKES rain (`item=fiddleheads@30?we=rain`) still sees the rain: the charm keeps you dry, it does not stop the weather.
 *  2. map-scrap: a button on the Trail (trail_mapscrap) uses one scrap to MARK one find of this stretch that is not yet taken: it is drawn with a pin, and in fog it
 *     shows although you are not next to it. Walk state st.marked = ["<stretch>:<x>,<y>", ...].
 *  3. star-chart: the Satchel button "File in your Almanac" opens the Almanac page of the CURRENT season (4 pages, data/trail_sight_pages_items.txt, key star-chart-<season>)
 *     and uses the chart up; a season you already have is refused and the chart stays.
 *  4. stargazers-chalk: a Trail button beside the star-chart stones, at night: chalk your mark on the stones. Private tally `chalk-marks` (N marks), a little lore XP.
 *     Other players' marks stay P4 (they need a shared table and moderation).
 *  5. message-bottle: the Satchel button "Open the bottle" reads a note from the bottle post (data/trail_sight_bottles*.txt, the `bottle=1` machinery of the third pass).
 *     Notes from other players stay P4.
 *  6. condition `hv=<item slug>:N` = the gnome holds at least N of the item: with `take=` it makes an OPTIONAL swap (a row pays maple syrup only to a gnome with 3 sap,
 *     and takes the 3 sap only then).
 * Everything here is new functions; trail_sights.php, trail_sight_extras.php, trail_sights_4.php, trail_tiles.php, shelves.php, inventory.php, explore.php and adventure.php only call them.
 */

const SIGHTS5_CHARM = 'fern-drip-hat-charm';
const SIGHTS5_SCRAP = 'map-scrap';
const SIGHTS5_CHART = 'star-chart';
const SIGHTS5_CHALK = 'stargazers-chalk';
const SIGHTS5_BOTTLE = 'message-bottle';
const SIGHTS5_STONES = 'tundra-the-star-chart-stones';
const SIGHTS5_SEASONS = ['spring', 'summer', 'autumn', 'winter'];

/** How many of an item the gnome holds (by slug). */
function sights5_have(int $uid, string $slug): int
{
    try { return (int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = ?', [$uid, $slug]); } catch (Throwable $e) { return 0; }
}

// ---------------------------------------------------------------- 1. rain

/** Is this gnome keeping the rain off (the Fern-Drip Hat Charm is in the satchel)? */
function sights5_dry(int $uid): bool
{
    return $uid > 0 && sights5_have($uid, SIGHTS5_CHARM) > 0;
}

/** The conditions a PENALTY or a harder check is judged by: a dry gnome sees rain and storm as plain cloud. $now['dry'] is set by trail_sight_now(). */
function sights5_dry_now(array $now): array
{
    if (!empty($now['dry']) && in_array((string)($now['we'] ?? ''), ['rain', 'storm'], true)) $now['we'] = 'cloud';
    return $now;
}

/**
 * A lost roll on a weather road card for rain / storm: the health it costs is not paid by a dry gnome. $ev = the card (road_event_get), $fx = the lost effect.
 * Returns [effect, note]; note is '' when nothing changed.
 */
function sights5_road_rain(array $ev, string $fx, int $uid): array
{
    if (($ev['kind'] ?? '') !== 'weather' || !preg_match('/we=[a-z,]*\b(rain|storm)\b/', (string)($ev['cond'] ?? '')) || !sights5_dry($uid)) return [$fx, ''];
    $parts = array_values(array_filter(explode('+', $fx), fn($p) => !preg_match('/^hp:-/', $p)));
    $new = implode('+', $parts);
    return $new === $fx ? [$fx, ''] : [$new, '🌿 your hat charm keeps the drops off'];
}

// ---------------------------------------------------------------- 6. hv= (the gnome holds N of an item)

/** Condition `hv=<slug>:N`. $now['uid'] is set by trail_sight_now(); without it (a lint, a test of a bare $now) it is false. */
function sights5_cond_hv(string $v, array $now): bool
{
    [$slug, $n] = array_pad(explode(':', $v, 2), 2, '1');
    $uid = (int)($now['uid'] ?? 0);
    if ($uid > 0 && preg_match(SIGHTS5_ANY_RE, $slug)) return sights5_any_have($uid, substr($slug, 4))[1] >= max(1, (int)$n);   // sixth pass A: hv=any-bread:1
    return $uid > 0 && preg_match('/^[a-z0-9-]+$/', $slug) && sights5_have($uid, $slug) >= max(1, (int)$n);
}

// ---------------------------------------------------------------- 2. map-scrap

/** The finds of this stretch the gnome marked: ["<stretch>:<x>,<y>", ...]. */
function sights5_marked(array $st): array
{
    return array_values(array_filter((array)($st['marked'] ?? []), 'is_string'));
}

function sights5_is_marked(array $st, int $x, int $y): bool
{
    return in_array((int)($st['sec'] ?? 0) . ':' . $x . ',' . $y, sights5_marked($st), true);
}

/** Token indexes of finds ('F') on this stretch that are not taken and not marked yet. */
function sights5_mark_candidates(array $sc): array
{
    $out = [];
    foreach ((array)($sc['st']['tokens'] ?? []) as $i => $t) {
        if (($t[2] ?? '') !== 'F' || (int)($t[3] ?? 1) !== 0 || sights5_is_marked($sc['st'], (int)$t[0], (int)$t[1])) continue;
        if ((int)$t[0] === (int)$sc['x'] && (int)$t[1] === (int)$sc['y']) continue;
        $out[] = $i;
    }
    return $out;
}

/** Use one Map Scrap: mark the nearest find of this stretch that is not taken yet. [ok, message] */
function sights5_mapscrap_use(array $u, array &$exp): array
{
    $uid = (int)$u['id'];
    $sc = function_exists('trail_scene') ? trail_scene($exp) : null;
    if (!$sc) return [false, 'You need to be on a Trail to read a map scrap.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    if (($sc['st']['phase'] ?? '') !== 'section') return [false, 'Wait until you are in a stretch of the Trail.'];
    if (sights5_have($uid, SIGHTS5_SCRAP) < 1) return [false, 'You have no map scrap.'];
    $cand = sights5_mark_candidates($sc);
    if (!$cand) return [false, 'Nothing left to mark on this stretch: every find is taken or marked already. The scrap stays in your satchel.'];
    usort($cand, fn($a, $b) => (abs($sc['st']['tokens'][$a][0] - $sc['x']) + abs($sc['st']['tokens'][$a][1] - $sc['y'])) <=> (abs($sc['st']['tokens'][$b][0] - $sc['x']) + abs($sc['st']['tokens'][$b][1] - $sc['y'])));
    $t = $sc['st']['tokens'][$cand[0]];
    if (!give_item($uid, (int)item_id_by_slug(SIGHTS5_SCRAP), -1)) return [false, 'You have no map scrap.'];
    $sc['st']['marked'] = array_merge(sights5_marked($sc['st']), [(int)$sc['st']['sec'] . ':' . (int)$t[0] . ',' . (int)$t[1]]);
    if (!trail_save($sc)) return [false, 'The scrap would not unfold.'];
    $msg = '📍 The x on the map scrap is a find on this stretch. You pin it on your map.';
    exp_log($exp, $msg);
    return [true, $msg];
}

// ---------------------------------------------------------------- 4. stargazers-chalk

function sights5_near(array $sc, string $slug): bool
{
    if (!function_exists('trail_sights_near') || ($sc['st']['phase'] ?? '') !== 'section') return false;
    return (bool)array_filter(trail_sights_near($sc['map']['art'] ?? null, (int)$sc['x'], (int)$sc['y']), fn($n) => $n[0] === $slug);
}

/** Chalk a mark on the star-chart stones (at night, next to them). [ok, message] */
function sights5_chalk_use(array $u, array &$exp): array
{
    $uid = (int)$u['id'];
    $sc = function_exists('trail_scene') ? trail_scene($exp) : null;
    if (!$sc || !sights5_near($sc, SIGHTS5_STONES)) return [false, 'You need to be next to the star-chart stones.'];
    if ($exp['encounter']) return [false, 'Deal with what is in front of you first.'];
    $dpf = setting('stop_daypart_force'); $dp = isset(HOLLOW_DAYPARTS[$dpf]) ? $dpf : hollow_daypart();   // the same forced time of day the Sights conditions use
    if ($dp !== 'night') return [false, 'You mark the stone where you saw a nice star, so wait for night to find one.'];
    if (!give_item($uid, (int)item_id_by_slug(SIGHTS5_CHALK), -1)) return [false, 'You have no chalk.'];
    require_once __DIR__ . '/trail_sights.php';
    $n = trail_sight_tally_add($uid, 'chalk-marks');
    add_xp($uid, 4);
    $msg = '🖍️ You chalk a small star beside the one you liked best. Your mark number ' . $n . ' on these stones (+4 XP).' . sights6_chalk_after($u, SIGHTS5_STONES);   // sixth pass B: the shared count and the words
    exp_log($exp, $msg);
    return [true, $msg];
}

/** The Trail buttons for these items, drawn in the foot under the map ('' = none). */
function sights5_trailfoot_html(array $u, array $exp, ?array $sc): string
{
    if (!$sc || !empty($exp['encounter'])) return '';
    $uid = (int)$u['id']; $h = '';
    $scrap = sights5_have($uid, SIGHTS5_SCRAP);
    if ($scrap > 0 && sights5_mark_candidates($sc) && ($sc['st']['phase'] ?? '') === 'section')
        $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_mapscrap"><button class="btn alt trailscrap">📍 Map scrap <small>×' . $scrap . '</small></button></form>';
    $chalk = sights5_have($uid, SIGHTS5_CHALK);
    if ($chalk > 0 && sights5_near($sc, SIGHTS5_STONES))
        $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_chalk">' . sights6_chalk_input() . '<button class="btn alt trailchalk">🖍️ Chalk a mark <small>×' . $chalk . '</small></button></form>';
    return $h . sights6_trailfoot_html($u, $sc);   // sixth pass B: the cairn count, other gnomes' chalk words
}

/** adventure.php: the Trail posts of these items. [ok, message] */
function sights5_trail_do(string $do, array $u, array &$exp): array
{
    return $do === 'trail_chalk' ? sights5_chalk_use($u, $exp) : sights5_mapscrap_use($u, $exp);
}

// ---------------------------------------------------------------- 3. star-chart, 5. message-bottle (the Satchel)

const SIGHTS5_USES = [SIGHTS5_CHART => '📖 File in your Almanac', SIGHTS5_BOTTLE => '🍾 Open the bottle'];

/** Satchel buttons (shelves.php) for an item row $i: a list of form html. */
function sights5_satchel_acts(array $i, string $hid): array
{
    $slug = (string)($i['slug'] ?? '');
    if (!isset(SIGHTS5_USES[$slug])) return [];
    return [sh_bag_form('sight_item', (int)$i['id'], SIGHTS5_USES[$slug], $hid)];
}

/** inventory.php do=sight_item. [ok, message] */
function sights5_use_item(array $u, int $itemId): array
{
    $uid = (int)$u['id'];
    $slug = (string)q_val('SELECT slug FROM items WHERE id = ?', [$itemId]);
    if (!isset(SIGHTS5_USES[$slug])) return [false, 'There is nothing to do with that here.'];
    if (sights5_have($uid, $slug) < 1) return [false, 'You do not have that.'];
    return $slug === SIGHTS5_CHART ? sights5_chart_file($u, $itemId) : sights5_bottle_open($u, $itemId);
}

/** The current season's key, spring..winter. */
function sights5_season(): string
{
    $s = hollow_season();
    return in_array($s, SIGHTS5_SEASONS, true) ? $s : 'spring';
}

function sights5_chart_file(array $u, int $itemId): array
{
    $uid = (int)$u['id']; $season = sights5_season();
    require_once __DIR__ . '/trail_sights.php';
    trail_sights_ensure_pages();   // the four pages (data/trail_sight_pages_items.txt) exist before they are opened
    $eid = (int)q_val('SELECT id FROM encyclopedia_entries WHERE unlock_key = ?', ['sightpage:' . SIGHTS5_CHART . '-' . $season]);
    if (!$eid) return [false, 'The Almanac has no page for this sky yet.'];
    if (q_val('SELECT 1 FROM user_encyclopedia WHERE user_id = ? AND entry_id = ?', [$uid, $eid])) return [false, 'You already have the ' . $season . ' sky in your Almanac. Keep the chart for another season.'];
    if (!give_item($uid, $itemId, -1)) return [false, 'You do not have that.'];
    unlock_entries($uid, 'sightpage:' . SIGHTS5_CHART . '-' . $season);
    return [true, '📖 You copy your wobbly star chart into the Almanac: a new page, the ' . $season . ' sky.'];
}

function sights5_bottle_open(array $u, int $itemId): array
{
    $uid = (int)$u['id'];
    require_once __DIR__ . '/trail_sights.php';
    if (($s6 = sights6_bottle_open($u, $itemId)) !== null) return $s6;   // sixth pass B: a stranger's note, when one is waiting
    if (!trail_sight_bottles()) return [false, 'The cork will not come out.'];
    $loc = (q_one('SELECT * FROM locations WHERE id = ?', [(int)($u['location_id'] ?? 0)]) ?: []); $loc['landscape'] = 'coast'; $loc['name'] = 'the bottle';
    $now = trail_sight_now($loc, null, $u);
    if (!give_item($uid, $itemId, -1)) return [false, 'You do not have that.'];
    $lines = trail_sight_b_pay($u, $loc, 'bottle=1', $now);
    if (!$lines) { give_item($uid, $itemId, 1); return [false, 'The bottle is empty after all. It goes back in your satchel.']; }
    return [true, str_replace('A bottle washes up.', 'You pull the cork.', implode(' ', array_map('strval', $lines)))];
}

// ---------------------------------------------------------------- sixth pass A (claude/sights/GRAMMAR.md "Sixth pass A"; test tests/trail_sights_284.sh)

const SIGHTS6A_VCHOOSE_KINDS = ['c', 'xp', 'en', 'item', 'seed', 'crop', 'fish', 'find', 'buff', 'fp', 'take', 'disc'];   // the tokens a villager's choice option may hold

/**
 * Word lists for `any-<word>` (data/trail_sight_words.txt: `word|slug,slug,...`): the words that are no item category and no plant kind (bread slugs have no common
 * ending: cornbread, herb-flatbread; teas are listed by slug). Used by take=any-bread, give=any-tea, hv=any-bread:1. Null when $word is not a list.
 */
function sights6a_word_list(string $word): ?array
{
    static $c = [];
    $files = trail_sight_data_files('words'); $key = implode(',', $files) . '|' . implode(',', array_map(fn($f) => is_file($f) ? filemtime($f) : 0, $files));
    if (!isset($c[$key])) {
        $c[$key] = [];
        foreach (trail_sight_data_lines('words') as $l) { [$w, $sl] = array_pad(array_map('trim', explode('|', $l, 2)), 2, ''); if (preg_match('/^[a-z]+$/', $w)) $c[$key][$w] = array_values(array_filter(array_map('trim', explode(',', $sl)))); }
    }
    return $c[$key][$word] ?? null;
}

/** A villager row's choice: `choose=Label~tok+tok;Label~tok+tok` (2 to 4 options) as [[label, [tokens]], ...], or null when the rewards hold none. */
function sights6a_vchoose(string $rewards): ?array
{
    foreach (trail_sight_tokens($rewards) as $t) if (str_starts_with($t['tok'], 'choose=') && str_contains($t['tok'], '~')) {
        $out = [];
        foreach (array_filter(array_map('trim', explode(';', substr($t['tok'], 7)))) as $o) { [$lb, $tk] = array_pad(explode('~', $o, 2), 2, ''); $out[] = [trim($lb), array_values(array_filter(array_map('trim', explode('+', $tk))))]; }
        return $out ?: null;
    }
    return null;
}

/** Problems with a villager choice (`Label~tok+tok;...`). $db false = do not look items up. */
function sights6a_lint_vchoose(string $v, bool $db = true): array
{
    $bad = []; $opts = array_values(array_filter(array_map('trim', explode(';', $v))));
    if (count($opts) < 2 || count($opts) > 4) $bad[] = 'a villager choose= needs 2 to 4 options joined by ;';
    foreach ($opts as $o) {
        if (!str_contains($o, '~')) { $bad[] = 'a villager choose= option needs Label~reward+reward ("' . $o . '")'; continue; }
        [$lb, $tk] = explode('~', $o, 2);
        if (trim($lb) === '' || mb_strlen(trim($lb)) > 40) $bad[] = 'a villager choose= label needs 1 to 40 characters';
        $toks = array_values(array_filter(array_map('trim', explode('+', $tk))));
        if (!$toks) $bad[] = 'a villager choose= option "' . $lb . '" has no reward';
        foreach ($toks as $tok) {
            [$k, $val] = array_pad(explode('=', $tok, 2), 2, '');
            if (!in_array($k, SIGHTS6A_VCHOOSE_KINDS, true)) { $bad[] = 'a villager choose= option "' . $lb . '" may not hold ' . $k . '='; continue; }
            if (($k === 'item' || $k === 'take') && $db && !preg_match(SIGHTS5_ANY_RE, explode(':', $val)[0]) && !trail_sight_item_known(explode(':', $val)[0])) $bad[] = 'a villager choose= item "' . explode(':', $val)[0] . '" does not exist';
        }
    }
    return $bad;
}

/**
 * A villager row with a choice (`choose=Let them sleep~buff=luck:1:60+fp=1;Wake them~take=cornbread:1+fp=2`): the Sights card shows one button per option; the line column
 * is `prompt // result 1 // result 2 ...` (one result per option, said in the journal). A `take=` in an option is used up (and checked first). Once per game day, like give=.
 * Called from trail_sight_give(): [ok, message].
 */
function sights6a_folk_choose(array $u, array &$exp, array $loc, array $now, array $f, string $slug, int $idx, int $reward): array
{
    $opts = sights6a_vchoose((string)$f['rewards']);
    if (!$opts) return [false, 'They do not need anything.'];
    if ($reward < 0 || $reward >= count($opts)) return [false, 'Choose one.'];
    $uid = (int)$u['id'];
    $gkey = 'give~' . substr(md5($slug . '|' . $idx), 0, 16); $dayNo = (int)floor(strtotime(gclock_my_date() . ' UTC') / 86400);
    if ((int)(trail_sight_tallies($uid)[$gkey] ?? 0) === $dayNo) return [false, trail_sight_split_who($f['who'])[0] . ' has had what they need from you today.'];
    $takes = []; $pay = [];
    foreach ($opts[$reward][1] as $tok) {
        if (!str_starts_with($tok, 'take=')) { $pay[] = $tok; continue; }
        [$ts, $tq] = array_pad(explode(':', substr($tok, 5), 2), 2, '1'); $tq = max(1, (int)$tq);
        if (preg_match(SIGHTS5_ANY_RE, $ts)) { if (sights5_any_have($uid, substr($ts, 4))[1] < $tq) return [false, 'You need ' . $tq . ' × ' . sights5_any_label(substr($ts, 4)) . ' for that.']; $takes[] = [$ts, $tq, 0]; continue; }
        $tid = (int)q_val('SELECT id FROM items WHERE slug = ?', [$ts]);
        if (!$tid || (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $tid]) < $tq) return [false, 'You need ' . $tq . ' × ' . ($tid ? (string)q_val('SELECT name FROM items WHERE id = ?', [$tid]) : $ts) . ' for that.'];
        $takes[] = [$ts, $tq, $tid];
    }
    foreach ($takes as [$ts, $tq, $tid]) if (!($tid ? give_item($uid, $tid, -$tq) : sights5_any_use($uid, substr($ts, 4), $tq))) return [false, 'You need ' . $tq . ' × ' . ($tid ? (string)q_val('SELECT name FROM items WHERE id = ?', [$tid]) : sights5_any_label(substr($ts, 4))) . ' for that.'];
    try { if (q('UPDATE trail_sight_tally SET n = ? WHERE user_id = ? AND tkey = ?', [$dayNo, $uid, $gkey])->rowCount() < 1) db_insert('trail_sight_tally', ['user_id' => $uid, 'tkey' => $gkey, 'n' => $dayNo]); } catch (Throwable $e) { /* a double click */ }
    gclock_charge($uid, 'sight');
    $lines = $pay ? trail_sight_pay($u, $loc, implode(',', $pay), $f['who'], $now) : [];
    $said = array_map('trim', explode(' // ', (string)$f['miss']))[$reward] ?? '';
    $tl = array_map(fn($t) => '🎁 used ' . $t[1] . ' × ' . ($t[2] ? (string)q_val('SELECT name FROM items WHERE id = ?', [$t[2]]) : sights5_any_label(substr($t[0], 4))), $takes);
    exp_log($exp, '💬 ' . ($said !== '' ? $said : trail_sight_split_who($f['who'])[0] . ': ' . $opts[$reward][0] . '.') . (($lines || $tl) ? ' (' . implode(', ', array_merge($tl, array_filter($lines))) . ')' : ''));
    return [true, ''];
}

/** The Sights card buttons for a villager row with a choice: '' when the row has none. $near = the gnome stands by the Sight. */
function sights6a_folk_choose_html(array $u, string $slug, array $f, bool $near): string
{
    $opts = sights6a_vchoose((string)$f['rewards']);
    if (!$opts) return '';
    if (!$near) return ' <small class="muted">Walk there to answer.</small>';
    $h = '<form method="post" class="inline sgpick">' . csrf_field() . '<input type="hidden" name="do" value="sightgive"><input type="hidden" name="slug" value="' . e($slug) . '"><input type="hidden" name="idx" value="' . (int)$f['idx'] . '">';
    foreach ($opts as $i => [$lb, $toks]) {
        $dis = '';
        foreach ($toks as $tok) if (str_starts_with($tok, 'take=')) { [$ts, $tq] = array_pad(explode(':', substr($tok, 5), 2), 2, '1'); $have = preg_match(SIGHTS5_ANY_RE, $ts) ? sights5_any_have((int)$u['id'], substr($ts, 4))[1] : sights5_have((int)$u['id'], $ts); if ($have < max(1, (int)$tq)) $dis = ' disabled'; }
        $h .= ' <button class="btn small" name="reward" value="' . $i . '"' . $dis . '>' . e($lb) . '</button>';
    }
    return ' ' . $h . '</form>';
}

/** Put rope on the shelf of Twigg's (the supplies shop reachable from anywhere) so a rope discount has a shop to apply in. Adds only what is missing; boot step rope_stock_ensure. */
function sights6a_rope_stock_ensure(): int
{
    require_once __DIR__ . '/rebuild.php';
    ensure_building_items();
    $rope = q_one("SELECT id, base_price FROM items WHERE slug = 'rope'"); $shop = (int)q_val("SELECT id FROM shops WHERE slug = 'twigg-s-seed-emporium'");
    if (!$rope || !$shop || q_val('SELECT 1 FROM shop_stock WHERE shop_id = ? AND item_id = ?', [$shop, (int)$rope['id']])) return 0;
    $p = max(1, (int)$rope['base_price']);
    db_insert('shop_stock', ['shop_id' => $shop, 'item_id' => (int)$rope['id'], 'price_min' => $p * 4, 'price_max' => $p * 5, 'max_stock' => 4, 'restock_chance' => 40, 'current_stock' => 2, 'current_price' => $p * 4]);
    return 1;
}

/** Every word list: [word => [slugs]] (for the lint). */
function sights6a_word_list_all(): array
{
    $o = [];
    foreach (trail_sight_data_lines('words') as $l) { [$w, $sl] = array_pad(array_map('trim', explode('|', $l, 2)), 2, ''); if (preg_match('/^[a-z]+$/', $w)) $o[$w] = array_values(array_filter(array_map('trim', explode(',', $sl)))); }
    return $o;
}

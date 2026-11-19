<?php
declare(strict_types=1);

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
    $msg = '🖍️ You chalk a small star beside the one you liked best. Your mark number ' . $n . ' on these stones (+4 XP).';
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
        $h .= '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="trail_chalk"><button class="btn alt trailchalk">🖍️ Chalk a mark <small>×' . $chalk . '</small></button></form>';
    return $h;
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
    if (!trail_sight_bottles()) return [false, 'The cork will not come out.'];
    $loc = (q_one('SELECT * FROM locations WHERE id = ?', [(int)($u['location_id'] ?? 0)]) ?: []); $loc['landscape'] = 'coast'; $loc['name'] = 'the bottle';
    $now = trail_sight_now($loc, null, $u);
    if (!give_item($uid, $itemId, -1)) return [false, 'You do not have that.'];
    $lines = trail_sight_b_pay($u, $loc, 'bottle=1', $now);
    if (!$lines) { give_item($uid, $itemId, 1); return [false, 'The bottle is empty after all. It goes back in your satchel.']; }
    return [true, str_replace('A bottle washes up.', 'You pull the cork.', implode(' ', array_map('strval', $lines)))];
}

<?php
declare(strict_types=1);
/**
 * 2.8.85: Expedition Standing and the area Seals (claude/PROPOSAL-HOLLOW-MASTER.md sections 2.2 and 4). Behind the setting
 * `seals_open` (default 0): while it is 0 nothing here gates anything and no Seal is awarded (region_gate_open() is always true).
 *
 * Standing: 0-100 per gnome and area, from the rows of STANDING_ROWS. Every row is a high-water mark (region_standing_best):
 * a stop that loses a tier, a released adoption, anything that goes down, never lowers a row once reached.
 * At `seal_threshold` (default 80) the gnome earns that area's Seal (region_seals), once, for good.
 *
 * Gates: a region of tier 3 or above opens when the gnome holds the Seal(s) GATE_NEEDS names for it, or is grandfathered
 * (home region, a garden there, walked there before, standing there now). Walking between two regions of the same tier, or down a tier,
 * is never gated; nor is any region of tier 1 or 2, nor a guest. A closed gate can never trap a gnome: the way back is always open.
 */

/** Tier (band) of each area, master doc 2.1. */
const REGION_TIERS = ['NA' => 1, 'CA' => 2, 'NWE' => 2, 'CB' => 3, 'SA' => 3, 'SE' => 3, 'EE' => 3,
    'MENA' => 4, 'CSA' => 4, 'WCA' => 4, 'ESA' => 4, 'EA' => 5, 'SEA' => 5, 'OC' => 5];

/**
 * Seals needed to walk INTO a region from a lower tier (master doc 2.2). Each entry is a list of alternatives; an alternative is a list
 * of area codes whose Seals are ALL needed. Tier 3: both tier 2 Seals. Tier 4: the Seal of the tier 3 area the road leaves
 * (SE-MENA, EE-CSA, and the two new roads CB-WCA, SA-ESA). Tier 5: Spicepeak (CSA-EA, CSA-SEA); SA-OC needs any one tier 4 Seal.
 */
const GATE_NEEDS = [
    'CB' => [['CA', 'NWE']], 'SA' => [['CA', 'NWE']], 'SE' => [['CA', 'NWE']], 'EE' => [['CA', 'NWE']],
    'MENA' => [['SE']], 'CSA' => [['EE']], 'WCA' => [['CB']], 'ESA' => [['SA']],
    'EA' => [['CSA']], 'SEA' => [['CSA']], 'OC' => [['MENA'], ['CSA'], ['WCA'], ['ESA']],
];
/** Roads with their own door, 'FROM>TO' => alternatives as GATE_NEEDS: Clovercove (NA-EA) needs all 14 Seals (the final chapter). */
const GATE_ROAD_NEEDS = ['NA>EA' => [['NA', 'CA', 'NWE', 'CB', 'SA', 'SE', 'EE', 'MENA', 'CSA', 'WCA', 'ESA', 'EA', 'SEA', 'OC']]];

/** The Standing table (master doc section 4): key => [label, max points]. Sums to 100. */
const STANDING_ROWS = [
    'lit' => ['Stops: lit', 14], 'raised' => ['Stops: raised', 10], 'hearth' => ['Stops: Hearth', 6],
    'repair' => ['Wren’s Repair', 15], 'places' => ['Places found', 10],
    'friend' => ['Folk: a Friend', 5], 'threads' => ['Folk: stop threads', 5], 'errands' => ['Folk: errands', 5],
    'grown' => ['Garden: grown', 5], 'seedbed' => ['Garden: Seed Bed', 6], 'flower' => ['Garden: in flower', 4],
    'delve' => ['Delve cleared', 5], 'lair' => ['Lair', 5], 'pages' => ['Almanac pages', 5],
];
/** TODO (data source not built yet): rows that score 0 until their system ships. Seed Bed = data/seed_beds.txt (build plan 8).
 *  Errands count the rest stop villagers' errands done in the area today (stop_errands); TODO: add data/journey_errands.txt errands when build plan 10 ships. */
const STANDING_TODO_ROWS = ['seedbed'];
/** TODO (build plan 5): N counts the villages that can be adopted today (road villages). When off-road adoption ships, N becomes every village of the area (Maplewold 12). */
const STANDING_N_ROAD_ONLY = true;
/** Almanac pages: full at this share of the area's place and crop pages (there are 30+, rare crops among them). TODO: folk pages once the Folk chapter has per-area pages. */
const STANDING_PAGES_FULL = 0.6;

function seals_on(): bool
{
    return setting('seals_open') === '1';
}

function seal_threshold(): int
{
    $t = (int)setting('seal_threshold');
    return $t > 0 ? min(100, $t) : 80;
}

function region_tier_of(string $code): int
{
    return REGION_TIERS[strtoupper($code)] ?? 1;
}

/** @return array<int,array> region rows by id (cached for the request) */
function seal_regions(): array
{
    static $all = null;
    if ($all === null) { $all = []; foreach (q('SELECT * FROM regions')->fetchAll() as $r) $all[(int)$r['id']] = $r; }
    return $all;
}

function seal_region_code(int $rid): string
{
    return (string)(seal_regions()[$rid]['code'] ?? '');
}

function seal_region_id(string $code): int
{
    foreach (seal_regions() as $id => $r) if ($r['code'] === $code) return $id;
    return 0;
}

/** "Maizehollow", "Sunsprinkle Isles" (no leading "The"). */
function seal_area_name(int $rid): string
{
    return (string)preg_replace('/^The\s+/', '', (string)(seal_regions()[$rid]['gnomish_name'] ?? '?'));
}

/** @return string[] codes of the Seals this gnome holds */
function seals_held(int $uid): array
{
    $out = [];
    foreach (q('SELECT region_id FROM region_seals WHERE user_id = ?', [$uid])->fetchAll(PDO::FETCH_COLUMN) as $rid) $out[] = seal_region_code((int)$rid);
    return array_values(array_filter($out));
}

function seal_held(int $uid, int $rid): bool
{
    return (bool)q_val('SELECT 1 FROM region_seals WHERE user_id = ? AND region_id = ?', [$uid, $rid]);
}

function seal_is_guest(int $uid): bool
{
    return (int)q_val('SELECT guest FROM users WHERE id = ?', [$uid]) === 1;
}

/** Grandfathering: home region, a garden there, walked there before, or standing there now. Never lock a gnome out of these. */
function seal_grandfathered(int $uid, int $rid): bool
{
    $u = q_one('SELECT region_id, location_id FROM users WHERE id = ?', [$uid]) ?: [];
    if ((int)($u['region_id'] ?? 0) === $rid) return true;
    if (!empty($u['location_id']) && (int)q_val('SELECT region_id FROM locations WHERE id = ?', [(int)$u['location_id']]) === $rid) return true;
    if (q_val('SELECT 1 FROM plots WHERE user_id = ? AND region_id = ?', [$uid, $rid])) return true;
    return (bool)q_val('SELECT 1 FROM region_visits WHERE user_id = ? AND region_id = ?', [$uid, $rid]);
}

/** Is one alternative list (GATE_NEEDS shape) met by these held codes? */
function seal_needs_met(array $alts, array $held): bool
{
    foreach ($alts as $need) if (!array_diff($need, $held)) return true;
    return false;
}

/** Same-tier neighbour by road that this gnome has reached (the "open once in tier N" rule). */
function seal_sibling_reached(int $uid, string $code): bool
{
    require_once __DIR__ . '/roads.php';
    $tier = region_tier_of($code);
    $been = array_flip(array_map('seal_region_code', visited_regions($uid)));
    foreach (ROAD_PAIRS as [$a, $b]) {
        $other = $a === $code ? $b : ($b === $code ? $a : '');
        if ($other !== '' && region_tier_of($other) === $tier && isset($been[$other]) && !in_array([$a, $b], ROAD_DEAD_ENDS, true)) return true;
    }
    return false;
}

/** The real gate (progression.php's region_gate_open() calls this). */
function seal_region_gate_open(int $uid, int $rid): bool
{
    if (!seals_on() || $uid < 1 || $rid < 1) return true;
    $code = seal_region_code($rid);
    if ($code === '' || region_tier_of($code) <= 2) return true;
    if (seal_is_guest($uid) || seal_grandfathered($uid, $rid)) return true;
    $held = seals_held($uid);
    if (seal_needs_met(GATE_NEEDS[$code] ?? [], $held)) return true;
    return seal_sibling_reached($uid, $code);
}

/** The door on one road crossing: walking from region $from into region $to. True = open. */
function road_gate_open(int $uid, int $from, int $to): bool
{
    if (!seals_on() || $uid < 1 || $from < 1 || $to < 1 || $from === $to) return true;
    $fc = seal_region_code($from); $tc = seal_region_code($to);
    if ($fc === '' || $tc === '' || region_tier_of($tc) <= 2) return true;
    if (seal_is_guest($uid) || seal_grandfathered($uid, $to)) return true;
    $alts = seal_road_needs($fc, $tc);
    if ($alts === []) return true;   // same tier or down a tier: always open (the way back never closes)
    foreach (array_unique(array_merge(...$alts)) as $c) if (($rid = seal_region_id($c))) region_seal_check($uid, $rid);   // earned on the way: award it now
    return seal_needs_met($alts, seals_held($uid));
}

/** What a crossing needs: [] = nothing. */
function seal_road_needs(string $fc, string $tc): array
{
    if (isset(GATE_ROAD_NEEDS[$fc . '>' . $tc])) return GATE_ROAD_NEEDS[$fc . '>' . $tc];
    if (region_tier_of($fc) >= region_tier_of($tc)) return [];
    return GATE_NEEDS[$tc] ?? [];
}

/** The Warden's words at a closed door: what it needs and what Standing is missing. '' when the door is open. */
function seal_warden_message(int $uid, int $from, int $to): string
{
    if (road_gate_open($uid, $from, $to)) return '';
    return seal_warden_text($uid, seal_road_needs(seal_region_code($from), seal_region_code($to)), region_tier_of(seal_region_code($to)));
}

/** The Warden's words for a region as a whole (fast travel): '' when region_gate_open(). */
function seal_region_warden_message(int $uid, int $rid): string
{
    if (seal_region_gate_open($uid, $rid)) return '';
    $code = seal_region_code($rid);
    return seal_warden_text($uid, GATE_NEEDS[$code] ?? [], region_tier_of($code));
}

/** "Tier 3 door: needs the Maizehollow and Mistmoor Seals. Maizehollow 62%: Places found 4/10, ..." */
function seal_warden_text(int $uid, array $alts, int $tier): string
{
    if (!$alts) return '';
    $held = seals_held($uid);
    $names = fn(array $codes) => implode(' and ', array_map(fn($c) => seal_area_name(seal_region_id($c)), $codes));
    if (count($alts) === 1) {
        $need = $alts[0];
        $head = 'Tier ' . $tier . ' door: needs ' . (count($need) > 3 ? 'all ' . count($need) . ' area Seals' : 'the ' . $names($need) . ' Seal' . (count($need) === 1 ? '' : 's')) . '.';
        $missing = array_values(array_diff($need, $held));
    } else {
        $head = 'Tier ' . $tier . ' door: needs one Seal of: ' . implode(', ', array_map(fn($a) => $names($a), $alts)) . '.';
        $best = null;   // the nearest alternative by Standing
        foreach ($alts as $a) { $p = 0; foreach (array_diff($a, $held) as $c) $p -= 100 - region_standing($uid, seal_region_id($c))['total']; if ($best === null || $p > $best[0]) $best = [$p, $a]; }
        $missing = array_values(array_diff($best[1], $held));
    }
    $parts = [];
    foreach (array_slice($missing, 0, 3) as $c) {
        $rid = seal_region_id($c);
        $st = region_standing($uid, $rid);
        $gaps = [];
        foreach ($st['rows'] as $k => $r) if ($r['pts'] < $r['max'] && empty($r['todo'])) $gaps[] = $r['label'] . ' ' . rtrim(rtrim(number_format($r['pts'], 1), '0'), '.') . '/' . $r['max'];
        $parts[] = seal_area_name($rid) . ' ' . (int)floor($st['total']) . '%' . ($gaps ? ': ' . implode(', ', array_slice($gaps, 0, 5)) : '');
    }
    if (count($missing) > 3) $parts[] = '+' . (count($missing) - 3) . ' more';
    return '🛡️ The Warden: ' . $head . ($parts ? ' ' . implode('. ', $parts) . '.' : '') . ' (Seal at ' . seal_threshold() . '% Standing.)';
}

// ---------------------------------------------------------------- Standing

/** Live points of every row (not yet high-water). @return array<string,float> */
function region_standing_live(int $uid, int $rid): array
{
    require_once __DIR__ . '/roads.php';
    require_once __DIR__ . '/stop_adopt.php';
    require_once __DIR__ . '/stops.php';   // stop_threads(), stop_fam_level() (stops.php loads stop_living.php)
    require_once __DIR__ . '/friends.php';
    $p = array_fill_keys(array_keys(STANDING_ROWS), 0.0);
    $reg = seal_regions()[$rid] ?? null;
    if (!$reg || $uid < 1) return $p;

    // Stops: N = adoptable villages; L = lit (tier 1+) where this gnome is a Regular; raised = their tier sum / N; Hearth = own best stop
    $villages = q("SELECT * FROM locations WHERE region_id = ? AND kind = 'village'", [$rid])->fetchAll();
    $n = 0; $lit = 0; $tierSum = 0;
    foreach ($villages as $v) {
        if (STANDING_N_ROAD_ONLY && !on_road((int)$v['id'])) continue;
        $n++;
        $t = stop_tier((int)$v['id']);
        if ($t >= 1 && stop_fam_level($uid, (int)$v['id']) !== 'stranger') { $lit++; $tierSum += $t; }
    }
    if ($n > 0) {
        $p['lit'] = 14 * min(1, $lit / max(1, (int)round(0.6 * $n)));
        $p['raised'] = 10 * min(1, $tierSum / $n);
    }
    $best = (int)q_val('SELECT MAX(a.tier) FROM stop_adoptions a JOIN locations l ON l.id = a.location_id WHERE l.region_id = ? AND (a.user_id = ? OR a.founder_id = ?)', [$rid, $uid, $uid]);
    $p['hearth'] = (float)([0 => 0, 1 => 1, 2 => 2, 3 => 4][$best] ?? ($best >= 4 ? 6 : 0));

    // Wren's flagship Repair: the area's chapter stages done (a finished chapter is full)
    $stages = 0; $done = 0;
    foreach (q('SELECT id FROM quest_chapters WHERE region_id = ? AND active = 1', [$rid])->fetchAll(PDO::FETCH_COLUMN) as $chId) {
        $s = (int)q_val("SELECT COUNT(*) FROM quest_tasks WHERE chapter_id = ? AND kind = 'stage'", [$chId]);
        $row = q_one('SELECT stage, done_at FROM user_quests WHERE user_id = ? AND chapter_id = ?', [$uid, $chId]);
        $stages += $s;
        $done += $row ? ($row['done_at'] ? $s : min($s, (int)$row['stage'])) : 0;
    }
    if ($stages > 0) $p['repair'] = 15 * $done / $stages;

    // Places found: every village and off-road place of the area (not the town)
    $places = q("SELECT * FROM locations WHERE region_id = ? AND kind NOT IN ('market', 'hub')", [$rid])->fetchAll();
    $known = 0;
    foreach ($places as $l) if (place_known($uid, $l)) $known++;
    if ($places) $p['places'] = 10 * $known / count($places);

    // Folk: one townsfolk Friend; three stop threads finished at the area's stops; five villagers' errands done at the area's stops
    $friendPts = (int)(FRIEND_LEVELS[2][0] ?? 100);
    if (q_val('SELECT 1 FROM npc_friends f JOIN npcs n ON n.id = f.npc_id JOIN town_spots s ON s.id = n.fav_spot_id WHERE f.user_id = ? AND s.region = ? AND f.points >= ? LIMIT 1',
        [$uid, $reg['gnomish_name'], $friendPts])) $p['friend'] = 5.0;
    $threads = stop_threads();
    $fin = 0;
    foreach (q("SELECT sp.k, sp.n FROM stop_prog sp JOIN locations l ON l.id = sp.location_id WHERE sp.user_id = ? AND l.region_id = ? AND sp.k LIKE 'thread:%'", [$uid, $rid])->fetchAll() as $r) {
        $th = $threads[substr((string)$r['k'], 7)] ?? null;
        if ($th && (int)$r['n'] >= count($th['beats'])) $fin++;
    }
    $p['threads'] = 5 * min(1, $fin / 3);
    $errands = (int)q_val("SELECT COUNT(*) FROM stop_errands e JOIN stop_folk f ON f.id = e.folk_id JOIN locations l ON l.id = f.location_id
                           WHERE e.user_id = ? AND e.status = 'done' AND l.region_id = ?", [$uid, $rid]);
    $p['errands'] = 5 * min(1, $errands / 5);

    // Garden: share of the area's staple and uncommon crops grown; native flowers grown (1 = 2 points, 3 = 4); Seed Bed (TODO)
    $crops = (int)q_val("SELECT COUNT(DISTINCT plant_id) FROM plant_regions WHERE region_id = ? AND tier IN ('staple', 'uncommon')", [$rid]);
    $grown = (int)q_val("SELECT COUNT(DISTINCT pr.plant_id) FROM plant_regions pr JOIN user_plant_knowledge k ON k.plant_id = pr.plant_id AND k.user_id = ? AND k.knowledge > 0
                         WHERE pr.region_id = ? AND pr.tier IN ('staple', 'uncommon')", [$uid, $rid]);
    if ($crops > 0) $p['grown'] = 5 * $grown / $crops;
    $fl = (int)q_val("SELECT COUNT(DISTINCT pr.plant_id) FROM plant_regions pr JOIN user_plant_knowledge k ON k.plant_id = pr.plant_id AND k.user_id = ? AND k.knowledge > 0
                      WHERE pr.region_id = ? AND pr.tier = 'flower'", [$uid, $rid]);
    $p['flower'] = $fl >= 3 ? 4.0 : ($fl >= 1 ? 2.0 : 0.0);

    // Delve cleared; lair beaten or charmed (landmark_clears). TODO: a lair's peaceful act, where it has one
    foreach (['delve', 'lair'] as $kind) {
        if (q_val('SELECT 1 FROM landmark_clears c JOIN landmarks m ON m.id = c.landmark_id WHERE c.user_id = ? AND m.region_id = ? AND m.kind = ? LIMIT 1', [$uid, $rid, $kind])) $p[$kind] = 5.0;
    }

    // Almanac pages: the area's place pages and crop pages unlocked, full at STANDING_PAGES_FULL of them
    $keys = [];
    foreach ($places as $l) $keys[] = ($l['kind'] === 'village' ? 'village:' : 'landmark:') . $l['slug'];
    foreach (q('SELECT DISTINCT p.slug FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id WHERE pr.region_id = ?', [$rid])->fetchAll(PDO::FETCH_COLUMN) as $s) $keys[] = 'plant:' . $s;
    if ($keys) {
        $in = implode(',', array_fill(0, count($keys), '?'));
        $total = (int)q_val("SELECT COUNT(*) FROM encyclopedia_entries WHERE unlock_key IN ($in)", $keys);
        $have = (int)q_val("SELECT COUNT(*) FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE ue.user_id = ? AND e.unlock_key IN ($in)", array_merge([$uid], $keys));
        if ($total > 0) $p['pages'] = 5 * min(1, $have / max(1, (int)ceil(STANDING_PAGES_FULL * $total)));
    }
    foreach (STANDING_TODO_ROWS as $k) $p[$k] = 0.0;
    return $p;
}

/**
 * Expedition Standing of a gnome in one area: each row's points (the best ever reached) and the total.
 * @return array{rows: array<string,array{label:string,max:int,pts:float,live:float,todo:bool}>, total: float, seal: bool}
 */
function region_standing(int $uid, int $rid): array
{
    $live = region_standing_live($uid, $rid);
    $best = [];
    if ($uid > 0) foreach (q('SELECT row_key, pts100 FROM region_standing_best WHERE user_id = ? AND region_id = ?', [$uid, $rid])->fetchAll() as $r) $best[(string)$r['row_key']] = (int)$r['pts100'];
    $rows = [];
    $total = 0.0;
    foreach (STANDING_ROWS as $k => [$label, $max]) {
        $l100 = (int)floor(min($max, max(0.0, $live[$k] ?? 0.0)) * 100 + 0.0001);
        $b100 = $best[$k] ?? 0;
        if ($uid > 0 && $l100 > $b100) {   // a new high-water mark
            if (isset($best[$k])) q('UPDATE region_standing_best SET pts100 = ?, updated_at = ? WHERE user_id = ? AND region_id = ? AND row_key = ? AND pts100 < ?', [$l100, now(), $uid, $rid, $k, $l100]);
            else { try { db_insert('region_standing_best', ['user_id' => $uid, 'region_id' => $rid, 'row_key' => $k, 'pts100' => $l100, 'updated_at' => now()]); } catch (Throwable) {} }
            $b100 = $l100;
        }
        $pts = max($l100, $b100) / 100;
        $rows[$k] = ['label' => $label, 'max' => $max, 'pts' => $pts, 'live' => $l100 / 100, 'todo' => in_array($k, STANDING_TODO_ROWS, true)];
        $total += $pts;
    }
    return ['rows' => $rows, 'total' => round(min(100.0, $total), 1), 'seal' => $uid > 0 && seal_held($uid, $rid)];
}

/**
 * Award the area's Seal once Standing reaches seal_threshold(). Cheap enough to call after any action that may move Standing.
 * Idempotent (UNIQUE user_id, region_id). Returns true only the moment it is awarded. Does nothing while seals_open is 0.
 */
function region_seal_check(int $uid, int $rid): bool
{
    if (!seals_on() || $uid < 1 || $rid < 1 || seal_held($uid, $rid)) return false;
    if (region_standing($uid, $rid)['total'] < seal_threshold()) return false;
    try {
        db_insert('region_seals', ['user_id' => $uid, 'region_id' => $rid, 'earned_at' => now()]);
    } catch (Throwable) {
        return false;   // another request got there first
    }
    $name = seal_area_name($rid);
    require_once __DIR__ . '/trade.php';
    notify($uid, '🔏 The ' . $name . ' Seal is yours! Wren binds the ' . $name . ' section of her Almanac. Doors that wanted it are open now.');
    return true;
}

/** The Almanac line on the area's Region page. */
function seal_almanac_line(int $uid, int $rid): string
{
    if (!seals_on() || $uid < 1) return '';
    $earned = q_val('SELECT earned_at FROM region_seals WHERE user_id = ? AND region_id = ?', [$uid, $rid]);
    if ($earned) return '🔏 ' . e(seal_area_name($rid)) . ' Seal: bound by Wren on ' . e(date('j M Y', ts((string)$earned))) . '.';
    return '🧭 Expedition Standing ' . (int)floor(region_standing($uid, $rid)['total']) . '% (the Seal at ' . seal_threshold() . '%).';
}

/** The "Expedition Standing" card (Wren's Journey chapter of the area). '' while seals_open is 0. */
function standing_card_html(array $u, int $rid): string
{
    $uid = (int)$u['id'];
    if (!seals_on() || $uid < 1 || $rid < 1) return '';
    region_seal_check($uid, $rid);   // lazily, on Wren's page
    $st = region_standing($uid, $rid);
    $thr = seal_threshold();
    $name = seal_area_name($rid);
    $fmt = fn(float $x) => rtrim(rtrim(number_format($x, 1), '0'), '.');
    $h = '<div class="box jstanding"><h4>🧭 Expedition Standing: ' . e($name) . ' <small>' . $fmt($st['total']) . '%</small></h4>'
        . '<progress class="jstbar" max="100" value="' . e((string)$st['total']) . '" aria-label="Standing ' . e($fmt($st['total'])) . ' of 100"></progress>'
        . '<p class="help">' . ($st['seal'] ? '🔏 <b>The ' . e($name) . ' Seal is yours.</b> Standing never goes down.'
            : '🔏 The ' . e($name) . ' Seal at <b>' . $thr . '%</b>: ' . $fmt(max(0, $thr - $st['total'])) . ' points to go. Every row keeps the best you have reached.') . '</p>'
        . '<table class="grid jsttbl"><thead><tr><th>Part</th><th>Points</th></tr></thead><tbody>';
    foreach ($st['rows'] as $r) {
        $full = $r['pts'] >= $r['max'];
        $h .= '<tr class="' . ($full ? 'full' : '') . '"><td>' . ($full ? '✅ ' : '⬜ ') . e($r['label']) . ($r['todo'] ? ' <small class="muted">(coming later)</small>' : '') . '</td>'
            . '<td>' . $fmt($r['pts']) . ' / ' . (int)$r['max'] . '</td></tr>';
    }
    $h .= '</tbody></table>';
    $doors = [];
    $code = seal_region_code($rid);
    foreach (GATE_NEEDS as $to => $alts) foreach ($alts as $a) if (in_array($code, $a, true)) $doors[$to] = seal_area_name(seal_region_id($to));
    if ($doors) $h .= '<p class="help">🚪 This Seal helps open the door' . (count($doors) === 1 ? '' : 's') . ' to ' . e(implode(', ', $doors)) . '.</p>';
    return $h . '</div>';
}

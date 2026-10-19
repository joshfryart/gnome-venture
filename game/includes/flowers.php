<?php
declare(strict_types=1);
/**
 * v0.9.9 part A: flowers. Arranging cut and dried flowers into an Arrangement (a one-off item that draws itself as SVG), the weekly
 * Arrangements show, a drying rack (real hours, lazy like the Pantry jars), seed packets for mastered flowers, and volunteer shifts at
 * the florists. Art: flower_art.php. Page: arrange.php. Nothing here needs cron: every timer is a ready_at that is checked when read.
 */
require_once __DIR__ . '/flower_art.php';
require_once __DIR__ . '/trade.php';       // mastered_plants(), notify()
require_once __DIR__ . '/friends.php';     // friend_add()

const ARR_MIN_STEMS_FLOOR = 1;

// ---------- small shared helpers ----------

/** Per-day counter (Hollow day) for 'shift' or 'packet'. */
function flower_daily_count(int $uid, string $kind): int
{
    return (int)q_val('SELECT n FROM flower_daily WHERE user_id = ? AND day = ? AND kind = ?', [$uid, hollow_date('Y-m-d'), $kind]);
}

function flower_daily_add(int $uid, string $kind): void
{
    $day = hollow_date('Y-m-d');
    if (q('UPDATE flower_daily SET n = n + 1 WHERE user_id = ? AND day = ? AND kind = ?', [$uid, $day, $kind])->rowCount() === 1) return;
    try {
        db_insert('flower_daily', ['user_id' => $uid, 'day' => $day, 'kind' => $kind, 'n' => 1]);
    } catch (PDOException $e) {   // a double click got there first
        q('UPDATE flower_daily SET n = n + 1 WHERE user_id = ? AND day = ? AND kind = ?', [$uid, $day, $kind]);
    }
}

/** Cut and dried flowers this gnome owns, ready to arrange. Each: id, slug, name, qty, rarity, base_price, dried, pslug, look. */
function flower_stock(int $uid): array
{
    $out = [];
    foreach (q("SELECT i.id, i.slug, i.name, i.category, i.effects, i.rarity, i.base_price, i.description, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
                WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'flower' ORDER BY i.name", [$uid])->fetchAll() as $r) {
        $slug = flower_item_slug($r);
        if ($slug === '') continue;
        $fx = json_decode((string)$r['effects'], true) ?: [];
        $r['pslug'] = $slug;
        $r['dried'] = !empty($fx['dried']);
        $r['look'] = flower_look($slug);
        $out[] = $r;
    }
    return $out;
}

/** The plant (name, region code) behind a flower slug. */
function flower_plant_info(string $slug): array
{
    static $c = [];
    if (!isset($c[$slug])) $c[$slug] = q_one('SELECT id, name, slug, region_code, seed_item_id, produce_item_id, knowledge_max FROM plants WHERE slug = ?', [$slug]) ?: ['name' => ucwords(str_replace('-', ' ', $slug)), 'region_code' => '', 'slug' => $slug];
    return $c[$slug];
}

// ---------- scoring ----------

/** Angle difference 0-180. */
function flower_hue_dist(float $a, float $b): float
{
    $d = abs($a - $b);
    return $d > 180 ? 360 - $d : $d;
}

/** Centre of a group of hues on the colour wheel (circular mean), 0-359. */
function flower_hue_mean(array $hs): float
{
    $x = $y = 0.0;
    foreach ($hs as $h) { $x += cos(deg2rad($h)); $y += sin(deg2rad($h)); }
    $m = rad2deg(atan2($y, $x));
    return $m < 0 ? $m + 360 : $m;
}

/** How far a group of hues spreads round the wheel (360 minus the biggest gap between neighbours). */
function flower_hue_spread(array $hs): float
{
    if (count($hs) < 2) return 0.0;
    $hs = array_values(array_unique(array_map('intval', $hs)));
    sort($hs);
    $gap = 0;
    for ($i = 0, $n = count($hs); $i < $n; $i++) $gap = max($gap, (($hs[($i + 1) % $n] - $hs[$i]) + 360) % 360 ?: 360);
    return (float)(360 - $gap);
}

/** Colour harmony 0-30 and what to call it. $hues = hues of the coloured stems, $neutrals = count of whites. */
function flower_harmony(array $hues, int $neutrals): array
{
    $hues = array_values(array_unique(array_map('intval', $hues)));   // distinct hues only: two reds are still one red
    sort($hues);
    if (!$hues) return [22, 'Pure and simple'];
    $spread = flower_hue_spread($hues);
    $word = '';
    if ($spread <= 35) { $pts = 30; $word = 'Tone on tone'; }
    elseif ($spread <= 80) { $pts = 26; $word = 'Neighbouring colours'; }
    else {
        // two camps opposite each other?
        $a = array_values(array_filter($hues, fn($h) => flower_hue_dist((float)$h, (float)$hues[0]) <= 50));
        $b = array_values(array_filter($hues, fn($h) => flower_hue_dist((float)$h, (float)$hues[0]) > 50));
        if ($b && flower_hue_spread($b) <= 70 && flower_hue_spread($a) <= 70
            && ($d = flower_hue_dist(flower_hue_mean($a), flower_hue_mean($b))) >= 130 && $d <= 230) {
            $pts = 27; $word = 'Opposites that sing';
        } else {
            // three camps a third of the wheel apart?
            sort($hues);
            $n = count($hues);
            $gaps = [];
            for ($i = 0; $i < $n; $i++) $gaps[$i] = (($hues[($i + 1) % $n] - $hues[$i]) + 360) % 360;
            arsort($gaps);
            $cut = array_slice(array_keys($gaps), 0, 3);
            sort($cut);
            $pts = count($cut) === 3 ? 10 : 8;
            $word = 'A lively mix';
            if (count($cut) === 3) {
                $groups = [];
                for ($g = 0; $g < 3; $g++) {
                    $from = $cut[$g] + 1;
                    $to = $cut[($g + 1) % 3];
                    $grp = [];
                    for ($k = $from; ; $k++) { $grp[] = $hues[$k % $n]; if ($k % $n === $to) break; }
                    $groups[] = $grp;
                }
                $c = array_map('flower_hue_mean', $groups);
                $ok = true;
                foreach ($groups as $g) if (flower_hue_spread($g) > 55) $ok = false;
                foreach ([[0, 1], [1, 2], [0, 2]] as [$i, $j]) { $d = flower_hue_dist($c[$i], $c[$j]); if ($d < 85 || $d > 155) $ok = false; }
                if ($ok) { $pts = 24; $word = 'A bright triad'; }
            }
            if ($pts < 24 && $n >= 6) $pts = 7;
        }
    }
    if ($neutrals > 0) $pts = min(30, $pts + 2);
    return [$pts, $word];
}

/** Season (0-3) of a month 1-12: 0 spring, 1 summer, 2 autumn, 3 winter. */
function flower_season_of(int $month): string
{
    return ['wi', 'wi', 'sp', 'sp', 'sp', 'su', 'su', 'su', 'au', 'au', 'au', 'wi'][max(1, min(12, $month)) - 1];
}

/**
 * Score an arrangement 0-100. Pure: the same stems, vessel and context always give the same number.
 * $stems: [['slot' => 0, 'slug' => 'dahlia', 'dried' => false, 'rarity' => 51], ...]; $ctx: ['month' => 1-12, 'regions' => ['NA', ...]].
 *   harmony 0-30 (colour wheel) · variety 0-20 (kinds) · rarity 0-20 · focal 0-12 (the rarest in the centre) · balance 0-10 (left against right)
 *   · season 0-5 (in bloom this month; dried keep) · region 0-3 (grown where you are or at home)
 * Returns ['total', 'parts' => [label => [points, max, note]], 'word', 'dominant' (hue name)].
 */
function arrange_score(array $stems, string $vessel, array $ctx): array
{
    usort($stems, fn($a, $b) => $a['slot'] <=> $b['slot']);
    $n = count($stems);
    $hues = [];
    $neutral = 0;
    $kinds = [];
    $rar = 0;
    $maxRar = 0;
    foreach ($stems as $s) {
        [, $tint] = flower_look($s['slug']);
        [$h, $sat, $l] = flower_hsl($tint);
        if ($l > 0.88 || $sat < 0.12) $neutral++; else $hues[] = $h;
        $kinds[$s['slug']] = ($kinds[$s['slug']] ?? 0) + 1;
        $rar += (int)$s['rarity'];
        $maxRar = max($maxRar, (int)$s['rarity']);
    }
    [$harm, $harmWord] = flower_harmony($hues, $neutral);
    $d = count($kinds);
    $var = $d <= 1 ? 6 : ($d === 2 ? 13 : ($d === 3 ? 20 : ($n >= 7 ? 18 : 16)));
    $avg = $n ? $rar / $n : 0;
    $rarPts = (int)round(max(0.0, min(1.0, ($avg - 25) / 50)) * 20);
    $focal = 1;
    $focalNote = 'Put your rarest flower in the middle top.';
    if ($stems && $stems[0]['slot'] === 0) {
        $f = $stems[0];
        if ((int)$f['rarity'] >= $maxRar) {
            $solo = $kinds[$f['slug']] === 1;
            $focal = $solo ? 12 : 8;
            $focalNote = $solo ? 'A rare flower all on its own in the centre.' : 'The rarest kind is in the centre.';
        } elseif ((int)$f['rarity'] >= $avg) { $focal = 4; $focalNote = 'A fine centre; a rarer one would shine.'; }
    }
    $L = $R = 0.0;
    foreach ($stems as $s) {
        $w = 1 + (int)$s['rarity'] / 100;
        $x = SLOT_POS[$s['slot']][0] ?? 100;
        if ($x < 100) $L += $w; elseif ($x > 100) $R += $w; else { $L += $w / 2; $R += $w / 2; }
    }
    $bal = ($L + $R) > 0 ? (int)round(10 * (1 - abs($L - $R) / ($L + $R))) : 0;
    $season = (string)($ctx['season'] ?? flower_season_of((int)($ctx['month'] ?? 1)));   // v1.0.0: the Hollow's season when given (arrange_ctx), else from the month
    $in = 0.0;
    $local = 0.0;
    foreach ($stems as $s) {
        $look = flower_look($s['slug']);
        $in += !empty($s['dried']) ? 0.8 : (count($look[2]) >= 4 ? 0.5 : (in_array($season, $look[2], true) ? 1.0 : 0.0));
        $code = (string)(flower_plant_info($s['slug'])['region_code'] ?? '');
        if ($code !== '' && in_array($code, (array)($ctx['regions'] ?? []), true)) $local += 1;
    }
    $seaPts = $n ? (int)round(5 * $in / $n) : 0;
    $regPts = $n ? (int)round(3 * $local / $n) : 0;
    $total = max(0, min(100, $harm + $var + $rarPts + $focal + $bal + $seaPts + $regPts));
    $parts = [
        'Colour' => [$harm, 30, $harmWord],
        'Variety' => [$var, 20, $d . ' kind' . ($d === 1 ? '' : 's') . ' of flower'],
        'Rarity' => [$rarPts, 20, $avg >= 55 ? 'Choice blooms' : ($avg >= 40 ? 'Pretty ordinary' : 'Common flowers')],
        'Focal flower' => [$focal, 12, $focalNote],
        'Balance' => [$bal, 10, $bal >= 9 ? 'Even on both sides' : 'Heavier on one side'],
        'Season' => [$seaPts, 5, $seaPts >= 4 ? 'In bloom now' : 'Not many in season'],
        'Local' => [$regPts, 3, $regPts >= 2 ? 'Grown near you' : 'From far away'],
    ];
    return ['total' => $total, 'parts' => $parts, 'word' => arrange_word($total), 'hues' => $hues, 'neutral' => $neutral, 'kinds' => $kinds];
}


/** A name for an arrangement ("Sunny Meadow Basket"), the same every time for the same stems. */
function arrange_name(array $stems, string $vessel, array $score): string
{
    usort($stems, fn($a, $b) => $a['slot'] <=> $b['slot']);   // the name must not depend on the order the stems were listed in
    $names = [];
    $allDried = $stems !== [];
    foreach ($stems as $s) { $names[$s['slug']] = flower_plant_info($s['slug'])['name']; if (empty($s['dried'])) $allDried = false; }
    $h = crc32(implode('|', array_map(fn($s) => $s['slot'] . $s['slug'] . (int)$s['dried'], $stems)) . $vessel);
    $pick = fn(array $a) => $a[$h % count($a)];
    if ($allDried) $adj = 'Everlasting';
    elseif (!$score['hues']) $adj = 'Snowdrift';
    else {
        $m = flower_hue_mean($score['hues']);
        $adj = match (true) {
            $m >= 345 || $m < 15 => 'Scarlet', $m < 45 => 'Sunset', $m < 70 => 'Sunny', $m < 165 => 'Fresh',
            $m < 205 => 'Lagoon', $m < 255 => 'Skyward', $m < 295 => 'Twilight', default => 'Rosy',
        };
    }
    $d = count($names);
    $theme = $d === 1 ? (string)reset($names) : ($d === 2 ? $pick(['Posy', 'Duet', 'Pair']) : ($d === 3 ? $pick(['Meadow', 'Trio', 'Bouquet']) : $pick(['Garden', 'Medley', 'Cottage'])));
    $vw = ['jar' => 'Jar', 'vase' => 'Vase', 'basket' => 'Basket'][$vessel] ?? 'Vase';
    return mb_substr($adj . ' ' . $theme . ' ' . $vw, 0, 70);
}

/** Where a gnome is: the month and the region codes that count as "local" (home and the region they are standing in). */
function arrange_ctx(array $u): array
{
    $codes = [];
    if (!empty($u['region_id'])) $codes[] = (string)q_val('SELECT code FROM regions WHERE id = ?', [(int)$u['region_id']]);
    if (!empty($u['location_id'])) {
        $rid = (int)q_val('SELECT region_id FROM locations WHERE id = ?', [(int)$u['location_id']]);
        if ($rid) $codes[] = (string)q_val('SELECT code FROM regions WHERE id = ?', [$rid]);
    }
    return ['month' => (int)hollow_date('n'), 'season' => hollow_season_code(), 'regions' => array_values(array_filter(array_unique($codes)))];
}

// ---------- arranging ----------

/**
 * Make an arrangement. $slots = [slot => item id of a flower in the satchel]. Takes the stems and the energy in one transaction,
 * and gives back a new Arrangement item (its stems, vessel and score are kept in the item's effects so it draws itself anywhere).
 * Returns [ok, message, item id].
 */
function arrange_make(array $u, string $vessel, array $slots): array
{
    $uid = (int)$u['id'];
    if (!isset(VESSELS[$vessel])) return [false, 'Pick a vessel first.', 0];
    [$vname, $cap, $allowed] = VESSELS[$vessel];
    $min = max(ARR_MIN_STEMS_FLOOR, (int)setting('arrange_min_stems'));
    $want = [];
    foreach ($slots as $slot => $iid) {
        if (!in_array((int)$slot, $allowed, true) || (int)$iid <= 0) continue;
        $want[(int)$slot] = (int)$iid;
    }
    if (count($want) < $min) return [false, 'A ' . strtolower($vname) . ' needs at least ' . $min . ' stems. Tap a flower, then a spot.', 0];
    if (count($want) > $cap) return [false, 'That is too many stems for a ' . strtolower($vname) . '.', 0];
    ksort($want);
    $need = array_count_values($want);
    $items = [];
    foreach ($need as $iid => $qty) {
        $it = q_one("SELECT * FROM items WHERE id = ? AND category = 'flower'", [$iid]);
        if (!$it || flower_item_slug($it) === '') return [false, 'One of those is not a flower you can arrange.', 0];
        $items[$iid] = $it;
    }
    $stems = [];
    $priceSum = 0;
    $dryCount = 0;
    foreach ($want as $slot => $iid) {
        $it = $items[$iid];
        $fx = json_decode((string)$it['effects'], true) ?: [];
        $stems[] = ['slot' => $slot, 'slug' => flower_item_slug($it), 'dried' => !empty($fx['dried']), 'rarity' => (int)$it['rarity']];
        $priceSum += (int)$it['base_price'];
        $dryCount += !empty($fx['dried']) ? 1 : 0;
    }
    $score = arrange_score($stems, $vessel, arrange_ctx($u));
    $name = arrange_name($stems, $vessel, $score);
    $energy = max(0, (int)setting('arrange_energy'));
    $comp = ['v' => $vessel, 's' => array_map(fn($s) => [$s['slot'], $s['slug'], $s['dried'] ? 1 : 0], $stems)];
    $kinds = array_values(array_unique(array_map(fn($s) => flower_plant_info($s['slug'])['name'], $stems)));
    $value = max(5, (int)round($priceSum * (80 + $score['total']) / 100 * max(10, (int)setting('arrange_value_pct')) / 100));
    db()->beginTransaction();
    foreach ($need as $iid => $qty) {
        if (!give_item($uid, $iid, -$qty)) {
            db()->rollBack();
            return [false, 'You don’t have all of those flowers any more. Nothing was used.', 0];
        }
    }
    if ($energy > 0 && !spend_energy($uid, $energy)) {
        db()->rollBack();
        return [false, 'You’re too tired to arrange. It takes ⚡' . $energy . '. Nothing was used.', 0];
    }
    $slug = 'arr-' . substr(bin2hex(random_bytes(8)), 0, 12);
    $itemId = db_insert('items', ['name' => $name, 'slug' => $slug, 'category' => 'arrangement', 'rarity' => min(95, 20 + (int)round($score['total'] * 0.75)),
        'base_price' => $value, 'tradable' => 1, 'edible' => 0,
        'description' => 'A ' . strtolower($score['word']) . ' arrangement of ' . count($stems) . ' stems in a ' . strtolower($vname) . ': ' . implode(', ', array_slice($kinds, 0, 5))
            . (count($kinds) > 5 ? ' and more' : '') . '. Score ' . $score['total'] . '/100. Sell it, give it as a present, or put it in the weekly Arrangements show.',
        'effects' => json_encode(['arrangement' => $comp + ['score' => $score['total'], 'dried' => $dryCount]])]);
    give_item($uid, $itemId, 1);
    [$xp] = add_action_xp($uid, 3 + intdiv($score['total'], 25), 'Arranging', (int)$u['level']);
    unlock_entries($uid, 'flowers');
    db()->commit();
    return [true, '💐 You make “' . $name . '”: ' . $score['word'] . ', ' . $score['total'] . '/100' . ($energy ? ' (−' . $energy . ' ⚡' : ' (') . '+' . $xp . ' XP). It’s in your Satchel.', $itemId];
}


/** Arrangements this gnome holds, best first. */
function arrangements_owned(int $uid): array
{
    $out = [];
    foreach (q("SELECT i.id, i.name, i.slug, i.category, i.effects, i.base_price, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
                WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'arrangement' ORDER BY i.id DESC", [$uid])->fetchAll() as $r) {
        if ($a = arrangement_of($r)) { $r['arr'] = $a; $out[] = $r; }
    }
    usort($out, fn($a, $b) => (int)$b['arr']['score'] <=> (int)$a['arr']['score']);
    return $out;
}

// ---------- the Arrangements show (weekly) ----------

function arr_prizes(): array
{
    $p = array_map(fn($v) => max(0, (int)trim($v)), explode(',', (string)setting('arrange_prizes')));
    return $p + [0 => 800, 1 => 400, 2 => 200, 3 => 25];
}

/** Put an arrangement on show for this week. One entry a gnome; a better one swaps in (the old one comes back to the Satchel). */
function arrangement_enter(array $u, int $itemId): array
{
    $uid = (int)$u['id'];
    $it = q_one("SELECT * FROM items WHERE id = ? AND category = 'arrangement'", [$itemId]);
    $a = $it ? arrangement_of($it) : null;
    if (!$a) return [false, 'Pick one of your arrangements.'];
    if (!q_val('SELECT COUNT(*) FROM users u WHERE u.id = ? AND ' . gnome_in_play_sql('u'), [$uid])) return [false, 'Only gnomes who are out and about can enter.'];
    $week = job_period_key('weekly');
    $mine = q_one('SELECT * FROM arrangement_entries WHERE week = ? AND user_id = ?', [$week, $uid]);
    if ($mine && (int)$mine['score'] >= (int)$a['score']) return [false, 'Your entry this week (' . (int)$mine['score'] . ') is already as good. Make a better one to swap it in.'];
    db()->beginTransaction();
    if (!give_item($uid, $itemId, -1)) {
        db()->rollBack();
        return [false, 'You don’t have that arrangement any more.'];
    }
    if ($mine) {
        if (q('UPDATE arrangement_entries SET item_id = ?, title = ?, score = ?, comp = ?, entered_at = ? WHERE id = ? AND placed IS NULL',
            [$itemId, $it['name'], (int)$a['score'], json_encode($a), now(), $mine['id']])->rowCount() !== 1) {
            db()->rollBack();
            return [false, 'This week’s show has already been judged.'];
        }
        if ((int)$mine['item_id'] > 0) give_item($uid, (int)$mine['item_id'], 1);   // the one it replaces comes home
    } else {
        try {
            db_insert('arrangement_entries', ['week' => $week, 'user_id' => $uid, 'item_id' => $itemId, 'title' => $it['name'], 'score' => (int)$a['score'],
                'comp' => json_encode($a), 'entered_at' => now()]);
        } catch (PDOException $e) {
            db()->rollBack();
            return [false, 'You have already entered this week.'];
        }
    }
    db()->commit();
    return [true, '🎗️ “' . $it['name'] . '” (' . (int)$a['score'] . '/100) is on show for the week. It stays at the show, and the judges announce the winners when the week ends.' . ($mine ? ' Your earlier one is back in your Satchel.' : '')];
}

/** Judge any finished week: ranked by score, ties to the earlier entry. Prizes and ribbons are paid once per entry. */
function settle_arrangements(): void
{
    $now = job_period_key('weekly');
    $weeks = q('SELECT DISTINCT week FROM arrangement_entries WHERE placed IS NULL AND week <> ?', [$now])->fetchAll(PDO::FETCH_COLUMN);
    if (!$weeks) return;
    $prizes = arr_prizes();
    foreach ($weeks as $week) {
        $rows = q('SELECT e.* FROM arrangement_entries e JOIN users u ON u.id = e.user_id WHERE e.week = ? AND e.placed IS NULL AND ' . gnome_in_play_sql('u')
            . ' ORDER BY e.score DESC, e.entered_at, e.id', [$week])->fetchAll();
        $rank = 0;
        foreach ($rows as $r) {
            $rank++;
            db()->beginTransaction();
            if (q('UPDATE arrangement_entries SET placed = ? WHERE id = ? AND placed IS NULL', [$rank, $r['id']])->rowCount() === 1) {
                $coins = (int)$prizes[min($rank, 4) - 1];
                q('UPDATE users SET coins = coins + ?' . ($rank <= 3 ? ', ribbons = ribbons + 1' : '') . ' WHERE id = ?', [$coins, $r['user_id']]);
                add_xp((int)$r['user_id'], [1 => 30, 2 => 20, 3 => 10][$rank] ?? 5, 'Arrangements show');
                notify((int)$r['user_id'], $rank <= 3
                    ? ['', '🥇', '🥈', '🥉'][$rank] . ' “' . $r['title'] . '” (' . (int)$r['score'] . '/100) came #' . $rank . ' in the Arrangements show! Prize: ' . money($coins) . ' and a ribbon.'
                    : '💐 Thanks for showing “' . $r['title'] . '” (#' . $rank . '). Here’s ' . money($coins) . ' for taking part.');
            }
            db()->commit();
        }
        // entries by gnomes in a time-out sit the week out: marked 0 so they are not judged twice, and get no prize
        q('UPDATE arrangement_entries SET placed = 0 WHERE week = ? AND placed IS NULL', [$week]);
    }
}

/** This week's leaders: [title, score, comp, gnome name], best first. */
function arrangement_leaders(string $week, int $limit = 5): array
{
    return q('SELECT e.title, e.score, e.comp, COALESCE(u.gnome_name, u.username) AS gname FROM arrangement_entries e JOIN users u ON u.id = e.user_id
              WHERE e.week = ? AND ' . gnome_in_play_sql('u') . ' ORDER BY e.score DESC, e.entered_at, e.id LIMIT ' . (int)$limit, [$week])->fetchAll();
}

// ---------- drying ----------

/** The Dried item for a cut flower (made the first time anyone dries one). */
function dried_item(array $cut): int
{
    $slug = 'dried-' . flower_item_slug($cut);
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    if ($id) return $id;
    $name = preg_replace('/^Cut\s+/u', '', (string)$cut['name']);
    return db_insert('items', ['name' => 'Dried ' . $name, 'slug' => $slug, 'category' => 'flower', 'rarity' => (int)$cut['rarity'],
        'base_price' => max(1, (int)ceil((int)$cut['base_price'] * max(50, (int)setting('dried_price_pct')) / 100)), 'tradable' => 1, 'edible' => 0,
        'description' => 'A ' . strtolower($name) . ' hung upside down until it dried to a faded, papery colour. It never wilts. Use it in an arrangement as an everlasting flower.',
        'effects' => json_encode(['dried' => 1, 'of' => flower_item_slug($cut)])]);
}

function dry_busy(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM dry_racks WHERE user_id = ? AND collected_at IS NULL', [$uid]);
}

function dry_ready_count(int $uid): int
{
    return (int)q_val('SELECT COUNT(*) FROM dry_racks WHERE user_id = ? AND collected_at IS NULL AND ready_at <= ?', [$uid, now()]);
}

/** Bundles on the rack, soonest first, with seconds left. */
function dry_list(int $uid): array
{
    $rows = q('SELECT d.id, d.qty, d.ready_at, i.id AS item_id, i.name, i.slug, i.category, i.effects FROM dry_racks d JOIN items i ON i.id = d.item_id
               WHERE d.user_id = ? AND d.collected_at IS NULL ORDER BY d.ready_at, d.id', [$uid])->fetchAll();
    foreach ($rows as &$r) $r['left'] = max(0, (int)strtotime($r['ready_at'] . ' UTC') - time());
    return $rows;
}

/** Hang a bundle of one cut flower to dry. */
function dry_start(array $u, int $itemId, int $qty): array
{
    $uid = (int)$u['id'];
    $it = q_one("SELECT * FROM items WHERE id = ? AND category = 'flower'", [$itemId]);
    if (!$it || flower_item_slug($it) === '') return [false, 'Pick a cut flower to dry.'];
    $fx = json_decode((string)$it['effects'], true) ?: [];
    if (!empty($fx['dried'])) return [false, 'That one is already dried.'];
    $qty = max(1, min((int)setting('dry_per_rack'), $qty));
    if (dry_busy($uid) >= (int)setting('dry_racks')) return [false, 'Your drying rack is full (' . (int)setting('dry_racks') . ' bundles). Collect a dry one first.'];
    $secs = max(1, (int)setting('dry_hours')) * 3600;
    db()->beginTransaction();
    if (!give_item($uid, $itemId, -$qty)) {
        db()->rollBack();
        return [false, 'You don’t have ' . $qty . ' × ' . $it['name'] . '.'];
    }
    db_insert('dry_racks', ['user_id' => $uid, 'item_id' => $itemId, 'qty' => $qty, 'started_at' => now(), 'ready_at' => gmdate('Y-m-d H:i:s', time() + $secs)]);
    db()->commit();
    return [true, '🪢 You hang ' . $qty . ' × ' . $it['name'] . ' to dry. Ready in ' . nice_time($secs) . '; come back and collect them.'];
}

/** Collect one dry bundle. */
function dry_collect(array $u, int $rackId): array
{
    $uid = (int)$u['id'];
    $d = q_one('SELECT * FROM dry_racks WHERE id = ? AND user_id = ? AND collected_at IS NULL', [$rackId, $uid]);
    if (!$d) return [false, 'That bundle has already been taken down.'];
    if ($d['ready_at'] > now()) return [false, 'Those flowers aren’t dry yet.'];
    $cut = q_one('SELECT * FROM items WHERE id = ?', [$d['item_id']]);
    if (!$cut) return [false, 'That flower is gone.'];
    db()->beginTransaction();
    if (q('UPDATE dry_racks SET collected_at = ? WHERE id = ? AND user_id = ? AND collected_at IS NULL', [now(), $rackId, $uid])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That bundle has already been taken down.'];   // two tabs at once
    }
    $did = dried_item($cut);
    give_item($uid, $did, (int)$d['qty']);
    unlock_entries($uid, 'flowers');
    db()->commit();
    return [true, '🌾 ' . (int)$d['qty'] . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$did]) . ' collected. They will never wilt.'];
}

function dry_collect_all(array $u): array
{
    $n = 0;
    $msgs = [];
    foreach (dry_list((int)$u['id']) as $r) {
        if ($r['left'] > 0) continue;
        [$ok, $m] = dry_collect($u, (int)$r['id']);
        if ($ok) { $n++; $msgs[] = $m; }
    }
    return $n ? [true, implode(' ', $msgs)] : [false, 'Nothing is dry yet.'];
}

// ---------- seed packets ----------

function packet_item(array $p): int
{
    $slug = $p['slug'] . '-packet';
    $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [$slug]);
    if ($id) return $id;
    $n = max(1, (int)setting('packet_seeds'));
    $seedPrice = (int)q_val('SELECT base_price FROM items WHERE id = ?', [$p['seed_item_id']]);
    return db_insert('items', ['name' => $p['name'] . ' Seed Packet', 'slug' => $slug, 'category' => 'packet', 'rarity' => 35,
        'base_price' => max(30, (int)round($seedPrice * $n * 1.8)), 'tradable' => 1, 'edible' => 0,
        'description' => 'A neat paper packet of ' . $n . ' ' . $p['name'] . ' seeds, saved by a master gardener. Open it to get the seeds.',
        'effects' => json_encode(['packet' => (int)$p['id'], 'of' => $p['slug'], 'seeds' => $n])]);
}

/** Flowers this gnome has mastered and could pack: each has the seeds owned. */
function packet_choices(int $uid): array
{
    return array_values(array_filter(mastered_plants($uid), fn($p) => $p['kind'] === 'flower'));
}

function packet_make(array $u, int $plantId): array
{
    $uid = (int)$u['id'];
    $p = null;
    foreach (packet_choices($uid) as $m) if ((int)$m['id'] === $plantId) $p = $m;
    if (!$p) return [false, 'You need to master a flower (full knowledge from growing it) before you can pack its seeds.'];
    if (flower_daily_count($uid, 'packet') >= (int)setting('packets_per_day')) return [false, 'You’ve packed all the seed packets you can today. Come back tomorrow.'];
    $n = max(1, (int)setting('packet_seeds'));
    $fee = max(0, (int)setting('packet_fee'));
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.2.2: lock this gnome, then re-count today's packets
    if (flower_daily_count($uid, 'packet') >= (int)setting('packets_per_day')) {
        db()->rollBack();
        return [false, 'You’ve packed all the seed packets you can today. Come back tomorrow.'];
    }
    if (!give_item($uid, (int)$p['seed_item_id'], -$n)) {
        db()->rollBack();
        return [false, 'You need ' . $n . ' × ' . $p['seed_name'] . ' for a packet.'];
    }
    if ($fee > 0 && q('UPDATE users SET coins = coins - ? WHERE id = ? AND coins >= ?', [$fee, $uid, $fee])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'Paper and string cost ' . money($fee) . '.'];
    }
    $pid = packet_item($p);
    give_item($uid, $pid, 1);
    flower_daily_add($uid, 'packet');
    db()->commit();
    return [true, '📦 You pack ' . $n . ' seeds into a ' . $p['name'] . ' Seed Packet' . ($fee ? ' (−' . money($fee) . ')' : '') . '. Sell it, trade it or give it to a friend.'];
}

function packet_open(array $u, int $itemId): array
{
    $uid = (int)$u['id'];
    $it = q_one("SELECT * FROM items WHERE id = ? AND category = 'packet'", [$itemId]);
    $fx = $it ? (json_decode((string)$it['effects'], true) ?: []) : [];
    $plant = !empty($fx['packet']) ? q_one('SELECT seed_item_id, name FROM plants WHERE id = ?', [(int)$fx['packet']]) : null;
    if (!$plant) return [false, 'That is not a seed packet.'];
    $n = max(1, (int)($fx['seeds'] ?? 3));
    db()->beginTransaction();
    if (!give_item($uid, $itemId, -1)) {
        db()->rollBack();
        return [false, 'You don’t have that packet.'];
    }
    give_item($uid, (int)$plant['seed_item_id'], $n);
    db()->commit();
    return [true, '🌱 You open the packet: ' . $n . ' × ' . $plant['name'] . ' seeds.'];
}

// ---------- florists and volunteering ----------

function florist_shops(): array
{
    return q("SELECT s.*, l.name AS town FROM shops s LEFT JOIN locations l ON l.id = s.location_id WHERE s.shop_type = 'florist' AND s.open = 1 ORDER BY s.id")->fetchAll();
}

function florist_active(int $uid): ?array
{
    $r = q_one('SELECT f.*, s.name AS shop_name FROM florist_shifts f JOIN shops s ON s.id = f.shop_id WHERE f.user_id = ? AND f.collected_at IS NULL ORDER BY f.id DESC LIMIT 1', [$uid]);
    if ($r) $r['left'] = max(0, (int)strtotime($r['ready_at'] . ' UTC') - time());
    return $r;
}

function florist_shifts_left(int $uid): int
{
    return max(0, (int)setting('florist_shifts_day') - flower_daily_count($uid, 'shift'));
}

function florist_start(array $u, array $shop): array
{
    $uid = (int)$u['id'];
    if (($shop['shop_type'] ?? '') !== 'florist') return [false, 'That is not a florist.'];
    if (!shop_reachable($u, $shop)) return [false, 'You need to be in that town to volunteer here.'];
    $staff = staff_on_duty((int)$shop['id']);
    if (!$staff) return [false, 'Nobody is at the counter right now. Come back when the florist is in.'];
    if (florist_active($uid)) return [false, 'You already have a shift going. Finish it first.'];
    if (florist_shifts_left($uid) < 1) return [false, 'You’ve done all the shifts you can today (' . (int)setting('florist_shifts_day') . '). Come back tomorrow.'];
    $energy = max(0, (int)setting('florist_energy'));
    $secs = max(1, (int)setting('florist_minutes')) * 60;
    $who = $staff[0];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // v1.2.2: lock, then re-check: one shift at a time, and the day's limit
    if (florist_active($uid)) {
        db()->rollBack();
        return [false, 'You already have a shift going. Finish it first.'];
    }
    if (florist_shifts_left($uid) < 1) {
        db()->rollBack();
        return [false, 'You’ve done all the shifts you can today (' . (int)setting('florist_shifts_day') . '). Come back tomorrow.'];
    }
    if ($energy > 0 && !spend_energy($uid, $energy)) {
        db()->rollBack();
        return [false, 'You’re too tired to volunteer. A shift costs ⚡' . $energy . '.'];
    }
    db_insert('florist_shifts', ['user_id' => $uid, 'shop_id' => (int)$shop['id'], 'npc_id' => (int)$who['id'], 'started_at' => now(), 'ready_at' => gmdate('Y-m-d H:i:s', time() + $secs)]);
    flower_daily_add($uid, 'shift');
    db()->commit();
    return [true, '🌷 You tie on an apron and start a ' . nice_time($secs) . ' shift with ' . $who['name'] . ($energy ? ' (−' . $energy . ' ⚡)' : '') . '. Collect your thanks when it’s done.'];
}

/** The pool of cut flowers a florist hands out: its own region's flowers, or any region's at the Mossbottom hub. [item id => weight] */
function florist_pool(array $shop): array
{
    $loc = $shop['location_id'] ? q_one('SELECT region_id, kind FROM locations WHERE id = ?', [$shop['location_id']]) : null;
    $sql = "SELECT i.id, i.rarity FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.kind = 'flower'";
    $args = [];
    if ($loc && $loc['kind'] !== 'hub' && (int)$loc['region_id']) {
        $sql .= ' AND p.region_code = (SELECT code FROM regions WHERE id = ?)';
        $args[] = (int)$loc['region_id'];
    }
    $pool = [];
    foreach (q($sql . ' ORDER BY i.id', $args)->fetchAll() as $r) $pool[(int)$r['id']] = max(5, 100 - (int)$r['rarity']);
    return $pool;
}

function florist_collect(array $u, int $shiftId): array
{
    $uid = (int)$u['id'];
    $s = q_one('SELECT * FROM florist_shifts WHERE id = ? AND user_id = ? AND collected_at IS NULL', [$shiftId, $uid]);
    if (!$s) return [false, 'That shift is already done.'];
    if ($s['ready_at'] > now()) return [false, 'Your shift isn’t over yet.'];
    $shop = q_one('SELECT * FROM shops WHERE id = ?', [$s['shop_id']]);
    $pool = $shop ? florist_pool($shop) : [];
    [$lo, $hi] = array_map('intval', array_pad(explode(',', (string)setting('florist_stems')), 2, 5));
    $lo = max(1, $lo);
    $hi = max($lo, $hi);
    db()->beginTransaction();
    if (q('UPDATE florist_shifts SET collected_at = ? WHERE id = ? AND user_id = ? AND collected_at IS NULL', [now(), $shiftId, $uid])->rowCount() !== 1) {
        db()->rollBack();
        return [false, 'That shift is already done.'];   // two tabs at once
    }
    $got = [];
    $total = array_sum($pool);
    for ($k = 0, $n = random_int($lo, $hi); $total > 0 && $k < $n; $k++) {
        $roll = random_int(1, $total);
        foreach ($pool as $iid => $w) { if (($roll -= $w) <= 0) { $got[$iid] = ($got[$iid] ?? 0) + 1; break; } }
    }
    $names = [];
    foreach ($got as $iid => $qty) {
        give_item($uid, $iid, $qty);
        $names[] = $qty . ' × ' . q_val('SELECT name FROM items WHERE id = ?', [$iid]);
    }
    $xp = max(0, (int)setting('florist_xp'));
    if ($xp > 0) [$xp] = add_action_xp($uid, $xp, 'Volunteering', (int)$u['level']);
    $fr = max(0, (int)setting('florist_friend'));
    $npc = (int)$s['npc_id'] ? q_one('SELECT id, name FROM npcs WHERE id = ?', [(int)$s['npc_id']]) : null;
    if ($npc && $fr > 0) friend_add($uid, (int)$npc['id'], $fr);
    unlock_entries($uid, 'flowers');
    db()->commit();
    return [true, '🌷 Shift done! ' . ($npc ? $npc['name'] . ' gives you ' : 'You get ') . ($names ? implode(', ', $names) : 'a warm thank-you') . ' (+' . $xp . ' XP' . ($npc && $fr ? ', +' . $fr . ' friendship' : '') . ').'];
}

/** The volunteering box on a florist's shop page (HTML). */
function florist_panel(array $u, array $shop, bool $open): string
{
    $uid = (int)$u['id'];
    $act = florist_active($uid);
    $left = florist_shifts_left($uid);
    $mins = max(1, (int)setting('florist_minutes'));
    $h = '<section class="box florist" id="volunteer"><h2>🌷 Volunteer for ' . $mins . ' minutes</h2>'
        . '<p class="help">Lend a hand at the counter: tie bunches, sweep petals, water the buckets. It takes ' . $mins . ' real minutes and ⚡' . (int)setting('florist_energy')
        . '. You earn XP, the florist’s friendship and a small bundle of cut flowers for arranging. ' . $left . ' shift' . ($left === 1 ? '' : 's') . ' left today.</p>';
    $act_here = $act && (int)$act['shop_id'] === (int)$shop['id'];
    if ($act) {
        $h .= '<p><b>' . ($act['left'] > 0 ? '⏳ Shift at ' . e($act['shop_name']) . ': ' . e(nice_time((int)$act['left'])) . ' to go.' : '✅ Your shift at ' . e($act['shop_name']) . ' is over.') . '</b></p>';
        if ($act['left'] <= 0) {
            $h .= '<form method="post" action="' . e(url('shop.php?id=' . (int)$shop['id'])) . '">' . csrf_field() . '<input type="hidden" name="do" value="flo_collect"><input type="hidden" name="shift" value="' . (int)$act['id'] . '">'
                . '<button class="btn">🎁 Collect your thanks</button></form>';
        }
    } elseif ($open && $left > 0) {
        $h .= '<form method="post" action="' . e(url('shop.php?id=' . (int)$shop['id'])) . '">' . csrf_field() . '<input type="hidden" name="do" value="flo_start"><button class="btn">🧑‍🌾 Start a shift</button></form>';
    } else {
        $h .= '<p class="muted">' . ($left < 1 ? 'No shifts left today.' : 'Come when the florist is in and you are in town.') . '</p>';
    }
    return $h . '</section>';
}

/** Handle the florist panel's buttons on shop.php. Returns [ok, message]. */
function florist_post(array $u, array $shop, string $do): array
{
    if ($do === 'flo_start') return florist_start($u, $shop);
    if ($do === 'flo_collect') return florist_collect($u, (int)($_POST['shift'] ?? 0));
    return [false, 'Nothing happened.'];
}

// ---------- item facts (Satchel) ----------


// ---------- install / upgrade ----------

const FLOWERS_ALMANAC = [
    'Arranging flowers' => [31, "💐 [b]Arranging[/b] turns cut and dried flowers into a one-off [b]Arrangement[/b]. Open Satchel → Arranging, pick a vessel (a glass jar holds 5 stems, a vase 7, a wicker basket 9), tap a flower and then a spot, and watch it fill. Press [b]Make it[/b] when you like it. It costs a little energy and uses up the stems.\n\n"
        . "[b]The score[/b] (0 to 100) comes from: [b]Colour[/b] (flowers that sit together on the colour wheel: tone on tone, neighbours, opposites or a triad), [b]Variety[/b] (three kinds is best), [b]Rarity[/b], the [b]Focal flower[/b] (your rarest, alone, in the top centre), [b]Balance[/b] (left against right), and a little for flowers in [b]Season[/b] and [b]Local[/b] ones grown where you are. The same stems in the same places always score the same.\n\n"
        . "[b]What for:[/b] an arrangement sells for more than its stems would, makes a loved present for folk (better than a single flower) and can go in the weekly [b]Arrangements show[/b], where the top three win Petals and a ribbon. A show entry stays at the show."],
    'Dried flowers' => [32, "🌾 Hang cut flowers upside down and they dry into everlastings. In Satchel → Arranging → [b]Drying rack[/b], pick a flower and how many (up to 6 in a bundle). You have 4 bundles at once, and each takes a real day, even while you are away.\n\nDried flowers [b]never wilt[/b], sell for a bit more than the fresh ones, and look faded and papery in an arrangement. They count as in season all year, and an arrangement made only of dried flowers is called [b]Everlasting[/b]."],
    'Seed packets' => [33, "📦 Once you have [b]mastered[/b] a flower (full knowledge from growing it), you can pack its seeds. In Satchel → Arranging → [b]Seed packets[/b], 3 of its seeds and a few Petals for the paper make a packet you can sell, trade or give away. Whoever opens it gets the 3 seeds. You can pack up to 5 a day."],
    'The florists' => [34, "🌷 [b]Florists[/b] sell cut flowers and let gnomes volunteer. There is one at Mossbottom Market (open to everyone) and one in Blossomreach. Their staff work in shifts round the clock.\n\n[b]Volunteer for 30 minutes[/b] on the florist's shop page: it costs 3 energy and a real half hour. You get a little XP, the florist's friendship and a bundle of 3 to 5 cut flowers, usually common ones. You can do 3 shifts a day, one at a time."],
];

/** Make the florist shops, their staff and stock, and the Almanac pages. Idempotent. Run by upgrade_099_flowers(). */
function flowers_ensure_shops(): void
{
    $hub = (int)q_val("SELECT id FROM locations WHERE kind = 'hub' ORDER BY id LIMIT 1");
    $meadow = (int)q_val("SELECT id FROM locations WHERE slug = 'whispering-meadow'") ?: $hub;
    $burrows = (int)q_val("SELECT id FROM locations WHERE slug = 'rootling-burrows'") ?: $hub;
    $ea = (int)q_val("SELECT id FROM locations WHERE slug = 'market-ea'");
    $sites = [
        ['petalpins-posies', 'Petalpin’s Posies', $hub, 'The florist at Mossbottom Market: buckets of cut flowers, string, scissors and a counter that smells wonderful. Gnomes are always welcome to lend a hand for half an hour.', null, $meadow, $burrows,
            [['Petalpin Greenfinger', 'Mouse', 'Warm', 'Opens the buckets at dawn and talks to every bloom by name.'], ['Marigold Tuftwhistle', 'Hedgehog', 'Cheerful', 'Makes the best ribbon bows in the Hollow and will tell you so.'], ['Nocturne', 'Moth', 'Dreamy', 'Works nights, tending the moon-flowers that only open after dark.']]],
        ['blossom-and-bough', 'Blossom & Bough', $ea, 'A tiny florist beside the Blossomreach market, full of branches in bloom and cut flowers from the eastern gardens. Volunteers are fed tea.', 'EA', $ea, $ea,
            [['Sakuya Brushwick', 'Toad', 'Proud', 'Arranges every vase as if the emperor were coming to tea.'], ['Haru Pennywhistle', 'Beetle', 'Eager', 'Sweeps petals, waters buckets and is always asking if there is anything else to do.'], ['Yoru Quillmoss', 'Mouse', 'Sleepy', 'Takes the night shift and snoozes among the chrysanthemums.']]],
    ];
    foreach ($sites as [$slug, $name, $loc, $desc, $region, $wander, $home, $staff]) {
        if (!$loc || q_val('SELECT 1 FROM shops WHERE slug = ?', [$slug])) continue;
        $shopId = db_insert('shops', ['name' => $name, 'slug' => $slug, 'location_id' => $loc, 'shop_type' => 'florist', 'restock_minutes' => 30, 'description' => $desc]);
        $sql = "SELECT i.id, i.base_price, i.rarity FROM plants p JOIN items i ON i.id = p.produce_item_id WHERE p.kind = 'flower'";
        $args = [];
        if ($region) { $sql .= ' AND p.region_code = ?'; $args[] = $region; }
        $sql .= ' ORDER BY i.rarity, i.id' . ($region ? '' : ' LIMIT 12');
        foreach (q($sql, $args)->fetchAll() as $it) {
            $p = (int)$it['base_price'];
            db_insert('shop_stock', ['shop_id' => $shopId, 'item_id' => $it['id'], 'price_min' => max(1, (int)ceil($p * 1.1)), 'price_max' => (int)ceil($p * 1.4),
                'max_stock' => 6, 'restock_chance' => max(20, 100 - (int)$it['rarity']), 'current_stock' => 3, 'current_price' => $p]);
        }
        foreach ($staff as $k => [$nm, $species, $pers, $bio]) {
            $nslug = slugify($nm);
            $nid = (int)q_val('SELECT id FROM npcs WHERE slug = ?', [$nslug]);
            if (!$nid) $nid = db_insert('npcs', ['name' => $nm, 'slug' => $nslug, 'species' => $species, 'personality' => $pers, 'bio' => $bio, 'home_location_id' => $home]);
            [$s, $eh] = [[6, 14], [14, 22], [22, 6]][$k];
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $loc, 'shop_id' => $shopId, 'activity' => 'working', 'start_hour' => $s, 'end_hour' => $eh]);
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $wander, 'shop_id' => null, 'activity' => 'wandering', 'start_hour' => $eh, 'end_hour' => ($eh + 3) % 24]);
            db_insert('npc_schedules', ['npc_id' => $nid, 'location_id' => $home, 'shop_id' => null, 'activity' => 'resting', 'start_hour' => ($eh + 3) % 24, 'end_hour' => $s]);
        }
    }
}

/**
 * v0.9.9 part A upgrade. Tables come from schema.php (db_migrate). This adds the two florists (shops, staff round the clock, stock) and
 * the four Almanac pages. Idempotent: nothing that exists is changed. Safe to call on every request that needs it (it checks first).
 */
function upgrade_099_flowers(): void
{
    flowers_ensure_shops();
    foreach (FLOWERS_ALMANAC as $title => [$sort, $body]) {
        if (q_val("SELECT 1 FROM encyclopedia_entries WHERE chapter = 'General' AND title = ?", [$title])) continue;
        $eid = db_insert('encyclopedia_entries', ['chapter' => 'General', 'category' => 'Getting started', 'title' => $title, 'body' => $body, 'unlock_key' => 'start', 'hint' => '', 'sort_order' => $sort]);
        foreach (q("SELECT DISTINCT ue.user_id FROM user_encyclopedia ue JOIN encyclopedia_entries e ON e.id = ue.entry_id WHERE e.unlock_key = 'start'")->fetchAll(PDO::FETCH_COLUMN) as $uid) {
            try { db_insert('user_encyclopedia', ['user_id' => $uid, 'entry_id' => $eid, 'unlocked_at' => now()]); } catch (PDOException $e) {}
        }
    }
    set_setting('flowers099', '1');
}

/** Run the upgrade once if this world hasn't had it (a world that was updated in place, or a version that is not bumped yet). */
function flowers_boot(): void
{
    static $done = false;
    if ($done) return;
    $done = true;
    if (setting('flowers099') !== '1') upgrade_099_flowers();
}

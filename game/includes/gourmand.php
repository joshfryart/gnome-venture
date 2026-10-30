<?php
declare(strict_types=1);

// The Gourmand (Pomeroy Crumbworth): the camp schedule, the data file, the spoon bars, serving a course, the ledger and the finale.
// Data: includes/data/gourmand.txt (R region rows, M menu rows, B story beats). The schedule follows TOWN_FESTIVALS (town.php), in Hollow time.
// The questline is always open from anywhere in a region; the schedule only decides where he is shown (the camp), and which day is the festival.
// Off by default: npcs.active follows the gourmand_open setting (gourmand_sync_active), so every folk list hides him without a check of its own.

const GOURMAND_HUB_CODE = 'MB';   // Mossbottom has no region code of its own
const GOURMAND_BARS = [   // spoon bars: 🥄, 🥄🥄, 🥄🥄🥄
    'plate' => [40, 50, 65], 'pot' => [40, 50, 65], 'grand' => [40, 50, 65],
    'jar' => [45, 52, 62],
];
const GOURMAND_WORDS = [1 => 'Honest', 2 => 'Seconds, please', 3 => 'Splendid'];   // not fair_word(): 62 is "Fine" there
const GOURMAND_LEVEL = 3;                                   // gnome level to dine with him
const GOURMAND_FIRST = [1 => [60, 20], 2 => [60, 20], 3 => [120, 40]];   // [Petals, XP] for reaching each spoon level on a course, once in a lifetime
const GOURMAND_TIP = [25, 8];                               // [Petals, XP] for a repeat serve (once per course each tour); XP doubles on the festival day
const GOURMAND_TABLE = 150;                                 // a Taste (plate, pot and jar all served): Petals, plus 2 seeds of the plate crop
const GOURMAND_GOLD = 300;                                  // a Golden table (all three at 3 spoons): Petals, plus one region treasure seed
const GOURMAND_SEAT_MIN = 7;                                // courses served last tour to earn a seat at the Long Table
const GOURMAND_FINALE = 1000;                               // Petals for his own cooking, at 14 Tastes
const GOURMAND_GOLD_SEEDS = [
    'NA' => 'pecan-seed', 'CA' => 'cacao-seed', 'CB' => 'nutmeg-seed', 'SA' => 'brazil-nut-seed', 'NWE' => 'cloudberry-seed', 'SE' => 'caper-seed', 'EE' => 'sea-buckthorn-seed',
    'MENA' => 'saffron-seed', 'WCA' => 'grains-of-paradise-seed', 'ESA' => 'coffee-seed', 'CSA' => 'black-pepper-seed', 'EA' => 'yuzu-seed', 'SEA' => 'mangosteen-seed', 'OC' => 'macadamia-seed',
];
const GOURMAND_COURSES = ['plate' => ['🥗', 'Plate', 'a raw crop'], 'pot' => ['🍲', 'Pot', 'a cooked dish'], 'jar' => ['🫙', 'Jar', 'a Pantry preserve']];
const GOURMAND_GRAND = ['🍽️', 'Grand', 'a regional feast'];   // the fourth course of the eight feast regions: Kitchen III, after that region's first Taste, pot bars
const GOURMAND_GRAND_PAY = [200, 40];                       // [Petals, XP] for a first 🥄 or better on a region's Grand course (the grandpay claim), once in a lifetime per region
const GOURMAND_HOME_PAY = [200, 40];                        // [Petals, XP] for the Home Plate (HOME/home), once in a lifetime
const GOURMAND_HOME_TASTES = 10;                            // Tastes that open the Home Plate (the `home` beat)

/** Is the feature on for this viewer? Admins always see it; players only while the setting is On. */
function gourmand_open(): bool
{
    return is_admin() || setting('gourmand_open') === '1';
}

/** Keep his folk row in step with the setting, so every list that reads npcs.active hides him while he is off. */
function gourmand_sync_active(): void
{
    q("UPDATE npcs SET active = ? WHERE traveller = 'gourmand'", [setting('gourmand_open') === '1' ? 1 : 0]);
}

function gourmand_npc_id(): int
{
    return (int)q_val("SELECT id FROM npcs WHERE traveller = 'gourmand'");
}

/** The tables this feature owns (merged at the end of schema.php), and the dish score column on cook_pots. */
function gourmand_schema(string $PK, string $ID, string $END): array
{
    $t = ["CREATE TABLE IF NOT EXISTS gourmand_ledger (
        id $PK,
        user_id $ID NOT NULL,
        region VARCHAR(4) NOT NULL,
        course VARCHAR(8) NOT NULL,
        best_q INT NOT NULL DEFAULT 0,
        spoons INT NOT NULL DEFAULT 0,
        paid INT NOT NULL DEFAULT 0,
        served INT NOT NULL DEFAULT 0,
        first_at DATETIME NULL,
        last_at DATETIME NULL,
        UNIQUE (user_id, region, course)
    )$END"];
    return [$t, [], [['cook_pots', 'score', 'INT NOT NULL DEFAULT 0']]];
}

/** "Now" for his schedule: the clock, or noon (Hollow time) of the admin's gourmand_force_date (Y-m-d). */
function gourmand_now(): int
{
    $f = trim((string)setting('gourmand_force_date'));
    if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $f)) {
        try { return (new DateTimeImmutable($f . ' 12:00:00', hollow_tz()))->getTimestamp(); } catch (Throwable $e) { /* fall through to the real clock */ }
    }
    return time();
}

/**
 * The windows of one Hollow month, pure: [[town, from day, to day, starts, ends], ...] in order, covering every day once.
 * Each town's window runs from the day after the previous festival through its own festival day; the last town stays to the month's end.
 * $fests is a town => festival day map (default TOWN_FESTIVALS); $ym is "Y-m".
 */
function gourmand_schedule(string $ym, ?array $fests = null): array
{
    if ($fests === null) {
        require_once __DIR__ . '/town.php';
        $fests = array_map(fn($f) => $f[2], TOWN_FESTIVALS);
    }
    asort($fests);
    $tz = hollow_tz();
    $first = new DateTimeImmutable($ym . '-01 00:00:00', $tz);
    $dim = (int)$first->format('t');
    $at = fn(int $d) => $d > $dim ? $first->modify('first day of next month')->getTimestamp() : $first->setDate((int)$first->format('Y'), (int)$first->format('n'), $d)->getTimestamp();
    $out = []; $from = 1; $i = 0; $last = count($fests);
    foreach ($fests as $town => $day) {
        $i++;
        $to = $i === $last ? $dim : max($from, min($dim, (int)$day));
        $out[] = ['town' => (string)$town, 'from' => $from, 'to' => $to, 'starts' => $at($from), 'ends' => $at($to + 1)];
        $from = $to + 1;
        if ($from > $dim) break;
    }
    return $out;
}

/** Region code of a town's gnomish name (Mossbottom = MB). */
function gourmand_code(string $town): string
{
    static $map = null;
    if ($map === null) {
        $map = [HUB_REGION => GOURMAND_HUB_CODE];
        require_once __DIR__ . '/stops.php';
        foreach (stops_file_rows('regions.txt') as $r) if (count($r) >= 2) $map[$r[1]] = $r[0];
    }
    return $map[$town] ?? '';
}

/**
 * Where he is shown at a moment (default: gourmand_now()): town, code, stop ("Y-m|CODE"), tour ("Y-m"), starts, ends, next (the next window),
 * festival (it is that town's festival day), long_table (day 1), camp (the spot slug). It only decides where he is shown; it never gates serving.
 */
function gourmand_stop(?int $ts = null): array
{
    $ts ??= gourmand_now();
    $ym = hollow_date('Y-m', $ts); $d = (int)hollow_date('j', $ts);
    $win = gourmand_schedule($ym); $k = 0;
    foreach ($win as $i => $w) if ($d >= $w['from'] && $d <= $w['to']) { $k = $i; break; }
    $w = $win[$k];
    $next = $win[$k + 1] ?? gourmand_schedule(hollow_date('Y-m', $w['ends']))[0];
    $code = gourmand_code($w['town']);
    require_once __DIR__ . '/town.php';
    return [
        'town' => $w['town'], 'code' => $code, 'stop' => $ym . '|' . $code, 'tour' => $ym, 'starts' => $w['starts'], 'ends' => $w['ends'],
        'next' => ['town' => $next['town'], 'code' => gourmand_code($next['town']), 'starts' => $next['starts']],
        'festival' => (TOWN_FESTIVALS[$w['town']][2] ?? 0) === $d, 'long_table' => $d === 1,
        'camp' => gourmand_rows()['R'][$code]['camp'] ?? '',
    ];
}

/** The parsed data file: ['R' => code => [code, camp, taste, line], 'M' => code => course => variant => row, 'B' => key => row]. */
function gourmand_rows(): array
{
    static $rows = null;
    if ($rows !== null) return $rows;
    require_once __DIR__ . '/stops.php';
    $rows = ['R' => [], 'M' => [], 'B' => []];
    foreach (stops_file_rows('gourmand.txt') as $r) {
        if ($r[0] === 'R' && count($r) >= 5) {
            $rows['R'][$r[1]] = ['code' => $r[1], 'camp' => $r[2], 'taste' => $r[3], 'line' => $r[4]];
        } elseif ($r[0] === 'M' && count($r) >= 8) {
            $rows['M'][$r[1]][$r[2]][(int)$r[3]] = ['code' => $r[1], 'course' => $r[2], 'variant' => (int)$r[3], 'item' => $r[4], 'qty' => max(1, (int)$r[5]), 'ask' => $r[6], 'note' => $r[7]];
        } elseif ($r[0] === 'B' && count($r) >= 5) {
            $rows['B'][$r[1]] = ['key' => $r[1], 'tastes' => (int)$r[2], 'title' => $r[3], 'text' => $r[4]];
        }
    }
    return $rows;
}

/** A region's menu for one tour ("Y-m"): course => M row. The variant rotates every month, (Y*12+m) % n. */
function gourmand_menu(string $code, string $tour): array
{
    [$y, $m] = array_map('intval', explode('-', $tour) + [0, 0]);
    $out = [];
    foreach (gourmand_rows()['M'][$code] ?? [] as $course => $variants) {
        ksort($variants);
        $out[$course] = array_values($variants)[($y * 12 + $m) % count($variants)];
    }
    return $out;
}

/** The camp dates of one tour for the Menu tab: the schedule's windows with their region codes and camp spots. */
function gourmand_itinerary(string $tour): array
{
    $out = [];
    foreach (gourmand_schedule($tour) as $w) {
        $code = gourmand_code($w['town']);
        $out[] = $w + ['code' => $code, 'camp' => gourmand_rows()['R'][$code]['camp'] ?? ''];
    }
    return $out;
}

/** Spoons (0-3) a quality earns on a course. */
function gourmand_spoons(string $course, int $q): int
{
    $n = 0;
    foreach (GOURMAND_BARS[$course] ?? GOURMAND_BARS['plate'] as $bar) if ($q >= $bar) $n++;
    return $n;
}

/** His verdict word for 1-3 spoons ('' for none). */
function gourmand_word(int $spoons): string
{
    return GOURMAND_WORDS[$spoons] ?? '';
}

/** The Gnomish name of a region code (NA => The Maplewold), or '' (Mossbottom has no code of its own). */
function gourmand_region_name(string $code): string
{
    static $map = null;
    if ($map === null) {
        $map = [];
        require_once __DIR__ . '/stops.php';
        foreach (stops_file_rows('regions.txt') as $r) if (count($r) >= 2) $map[$r[0]] = $r[1];
    }
    return $map[$code] ?? '';
}

/** The region code a gnome is standing in ('' in Mossbottom, where he has no courses). */
function gourmand_here(array $u): string
{
    require_once __DIR__ . '/world.php';
    $c = gourmand_code(player_location($u));
    return $c === GOURMAND_HUB_CODE ? '' : $c;
}

/** The Y-m of the tour before $tour. */
function gourmand_prev_tour(string $tour): string
{
    return (new DateTimeImmutable($tour . '-01 12:00:00', hollow_tz()))->modify('-1 month')->format('Y-m');
}

/** A teahouse rumour about this month's ask in a town ('' when he has nothing there). */
function gourmand_rumour(string $town): string
{
    $code = gourmand_code($town);
    $menu = $code !== '' ? gourmand_menu($code, hollow_date('Y-m', gourmand_now())) : [];
    if (!$menu) return '';
    $row = $menu[crc32($town . '|' . hollow_date('Y-m-d H')) % 2 ? 'jar' : 'plate'] ?? reset($menu);
    $name = (string)q_val('SELECT name FROM items WHERE slug = ?', [$row['item']]);
    return $name === '' ? '' : '“Pomeroy’s asking for ' . ($row['course'] === 'jar' ? 'a jar of ' : '') . $name . ' in ' . $town . ' this month. Bring the best you have.”';
}

/** Is his festival bonus on for this region today? (Friendship only; the gnome need not be at the camp.) */
function gourmand_festival(string $code): bool
{
    require_once __DIR__ . '/town.php';
    $name = gourmand_region_name($code);
    return $name !== '' && town_festival($name, gourmand_now()) !== null;
}

/**
 * What a dish scores, 1-100 (0 on a pot means "not scored": started before this existed). The mean quality of what goes in
 * (tracked harvest or jar quality; 50 for wild and animal goods; 35 for plain or bought), eased by the Kitchen, a little luck and a small wobble.
 * $stock is craft_stock(): slug => id, qty (per make), have. Call it before the ingredients leave the satchel.
 */
function gourmand_dish_score(array $u, array $stock): int
{
    require_once __DIR__ . '/gardens.php';
    $uid = (int)$u['id'];
    $sum = 0; $w = 0;
    foreach ($stock as $slug => $s) {
        if ((int)$s['id'] < 1) continue;
        $tracked = (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, (int)$s['id']]) > 0;
        if ($tracked) $qual = market_stack_q($uid, (int)$s['id'], (int)$s['have']);
        else {
            $cat = (string)q_val('SELECT category FROM items WHERE id = ?', [(int)$s['id']]);
            $qual = in_array($cat, ['forage', 'part'], true) || in_array((string)$slug, ['hen-egg', 'quail-egg', 'goat-milk'], true) ? 50 : MARKET_PLAIN_Q;
        }
        $sum += $qual * (int)$s['qty']; $w += (int)$s['qty'];
    }
    $ing = $w > 0 ? $sum / $w : MARKET_PLAIN_Q;
    $score = 0.8 * $ing + 4 * user_building_bonus($uid, 'kitchen')['best'] + min(4, max(0, eff_mod($u, 'luck'))) + random_int(-3, 3);
    return max(1, min(100, (int)round($score)));
}

// ---------------------------------------------------------------- the ledger

/** A gnome's ledger rows: region => course => row (plate, pot, jar; and the claim rows table, gold, finale). */
function gourmand_ledger(int $uid): array
{
    $out = [];
    foreach (q('SELECT * FROM gourmand_ledger WHERE user_id = ?', [$uid])->fetchAll() as $r) $out[(string)$r['region']][(string)$r['course']] = $r;
    return $out;
}

/** Tastes earned (regions where plate, pot and jar have all been served at a spoon or better). */
function gourmand_tastes(int $uid): int
{
    return (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course = 'table'", [$uid]);
}

/** How many regions have a Grand course (the menu rows with course grand): 8. */
function gourmand_grand_regions(): int
{
    return count(array_filter(gourmand_rows()['M'], fn($c) => isset($c['grand'])));
}

/** Journal totals: tastes x/14, spoons x/126 (3 courses in 14 regions at 3 spoons), golden tables, Grand courses x/8. */
function gourmand_progress(int $uid): array
{
    return ['tastes' => gourmand_tastes($uid), 'tastes_max' => 14,
        'spoons' => (int)q_val("SELECT COALESCE(SUM(spoons), 0) FROM gourmand_ledger WHERE user_id = ? AND course IN ('plate', 'pot', 'jar')", [$uid]), 'spoons_max' => 126,
        'gold' => (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course = 'gold'", [$uid]),
        'grand' => (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course = 'grandpay'", [$uid]), 'grand_max' => gourmand_grand_regions()];
}

/** Titles he has given this gnome (for the Almanac title picker). */
function gourmand_titles(int $uid): array
{
    $out = [];
    $p = gourmand_progress($uid);
    if ($p['tastes'] >= 1) $out[] = 'Guest of the Gourmand';
    if ($p['tastes'] >= 7) $out[] = 'Well Fed';
    if (q_val("SELECT 1 FROM gourmand_ledger WHERE user_id = ? AND region = 'ALL' AND course = 'finale'", [$uid])) $out[] = 'Second Spoon';
    if ((int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course IN ('plate', 'pot', 'jar') AND spoons >= 3", [$uid]) >= 42) $out[] = 'Golden Palate';
    $gm = gourmand_grand_regions();
    if ($gm > 0 && (int)q_val("SELECT COUNT(*) FROM gourmand_ledger WHERE user_id = ? AND course = 'grandpay'", [$uid]) >= $gm) $out[] = 'Grand Diner';
    return $out;
}

/** Claim a once-in-a-lifetime row (table, gold, grandpay, finale). True only for the request that made it. */
function gourmand_claim(int $uid, string $region, string $course): bool
{
    try { db_insert('gourmand_ledger', ['user_id' => $uid, 'region' => $region, 'course' => $course, 'paid' => 1, 'served' => 0, 'first_at' => now(), 'last_at' => now()]); }
    catch (PDOException $e) { return false; }
    return true;
}

/** The reward decoration: a silver spoon in a flowerpot. Made when first needed; not tradable, not sold anywhere (the reward-decor pattern of the Opening Day bunting). */
function gourmand_spoon_item(): int
{
    $id = (int)q_val("SELECT id FROM items WHERE slug = 'second-spoon'");
    if ($id) return $id;
    return db_insert('items', ['name' => 'Second Spoon', 'slug' => 'second-spoon', 'category' => 'decor', 'rarity' => 5, 'base_price' => 300, 'tradable' => 0,
        'description' => 'A silver spoon planted in a little terracotta pot, for the gnome who always has a seat at Pomeroy’s table.',
        'effects' => json_encode(['decor' => ['type' => 'ornament', 'w' => 1, 'h' => 1, 'icon' => '🥄', 'appeal' => 6, 'bonus' => '']], JSON_UNESCAPED_UNICODE)]);
}

// ---------------------------------------------------------------- serving

/** What a gnome would score serving this course now, for the panel: [item row, held, quality, spoons, untracked units held]. */
function gourmand_preview(int $uid, array $row): array
{
    $item = q_one('SELECT id, name FROM items WHERE slug = ?', [$row['item']]);
    if (!$item) return [null, 0, 0, 0, 0];
    $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $item['id']]);
    $q = market_stack_q($uid, (int)$item['id'], $have);
    $n = (int)q_val('SELECT n FROM item_quality WHERE user_id = ? AND item_id = ?', [$uid, $item['id']]);
    return [$item, $have, $q, gourmand_spoons((string)$row['course'], $q), max(0, $have - $n)];
}

/** Has this gnome served this course of this region's menu this tour? */
function gourmand_served_this_tour(int $uid, string $code, string $course, ?string $tour = null): bool
{
    $tour ??= hollow_date('Y-m', gourmand_now());
    return (bool)q_val('SELECT 1 FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop = ?', [$uid, gourmand_npc_id(), $tour . '|' . $code . '|' . $course]);
}

/**
 * Tell the jobs, callings and Hollow jars that a course was served: job_event('serve', region, 1, course + spoons). Called once per paid serve,
 * AFTER the commit (the ledger and the claim are the truth; a refusal never gets here). Never breaks the serve.
 */
function gourmand_fire(int $uid, string $region, string $course, int $spoons): void
{
    try {
        require_once __DIR__ . '/jobs.php';
        job_event($uid, 'serve', $region, 1, ['course' => $course, 'spoons' => $spoons, 'region' => $region]);
    } catch (Throwable $e) {
        error_log('gourmand serve event: ' . $e->getMessage());
    }
}

/**
 * Serve one course of the region you are standing in. Any day, from anywhere in the region. One serve per course per region per tour
 * (the traveller_deals claim). The user row is locked first, so two taps at once can't both pay. Returns [ok, message].
 */
function gourmand_serve(array $u, string $course): array
{
    require_once __DIR__ . '/rewards.php';
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    if (!gourmand_open()) return [false, 'Pomeroy isn’t about yet.'];
    if (is_guest_uid($uid)) return [false, 'Guests can look around, but Pomeroy only dines with gnomes of their own.'];
    if ((int)$u['level'] < GOURMAND_LEVEL) return [false, 'Pomeroy dines with gnomes from level ' . GOURMAND_LEVEL . '.'];
    $grand = $course === 'grand';
    $info = $grand ? GOURMAND_GRAND : (GOURMAND_COURSES[$course] ?? null);
    if (!$info) return [false, 'That isn’t on the menu.'];
    $code = gourmand_here($u);
    if ($code === '') return [false, 'There is no menu on the Green. Pomeroy takes his courses out in the regions (the Long Table is only a seat).'];
    $tour = hollow_date('Y-m', gourmand_now());
    $row = gourmand_menu($code, $tour)[$course] ?? null;
    $item = $row ? q_one('SELECT id, name FROM items WHERE slug = ?', [$row['item']]) : null;
    $npcId = gourmand_npc_id();
    if (!$row || !$item || !$npcId) return [false, 'That isn’t on the menu.'];
    $key = $tour . '|' . $code . '|' . $course;
    if ($grand) {
        require_once __DIR__ . '/gardens.php';
        if (user_building_bonus($uid, 'kitchen')['best'] < 3) return [false, 'A feast needs a Kitchen at level III. Pomeroy will wait.'];
    }
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);   // lock this gnome, then re-read what is held
    if ($grand && !q_val("SELECT 1 FROM gourmand_ledger WHERE user_id = ? AND region = ? AND course = 'table'", [$uid, $code])) {
        db()->rollBack();
        return [false, 'Pomeroy wants a Taste of ' . gourmand_region_name($code) . ' before he sits down to a feast. Serve him a plate, a pot and a jar here first.'];
    }
    $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $item['id']]);
    if ($have < (int)$row['qty']) {
        db()->rollBack();
        return [false, 'Pomeroy asked for ' . (int)$row['qty'] . ' × ' . $item['name'] . '. You have ' . $have . '.'];
    }
    $quality = market_stack_q($uid, (int)$item['id'], $have);
    $spoons = gourmand_spoons($course, $quality);
    if ($spoons < 1) {
        db()->rollBack();
        return [false, '“I can taste the shop counter.” Your ' . $item['name'] . ' scored ' . $quality . ', not enough for a spoon. Nothing was taken. A fresh harvest or a home-made dish scores higher.'];
    }
    try {
        db_insert('traveller_deals', ['user_id' => $uid, 'npc_id' => $npcId, 'stop' => $key, 'at' => now()]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'Already served this month. Pomeroy has had his ' . strtolower($info[1]) . ' from you. Come back next month.'];
    }
    if (!give_item($uid, (int)$item['id'], -(int)$row['qty'])) {
        db()->rollBack();
        return [false, 'Something changed while you were setting the table. Nothing was taken.'];
    }
    // The ledger: best quality, best spoons, how many levels have been paid
    $L = q_one('SELECT * FROM gourmand_ledger WHERE user_id = ? AND region = ? AND course = ?', [$uid, $code, $course]);
    $paid = $L ? (int)$L['paid'] : 0;
    $first = !$L;
    $petals = 0; $xp = 0; $lines = [];
    if (!$L) db_insert('gourmand_ledger', ['user_id' => $uid, 'region' => $code, 'course' => $course, 'best_q' => $quality, 'spoons' => $spoons, 'paid' => 0, 'served' => 1, 'first_at' => now(), 'last_at' => now()]);
    else q('UPDATE gourmand_ledger SET best_q = ?, spoons = ?, served = served + 1, last_at = ? WHERE user_id = ? AND region = ? AND course = ?',
        [max($quality, (int)$L['best_q']), max($spoons, (int)$L['spoons']), now(), $uid, $code, $course]);
    $fest = gourmand_festival($code);
    if ($grand && gourmand_claim($uid, $code, 'grandpay')) {   // the feast pays once per region, however many spoons; later months tip
        $petals += GOURMAND_GRAND_PAY[0]; $xp += GOURMAND_GRAND_PAY[1];
        q('UPDATE gourmand_ledger SET paid = ? WHERE user_id = ? AND region = ? AND course = ?', [$spoons, $uid, $code, $course]);
        $lines[] = '🍽️ The feast of ' . gourmand_region_name($code) . ': a gold spoon on your journal card.';
        if (gourmand_progress($uid)['grand'] >= gourmand_grand_regions()) $lines[] = 'All the feasts eaten: the title “Grand Diner”';
    } elseif ($spoons > $paid && !$grand) {
        for ($l = $paid + 1; $l <= $spoons; $l++) { $petals += GOURMAND_FIRST[$l][0]; $xp += GOURMAND_FIRST[$l][1]; }
        q('UPDATE gourmand_ledger SET paid = ? WHERE user_id = ? AND region = ? AND course = ?', [$spoons, $uid, $code, $course]);
        $lines[] = '🥄 ' . ($paid === 0 ? 'First ' : 'New ') . 'spoons on this course!';
    } else {
        $petals += GOURMAND_TIP[0]; $xp += GOURMAND_TIP[1] * ($fest ? 2 : 1);
        $lines[] = 'A tip for a familiar face.';
    }
    // A Taste: plate, pot and jar all at a spoon or better. A Golden table: all three at three spoons.
    $three = q("SELECT spoons FROM gourmand_ledger WHERE user_id = ? AND region = ? AND course IN ('plate', 'pot', 'jar')", [$uid, $code])->fetchAll(PDO::FETCH_COLUMN);
    $tastesBefore = gourmand_tastes($uid);
    if (count($three) === 3 && min(array_map('intval', $three)) >= 1 && gourmand_claim($uid, $code, 'table')) {
        $petals += GOURMAND_TABLE;
        $crop = (string)(gourmand_rows()['M'][$code]['plate'][1]['item'] ?? '');
        $seed = $crop !== '' ? q_one('SELECT id, name FROM items WHERE slug = ?', [$crop . '-seed']) : null;
        if ($seed) { give_item($uid, (int)$seed['id'], 2); $lines[] = '+2 × ' . $seed['name']; }
        $lines[] = '🍽️ A full table: ' . (gourmand_rows()['R'][$code]['taste'] ?? 'a Taste') . '! Pomeroy has one of his fourteen tastes back.';
    }
    if (count($three) === 3 && min(array_map('intval', $three)) >= 3 && gourmand_claim($uid, $code, 'gold')) {
        $petals += GOURMAND_GOLD;
        $gs = q_one('SELECT id, name FROM items WHERE slug = ?', [GOURMAND_GOLD_SEEDS[$code] ?? '']);
        if ($gs) { give_item($uid, (int)$gs['id'], 1); $lines[] = '+1 × ' . $gs['name']; }
        $lines[] = '🏅 A golden table: three splendid courses in one region.';
    }
    $fp = ($spoons === 3 ? 10 : 5) * ($fest ? 2 : 1);
    friend_add($uid, $npcId, $fp);
    if ($petals > 0) give_petals($uid, $petals, 'gourmand');
    if ($xp > 0) give_xp($uid, $xp, 'Gourmand');
    db()->commit();
    gourmand_fire($uid, $code, $course, $spoons);
    $tastes = gourmand_tastes($uid);
    if ($tastes >= 14 && $tastesBefore < 14) {
        $_SESSION['gourmand_hold'] = 1;   // the finale waits for the next meeting
        $lines[] = 'Come back and sit down. I have something for you.';
    }
    $head = array_filter([$petals ? '+' . money($petals) : '', $xp ? '+' . $xp . ' XP' : '', '💛 +' . $fp . ' with Pomeroy' . ($fest ? ' (festival day: doubled)' : '')]);
    $note = $first ? (string)$row['note'] : '';
    prize('🥄', 'Pomeroy tucks in his napkin, lifts his spoon…', str_repeat('🥄', $spoons) . ' ' . gourmand_word($spoons),
        array_merge($note !== '' ? ['“' . $note . '”'] : [], $spoons === 3 ? ['He dozes off mid-compliment. Then: “…as I was saying: splendid.”'] : [], $head, $lines));
    return [true, 'Pomeroy ate your ' . $item['name'] . ': ' . str_repeat('🥄', $spoons) . ' (' . gourmand_word($spoons) . ').'];
}

/** Day 1 at the Long Table: a seat for a gnome who served 7+ courses last tour. A seat only, no board. Returns [ok, message]. */
function gourmand_seat(array $u): array
{
    require_once __DIR__ . '/rewards.php';
    require_once __DIR__ . '/events.php';
    $uid = (int)$u['id'];
    if (!gourmand_open()) return [false, 'Pomeroy isn’t about yet.'];
    if (is_guest_uid($uid)) return [false, 'Guests can look around, but Pomeroy only dines with gnomes of their own.'];
    if (!gourmand_stop()['long_table']) return [false, 'The Long Table is only laid on the first of the month.'];
    $prev = gourmand_prev_tour(hollow_date('Y-m', gourmand_now()));
    $npcId = gourmand_npc_id();
    if (!$npcId) return [false, 'Pomeroy isn’t about yet.'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    $n = (int)q_val("SELECT COUNT(*) FROM traveller_deals WHERE user_id = ? AND npc_id = ? AND stop LIKE ? AND stop <> ?", [$uid, $npcId, $prev . '|%', $prev . '|LT|seat']);
    if ($n < GOURMAND_SEAT_MIN) {
        db()->rollBack();
        return [false, 'Pomeroy keeps the Long Table for gnomes who fed him last month: ' . GOURMAND_SEAT_MIN . ' courses or more. You served ' . $n . '.'];
    }
    try { db_insert('traveller_deals', ['user_id' => $uid, 'npc_id' => $npcId, 'stop' => $prev . '|LT|seat', 'at' => now()]); }
    catch (PDOException $e) {
        db()->rollBack();
        return [false, 'You have already taken your seat this month.'];
    }
    give_petals($uid, 50, 'gourmand');
    $fx = apply_event_effect($u, 'tbuff:charm:2:240');
    db()->commit();
    prize('🥄', 'A seat at the Long Table', '“Sit, sit. There’s always a second spoon at this table.”', array_merge(['+' . money(50)], $fx));
    return [true, 'You take your seat at the Long Table.'];
}

// ---------------------------------------------------------------- the Home Plate

/** The region code of a gnome's home village ('' if none). */
function gourmand_home_code(array $u): string
{
    $hv = (int)($u['home_village_id'] ?? 0);
    $town = $hv ? (string)q_val('SELECT region FROM locations WHERE id = ?', [$hv]) : '';
    $c = $town !== '' ? gourmand_code($town) : '';
    return $c === GOURMAND_HUB_CODE ? '' : $c;
}

/** Has the Home Plate been eaten? */
function gourmand_home_done(int $uid): bool
{
    return (bool)q_val("SELECT 1 FROM gourmand_ledger WHERE user_id = ? AND region = 'HOME' AND course = 'home'", [$uid]);
}

/** Is this item slug a Pot dish (a snack or meal recipe) that uses a crop from the home region? Returns the recipe's name or null. */
function gourmand_home_dish(string $homeCode, string $slug): ?string
{
    $rec = q_one("SELECT r.ingredients, i.name FROM recipes r JOIN items i ON i.id = r.output_item_id WHERE i.slug = ? AND r.tier IN ('snack', 'meal')", [$slug]);
    if (!$rec || $homeCode === '') return null;
    $crops = array_column(q("SELECT DISTINCT it.slug FROM plant_regions pr JOIN regions rg ON rg.id = pr.region_id JOIN plants p ON p.id = pr.plant_id JOIN items it ON it.id = p.produce_item_id
                             WHERE rg.code = ?", [$homeCode])->fetchAll(), 'slug');
    foreach (array_keys(json_decode((string)$rec['ingredients'], true) ?: []) as $ing) {
        if (in_array((string)$ing, $crops, true)) return (string)$rec['name'];
    }
    return null;
}

/** The Pot dishes in the satchel that would do for the Home Plate: [slug, name, held, quality, spoons]. */
function gourmand_home_options(array $u): array
{
    $uid = (int)$u['id']; $home = gourmand_home_code($u); $out = [];
    if ($home === '') return $out;
    foreach (q("SELECT it.slug, it.name, ui.qty, it.id FROM user_items ui JOIN items it ON it.id = ui.item_id JOIN recipes r ON r.output_item_id = it.id
                WHERE ui.user_id = ? AND ui.qty > 0 AND r.tier IN ('snack', 'meal') ORDER BY it.name", [$uid])->fetchAll() as $r) {
        if (gourmand_home_dish($home, (string)$r['slug']) === null) continue;
        $qq = market_stack_q($uid, (int)$r['id'], (int)$r['qty']);
        $out[] = ['slug' => (string)$r['slug'], 'name' => (string)$r['name'], 'held' => (int)$r['qty'], 'q' => $qq, 'spoons' => gourmand_spoons('pot', $qq)];
    }
    return $out;
}

/**
 * Serve the Home Plate: one Pot dish that uses a crop from your home region, at 2 spoons or better, from anywhere. Once in a lifetime
 * (the HOME/home ledger row is the claim; the user row is locked first, as in gourmand_serve). Returns [ok, message].
 */
function gourmand_serve_home(array $u, string $slug): array
{
    require_once __DIR__ . '/rewards.php';
    require_once __DIR__ . '/friends.php';
    $uid = (int)$u['id'];
    if (!gourmand_open()) return [false, 'Pomeroy isn’t about yet.'];
    if (is_guest_uid($uid)) return [false, 'Guests can look around, but Pomeroy only dines with gnomes of their own.'];
    if ((int)$u['level'] < GOURMAND_LEVEL) return [false, 'Pomeroy dines with gnomes from level ' . GOURMAND_LEVEL . '.'];
    if (gourmand_tastes($uid) < GOURMAND_HOME_TASTES) return [false, 'Pomeroy will ask for the cooking of your home after ' . GOURMAND_HOME_TASTES . ' Tastes.'];
    $home = gourmand_home_code($u);
    if ($home === '') return [false, 'You have no home village to cook for.'];
    $npcId = gourmand_npc_id();
    $item = q_one('SELECT id, name FROM items WHERE slug = ?', [$slug]);
    if (!$npcId || !$item) return [false, 'That isn’t a dish.'];
    if (gourmand_home_dish($home, $slug) === null) return [false, 'Pomeroy wants a cooked dish made with a crop of ' . gourmand_region_name($home) . '. ' . $item['name'] . ' isn’t one.'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (gourmand_home_done($uid)) {
        db()->rollBack();
        return [false, 'You have already shown Pomeroy the cooking of your home.'];
    }
    $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $item['id']]);
    if ($have < 1) {
        db()->rollBack();
        return [false, 'You aren’t holding a ' . $item['name'] . '.'];
    }
    $quality = market_stack_q($uid, (int)$item['id'], $have);
    $spoons = gourmand_spoons('pot', $quality);
    if ($spoons < 2) {
        db()->rollBack();
        return [false, '“Not quite moved.” Your ' . $item['name'] . ' scored ' . $quality . '; the Home Plate needs ' . GOURMAND_BARS['pot'][1] . ' for two spoons. Nothing was taken.'];
    }
    try {
        db_insert('gourmand_ledger', ['user_id' => $uid, 'region' => 'HOME', 'course' => 'home', 'best_q' => $quality, 'spoons' => $spoons, 'paid' => 1, 'served' => 1, 'first_at' => now(), 'last_at' => now()]);
    } catch (PDOException $e) {
        db()->rollBack();
        return [false, 'You have already shown Pomeroy the cooking of your home.'];
    }
    if (!give_item($uid, (int)$item['id'], -1)) {
        db()->rollBack();
        return [false, 'Something changed while you were setting the table. Nothing was taken.'];
    }
    give_petals($uid, GOURMAND_HOME_PAY[0], 'gourmand');
    give_xp($uid, GOURMAND_HOME_PAY[1], 'Gourmand');
    friend_add($uid, $npcId, 10);
    db()->commit();
    gourmand_fire($uid, $home, 'home', $spoons);
    prize('🥄', 'The Home Plate', str_repeat('🥄', $spoons) . ' ' . gourmand_word($spoons),
        ['“I tasted ' . gourmand_region_name($home) . ' in that. I think I tasted home.”', '+' . money(GOURMAND_HOME_PAY[0]), '+' . GOURMAND_HOME_PAY[1] . ' XP', '💛 +10 with Pomeroy']);
    return [true, 'Pomeroy ate your ' . $item['name'] . ': ' . str_repeat('🥄', $spoons) . ' (' . gourmand_word($spoons) . '). The Home Plate is done.'];
}

// ---------------------------------------------------------------- the story

/**
 * The beats unlocked so far, in order of play (hello, first, four, mid, home, finale; the Home Plate beat shows at 10 Tastes).
 * Plays the finale once, at the first meeting after the 14th Taste: the first load of his page or his folk card. Returns [beat rows].
 */
function gourmand_beats(array $u): array
{
    $uid = (int)$u['id'];
    $tastes = gourmand_tastes($uid);
    if ($tastes >= 14 && !is_guest_uid($uid)) {
        if (!empty($_SESSION['gourmand_hold'])) unset($_SESSION['gourmand_hold']);   // the page we land on straight after the last serve: let him finish his napkin first
        else gourmand_finale($u);
    }
    $finale = (bool)q_val("SELECT 1 FROM gourmand_ledger WHERE user_id = ? AND region = 'ALL' AND course = 'finale'", [$uid]);
    $out = [];
    foreach (gourmand_rows()['B'] as $b) {
        if ($b['key'] === 'finale' ? !$finale : $tastes < $b['tastes']) continue;
        $out[] = $b;
    }
    return $out;
}

/** The finale: once per gnome. 1,000 Petals, the Second Spoon decoration and the title. */
function gourmand_finale(array $u): bool
{
    require_once __DIR__ . '/rewards.php';
    $uid = (int)$u['id'];
    db()->beginTransaction();
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if (!gourmand_claim($uid, 'ALL', 'finale')) {
        db()->rollBack();
        return false;
    }
    give_petals($uid, GOURMAND_FINALE, 'gourmand');
    give_item($uid, gourmand_spoon_item(), 1);
    db()->commit();
    $b = gourmand_rows()['B']['finale'] ?? null;
    prize('🥄', 'Pomeroy cooks for you', $b ? str_replace('{gnome}', (string)($u['gnome_name'] ?: $u['username']), $b['text']) : '“It tastes of company.”',
        ['+' . money(GOURMAND_FINALE), '+1 × Second Spoon', 'The title “Second Spoon”']);
    return true;
}

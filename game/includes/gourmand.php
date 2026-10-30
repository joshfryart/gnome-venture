<?php
declare(strict_types=1);

// The Gourmand (Pomeroy Crumbworth): the camp schedule, the data file and the spoon bars. Pure functions only so far; nothing here is wired to a page yet.
// Data: includes/data/gourmand.txt (R region rows, M menu rows, B story beats). The schedule follows TOWN_FESTIVALS (town.php), in Hollow time.

const GOURMAND_HUB_CODE = 'MB';   // Mossbottom has no region code of its own
const GOURMAND_BARS = [   // spoon bars: 🥄, 🥄🥄, 🥄🥄🥄
    'plate' => [40, 50, 65], 'pot' => [40, 50, 65], 'grand' => [40, 50, 65],
    'jar' => [45, 52, 62],
];
const GOURMAND_WORDS = [1 => 'Honest', 2 => 'Seconds, please', 3 => 'Splendid'];   // not fair_word(): 62 is "Fine" there

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

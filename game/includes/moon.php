<?php
declare(strict_types=1);
/**
 * The moon and the tides (2.7.01, Josh 2026-11-15). One lunar month = 28 game days (two seasons), counted from the game day index, so it is the same for everybody
 * and the same on every page. Phases: new (age 0), full (age 14). The tide follows the moon: 54 tides a month (12.44 h apart, so each day the tides come about 53 minutes
 * later), SPRING tides (new and full moon: the biggest highs and lowest lows) and NEAP tides (the quarters: small ones, the pools barely open).
 * moon_phase(dayIndex), moon_tide(hour, dayIndex). Conditions: `mo=new,full,...` in the Sights grammar (trail_sight_cond_ok).
 */

const MOON_DAYS = 28;
const MOON_PHASES = [   // key => [icon, name]
    'new' => ['🌑', 'New moon'], 'waxing-crescent' => ['🌒', 'Waxing crescent'], 'first-quarter' => ['🌓', 'First quarter'], 'waxing-gibbous' => ['🌔', 'Waxing gibbous'],
    'full' => ['🌕', 'Full moon'], 'waning-gibbous' => ['🌖', 'Waning gibbous'], 'last-quarter' => ['🌗', 'Last quarter'], 'waning-crescent' => ['🌘', 'Waning crescent'],
];
const MOON_TIDE_PERIOD = 24.0 * MOON_DAYS / 54;   // hours between a high and the next high
const MOON_TIDE_HIGH0 = 0.5;                       // hour of the first high on a new-moon day
const MOON_LOW = -0.5;                             // the water at or below this is low tide; at or above -MOON_LOW high

/** The phase on a game day: ['age' 0-27, 'key', 'icon', 'name', 'light' 0..1 (how much of the disc is lit), 'range' 'spring'|'neap'|'mid' (the size of the tides), 'amp' tide height 0.62..1]. */
function moon_phase(int $dayIndex): array
{
    $age = (($dayIndex % MOON_DAYS) + MOON_DAYS) % MOON_DAYS;
    $key = match (true) {
        $age === 0 || $age === 27 || $age === 1 => 'new', $age <= 5 => 'waxing-crescent', $age <= 8 => 'first-quarter', $age <= 12 => 'waxing-gibbous',
        $age <= 15 => 'full', $age <= 19 => 'waning-gibbous', $age <= 22 => 'last-quarter', default => 'waning-crescent',
    };
    $c = cos(4 * M_PI * $age / MOON_DAYS);   // 1 at new and full, -1 at the quarters
    return ['age' => $age, 'key' => $key, 'icon' => MOON_PHASES[$key][0], 'name' => MOON_PHASES[$key][1], 'light' => (1 - cos(2 * M_PI * $age / MOON_DAYS)) / 2,
        'range' => $c > 0.5 ? 'spring' : ($c < -0.5 ? 'neap' : 'mid'), 'amp' => 0.62 + 0.38 * ($c + 1) / 2];
}

/** The water level (-1 low .. 1 high) at an hour of a game day. Continuous over midnight (the month is exactly 54 tides long). */
function moon_level(float $hour, int $dayIndex): float
{
    $age = (($dayIndex % MOON_DAYS) + MOON_DAYS) % MOON_DAYS;
    $t = $age * 24.0 + $hour;
    $amp = 0.62 + 0.38 * (cos(4 * M_PI * ($age + $hour / 24.0) / MOON_DAYS) + 1) / 2;   // the size of the tide changes smoothly through the day too
    return $amp * cos(2 * M_PI * ($t - MOON_TIDE_HIGH0) / MOON_TIDE_PERIOD);
}

/**
 * The tide at a clock hour: ['h' water level -1..1, 'state' low|rising|high|falling, 'next' 'low'|'high', 'in' whole hours to the next low or high (or to the turn when it is low / high now),
 * 'text', 'lows' => [hours of the day when the water is lowest], 'highs' => [...] (1 or 2 each: the tides drift a day round the clock over the month), 'moon' => moon_phase, 'range'].
 */
function moon_tide(float $hour, int $dayIndex): array
{
    $ph = moon_phase($dayIndex);
    $h = moon_level($hour, $dayIndex);
    $low = $h <= MOON_LOW; $high = $h >= -MOON_LOW;
    $eps = 0.05;
    $falling = moon_level($hour + $eps, $dayIndex) < $h;
    $state = $low ? 'low' : ($high ? 'high' : ($falling ? 'falling' : 'rising'));
    $want = ($state === 'high' || $state === 'falling') ? 'low' : 'high';
    // a neap low may never get under MOON_LOW: then "low" for the story is the day's lowest water, but the pools stay shut (state stays rising / falling)
    $in = 0;
    for ($i = 1; $i <= 400; $i++) {
        $lv = moon_level($hour + $i / 10.0, $dayIndex);
        if (($state === 'low' && $lv > MOON_LOW) || ($state === 'high' && $lv < -MOON_LOW)) { $in = (int)ceil($i / 10.0 - 1e-9); break; }
        if ($state !== 'low' && $state !== 'high' && (($want === 'low' && $lv <= MOON_LOW) || ($want === 'high' && $lv >= -MOON_LOW))) { $in = (int)ceil($i / 10.0 - 1e-9); break; }
    }
    $text = $state === 'low' ? 'Low tide now, turning in ' . $in . ' h' : ($state === 'high' ? 'High tide now, turning in ' . $in . ' h' : ucfirst($want) . ' tide in ' . ($in ?: '?') . ' h');
    $lows = $highs = [];
    for ($m = 1; $m < 240; $m++) {   // the turning points of the day, every 6 minutes
        $a = moon_level(($m - 1) / 10.0, $dayIndex); $b = moon_level($m / 10.0, $dayIndex); $c = moon_level(($m + 1) / 10.0, $dayIndex);
        if ($b < $a && $b <= $c) $lows[] = round($m / 10.0, 1);
        if ($b > $a && $b >= $c) $highs[] = round($m / 10.0, 1);
    }
    return ['h' => $h, 'state' => $state, 'next' => $want, 'in' => $in, 'text' => $text, 'lows' => $lows, 'highs' => $highs, 'moon' => $ph, 'range' => $ph['range']];
}

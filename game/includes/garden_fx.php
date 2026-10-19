<?php
declare(strict_types=1);

/**
 * v1.0.0 wave 2a: the garden feels the Hollow. Crop seasons, weather in the garden, pests and companion planting.
 * Lazy and cosy by design: worked out when a garden is viewed (no cron), every number is a setting, and nothing here
 * ever kills a crop or ruins a harvest. The worst case is a slow day or a small dip in yield.
 *
 *   crop seasons   in season grows faster and gives a little more; out of season slower (never stopped); blank = all year; greenhouse ignores it
 *   weather        the garden's own region: rain waters the beds, storms lean tall crops, frost slows tender ones (mulch / greenhouse protect),
 *                  heat dries a watering faster (rain barrel helps), wind spreads weeds, fog does little
 *   pests          aphids, slugs and snails, gnats, caterpillars: a light puzzle per bed. Handle by hand, companions, hedges, birds, ladybirds, frogs
 */

require_once __DIR__ . '/garden_world.php';

function gfx_on(): bool
{
    return setting('garden_fx_on') !== '0';
}

// ----------------------------------------------------------------- Seasons and weather

/** The region code of a garden (null if it has none). */
function garden_region_code(int $plotId): ?string
{
    static $c = [];
    if (!array_key_exists($plotId, $c)) {
        $code = (string)q_val('SELECT r.code FROM plots p JOIN regions r ON r.id = p.region_id WHERE p.id = ?', [$plotId]);
        $c[$plotId] = $code !== '' ? $code : null;
    }
    return $c[$plotId];
}

/** The weather in a garden's region on a Hollow date (null = today). */
function garden_weather_on(int $plotId, ?string $date = null): string
{
    return hollow_weather(garden_region_code($plotId), $date);
}

/** Weather traits of a plant row: ['tender', 'tall']. */
function plant_traits(array $p): array
{
    return array_values(array_filter(array_map('trim', explode(',', strtolower((string)($p['traits'] ?? ''))))));
}

/** 'in' | 'off' | 'any' for a plant on a date. Blank seasons and greenhouses are 'any'. */
function plant_season_state(array $p, string $date, bool $greenhouse = false): string
{
    $s = trim((string)($p['seasons'] ?? ''));
    if ($greenhouse || $s === '' || $s === '*') return 'any';
    return hollow_in_season($s, $date) ? 'in' : 'off';
}

/** The little "in season" / "off season" chip for seed shelves, the seed picker and plant cards. '' for crops that grow all year. */
function season_chip(array $p, bool $greenhouse = false): string
{
    if (!gfx_on()) return '';
    $st = plant_season_state($p, hollow_today(), $greenhouse);
    if ($st === 'in') return '<span class="chip chip-in" title="In season: grows faster and gives a little more right now">🌿 in season</span>';
    if ($st === 'off') return '<span class="chip chip-off" title="Off season: grows slower, but it never stops">🍂 off season</span>';
    return '';
}

/** Plain-text version for places that can't show HTML (picker info lines). */
function season_chip_text(array $p, bool $greenhouse = false): string
{
    if (!gfx_on()) return '';
    $st = plant_season_state($p, hollow_today(), $greenhouse);
    return $st === 'in' ? '🌿 in season' : ($st === 'off' ? '🍂 off season' : '');
}

/** What a day's season and weather do to one growing crop: speed multiplier, whether rain waters it, whether frost nips it. */
function garden_day_fx(array $t, array $p, string $date): array
{
    $fx = ['speed' => 1.0, 'wet' => false, 'nip' => false, 'season' => 'any', 'weather' => 'sun'];
    if (!gfx_on()) return $fx;
    $plot = (int)$t['plot_id'];
    $gh = building_level($plot, 'greenhouse') > 0;
    $fx['season'] = plant_season_state($p, $date, $gh);
    if ($fx['season'] === 'in') $fx['speed'] *= max(0.5, (int)setting('season_in_speed') / 100);
    elseif ($fx['season'] === 'off') $fx['speed'] *= max(0.1, (int)setting('season_off_speed') / 100);
    $w = $fx['weather'] = garden_weather_on($plot, $date);
    if (setting('rain_waters') !== '0' && ($w === 'rain' || $w === 'storm')) $fx['wet'] = true;
    if (!$gh) {
        $tr = plant_traits($p);
        if ($w === 'storm' && in_array('tall', $tr, true) && empty($t['_hedge'])) $fx['speed'] *= 1 - max(0, min(90, (int)setting('storm_slow_pct'))) / 100;
        if (($w === 'frost' || $w === 'snow') && in_array('tender', $tr, true) && (int)($t['mulch'] ?? 0) <= 0) {
            $slow = max(0, min(90, (int)setting('frost_slow_pct'))) / 100;
            $fx['speed'] *= 1 - ($w === 'snow' ? $slow / 2 : $slow);
            if ($w === 'frost') $fx['nip'] = true;
        }
    }
    return $fx;
}

/** Midnight (the Hollow's) after a timestamp. */
function garden_next_midnight(int $ts): int
{
    return (new DateTimeImmutable('@' . $ts))->setTimezone(hollow_tz())->setTime(0, 0)->modify('+1 day')->getTimestamp();
}

/**
 * Growth seconds earned between $from and $at, day by day: wet seconds (a watering, or a rainy day) times the soil speed,
 * the day's season and weather, and any pest. Returns [seconds, nipped by frost].
 */
function garden_grow_gain(array $t, array $p, int $from, int $at, int $wetUntil): array
{
    $base = soil_speed($t);
    $slowPest = !empty($t['pest']) ? max(0, min(90, (int)setting('pest_slow_pct'))) / 100 : 0.0;
    $pestAt = !empty($t['pest_at']) ? ts($t['pest_at']) : 0;
    $gain = 0.0;
    $nip = false;
    $cur = $from;
    $n = 0;
    while ($cur < $at) {
        if ($n++ >= 45) {   // a very long way back: finish plainly
            $gain += max(0, min($at, $wetUntil) - $cur) * $base;
            break;
        }
        $segEnd = min($at, garden_next_midnight($cur));
        if ($segEnd <= $cur) $segEnd = $at;
        $len = $segEnd - $cur;
        $fx = garden_day_fx($t, $p, hollow_date('Y-m-d', $cur));
        $wet = $fx['wet'] ? $len : max(0, min($segEnd, $wetUntil) - $cur);
        $mult = $fx['speed'];
        if ($slowPest > 0 && $pestAt < $segEnd) $mult *= 1 - $slowPest * (($segEnd - max($cur, $pestAt)) / $len);
        $gain += $wet * $base * $mult;
        if ($fx['nip'] && $wet > 0) $nip = true;
        $cur = $segEnd;
    }
    return [(int)$gain, $nip];
}

/** The pest multiplier on growth right now (1 = none). */
function garden_pest_factor(array $t): float
{
    return !empty($t['pest']) ? 1 - max(0, min(90, (int)setting('pest_slow_pct'))) / 100 : 1.0;
}

/** How much shorter a watering lasts today (heat dries beds; a rain barrel halves it). 1 = normal. */
function garden_water_mult(array $t): float
{
    if (!gfx_on() || empty($t['plot_id'])) return 1.0;
    $plot = (int)$t['plot_id'];
    if (building_level($plot, 'greenhouse') > 0) return 1.0;
    if (garden_weather_on($plot) !== 'heat') return 1.0;
    $pen = max(0, min(80, (int)setting('heat_dry_pct'))) / 100;
    if (!empty($t['_barrel']) || !empty($t['_rain']) || building_level($plot, 'rain_barrel') > 0) $pen /= 2;
    return 1 - $pen;
}

/** Windy hours make weeds grow faster: shorter weed period (>= 1) for a no-till bed hour. */
function garden_wind_weeds(int $plotId, int $ts, int $period): int
{
    static $cache = [];
    if (!gfx_on()) return $period;
    $boost = max(0, (int)setting('wind_weed_pct'));
    if ($boost <= 0) return $period;
    $key = $plotId . '|' . intdiv($ts + 43200, 86400);   // close enough to a day: wind is a mild effect
    if (!isset($cache[$key])) $cache[$key] = garden_weather_on($plotId, hollow_date('Y-m-d', $ts)) === 'wind';
    return $cache[$key] ? max(1, (int)round($period * 100 / (100 + $boost))) : $period;
}

/** Scale a harvest by a percent (can be negative) with a fair dice roll for the fraction. */
function garden_pct_qty(int $qty, int $pct): int
{
    if ($pct === 0) return $qty;
    $x = $qty * (100 + $pct) / 100;
    $whole = (int)floor($x);
    return max(1, $whole + (random_int(1, 10000) <= (int)round(($x - $whole) * 10000) ? 1 : 0));
}

/** The harvest after the season and any frost nip. Adds a line to $msgs when it changed. */
function garden_yield_adjust(int $qty, array $t, array $p, array &$msgs): int
{
    if (!gfx_on() || $qty < 1) return $qty;
    $gh = building_level((int)$t['plot_id'], 'greenhouse') > 0;
    $pct = 0;
    $in = plant_season_state($p, hollow_today(), $gh) === 'in';
    if ($in) $pct += max(0, (int)setting('season_in_yield'));
    $nip = !empty($t['nipped']) && !$gh;
    if ($nip) $pct -= max(0, (int)setting('frost_yield_pct'));
    $new = garden_pct_qty($qty, $pct);
    if ($new > $qty) $msgs[] = '🌿 In season: +' . ($new - $qty) . '.';
    elseif ($new < $qty) $msgs[] = '🥶 A frost nipped it: ' . ($qty - $new) . ' fewer.';
    elseif ($nip) $msgs[] = '🥶 A frost nipped it, but you still got the full harvest.';
    return $new;
}

/** One line for the garden page: what today's weather does to this garden. [emoji + label, sentence, severity class] */
function garden_weather_note(int $plotId, array $tiles, array $plants): array
{
    $w = garden_weather_on($plotId);
    $now = hollow_now(garden_region_code($plotId));
    $head = $now['weather_emoji'] . ' ' . $now['weather_label'];
    if (!gfx_on()) return [$head, 'The weather is just for show in this garden today.', 'calm'];
    $gh = building_level($plotId, 'greenhouse') > 0;
    $tall = $tender = $exposed = 0;
    foreach ($tiles as $row) foreach ($row as $t) {
        if (empty($t['plant_id']) || !isset($plants[(int)$t['plant_id']])) continue;
        $tr = plant_traits($plants[(int)$t['plant_id']]);
        if (in_array('tall', $tr, true) && empty($t['_hedge'])) $tall++;
        if (in_array('tender', $tr, true)) { $tender++; if ((int)$t['mulch'] <= 0) $exposed++; }
    }
    $sh = $gh ? ' Your greenhouse keeps the harsh weather off.' : '';
    switch ($w) {
        case 'rain': return [$head, 'Rain waters every bed for you today. Skip the watering can.', 'good'];
        case 'storm':
            return [$head, 'Rain waters every bed for you' . ($gh ? '.' : ', but the wind leans tall crops over' . ($tall ? ' (' . $tall . ' of yours: slower today)' : '') . ' — nothing is hurt.') . $sh, 'warn'];
        case 'frost':
            if ($gh) return [$head, 'Frost outside, but your greenhouse keeps every crop snug.', 'good'];
            return [$head, $tender ? 'Frost slows tender crops and may nip them' . ($exposed ? ': ' . $exposed . ' of yours are exposed. Mulch protects a bed.' : ', but all of yours are mulched. Snug.') : 'A sharp frost, but none of your crops are tender.', $exposed ? 'warn' : 'good'];
        case 'snow':
            return [$head, $gh ? 'Soft snow outside; the greenhouse stays cosy.' : ($exposed ? 'Snow slows tender crops a little (' . $exposed . ' exposed). Mulch protects a bed.' : 'Snow settles over the garden. Nothing to worry about.'), $exposed ? 'warn' : 'calm'];
        case 'heat':
            return [$head, $gh ? 'Hot outside; the greenhouse vents keep things comfortable.' : 'Heat dries beds faster: each watering lasts ' . (int)round(max(0, min(80, (int)setting('heat_dry_pct'))) * (building_level($plotId, 'rain_barrel') > 0 ? 0.5 : 1)) . '% shorter today' . (building_level($plotId, 'rain_barrel') > 0 ? ' (your rain barrel helps)' : ' (a rain barrel halves that)') . '.', 'warn'];
        case 'wind': return [$head, 'Wind carries weed seed: no-till beds grow weeds a little faster today.', 'calm'];
        case 'fog': return [$head, 'Fog does very little to crops. Slugs and snails like it, though.', 'calm'];
        case 'cloud': return [$head, 'Mild grey skies. Plain growing weather.', 'calm'];
        default: return [$head, 'A good day for the garden. Nothing special to worry about.', 'good'];
    }
}

// ----------------------------------------------------------------- Pests and companions

/** Pest kinds from the data table: slug => def (weights parsed). */
function pest_defs(bool $reset = false): array
{
    static $defs = null;
    if ($defs === null || $reset) {
        $defs = [];
        foreach (q('SELECT * FROM pest_kinds WHERE active = 1 ORDER BY id')->fetchAll() as $r) {
            $sw = array_map('floatval', explode(',', (string)$r['season_w']));
            $sw = array_pad($sw, 4, 1.0);
            $r['sw'] = array_map(fn($x) => max(0.0, $x), array_slice($sw, 0, 4));
            $r['ww'] = hollow_parse_weights((string)$r['weather_w'], HOLLOW_WEATHER);
            $r['kindlist'] = array_values(array_filter(array_map('trim', explode(',', (string)$r['kinds']))));
            $defs[(string)$r['slug']] = $r;
        }
    }
    return $defs;
}

/** Companion plants from the data table: plant slug => ['pests' => [...], 'helps' => [...], 'about']. */
function companion_defs(bool $reset = false): array
{
    static $defs = null;
    if ($defs === null || $reset) {
        $defs = [];
        foreach (q('SELECT * FROM companion_plants')->fetchAll() as $r) {
            $defs[(string)$r['plant_slug']] = [
                'pests' => array_values(array_filter(array_map('trim', explode(',', (string)$r['pests'])))),
                'helps' => array_values(array_filter(array_map('trim', explode(',', (string)$r['helps'])))),
                'about' => (string)$r['about'],
            ];
        }
    }
    return $defs;
}

/** Residents in a garden's animal home (0 when there is no such building). */
function garden_residents(int $plotId, string $building): int
{
    static $c = [];
    $k = $plotId . '|' . $building;
    return $c[$k] ??= building_level($plotId, $building) > 0 ? (int)q_val('SELECT COUNT(*) FROM garden_critters WHERE plot_id = ? AND building = ?', [$plotId, $building]) : 0;
}

/** Chance (percent) of each pest visiting one growing bed on a date. */
function pest_chances(array $t, array $p, string $date, array $ctx): array
{
    $defs = pest_defs();
    if (!$defs || ($p['kind'] ?? '') === 'cover') return [];
    $base = max(0, (int)setting('pest_chance'));
    $season = array_search(hollow_season($date), array_keys(HOLLOW_SEASONS), true);
    $w = garden_weather_on((int)$t['plot_id'], $date);
    $pos = (int)$t['yx'] . ',' . (int)$t['yy'];
    $b = $ctx['bonus'][$pos] ?? [];
    $cutC = max(0, min(90, (int)setting('companion_cut_pct'))) / 100;
    $cutA = max(0, min(100, (int)setting('pest_counter_cut_pct'))) / 100;
    $out = [];
    foreach ($defs as $slug => $d) {
        if ($d['kindlist'] && !in_array((string)$p['kind'], $d['kindlist'], true)) continue;
        $c = $base * $d['sw'][$season === false ? 0 : $season] * ($d['ww'][$w] ?? 1.0);
        if ($c <= 0) continue;
        // companions beside the bed (up to two kinds count)
        $helpers = 0;
        foreach ($ctx['near'][$pos] ?? [] as $nslug) if (in_array($slug, $ctx['comp'][$nslug]['pests'] ?? [], true)) $helpers++;
        $c *= (1 - $cutC) ** min(2, $helpers);
        // living and growing counters
        $counter = (string)$d['counter'];
        if ($counter === 'lodge' && !empty($b['lodge']) && $ctx['lodge']) $c *= 1 - $cutA;
        if ($counter === 'pond' && !empty($b['pond']) && $ctx['pond']) $c *= 1 - $cutA;
        if ($counter === 'birds' && !empty($b['birds'])) $c *= 0.4;
        if (!empty($b['hedge'])) $c *= 0.8;
        if ($ctx['greenhouse']) $c *= 0.5;
        $out[$slug] = $c;
    }
    return $out;
}

/** Does a pest on this bed have a living counter in reach? Returns the helper's name for the news line ('' = none). */
function pest_counter_here(array $t, array $d, array $ctx, string $date): string
{
    $b = $ctx['bonus'][(int)$t['yx'] . ',' . (int)$t['yy']] ?? [];
    $counter = (string)$d['counter'];
    if ($counter === 'lodge' && !empty($b['lodge']) && $ctx['lodge']) return 'ladybirds';
    if ($counter === 'pond' && !empty($b['pond']) && $ctx['pond']) return 'frogs';
    if ($counter === 'birds' && !empty($b['birds']) && hollow_unit('birds|' . $t['id'] . '|' . $date) < 0.5) return 'birds';
    return '';
}

/**
 * Roll pests for the beds of a garden (called when the owner loads it). Pests come with the season and weather, only to beds that are
 * growing something and only for the last couple of Hollow days (away longer = paused), at most pest_max_pct of beds at once.
 * Living counters clear pests after a few hours; frost sends the small ones away. Updates $tiles in place; returns news lines.
 */
function garden_pest_pass(array $plot, array &$tiles, array $plants): array
{
    $msgs = [];
    if (setting('pests_on') === '0' || !gfx_on() || !pest_defs()) return $msgs;
    if ((int)$plot['garden_level'] < (int)setting('pest_min_garden_level')) return $msgs;
    $plotId = (int)$plot['id'];
    $today = hollow_today();
    $days = [hollow_date_add($today, -1), $today];
    // context: yard bonuses, who is beside whom, whether the animals have residents
    $ctx = ['bonus' => yard_bonus_map($plotId), 'comp' => companion_defs(), 'near' => [], 'greenhouse' => building_level($plotId, 'greenhouse') > 0,
            'lodge' => garden_residents($plotId, 'ladybird_lodge') > 0, 'pond' => garden_residents($plotId, 'frog_pond') > 0];
    $at = [];
    $growing = 0;
    $infested = 0;
    foreach ($tiles as $row) foreach ($row as $t) {
        if ($t['yx'] === null || empty($t['plant_id']) || !isset($plants[(int)$t['plant_id']])) continue;
        $at[(int)$t['yx'] . ',' . (int)$t['yy']] = (string)$plants[(int)$t['plant_id']]['slug'];
        if ($plants[(int)$t['plant_id']]['kind'] !== 'cover') $growing++;
        if (!empty($t['pest'])) $infested++;
    }
    foreach ($at as $pos => $_s) {
        [$x, $y] = array_map('intval', explode(',', $pos));
        for ($dx = -1; $dx <= 1; $dx++) for ($dy = -1; $dy <= 1; $dy++) {
            if (($dx || $dy) && isset($at[($x + $dx) . ',' . ($y + $dy)])) $ctx['near'][$pos][] = $at[($x + $dx) . ',' . ($y + $dy)];
        }
    }
    $maxInf = max(1, (int)ceil($growing * max(5, min(100, (int)setting('pest_max_pct'))) / 100));
    $clearH = max(0, (int)setting('pest_clear_hours')) * 3600;
    $cleared = [];
    foreach ($tiles as $y => $row) foreach ($row as $x => $t) {
        if ($t['yx'] === null || empty($t['plant_id']) || !isset($plants[(int)$t['plant_id']])) continue;
        $p = $plants[(int)$t['plant_id']];
        if ($p['kind'] === 'cover') continue;
        $defs = pest_defs();
        $changed = false;
        // a pest already here
        if (!empty($t['pest'])) {
            $d = $defs[(string)$t['pest']] ?? null;
            if (!$d) { $t['pest'] = null; $t['pest_at'] = null; $changed = true; }
            else {
                $age = time() - ts($t['pest_at']);
                $helper = $age >= $clearH ? pest_counter_here($t, $d, $ctx, $today) : '';
                $cold = in_array(garden_weather_on($plotId), ['frost', 'snow'], true) && in_array((string)$t['pest'], ['aphids', 'gnats', 'caterpillars'], true);
                if ($helper !== '' || $cold) {
                    $cleared[$helper !== '' ? $helper : 'the cold'][$d['name']] = ($cleared[$helper !== '' ? $helper : 'the cold'][$d['name']] ?? 0) + 1;
                    $t['pest'] = null; $t['pest_at'] = null; $changed = true; $infested--;
                }
            }
        }
        // new visitors, one roll a Hollow day
        $last = (string)($t['pest_check'] ?? '');
        if ($last === '') $last = hollow_date('Y-m-d', ts($t['planted_at']) ?: time());
        if (empty($t['pest']) && !tile_info($t, $p)['ready']) {
            foreach ($days as $d0) {
                if ($d0 <= $last || $infested >= $maxInf) continue;
                $ch = pest_chances($t, $p, $d0, $ctx);
                $sum = array_sum($ch);
                $r = hollow_unit('pest|' . $t['id'] . '|' . $d0) * 100;
                if ($sum > 0 && $r < min(60.0, $sum)) {
                    $r2 = hollow_unit('pestkind|' . $t['id'] . '|' . $d0) * $sum;
                    foreach ($ch as $slug => $c) {
                        if ($r2 < $c) { $t['pest'] = $slug; $t['pest_at'] = now(); $infested++; $changed = true; break; }
                        $r2 -= $c;
                    }
                    if (!empty($t['pest'])) break;
                }
            }
        }
        if ($last < $today) { $t['pest_check'] = $today; $changed = true; }
        if ($changed) {
            q('UPDATE plot_tiles SET pest = ?, pest_at = ?, pest_check = ? WHERE id = ?', [$t['pest'] ?: null, $t['pest'] ? $t['pest_at'] : null, $t['pest_check'] ?? $today, $t['id']]);
            $tiles[$y][$x] = $t;
        }
    }
    foreach ($cleared as $who => $list) {
        $icon = ['ladybirds' => '🐞', 'frogs' => '🐸', 'birds' => '🐦'][$who] ?? '❄️';
        $bits = [];
        foreach ($list as $name => $n) $bits[] = strtolower($name) . ' from ' . $n . ' bed' . ($n === 1 ? '' : 's');
        $msgs[] = $icon . ' ' . ucfirst($who === 'the cold' ? 'The cold' : 'Your ' . $who) . ' cleared ' . implode(' and ', $bits) . '.';
    }
    return $msgs;
}

/** Pick the pest off one bed by hand. Always works; costs a little energy. [ok, [messages]] */
function pest_pick(int $uid, int $x, int $y): array
{
    $t = q_one('SELECT * FROM plot_tiles WHERE plot_id = ? AND user_id = ? AND x = ? AND y = ?', [active_plot_id($uid), $uid, $x, $y]);
    if (!$t) return [false, ['That square isn’t part of your plot.']];
    if (empty($t['pest']) || empty($t['plant_id'])) return [false, ['No pests here.']];
    $d = pest_defs()[(string)$t['pest']] ?? null;
    $cost = max(0, (int)setting('pest_pick_energy'));
    // v1.0.0: take the pest off first (a conditional update), so two quick taps can't both spend the energy
    $took = db_tx(function () use ($t, $uid, $cost): bool {
        if (q('UPDATE plot_tiles SET pest = NULL, pest_at = NULL, pest_check = ? WHERE id = ? AND pest IS NOT NULL', [hollow_today(), $t['id']])->rowCount() !== 1) { db()->rollBack(); return false; }
        if ($cost > 0 && !spend_energy($uid, $cost)) { db()->rollBack(); return false; }
        return true;
    });
    if (!$took) return (int)q_val('SELECT energy FROM users WHERE id = ?', [$uid]) < $cost ? [false, ['You’re too tired. Rest a bit and your energy will come back.' . tired_hint($uid)]] : [false, ['No pests here.']];
    $n = random_int(6, 18);
    $name = $d ? strtolower((string)$d['name']) : 'pests';
    require_once __DIR__ . '/animals140.php';   // v1.4.0: a slug or snail may be rescued into the Snail Jar
    $rescue = animals140_on_pest_pick($uid, (int)$t['plot_id'], (string)$t['pest']);
    return [true, [($d['icon'] ?? '🐛') . ' You pick ' . $n . ' ' . $name . ' off by hand. The bed grows at full pace again.' . $rescue]];
}

/** A pest chip for a bed: icon + name. */
function pest_chip(array $t, bool $long = false): string
{
    if (empty($t['pest'])) return '';
    $d = pest_defs()[(string)$t['pest']] ?? null;
    if (!$d) return '';
    return '<span class="chip chip-pest" title="' . e($d['name'] . ': ' . $d['about']) . '">' . e($d['icon']) . ' ' . e($long ? $d['name'] . ' slowing growth' : $d['name']) . '</span>';
}

/** Which pest each of this bed's companion plants is keeping away: text for the bed panel (plants beside it). */
function companion_notes(array $t, array $plants): array
{
    if ($t['yx'] === null) return [];
    $comp = companion_defs();
    $out = [];
    $nb = neighbours((int)$t['plot_id'], (int)$t['yx'], (int)$t['yy']);
    $pdefs = pest_defs();
    foreach ($nb as $n) {
        if (!isset($comp[$n['slug']])) continue;
        $c = $comp[$n['slug']];
        $names = array_filter(array_map(fn($s) => isset($pdefs[$s]) ? strtolower($pdefs[$s]['name']) : null, $c['pests']));
        $name = (string)q_val('SELECT name FROM plants WHERE slug = ?', [$n['slug']]);
        $out[$n['slug']] = ['name' => $name ?: $n['slug'], 'pests' => $names, 'helps' => $c['helps'], 'about' => $c['about']];
    }
    return array_values($out);
}

/** Companion yield bonus: a neighbour that "helps" this crop sometimes gives +1. Returns a message or ''. */
function garden_companion_yield(array $t, array $p, array $nb, int &$qty): string
{
    if (!gfx_on()) return '';
    $comp = companion_defs();
    foreach ($nb as $n) {
        if (isset($comp[$n['slug']]) && in_array((string)$p['slug'], $comp[$n['slug']]['helps'], true)
            && random_int(1, 100) <= max(0, (int)setting('companion_yield_pct'))) {
            $qty++;
            $name = (string)q_val('SELECT name FROM plants WHERE slug = ?', [$n['slug']]);
            return '🌿 ' . ($name ?: 'A companion') . ' beside it helped: +1.';
        }
    }
    return '';
}

// ----------------------------------------------------------------- The bed panel

/** Chips, the pest puzzle and companion notes for one growing bed (HTML, inside the plant box). */
function tile_fx_html(array $t, array $p, array $plants = []): string
{
    if (!gfx_on()) return '';
    $gh = building_level((int)$t['plot_id'], 'greenhouse') > 0;
    $chips = season_chip($p, $gh);
    if ($gh && trim((string)($p['seasons'] ?? '')) !== '') $chips .= '<span class="chip chip-in" title="A greenhouse ignores the seasons">🏠 greenhouse: any season</span>';
    $info = tile_info($t, $p);
    if (!empty($info['rain'])) $chips .= '<span class="chip chip-rain" title="Rain counts as watering until midnight">🌧️ rain waters it <small class="muted">until midnight</small></span>';
    if (!empty($t['nipped']) && !$gh) $chips .= '<span class="chip chip-frost" title="A frost nipped it: a small dip in the harvest">🥶 frost-nipped <small class="muted">smaller harvest</small></span>';
    $chips .= pest_chip($t, true);
    $h = $chips !== '' ? '<p class="chips">' . $chips . '</p>' : '';
    $tr = plant_traits($p);
    $w = garden_weather_on((int)$t['plot_id']);
    $tips = [];
    if (in_array('tender', $tr, true) && !$gh) $tips[] = '🥶 Tender: frost slows it' . ($w === 'frost' && (int)$t['mulch'] <= 0 ? ' (frost today: mulch this bed!)' : ', unless the bed is mulched') . '.';
    if (in_array('tall', $tr, true) && !$gh) $tips[] = '🌬️ Tall: a storm leans it over' . (empty($t['_hedge']) ? '; a hedge beside the bed shelters it' : ' (your hedge shelters it)') . '.';
    if (!empty($t['pest'])) {
        $d = pest_defs()[(string)$t['pest']] ?? null;
        if ($d) {
            $cost = max(0, (int)setting('pest_pick_energy'));
            $h .= '<div class="pesthelp"><p class="help">' . e($d['icon'] . ' ' . $d['name']) . ' are slowing this bed by ' . (int)setting('pest_slow_pct') . '%. ' . e($d['hint']) . '</p>'
                . '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="pick"><input type="hidden" name="x" value="' . (int)$t['x'] . '"><input type="hidden" name="y" value="' . (int)$t['y'] . '">'
                . '<button class="btn act">🧤 Pick them off' . ($cost ? ' <span class="cost">⚡' . $cost . '</span>' : '') . '</button></form></div>';
        }
    }
    foreach ($tips as $tip) $h .= '<p class="help">' . e($tip) . '</p>';
    $notes = companion_notes($t, $plants);
    if ($notes) {
        $bits = [];
        foreach ($notes as $n) $bits[] = e($n['name']) . ($n['pests'] ? ' keeps off ' . e(implode(' and ', $n['pests'])) : '') . (in_array((string)$p['slug'], $n['helps'], true) ? ' and helps this crop' : '');
        $h .= '<p class="help">🌿 Beside it: ' . implode('; ', $bits) . '.</p>';
    }
    $own = companion_defs()[(string)$p['slug']] ?? null;
    if ($own && $own['pests']) {
        $pd = pest_defs();
        $names = array_filter(array_map(fn($s) => isset($pd[$s]) ? strtolower($pd[$s]['name']) : null, $own['pests']));
        $h .= '<p class="help">🌿 A good companion: ' . e($own['about']) . ' It keeps ' . e(implode(' and ', $names)) . ' off the beds around it.</p>';
    }
    return $h;
}

<?php
declare(strict_types=1);
/**
 * Haven family layer (2.7.01): "Guest book" and "Bedtime Rounds" (proposal-route-sights.md, haven end pieces). Above a section that has a haven Sight (a mark whose slug starts `end-haven-`)
 * a quilt-coloured strip shows (1) the moon of the day and what it does to the havens' bedtimes (a full moon keeps everybody up an hour later, a new moon sends them to bed an hour earlier),
 * (2) the guest book: one line per villager named at the section's havens (the Sights folk rows), signed when the gnome knows them (friendship 1 or more, trail_sight_friend_known),
 * blank when not, and (3) the bedtime round: the villagers in the order they go to bed (a fixed bedtime of 8 to 10 pm each, from hollow_unit, moved by the moon) with a word for now:
 * "up", "tuck in now" (the hour before bed), "asleep" (bed to 6 am). The game is data: every haven Sight tallies `tucked` when used at dusk or night (data/trail_sights_end.txt).
 * Pure functions of the clock, so the strip never lies. Style: assets/style.css "Haven family" block (classes tfhaven / tfh-). No JS. Text says it; colour alone never does.
 */

const TRAIL_FAM_HAVEN_WAKE = 6;

/** The hour a villager goes to bed on a game day (20-22 from their name, +1 on a full moon, -1 on a new moon). */
function trail_fam_haven_bed(string $who, int $dayIndex): int
{
    $base = 20 + (int)floor(hollow_unit('havenbed|' . $who) * 3);
    require_once __DIR__ . '/moon.php';
    $k = moon_phase($dayIndex)['key'];
    return $base + ($k === 'full' ? 1 : ($k === 'new' ? -1 : 0));
}

/** 'up' | 'tuck' (the hour before bed) | 'asleep' (bed to the wake hour) at a clock hour. */
function trail_fam_haven_state(int $bed, float $hour): string
{
    if ($hour < TRAIL_FAM_HAVEN_WAKE || $hour >= $bed) return 'asleep';
    return $hour >= $bed - 1 ? 'tuck' : 'up';
}

function trail_fam_haven(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'end-haven-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $hour = (float)$hour; $di = (int)$di;
    $uid = (int)(($ctx['u'] ?? [])['id'] ?? 0);
    $mo = moon_phase($di);
    $folk = trail_sight_folk();
    $seen = [];   // name => [who, first Sight slug]
    foreach ($marks as $m) foreach ($folk[$m['slug']] ?? [] as $r) {
        $nm = trail_sight_split_who($r['who'])[0];
        if (!isset($seen[$nm])) $seen[$nm] = [$r['who'], $m['slug']];
    }
    $moonSay = $mo['key'] === 'full' ? 'Full moon: nobody wants to go to bed, bedtimes are an hour late'
        : ($mo['key'] === 'new' ? 'New moon: it is dark early, bedtimes are an hour early' : 'Bedtimes are the usual hours');
    $h = '<p class="tfh-h"><b>' . e($mo['name']) . '</b> · ' . e($moonSay) . '</p>';
    $book = ''; $signed = 0; $rows = [];
    foreach ($seen as $nm => [$who, $slug]) {
        $sig = $uid > 0 && trail_sight_friend_known($uid, $who);
        if ($sig) $signed++;
        $book .= '<li class="tfh-sig ' . ($sig ? 'signed' : 'blank') . '"><span class="tfh-ico" aria-hidden="true">' . ($sig ? '✍️' : '▫️') . '</span>'
            . '<span class="tfh-nm">' . e($nm) . '</span><span class="tfh-st">' . ($sig ? 'signed' : 'blank line') . ' · ' . e(trail_sight_label($slug)[0]) . '</span></li>';
        $bed = trail_fam_haven_bed($nm, $di);
        $rows[] = [$bed, $nm, trail_fam_haven_state($bed, $hour)];
    }
    if ($seen) {
        $h .= '<p class="tfh-sub">Guest book: ' . $signed . ' of ' . count($seen) . ' signed</p><ul class="tfh-book">' . $book . '</ul>';
        usort($rows, fn($a, $b) => [$a[0], $a[1]] <=> [$b[0], $b[1]]);
        $say = ['up' => 'up', 'tuck' => 'tuck in now', 'asleep' => 'asleep'];
        $li = '';
        foreach ($rows as $i => [$bed, $nm, $st]) $li .= '<li class="tfh-bed ' . $st . '"><span class="tfh-no">' . ($i + 1) . '.</span> <span class="tfh-nm">' . e($nm) . '</span> <span class="tfh-st">bed at ' . e(hour_label($bed)) . ' · ' . $say[$st] . '</span></li>';
        $h .= '<p class="tfh-sub">Bedtime round, first to bed first:</p><ol class="tfh-round">' . $li . '</ol>';
    }
    $tl = (int)((($ctx['now'] ?? [])['tl'] ?? [])['tucked'] ?? 0);
    $h .= '<p class="tfh-tally">Tucked in so far: ' . $tl . ' (use a haven Sight at dusk or night to tuck in; coins from the 3rd, a title at 10)</p>';
    return '<section class="tfhaven" aria-label="Haven guest book and bedtime round">' . moon_pill((string)$mo['icon'], $mo['name'] . ' · guest book and bedtimes', $h) . '</section>';
}

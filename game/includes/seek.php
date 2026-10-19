<?php
declare(strict_types=1);
/**
 * v0.7.97: Seek. Pick a resource on the World page's 🧺 Gather tab and the game points you to the nearest places to
 * gather it: which road stop, and how many steps off the road. It only gives directions; the gnome walks and clicks.
 * The choice is kept in the session ($_SESSION['seek'] = item slug) and shown as a chip on the World and exploring pages.
 */
require_once __DIR__ . '/gathering.php';
require_once __DIR__ . '/explore.php';

/** Every gatherable, for the picker: rows with name, slug, tool, rarity, lands (array), known (found it before). */
function seek_catalog(int $uid): array
{
    $known = array_fill_keys(q("SELECT en.unlock_key FROM user_encyclopedia ue JOIN encyclopedia_entries en ON en.id = ue.entry_id
                                WHERE ue.user_id = ? AND en.unlock_key LIKE 'gather:%'", [$uid])->fetchAll(PDO::FETCH_COLUMN), true);
    $out = [];
    foreach (q('SELECT g.*, i.name, i.slug FROM gatherables g JOIN items i ON i.id = g.item_id WHERE g.active = 1 ORDER BY g.tool, i.name')->fetchAll() as $g) {
        $g['lands'] = $g['landscapes'] === 'any' ? ['any'] : array_values(array_filter(array_map('trim', explode(',', (string)$g['landscapes']))));
        $g['known'] = isset($known['gather:' . $g['slug']]);
        $out[$g['slug']] = $g;
    }
    return $out;
}

/** The first step out where each zone (2–4) begins, with the current settings: [zone => depth]. */
function seek_zone_depths(): array
{
    static $d = null;
    if ($d !== null) return $d;
    $d = [];
    for ($i = 3; $i <= 80 && count($d) < 3; $i++) {
        $z = explore_zone_of_depth($i);
        $d[$z] ??= $i;
    }
    return $d;
}

/** The lands a gnome walks into off a road stop, nearest first: [[depth, land], …] (depth 0 = right at the stop). */
function seek_stop_lands(array $loc): array
{
    $out = [[0, (string)($loc['landscape'] ?: 'grassland')]];
    if (empty($loc['region_id'])) return $out;
    $out[] = [2, stop_near_land($loc)];
    static $zones = [];
    $rid = (int)$loc['region_id'];
    $zones[$rid] ??= q('SELECT zone_num, landscape FROM zones WHERE region_id = ?', [$rid])->fetchAll(PDO::FETCH_KEY_PAIR);
    foreach (seek_zone_depths() as $z => $depth) {
        if (!empty($zones[$rid][$z])) $out[] = [$depth, (string)$zones[$rid][$z]];
    }
    return $out;
}

/**
 * The nearest places to gather $g: up to $limit rows, nearest first, one per road stop:
 * [loc, depth, land, how (0 here · 1 this region · 2 fast travel · 3 walk there first), region name].
 */
function seek_places(array $u, array $g, int $limit = 3): array
{
    require_once __DIR__ . '/adventure.php';
    $here = player_node($u);
    $hereRegion = (int)($here['region_id'] ?? 0);
    $want = $g['lands'];
    $rows = [];
    $stops = q("SELECT DISTINCT l.*, rg.gnomish_name AS region_name FROM locations l JOIN routes r ON (r.a_id = l.id OR r.b_id = l.id) AND r.kind = 'road'
                JOIN regions rg ON rg.id = l.region_id ORDER BY l.id")->fetchAll();
    foreach ($stops as $loc) {
        $best = null;
        foreach (seek_stop_lands($loc) as [$depth, $land]) {
            if (in_array('any', $want, true) || in_array($land, $want, true)) { $best = [$depth, $land]; break; }
        }
        if (!$best) continue;
        $rid = (int)$loc['region_id'];
        $how = (int)$loc['id'] === (int)$here['id'] ? 0 : ($rid === $hereRegion ? 1 : (can_fast_travel($u, $rid) ? 2 : 3));
        $rows[] = ['loc' => $loc, 'depth' => $best[0], 'land' => $best[1], 'how' => $how, 'region' => (string)$loc['region_name'],
                   'score' => $how * 1000 + $best[0] * 10 + ((string)$loc['kind'] === 'village' ? 0 : 1)];
    }
    usort($rows, fn($a, $b) => $a['score'] <=> $b['score']);
    return array_slice($rows, 0, $limit);
}

/** "2 steps off the road" / "right at the stop" */
function seek_depth_text(int $depth): string
{
    return $depth === 0 ? 'right at the stop (or 1 step out)' : $depth . ' steps off the road';
}

/** One plain-language line on how to get there. Directions only: the gnome does the walking. */
function seek_how_text(array $u, array $p): string
{
    $name = (string)$p['loc']['name'];
    return match ($p['how']) {
        0 => 'You’re here. ',
        1 => 'Walk the road to ' . $name . '. ',
        2 => 'Fast travel to ' . $p['region'] . ' (' . money(seek_travel_cost($u, (int)$p['loc']['region_id'])) . '), then walk to ' . $name . '. ',
        default => 'Walk the roads to ' . $p['region'] . ' first (recommended level ' . region_min_level((int)$p['loc']['region_id']) . '), then on to ' . $name . '. ',
    } . ($p['depth'] > 0 ? 'Wander off the path ' . $p['depth'] . ' steps.' : 'Gather at the stop.');
}

function seek_travel_cost(array $u, int $regionId): int
{
    $home = home_region($u);
    require_once __DIR__ . '/journey.php';
    if (($home && (int)$home['id'] === $regionId) || journey_benefit((int)$u['id'], 'free_travel', $regionId)) return 0;
    $c = (int)setting('travel_cost');
    // v0.9.1: calling perk (Wayfinder) Petals discount, by calling tier; same rule as travel_to()
    return (int)round($c * (100 - calling_perk($u, 'fast_travel_discount')) / 100);
}

/** What the gnome is seeking (a catalog row), or null. */
function seek_current(int $uid): ?array
{
    $slug = (string)($_SESSION['seek'] ?? '');
    if ($slug === '') return null;
    return seek_catalog($uid)[$slug] ?? null;
}

/** Display name: the real name once found, else "??? (a rock pick find)". */
function seek_name(array $g): string
{
    return $g['known'] ? (string)$g['name'] : '??? (a ' . (GATHER_TOOL_NOUN[$g['tool']] ?? 'tool') . ' find)';
}

/** Does the gnome's tool reach it? [ok, text] */
function seek_tool_check(int $uid, array $g): array
{
    $need = GATHER_RARITY[$g['rarity']][0] ?? 1;
    $have = tool_tier($uid, (string)$g['tool']);
    $noun = GATHER_TOOL_NOUN[$g['tool']] ?? 'tool';
    if ($have >= $need) return [true, 'Your ' . $noun . ' is good enough ✔'];
    return [false, 'Needs a ' . (TOOL_TIERS[$need] ?? '') . ' ' . $noun . ($have ? ' (yours is ' . (TOOL_TIERS[$have] ?? 'too weak') . ')' : ' (you don’t have one)') . '. Twigg’s sells them.'];
}

/**
 * The 🎯 chip for the World page and the exploring page. With $exp (on a walk off the path) it says how far to go from
 * this stop, or "here!". Empty when not seeking.
 */
function seek_chip(array $u, ?array $exp = null): string
{
    $g = seek_current((int)$u['id']);
    if (!$g) return '';
    $L = fn(string $l) => (LANDSCAPES[$l][0] ?? '🌱') . ' ' . (LANDSCAPES[$l][1] ?? ucfirst($l));
    $line = '';
    if ($exp) {
        $from = q_one('SELECT * FROM locations WHERE id = ?', [$exp['from_id']]);
        $depth = (int)$exp['depth'];
        $now = explore_land($exp);
        if (in_array('any', $g['lands'], true) || in_array($now, $g['lands'], true)) {
            $line = '<b>It’s right here!</b> Use 🧺 Gather here below.';
            $_SESSION['gather_game_last'] = (string)$g['tool'];   // the gathering game opens on the right tool
        } elseif ($from) {
            $target = null;
            foreach (seek_stop_lands($from) as [$d, $land]) {
                if ($d > 0 && (in_array($land, $g['lands'], true))) { $target = [$d, $land]; break; }
            }
            $line = $target
                ? ($target[0] > $depth ? 'Keep going: ' . $L($target[1]) . ' starts at step ' . $target[0] . ' (you’re at step ' . $depth . ').'
                    : 'You’ve passed it: ' . $L($target[1]) . ' is at step ' . $target[0] . '. Head back a little.')
                : 'Not off this road stop. Check the 🧺 Gather tab for where to go.';
        }
    } else {
        $p = seek_places($u, $g, 1)[0] ?? null;
        $line = $p ? e(seek_how_text($u, $p)) : 'Nowhere on the map has it yet.';
    }
    return '<div class="seekchip">🎯 Seeking <b>' . e(seek_name($g)) . '</b> · ' . $line
        . ' <a class="seekx" href="' . e(url('world.php?tab=gather&seek=off')) . '" title="Stop seeking" aria-label="Stop seeking">✖</a></div>';
}

/** Regions and stops to mark on the world map while seeking: [region ids => true], [location ids => true]. */
function seek_map_marks(array $u): array
{
    $g = seek_current((int)$u['id']);
    if (!$g) return [[], []];
    $regions = [];
    $stops = [];
    foreach (seek_places($u, $g, 200) as $p) $regions[(int)$p['loc']['region_id']] = true;
    foreach (seek_places($u, $g, 3) as $p) $stops[(int)$p['loc']['id']] = true;
    return [$regions, $stops];
}

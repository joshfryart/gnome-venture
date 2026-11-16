<?php
declare(strict_types=1);
/**
 * Wonder family layer (2.7.01): "Postcard frame" and "Look Closer" (proposal-route-sights.md, wonder end pieces). Above a section that has a wonder Sight (a mark whose slug starts `end-wonder-`)
 * a framed postcard shows the wonder (gate or hush, land), a postmark with the moon of the day (the moon is the light the wonder is seen in), and a sticker slot that fills once the gnome
 * has used the Sight (trail_sight_uses). Below it the album: the 16 wonders as sticker slots (found or empty, said in words) and the Look Closer tally ("Close looks", title Sharp Eye at 8).
 * The game is data: every wonder Sight is a `pick:3:detail;detail;detail` hidden-detail check with `tally=wonder-looks` (data/trail_sights_end.txt); Wren Thimblewick is a traveller
 * (no clockwork), the clockwork chips are for the other villagers due at the section's wonders. Style: assets/style.css "Wonder family" block (tfwonder / tfw-). No JS.
 */

const TRAIL_FAM_WONDER_LANDS = ['coast' => '🌊', 'desert' => '🏜️', 'forest' => '🌲', 'grassland' => '🌾', 'island' => '🏝️', 'mountain' => '⛰️', 'rainforest' => '🌴', 'wetland' => '🪷'];

/** [kind 'gate'|'hush', land] of a wonder slug, or null. */
function trail_fam_wonder_parse(string $slug): ?array
{
    if (!preg_match('/^end-wonder-([12])-([a-z]+)$/', $slug, $m)) return null;
    return [$m[1] === '1' ? 'gate' : 'hush', $m[2]];
}

/** Slugs of the wonders this gnome has used at least once (their stickers). */
function trail_fam_wonder_found(int $uid): array
{
    if ($uid <= 0) return [];
    try { return array_map('strval', q("SELECT DISTINCT slug FROM trail_sight_uses WHERE user_id = ? AND slug LIKE 'end-wonder-%'", [$uid])->fetchAll(PDO::FETCH_COLUMN)); }
    catch (Throwable $e) { return []; }
}

function trail_fam_wonder(array $ctx): string
{
    $marks = array_values(array_filter((array)($ctx['marks'] ?? []), fn($m) => str_starts_with((string)($m['slug'] ?? ''), 'end-wonder-')));
    if (!$marks) return '';
    require_once __DIR__ . '/npc_clockwork.php';
    require_once __DIR__ . '/moon.php';
    if (!function_exists('trail_sight_label')) require_once __DIR__ . '/trail_sight_extras.php';
    [, $hour, $di] = ($ctx['clock'] ?? null) ?: npc_cw_clock();
    $di = (int)$di;
    $uid = (int)(($ctx['u'] ?? [])['id'] ?? 0);
    $mo = moon_phase($di);
    $found = array_flip(trail_fam_wonder_found($uid));
    $now = (array)($ctx['now'] ?? []);
    $h = '<section class="tfwonder" aria-label="Wonder postcard frame">';
    $shown = [];
    foreach ($marks as $m) {
        if (isset($shown[$m['slug']])) continue;
        $shown[$m['slug']] = 1;
        $p = trail_fam_wonder_parse($m['slug']);
        if (!$p) continue;
        [$kind, $land] = $p;
        $has = isset($found[$m['slug']]);
        $ico = TRAIL_FAM_WONDER_LANDS[$land] ?? '✨';
        $h .= '<figure class="tfw-card ' . $kind . ' ' . ($has ? 'has' : 'empty') . '">'
            . '<div class="tfw-pic" aria-hidden="true">' . $ico . '</div>'
            . '<figcaption><b>' . e(trail_sight_label($m['slug'])[0]) . '</b>'
            . '<span class="tfw-sub">' . ($kind === 'gate' ? 'a gate to look at' : 'a hush to listen to') . ' · ' . e(ucfirst($land)) . '</span>'
            . '<span class="tfw-post" title="The moon of the day">Postmark: ' . e($mo['icon']) . ' ' . e($mo['name']) . ', day ' . ((int)$mo['age'] + 1) . ' of ' . MOON_DAYS . '</span></figcaption>'
            . '<span class="tfw-stk ' . ($has ? 'on' : 'off') . '">' . ($has ? '<span aria-hidden="true">' . $ico . '</span> sticker stuck' : '<span aria-hidden="true">▫️</span> empty sticker slot') . '</span>'
            . '</figure>';
    }
    $all = [];
    foreach (trail_sights_all() as $slug => $row) if (trail_fam_wonder_parse((string)$slug)) $all[] = (string)$slug;
    sort($all);
    $album = ''; $n = 0;
    foreach ($all as $slug) {
        $has = isset($found[$slug]); if ($has) $n++;
        [$kind, $land] = trail_fam_wonder_parse($slug);
        $album .= '<li class="tfw-s ' . ($has ? 'on' : 'off') . '" title="' . e(ucfirst($land) . ' ' . $kind . ($has ? ': found' : ': not yet')) . '"><span aria-hidden="true">' . ($has ? (TRAIL_FAM_WONDER_LANDS[$land] ?? '✨') : '▫️') . '</span><span class="tfw-sr">' . e(ucfirst($land) . ' ' . $kind . ($has ? ', sticker found' : ', empty')) . '</span></li>';
    }
    $tl = (int)(($now['tl'] ?? [])['wonder-looks'] ?? 0);
    $h .= '<p class="tfw-h"><span aria-hidden="true">🔍</span> <b>Look closer</b>: ' . $n . ' of ' . count($all) . ' stickers in the album · close looks: ' . $tl . ' (a title at 8). Spot the right detail at a wonder and it counts.</p>'
        . '<ul class="tfw-album">' . $album . '</ul>';
    $chips = [];
    if (npc_cw_on()) {
        foreach ($marks as $m) foreach (npc_cw_sight_lines($m['slug']) as $l) {
            if ($l['text'] === 'not this fortnight') continue;
            $chips[] = ['now' => $l['now'], 'near' => $l['now'] || str_starts_with($l['text'], 'today') || str_starts_with($l['text'], 'tomorrow'), 'text' => $l['name'] . ' at ' . trail_sight_label($m['slug'])[0] . ': ' . $l['text']];
        }
    }
    usort($chips, fn($a, $b) => [$b['now'], $b['near']] <=> [$a['now'], $a['near']]);
    foreach (array_slice($chips, 0, 2) as $c) $h .= '<p class="tfw-chip' . ($c['now'] ? ' now' : '') . '"><span aria-hidden="true">📮</span> ' . e($c['text']) . '</p>';
    return $h . '</section>';
}

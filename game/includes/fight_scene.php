<?php
/**
 * The fight on the animated stage (setting fight_scene). The server already rolled everything: this only hands the engine
 * (assets/fightengine.js, played by assets/fightscene.js) the start health, the events of the last action and the picture URLs.
 * No JS or an error: the plain bars and text inside the stage stay and the buttons work as before.
 */
require_once __DIR__ . '/gnome_rig.php';

/** v2.5.93: the Puzzle Pals taken along, for the fight stage: [['img' => url, 'name' => name]] (up to 3); [] when take-along is off, a guest, or no art. */
function fight_scene_pals(array $u): array
{
    if (!empty($u['guest']) || setting('ppal_party') !== '1') return [];
    require_once __DIR__ . '/puzzle_pals.php';
    $o = [];
    foreach (ppal_equipped($u) as $e) {
        $url = ppal_art_url((string)$e['pal']['key']);
        if ($url !== '' && count($o) < 3) $o[] = ['img' => $url, 'name' => (string)($e['pal']['name'] ?? 'Pal')];
    }
    return $o;
}

function fight_scene_on(): bool
{
    return setting('fight_scene') === '1' && is_file(APP_ROOT . '/assets/fightengine.js');
}

/** The stage for a creature fight. $c = encounter_creature($enc) after fight_prep. */
/** $over = ['cols'=>,'rows'=>,'mx'=>,'my'=>,'fx'=>]: the stage sits exactly over the tile map (flat, transparent) with the gnome and the foe on those cells. */
function fight_scene_html(array $u, array $exp, array $enc, array $c, ?array $over = null): string
{
    $slug = (string)($c['slug'] ?? '');
    $take = fight_ev_take((int)$exp['id'], $enc, $exp);   // only events that belong to this very fight
    $meHp = max(0, (int)$exp['hp']); $foeHp = max(0, (int)($enc['hp'] ?? 0));
    $data = [
        'slug' => preg_match('/^[a-z0-9-]+$/', $slug) ? $slug : '',
        'me' => ['name' => gnome_name($u), 'hp' => $take ? (int)$take['start']['me']['hp'] : $meHp, 'max' => (int)$exp['max_hp']],
        'foe' => ['name' => (string)$c['name'], 'hp' => $take ? (int)$take['start']['foe']['hp'] : $foeHp, 'max' => (int)$enc['max']],
        'events' => $take ? $take['ev'] : [],
        'end' => ['me' => $meHp, 'foe' => $foeHp],
        'sheet' => gnome_rig_url($u), 'v' => APP_VERSION,
        'base' => url('assets/img/fight'),
        'mini' => $slug !== '' && is_file(APP_ROOT . '/assets/img/mini/mini-' . $slug . '.png') ? url('assets/img/mini/mini-' . $slug . '.png') : '',
        'over' => $over,
        'pals' => fight_scene_pals($u),
        'hat' => !empty($enc['hat']) ? 1 : 0,
        'land' => strtolower((string)($enc['land'] ?? '')),
    ];
    $bar = fn(string $n, int $v, int $m) => '<span class="fs-fb"><b>' . e($n) . '</b> ❤️ <progress max="' . $m . '" value="' . $v . '"></progress> ' . $v . '/' . $m . '</span>';
    return '<div class="fightscene' . ($over ? ' fs-over' : '') . '" id="fightscene" data-fight="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '" role="img" aria-label="' . e(gnome_name($u) . ' fights ' . $c['name']) . '">'
        . $bar(gnome_name($u), $meHp, (int)$exp['max_hp']) . $bar((string)$c['name'], $foeHp, (int)$enc['max']) . '</div>'
        . (!$over ? fight_hatform_html($enc) : '');   // over a map the stage sits inside the map's own form: the hat form goes with the dock, outside it
}

/** The stage for a non-fight encounter (an event, a riddle, a skill check): the gnome and pals on the stage, the event's icon standing opposite, no health bars. */
function fight_event_html(array $u, array $enc): string
{
    $icon = '❓';
    if (($enc['type'] ?? '') === 'choice' && ($ch = road_event_get($enc))) $icon = (string)($ch['icon'] ?? '❓');
    $data = ['event' => $icon, 'slug' => '', 'me' => ['name' => gnome_name($u), 'hp' => 1, 'max' => 1], 'foe' => ['name' => '', 'hp' => 1, 'max' => 1], 'events' => [],
        'sheet' => gnome_rig_url($u), 'v' => APP_VERSION, 'base' => url('assets/img/fight'), 'mini' => '', 'over' => null, 'pals' => fight_scene_pals($u), 'hat' => 0, 'land' => ''];
    return '<div class="fightscene" id="fightscene" data-fight="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '" role="img" aria-label="' . e(gnome_name($u) . ' meets something on the road') . '"></div>';
}

/**
 * The fight menu on the map (v2.5.96, "Design C"): a small command column over the map with Fight, Item and Flee. Fight and Item open a list beside it
 * (Fight: Attack, the calling's ability, the pals' actives; no Fight on / Auto-win since 2.5.98; Item: the snacks, one row each). Tap an option once to read what it does in the
 * list's top line, tap it again to do it (assets/fightscene.js). After an action the page comes back with the menu closed, so the fight plays out in full view.
 * Every option is a real form: with no script the lists simply sit open. $side 'l' / 'r' = which side of the map the column is on (opposite the gnome); 'b' = in the page flow right under the stage (a short stage off the Trail: the menu would hide it). $withHat false when the stage already carries the hat form (the stage off the Trail: delve, wander, list).
 * Needs fight_snacks() and friends from adventure.php.
 */
function fight_dock_html(array $u, array $exp, array $enc, array $c, string $side = 'l', bool $withHat = true): string
{
    $gc = gnome_combat($u, true);
    [$abName, $abDesc] = CALLING_ABILITIES[$u['calling'] ?? ''] ?? CALLING_ABILITIES[''];
    $hitPct = (int)fight_odds($u, $exp, $enc)['hit'];
    $runPct = max(0, min(100, (21 - (8 + intdiv((int)$c['level'], 3) - eff_mod($u, 'nimble'))) * 5));
    $opt = function (string $do, string $icon, string $title, string $right, string $desc, string $extra = '', bool $off = false): string {
        return '<form method="post" class="fsc-f">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">' . $extra
            . '<button class="fsc-opt" data-desc="' . e($desc) . '"' . ($off ? ' disabled' : '') . '><span class="o-ic" aria-hidden="true">' . e($icon) . '</span><span class="o-t">' . e($title)
            . '</span>' . ($right !== '' ? '<span class="o-r">' . e($right) . '</span>' : '') . '</button></form>';
    };
    $fight = $opt('attack', '⚔️', 'Attack', $hitPct . '%', 'A plain swing: d' . (int)$gc['dmg_die'] . '+' . (int)$gc['dmg_bonus'] . ' damage, ' . $hitPct . '% to hit.');
    $fight .= $opt('ability', '✨', $abName, $enc['used'] ? 'used' : '', $abName . ': ' . $abDesc . ' Once per fight.', '', !empty($enc['used']));
    if (ppal_boons_on()) foreach (ppal_fight_actives($u, $enc) as $pa) $fight .= $opt($pa['do'], '🍄', $pa['title'], $pa['used'] ? 'used' : '', $pa['title'] . ': ' . (string)$pa['sub'], '', !empty($pa['used']));
    $left = snacks_left($u, $enc);
    $snacks = $left > 0 ? fight_snacks($u) : [];
    $item = '';
    foreach ($snacks as $sn) $item .= $opt('snack', '🥧', (string)$sn['name'], '×' . (int)$sn['qty'], 'Heals ' . (int)$sn['heal'] . ' ❤️. Uses your turn. ' . $left . ' snack' . ($left === 1 ? '' : 's') . ' left this fight.',
        '<input type="hidden" name="item" value="' . (int)$sn['id'] . '">');
    $flee = '<form method="post" class="fsc-f">' . csrf_field() . '<input type="hidden" name="do" value="flee"><button class="fsc-opt fsc-flee" data-desc="" data-armtext="Run? Tap again"><span class="o-ic" aria-hidden="true">🏃</span><span class="o-t">Flee</span><span class="o-r">' . $runPct . '%</span></button></form>';
    $top = fn(string $k, string $icon, string $t, bool $off = false) => '<button type="button" class="fsc-top" data-open="' . $k . '"' . ($off ? ' disabled' : '') . '><span class="o-ic" aria-hidden="true">' . $icon . '</span><span class="o-t">' . $t . '</span><span class="o-r" aria-hidden="true">▸</span></button>';
    // v2.6.07: a fallen hat can lie under the menu, so the menu has its own one-tap Hat button while it is down (posts do=hat like the tap on the hat itself)
    $hatBtn = !empty($enc['hat']) ? '<form method="post" class="fsc-f">' . csrf_field() . '<input type="hidden" name="do" value="hat"><button class="fsc-opt fsc-hatbtn" data-desc="Put your hat back on."><span class="o-ic" aria-hidden="true">🎩</span><span class="o-t">Hat</span></button></form>' : '';
    return '<div class="fsdockwrap fsd-' . ($side === 'b' ? 'b' : ($side === 'r' ? 'r' : 'l')) . '">' . ($withHat ? fight_hatform_html($enc) : '')
        . '<div class="fsdock fsc" role="group" aria-label="Fight actions">'
        . '<div class="fsc-sub" data-for="fight" data-hint="Tap to read, tap again to do."><div class="fsc-info"></div>' . $fight . '</div>'
        . ($item !== '' ? '<div class="fsc-sub" data-for="item" data-hint="Tap to read, tap again to eat."><div class="fsc-info"></div>' . $item . '</div>' : '')
        . '<div class="fsc-menu">' . $top('fight', '⚔️', 'Fight') . $top('item', '🎒', 'Item', $item === '') . $hatBtn . $flee . '</div>'
        . '</div></div>';
}

/**
 * A fight, or its end scene, over a tile map (the Trail, a delve floor, the map behind a wander). $fexp = the expedition the fight belongs to (a wander's own, not the map's),
 * $sc = the map scene (x, y), $win = tm_window of it. Returns [stage html, dock html, over]: over false = nothing to draw (the plain map). The gnome stands on its own tile,
 * kept inside the middle 7 of 9 so a narrow phone sees both, the foe two tiles to the right; the dock goes on the side away from the gnome.
 */
function fight_map_over(array $u, array $fexp, array $sc, array $win, bool $fightOver): array
{
    if (!$fightOver) return ['', '', false];
    $mx = max(1, min(DM_VIEW - 4, $sc['x'] - $win['x0']));
    $over = ['cols' => DM_VIEW, 'rows' => DM_VIEW, 'mx' => $mx, 'my' => max(1, min(DM_VIEW - 2, $sc['y'] - $win['y0'])), 'fx' => $mx + 2];
    if (!empty($fexp['encounter']) && ($enc = json_decode((string)$fexp['encounter'], true)) && ($enc['type'] ?? '') === 'creature' && ($c = encounter_creature($enc))) {
        fight_prep($enc, $c);
        return [fight_scene_html($u, $fexp, $enc, $c, $over), fight_dock_html($u, $fexp, $enc, $c, $mx <= 3 ? 'r' : 'l'), true];   // real forms: they cannot sit inside the map's own form, so they follow it and css pulls them up over the map
    }
    if (empty($fexp['encounter'])) {   // the fight just ended: its end scene plays over the map before the map is usable
        $h = fight_finale_html($u, $fexp, $over);
        if ($h !== '') return [$h, '', true];
    }
    return ['', '', false];
}

/** The hidden form the hat tap submits (do=hat). */
function fight_hatform_html(array $enc): string
{
    return !empty($enc['hat']) ? '<form method="post" class="hatform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="hat"></form>' : '';
}

/** Is there an end scene waiting (a fight that just finished on this walk)? Looks, does not consume. */
function fight_finale_pending(array $exp): bool
{
    $r = $_SESSION['fight_ev'] ?? null;
    if (!is_array($r) || (int)($r['exp'] ?? 0) !== (int)$exp['id'] || time() - (int)($r['t'] ?? 0) > 30 || empty($r['ev'])) return false;
    $last = end($r['ev']);
    return is_array($last) && in_array($last['end'] ?? '', ['win', 'peace', 'flee'], true);   // a knock-out ends the walk: its scene sits on the result page (fight_finale_html with no map)
}

/**
 * The end scene of a fight, drawn over the map after the last blow: the foe falls (or the gnome runs), XP and loot drop and are drawn into the gnome,
 * then the map unlocks (assets/fightscene.js, FightEngine reward). $over = the same cells as fight_scene_html. '' when nothing is waiting.
 */
function fight_finale_html(array $u, array $exp, ?array $over): string
{
    $take = fight_ev_take((int)$exp['id']);
    if (!$take) return '';
    $last = end($take['ev']);
    $slug = (string)($take['start']['foe']['slug'] ?? '');
    $loot = [];
    foreach ((array)($last['loot'] ?? []) as $l) {
        $rel = (string)($l['img'] ?? '');
        $loot[] = ['name' => (string)$l['name'], 'qty' => (int)($l['qty'] ?? 1), 'img' => $rel !== '' && art_path($rel) !== '' ? url($rel) : ''];
    }
    $data = [
        'slug' => preg_match('/^[a-z0-9-]+$/', $slug) ? $slug : '',
        'me' => ['name' => gnome_name($u), 'hp' => (int)$take['start']['me']['hp'], 'max' => (int)$take['start']['me']['max']],
        'foe' => ['name' => (string)($take['start']['foe']['name'] ?? ''), 'hp' => (int)$take['start']['foe']['hp'], 'max' => (int)$take['start']['foe']['max']],
        'events' => $take['ev'], 'end' => ['me' => (int)$take['end']['me']['hp'], 'foe' => (int)$take['end']['foe']['hp']],
        'sheet' => gnome_rig_url($u), 'v' => APP_VERSION, 'base' => url('assets/img/fight'),
        'mini' => $slug !== '' && is_file(APP_ROOT . '/assets/img/mini/mini-' . $slug . '.png') ? url('assets/img/mini/mini-' . $slug . '.png') : '',
        'over' => $over, 'pals' => fight_scene_pals($u), 'hat' => 0, 'finale' => 1,
        'reward' => in_array((string)($last['end'] ?? ''), ['win', 'peace'], true) ? ['kind' => (string)$last['end'], 'xp' => (int)($last['xp'] ?? 0), 'lvl' => (int)($last['lvl'] ?? 0), 'loot' => $loot] : null,   // a run or a knock-out has nothing to collect: the scene is just the last moves
    ];
    return '<div class="fightscene' . ($over ? ' fs-over' : '') . '" id="fightscene" data-fight="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '" role="img" aria-label="The fight is over"></div>';
}

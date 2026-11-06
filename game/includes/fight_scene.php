<?php
/**
 * The fight on the animated stage (setting fight_scene). The server already rolled everything: this only hands the engine
 * (assets/fightengine.js, played by assets/fightscene.js) the start health, the events of the last action and the picture URLs.
 * No JS or an error: the plain bars and text inside the stage stay and the buttons work as before.
 */
require_once __DIR__ . '/gnome_rig.php';

function fight_scene_on(): bool
{
    return setting('fight_scene') === '1' && is_file(APP_ROOT . '/assets/fightengine.js');
}

/** The stage for a creature fight. $c = encounter_creature($enc) after fight_prep. */
/** $over = ['cols'=>,'rows'=>,'mx'=>,'my'=>,'fx'=>]: the stage sits exactly over the tile map (flat, transparent) with the gnome and the foe on those cells. */
function fight_scene_html(array $u, array $exp, array $enc, array $c, ?array $over = null): string
{
    $slug = (string)($c['slug'] ?? '');
    $take = fight_ev_take((int)$exp['id']);
    $meHp = max(0, (int)$exp['hp']); $foeHp = max(0, (int)($enc['hp'] ?? 0));
    $data = [
        'slug' => preg_match('/^[a-z0-9-]+$/', $slug) ? $slug : '',
        'me' => ['name' => gnome_name($u), 'hp' => $take ? (int)$take['start']['me']['hp'] : $meHp, 'max' => (int)$exp['max_hp']],
        'foe' => ['name' => (string)$c['name'], 'hp' => $take ? (int)$take['start']['foe']['hp'] : $foeHp, 'max' => (int)$enc['max']],
        'events' => $take ? $take['ev'] : [],
        'end' => ['me' => $meHp, 'foe' => $foeHp],
        'parts' => gnome_rig_urls($u),
        'base' => url('assets/img/fight'),
        'mini' => $slug !== '' && is_file(APP_ROOT . '/assets/img/mini/mini-' . $slug . '.png') ? url('assets/img/mini/mini-' . $slug . '.png') : '',
        'over' => $over,
        'hat' => !empty($enc['hat']) ? 1 : 0,
        'land' => strtolower((string)($enc['land'] ?? '')),
    ];
    $bar = fn(string $n, int $v, int $m) => '<span class="fs-fb"><b>' . e($n) . '</b> ❤️ <progress max="' . $m . '" value="' . $v . '"></progress> ' . $v . '/' . $m . '</span>';
    return '<div class="fightscene' . ($over ? ' fs-over' : '') . '" id="fightscene" data-fight="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '" role="img" aria-label="' . e(gnome_name($u) . ' fights ' . $c['name']) . '">'
        . $bar(gnome_name($u), $meHp, (int)$exp['max_hp']) . $bar((string)$c['name'], $foeHp, (int)$enc['max']) . '</div>'
        . (!$over ? fight_hatform_html($enc) : '');   // over a map the stage sits inside the map's own form: the hat form goes with the dock, outside it
}

/**
 * The action dock for a fight on the map (the same forms as the fight buttons: Attack, the calling's ability, Run, Fight on) plus a "More" sheet for the rest
 * (pal actives, snack, Auto-win) and the odds. Pure HTML forms, no script needed. Needs act_choice() from adventure.php.
 */
function fight_dock_html(array $u, array $exp, array $enc, array $c): string
{
    $gc = gnome_combat($u, true);
    [$abName, $abDesc] = CALLING_ABILITIES[$u['calling'] ?? ''] ?? CALLING_ABILITIES[''];
    $sure = fight_certainty($u, $exp, $c, $enc);
    $hitPct = (int)fight_odds($u, $exp, $enc)['hit'];
    $runPct = max(0, min(100, (21 - (8 + intdiv((int)$c['level'], 3) - eff_mod($u, 'nimble'))) * 5));
    $o = act_choice('attack', '⚔️', 'Attack', '', '', 'primary');
    $o .= $enc['used'] ? act_choice('ability', '✨', $abName, '', '', '', '', 'disabled') : act_choice('ability', '✨', $abName);
    $o .= act_choice('flee', '🏃', 'Run');
    $o .= can_fight_on($exp) ? act_choice('fighton', '⏩', 'Fight on') : '';
    $more = '<p class="fsodds">⚔️ hit ' . $hitPct . '% · 🏃 run ' . $runPct . '% · d' . (int)$gc['dmg_die'] . '+' . (int)$gc['dmg_bonus'] . ' damage</p>'
        . '<p class="fsodds">' . e($abName) . ': ' . e($abDesc) . ' Once per fight.</p>';
    if (ppal_boons_on()) foreach (ppal_fight_actives($u, $enc) as $pa) $more .= $pa['used'] ? act_choice($pa['do'], '✨', $pa['title'], 'Used this fight', '', '', '', 'disabled') : act_choice($pa['do'], '✨', $pa['title'], $pa['sub']);
    $more .= fight_snack_picker($u, $exp, $enc, fn($do, $label, $extra) => act_choice($do, '🎒', 'Snack', 'Eats a home-cooked snack: heals ' . (int)setting('fight_snack_heal_mult') . '× its energy. Uses your turn; ' . snack_limit($u) . ' a fight.', '', '', $extra));
    if ($sure === 'win') $more .= act_choice('auto', '⏩', 'Auto-win', 'A sure win: the fight plays out for you.', ['sure', 'cost']);
    return '<div class="fsdockwrap">' . fight_hatform_html($enc) . '<div class="fsdock" role="group" aria-label="Fight actions">' . $o
        . '<details class="fsmore"><summary aria-label="More actions">⋯</summary><div class="fsmorebox">' . $more . '</div></details></div></div>';
}

/** The hidden form the hat tap submits (do=hat). */
function fight_hatform_html(array $enc): string
{
    return !empty($enc['hat']) ? '<form method="post" class="hatform" hidden>' . csrf_field() . '<input type="hidden" name="do" value="hat"></form>' : '';
}

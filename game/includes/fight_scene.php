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
        'parts' => gnome_rig_urls($u),
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
    // v2.5.95: every option sits in the menu itself (no hidden "More"): Attack (double width), the calling's ability and Run on the first row, then Fight on, the pals' actives
    // and Auto-win, then the snack (its own full row, it has a picker). The (i) sheet only explains the odds and what each one does.
    $o = act_choice('attack', '⚔️', 'Attack', '', '', 'primary');
    $o .= $enc['used'] ? act_choice('ability', '✨', $abName, '', '', '', '', 'disabled') : act_choice('ability', '✨', $abName);
    $o .= act_choice('flee', '🏃', 'Run');
    $o .= can_fight_on($exp) ? act_choice('fighton', '⏩', 'Fight on') : '';
    $more = '<p class="fsodds">⚔️ hit ' . $hitPct . '% · 🏃 run ' . $runPct . '% · d' . (int)$gc['dmg_die'] . '+' . (int)$gc['dmg_bonus'] . ' damage</p>'
        . '<p class="fsodds"><b>' . e($abName) . '</b>: ' . e($abDesc) . ' Once per fight.</p>';
    if (ppal_boons_on()) foreach (ppal_fight_actives($u, $enc) as $pa) {
        $o .= $pa['used'] ? act_choice($pa['do'], '✨', $pa['title'], '', '', '', '', 'disabled') : act_choice($pa['do'], '✨', $pa['title']);
        $more .= '<p class="fsodds"><b>' . e($pa['title']) . '</b>' . ($pa['used'] ? ' (used this fight)' : '') . ': ' . e((string)$pa['sub']) . '</p>';
    }
    if ($sure === 'win') {
        $o .= act_choice('auto', '⏩', 'Auto-win', '', ['sure', 'cost']);
        $more .= '<p class="fsodds"><b>Auto-win</b>: a sure win; the fight plays out for you.</p>';
    }
    $snack = fight_snack_picker($u, $exp, $enc, fn($do, $label, $extra) => act_choice($do, '🎒', 'Snack', '', '', '', $extra));
    if ($snack !== '') $more .= '<p class="fsodds"><b>Snack</b>: eats a home-cooked snack and heals ' . (int)setting('fight_snack_heal_mult') . '× its energy. Uses your turn; ' . snack_limit($u) . ' a fight.</p>';
    return '<div class="fsdockwrap">' . fight_hatform_html($enc) . '<div class="fsdock" role="group" aria-label="Fight actions">' . $o
        . ($snack !== '' ? '<div class="fssnack">' . $snack . '</div>' : '')
        . '<details class="fsmore"><summary aria-label="What each option does">ⓘ</summary><div class="fsmorebox">' . $more . '</div></details></div></div>';
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
    return is_array($last) && in_array($last['end'] ?? '', ['win', 'peace'], true);   // a run or a knock-out just returns to the page
}

/**
 * The end scene of a fight, drawn over the map after the last blow: the foe falls (or the gnome runs), XP and loot drop and are drawn into the gnome,
 * then the map unlocks (assets/fightscene.js, FightEngine reward). $over = the same cells as fight_scene_html. '' when nothing is waiting.
 */
function fight_finale_html(array $u, array $exp, array $over): string
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
        'parts' => gnome_rig_urls($u), 'base' => url('assets/img/fight'),
        'mini' => $slug !== '' && is_file(APP_ROOT . '/assets/img/mini/mini-' . $slug . '.png') ? url('assets/img/mini/mini-' . $slug . '.png') : '',
        'over' => $over, 'pals' => fight_scene_pals($u), 'hat' => 0, 'finale' => 1,
        'reward' => ['kind' => (string)$last['end'], 'xp' => (int)($last['xp'] ?? 0), 'lvl' => (int)($last['lvl'] ?? 0), 'loot' => $loot],
    ];
    return '<div class="fightscene fs-over" id="fightscene" data-fight="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '" role="img" aria-label="The fight is over"></div>';
}

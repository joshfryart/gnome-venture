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
function fight_scene_html(array $u, array $exp, array $enc, array $c): string
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
        'land' => strtolower((string)($enc['land'] ?? '')),
    ];
    $bar = fn(string $n, int $v, int $m) => '<span class="fs-fb"><b>' . e($n) . '</b> ❤️ <progress max="' . $m . '" value="' . $v . '"></progress> ' . $v . '/' . $m . '</span>';
    return '<div class="fightscene" id="fightscene" data-fight="' . e((string)json_encode($data, JSON_UNESCAPED_UNICODE)) . '" role="img" aria-label="' . e(gnome_name($u) . ' fights ' . $c['name']) . '">'
        . $bar(gnome_name($u), $meHp, (int)$exp['max_hp']) . $bar((string)$c['name'], $foeHp, (int)$enc['max']) . '</div>';
}

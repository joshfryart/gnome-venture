<?php
declare(strict_types=1);
/**
 * The slim place card for a town spot (Green, Café, Notice Board, Library, special places), shown inside a Here popover.
 * Loaded lazily by assets/hubscene.js (GET town.php?spot=N&frag=1); its forms post in place to town.php (JSON {ok, msg, html}), so nothing leaves the picture.
 * Layout: one short line about the place, the things to do as compact rows (cost chip + "left today"), who is here as little faces (tap = their popover),
 * the board's favours / the café's gossip, and "Open full page" last.
 */

/** A villager's head from their 2.5D sprite (first frame), else the species emoji. Tapping it opens their popover (hubscene.js) or the villager page. */
function spot_face(array $n): string
{
    $slug = function_exists('scene_key') ? scene_key((string)($n['slug'] ?? '')) : preg_replace('/[^a-z0-9-]/', '', (string)($n['slug'] ?? ''));
    $rel = 'assets/img/sprite/npc-' . $slug . '.png';
    $pic = ($slug !== '' && is_file(APP_ROOT . '/' . $rel))
        ? '<svg class="sfpic" viewBox="8 6 48 46" width="44" height="42" aria-hidden="true" overflow="hidden"><image href="' . e(url($rel)) . '" x="0" y="0" width="256" height="96" image-rendering="pixelated"/></svg>'
        : '<span class="sfpic sfemo" aria-hidden="true">' . e(npc_icon($n['species'] ?? null)) . '</span>';
    return '<a class="sface" href="' . e(url('villagers.php?id=' . (int)$n['id'])) . '" data-nid="' . (int)$n['id'] . '">' . $pic . '<span>' . e(preg_replace('/^(Old|Auntie|Grandmother|Captain|Nonna|Abuela|Babka)\s+/u', '', (string)$n['name'])) . '</span></a>';
}

function spot_card_html(array $u, array $spot, bool $hub, string $msg = '', bool $ok = true): string
{
    require_once __DIR__ . '/town.php';
    require_once __DIR__ . '/journey.php';
    require_once __DIR__ . '/place_ui.php';
    require_once __DIR__ . '/npc_life.php';
    require_once __DIR__ . '/folk_list.php';
    $uid = (int)$u['id'];
    $town = (string)$spot['region'];
    $q = $hub ? 'hub=1&' : '';
    $sid = (int)$spot['id'];
    $uses = town_uses_today($uid);
    $closed = spot_closed($spot);
    $h = '';
    if ($msg !== '') $h .= '<p class="vmsg ' . ($ok ? 'ok' : 'err') . '" role="status">' . e($msg) . '</p>';
    $h .= '<p class="sdesc">' . e((string)$spot['description']) . '</p>';
    if ($closed) $h .= '<p class="notice">🔒 Closed right now. ' . e($closed) . '</p>';
    if ($jlock = journey_lock($uid, 'spot', (string)$spot['slug'])) {
        $h .= journey_lock_note($jlock, (string)$spot['name']);
    } else {
        $h .= action_buttons($spot, $u, $uses, $q) . town_pickers($uid);
    }
    if ($spot['kind'] === 'green' && ($fest = town_festival($town))) {
        $h .= '<form method="post" class="tact"><input type="hidden" name="do" value="festival"><input type="hidden" name="spot" value="' . $sid . '">' . ($hub ? '<input type="hidden" name="hub" value="1">' : '') . csrf_field()
            . '<button class="btn act gold">' . $fest[1] . ' Visit the festival stall</button><small class="muted">a free treat, once today</small></form>';
    }
    $here = npcs_at_spot($spot);
    if ($here) {
        npc_meet($uid, array_column($here, 'id'));
        $h .= '<div class="sfaces" aria-label="Here now">' . implode('', array_map('spot_face', $here)) . '</div>';
    }
    if ($spot['kind'] === 'board') { ob_start(); town_favours_box($uid, $town, $hub, $sid); $h .= ob_get_clean(); }
    if ($spot['kind'] === 'teahouse' && ($rumours = teahouse_rumours($town))) {
        $h .= '<div class="rumours"><b>👂 Overheard</b>' . implode('', array_map(fn($r) => '<p>' . e($r) . '</p>', $rumours)) . '</div>';
    }
    $h .= '<p class="vmore"><a href="' . e(url('town.php?' . $q . 'spot=' . $sid)) . '">Open full page ›</a></p>';
    return str_replace('<form method="post"', '<form method="post" data-vform="1"', $h);
}

/** JSON reply for the in-place card (GET frag, or a POST from inside the card). */
function spot_card_reply(array $u, bool $hub, int $spotId, string $msg = '', bool $ok = true): void
{
    $town = town_for($u, $hub);
    $spot = $spotId > 0 ? q_one('SELECT * FROM town_spots WHERE id = ? AND region = ? AND active = 1', [$spotId, $town]) : null;
    header('Content-Type: application/json; charset=utf-8');
    if (!$spot) { echo json_encode(['ok' => false, 'msg' => $msg !== '' ? $msg : 'That place is not here.', 'html' => ''], JSON_UNESCAPED_SLASHES); exit; }
    $u = q_one('SELECT * FROM users WHERE id = ?', [(int)$u['id']]);
    echo json_encode(['ok' => $ok, 'msg' => $msg, 'html' => spot_card_html($u, $spot, $hub, $msg, $ok), 'toasts' => take_toasts()], JSON_UNESCAPED_SLASHES);
    exit;
}

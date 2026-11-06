<?php
declare(strict_types=1);
/**
 * Graphical navigation, phase 3: Residential (the street of houses of a town or stop) and the Door of one house.
 * A house is not data: it is a villager's home (npcs.home_location_id, or the place their shop is in). House slot = index in the id-ordered list,
 * append-only, so a new villager takes the next slot and nobody else moves. Villagers out in the street are on Here; villagers at home are behind
 * their door. Knock only works when they are home (lit window). A gift can be left at the door when they are out (once a day, half friendship).
 */
require_once __DIR__ . '/hub_scene.php';
require_once __DIR__ . '/npc_life.php';
require_once __DIR__ . '/friends.php';
require_once __DIR__ . '/scene.php';

const RESID_HOMES = ['cottage' => '🏡', 'burrow' => '🕳️', 'treehouse' => '🌳', 'hut' => '🛖', 'stone' => '🏰', 'boat' => '⛵'];

/** Villagers who live at a place, id order (the slot order). Travellers have no home; inactive ones are skipped. */
function npcs_homed_at(int $locId): array
{
    return q("SELECT n.* FROM npcs n WHERE n.active = 1 AND n.traveller IS NULL AND (n.home_location_id = ?
              OR (n.home_location_id IS NULL AND n.id IN (SELECT s.npc_id FROM npc_schedules s JOIN shops sh ON sh.id = s.shop_id WHERE sh.location_id = ? AND s.activity = 'working')))
              ORDER BY n.id", [$locId, $locId])->fetchAll();
}

/** Street template for a number of houses and how many fit on a page: [layout key, per page]. */
function resid_template(int $total): array
{
    return $total <= 4 ? ['resid-4', 4] : ($total <= 6 ? ['resid-6', 6] : ['resid-8', 8]);
}

/** Has this gnome met the villager (so the house shows their name)? */
function resid_met(int $uid, int $npcId): bool
{
    return (bool)q_val('SELECT 1 FROM user_npc_met WHERE user_id = ? AND npc_id = ?', [$uid, $npcId]) || (bool)q_val('SELECT 1 FROM npc_friends WHERE user_id = ? AND npc_id = ? AND points > 0', [$uid, $npcId]);
}

/** May the gnome stand at this villager's door now? Must be at the home place, not walking. */
function door_allowed(array $u, array $npc): bool
{
    require_once __DIR__ . '/adventure.php';
    if (active_expedition((int)$u['id'])) return false;
    $at = (int)player_node($u)['id'];
    foreach (npcs_homed_at($at) as $n) if ((int)$n['id'] === (int)$npc['id']) return true;
    return false;
}

/** The street picture of a place, page $page (1-based). Returns [html, pages]. */
function resid_view(array $u, array $loc, int $page, string $open = ''): array
{
    require_once __DIR__ . '/hub_pages.php';   // hubp_nav: the compass, globe and Fast travel under the picture (v2.5.49)
    $uid = (int)$u['id'];
    $npcs = npcs_homed_at((int)$loc['id']);
    [$key, $per] = resid_template(count($npcs));
    $L = here_layouts_all()[$key] ?? null;
    $pages = max(1, (int)ceil(count($npcs) / $per));
    $page = max(1, min($pages, $page));
    if (!$L) return ['<p class="muted">No street picture for this place yet.</p>', $pages];
    $rows = array_slice($npcs, ($page - 1) * $per, $per);
    $hot = [];
    foreach ($rows as $i => $n) {
        $slot = $L['houses'][$i] ?? null;
        if (!$slot) continue;
        $met = resid_met($uid, (int)$n['id']);
        $home = !empty(npc_now($n)['home']);
        $hk = npc_home_key($n);
        $hot[] = ['id' => 'h' . (int)$n['id'], 'x' => (int)$slot['x'], 'y' => (int)$slot['y'], 'label' => $met ? (string)$n['name'] : 'A house (unmet)', 'emoji' => RESID_HOMES[$hk] ?? '🏡',
                  'chip' => 'Visit · ' . ($home ? '💡 window lit' : 'window dark'), 'cls' => $home ? 'homelit' : 'dim', 'href' => url('door.php?npc=' . (int)$n['id'] . '&page=' . $page), 'r' => 30];
    }
    $spots = [];
    foreach ($L['spots'] ?? [] as $s) $spots[(string)$s['k']] = $s;
    if (isset($spots['back'])) $hot[] = ['id' => 'back', 'x' => (int)$spots['back']['x'], 'y' => (int)$spots['back']['y'], 'label' => 'Back to the square', 'emoji' => '⬅️', 'href' => url('here.php')];
    if ($page > 1 && isset($spots['prev'])) $hot[] = ['id' => 'prev', 'x' => (int)$spots['prev']['x'], 'y' => (int)$spots['prev']['y'], 'label' => '← Back street', 'emoji' => '◀️', 'href' => url('residential.php?loc=' . (int)$loc['id'] . '&page=' . ($page - 1))];
    if ($page < $pages && isset($spots['next'])) $hot[] = ['id' => 'next', 'x' => (int)$spots['next']['x'], 'y' => (int)$spots['next']['y'], 'label' => 'Next street →', 'emoji' => '▶️', 'href' => url('residential.php?loc=' . (int)$loc['id'] . '&page=' . ($page + 1))];
    $html = hub_scene(str_replace('resid-', '', $key), $hot, [], ['layout' => $L, 'alt' => 'The homes of ' . $loc['name'], 'art' => 'resid', 'title' => 'List of homes', 'open' => $open, 'close_href' => url('residential.php?loc=' . (int)$loc['id'] . '&page=' . $page),
        'nav' => hubp_nav('residential', 'loc=' . (int)$loc['id'] . '&page=' . $page), 'navbar' => true]);
    return [$html, $pages];
}

/** The door picture of one villager. $back = the street page to return to. */
function door_view(array $u, array $npc, int $page, string $open = ''): string
{
    require_once __DIR__ . '/hub_pages.php';
    $uid = (int)$u['id'];
    $L = here_layouts_all()['door'] ?? null;
    if (!$L) return '<p class="muted">No door picture yet.</p>';
    $met = resid_met($uid, (int)$npc['id']);
    $home = !empty(npc_now($npc)['home']);
    $hk = npc_home_key($npc);
    $slug = scene_key((string)$npc['slug']);
    $artKey = scene_path('door', $slug) !== '' ? $slug : $hk;   // door-<slug>.png, else door-<homekey>.png, else a drawn door
    $name = $met ? (string)$npc['name'] : '???';
    $spots = [];
    foreach ($L['spots'] ?? [] as $s) $spots[(string)$s['k']] = $s;
    $locId = (int)player_node($u)['id'];
    $hot = [];
    $knockHref = url('villagers.php?id=' . (int)$npc['id'] . '&home=1');
    $hot[] = ['id' => 'knock', 'x' => (int)$spots['knock']['x'], 'y' => (int)$spots['knock']['y'], 'label' => 'Knock', 'emoji' => '🚪', 'chip' => $home ? 'they are home' : 'nobody home',
              'cls' => $home ? '' : 'dim', 'href' => $home ? $knockHref : url('door.php?npc=' . (int)$npc['id'] . '&page=' . $page . '&o=knock'),
              'card' => $home ? '' : '<p>💡 No light on. ' . e($met ? (string)$npc['name'] : 'Nobody') . ' is out. They’re usually home ' . e(npc_home_hours($npc)) . '.</p>'];
    $giftable = q("SELECT i.id, i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 AND i.category NOT IN ('tool', 'broken') ORDER BY i.name", [$uid])->fetchAll();
    $f = friendship($uid, (int)$npc['id']);
    $given = $f['last_gift'] === hollow_date('Y-m-d');
    if ($given) $card = '<p class="muted">You already gave ' . e($name) . ' a present today.</p>';
    elseif (!$giftable) $card = '<p class="muted">You have nothing to give.</p>';
    else {
        $card = '<p>' . ($home ? 'Hand it over at the door.' : 'Leave it at the door: ' . e($name) . ' finds it later (half the friendship).') . '</p><form method="post" action="' . e(url('door.php')) . '">' . csrf_field()
            . '<input type="hidden" name="do" value="gift"><input type="hidden" name="npc" value="' . (int)$npc['id'] . '"><input type="hidden" name="page" value="' . $page . '"><label>Gift <select name="item_id">';
        foreach ($giftable as $g) $card .= '<option value="' . (int)$g['id'] . '">' . e((string)$g['name']) . ' × ' . (int)$g['qty'] . '</option>';
        $card .= '</select></label> <button class="btn">🎁 Leave gift</button></form>';
    }
    $hot[] = ['id' => 'gift', 'x' => (int)$spots['gift']['x'], 'y' => (int)$spots['gift']['y'], 'label' => 'Leave gift', 'emoji' => '🎁', 'chip' => $given ? 'given today' : '', 'href' => url('door.php?npc=' . (int)$npc['id'] . '&page=' . $page . '&o=gift'), 'card' => $card];
    $hot[] = ['id' => 'back', 'x' => (int)$spots['back']['x'], 'y' => (int)$spots['back']['y'], 'label' => 'Back to the street', 'emoji' => '⬅️', 'href' => url('residential.php?loc=' . $locId . '&page=' . $page)];
    $hot[] = ['id' => 'plate', 'x' => (int)$spots['plate']['x'], 'y' => (int)$spots['plate']['y'], 'label' => $name, 'emoji' => '🪧', 'chip' => $met ? '' : 'not met yet', 'href' => url('door.php?npc=' . (int)$npc['id'] . '&page=' . $page . '&o=plate'),
              'card' => '<p><b>' . e($name) . '</b>' . ($met ? '' : '. Knock to meet them.') . '</p><p class="muted">' . ($home ? '💡 The window is lit: they are home.' : 'The window is dark: they are out.') . '</p>', 'cls' => $home ? 'homelit' : 'dim'];
    return hub_scene($artKey, $hot, [], ['layout' => $L, 'alt' => 'The door of ' . $name, 'art' => 'door', 'open' => $open, 'close_href' => url('door.php?npc=' . (int)$npc['id'] . '&page=' . $page), 'title' => 'List view',
        'nav' => hubp_nav('door', 'npc=' . (int)$npc['id'] . '&page=' . $page), 'navbar' => true]);
}

/** Leave a gift at the door: the villager must live where the gnome stands; same once-a-day claim and tastes as a handed gift, half the friendship. */
function npc_gift_door(array $u, int $npcId, int $itemId): array
{
    $npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$npcId]);
    if (!$npc || !door_allowed($u, $npc)) return [false, 'You need to be at their door.'];
    return npc_gift($u, $npcId, $itemId, true);
}

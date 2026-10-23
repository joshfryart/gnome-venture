<?php
declare(strict_types=1);
/** v2.0.39: the Villagers page — every villager in one place (the ones you haven't met are shadows), with a detail panel that opens in place. */
require_once __DIR__ . '/friends.php';
require_once __DIR__ . '/npc_life.php';
require_once __DIR__ . '/folk_list.php';
require_once __DIR__ . '/scene.php';

/** All active villagers with whether you've met them, friendship, where they are now and whether you can reach them. */
function villagers_all(array $u): array
{
    $uid = (int)$u['id'];
    $rows = q('SELECT n.*, COALESCE(f.points, 0) AS points, m.first_at, (m.npc_id IS NOT NULL OR f.npc_id IS NOT NULL) AS met
               FROM npcs n LEFT JOIN npc_friends f ON f.npc_id = n.id AND f.user_id = ? LEFT JOIN user_npc_met m ON m.npc_id = n.id AND m.user_id = ?
               WHERE n.active = 1 ORDER BY n.name', [$uid, $uid])->fetchAll();
    foreach ($rows as &$n) {
        $n['met'] = (bool)$n['met'];
        $n['level'] = friend_level((int)$n['points']);
        if (!$n['met']) { $n['now'] = null; $n['home'] = null; $n['here'] = false; continue; }
        $n['now'] = npc_now($n);
        $n['home'] = $n['home_location_id'] ? q_one('SELECT l.name, l.region FROM locations l WHERE l.id = ?', [$n['home_location_id']]) : null;
        $n['here'] = !empty($n['now']['town']) && can_reach($u, (string)$n['now']['town']);
    }
    return $rows;
}

/** The filter bar and the card grid. */
function villagers_grid(array $u, array $all, array $g): string
{
    $q = trim((string)($g['q'] ?? ''));
    $f = in_array($g['f'] ?? '', ['met', 'unmet', 'here'], true) ? (string)$g['f'] : '';
    $r = (string)($g['r'] ?? '');
    $s = in_array($g['s'] ?? '', ['name', 'recent'], true) ? (string)$g['s'] : 'friend';
    $met = count(array_filter($all, fn($n) => $n['met']));
    $regions = array_values(array_unique(array_filter(array_map(fn($n) => (string)($n['home']['region'] ?? ''), $all))));
    sort($regions);
    $list = array_filter($all, function ($n) use ($q, $f, $r) {
        if ($f === 'met' && !$n['met']) return false;
        if ($f === 'unmet' && $n['met']) return false;
        if ($f === 'here' && !$n['here']) return false;
        if ($r !== '' && ($n['home']['region'] ?? '') !== $r) return false;
        if ($q !== '' && (!$n['met'] || stripos($n['name'] . ' ' . $n['species'] . ' ' . $n['personality'], $q) === false)) return false;   // a name search never reveals someone you haven't met
        return true;
    });
    usort($list, function ($a, $b) use ($s) {
        if ($a['met'] !== $b['met']) return $a['met'] ? -1 : 1;
        if ($s === 'name') return strcmp($a['name'], $b['name']);
        if ($s === 'recent') return strcmp((string)$b['first_at'], (string)$a['first_at']) ?: strcmp($a['name'], $b['name']);
        return ((int)$b['points'] <=> (int)$a['points']) ?: strcmp($a['name'], $b['name']);
    });
    $around = array_filter($all, fn($n) => $n['met'] && $n['here']);
    $h = '<p class="help">You’ve met <b>' . $met . '</b> of the Hollow’s <b>' . count($all) . '</b> villagers. Meet people at their shop, about town, or by chatting and giving gifts.</p>';
    if ($around) {
        $h .= '<div class="vaaround box"><b>📍 Around you now</b> ';
        foreach (array_slice($around, 0, 12) as $n) $h .= '<a class="npcface" href="' . e(url('villagers.php?id=' . (int)$n['id'])) . '" data-vopen="' . (int)$n['id'] . '">' . npc_icon($n['species']) . ' ' . e($n['name']) . '</a> ';
        $h .= '</div>';
    }
    $h .= '<form method="get" action="' . e(url('villagers.php')) . '" class="box folkfilter vfilter"><input type="search" name="q" value="' . e($q) . '" placeholder="Search by name…" aria-label="Search by name">'
        . '<select name="f" aria-label="Show">';
    foreach (['' => 'Everyone', 'met' => 'Met', 'unmet' => 'Not met yet', 'here' => 'Here now'] as $k => $l) $h .= '<option value="' . e((string)$k) . '"' . ($k === $f ? ' selected' : '') . '>' . e($l) . '</option>';
    $h .= '</select><select name="r" aria-label="Home region"><option value="">All regions</option>';
    foreach ($regions as $rg) $h .= '<option' . ($rg === $r ? ' selected' : '') . '>' . e($rg) . '</option>';
    $h .= '</select><select name="s" aria-label="Sort">';
    foreach (['friend' => 'Closest friends', 'name' => 'A–Z', 'recent' => 'Newest met'] as $k => $l) $h .= '<option value="' . $k . '"' . ($k === $s ? ' selected' : '') . '>' . e($l) . '</option>';
    $h .= '</select><button class="btn small">Show</button>' . ($q !== '' || $f !== '' || $r !== '' || $s !== 'friend' ? ' <a href="' . e(url('villagers.php')) . '">Clear</a>' : '') . '</form>';
    if (!$list) return $h . '<div class="box"><p class="muted">Nobody matches that.</p></div>';
    $h .= '<div class="vgrid">';
    foreach ($list as $n) {
        $id = (int)$n['id'];
        if (!$n['met']) {
            $sil = ph_img('npc-unknown', 64, '') ?: '<span class="vq">❓</span>';
            $h .= '<div class="vcard unmet" aria-label="A villager you have not met yet">' . $sil . '<b>?</b><small class="muted">Not met yet</small></div>';
            continue;
        }
        $h .= '<a class="vcard" href="' . e(url('villagers.php?id=' . $id)) . '" data-vopen="' . $id . '">' . npc_portrait($n, 'small')
            . '<b>' . e($n['name']) . (npc_birthday_today($n) ? ' 🎂' : '') . '</b>'
            . '<small class="muted">💛 ' . e($n['level']['name']) . '</small>'
            . '<small>' . ($n['here'] ? '<span class="good">here now</span> · ' : '') . e((string)$n['now']['what']) . '</small></a>';
    }
    return $h . '</div>';
}

/** Do one thing to a villager: chat, give a gift, or a traveller's deal. [ok, message] */
function villagers_act(array $u, string $do, int $nid, array $post): array
{
    return match ($do) {
        'talk' => npc_talk($u, $nid),
        'gift' => npc_gift($u, $nid, (int)($post['item_id'] ?? 0)),
        'deal' => traveller_deal($u, $nid),
        default => [false, 'Unknown action.'],
    };
}

/** The detail panel for one villager (met, or reachable right now). Returns '' if you can't see them. */
function villager_panel(array $u, int $nid, string $msg = '', bool $ok = true): string
{
    $uid = (int)$u['id'];
    $npc = q_one('SELECT * FROM npcs WHERE id = ? AND active = 1', [$nid]);
    if (!$npc) return '';
    $here = npc_here($u, $nid);
    if ($here) npc_meet($uid, [$nid]);
    $f = friendship($uid, $nid);
    if (!$here && !q_val('SELECT 1 FROM user_npc_met WHERE user_id = ? AND npc_id = ?', [$uid, $nid]) && (int)$f['points'] === 0) return '';
    $lvl = friend_level((int)$f['points']);
    $today = hollow_date('Y-m-d');
    $now = npc_now($npc);
    $tastes = known_tastes($f, $npc);
    $bday = npc_birthday_today($npc);
    $bar = $lvl['next'] ? max(0, min(100, (int)round(100 * (int)$f['points'] / max(1, (int)$lvl['next'][0])))) : 100;
    $h = '<div class="vpanel box" data-nid="' . $nid . '">';
    if ($msg !== '') $h .= '<p class="vmsg ' . ($ok ? 'ok' : 'err') . '" role="status">' . e($msg) . '</p>';
    $h .= '<div class="npchead"><div class="npcpic">' . npc_portrait($npc)
        . '<div class="fondbar"><div class="fbtrack"><span class="fbfill w' . (int)(round($bar / 5) * 5) . '"></span></div><small>💛 <b>' . e($lvl['name']) . '</b>'
        . ($lvl['next'] ? ' · ' . (int)$f['points'] . '/' . (int)$lvl['next'][0] . ' to ' . e($lvl['next'][1]) : ' · best of friends') . ($lvl['discount'] ? ' · 🏷️ ' . (int)$lvl['discount'] . '% off' : '') . '</small></div></div>'
        . '<div class="npcid"><h2>' . npc_icon($npc['species']) . ' ' . e($npc['name']) . ($bday ? ' 🎂' : '') . '</h2>'
        . '<p class="muted">' . e(trim($npc['personality'] . ' ' . strtolower((string)$npc['species']))) . '</p>'
        . '<p>📍 ' . e($now['what']) . (!empty($now['home']) && $now['town'] ? ' in ' . e($now['town']) : '')
        . (!empty($now['spot']) && $now['town'] ? ' · <a href="' . e(url('town.php?' . ($now['town'] === HUB_REGION ? 'hub=1&' : '') . 'spot=' . (int)$now['spot']['id'])) . '">go there</a>' : '') . '</p>';
    if ($here) {
        $h .= !empty($now['home']) ? '<p class="help">🚪 You knocked, and ' . e($npc['name']) . ' asks you in.</p>' : '';
        $h .= '<form method="post" action="' . e(url('villagers.php')) . '" class="vact" data-vform="1">' . csrf_field() . '<input type="hidden" name="id" value="' . $nid . '"><input type="hidden" name="do" value="talk">'
            . '<button class="btn"' . ($f['last_talk'] === $today ? ' disabled' : '') . '>💬 ' . ($f['last_talk'] === $today ? 'Chatted today' : 'Chat') . '</button></form>';
        $giftable = $f['last_gift'] === $today ? [] : q("SELECT i.id, i.name, i.category, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id
            WHERE ui.user_id = ? AND ui.qty > 0 AND i.tradable = 1 AND i.category <> 'tool' ORDER BY i.name", [$uid])->fetchAll();
        if ($f['last_gift'] === $today) $h .= '<p class="help">🎁 Gift given today.</p>';
        elseif (!$giftable) $h .= '<p class="help">🎁 Nothing in your Satchel to give.</p>';
        else {
            $known = json_decode((string)($f['known'] ?? '[]'), true) ?: [];
            $T = npc_tastes($npc);
            $h .= '<form method="post" action="' . e(url('villagers.php')) . '" class="vact" data-vform="1">' . csrf_field() . '<input type="hidden" name="id" value="' . $nid . '"><input type="hidden" name="do" value="gift">'
                . '<label class="visually-hidden" for="vgift' . $nid . '">Gift</label><select name="item_id" id="vgift' . $nid . '">';
            foreach ($giftable as $g) {
                $mark = '';
                if ((int)$g['id'] === (int)$T['loved'] && in_array('loved', $known, true)) $mark = ' 💛';
                elseif (in_array($g['category'], $T['liked'], true) && in_array('like:' . $g['category'], $known, true)) $mark = ' 👍';
                elseif ($g['category'] === $T['disliked'] && in_array('dislike:' . $g['category'], $known, true)) $mark = ' 👎';
                $h .= '<option value="' . (int)$g['id'] . '">' . e($g['name']) . ' ×' . (int)$g['qty'] . $mark . '</option>';
            }
            $h .= '</select> <button class="btn alt">🎁 Give</button></form>';
        }
        if ($npc['traveller'] && ($offer = traveller_offer($npc))) {
            $done = traveller_dealt($uid, $npc);
            $h .= '<form method="post" action="' . e(url('villagers.php')) . '" class="vact" data-vform="1">' . csrf_field() . '<input type="hidden" name="id" value="' . $nid . '"><input type="hidden" name="do" value="deal">'
                . '<button class="btn small"' . ($done ? ' disabled' : '') . '>' . e($offer['label']) . ($done ? ' (done this visit)' : '') . '</button></form>';
        }
    } else {
        $h .= '<p class="help">Not anywhere you can reach right now. Find them in town or knock when they’re home.</p>';
    }
    $h .= '</div></div>';
    if ($bday) $h .= '<p class="bday">🎂 It’s ' . e($npc['name']) . '’s birthday today! A gift counts three times as much.</p>';
    if ($npc['bio']) $h .= '<p>' . e($npc['bio']) . '</p>';
    $work = q('SELECT DISTINCT sh.id, sh.name FROM npc_schedules s JOIN shops sh ON sh.id = s.shop_id WHERE s.npc_id = ?', [$nid])->fetchAll();
    if ($work) $h .= '<p>🏪 Works at ' . implode(', ', array_map(fn($w) => '<a href="' . e(url('shop.php?id=' . (int)$w['id'])) . '">' . e($w['name']) . '</a>', $work)) . '</p>';
    if ($hm = npc_home($npc)) $h .= '<p>🏡 Lives at ' . e($hm['name']) . ' in ' . e($hm['region']) . '. Usually home ' . e(npc_home_hours($npc)) . '.</p>';
    $h .= $lvl['index'] >= 1 ? '<p>🎂 Birthday: ' . e(npc_birthday_text($npc)) . '</p>' : '<p class="help">🎂 Birthday: get to know them better to find out.</p>';
    $h .= '<details><summary>🎁 Likes &amp; dislikes <small>' . count($tastes) . '/4</small></summary>'
        . ($tastes ? '<ul class="tastelist">' . implode('', array_map(fn($t) => '<li>' . e($t) . '</li>', $tastes)) . '</ul>' : '<p class="muted">You don’t know what they like yet. Give gifts to find out.</p>') . '</details>';
    $h .= '<details><summary>🕰️ Their usual day <small class="muted">(Hollow time)</small></summary><ul>' . implode('', array_map(fn($l) => '<li>' . e($l) . '</li>', npc_routine($npc))) . '</ul></details>';
    $h .= '<p><a href="' . e(url('book.php?ch=Folk')) . '">Almanac → Villagers</a></p></div>';
    return $h;
}

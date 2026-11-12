<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/scene.php';   // v2.0.43: the stage
require_once __DIR__ . '/includes/puzzle_pals.php';   // v2.3.8: pal actives on the fight buttons
require_once __DIR__ . '/includes/pfight_game.php';   // puzzle combat (flag pfight_open)
require_once __DIR__ . '/includes/fight_scene.php';   // fight_scene: the animated fight stage
require_once __DIR__ . '/includes/trail_tiles.php';
require_once __DIR__ . '/includes/trail_sights.php';   // v2.6.68 Trail Sights (spike)   // graphical navigation 2d: the Trail as tile sections (gnav_tiles)
$u = require_login();
$uid = (int)$u['id'];

$exp = active_expedition($uid);

if (!is_post() && isset($_GET['view']) && in_array($_GET['view'], ['list', 'map'], true)) {   // v2.0.6: map or the simple list, remembered in the session
    dm_set_pref((string)$_GET['view']);
    redirect('adventure.php');
}

if (is_post()) {
    csrf_check();
    try {   // UserError (e.g. spend_energy(): "still busy with a long job") becomes a message, not the error page. The block below keeps its indent.
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'start') {
        if (isset($_POST['dest'])) {   // v0.9.3: set off along the whole route (the first leg is worked out server-side)
            require_once __DIR__ . '/includes/destination.php';
            [$ok, $msg] = dest_set_off($u, (int)$_POST['dest']);
        } else {
            [$ok, $msg] = start_expedition($u, (int)($_POST['route_id'] ?? 0));
        }
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'adventure.php' : 'world.php');
    }
    if ($do === 'dest_forget' || $do === 'dest_opts') {   // v0.9.3
        require_once __DIR__ . '/includes/destination.php';
        if ($do === 'dest_forget') { dest_set($uid, 0); flash('🧭 Route forgotten.', 'ok'); }
        else { dest_save_opts($uid); flash('🧭 Saved.', 'ok'); }
        redirect(safe_back($exp ? 'adventure.php' : 'world.php'));
    }
    if ($do === 'trail_resume') {   // graphical navigation 2d: pick a put-away walk up again
        [$ok, $msg] = trail_resume($u);
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'adventure.php' : 'here.php');
    }
    if ($do === 'explore') {
        [$ok, $msg] = explore_start($u);
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'adventure.php' : 'world.php');
    }
    if ($do === 'explore_back' || $do === 'explore_road') {   // v0.7.61: from a place you found off the path
        require_once __DIR__ . '/includes/explore.php';
        [$ok, $msg] = explore_come_back($u, $do === 'explore_road' ? 'road' : 'wild');
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? ($do === 'explore_road' ? (gnav_on() ? 'here.php' : 'world.php') : 'adventure.php') : (gnav_on() ? 'here.php' : 'town.php'));
    }
    if (!$exp) redirect('world.php');

    db()->beginTransaction();
    // v1.2.2: lock this gnome first (serialises two logins), refresh the user row, THEN re-read the expedition
    q('UPDATE users SET id = id WHERE id = ?', [$uid]);
    if ($fresh = q_one('SELECT * FROM users WHERE id = ?', [$uid])) $u = array_merge($u, $fresh);
    // Re-read inside the transaction so two quick clicks can't both act on the same step
    $exp = q_one("SELECT * FROM expeditions WHERE id = ? AND user_id = ? AND status = 'active'", [$exp['id'], $uid]);
    if ($exp) {
        road_bind($u, $exp);   // v1.9.3: the recent-picks memory, read after the lock above and written (road_flush) before the commit below
        $enc = $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
        if ($enc && $enc['type'] === 'creature' && pfight_on($u)) {   // puzzle combat: only its own actions count (an old attack button from a stale page does nothing)
            if ($do === 'pfb_preview') pfight_preview_out($u, $exp);   // read only; answers JSON and exits
            if ($do === 'pfb_cells') pfight_cells_out($u, $exp);   // read only: the numbers for each lit spot
            if (in_array($do, ['pf_play', 'pfb_play', 'pfb_pass', 'pf_run', 'pf_redraw', 'pf_finish'], true)) {
                $fev0 = fight_ev_start($exp, $enc); fight_ev();   // the end scene (the chest and the loot drawn in) is kept for the next page, like the old fight's
                pfight_do($u, $exp, $do);
                fight_ev_save($fev0, $exp);
            }
        } elseif ($enc && $enc['type'] === 'creature') {
            $fev0 = fight_ev_start($exp, $enc); fight_ev();   // fight events for the fight scene: both sides' health now, then whatever this action records
            if (in_array($do, ['attack', 'ability', 'flee'], true) || preg_match('/^palskill:[a-z0-9_-]{1,48}$/', $do)) {   // v2.3.8: palskill:KEY = a rare pal's active
                combat_turn($u, $exp, $do);
            } elseif ($do === 'snack') {   // v1.4.0: one home-cooked snack, same transaction and lock as the rest
                combat_turn($u, $exp, 'snack', (int)($_POST['item'] ?? 0));
            } elseif ($do === 'hat' && fight_scene_on()) {   // fight_scene: tap the fallen hat, +5 health once, free
                fight_hat_pick($u, $exp);
            } elseif ($do === 'fighton') {   // v1.3.0: auto-attack until hurt, done, or 30 rounds (same transaction and lock as above)
                fight_on($u, $exp);
            } elseif ($do === 'auto') {
                $c = encounter_creature($enc);
                fight_prep($enc, $c);   // v1.3.0
                if (fight_certainty($u, $exp, $c, $enc)) auto_resolve($u, $exp);
            }
            fight_ev_save($fev0, $exp);
        } elseif ($enc && $enc['type'] === 'problem') {
            if ($do === 'solve') solve_problem($u, $exp, (int)($_POST['option'] ?? -1));
        } elseif ($enc && $enc['type'] === 'choice') {
            if ($do === 'choose') explore_choose($u, $exp, (int)($_POST['option'] ?? -1));
        } elseif ($enc && $enc['type'] === 'meet') {   // v1.9.4: a villager or traveller met on the road
            if ($do === 'meet') road_meet_resolve($u, $exp, (int)($_POST['option'] ?? -1));
        } elseif (($exp['kind'] ?? 'walk') === 'delve' && ($dv2 = dv2_scene($exp))) {   // v2.3.1: the route menu and tile floors
            if ($do === 'route') {
                [$gok, $gmsg] = dv2_pick($u, $exp, $dv2, (string)($_POST['pick'] ?? ''));
            } elseif ($do === 'quick') {
                [$gok, $gmsg] = dv2_quick($u, $exp, $dv2);
            } elseif ($do === 'go') {
                [$gx, $gy] = array_map('intval', array_pad(explode(',', (string)($_POST['go'] ?? ''), 2), 2, '0'));
                [$gok, $gmsg] = dv2_walk($u, $exp, $dv2, $gx, $gy);
            } elseif ($do === 'leave') { delve_leave($u, $exp); $gok = true; $gmsg = ''; }
            elseif ($do === 'chest') { delve_chest($u, $exp); $gok = true; $gmsg = ''; }
            else { $gok = true; $gmsg = ''; }
            if (!$gok) flash($gmsg, 'err');
            elseif ($gmsg !== '') flash($gmsg, 'ok');   // hazard ground and wandering creatures say what happened
        } elseif (($exp['kind'] ?? 'walk') === 'delve') {
            if ($do === 'next') delve_next($u, $exp);
            elseif ($do === 'leave') delve_leave($u, $exp);
            elseif ($do === 'chest') delve_chest($u, $exp);
            elseif ($do === 'go') {   // v2.0.6: a tap on the map (walk there; a room tile goes into the room)
                [$gx, $gy] = array_map('intval', array_pad(explode(',', (string)($_POST['go'] ?? ''), 2), 2, '0'));
                [$gok, $gmsg] = dm_walk($u, $exp, $gx, $gy);
                if (!$gok) flash($gmsg, 'err');
            }
        } elseif (($exp['kind'] ?? 'walk') === 'lair') {   // v2.0.6: the boss has not risen yet (it waits at the end of the map)
            if ($do === 'go') {
                [$gx, $gy] = array_map('intval', array_pad(explode(',', (string)($_POST['go'] ?? ''), 2), 2, '0'));
                [$gok, $gmsg] = dm_walk($u, $exp, $gx, $gy);
                if (!$gok) flash($gmsg, 'err');
            } elseif ($do === 'lair_engage') lair_engage($exp);
            elseif ($do === 'leave') lair_leave($exp);
        } elseif (($exp['kind'] ?? 'walk') === 'explore') {
            $logBefore = count(json_decode((string)$exp['log'], true) ?: []);   // v1.3.0: a quiet step rests
            if ($do === 'deeper') explore_deeper($u, $exp);
            elseif ($do === 'roam') explore_deeper($u, $exp, 0);
            elseif ($do === 'back') explore_deeper($u, $exp, -1);
            elseif ($do === 'return') explore_return($u, $exp);
            elseif ($do === 'visit' && explore_visit($u, $exp, (int)($_POST['place'] ?? 0))) $visited = true;
            elseif ($do === 'gather') explore_gather($u, $exp, (string)($_POST['tool'] ?? ''));   // v0.7.80
            if (in_array($do, ['deeper', 'roam', 'back'], true)) rest_after_explore($exp, $logBefore);   // v1.3.0
        } elseif (in_array($do, ['trail_go', 'trail_next', 'trail_prev', 'trail_stay', 'trail_back', 'trail_arrive', 'trail_wander', 'trail_stance', 'gather', 'sight', 'sightgive', 'sightchat', 'sightgift'], true) && ($exp['kind'] ?? 'walk') === 'walk' && trail_scene($exp)) {   // graphical navigation 2d
            if ($do === 'trail_go') { $xy = explode(',', (string)($_POST['go'] ?? '')); [$tok, $tmsg] = trail_go($u, $exp, (int)($xy[0] ?? -1), (int)($xy[1] ?? -1)); }
            elseif ($do === 'trail_next') [$tok, $tmsg] = trail_next($u, $exp);
            elseif ($do === 'trail_prev') [$tok, $tmsg] = trail_prev($u, $exp);
            elseif ($do === 'trail_stay') [$tok, $tmsg] = trail_stay($u, $exp);
            elseif ($do === 'gather') [$tok, $tmsg] = trail_gather($u, $exp, (string)($_POST['tool'] ?? ''));
            elseif ($do === 'sight') { $sgp = fn(string $k): string => is_scalar($_POST[$k] ?? null) ? (string)$_POST[$k] : ''; [$tok, $tmsg] = trail_sight_do($u, $exp, $sgp('slug'), $sgp('pick') !== '' && ctype_digit($sgp('pick')) ? ['pick' => (int)$sgp('pick')] : []); }   // v2.6.68 Trail Sights (POST values may be arrays: only scalars count)
            elseif ($do === 'sightchat') { $sgp = fn(string $k): string => is_scalar($_POST[$k] ?? null) ? (string)$_POST[$k] : ''; [$tok, $tmsg] = trail_sight_folk_talk($u, $exp, 'chat', $sgp('fk')); }
            elseif ($do === 'sightgift') { $sgp = fn(string $k): string => is_scalar($_POST[$k] ?? null) ? (string)$_POST[$k] : ''; [$tok, $tmsg] = trail_sight_folk_talk($u, $exp, 'gift', $sgp('fk'), (int)$sgp('item_id')); }
            elseif ($do === 'sightgive') { $sgp = fn(string $k): string => is_scalar($_POST[$k] ?? null) ? (string)$_POST[$k] : ''; [$tok, $tmsg] = trail_sight_give($u, $exp, $sgp('slug'), $sgp('idx') !== '' && ctype_digit($sgp('idx')) ? (int)$sgp('idx') : -1); }   // v2.6.68 Trail Sights
            elseif ($do === 'trail_stance') [$tok, $tmsg] = trail_stance($u, $exp, (string)($_POST['mode'] ?? ''));
            elseif ($do === 'trail_wander') { [$tok, $tmsg] = trail_wander($u, $exp); }
            elseif ($do === 'trail_back') { [$tok, $tmsg] = trail_back($u, $exp); $visited = true; }
            elseif (trail_can_arrive($exp)) { arrive($u, $exp); dm_scene_drop((int)$exp['id']); $arrivedAt = (int)$exp['to_id']; $tok = true; $tmsg = ''; }
            else { $tok = false; $tmsg = 'Not there yet.'; }
            if (!$tok && $tmsg !== '') flash($tmsg, 'err');
            elseif ($tok && in_array($do, ['trail_back', 'trail_wander', 'trail_stance'], true)) flash($tmsg, 'ok');
        } elseif ($do === 'continue' && (int)$exp['step'] < (int)$exp['steps_total'] && !(($exp['kind'] ?? 'walk') === 'walk' && trail_scene($exp))) {   // a tile walk is only walked on its map (trail_go ...), never by the old step button
            next_step($u, $exp);
        } elseif ($do === 'arrive' && (int)$exp['step'] >= (int)$exp['steps_total'] && ts($exp['arrive_at']) <= time() && !(($exp['kind'] ?? 'walk') === 'walk' && trail_scene($exp))) {
            arrive($u, $exp);
            $arrivedAt = (int)$exp['to_id'];
        }
        // A lair fight is over when the boss is gone: a win (defeated or befriended) or a getaway (v0.7.26)
        if (($exp['kind'] ?? '') === 'lair' && $exp['status'] === 'active' && !$exp['encounter'] && (int)$exp['depth'] >= 1) {   // v2.0.6: depth 0 = the boss has not risen yet
            $recent = array_slice(json_decode((string)$exp['log'], true) ?: [], -8);
            if (!empty($exp['_won']) || preg_grep('/ is (defeated|befriended)!/u', $recent)) lair_victory($u, $exp);   // _won: set by win_fight (a long run of level-up and drop lines could push the "defeated" line out of the last 8)
            else { $exp['status'] = 'done'; exp_log($exp, '🏃 You escape the lair in one piece.'); }
        }
        save_exp($exp);
        road_flush();
    }
    db()->commit();
    if (!empty($visited)) redirect(gnav_on() ? 'here.php' : 'town.php');   // turned back: the place you left is the Here page
    // After arriving, send the player straight to the destination page
    if (!empty($arrivedAt)) {
        require_once __DIR__ . '/includes/destination.php';   // v0.9.3: keep walking to the next stop of the route
        $chain = dest_chain_after_arrival($uid);
        if ($chain) {
            flash($chain[1], 'ok');
            if ($chain[0]) redirect('adventure.php');
        }
        // v2.5.63: the GPS stops at every stop, pass-through places included, so there is no skipping ahead to the next "Head into" card any more
        $dest = q_one('SELECT kind FROM locations WHERE id = ?', [$arrivedAt]);
        $kind = $dest['kind'] ?? '';
        // v0.7.61: every place has its page on town.php (town square, rest stop, haven…). local.php never existed.
        redirect(gnav_on() && $kind !== '' ? 'here.php' : ($kind === 'hub' ? 'town.php?hub=1' : ($kind ? 'town.php' : 'world.php')));   // arrived: the Here page of the place
    }
    redirect(safe_back('adventure.php'));
    } catch (UserError $e) {
        if (db()->inTransaction()) db()->rollBack();
        flash($e->getMessage(), 'err');
        redirect(safe_back('adventure.php'));
    }
}
if (!$exp && trail_resume_offer($u)) { [$rok, $rmsg] = trail_resume($u); flash($rmsg, $rok ? 'ok' : 'err'); redirect('adventure.php'); }   // the wander is over: back to the Trail, no page to click through
refresh_energy($u);   // v2.3.94: a GET showed the energy from the last POST ("too tired" after a rest)

// Show the last finished expedition's log if there's no active one
$last = $exp ?: q_one('SELECT * FROM expeditions WHERE user_id = ? ORDER BY id DESC LIMIT 1', [$uid]);
if (!$last) redirect('world.php');
$from = q_one('SELECT * FROM locations WHERE id = ?', [$last['from_id']]);
$to = q_one('SELECT * FROM locations WHERE id = ?', [$last['to_id']]);
$scene = exp_scene($last);
$quickRoute = false;   // v0.9.7: say so when this walk is a quick one
if (($last['kind'] ?? 'walk') === 'walk' && ($qr = q_one('SELECT * FROM routes WHERE id = ?', [(int)$last['route_id']]))) [, $quickRoute] = route_walk_minutes($u, $qr);
$log = json_decode((string)$last['log'], true) ?: [];
road_bind($u, $last);   // v1.9.3: read-only on a page view (road_flush is never called here), so the line above the button is the one the next step will log
$enc = $exp && $exp['encounter'] ? json_decode((string)$exp['encounter'], true) : null;
$gc = gnome_combat($u, true);
$L = LANDSCAPES[$scene['land']] ?? ['🌱', 'Wilds', ''];
$dmScene = ($exp && dm_on()) ? dm_scene($exp) : null;   // v2.0.6: a delve or lair that has a map (the list still works for it)
$mapMode = $dmScene && dm_pref() === 'map';
$trailSc = $exp ? trail_scene($exp) : null;   // graphical navigation 2d: a walk that began as tile sections stays one, even if gnav_tiles is switched off meanwhile
$dv2Scene = ($exp && ($exp['kind'] ?? '') === 'delve') ? dv2_scene($exp) : null;   // v2.3.1: a delve with the route menu and tile floors

function act(string $do, string $label, string $extra = '', string $class = ''): string
{
    return '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">' . $extra
        . '<button class="btn ' . e($class) . '">' . $label . '</button></form> ';
}

/** v1.6.3: a fight action as a .choice row inside its own POST form (the hidden "do" keeps working for scripts). */
function act_choice(string $do, string $icon, string $title, string $sub = '', $badge = '', string $cls = '', string $extra = '', string $attrs = ''): string
{
    return '<form method="post" class="choiceform">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">'
        . $extra . choice_row($icon, $title, $sub, $badge, $cls, $attrs) . '</form>';
}

/**
 * Optional pixel art for the wander card. A file that does not exist draws NOTHING (the emoji / plain header stays): no broken images.
 * scenes/wander-<land>.png banner (+ wander-deep.png for the Deep wilds, wander-wild.png for the Hard and Wild tiers), ico/wander-tier-<gentle|wild|dangerous|deep>.png (24 px),
 * ico/wander-<deeper|roam|back|return|visit>.png (24 px), ico/wander-found.png. Names in claude/todo.md (ART TODO: the wander area).
 */
function wander_art(string $rel, int $w, int $h, string $cls = ''): string
{
    static $have = [];
    if (!preg_match('~^[a-z0-9_/-]+\.png$~', $rel)) return '';
    $have[$rel] ??= is_file(__DIR__ . '/assets/img/' . $rel);
    return $have[$rel] ? '<img class="pix ' . e($cls) . '" src="' . e(url('assets/img/' . $rel)) . '" width="' . $w . '" height="' . $h . '" alt="" decoding="async">' : '';
}

/** The banner strip for the card's tier and land: the tier variant when drawn, else the land's strip, else ''. */
function wander_banner(string $tierKey, string $land): string
{
    $land = preg_replace('/[^a-z]/', '', strtolower($land));
    $first = match ($tierKey) { 'deep' => 'scenes/wander-deep.png', 'hard', 'wild' => 'scenes/wander-wild.png', default => '' };
    foreach (array_filter([$first, 'scenes/wander-' . $land . '.png', 'scenes/wander-generic.png']) as $rel) {   // v2.5.34: wander-generic.png is the strip for a land with none of its own
        if ($a = wander_art($rel, 480, 64, 'wc-banner-img')) return '<div class="wc-banner">' . $a . '</div>';
    }
    return '';
}

/** Wander off the Trail, nothing in front of you: one compact popover over the Trail section. Header, what just happened, the four moves, a gather fold. */
function wander_card_html(array $u, array $exp, array $last, array $log, array $from, array $L): string
{
    require_once __DIR__ . '/includes/explore.php';
    require_once __DIR__ . '/includes/gathering.php';
    $dep = (int)$exp['depth'];
    [$hereTier, $hereKey] = explore_tier(max(1, $dep));
    [$nextTier] = explore_tier($dep + 1);
    $nextLvl = explore_level($u, $dep + 1, $exp);
    $hereLvl = explore_level($u, max(1, $dep), $exp);
    $lastLine = $log ? (string)end($log) : '';
    $res = '';
    if ($lastLine !== '' && !str_contains($lastLine, 'You step off the Trail')) {
        [$cls, $ico, $title, $sub] = road_result_parts($lastLine);
        $res = '<div class="wc-res ' . e($cls) . '" aria-live="polite"><span class="wc-ico" aria-hidden="true">' . e($ico) . '</span><span><b>' . e($title) . '</b>' . ($sub !== '' ? '<small>' . e($sub) . '</small>' : '') . '</span></div>';
    } else {
        $res = '<div class="wc-res"><span>The wild mycelium stretches away from the road…</span></div>';
    }
    $btn = fn(string $do, string $ico, string $title, string $sub, string $cost, string $cls = '', string $extra = '') =>
        '<form method="post" class="wc-b">' . csrf_field() . '<input type="hidden" name="do" value="' . e($do) . '">' . $extra
        . '<button class="btn wc-btn ' . e($cls) . '"><span class="wc-bt">' . (wander_art('ico/wander-' . $do . '.png', 24, 24, 'wc-mv') ?: $ico) . ' ' . e($title) . '</span><small>' . e($sub) . '</small><i>' . e($cost) . '</i></button></form>';
    $o = '<dialog class="picker hubpop trailpop trailsmall wanderpop" id="trailpop" open aria-label="Off the Trail"><div class="pickbox"><div class="hubcard trailui wcard">'
        . wander_banner($hereKey, explore_land($exp))
        . wander_step_once('off')   // v2.5.49: the gnome stepping off the road, once, when art exists
        . '<div class="wc-head"><b>🌿 Off the Trail</b><span>' . $L[0] . ' ' . e($L[1]) . ' · step ' . $dep . ' · ' . wander_art('ico/wander-tier-' . (['gentle' => 'gentle', 'medium' => 'wild', 'hard' => 'dangerous', 'wild' => 'dangerous', 'deep' => 'deep'][$hereKey] ?? 'gentle') . '.png', 24, 24, 'wc-tier') . e($hereTier) . ' · danger ' . (int)$last['level'] . '</span></div>'
        . $res;
    $foundId = (int)($_SESSION['explore_found'] ?? 0);
    if ($foundId && ($fl = q_one('SELECT id, name FROM locations WHERE id = ?', [$foundId]))) {
        $o .= wander_art('ico/wander-found.png', 24, 24, 'wc-found') . '<div class="wc-grid">' . $btn('visit', '🚶', 'Visit ' . $fl['name'], 'then come back', 'free', 'primary', '<input type="hidden" name="place" value="' . $foundId . '">') . '</div>';
    }
    $o .= '<div class="wc-grid">'
        . $btn('deeper', '🌿', 'Go deeper', $nextTier . ' · danger ' . $nextLvl, '⚡1', 'primary')
        . ($dep >= 1 ? $btn('roam', '🔁', 'Keep exploring', $hereTier . ' · danger ' . $hereLvl, '⚡1') : '')
        . ($dep >= 2 ? $btn('back', '↩️', 'Step back', explore_tier($dep - 1)[0], '⚡1') : '')
        . $btn('return', '🛣️', 'Back to the Trail', 'free · keep everything', 'free', 'alt')
        . '</div>';
    if ($dep >= 1) $o .= '<details class="wfold wgather"><summary>🧺 Gather here</summary>' . gather_here_box($u, explore_land($exp), url('adventure.php'), '') . '</details>';
    $o .= '<p class="help wc-foot">Knocked out? You wake on the road with all your things.</p></div></div></dialog>';
    return $o;
}

page_header('On the mycelium');
// graphical navigation 2d: Wander off the Trail plays in a popover over the Trail's section; when the wander ends the walk is picked up again
$wanderView = null;
if ($exp && ($exp['kind'] ?? '') === 'explore' && ($snap = trail_snapshot($u))) $wanderView = trail_snapshot_view($u, $snap, $exp);
if ($wanderView) {
    $wOver = $exp && fight_scene_on() && (($enc && ($enc['type'] ?? '') === 'creature' && !pfight_on($u)) || fight_finale_pending($exp));   // (a puzzle fight never draws the old stage)   // a fight off the Trail still plays on the map behind it
    echo '<div class="wanderbehind">' . trail_view_html($u, $wanderView[0], $wanderView[1], true, $wOver, $exp) . '</div>';
    if (!$enc) { echo wander_card_html($u, $exp, $last, $log, $from, $L); page_footer(); exit; }   // nothing in front of you: the purpose-built wander card
    ob_start();   // something in front of you: the usual encounter popover (fight, choice, meeting), the old page hidden behind it
}
?>
<?php $isExplore = ($last['kind'] ?? 'walk') === 'explore'; $kind = $last['kind'] ?? 'walk'; $isWalk = !in_array($kind, ['delve', 'lair', 'explore'], true);   // v2.0.51: a road walk gets the route ribbon instead of the heading, status line and route strip ?>
<?php if ($kind === 'delve' || $kind === 'lair'): ?>
<h1><?= $kind === 'delve' ? '🕳️' : '🐉' ?> <?= e($from['name']) ?></h1>
<p class="status<?= $dv2Scene ? ' dv2status' : '' ?>">
  <?= $kind === 'delve' ? ($dv2Scene ? 'Stage <b>' . min((int)$last['steps_total'], (int)$last['depth'] + 1) . '</b>/' . (int)$last['steps_total'] : 'Room <b>' . (int)$last['depth'] . '</b>/' . DELVE_ROOMS) . ' · ' : '' ?>danger level <?= (int)$last['level'] ?>
<?php elseif ($isExplore): [$tierName] = explore_tier((int)$last['depth']); ?>
<h1>🌿 Off the path near <?= e($from['name']) ?></h1>
<?php require_once __DIR__ . '/includes/seek.php'; echo seek_chip($u, $exp);   // v0.7.97 ?>
<p class="status">
  <?= $L[0] ?> <?= e($L[1]) ?> · <b><?= (int)$last['depth'] ?></b> step<?= (int)$last['depth'] === 1 ? '' : 's' ?> out · <?= e($tierName) ?> · danger level <?= (int)$last['level'] ?>
<?php endif; ?>
<?php /* v1.6.3: ❤️/⚡ dropped here: the walk bar, top bar and fight card already show them */ ?>
<?php if (!$isWalk): ?></p><?php endif; ?>
<?php require_once __DIR__ . '/includes/maps.php'; require_once __DIR__ . '/includes/destination.php';
$wi = $exp ? dest_walk_info($u, $exp) : null;   // v0.9.3
if ($wi && !$isWalk): ?>
<div class="routestrip"><div class="routestrip-summary">🏁 <b><?= e(dest_name($uid, $wi['loc'])) ?></b> · leg <?= (int)$wi['k'] ?> of <?= (int)$wi['n'] ?> · <?= (int)$wi['left'] ?> stop<?= (int)$wi['left'] === 1 ? '' : 's' ?> left</div>
  <p class="routeopts"><?= dest_opts_html($u) ?></p>
</div>
<?php endif; ?>
<?php $hasMap = $trailSc || $wanderView || $mapMode || ($dv2Scene && $dv2Scene['map']); $fighting = $enc && $enc['type'] === 'creature'; $wander = $isExplore && $exp && !$fighting;   // v2.1.11: the phone wander layout (map left, info right, actions in a grid, gather in a fold); v2.1.12: event cards use it too ?>
<div class="advgrid<?= $isExplore ? ' withrings' : '' ?><?= $fighting ? ' fighting' : '' ?><?= $fighting && $hasMap && fight_scene_on() && !pfight_on($u) ? ' fsover' : '' ?><?= $wander ? ' wander' : '' ?><?= $fighting && pfight_on($u) ? ' pfover' : '' ?>">
<div class="mapcol"<?= $fighting && pfight_on($u) ? ' inert aria-hidden="true"' : '' ?>>
<?php $pfAct = $fighting && pfight_on($u);   // puzzle combat: no old stage, no old dock
$fsc = $fighting && fight_scene_on() && !$pfAct;   // fight_scene: the animated stage replaces the picture and the popover for a creature fight
$overMap = $exp && fight_scene_on() && (($fighting && !$pfAct) || fight_finale_pending($exp));   // a fight (or its end scene) is drawn over whichever map the page shows
if ($exp && $overMap && !$fighting && !$hasMap) echo fight_finale_html($u, $exp, null);   // no map on the page (the list): the end scene plays on a stage of its own
$evStage = $exp && !$trailSc && !$hasMap && fight_scene_on() && $enc && in_array($enc['type'] ?? '', ['choice', 'problem'], true);   // an event or a skill check stands on the same stage
if ($evStage) { echo fight_event_html($u, $enc); }
elseif ($exp && !$trailSc && !$fsc && !$pfAct && !($overMap && !$hasMap)) { echo adventure_stage_html($u, $exp, $scene, $enc); }   // the tile page has no scene picture: the map is the picture ?>
<?php if ($dv2Scene): // v2.3.1: the floor you are on, or the route menu between floors ?>
<?php if ($dv2Scene['map']): ?><?= dv2_floor_html($u, $exp, $dv2Scene, (bool)$enc, $overMap) ?>
<?php elseif ($dv2Scene['st']['q']): ?><?= dv2_quick_html($dv2Scene) ?>
<?php else: ?><?= dv2_menu_html($u, $exp, $dv2Scene, (bool)$enc) ?>
<?php endif; ?>
<?= dv2_party_html($u, $exp, $dv2Scene) ?>
<?php elseif ($mapMode): // v2.0.6: the map is the default; the list is one tap away ?>
<?= dm_view_html($u, $exp, $dmScene, (bool)$enc, $overMap) ?>
<p class="tmlinks"><a data-inplace href="<?= e(url('adventure.php?view=list')) ?>">Use the simple list</a></p>
<?php elseif ($trailSc): ?>
<?= trail_view_html($u, $exp, $trailSc, (bool)$enc, $overMap) ?>
<?php $tLand0 = (string)(exp_scene($exp)['land'] ?? 'grassland'); ?><div class="trailui">
  <div class="trailfoot">
    <a class="btn" data-pop="hubpop-tgather" href="<?= e(url('adventure.php?g=1')) ?>">🧺 Gather here</a>
    <?php if (empty($exp['encounter']) && trail_fish_here($trailSc)): /* v2.7: on or beside water the rod gets its own button */ ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="gather"><input type="hidden" name="tool" value="rod"><button class="btn trailfish">🎣 Fish <small>⚡1</small></button></form><?php endif; ?>
    <?php $sgMarks = empty($exp['encounter']) ? trail_sights_marks($u, $trailSc) : []; if ($sgMarks): ?><a class="btn alt trailsights" data-pop="hubpop-tsights" href="<?= e(url('adventure.php?sg=1')) ?>">🔎 Sights <small><?= count($sgMarks) ?></small></a><?php endif; ?>
    <?php if (empty($exp['encounter'])) foreach (trail_sights_here($u, $trailSc) as [$sgRow, $sgLeft, $sgWhy]): /* v2.6.68: next to a big set piece: its own button (data/trail_sights.txt) */ ?><?php if (trail_sight_pick_info($sgRow) && $sgLeft > 0): ?><a class="btn trailsight" data-pop="hubpop-tsights" href="<?= e(url('adventure.php?sg=1')) ?>"><?= e($sgRow['icon']) ?> <?= e($sgRow['verb']) ?> <small>choose</small></a><?php else: ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="sight"><input type="hidden" name="slug" value="<?= e($sgRow['slug']) ?>"><button class="btn trailsight"<?= $sgLeft < 1 ? ' disabled title="' . e($sgWhy) . '"' : '' ?>><?= e($sgRow['icon']) ?> <?= e($sgRow['verb']) ?> <small><?= $sgLeft < 1 ? e($sgWhy) : '⚡' . (int)$sgRow['energy'] ?></small></button></form><?php endif; ?><?php endforeach; ?>
    <?php if (on_road((int)$exp['from_id'])): ?><a class="btn alt" data-pop="hubpop-twander" href="<?= e(url('adventure.php?w=1')) ?>">🌿 Wander off <small>⚡1</small></a><?php endif; ?>
    <?php $stance = (string)($trailSc['st']['stance'] ?? ''); foreach (empty($exp['encounter']) ? ['sneak' => '🤫 Sneak', 'hunt' => '🏹 Hunt'] : [] as $sm => $sl): ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="trail_stance"><input type="hidden" name="mode" value="<?= $sm ?>"><button class="btn<?= $stance === $sm ? '' : ' alt' ?>" aria-pressed="<?= $stance === $sm ? 'true' : 'false' ?>"><?= $sl ?></button></form><?php endforeach; ?>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="trail_back"><button class="btn alt">↩️ Turn back</button></form>
  </div>
  <?php if (on_road((int)$exp['from_id'])): ?><dialog class="picker hubpop trailsmall" id="hubpop-twander" aria-labelledby="hubpop-twander-t"<?= !empty($_GET['w']) ? ' open' : '' ?>><div class="pickbox">
    <div class="pickhead"><h3 id="hubpop-twander-t">🌿 Wander off the Trail?</h3><a class="pickx" href="<?= e(url('adventure.php')) ?>" data-pop-close aria-label="Close">✕</a></div>
    <div class="hubcard trailui"><p class="help">Leave the Trail for the wilds. ⚡1. Your walk waits for you on the road, and you can resume it from there.</p>
      <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="trail_wander"><button class="btn">🌿 Wander off <small>⚡1</small></button></form>
      <a class="btn alt" href="<?= e(url('adventure.php')) ?>" data-pop-close>Stay on the Trail</a></div></div></dialog><?php endif; ?>
  <?php if (!empty($sgMarks)): ?><dialog class="picker hubpop" id="hubpop-tsights" aria-labelledby="hubpop-tsights-t"<?= !empty($_GET['sg']) ? ' open' : '' ?>><div class="pickbox">
    <div class="pickhead"><h3 id="hubpop-tsights-t">🔎 Sights here</h3><a class="pickx" href="<?= e(url('adventure.php')) ?>" data-pop-close aria-label="Close">✕</a></div>
    <div class="hubcard sgcards"><?= trail_sights_cards_html($u, $trailSc, $sgMarks, $exp) ?></div></div></dialog><?php endif; ?>
  <?php foreach (!empty($sgMarks) ? trail_sights_folk_on_map($u, $exp, $trailSc, $sgMarks) : [] as $fi => $fe): /* v2.6.68: tap a villager out and about at a Sight: their card (chat, gift) */ ?><dialog class="picker hubpop" id="hubpop-tfolk-<?= (int)$fi ?>" aria-labelledby="hubpop-tfolk-<?= (int)$fi ?>-t"><div class="pickbox">
    <div class="pickhead"><h3 id="hubpop-tfolk-<?= (int)$fi ?>-t">💬 <?= e((string)$fe[3]) ?></h3><a class="pickx" href="<?= e(url('adventure.php')) ?>" data-pop-close aria-label="Close">✕</a></div>
    <div class="hubcard sgcards"><?= trail_sight_folk_card_html($u, $fe, $trailSc) ?></div></div></dialog><?php endforeach; ?>
  <dialog class="picker hubpop" id="hubpop-tgather" aria-labelledby="hubpop-tgather-t"<?= !empty($_GET['g']) ? ' open' : '' ?>><div class="pickbox">
    <div class="pickhead"><h3 id="hubpop-tgather-t">🧺 Gather here</h3><a class="pickx" href="<?= e(url('adventure.php')) ?>" data-pop-close aria-label="Close">✕</a></div>
    <div class="hubcard"><?= gather_here_box($u, $tLand0, url('adventure.php'), '') ?></div></div></dialog>
</div>
<?php elseif ($isWalk): ?>
<?= route_ribbon_html($u, $last, $wi, (int)$scene['level']) ?>
<?php else: ?>
<div class="mapwrap small">
<?php if (in_array($kind, ['delve', 'lair'], true)): ?><?= mycelium_track($last) ?>
<?php else: ?><?= journey_map_svg($u, $last) ?>
<?php endif; ?>
</div>
<?php if ($dmScene): ?><p class="tmlinks"><a data-inplace href="<?= e(url('adventure.php?view=map')) ?>">🗺️ Show the map</a></p><?php endif; ?>
<?php endif; ?>
<?php if ($wander): [$wTier] = explore_tier(max(1, (int)$last['depth'])); ?>
<div class="wanderinfo"><b>🌿 Off the path near <?= e($from['name']) ?></b><br><?= $L[0] ?> <?= e($L[1]) ?> · <?= (int)$last['depth'] ?> step<?= (int)$last['depth'] === 1 ? '' : 's' ?> out · <?= e($wTier) ?> · danger <?= (int)$last['level'] ?></div>
<?php endif; ?>
<?php ob_start();   // v2.0.52: the latest result is built here and shown at the top of the action card
$rcIcons = array_merge(['✅', '❌', '👉', '✨', '🪙', '🧺', '🌱', '🎁', '👛', '💬', '👋'], road_sight_icons());   // v1.9.4: the sights come from road_events.txt
$lastLine = $log ? (string)end($log) : '';
$resultCard = ($exp && !$enc && $lastLine !== '' && !str_contains($lastLine, 'You step onto the mycelium') && in_array(preg_match('/^(\X)\s/us', $lastLine, $rm) ? $rm[1] : '', $rcIcons, true)) ? road_result_parts($lastLine) : null;
if ($resultCard): ?>
  <div class="roadresult <?= e($resultCard[0]) ?>" aria-live="polite"><span class="rr-ico" aria-hidden="true"><?= e($resultCard[1]) ?></span><span class="rr-body"><b class="rr-title"><?= e($resultCard[2]) ?></b><?php if ($resultCard[3] !== ''): ?><small class="rr-sub"><?= e($resultCard[3]) ?></small><?php endif; ?></span></div>
<?php elseif ($log && !($enc && in_array($enc['type'] ?? '', ['choice', 'meet', 'problem'], true))): // v0.7.61: what just happened, right under the map so you don't have to scroll to the journal (v1.9.4: not while the card says the same thing) ?>
  <div class="advlatest" aria-live="polite"><b>Latest:</b> <?= e((string)end($log)) ?></div>
<?php endif;
$latestHtml = ob_get_clean(); if ($fighting) $latestHtml = '';
$gvCarrier = function (string $html) use ($exp, $log): string {   // the "what just happened" line as a hidden carrier that site.js (gvPageToasts) turns into a toast and/or a pop-up over the map
    $txt = trim(html_entity_decode(strip_tags(str_replace(['</b>', '</small>'], ' ', $html)), ENT_QUOTES | ENT_HTML5));
    $txt = trim(preg_replace('/^Latest:\s*/u', '', $txt));
    return $txt === '' ? '' : '<div hidden data-gvtoast="' . (int)($exp['id'] ?? 0) . ':' . count($log) . ':' . crc32((string)end($log)) . '">' . e($txt) . '</div>';
};
if (!$enc && $latestHtml !== '') {
    if ($trailSc || $mapMode || ($dv2Scene && $dv2Scene['map'])) $latestHtml = $gvCarrier($latestHtml);   // a tile map page (Trail, delve): one toast box + a pop-up over the map, no card in the page
}
?>
<?php if ($isWalk && !$mapMode) echo route_fold_html($u, $last, $wi); ?>
</div>


<?php $trailPop = ($trailSc || $mapMode || $dv2Scene || $wanderView) && $enc && !$fsc;   // on every tile map the encounter (a fight above all) is a popover over the screen, sized to it; it cannot be closed until it is settled
if ($trailPop): ?><dialog class="picker hubpop trailpop" id="trailpop" open aria-label="<?= $enc['type'] === 'creature' ? 'A fight' : 'Something in your way' ?>"><div class="pickbox"><div class="hubcard trailui"><?= $pfAct ? '' : adventure_stage_html($u, $exp, $scene, $enc, 'fight', 'fightstage') /* the battle backdrop (placeholder art: scenes/fight-<land>.png) */ ?><?php endif; ?>
<div class="panel box encounter">
<?= fight_replay_stage((int)$last['id']) ?>   <?php // v1.4.0: Fight on replay, played by assets/fighton.js ?>
<?= $latestHtml ?>
<?php if (!$exp): ?>
  <?php if ($last['status'] === 'done' && $kind === 'delve'): ?>
    <h3>🪜 You’re back out at <?= e($from['name']) ?>.</h3>
  <?php elseif ($last['status'] === 'done' && $kind === 'lair'): ?>
    <h3>🐉 You walk out of <?= e($from['name']) ?>.</h3><p class="help">See the journal for how it went.</p>
  <?php elseif ($last['status'] === 'done' && $isExplore): ?>
    <h3>🛣️ You’re back on the road at <?= e($from['name']) ?>.</h3>
  <?php elseif ($last['status'] === 'done'): ?>
    <h3>🏡 You’ve arrived at <?= e($to['name']) ?>.</h3>
  <?php else: ?>
    <?php if (fight_scene_on()) echo fight_finale_html($u, $last, null);   // the knock-out plays on the stage first (nothing is shown if the record is gone) ?>
    <h3>💫 Knocked out!</h3><p>You woke up back in <?= e($from['name']) ?>. Nothing was lost except a little energy and pride.</p>
  <?php endif; ?>
  <p><a class="btn" href="<?= e(url('world.php')) ?>">Look around</a></p>

<?php elseif ($enc && $enc['type'] === 'creature' && pfight_on($u)):
    $c = encounter_creature($enc); fight_prep($enc, $c); ?>
  <?= pfight_html($u, $exp, $enc, $c) ?>

<?php elseif ($enc && $enc['type'] === 'creature'):
    $c = encounter_creature($enc);
    fight_prep($enc, $c);   // v1.3.0: show the eased health
    $sure = fight_certainty($u, $exp, $c, $enc);
    [$abName, $abDesc] = CALLING_ABILITIES[$u['calling'] ?? ''] ?? CALLING_ABILITIES['']; ?>
  <?php // v0.7.61: one box; reversed in 2.2.1 so you are on the left, under your gnome on the stage, and the foe on the right under theirs ?>
  <?php if ($fsc): if (!$hasMap) echo fight_scene_html($u, $exp, $enc, $c) . fight_dock_html($u, $exp, $enc, $c, 'b', false);   // off the Trail the dock sits right under the stage (the stage is short: over it the lists would hide the fight); the Trail's own is over the map in trail_view_html;   // on the Trail the stage sits over the map itself (trail_view_html) ?>
  <small class="muted fs-line">⚡ <?= (int)$u['energy'] ?> · ⚔️ +<?= $gc['atk'] ?> · 🛡️ <?= $gc['ac'] ?> · 🎲 d<?= $gc['dmg_die'] ?>+<?= $gc['dmg_bonus'] ?> · foe ⚔️ +<?= (int)$c['attack'] ?> 🛡️ <?= (int)$c['defense'] ?><?= $enc['poison'] ? ' · 🧪 poisoned' : '' ?></small>
  <?php else: ?>
  <div class="fightgrid">
    <div class="fcard you">
      <div class="fname"><?= gnome_avatar_pals($u, 30) ?> <b><?= e(gnome_name($u)) ?></b></div>
      <small class="muted">gnome level <?= (int)$u['level'] ?></small>
      <div class="fbar">❤️ <progress max="<?= (int)$exp['max_hp'] ?>" value="<?= max(0, (int)$exp['hp']) ?>"></progress> <?= max(0, (int)$exp['hp']) ?>/<?= (int)$exp['max_hp'] ?></div>
      <small>⚡ <?= (int)$u['energy'] ?> · ⚔️ +<?= $gc['atk'] ?> · 🛡️ <?= $gc['ac'] ?> · 🎲 d<?= $gc['dmg_die'] ?>+<?= $gc['dmg_bonus'] ?><?= $enc['bark'] ? ' · 🌳 ' . (int)$enc['bark'] : '' ?></small>
    </div>
    <div class="fcard foe">
      <div class="fname"><span class="bigfoe"><?php require_once __DIR__ . '/includes/items.php'; $cim = creature_image((string)($c['slug'] ?? ''), true);   // v1.5.2: or its placeholder echo $cim !== '' ? art_img($cim, 'lg', (string)$c['name']) : creature_icon((string)$c['name'], (string)$c['size']); ?></span> <b><?= e($c['name']) ?></b></div>
      <small class="muted"><?= e($c['size']) ?> · level <?= (int)$c['level'] ?></small>
      <div class="fbar">❤️ <progress max="<?= (int)$enc['max'] ?>" value="<?= max(0, (int)$enc['hp']) ?>"></progress> <?= max(0, (int)$enc['hp']) ?>/<?= (int)$enc['max'] ?></div>
      <small>⚔️ +<?= (int)$c['attack'] ?> · 🛡️ <?= (int)$c['defense'] ?><?= $enc['poison'] ? ' · 🧪 poisoned' : '' ?></small>
    </div>
  </div>
  <?php endif; ?>
  <details class="helpfold"><summary>About the <?= e($c['name']) ?></summary><p><i><?= e($c['description']) ?></i></p></details>
  <?= fight_card_extra($u, $exp, $enc, 3, true) ?>
  <?php // v1.6.3: fight actions are .choice rows; what each one does sits in its sub line (it used to be a help paragraph)
    $hitPct = (int)fight_odds($u, $exp, $enc)['hit'];
    $runPct = max(0, min(100, (21 - (8 + intdiv((int)$c['level'], 3) - eff_mod($u, 'nimble'))) * 5)); ?>
  <?php if (!$fsc): ?>   <?php // with the fight scene the buttons are the dock (over the map on the Trail, over the stage elsewhere); the plain list is for the old popover/picture fight ?>
  <div class="fightbtns choicelist">
  <?= act_choice('attack', '⚔️', 'Attack', 'd' . $gc['dmg_die'] . '+' . $gc['dmg_bonus'] . ' damage · +' . $gc['atk'] . ' vs 🛡️ ' . (int)$c['defense'], [$hitPct . '%', choice_odds_class($hitPct)], 'primary') ?>
  <?= $enc['used'] ? act_choice('ability', '✨', $abName, 'Used this fight', '', '', '', 'disabled') : act_choice('ability', '✨', $abName, $abDesc . ' Once per fight.') ?>
  <?php if (ppal_boons_on()): foreach (ppal_fight_actives($u, $enc) as $pa): ?><?= $pa['used'] ? act_choice($pa['do'], '✨', $pa['title'], 'Used this fight', '', '', '', 'disabled') : act_choice($pa['do'], '✨', $pa['title'], $pa['sub']) ?><?php endforeach; endif; ?>
  <?= act_choice('flee', '🏃', 'Run', 'Slip away, no reward · Nimble check', [$runPct . '%', choice_odds_class($runPct)]) ?>
  <?php if (can_fight_on($exp)): ?><?= act_choice('fighton', '⏩', 'Fight on', 'Keeps attacking (no ability) until the fight ends, you drop under half health, or 30 rounds.') ?><?php endif; ?>
  <?= fight_snack_picker($u, $exp, $enc, fn($do, $label, $extra) => act_choice($do, '🎒', 'Snack', 'Eats a home-cooked snack: heals ' . (int)setting('fight_snack_heal_mult') . '× its energy. Uses your turn; ' . snack_limit($u) . ' a fight.', '', '', $extra)) ?>   <?php // v1.4.0 ?>
  <?php if ($sure === 'win'): ?>   <?php // v1.3.0: Auto only for a sure win ?>
    <?= act_choice('auto', '⏩', 'Auto-win', 'A sure win: the fight plays out for you.', ['sure', 'cost']) ?>
  <?php endif; ?>
  </div>
  <?php endif; ?>

<?php elseif ($enc && $enc['type'] === 'choice'):
    $ch = road_event_get($enc) ?? road_events()['ev'][array_key_first(road_events()['ev'])];
    $kindLabel = ROAD_KIND_LABEL[$ch['kind'] ?? 'choice'] ?? '';   // v2.0.79: fork / riddle / trade / chain / sketch
    $order = isset($enc['ord']) && count((array)$enc['ord']) === count($ch['opts']) ? array_map('intval', (array)$enc['ord']) : array_keys($ch['opts']); ?>
  <div class="scenecard">
  <?php if ($kindLabel !== ''): $kimg = 'assets/img/roadkinds/' . ($ch['kind'] ?? '') . '.png'; ?><p class="help roadkind"><?= pixel_has($kimg) ? '<img class="ico pix roadkindimg" src="' . e(url($kimg)) . '" alt="" width="24" height="24"> ' : '' ?><?= e($kindLabel) ?></p><?php endif; ?>
  <h3><span class="bigfoe"><?= e($ch['icon']) ?></span> <?= e($ch['text']) ?></h3>
  <p class="help"><?= ($ch['kind'] ?? '') === 'riddle' ? 'Which answer is right?' : (($ch['kind'] ?? '') === 'trade' ? 'Will you trade?' : 'What do you do?') ?></p>
  </div>
  <div class="choicelist">
  <?php foreach ($order as $i): $o = $ch['opts'][$i];   // v1.9.3: .choice rows with the odds badge, like the fight and the problems
      $rolls = $o['stat'] !== '' && isset(GNOME_STATS[$o['stat']]);
      $icon = '👉'; $sub = 'No roll needed'; $badge = ''; $off = '';
      if ($rolls) {
          $dc = (int)$o['dc'] + intdiv(max(1, (int)$exp['depth']) - 1, 2);
          $mod = eff_mod($u, $o['stat']);
          $chance = max(5, min(100, (21 - ($dc - $mod)) * 5));
          $icon = GNOME_STATS[$o['stat']][1];
          $sub = GNOME_STATS[$o['stat']][0] . ' ' . ($mod >= 0 ? '+' : '') . $mod . ' vs ' . $dc;
          $badge = [$chance . '%', choice_odds_class($chance)];
      } elseif ($o['stat'] === '!') { $sub = ''; }
      foreach (explode('+', (string)$o['win']) as $part) {   // v2.0.79: a trade or a toll shows its price and is off when you cannot pay it
          $pp = explode(':', trim($part));
          if ($pp[0] === 'pay' && (int)($pp[1] ?? 0) > 0) { $sub .= ($sub !== '' ? ' · ' : '') . 'costs ' . money((int)$pp[1]); if ((int)$u['coins'] < (int)$pp[1]) $off = ' disabled'; }
          if ($pp[0] === 'take' && isset($pp[1])) {
              $need = max(1, (int)($pp[2] ?? 1));
              $haveN = (int)q_val('SELECT COALESCE(SUM(ui.qty), 0) FROM user_items ui JOIN items it ON it.id = ui.item_id WHERE ui.user_id = ? AND it.slug = ?', [(int)$u['id'], $pp[1]]);
              $sub .= ($sub !== '' ? ' · ' : '') . 'give ' . $need . ' × ' . (string)(q_val('SELECT name FROM items WHERE slug = ?', [$pp[1]]) ?: $pp[1]) . ' (you have ' . $haveN . ')';
              if ($haveN < $need) $off = ' disabled';
          }
      } ?>
    <?= act_choice('choose', $icon, (string)$o['label'], $sub, $badge, '', '<input type="hidden" name="option" value="' . (int)$i . '">', $off) ?>
  <?php endforeach; ?>
  </div>

<?php elseif ($enc && $enc['type'] === 'meet'): // v1.9.4: somebody on the road. The card holds everything it shows (road_meet_start) ?>
  <div class="meetcard">
    <div class="meet-who"><span class="bigfoe"><?= e((string)$enc['ic']) ?></span><b><?= e((string)$enc['n']) ?></b><small><?= e((string)$enc['s']) ?></small></div>
    <p class="meet-says"><?= e((string)$enc['t']) ?></p>
  </div>
  <div class="choicelist">
  <?= act_choice('meet', '💬', 'Stop for a chat', 'Free · counts as today’s chat with ' . (string)$enc['n'], '', 'primary', '<input type="hidden" name="option" value="0">') ?>
  <?= act_choice('meet', '👋', 'Wave and walk on', 'Free', '', '', '<input type="hidden" name="option" value="1">') ?>
  </div>

<?php elseif ($enc && $enc['type'] === 'problem'):
    $p = q_one('SELECT * FROM problems WHERE id = ?', [$enc['id']]); ?>
  <h3 class="probq">❓ <?= e($p['text']) ?></h3>
  <p class="help probq">Pick an approach: d20 + the stat’s modifier must reach the number.</p>
  <div class="choicelist">
  <?php foreach (json_decode((string)$p['options'], true) ?: [] as $i => $o):
      $st = GNOME_STATS[$o['stat']] ?? GNOME_STATS['grit'];
      $mod = eff_mod($u, $o['stat']);
      $o['dc'] = (int)$o['dc'] + (int)($enc['dc_bonus'] ?? 0);
      $chance = max(5, min(100, (21 - ((int)$o['dc'] - $mod)) * 5)); ?>
    <form method="post" class="option"><?= csrf_field() ?><input type="hidden" name="do" value="solve"><input type="hidden" name="option" value="<?= (int)$i ?>">
      <?= choice_row($st[1], (string)$o['label'], $st[0] . ' ' . ($mod >= 0 ? '+' : '') . $mod . ' vs ' . (int)$o['dc'], [$chance . '%', choice_odds_class($chance)]) ?></form>   <?php // v1.6.3: .choice row ?>
  <?php endforeach; ?>
  </div>

<?php elseif ($dv2Scene): // v2.3.1: nothing in front of you ?>
  <?php if ($kind === 'delve' && (int)$exp['depth'] >= (int)$exp['steps_total']): ?>
    <h3>💰 The chest sits in the last chamber, unguarded at last.</h3>
    <div class="choicelist"><?= act_choice('chest', '💰', 'Open the chest', 'Everything in it is yours', '', 'primary') ?></div>
  <?php endif; ?>
<?php elseif ($mapMode): // v2.0.6: nothing in front of you: walk the map ?>
  <?php if ($kind === 'delve' && (int)$exp['depth'] >= DELVE_ROOMS): ?>
    <h3>💰 The chest sits in the last room, unguarded at last.</h3>
    <div class="choicelist"><?= act_choice('chest', '💰', 'Open the chest', 'Everything in it is yours', '', 'primary') ?></div>
  <?php else: ?>
    <h3><?= $kind === 'lair' ? 'The lair stretches away into the dark…' : ((int)$exp['depth'] === 0 ? 'Steps lead down into the dark…' : 'More rooms lie deeper in…') ?></h3>
    <p class="help"><?= $kind === 'lair' ? 'Tap a lit tile to walk. The boss waits at the far end (🐉).' : 'Tap a lit tile to walk. Walking is free; going into a room costs ⚡1 (free with a lantern). Do four rooms in any order, then the guardian’s.' ?></p>
  <?php endif; ?>
  <div class="choicelist"><?= act_choice('leave', '🪜', $kind === 'lair' ? 'Slip back out' : 'Climb back out', 'Free · you keep what you found') ?></div>

<?php elseif ($kind === 'lair' && !$enc): // v2.0.6: a lair whose boss has not risen yet, seen as the simple list ?>
  <h3>🐉 The boss waits deeper in the lair.</h3>
  <div class="choicelist">
  <?= act_choice('lair_engage', '⚔️', 'Face the boss now', 'It rises to meet you', '', 'primary') ?>
  <?= act_choice('leave', '🏃', 'Slip back out', 'Free') ?>
  </div>

<?php elseif ($kind === 'delve'): ?>
  <?php if ((int)$exp['depth'] >= DELVE_ROOMS): ?>
    <h3>💰 The chest sits in the last room, unguarded at last.</h3>
    <div class="choicelist"><?= act_choice('chest', '💰', 'Open the chest', 'Everything in it is yours', '', 'primary') ?></div>
  <?php else: ?>
    <h3><?= (int)$exp['depth'] === 0 ? 'Steps lead down into the dark…' : 'A doorway leads on, deeper down…' ?></h3>
    <?php $lit = tool_tier($uid, 'lantern') > 0; ?>
    <div class="choicelist">
    <?= act_choice('next', '🚪', 'Next room', ($lit ? 'Free, your lantern lights the way' : '1 energy') . ' · room ' . ((int)$exp['depth'] + 1) . ' of ' . DELVE_ROOMS, $lit ? ['free', 'free'] : ['⚡1', 'cost'], 'primary') ?>
    <?= act_choice('leave', '🪜', 'Climb back out', 'Free · you keep what you found') ?>
    </div>
    <p class="help">You keep everything you find, whenever you leave. If you’re knocked out, you wake up at the entrance.</p>
  <?php endif; ?>

<?php elseif ($isExplore):
    $dep = (int)$exp['depth'];
    $nextLvl = explore_level($u, $dep + 1, $exp); [$nextTier] = explore_tier($dep + 1);
    [$hereTier] = explore_tier(max(1, $dep));
    $warnAt = (int)setting('explore_warn_from');   // v0.7.74: the step where it turns dangerous, and where the wild starts
    $wildAt = (int)setting('explore_wild_from');
    $deepAt = (int)setting('explore_deep_from');   // v0.7.75: the deep wilds, matched to your own level
    $outPct = $dep > 0 ? outlevel_percent($u, explore_level($u, $dep, $exp)) : 100; ?>
  <?php $rl = $dep > 0 ? road_line($scene, ['seed' => road_line_seed($exp, count($log)), 'record' => false]) : null;   // v1.9.3: the line this step will log ?>
  <h3<?= $rl ? ' class="roadline"' : '' ?>><?= $rl ? '🍃 ' . e($rl) : ($dep === 0 ? 'The wild mycelium stretches away from the road…' : 'The threads tangle on ahead…') ?></h3>
  <?php ob_start(); ?>
  <p class="help"><?= $dep > 0 ? 'You’re in <b>' . e($hereTier) . '</b> country (danger level ' . explore_level($u, $dep, $exp) . '). ' : '' ?>
    Deeper is <b><?= e($nextTier) ?></b>, danger level <?= $nextLvl ?><?= $dep + 1 >= $wildAt ? ' (bosses roam out there!)' : '' ?>.<?= $dep + 1 >= $deepAt ? ' The deep wilds are matched to your own level.' : '' ?>
    Each step out is a little harder than the last. The further you go, the better the finds, and the more likely you are to spot a hidden village or landmark.</p>
  <?php if ($outPct < 100): // v0.7.75: an outgrown area ?>
    <p class="help">🌱 You’ve outgrown these parts: XP and Petals here are <?= $outPct ?>%. Items are the same. Head for the deep wilds (step <?= $deepAt ?>) for a real challenge.</p>
  <?php endif; ?>
  <?php $wmore = ob_get_clean(); ?>
  <?php if ($dep + 1 >= $warnAt && $dep < $warnAt): ?>
    <p class="flash err">⚠️ Past here it gets dangerous: danger level <?= $nextLvl ?>. Only go on if you’re feeling strong; heading back is always free.</p>
  <?php endif; ?>
  <?php $foundId = (int)($_SESSION['explore_found'] ?? 0);
  if ($foundId && ($fl = q_one('SELECT id, name FROM locations WHERE id = ?', [$foundId]))): ?>
    <div class="choicelist"><?= act_choice('visit', '🚶', 'Visit ' . $fl['name'] . ' now', 'You can come straight back to exploring afterwards', '', 'primary', '<input type="hidden" name="place" value="' . $foundId . '">') ?></div>
  <?php endif; ?>
  <div class="choicelist">   <?php // v1.9.3: .choice rows: what it costs and how hard it is, in the sub line ?>
  <?= act_choice('deeper', '🌿', 'Go deeper', $nextTier . ' · danger ' . $nextLvl, ['⚡1', 'cost'], 'primary') ?>
  <?php if ($dep >= 1): ?><?= act_choice('roam', '🔁', 'Keep exploring', $hereTier . ' · danger ' . explore_level($u, $dep, $exp), ['⚡1', 'cost']) ?><?php endif; ?>
  <?php if ($dep >= 2): ?><?= act_choice('back', '↩️', 'Step back', explore_tier($dep - 1)[0] . ' · danger ' . explore_level($u, $dep - 1, $exp), ['⚡1', 'cost']) ?><?php endif; ?>
  <?= act_choice('return', '🛣️', 'Head to the road', 'Free · keep everything', ['free', 'free']) ?>
  </div>
  <details class="wfold wmore"><summary>More</summary><?= $wmore ?><p class="help">If you’re knocked out, you wake up on the road with all your things.</p></details>   <?php // v2.1.11: the long notes, folded ?>
  <?php if ($dep >= 1): $gOpen = !$wanderView && !empty($_SESSION['gather_reveal']);   // v2.1.11: gather lives in a fold, open when a find has just come in ?>
  <details class="wfold wgather"<?= $gOpen ? ' open' : '' ?>><summary>🧺 Gather here</summary><?= gather_here_box($u, explore_land($exp), url('adventure.php'), '') ?></details>   <?php // v0.7.80 ?>
  <?php endif; ?>


<?php elseif ($trailSc): // graphical navigation 2d: nothing in front of you. Text is centered here, always. ?>
  <?php $tPhase = (string)$trailSc['st']['phase']; $tLast = (int)$trailSc['st']['sec'] + 1 >= (int)$trailSc['st']['S'];
  $tLand = (string)(exp_scene($exp)['land'] ?? 'grassland'); ?>
  <div class="trailui">
  <?php if ($tPhase === 'confirm'): ?>
  <dialog class="picker hubpop trailpop trailsmall" id="trailpop" open aria-label="The way on"><div class="pickbox"><div class="hubcard trailui">
    <h3><?= $tLast ? e($to['name']) . ' is just ahead.' : 'The way on lies ahead.' ?></h3>
    <p class="help"><?= $tLast ? 'Head into ' . e($to['name']) . '? No more energy.' : 'Section ' . ((int)$trailSc['st']['sec'] + 1) . ' of ' . (int)$trailSc['st']['S'] . ' done. Continuing is free.' ?></p>
    <div class="choicelist">
      <?= $tLast ? act_choice('trail_arrive', '🏡', 'Head into ' . $to['name'], 'Walk in · free', '', 'primary') : act_choice('trail_next', '🍄', 'Continue along the Trail', 'Section ' . ((int)$trailSc['st']['sec'] + 2) . ' of ' . (int)$trailSc['st']['S'] . ' · free', '', 'primary') ?>
    </div>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="trail_stay"><button class="btn alt small">👣 Not yet <small>look around</small></button></form>
    <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="trail_back"><button class="btn alt small">↩️ Turn back <small>free</small></button></form>
  </div></div></dialog>
  <?php else: ?>
    <p class="help">Tap a lit tile to walk. ⚔️ and ✨ wait on some tiles. Reach 🚪 to go on. Walking is free.</p>
    <?php if ((int)$trailSc['st']['sec'] > 0 && $trailSc['x'] === (int)$trailSc['map']['entry'][0] && $trailSc['y'] === (int)$trailSc['map']['entry'][1]): ?>
      <div class="choicelist"><?= act_choice('trail_prev', '↩️', 'Back to section ' . (int)$trailSc['st']['sec'], 'The way you came · free') ?></div>
    <?php endif; ?>
  <?php endif; ?>
  </div>

<?php elseif ((int)$exp['step'] < (int)$exp['steps_total']): ?>
  <?php $rl = road_line($scene, ['seed' => road_line_seed($exp, (int)$exp['step'] + 1), 'record' => false]);   // v1.9.3: the line the next space will log ?>
  <h3 class="roadline">🍃 <?= e($rl ?? 'The thread glows on ahead…') ?></h3>
  <div class="choicelist"><?= act_choice('continue', '🍄', 'Move to the next space', 'Space ' . ((int)$exp['step'] + 1) . ' of ' . (int)$exp['steps_total'] . ' · no energy', '', 'primary') ?></div>

<?php else:
    $wait = ts($exp['arrive_at']) - time(); ?>
  <h3><?= e($to['name']) ?> is in sight!</h3>
  <?php if ($wait > 0): ?>
    <p class="insight" data-hide-at-zero>The mycelium is carrying you the last stretch. You’ll arrive in about <b data-countdown="<?= (int)$wait ?>"><?= nice_time($wait) ?></b><?= $quickRoute ? ' (💨 a quick walk)' : '' ?>. Feel free to tend your garden meanwhile.</p>
    <div class="choicelist" hidden data-show-at-zero><?= act_choice('arrive', '🏡', 'Arrive', 'Walk into ' . $to['name'], '', 'primary') ?></div>   <?php // v2.0.1: counts down live like the top bar, then Arrive appears without a reload ?>
  <?php else: ?>
    <div class="choicelist"><?= act_choice('arrive', '🏡', 'Arrive', 'Walk into ' . $to['name'], '', 'primary') ?></div>
  <?php endif; ?>
  <?php if ($wi && $wi['next']): ?>
    <?php $arr = q_one('SELECT * FROM locations WHERE id = ?', [(int)$exp['to_id']]);   // v1.0.4: say when the route will pause here
      // v2.0.1: "go on to B" is the stop AFTER this one; say so, and name the final destination when B is not it
      $nextName = dest_name($uid, $wi['next']);
      $goalName = dest_name($uid, $wi['loc']);
      $thenTxt = (int)$wi['next']['id'] === (int)$wi['loc']['id'] ? 'on to <b>' . e($nextName) . '</b> (your destination)' : 'on to <b>' . e($nextName) . '</b>, then toward <b>' . e($goalName) . '</b> (your destination)';
      if ($arr): ?>
    <p class="help">⏸️ You’ll stop at <b><?= e((string)$arr['name']) ?></b> to look around. Tap Set off when you’re ready, then <?= $thenTxt ?> (⚡<?= (int)$wi['next_energy'] ?>).</p>
    <?php endif; ?>
  <?php endif; ?>
<?php endif; ?>
</div>
<?php if ($trailPop): ?></div></div></dialog><?php endif; ?>
</div>
<div class="gardenwrap">

<details class="panel box advjournal"<?= $exp ? '' : ' open' ?>>
  <summary><b>Journal</b> <small class="muted">(<?= count($log) ?>)</small><?php if ($log && !$dv2Scene): ?><span class="jpeek"><?= e((string)end($log)) ?></span><?php endif; ?></summary>
  <ul class="journal">
    <?php foreach (array_reverse(array_slice($log, -25)) as $line): ?><li><?= e($line) ?></li><?php endforeach; ?>
  </ul>
</details>
</div>
<?php if (!in_array($kind, ['delve', 'lair'], true)): ?>
<p class="tmlinks worldlink"><a href="<?= e(url('world.php?tab=map#regionmap')) ?>">🗺️ Region map →</a></p>
<?php endif; ?>
<?php if ($wanderView): ?><div class="wanderhide"><?= ob_get_clean() ?></div><?php endif; ?>
<?php page_footer();

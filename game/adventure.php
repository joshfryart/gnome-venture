<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/adventure.php';
require_once __DIR__ . '/includes/scene.php';   // v2.0.43: the stage
require_once __DIR__ . '/includes/puzzle_pals.php';   // v2.3.8: pal actives on the fight buttons
$u = require_login();
$uid = (int)$u['id'];

$exp = active_expedition($uid);

if (!is_post() && isset($_GET['view']) && in_array($_GET['view'], ['list', 'map'], true)) {   // v2.0.6: map or the simple list, remembered in the session
    dm_set_pref((string)$_GET['view']);
    redirect('adventure.php');
}

if (is_post()) {
    csrf_check();
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
    if ($do === 'explore') {
        [$ok, $msg] = explore_start($u);
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? 'adventure.php' : 'world.php');
    }
    if ($do === 'explore_back' || $do === 'explore_road') {   // v0.7.61: from a place you found off the path
        require_once __DIR__ . '/includes/explore.php';
        [$ok, $msg] = explore_come_back($u, $do === 'explore_road' ? 'road' : 'wild');
        flash($msg, $ok ? 'ok' : 'err');
        redirect($ok ? ($do === 'explore_road' ? 'world.php' : 'adventure.php') : 'town.php');
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
        if ($enc && $enc['type'] === 'creature') {
            if (in_array($do, ['attack', 'ability', 'flee'], true) || preg_match('/^palskill:[a-z0-9_-]{1,48}$/', $do)) {   // v2.3.8: palskill:KEY = a rare pal's active
                combat_turn($u, $exp, $do);
            } elseif ($do === 'snack') {   // v1.4.0: one home-cooked snack, same transaction and lock as the rest
                combat_turn($u, $exp, 'snack', (int)($_POST['item'] ?? 0));
            } elseif ($do === 'fighton') {   // v1.3.0: auto-attack until hurt, done, or 30 rounds (same transaction and lock as above)
                fight_on($u, $exp);
            } elseif ($do === 'auto') {
                $c = encounter_creature($enc);
                fight_prep($enc, $c);   // v1.3.0
                if (fight_certainty($u, $exp, $c, $enc)) auto_resolve($u, $exp);
            }
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
        } elseif ($do === 'continue' && (int)$exp['step'] < (int)$exp['steps_total']) {
            next_step($u, $exp);
        } elseif ($do === 'arrive' && (int)$exp['step'] >= (int)$exp['steps_total'] && ts($exp['arrive_at']) <= time()) {
            arrive($u, $exp);
            $arrivedAt = (int)$exp['to_id'];
        }
        // A lair fight is over when the boss is gone: a win (defeated or befriended) or a getaway (v0.7.26)
        if (($exp['kind'] ?? '') === 'lair' && $exp['status'] === 'active' && !$exp['encounter'] && (int)$exp['depth'] >= 1) {   // v2.0.6: depth 0 = the boss has not risen yet
            $recent = array_slice(json_decode((string)$exp['log'], true) ?: [], -8);
            if (preg_grep('/ is (defeated|befriended)!/u', $recent)) lair_victory($u, $exp);
            else { $exp['status'] = 'done'; exp_log($exp, '🏃 You escape the lair in one piece.'); }
        }
        save_exp($exp);
        road_flush();
    }
    db()->commit();
    if (!empty($visited)) redirect('town.php');
    // After arriving, send the player straight to the destination page
    if (!empty($arrivedAt)) {
        require_once __DIR__ . '/includes/destination.php';   // v0.9.3: keep walking to the next stop of the route
        $chain = dest_chain_after_arrival($uid);
        if ($chain) {
            flash($chain[1], $chain[0] ? 'ok' : 'err');
            if ($chain[0]) redirect('adventure.php');
        }
        $dest = q_one('SELECT kind FROM locations WHERE id = ?', [$arrivedAt]);
        $kind = $dest['kind'] ?? '';
        // v0.7.61: every place has its page on town.php (town square, rest stop, haven…). local.php never existed.
        redirect($kind === 'hub' ? 'town.php?hub=1' : ($kind ? 'town.php' : 'world.php'));
    }
    redirect(safe_back('adventure.php'));
}

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

page_header('On the mycelium');
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
  <details class="routeopts-collapse">
    <summary>Travel options</summary>
    <form method="post" class="inline routeopts"><?= csrf_field() ?><input type="hidden" name="do" value="dest_opts"><input type="hidden" name="back" value="adventure.php"><?= dest_opts_html($u) ?> <button class="btn ghost">Save</button></form>
  </details>
</div>
<?php endif; ?>
<?php $fighting = $enc && $enc['type'] === 'creature'; $wander = $isExplore && $exp && !$fighting;   // v2.1.11: the phone wander layout (map left, info right, actions in a grid, gather in a fold); v2.1.12: event cards use it too ?>
<div class="advgrid<?= $isExplore ? ' withrings' : '' ?><?= $fighting ? ' fighting' : '' ?><?= $wander ? ' wander' : '' ?>">
<div class="mapcol">
<?php if ($exp): echo adventure_stage_html($u, $exp, $scene, $enc); endif; ?>
<?php if ($dv2Scene): // v2.3.1: the floor you are on, or the route menu between floors ?>
<?php if ($dv2Scene['map']): ?><?= dv2_floor_html($u, $exp, $dv2Scene, (bool)$enc) ?>
<?php elseif ($dv2Scene['st']['q']): ?><?= dv2_quick_html($dv2Scene) ?>
<?php else: ?><?= dv2_menu_html($u, $exp, $dv2Scene, (bool)$enc) ?>
<?php endif; ?>
<?= dv2_party_html($u, $exp, $dv2Scene) ?>
<?php elseif ($mapMode): // v2.0.6: the map is the default; the list is one tap away ?>
<?= dm_view_html($u, $exp, $dmScene, (bool)$enc) ?>
<p class="tmlinks"><a data-inplace href="<?= e(url('adventure.php?view=list')) ?>">Use the simple list</a></p>
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
$latestHtml = ob_get_clean(); if ($fighting) $latestHtml = '';   // a fight card already shows the rounds
?>
<?php if ($isWalk && !$mapMode) echo route_fold_html($u, $last, $wi); ?>
</div>


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
    <h3>💫 Knocked out!</h3><p>You woke up back in <?= e($from['name']) ?>. Nothing was lost except a little energy and pride.</p>
  <?php endif; ?>
  <p><a class="btn" href="<?= e(url('world.php')) ?>">Look around</a></p>

<?php elseif ($enc && $enc['type'] === 'creature'):
    $c = encounter_creature($enc);
    fight_prep($enc, $c);   // v1.3.0: show the eased health
    $sure = fight_certainty($u, $exp, $c, $enc);
    [$abName, $abDesc] = CALLING_ABILITIES[$u['calling'] ?? ''] ?? CALLING_ABILITIES['']; ?>
  <?php // v0.7.61: one box; reversed in 2.2.1 so you are on the left, under your gnome on the stage, and the foe on the right under theirs ?>
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
  <details class="helpfold"><summary>About the <?= e($c['name']) ?></summary><p><i><?= e($c['description']) ?></i></p></details>
  <?= fight_card_extra($u, $exp, $enc, 3, true) ?>
  <?php // v1.6.3: fight actions are .choice rows; what each one does sits in its sub line (it used to be a help paragraph)
    $hitPct = (int)fight_odds($u, $exp, $enc)['hit'];
    $runPct = max(0, min(100, (21 - (8 + intdiv((int)$c['level'], 3) - eff_mod($u, 'nimble'))) * 5)); ?>
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
  <?php if ($dep >= 1): $gOpen = !empty($_SESSION['gather_reveal']);   // v2.1.11: gather lives in a fold, open when a find has just come in ?>
  <details class="wfold wgather"<?= $gOpen ? ' open' : '' ?>><summary>🧺 Gather here</summary><?= gather_here_box($u, explore_land($exp), url('adventure.php'), '') ?></details>   <?php // v0.7.80 ?>
  <?php endif; ?>


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
      if ((int)($u['dest_auto'] ?? 1) && (int)($u['dest_pause_towns'] ?? 0) && $arr && dest_is_town($arr)): ?>
    <p class="help">⏸️ You’ll pause at <b><?= e((string)$arr['name']) ?></b> to look around. Tap Set off when you’re ready, then <?= $thenTxt ?>.</p>
    <?php else: ?>
    <p class="help"><?= (int)($u['dest_auto'] ?? 1) ? '🧭 After this stop: walk ' . $thenTxt . ' (⚡' . (int)$wi['next_energy'] . ') as soon as you arrive.' : '🧭 Next stop on your route after this one: ' . e($nextName) . '.' ?></p>
    <?php endif; ?>
  <?php endif; ?>
<?php endif; ?>
</div>
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
<p class="tmlinks worldlink"><a href="<?= e(url('world.php?tab=map#regionmap')) ?>">🗺️ World map →</a></p>
<?php endif; ?>
<?php page_footer();

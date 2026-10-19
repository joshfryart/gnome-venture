<?php
declare(strict_types=1);
/**
 * v1.1.0: the Quests half of Jobs & Quests (jobs.php?t=quests). One short line per thing on the go, each linking to where it's
 * done: Wren's Journey chapters, the calling questline and landmark repairs (full boxes). v1.7.2: errands and orders have their own Tasks tabs.
 */
require_once __DIR__ . '/journey.php';

function quests_overview(array $u): void
{
    $uid = (int)$u['id'];
    $any = false;

    // Wren's Journey: every chapter in progress
    $rows = '';
    foreach (journey_chapters() as $ch) {
        $st = journey_status($u, $ch);
        if (!$st['row'] || $st['row']['done_at']) continue;
        $n = count(array_filter($st['tasks'], fn($t) => $t[3]));
        $rd = journey_ready($u, $st);
        $hf = '';   // v1.7.5: hand-in / finish right here (journey.php sends you back to this tab)
        if ($rd !== '') {
            $hf = '<form method="post" action="' . e(url('journey.php')) . '" class="inline jqhand">' . csrf_field() . '<input type="hidden" name="do" value="' . ($rd === 'finish' ? 'finish' : 'hand_in') . '">'
                . '<input type="hidden" name="ch" value="' . (int)$ch['id'] . '"><input type="hidden" name="back" value="jobs.php?t=quests">'
                . '<button class="btn small' . ($rd === 'finish' ? ' gold' : '') . '">' . ($rd === 'finish' ? '📜 Finish the chapter' : '✋ Hand in') . '</button></form>';
        }
        $rows .= '<li><a href="' . e(url('book.php?ch=Journey&j=' . (int)$ch['id'])) . '">' . e((string)$ch['project_icon']) . ' ' . e($ch['region']) . ': ' . e($ch['title']) . '</a>'
            . ' <small class="muted">' . $n . '/' . count($st['tasks']) . ($rd === 'finish' ? ' · <b>ready to finish</b>' : ($rd === 'stage' ? ' · <b>stage ready</b>' : '')) . '</small>' . $hf . '</li>';
    }
    if ($rows === '' && ($nl = journey_next_locked($u))) {
        $rows = '<li class="muted">Next chapter: ' . e($nl['region']) . ' (level ' . (int)$nl['min_level'] . '). It starts when you walk there.</li>';
    }
    if ($rows !== '') { $any = true; echo '<section class="box qsec"><h3>🧭 Wren’s Journey</h3><ul class="qlist">' . $rows . '</ul></section>'; }

    // Calling questline
    require_once __DIR__ . '/calling_view.php';
    if (($cl = calling_today_line($u)) !== '') { $any = true; echo '<section class="box qsec"><h3>📜 Your calling</h3>' . $cl . '</section>'; }

    // Landmark repairs (full boxes: they have their own buttons)
    require_once __DIR__ . '/rebuild.php';
    foreach (repair_list($uid) as $k => $rp) {
        $any = true;
        if ($k === 0) echo '<h2 id="repairs">🔨 Your repairs</h2>';
        echo '<div class="box">' . repair_box($u, $rp, 'jobs.php?t=quests') . '</div>';
    }

    if (!$any) echo '<p class="muted">No quests on the go. Walk to a new region to start a Journey chapter.</p>';
}


// ======================================================================= v1.7.2 tasks: the tabs of jobs.php

/** Is the gnome standing in a town (or using the Mossbottom hub link)? Orders are only filled there. */
function tasks_in_town(array $u, bool $hub): bool
{
    require_once __DIR__ . '/adventure.php';
    return $hub || in_array(player_node($u)['kind'], ['market', 'hub'], true);
}

/** Small badge counts per tab: things ready to hand in or collect. */
function tasks_counts(array $u, bool $hub = false): array
{
    $uid = (int)$u['id'];
    $c = ['jobs' => 0, 'quests' => 0, 'orders' => 0, 'errands' => 0];
    try {
        foreach (array_keys(JOB_PERIODS) as $pk) {
            $j = current_job($uid, $pk);
            if (!$j || $j['status'] !== 'active') continue;
            if ($j['kind'] === 'rebuild') continue;
            if ((int)$j['progress'] >= (int)$j['qty'] && (int)$j['stages'] <= 1) { $c['jobs']++; continue; }
            if ((str_starts_with((string)$j['kind'], 'deliver') || $j['kind'] === 'p_deliver') && $j['target_item_id']
                && (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $j['target_item_id']]) > 0) $c['jobs']++;
        }
        require_once __DIR__ . '/journey.php';
        foreach (journey_chapters() as $ch) if (journey_ready($u, journey_status($u, $ch)) !== '') $c['quests']++;
        require_once __DIR__ . '/rebuild.php';
        foreach (repair_list($uid) as $rp) if (!array_filter(rebuild_stage_status($u, (int)$rp['stage'] + 1), fn($x) => $x[2] < $x[1])) $c['quests']++;
        require_once __DIR__ . '/stop_folk.php';
        $c['errands'] = count(stop_errands_active($uid));
        if (setting('orders_on') === '1' && tasks_in_town($u, $hub)) {
            require_once __DIR__ . '/town.php';
            $town = town_for($u, $hub);
            foreach (orders_board($town) as $b) {
                if (order_done($uid, (int)$b['npc']['id'], $b['o']['cycle'])) continue;
                $ck = order_check($uid, $b['o']);
                if ($ck && !empty($ck['enough'])) $c['orders']++;
            }
        }
    } catch (Throwable $e) {
        // a badge is never worth a broken page
    }
    return $c;
}

function tasks_quests(array $u): void
{
    quests_overview($u);
}

/** POST do=order|favour from the Orders tab. Same rules as the town square. */
function tasks_order_post(array $u, string $do, int $npc, bool $hub): array
{
    require_once __DIR__ . '/town.php';
    require_once __DIR__ . '/adventure.php';
    require_once __DIR__ . '/town_social.php';
    if (!tasks_in_town($u, $hub)) return [false, 'You’re not in town right now. Walk to the town at the end of the road to fill orders.'];
    refresh_energy($u);
    $town = town_for($u, $hub);
    return $do === 'order' ? order_deliver($u, $npc, $town) : favour_deliver($u, $npc, $town);
}

function tasks_orders(array $u, bool $hub): void
{
    $uid = (int)$u['id'];
    require_once __DIR__ . '/town.php';
    require_once __DIR__ . '/town_social.php';
    echo '<h2>📌 Orders</h2>';
    if (!tasks_in_town($u, $hub)) {
        echo '<div class="box"><p class="muted">Orders are pinned on a town’s board. Walk to a town to see and fill them.</p><a class="btn small" href="' . e(url('world.php')) . '">🌍 To the map →</a></div>';
        return;
    }
    $town = town_for($u, $hub);
    if (setting('orders_on') === '1') {
        orders_board_box($uid, $town, $hub, 0);
        return;
    }
    // orders switched off in Admin: the old weekly favours
    $folk = town_folk($town); ?>
    <div class="box favours"><h3>📌 Favours from the townsfolk</h3>
      <?php $shown = 0; foreach ($folk as $n): $o = favour_offer($uid, $n, $town); if (!$o) continue; $shown++;
          $have = (int)q_val('SELECT qty FROM user_items WHERE user_id = ? AND item_id = ?', [$uid, $o['item']['id']]); ?>
        <div class="favour<?= $o['done'] ? ' done' : '' ?>"><span class="ficon"><?= npc_icon($n['species']) ?></span>
          <div><b><a href="<?= e(url('folk.php?id=' . (int)$n['id'])) ?>"><?= e($n['name']) ?></a></b>: “Could you bring me <?= (int)$o['qty'] ?> × <?= e($o['item']['name']) ?>?”
            <br><small class="muted">Reward: <?= money($o['coins']) ?>, 10 XP and friendship · you have <?= $have ?></small></div>
          <?php if ($o['done']): ?><span class="muted">✔️ Done this week</span>
          <?php else: ?><form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="favour"><input type="hidden" name="npc" value="<?= (int)$n['id'] ?>"><?php if ($hub): ?><input type="hidden" name="hub" value="1"><?php endif; ?>
            <button class="btn small" <?= $have < $o['qty'] ? 'disabled' : '' ?>>Deliver</button></form><?php endif; ?>
        </div>
      <?php endforeach; ?>
      <?php if (!$shown): ?><p class="muted">Nothing for you yet. Chat with the townsfolk and they’ll pin a favour here each week.</p><?php endif; ?>
    </div>
<?php
}

/** Rest-stop errands the gnome carries: read-only. They're done at the stop. */
function tasks_errands(array $u): void
{
    require_once __DIR__ . '/stop_folk.php';
    $list = stop_errands_active((int)$u['id']);
    echo '<h2>🧺 Errands</h2>';
    if (!$list) {
        echo '<div class="box"><p class="muted">No errands carried. Villagers at rest stops ask for them.</p></div>';
        return;
    }
    echo '<div class="box qsec"><ul class="qlist">';
    foreach ($list as $x) {
        $what = $x['target']
            ? ($x['kind'] === 'escort' ? 'Walk a traveller to ' : 'Take a parcel to ') . '<b>' . e((string)$x['target']) . '</b> at <b>' . e((string)$x['target_place']) . '</b>'
            : 'Bring ' . (int)$x['qty'] . ' × ' . e((string)($x['item_name'] ?? 'something')) . ' to <b>' . e((string)$x['giver']) . '</b> at <b>' . e((string)$x['giver_place']) . '</b>';
        echo '<li>🧺 ' . $what . '<br><small class="muted">From ' . e((string)$x['giver']) . ' (' . e((string)$x['giver_place']) . ') · '
            . money((int)$x['coins']) . ', ' . (int)$x['xp'] . ' XP · until ' . e(date('D j M', strtotime($x['expires_day'] . ' UTC'))) . '</small></li>';
    }
    echo '</ul></div><p class="help">Hand them in when you reach the stop: open the villager there.</p>';
}

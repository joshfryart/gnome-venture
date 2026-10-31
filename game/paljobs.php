<?php
declare(strict_types=1);
/**
 * v2.3.0: Pal Jobs. Send a found Puzzle Pal to tend a garden, on a gathering trip, or to re-run a delve you have already cleared. Logic: includes/pal_jobs.php.
 * Behind ppal_open() and pj_open() (gnome level 10 by default). Posts: send_garden, send_trip, send_delve, collect, recall, heal. No inline script or style (CSP).
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/puzzles.php';
require_once __DIR__ . '/includes/puzzle_games.php';
require_once __DIR__ . '/includes/jigsaw.php';
require_once __DIR__ . '/includes/pal_jobs.php';
$u = require_login();
if (!ppal_open() || is_guest($u)) { flash('Puzzle Pals are coming soon.', 'err'); redirect('games.php'); }
$uid = (int)$u['id'];
if (!pj_open($u)) { flash('Pal jobs open at gnome level ' . pj_min_level() . '.', 'err'); redirect('puzzlepals.php'); }

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $pal = (string)($_POST['pal'] ?? '');
    $pots = (int)($_POST['potions'] ?? 0);
    $res = match ($do) {
        'send_garden' => pj_garden_send($u, $pal, (int)($_POST['plot'] ?? 0), (int)($_POST['days'] ?? 0)),
        'send_trip' => pj_trip_send($u, $pal, (string)($_POST['land'] ?? ''), (string)($_POST['tool'] ?? ''), (int)($_POST['hours'] ?? 0), $pots),
        'send_delve' => pj_delve_send($u, $pal, (int)($_POST['delve'] ?? 0), $pots),
        'recall' => pj_recall($u, (int)($_POST['job'] ?? 0)),
        'heal' => pj_heal($u, $pal),
        'collect' => pj_collect($u, (int)($_POST['job'] ?? 0)),
        default => [false, 'Nothing to do.'],
    };
    if ($do === 'collect') foreach ((array)$res[1] as $l) flash((string)$l, $res[0] ? 'ok' : 'err');
    else flash((string)$res[1], $res[0] ? 'ok' : 'err');
    redirect('paljobs.php');
}

pj_settle($uid);
$pals = pj_pals($uid);
$jobs = pj_jobs($uid);
$byUid = [];
foreach ($jobs as $j) $byUid[$j['pal_uid']] = $j;
$home = array_filter($pals, fn($p) => $p['status'] === 'home');
$plots = q('SELECT id, garden_name FROM plots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
$delves = pj_cleared_delves($uid);
$tools = pj_tools($uid);
$potions = pj_potion_count($uid);
$left = pj_max_away() - count($jobs);
$runsLeft = max(0, pj_runs_per_day() - pj_runs_today($uid));
$kindTxt = ['garden' => '🪴 Garden', 'trip' => '🧺 Gathering', 'delve' => '🕳️ Delve'];
page_header('Pal Jobs');
?>
<div id="pz" class="ppalbook pjpage">
<div id="lib">
  <h1>🧩 Pal Jobs</h1>
  <p class="help">Pals out: <b><?= count($jobs) ?></b> of <?= pj_max_away() ?> · Trips and delves left today: <b><?= $runsLeft ?></b> · Healing Potions: <b><?= $potions ?></b>
    · <a href="<?= e(url('puzzlepals.php')) ?>">Pal Book</a></p>

  <?php if (!$pals): ?>
  <div class="box"><p class="muted">No pals yet. Find some on the map first.</p></div>
  <?php endif; ?>

  <?php if ($jobs): ?>
  <section class="box" aria-label="Pals out">
    <h2>Out and about</h2>
    <ul class="pjlist">
      <?php foreach ($jobs as $j): $p = $pals[$j['pal_uid']] ?? null; if (!$p) continue; $r = json_decode((string)$j['result'], true) ?: []; $secs = ts($j['ends_at']) - time(); ?>
      <li class="pjrow">
        <?= ppal_img($p['key'], $p['name'], 'ppalimg', 40) ?>
        <span class="pjwho"><b><?= e($p['name']) ?></b><br>
          <small class="muted"><?= $kindTxt[$j['kind']] ?? '' ?>
          <?php if ($j['kind'] === 'garden'): ?> · until <?= e(puzzle_local((string)$j['ends_at'], 'j M, H:i')) ?>
          <?php elseif ($j['state'] === 'ready'): ?> · back home<?= !empty($r['fainted']) ? ' (ran out of HP)' : '' ?>
          <?php else: ?> · back in <?= e(pj_ago($secs)) ?><?php endif; ?></small></span>
        <form method="post" action="<?= e(url('paljobs.php')) ?>"><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>">
          <?php if ($j['state'] === 'ready'): ?><button class="btn small" name="do" value="collect">Collect</button>
          <?php elseif ($j['kind'] === 'garden'): ?><button class="btn small ghost" name="do" value="recall">Call home</button><?php endif; ?>
        </form>
      </li>
      <?php endforeach; ?>
    </ul>
  </section>
  <?php endif; ?>

  <?php foreach ($pals as $p): ?>
  <section class="box pjpal ppr-<?= e($p['pal']['rarity']) ?>" aria-label="<?= e($p['name']) ?>">
    <div class="pjhead">
      <?= ppal_img($p['key'], $p['name'], 'ppalimg', 56) ?>
      <div>
        <h3><?= e($p['name']) ?> <small class="muted"><?= e(ucfirst($p['pal']['rarity'])) ?></small></h3>
        <p class="help">🪴 Gardening <b><?= (int)$p['g'] ?></b><?= ($n = pj_xp_to_next($p['gxp'])) ? ' (' . $n . ' XP to next)' : ' (top)' ?>
          · 🧭 Adventuring <b><?= (int)$p['a'] ?></b><?= ($n = pj_xp_to_next($p['axp'])) ? ' (' . $n . ' XP to next)' : ' (top)' ?></p>
        <p class="help"><label>HP <meter min="0" max="<?= (int)$p['max'] ?>" low="<?= (int)($p['max'] * 0.4) ?>" optimum="<?= (int)$p['max'] ?>" value="<?= (int)$p['hp'] ?>"></meter></label>
          <?= (int)$p['hp'] ?>/<?= (int)$p['max'] ?><?= $p['active'] ? ' · taken along (earns a little XP)' : '' ?><?= $p['status'] !== 'home' ? ' · out on a job' : '' ?></p>
      </div>
    </div>
    <?php if ($p['status'] === 'home'): ?>
    <details class="pjsend">
      <summary>Send out</summary>
      <?php if ($p['hp'] < 1): ?><p class="muted">Resting. Back to work when it has some HP.</p>
      <?php elseif ($left < 1): ?><p class="muted">All <?= pj_max_away() ?> jobs are taken. Collect one first.</p>
      <?php else: ?>
      <?php if ($plots): ?>
      <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjform"><?= csrf_field() ?><input type="hidden" name="do" value="send_garden"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>">
        <b>🪴 Tend a garden</b>
        <label>Garden <select name="plot"><?php foreach ($plots as $pl): ?><option value="<?= (int)$pl['id'] ?>"><?= e((string)($pl['garden_name'] ?: 'Garden ' . $pl['id'])) ?></option><?php endforeach; ?></select></label>
        <label>For <select name="days"><?php foreach (PJ_GARDEN_DAYS as $d): ?><option value="<?= $d ?>"><?= $d ?> day<?= $d > 1 ? 's' : '' ?></option><?php endforeach; ?></select></label>
        <small class="muted">Waters at Gardening 1, weeds from 3, harvests at 9. Works beside your hired helpers.</small>
        <button class="btn small">Send</button>
      </form>
      <?php endif; ?>
      <?php if ($tools): ?>
      <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjform"><?= csrf_field() ?><input type="hidden" name="do" value="send_trip"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>">
        <b>🧺 Gathering trip</b>
        <label>Where <select name="land"><?php foreach (LANDSCAPES as $k => $L): ?><option value="<?= e($k) ?>"><?= $L[0] ?> <?= e($L[1]) ?></option><?php endforeach; ?></select></label>
        <label>Tool <select name="tool"><?php foreach ($tools as $t => $tier): ?><option value="<?= e($t) ?>"><?= TOOL_TYPES[$t][1] ?> <?= e(TOOL_TYPES[$t][0]) ?> (tier <?= (int)$tier ?>)</option><?php endforeach; ?></select></label>
        <label>Hours <select name="hours"><?php foreach (PJ_TRIP_HOURS as $h): ?><option value="<?= $h ?>"><?= $h ?></option><?php endforeach; ?></select></label>
        <label>Potions <input type="number" name="potions" value="<?= min(2, $potions) ?>" min="0" max="<?= min(5, $potions) ?>" class="pjnum"></label>
        <small class="muted">Rare finds need Adventuring 5. Unused potions come back.</small>
        <button class="btn small">Send</button>
      </form>
      <?php else: ?><p class="muted">🧺 Trips need a gathering tool in your satchel.</p><?php endif; ?>
      <?php if ($delves): ?>
      <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjform"><?= csrf_field() ?><input type="hidden" name="do" value="send_delve"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>">
        <b>🕳️ Re-run a cleared delve</b>
        <label>Delve <select name="delve"><?php foreach ($delves as $d): ?><option value="<?= (int)$d['id'] ?>"><?= e((string)$d['name']) ?> (L<?= (int)$d['level'] ?>)</option><?php endforeach; ?></select></label>
        <label>Potions <input type="number" name="potions" value="<?= min(2, $potions) ?>" min="0" max="<?= min(5, $potions) ?>" class="pjnum"></label>
        <small class="muted">About 60% of a real clear. No first-clear bonus. Once a day per delve.</small>
        <button class="btn small">Send</button>
      </form>
      <?php else: ?><p class="muted">🕳️ Clear a delve yourself first, then a pal can re-run it.</p><?php endif; ?>
      <?php endif; ?>
    </details>
    <?php if ($p['hp'] < $p['max'] && $potions > 0): ?>
    <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjheal"><?= csrf_field() ?><input type="hidden" name="do" value="heal"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>"><button class="btn small ghost">🧪 Give a potion</button></form>
    <?php endif; ?>
    <?php endif; ?>
  </section>
  <?php endforeach; ?>
  <p class="help">Healing Potions: craft them (Crafting → Potions) or buy them at Twigg’s Seed Emporium. A pal at 0 HP heads home. HP grows back at home.</p>
  <p><a href="<?= e(url('puzzlepals.php')) ?>">← Pal Book</a></p>
</div>
</div>
<?php page_footer();

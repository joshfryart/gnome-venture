<?php
declare(strict_types=1);
/**
 * v2.3.0: Pal Jobs. Send a found Puzzle Pal to tend a garden, on a gathering trip, or to re-run a delve you have already cleared. Logic: includes/pal_jobs.php.
 * Behind ppal_open() and pj_open() (gnome level 10 by default). Posts: send_garden, send_trip, send_delve, collect, recall, heal. No inline script or style (CSP).
 * v2.3.1: one screen in three parts: the ledger (pals out, with progress) beside the pals at home, then the job board (pick a job, pick a pal, set it, send).
 * Each job is one plain form (a radio list of pals + its options), so it all works without JS; assets/paljobs.js adds the countdown, one open job at a time,
 * a potion stepper and the "back at" line. Styles: assets/puzzles.css (.pj*).
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
    $unq = !empty($_POST['unequip']);   // v2.3.2: the player agreed to take an equipped pal off the party
    $jobPal = $do === 'collect' ? (string)q_val('SELECT pal_uid FROM ppal_jobs WHERE id = ? AND user_id = ?', [(int)($_POST['job'] ?? 0), $uid]) : '';
    $res = match ($do) {
        'send_garden' => pj_garden_send($u, $pal, (int)($_POST['plot'] ?? 0), (int)($_POST['days'] ?? 0), $unq),
        'send_trip' => pj_trip_send($u, $pal, (string)($_POST['land'] ?? ''), (string)($_POST['tool'] ?? ''), (int)($_POST['hours'] ?? 0), $pots, $unq),
        'send_delve' => pj_delve_send($u, $pal, (int)($_POST['delve'] ?? 0), $pots, $unq),
        'recall' => pj_recall($u, (int)($_POST['job'] ?? 0)),
        'heal' => pj_heal($u, $pal),
        'collect' => pj_collect($u, (int)($_POST['job'] ?? 0)),
        default => [false, 'Nothing to do.'],
    };
    if ($do === 'collect') {
        if (!empty($res[2])) flash((string)$res[2], 'ok');   // v2.3.3: the receipt title leads the message log too
        foreach ((array)$res[1] as $l) flash((string)$l, $res[0] ? 'ok' : 'err');
        if ($res[0]) $_SESSION['pj_receipt'] = ['pal' => $jobPal, 'head' => (string)($res[2] ?? ''), 'lines' => array_map('strval', (array)$res[1])];   // shown once, at the top of the ledger
    } else flash((string)$res[1], $res[0] ? 'ok' : 'err');
    redirect('paljobs.php');
}

pj_settle($uid);
$now = time();
$pals = pj_pals($uid);
$jobs = pj_jobs($uid);
$plots = q('SELECT id, garden_name FROM plots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
$delves = pj_cleared_delves($uid);
$ranToday = array_map('intval', q("SELECT target FROM ppal_jobs WHERE user_id = ? AND kind = 'delve' AND day = ?", [$uid, landmark_day()])->fetchAll(PDO::FETCH_COLUMN));
$tools = pj_tools($uid);
$potions = pj_potion_count($uid);
$maxAway = pj_max_away();
$left = $maxAway - count($jobs);
$runsLeft = max(0, pj_runs_per_day() - pj_runs_today($uid));
$potMax = min(5, $potions);
$receipt = $_SESSION['pj_receipt'] ?? null;
unset($_SESSION['pj_receipt']);

$plotName = [];
foreach ($plots as $pl) $plotName[(int)$pl['id']] = (string)($pl['garden_name'] ?: 'Garden ' . $pl['id']);
$delveName = [];
foreach ($delves as $d) $delveName[(int)$d['id']] = $d['name'] . ' (L' . (int)$d['level'] . ')';
$byUid = [];
foreach ($jobs as $j) $byUid[$j['pal_uid']] = $j;
$home = array_filter($pals, fn($p) => $p['status'] === 'home');

// the ledger: ready first, then soonest back; garden stays last (they end on a date, not a countdown)
usort($jobs, fn($a, $b) => [$a['state'] !== 'ready', $a['kind'] === 'garden', ts($a['ends_at'])] <=> [$b['state'] !== 'ready', $b['kind'] === 'garden', ts($b['ends_at'])]);
$kindTxt = ['garden' => '🪴 Garden', 'trip' => '🧺 Gathering', 'delve' => '🕳️ Delve'];
$jobLine = fn(array $j): string => match ($j['kind']) {
    'garden' => $plotName[(int)$j['plot_id']] ?? 'a garden',
    'trip' => (LANDSCAPES[$j['target']][1] ?? $j['target']) . ' · ' . (TOOL_TYPES[$j['tool']][0] ?? $j['tool']) . ' · ' . pj_ago(ts($j['ends_at']) - ts($j['started_at'])),
    'delve' => ($delveName[(int)$j['target']] ?? 'a delve') . ((int)$j['potions'] ? ' · ' . (int)$j['potions'] . ' potion' . ((int)$j['potions'] > 1 ? 's' : '') : ''),
    default => '',
};
$nextBack = null;
foreach ($jobs as $j) if ($j['state'] === 'active' && $j['kind'] !== 'garden' && (!$nextBack || ts($j['ends_at']) < ts($nextBack['ends_at']))) $nextBack = $j;
$anyReady = (bool)array_filter($jobs, fn($j) => $j['state'] === 'ready');

// the board: [icon, title, length, what it does, what it pays, skill key, skill label, the small print]
$posts = [
    'garden' => ['🪴', 'Tend a garden', '1, 3 or 7 days', 'Waters, weeds and harvests while you are away. Works beside your hired helpers.', 'Pays Gardening XP', 'g', '🪴 Gardening', 'Waters at Gardening 1, weeds from 3, harvests at 9.'],
    'trip' => ['🧺', 'Gathering trip', '1, 3 or 8 hours', 'Pick a land and a tool. The pal brings back what it finds.', 'Pays finds and Adventuring XP', 'a', '🧭 Adventuring', 'Rare finds need Adventuring 5. Unused potions come back.'],
    'delve' => ['🕳️', 'Re-run a cleared delve', 'Once a day per delve', 'Five rooms against the delve’s level. The chest pays about 60% of a real clear.', 'No first-clear bonus', 'a', '🧭 Adventuring', 'Unused potions come back.'],
];
$blocked = function (string $kind) use ($left, $maxAway, $runsLeft, $tools, $delves, $ranToday, $plots, $home): string {
    if ($left < 1) return 'All ' . $maxAway . ' jobs are taken. Collect one first.';
    if ($kind !== 'garden' && $runsLeft < 1) return 'Your pals have done enough trips and delves for today (' . pj_runs_per_day() . ').';
    if ($kind === 'garden' && !$plots) return 'Pals tend your gardens. Start one first.';
    if ($kind === 'trip' && !$tools) return 'Trips need a gathering tool in your satchel.';
    if ($kind === 'delve' && !$delves) return 'Clear a delve yourself first, then a pal can re-run it.';
    if ($kind === 'delve' && !array_diff(array_map(fn($d) => (int)$d['id'], $delves), $ranToday)) return 'Every delve you have cleared needs a day to settle.';
    if (!$home) return 'Everyone is out on a job.';
    return '';
};
$potionField = fn(string $kind): string => '<div class="pjfield"><label for="pjpot-' . $kind . '">Potions to pack</label>'
    . '<div class="pjstep"><input type="number" id="pjpot-' . $kind . '" name="potions" value="' . min(2, $potMax) . '" min="0" max="' . $potMax . '" inputmode="numeric" data-pj-step>'
    . '<small class="muted">' . ($potions ? 'of ' . $potions . ' · up to 5' : 'You have none') . '</small></div></div>';
$seg = function (string $name, string $legend, array $vals, int $on, callable $fmt): string {
    $h = '<fieldset class="pjfield pjseg"><legend>' . e($legend) . '</legend><div class="pjsegs">';
    foreach ($vals as $v) $h .= '<label><input type="radio" name="' . $name . '" value="' . (int)$v . '"' . ($v === $on ? ' checked' : '') . '><span>' . e($fmt($v)) . '</span></label>';
    return $h . '</div></fieldset>';
};

page_header('Pal Jobs');
?>
<div id="pz" class="pjpage" data-pj-now="<?= $now ?>">
  <div class="pjtop">
    <h1>🧩 Pal Jobs</h1>
    <ul class="chips pjcounts" aria-label="Today">
      <li class="chip<?= $runsLeft < 1 ? ' pjnone-left' : '' ?>"><b><?= $runsLeft ?></b> runs left</li>
      <li class="chip"><a href="<?= e(url('inventory.php?tab=craft&c=potions')) ?>" title="Craft Healing Potions at the Alchemy Table">🧪 <b><?= $potions ?></b> Potion<?= $potions === 1 ? '' : 's' ?></a></li>
      <li class="chip"><a href="<?= e(url('puzzlepals.php')) ?>">📖 Pal Book</a></li>
    </ul>
  </div>

  <?php if (!$pals): ?>
  <section class="box pjempty">
    <h2>No pals yet</h2>
    <p>Pals turn up at places on the map once you solve one of their pictures at Advanced. Find one and it can work for you here.</p>
    <a class="btn" href="<?= e(url('world.php')) ?>">🗺️ Open the map</a>
  </section>
  <?php else: ?>
  <div class="pjgrid">
    <section class="box pjpanel pjledger" aria-labelledby="pjouth">
      <header class="pjpanelhd">
        <h2 id="pjouth" tabindex="-1">Out and about</h2>
        <span class="pjslots"><span><b><?= count($jobs) ?></b> of <?= $maxAway ?> out</span>
          <span class="pjdots" aria-hidden="true"><?php for ($i = 0; $i < $maxAway; $i++): ?><i<?= $i < count($jobs) ? ' class="on"' : '' ?>></i><?php endfor; ?></span></span>
      </header>
      <?php if ($receipt && $receipt['lines']): $rp = $pals[$receipt['pal']] ?? null; ?>
      <div class="flash pjreceipt" role="status">
        <b><?= ($receipt['head'] ?? '') !== '' ? e($receipt['head']) : ($rp ? e($rp['name']) . ' is home.' : 'Collected.') ?></b>
        <ul><?php foreach ($receipt['lines'] as $i => $l): ?><li class="pjl<?= min($i, 7) ?>"><?= e($l) ?></li><?php endforeach; ?></ul>
      </div>
      <?php endif; ?>
      <ul class="pjrows">
        <?php foreach ($jobs as $j): $p = $pals[$j['pal_uid']] ?? null; if (!$p) continue;
          $r = json_decode((string)$j['result'], true) ?: [];
          $t0 = ts($j['started_at']); $t1 = ts($j['ends_at']);
          $ready = $j['state'] === 'ready';
          $pct = $ready ? 100 : max(2, min(100, (int)round(100 * ($now - $t0) / max(1, $t1 - $t0)))); ?>
        <li class="pjrow pj-<?= e($j['kind']) ?><?= $ready ? ' is-ready' : '' ?>"<?= !$ready && $j['kind'] !== 'garden' ? ' data-pj-start="' . $t0 . '" data-pj-end="' . $t1 . '"' : '' ?>>
          <?= ppal_img($p['key'], '', 'ppalimg pjimg', 44) ?>
          <div class="pjwho"><b><?= e($p['name']) ?></b>
            <small><?= $kindTxt[$j['kind']] ?? '' ?> · <?= $ready ? 'back home' . (!empty($r['fainted']) ? ' (ran out of HP)' : '') : e($jobLine($j)) ?></small></div>
          <div class="pjact">
            <?php if ($ready): ?>
            <span class="pjeta">Ready</span>
            <form method="post" action="<?= e(url('paljobs.php')) ?>"><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small" name="do" value="collect">Collect</button></form>
            <?php elseif ($j['kind'] === 'garden'): ?>
            <span class="pjeta pjeta-date">until <?= e(puzzle_local((string)$j['ends_at'], 'j M, H:i')) ?></span>
            <form method="post" action="<?= e(url('paljobs.php')) ?>"><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small ghost" name="do" value="recall">Call home</button></form>
            <?php else: ?>
            <span class="pjeta" data-pj-eta><?= e(pj_ago($t1 - $now)) ?></span>
            <small class="muted" data-pj-hide-at-zero>back at <?= e(puzzle_local((string)$j['ends_at'], 'H:i')) ?></small>
            <form method="post" action="<?= e(url('paljobs.php')) ?>" hidden data-pj-show-at-zero><?= csrf_field() ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small" name="do" value="collect">Collect</button></form>
            <?php endif; ?>
          </div>
          <progress class="pjbar" max="100" value="<?= $pct ?>" aria-label="<?= e($p['name']) ?>: <?= $pct ?>% of the way"></progress>
        </li>
        <?php endforeach; ?>
        <?php for ($i = count($jobs); $i < $maxAway; $i++): ?>
        <li class="pjrow pjfree"><span class="pjph" aria-hidden="true"></span><span>Free slot. <a href="#pjboard">Pick a job</a></span></li>
        <?php endfor; ?>
      </ul>
      <p class="pjfoot"><?php if ($nextBack && ($nb = $pals[$nextBack['pal_uid']] ?? null)): ?>Next back: <?= e($nb['name']) ?> at <?= e(puzzle_local((string)$nextBack['ends_at'], 'H:i')) ?>.<?php elseif ($anyReady): ?>Collect to free the slot.<?php else: ?>Gardeners stay until their days are up, or until you call them home.<?php endif; ?></p>
    </section>

    <section class="box pjpanel pjathome" aria-labelledby="pjhomeh">
      <header class="pjpanelhd"><h2 id="pjhomeh">At home</h2><small class="muted">HP grows back at home</small></header>
      <?php if (!$home): ?><p class="muted pjnone">Everyone is out on a job.</p><?php endif; ?>
      <ul class="pjrows">
        <?php foreach ($home as $p): $back = ($byUid[$p['uid']]['state'] ?? '') === 'ready'; ?>
        <li class="pjrow pjpal ppr-<?= e($p['pal']['rarity']) ?>">
          <?= ppal_img($p['key'], '', 'ppalimg pjimg', 44) ?>
          <div class="pjwho">
            <span class="pjnmrow"><b><?= e($p['name']) ?></b> <span class="ppalrar"><?= e(ucfirst($p['pal']['rarity'])) ?></span></span>
            <span class="pjstats">
              <span class="pjsk" title="Gardening">🪴<span class="vh">Gardening</span> <?= (int)$p['g'] ?></span>
              <span class="pjsk" title="Adventuring">🧭<span class="vh">Adventuring</span> <?= (int)$p['a'] ?></span>
              <?php if ($p['hp'] < 1): ?><span class="pjrest">Resting · 0/<?= (int)$p['max'] ?><span class="vh"> HP</span></span>
              <?php else: ?><span class="pjhp"><meter min="0" max="<?= (int)$p['max'] ?>" low="<?= (int)ceil($p['max'] * 0.4) ?>" high="<?= (int)ceil($p['max'] * 0.4) ?>" optimum="<?= (int)$p['max'] ?>" value="<?= (int)$p['hp'] ?>" aria-hidden="true"></meter><?= (int)$p['hp'] ?>/<?= (int)$p['max'] ?><span class="vh"> HP</span></span><?php endif; ?>
            </span>
            <?php if ($back || $p['active']): ?><small class="muted"><?= $back ? 'Just back: collect above' : 'Taken along: earns a little XP' ?></small><?php endif; ?>
          </div>
          <?php if ($p['hp'] < $p['max']): ?>
          <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjheal"><?= csrf_field() ?><input type="hidden" name="do" value="heal"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>">
            <button class="btn small ghost"<?= $potions < 1 ? ' disabled title="You have no Healing Potion."' : '' ?> aria-label="Give <?= e($p['name']) ?> a potion, plus <?= PJ_POTION_HEAL ?> HP">🧪 +<?= PJ_POTION_HEAL ?> HP</button></form>
          <?php endif; ?>
        </li>
        <?php endforeach; ?>
      </ul>
      <p class="pjfoot">A pal at 0 HP heads home. Healing Potions: craft them (Crafting → Potions) or buy them at Twigg’s Seed Emporium.</p>
    </section>
  </div>

  <section id="pjboard" class="pjboard" aria-labelledby="pjboardh">
    <div class="pjboardhd"><h2 id="pjboardh">Jobs</h2><p class="muted">Pick a job, then a pal.</p></div>
    <div class="pjposts">
      <?php foreach ($posts as $kind => [$ico, $title, $len, $desc, $pays, $sk, $skTxt, $why]):
        $stop = $blocked($kind);
        $ranked = $home;
        uasort($ranked, fn($a, $b) => [$b['hp'] > 0, $b[$sk], $b['hp']] <=> [$a['hp'] > 0, $a[$sk], $a['hp']]); ?>
      <article class="box pjpost pjpost-<?= $kind ?>" aria-labelledby="pjt-<?= $kind ?>">
        <div class="pjposthd"><span class="pjico" aria-hidden="true"><?= $ico ?></span><div><h3 id="pjt-<?= $kind ?>"><?= e($title) ?></h3><p class="pjlen"><?= e($len) ?></p></div></div>
        <p class="pjdesc"><?= e($desc) ?></p>
        <p class="pjpays muted"><?= e($pays) ?></p>
        <?php if ($stop !== ''): ?>
        <p class="pjblocked">⚠️ <?= e($stop) ?></p>
        <?php else: ?>
        <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjform" data-pj-kind="<?= $kind ?>"><?= csrf_field() ?><input type="hidden" name="do" value="send_<?= $kind ?>">
          <fieldset class="pjpick">
            <legend><span>Send who?</span> <small class="muted"><?= $skTxt ?></small></legend>
            <ul class="pjfaces">
              <?php foreach ($ranked as $p): $rest = $p['hp'] < 1; ?>
              <li><label class="pjface<?= $rest ? ' is-resting' : '' ?>">
                <input type="radio" name="pal" value="<?= e($p['uid']) ?>" required<?= $rest ? ' disabled' : '' ?><?= $p['active'] ? ' data-pj-party="1"' : '' ?>>
                <?= ppal_img($p['key'], '', 'ppalimg pjimg', 32) ?>
                <span class="pjnm"><?= e($p['name']) ?><?= $p['active'] ? ' <small class="pjparty">On party</small>' : '' ?></span>
                <?php if ($rest): ?><span class="pjlv pjlv-rest">Resting</span>
                <?php else: ?><meter class="pjfhp" min="0" max="<?= (int)$p['max'] ?>" low="<?= (int)ceil($p['max'] * 0.4) ?>" high="<?= (int)ceil($p['max'] * 0.4) ?>" optimum="<?= (int)$p['max'] ?>" value="<?= (int)$p['hp'] ?>" aria-hidden="true"></meter>
                <span class="pjlv"><span class="vh"><?= $sk === 'g' ? 'Gardening' : 'Adventuring' ?> </span><?= (int)$p[$sk] ?><span class="vh">, HP <?= (int)$p['hp'] ?> of <?= (int)$p['max'] ?></span></span><?php endif; ?>
              </label></li>
              <?php endforeach; ?>
            </ul>
          </fieldset>
          <label class="pjeq"><input type="checkbox" name="unequip" value="1"> <span>This pal is on your party (taken along). Take it off my party to send it out.</span></label>
          <div class="pjopts">
            <?php if ($kind === 'garden'): ?>
            <div class="pjfield"><label for="pjplot">Garden</label><select id="pjplot" name="plot"><?php foreach ($plotName as $id => $nm): ?><option value="<?= $id ?>"><?= e($nm) ?></option><?php endforeach; ?></select></div>
            <?= $seg('days', 'For', PJ_GARDEN_DAYS, 3, fn($d) => $d . ' day' . ($d > 1 ? 's' : '')) ?>
            <?php elseif ($kind === 'trip'): ?>
            <div class="pjfield"><label for="pjland">Where</label><select id="pjland" name="land"><?php foreach (LANDSCAPES as $k => $L): ?><option value="<?= e($k) ?>"><?= e($L[1]) ?></option><?php endforeach; ?></select></div>
            <div class="pjfield"><label for="pjtool">Tool</label><select id="pjtool" name="tool"><?php foreach ($tools as $t => $tier): ?><option value="<?= e($t) ?>"><?= e(TOOL_TYPES[$t][0] ?? $t) ?> (tier <?= (int)$tier ?>)</option><?php endforeach; ?></select></div>
            <?= $seg('hours', 'Hours', PJ_TRIP_HOURS, 3, fn($h) => $h . ' h') ?>
            <?= $potionField('trip') ?>
            <?php else: ?>
            <div class="pjfield"><label for="pjdelve">Delve</label><select id="pjdelve" name="delve"><?php foreach ($delves as $d): $ran = in_array((int)$d['id'], $ranToday, true); ?><option value="<?= (int)$d['id'] ?>"<?= $ran ? ' disabled' : '' ?>><?= e($delveName[(int)$d['id']]) ?><?= $ran ? ' · re-run today' : '' ?></option><?php endforeach; ?></select></div>
            <?= $potionField('delve') ?>
            <?php endif; ?>
            <p class="pjhint muted"><?= e($why) ?></p>
            <p class="pjback" data-pj-back aria-live="polite"><?= $kind === 'garden' ? 'Back when the days are up.' : ($kind === 'trip' ? 'Back when the hours are up, sooner if HP runs out.' : 'Back in about an hour.') ?></p>
            <button class="btn pjsend" data-pj-send>Send</button>
          </div>
        </form>
        <?php endif; ?>
      </article>
      <?php endforeach; ?>
    </div>
  </section>
  <?php endif; ?>
</div>
<?php page_footer();

<?php
declare(strict_types=1);
/**
 * Pal Jobs, the page parts as functions: the same markup paljobs.php shows (ledger, pals at home, one job post), so the Pal Yard picture (palyard.php)
 * puts the REAL job forms in its site popovers instead of copying them. Logic stays in pal_jobs.php; the POST handler stays in paljobs.php.
 *   $c = pjv_ctx($u, 'yard'|'')   (settles jobs, reads everything the parts need)   then   pjv_ledger($c), pjv_home($c), pjv_post($c, 'garden'|'trip'|'delve'|'station')
 * With $from = 'yard' every form also posts back=palyard, and paljobs.php sends the gnome back to the picture afterwards.
 */
require_once __DIR__ . '/puzzles.php';
require_once __DIR__ . '/puzzle_games.php';
require_once __DIR__ . '/jigsaw.php';
require_once __DIR__ . '/pal_jobs.php';
require_once __DIR__ . '/crafting.php';
require_once __DIR__ . '/craft_map.php';

/** Everything the job page parts read. */
function pjv_ctx(array $u, string $from = ''): array
{
    $uid = (int)$u['id'];
    $bk = $from === 'yard' ? '<input type="hidden" name="back" value="palyard">' : '';
pj_settle($uid);
$now = time();
$pals = pj_pals($uid);
$jobs = pj_jobs($uid);
$plots = q('SELECT id, garden_name FROM plots WHERE user_id = ? ORDER BY id', [$uid])->fetchAll();
$delves = pj_cleared_delves($uid);
$ranToday = array_map('intval', q("SELECT target FROM ppal_jobs WHERE user_id = ? AND kind = 'delve' AND day = ?", [$uid, landmark_day()])->fetchAll(PDO::FETCH_COLUMN));
$tools = pj_tools($uid);
// v2.3.99: which lands each owned tool can gather in (gather_candidates), so the pickers only offer what works
$toolLands = [];
foreach ($tools as $t => $tier) foreach (array_keys(LANDSCAPES) as $lk) if (gather_candidates($lk, $t)) $toolLands[$t][] = $lk;
$landTools = [];
foreach ($toolLands as $t => $ls) foreach ($ls as $lk) $landTools[$lk][] = $t;
$tripLands = array_values(array_filter(array_keys(LANDSCAPES), fn($lk) => !empty($landTools[$lk])));
$firstLand = $tripLands[0] ?? '';
$toolOpts = function (string $land, string $withBlank = '') use ($tools, $toolLands): string {
    $h = $withBlank !== '' ? '<option value="">' . e($withBlank) . '</option>' : '';
    foreach ($tools as $t => $tier) {
        $ok = $land === '' || in_array($land, $toolLands[$t] ?? [], true);
        $h .= '<option value="' . e($t) . '" data-lands="' . e(implode(' ', $toolLands[$t] ?? [])) . '"' . ($ok ? '' : ' disabled hidden') . '>' . e(TOOL_TYPES[$t][0] ?? $t) . ' (tier ' . (int)$tier . ')</option>';
    }
    return $h;
};
$landOpts = function (string $withBlank = '') use ($tripLands): string {
    $h = $withBlank !== '' ? '<option value="">' . e($withBlank) . '</option>' : '';
    foreach ($tripLands as $lk) $h .= '<option value="' . e($lk) . '">' . e(LANDSCAPES[$lk][1]) . '</option>';
    return $h;
};
$potions = pj_potion_count($uid);
$heals = alchemy_heals($uid);   // healing tiers held (Strong, Grand)
$lucky = alchemy_count($uid, ALCHEMY_LUCK);
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
// v2.4.70: any active job can be called home early (a confirm box says what it costs)
$recallBox = function (array $j) use ($bk): string {
    [$can, $txt] = pj_recall_preview($j);
    if ($txt === '') return '';
    return '<details class="pjrecall"><summary class="btn small ghost">Call home</summary><p class="muted">' . e($txt) . '</p>'
        . ($can ? '<form method="post" action="' . e(url('paljobs.php')) . '">' . csrf_field() . $bk . '<input type="hidden" name="job" value="' . (int)$j['id'] . '"><button class="btn small" name="do" value="recall">Call home now</button></form>' : '') . '</details>';
};
$kindTxt = ['garden' => '🪴 Garden', 'trip' => '🧺 Gathering', 'delve' => '🕳️ Delve', 'station' => '🍳 Station'];
$stationList = pj_station_list();
$jobLine = fn(array $j): string => match ($j['kind']) {
    'garden' => ($plotName[(int)$j['plot_id']] ?? 'a garden') . ' · ' . strtolower(pj_garden_task_text((int)$j['plot_id'])),   // v2.3.3: works after your hired help
    'trip' => (LANDSCAPES[$j['target']][1] ?? $j['target']) . ' · ' . (TOOL_TYPES[$j['tool']][0] ?? $j['tool']) . ' · ' . pj_ago(ts($j['ends_at']) - ts($j['started_at'])),
    'delve' => ($delveName[(int)$j['target']] ?? 'a delve') . ((int)$j['potions'] ? ' · ' . (int)$j['potions'] . ' potion' . ((int)$j['potions'] > 1 ? 's' : '') : ''),
    'station' => (($stationList[$j['target']][0] ?? '') . ' · ' . ($stationList[$j['target']][1] ?? 'station') . ' · ' . (($j['tool'] ?? '') === 'passive' ? 'tends a pot' : (int)(json_decode((string)$j['result'], true)['makes'] ?? 0) . ' makes')),
    default => '',
};
$nextBack = null;
foreach ($jobs as $j) if ($j['state'] === 'active' && $j['kind'] !== 'garden' && (!$nextBack || ts($j['ends_at']) < ts($nextBack['ends_at']))) $nextBack = $j;
$anyReady = (bool)array_filter($jobs, fn($j) => $j['state'] === 'ready');

// the board: [icon, title, length, what it does, what it pays, skill key, skill label, the small print]
$posts = [
    'garden' => ['🪴', 'Tend a garden', gclock_on() ? '1, 3 or 7 sleeps, or full time' : '1, 3 or 7 days', gclock_on() ? 'Pick a job (water, weed, pests, harvest, plant). The pal works while you sleep.' : 'Waters, weeds and harvests while you are away. Works after your hired help, on whatever is still undone.', 'Pays Gardening XP', 'g', '🪴 Gardening', 'Higher Gardening: more visits and extra crops.'],
    'trip' => ['🧺', 'Gathering trip', '1, 3 or 8 hours', 'Pick a land and a tool. The pal brings back what it finds.', 'Pays finds and Adventuring XP', 'a', '🧭 Adventuring', 'Higher Adventuring: more finds, more rares. Unused potions come back.'],
    'station' => ['🍳', 'Man a station', '1, 3 or 8 hours', 'A pal works one object of a crafting area (Stove, Workbench...): it makes everything that object makes, or recipes you pick (up to 5). No energy, but slower than you: one make per 60 minutes, faster as its Crafting skill grows. Cooking is passive: the pal holds one of your pots (you cannot use it meanwhile) and checks it every 10 minutes, cooking one batch at a time from your satchel. Pick the dish on the pot in your Kitchen.', 'Ingredients taken now (other stations); XP split: half to you, half to the pal', 'c', '🍳 Crafting', 'Other stations: one pal each. Cooking: one pal per free pot. Only recipes you know.'],
    'delve' => ['🕳️', 'Re-run a cleared delve', 'Once a day per delve', 'Five rooms against the delve’s level. The chest pays about 60% of a real clear.', 'No first-clear bonus', 'a', '🧭 Adventuring', 'Risky below Adventuring ' . PJ_DELVE_SAFE . ': pack potions. Unused potions come back.'],
];
$stSt = craft_stations($uid);
$stOk = array_filter($stationList, fn($v, $k) => ($stSt[explode(':', $k)[0]] ?? 0) !== 0, ARRAY_FILTER_USE_BOTH);   // v2.4.61: stations whose building you have
$stRecipes = [];   // recipe id => [row, 'area:obj' list]
if ($stOk) foreach (array_unique(array_map(fn($k) => explode(':', $k)[0], array_keys($stOk))) as $ar) {
    foreach (array_keys(array_filter($stOk, fn($v, $k) => str_starts_with($k, $ar . ':'), ARRAY_FILTER_USE_BOTH)) as $sk2) {
        $o2 = pj_station_object($ar, explode(':', $sk2)[1]);
        foreach (pj_station_recipes($uid, $ar, $o2['globs']) as $rid => $rr) { $stRecipes[$rid]['r'] = $rr; $stRecipes[$rid]['st'][] = $sk2; }
    }
}
$blocked = function (string $kind) use ($stOk, $left, $maxAway, $runsLeft, $tools, $delves, $ranToday, $plots, $home, $tripLands): string {
    if ($left < 1) return 'All ' . $maxAway . ' jobs are taken. Collect one first.';
    if (!in_array($kind, ['garden', 'station'], true) && $runsLeft < 1) return 'Your pals have done enough trips and delves for today (' . pj_runs_per_day() . ').';
    if ($kind === 'garden' && !$plots) return 'Pals tend your gardens. Start one first.';
    if ($kind === 'station' && !$stOk) return 'You need a Kitchen or Tool Shed (or another crafting building) first.';
    if ($kind === 'station' && $left < 1) return 'All jobs are taken. Collect one first.';
    if ($kind === 'trip' && !$tools) return 'Trips need a gathering tool in your satchel.';
    if ($kind === 'trip' && !$tripLands) return 'None of your tools can gather anywhere yet.';
    if ($kind === 'delve' && !$delves) return 'Clear a delve yourself first, then a pal can re-run it.';
    if ($kind === 'delve' && !array_diff(array_map(fn($d) => (int)$d['id'], $delves), $ranToday)) return 'Every delve you have cleared needs a day to settle.';
    if (!$home) return 'Everyone is out on a job.';
    return '';
};
$potionField = function (string $kind) use ($potions, $potMax, $heals): string {
    $h = '<div class="pjfield"><label for="pjpot-' . $kind . '">Potions to pack</label>'
        . '<div class="pjstep"><input type="number" id="pjpot-' . $kind . '" name="potions" value="' . min(2, $potMax) . '" min="0" max="' . $potMax . '" inputmode="numeric" data-pj-step>'
        . '<small class="muted">' . ($potions ? 'of ' . $potions . ' · up to 5' : 'You have none') . '</small></div>';
    foreach ($heals as $hs => $hv) {   // v2.5.49: Strong Healing Potions and Grand Healing Elixirs can be packed too (5 potions in all)
        if ($hs === PJ_POTION) continue;
        $f = $hs === 'strong-healing-potion' ? 'potions_strong' : 'potions_grand';
        $h .= '<label for="pjpot-' . $kind . '-' . $f . '">' . e($hv['name']) . ' <small class="muted">' . e(alchemy_pal_label($hs)) . ' · of ' . (int)$hv['qty'] . '</small></label>'
            . '<div class="pjstep"><input type="number" id="pjpot-' . $kind . '-' . $f . '" name="' . $f . '" value="0" min="0" max="' . min(5, (int)$hv['qty']) . '" inputmode="numeric" data-pj-step data-pj-label="' . e($hv['name']) . ' to pack"></div>';
    }
    return $h . '</div>';
};
$seg = function (string $name, string $legend, array $vals, int $on, callable $fmt): string {
    $h = '<fieldset class="pjfield pjseg"><legend>' . e($legend) . '</legend><div class="pjsegs">';
    foreach ($vals as $v) $h .= '<label><input type="radio" name="' . $name . '" value="' . (int)$v . '"' . ($v === $on ? ' checked' : '') . '><span>' . e($fmt($v)) . '</span></label>';
    return $h . '</div></fieldset>';
};

    return get_defined_vars();
}

/** The ledger panel: pals out, progress, Collect / Call home. */
function pjv_ledger(array $c): string
{
    extract($c);
    require_once __DIR__ . '/pal_crew.php';
    $crewRows = []; try { pcrew_boot(); $crewRows = q('SELECT s.*, pl.garden_name AS plot_name FROM garden_pal_slots s LEFT JOIN plots pl ON pl.id = s.plot_id WHERE s.user_id = ? ORDER BY s.plot_id, s.id', [$GLOBALS['u']['id'] ?? 0])->fetchAll(); } catch (Throwable $e) {}
    ob_start(); ?>
    <?php if ($crewRows): ?>
    <section class="box pjpanel pjcrew" aria-labelledby="pjcrewh">
      <header class="pjpanelhd"><h2 id="pjcrewh">🌱 Garden crew</h2><small class="muted">working while you sleep</small></header>
      <?php foreach ($crewRows as $cr): $cp = pj_pal((int)$cr['user_id'], (string)$cr['pal_uid']); ?>
        <div class="pjcrewrow">
          <span class="pjcrewtxt"><?= PCREW_ROLES[$cr['role']][0] ?? '🧩' ?> <b><?= e($cp['name'] ?? 'A pal') ?></b><?= pcrew_tired($cr) ? ' <span class="bang" title="Wants a change">!</span>' : '' ?> · <?= e(PCREW_ROLES[$cr['role']][1] ?? $cr['role']) ?><br>
            <small class="muted"><?= e((string)($cr['plot_name'] ?? 'Garden')) ?> · <?= $cr['mode'] === 'full' ? 'full time' : 'sleep ' . min((int)$cr['nights'], (int)$cr['done'] + 1) . ' of ' . (int)$cr['nights'] ?></small></span>
        </div>
      <?php endforeach; ?>
      <p class="pjcrewlink"><a class="btn small alt" href="<?= e(url('garden.php?t=help')) ?>">About the crew</a></p>
    </section>
    <?php endif; ?>
    <section class="box pjpanel pjledger" aria-labelledby="pjouth">
      <header class="pjpanelhd">
        <h2 id="pjouth" tabindex="-1">Out and about</h2>
        <span class="pjslots"><span><b><?= count($jobs) ?></b> of <?= $maxAway ?> out</span>
          <span class="pjdots" aria-hidden="true"><?php for ($i = 0; $i < $maxAway; $i++): ?><i<?= $i < count($jobs) ? ' class="on"' : '' ?>></i><?php endfor; ?></span></span>
      </header>
      <?php if (count(array_filter($jobs, fn($j) => $j['state'] === 'ready')) > 1): ?>
      <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjcollectall"><?= csrf_field() ?><?= $bk ?><button class="btn small" name="do" value="collect_all">Collect all (<?= count(array_filter($jobs, fn($j) => $j['state'] === 'ready')) ?>)</button></form>
      <?php endif; ?>
      <?php if ($receipt && !empty($receipt['chips'])): ?>
      <div class="flash pjreceipt" role="status"><b><?= e((string)$receipt['head']) ?></b>
        <ul class="pjchips"><?php foreach ($receipt['chips'] as $i => $c): ?><li class="pjl<?= min($i, 7) ?>"><?= e($c) ?></li><?php endforeach; ?></ul></div>
      <?php elseif ($receipt && $receipt['lines']): $rp = $pals[$receipt['pal']] ?? null; ?>
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
            <form method="post" action="<?= e(url('paljobs.php')) ?>"><?= csrf_field() ?><?= $bk ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small" name="do" value="collect">Collect</button></form>
            <?php elseif ($j['kind'] === 'garden'): ?>
            <span class="pjeta pjeta-date">until <?= e(puzzle_local((string)$j['ends_at'], 'j M, H:i')) ?></span>
            <?= $recallBox($j) ?>
            <?php else: ?>
            <span class="pjeta" data-pj-eta><?= e(pj_ago($t1 - $now)) ?></span>
            <small class="muted" data-pj-hide-at-zero>back at <?= e(puzzle_local((string)$j['ends_at'], 'H:i')) ?></small>
            <form method="post" action="<?= e(url('paljobs.php')) ?>" hidden data-pj-show-at-zero><?= csrf_field() ?><?= $bk ?><input type="hidden" name="job" value="<?= (int)$j['id'] ?>"><button class="btn small" name="do" value="collect">Collect</button></form>
            <?= $recallBox($j) ?>
            <?php endif; ?>
          </div>
          <progress class="pjbar" max="100" value="<?= $pct ?>" aria-label="<?= e($p['name']) ?>: <?= $pct ?>% of the way"></progress>
        </li>
        <?php endforeach; ?>
        <?php for ($i = count($jobs); $i < $maxAway; $i++): ?>
        <li class="pjrow pjfree"><span class="pjph" aria-hidden="true"></span><span>Free slot. <?= $from === 'yard' ? 'Tap a site in the yard' : '<a href="#pjboard">Pick a job</a>' ?></span></li>
        <?php endfor; ?>
      </ul>
      <p class="pjfoot"><?php if ($nextBack && ($nb = $pals[$nextBack['pal_uid']] ?? null)): ?>Next back: <?= e($nb['name']) ?> at <?= e(puzzle_local((string)$nextBack['ends_at'], 'H:i')) ?>.<?php elseif ($anyReady): ?>Collect to free the slot.<?php else: ?>Gardeners stay until their days are up, or until you call them home.<?php endif; ?></p>
    </section>
<?php
    return (string)ob_get_clean();
}

/** The pals-at-home panel (HP, heal). */
function pjv_home(array $c): string
{
    extract($c);
    ob_start(); ?>
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
          <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjheal"><?= csrf_field() ?><?= $bk ?><input type="hidden" name="do" value="heal"><input type="hidden" name="pal" value="<?= e($p['uid']) ?>">
            <button class="btn small ghost"<?= $potions < 1 ? ' disabled title="You have no Healing Potion."' : '' ?> aria-label="Give <?= e($p['name']) ?> a potion, plus <?= PJ_POTION_HEAL ?> HP">🧪 +<?= PJ_POTION_HEAL ?> HP</button>
            <?php foreach ($heals as $hs => $hv): if ($hs === PJ_POTION) continue; ?><button class="btn small ghost" name="potion" value="<?= e($hs) ?>" aria-label="Give <?= e($p['name']) ?> a <?= e($hv['name']) ?>, <?= e(alchemy_pal_label($hs)) ?>">🧪 <?= e(alchemy_pal_label($hs)) ?> <small>×<?= $hv['qty'] ?></small></button><?php endforeach; ?></form>
          <?php endif; ?>
        </li>
        <?php endforeach; ?>
      </ul>
      <p class="pjfoot">A pal at 0 HP heads home. Healing Potions: craft them (Crafting → Potions) or buy them at Twigg’s Seed Emporium.</p>
    </section>
<?php
    return (string)ob_get_clean();
}

/** One job post (the form for garden, trip, delve or station), or its blocked reason. */
function pjv_post(array $c, string $kind): string
{
    extract($c);
        [$ico, $title, $len, $desc, $pays, $sk, $skTxt, $why] = $posts[$kind];
        $stop = $blocked($kind);
        $ranked = $home;
        uasort($ranked, fn($a, $b) => [$b['hp'] > 0, $b[$sk], $b['hp']] <=> [$a['hp'] > 0, $a[$sk], $a['hp']]);
    ob_start(); ?>
      <article class="box pjpost pjpost-<?= $kind ?>" aria-labelledby="pjt-<?= $kind ?>">
        <div class="pjposthd"><span class="pjico" aria-hidden="true"><?= $ico ?></span><div><h3 id="pjt-<?= $kind ?>"><?= e($title) ?></h3><p class="pjlen"><?= e($len) ?></p></div></div>
        <p class="pjdesc"><?= e($desc) ?></p>
        <p class="pjpays muted"><?= e($pays) ?></p>
        <?php if ($stop !== ''): ?>
        <p class="pjblocked">⚠️ <?= e($stop) ?></p>
        <?php else: ?>
        <form method="post" action="<?= e(url('paljobs.php')) ?>" class="pjform" data-pj-kind="<?= $kind ?>"><?= csrf_field() ?><?= $bk ?><input type="hidden" name="do" value="send_<?= $kind ?>">
          <fieldset class="pjpick">
            <legend><span>Send who?</span> <small class="muted">tick one or more</small> <small class="muted"><?= $skTxt ?></small></legend>
            <ul class="pjfaces">
              <?php foreach ($ranked as $p): $rest = $p['hp'] < 1; $risky = $kind === 'delve' && $p['a'] < PJ_DELVE_SAFE; ?>
              <li><label class="pjface<?= $rest ? ' is-resting' : '' ?>">
                <input type="checkbox" name="pals[]" value="<?= e($p['uid']) ?>"<?= $rest ? ' disabled' : '' ?><?= $p['active'] ? ' data-pj-party="1"' : '' ?><?= $risky ? ' data-pj-risky="1"' : '' ?>>
                <?= ppal_img($p['key'], '', 'ppalimg pjimg', 32) ?>
                <span class="pjnm"><?= e($p['name']) ?><?= $p['active'] ? ' <small class="pjparty">On party</small>' : '' ?><?= $risky ? ' <small class="pjrisky">Risky</small>' : '' ?></span>
                <?php if ($rest): ?><span class="pjlv pjlv-rest">Resting</span>
                <?php else: ?><meter class="pjfhp" min="0" max="<?= (int)$p['max'] ?>" low="<?= (int)ceil($p['max'] * 0.4) ?>" high="<?= (int)ceil($p['max'] * 0.4) ?>" optimum="<?= (int)$p['max'] ?>" value="<?= (int)$p['hp'] ?>" aria-hidden="true"></meter>
                <span class="pjlv"><span class="vh"><?= $sk === 'g' ? 'Gardening' : ($sk === 'c' ? 'Crafting' : 'Adventuring') ?> </span><?= (int)$p[$sk] ?><span class="vh">, HP <?= (int)$p['hp'] ?> of <?= (int)$p['max'] ?></span></span><?php endif; ?>
              </label>
              <?php if (count($ranked) > 0 && !$rest): ?>
              <div class="pjover">
                <?php if ($kind === 'garden' && count($plotName) > 1): ?>
                <label>Garden<select name="over[<?= e($p['uid']) ?>][plot]"><option value="">As above</option><?php foreach ($plotName as $id => $nm): ?><option value="<?= $id ?>"><?= e($nm) ?></option><?php endforeach; ?></select></label>
                <?php elseif ($kind === 'trip'): ?>
                <label>Where<select name="over[<?= e($p['uid']) ?>][land]" data-pj-pland><?= $landOpts('As above') ?></select></label>
                <label>Tool<select name="over[<?= e($p['uid']) ?>][tool]" data-pj-ptool><?= $toolOpts($firstLand, 'As above') ?></select></label>
                <?php elseif ($kind === 'station'): ?>
                <label>Station<select name="over[<?= e($p['uid']) ?>][station]"><option value="">As above</option><?php foreach ($stOk as $sv => [$sa, $so]): ?><option value="<?= e($sv) ?>"><?= e($sa . ' · ' . $so) ?></option><?php endforeach; ?></select></label>
                <?php elseif ($kind === 'delve'): ?>
                <label>Delve<select name="over[<?= e($p['uid']) ?>][delve]"><option value="">As above</option><?php foreach ($delves as $d): $ran = in_array((int)$d['id'], $ranToday, true); ?><option value="<?= (int)$d['id'] ?>"<?= $ran ? ' disabled' : '' ?>><?= e($delveName[(int)$d['id']]) ?><?= $ran ? ' · re-run today' : '' ?></option><?php endforeach; ?></select></label>
                <?php endif; ?>
              </div>
              <?php endif; ?>
              </li>

              <?php endforeach; ?>
            </ul>
          </fieldset>
          <?php if ($kind === 'delve'): ?><p class="pjriskwarn" role="note">⚠️ Below Adventuring <?= PJ_DELVE_SAFE ?> a pal often runs out of HP down there and comes home with little. Pack potions, or pick a stronger pal.</p><?php endif; ?>
          <label class="pjeq"><input type="checkbox" name="unequip" value="1"> <span>This pal is on your party (taken along). Take it off my party to send it out.</span></label>
          <div class="pjopts">
            <?php if ($kind === 'garden'): ?>
            <div class="pjfield"><label for="pjplot">Garden</label><select id="pjplot" name="plot"><?php foreach ($plotName as $id => $nm): ?><option value="<?= $id ?>"><?= e($nm) ?></option><?php endforeach; ?></select></div>
            <?php if (gclock_on()): require_once __DIR__ . '/pal_crew.php'; ?>
            <div class="pjfield"><label for="pjrole">Job</label><select id="pjrole" name="role"><?php foreach (PCREW_ROLES as $rk => $rv): if (!$rv[3]) continue; ?><option value="<?= e($rk) ?>"><?= $rv[0] ?> <?= e($rv[1]) ?></option><?php endforeach; ?></select></div>
            <fieldset class="pjfield pjseg"><legend>For</legend><div class="pjsegs"><?php foreach (PCREW_NIGHTS as $n): ?><label><input type="radio" name="days" value="<?= $n ?>"<?= $n === 3 ? ' checked' : '' ?>><span><?= $n ?> sleep<?= $n > 1 ? 's' : '' ?></span></label><?php endforeach; ?><label><input type="radio" name="days" value="full"><span>Full time</span></label></div></fieldset>
            <?php else: ?>
            <?= $seg('days', 'For', PJ_GARDEN_DAYS, 3, fn($d) => $d . ' day' . ($d > 1 ? 's' : '')) ?>
            <?php endif; ?>
            <?php elseif ($kind === 'trip'): ?>
            <div class="pjfield"><label for="pjland">Where (default)</label><select id="pjland" name="land" data-pj-gland><?= $landOpts() ?></select></div>
            <div class="pjfield"><label for="pjtool">Tool</label><select id="pjtool" name="tool" data-pj-gtool><?= $toolOpts($firstLand) ?></select></div>
            <?= $seg('hours', 'Hours', PJ_TRIP_HOURS, 3, fn($h) => $h . ' h') ?>
            <?= $potionField('trip') ?>
            <?php if ($lucky > 0): ?><label class="pjluck"><input type="checkbox" name="luck" value="1"> <span>🍀 Pack a Lucky Draught (Luck +<?= ALCHEMY_LUCK_PAL ?> for the trip, you have <?= $lucky ?>)</span></label><?php endif; ?>
            <?php elseif ($kind === 'station'): ?>
            <div class="pjfield"><label for="pjstation">Station</label><select id="pjstation" name="station" data-pj-gstation><?php foreach ($stOk as $sv => [$sa, $so]): ?><option value="<?= e($sv) ?>"<?= (string)($_GET['station'] ?? '') === $sv ? ' selected' : '' ?>><?= e($sa . ' · ' . $so) ?></option><?php endforeach; ?></select></div>
            <fieldset class="pjfield pjseg"><legend>Make</legend><div class="pjsegs"><label><input type="radio" name="mode" value="all" checked><span>Everything it can</span></label><label><input type="radio" name="mode" value="chosen"><span>Chosen recipes</span></label></div></fieldset>
            <details class="pjfield pjrecipes" data-pj-recipes><summary>Chosen recipes <small class="muted" data-pj-rcount>0 of 5</small></summary>
              <input type="search" class="pjrq" data-pj-rfilter placeholder="🔍 Find a recipe…" aria-label="Find a recipe" autocomplete="off">
              <div class="pjrlist"><?php foreach ($stRecipes as $rid => $rx): ?><label class="pjrecipe" data-st="<?= e(implode(' ', $rx['st'])) ?>" data-name="<?= e(mb_strtolower((string)$rx['r']['name'])) ?>"><input type="checkbox" name="recipes[]" value="<?= (int)$rid ?>"> <span><?= e((string)$rx['r']['name']) ?></span></label>
              <?php endforeach; ?><?php if (!$stRecipes): ?><small class="muted">You know no recipes for these stations yet.</small><?php endif; ?></div>
              <p class="muted pjrnone" hidden>No recipe matches.</p></details>
            <?= $seg('hours', 'Hours', PJ_TRIP_HOURS, 3, fn($h) => $h . ' h') ?>
            <?php else: ?>
            <div class="pjfield"><label for="pjdelve">Delve</label><select id="pjdelve" name="delve"><?php foreach ($delves as $d): $ran = in_array((int)$d['id'], $ranToday, true); ?><option value="<?= (int)$d['id'] ?>"<?= $ran ? ' disabled' : '' ?>><?= e($delveName[(int)$d['id']]) ?><?= $ran ? ' · re-run today' : '' ?></option><?php endforeach; ?></select></div>
            <?= $potionField('delve') ?>
            <?php endif; ?>
            <p class="pjhint muted"><?= e($why) ?></p>
            <p class="pjback" data-pj-back aria-live="polite"><?= $kind === 'garden' ? 'Back when the days are up.' : ($kind === 'trip' ? 'Back when the hours are up, sooner if HP runs out.' : ($kind === 'station' ? 'Back when the shift ends; the makes wait for you.' : 'Back in about an hour.')) ?></p>
            <button class="btn pjsend" data-pj-send>Send</button>
          </div>
        </form>
        <?php endif; ?>
      </article>
<?php
    return (string)ob_get_clean();
}

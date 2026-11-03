<?php
declare(strict_types=1);
/**
 * New player experience: create your gnome, pick a village in the Maplewold (v0.7.43: everyone starts there), name your first garden.
 * Choices are kept in the session until the last step, then everything is created in one transaction.
 */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/gnome.php';
require_once __DIR__ . '/includes/adventure_data.php';
require_once __DIR__ . '/includes/catalog.php';
require_once __DIR__ . '/includes/world.php';
require_once __DIR__ . '/includes/items.php';
require_once __DIR__ . '/includes/onboard.php';   // v2.0.75: village_welcome_pack(), swatch(), onboard_create() (shared with guest.php)

$u = require_login();
$uid = (int)$u['id'];
if ((int)($u['onboarded'] ?? 1) === 1) {
    redirect('garden.php');
}

$STEPS = ['gnome' => 'Your gnome', 'place' => 'Village', 'garden' => 'First garden'];
$wf = $_SESSION['welcome'] ?? [];
$wf += ['name' => '', 'hat' => array_key_first(HAT_COLORS), 'beard' => array_key_first(BEARD_COLORS),
        'region_id' => 0, 'village_id' => 0, 'garden' => ''];
// v0.7.43: every gnome starts in the same region (The Maplewold unless the admin picks another) and adventures outward
$startRegion = start_region_id();
// v0.7.48: start only where the next stops are gentle (unless no village in the region is)
$gentleAny = (bool)array_filter(q("SELECT l.id FROM locations l WHERE l.region_id = ? AND l.kind = 'village'
    AND EXISTS (SELECT 1 FROM routes r WHERE r.kind = 'road' AND (r.a_id = l.id OR r.b_id = l.id))", [$startRegion])->fetchAll(PDO::FETCH_COLUMN), fn($id) => gentle_start_village((int)$id));
if ((int)$wf['region_id'] !== $startRegion) { $wf['region_id'] = $startRegion; $wf['village_id'] = 0; }

/** The furthest step the player may open, given what they've chosen so far. */
$reachable = function (array $wf) use ($STEPS): array {
    $ok = ['gnome'];
    if ($wf['name'] !== '' && $wf['region_id']) $ok[] = 'place';
    if ($wf['name'] !== '' && $wf['region_id'] && $wf['village_id']) $ok[] = 'garden';
    return $ok;
};

$errors = [];
if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    if ($do === 'gnome') {
        $name = trim(preg_replace('/\s+/u', ' ', (string)($_POST['gnome_name'] ?? '')));
        $hat = (string)($_POST['hat'] ?? '');
        $beard = (string)($_POST['beard'] ?? '');
        if (!preg_match("/^\\p{L}[\\p{L} '’.-]{1,23}$/u", $name)) {
            $errors[] = 'Gnome names need 2–24 letters. Spaces, apostrophes and hyphens are fine too.';
        }
        require_once __DIR__ . '/includes/moderation.php';
        if ($name !== '' && blocked_word($name)) $errors[] = 'Please pick a friendlier name.';
        if (!isset(HAT_COLORS[$hat])) $errors[] = 'Pick a hat colour.';
        if (!isset(BEARD_COLORS[$beard])) $errors[] = 'Pick a beard colour.';
        $wf['name'] = $errors ? $wf['name'] : $name;
        $wf['hat'] = isset(HAT_COLORS[$hat]) ? $hat : $wf['hat'];
        $wf['beard'] = isset(BEARD_COLORS[$beard]) ? $beard : $wf['beard'];
        if (!$errors) { $_SESSION['welcome'] = $wf; redirect('welcome.php?step=place'); }
        $step = 'gnome';
    } elseif ($do === 'place') {
        $vid = (int)($_POST['village_id'] ?? 0);
        if (!q_val("SELECT 1 FROM locations l WHERE l.id = ? AND l.region_id = ? AND l.kind = 'village'
                    AND EXISTS (SELECT 1 FROM routes r WHERE r.kind = 'road' AND (r.a_id = l.id OR r.b_id = l.id))", [$vid, $wf['region_id']])
            || (!gentle_start_village($vid) && $gentleAny)) {
            $errors[] = 'Choose a village to start in.';
            $step = 'place';
        } else {
            $wf['village_id'] = $vid;
            $_SESSION['welcome'] = $wf;
            redirect('welcome.php?step=garden');
        }
    } elseif ($do === 'finish') {
        $garden = trim(preg_replace('/\s+/u', ' ', (string)($_POST['garden_name'] ?? '')));
        $wf['garden'] = $garden;
        $_SESSION['welcome'] = $wf;
        if ($garden === '' || mb_strlen($garden) > 40) $errors[] = 'Garden names need 1–40 characters.';
        require_once __DIR__ . '/includes/moderation.php';
        if ($garden !== '' && blocked_word($garden)) $errors[] = 'Please pick a friendlier garden name.';
        if (!in_array('garden', $reachable($wf), true)) $errors[] = 'A step was skipped. Please go back and finish it.';
        if (!$errors) {
            onboard_create($uid, $wf['name'], $wf['hat'], $wf['beard'], (int)$wf['region_id'], (int)$wf['village_id'], $garden, 1);
            unset($_SESSION['welcome']);
            flash('🌱 ' . $wf['name'] . ' has arrived! Wren is waiting in your garden to show you around.');
            redirect('garden.php');
        }
        $step = 'garden';
    }
}

$step ??= (string)($_GET['step'] ?? 'gnome');
$ok = $reachable($wf);
if (!isset($STEPS[$step]) || !in_array($step, $ok, true)) {
    $step = end($ok);
}
$preview = ['hat_color' => $wf['hat'], 'beard_color' => $wf['beard'], 'gnome_name' => $wf['name'], 'username' => $u['username']];
$region = $wf['region_id'] ? q_one('SELECT * FROM regions WHERE id = ?', [$wf['region_id']]) : null;

/** Seed chips: "🫛 Soybean ×2" (kept for callers outside the redesigned welcome flow) */
function seed_chips(array $list): string
{
    $out = '';
    foreach ($list as $s) {
        $label = $s[4] ?? $s[1];
        $out .= '<span class="chip">' . pack_icon($s) . ' ' . e($label) . ' <b>×' . (int)$s[2] . '</b></span>';
    }
    return $out;
}

/** v2.4.96: progress bar (three icon tiles joined by bars); done tiles link back to their step. */
function welcome_progress(array $STEPS, array $ok, string $step): string
{
    $keys = array_keys($STEPS);
    $cur = (int)array_search($step, $keys, true);
    $icons = ['gnome' => 'progress-gnome', 'place' => 'progress-house', 'garden' => 'progress-sprout'];
    $out = '<div class="wprog" role="group" aria-label="Step ' . ($cur + 1) . ' of 3: ' . e($STEPS[$step]) . '">';
    foreach ($keys as $i => $key) {
        $state = $i < $cur ? 'done' : ($i === $cur ? 'now' : 'todo');
        $inner = $state === 'done' ? '<span class="tick" aria-hidden="true">✓</span>'
            : '<img class="pxl" src="' . e(url('assets/img/welcome/' . $icons[$key] . '.png')) . '" width="18" height="18" alt="">';
        $label = ($i + 1) . '. ' . $STEPS[$key];
        if ($i) $out .= '<b class="bar' . ($i <= $cur ? ' done' : '') . '" aria-hidden="true"></b>';
        if ($state === 'done' && in_array($key, $ok, true)) {
            $out .= '<a class="tile done" href="' . e(url('welcome.php?step=' . $key)) . '" title="' . e($label) . '" aria-label="' . e($label . ' (done, go back)') . '">' . $inner . '</a>';
        } else {
            $out .= '<span class="tile ' . $state . '" title="' . e($label) . '"' . ($state === 'now' ? ' aria-current="step"' : '') . '>' . $inner . '</span>';
        }
    }
    return $out . '</div>';
}

/** v2.4.96: Wren's bubble: portrait, one or two short sentences ($short is trusted HTML), long copy behind "More". */
function welcome_wren(string $short, string $more = ''): string
{
    return '<div class="wren"><div class="bubble"><img class="pxl wrenpic" src="' . e(url('assets/img/welcome/wren-portrait.png')) . '" width="72" height="72" alt="Wren Thimblewick">'
        . '<div class="txt"><p>' . $short . '</p>'
        . ($more !== '' ? '<details class="wmore"><summary>More</summary><div>' . $more . '</div></details>' : '')
        . '</div></div></div>';
}

/** v2.4.96: the sticky bottom bar: one primary button and a Back link. */
function welcome_cta(string $btn, string $backHref = '', string $backText = '← Back'): string
{
    return '<div class="wcta"><button class="btn">' . $btn . '</button>'
        . ($backHref !== '' ? '<a class="wback" href="' . e(url($backHref)) . '">' . e($backText) . '</a>' : '') . '</div>';
}

page_header('Welcome to the Hollow');
?>
<div class="welcomeflow">
<?= welcome_progress($STEPS, $ok, $step) ?>
<?php foreach ($errors as $err): ?><div class="flash err"><?= e($err) ?></div><?php endforeach; ?>

<?php if ($step === 'gnome'): ?>
  <?= welcome_wren('Well now! A brand-new gnome, fresh out of the toadstool. <b>Who are you?</b>',
      '<p>I’m Wren. I travel the fourteen regions of the Hollow collecting seeds and stories. Before I show you around, tell me who you are.</p>'
      . '<p>This is the name other players and NPCs will see. Your log-in name stays private.</p>'
      . '<p>When your gnome takes up a calling at level 5, the calling’s hat colour takes over.</p>') ?>
  <form method="post" class="wform" data-gnome-preview>
    <?= csrf_field() ?><input type="hidden" name="do" value="gnome">
    <div class="wstage">
      <img class="pxl wstagebg" src="<?= e(url('assets/img/welcome/stage-backdrop.png')) ?>" width="380" height="230" alt="">
      <div class="wgnome"><?= gnome_avatar($preview, 160) ?></div>
    </div>
    <input class="wname" name="gnome_name" value="<?= e($wf['name']) ?>" required maxlength="24" placeholder="Your gnome’s name, e.g. Bramble Puddlefoot" aria-label="Your gnome’s name" autocomplete="off">
    <fieldset class="wrow"><legend class="sr">Hat colour</legend>
      <span class="rowico" aria-hidden="true">🎩</span>
      <?php foreach (HAT_COLORS as $c => $label): echo swatch_tile('hat', $c, $c, $label . ' hat', $wf['hat'] === $c, 'hat'); endforeach; ?>
    </fieldset>
    <fieldset class="wrow"><legend class="sr">Beard colour</legend>
      <span class="rowico" aria-hidden="true">🧔</span>
      <?php foreach (BEARD_COLORS as $c => $label): echo swatch_tile('beard', $c, $c, $label . ' beard', $wf['beard'] === $c, 'beard'); endforeach; ?>
    </fieldset>
    <?= welcome_cta('Next: pick your village →') ?>
  </form>

<?php elseif ($step === 'place' && $region):
    $default = (int)$wf['village_id'] ?: (int)first_village((int)$region['id']);
    $cards = [];
    foreach (q('SELECT * FROM zones WHERE region_id = ? ORDER BY zone_num', [$region['id']])->fetchAll() as $z) {
        $villages = q("SELECT l.id, l.name, l.slug FROM locations l WHERE l.zone_id = ? AND l.kind = 'village'
                       AND EXISTS (SELECT 1 FROM routes r WHERE r.kind = 'road' AND (r.a_id = l.id OR r.b_id = l.id)) ORDER BY l.sort_order", [$z['id']])->fetchAll();
        if ($gentleAny) $villages = array_values(array_filter($villages, fn($v) => gentle_start_village((int)$v['id'])));
        foreach ($villages as $v) $cards[] = $v + ['landscape' => (string)$z['landscape']];   // only villages on the roads (v0.7.24)
    }
    $ids = array_map(fn($v) => (int)$v['id'], $cards);
    if (!in_array($default, $ids, true) && $ids) $default = $ids[0];
    $short = 'Lovely to meet you, <b>' . e($wf['name']) . '</b>! Where shall we plant your first garden in the <b>' . e($region['gnomish_name']) . '</b>?';
    $more = '<p>Every gnome’s journey starts here in <b>' . e($region['gnomish_name']) . '</b>. Its villages sit along the mycelium roads between the towns, and the roads here are gentle. '
        . 'Further out, the world gets wilder: each region has a recommended level, and once you’ve walked somewhere you can travel straight back any time.</p>'
        . '<p>The locals send you off with: <span class="chips small">' . seed_chips(home_seed_list((int)$region['id'])) . '</span></p>'; ?>
  <?= welcome_wren($short, $more) ?>
  <form method="post" class="wform">
    <?= csrf_field() ?><input type="hidden" name="do" value="place">
    <div class="vcards" role="radiogroup" aria-label="Village">
      <?php foreach ($cards as $v): $L = LANDSCAPES[$v['landscape']] ?? ['📍', ucfirst($v['landscape']), ''];
          $vslug = preg_replace('/[^a-z0-9-]/', '', strtolower(slugify((string)$v['name'])));
          $art = 'assets/img/villages/' . $vslug . '.png'; ?>
        <label class="vcard"><input type="radio" name="village_id" value="<?= (int)$v['id'] ?>" required data-vname="<?= e($v['name']) ?>"<?= (int)$v['id'] === $default ? ' checked' : '' ?>>
          <?php if ($vslug !== '' && is_file(APP_ROOT . '/' . $art)): ?>
            <img class="pxl vil" src="<?= e(url($art)) ?>" width="160" height="100" alt="">
          <?php else: ?>
            <span class="vil vfall ls-<?= e(preg_replace('/[^a-z]/', '', $v['landscape'])) ?>" aria-hidden="true"><?= $L[0] ?></span>
          <?php endif; ?>
          <span class="vname"><?= e($v['name']) ?></span></label>
      <?php endforeach; ?>
    </div>
    <div class="wbaskets" aria-live="polite" aria-atomic="true">
      <?php foreach ($cards as $v): $pack = village_welcome_pack((int)$v['id']); ?>
        <section class="wbgroup" data-village="<?= (int)$v['id'] ?>"<?= (int)$v['id'] === $default ? '' : ' hidden' ?>>
          <h3 class="wbtitle"><span aria-hidden="true">🧺</span> <?= e($v['name']) ?>’s welcome basket</h3>
          <div class="wbasket">
            <img class="pxl wbart" src="<?= e(url('assets/img/welcome/welcome-basket-topdown.png')) ?>" width="380" height="330" alt="">
            <div class="wbfloor"><div class="wbitems"><?= pack_slots($pack, true) ?></div></div>
          </div>
        </section>
      <?php endforeach; ?>
    </div>
    <p class="whint">Roads here are gentle. Further out, the world gets wilder.</p>
    <?= welcome_cta('Next: name your garden →', 'welcome.php?step=gnome') ?>
  </form>

<?php elseif ($step === 'garden' && $region):
    $village = q_one('SELECT l.name, z.name AS zone, z.landscape FROM locations l JOIN zones z ON z.id = l.zone_id WHERE l.id = ?', [$wf['village_id']]);
    $gname = $wf['garden'] !== '' ? $wf['garden'] : $wf['name'] . '’s Garden';
    $kit = array_map(fn($s) => [$s[0], $s[1], $s[2]], starter_item_list());
    $vname = (string)($village['name'] ?? 'your village');
    $plot = (int)setting('starting_plot_size');
    $packs = [
        ['pack-seeds', e($region['gnomish_name']) . ' seeds', home_seed_list((int)$region['id']), 'Seeds from ' . e($region['gnomish_name']) . '. You already know how to grow these.'],
        ['pack-basket', e($vname) . ' basket', village_welcome_pack((int)$wf['village_id']), 'A welcome basket from ' . e($vname) . '.'],
        ['pack-kit', 'Everyday kit', $kit, 'Everyday seeds and tools every new gnome gets.'],
    ];
    $more = '<p>' . LANDSCAPES[$village['landscape'] ?? '']['0'] . ' ' . e($village['name'] ?? '') . ', ' . e($village['zone'] ?? '') . ' in <b>' . e($region['gnomish_name']) . '</b> <span class="muted">(' . e($region['real_name']) . ')</span>.</p>'
        . '<p>Plus ' . money((int)setting('starting_coins')) . ', your Almanac, and a ' . $plot . '×' . $plot . ' garden plot.</p>'
        . '<p>⚡ ' . (int)setting('max_energy') . ' energy to start, then ' . e(energy_rate_text()) . '. Gardening spends it; eating food gives it back.</p>'; ?>
  <?= welcome_wren(e($vname) . ' it is! The villagers have set aside a little <b>' . $plot . '×' . $plot . '</b> patch of ground for you. Every good garden needs a name.', $more) ?>
  <form method="post" class="wform">
    <?= csrf_field() ?><input type="hidden" name="do" value="finish">
    <input class="wname" name="garden_name" value="<?= e($gname) ?>" required maxlength="40" aria-label="Name your first garden">
    <div class="wstats">
      <div class="wstat"><span class="ic" aria-hidden="true">🌸</span><b><?= number_format((int)setting('starting_coins')) ?></b><small><?= e(setting('currency_name')) ?></small></div>
      <div class="wstat"><span class="ic" aria-hidden="true">▦</span><b><?= $plot ?>×<?= $plot ?></b><small>plot</small></div>
      <div class="wstat"><span class="ic" aria-hidden="true">⚡</span><b><?= (int)setting('max_energy') ?></b><small>energy</small></div>
    </div>
    <div class="wpacks">
      <?php foreach ($packs as [$icon, $title, $list, $note]): ?>
        <details class="wpack">
          <summary><span class="whead"><img class="pxl pk" src="<?= e(url('assets/img/welcome/' . $icon . '.png')) ?>" width="32" height="32" alt=""><span class="ptitle"><?= $title ?></span><span class="pn"><?= count($list) ?></span></span>
            <span class="wgrid"><?= pack_slots($list, false, 5) ?></span></summary>
          <p class="help"><?= $note ?></p>
          <p class="chips"><?= seed_chips($list) ?></p>
        </details>
      <?php endforeach; ?>
    </div>
    <?= welcome_cta('🌱 Plant my first garden', 'welcome.php?step=place', '← Change village') ?>
  </form>
<?php endif; ?>
</div>
<?php page_footer();

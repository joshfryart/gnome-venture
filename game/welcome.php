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
            db()->beginTransaction();
            try {
                // Only once: the WHERE onboarded = 0 stops a double click making two gardens.
                $claimed = q('UPDATE users SET gnome_name = ?, hat_color = ?, beard_color = ?, region_id = ?, onboarded = 1, tour_step = 1
                              WHERE id = ? AND onboarded = 0', [$wf['name'], $wf['hat'], $wf['beard'], $wf['region_id'], $uid])->rowCount();
                if ($claimed === 1) {
                    setup_new_player($uid, (int)$wf['village_id'], $garden);
                    foreach (village_welcome_pack((int)$wf['village_id']) as [$itemId, , $qty]) {
                        give_item($uid, $itemId, $qty);
                    }
                    $vslug = (string)q_val('SELECT slug FROM locations WHERE id = ?', [$wf['village_id']]);
                    unlock_entries($uid, 'village:' . $vslug);
                }
                db()->commit();
            } catch (Throwable $e) {
                db()->rollBack();
                throw $e;
            }
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

/**
 * A village's welcome basket: both of its landscape's finds, a seed of one of the region's market crops
 * and a local snack. Picked from the village's name, so it's always the same for a village but
 * villages differ. [[item_id, name, qty, kind, label, icon], ...]
 */
function village_welcome_pack(int $villageId): array
{
    $v = q_one("SELECT id, slug, region_id, landscape FROM locations WHERE id = ? AND kind = 'village'", [$villageId]);
    if (!$v) return [];
    $pick = fn(array $rows, string $salt) => $rows ? $rows[crc32($v['slug'] . $salt) % count($rows)] : null;
    $out = [];
    foreach (LANDSCAPE_FINDS[$v['landscape']] ?? [] as [$name]) {
        $id = (int)q_val('SELECT id FROM items WHERE slug = ?', [slugify($name)]);
        if ($id) $out[] = [$id, $name, 1, 'find', $name, LANDSCAPES[$v['landscape']][0] ?? '✨'];
    }
    $seed = $pick(q("SELECT i.id, i.name, p.kind, p.name AS plant FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                     JOIN items i ON i.id = p.seed_item_id WHERE pr.region_id = ? AND pr.tier = 'uncommon' ORDER BY p.id",
                     [$v['region_id']])->fetchAll(), ':seed');
    if ($seed) $out[] = [(int)$seed['id'], (string)$seed['name'], 2, (string)$seed['kind'], (string)$seed['name'], null];
    $snack = $pick(q("SELECT i.id, i.name, p.kind FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id
                      JOIN items i ON i.id = p.produce_item_id WHERE pr.region_id = ? AND pr.tier IN ('staple','uncommon')
                      AND i.edible = 1 ORDER BY p.id", [$v['region_id']])->fetchAll(), ':snack');
    if ($snack) $out[] = [(int)$snack['id'], (string)$snack['name'], 2, (string)$snack['kind'], (string)$snack['name'], '🧺'];
    return $out;
}

/** Seed chips: "🫛 Soybean ×2" */
function seed_chips(array $list): string
{
    $out = '';
    foreach ($list as $s) {
        $label = $s[4] ?? $s[1];
        // v0.8.6: the item's own picture (Raspberry 🍓, Trowel 🪏) for baskets and starter kit; seeds stay 🌱 or their crop kind
        if (empty($s[5]) && isset($s[3])) $icon = catalog_kind_icon($s[3]);
        elseif (preg_match('/\bseeds?\b/i', $label)) $icon = '🌱';
        else $icon = name_emoji($label) ?: (!empty($s[5]) ? $s[5] : '🎒');
        $out .= '<span class="chip">' . $icon . ' ' . e($label) . ' <b>×' . (int)$s[2] . '</b></span>';
    }
    return $out;
}

function swatch(string $color, int $r = 11): string
{
    return '<svg width="' . ($r * 2) . '" height="' . ($r * 2) . '" viewBox="0 0 ' . ($r * 2) . ' ' . ($r * 2) . '" aria-hidden="true">'
        . '<circle cx="' . $r . '" cy="' . $r . '" r="' . ($r - 1) . '" fill="' . e($color) . '" stroke="#6b4a2b" stroke-width="1"/></svg>';
}

page_header('Welcome to the Hollow');
?>
<div class="welcomeflow">
<ol class="wsteps">
  <?php $i = 0; foreach ($STEPS as $key => $label): $i++;
      $state = $key === $step ? 'now' : (in_array($key, $ok, true) && array_search($key, array_keys($STEPS)) < array_search($step, array_keys($STEPS)) ? 'done' : ''); ?>
    <li class="<?= $state ?>"><?php if ($state === 'done' || ($state === '' && in_array($key, $ok, true))): ?>
      <a href="<?= e(url('welcome.php?step=' . $key)) ?>"><span><?= $i ?></span> <?= e($label) ?></a>
    <?php else: ?><span><?= $i ?></span> <?= e($label) ?><?php endif; ?></li>
  <?php endforeach; ?>
</ol>
<?php foreach ($errors as $err): ?><div class="flash err"><?= e($err) ?></div><?php endforeach; ?>

<?php if ($step === 'gnome'): ?>
  <div class="box wren">
    <p class="say"><b>🐦 Wren Thimblewick:</b> “Well now! A brand-new gnome, fresh out of the toadstool. I’m Wren. I travel the
      fourteen regions of the Hollow collecting seeds and stories. Before I show you around, tell me who you are.”</p>
  </div>
  <form method="post" class="box form gnomemaker" data-gnome-preview>
    <?= csrf_field() ?><input type="hidden" name="do" value="gnome">
    <div class="avatarcol"><?= gnome_avatar($preview, 120) ?></div>
    <div>
      <label>Your gnome’s name
        <input name="gnome_name" value="<?= e($wf['name']) ?>" required maxlength="24" placeholder="e.g. Bramble Puddlefoot" autocomplete="off"></label>
      <p class="help">This is the name other players and NPCs will see. Your log-in name stays private.</p>
      <fieldset class="swatches"><legend>Hat</legend>
        <?php foreach (HAT_COLORS as $c => $label): ?>
          <label title="<?= e($label) ?>"><input type="radio" name="hat" value="<?= e($c) ?>" data-part="hat"<?= $wf['hat'] === $c ? ' checked' : '' ?>> <?= swatch($c) ?> <span><?= e($label) ?></span></label>
        <?php endforeach; ?>
      </fieldset>
      <p class="help">When your gnome takes up a calling at level 5, the calling’s hat colour takes over.</p>
      <fieldset class="swatches"><legend>Beard</legend>
        <?php foreach (BEARD_COLORS as $c => $label): ?>
          <label title="<?= e($label) ?>"><input type="radio" name="beard" value="<?= e($c) ?>" data-part="beard"<?= $wf['beard'] === $c ? ' checked' : '' ?>> <?= swatch($c) ?> <span><?= e($label) ?></span></label>
        <?php endforeach; ?>
      </fieldset>
      <button class="btn">Next: pick your village →</button>
    </div>
  </form>

<?php elseif ($step === 'place' && $region): ?>
  <div class="box wren">
    <p class="say"><b>🐦 Wren:</b> “Lovely to meet you, <?= e($wf['name']) ?>! Every gnome’s journey starts here in <b><?= e($region['gnomish_name']) ?></b>.
      Its villages sit along the mycelium roads between the towns, and the roads here are gentle. Further out, the world gets wilder:
      each region has a recommended level, and once you’ve walked somewhere you can travel straight back any time.
      Where shall we plant your first garden?”</p>
    <p class="help">The locals send you off with: <span class="chips small"><?= seed_chips(home_seed_list((int)$region['id'])) ?></span></p>
  </div>
  <form method="post" class="form">
    <?= csrf_field() ?><input type="hidden" name="do" value="place">
    <?php $default = (int)$wf['village_id'] ?: (int)first_village((int)$region['id']);
    foreach (q('SELECT * FROM zones WHERE region_id = ? ORDER BY zone_num', [$region['id']])->fetchAll() as $z):
        $L = LANDSCAPES[$z['landscape']] ?? ['📍', ucfirst((string)$z['landscape']), ''];
        $villages = q("SELECT l.id, l.name FROM locations l WHERE l.zone_id = ? AND l.kind = 'village'
                       AND EXISTS (SELECT 1 FROM routes r WHERE r.kind = 'road' AND (r.a_id = l.id OR r.b_id = l.id)) ORDER BY l.sort_order", [$z['id']])->fetchAll();
        if ($gentleAny) $villages = array_values(array_filter($villages, fn($v) => gentle_start_village((int)$v['id'])));
        if (!$villages) continue;   // only villages on the roads (v0.7.24)
        $lms = q('SELECT kind, name FROM landmarks WHERE zone_id = ? ORDER BY kind, name', [$z['id']])->fetchAll(); ?>
      <div class="box zonecard d-<?= e($z['difficulty']) ?>">
        <h3><?= $L[0] ?> <?= e($z['name']) ?>
</h3>
        <p class="muted"><?= e($L[1]) ?>. <?= e($L[2]) ?></p>
        <p class="help">Each village sends you off with its own welcome basket:</p>
        <div class="villagepick">
          <?php foreach ($villages as $v): ?>
            <label><input type="radio" name="village_id" value="<?= (int)$v['id'] ?>" required<?= (int)$v['id'] === $default ? ' checked' : '' ?>>
              <span><b>🏡 <?= e($v['name']) ?></b><span class="chips small"><?= seed_chips(village_welcome_pack((int)$v['id'])) ?></span></span></label>
          <?php endforeach; ?>
        </div>
      </div>
    <?php endforeach; ?>
    <p><button class="btn">Next: name your garden →</button>
      <a href="<?= e(url('welcome.php?step=gnome')) ?>">← back to your gnome</a></p>
  </form>

<?php elseif ($step === 'garden' && $region):
    $village = q_one('SELECT l.name, z.name AS zone, z.landscape FROM locations l JOIN zones z ON z.id = l.zone_id WHERE l.id = ?', [$wf['village_id']]);
    $gname = $wf['garden'] !== '' ? $wf['garden'] : $wf['name'] . '’s Garden';
    $kit = array_map(fn($s) => [$s[0], $s[1], $s[2]], starter_item_list()); ?>
  <div class="box wren">
    <p class="say"><b>🐦 Wren:</b> “<?= e($village['name'] ?? 'Your village') ?> it is! The villagers have set aside a little
      <?= (int)setting('starting_plot_size') ?>×<?= (int)setting('starting_plot_size') ?> patch of ground for you. Every good garden needs a name.”</p>
  </div>
  <form method="post" class="box form summary">
    <?= csrf_field() ?><input type="hidden" name="do" value="finish">
    <div class="avatarcol"><?= gnome_avatar($preview, 110) ?><p><b><?= e($wf['name']) ?></b></p></div>
    <div>
      <p>🌍 <b><?= e($region['gnomish_name']) ?></b> <span class="muted">(<?= e($region['real_name']) ?>)</span><br>
        <?= LANDSCAPES[$village['landscape'] ?? '']['0'] ?? '📍' ?> <?= e($village['name'] ?? '') ?>, <?= e($village['zone'] ?? '') ?>
        · <a href="<?= e(url('welcome.php?step=place')) ?>">change</a></p>
      <label>Name your first garden
        <input name="garden_name" value="<?= e($gname) ?>" required maxlength="40"></label>
      <h3>What you’ll start with</h3>
      <p class="help">Seeds from <?= e($region['gnomish_name']) ?>. You already know how to grow these.</p>
      <p class="chips"><?= seed_chips(home_seed_list((int)$region['id'])) ?></p>
      <p class="help">A welcome basket from <?= e($village['name'] ?? 'your village') ?>.</p>
      <p class="chips"><?= seed_chips(village_welcome_pack((int)$wf['village_id'])) ?></p>
      <p class="help">Everyday seeds and tools every new gnome gets.</p>
      <p class="chips"><?= seed_chips($kit) ?></p>
      <p class="help">Plus <?= money((int)setting('starting_coins')) ?>, your Almanac, and a <?= (int)setting('starting_plot_size') ?>×<?= (int)setting('starting_plot_size') ?> garden plot.</p>
      <p class="help">⚡ <?= (int)setting('max_energy') ?> energy to start, then <?= e(energy_rate_text()) ?>. Gardening spends it; eating food gives it back.</p>
      <button class="btn">🌱 Plant my first garden</button>
    </div>
  </form>
<?php endif; ?>
</div>
<?php page_footer();

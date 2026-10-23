<?php
declare(strict_types=1);
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/yard.php';
require_once __DIR__ . '/includes/catalog.php';
$u = require_login();
$uid = (int)$u['id'];
require_once __DIR__ . '/includes/breeding110.php'; breeding110_boot();   // v1.1.0: imports the hybrids once on an upgraded world

if (is_post()) {
    csrf_check();
    unset($_SESSION['nav_badges']);   // v1.4.0: any garden action refreshes the Garden "ready" badge
    refresh_energy($u);
    $do = (string)($_POST['do'] ?? '');
    $x = (int)($_POST['x'] ?? -1);
    $y = (int)($_POST['y'] ?? -1);
    // v1.4.0: every panel action returns to its own tab (Beds is the default)
    $tabOfDo = ['build' => 'bld', 'upgrade' => 'bld', 'pantry_buy' => 'bld', 'add_scraps' => 'bld', 'heap_out' => 'bld', 'collect' => 'bld',
                'hire' => 'help', 'dismiss' => 'help', 'expand' => 'grow', 'sign_buy' => 'grow', 'sign_use' => 'grow'];
    if ($do === 'collect' && ($_POST['from'] ?? '') === 'yard') unset($tabOfDo['collect']);   // v1.9.7: tapping a glowing building on the yard collects and stays on the garden
    $postTab = $tabOfDo[$do] ?? (in_array((string)($_POST['t'] ?? ''), ['bld', 'an', 'help', 'grow'], true) ? (string)$_POST['t'] : 'beds');
    $tq = $postTab !== 'beds' ? '?t=' . $postTab : '';
    $back = 'garden.php' . ($x >= 0 ? "?sel=$x-$y" : $tq);

    if ($do === 'switch') {
        if (!switch_garden($uid, (int)($_POST['plot_id'] ?? 0))) flash('That isn’t your garden.', 'err');
        redirect('garden.php' . $tq);
    } elseif ($do === 'rename') {
        [$ok, $msg] = rename_garden($uid, active_plot_id($uid), (string)($_POST['name'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'build') {
        [$ok, $msg] = build_building($u, active_plot_id($uid), (string)($_POST['building'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'upgrade') {   // v0.7.95
        [$ok, $msg] = upgrade_building($u, active_plot_id($uid), (string)($_POST['building'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'pantry_buy') {   // v0.9.8: the Pantry, a Kitchen add-on
        [$ok, $msg] = pantry_buy($u, active_plot_id($uid));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?bld=kitchen#b-kitchen');
    } elseif ($do === 'collect_all') {   // v0.7.99
        [$ok, $msg] = collect_all_buildings($u, active_plot_id($uid));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'add_scraps') {   // v0.9.4: Food Scraps from the satchel onto the compost heap
        [$ok, $msg] = add_food_scraps($u, active_plot_id($uid), 'all');
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'heap_out') {   // v0.9.4: what the heap makes
        [$ok, $msg] = set_heap_output($u, active_plot_id($uid), (string)($_POST['out'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif (in_array($do, ['skin_buy', 'skin_use'], true)) {   // v0.9.7: building looks
        $bk = (string)($_POST['building'] ?? '');
        [$ok, $msg] = $do === 'skin_buy' ? skin_buy($u, active_plot_id($uid), $bk, (string)($_POST['skin'] ?? ''))
                                         : skin_use($u, active_plot_id($uid), $bk, (string)($_POST['skin'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?bld=' . urlencode(isset(BUILDINGS[$bk]) ? $bk : '') . '#b-' . urlencode($bk));
    } elseif (in_array($do, ['sign_buy', 'sign_use'], true)) {   // v0.9.7: garden signposts
        [$ok, $msg] = $do === 'sign_buy' ? sign_buy($u, active_plot_id($uid), (string)($_POST['style'] ?? ''))
                                         : sign_use($u, active_plot_id($uid), (string)($_POST['style'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'pick') {   // v1.0.0: pick a pest off a bed by hand
        [$ok, $msgs] = pest_pick($uid, $x, $y);
        foreach ($msgs as $m) flash($m, $ok ? 'ok' : 'err');
    } elseif ($do === 'pick_all') {
        [, $tiles] = load_plot($uid);
        $done = 0;
        $err = null;
        foreach ($tiles as $row) foreach ($row as $t) {
            if (empty($t['pest']) || empty($t['plant_id'])) continue;
            [$ok, $m] = pest_pick($uid, (int)$t['x'], (int)$t['y']);
            if (!$ok) { $err = end($m); break 2; }
            $done++;
        }
        if ($done) flash("🐛 You picked pests off $done bed" . ($done === 1 ? '' : 's') . '.', 'ok');
        if ($err) flash($err, 'err');
        if (!$done && !$err) flash('No pests to pick.', 'err');
    } elseif ($do === 'critter_feed') {   // v1.0.0: garden animals
        [$ok, $msg] = critter_feed($u, active_plot_id($uid), (string)($_POST['building'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?bld=' . urlencode((string)($_POST['building'] ?? '')) . '#b-' . urlencode((string)($_POST['building'] ?? '')));
    } elseif ($do === 'critter_welcome') {
        [$ok, $msg] = critter_welcome($u, active_plot_id($uid), (string)($_POST['building'] ?? ''), (string)($_POST['name'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?bld=' . urlencode((string)($_POST['building'] ?? '')) . '#b-' . urlencode((string)($_POST['building'] ?? '')));
    } elseif ($do === 'critter_rename') {
        [$ok, $msg] = critter_rename($u, active_plot_id($uid), (int)($_POST['critter'] ?? 0), (string)($_POST['name'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?bld=' . urlencode((string)($_POST['building'] ?? '')) . '#b-' . urlencode((string)($_POST['building'] ?? '')));
    } elseif ($do === 'critter_hatch') {
        [$ok, $msg] = critter_hatch($u, active_plot_id($uid));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?bld=frog_pond#b-frog_pond');
    } elseif ($do === 'biddy') {   // v1.0.0: trade scraps for eggs at the fence
        [$ok, $msg] = biddy_trade($u, active_plot_id($uid), (int)($_POST['scraps'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?an=1#biddy');
    } elseif ($do === 'clementine') {   // v1.2.0: trade scraps for goat milk at the fence
        [$ok, $msg] = clementine_trade($u, active_plot_id($uid), (int)($_POST['scraps'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?an=1#biddy');
    } elseif ($do === 'percy') {   // v1.2.0: seeds for a far-off seed from Percy
        [$ok, $msg] = percy_trade($u, active_plot_id($uid), (int)($_POST['seed'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
        redirect('garden.php?an=1#biddy');
    } elseif ($do === 'collect') {
        [$ok, $msg] = collect_building($u, active_plot_id($uid), (string)($_POST['building'] ?? ''));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'hire') {
        [$ok, $msg] = hire_helper($u, active_plot_id($uid), (int)($_POST['helper_id'] ?? 0), (int)($_POST['days'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'dismiss') {
        [$ok, $msg] = dismiss_helper($u, active_plot_id($uid), (int)($_POST['hire_id'] ?? 0));
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'expand') {
        [$ok, $msg] = expand_plot($uid);
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'weed_all') {
        [, $tiles] = load_plot($uid);
        $done = 0;
        $err = null;
        foreach ($tiles as $row) {
            foreach ($row as $t) {
                if ($t['method'] !== 'notill' || (int)$t['weeds'] < 5) continue;
                [$ok, $m] = garden_action($uid, 'weed', (int)$t['x'], (int)$t['y']);
                if (!$ok) { $err = end($m); break 2; }
                $done++;
            }
        }
        if ($done || !$err) flash($done ? "Weeded $done bed(s)." : 'No beds need weeding.', $done ? 'ok' : 'err');   // v0.7.61: just the real reason when tired
        if ($err) flash($err, 'err');
    } elseif ($do === 'water_all' || $do === 'harvest_all') {
        [, $tiles, $plants] = load_plot($uid);
        $done = 0;
        $all = [];
        $freeWater = $perkFree = false;
        if ($do === 'water_all') [$freeWater, $perkFree] = garden_claim_free_water($u, $uid, $tiles, $plants);
        foreach ($tiles as $row) {
            foreach ($row as $t) {
                if (!$t['plant_id']) continue;
                $info = tile_info($t, $plants[(int)$t['plant_id']]);
                if (($do === 'water_all' && $info['thirsty']) || ($do === 'harvest_all' && $info['ready'])) {
                    [$ok, $m] = garden_action($uid, $do === 'water_all' ? 'water' : 'harvest', (int)$t['x'], (int)$t['y']);
                    if (!$ok) {
                        $all[] = end($m);
                        break 2;
                    }
                    $done++;
                    if ($do === 'harvest_all') $all = array_merge($all, $m);
                }
            }
        }
        // v0.7.61: harvests fold into one summary; when the first square already failed (tired), only say why
        if ($do === 'harvest_all' && $done) {
            foreach (harvest_summary($all, $done) as $m) flash($m, str_contains($m, 'tired') ? 'err' : 'ok');
        } else {
            $GLOBALS['gv_free_water'] = false;
            if ($perkFree && !$done) q('UPDATE plots SET free_water_n = free_water_n - 1 WHERE id = ? AND free_water_n > 0', [active_plot_id($uid)]);   // v0.9.1: nothing watered, give the free use back
            if ($done || !$all) flash($done ? ($perkFree ? '💧 Your Bloomcaller touch watered ' . $done . ' plant(s) for free.' : ($freeWater ? '🛢️ The rain barrel watered ' . $done . ' plant(s) for free (once a day).' : "Watered $done plant(s).")) : 'Nothing needed doing.', $done ? 'ok' : 'err');
            foreach (array_unique($all) as $m) flash($m, str_contains($m, 'tired') ? 'err' : 'ok');
        }
    } elseif ($do === 'cellar') {   // v0.7.56: root cellar
        [$ok, $msg] = cellar_store($uid, $x, $y);
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'uncellar') {
        [$ok, $msg] = cellar_replant($uid, (int)($_POST['cellar_id'] ?? 0), $x, $y);
        flash($msg, $ok ? 'ok' : 'err');
    } elseif ($do === 'batch') {   // v0.7.54: one action on the squares picked in select mode
        $squares = [];
        foreach ((array)($_POST['sq'] ?? []) as $k) {
            if (is_string($k) && preg_match('/^(\d{1,3})-(\d{1,3})$/', $k, $mm)) $squares[$k] = [(int)$mm[1], (int)$mm[2]];
        }
        $squares = array_slice(array_values($squares), 0, 400);
        $act = (string)($_POST['act'] ?? '');
        $queue = [];
        if ($act === 'plant') {
            foreach ((array)($_POST['seed'] ?? []) as $id => $n) if ((int)$id > 0 && (int)$n > 0) $queue[] = [(int)$id, min(400, (int)$n)];
        } elseif ((int)($_POST['item_id'] ?? 0) > 0) {
            $queue[] = [(int)$_POST['item_id'], 0];
        }
        if (!$squares) {
            flash('Pick some squares first.', 'err');
        } else {
            // v1.2.2: picking every thirsty square and tapping Water counts as "Water all" (rain barrel III / Bloomcaller free water)
            $freeWater = $perkFree = false;
            if ($act === 'water') {
                [, $wt, $wp] = load_plot($uid);
                $picked = [];
                foreach ($squares as [$sx, $sy]) $picked[$sx . '-' . $sy] = true;
                $allIn = true;
                foreach ($wt as $row) foreach ($row as $t) {
                    if ($t['plant_id'] && isset($wp[(int)$t['plant_id']]) && tile_info($t, $wp[(int)$t['plant_id']])['thirsty'] && empty($picked[(int)$t['x'] . '-' . (int)$t['y']])) { $allIn = false; break 2; }
                }
                if ($allIn) [$freeWater, $perkFree] = garden_claim_free_water($u, $uid, $wt, $wp);
            }
            [$ok, $msgs] = garden_batch_action($uid, $act, $squares, $queue);
            $GLOBALS['gv_free_water'] = false;
            if ($perkFree && !$ok) q('UPDATE plots SET free_water_n = free_water_n - 1 WHERE id = ? AND free_water_n > 0', [active_plot_id($uid)]);   // nothing watered: give the free use back
            if ($freeWater && $ok) flash($perkFree ? '💧 Your Bloomcaller touch made that watering free.' : '🛢️ The rain barrel made that watering free (once a day).', 'ok');
            foreach ($msgs as $i => $m) flash($m, $ok && !str_contains($m, 'too tired') && !str_contains($m, 'ran out') ? 'ok' : 'err');
        }
        redirect('garden.php');
    } else {
        [$ok, $msgs] = garden_area_action($uid, $do, $x, $y, (int)($_POST['item_id'] ?? 0), (string)($_POST['reach'] ?? 'one'));
        foreach ($msgs as $m) flash($m, $ok ? 'ok' : 'err');
    }
    redirect($back);
}

refresh_energy($u);
$GLOBALS['CURRENT_USER'] = $u;
[$plot, $tiles, $plants] = load_plot($uid);
if (!$plot) {   // no garden yet (e.g. the welcome flow was skipped in Admin): set one up properly
    q('UPDATE users SET onboarded = 0 WHERE id = ?', [$uid]);
    redirect('welcome.php');
}
critter_ready_map((int)$plot['id']); critter_flush_news();   // v1.0.0: bring the animals up to date (a tadpole may have grown up) before the page starts
$known = known_plants($u);
$hasKit = tool_power($uid, 'soiltest') > 0;
$canNoTill = (int)$u['level'] >= (int)setting('notill_level');

$sel = null;
if (preg_match('/^(\d+)-(\d+)$/', (string)($_GET['sel'] ?? ''), $m)) {
    $sel = $tiles[(int)$m[2]][(int)$m[1]] ?? null;
}
$byCat = function (string $cat) use ($uid): array {
    return q('SELECT i.id, i.name, ui.qty, i.effects FROM user_items ui JOIN items i ON i.id = ui.item_id
              WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = ? ORDER BY i.name', [$uid, $cat])->fetchAll();
};
$seeds = q('SELECT i.id, i.name, ui.qty, p.id AS plant_id, p.min_soil, p.perennial, p.kind, p.nutrient, p.seasons FROM user_items ui
            JOIN items i ON i.id = ui.item_id JOIN plants p ON p.seed_item_id = i.id
            WHERE ui.user_id = ? AND ui.qty > 0 ORDER BY i.name', [$uid])->fetchAll();
// v0.8.6: during Wren's tour the quick radish comes first (the tour says radishes are quickest)
$ts = (int)q_val('SELECT tour_step FROM users WHERE id = ?', [$uid]);
if ($ts >= 1 && $ts <= 3) {
    usort($seeds, fn($a, $b) => (int)(stripos($b['name'], 'radish') === 0) <=> (int)(stripos($a['name'], 'radish') === 0));
}
// Saplings (v0.7.10) can be planted by anyone, known crop or not
foreach (q("SELECT i.id, i.name, ui.qty, i.effects FROM user_items ui JOIN items i ON i.id = ui.item_id
            WHERE ui.user_id = ? AND ui.qty > 0 AND i.category = 'sapling' ORDER BY i.name", [$uid])->fetchAll() as $sp) {
    $spid = (int)((json_decode((string)$sp['effects'], true) ?: [])['sapling'] ?? 0);
    $minSoil = q_val('SELECT min_soil FROM plants WHERE id = ?', [$spid]);
    $spp = q_one('SELECT min_soil, perennial, kind, nutrient, seasons FROM plants WHERE id = ?', [$spid]);
    if ($minSoil !== false && $minSoil !== null) $seeds[] = ['id' => $sp['id'], 'name' => '🌱 ' . $sp['name'], 'qty' => $sp['qty'], 'plant_id' => $spid, 'min_soil' => $minSoil, 'sapling' => 1,
        'perennial' => $spp['perennial'] ?? 0, 'kind' => 'tree', 'nutrient' => $spp['nutrient'] ?? null, 'seasons' => $spp['seasons'] ?? ''];
}
$soils = $byCat('soil');
$mulches = $byCat('mulch');
[$pages, $totalPages] = almanac_counts($uid);
$gardens = user_gardens($uid);
$here = null;
foreach ($gardens as $g) if ((int)$g['id'] === (int)$plot['id']) $here = $g;
$built = [];
foreach (q('SELECT * FROM garden_buildings WHERE plot_id = ?', [$plot['id']])->fetchAll() as $b) $built[$b['building']] = $b;
// v1.4.0: the page is split into tabs (?t=); the old ?bld= and ?an= links still land on their tab
$tab = (string)($_GET['t'] ?? '');
if (!in_array($tab, ['beds', 'bld', 'an', 'help', 'grow'], true)) $tab = isset($_GET['bld']) ? 'bld' : (isset($_GET['an']) ? 'an' : 'beds');

function action_form(string $do, array $t, string $label, int $cost, string $extra = '', string $confirm = ''): string
{
    return '<form method="post" class="inline"' . ($confirm ? ' data-confirm="' . e($confirm) . '"' : '') . '>' . csrf_field()
        . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="x" value="' . (int)$t['x'] . '">'
        . '<input type="hidden" name="y" value="' . (int)$t['y'] . '">' . $extra
        . '<button class="btn act">' . e($label) . ' <span class="cost">⚡' . $cost . '</span></button></form> ';
}

/**
 * v0.7.86: the energy a harvest over the squares a tool reaches can take ("2", or "1–3" when the crops differ in tier).
 * Same squares as garden_area_action(): this square's row neighbours, or the whole row.
 */
function harvest_cost_range(array $t, int $reach): string
{
    $sql = 'SELECT DISTINCT plant_id FROM plot_tiles WHERE plot_id = ? AND yy = ? AND plant_id IS NOT NULL';
    $args = [(int)$t['plot_id'], (int)$t['yy']];
    if ($reach < 99) {
        $sql .= ' AND ABS(yx - ?) <= 1';
        $args[] = (int)$t['yx'];
    }
    $costs = array_map(fn($pid) => harvest_energy_cost((int)$pid), q($sql, $args)->fetchAll(PDO::FETCH_COLUMN));
    if (!$costs) return (string)harvest_energy_cost((int)($t['plant_id'] ?? 0));
    $lo = min($costs);
    $hi = max($costs);
    return $lo === $hi ? (string)$lo : $lo . '–' . $hi;
}

/**
 * A garden action form whose tool may reach further: one button for this square, and one for 3 squares
 * or the whole row when the gnome's tool allows. Energy shown is per square, after tool discounts.
 */
function tool_action_form(string $do, array $t, string $label, int $unused = 0, string $extra = '', string $confirm = ''): string
{
    global $uid;
    $pid = $do === 'harvest' ? (int)($t['plant_id'] ?? 0) : 0;   // v0.7.86: a harvest costs by the crop's tier
    $cost = action_cost($uid, $do, $pid);
    $type = ACTION_TOOL[$do] ?? null;
    $reach = $type ? tool_reach(tool_tier($uid, $type)) : 1;
    $btns = '<button class="btn act" name="reach" value="one">' . e($label) . ' <span class="cost">⚡' . $cost . '</span></button>';
    if ($reach > 1) {
        $each = $do === 'harvest' ? harvest_cost_range($t, $reach) : (string)$cost;
        $btns .= ' <button class="btn act alt" name="reach" value="' . ($reach >= 99 ? 'row' : 'three') . '">'
            . e($label) . ($reach >= 99 ? ' whole row' : ' ×3') . ' <span class="cost">⚡' . $each . ' each</span></button>';
    }
    return '<form method="post" class="inline toolform"' . ($confirm ? ' data-confirm="' . e($confirm) . '"' : '') . '>' . csrf_field()
        . '<input type="hidden" name="do" value="' . e($do) . '"><input type="hidden" name="x" value="' . (int)$t['x'] . '">'
        . '<input type="hidden" name="y" value="' . (int)$t['y'] . '">' . $extra . $btns . '</form> ';
}

function item_select(array $items, callable $label, string $pick = ''): string
{
    return '<select name="item_id"' . ($pick !== '' ? ' data-pick="' . e($pick) . '"' : '') . '>' . implode('', array_map(fn($i) => '<option value="' . (int)$i['id'] . '">' . e($label($i)) . '</option>', $items)) . '</select>';
}

/** A pop-up grid of items to choose from (the Satchel look), used by select mode and by the square panel. */
function picker_html(string $kind, string $title, array $items, callable $icon, callable $info, string $go, ?callable $more = null): string   // v1.6.2: $more = a smaller second line
{
    $cards = '';
    foreach ($items as $i) {
        $cards .= '<button type="button" class="pcard" data-id="' . (int)$i['id'] . '" data-qty="' . (int)$i['qty'] . '">'
            . '<span class="pcicon">' . $icon($i) . '</span><span class="pcname">' . e($i['name']) . '</span><b class="pcqty">×' . (int)$i['qty'] . '</b>'
            . '<small class="pcinfo">' . $info($i) . '</small>' . ($more && ($mt = $more($i)) !== '' ? '<small class="pcmore">' . $mt . '</small>' : '') . '<span class="pccount" hidden></span>'
            . ($kind === 'seed' ? '<span class="pcbtns" hidden><i data-step="-1" role="button" aria-label="One fewer">−</i><i data-step="max" role="button" aria-label="Fill the rest">all</i></span>' : '')
            . '</button>';
    }
    return '<dialog class="picker" data-kind="' . e($kind) . '" aria-label="' . e($title) . '"><div class="pickbox">'
        . '<div class="pickhead"><b>' . e($title) . '</b> <span class="pickhint muted"></span><button type="button" class="pickx" aria-label="Close">✕</button></div>'
        . ($cards !== '' ? '<div class="pickgrid">' . $cards . '</div>' : '<p class="muted">You don’t have any.</p>')
        . '<div class="pickfoot"><span class="picksum muted"></span><button type="button" class="btn" data-go>' . e($go) . '</button></div></div></dialog>';
}

page_header('My Garden');
?>
<div class="ghead"><h1><?= eu($plot['garden_name'] ?: gnome_name($u) . '’s Garden') ?></h1>
  <details class="renamefold"><summary aria-label="Rename this garden">✏️ Rename</summary>
    <form method="post" class="inline renamer"><?= csrf_field() ?><input type="hidden" name="do" value="rename"><input type="hidden" name="t" value="<?= e($tab) ?>">
      <label>Garden name <input name="name" value="<?= e($plot['garden_name'] ?? '') ?>" maxlength="40"></label>
      <button class="btn small">Rename</button></form></details></div>
<?php if (count($gardens) > 1): ?>
  <nav class="gardentabs">
    <?php foreach ($gardens as $g): ?>
      <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="switch"><input type="hidden" name="t" value="<?= e($tab) ?>"><input type="hidden" name="plot_id" value="<?= (int)$g['id'] ?>">
        <button class="tab<?= (int)$g['id'] === (int)$plot['id'] ? ' on' : '' ?>">🏡 <?= eu($g['garden_name'] ?: 'Garden') ?> <small>L<?= (int)$g['garden_level'] ?></small></button></form>
    <?php endforeach; ?>
  </nav>
<?php endif; ?>
<?php   // v1.4.0: tab bar (badges: ready crops, buildings with something to collect, animals about, helpers working)
$yobjs = yard_objects((int)$plot['id']);
$readyB = [];
foreach ($built as $bk => $brow) if (isset(BUILDING_PRODUCE[$bk]) && building_ready($brow) + heap_ready($brow) > 0) $readyB[$bk] = true;
foreach (critter_ready_map((int)$plot['id']) as $bk => $_n) $readyB[$bk] = true;   // v1.0.0: gifts from the garden animals
$biddy = biddy_html($u, $plot);
$homes = array_values(array_filter(array_keys($built), 'critter_is_home'));
$nbr = animals120_neighbours($u, $plot);   // v1.2.0: Clementine and Percy
$hasAnimals = $biddy !== '' || $nbr['html'] !== '' || $homes;
if ($tab === 'an' && !$hasAnimals) $tab = 'beds';
$hires = current_hires((int)$plot['id']); $slots = helper_slots((int)$plot['id']);   // v0.7.99: one helper per Tool Shed level
$nReadyBeds = 0;
foreach ($tiles as $row) foreach ($row as $t) if ($t['plant_id'] && isset($plants[(int)$t['plant_id']]) && tile_info($t, $plants[(int)$t['plant_id']])['ready']) $nReadyBeds++;
$nAnimals = ($biddy !== '' ? 1 : 0) + substr_count($nbr['hint'], ' · ');
$tb = fn(int $n, string $cls = '') => $n > 0 ? ' <span class="tbadge' . $cls . '">' . $n . '</span>' : '';
?>
<nav class="tabs gardentabnav" aria-label="Garden sections">
  <a class="<?= $tab === 'beds' ? 'on' : '' ?>" href="<?= e(url('garden.php')) ?>"><span class="tabic">🌱</span> Beds<?= $tb($nReadyBeds) ?></a>
  <a class="<?= $tab === 'bld' ? 'on' : '' ?>" href="<?= e(url('garden.php?t=bld')) ?>"><span class="tabic">🏠</span> Buildings<?= $tb(count($readyB)) ?></a>
  <?php if ($hasAnimals): ?><a class="<?= $tab === 'an' ? 'on' : '' ?>" href="<?= e(url('garden.php?t=an')) ?>"><span class="tabic">🐾</span> Animals<?= $tb($nAnimals) ?></a><?php endif; ?>
  <a class="<?= $tab === 'help' ? 'on' : '' ?>" href="<?= e(url('garden.php?t=help')) ?>"><span class="tabic">🧑‍🌾</span> Help<?= $tb(count($hires), ' muted') ?></a>
  <a class="<?= $tab === 'grow' ? 'on' : '' ?>" href="<?= e(url('garden.php?t=grow')) ?>"><span class="tabic">📐</span> Grow</a>
</nav>
<?php if ($tab === 'beds'): ?>
<details class="helpfold gardeninfo"><summary>📍 <?= $here && $here['region'] ? e($here['region']) : 'This garden' ?> · about this spot</summary>   <?php /* v1.0.1: folded so the yard comes first on a phone */ ?>
<p class="help">📍 <?= $here && $here['region'] ? e($here['region']) . ($here['region_real'] ? ' (' . e($here['region_real']) . ')' : '') : 'Somewhere on Earth' ?>.
  Crops native to <?= $here && $here['region'] ? e($here['region']) : 'this region' ?> grow <?= (int)setting('native_bonus_percent') ?>% faster here.
  You tend <?= count($gardens) ?> of <?= max_gardens($u) ?> possible garden<?= max_gardens($u) === 1 ? '' : 's' ?><?= next_garden_level($u) ? ' (another at gnome level ' . next_garden_level($u) . ')' : '' ?>.</p>
<?php if (!empty($plot['region_id'])):   // v0.7.61: say plainly which crops get the home bonus here
    $natives = q('SELECT DISTINCT p.name, p.kind FROM plant_regions pr JOIN plants p ON p.id = pr.plant_id WHERE pr.region_id = ? ORDER BY p.kind, p.name', [$plot['region_id']])->fetchAll();
    if ($natives):
        $byKind = [];
        foreach ($natives as $n) $byKind[$n['kind']][] = $n['name'];
        arsort($byKind);
        uasort($byKind, fn($a, $b) => count($b) <=> count($a)); ?>
  <details class="helpfold nativefold"><summary>🌍 Native bonus here: <?= e(implode(', ', array_map(fn($k, $l) => count($l) . ' ' . $k . (count($l) > 1 && $k !== 'fruit' ? 's' : ''), array_keys($byKind), $byKind))) ?> grow <?= (int)setting('native_bonus_percent') ?>% faster</summary>
    <?php foreach ($byKind as $k => $list): ?><p class="help"><?= catalog_kind_icon((string)$k) ?> <b><?= e(ucfirst((string)$k)) ?>:</b> <?= e(implode(', ', $list)) ?></p><?php endforeach; ?>
  </details>
<?php endif; endif; ?>
<?php if (!empty($plot['region_id']) && setting('climate_on') === '1'):   // v0.8.9: this garden's climate
    require_once __DIR__ . '/includes/climate.php';
    $climReg = q_one('SELECT id, climate_trait FROM regions WHERE id = ?', [$plot['region_id']]);
    if ($climReg && climate_fx((int)$climReg['id'])): ?>
  <p class="help">🌦️ <b>Climate here:</b> <?= e(climate_text($climReg)) ?><?= garden_mods((int)$plot['id'])['greenhouse'] ? ' Your greenhouse shelters crops from any slowdown.' : '' ?></p>
<?php endif; endif; ?>
</details>
<?php // v1.0.0: what today's season and weather do here
    [$wxHead, $wxText, $wxCls] = garden_weather_note((int)$plot['id'], $tiles, $plants);
    $seasonNow = hollow_now(garden_region_code((int)$plot['id'])); ?>
<p class="wxline wx-<?= e($wxCls) ?>"><b><?= e($wxHead) ?></b> · <?= e($wxText) ?>
  <span class="muted"><?= $seasonNow['season_emoji'] ?> <?= e($seasonNow['season_label']) ?>, day <?= (int)$seasonNow['season_day'] ?>. <a href="<?= e(url('world.php?tab=seasons#seasons')) ?>">Forecast</a></span></p>
<?php if (empty($u['region_id'])): ?>
  <div class="flash err">You haven’t chosen a home region yet. <a href="<?= e(url('world.php')) ?>">Choose one</a> to get your home seeds.</div>
<?php endif; ?>

<div class="gardenwrap">
  <div>
    <?php $appeal = yard_appeal((int)$plot['id'], $yobjs);
        if ($appeal !== (int)$plot['appeal']) q('UPDATE plots SET appeal = ? WHERE id = ?', [$appeal, $plot['id']]); ?>
    <?php   // v1.6.3: on phones the view crops to EVERYTHING in use (every bed, building, critter home, decor, fence, path) + 1 square of margin.
        // Only when that box is clearly smaller than the yard and not wider than 8 squares; otherwise the whole yard shows.
        [$ycw, $ych] = yard_size($plot);
        $bx0 = $by0 = 99; $bx1 = $by1 = -1;
        $grow = function (int $x, int $y, int $w, int $h) use (&$bx0, &$bx1, &$by0, &$by1): void { $bx0 = min($bx0, $x); $by0 = min($by0, $y); $bx1 = max($bx1, $x + max(1, $w) - 1); $by1 = max($by1, $y + max(1, $h) - 1); };
        foreach ($tiles as $row) foreach ($row as $t) if ($t['yx'] !== null) $grow((int)$t['yx'], (int)$t['yy'], 1, 1);
        foreach ($yobjs as $o) if ((int)$o['x'] >= 0) { $odd = (int)$o['rot'] % 2 === 1; $grow((int)$o['x'], (int)$o['y'], $odd ? (int)$o['h'] : (int)$o['w'], $odd ? (int)$o['w'] : (int)$o['h']); }
        $cropCls = '';
        if ($bx1 >= 0) {
            $cx0 = max(0, $bx0 - 1); $cx1 = min($ycw - 1, $bx1 + 1); $cy0 = max(0, $by0 - 1); $cy1 = min($ych - 1, $by1 + 1);
            $cw = $cx1 - $cx0 + 1; $ch = $cy1 - $cy0 + 1;
            if ($cw <= 8 && $cw * $ch <= 0.7 * $ycw * $ych) $cropCls = ' crop ycx' . $cx0 . ' ycy' . $cy0 . ' ycw' . $cw . ' ych' . $ch;
        } ?>
    <?php if ($cropCls !== ''): ?><p class="yardzoom"><button type="button" class="linkbtn" data-yardwhole><span class="yz-a">🔭 Show whole yard</span><span class="yz-b">🔍 Zoom to my beds</span></button></p><?php endif; ?>
    <div class="yardwrap<?= $cropCls ?>" id="yard"><?= render_yard($plot, $tiles, $plants, $yobjs, 'own', $sel, ['ready' => $readyB]) ?></div>
    <p class="yardbar"><a class="btn small" href="<?= e(url('yard.php')) ?>">✏️ Design yard</a>
      <span title="How lovely your yard looks: decor, variety, buildings and flowers in bloom">🌼 Curb appeal <b><?= $appeal ?></b> (<?= e(appeal_word($appeal)) ?>)</span>
      <?php require_once __DIR__ . '/includes/social169.php'; echo social169_garden_counts((int)$plot['id']); /* v1.6.9 */ ?>
      <a class="muted" href="<?= e(url('visit.php?g=' . (int)$plot['id'])) ?>">See it as visitors do</a></p>
    <details class="helpfold needhelp"><summary>🤝 Need help?</summary>   <?php /* v1.7.0 */ ?>
      <ul>
        <li><a href="<?= e(url('garden.php?t=help')) ?>">🧑‍🌾 Hire a villager</a> to tend while you’re out.</li>
        <li><a href="<?= e(url('jobs.php?t=jobs&p=post')) ?>">📌 Post a job</a> for other players.</li>
        <li>💧 Other gnomes can water for you when they visit.</li>
      </ul>
    </details>
    <?php // v0.7.54: select squares, then do one thing to all of them
        $flags = [];
        $pnames = [];
        $hcosts = [];   // v0.7.86: energy a harvest of each square takes (by crop tier)
        foreach ($tiles as $row) foreach ($row as $t) {
            $f = '';
            $pl = $t['plant_id'] && isset($plants[(int)$t['plant_id']]) ? $plants[(int)$t['plant_id']] : null;
            if ($pl) $hcosts[] = (int)$t['x'] . '-' . (int)$t['y'] . ':' . harvest_energy_cost((int)$t['plant_id']);
            if ($t['method'] === 'notill') $f .= 'N';   // v1.6.2: a no-till bed (tilling it loses its grade)
            if (tile_plantable($t)) $f .= 'P';
            if ((int)$t['tilled'] && (int)$t['feed_hours'] <= 0 && (int)$t['fertility'] < (int)setting('amend_max_fertility')) $f .= 'A';
            if ((int)$t['tilled']) $f .= 'M';
            // v0.7.85: a no-till bed is never picked for tilling (tilling it loses its grade)
            if (!$pl && $t['method'] !== 'notill' && !((int)$t['tilled'] && $t['method'] === 'till')) $f .= 'T';
            if ($pl) { $ti = tile_info($t, $pl); if ($ti['thirsty']) $f .= 'W'; if ($ti['ready']) $f .= 'H'; }
            $flags[] = (int)$t['x'] . '-' . (int)$t['y'] . ':' . $f . ':' . ($pl ? (int)$t['plant_id'] : 0);   // v0.9.1a: plant id for "select all of this crop"
            if ($pl) $pnames[(int)$t['plant_id']] = (int)$t['plant_id'] . ':' . str_replace([',', ':'], ' ', (string)$pl['name']);
        }
        $plantableSeeds = $seeds;   // v0.7.65: anything can be planted; unstudied ones are marked
        $costs = []; foreach (['plant', 'soil', 'mulch', 'till', 'water', 'harvest', 'dig', 'sheet'] as $a) $costs[] = $a . ':' . action_cost($uid, $a); ?>
    <div class="selbar" data-tiles="<?= e(implode(',', $flags)) ?>" data-costs="<?= e(implode(',', $costs)) ?>" data-hcosts="<?= e(implode(',', $hcosts)) ?>" data-pnames="<?= e(implode(',', $pnames)) ?>" hidden>
      <button type="button" class="btn small" data-sel="on">☑️ Select squares</button>
      <div class="selon" hidden>
        <p><b>☑️ <span class="selcount">0</span> selected.</b> Tap squares to pick them, or pick:
          <button type="button" class="btn small alt" data-q="P">🟫 empty &amp; ready to plant</button>
          <button type="button" class="btn small alt" data-q="A">🪱 can take a soil improver</button>
          <button type="button" class="btn small alt" data-q="T">⛏️ needs tilling</button>
          <button type="button" class="btn small alt" data-q="W">💧 thirsty</button>
          <button type="button" class="btn small alt" data-q="H">🧺 ready</button>
          <button type="button" class="btn small alt" data-q="none">✖ none</button></p>
        <p class="selcrop" hidden><button type="button" class="btn small" data-selcrop></button></p>
        <p class="selacts">
          <button type="button" class="btn" data-open="seed">🌱 Plant…</button>
          <button type="button" class="btn" data-open="soil">🪱 Work in…</button>
          <button type="button" class="btn" data-open="mulch">🍂 Mulch…</button>
          <?php if ($canNoTill): ?><button type="button" class="btn" data-open="mulch" data-act="sheet" title="Cardboard + mulch: turns squares into no-till beds">📦 Sheet mulch…</button><?php endif; ?>
          <button type="button" class="btn alt" data-act="till" data-ask="Till the N selected squares? Tilling a no-till bed loses its grade." data-askif="N">⛏️ Till</button>
          <button type="button" class="btn alt" data-act="water">💧 Water</button>
          <button type="button" class="btn alt" data-act="harvest">🧺 Harvest</button> <span class="cost selhcost"></span>
          <button type="button" class="btn alt" data-act="dig" data-ask="Dig up the plants on the N selected squares? You won’t get a harvest from them.">🪏 Dig up</button>
          <button type="button" class="btn small alt" data-sel="off">Done</button></p>
        <p class="help">Squares that can’t take it are skipped (you’ll be told why), and it stops if you run out of energy.</p>
      </div>
    </div>
    <form class="batchform" method="post" hidden><?= csrf_field() ?><input type="hidden" name="do" value="batch"><input type="hidden" name="act" value=""><input type="hidden" name="item_id" value=""></form>
    <?= picker_html('seed', 'Choose seeds', $plantableSeeds, fn($i) => (($pic = item_pic(['id' => $i['id'], 'name' => $i['name']], 'md')) !== '' ? $pic : (!empty($i['sapling']) ? '🌳' : catalog_kind_icon((string)($i['kind'] ?? '')))),   // v1.6.2: the packet's own picture
        fn($i) => implode(' · ', array_filter([trim(season_chip_text($i, building_level((int)$plot['id'], 'greenhouse') > 0)), (empty($i['sapling']) && empty($known[(int)$i['plant_id']]) ? '📕 unstudied' : ''), (!empty($i['perennial']) ? '🔄 regrows' : '')], fn($x) => trim((string)$x) !== '')), 'Plant',
        fn($i) => e((empty($i['sapling']) && empty($known[(int)$i['plant_id']]) ? '−' . (100 - unstudied_yield_pct($u)) . '% harvest · ' : '')
            . ((int)$i['min_soil'] <= 0 ? 'any soil' : ((int)$i['min_soil'] < 40 ? 'decent soil' : 'rich soil')))) ?>
    <?php if (isset($built['root_cellar'])):   // v0.7.57: the root cellar uses the same picker
        $celPick = array_map(fn($c) => ['id' => $c['id'], 'name' => $c['name'], 'qty' => 1, 'kind' => $c['kind'],
            'pct' => (int)min(100, round((int)$c['growth_seconds'] / max(1, (int)$c['grow_minutes'] * 60) * 100))], cellar_plants((int)$plot['id'])); ?>
      <?= picker_html('cellar', 'Replant from the root cellar', $celPick, fn($i) => catalog_kind_icon((string)$i['kind']), fn($i) => '🔄 Perennial · ' . (int)$i['pct'] . '% grown', 'Replant') ?>
    <?php endif; ?>
    <?= picker_html('soil', 'Choose a soil improver', $soils, fn($i) => '🪱', fn($i) => e(amend_summary($i)), 'Work in') ?>
    <?= picker_html('mulch', 'Choose a mulch', $mulches, fn($i) => '🍂', fn($i) => e(amend_summary($i)), 'Spread') ?>
    <div class="bulk">
      <?php $nThirsty = $nReady = $nWeedy = 0;
          $hEnergy = 0;   // v0.7.86: the energy all the ready crops would take, each by its tier
          foreach ($tiles as $row) foreach ($row as $t) {
              if ($t['plant_id'] && isset($plants[(int)$t['plant_id']])) {
                  $ti = tile_info($t, $plants[(int)$t['plant_id']]);
                  if ($ti['thirsty']) $nThirsty++;
                  if ($ti['ready']) { $nReady++; $hEnergy += harvest_energy_cost((int)$t['plant_id']); }
              }
              if ($t['method'] === 'notill' && (int)$t['weeds'] >= 5) $nWeedy++;
          }
          $nPest = 0;   // v1.0.0: beds with a pest
          foreach ($tiles as $row) foreach ($row as $t) if (!empty($t['pest']) && $t['plant_id']) $nPest++;
          $bulk = function (string $do, string $label, int $n, int $energy) {
              return '<form method="post" class="inline">' . csrf_field() . '<input type="hidden" name="do" value="' . $do . '"><button class="btn small"' . ($n ? '' : ' disabled') . '>'
                  . $label . ($n ? ' (' . $n . ') <span class="cost">⚡' . $energy . '</span>' : '') . '</button></form> ';
          }; ?>
      <?php $freeW = isset($built['rain_barrel']) && (int)$built['rain_barrel']['level'] >= 3 && (string)$built['rain_barrel']['free_day'] !== hollow_date('Y-m-d');   // v0.7.96
          $perkN = calling_perk($u, 'free_water_all');   // v0.9.1: Bloomcaller master
          $perkLeft = $perkN > 0 ? max(0, $perkN - ((string)($plot['free_water_day'] ?? '') === hollow_date('Y-m-d') ? (int)$plot['free_water_n'] : 0)) : 0;
          if ($perkLeft > 0) $freeW = true; ?>
      <?= $bulk('water_all', $nThirsty ? '💧 Water all thirsty' : '💧 Nothing thirsty', $nThirsty, $freeW ? 0 : action_cost($uid, 'water') * $nThirsty) ?>
      <?php if ($perkLeft > 0): ?><span class="help">💧 Free Water all: <?= $perkLeft ?> left today</span> <?php endif; ?>
      <?= $bulk('harvest_all', $nReady ? '🧺 Harvest all ready' : '🧺 Nothing ready', $nReady, $hEnergy) ?>
      <?php if ($readyB): ?><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="collect_all"><button class="btn small">📦 Collect all (<?= count($readyB) ?>)</button></form> <?php endif;   // v0.7.99 ?>
      <?php if ($nPest): ?><?= $bulk('pick_all', '🧤 Pick pests off', $nPest, max(0, (int)setting('pest_pick_energy')) * $nPest) ?><?php endif; ?>
      <?php if ($canNoTill): ?><?= $bulk('weed_all', $nWeedy ? '🌿 Weed all beds' : '🌿 No weeds', $nWeedy, action_cost($uid, 'weed') * $nWeedy) ?><?php endif; ?>
      <p class="help">Energy shown is the most it can cost: good tools sometimes make squares free.</p>
    </div>
    <p class="help legend"><span class="sw wild"></span> wild <span class="sw tilled"></span> tilled <span class="sw notill"></span> no-till bed (green edge). Hover a bed to see its yard bonuses.</p>
  </div>

  <div class="panel box" data-inplace-show>
    <?php if (!$sel): ?>
      <h3>Pick a square</h3>
      <p>Tap a square of your plot to tend it.</p>
      <p class="help">Till (or sheet mulch) → add compost → plant → water → harvest. Plants only grow while watered.
        <?= $canNoTill ? '' : 'Wren will teach you no-till gardening at level ' . (int)setting('notill_level') . '.' ?></p>
    <?php else:
        $p = $sel['plant_id'] ? $plants[(int)$sel['plant_id']] : null;
        $w = soil_words($sel);
        $method = $sel['method'] === 'notill' ? '🍂 No-till bed' : ((int)$sel['tilled'] ? '⛏️ Tilled' : '🌾 Wild ground'); ?>
      <h3>Square <?= (int)$sel['x'] + 1 ?>, <?= (int)$sel['y'] + 1 ?> · <?= $method ?> <a class="backtoyard" href="#yard">⬆ yard</a></h3>
      <?php   // v1.6.2: two plain lines first; the numbers are behind "Soil details"
          $sumWord = $sel['method'] === 'notill' ? 'No-till bed' : ((int)$sel['tilled'] ? 'Tilled' : 'Wild ground');
          $sumState = $p ? ($p['kind'] === 'cover' ? 'cover crop growing' : 'growing ' . $p['name']) : (ts($sel['settle_until']) > time() ? 'settling' : (tile_plantable($sel) ? 'ready to plant' : ((int)$sel['tilled'] ? 'ready for soil care' : 'till it first')));
          $fw = (int)$sel['fertility'] < 40 ? 'tired' : ((int)$sel['fertility'] < 65 ? 'okay' : 'good'); ?>
      <p class="sqsum"><b><?= e($sumWord) ?> · <?= e($sumState) ?></b><br><span class="muted">Soil: <?= $fw ?><?= $fw === 'tired' && (int)$sel['tilled'] ? ' · add compost' : '' ?></span></p>
      <?php $yb = yard_tile_bonuses($sel); if ($yb): ?>
        <p class="yardbonus"><?php foreach (array_keys($yb) as $bk): ?><span class="tag" title="<?= e(YARD_BONUSES[$bk][3]) ?>"><?= YARD_BONUSES[$bk][0] ?> <?= e(YARD_BONUSES[$bk][1]) ?></span> <?php endforeach; ?></p>
      <?php endif; ?>
      <?php if ($p):
          $info = tile_info($sel, $p); ?>
      <div class="plantinfo<?= $info['ready'] ? ' ready' : ($info['thirsty'] ? ' thirsty' : '') ?>">
        <p><b><?= e($p['name']) ?></b><?= !empty($sel['_native']) ? ' <span class="tag">🌍 native +' . (int)setting('native_bonus_percent') . '%</span>' : '' ?><?= $p['perennial'] ? ' <span class="tag">🔄 Perennial</span>' : '' ?><?= $p['kind'] === 'cover' ? ' <span class="muted">(cover crop: feeds N, P and K when dug in)</span>' : '' ?></p>
        <?php if (plant_unstudied($u, $p)): ?><p class="help unstudied">📕 Unstudied: grows <?= unstudied_slow_pct($u) ?>% slower and gives <?= 100 - unstudied_yield_pct($u) ?>% less. Study <?= e(plant_home_name((int)$p['id']) ?: 'its region') ?> or master it to fix that.</p><?php endif; ?>
        <?php if ($lt = perennial_life_text($sel, $p)): ?><p class="help lifeline"><?= e($lt) ?></p><?php endif; ?>
        <?php if (isset(NUTRIENTS[(string)($p['nutrient'] ?? '')])): $nu = (string)$p['nutrient']; $nv = (int)($sel[$nu] ?? 50); ?>
          <p class="help">Feeds on <?= e(strtolower(NUTRIENTS[$nu][0])) ?> (<?= NUTRIENTS[$nu][1] ?>): growing at <?= (int)round(nutrient_speed($sel) * 100) ?>% speed from it.
            <?= $nv < 35 ? 'Running low. ' . ['n' => 'Worm tea, fern tea, or grow beans or a cover crop first.', 'p' => 'Try shell meal or rock dust.', 'k' => 'Try kelp meal or wood ash.'][$nu] : '' ?>
            <?= $p['kind'] === 'legume' ? 'Beans give nitrogen back when harvested.' : '' ?></p>
        <?php endif; ?>
        <?= tile_fx_html($sel, $p, $plants) /* v1.0.0: season, weather, pests, companions */ ?>
        <?php require_once __DIR__ . '/includes/breeding110.php'; echo breeding110_garden_note($u, $sel, $p); /* v1.1.0: hybrids */ ?>
        <progress max="100" value="<?= (int)round($info['progress'] * 100) ?>"></progress>
        <p><?php if ($info['ready']): ?><?= $p['kind'] === 'cover' ? 'Ready to dig in! ☘️' : 'Ready to harvest! 🧺' ?>
           <?php elseif (!empty($info['rain'])): ?>🌧️ The rain is watering it. About <?= nice_time($info['time_left']) ?> left.
           <?php elseif ($info['thirsty']): ?>💧 Thirsty — growth has paused. About <?= nice_time($info['time_left']) ?> of watered growing left.
           <?php else: ?>Growing. About <?= nice_time($info['time_left']) ?> left. Water lasts another <?= nice_time($info['wet_left']) ?>.<?php endif; ?></p>
        <?= $info['ready'] ? tool_action_form('harvest', $sel, $p['kind'] === 'cover' ? 'Dig in' : 'Harvest', ENERGY_COST['harvest'])
                           : tool_action_form('water', $sel, 'Water', ENERGY_COST['water']) ?>
        <?= action_form('dig', $sel, 'Dig up', ENERGY_COST['dig'], '', 'Dig up this plant? You won’t get a harvest.') ?>
        <?php if (isset($built['root_cellar']) && (int)$p['perennial'] && $p['kind'] !== 'cover'): $cc = (int)setting('cellar_store_cost'); ?>
          <form method="post" class="inline" data-confirm="Dig the <?= e($p['name']) ?> up into the root cellar<?= $cc ? ' for ' . number_format($cc) : '' ?>?"><?= csrf_field() ?>
            <input type="hidden" name="do" value="cellar"><input type="hidden" name="x" value="<?= (int)$sel['x'] ?>"><input type="hidden" name="y" value="<?= (int)$sel['y'] ?>">
            <button class="btn act alt">🚪 Store in root cellar<?= $cc ? ' · ' . money($cc) : '' ?></button></form>
        <?php endif; ?>
      </div>
      <?php endif; ?>
      <div class="sqactions">
      <?php if (ts($sel['settle_until']) > time()): ?><p>🍂 Settling — ready to plant in <?= nice_time(ts($sel['settle_until']) - time()) ?>.</p><?php endif; ?>

      <?php if ($p): ?>
      <?php else: ?>
        <?php if ($sel['method'] !== 'till' || !(int)$sel['tilled']): ?>
          <?= tool_action_form('till', $sel, 'Till', action_cost($uid, 'till'), '',
              $sel['method'] === 'notill' ? 'Tilling a no-till bed destroys all the soil life you have built. Are you sure?' : '') ?>
        <?php endif; ?>
        <?php if ($canNoTill && $sel['method'] !== 'notill'): ?>
          <?= $mulches ? action_form('sheet', $sel, 'Sheet mulch (no-till)', action_cost($uid, 'sheet'), item_select($mulches, fn($i) => $i['name'] . ' ×' . $i['qty'], 'mulch'))
                       : '<p class="help">To start a no-till bed you need a Cardboard Sheet and some mulch.</p>' ?>
        <?php endif; ?>
        <?php if ($sel['method'] === 'notill' && tool_power($uid, 'broadfork')):
            $forkWait = $sel['fork_at'] ? (int)setting('broadfork_days') * 86400 - (time() - ts($sel['fork_at'])) : 0; ?>
          <?= $forkWait > 0 ? '<p class="help">⛏️ Broadforked recently. Again in ' . nice_time($forkWait) . '.</p>'
                            : action_form('broadfork', $sel, 'Broadfork', ENERGY_COST['broadfork']) ?>
        <?php endif; ?>
        <?php if (tile_plantable($sel)):
            $plantable = $seeds;   // v0.7.65
            $unknownCount = count(array_filter($seeds, fn($s) => empty($s['sapling']) && empty($known[(int)$s['plant_id']]))); ?>
          <?php if ($plantable): ?>
            <?= tool_action_form('plant', $sel, 'Plant', ENERGY_COST['plant'], item_select($plantable, fn($s) =>
                $s['name'] . ' ×' . $s['qty']
                . (empty($s['sapling']) && empty($known[(int)$s['plant_id']]) ? ' 📕 unstudied' : '')
                . (!empty($s['perennial']) ? ' 🔄 Perennial' : '')
                . ((int)$s['min_soil'] > (int)$sel['fertility'] ? ' (needs fertility ' . $s['min_soil'] . ')' : ''), 'seed')) ?>
          <?php else: ?><p class="muted">No seeds in your satchel. Visit a market!</p><?php endif; ?>
          <?php $cel = isset($built['root_cellar']) ? cellar_plants((int)$plot['id']) : [];
          if ($cel): ?>
            <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="uncellar"><input type="hidden" name="x" value="<?= (int)$sel['x'] ?>"><input type="hidden" name="y" value="<?= (int)$sel['y'] ?>">
              <select name="cellar_id" data-pick="cellar"><?php foreach ($cel as $cp): ?><option value="<?= (int)$cp['id'] ?>"><?= e($cp['name']) ?> (<?= (int)min(100, round((int)$cp['growth_seconds'] / max(1, (int)$cp['grow_minutes'] * 60) * 100)) ?>% grown)</option><?php endforeach; ?></select>
              <button class="btn act alt">🚪 Replant from cellar</button></form>
          <?php endif; ?>
          <?php if ($unknownCount): ?><p class="help">📕 <?= $unknownCount ?> kind(s) of seed in your satchel are unstudied: they grow <?= unstudied_slow_pct($u) ?>% slower and give <?= 100 - unstudied_yield_pct($u) ?>% less until you study their region (its gardening guide, or its questline in Almanac → Journey) or master the crop.</p><?php endif; ?>
        <?php endif; ?>
      <?php endif; ?>
      <?php if ((int)$sel['tilled']): ?>
        <?php if ($soils && (int)$sel['feed_hours'] <= 0 && (int)$sel['fertility'] < (int)setting('amend_max_fertility')) echo tool_action_form('soil', $sel, 'Work in', ENERGY_COST['soil'], item_select($soils, fn($i) => $i['name'] . ' ×' . $i['qty'], 'soil')); ?>
        <?php if ($mulches) echo tool_action_form('mulch', $sel, 'Add mulch', ENERGY_COST['mulch'], item_select($mulches, fn($i) => $i['name'] . ' ×' . $i['qty'], 'mulch')); ?>
      <?php endif; ?>
      </div>
      <details class="soildet"<?= $p ? ' open' : '' ?>><summary>Soil details</summary>   <?php /* v1.6.2 */ ?>
      <table class="kv soil">
        <tr><th>Fertility</th><td><?= e($w['fertility']) ?> <b><?= (int)$sel['fertility'] ?></b>/100</td></tr>
        <tr><th>Soil life</th><td><?= $hasKit ? (int)$sel['soil_life'] . '/100' : e($w['life']) ?></td></tr>
        <?php if ($p && empty($info['ready'])): ?><tr><th>💧 Watered</th><td><?= $info['thirsty'] ? '<b class="bad">No, thirsty</b>' : 'Yes, for another ' . nice_time($info['wet_left']) ?></td></tr><?php endif; ?>
        <tr><th title="How well the soil holds water. Better soil makes each watering last longer (up to twice as long). Mulch, compost and no-till beds improve it; watering helps a little.">Holds water</th><td><?= $hasKit ? (int)$sel['moisture'] . '/100' : e($w['moisture']) ?></td></tr>
        <?php $need = $p ? (string)($p['nutrient'] ?? '') : '';
        foreach (NUTRIENTS as $nu => [$nName, $nLetter, $nIcon]): $nv = (int)($sel[$nu] ?? 50); ?>
          <tr class="npk<?= $need === $nu ? ' need' : '' ?><?= $nv < 35 ? ' low' : '' ?>"><th><span class="npkb <?= $nu ?>"><?= $nLetter ?></span> <?= e($nName) ?></th>
            <td><?= $hasKit ? $nv . '/100' : e(nutrient_word($nv)) ?><?= $need === $nu ? ' ← ' . e($p['name']) . ' feeds on this' : '' ?></td></tr>
        <?php endforeach; ?>
      </table>
      <?php if (!$hasKit): ?><p class="help">A Soil Test Kit from the Mossbottom hub shows exact numbers.</p><?php endif; ?>
      <?php if (tool_tier($uid, 'soiltest') >= 2 && (int)$sel['tilled'] && !$p && ($best = probe_best_crops($u, $sel))): ?>
        <p class="probe">🔬 <b>Soil Probe:</b> best crops you know for this square:
          <?= implode(' · ', array_map(fn($b) => '<b>' . e($b[0]['name']) . '</b> <small class="muted">(' . e($b[1]) . ')</small>', $best)) ?></p>
      <?php endif; ?>
      <?php if ((int)$sel['feed_hours'] > 0): ?>
        <?php $still = array_filter([(int)$sel['feed_fert'] ? '+' . (int)$sel['feed_fert'] . ' fertility' : '', (int)$sel['feed_life'] ? '+' . (int)$sel['feed_life'] . ' soil life' : '',
            npk_text(['n' => (int)($sel['feed_n'] ?? 0), 'p' => (int)($sel['feed_p'] ?? 0), 'k' => (int)($sel['feed_k'] ?? 0)])]); ?>
        <p class="feeding">🪱 Soil improver working in<?= $hasKit && $still ? ': ' . e(implode(', ', $still)) . ' still to come' : '' ?>.
          Ready for more in <?= nice_time(feed_seconds_left($sel)) ?>.</p>
      <?php elseif ((int)$sel['tilled']): ?>
        <p class="help">Compost and other soil improvers take a short time to work in, one at a time.</p>
      <?php endif; ?>
      <?php if ($sel['method'] !== 'notill'):   // v0.8.7: soil care stars for tilled squares
          $cp = care_points($sel); $cs = care_stars_for($cp); $steps = care_steps();
          $prev = $cs > 0 ? $steps[$cs - 1] : 0;
          $todayDone = ($sel['care_day'] ?? '') === job_period_key('daily');
          $lifeOk = (int)$sel['soil_life'] >= (int)setting('care_min_life'); ?>
        <div class="gradebox carebox">
          <span class="grade big care"><?= $cs ? '★' . $cs : '☆' ?></span>
          <div>
            <b>Soil care <?= care_star_text($cs) ?></b> <span class="muted"><?= e(CARE_NAMES[$cs]) ?></span>
            <?php if ($cs < 5): ?><progress max="<?= $steps[$cs] - $prev ?>" value="<?= $cp - $prev ?>"></progress>
              <span class="help"><?= $steps[$cs] - $cp ?> more good harvest<?= $steps[$cs] - $cp === 1 ? '' : 's' ?> (one a day) to <?= care_star_text($cs + 1) ?></span>
            <?php else: ?><span class="help">The best tilled soil there is.</span><?php endif; ?>
          </div>
        </div>
        <ul class="upkeep">
          <li class="<?= (int)$sel['care_fed'] ? 'good' : 'muted' ?>">Soil improver since the last harvest <?= (int)$sel['care_fed'] ? '✔' : '— work some in' ?></li>
          <li class="<?= $lifeOk ? 'good' : 'bad' ?>">Soil life <?= $lifeOk ? '✔' : '— too low, it needs to be lively' ?></li>
          <li class="<?= $todayDone ? 'good' : 'muted' ?>"><?= $todayDone ? 'Point earned today ✔' : 'No point earned today yet' ?></li>
        </ul>
        <p class="help">A harvest with both earns a point. Each star makes crops here grow <?= (int)setting('care_growth_percent') ?>% faster
          and tilling less harmful: the next till costs <?= care_till_damage($sel) ?> soil life. Left as wild ground, a square loses a star every <?= (int)setting('care_decay_days') ?> days.
          <?= $cs >= 2 ? 'Turning it into a no-till bed starts it at grade ' . e(grade_name(intdiv($cs, 2))) . '.' : '' ?></p>
      <?php endif; ?>
      </details>
      <?php if ($sel['method'] === 'notill'):
          $gi = grade_index($sel);
          $into = (int)$sel['bed_score'] - $gi * GRADE_STEP;
          $probs = bed_problems($sel); ?>
        <div class="gradebox">
          <span class="grade big g<?= $gi ?>"><?= e(grade_name($gi)) ?></span>
          <div>
            <b>Soil grade <?= e(grade_name($gi)) ?></b>
            <?php if ($gi < 10): ?><progress max="<?= GRADE_STEP ?>" value="<?= max(0, $into) ?>"></progress>
              <span class="help"><?= max(0, GRADE_STEP - $into) ?> points to <?= e(grade_name($gi + 1)) ?></span>
            <?php else: ?><span class="help">The finest soil there is. Keep it that way!</span><?php endif; ?>
          </div>
        </div>
        <ul class="upkeep">
          <li class="<?= isset($probs['mulch']) ? 'bad' : ((int)$sel['mulch'] < 24 ? 'warn' : 'good') ?>">Mulch: <?= e(mulch_text((int)$sel['mulch'])) ?> <?= isset($probs['mulch']) ? '— add mulch' : ((int)$sel['mulch'] < 24 ? '— top up soon' : '✔') ?></li>
          <li class="<?= isset($probs['weeds']) ? 'bad' : 'good' ?>">Weeds <?= (int)$sel['weeds'] ?>/100 <?= isset($probs['weeds']) ? '— pull them' : '✔' ?></li>
          <li class="<?= isset($probs['moisture']) ? 'bad' : 'good' ?>">Moisture <?= isset($probs['moisture']) ? '— water the bed' : '✔' ?></li>
          <li class="<?= isset($probs['fertility']) ? 'bad' : 'good' ?>">Fertility <?= isset($probs['fertility']) ? '— add compost' : '✔' ?></li>
          <li class="<?= $sel['plant_id'] ? 'good' : 'muted' ?>">Living roots <?= $sel['plant_id'] ? '✔ (double points)' : '— plant something or a cover crop' ?></li>
        </ul>
        <p class="help"><?= $probs ? '⚠️ This bed is slowly losing points until it’s fixed.' : 'Well kept! Gaining points every hour.' ?></p>
        <?php if ((int)$sel['checkpoint'] > 0):
            $graceLeft = (int)setting('notill_checkpoint_days') * 24 - (int)$sel['neglect_hours']; ?>
          <p class="checkpoint">🛡️ Checkpoint <?= checkpoint_name((int)$sel['checkpoint']) ?> — this bed can’t fall below grade <?= checkpoint_name((int)$sel['checkpoint']) ?><?= (int)$sel['neglect_hours'] > 0 ? '. Neglected for ' . nice_time((int)$sel['neglect_hours'] * 3600) . '; the checkpoint is lost after ' . nice_time($graceLeft * 3600) . ' more.' : ' unless tilled or neglected for ' . (int)setting('notill_checkpoint_days') . ' days straight.' ?></p>
        <?php endif; ?>
        <?php if ((int)$sel['weeds'] >= 5) echo tool_action_form('weed', $sel, 'Pull weeds', ENERGY_COST['weed']); ?>
        <?php if (!$sel['plant_id']) echo tool_action_form('water', $sel, 'Water bed', ENERGY_COST['water']); ?>
      <?php endif; ?>
    <?php endif; ?>
  </div>
</div>
<?php endif; /* v1.4.0: end of the Beds tab */ ?>

<?php if ($tab === 'bld'):   // v0.9.6: compact buildings panel
$bBuilt = $bCan = $bLater = [];
foreach (BUILDINGS as $key => $bdef) {
    if (critter_is_home($key) && (setting('animals_on') === '0' || animals120_blocked($key) || animals140_blocked($key)) && !isset($built[$key])) continue;   // v1.0.0: animals switched off
    if (isset($built[$key])) $bBuilt[$key] = $bdef;
    elseif ((int)$plot['garden_level'] >= $bdef[2]) $bCan[$key] = $bdef;
    else $bLater[$key] = $bdef;
}
$maxLv = fn(string $k): int => 1 + count(BUILDING_UPGRADES[$k] ?? []);
?>
<div class="box gtab" id="buildings">
  <?php if ($readyB): ?><p><b>📦 Something to collect!</b></p><?php endif; ?>
  <p class="help">Tap a building for details. New ones appear in a free yard spot: move them with ✏️ Design yard.</p>
  <?php if ($bBuilt): ?>
  <div class="btiles">
  <?php foreach ($bBuilt as $key => [$bname, $icon, $lvl, $cost, $desc]):
      $blv = max(1, (int)($built[$key]['level'] ?? 1)); $mx = $maxLv($key);
      $ready = isset(BUILDING_PRODUCE[$key]) ? building_ready($built[$key]) + heap_ready($built[$key]) : (critter_is_home($key) ? critter_ready((int)$plot['id'], $key) : 0);
      $next = BUILDING_UPGRADES[$key][$blv + 1] ?? null; $uc = $um = $ul = 0;
      if ($next !== null) [$uc, $um, $ul] = upgrade_cost($key, $blv + 1);
      $canUp = $next !== null && (int)$plot['garden_level'] >= $ul;
      if ($key === 'compost_bin') {
          $hout = heap_output($built[$key]); $need = heap_need($blv, $hout); $sc = (int)$built[$key]['scraps']; $hr = heap_ready($built[$key]);
          $haveScraps = (int)q_val("SELECT ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? AND i.slug = 'food-scrap'", [$uid]);
      }
      if ($key === 'root_cellar') { $cel = cellar_plants((int)$plot['id']); $cslots = cellar_slots((int)$plot['id']); }
      if ($key === 'kitchen') $kb = user_building_bonus($uid, 'kitchen');   // stacking
      $status = $ready > 0 ? $ready . ' ready'
          : ($key === 'compost_bin' ? 'Heap ' . ($sc % $need) . '/' . $need
          : ($key === 'beehive' ? 'Making honey'
          : ($key === 'kitchen' ? cook_pot_limit($u) . ' pots' . (!empty($built[$key]['pantry']) ? ' · 🫙 ' . pantry_jar_limit($uid) : '')
          : ($key === 'root_cellar' ? count($cel) . '/' . $cslots . ' stored' : (critter_is_home($key) ? critter_status((int)$plot['id'], $key) : 'Built'))))); ?>
    <div class="btile built" id="b-<?= e($key) ?>">
      <details class="bt"<?= ($_GET['bld'] ?? '') === $key ? ' open' : '' ?>>
        <summary><span class="bticon" aria-hidden="true"><?= $icon ?></span>
          <span class="btname"><?= e($bname) ?></span>
          <?php if ($mx > 1): ?><span class="pips" role="img" aria-label="Level <?= $blv ?> of <?= $mx ?>"><?php for ($i = 1; $i <= $mx; $i++): ?><i class="<?= $i <= $blv ? 'on' : '' ?>"><?= e(trim(BUILDING_LEVEL_MARK[$i] ?? '') ?: 'I') ?></i><?php endfor; ?></span><?php endif; ?>
          <span class="btstat<?= $ready > 0 ? ' ready' : '' ?>"><?= e($status) ?></span></summary>
        <div class="btbody">
          <p><b>Now:</b> <?= e(BUILDING_NOW[$key][$blv] ?? $desc) ?></p>
          <?php if (critter_is_home($key)) echo critter_panel_html($u, $plot, $key);   // v1.0.0: the residents ?>
          <?php if ($ready > 0): ?>
            <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="collect"><input type="hidden" name="building" value="<?= e($key) ?>">
              <button class="btn small">Collect <?= $ready ?></button></form>
          <?php endif; ?>
          <?php if ($key === 'kitchen'): ?>
            <p>🍳 All your kitchens together: meal buffs last <b>+<?= $kb['buff_pct'] ?>%</b> longer, cooking gives <b>+<?= $kb['xp_pct'] ?>%</b> XP, you have <b><?= cook_pot_limit($u) ?></b> pots<?= $kb['feasts'] ? ', and you can cook feasts' : '' ?>.</p>
            <?php if (!empty($built[$key]['pantry'])): $jb = pantry_busy($uid); $jr = pantry_ready_count($uid); ?>
              <p>🫙 <b>Pantry:</b> <?= $jb ?>/<?= $kb['jars'] ?> jars in use<?= $jr ? ' · <b>' . $jr . ' ready</b>' : '' ?>. <a href="<?= e(url('inventory.php?tab=craft&c=pantry')) ?>">Open the Pantry →</a></p>
              <details class="how"><summary>How many jars?</summary>
                <p class="help"><?= (int)setting('pantry_jars') ?> to start, +<?= (int)setting('pantry_jars_k3') ?> when a Kitchen with a Pantry is level III, and +<?= (int)setting('stack_pantry_jar_per') ?> for each Pantry in your other gardens (up to +<?= (int)setting('stack_pantry_jar_max') ?>). You have <?= $kb['pantries'] ?> Pantr<?= $kb['pantries'] === 1 ? 'y' : 'ies' ?>.</p></details>
            <?php else: [$pc, $pm] = pantry_cost(); ?>
              <p class="btnext"><b>🫙 Pantry:</b> <?= (int)setting('pantry_jars') ?> jars for jam, pickles and cordials that keep for real days and never spoil.<br><span class="muted">Costs <?= money($pc) ?><?= $pm ? ' + ' . e(upgrade_mats_text($pm)) : '' ?> (Timber Planks: Satchel → Crafting → Building).</span></p>
              <form method="post" data-confirm="Add a Pantry to this Kitchen for <?= number_format($pc) ?> Petals?"><?= csrf_field() ?><input type="hidden" name="do" value="pantry_buy">
                <button class="btn small">🫙 Add a Pantry · <?= money($pc) ?></button></form>
            <?php endif; ?>
            <details class="how"><summary>How stacking works</summary>
              <p class="help"><?= count($kb['levels']) > 1 ? 'Your best kitchen counts fully; each level in your other gardens adds ' . (int)setting('stack_kitchen_buff_pct') . '% buff time and ' . (int)setting('stack_kitchen_xp_pct') . '% XP, and each other Kitchen III adds ' . (int)setting('stack_kitchen_pot_per_iii') . ' pot (up to ' . (int)setting('stack_kitchen_pot_max') . ').' : 'Build another kitchen in a second garden and it adds ' . (int)setting('stack_kitchen_buff_pct') . '% buff time and ' . (int)setting('stack_kitchen_xp_pct') . '% XP per level on top.' ?></p></details>
          <?php endif; ?>
          <?php if ($key === 'compost_bin'): ?>
            <p>♻️ Heap: <b><?= $sc % $need ?>/<?= $need ?></b> scraps for <?= e(HEAP_OUTPUTS[$hout][0]) ?><?= $hr ? ' · <b>' . $hr . ' ready</b>' : '' ?><?= $hr >= (int)setting('compost_heap_max') ? ' (full!)' : '' ?></p>
            <div class="btrow">
            <?php if ($haveScraps > 0): ?>
              <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="add_scraps">
                <button class="btn small">♻️ Add scraps (<?= $haveScraps ?>)</button></form>
            <?php endif; ?>
            <?php $opts = array_filter(HEAP_OUTPUTS, fn($o) => $o[1] <= $blv); if (count($opts) > 1): ?>
              <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="do" value="heap_out">
                <label>Heap makes <select name="out"><?php foreach ($opts as $oslug => $o): ?><option value="<?= e($oslug) ?>"<?= $oslug === $hout ? ' selected' : '' ?>><?= e($o[0]) ?> (<?= heap_need($blv, $oslug) ?> scraps)</option><?php endforeach; ?></select></label>
                <button class="btn small">Set</button></form>
            <?php endif; ?>
            </div>
            <?php if ($haveScraps < 1): ?><p class="help">Eat a raw crop to get Food Scraps, then add them here.</p><?php endif; ?>
          <?php endif; ?>
          <?= skin_panel_html($u, $plot, $key, (string)($built[$key]['skin'] ?? '')) /* v0.9.7: building looks */ ?>
          <?php if ($key === 'root_cellar'): ?>
            <p><?= count($cel) ?>/<?= $cslots ?> stored<?= $cel ? ': ' . e(implode(', ', array_column($cel, 'name'))) : '' ?></p>
            <p class="help">Store: open a perennial’s square. Replant: open an empty tilled square.</p>
          <?php endif; ?>
          <?php if ($next !== null): ?>
            <p class="btnext"><b>Level <?= $blv + 1 ?>:</b> <?= e($next) ?><br><span class="muted">Costs <?= money($uc) ?><?= $um ? ' + ' . e(upgrade_mats_text($um)) : '' ?> (Dressed Stone, Timber Planks and Rope: Satchel → Crafting → Building).</span></p>
            <?php if ($canUp): ?>
              <form method="post" data-confirm="Upgrade your <?= e($bname) ?> to level <?= $blv + 1 ?>?"><?= csrf_field() ?><input type="hidden" name="do" value="upgrade"><input type="hidden" name="building" value="<?= e($key) ?>">
                <button class="btn small">⬆️ Upgrade · <?= money($uc) ?></button></form>
            <?php else: ?><span class="muted">🔒 Garden level <?= $ul ?></span><?php endif; ?>
          <?php endif; ?>
        </div>
      </details>
      <?php if ($ready > 0): ?>
        <form method="post"><?= csrf_field() ?><input type="hidden" name="do" value="collect"><input type="hidden" name="building" value="<?= e($key) ?>">
          <button class="btn small">Collect <?= $ready ?></button></form>
      <?php elseif ($canUp): ?>
        <form method="post" data-confirm="Upgrade your <?= e($bname) ?> to level <?= $blv + 1 ?>?"><?= csrf_field() ?><input type="hidden" name="do" value="upgrade"><input type="hidden" name="building" value="<?= e($key) ?>">
          <button class="btn small alt">⬆️ Lv <?= e(trim(BUILDING_LEVEL_MARK[$blv + 1] ?? '') ?: $blv + 1) ?> · <?= number_format($uc) ?></button></form>
      <?php endif; ?>
    </div>
  <?php endforeach; ?>
  </div>
  <?php endif; ?>
  <?php if ($bCan): ?>
  <h3 class="bsub">Ready to build</h3>
  <div class="btiles small">
  <?php foreach ($bCan as $key => [$bname, $icon, $lvl, $cost, $desc]): ?>
    <div class="btile" id="b-<?= e($key) ?>">
      <b><span aria-hidden="true"><?= $icon ?></span> <?= e($bname) ?></b>
      <span class="help"><?= e(BUILDING_SHORT[$key] ?? '') ?></span>
      <form method="post" data-confirm="Build a <?= e($bname) ?> for <?= number_format($cost) ?>?"><?= csrf_field() ?><input type="hidden" name="do" value="build"><input type="hidden" name="building" value="<?= e($key) ?>">
        <button class="btn small">Build · <?= money($cost) ?></button></form>
    </div>
  <?php endforeach; ?>
  </div>
  <?php endif; ?>
  <?php if ($bLater): ?>
  <div class="blater"><span class="muted">🔒 Later, as the garden levels up:</span>
  <?php foreach ($bLater as $key => [$bname, $icon, $lvl, $cost, $desc]): ?>
    <details class="lk" id="b-<?= e($key) ?>"><summary><?= $icon ?> <?= e($bname) ?> <small>(Lv <?= $lvl ?>)</small></summary>
      <p class="help"><?= e(BUILDING_SHORT[$key] ?? '') ?> Costs <?= money($cost) ?><?= e(garden_xp_hint($plot, $lvl)) ?></p></details>
  <?php endforeach; ?>
  </div>
  <?php endif; ?>
</div>
<?php endif; /* v1.4.0: end of the Buildings tab */ ?>

<?php if ($tab === 'an'):   // v1.0.1: the animals (Biddy used to sit above the yard); v1.4.0: their own tab
    $biddyTrade = str_contains($biddy, 'value="biddy"'); ?>
<div class="box animals gtab" id="biddy">
  <?php if ($biddyTrade || $nbr['hint'] !== ''): ?><p class="help"><?= $biddyTrade ? '🐔 Biddy wants scraps' : ($biddy !== '' ? '🐔 Biddy is here' : '') ?><?= e($nbr['hint']) ?></p><?php endif; ?>
  <?php if ($homes): ?><ul class="animalhomes">
    <?php foreach ($homes as $hk): ?><li><a href="<?= e(url('garden.php?bld=' . $hk . '#b-' . $hk)) ?>"><?= BUILDINGS[$hk][1] ?> <?= e(BUILDINGS[$hk][0]) ?></a> <small class="muted"><?= e(critter_status((int)$plot['id'], $hk)) ?></small></li><?php endforeach; ?>
  </ul><?php endif; ?>
  <?= $biddy ?>
  <?= $nbr['html'] /* built from escaped parts in animals120_neighbours() */ ?>
  <?php if ($biddy === '' && $nbr['html'] === '' && setting('animals_on') !== '0'):   // v1.4.8: say who might come, on a quiet day
      $who = array_values(array_filter([setting('biddy_on') !== '0' ? '🐔 Biddy the hen' : '', setting('clementine_on') !== '0' ? '🐐 Clementine the goat' : '', setting('percy_on') !== '0' ? '🕊️ Percy the pigeon' : '']));
      if ($who): ?>
    <p class="help">No visitors at the fence today. <?= e(count($who) > 1 ? implode(', ', array_slice($who, 0, -1)) . ' and ' . end($who) : $who[0]) ?> drop by on some days to trade, and a lovelier yard (curb appeal) brings them a little more often.</p>
  <?php endif; endif; ?>
</div>
<?php endif; /* v1.4.0: end of the Animals tab */ ?>

<?php if ($tab === 'help'):
    $hnames = array_map('strval', array_column($hires, 'name'));   // v1.4.0: "Clover and Moss are here"
    $hlist = count($hnames) > 1 ? implode(', ', array_slice($hnames, 0, -1)) . ' and ' . end($hnames) : implode('', $hnames); ?>
<div class="box hiredhelp gtab">
  <?php if ($hires): ?><p><b>🧑‍🌾 <?= e($hlist) ?> <?= count($hires) === 1 ? 'is' : 'are' ?> here</b></p><?php endif; ?>
  <?php foreach ($hires as $hire): ?>
    <div class="helper on">
      <span class="hicon"><?= e((string)$hire['icon']) ?></span>
      <div>
        <b><?= e($hire['name']) ?></b> <span class="muted">(<?= e((string)$hire['species']) ?>)</span> is staying in your Tool Shed.
        <p class="help"><?= e(helper_skill_text($hire)) ?> · visits every <?= (int)setting('helper_visit_hours') ?> hours ·
          <?= nice_time(max(0, ts($hire['ends_at']) - time())) ?> left</p>
        <p class="help">So far: <?= (int)$hire['visits'] ?> visits, watered <?= (int)$hire['waterings'] ?>, weeded <?= (int)$hire['weedings'] ?>, harvested <?= (int)$hire['harvests'] ?>.</p>
        <form method="post" data-confirm="Send <?= e($hire['name']) ?> home? Unused whole days are refunded."><?= csrf_field() ?><input type="hidden" name="do" value="dismiss"><input type="hidden" name="hire_id" value="<?= (int)$hire['id'] ?>">
          <button class="btn small alt">Send home</button></form>
      </div>
    </div>
  <?php endforeach; ?>
  <?php if (!isset($built['tool_shed'])): ?>
    <p>Going adventuring? A helper can water, weed and harvest while you’re away. They need somewhere to stay:
      build a <b>🧰 Tool Shed</b> in this garden (garden level <?= (int)BUILDINGS['tool_shed'][2] ?>).</p>
  <?php elseif (count($hires) >= $slots): ?>
    <p class="help">🧰 Your Tool Shed houses <?= $slots ?> helper<?= $slots === 1 ? '' : 's' ?><?= $slots < 3 ? '. Upgrade it to make room for another.' : ', the most it can.' ?></p>
  <?php else: $busy = array_map('intval', array_column($hires, 'helper_id')); ?>
    <p class="help">🧰 Room for <?= $slots - count($hires) ?> more (the Tool Shed houses one helper per level). Paid up front. They visit every <?= (int)setting('helper_visit_hours') ?> hours, keep <?= (int)setting('helper_cut_percent') ?>% of what they harvest,
      and you get <?= (int)setting('helper_xp_percent') ?>% XP for their harvests.</p>
    <div class="helpers">
    <?php foreach (q('SELECT * FROM helpers WHERE active = 1 ORDER BY wage')->fetchAll() as $h): if (in_array((int)$h['id'], $busy, true)) continue; ?>
      <div class="helper">
        <span class="hicon"><?= e((string)$h['icon']) ?></span>
        <div>
          <b><?= e($h['name']) ?></b> <span class="muted">(<?= e((string)$h['species']) ?>)</span>
          <p class="help"><?= e((string)$h['bio']) ?></p>
          <p class="help"><?= e(helper_skill_text($h)) ?> · <?= money((int)$h['wage']) ?> a day</p>
          <?php foreach (HELP_DAYS as $d): ?>
            <form method="post" class="inline" data-confirm="Hire <?= e($h['name']) ?> for <?= $d ?> day<?= $d > 1 ? 's' : '' ?> (<?= number_format((int)$h['wage'] * $d) ?>)?"><?= csrf_field() ?>
              <input type="hidden" name="do" value="hire"><input type="hidden" name="helper_id" value="<?= (int)$h['id'] ?>"><input type="hidden" name="days" value="<?= $d ?>">
              <button class="btn small"><?= $d ?> day<?= $d > 1 ? 's' : '' ?> · <?= money((int)$h['wage'] * $d) ?></button></form>
          <?php endforeach; ?>
        </div>
      </div>
    <?php endforeach; ?>
    </div>
  <?php endif; ?>
</div>
<?php endif; /* v1.4.0: end of the Help tab */ ?>

<?php if ($tab === 'grow'): ?>
<div class="box gtab"><h3>📐 Add beds</h3>
  <?php $nbeds = (int)q_val('SELECT COUNT(*) FROM plot_tiles WHERE plot_id = ?', [$plot['id']]); $room = bed_room($plot); [$bc, $bi] = bed_add_cost($plot); $bcap = garden_max_side($plot); ?>
  <p>You have <b><?= $nbeds ?></b> beds. At garden level <?= (int)$plot['garden_level'] ?> this garden holds up to <b><?= $bcap * $bcap ?></b>
    (up to <?= (int)setting('max_plot_size') ** 2 ?> as it levels). New beds appear in your yard like decor: move them with ✏️ Design yard.</p>
  <?php if ($room > 0): ?>
    <p class="help">Next <?= min(4, $room) ?> beds cost <b><?= money($bc) ?></b><?= $bi ? ' + ' . e(upgrade_mats_text($bi)) : '' ?> (Timber Planks are made in Satchel → Crafting → Building). Each purchase costs <?= (int)setting('bed_add_growth_pct') ?>% more than the last.</p>
    <form method="post" class="inline" data-confirm="Add <?= min(4, $room) ?> beds for <?= number_format($bc) ?><?= $bi ? ' and ' . e(upgrade_mats_text($bi)) : '' ?>?"><?= csrf_field() ?>
      <input type="hidden" name="do" value="expand"><button class="btn small">➕ Add <?= min(4, $room) ?> beds</button></form>
  <?php else: ?>
    <p class="help"><?= $bcap >= (int)setting('max_plot_size') ? 'This garden has as many beds as it can ever hold.' : 'A higher garden level lets it hold more beds. Harvests raise it.' ?></p>
  <?php endif; ?>
</div>

<?= sign_panel_html($u, $plot) /* v0.9.7: garden signpost */ ?>
<?php endif; /* v1.4.0: end of the Grow tab */ ?>

<p class="help">Your gnome’s stats, calling and meal buffs are on <a href="<?= e(url('gnome.php')) ?>">My Gnome</a>.</p>
<?php page_footer();

<?php
declare(strict_types=1);
// Graphical navigation: layout editor. A picture page's slots (exits, spots, stand points, house slots) are drawn as dots on its art; drag a dot
// or type x / y, Save writes the here_layouts table (it overrides includes/data/here_layouts.json), Reset goes back to the shipped layout.
// Works without script (number boxes post as a normal form); assets/hereedit.js only adds dragging. Lint = includes/here_layout.php here_lint_layout().
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_helpers.php';
require_once dirname(__DIR__) . '/includes/here_layout.php';
require_once dirname(__DIR__) . '/includes/scene.php';
$me = require_admin();
here_ensure_layouts_table();
$shipped = here_layouts_shipped();
$all = here_layouts_all();
$keys = array_keys($all);
sort($keys);
$key = (string)($_REQUEST['key'] ?? 'generic');
if (!preg_match('/^[a-z0-9:_-]{1,60}$/', $key)) $key = 'generic';
$GROUPS = ['exits' => 'Exits (compass paths)', 'spots' => 'Spots (named things)', 'stand' => 'Stand points (where villagers stand)', 'houses' => 'House slots (Residential)', 'pals' => 'Pal perches (Treehouse)'];
$msg = '';
$lintOnly = null;

/** Build a layout from the posted form, keeping the layout's own meta (w, h, horizon, extra keys). */
function here_layout_from_post(array $base): array
{
    $L = $base;
    $L['w'] = max(64, min(4000, (int)($_POST['w'] ?? $base['w'] ?? 480)));
    $L['h'] = max(64, min(4000, (int)($_POST['h'] ?? $base['h'] ?? 270)));
    $L['horizon'] = max(0, min($L['h'], (int)($_POST['horizon'] ?? $base['horizon'] ?? 0)));
    foreach (['exits', 'spots', 'stand', 'houses', 'pals'] as $g) {
        $rows = [];
        foreach ((array)($_POST['x'][$g] ?? []) as $i => $x) {
            $y = $_POST['y'][$g][$i] ?? '';
            if ($x === '' || $y === '' || !empty($_POST['del'][$g][$i])) continue;
            $r = ['x' => (int)$x, 'y' => (int)$y];
            if ($g === 'exits') { $a = (string)($_POST['n'][$g][$i] ?? ''); if (!isset(HERE_ANCHORS[$a])) continue; $r = ['a' => $a] + $r; }
            if ($g === 'spots') { $k = (string)($_POST['n'][$g][$i] ?? ''); if (!preg_match('/^[a-z0-9_-]{1,24}$/', $k)) continue; $r = ['k' => $k] + $r;
                foreach ($base['spots'] ?? [] as $bs) if (($bs['k'] ?? '') === $k && isset($bs['box'])) $r['box'] = $bs['box']; }   // the editor moves the dot; the hit box (art side) is kept
            $rows[] = $r;
        }
        if ($rows || isset($base[$g])) $L[$g] = $rows;
        if (!$rows && !isset($base[$g])) unset($L[$g]);
    }
    return $L;
}

if (is_post()) {
    csrf_check();
    $do = (string)($_POST['do'] ?? '');
    $cur = $all[$key] ?? ($all['generic'] ?? ['w' => 480, 'h' => 270, 'horizon' => 112]);
    if ($do === 'save' || $do === 'lint') {
        $L = here_layout_from_post($cur);
        $problems = here_lint_layout($L);
        if ($do === 'save') {
            $j = json_encode($L, JSON_UNESCAPED_SLASHES);
            if (q_val('SELECT COUNT(*) FROM here_layouts WHERE layout_key = ?', [$key])) q('UPDATE here_layouts SET json = ?, updated_at = ? WHERE layout_key = ?', [$j, now(), $key]);
            else db_insert('here_layouts', ['layout_key' => $key, 'json' => $j, 'updated_at' => now()]);
            admin_log('here_layout_save', $key, $problems ? count($problems) . ' lint problems' : 'clean');
            flash('Saved layout "' . $key . '".' . ($problems ? ' Lint found ' . count($problems) . ' problem(s): see below.' : ' Lint is clean.'), $problems ? 'err' : 'ok');
            redirect('admin/here_layout.php?key=' . urlencode($key) . ($problems ? '&lint=1' : ''));
        }
        $lintOnly = [$L, $problems];
    } elseif ($do === 'reset') {
        q('DELETE FROM here_layouts WHERE layout_key = ?', [$key]);
        admin_log('here_layout_reset', $key, '');
        flash('Layout "' . $key . '" is back to the shipped one.' . (isset($shipped[$key]) ? '' : ' (There is no shipped copy, so it is gone.)'));
        redirect('admin/here_layout.php?key=' . urlencode(isset($shipped[$key]) ? $key : 'generic'));
    } elseif ($do === 'copy') {
        $to = (string)($_POST['newkey'] ?? '');
        if (!preg_match('/^[a-z0-9:_-]{1,60}$/', $to) || isset($all[$to])) { flash('Pick a new key: lower case letters, digits, : _ -, not used yet.', 'err'); redirect('admin/here_layout.php?key=' . urlencode($key)); }
        db_insert('here_layouts', ['layout_key' => $to, 'json' => json_encode($cur, JSON_UNESCAPED_SLASHES), 'updated_at' => now()]);
        admin_log('here_layout_copy', $key, $to);
        flash('Made "' . $to . '" from "' . $key . '". Lookup order: slug:<place slug>, <kind>-<landscape>, <kind>, generic.');
        redirect('admin/here_layout.php?key=' . urlencode($to));
    }
}

$L = $lintOnly[0] ?? ($all[$key] ?? $all['generic'] ?? ['w' => 480, 'h' => 270, 'horizon' => 112]);
$problems = $lintOnly[1] ?? here_lint_layout($L);
$W = (int)$L['w']; $H = (int)$L['h']; $hz = (int)($L['horizon'] ?? 0);
$file = 'scenes/' . here_layout_file($key);
$art = is_file(APP_ROOT . '/assets/img/' . $file) ? url('assets/img/' . $file) : '';
$cols = ['exits' => '#d33', 'spots' => '#36c', 'stand' => '#2a2', 'houses' => '#c80', 'pals' => '#a3a'];
page_header('Picture layouts', true);
?>
<?php admin_crumbs('here_layout.php'); ?>
<div class="center">
<h1>📍 Picture layouts</h1>
<p class="help">Slots never move: the art is drawn to match them. Drag a dot or type x / y, then Save. Saving overrides the shipped layout; Reset undoes it. Lookup for a place: <code>slug:&lt;slug&gt;</code>, then <code>&lt;kind&gt;-&lt;landscape&gt;</code>, then <code>&lt;kind&gt;</code>, then <code>generic</code>.</p>
<form method="get" class="inline"><label>Layout <select name="key"><?php foreach ($keys as $k): ?><option value="<?= e($k) ?>"<?= $k === $key ? ' selected' : '' ?>><?= e($k) ?><?= isset($shipped[$k]) ? '' : ' (new)' ?></option><?php endforeach; ?></select></label> <button class="btn small">Open</button></form>
<?php if ($problems): ?><div class="box notice"><b>Lint: <?= count($problems) ?> problem<?= count($problems) === 1 ? '' : 's' ?></b><ul><?php foreach ($problems as $p): ?><li><?= e($p) ?></li><?php endforeach; ?></ul></div>
<?php else: ?><p class="flash ok">Lint is clean.</p><?php endif; ?>
<form method="post" id="hereform"><?= csrf_field() ?><input type="hidden" name="key" value="<?= e($key) ?>">
<svg class="hereedit" id="hereedit" viewBox="0 0 <?= $W ?> <?= $H ?>" width="<?= $W ?>" height="<?= $H ?>" data-w="<?= $W ?>" data-h="<?= $H ?>" role="img" aria-label="Layout <?= e($key) ?>">
<?php if ($art): ?><image href="<?= e($art) ?>" x="0" y="0" width="<?= $W ?>" height="<?= $H ?>" image-rendering="pixelated"/>
<?php else: ?><rect x="0" y="0" width="<?= $W ?>" height="<?= max(1, $hz) ?>" fill="#bfe1ee"/><rect x="0" y="<?= $hz ?>" width="<?= $W ?>" height="<?= max(1, $H - $hz) ?>" fill="#9fc27a"/><?php endif; ?>
<line id="hz-line" x1="0" y1="<?= $hz ?>" x2="<?= $W ?>" y2="<?= $hz ?>" stroke="#5f7f4a" stroke-dasharray="4 3"/>
<?php foreach ($GROUPS as $g => $_): foreach ($L[$g] ?? [] as $i => $p): ?>
<g class="hdot" data-g="<?= $g ?>" data-i="<?= $i ?>" tabindex="0"><circle cx="<?= (int)$p['x'] ?>" cy="<?= (int)$p['y'] ?>" r="7" fill="<?= $cols[$g] ?>" stroke="#fff"/><text x="<?= (int)$p['x'] + 9 ?>" y="<?= (int)$p['y'] + 4 ?>" font-size="10" fill="<?= $cols[$g] ?>"><?= $i + 1 ?><?= e((string)($p['a'] ?? $p['k'] ?? '')) ?></text></g>
<?php endforeach; endforeach; ?>
</svg>
<p class="help"><?= $art ? 'Art: ' . e($file) : 'No art file yet (' . e($file) . '): a drawn sky and ground is shown.' ?> · size <input type="number" name="w" value="<?= $W ?>" min="64" max="4000" aria-label="Width"> × <input type="number" name="h" value="<?= $H ?>" min="64" max="4000" aria-label="Height"> · horizon y <input type="number" name="horizon" value="<?= $hz ?>" min="0" max="<?= $H ?>" aria-label="Horizon"></p>
<?php foreach ($GROUPS as $g => $title): $rows = $L[$g] ?? []; if (!$rows && !in_array($g, ['stand', 'spots', 'exits', 'houses', 'pals'], true)) continue; $rows[] = ['x' => '', 'y' => '']; ?>
<h3 class="hg-<?= $g ?>"><?= e($title) ?></h3>
<table class="heretab"><tr><?php if ($g === 'exits' || $g === 'spots'): ?><th><?= $g === 'exits' ? 'Anchor' : 'Name' ?></th><?php endif; ?><th>x</th><th>y</th><th>Remove</th></tr>
<?php foreach ($rows as $i => $p): $new = $p['x'] === ''; ?><tr data-g="<?= $g ?>" data-i="<?= $i ?>">
<?php if ($g === 'exits'): ?><td><select name="n[exits][<?= $i ?>]"><?php foreach (array_keys(HERE_ANCHORS) as $a): ?><option<?= ($p['a'] ?? '') === $a ? ' selected' : '' ?>><?= $a ?></option><?php endforeach; ?></select></td>
<?php elseif ($g === 'spots'): ?><td><input name="n[spots][<?= $i ?>]" value="<?= e((string)($p['k'] ?? '')) ?>" maxlength="24" aria-label="Spot name"></td><?php endif; ?>
<td><input type="number" name="x[<?= $g ?>][<?= $i ?>]" value="<?= $new ? '' : (int)$p['x'] ?>" aria-label="x"></td><td><input type="number" name="y[<?= $g ?>][<?= $i ?>]" value="<?= $new ? '' : (int)$p['y'] ?>" aria-label="y"></td>
<td><?= $new ? '<span class="muted">add a row: fill x and y</span>' : '<input type="checkbox" name="del[' . $g . '][' . $i . ']" value="1" aria-label="Remove">' ?></td></tr>
<?php endforeach; ?></table>
<?php endforeach; ?>
<p><button class="btn" name="do" value="save">💾 Save</button> <button class="btn alt" name="do" value="lint">🔍 Lint (no save)</button></p>
</form>
<div class="box"><form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="key" value="<?= e($key) ?>"><button class="btn alt" name="do" value="reset" data-confirm="Back to the shipped layout?">↩ Reset to shipped</button></form>
 <form method="post" class="inline"><?= csrf_field() ?><input type="hidden" name="key" value="<?= e($key) ?>"><label>Copy to new key <input name="newkey" placeholder="village-forest" maxlength="60"></label> <button class="btn small" name="do" value="copy">Copy</button></form></div>
</div>
<script src="<?= e(url('assets/hereedit.js?v=' . APP_VERSION)) ?>" defer></script>
<?php page_footer();

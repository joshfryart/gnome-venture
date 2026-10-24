<?php
declare(strict_types=1);
/** One editor for every game table described in includes/admin_resources.php */
require dirname(__DIR__) . '/includes/bootstrap.php';
require_once dirname(__DIR__) . '/includes/admin_resources.php'; // v1.6.3: once
require dirname(__DIR__) . '/includes/admin_helpers.php';
$me = require_admin();

$RES = admin_resources();
$r = (string)($_GET['r'] ?? '');
if (!isset($RES[$r])) {
    http_response_code(404);
    exit('Unknown section.');
}
$res = $RES[$r];
$table = $res['table'];          // from code, never from the user
$fields = $res['fields'];
$action = (string)($_GET['action'] ?? 'list');
$base = 'admin/crud.php?r=' . urlencode($r);

// ---------------------------------------------------------------- helpers
function f_label(string $name, array $def): string
{
    return $def['label'] ?? ucfirst(str_replace(['_id', '_'], ['', ' '], $name));
}

function fk_options(array $def): array
{
    static $cache = [];
    $key = $def['table'] . '.' . $def['show'];
    if (!isset($cache[$key])) {
        $cache[$key] = [];
        foreach (q('SELECT id, ' . $def['show'] . ' AS label FROM ' . $def['table'] . ' ORDER BY ' . $def['show'])->fetchAll() as $row) {
            $cache[$key][(int)$row['id']] = (string)$row['label'];
        }
    }
    return $cache[$key];
}

function show_value(string $col, $val, array $fields): string
{
    $def = $fields[$col] ?? null;
    if ($val === null || $val === '') {
        return '<span class="muted">—</span>';
    }
    if ($def && $def['type'] === 'fk') {
        $opts = fk_options($def);
        return e($opts[(int)$val] ?? ('#' . $val));
    }
    if (($def && $def['type'] === 'bool') || in_array($col, ['banned', 'published', 'open', 'active', 'edible'], true)) {
        return (int)$val ? '✔' : '<span class="muted">✘</span>';
    }
    if ($def && $def['type'] === 'select') {
        return e($def['options'][$val] ?? $val);
    }
    $s = (string)$val;
    return e(mb_strlen($s) > 60 ? mb_substr($s, 0, 57) . '…' : $s);
}

/** Validate submitted form values. Returns [cleanRow, errors]. */
function validate_input(array $fields, string $table, int $id): array
{
    $row = [];
    $errors = [];
    foreach ($fields as $name => $def) {
        $label = f_label($name, $def);
        $raw = $_POST['f'][$name] ?? '';
        if (!is_string($raw)) {
            $raw = '';
        }
        $raw = trim($raw);
        $req = !empty($def['required']);
        switch ($def['type']) {
            case 'bool':
                $row[$name] = isset($_POST['f'][$name]) ? 1 : 0;
                break;
            case 'int':
            case 'hour':
                if ($raw === '') {
                    if ($req) { $errors[] = "$label is required."; break; }
                    $raw = (string)($def['default'] ?? 0);
                }
                if (!preg_match('/^-?\d{1,10}$/', $raw)) { $errors[] = "$label must be a whole number."; break; }
                $n = (int)$raw;
                if (isset($def['min']) && $n < $def['min']) $errors[] = "$label must be at least {$def['min']}.";
                if (isset($def['max']) && $n > $def['max']) $errors[] = "$label must be at most {$def['max']}.";
                $row[$name] = $n;
                break;
            case 'select':
                if (!array_key_exists($raw, $def['options'])) { $errors[] = "Pick a valid $label."; break; }
                $row[$name] = $raw;
                break;
            case 'fk':
                if ($raw === '' || $raw === '0') {
                    if ($req) $errors[] = "$label is required.";
                    $row[$name] = null;
                    break;
                }
                if (!ctype_digit($raw) || !q_val('SELECT 1 FROM ' . $def['table'] . ' WHERE id = ?', [(int)$raw])) {
                    $errors[] = "$label doesn't exist.";
                    break;
                }
                $row[$name] = (int)$raw;
                break;
            case 'json':
                if ($raw === '') {
                    if ($req) $errors[] = "$label is required.";
                    $row[$name] = null;
                    break;
                }
                $decoded = json_decode($raw, true);
                if (!is_array($decoded)) { $errors[] = "$label is not valid JSON. Check your brackets, quotes and commas."; break; }
                $row[$name] = json_encode($decoded, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
                break;
            case 'slug':
                $src = trim((string)($_POST['f'][$def['from']] ?? ''));
                $slug = $raw !== '' ? strtolower($raw) : slugify($src);
                if (!preg_match('/^[a-z0-9-]{1,80}$/', $slug)) { $errors[] = "$label: only lowercase letters, numbers and dashes."; break; }
                if (q_val("SELECT 1 FROM $table WHERE $name = ? AND id <> ?", [$slug, $id])) { $errors[] = "$label \"$slug\" is already used."; break; }
                $row[$name] = $slug;
                break;
            case 'textarea':
                if ($req && $raw === '') $errors[] = "$label is required.";
                if (strlen($raw) > 60000) $errors[] = "$label is too long.";
                $row[$name] = $raw === '' ? null : str_replace("\r\n", "\n", (string)($_POST['f'][$name] ?? ''));
                break;
            default: // text
                if ($req && $raw === '') $errors[] = "$label is required.";
                $max = $def['max'] ?? 255;
                if (mb_strlen($raw) > $max) $errors[] = "$label must be $max characters or fewer.";
                $row[$name] = $raw !== '' ? $raw : (isset($def['default']) ? (string)$def['default'] : null);
        }
    }
    return [$row, $errors];
}

function hook_values(array $map): array
{
    $out = [];
    foreach ($map as $col => $v) {
        $out[$col] = $v === '@now' ? now() : ($v === '@user' ? (int)current_user()['id'] : $v);
    }
    return $out;
}

/** Rows elsewhere that point at this record: [label, table, column, count, cascade?] */
function references(array $RES, string $r, string $table, int $id): array
{
    $refs = [];
    $children = $RES[$r]['children'] ?? [];
    foreach ($RES as $otherKey => $other) {
        foreach ($other['fields'] as $col => $def) {
            if ($def['type'] === 'fk' && $def['table'] === $table) {
                $n = (int)q_val('SELECT COUNT(*) FROM ' . $other['table'] . " WHERE $col = ?", [$id]);
                if ($n) {
                    $cascade = ($children[$otherKey] ?? null) === $col;
                    $refs[] = [$other['label'] . ' (' . f_label($col, $def) . ')', $other['table'], $col, $n, $cascade];
                }
            }
        }
    }
    foreach ($RES[$r]['extra_refs'] ?? [] as [$t, $col]) {
        $n = (int)q_val("SELECT COUNT(*) FROM $t WHERE $col = ?", [$id]);
        if ($n) {
            $refs[] = [str_replace('_', ' ', $t), $t, $col, $n, false];
        }
    }
    // v1.2.2: references by slug (item rewards in templates/chapters, recipe ingredients)
    if (!empty($RES[$r]['slug_refs'])) {
        $slug = (string)q_val("SELECT slug FROM $table WHERE id = ?", [$id]);
        if ($slug !== '' && preg_match('/^[a-z0-9-]+$/', $slug)) {
            foreach ($RES[$r]['slug_refs'] as [$t, $col, $mode]) {
                if ($mode === 'eq') {
                    $n = (int)q_val("SELECT COUNT(*) FROM $t WHERE $col = ?", [$slug]);
                } elseif ($mode === 'prefix') {
                    $n = (int)q_val("SELECT COUNT(*) FROM $t WHERE $col = ? OR $col LIKE ?", [$slug, $slug . ':%']);
                } else {
                    $n = (int)q_val("SELECT COUNT(*) FROM $t WHERE $col LIKE ?", ['%"' . $slug . '"%']);
                }
                if ($n) $refs[] = [str_replace('_', ' ', $t) . ' (by slug)', $t, $col, $n, false];
            }
        }
    }
    return $refs;
}

// ---------------------------------------------------------------- POST: save / delete
if (is_post()) {
    csrf_check();
    $id = (int)($_POST['id'] ?? 0);
    $do = (string)($_POST['do'] ?? '');

    // v2.0.48: bulk-set every route's travel wait time from the Routes admin section.
    if ($do === 'bulk_route_minutes') {
        if ($r !== 'routes') { http_response_code(400); exit('This action is only available for routes.'); }
        $rawMinutes = trim((string)($_POST['minutes'] ?? ''));
        if (!preg_match('/^\\d{1,10}$/', $rawMinutes)) {
            flash('Wait time must be a whole number of minutes (0 or more).', 'err');
            redirect($base);
        }
        $minutes = (int)$rawMinutes;
        $count = (int)q_val('SELECT COUNT(*) FROM routes');
        q('UPDATE routes SET minutes = ?', [$minutes]);
        admin_log('bulk_route_minutes', 'routes', json_encode(['minutes' => $minutes, 'routes' => $count], JSON_UNESCAPED_UNICODE));
        flash('Set the wait time to ' . $minutes . ' minute' . ($minutes === 1 ? '' : 's') . ' for all ' . $count . ' routes.');
        redirect($base);
    }

    if ($do === 'fresh_start') {   // v0.9.5.2: admin only (require_admin above), CSRF checked above, typed username required
        $target = $r === 'users' ? q_one('SELECT id, username FROM users WHERE id = ?', [$id]) : null;
        if (!$target) {
            flash('No such player.', 'err');
            redirect($base);
        }
        if (!hash_equals((string)$target['username'], trim((string)($_POST['confirm_name'] ?? '')))) {
            flash('Fresh start cancelled: type the username exactly to confirm.', 'err');
            redirect($base . '&action=edit&id=' . $id);
        }
        require_once dirname(__DIR__) . '/includes/fresh_start.php';
        [$ok, $info] = fresh_start_player((int)$target['id']);
        admin_log('fresh_start', 'users#' . $target['id'], ($ok && is_array($info)) ? json_encode(array_filter($info), JSON_UNESCAPED_UNICODE) : (string)$info);
        flash($ok ? '🌱 Fresh start done for ' . $target['username'] . '. They begin again at the welcome flow.' : (string)$info, $ok ? 'ok' : 'err');
        redirect($base . '&action=edit&id=' . $id);
    }

    if ($do === 'delete') {
        if (!empty($res['no_delete'])) {
            flash('These can’t be deleted here.', 'err');
            redirect($base);
        }
        $existing = q_one("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$existing) {
            flash('Already gone.', 'err');
            redirect($base);
        }
        $refs = references($RES, $r, $table, $id);
        $blocking = array_filter($refs, fn($x) => !$x[4]);
        if ($blocking) {
            $msg = 'Can’t delete: still used by ' . implode(', ', array_map(fn($x) => $x[3] . ' × ' . $x[0], $blocking)) . '.';
            flash($msg, 'err');
            redirect($base . '&action=edit&id=' . $id);
        }
        db()->beginTransaction();
        foreach ($refs as $ref) {
            q('DELETE FROM ' . $ref[1] . ' WHERE ' . $ref[2] . ' = ?', [$id]);
        }
        q("DELETE FROM $table WHERE id = ?", [$id]);
        db()->commit();
        admin_log('delete', "$r#$id", json_encode($existing, JSON_UNESCAPED_UNICODE));
        flash('Deleted.');
        redirect($base);
    }

    // save
    if ($id === 0 && !empty($res['no_create'])) {
        flash('Can’t create these here.', 'err');
        redirect($base);
    }
    $existing = $id ? q_one("SELECT * FROM $table WHERE id = ?", [$id]) : null;
    if ($id && !$existing) {
        flash('That record no longer exists.', 'err');
        redirect($base);
    }
    [$row, $errors] = validate_input($fields, $table, $id);

    // Don't let an admin lock themselves out.
    if ($r === 'users' && $id === (int)$me['id']) {
        if (($row['role'] ?? 'admin') !== 'admin') $errors[] = 'You can’t remove your own admin role.';
        if (!empty($row['banned'])) $errors[] = 'You can’t ban yourself.';
    }
    if ($r === 'plants' && isset($row['yield_min'], $row['yield_max']) && $row['yield_min'] > $row['yield_max']) {
        $errors[] = 'Yield min can’t be bigger than yield max.';
    }
    if ($r === 'shop_stock' && isset($row['price_min'], $row['price_max']) && $row['price_min'] > $row['price_max']) {
        $errors[] = 'Price min can’t be bigger than price max.';
    }

    if (!$errors) {
        $row += hook_values($res['on_save'] ?? []);
        if ($id) {
            $changes = [];
            foreach ($row as $k => $v) {
                if ((string)($existing[$k] ?? '') !== (string)$v) {
                    $changes[$k] = [$existing[$k] ?? null, $v];
                }
            }
            db_update($table, $row, 'id = ?', [$id]);
            admin_log('edit', "$r#$id", json_encode($changes, JSON_UNESCAPED_UNICODE));
        } else {
            $row += hook_values($res['on_create'] ?? []);
            $id = db_insert($table, $row);
            admin_log('create', "$r#$id", '');
        }
        flash('Saved.');
        redirect($base . '&action=edit&id=' . $id);
    }
    $_SESSION['form_errors'] = $errors;
    $_SESSION['form_values'] = $_POST['f'] ?? [];
    redirect($base . '&action=' . ($id ? 'edit&id=' . $id : 'new'));
}

// ---------------------------------------------------------------- GET: edit / new
if ($action === 'edit' || $action === 'new') {
    $id = (int)($_GET['id'] ?? 0);
    $record = [];
    if ($action === 'edit') {
        $record = q_one("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$record) {
            flash('Not found.', 'err');
            redirect($base);
        }
    } else {
        if (!empty($res['no_create'])) redirect($base);
        foreach ($fields as $name => $def) {
            if (isset($def['default'])) $record[$name] = $def['default'];
            if ($def['type'] === 'fk' && isset($_GET[$name])) $record[$name] = (int)$_GET[$name];   // prefill from a parent page
        }
    }
    $errors = $_SESSION['form_errors'] ?? [];
    if (isset($_SESSION['form_values'])) {
        $record = array_merge($record, $_SESSION['form_values']);
    }
    unset($_SESSION['form_errors'], $_SESSION['form_values']);

    $title = $action === 'edit' ? 'Edit: ' . ($record[$res['title_col']] ?? '#' . $id) : 'New ' . rtrim($res['label'], 's');
    page_header($title, true);
    admin_crumbs('r:' . $r, $action === 'edit' ? 'Edit' : 'New');   // v1.6.3
    echo '<h1>' . e($title) . '</h1>';
    foreach ($errors as $err) echo '<div class="flash err">' . e($err) . '</div>';

    if (!empty($res['show']) && $record) {
        echo '<table class="kv">';
        foreach ($res['show'] as $c) echo '<tr><th>' . e(f_label($c, [])) . '</th><td>' . e($record[$c] ?? '—') . '</td></tr>';
        echo '</table>';
    }
    ?>
    <form method="post" action="<?= e(url($base)) ?>" class="form box">
      <?= csrf_field() ?>
      <input type="hidden" name="do" value="save">
      <input type="hidden" name="id" value="<?= (int)($record['id'] ?? 0) ?>">
      <?php foreach ($fields as $name => $def):
          $val = $record[$name] ?? '';
          $n = 'f[' . e($name) . ']'; ?>
        <?php if ($def['type'] === 'bool'): ?>
          <label class="check"><input type="checkbox" name="<?= $n ?>" value="1" <?= (int)$val ? 'checked' : '' ?>> <?= e(f_label($name, $def)) ?></label>
        <?php else: ?>
          <label><?= e(f_label($name, $def)) ?><?= !empty($def['required']) ? ' *' : '' ?>
          <?php if ($def['type'] === 'textarea' || $def['type'] === 'json'): ?>
            <?php if (!empty($def['bbcode'])): ?>
              <textarea name="<?= $n ?>" rows="12" data-bbcode data-csrf="<?= e(csrf_token()) ?>" data-preview="<?= e(url('admin/preview.php')) ?>" data-upload="<?= e(url('admin/upload.php')) ?>"><?= e($val) ?></textarea>
            <?php else: ?>
            <textarea name="<?= $n ?>" rows="<?= $def['type'] === 'json' ? 3 : 6 ?>"><?= e($val) ?></textarea>
            <?php endif; ?>
          <?php elseif ($def['type'] === 'select'): ?>
            <select name="<?= $n ?>"><?php foreach ($def['options'] as $k => $lab): ?>
              <option value="<?= e($k) ?>" <?= (string)$val === (string)$k ? 'selected' : '' ?>><?= e($lab) ?></option><?php endforeach; ?></select>
          <?php elseif ($def['type'] === 'fk'): ?>
            <select name="<?= $n ?>"><option value="">— none —</option><?php foreach (fk_options($def) as $k => $lab): ?>
              <option value="<?= $k ?>" <?= (string)$val === (string)$k ? 'selected' : '' ?>><?= e($lab) ?></option><?php endforeach; ?></select>
          <?php elseif ($def['type'] === 'int' || $def['type'] === 'hour'): ?>
            <input type="number" name="<?= $n ?>" value="<?= e($val) ?>" <?= isset($def['min']) ? 'min="' . (int)$def['min'] . '"' : '' ?> <?= isset($def['max']) ? 'max="' . (int)$def['max'] . '"' : '' ?>>
          <?php else: ?>
            <input name="<?= $n ?>" value="<?= e($val) ?>" maxlength="<?= (int)($def['max'] ?? 255) ?>">
          <?php endif; ?>
          </label>
        <?php endif; ?>
        <?php if (!empty($def['help'])): ?><p class="help"><?= e($def['help']) ?></p><?php endif; ?>
      <?php endforeach; ?>
      <button class="btn">Save</button>
    </form>
    <?php
    if ($action === 'edit') {
        // Related lists (e.g. an NPC's schedule, a shop's stock)
        foreach ($res['children'] ?? [] as $childKey => $col) {
            $child = $RES[$childKey];
            $n = (int)q_val('SELECT COUNT(*) FROM ' . $child['table'] . " WHERE $col = ?", [$id]);
            echo '<div class="box"><h3>' . e($child['label']) . " ($n)</h3>";
            echo '<a class="btn small" href="' . e(url('admin/crud.php?r=' . $childKey . '&' . $col . '=' . $id)) . '">View</a> ';
            echo '<a class="btn small" href="' . e(url('admin/crud.php?r=' . $childKey . '&action=new&' . $col . '=' . $id)) . '">Add</a></div>';
        }
        if ($r === 'shops') {
            render_shop_coverage($id);
        }
        if ($r === 'users') {
            echo '<div class="box"><h3>Satchel</h3>';
            $items = q('SELECT i.name, ui.qty FROM user_items ui JOIN items i ON i.id = ui.item_id WHERE ui.user_id = ? ORDER BY i.name', [$id])->fetchAll();
            echo $items ? '<ul>' . implode('', array_map(fn($x) => '<li>' . e($x['name']) . ' × ' . (int)$x['qty'] . '</li>', $items)) . '</ul>' : '<p class="muted">Empty.</p>';
            echo '<a class="btn small" href="' . e(url('admin/grant.php?user_id=' . $id)) . '">Give / take items</a></div>';
        }
        if ($r === 'users') {   // v0.9.5.2 admin-only; deliberately not offered to players anywhere
            ?>
            <form method="post" action="<?= e(url($base)) ?>" class="box danger" data-confirm="Wipe ALL of <?= e($record['username']) ?>'s progress and start them again at level 1? This cannot be undone.">
              <?= csrf_field() ?><input type="hidden" name="do" value="fresh_start"><input type="hidden" name="id" value="<?= $id ?>">
              <h3>🌱 Fresh start</h3>
              <p class="help">Back to level 1: every garden, item, recipe, Almanac page, quest, calling, trade and score is deleted and the gnome goes through the welcome flow again.
                Kept: username, email, password, role, ban state, feedback, reports and the admin log. Their open trades, stall and jobs are cancelled.</p>
              <label>Type <b><?= e($record['username']) ?></b> to confirm <input name="confirm_name" autocomplete="off" required></label>
              <button class="btn red">Fresh start</button>
            </form>
            <?php
        }
        if (empty($res['no_delete'])) {
            $refs = references($RES, $r, $table, $id);
            ?>
            <form method="post" action="<?= e(url($base)) ?>" class="box danger" data-confirm="Delete this for good?">
              <?= csrf_field() ?><input type="hidden" name="do" value="delete"><input type="hidden" name="id" value="<?= $id ?>">
              <h3>Delete</h3>
              <?php foreach ($refs as $ref): ?>
                <p class="help"><?= $ref[4] ? 'Will also delete' : 'Blocked by' ?> <?= (int)$ref[3] ?> × <?= e($ref[0]) ?></p>
              <?php endforeach; ?>
              <button class="btn red">Delete</button>
            </form>
            <?php
        }
    }
    page_footer();
    exit;
}

// ---------------------------------------------------------------- GET: list
$where = [];
$params = [];
$qstr = trim((string)($_GET['q'] ?? ''));
if ($qstr !== '' && !empty($res['search'])) {
    $or = [];
    foreach ($res['search'] as $c) {
        $or[] = "$c LIKE ?";
        $params[] = '%' . $qstr . '%';
    }
    $where[] = '(' . implode(' OR ', $or) . ')';
}
$activeFilters = [];
foreach (array_merge($res['filters'] ?? [], array_values($res['children'] ?? [])) as $c) {
    if (isset($_GET[$c]) && $_GET[$c] !== '' && (isset($fields[$c]) || in_array($c, $res['filters'] ?? [], true))) {
        $where[] = "$c = ?";
        $params[] = (string)$_GET[$c];
        $activeFilters[$c] = (string)$_GET[$c];
    }
}
$wsql = $where ? ' WHERE ' . implode(' AND ', $where) : '';
$total = (int)q_val("SELECT COUNT(*) FROM $table$wsql", $params);
$per = 50;
$page = max(1, (int)($_GET['page'] ?? 1));
$offset = ($page - 1) * $per;
$order = $res['order'] ?? 'id DESC';
$rows = q("SELECT * FROM $table$wsql ORDER BY $order LIMIT $per OFFSET $offset", $params)->fetchAll();

page_header($res['label'], true);
admin_crumbs('r:' . $r);   // v1.6.3
?>
<h1><?= e($res['label']) ?> <small class="muted">(<?= $total ?>)</small></h1>
<div class="toolbar">
  <?php if (empty($res['no_create'])):
      $prefill = '';
      foreach ($activeFilters as $c => $v) if (($fields[$c]['type'] ?? '') === 'fk') $prefill .= '&' . urlencode($c) . '=' . urlencode($v); ?>
    <a class="btn" href="<?= e(url($base . '&action=new' . $prefill)) ?>">+ New</a>
  <?php endif; ?>
  <form method="get" action="<?= e(url('admin/crud.php')) ?>" class="inline">
    <input type="hidden" name="r" value="<?= e($r) ?>">
    <?php if (!empty($res['search'])): ?><input name="q" value="<?= e($qstr) ?>" placeholder="Search…"><?php endif; ?>
    <?php foreach ($res['filters'] ?? [] as $c): $def = $fields[$c] ?? ['type' => 'text']; ?>
      <select name="<?= e($c) ?>"><option value="">All <?= e(strtolower(f_label($c, $def))) ?></option>
        <?php $opts = match ($def['type']) {
            'fk' => fk_options($def),
            'select' => $def['options'],
            'bool' => ['1' => 'Yes', '0' => 'No'],
            default => (function () use ($res, $c) {   // plain text: the values already in the table
                $vals = q('SELECT DISTINCT ' . $c . ' FROM ' . $res['table'] . ' ORDER BY ' . $c . ' LIMIT 200')->fetchAll(PDO::FETCH_COLUMN);
                return array_combine(array_map('strval', $vals), array_map('strval', $vals)) ?: [];
            })(),
        };
        foreach ($opts as $k => $lab): ?>
          <option value="<?= e($k) ?>" <?= ($activeFilters[$c] ?? null) === (string)$k ? 'selected' : '' ?>><?= e($lab) ?></option>
        <?php endforeach; ?></select>
    <?php endforeach; ?>
    <button class="btn small">Filter</button>
    <?php if ($activeFilters || $qstr !== ''): ?><a href="<?= e(url($base)) ?>">clear</a><?php endif; ?>
  </form>
</div>
<?php if ($r === 'routes'): ?>
  <form method="post" action="<?= e(url($base)) ?>" class="box form" data-confirm="Replace the wait time on every route with the number you entered? Individual route wait times will be overwritten.">
    <?= csrf_field() ?><input type="hidden" name="do" value="bulk_route_minutes">
    <h2>All routes: set wait time</h2>
    <p class="help">Set the travel wait time in real minutes for every route at once. This overwrites each route's current wait time; you can still edit individual routes afterwards. Use 0 for instant travel.</p>
    <label>Wait time for every route (minutes)
      <input type="number" name="minutes" min="0" max="2147483647" step="1" required value="<?= e((string)q_val('SELECT minutes FROM routes ORDER BY id LIMIT 1')) ?>">
    </label>
    <button class="btn">Apply to all routes</button>
  </form>
<?php endif; ?>

<table class="grid">
  <tr><?php foreach ($res['list'] as $c): ?><th><?= e(f_label($c, $fields[$c] ?? [])) ?></th><?php endforeach; ?><th></th></tr>
  <?php foreach ($rows as $row): ?>
    <tr><?php foreach ($res['list'] as $c): ?><td><?= show_value($c, $row[$c] ?? null, $fields) ?></td><?php endforeach; ?>
      <td><a href="<?= e(url($base . '&action=edit&id=' . (int)$row['id'])) ?>">Edit</a></td></tr>
  <?php endforeach; ?>
  <?php if (!$rows): ?><tr><td colspan="99" class="muted">Nothing here yet.</td></tr><?php endif; ?>
</table>
<?php if ($total > $per):
    $qs = $_GET; ?>
  <p class="pager">
    <?php for ($p = 1; $p <= (int)ceil($total / $per); $p++): $qs['page'] = $p; ?>
      <?= $p === $page ? "<strong>$p</strong>" : '<a href="' . e(url('admin/crud.php?' . http_build_query($qs))) . '">' . $p . '</a>' ?>
    <?php endfor; ?>
  </p>
<?php endif;
page_footer();

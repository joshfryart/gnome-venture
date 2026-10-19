<?php
declare(strict_types=1);
/**
 * v0.9.8: picture uploads (Admin → Images). Files are matched to things by name, checked, re-encoded as PNG and saved under uploads/.
 *   {slug}.png                items            -> uploads/items/{slug}.png     (items.image is set)
 *   creature-{slug}.png       creatures        -> uploads/creatures/{slug}.png
 *   npc-{slug}.png            NPC portraits    -> uploads/npcs/{slug}.png      (npcs.image is set; 400×500)
 *   {building}-{level}.png    building at a level   -> uploads/buildings/{building}-{level}.png
 *   {building}-{skin}.png     building looks   -> uploads/skins/{building}-{skin}.png
 *   nav-{slug}.png            menu icons (see NAV_ICONS) -> uploads/nav/{slug}.png
 *   {slug}-{shape}.png        fence/wall/hedge pieces (end straight corner tee cross gate) -> uploads/yard/{slug}-{shape}.png
 * Names never come from the upload itself, only from a matched slug, so nothing can be written outside those folders.
 */
require_once __DIR__ . '/items.php';
require_once __DIR__ . '/yard.php';

const ART_EXTS = ['png', 'jpg', 'jpeg', 'webp'];

/** Work out where a file called $name goes. ['kind','dest','set'=>[table,id]|null,'label'] or null when nothing matches. */
function art_match(string $name): ?array
{
    $base = strtolower((string)pathinfo($name, PATHINFO_FILENAME));
    if (!preg_match('/^[a-z0-9][a-z0-9_-]{0,100}$/', $base)) return null;
    if (str_starts_with($base, 'nav-') && isset(NAV_ICONS[substr($base, 4)])) {   // menu icons icons
        return ['kind' => 'nav', 'dest' => 'uploads/nav/' . substr($base, 4) . '.png', 'set' => null, 'label' => 'menu icon ' . substr($base, 4)];
    }
    if (str_starts_with($base, 'creature-') && ($id = q_val('SELECT id FROM creatures WHERE slug = ?', [substr($base, 9)]))) {
        return ['kind' => 'creature', 'dest' => 'uploads/creatures/' . substr($base, 9) . '.png', 'set' => null, 'label' => 'creature ' . substr($base, 9)];
    }
    if (str_starts_with($base, 'npc-') && ($id = q_val('SELECT id FROM npcs WHERE slug = ?', [substr($base, 4)]))) {
        return ['kind' => 'npc', 'dest' => 'uploads/npcs/' . substr($base, 4) . '.png', 'set' => ['npcs', (int)$id], 'label' => 'NPC ' . substr($base, 4)];
    }
    if ($id = q_val('SELECT id FROM items WHERE slug = ?', [$base])) {
        return ['kind' => 'item', 'dest' => 'uploads/items/' . $base . '.png', 'set' => ['items', (int)$id], 'label' => 'item ' . $base];
    }
    if (preg_match('/^([a-z_]+)-(\d)$/', $base, $m) && isset(BUILDINGS[$m[1]]) && (int)$m[2] >= 1 && (int)$m[2] <= 3) {
        return ['kind' => 'building', 'dest' => 'uploads/buildings/' . $base . '.png', 'set' => null, 'label' => 'building ' . $m[1] . ' level ' . $m[2]];
    }
    if (preg_match('/^([a-z_]+)-([a-z]+)$/', $base, $m) && in_array($m[2], BUILDING_SKINS[$m[1]] ?? [], true)) {
        return ['kind' => 'skin', 'dest' => 'uploads/skins/' . $base . '.png', 'set' => null, 'label' => 'building look ' . $m[1] . ' ' . $m[2]];
    }
    if (preg_match('/^(.+)-(' . implode('|', array_merge(YARD_JOIN_SHAPES, ['gate'])) . ')$/', $base, $m) && ($id = q_val('SELECT id FROM items WHERE slug = ?', [$m[1]]))) {
        return ['kind' => 'piece', 'dest' => 'uploads/yard/' . $base . '.png', 'set' => ['items', (int)$id], 'setpath' => 'uploads/yard/' . $m[1] . '-{shape}.png',
            'label' => 'fence piece ' . $m[1] . ' ' . $m[2]];
    }
    return null;
}

/** Check one image (raw bytes) and save it for $name. Returns [status, message]: status is matched, replaced, unmatched or rejected. */
function art_save(string $name, string $bytes): array
{
    $ext = strtolower((string)pathinfo($name, PATHINFO_EXTENSION));
    if (!in_array($ext, ART_EXTS, true)) return ['rejected', 'not a PNG, JPG or WebP file'];
    $max = max(50, (int)setting('image_max_kb')) * 1024;
    if (strlen($bytes) > $max) return ['rejected', 'bigger than ' . round($max / 1024) . ' KB'];
    $m = art_match($name);
    if (!$m) return ['unmatched', 'no item, creature, NPC or building has that name'];
    $mime = (string)(new finfo(FILEINFO_MIME_TYPE))->buffer($bytes);
    $types = ['image/png', 'image/jpeg', 'image/webp'];
    $info = @getimagesizefromstring($bytes);
    if (!in_array($mime, $types, true) || !$info || ($info['mime'] ?? '') !== $mime) return ['rejected', 'not a real PNG, JPG or WebP image'];
    if ($info[0] < 1 || $info[1] < 1 || $info[0] > 4000 || $info[1] > 4000) return ['rejected', 'too big (4000 × 4000 pixels at most)'];
    if (!function_exists('imagecreatefromstring') || !function_exists('imagepng')) return ['rejected', 'this server has no image library (GD) to check the picture'];
    if ($mime === 'image/webp' && !function_exists('imagecreatefromwebp')) return ['rejected', 'this server can’t read WebP; use PNG'];
    $im = @imagecreatefromstring($bytes);
    if (!$im) return ['rejected', 'the picture is damaged'];
    imagealphablending($im, false); imagesavealpha($im, true);
    $dest = APP_ROOT . '/' . $m['dest'];
    $dir = dirname($dest);
    if (!is_dir($dir) && !@mkdir($dir, 0755, true)) { imagedestroy($im); return ['rejected', 'the uploads folder can’t be made']; }
    art_guard_uploads();
    $existed = is_file($dest);
    $tmp = $dir . '/.up-' . bin2hex(random_bytes(6)) . '.tmp';
    $ok = @imagepng($im, $tmp, 9);   // re-encoded: nothing but pixels survives
    imagedestroy($im);
    if (!$ok || !@rename($tmp, $dest)) { @unlink($tmp); return ['rejected', 'couldn’t save it (is uploads/ writable?)']; }
    @chmod($dest, 0644);
    if ($m['set']) {
        [$tbl, $id] = $m['set'];
        q("UPDATE $tbl SET image = ? WHERE id = ?", [$m['setpath'] ?? $m['dest'], $id]);
    }
    return [$existed ? 'replaced' : 'matched', $m['label']];
}

/** Make sure nothing in uploads/ can ever be run as a script. */
function art_guard_uploads(): void
{
    $f = APP_ROOT . '/uploads/.htaccess';
    if (!is_file($f)) @file_put_contents($f, "# Pictures only: never run anything from here\n<FilesMatch \"\\.(php|phtml|phar|pl|py|cgi)$\">\n  Require all denied\n</FilesMatch>\nOptions -ExecCGI\nRemoveHandler .php .phtml\n");
}

/** Run a whole upload: $_FILES['pics'] (many files, or one .zip). Returns rows [file, status, message]. */
function art_process_upload(array $files): array
{
    $rows = [];
    $n = is_array($files['name'] ?? null) ? count($files['name']) : 0;
    for ($i = 0; $i < min($n, 200); $i++) {
        $name = (string)$files['name'][$i]; $tmp = (string)$files['tmp_name'][$i]; $err = (int)$files['error'][$i];
        if ($err === UPLOAD_ERR_NO_FILE) continue;
        if ($err !== UPLOAD_ERR_OK) { $rows[] = [$name, 'rejected', $err === UPLOAD_ERR_INI_SIZE || $err === UPLOAD_ERR_FORM_SIZE ? 'bigger than the server’s upload limit' : 'the upload failed']; continue; }
        if (!is_uploaded_file($tmp)) { $rows[] = [$name, 'rejected', 'not an upload']; continue; }
        if (strtolower((string)pathinfo($name, PATHINFO_EXTENSION)) === 'zip') { array_push($rows, ...art_process_zip($tmp)); continue; }
        $rows[] = array_merge([$name], art_save(basename($name), (string)@file_get_contents($tmp, false, null, 0, 16 * 1024 * 1024)));
    }
    return $rows;
}

function art_process_zip(string $path): array
{
    $rows = [];
    if (!class_exists('ZipArchive')) return [['(zip)', 'rejected', 'this server can’t open zip files; upload the pictures one by one']];
    $z = new ZipArchive();
    if ($z->open($path) !== true) return [['(zip)', 'rejected', 'not a readable zip file']];
    $max = max(50, (int)setting('image_max_kb')) * 1024;
    $total = 0;
    for ($i = 0; $i < min($z->numFiles, 500); $i++) {
        $st = $z->statIndex($i);
        $nm = (string)($st['name'] ?? '');
        if ($nm === '' || str_ends_with($nm, '/') || str_starts_with($nm, '__MACOSX/') || str_starts_with(basename($nm), '.')) continue;
        if (str_contains($nm, '..') || str_starts_with($nm, '/') || str_contains($nm, '\\') || str_contains($nm, "\0")) { $rows[] = [$nm, 'rejected', 'unsafe path in the zip']; continue; }
        if (!in_array(strtolower((string)pathinfo($nm, PATHINFO_EXTENSION)), ART_EXTS, true)) continue;   // skipped quietly: not a picture
        $size = (int)($st['size'] ?? 0);
        $total += $size;
        if ($size > $max) { $rows[] = [$nm, 'rejected', 'bigger than ' . round($max / 1024) . ' KB']; continue; }
        if ($total > 64 * 1024 * 1024) { $rows[] = [$nm, 'rejected', 'the zip holds too much (64 MB of pictures at most)']; break; }
        $bytes = $z->getFromIndex($i);
        $rows[] = array_merge([$nm], $bytes === false ? ['rejected', 'couldn’t read it'] : art_save(basename($nm), $bytes));
    }
    $z->close();
    return $rows ?: [['(zip)', 'unmatched', 'no pictures found inside']];
}

/** Does this item have a picture that will show? (shape pieces count when their straight piece exists) */
function art_item_has(array $it): bool
{
    $img = trim((string)($it['image'] ?? ''));
    return $img !== '' && art_path(str_replace('{shape}', 'straight', $img)) !== '';
}

/** Missing-art counts per category and the most-wanted items without a picture. */
function art_progress(int $top = 25): array
{
    $cats = [];
    $miss = [];
    $items = q('SELECT i.id, i.name, i.slug, i.category, i.image, i.rarity,
                (SELECT COUNT(*) FROM user_items ui WHERE ui.item_id = i.id) + 3 * (SELECT COUNT(*) FROM shop_stock st WHERE st.item_id = i.id) AS want
                FROM items i ORDER BY i.category, i.name')->fetchAll();
    foreach ($items as $it) {
        $c = 'Items: ' . $it['category'];
        $cats[$c] ??= [0, 0, 0];
        $cats[$c][0]++;
        if (art_item_has($it)) $cats[$c][1]++;
        else {   // v1.5.2: a placeholder still counts as missing (real art only counts as "with a picture")
            $it['ph'] = ph_path((string)$it['slug']) !== '';
            if ($it['ph']) $cats[$c][2]++;
            $miss[] = $it;
        }
    }
    usort($miss, fn($a, $b) => [$b['want'], $a['rarity']] <=> [$a['want'], $b['rarity']]);
    // v1.5.2: [total, with real art, of the missing ones: drawn as a placeholder]
    $cats['Creatures'] = [0, 0, 0];
    foreach (q('SELECT slug FROM creatures')->fetchAll(PDO::FETCH_COLUMN) as $s) {
        $cats['Creatures'][0]++;
        if (creature_image((string)$s) !== '') $cats['Creatures'][1]++; elseif (ph_path('creature-' . $s) !== '') $cats['Creatures'][2]++;
    }
    $cats['Menu icons'] = [0, 0, 0];   // menu icons
    foreach (array_keys(NAV_ICONS) as $s) {
        $cats['Menu icons'][0]++;
        if (art_path('uploads/nav/' . $s . '.png') !== '') $cats['Menu icons'][1]++; elseif (ph_path('nav-' . $s) !== '') $cats['Menu icons'][2]++;
    }
    $cats['NPC portraits'] = [0, 0, 0];
    foreach (q('SELECT image, slug FROM npcs')->fetchAll() as $n) {
        $cats['NPC portraits'][0]++;
        if (art_path(trim((string)$n['image'])) !== '') $cats['NPC portraits'][1]++; elseif (ph_path('npc-' . $n['slug']) !== '') $cats['NPC portraits'][2]++;
    }
    $cats['Buildings (per level, 1-3)'] = [0, 0, 0];
    $cats['Building looks'] = [0, 0, 0];
    foreach (array_keys(BUILDINGS) as $b) {
        for ($l = 1; $l <= 3; $l++) {
            $cats['Buildings (per level, 1-3)'][0]++;
            if (building_image($b, $l) !== '') $cats['Buildings (per level, 1-3)'][1]++; elseif (ph_path($b . '-' . $l) !== '') $cats['Buildings (per level, 1-3)'][2]++;
        }
        foreach (BUILDING_SKINS[$b] ?? [] as $sk) {
            $cats['Building looks'][0]++;
            if (skin_image($b, $sk) !== '') $cats['Building looks'][1]++; elseif (ph_path($b . '-' . $sk) !== '') $cats['Building looks'][2]++;
        }
    }
    return ['cats' => $cats, 'missing' => array_slice($miss, 0, $top), 'missing_total' => count($miss)];
}

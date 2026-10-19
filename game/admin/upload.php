<?php
declare(strict_types=1);
// Image upload for news and pages (v0.7.18). Admins only. Returns JSON for the editor, or redirects for the plain form.
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/admin_helpers.php';
require_admin();
if (!is_post()) { http_response_code(405); exit; }
csrf_check();
$json = ($_POST['ajax'] ?? '') === '1';
$fail = function (string $msg) use ($json) {
    if ($json) { header('Content-Type: application/json'); echo json_encode(['ok' => false, 'error' => $msg]); exit; }
    flash($msg, 'err');
    redirect('admin/tools.php#images');
};
$f = $_FILES['image'] ?? null;
if (!$f || !is_array($f) || ($f['error'] ?? UPLOAD_ERR_NO_FILE) !== UPLOAD_ERR_OK || !is_uploaded_file((string)$f['tmp_name'])) $fail('Pick an image to upload.');
if ((int)$f['size'] > 2 * 1024 * 1024) $fail('Images can be up to 2 MB.');
// Check what the file really is, not what its name says
$types = ['image/png' => 'png', 'image/jpeg' => 'jpg', 'image/gif' => 'gif', 'image/webp' => 'webp'];
$mime = (string)(new finfo(FILEINFO_MIME_TYPE))->file((string)$f['tmp_name']);
$info = @getimagesize((string)$f['tmp_name']);
if (!isset($types[$mime]) || !$info || ($info['mime'] ?? '') !== $mime) $fail('That isn’t a PNG, JPEG, GIF or WebP image.');
if ($info[0] > 4000 || $info[1] > 4000) $fail('That image is too big (4000 × 4000 pixels at most).');
$dir = APP_ROOT . '/uploads';
if (!is_dir($dir) && !@mkdir($dir, 0755, true)) $fail('The uploads folder is missing and couldn’t be made.');
$name = bin2hex(random_bytes(12)) . '.' . $types[$mime];
if (!move_uploaded_file((string)$f['tmp_name'], $dir . '/' . $name)) $fail('Couldn’t save the image. Is the uploads folder writable?');
@chmod($dir . '/' . $name, 0644);
admin_log('upload', $name, '');
$path = 'uploads/' . $name;
if ($json) {
    header('Content-Type: application/json');
    echo json_encode(['ok' => true, 'path' => $path, 'url' => url($path), 'bbcode' => '[img]' . $path . '[/img]']);
    exit;
}
flash('Uploaded. Use [img]' . $path . '[/img] in news or pages.');
redirect('admin/tools.php#images');

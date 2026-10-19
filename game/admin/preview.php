<?php
declare(strict_types=1);
// Live preview for the BBCode editor (v0.7.18): returns the text formatted exactly as players will see it.
require dirname(__DIR__) . '/includes/bootstrap.php';
require dirname(__DIR__) . '/includes/admin_helpers.php';
require_admin();
if (!is_post()) { http_response_code(405); exit; }
csrf_check();
header('Content-Type: text/html; charset=utf-8');
echo format_text(mb_substr((string)($_POST['text'] ?? ''), 0, 60000));

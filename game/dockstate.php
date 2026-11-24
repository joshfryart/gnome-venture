<?php
declare(strict_types=1);
/** The dock's status plate as JSON (v2.8.43): assets/dock.js asks for it after an action that did not reload the page (a form sent in the background), so the clock, energy and coins on the plate are current. GET, logged in; no state changes. */
require __DIR__ . '/includes/bootstrap.php';
require_once __DIR__ . '/includes/garden_logic.php';
require_once __DIR__ . '/includes/dock.php';
header('Content-Type: application/json; charset=utf-8');
header('Cache-Control: no-store');
if (!current_user()) { http_response_code(401); echo '{}'; exit; }
$u = current_user();
$st = dock_status($u);
echo json_encode(['plate' => $st['plate'], 'rows' => $st['rows'], 'links' => $st['links']], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_INVALID_UTF8_SUBSTITUTE);

<?php
// Local test server router. The built-in PHP server ignores .htaccess, so this blocks
// the private folders (game code, database, settings) the same way the real host does.
$path = rawurldecode((string)parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH));
$path = str_replace('\\', '/', $path);
if (preg_match('~(^|/)(includes|data)(/|$)|(^|/)config\.php$|(^|/)\.~i', $path)) {
    http_response_code(403);
    exit('Forbidden');
}
// Uploaded images (v0.9.8: and the pictures Admin → Images saves in subfolders): only image files are served from uploads/, nothing else (never scripts)
if (preg_match('~(^|/)uploads/~i', $path) && !preg_match('~(^|/)uploads/([a-f0-9]{24}\.(png|jpg|gif|webp)|(items|creatures|npcs|buildings|skins|yard)/[a-z0-9_{}-]+\.png|puzzles/[a-f0-9]{24}(\.gif|-still\.png)|jigsaw/[a-f0-9]{24}(-thumb)?\.jpg)$~', $path)) {
    http_response_code(403);
    exit('Forbidden');
}
return false;   // let the server handle everything else normally

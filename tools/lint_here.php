<?php
// Lint the shipped picture layouts and any art placed for them. Usage: php tools/lint_here.php [GAMEDIR]   (exit 1 on a problem)
// Checks: every layout passes here_lint_layout(); a scene PNG that exists (scenes/here-<key>.png, resid-<n>.png, door-*.png) is a real PNG of the layout's w x h.
$game = $argv[1] ?? dirname(__DIR__) . '/game';
require $game . '/includes/here_layout.php';
$all = here_layouts_shipped();
$bad = 0;
foreach (here_lint_all($all) as $k => $p) { foreach ($p as $m) { echo "FAIL layout $k: $m\n"; $bad++; } }
$files = [];
foreach ($all as $k => $L) {
    $f = str_starts_with($k, 'resid-') ? $k . '.png' : ($k === 'door' ? 'door-cottage.png' : 'here-' . str_replace(':', '-', $k) . '.png');
    $files[$f] = [$k, (int)$L['w'], (int)$L['h']];
}
foreach (glob($game . '/assets/img/scenes/{here-*,resid-*,door-*}.png', GLOB_BRACE) ?: [] as $path) {
    $f = basename($path);
    $sz = @getimagesize($path);
    if (!$sz || $sz[2] !== IMAGETYPE_PNG) { echo "FAIL $f is not a PNG\n"; $bad++; continue; }
    if (!isset($files[$f])) { echo "note $f has no layout of its own (a layout for it will fall back to a shared one)\n"; continue; }
    [$k, $w, $h] = $files[$f];
    if ($sz[0] !== $w || $sz[1] !== $h) { echo "FAIL $f is {$sz[0]}x{$sz[1]}, layout $k is {$w}x{$h}\n"; $bad++; }
}
echo $bad ? "$bad problem(s)\n" : "layouts and scene sizes ok (" . count($all) . " layouts)\n";
exit($bad ? 1 : 0);

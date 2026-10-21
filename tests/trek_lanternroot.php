<?php
// v2.0.31: Lanternroot is a real crop. Run: php tests/trek_lanternroot.php GAME_DIR  (a fresh, already-booted install).
$_SERVER['SCRIPT_NAME'] = '/trek.php';
require $argv[1] . '/includes/bootstrap.php';
require_once $argv[1] . '/includes/trek_data.php';
$fails = 0;
function ok(string $what, bool $cond): void { global $fails; echo ($cond ? '  ok   ' : '  FAIL ') . $what . "\n"; if (!$cond) $fails++; }
trek_lanternroot_crop();
$p = q_one("SELECT * FROM plants WHERE slug = 'lanternroot'");
ok('plant exists', (bool)$p);
ok('plant is common (never unstudied)', (int)($p['common'] ?? 0) === 1);
ok('seed is a seed item', q_val("SELECT category FROM items WHERE slug = 'lanternroot-seed'") === 'seed');
ok('plant links the trek seed', (int)$p['seed_item_id'] === (int)q_val("SELECT id FROM items WHERE slug = 'lanternroot-seed'"));
ok('produce item exists', (int)$p['produce_item_id'] === (int)q_val("SELECT id FROM items WHERE slug = 'lanternroot'"));
trek_lanternroot_crop();
ok('idempotent', (int)q_val("SELECT COUNT(*) FROM plants WHERE slug = 'lanternroot'") === 1);
exit($fails ? 1 : 0);

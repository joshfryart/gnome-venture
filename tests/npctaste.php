<?php
// Helper for friends.sh. Prints one line: "<loved item id> <a liked category> <disliked item id>" for an NPC.
// Usage: php tests/npctaste.php GAME_DIR NPC_ID
declare(strict_types=1);
$game = rtrim((string)($argv[1] ?? ''), '/');
$nid = (int)($argv[2] ?? 0);
if (!is_file($game . '/includes/bootstrap.php')) { fwrite(STDERR, "no game at $game\n"); exit(1); }
require $game . '/includes/bootstrap.php';
require_once $game . '/includes/friends.php';
$npc = q_one('SELECT * FROM npcs WHERE id = ?', [$nid]);
if (!$npc) { fwrite(STDERR, "no npc $nid\n"); exit(1); }
$t = npc_tastes($npc);   // also stores the loved item on the NPC on first use, as the game does
$dis = (int)q_val('SELECT id FROM items WHERE category = ? AND tradable = 1 ORDER BY id LIMIT 1', [$t['disliked']]);
echo $t['loved'], ' ', $t['liked'][0], ' ', $dis, "\n";

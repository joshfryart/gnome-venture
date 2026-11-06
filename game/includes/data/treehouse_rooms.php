<?php
// Treehouse rooms: room id (a spot of the 'treehouse' layout) => [label, emoji, [game keys from includes/games.php GAMES]].
// Adding a game to a room is one word; a game in no room is not shown in the picture (it stays on games.php).
return [
    'parlour' => ['Parlour', '🛋️', ['memory', 'letters', 'mushroom']],
    'loft' => ['Loft', '🪜', ['race', 'spit', 'pest']],
    'cellar' => ['Cellar', '🕯️', ['marrow', 'worms']],
];

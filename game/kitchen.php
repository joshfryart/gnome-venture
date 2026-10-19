<?php
declare(strict_types=1);
// Cooking now lives in Crafting (v0.7.5). Old links and bookmarks land there.
require __DIR__ . '/includes/bootstrap.php';
redirect('inventory.php?tab=craft&c=cooking');

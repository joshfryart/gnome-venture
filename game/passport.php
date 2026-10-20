<?php
declare(strict_types=1);
// v2.0.4 menu folds: the stamp passport is a tab on Town (town.php?view=passport). The page has no forms, so a POST just goes to the same place.
require __DIR__ . '/includes/bootstrap.php';
require_login();
redirect('town.php?view=passport');

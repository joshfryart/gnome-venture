<?php
declare(strict_types=1);
// v2.0.4 menu folds: Seasons & weather is now a fold on the World page (Here tab). Old links land there.
require __DIR__ . '/includes/bootstrap.php';
require_login();
redirect('world.php?tab=seasons#seasons');

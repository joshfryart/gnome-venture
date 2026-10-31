<?php
declare(strict_types=1);
/** v0.7.61: the Crafting tab of the Satchel page (was crafting.php). Expects $u.
 *  The Pantry has its own master-detail view (pantry_view.php); every other tab is Shelves (craft_shelves.php, mockup design 3),
 *  which replaced the v0.8.5 recipe cards. */
require_once __DIR__ . '/crafting.php';
require_once __DIR__ . '/almanac.php';

function craft_view(array $u, string $tab): void
{
    if (!isset(CRAFT_CATEGORIES[$tab])) $tab = 'cooking';
    if ($tab === 'pantry') {
        require_once __DIR__ . '/pantry_view.php';
        pantry_view($u);
        return;
    }
    require_once __DIR__ . '/craft_shelves.php';
    craft_shelves($u, $tab);
}

# Handoff + TODO: Crafting "area map" (replaces category dropdown)

Branch: `ccr-187536d6-6139q1`. Status: PLAN ONLY. No code written yet.

## Problem
Satchel → Crafting picks a category via native `<select>` (Cooking, Pantry, Tools, Garden supplies, Potions, Building, Yard & decor). Owner wants a graphical, tappable representation of these areas.

## Where the code is
- `game/includes/crafting.php:12` `CRAFT_CATEGORIES` = key => [label, icon, building|null, blurb]. Keys: cooking, pantry, tools, garden, potions, building, decor.
- `game/includes/craft_shelves.php:43-52` category `<select name="c" data-autosubmit>` + List/show select + Go button. `$counts[cat]` = have/total (line 19). `$stations[cat] === 0` = building missing (line 57).
- `game/includes/pantry_view.php:129-134` duplicate category select (Pantry tab).
- `game/includes/craft_view.php:11` and `game/crafting.php:12` read `?c=` (default cooking).
- Routing: `inventory.php?tab=craft&c=<key>`.
- CSS: `game/assets/style.css` (reuse `.p2jar`, pill styles). JS: `game/assets/site.js` (`data-autosubmit`).
- Existing mockups: `docs/satchel-mockups`, `docs/pantry-mockups`.

## Design decision (recommended)
Tile grid, option A: 7 tappable tiles (real `<a>` links, no JS needed). Each: big icon, name, have/total progress bar, badge (🔒 needs building / ✅ N ready / ⏳ jars or pots done). 2 cols mobile, 4 desktop, tap target >= 44px. Option B (illustrated pixel-art workshop with hotspots) is a later swap; needs new art.

Open questions for owner (defaults in bold):
1. A or B? **A**
2. `inventory.php?tab=craft` with no `c`: show map, or default Cooking? **Show map**

## TODO
- [ ] New `game/includes/craft_map.php`: `craft_area_map(array $u, string $tab, array $counts, array $stations): void` rendering `<nav class="cmap">` of 7 `<a>` tiles; active tile `aria-current="page"`.
- [ ] Badges: ready count via `sh_craft_entries` (status `ok`; fall back to have/total if heavy); locked via `$stations[cat] === 0`; Pantry jars done/in use from `$jarsList` in `pantry_view.php`.
- [ ] Landing: no `?c=` => full map. Inside an area: compact scrollable icon strip, current highlighted, plus "🗺 All areas" button.
- [ ] Replace both category `<select>`s (`craft_shelves.php:45`, `pantry_view.php:131`); keep the List/show dropdown; drop unused category-form Go button.
- [ ] CSS in `style.css`: match brown/gold/red theme, `grid-template-columns: repeat(auto-fit, minmax(140px, 1fr))`, bottom padding so sticky bottom nav and sheet don't cover tiles.
- [ ] A11y: link text like "Cooking, 8 of 85 known"; visible focus ring; locked state not colour-only.
- [ ] Bump version + CHANGELOG (repo convention, e.g. 2.3.3; see recent commits like "2.3.2").
- [ ] Tests: check `tests/` for crafting render tests; add one asserting all 7 `CRAFT_CATEGORIES` keys render as links.
- [ ] Manual check at mobile viewport with Playwright (pre-installed in cloud env; do not reinstall).
- [ ] Commit, push to `ccr-187536d6-6139q1`. No PR unless owner asks.

## Owner prefs
Short, concise replies. Exact descriptions. Save tokens.

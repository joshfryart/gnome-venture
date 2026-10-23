# Overhaul plan: Adventure, Trek, scenes, Villagers (2026-10-23)

Art is done by another AI. Art needs: `claude/art-spec-overhaul.md` (exact files, sizes, names). Code never blocks on art: every new image has a fallback (generated gradient + silhouette).

## Facts from the code
- PHP pages, form POST + reload. Strict CSP (no `style=`, no inline script). Vanilla JS. Pixel PNGs, `image-rendering: pixelated`.
- Adventure: `adventure.php`, `includes/adventure.php` (957), `adventure_data.php`, `delve_map.php`, `destination.php`. World map: `world.php`.
- Trek: `trek.php` (1084) + 12 `includes/trek_*.php` + `trekfight/scene/map/camp.js`. State is already server-side (`trek_tx`, `trek_save`).
- Villagers: only a tab in `town.php?view=villagers` (met NPCs only, `includes/folk_list.php`) + `folk.php`. No menu tile (`layout.php` `nav_sheet`).
- Existing art: ph/ icons 64x64, NPC + gnome 80x100, stop icons 48x48, trek tiles, animals 72 files. New PNGs not wired yet (`handoff-codechangesforart.md`).

## Phase 0: plumbing (first)
1. `art_url($relNoExt)`: PNG if present, else SVG (per handoff doc). `.pixel` CSS class.
2. `includes/scene.php`: `scene_bg(kind, key)` returns `assets/img/scenes/<kind>-<key>.png`, else fallback class `scene-fallback-<key>` (CSS gradient per landscape).
3. `assets/stage.js`: one module. Given a backdrop + `party[]` (left) + `foes[]` (right) it draws a fixed 480x270 stage scaled by integer CSS zoom. Idle bob, attack lunge, hurt flash, KO tilt, floating damage numbers, all in code (no sprite sheets needed). Reused by Adventure, Trek, home visits.
4. `assets/shell.js`: tiny fetch-JSON helper with CSRF, swaps panels, no reload.

## Phase 1: Villagers (menu tile, central place) - quick win
- New `villagers.php` + tile in `nav_sheet` ("Out & about", icon `nav-villagers`, exists). Badge = orders/favours waiting.
- Grid of ALL villagers; unmet = silhouette (`?` card). Filters: here now, friendship level, town/region, has order, search. Sort: friendship, name, recent.
- "Around now" strip on top (uses `npc_now()`).
- Click a card: detail panel in-page (no navigation): portrait, friendship bar, schedule, likes, gift, order, favour, chat. All via `villagers_api.php` (reuses `order_deliver`, `favour_deliver`, gifts from `npc_life.php`/`town.php`).
- "Visit home" button opens the Phase 3 home scene.
- `folk.php` and `town.php?view=villagers` 301 to `villagers.php`. Almanac Folk links updated.

## Phase 2: Trek as one interface
- `trek.php` becomes a shell: fixed viewport, no page scroll, no reload. Actions via `trek_api.php` (JSON: move, fight turn, camp action, choice, use item, recruit). Server rules untouched; only the controller changes.
- Layout (desktop): left = stage (scene or fight) over narrative + choice buttons; right = party, pack, minimap, log as tabs. Phone: stage on top, bottom sheet with the same tabs. Follows `claude/plan-trek-desktop-layout.md`.
- Fight: same stage, party left / foes right, turn buttons under it. `trekfight.js` ported onto `stage.js`.
- Camp: camp backdrop + crew sprites standing around fire; camp menu as buttons.
- No-JS fallback: current server pages stay behind `?classic=1`.

## Phase 3: Adventure rebuild
- Same shell pattern. One world view: new-style world map -> click region -> region map -> click location -> arrive scene. Replaces list/map toggle (`dm_set_pref`).
- Pins: buttons placed by per-location CSS classes generated from DB x/y (new `locations.map_x/map_y`, percent; admin tool to drag-place). Needed because CSP forbids inline `style`.
- Walking a route: scene banner of the land with the gnome walking; encounters open the fight stage; finds/problems are choice cards.
- `adventure_api.php` wraps `combat_turn`, `next_step`, `start_expedition`, `dest_set_off`.

## Phase 4: Scenes everywhere
- Banners on: location arrival, region page, stop pages (`stop_folk.php`), shops, Town.
- Home visits: interior backdrop + villager sprite standing in it; talk/gift/order below.
- Fights (Adventure + Trek): backdrop chosen by landscape / trek chapter.

## Order and rough size
0 (small) -> 1 (medium, ships alone) -> 2 (large) -> 3 (large) -> 4 (grows as art lands). Each phase: version bump, CHANGELOG, tests in `tests/`, fallback art so it ships before art exists.

## Risks
- Trek has many branches (`trek_events/ch3/ch3b`): API must return same HTML fragments the pages do now, so extract renderers first, then wrap.
- Stage scale: integer zoom only (2x/3x) to keep pixels crisp.
- DB change: `locations.map_x/map_y` migration (additive).

## Update: miniatures on the stage
`stage.js` draws `assets/img/mini/<slug>.png` (Aseprite-only toy miniature on a round base) when present, else the existing sticker on a code-drawn base disc. Party layers (gnome body/face/beard/hat) keep tint support. Rules: guide Part E, "Toy miniatures".

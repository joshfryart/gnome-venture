# Plan: graphical navigation ("Here" scenes, residential, door, tile routes) (2026-11-04)
Status: **not built, plan only.** Starts after v3 art lands. Owner: Josh. Written against 2.4.97 (read the code named below before each phase; line numbers drift).

## Goal
Play by tapping pictures. Login lands on **Here**: a v3-style picture of where the gnome stands. Every way out is a path in the picture, every villager present is a 2.5D sprite standing in it. Towns open a **Residential** picture (all houses), each house opens a **Door** picture (Knock / Leave gift / Back). Routes become tile walks in sections, 1 energy a section. World keeps the maps and gains Fast travel and GPS up front.

## Rules for the whole build (so nothing breaks)
1. **Additive + flag.** New pages `here.php`, `residential.php`, `door.php`. Old pages (`town.php`, `world.php`, `villagers.php`, `adventure.php`) stay and keep working. One setting `gnav_on` (admin, default 0). Off = today's game exactly. Flip on for admin first, then everyone.
2. **Art is optional** (same rule as `scene.php`): missing file → generated placeholder → emoji. Never a broken page waiting for art.
3. **Logic stays in existing functions.** Hotspots are links into existing actions (`landmark.php` delve, `start_expedition`, `dest_set_off`, `travel_to`, `villagers_act`). No second copy of game rules.
4. **CSP:** no `style=`, no inline script. Pictures are inline `<svg viewBox="0 0 480 270">` with positions as SVG attributes (`x`,`y`,`transform`), like `maps.php`. Pixel art gets `image-rendering="pixelated"`.
5. **No-JS works.** Every hotspot is a real `<a>`; actions are POST forms on a confirm panel. JS only adds highlight + tap-to-preview.
6. **Every page has a text twin** (`<details>` "List view", like the delve map/list pref `dm_pref`). Needed for a11y, screen readers, tiny phones, and as the fallback when a layout is missing.
7. New tables via a `*_schema()` function in a new includes file (README convention). New settings via the `*_settings()` pattern in `trek_data.php:34`. Importers add missing rows only.
8. One PR-sized step at a time; each ends green on the suites in "Tests".

## Open decisions for Josh (defaults in bold; I build with the default unless told)
1. **Energy:** 1 per section × S sections is a big raise vs today (`route_energy` = `intdiv(steps,3)`, min 1; a 3-step road = 1). **Default: a road/side path has `sections = steps` (3 on roads) and each costs 1 = 3 energy; run `tests/balance_sim.php` and, if too steep, set `gnav_section_energy` to a lower pace (e.g. first section 1, others 1 every 2nd).** Setting `gnav_section_energy` (default 1).
2. **Time:** tile walks are player-paced, so `routes.minutes`, quick-walk and climate slow-down no longer wait. **Default: ignore minutes when `gnav_on`; climate slowdown becomes +1 section on slow climates only if you want it (off).**
3. **Unmet villagers:** Knock on a door of someone you haven't met. **Default: allowed, it meets them** (door shows "?" until then).
4. **Gift when nobody is home:** `npc_gift` needs `npc_here`. **Default: "left at the door", same once-per-day rule, half friendship, no reaction text until they're home.**
5. **Art size:** all new backdrops 480×270 (same as `stop-*.png`, `stage-*.png`). **Confirm with the v3 art AIs before layouts are drawn.**
6. **Login target:** **Here for everyone, with an Account switch "Start on: Here / Home".** Away gnomes still see `back.php` first; unfinished onboarding still goes to the Welcome flow.

---

## Phase 0: recon (half a day, no code)
Read, don't change: `gnome.php` (home/tabs), `login.php:34` (redirect), `town.php` (+ `includes/town.php`, `place_ui.php`: tabs, shops, orders, local acts for non-town stops), `world.php`, `includes/maps.php` + `region_layout.php` (the "slots never move" pattern we copy), `adventure.php` + `includes/adventure.php` (`player_node`, `routes_from`, `start_expedition`, `next_step`, `knock_out`), `destination.php` (`dest_edges`, GPS), `explore.php` (off-path steps), `delve_map.php` + `tilemap.php` + `assets/tilemap.js` (`walk_scene`), `npc_life.php` (`npcs_at_spot`, `npc_now`, `npc_home`), `scene.php`, `friends.php:176` (`npc_gift`), `villagers.php` (`villager_panel`, Knock via `?home`).
Findings to plan around:
- Locations are `hub, market, village, haven, wonder, delve, lair, place` (`locations.kind`), `landscape` picks art. NPC "town" is the region **name string**, not an id.
- NPCs at a location: market/hub towns via `town_spots` + `npc_schedules.spot_id`; travellers on the Green; everyone else is "at home" (`npc_now()['home']`) or out. Villages/havens have no spots.
- A "house" does not exist as data: home = `npcs.home_location_id` (fallback: the shop's location in `npc_home`). Residential = those NPCs.
- Walks are an `expeditions` row: `steps_total`, `step`, `arrive_at` (real time), encounters, logs. Delves/lairs are `expeditions` + `walk_scene` tile rows. Both are guarded by `active_expedition()` redirects on `town.php`, `landmark.php`, etc.
- 151 NPC portraits `ph/npc-<slug>.png`, 64×80 toy minis `mini/mini-npc-<slug>.png` (front-facing). No 2.5D sprites yet.

## Phase 1: foundations (new files only, nothing visible)
**Files:** `includes/here_layout.php` (pure functions), `includes/here_schema.php`, `data/here_layouts.json` (shipped), `tests/here.php` + `tests/here.sh`.

**1a. Scene templates, not one layout per place.** ~80 places can't each have a hand slot map. Key = `<kind>-<landscape>` (e.g. `village-forest`, `haven-coast`, `town-desert`, `delve-mountain`, `stop-camp`) with optional per-slug override `slug:<locations.slug>`. Lookup order: slug → kind-landscape → kind → generic. Scene art file: `scenes/here-<key>.png` (found by `scene_path('here', $key)`).

**1b. Layout JSON = the contract with the art AIs.** Slots never move (like `region_layout`):
```json
{ "village-forest": {
    "w": 480, "h": 270, "horizon": 112,
    "exits":  [ {"a":"N","x":240,"y":118}, {"a":"NE","x":372,"y":128}, {"a":"E","x":452,"y":176},
                {"a":"SE","x":396,"y":236}, {"a":"S","x":240,"y":258}, {"a":"SW","x":84,"y":236},
                {"a":"W","x":28,"y":176}, {"a":"NW","x":108,"y":128} ],
    "spots":  [ {"k":"green","x":240,"y":170}, {"k":"shops","x":330,"y":150}, {"k":"homes","x":150,"y":150}, {"k":"teahouse","x":..,"y":..} ],
    "stand":  [ {"x":200,"y":200}, {"x":280,"y":206}, {"x":120,"y":214}, {"x":360,"y":214}, {"x":240,"y":232}, {"x":60,"y":222} ]
} }
```
- `exits` = up to 8 compass anchors, each a path drawn in the art. `spots` = named things (town square parts, shops, residential door, haven fire, delve mouth). `stand` = where sprites may stand (feet point).
- Debug: `here.php?debug=1` (admin only) draws all slots as numbered dots.

**1c. Pure helpers** (all testable without a DB):
```php
/** Perspective for a 2.5D sprite: feet at y → scale and z-order. Lower on screen = nearer = bigger. */
function here_persp(array $L, int $y): array {
    $t = max(0.0, min(1.0, ($y - $L['horizon']) / max(1, $L['h'] - $L['horizon'])));
    return ['scale' => round(0.75 + 0.5 * $t, 3), 'z' => $y];          // 0.75× far, 1.25× near
}

/** Compass bearing from a place to another, from region_layout coordinates (0 = N, clockwise). Same region only. */
function here_bearing(array $from, array $to): float {
    return fmod(rad2deg(atan2($to['x'] - $from['x'], -($to['y'] - $from['y']))) + 360.0, 360.0);
}

/** Give each route the nearest free compass anchor. Stable: routes sorted by (bearing, id), so the same place always draws the same. */
function here_assign_exits(array $anchors, array $routes): array {   // $routes: [['id'=>, 'bearing'=>float], …]; $anchors: ['N'=>0,'NE'=>45,…]
    usort($routes, fn($a, $b) => [$a['bearing'], $a['id']] <=> [$b['bearing'], $b['id']]);
    $free = $anchors; $out = []; $more = [];
    foreach ($routes as $r) {
        if (!$free) { $more[] = $r['id']; continue; }                     // more routes than anchors → "More ways" list
        $best = null; $bd = 999.0;
        foreach ($free as $name => $deg) {
            $d = abs(fmod($r['bearing'] - $deg + 540.0, 360.0) - 180.0);
            if ($d < $bd) { $bd = $d; $best = $name; }
        }
        $out[$r['id']] = $best; unset($free[$best]);
    }
    return [$out, $more];
}

/** Put villagers on stand slots. Same villager keeps the same slot for an hour (hash), so a refresh doesn't shuffle the crowd. */
function here_place_npcs(array $stand, array $npcs, int $hourKey): array {   // [[slot, npc]…], overflow count
    usort($npcs, fn($a, $b) => crc32($a['slug'] . $hourKey) <=> crc32($b['slug'] . $hourKey));
    $n = min(count($stand), count($npcs));
    return [array_map(null, array_slice($stand, 0, $n), array_slice($npcs, 0, $n)), max(0, count($npcs) - $n)];
}
```
Edge cases here: a place with 0 exits (dead end haven) still has its way back; routes across regions have no shared coordinates → use `region_layout()['exits']` side (N/E/S/W) as the bearing; two routes equal bearing → id tiebreak; > anchors → "More ways" button opens a dialog list; missing template → text twin only.

**1d. Settings + tables** (`here_schema()`):
- Settings: `gnav_on` (0), `gnav_section_energy` (1), `gnav_login_here` (1).
- `user_prefs`? Check if one exists; otherwise add `users.start_page VARCHAR(8) NULL` via the column list `$c` in `schema.php` (plus MySQL ALTER path as other columns do).
- `here_layouts (layout_key PK, json TEXT, updated_at)`: admin edits override the shipped JSON (Phase 7). Read = DB row else file.
- Sprites: `npc_sprites` not needed; file lookup only.

**1e. Placeholder art generator** `tools/gen_here_placeholders.py` (extend `gen_placeholder_art.py`): draws each template's ground, horizon, anchor paths and slot dots to `scenes/here-<key>.png`. Real v3 art overwrites same names. Lets every later phase be built and tested before art exists.

**Done when:** `php tests/here.php` passes (perspective monotonic; assignment deterministic and total; every exit gets a distinct anchor; overflow counted; missing template → null).

## Phase 2: the Here page (read-only picture + links)
**`here.php`** (+ `includes/here_view.php`): `require_login`, onboarding/away/guest guards copied from `gnome.php`/`town.php` order; if `active_expedition()` → redirect to the route view (Phase 6) or `adventure.php`.

Build per request:
1. `$node = player_node($u)`; template via 1a.
2. Exits: `routes_from($node['id'])` + side paths the gnome knows (reuse the filter in `dest_edges`: side route to a place not on a road and not `place_known()` is **hidden**). Each exit: label ("Continue to Mossbottom", "Side path: Salt Mine"), energy chip, level chip (`go_level_chip`), danger (`route_danger`), tags: GPS goal (`users.dest_id`) gets a pulsing ring + "Continue →" first. Locked by Journey (`journey_lock`) → barricade sprite, tap shows why. Ruins (`landmark_in_ruins`) → rubble, tap shows repair link.
3. Spots by kind: town (market/hub): Green, Teahouse, Notice board, Library, Shops (`town.php?view=shops`), Orders, Passport, Homes → Residential (only if any NPC lives here). Village/stop: Do here (`town.php` local acts), Villagers, Stop tab. Haven: Rest/Stay/Buy (existing `landmark.php` POST). Wonder: Investigate. Delve/lair: the mouth → confirm → `landmark.php do=delve|lair`. Own garden here: "Your garden" → `garden.php`. Off-path ("explore") start from any town/road village: a wild trail anchor → `adventure.php do=explore`.
4. Sprites (Phase 3).
5. A tap does `here.php?sel=<id>`; JS toggles an info card under the picture; the card holds the POST form (CSRF, `back=here.php`). Never POST from the picture itself (misclick = lost energy).

SVG render sketch (CSP safe, 44 px tap target at 412 px wide = r ≥ 26 units):
```php
function here_hotspot(string $href, string $label, int $x, int $y, string $icon, string $cls = ''): string {
    return '<a class="hs ' . $cls . '" href="' . e($href) . '" aria-label="' . e($label) . '">'
         . '<circle cx="' . $x . '" cy="' . $y . '" r="26" class="hit"/>'                 // invisible hit area, css fill:transparent
         . '<image href="' . e($icon) . '" x="' . ($x - 16) . '" y="' . ($y - 16) . '" width="32" height="32" image-rendering="pixelated"/></a>';
}
```
Text labels live in the HTML card/legend below the picture (10 px SVG text is unreadable on a phone).

CSS in the marked block at the end of `style.css`; `body[data-area]` stays `world`. Dark theme: art has no dark variant, so use the existing tint layer idea from `stage.js` (a translucent `<rect>` fill via attribute, swapped by `data-theme` in CSS with `fill` rule, no inline style).

**Edge cases:** gnome mid-walk; gnome at a place with no template/art (placeholder + text twin); `location_id` NULL (player_node already repairs it); two exits to the same place (kind road + side); route to a region the gnome cannot reach (`can_reach`); hidden places must stay hidden (no bearing leak: don't draw an exit for unknown side paths); admin in maintenance mode; guests (`is_guest`: view only where Today allows); 8+ exits.

## Phase 3: villager sprites (2.5D)
- Sprite lookup `here_sprite(slug)`: `assets/img/sprite/npc-<slug>.png` (new 2.5D art, any size, **feet at bottom-centre**, file name = slug) → `mini/mini-npc-<slug>.png` (64×80, exists) → `ph/npc-<slug>.png` bust → circle + `npc_icon(species)` emoji.
- Draw: `<image x=cx-w*s/2 y=feetY-h*s width=w*s height=h*s>` ordered by `z` (sort by feet y, far first). Scale from `here_persp`. Soft ellipse shadow under feet. Name appears on tap, not always (clutter).
- Who: `here_npcs($node)` = union of `npcs_at_spot()` for each spot of this region (town only), travellers whose `traveller_stop` is this town, and for non-town places NPCs whose `npc_now()` says out-and-about in this region. **NPCs "at home" are not on the street; they're behind their door (Residential).** Cache one query set per request; `npc_now` is 2 queries per NPC, so for a town with 40+ NPCs load all schedules once (`WHERE npc_id IN (…)`) and evaluate in PHP.
- Tap sprite → `villagers.php?id=` panel (existing talk/wave/bench/snack). Birthday NPC gets a bunting dot.
- Placement via `here_place_npcs`. Overflow → "+N more" chip → Villagers list. Own gnome + friends standing there are a later add-on (not in this plan).
- Walk-in/out: none. Positions change once per Hollow hour; no animation beyond a 2-frame idle bob that respects `prefers-reduced-motion`.

**Edge cases:** the same NPC at two spots at once (schedule overlap: first wins, `array_unique` by id); NPC just changed hour mid-page (stale ok, `npc_gift` re-checks `npc_here`); inactive NPC (`active=0`) skipped; missing sprite for 1 of 151 never breaks the others; sprites must not cover exits (stand slots are chosen clear of exit/spot circles; lint in Phase 7).

## Phase 4: nav wiring, login, World quick access
- `login.php:34` and `back.php` after "welcome back": target `gnav_on && gnav_login_here && users.start_page !== 'home' ? 'here.php' : 'gnome.php'`. Keep the maintenance-admin and away branches first, exactly as now. Also `register/verify` flow ends: leave as is (Welcome flow owns new gnomes).
- Bottom bar `layout.php:402` "Here" → `here.php` when on; desktop menu `layout.php:684` the same. `town.php` stays reachable as "Town square" from the picture and keeps its URLs (bookmarks, `back` params, AJAX loads, tour links). **Do not rename or move `town.php?view=…`; many redirects use them** (grep `town.php` before touching; `landmark.php` `$safe` regex lists `town|world|index|jobs`: add `here`).
- `Account` page: "Start on" select (Here / Home).
- **World page** (`world.php`): add a top strip with two buttons, **Fast travel** (opens a `<dialog>` via `gvOpenDlg` with the existing region list from `travel_to` rules: `can_reach`, `travel_blocked`) and **GPS** (dialog with Seek + current `dest_id` + "Forget route": the forms in `adventure.php do=dest_forget|dest_opts` and `seek.php`). The same two buttons sit on Here. No new rules, only new entry points. World keeps the world map and region map as is (`maps.php`); tapping a place on it with GPS on already sets a destination.
- Tour (`tour.php`) and First Week tasks mention "Here": update copy so the steps match the new page (run `tests/tour.sh`).

**Edge cases:** `AJAX_PAGES` (layout.php:10): do **not** add `here.php` until it is stable (fetch-swapped pages break inline SVG event setup); set `data-area="world"` through `page_area()`; deep links with `?hub=1`; a POST that `redirect()`s back to `town.php` after an action should go back to Here if the action started there (`back` param, whitelisted).

## Phase 5: Residential + Door
**5a. Data.** `npcs_homed_at(int $locId): array` = NPCs with `home_location_id = $locId` plus the `npc_home()` shop-location fallback, `active=1`, travellers excluded, ordered by `id`. **House slot = index in that id-ordered list** (append-only: a new villager takes the next slot, nobody else moves). Show the Residential hotspot only when the list is non-empty.

**5b. Residential picture** `residential.php?loc=<id>&page=<n>`: backdrop `scenes/resid-<style>.png`, style from the place's landscape/kind (same fallback chain as 1a). Templates hold 4, 6 or 8 house slots; more than fit → pages ("Next street →", "← Back street"). Each house: roof/door art from `npc_home_key()` (cottage, burrow, treehouse, hut, stone, boat) drawn at the slot; a lit window if home. Unmet villager: house is plain with "?" and no name. Exits: "Back to town square" (Here), pager. Villagers *currently in the street* are not shown here (they're on Here); villagers at home are not shown either (they're behind the door).
- Guard: `player_node($u)['id'] === $locId` (must be physically there) and no active expedition.

**5c. Door picture** `door.php?npc=<id>`: unique door art `scenes/door-<slug>.png` → else `door-<homekey>.png` (6 shared) → else placeholder. Name plate, "Home / Out / Asleep" via `npc_now` + `npc_home_hours`. Buttons (POST, CSRF):
- **Knock** → at home: the existing visit (`villagers.php?id=&home=1` panel with `npc_home_scene`); out: "No answer. They're usually home {hours}." Costs nothing, no spam rewards (no friendship from a knock).
- **Leave gift** → item picker `<dialog>` (reuse `town_pickers`/gift form from `villager_panel`) → new `npc_gift_door()` (decision 4) that wraps `npc_gift`'s tastes/friendship code, skips `npc_here`, keeps once-per-day (`last_gift`), and logs "left at the door".
- **Back** → `residential.php?loc=…&page=…` (return to the same street page).
After any POST: redirect to the door again with a flash, so Back always lands in the right street.

**Edge cases:** NPC deleted/deactivated while on the door page (404 → residential); NPC moves home (changed `home_location_id`) → slot list shifts only for that NPC; 0 or 1 houses; 50 houses (pager); a gnome opening `door.php?npc=` by URL from elsewhere (guard: must be at the NPC's home location, else redirect to Villagers); shop-keeper homes via fallback; `friends.php` gift limits & tastes unchanged; unmet gift allowed? (decision 3); XP/tasks hooks that fire on `villagers_act` (First Week "talk", Journey, calling quests) must still fire for Knock/Gift. Reuse `villagers_act`, don't duplicate.

## Phase 6: routes as tile walks (largest, riskiest; build behind its own flag `gnav_tiles`)
**Principle:** the `expeditions` row stays the source of truth. The tile view is a **new view of the same walk**, so fights, `knock_out`, logs, GPS "continue", pal/calling perks and the 2.3.94 double-start guard keep working.

**6a. Model.**
- Route = `S` sections (default `S = routes.steps`, roads 3). Section `i` (0-based) is a small tile map, 11×7, generated from seed `route_id|uid|expedition_id|i` with `tm_rng` (as `dv_route` does), entry `S`, exit tile `9`, 0–2 encounter/find tokens from the existing generators (`pick_creature`, `pick_problem`, `give_find`) at the same levels `route_danger` gives. Terrain look by `landscape` of the stretch (reuse `tm_render_svg` palettes).
- `walk_scene` row kind `'route'` (see `dm_scene_make/dm_scene/dm_scene_save` in `delve_map.php:147-212`; add the kind, keep PK on `expedition_id`). Stores `sec`, `x`,`y`, `seen` (fog bitset), `done_tokens`.
- `expeditions.step` is mirrored from `sec`; `steps_total = S`; `arrive_at` set to now (time ignored, decision 2). Arriving = leaving the last section's exit tile → existing arrive code path.
- Section view page = `adventure.php` (already the walking page): when `gnav_tiles && walk_scene kind=route` render the tile map via `delve_map.php` renderer (`tm_render_svg` + `assets/tilemap.js` token walk), else today's timer view.

**6b. Energy (1 per section).**
```php
/** Energy for ONE section of a route, after reductions. Sum over sections is what the gnome pays in total. */
function route_section_cost(array $u, array $route, int $sec): int {
    $base = max(0, (int)setting('gnav_section_energy'));                       // default 1
    if (($route['kind'] ?? 'road') === 'road' && calling_perk($u, 'free_walks') > 0) return 0;   // Master Wayfinder: roads free
    if (staff_free((int)$u['id'])) return 0;                                    // walking staff carries you (wear: once per route, see below)
    return $base;
}
```
- **Enter section 0** (start the route): `spend_energy($uid, route_section_cost(...,0))` inside `start_expedition` (replace the single `route_energy` charge when flag on). **Move to section i+1**: POST `do=section_next` charges `route_section_cost(...,i+1)`.
- Reductions: free_walks perk → all 0; `ev_quickwalk` (fireflies) → consume the flag at start, **all sections free** (store `expeditions.free_walk=1`); staff → 0 energy but wear **once at start** (as today, not per section); Master Wayfinder staff never wears; any future "−X energy" bonus plugs into `route_section_cost` only (single choke point; grep `route_energy(` callers: `world.php`, `place_ui.php`, `destination.php`, previews must call the new total helper so the number shown = the number charged: `route_total_energy($u,$route)` = Σ section costs, and the exit chip on Here uses it).
- **Atomic advance (compare-and-swap)** so two tabs / double taps can't double-charge or skip:
```php
db()->beginTransaction();
$ok = q('UPDATE walk_scenes SET sec = sec + 1 WHERE expedition_id = ? AND sec = ?', [$expId, $sec])->rowCount() === 1;   // table name per delve_map.php
if ($ok && $cost > 0 && !spend_energy($uid, $cost)) { db()->rollBack(); return [false, "You need $cost energy to go on. Rest or turn back."]; }
$ok ? db()->commit() : db()->rollBack();
```
- Out of energy mid-route: gnome stays in the section safe; **Turn back is always free** (back to the origin, or forward-only if already past half? default: back to origin, free) and the route can resume later: the section map and fog are saved, no energy refunded for entered sections.
- Knocked out: existing `knock_out` (wakes at `from_id`) → also `dm_scene_drop`.
- Abandoning with the Back button/closing the tab: scene persists; `active_expedition` gating keeps redirecting to `adventure.php` (as for timed walks).

**6c. GPS / destinations.** `dest_set_off` still sets the first leg; on arrival `Continue to X →` on Here highlights the next exit (Phase 2). Multi-leg total energy preview = Σ `route_total_energy` over `dest_path`.

**6d. Off-path "wilds" (`explore.php`)** already costs 1 energy per step: reuse the same tile section view later (Phase 6 stretch; not required for v1).

**6e. Rollout.** `gnav_tiles` default 0. Admin sees it first. Walks already in progress when the flag flips finish the old way (a row without a `walk_scene` stays timer-based; decide per row, never mid-walk). `lay_roads()` comment shows how the code already finishes in-flight walks safely; copy that care.

**Edge cases:** a route with `steps` 0 or >9 (clamp S 1..6); duplicate section tokens after a refresh (tokens keyed by id in `done_tokens`); fight in progress when the page reloads (the fight state is in `expeditions.encounter`, untouched); pals along (`gnome_combat($u, true)`) unchanged; pal-job trips use `pal_jobs.php` timers (separate, untouched: confirm in Phase 0); `climate` slowdown; "Easy roads" cap (`exp_easy_cap`) still applied by the existing level code; Hollow-hour/weather stage art on a route section; mobile: 11×7 at 412 px = 37 px per tile (OK, tilemap.js already uses 44 px hit buttons over the svg for delves, copy that); fog uses the hex bitset `tm_seen_*`.

## Phase 7: admin layout editor + art drop-in
- `admin/here_layout.php`: pick a template, show its art with the slots as draggable dots (vanilla JS, pointer events, 1 px snap), number inputs for exact x/y, "Save" writes `here_layouts`. "Lint" button: every slot inside 0..w/0..h, stand slots ≥ 28 units from every exit/spot, exits ≥ 40 apart, horizon < all stand y, ≥ 4 stand slots, Residential house slots in view. This is how art from the v3 AIs gets matched without code deploys.
- `tools/lint_here.php` runs the same lint over the shipped JSON + `assets/img/scenes/here-*.png` sizes (must be 480×270 PNG) in CI.
- Art brief for the AIs: `claude/art-brief-here.md`: canvas 480×270; template list (kind × landscape; ~45) + residential styles + 6 door arts + generic; where paths/doors go (the slot JSON), horizon line rule, no baked-in people, ground plane flat enough for sprites, 8 path stubs; sprites: feet bottom-centre, ≤96 px tall, 1 px umber outline, transparent bg.
- Update `admin/artguide.php`, `tests/build_guide*.py` catalog entries, `README.md` Key systems, `DESIGN.md` (Here/door pictures), CHANGELOG.

## Phase 8: release
Bump `APP_VERSION` (single source), `CHANGELOG.md`, `tests/manifests/<ver>.txt`, `tests/build_update.sh` slim zip (new files only + edited ones; follow `releases/` convention), `bash tools/check_versions.sh`, `claude/todo.md` NOW block + `claude/handoff-<ver>.md`. Joshua uploads. Ship order: (A) phases 1–4 with `gnav_on` off, turn on for admin; (B) 5; (C) 6 behind `gnav_tiles`.

---

## Tests (add + keep green)
New: `tests/here.php`/`here.sh` (pure helpers; render smoke for each kind; every exit has an anchor; no hidden-place leak; sprite fallback chain; residential slot stability when an NPC is added; door guard redirects; `route_section_cost` matrix: normal / free_walks road / free_walks side / staff / quickwalk / 0 setting; CAS advance twice = one charge). Add to `SELF_INSTALLING`/suite list in `tests/ci_suites.sh` and the CI workflow.
Existing must still pass with `gnav_on` **both 0 and 1**: `walk, redirects, roads, roads097, roadlife, roadtext, roadkinds, stops100, stopthemes, scenes, villagers, town, adventure, advforce, delve2, delveroute, delvemap, delvefloors, treks, trekshell, calling, fix100, security190, health, css_lint, tour, landmarks, landmark_scene, mwalk43`. Also `tests/balance_sim.php` for the energy change, `tools/check_versions.sh`.
Manual (Playwright is installed; don't reinstall): 412 px phone + 1400 px desktop, light + dark, for Here (town / village / haven / delve / lair / road stop), Residential (1, 6, 30 houses), Door, route walk; keyboard-only pass; no horizontal scroll; no CSP errors in console; MySQL run (`upgrade_check.sh`) for new columns/tables, since only SQLite is in CI.

## Risks and rollback
| Risk | Mitigation |
|---|---|
| Energy economy shock (3× walk cost) | Decision 1, `balance_sim`, setting-driven; ship tiles last |
| Art not ready / mismatched slots | Placeholders + admin slot editor + text twin; `gnav_on` off until art lands |
| Hidden-place leaks via exit drawing | Same filter as `dest_edges`; test asserts it |
| N+1 queries in big towns | Batch schedules/NPCs once per request; cache `region_layout` (already static) |
| Double-charging energy (two tabs) | CAS update + transaction; test |
| Breaking old URLs | Old pages untouched; only add redirects behind flag; `back` param whitelist |
| In-flight walks at flag flip | Per-row mode, never convert mid-walk |
| MySQL-only column bugs | `$c` schema list + `upgrade_check.sh`; no SQLite-only SQL |
| CSP | No inline style/script; SVG attributes only; checked in console |
Rollback at any phase: set `gnav_on=0` (and `gnav_tiles=0`); new tables/columns stay unused; delete new files to remove completely.

## Build order summary
1 foundations → 2 Here page → 3 sprites → 4 nav/login/World strip → *(release A)* → 5 Residential + Door → *(release B)* → 6 tile routes → *(release C)* → 7 editor/art/docs. About 6–8 sessions; phase 6 is half of the risk and half of the work.

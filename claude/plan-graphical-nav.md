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

## Decisions (Josh, 2026-11-04)
1. **Energy:** 1 energy to step onto the trail from a town/location (section 1). Later sections cost 0: just a "Continue" confirm. Last confirm heads into the destination. See Phase 6.
2. **Route minutes:** not used any more (tile walks are player-paced).
3. **Door:** knock works only when they are home. Not home = lights off + a message. Lights on = home.
4. **Gift when away:** allowed, "left at the door", once a day, half friendship.
5. **Art size 480×270:** Josh will consider. Code reads size from the layout JSON (`w`,`h`), never hard-codes it.
6. **Login:** Here for everyone, Account switch "Start on: Here / Home".
7. **Road = Trail** (the mycelium trail). Player-facing text says Trail; code and tables keep `road`.
8. **New (2026-11-04):** Crafting, Games (treehouse) and Pals / Pal Jobs also become pictures (Phases 9 and 10), on the same scene engine.

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

**1b-2. One generic scene engine for every picture page.** Here, Residential, Door, Crafting, Treehouse and Pal Yard are all "a backdrop + hotspots + sprites + a popover". Build it once: `includes/hub_scene.php` with `hub_scene(string $key, array $hotspots, array $sprites, array $opts): string` (inline SVG, CSP-safe, hotspots are `<a>` with a `?o=<id>` fallback) and `assets/hubscene.js` (hover/focus highlight, tap opens the popover `<dialog>`, Esc / outside tap / ✕ closes, focus returns to the hotspot, no body scroll lock per DESIGN.md). Layouts come from the same JSON/`here_layouts` table and the same admin editor. Only the content of each popover differs. The old Crafting map (percent boxes + `.hs-*` CSS rules) keeps working until Phase 9 swaps it.

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
- Settings: `gnav_on` (0), `gnav_tiles` (0), `gnav_enter_energy` (1), `gnav_login_here` (1).
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

**5c. Door picture** `door.php?npc=<id>`: unique door art `scenes/door-<slug>.png` → else `door-<homekey>.png` (6 shared) → else placeholder. Name plate, and **lights**: window lit when they are home (`npc_now()['home']`), dark when not (art: `door-<key>-on/off.png`, or one door art plus a lit/dark window overlay layer). Message when dark: "No light on. They're usually home {hours}." Buttons (POST, CSRF):
- **Knock** → only works when they are home: the existing visit (`villagers.php?id=&home=1` panel with `npc_home_scene`). Dark = message, nothing happens. Unmet villagers: lights/knock work the same and knocking meets them (the "?" name plate fills in). Costs nothing; no friendship from the knock itself.
- **Leave gift** → item picker `<dialog>` (reuse `town_pickers`/gift form from `villager_panel`) → new `npc_gift_door()` (decision 4: left at the door, half friendship) that wraps `npc_gift`'s tastes/friendship code, skips `npc_here`, keeps once-per-day (`last_gift`), and logs "left at the door".
- **Back** → `residential.php?loc=…&page=…` (return to the same street page).
After any POST: redirect to the door again with a flash, so Back always lands in the right street.

**Edge cases:** NPC deleted/deactivated while on the door page (404 → residential); NPC moves home (changed `home_location_id`) → slot list shifts only for that NPC; 0 or 1 houses; 50 houses (pager); a gnome opening `door.php?npc=` by URL from elsewhere (guard: must be at the NPC's home location, else redirect to Villagers); shop-keeper homes via fallback; `friends.php` gift limits & tastes unchanged; gift to an unmet villager (allowed, meets them); XP/tasks hooks that fire on `villagers_act` (First Week "talk", Journey, calling quests) must still fire for Knock/Gift. Reuse `villagers_act`, don't duplicate.

## Phase 6: the Trail as tile sections (largest, riskiest; behind its own flag `gnav_tiles`)
**Flow (decided):**
```
Town/location  --(1 energy)-->  Trail section 1 (tile map: random encounters, items, finds)
  --[Continue? no energy]-->  roll a random event (by region/landscape/level/weather/hour)  -->  Trail section 2
  --[Continue? no energy]-->  roll event  -->  Trail section 3 (last)
  --[Head into <place>?]-->  arrive (existing arrive path)
Always on screen: Gather, and Wander off the Trail (= `explore_start`, 1 energy/step as today). Turn back is free.
```
Sections = `routes.steps` clamped 1..6 (roads 3). Energy is paid **once, when stepping from the place onto section 1**.

**Principle:** the `expeditions` row stays the source of truth. The tile view is a new view of the same walk, so fights, `knock_out`, logs, GPS "continue", perks and the 2.3.94 double-start guard keep working.

**6a. Model.**
- Section `i` (0-based) = a small tile map (about 11×7) from seed `route_id|uid|expedition_id|i` via `tm_rng` (as `dv_route`). Entry `S`, exit tile `9`, 0–2 encounter tokens and 1–3 item/find tokens, drawn from existing generators (`pick_creature`, `pick_problem`, `give_find`) at the levels `route_danger` gives. Look = `landscape` palette (`tm_render_svg`).
- New `walk_scene` kind `'route'` (copy `dm_scene_make/dm_scene/dm_scene_save`, `delve_map.php:147-212`): `sec`, position, fog bitset, `done_tokens`, `phase` (`section` | `confirm` | `event`).
- `expeditions.step` mirrors `sec`; `steps_total = S`; `arrive_at = now` (time unused).
- Walking page stays `adventure.php`: flag on and a route scene present → tile view, else today's timer view.

**6b. Energy (one charge, at the start).**
```php
/** Energy to step onto the Trail from a place. Later sections are free. Single choke point for every reduction. */
function route_enter_cost(array $u, array $route): int {
    if (($route['kind'] ?? 'road') === 'road' && calling_perk($u, 'free_walks') > 0) return 0;   // Master Wayfinder
    if (staff_free((int)$u['id'])) return 0;                                                       // walking staff (wear once, as today)
    return max(0, (int)setting('gnav_enter_energy'));                                              // default 1
}
```
- Replace the `route_energy()` charge in `start_expedition` (flag on): `ev_quickwalk` (fireflies) still makes the start free and is consumed there; staff wear once at start; Wayfinder perk and any future "−energy" bonus plug into `route_enter_cost` only. Every preview (Here exit chips, `world.php`, `place_ui.php`, `destination.php`) calls the same function so the number shown = the number charged. GPS multi-leg preview = Σ per leg.
- Section → section: POST `do=trail_next` costs 0 but is still compare-and-swap so a double tap / second tab can't skip a section or fire two events:
```php
$ok = q('UPDATE walk_scenes SET sec = sec + 1, phase = ? WHERE expedition_id = ? AND sec = ? AND phase = ?', ['event', $expId, $sec, 'confirm'])->rowCount() === 1;   // table name per delve_map.php
```
- Out of energy never strands anyone: the only charge happens before the walk starts. Wander off the Trail keeps its own per-step cost and its own "not enough energy" message.

**6c. The in-between: confirm + event.**
- When the exit tile is reached: overlay popover "Continue along the Trail? [Continue] [Turn back] [Gather] [Wander off]". No cost.
- On Continue: `trail_roll_event(array $u, array $route, int $sec): ?array` rolls once, **seeded and saved in the scene** (`event` JSON) so a refresh shows the same event and can't be re-rolled. Weighted table by landscape, weather, daypart, region, gnome level, `route.kind`: e.g. nothing (40%), traveller / trader (reuse `traveller_offer`), a villager meeting (`npcs` of the region), a find, a shortcut/detour, a small weather event, a rest spot, a rare legendary sign (never on Easy roads: respect `easy_roads_on`). Data in `includes/data/trail_events.txt` (one line per event: weights, landscapes, min/max level, text), lint like `tools/lint_road_events.py`. Reuse `road_life.php` / `road_text.php` / `trek_events.php` content wherever it already fits instead of writing new events.
- The event shows as a popover with 1–3 buttons; its result is applied once (flag `event_done`), then the next section starts. No energy anywhere in this loop.
- Last section: popover becomes "Head into <place>?" → existing arrive code.

**6d. Always-there actions.** Two buttons in the Trail footer, every section and every popover: **Gather** (existing `gather.php` for the stretch's landscape; check it doesn't need `active_expedition` to be null) and **Wander off the Trail** (`adventure.php do=explore`; coming back lands on the same section: `explore_come_back('road')` must resume the route scene, not drop it. Verify in Phase 0; add `phase='wander'` so `trail_next` is blocked while wandering).

**6e. Interface (clean, simple, popovers).**
- One full-width picture: the section's tile map with a slim top strip (Trail name, "Section 2 of 3", energy chip, HP bar) and a slim footer (Gather · Wander off · Turn back). Nothing else on the page.
- Everything else is a `<dialog>` popover via `gvOpenDlg/gvCloseDlg`: encounters/fights (existing fight UI inside a dialog on phones), finds, events, confirm. Back out = Esc / tap outside / ✕. Never more than one dialog; dialogs are real `<form>`s, so no-JS still works (falls back to a normal section below the map).
- Tokens on the map are the only things to tap; walking = tap tile, as delves (`tilemap.js`).

**6f. GPS / destinations.** `dest_set_off` still sets the first leg; on arrival Here highlights the next exit ("Continue to X →"), and a leg finishing hands straight to the next `Head into` popover only if the place is a pass-through stop (no extra energy: the next leg still charges `route_enter_cost` when it starts, as designed).

**6g. Rollout.** `gnav_tiles` default 0, admin first. Walks in progress when the flag flips finish the old way (a row with no `walk_scene` stays timer-based; decide per row, never mid-walk). Copy the care in `lay_roads()` for in-flight walks. `routes.minutes`, quick-walk and climate walk-slowdown are ignored for tile walks.

**Edge cases:** `steps` 0 or >6 (clamp); refresh mid-section/confirm/event (all saved in the scene by `phase`); two tabs (CAS); fight pending when reloading (state in `expeditions.encounter`, untouched); knocked out → `knock_out` wakes at `from_id` and drops the scene; pals along unchanged; pal-job trips use their own timers (confirm in Phase 0); Easy-road level cap (`exp_easy_cap`) still applies; Journey-locked or ruined destination at arrival (existing checks); weather/daypart look for sections; mobile tile size (copy `tilemap.js` 44 px buttons over the svg); fog `tm_seen_*`; player closes the tab on a popover (reopens on the same phase); logging out mid-walk; admin viewing a player's walk (read-only).

## Phase 9: Crafting = one picture, sections open as popovers
Today (2.3.x): `craft_map.php` + `data/craft_scenes.php` + `assets/img/craftmap/*` give a card per area, then a scene per area with tappable objects (percent boxes). Replace the landing with **one crafting workshop picture** (v3 style) holding every section as a hotspot; keep the old page as the text twin and fallback.
- Sections (= `CRAFT_CATEGORIES`, `crafting.php:12`): Cooking (hearth + pots), Pantry (shelves + jars), Tools (bench), Garden supplies, Potions (alchemy table), Building, Yard & decor. Each hotspot shows a small badge (ready count / locked 🔒 needs building / jars done) from the existing `craft_map_facts()`; locked sections look dim and the popover says what unlocks them.
- Tap a section → **popover overlay** (`<dialog>`, big on phones, centred card on desktop) with that section's content: the existing list/recipes (`craft_shelves`, `pantry_view`, `craft_pop_html`) rendered into the dialog from an AJAX fragment (`crafting.php?c=<key>&frag=1`, same header `X-Requested-With: fetch` pattern as `villagers.php`). Inside: the object sub-tags (`?o=`) as chips, craft buttons, results. **Back** closes the popover and leaves the workshop picture exactly as it was; **no-JS** follows `inventory.php?tab=craft&c=<key>` as today.
- Craft actions keep posting to the existing endpoints; after a craft the popover refreshes in place and the badge updates; the page never reloads the picture.
- Stations/buildings: a built Kitchen/Rain Barrel/etc. appears in the picture; unbuilt shows a build-site silhouette that links to the building. Pal station shifts (`pj` cook pots) show the pal at the pot (reuse the sprite rule from Phase 3).
- **Animations (later step, static first):** CSS-only, applied to separate PNG layers placed over the backdrop: bubbling pot (2–4 frame sprite sheet via `steps()`), stirring spoon, potion drip/bubbles, steam, flickering hearth, jars glow when done. Rules: only on visible sections, paused by `prefers-reduced-motion`, off in `data-saver`/low-power (JS `matchMedia`), max ~6 animated layers per screen, layers are optional files (`craft-<section>-anim.png`). Art note for the v3 AIs: draw static scene with those objects **empty/neutral**, and give the animatable pieces as separate transparent sprites with their anchor in the layout JSON (`anim`: `{id, x, y, w, h, frames, fps}`).
- Edge cases: a section with 0 known recipes (shows hint, not empty); long recipe lists inside the dialog scroll **inside** the dialog (no page scroll lock); craft in progress (jars/pots timers) keep counting via the existing `site.js` timers; the Pantry tab and Satchel > Crafting links must still land on the right section (old `?tab=craft&c=` URLs open the picture with that popover already open: `?o=`/`c=` handled in PHP by rendering the dialog `open`); two sections open at once (not allowed: opening one closes the other); dark theme art variant; keyboard focus trap in the dialog (native `<dialog>` modal does this).
- Tests: `tests/craft.sh` (must still pass), new render check that all 7 `CRAFT_CATEGORIES` keys have a hotspot link and a popover fragment; `craft_tags.php`; `pantry.sh`.

## Phase 10: Treehouse (Games), Puzzle Pals, Pal Jobs
**10a. The Great Treehouse (`games.php` becomes a picture).** One big tree, cut-away so several rooms show at once (Josh's idea). Rooms = the entries `games.php` lists today, each a hotspot with its badge (plays left / In progress / Done today / locked by level):
- Games room(s): the `GAMES` table (worms, memory, race, spit, marrow, carve, letters…): group into 3–4 rooms by feel (e.g. **Parlour**: memory, letters; **Loft**: race, spit; **Cellar**: marrow, carve, worms). Grouping lives in data (`includes/data/treehouse_rooms.php`: room id → game keys → slot positions), so adding a game is one line.
- **Puzzle Room** → `puzzles.php` (Jeff, GIFsaw, Jigsaw), gated by `puzzles_open`.
- **Cat Fish nook** → `catfish.php` when `catfish_open()`.
- **Contest Hall / trophy shelf** → the Contests tab (`games.php?tab=contests`), plus "This week's high scores" as a popover (the existing `game_top()` data).
- Room tap → **popover** with that room's games as cards (play, plays left, best score, blurb) instead of leaving the picture; "Play" navigates to the game page as now. Back from a game returns to the treehouse (set `back`/`from=treehouse`).
- Locked/not-yet-open rooms show closed shutters with the unlock text (Marrow at level `marrow_min_level`, Puzzles when open).
- Fallback: today's tile grid stays as the text twin (`?view=list`, remembered like `dm_pref`).

**10b. Puzzle Pals live in the treehouse.** `ppal_open()` and a found-map from `ppal_found_map($uid)` (`puzzle_pals.php:383`) tell which pals the gnome owns.
- Each found pal gets a **stable perch** in the treehouse: slot = index in the gnome's found order (append-only, like houses), from a `pals` slot list in the layout JSON (branches, window sills, rope swing, rug, hearth, bookshelf, ~24 perches, more via the "Pal Yard" below). Sprite lookup like Phase 3 (`assets/img/pals/<key>.png` → the existing sticker → piece crop → silhouette). Locked pals: nothing, or a faint silhouette on perches only for pictures the gnome has unlocked.
- **Slowly populating:** the treehouse starts with one lantern and an empty rope swing; a pal appears the first time its sticker is found (first view after finding shows a small arrive animation/sparkle, `new` flag from `found_at > last_seen`, last_seen saved per gnome in a small table `hub_seen`). Rooms also get "dressed" by milestones (5/10/20/40 pals → a rug, string lights, a telescope), data driven.
- Pal in **party** (`ppal_set_active`) sits on the gnome's shoulder / by the door instead of a perch (not duplicated); pal out on a **job** shows an empty perch with a tiny "away" tag and its return time.
- Tap a pal → popover: name, rarity, level, times found, "Take along / Send home" (existing `puzzlepals.php` POSTs), "Send on a job" link. Rarity glow ring on the perch.
- Pal Book (`puzzlepals.php`) stays as the complete grid (collection view with silhouettes) and is reachable from a bookshelf hotspot. Jigsaw tournament pals (Expert trophies) are a trophy shelf.
- Edge cases: 0 pals (empty tree + hint "Solve jigsaws to find pals"); 150+ pals (perches run out → pals fill the **Pal Yard**, see 10c, in found order; treehouse shows the first N + "+12 in the yard"); `ppal_open()` off or guest (pal parts hidden, games still shown); pals removed/renamed in data (missing key skipped, never fatal); perf: one `ppal_found_map` call, sprites are static `<image>`s.

**10c. Pal Yard + Pal Jobs (`paljobs.php` as a picture).** Level gate `pj_open($u)`. A picture of a garden yard beside the treehouse: hotspots are the job sites instead of a form list:
- **Garden plot** (send to tend a garden), **Trail head** (gathering trip), **Delve mouth** (re-run a cleared delve), **Kitchen / Craft stations** (pot shifts from 2.4.61+), **Sick bay** (heal), **Noticeboard / Ledger** (pals out, progress, countdown, collect, recall, call home).
- Tap a site → popover with the existing job form for that kind (pal radio list, options, Send). Pals out are drawn **at their site** working (sprite + progress ring); done jobs show a "collect" bubble; idle pals roam the yard stand slots. One popover at a time; the Ledger popover keeps today's countdown JS (`assets/paljobs.js`).
- Reuse `pj_pals`, `pj_jobs`, `pj_can_send`, `pj_settle`, `send_*`/`collect`/`recall`/`heal` POSTs unchanged; the picture only changes where the buttons live. `pj_max_away` / daily caps / level gate unchanged and shown in the popover.
- Edge cases: more jobs than site slots (sites hold N each; extras listed in the Ledger); job finishes while the page is open (existing timer reveals Collect); pal with low HP (sick-bay badge); pal both in party and on a job (blocked by `pj_can_send`, show why); no pals at level (empty yard + hint).

**Common to 9 and 10:** all are behind `gnav_on` (own sub-flags `gnav_craft`, `gnav_tree` for staged rollout); old pages stay as text twins and for no-JS; all popovers use the one `hubscene.js`; admin layout editor (Phase 7) covers their slots; v3 art briefs per picture go in `claude/art-brief-here.md` (workshop, treehouse cutaway with ~24 perches and 4 rooms, pal yard, residential styles, doors).

## Phase 7: admin layout editor + art drop-in
- `admin/here_layout.php`: pick a template, show its art with the slots as draggable dots (vanilla JS, pointer events, 1 px snap), number inputs for exact x/y, "Save" writes `here_layouts`. "Lint" button: every slot inside 0..w/0..h, stand slots ≥ 28 units from every exit/spot, exits ≥ 40 apart, horizon < all stand y, ≥ 4 stand slots, Residential house slots in view. This is how art from the v3 AIs gets matched without code deploys.
- `tools/lint_here.php` runs the same lint over the shipped JSON + `assets/img/scenes/here-*.png` sizes (must be 480×270 PNG) in CI.
- Art brief for the AIs: `claude/art-brief-here.md`: canvas 480×270; template list (kind × landscape; ~45) + residential styles + 6 door arts + generic; where paths/doors go (the slot JSON), horizon line rule, no baked-in people, ground plane flat enough for sprites, 8 path stubs; sprites: feet bottom-centre, ≤96 px tall, 1 px umber outline, transparent bg.
- Update `admin/artguide.php`, `tests/build_guide*.py` catalog entries, `README.md` Key systems, `DESIGN.md` (Here/door pictures), CHANGELOG.

## Phase 8: release
Bump `APP_VERSION` (single source), `CHANGELOG.md`, `tests/manifests/<ver>.txt`, `tests/build_update.sh` slim zip (new files only + edited ones; follow `releases/` convention), `bash tools/check_versions.sh`, `claude/todo.md` NOW block + `claude/handoff-<ver>.md`. Joshua uploads. Ship order: (A) phases 1–4 with `gnav_on` off, turn on for admin; (B) 5; (C) 9–10; (D) 6 behind `gnav_tiles`.

---

## Tests (add + keep green)
New: `tests/here.php`/`here.sh` (pure helpers; render smoke for each kind; every exit has an anchor; no hidden-place leak; sprite fallback chain; residential slot stability when an NPC is added; door guard redirects; `route_enter_cost` matrix: normal / free_walks road / free_walks side / staff / quickwalk / 0 setting; `trail_next` twice = one advance and one event; event roll is stable across refresh; later sections cost 0). Add to `SELF_INSTALLING`/suite list in `tests/ci_suites.sh` and the CI workflow.
Existing must still pass with `gnav_on` **both 0 and 1**: `walk, redirects, roads, roads097, roadlife, roadtext, roadkinds, stops100, stopthemes, scenes, villagers, town, adventure, advforce, delve2, delveroute, delvemap, delvefloors, treks, trekshell, calling, fix100, security190, health, css_lint, tour, landmarks, landmark_scene, mwalk43`. Also `tests/balance_sim.php` for the energy change, `tools/check_versions.sh`.
Manual (Playwright is installed; don't reinstall): 412 px phone + 1400 px desktop, light + dark, for Here (town / village / haven / delve / lair / road stop), Residential (1, 6, 30 houses), Door, route walk; keyboard-only pass; no horizontal scroll; no CSP errors in console; MySQL run (`upgrade_check.sh`) for new columns/tables, since only SQLite is in CI.

## Risks and rollback
| Risk | Mitigation |
|---|---|
| Energy economy shift (1 per trail instead of 1 per 3 steps; free later sections) | `gnav_enter_energy` setting, `balance_sim`; ship tiles last |
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
1 foundations → 2 Here page → 3 sprites → 4 nav/login/World strip → *(release A)* → 5 Residential + Door → *(release B)* → 9 Crafting scene → 10 Treehouse (Games, Pals, Pal Jobs) → *(release C)* → 6 Trail tiles → *(release D)* → 7 editor/art/docs (the editor is built earlier, in Phase 1b, if art arrives first). Phase 6 is half the risk; 9 and 10 are cheap because the scene engine already exists.

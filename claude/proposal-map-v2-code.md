# Map v2: implementation plan (game code and UI)

Date: 2026-11-28. Status: plan, nothing built. Scope: the region maps and the world map in the "lit floor" style, with off-road places spread across the cavern floor. Everything ships behind one setting, OFF by default. With the setting off the game draws exactly what it draws today.

Source material read for this plan:

- `game/includes/region_layout.php`, `game/includes/maps.php`, `game/world.php`, `game/includes/place_ui.php` (`go_map_html`), `game/includes/here_view.php` (`here_routes_map`, `here_route_bearing`), `game/assets/site.js` (`gvZoomPan`, `gvRegionZoom`, `gvMaps`), `tools/map_layout.php`, `tests/region_trails_gates.php`, `tests/map_fixes.php`.
- Owner-approved mockup: scratchpad `offroad2.html` (phone view, thick roots, bottom sheet, stop list), `spread_helper.py`, `delve-3.py`.
- `claude/PROPOSAL-HOLLOW-MASTER.md` section 17 (main line and side-quest villages).
- Already in the working tree from the art side (untracked): `game/includes/data/world_v2_layout.json`, `game/assets/img/scenes/map2-world.png`, `tools/map_v2/world.py`. This plan uses that JSON as it is.

Not available when this was written: scratchpad `plans/plan-<CODE>.json` (the folder does not exist yet). Section 3.2 states the shape this plan assumes for its `spread` key.

---

## 0. Facts about today's code that shape the plan

1. `region_layout($code)` (`region_layout.php`) is player-independent, cached per request in a `static`, and returns `slots`, `roads`, `trails`, `exits`, `pin`, `clear`. Slot ids are `locations.id`.
2. `region_map_svg()` (`maps.php:508`) hides off-road slots the gnome has not found, draws trails as thin dashed straight lines, and every marker is a plain link to `world.php?go=ID#gopanel`. It is called from two places: `game/world.php:153` and `go_map_html()` in `place_ui.php:29`. Both wrap it in `.rzoom` + `.rzctl`, which `gvRegionZoom()` in `site.js` binds.
3. `here_routes_map()` (`here_view.php:168`) also reads `region_layout()` and `scene_path('map', $code)`.
4. `compass_between()` (`maps.php:229`) reads slot x and y from `region_layout()`. `tests/map_fixes.php` checks that it equals `rl_heading8()` of the slot delta for every trail.
5. The trail fields `bow`, `heading`, `ctrl` (from `rl_trail_heading()`) have **no runtime reader in `game/`**. They are read by `tools/map_layout.php` (which writes `tools/map_layout.lua`, key `trail_bends`), by the Trail map tools (`tools/gen_bendy_trail_proto.py`, `tools/add_trail_extras.py`) and by `tests/region_trails_gates.php`, which asserts for every trail: `count(pts) === 2`, `bow` is L or R, `heading` is one of `RL_HEADINGS`, `ctrl` has 2 numbers, and that `tools/map_layout.lua` equals a fresh dump.
6. **The v1 layout is different when `world_v2_open` is on.** World v2 adds places (Cattailmere id 245, Granitegate id 248, and more), and the stretch step then moves everything (Poppyburrow is at 145,126 with world v2 off and at 212,140 with it on). The mockup, the scratchpad `layouts/layout-<CODE>.json` files and so the spread data are all built on the world-v2-on layout. The spread data therefore only fits a site where `world_v2_open` is on. Section 3.3 turns this into a check, so a site where it does not fit silently keeps the old maps.
7. The world map (`world_map_svg`, `maps.php:321`) draws in a 1000 x 560 unit view box. The art is 640 x 360, stretched over it. `map_positions()` places everything from `REGION_MAP` discs and `HUB_MAP`. `site.js` `gvMaps()` depends on the view box, the `lod1/2/3` groups and the `data-place` attributes.
8. Content-Security-Policy is `style-src 'self'; script-src 'self'`. No inline `<script>`, no `style=""` attributes. Setting `element.style` from a JS file is allowed (site.js already does it).
9. `scene_path('map2', 'NA')` already resolves to `assets/img/scenes/map2-NA.png` and `scene_path('map2', 'world')` to `map2-world.png` (`scene_key()` accepts `map2`). No change to `scene.php` is needed.

---

## 1. The setting (a)

File: `game/includes/functions.php`, in `settings_schema()`, the line right after `journey_v2_open` (so it sits with `seals_open`, `world_v2_open`, `journey_v2_open`):

```php
'map_v2_open' => ['label' => 'Map v2: the lit floor region maps and the delve-down world map. Places off the road are spread over the cavern floor, each joined to its stop by a thick root; a list opens from the bottom of the map. Needs World v2 on (the new maps are drawn for that world); a region whose new picture or positions are missing keeps its old map. Off = the maps as before (2.8.93)', 'type' => 'select', 'default' => '0', 'options' => ['0' => 'Off', '1' => 'On']],
```

No migration: `setting()` falls back to the schema default.

### 1.1 The three gates (new file `game/includes/map_v2.php`)

```php
function map_v2_on(): bool                    // setting('map_v2_open') === '1'. Not cached in a static (tests flip it).
function map_v2_region_on(string $code): bool // map_v2_on() && scene_path('map2', $code) !== '' && rl_spread_fits($code)
function map_v2_world_on(): bool              // map_v2_on() && world_v2_on() && scene_path('map2', 'world') !== '' && world2_layout() !== null
function map_v2_flush(): void                 // clears the statics of this file and of region_layout() (tests only)
```

Rule: a region is either fully v2 (new art, spread layout, new UI) or fully old. There is no mixed state, because the old art has the old trails painted in and the new art has the cavern floor the spread was planned on.

### 1.2 "Off = byte-for-byte" and how it is kept

- Every new branch starts with `map_v2_on()` or one of the two gates above. With the setting at 0 none of them is taken.
- `region_map_svg()`, `world_map_svg()` and `map_positions()` keep their bodies. Each gets one early-return line (sections 4 and 5). No other line of those bodies is edited.
- `region_layout($code)` keeps returning the same array when the gate is false (section 3.4).
- Guarded by a golden-hash test recorded on the unmodified code in slice 0 (section 8.1).

---

## 2. Art files (b)

| Map | New file | Size | Used when | Else |
|---|---|---|---|---|
| Region | `game/assets/img/scenes/map2-<CODE>.png` (14 files, codes as in `REGION_MAP`) | 480 x 270 | `map_v2_region_on($code)` | `map-<CODE>.png` as today |
| World | `game/assets/img/scenes/map2-world.png` | 640 x 360 | `map_v2_world_on()` | `map-world.png` as today |

The old files are never deleted or overwritten.

Code changes (all in `maps.php` unless noted):

```php
function world_art_path(): string    // add first line: if (map_v2_world_on()) return scene_path('map2', 'world');
function region_art_path(int $regionId): string   // after $code is read: if ($code !== '' && map_v2_region_on($code)) return scene_path('map2', $code);
// new, in map_v2.php: the same by code, for callers that already hold the code
function map_art_path(string $code): string   // map_v2_region_on($code) ? scene_path('map2', $code) : scene_path('map', $code)
```

- `here_view.php:182`: replace `scene_path('map', $code)` with `map_art_path($code)` (it already uses `region_layout($code)`, which follows the same gate, so picture and pins stay in step).
- `world.php:137,146,164`: unchanged. They call `world_art_path()` / `region_art_path()`, which now answer for v2 too.
- Cache busting: v2 pictures are linked as `url($art) . '?v=' . rl_spread_ver()` (section 3.5), so a phone never shows an old picture under new positions.

---

## 3. Region layout data (c)

### 3.1 The data file

`game/includes/data/region_spread.json`

```json
{
  "_meta": {
    "v": 1,
    "sig":   { "NA": "5f0c1a2b", "CA": "..." },
    "slugs": { "NA": { "18": "v-na-2-1", "245": "v-na-5-1" }, "CA": { } }
  },
  "NA":  { "18": [141, 143], "19": [280, 114], "245": [369, 160] },
  "CA":  { },
  "...": { }
}
```

- Top-level keys that are region codes hold `{"<slot id>": [x, y]}`: one entry per off-road slot (`type === 'off'`) of that region's layout, integers, in the 480 x 270 frame. This is the format the owner asked for.
- `_meta` is the only other key (keys starting with `_` are never region codes; same convention as `here_layouts.json`). It makes the file safe on a live site:
  - `sig[CODE]`: a fingerprint of the road skeleton the spread was planned on. `rl_stop_sig()` below. If the site's layout has other stop positions (for example `world_v2_open` is off, or a road changed), the region does not fit and stays on its old map.
  - `slugs[CODE][id]`: the location slug of each id. Slot ids are database ids; world v2 places get theirs when the setting is switched on. If an id's slug on the site is not the recorded one, the loader finds the off slot with that slug in the same region and uses its id instead.
  - `v`: bumped by hand when the format changes.

### 3.2 Building it: `tools/map_v2/spread_build.php`

`php tools/map_v2/spread_build.php PLANS_DIR [--check]`

1. Boot a throw-away SQLite game the way `tools/map_layout.php` does (migrate, default settings, `seed_starter_content()`), then `set_setting('world_v2_open', '1')`, `setting('__reload__')`, `world_v2_boot()`.
2. For each of the 14 codes: `$L = region_layout($code, false)` (v1 layout, section 3.4). Read `PLANS_DIR/plan-<CODE>.json`, key `spread`. Assumed shape, the output of `spread_helper.relax()`: `{"<slot id>": [x, y], ...}` with one decimal. If the planners write another shape (for example a list of `{id, x, y}`), this is the only place to adapt.
3. Validate (fail with a list, write nothing): every key is an off slot of `$L`; every off slot has a key; all the rules of section 8.2 hold.
4. Round to integers, sort by id, write `region_spread.json` with `_meta.sig[CODE] = rl_stop_sig($L)` and `_meta.slugs`.
5. `--check`: do steps 1 to 3 against the committed file instead of the plans and exit 0 or 1 (used by nobody in CI; the PHP test covers the same ground on the installed copy).

### 3.3 Loader functions (`map_v2.php`)

```php
/** region_spread.json, read once. [] when missing or not valid JSON. */
function rl_spread_all(): array

/** crc32 (8 hex) of every non-off slot, sorted by id: "id:type:x,y;" . The road skeleton the spread and the map2 art are drawn on. */
function rl_stop_sig(array $L): string

/** The spread of one region resolved against the site's v1 layout: [slot id => [x, y]] (ids remapped by slug where needed), or null when it does not fit. */
function rl_spread_for(string $code): ?array

function rl_spread_fits(string $code): bool   // rl_spread_for($code) !== null
```

`rl_spread_for()` returns null (region stays old) when any of these holds: no entry for the code; `_meta.sig[CODE] !== rl_stop_sig(region_layout($code, false))`; an entry resolves to no off slot (neither by id + slug nor by slug); a point is outside the frame. An off slot with **no** entry does not fail the fit: it keeps its v1 position (the test in 8.2 is what demands full coverage for the shipped data). The result is cached in a static per code (it does not depend on the setting).

### 3.4 `region_layout()` gets a variant

`region_layout.php`:

```php
function region_layout(string $code, ?bool $v2 = null): ?array
{
    static $cache = [];
    if ($v2 === null) { require_once __DIR__ . '/map_v2.php'; $v2 = map_v2_region_on($code); }
    $k = $code . ($v2 ? '|2' : '');
    if (array_key_exists($k, $cache)) return $cache[$k];
    $L = array_key_exists($code, $cache) ? $cache[$code] : ($cache[$code] = region_layout_build($code));   // v1, built once
    if (!$v2 || !$L) return $cache[$k] = $L;
    return $cache[$k] = rl_apply_spread($L, (array)rl_spread_for($code));
}
```

- `region_layout_build()` is not touched.
- `null` (every existing caller) follows the gate, so `region_map_svg`'s replacement, `here_routes_map()` and `compass_between()` all see the layout that is on screen.
- `false` always gives v1. Used by `rl_spread_for()`, `tools/map_v2/spread_build.php` and, new, by `tools/map_layout.php` (change its one call to `region_layout((string)$code, false)`), so `tools/map_layout.lua` and the `--check` art sync stay about the old art whatever the setting says.
- `map_v2_flush()` needs to reset this static: move `$cache` to `$GLOBALS['gv_rl_cache']` or add a tiny `region_layout_flush()` beside it. Either is fine; pick the second.

### 3.5 `rl_apply_spread(array $L, array $spread): array` (pure, in `map_v2.php`)

Returns a copy of the v1 layout with these changes and nothing else:

1. `$L['v'] = 2`.
2. Each off slot with a spread point: `x0`, `y0` = its v1 position (kept for tools), `x`, `y` = the spread point clamped to `[r + 6, W - r - 6]` x `[r + 6, H - r - 6]`.
3. Each off slot gets `near` = its `anchor` if not 0, else the id of the nearest slot of type `stop` or `town` (same rule as `spread_helper.py`). `near` is what the UI groups by. `anchor` is not changed.
4. Each off slot gets `role` (section 6). Road stops and the town get `role` too.
5. `clear`: the circle of each moved slot is moved with it.
6. `roads`, `exits`, `pin`, and every `town` / `stop` / `far` slot: untouched.
7. `trails`, one per v1 trail, same order, same `from` and `to`:

| key | value in the v2 layout |
|---|---|
| `pts` | still exactly two points: `[[ax, ay], [x, y]]`, the stop and the place's **spread** position. The chord of the root. |
| `bow`, `heading`, `ctrl` | **copied unchanged from the v1 trail.** See 3.6. |
| `root` | new: `['c' => [cx, cy], 'len' => L]`, the control point of the drawn root (below) and the chord length. |
| `bow2`, `heading2`, `ctrl2` | new: `rl_trail_heading($L['roads'], from, pts[0], pts[1])` on the spread position. For tools and reports only. |

The drawn root is a quadratic curve `M ax ay Q cx cy x y`. Its control point is one pure function, the formula of the mockup with a cap for short roots:

```php
/** Control point of a root from stop $a to place $b: the chord's middle pushed sideways (to the left of a->b on screen) by min(10, 0.2 x length). Ints. */
function rl_root_ctrl(array $a, array $b): array
{
    $dx = $b[0] - $a[0]; $dy = $b[1] - $a[1]; $len = hypot($dx, $dy) ?: 1.0; $k = min(10.0, 0.2 * $len);
    return [(int)round(($a[0] + $b[0]) / 2 - $dy / $len * $k), (int)round(($a[1] + $b[1]) / 2 + $dx / $len * $k)];
}
```

"Short": the test in 8.2 holds every root to a chord of at most 140 units and reports the longest. Roots are drawn by the game, not painted in the art, so art and lines cannot drift.

An off slot whose `anchor` is 0 (no side path in the data) has no trail in v1 and gets none in v2: it is listed under its `near` stop, with no root. The test prints how many there are.

### 3.6 The Trail map direction rule: what must not break, and how

The rule (2.7.08, `rl_trail_heading`): a side trail's Trail map leaves the stop leaning the way the road runs and bows to the side the place lies on. Its outputs `bow` / `heading` / `ctrl` were dumped to `tools/map_layout.lua` and the Trail maps were generated from that dump.

Exactly what this plan does:

1. `rl_heading8()` and `rl_trail_heading()` are not edited. Their unit checks in `tests/region_trails_gates.php` run unchanged.
2. In the v2 layout a trail's `bow`, `heading` and `ctrl` are the v1 values, copied. A Trail map that was drawn for a side trail keeps the turn it was drawn with, whichever map style is switched on. Moving a marker on the region map never changes a Trail map.
3. `pts` stays two points, so the "every side trail" loop of `tests/region_trails_gates.php` passes on a v2 layout as well (two points, a bow, a heading, a control point).
4. `tools/map_layout.php` asks for `region_layout($code, false)`, so `tools/map_layout.lua` and `--check` are byte-identical before and after this work, with the setting on or off.
5. `compass_between()` is not edited. It reads slot x, y from `region_layout($code)`, so the compass word on a route card matches the region map the gnome is looking at (v2 positions when v2 is on). `tests/map_fixes.php` section 2 compares it with the same slots and passes in both modes.
6. Known and accepted: for a place the spread moved to the other side of its road, the card compass (v2) and the Trail map's first turn (v1) can differ. `bow2` / `heading2` exist so this can be seen: `tools/map_v2/spread_build.php` prints "N of M roots change side (bow2 != bow)" with their ids, and the planners should prefer spread points on the v1 side of the road when the floor allows it. It is a report, not a failure. If the owner later wants the Trail maps regenerated from the spread, the generator reads `bow2` / `heading2` instead; nothing in the game changes.

### 3.7 The layout version cache

```php
/** 8 hex chars: sha1 of region_spread.json + world_v2_layout.json contents (static, read once). '0' when neither exists. */
function rl_spread_ver(): string
```

Used in three places: the `|2` layouts are keyed per request in the `region_layout()` static (3.4); `?v=<ver>` on `map2-*.png` links; `data-lv="<ver>"` on the map widget, which `mapv2.js` puts in its `sessionStorage` key (`gv-mapv2:<region>:<ver>`) for the remembered zoom, centre and selected stop, so a changed layout drops a remembered view instead of opening on empty rock. Nothing is written to the database or to disk.

---

## 4. World map (d)

### 4.1 Data: `game/includes/data/world_v2_layout.json` (exists; written by `tools/map_v2/world.py`)

Used keys, all in native pixels of the 640 x 360 art:

- `regions.<CODE>`: `x`, `y` (cavern floor centre), `rx`, `ry` (half-axes), `band`, `tier`, `label` `[x0, y0, x1, y1]` (name plaque box). All 14 codes.
- `hub`: `x`, `y`, `rx`, `ry`, `label_y` (Mossbottom: 582, 80).
- `routes.<A>-<B>`: the centre line of the glowing thread as a list of points, drawn from A to B. `route_order`: draw order.
- `ruler.bands[]`: `band`, `lv`, `y0`, `y1`, `colour` (green 1-15, cyan 15-25, gold 25-35, orange 35-45, violet 45-55).
- `start` (the lantern) is not used by the game in this plan.

### 4.2 Functions (`map_v2.php`)

```php
function world2_layout(): ?array                 // the JSON, read once; null unless w=640, h=360, all REGION_MAP codes present, hub present
function world2_xy(float $x, float $y): array    // art pixel -> map unit: [(int)round($x * 1000 / 640), (int)round($y * 560 / 360)]
function world2_route(string $a, string $b): ?array   // routes["A-B"] in units, or routes["B-A"] reversed, or null
function map_poly_at(array $poly, float $t): array    // the point at fraction t (0..1) of the polyline's length
function map_poly_d(array $poly): string              // 'M x y L x y ...' (ints)
function map_positions_v2(): array               // [location id => [x, y]] in units; fills $GLOBALS['gv_side_of'] and $GLOBALS['gv_road_curves']
function world_map2_svg(array $u, ?int $sel = null): string
```

Hooks in `maps.php` (one line each, first statement of the function, before the `static`):

```php
function map_positions(): array     { if (map_v2_world_on()) return map_positions_v2(); ... }
function world_map_svg(...): string { if (map_v2_world_on()) return world_map2_svg($u, $sel); ... }
```

`maps.php` adds `require_once __DIR__ . '/map_v2.php';` with its other requires.

### 4.3 `map_positions_v2()`

The view box stays 1000 x 560, so `site.js` `gvMaps()`, the tap card and every marker size keep working.

1. Hub: `world2_xy(hub.x, hub.y)`. Market of a region: `world2_xy(regions[code].x, regions[code].y)`.
2. Each row of `roads` (ordered by id): codes of its first and last node's regions give the route. `poly = world2_route(a, b)`. If null (a road the art does not know): the straight line between the two positions, and the test in 8.3 fails for a world-v2-on install.
   - A dead-end road (last node is not a market): cut the polyline where it first comes within 0.85 of the far region's ellipse (`((x-cx)/rx)^2 + ((y-cy)/ry)^2 <= 0.85^2`); the last node sits at that cut.
   - Stop i of n nodes sits at `map_poly_at(poly, i / (n - 1))`.
   - Two stops of one road closer than 12 units: slide the later one along the polyline until 12 apart (one forward pass; same floor as `tests/map_fixes.php` uses today).
   - Append `['poly' => $poly, 't' => [node id => fraction]]` to `$GLOBALS['gv_road_curves']`.
3. Off-road places are **not drawn on the v2 world map** (a cavern is about 80 x 27 units; 38 places do not fit; the region map is where they live). They still get a position, because `player_map_pos()`, `here_route_bearing()` and the `compass_between()` fallback read one: the position of their side-path stop (`gv_side_of`, same rule as today) moved 6 units towards the region centre; with no stop, the region centre.
4. All points are ints inside 0..1000 x 0..560.

`player_map_pos()` (`maps.php:260`): inside the existing loop add one branch, `if (isset($rc['poly'])) return array_map('intval', array_map('round', map_poly_at($rc['poly'], $tf + ($tt - $tf) * $t)));` before the `map_bez` line. With v2 off no entry has `poly`, so the old path is unchanged.

### 4.4 `world_map2_svg()`

Same outer markup as today so `gvMaps()` binds it: `<div class="mapzoom" data-me="x,y">`, `.mapctl`, `<svg class="worldmap art v2" viewBox="0 0 1000 560">`, `.mapcard`, `form.mapgo`. Inside, in paint order:

1. Rock rect and `pixel_image(map2-world.png?v=…, 0, 0, 1000, 560, '', '', 'none', 'mapart')`.
2. Level ruler from `ruler.bands`: on the left edge, per band a small colour swatch (`fill` = `colour`) and the text `Lv <lv>` in a dark plate. Group `class="w2ruler"`.
3. Roads: for each row of `roads` with a route, `<path class="roadcase">` (dark, 5) then `<path class="road">` (cream, 3, `stroke-dasharray="7 6"`) with `d = map_poly_d(poly)` and the road name as `<title>`. These follow the art's thread exactly because they are the same points. Roads without a route are skipped.
4. Regions, one `<a class="region" href="world.php?tab=map&r=ID#regionmap">` each: an `<ellipse class="hit">` of `rx + 14`, `ry + 14` units; the selected region gets a gold ellipse ring; the seek glow as today (ellipse); `map_mark()` at the centre with the town icon (dim when not open); the region name in a dark plate centred in `label`; under it `🥾 not yet visited` / `🔒 Lv N` / `Lv N` with today's wording and rule (`can_fast_travel`, `visited_regions`, `min_level`); guide and Puzzle Pal badges as today.
5. `lod2`: every road stop as today's dot (`data-place`, `data-name`, `data-what`, `data-go`, `data-route`, `data-steps`, `data-here`), found or `❔`. No off-road dots, no side trails.
6. Gardens, seek targets, folk bubbles, hub (`🍄 Mossbottom` at the hub, name at `label_y`), and the hat on top: the same blocks as `world_map_svg`, reading `$pos`.

To avoid two copies of blocks 5 and 6 drifting, move each of those blocks of `world_map_svg` into a private helper **only if** the golden test of 8.1 stays green after the move (pure cut and paste, same string out). If that is not trivially true, copy them into `world_map2_svg` and leave `world_map_svg` alone. Off-is-unchanged wins over tidiness.

### 4.5 `world.php`

No edit for the world map: the help text under it stays. One new sentence is appended only when `map_v2_world_on()`: "Deeper caverns are for higher levels: the ruler on the left shows the band."

---

## 5. Region map UI on a phone (e)

### 5.1 Entry point

```php
/** The v2 region map widget (map, controls, bottom sheet, stop list), or '' when this region is not on v2. */
function region_map_block(array $u, int $regionId, int $selId = 0, bool $focus = false, int $nearId = 0): string
```

- `world.php:150-157`: before the existing `<div class="regionmapbox" id="regionmap">` branch, `$mv2 = region_map_block($u, $mapRegion, $goId, false, (int)($_GET['near'] ?? 0));`. When not `''`: print `<div class="regionmapbox" id="regionmap">` + `region_nav()` + `$mv2` + a short help line, and skip the old `.rzoom` block and the emoji legend. Else the old markup, untouched. The myc branch above it is not reached, because `region_art_path()` is not `''`.
- `place_ui.php` `go_map_html()`: `$map = region_map_block($u, $rid, $goId, true);` first; when `''`, the existing code.
- `layout.php`, beside the other per-page scripts: `<?php if (!$admin && $page === 'world.php' && setting('map_v2_open') === '1'): ?><script src="<?= e(url('assets/mapv2.js?v=' . APP_VERSION)) ?>" defer></script><?php endif; ?>`. It comes after `site.js`; it does not use `gvZoomPan` (5.4), so order does not matter. `site.js` is not edited: its `gvRegionZoom()` looks for `.rzoom`, which the v2 widget does not have.

`?near=<stop id>` is a new, read-only query parameter of `world.php` (cast to int; ignored unless it is a `stop` or `town` slot of the region shown).

### 5.2 Markup (server-rendered, works with no JavaScript)

```html
<div class="mv2" data-region="NA" data-lv="5f0c1a2b" data-sel="15" data-here="212 140">
  <div class="mv2-vp" tabindex="0" role="group" aria-label="Map of The Maplewold. Drag to look around, plus and minus to zoom.">
    <svg class="regionmap art mv2-svg sel" viewBox="0 0 480 270" role="group" aria-label="Map of The Maplewold"> … </svg>
    <div class="mv2-ctl" hidden>
      <button type="button" class="btn small" data-z="in" aria-label="Zoom in">＋</button>
      <button type="button" class="btn small" data-z="out" aria-label="Zoom out">−</button>
      <button type="button" class="btn small alt" data-z="fit" aria-label="Fit the whole map">Fit</button>
    </div>
    <section class="mv2-sheet open" aria-label="Places near the chosen stop">
      <button type="button" class="mv2-hd" aria-expanded="true" aria-controls="mv2-rows-NA">
        <span><b class="mv2-t1" aria-live="polite">Near Poppyburrow</b><small class="mv2-t2">3 found, 2 not found yet</small></span><span class="mv2-ch">Hide</span>
      </button>
      <div class="mv2-rows" id="mv2-rows-NA">
        <ul class="mv2-grp" data-stop="15"> … rows … </ul>
        <ul class="mv2-grp" data-stop="16" hidden> … </ul>
      </div>
    </section>
  </div>
  <nav class="mv2-stops" aria-label="Stops with places off the road"> … </nav>
  <ul class="maplegend mv2-legend" aria-label="Map key"> … </ul>
</div>
```

Inside the SVG, in paint order (all colours as SVG attributes; no `style`):

1. `<rect class="rock">` and `<image class="mapart" href="map2-NA.png?v=…">`.
2. `<rect class="mv2-dim" fill="#0e0f09" opacity="0.34">` (CSS shows it only under `.mv2-svg.sel`).
3. Roads: the same segments, classes and widths as `region_map_svg` today (`rcase` 9, `road` 5, `unwalked` dashed, `<title>` = road name). Roads stay lines.
4. Roots, one group per layout trail, drawn for **every** trail, found or not:
   - `<g class="mv2-root found|unfound [on]" data-stop="15" data-id="18">`
   - found: `<path class="rc" stroke="#14110a" stroke-width="8">` then `<path class="rl" stroke="#f0c85a" stroke-width="4.2">`, round caps. CSS makes `.on .rl` 5.2 wide and `#ffe38a`.
   - not found: `<path class="rc" stroke="#14110a" stroke-width="6">` then `<path class="rl" stroke="#a39f8f" stroke-width="3.2" stroke-dasharray="1 6">`, round caps (reads as dots).
   - `d = 'M ax ay Q cx cy x y'` from the trail's `pts` and `root.c`. Widths are in map units, so roots grow with the zoom; they are never hidden at any zoom.
5. The route being followed (`dest_route_ids`): the gold `gps` path as today, straight between road slots, and along the root's curve for a stop-to-place leg.
6. Places (off slots), each `<g class="rmp mv2-p k-<kind> found|unfound [on] [here]" data-stop="<near>" data-id="<id>" transform="translate(x y)"><g class="ms">…</g></g>`:
   - found: dark disc r 10.5 with a 2-unit ring in the kind colour (village `#f4ead0`, wonder `#f0c85a`, delve `#a98ae0`, lair `#e0624a`, haven `#7fc08a`), the kind glyph (the five small vector paths of the mockup, kept in one PHP array `MAPV2_GLYPH`), a name plate under it (dark rect, cream text 7.3, name cut at 15 characters), and today's badges (garden 🌱/🏡, ruins 🏚️, Puzzle Pal) at the same offsets as `region_map_svg`.
   - not found: disc r 9, dashed grey ring, the glyph as a dashed grey outline, **no name anywhere** (not in a plate, not in `<title>`, not in `aria-label`: all say "A place not found yet").
   - the link: `<a href="world.php?tab=map&r=R&near=<near>&at=<id>#regionmap" aria-label="…">` wrapping the visuals and `<circle class="hit" r="24" fill="#ffffff" fill-opacity="0">`. Where the gnome stands: `<g aria-current="location">` instead of a link, with the hat, as today.
7. Stops and the town (drawn over the places): cream disc r 6.6 (town: gold, r 8.4), a name plate above it for the town, for stops with places, and for the selected stop; unvisited stops show `❔` and no name, as today. A stop **with** places links to `?tab=map&r=R&near=<id>#regionmap` (selects it); a stop **without** places and every exit links to `world.php?go=<id>#gopanel` as today. Exits keep today's arrow marker and edge label.
8. `aria-label` of a stop with places: "Poppyburrow, 5 places off the road, 3 found".

The sheet, one `<ul class="mv2-grp" data-stop="ID">` per stop or town that has places (`near` grouping), `hidden` unless selected:

- First row: the stop itself. Icon, name, "Stop on the road" (or "Town"), role tag (section 6), `Go` (`<a class="btn small mv2-go" href="world.php?go=ID#gopanel">`), or "You are here".
- Then its places, found first, then by name. Found row: glyph icon, name, "`<Kind>` · off the road from `<stop>`" plus the role tag for villages and 🏚️ when in ruins, `Go` link. Not-found row: dashed glyph, "A place not found yet", "Wander off the road near `<stop>` to find it", a `?` chip, no link.
- Each row has `id="mv2-r-<place id>"`; `?at=<id>` adds class `at` to that row (a highlight ring), and the server puts the stop of `at` in `near`.
- Header: `Near <stop>` and "`F` found, `N` not found yet". With nothing selected: "Places off the road" / "Tap a stop or a place".

The stop list `<nav class="mv2-stops">`: one link per stop with places, most places first: name and a chip "`F`/`T` found", `href="?tab=map&r=R&near=ID#regionmap"`, `aria-current="true"` on the selected one.

Initial selection on the server: `near` if valid; else the `near` of `at`; else (Go tab, `$selId` set) the stop of `$selId`; else the stop the gnome stands at or near; else none.

What changes for the player, to be said plainly in the changelog: places off the road that have not been found now show on the map as a dotted root to a dashed mark with its kind, without a name. Today they are invisible. This is the approved mockup. If the owner would rather not show the kind, set the constant `MAPV2_UNFOUND_KIND = false` in `map_v2.php`: unfound marks then draw a `?` instead of the glyph (one branch in the place renderer and in the row icon).

### 5.3 CSS (`game/assets/style.css`, one new block `/* 2.8.93 Map v2 */`)

- Without JS (`.mv2` has no `.on`): `.mv2-vp` is a normal block, the SVG is `width: 100%; height: auto` (16:9), the sheet is static under the map with all selected rows open, the controls are `hidden`.
- With JS (`.mv2.on`): `.mv2-vp { position: relative; height: min(520px, 68vh); overflow: hidden; touch-action: none; }`, `.mv2-svg { width: 100%; height: 100%; }`, `.mv2-ctl` absolute top right, column, each button 44 x 44; `.mv2-sheet` absolute at the bottom, rounded top, header `min-height: 56px`, `.mv2-rows { max-height: 0; overflow: auto; }`, `.mv2-sheet.open .mv2-rows { max-height: min(300px, 45vh); }`, rows `min-height: 48px`, `.mv2-go { min-height: 44px; min-width: 44px; }`.
- Dimming: `.mv2-svg.sel .mv2-p:not(.on), .mv2-svg.sel .mv2-root:not(.on) { opacity: .45; }`, `.mv2-dim { display: none; } .mv2-svg.sel .mv2-dim { display: inline; }`.
- Marker scale and far-zoom: `.mv2-svg .ms { transform: scale(var(--zs, 1)); }` (the existing `.regionmap .ms` rule already covers it); `.mv2-svg.far .mv2-p:not(.on) .plate { display: none; }`.
- Focus: `.mv2-svg a:focus-visible .hit { stroke: var(--focus); stroke-width: 3; stroke-dasharray: 6 4; vector-effect: non-scaling-stroke; }` and `.mv2-vp:focus-visible { outline: 3px solid var(--focus); }`. `tests/css_lint.sh` demands a focus ring for `.regionmap a`; the SVG keeps the `regionmap` class so the existing rule at style.css:6531 applies as well.
- Sheet colours come from existing tokens (`--card`, `--ink`, `--line`), dark plate colours inside the SVG are fixed attributes (the art is dark in both themes).
- Wide screens: reuse the existing `min-width: 721px` breakpoint (no new breakpoint; `css_lint` has a ratchet): `.mv2.on .mv2-vp { height: auto; aspect-ratio: 16 / 9; max-width: 760px; margin: 0 auto; }`.
- Reduced motion: `@media (prefers-reduced-motion: reduce) { .mv2-rows, .mv2-sheet { transition: none; } }`. The only transition anywhere is the sheet's `max-height` (0.3s).

### 5.4 `game/assets/mapv2.js` (new, no inline script, no dependency)

One IIFE; binds every `.mv2:not(.on)`; adds `.on`; unhides `.mv2-ctl`. It keeps its own small view model instead of `gvZoomPan`, because the viewport is taller than 16:9 and the map must pan inside it.

State: `s` (screen px per map unit), `cx`, `cy` (map point at the centre of the visible area), `sel` (stop id or 0).

```
viewW(), viewH()      // .mv2-vp client size; visH = viewH - sheet header height (56) when the sheet is closed, - sheet height when open
sFit  = viewW / 480                                   // whole map visible
sHome = min(3.4, max(visH / 270, 1.4))                // opening zoom: the floor fills the height; never under 1.4 px per unit
sMax  = 3.4
apply(animate)        // clamp, then svg.setAttribute('viewBox', x y w h) with w = viewW / s, h = viewH / s, x = cx - w / 2, y = cy - visH / (2 s)
clamp()               // s in [sFit, sMax]; if 480 s <= viewW centre x, else keep the view inside 0..480; same for y with 270 and visH
render()              // --zs = clamp(0.8, 1.95 / s, 1.35) on the svg; class 'far' when s < 1.25; hit radius (below)
centerOn(x, y, animate)
select(stopId, placeId)   // toggles .on on [data-stop], .sel on the svg, shows the right .mv2-grp (hidden attr), fills the header texts from
                          // data-t1 / data-t2 on the group, aria-current in the stop list, opens the sheet, centres on the stop,
                          // scrolls row #mv2-r-<placeId> into view and gives it .at; history.replaceState to ?near=…&at=… (same URL the server reads)
```

The SVG uses `preserveAspectRatio="xMidYMid meet"`; because the view box always has the viewport's own aspect, there is no letterboxing and client-to-map conversion is linear.

Input:

- Pointer: `pointerdown` / `pointermove` / `pointerup` / `pointercancel` on `.mv2-vp` (not when the target is inside `.mv2-sheet` or `.mv2-ctl`). One pointer: drag pans after 6 px of movement (pointer capture then). Two pointers: pinch zooms about the midpoint. A click that follows a drag is swallowed (capture-phase `click` listener, as `gvZoomPan` does).
- Wheel: Ctrl or Alt + wheel zooms about the cursor; a plain wheel scrolls the page.
- Buttons: `＋` and `−` change `s` by 0.45 px per unit steps about the visible centre; `Fit` sets `s = sFit`, clears the selection, closes the sheet.
- Click on a place or a stop-with-places link (`a[href*="near="]` inside the widget, map or stop list): `preventDefault()`, then `select()`. Tapping the selected stop again clears the selection. Links to `world.php?go=` (Go buttons, plain stops, exits) are left alone and navigate.
- Sheet header button: toggles `.open`, `aria-expanded`, the word List / Hide, then re-centres on the selection.
- Keyboard, when `.mv2-vp` or anything inside the SVG has focus: arrow keys pan 48 px; `+` / `=` and `-` zoom; `0` fits; `Escape` clears the selection and closes the sheet. Enter on a marker is the native link activation, which runs the same click handler. `focusin` on a marker that is outside the visible area calls `centerOn()` for it. The sheet rows and the stop list are ordinary links and buttons in document order after the map.
- Resize / orientation change: `ResizeObserver` on `.mv2-vp` re-runs `clamp()` and `render()`.

Tap targets: on every `render()` each `.hit` circle gets `r = max(24, 22 / (s * zs))` map units inside the scaled `.ms` group, so the target is at least 44 x 44 CSS px at any zoom. With places at least 32 units apart (8.2) targets do not overlap from 1.4 px per unit up, which is the smallest opening zoom. Below that (after Fit) neighbouring targets can overlap; the topmost wins, which still selects a nearby stop, and the sheet rows (48 px) are the exact targets. Sheet rows, Go, the three map buttons and the stop list entries are 44 px or more by CSS.

Animation: a pan or zoom started by a button, a selection or the keyboard tweens the view box over 250 ms with `requestAnimationFrame`. When `matchMedia('(prefers-reduced-motion: reduce)').matches` it jumps. Dragging and pinching never animate. Nothing runs on a timer; nothing pulses.

Opening view: the remembered one for this `data-region` + `data-lv` if there is one; else zoom `sHome` centred on the selected stop; else on `data-here`; else on the town. In the Go tab (`$focus`) always centred on `data-here`.

No timers, no fail states: the widget only reads. A place that cannot be reached yet shows the same `world.php?go=` panel as today, which explains the way.

---

## 6. Story fields: a village's role (f)

Rule of master doc section 17: the road stops and the two story villages are the main line; every other village is a side quest.

Data file `game/includes/data/village_roles.txt` (same pipe format as the other data files):

```
# Villages off the road that belong to the main line of Wren's Journey (master doc 17). Every road stop is main line by rule.
# Every other off-road village is a side quest. Area code | village name | role
NA | Cattailmere | main
NA | Granitegate | main
```

Functions (`map_v2.php`):

```php
function village_roles(): array                       // ['NA' => ['Cattailmere' => 'main', ...]], read once
function village_role(string $code, array $slot): string
// 'main' : the town, a slot of type 'stop', or an off-road village listed as main
// 'side' : any other off-road slot of kind 'village'
// ''     : everything else (havens, wonders, delves, lairs, exits)
```

`rl_apply_spread()` writes it to `slots[id]['role']`. The UI shows a small tag in the sheet rows and in the stop row: `Main line` (class `tag`) or `Side quest` (class `tag alt`), only for places the gnome has found and only while `journey_v2_open` is on (with it off there is no main line to speak of). Not-found rows never show a tag, so the tag gives nothing away.

Reserved, not built here: `slots[id]['quest']`, the errand id of the village's side quest. The 17 side quests are not written yet (master doc 17, "Open") and `journey_errands.txt` is keyed by zone, not by village. When they exist, a fourth column `errand id` in `village_roles.txt` fills it and the tag can link to the quest.

---

## 7. Migration and risk (g)

- **Players: none.** No table, no column, no stored state. The feature only changes how maps are drawn, and only while the setting is on. Switching it off again restores today's maps at once.
- **A site where the data does not fit** (world v2 off, changed roads, missing picture): the gate is false per region, the old map shows. `php tools/map_v2/status.php GAME_DIR` (new, 20 lines) prints, per region, picture yes/no, signature match yes/no, off slots covered n of m, and the same for the world map, so an admin can see why a region is still old.
- **Discovery feel** changes: unfound places off the road become visible as dotted roots (5.2). Behind the setting; flagged for the owner.
- **Card compass vs Trail map turn** can differ for places the spread moved across their road (3.6 point 6).
- **Shared layout readers**: `here_routes_map()` and `compass_between()` move to the v2 positions together with the map, by design. `tests/map_fixes.php` and `tests/region_trails_gates.php` must pass with the setting on as well; the new test runs their invariants in both modes.
- **Performance**: `rl_apply_spread()` is a loop over about 50 slots; the JSON files are read once per request (about 25 KB together). The v2 region map prints roughly the same number of nodes as today plus the sheet rows.
- **Golden test brittleness**: a later, intended change to `region_map_svg()` must re-record the hashes (one command, 8.1). That is the point of the test.

---

## 8. Tests

`tests/map_v2.sh` (wrapper, same shape as `tests/world_v2.sh`) and `tests/map_v2.php GAME_DIR` (runs on a `walk.sh`-installed copy; `ok()` helper as in the other suites). Add `map_v2` to `DEFAULT_SUITES` in `.github/workflows/ci.yml`, on the line that holds `seals_standing … world_v2 …`. It is not self-installing, so nothing is added to `SELF_INSTALLING` in `tests/ci_suites.sh`.

### 8.1 Off = unchanged (golden hashes)

Fixture `tests/fixtures/map_v2_off.json`, written by `php tests/map_v2.php GAME_DIR --write-golden` **in slice 0, on the code before any other change**, and committed.

- The seeded gnome: a new user row made by the test (fixed name `mapv2probe`, level 1, home and place = the Maplewold's market, no discoveries, no plots, no active walk, no destination). Not `sprout`, whose state depends on the walk-through.
- Recorded with `map_v2_open` = 0 and `world_v2_open` = 0: for each of the 14 regions `sha1(region_map_svg($u, $rid))`, `sha1(region_map_svg($u, $rid, 0, true))` and `sha1(json_encode(region_layout($code)))`; `sha1` of `world_map_svg($u)` with the CSRF token value blanked by a regex; `sha1(json_encode(map_positions()))`.
- The same set recorded again after `world_v2_open` = 1 and `world_v2_boot()` (key `world_v2`), because that is the world the feature will be switched on in.

Checks:

1. `setting('map_v2_open') === '0'` on a fresh install.
2. With it 0: every hash equals the fixture (both worlds).
3. With it 1 but `region_spread.json` renamed away and `map_v2_flush()`: every region hash equals the fixture (fallback to old layout and old art).
4. With it 1, data present, one `map2-<CODE>.png` renamed away: that region equals the fixture, `region_art_path()` gives `map-<CODE>.png`, `region_map_block()` is `''`.
5. With it 1 and `world_v2_open` = 0: `map_v2_region_on()` is false for every region whose signature differs (expected: all 14), and `map_v2_world_on()` is false.
6. `tools/map_layout.php --check GAME_DIR` exits 0 with `map_v2_open` = 1 and world v2 on or off as the lua was made (it is pinned to v1 layouts).

### 8.2 Layout loader and spread data (world v2 on, map v2 on)

7. `region_spread.json` parses; its region keys are exactly the 14 codes of `REGION_MAP`; `_meta.sig` and `_meta.slugs` have the same 14.
8. For every region: `rl_stop_sig(region_layout($code, false))` equals `_meta.sig[$code]`; `rl_spread_for($code)` is not null.
9. **Coverage**: for every region the key set of the spread equals the set of off slot ids of the layout (no missing, no extra). Prints the totals (expected about 38 for NA).
10. **Inside the frame**: every spread point has `12 <= x <= 468` and `12 <= y <= 258` (480 x 270 with the marker's radius).
11. **Minimum distances** (constants at the top of the test; the run prints the real minimum of each so they can be tightened):
    - two off-road places: at least 32 units apart (44 px targets at 1.4 px per unit);
    - an off-road place and its own stop: at least 20;
    - an off-road place and any other stop, town or exit: at least 24;
    - an off-road place and any road segment it does not end on: at least 10 (not sitting on a road line).
12. **Roots**: every trail of the v2 layout has `count(pts) === 2`, `pts[1]` equal to the slot's x, y, `root.c === rl_root_ctrl(pts[0], pts[1])`, chord length at most 140; `bow`, `heading`, `ctrl` equal the v1 trail's with the same `from` and `to`; `bow2` and `heading2` are valid. Prints how many roots change side.
13. Roads, exits, pin and every non-off slot of the v2 layout are identical to v1. Off slots carry `x0`, `y0`, `near`, `role`.
14. Slug remap: load a copy of the data in which one id is replaced by an unused number, with its slug kept in `_meta.slugs`: the place still gets its spread point. A copy with a wrong `sig`: the region does not fit.
15. The invariants of the existing suites, run here with map v2 on: the "every side trail" loop of `region_trails_gates.php`, and `compass_between(from, to) === rl_heading8(slot delta)` for every trail (`map_fixes.php` section 2).
16. `rl_root_ctrl()` unit cases: a 100-unit horizontal root bends 10 to one side; a 20-unit root bends 4; a zero-length root returns the point.
17. `village_role()`: road stop = `main`, Cattailmere and Granitegate = `main`, Acornby = `side`, a wonder = `''`. In NA: 9 road stops + 2 = 11 main-line villages, 17 side-quest villages, 28 in all (master doc 17).

### 8.3 World map

18. `world2_layout()` is not null; all 14 regions; every centre and the hub inside 640 x 360; `world2_xy(640, 360) === [1000, 560]`.
19. Every row of `roads` (world v2 on) has a route (`world2_route()` not null), in one direction or the other.
20. `map_positions_v2()`: every market is at its region's converted centre; the hub at the converted hub; every road stop is within 2 units of its road's polyline and the stops of a road come in road order along it; neighbouring stops at least 12 apart; every position inside 0..1000 x 0..560; every location with a position today has one in v2.
21. `player_map_pos()` for a walk between two neighbouring stops, at steps 0, half and all: on the polyline (within 2 units) and between the two stops.
22. `world_map_svg()` with v2 on: contains `map2-world.png`, `viewBox="0 0 1000 560"`, one `a.region` per region, the hub link, a `class="road"` path per road with a route, the ruler group; contains no `stroke-dasharray="2 3"` side trail. With `map2-world.png` renamed away: equals the fixture hash.

### 8.4 Region UI (HTML checks on the rendered string, and one page fetch)

23. `region_map_block()` for the probe gnome in NA: contains `map2-NA.png?v=`, `class="mv2"`, one `.mv2-root` per layout trail, all of them `unfound` for a gnome who has found nothing, and **no name of an unfound place anywhere in the output** (loop over the off slots' names; none may appear).
24. After marking two places found for the probe (insert the `user_encyclopedia` rows the way `place_known()` reads them): their roots are `found` with `stroke-width="4.2"` and `#f0c85a`; their names appear; the sheet header for their stop reads "2 found"; each has a `Go` link to `world.php?go=<id>#gopanel`.
25. `?near=<stop>`: that stop's group is the only one without `hidden`; the svg has class `sel`; that stop's places and roots carry `on`. `?near=999999` and a `near` that is an off slot are ignored. `?at=<place>` selects the place's stop and marks its row.
26. Every `.hit` circle in the block has `r >= 22`. No `style="` and no `<script` in the block (CSP).
27. `curl` the page `world.php?tab=map&r=<NA id>` as the logged-in walk.sh player with the setting on: 200, contains `assets/mapv2.js`, contains `class="mv2"`, no PHP warning. With the setting off: contains neither.
28. `node --check game/assets/mapv2.js` when `node` is on the path (skipped with a note otherwise, as the other JS suites do).
29. `bash tests/css_lint.sh GAME_DIR` still passes (it is its own suite; named here because the new CSS touches what it guards).

Manual check before the owner switches it on (not CI): a phone at 390 px and at 320 px, portrait and landscape; drag, pinch, the three buttons, a stop, a place, the sheet, Go; keyboard only on a desktop; "reduce motion" on; dark and light theme.

### 8.5 Version and changelog

- `game/includes/bootstrap.php`: `APP_VERSION` 2.8.92 to 2.8.93.
- `CHANGELOG.md`, new top entry:

```
## 2.8.93
- **Map v2 (off by default; Admin, Settings, `map_v2_open`; needs World v2).** New lit floor region maps (`map2-<CODE>.png`) and the delve-down world map (`map2-world.png`). On a region map, places off the road are spread over the whole cavern floor and each hangs on its stop by a thick root: gold for places you have found, dotted grey with no name for places you have not. Tap a stop or a place to pick that stop: the rest dims and a list slides up from the bottom (Near the stop, how many found, a row per place with Go). Drag to pan, pinch or ＋ − to zoom, Fit for the whole map; works from the keyboard and respects reduced motion. Villages carry a Main line or Side quest tag. On the world map the roads follow the painted threads and a ruler shows the level bands. A region whose new picture or positions are missing keeps its old map; with the setting off every map is exactly as before. No update zip in this step. Test `tests/map_v2.sh`.
```

No update zip is built and nothing is committed by the implementer of a slice unless the orchestrator says so.

---

## 9. Build order, in small slices (h)

Each slice leaves the game working and the suite green. "Off-test" = checks 1 and 2 of 8.1.

| # | Slice | Files | Done when |
|---|---|---|---|
| 0 | Golden fixture on untouched code | `tests/map_v2.php` (probe gnome + `--write-golden` + checks 1, 2), `tests/map_v2.sh`, `tests/fixtures/map_v2_off.json`, `.github/workflows/ci.yml` (+`map_v2`) | Off-test passes on the current code |
| 1 | Setting and gates | `functions.php` (setting), new `map_v2.php` with `map_v2_on()`, stubs of the two gates returning false, `map_v2_flush()`; `maps.php` require | Setting shows in admin beside `journey_v2_open`; off-test green |
| 2 | Spread data tooling | `tools/map_v2/spread_build.php`, `game/includes/data/region_spread.json` (built from `plans/plan-<CODE>.json`) | Tool validates and writes all 14 regions; prints minimum distances and side changes |
| 3 | Layout loader | `map_v2.php`: `rl_spread_all`, `rl_stop_sig`, `rl_spread_for`, `rl_spread_fits`, `rl_root_ctrl`, `rl_apply_spread`, `rl_spread_ver`; `region_layout.php`: the `$v2` argument and `region_layout_flush()`; `tools/map_layout.php` pinned to `false` | Checks 6 to 16 green. Gate still false in the game (no art hook yet), so nothing on screen changes |
| 4 | Roles | `data/village_roles.txt`, `village_roles()`, `village_role()` | Check 17 |
| 5 | Region art switch | `map_v2_region_on()` real; `region_art_path()`, `map_art_path()`, `here_view.php:182` | Checks 3 to 5. With the setting on, the old region map markup now sits on the new art with spread positions: correct but plain. Acceptable only on a dev copy; do not release between 5 and 6 with the setting on |
| 6 | Region widget, server side | `map_v2.php`: `region_map_block()`, `region_map2_svg()`, `map2_sheet_html()`, `map2_stops_html()`, `MAPV2_GLYPH`; `world.php`, `place_ui.php`; CSS no-JS part | Checks 23 to 26; usable with JavaScript off (`?near=`, `?at=`) |
| 7 | Region widget, phone behaviour | `assets/mapv2.js`, `layout.php` script line, CSS `.mv2.on` part, reduced motion, focus | Checks 27 to 29; manual phone pass |
| 8 | World positions | `world2_layout()`, `world2_xy()`, `world2_route()`, `map_poly_at()`, `map_poly_d()`, `map_positions_v2()`; hook in `map_positions()`; `player_map_pos()` poly branch; gate `map_v2_world_on()` real | Checks 18 to 21 |
| 9 | World drawing | `world_map2_svg()`, hook in `world_map_svg()`, `world_art_path()`, help sentence in `world.php` | Check 22; `gvMaps()` zoom, tap card and Set off still work on the new map |
| 10 | Status tool, version, changelog | `tools/map_v2/status.php`, `bootstrap.php`, `CHANGELOG.md`, `claude/IMPLEMENTATION-STATUS.md` line | Whole suite green with the setting off (CI default) and `tests/map_v2.sh` green |

Slices 2 and 5 wait on the art side (the plan JSONs and the 14 `map2-<CODE>.png`). Slices 0, 1, 3 (against a hand-made two-region spread file in the test), 4, 8 and 9 can start now: the world JSON and `map2-world.png` are already in the tree.

---

## 10. Open points for the owner

1. Unfound places show their kind as a dashed outline (mockup). Say if they should be a plain `?` instead (`MAPV2_UNFOUND_KIND`).
2. Off-road places are not drawn on the v2 world map (they do not fit in a cavern at that scale); the region map is where they are. Road stops still show when zoomed in.
3. The Trail map turn of a side trail stays as drawn (v1) even where the spread moved the place across the road. Regenerating Trail maps from the spread is possible later (`bow2` / `heading2`) and is not part of this plan.
4. The role tag shows only while `journey_v2_open` is on. Say if it should show always.

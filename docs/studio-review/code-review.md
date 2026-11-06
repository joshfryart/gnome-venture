# Code review: redundancy and streamlining (behaviour-identical only)

Reviewer: lead-programmer + tools-programmer (tech-debt scan method, code-review lens). Branch ccr-c58baef6-w75eu7, v2.4.63.
Scope: `game/*.php`, `game/includes/*.php`, `game/assets/*.js`. Nothing under `game/` was edited. Nothing committed.

## Baseline

- `php -l` on all 346 `.php` files in `game/` and `tests/`: **no problems in `game/`**. One expected hit: `tests/combat_math_golden.php:8` "Cannot redeclare random_int()". That is deliberate. The test is meant to run with `php -d disable_functions=random_int` (see its header, lines 5-8). It is not a defect, but a lint sweep over `tests/` will always flag it.
- Tests: `tests/ci_suites.sh` copies `game/` to a temp dir, installs via `tests/walk.sh` (SQLite, `php -S`, `tests/router.php`), then runs `tests/<suite>.sh`. A suite fails on a line starting `FAIL`, `N FAILED`, a PHP fatal, or non-zero exit. PHP 8.3.6 with pdo_sqlite is present here.
- Ran `bash tests/ci_suites.sh health`: **ok health, 1 suites, 0 failed** . Use `health` as the quick smoke suite. For anything touching bootstrap/upgrade use `walk` (and `updrollback`, `fix100`); for JS-only changes use the suite of the page touched (`memory`-family pages have no dedicated suite; `puzzles.sh`, `games2.sh`, `fun.sh` are the nearest).
- Functions: 2,763 definitions (game/ only), **no name defined twice**. Whole-file scan found no exact-body duplicate above 160 chars, so the codebase is already tidy. Remaining duplication is small and listed below.

## Findings, prioritized

### P1. Unused functions (dead code). Risk: low
Method: every name grepped with word match across all of `game/` and `tests/` (php, js, sh, py) plus `docs/`, `claude/`, `tools/`. Each has exactly one hit, its own definition. No `call_user_func`, variable-function or string-built-name use exists in `game/` for these prefixes.

| Function | Evidence |
|---|---|
| `trek_choice` | game/trek.php:200 |
| `is_calling` | game/includes/gnome.php:199 |
| `rebuild_targets` | game/includes/rebuild.php:76 |
| `tool_shed_owned` | game/includes/tools.php:413 |
| `upgrade_100_pending` | game/includes/upgrade100.php:52 |
| `today_social_top` | game/includes/today_social.php:19 |
| `game_clear` | game/includes/games.php:81 |
| `tm_spots` | game/includes/tilemap.php:44 |
| `pal_stamp_count` | game/includes/pals.php:252 |
| `dm_here_note` | game/includes/delve_map.php:302 |
| `local_level`, `local_visit_key` | game/includes/local.php:16, :21 |
| `npcs_around`, `shop_region_name` | game/includes/world.php:233, :247 |
| `current_hire` | game/includes/hired_help.php:57 |
| `social_hollow_day` | game/includes/social.php:155 |
| `zone_select` | game/includes/functions.php:938 |
| `stext_html`, `stext_box` | game/includes/site_text.php:80, :86 |
| `market_today_card` | game/includes/market100.php:859 |
| `scene_shop_banner` | game/includes/scene.php:222 |

Keep (not dead by intent): `upgrade_unlock` (upgrade100.php:37) is the pair of the used `upgrade_lock` (bootstrap.php:84). Remove only if you confirm the lock is released by process end.
Proposed change: delete each function body (plus its docblock). If a file becomes empty of live code, check `local.php` (only these two functions? then the file may be deletable; grep `local.php` includes first).
Verify: `php -l` on each edited file, then `bash tests/ci_suites.sh health walk`; re-run the word-grep for each name returning zero hits.
Caveat: the instruction says function signatures are shared across sections (graphify-out/SECTIONS.md). Check that file for the names above before deleting; if a name is listed as shared API, leave it.

### P2. Byte-identical helper pairs. Risk: low
1. `alchemy_item_id()` game/includes/alchemy.php:92 and `trek_item_id()` game/includes/trek.php:256 have identical bodies (static slug to id cache over `SELECT id FROM items WHERE slug = ?`). 95 call sites combined.
   Change: keep both names (shared signatures) but make one delegate: `function alchemy_item_id(string $s): int { return trek_item_id($s); }`, with a `require_once trek.php`-independent home. Simplest: put a single `item_id_by_slug()` in `includes/items.php` and make both one-line wrappers. Behaviour (cache keyed on slug, returns 0 when missing) stays identical.
2. `tm_n()` tilemap.php:319 = `tk_n()` trek_art.php:45 (number formatter). `tm_h()` tilemap.php:324 = `tk_h()` trek_art.php:40 (tile hash). 29 combined call sites.
   Change: keep the `tk_*` / `tm_*` names, make `tm_*` the body and `tk_*` a one-line wrapper (or vice versa). The two files are not always co-loaded (delve_map.php requires tilemap.php then trek_art.php at :315; trek.php requires trek_art.php alone), so wrapper must live in the file that is always loaded, or the wrapper file must `require_once` the other.
Verify: `bash tests/ci_suites.sh delvemap delvestamp delvefloors treks`; `tests/balance*.php` need no change.

### P3. 82 inline `SELECT id FROM items WHERE slug = ?` lookups. Risk: low to med
Examples: gardens.php:305,515; seed.php:36; garden_logic.php:1364,1482; flowers.php:417,504; tools.php:231,372; garden_critters.php:270,313; catalog.php:125. Several wrap it in a local closure (`$id = fn($slug)=>...`, gardens.php:515, seed.php:36, catalog.php:125).
Change: introduce `item_id_by_slug(string $slug): int` (uncached variant; `(int)q_val(...)`) next to P2's helper and replace the closures and `(int)q_val(...)` one-liners. Do NOT swap in the cached version at seed/install sites (items are inserted during the run; a cached 0 would change behaviour). Leave the `if ($id = q_val(...))` truthiness sites (art_upload.php:33,42, jobs.php:274) alone, they use a non-cast value.
Verify: `walk`, `fix100`, `garden100`, `flowers`, `security190` suites. Do it a file at a time.

### P4. JS: copy-pasted effect helpers across the small game scripts. Risk: low to med
- Reduced-motion probe `var rmq = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : { matches: false };` is pasted in 8 files: letters.js:7, marrow.js:8, memory.js:7, mushroom.js:8, pest.js:8, race.js:7, spit.js:10, worms.js:7. A function form `reduce = function(){...}` is pasted in 5 more: tilemap.js:9, trekfight.js:315 and :514 (twice in one file), trekmap.js:6, trekscene.js:6.
- `centre(el)` identical in memory.js:24, mushroom.js:26, worms.js:23.
- `petals()` near-identical in memory.js:26, mushroom.js:27 (identical, 34 petals, 2.2+1.6 s), letters.js:10 (30 petals, 2.2+1.4 s; differs in two constants).
- `burst(x,y,kind,n)` identical in memory.js:10 and mushroom.js:12; worms.js:9 differs only in constants (18/26 vs 16/24, size 3 vs 4) so do NOT merge that one without parameters.
- `seenGet/seenSet` identical in marrow.js:12-13 and race.js:10-11 (only KEY differs).
Change: add one tiny shared object to `early.js` (45 lines, loaded non-deferred on every page, layout.php) e.g. `window.gvFx = {reduce(), centre(el), petals(n, spread), seen(key)}`; each script calls it. Keep numeric constants as arguments so output is identical. Guard with `window.gvFx ||` fallbacks only if load order is a worry (early.js runs before all of them).
Constraint: no build step, CSS is class-driven; `style.setProperty` on elements is already used and CSP-safe. Page-script load list is `layout.php:59`; no new file is needed if you extend early.js, which avoids touching the page list and the update-zip manifest.
Verify: manual: play each page once with reduced motion on and off; `bash tests/ci_suites.sh games2 fun` (fetch only), `node tests/popart_check.js` style checks where present. No automated browser test covers the animations, so this is not "zero behaviour risk" for a first batch.

### P5. JS: `gnomebeds.js` and `rainbarrel.js` share a 12-line preamble. Risk: low
gnomebeds.js:1-16 vs rainbarrel.js:1-18: identical `$`, `NS`, `post(fields,cb)` (fetch POST with csrf, same error text), `say(t,err)` (even the same element ids `rbmsg`/`rboops`), and `el(tag,attrs)`. Also `finish`/`start`/`clock`/`repaint`/`build` follow the same shape (gnomebeds.js:48-77 vs rainbarrel.js:56-90).
Change: move `$`, `NS`, `el`, `post`, `say` into puzzles.js? No: puzzles.js is the GIFsaw script and is a different page. Best: a new `assets/pzcommon.js` loaded before both (layout.php:59 list), or leave as-is. Gain is about 25 lines; **recommend skipping** unless P4 lands, because it needs a new file in the release manifest.

### P6. `post()` / `say()` variants (catfish.js:57, puzzles.js:27)
Different bodies (timeout, subtitle reset). Not duplicates. Leave.

### P7. Upgrade-step sequence is written twice. Risk: med
The same ordered calls `require upgrade110/120/140/163/170/193 + upgrade_NNN_run()` appear in bootstrap.php:185-194 (live upgrade path) and seed.php:166-177 (fresh install path), with interleaved other steps, so the orders differ (seed runs `breeding110_import()` between). Do not collapse without proof of equal ordering.
Possible low-risk change: a single `upgrade_run_all_post100(): void` in a new tiny `upgrade_all.php` (or at the foot of upgrade100.php) containing only the six require+call pairs (110,120,140,163,170,193) that are contiguous in both places; call from both. In seed.php the `breeding110_import()` sits before `upgrade_110_run()` (seed.php:167-168) so keep that line before the call.
The seven `upgradeNNN.php` files total 395 lines. Merging them into one file saves nothing meaningful and they are named in `tests/upgrade_check.sh`/`upgrade193.sh`, `updrollback`. **Do not merge the files.** Only the call sequence dedupe is worth considering, and it is optional.
Verify: `bash tests/ci_suites.sh walk updrollback fix100 upgrade193`, plus a DB-upgrade test on a pre-2.0 SQLite snapshot if one exists in `tests/fixtures`.

### P8. Duplicate RNG classes: DO NOT MERGE. Risk would be high
`JobRng` (jobs.php:83) and `TownRng` (townsfolk.php:19) look the same but differ (seed mixing `crc32` vs `crc32 ^ 0x5bd1e995`, and `next()` returns `$s` vs `$s >> 8`). Merging changes the daily offers. `MycRng` (maps_myc.php:42) and an inline LCG (pal_jobs.php:186) also use the same constant. Only the `pick()` method is byte-identical; extracting that to a trait is possible but yields about 2 lines. Skip. Listed so nobody "cleans" it.

### P9. Oversized files mixing concerns. Risk: n/a (planning only)
- `game/assets/site.js` 2,089 lines, loaded on every page, mixes: dialog helpers (1-60), gnome layers/SVG tint (83), walk bar (125-843), world map zoom (844-953), region-map zoom (1053-1199, near-duplicate of the world map zoom at 858-953: same `zoom/apply/toMap/zoomAt/up` names at site.js:858-873 vs 1061-1134 vs 1109-1166), message toasts (1424-1502), shop tiles and basket (1554-1650), wide layout (1884+). The three zoom/pan blocks are the best real dedupe in the JS: a single `makeZoom(opts)` factory. Medium effort, needs manual map testing (no automated JS test). Do after P4.
- PHP: `catfish.php` 1,647, `garden_logic.php` 1,530, `schema.php` 1,480, `trek.php` 1,441: cohesive per feature; splitting is churn with no behaviour benefit given "function signatures shared". Not recommended.

### P10. Items checked and clean
- No orphan include/page: every `game/includes/*.php`, `game/admin/*.php` and `game/*.php` is referenced elsewhere (grep by filename; the four redirect stubs `kitchen/passport/seasons/crafting.php` stay as required).
- `tests/`: `trek_text2012/2015/2020/2021/204/207.php`, `trek_ch2*`, `gen_ico_*.py` are one-off generators/audits; not in scope, but candidates for an `tests/archive/` sweep if wanted.

## Safe first batch (zero behaviour change, apply in this order)
1. P1: delete the 22 unused functions after checking graphify-out/SECTIONS.md for shared-signature names (keep `upgrade_unlock`). Verify: `php -l` each file; `bash tests/ci_suites.sh health walk`.
2. P2.1: `alchemy_item_id` becomes a wrapper over `trek_item_id` (or both over one helper in items.php). Verify: `treks` suite + `health` (tests/alchemy.php is a helper script, not a suite).
3. P2.2: `tk_n`/`tk_h` delegate to `tm_n`/`tm_h` (or the reverse) with require_once as needed. Verify: `delvemap delvestamp delvefloors treks`.
4. P4 (the pure subset): `seenGet/seenSet` shared by marrow.js and race.js, and `centre()` shared by memory/mushroom/worms, once `window.gvFx` exists in early.js. Pure functions, no timing or randomness.
Defer: P3 (broad), P4 petals/burst (constants), P5, P7, P9 until after a green run of the full `ci_suites.sh` list.

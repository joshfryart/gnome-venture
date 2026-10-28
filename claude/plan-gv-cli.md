# Plan: `gv.py`, a no-Claude first-pass pixel-art generator (PLAN ONLY, nothing built)

Goal: `python3 gv.py <category> ...` drives headless Aseprite + gvlib and writes ranked first-pass PNG/.aseprite candidates plus a contact sheet. No LLM call at runtime. Josh picks; Claude/Opus only polishes picks. Written 2026-10-28 from: HANDOFF.md, art-style-guide.md Part D + addenda, gvlib/{gvlib.lua,README,brief}, tools/*, extras-pixel/scripts/cast-*.lua, gnome-parts/, flowers-pixel/, claude/art-spec-overhaul.md, art-handoff-overhaul.md, jeff-poses.md.

## 0. Facts found while reading (they change the plan)
| Fact | Consequence |
|---|---|
| gvlib saves ONE flat cel. The 4,666 `.aseprite` files have no layers (only gnome-parts, flowers-pixel, cast/ are one-file-per-layer). | Parts cannot be mined from `.aseprite` layers. Mine them by recording `c:part()` calls while re-running the 1,706 Lua scripts (section 3, `record.lua`). |
| `gvlib.lua` `finish()` ALREADY adds the 1 px `#000000` border (line ~541) and `GV.check` already treats only `#ffffff` as `bw`. What is stale: `MODES.*.halo/close` pens, `c.halo/c.close` (dead), the constant `C.halo` (really the eye cream `#f2e4c0`, also used as legend key `"halo"` in cast-common.lua), README/example Windows paths. HANDOFF 6c says "needs a black-border post-pass": likely out of date. | Prerequisite P0 is small cleanup + a golden-file test, not a rewrite. Keep `C.halo` as an alias when renaming to `C.cream` (cast-common `U.h = "halo"` depends on it). |
| 1,706 scripts hard-code `C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/`; extras-pixel/cast scripts hard-code `/home/user/gnome-venture/`. `tools/aseshim.py` needs `lupa` (not installed) and only emulates a gvlib subset. | `gv.py` never runs old scripts as-is: it copies them to a scratch dir with the prefix rewritten (`str.replace`). Real AppImage is the only renderer; aseshim stays a dev-only fallback. |
| Existing scripts render via `app.params` (`out=`, `ase=`, `only=`), run as `AppRun -b --script-param k=v --script f.lua` (params BEFORE `--script`). | Same convention for the new runtime. Job data goes in a generated `job.lua` (returns a table), so Lua needs no JSON decoder. |
| Josh's standing rule: every asset visually unique, recoloured templates rejected (HANDOFF s1, s5.7: 8 of 100 test assets were one drawing recoloured). | Biggest product risk. Gate: per-category pairwise similarity check (section 5) + at least 3 independent variation axes per archetype. |
| Foods: `game/includes/data/recipes.txt` has 99 dishes (`slug|name|crop:qty,...|buffs|min|energy|desc|tier`); art lives in `game/assets/img/ph/<slug>.png`. Crops: `crops.txt` (201, kinds vegetable/tuber/legume/grain/fruit/tree/nut/herb/spice). Do cards = `game/assets/img/acts/act-*.png` (838, 144x108 = 72x54 grid at out=2, wooden frame copied from `act-hand.png`). | Combos file is seeded from recipes.txt; "made" is derived from the filesystem, not stored. |
| Eye code is locked (5x5 disc, 3x3 pupil, glint). Cleanup/shader passes must never touch eye, stitch, seam, button, gloss, glint pixels. | gvlib must tag those pixels "protected" (P0 small edit). |

## 1. File / directory layout (all new, under `aseprite-source/gv/`)
```
aseprite-source/gv/
  gv.py                     entry point, stdlib only, argparse subcommands (thin; imports gvpy/)
  gvpy/                     cli.py runner.py jobs.py png.py checks.py rank.py sheet.py palette.py
                            parts.py mine.py combos.py darken.py recipes.py doctor.py
  lua/
    gvrun.lua               job runner: dofile(job.lua), loops variants, calls template, saves, prints JSON-ish report lines
    gvgen.lua               extends gvlib: RNG (own xorshift, no math.random), palette jitter, slot/part loader, flip/offset/recolour
    gvshade.lua             lighting shader (s.4)          gvclean.lua   pixel cleanup (s.4)
    record.lua              wraps Canvas:part/eye/spot/seam/button to dump parts (mine step)
    templates/<category>/<arch>.lua + <arch>.json   masters (s.4); .json = slots, param ranges, palettes, tags, canvas
  data/
    palettes.json           named ramps (Part A families + addenda recipe) + per-category default palettes
    keywords.json           slug word -> archetype/palette hints (so `--name acorn-nut` needs no Claude)
    combos.json             foods: dish slug, name, tier, ingredients[{crop,qty}], source("recipes.txt"|"manual"); synced by `foods --sync`
    kindmap.json            part-name -> kind (body, limb, hat, leaf, stem, bowl, lid, handle, prop, ...)
  parts/                    mined library: index.json + <kind>/<id>.json (mask RLE, bbox, base hex, opts, source asset, z, tags)
  out/                      GITIGNORED: out/<category>/<YYYYMMDD-HHMM>-<name>/{png/,aseprite/,jobs/,sheet.html,run.json}
  accepted/                 TRACKED: picks promoted by `gv.py accept`: <category>/<slug>.{png,aseprite,job.json}
  .cache/squashfs-root/     GITIGNORED: extracted AppImage (made by `gv.py setup`)
tools/ (unchanged)          aseshim.py stays dev-only; darken.py logic is ported to gvpy/darken.py (stdlib, so --dark needs no Pillow)
```
Promotion into `game/assets/img/...` is manual (Josh's call, same as the rest of the art pipeline); `accept --to <path>` copies but never overwrites without `--force`.
Repo root is found from `gv.py`'s own path (`../..`); override with `GV_ROOT`. Aseprite found via `--aseprite`, `GV_ASEPRITE`, then `.cache/squashfs-root/AppRun`.

## 2. CLI
Shared flags (every category): `--name SLUG` (drives keyword/combos lookup and output filename) `--arch NAME` (force a master; default = pick by keywords, else random) `--seed N` (default random, always printed; variant i uses seed+i) `--count N` (candidates, default 12) `--top K` (keep K best by score, default all) `--palette NAME|#hex|auto` (palettes.json key or a base hex fed to `GV.ramp`; `auto` = category default + hue jitter) `--size WxH` (default per category, s.4) `--dark` (also write `<name>-dark.png`, border to cream, fills dimmer) `--out DIR` (default `out/<cat>/<stamp>-<name>/`) `--sheet` (default on: `sheet.html`) `--jobs N` (Aseprite processes in parallel, default 1; one process renders a whole batch to avoid start-up cost) `--dry-run` (print the job) `--no-clean` `--shade {crescent,lit}` (default crescent until s.4 shader passes) `--keep-fail` (also keep rejected renders, marked).
Utility subcommands: `setup` (copy AppImage to cache, chmod, `--appimage-extract`), `doctor` (checks Python, AppRun, one test render, Pillow yes/no), `mine` (build parts library), `parts ls|show|sheet`, `accept RUN FILE... [--to PATH]`, `redo FILE.png` (re-render from sidecar job, must be byte-identical), `sheet RUN`, `rank RUN`.

| Category | Example commands |
|---|---|
| icons | `gv.py icons --name ico-acorn-nut --count 16 --top 6` / `gv.py icons --arch vessel --palette "#9a6b3f" --seed 7 --dark` |
| acts (Do cards) | `gv.py acts --name act-cast_a_line --scene jetty --props rod,bucket,water --count 8` / `gv.py acts --kind craft` (the 4 kind cards) |
| npcs | `gv.py npcs --name npc-miller --arch bust-stout --palette soil --count 10` / `gv.py npcs --mini --name mini-npc-miller` (64x80 later) |
| gnome-bits | `gv.py gnome-bits --slot hat --count 12` / `gv.py gnome-bits --slot beard --arch braided` (neutral greys, 80x100 layer) / `gv.py gnome-bits --composite` (stack preview) |
| items | `gv.py items --name cardboard-sheet --arch flat-sheet --count 12` / `gv.py items --list-archs` |
| banners | `gv.py banners --key forest --size 480x120 --count 8` / `gv.py banners --key NA --palette moss` |
| creatures | `gv.py creatures --name creature-aphid --arch bug-round --count 10` (sticker 64x64; `--mini` for 56x64 toy base later) |
| garden | `gv.py garden --type plant --name tomato --stage 3` / `gv.py garden --type seed --name tomato` / `gv.py garden --type misc --name rain_barrel-2` |
| foods | `gv.py foods --name berry-tart` / `gv.py foods --missing` (lists dishes with no PNG in `ph/` or `accepted/`; `--missing --render` makes candidates for all, `--tier meal`) / `gv.py foods --sync` / `gv.py foods --add "name|crop:2,crop:1|tier"` |
| pals (advanced) | `gv.py pals --count 24 --seed 1` (random puzzle-piece cast: edges, face, accessory) / `gv.py pals --like jeff --mood hmm` |

`foods --missing` output: table `slug | tier | ingredients | suggested container` plus a count; exit code 0. Container and garnish come from tier (snack=plate/wrap, meal=bowl, feast=platter, preserve=jar) and ingredient crop kinds (`crops.txt`), so no prompt is needed.

## 3. Modules
| Module | Responsibility |
|---|---|
| `gvpy/cli.py` | argparse, shared flags, dispatch; prints one summary table per run |
| `gvpy/jobs.py` | resolve name/arch/palette/size -> per-variant spec (seed, params, chosen parts, ramp hexes); write `jobs/job.lua` + sidecar `<file>.job.json` (full reproducibility) |
| `gvpy/runner.py` | locate Aseprite, rewrite old-script path prefixes into scratch copies, spawn `AppRun -b --script-param ... --script gvrun.lua`, parse report lines, timeout, retry-once on Lua error, parallel batches |
| `gvpy/png.py` | stdlib PNG read/write (8-bit RGBA, non-interlaced; zlib+struct), nearest/box downscale, alpha helpers. Pillow used only if present for the PNG contact sheet |
| `gvpy/checks.py` | the acceptance rules (s.5): semi, bw, margin, colour cap, border, readability at 32/38 px, connected components, protected-pixel patterns (eye), per-category extras |
| `gvpy/rank.py` | score = weighted checks (hard fails = reject) + readability + uniqueness (pairwise pixel IoU/Hamming vs same-run and `accepted/`) |
| `gvpy/sheet.py` | `sheet.html` (images at 1x/2x/4x via CSS `image-rendering: pixelated`, 32 px and 16 px thumbnails, seed + score + warnings under each; click to mark picks -> `picks.txt` via copy-button). No 8x files (Josh's rule) |
| `gvpy/palette.py` | `ramp(hex)` Python port of `GV.ramp` (for sheets/darken/tint previews) + palettes.json loader; verify against Lua output in tests |
| `gvpy/mine.py` + `lua/record.lua` | re-run all scripts with a recording hook; emit raw parts; `parts.py` classifies (kindmap by part name, then by asset prefix and size), dedupes (hash of normalised mask), writes `parts/` |
| `gvpy/combos.py` | parse `recipes.txt`/`crops.txt`, maintain `combos.json`, compute `--missing` from filesystem, pick container/garnish |
| `gvpy/darken.py` | port of `tools/darken.py` (border -> `#f2e4c0`, `r*.88 g*.9 b*.95+6`) on the stdlib PNG codec |
| `lua/gvgen.lua` | xorshift RNG, `P.vary()` helpers (jitter proportions, pick slot part, flip, offset, hue-shift ramp from palette), `slot()` loader (mined mask -> `c:mask()`), per-variant canvas creation, sidecar report |
| `lua/gvshade.lua`, `lua/gvclean.lua` | s.4 passes; `gvclean` runs before `Canvas:finish()` so the black border is drawn after cleanup |
| `lua/templates/*` | archetype masters: parametric Lua (`return function(c, P, R)`), not bitmaps |

## 4. The engine ideas, concretely
**Parts library (idea 1).** `record.lua` wraps `Canvas:part/limb/spot/eye/seam/button/stitch` and, at `save`, dumps `{asset, mode, canvas WxH, parts:[{name, z, ramp base+overrides, opts, mask RLE rows}], eyes:[x,y,small], seams, buttons}` to JSON instead of writing art. Top part names (count over the 1,706 scripts): body 453, leaf 238, stem 233, head 192, rim 118, neck 101, tail 100, lid 99, top 95, seed 92, handle 89, flap 84, band 84, belly 83, label 81, cap 76, mound 63. Library kinds: body, head, limb, hat/cap, leaf, stem, petal, bowl/jar/vessel, lid, handle, label/flap, prop, tail, ear, eye-layout (position by head width). Each entry keeps its source asset id and a `family` tag (`creature-`, `feast-`, `ico-`...). Metadata: bbox, aspect, mirror-safe, pixel count. Recombine = pick mask, flip/offset/scale-by-nearest-whole-factor (never resample), re-ramp via `GV.ramp(newBase)`. Mined parts keep their original proportions; never scale non-integer.
**Masters (idea 2).** Opus authors each archetype ONCE as a Lua function with named slots and param ranges, e.g. `bowl-meal`: `P.rim_w 22..30, P.depth 8..13, P.foot yes/no, slot garnish[2..4], slot steam 0..2, palette bowl, palette fill`. Variation axes required per archetype (>=3 independent): silhouette proportion, part swap, marking/garnish, palette hue, tilt/flip.
**Shader (idea 3, `gvshade.lua`).** `c:lit(mask, ramp, {height="dome"|"cyl"|"flat"|fn, light={-1,-1,z}})`: height field from distance-to-edge (sqrt/pillow profile) -> normal -> N.L -> quantise with fixed thresholds to gloss/base/shade/deep. Must still read as ONE crescent per part (Part D): thresholds chosen so only the lower-right region falls below base; bounce/rim/gloss comma/dot placed by the same routine as `Canvas:part`. Option `--shade crescent` keeps the current ellipse method. Acceptance: re-render 30 reference assets (mixed families) with `lit` and compare on a sheet next to the originals; Josh approves before it becomes default.
**Cleanup (idea 4, `gvclean.lua`).** Order: fill -> shade -> detail -> CLEAN -> outline (selective) -> border. Rules on `c.pix`: remove orphan pixels (no 4-neighbour of same colour) that are not protected; collapse doubled corners (L-corner pixel on 1 px lines/outlines); pixel-perfect line pass (drop corner px of staircase when both neighbours are 4-connected); re-run the selective-outline tone by `s=(x-cx)+(y-cy)`. Protected = eye, stitch, seam, button, gloss comma/dot, spot glint, any pixel painted via `c:px/c:paint` flagged `keep`. Needs `c.prot[key]=true` set inside those gvlib functions (P0).
**Recipe data (idea 6).** Optional `recipes/*.json` = ordered shape list (`ellipse|rrect|poly|line` + part name + ramp + opts) that `gvgen` renders with no per-asset Lua; used for foods garnish, plants, icons made from 2-5 shapes. Masters stay Lua; recipes are what `gv.py` can mutate (jitter numbers) cheaply.

## 5. Acceptance checks
Shared hard fails (any category): `semi==0`; `bw==0` (pure white only); only colours from palettes.json/ramps (colour cap per category); `margin>=3` for sticker/icon (busts: bottom edge bleeds, margin>=2 elsewhere); black `#000000` only as the 1 px border on sprites (none on scenes/banners/acts); 1 px black border present on every outside 4-neighbour edge of sprites; limbs/parts >=2 px (icons >=3); readable at 32 and 38 px (box downscale to 32/38: main shape one connected component, fill 20-85% of frame, >=3 tones survive, mean contrast vs transparent+dark and light bg); not a near-duplicate: pixel IoU < 0.85 vs every other candidate in the run and every file in `accepted/<category>/` (existing duplicate scan used ratio>0.80 on scripts; here on pixels); `redo` reproduces bytes.
Soft score: tone count 4-5 per part, eye pattern present where required, edge-stitch present on fabric parts only, outline tones in the allowed 3, silhouette symmetry where template says symmetric.
Each category adds the extras in the table below.

### Per-category spec
| Category | Template source | Canvas / mode | Parts needed | Extra acceptance | Ceiling |
|---|---|---|---|---|---|
| icons | 10-12 masters: vessel, tool (handle+head), leaf/sprig, fruit/round, bug-simple, shield/badge, key/lock, book/letter, tile/card, star/gem, drop/flame, box | 64x64 `icon` (273 `ico-*` exist) | mined from `ico/` scripts: handles, lids, leaves, rims | parts >=3 px; reads at 16 px (16 px downscale: still 1 component, >=2 tones); chunky, no fine detail | near-Opus |
| acts (Do cards) | 6 scene masters: frame+backdrop bands by stop type (market, inn, jetty, shrine, mill, camp), prop slots 1-3 from 112 `variety-act-*.lua` helper props | 144x108 = 72x54 `scene` out=2, ol=1; frame copied from `acts/act-hand.png` | props (rod, bucket, bench, lantern, sack...), band sets | frame pixels identical to `act-hand.png`; interior x5..68,y5..49 only; prop count 1-3; no black; every object outlined 1 px | near-Opus (single props), medium (scene composition) |
| npcs | 8-10 bust masters from the 139 `npc-*` + `gnome-parts/gnome-common.lua` shapes (face, ears, nose, beard, tunic, belt, bezier helper `G.q`, `G.sym`) | 80x100 `bust`, bleeds bottom | head shape, hair/hat, beard/moustache, collar/tunic, prop in hand, eye layout | locked eye pattern present x2 (pattern match 5x5/3x3/glint); head >=20 px wide else small eye; bottom row opaque, no border at bottom; symmetric on x=40 where template says so | medium: Opus masters + hand polish |
| gnome-bits | existing 7 layers in `gnome-parts/` (hat, beard, band, star, face, body, shadow) as anchors | 80x100 `bust`, `halo=0`, `margin=0`, no bleed, centred col 40; tint layers neutral grey | hat/beard/band/badge variants (cone, floppy, braided, forked, fez...) | tint layers r==g==b within +-6; bbox inside the head/hat region of `gnome-common`; stacks over body/face with `--composite` showing no gap; no black border (layers must composite) | near-Opus |
| items | 10 masters: flat-sheet, bag/sack, tool, jar/bottle, box/crate, coil/rope, bundle, ingot/block, scroll, shard | 64x64 `sticker` | mined bodies, handles, bands, labels | `broken-*` option: same drawing + damage mask (crack/chip/loose piece) with unchanged colours | near-Opus |
| banners | 6 masters: sky bands + 3 silhouette layers (seeded ridge function) + 1-3 landmarks per key (village, haven, wonder, delve, lair, market, lands, regions) | 480x120 = 240x60 `scene` out=2; hem stitch top/bottom allowed | band palettes per land, ridge/treeline/roof/water strips, landmark props | size exact; opaque (alpha 255 everywhere); <= Part E colour cap; 5 +-1 sky bands; no dither; no characters; no black | medium |
| creatures | 10-14 masters by body plan: round bug, long bug, quadruped, bird, fish, snake/worm, rodent, frog, boss | 64x64 `sticker` (137 exist; 56x64 mini later) | mined bodies, heads, tails, ears, legs (lavender 2 px bent limbs), eyes | eyes locked; limbs >=2 px lavender `#54447f` lit top `#7b66b4`; chibi ratio head ~5/6 body width; antenna tips 4x4 club | medium: needs masters, gets close |
| garden | plant: crop-kind masters (vegetable, tuber, legume, grain, fruit, tree, nut, herb, spice) x growth stage 1-4; seeds: packet master (body, flap, window, sprig, berries as in existing `ph` packet scripts) with crop emblem slot; misc: `ph/garden-*`, tool_shed, rain_barrel, compost_bin, beehive tiers | 64x64 `sticker` | leaves, stems, fruit blobs, packet parts, barrel/shed parts | stage N has more mass than N-1; seed packet window shows crop emblem; same subject across stages | near-Opus |
| foods | container masters (plate, bowl, pie-tin, platter, jar, wrap) x garnish slots; garnish = mined crop shapes + steam | 64x64 `sticker` (`ph/<slug>.png`) | bowls/jars/rims (mined from feast-* and jar scripts), crop shapes (`ph/<crop>`) | garnish count <= ingredient kinds (max 3 types); tier decides size/container; `--missing` empty after run | near-Opus |
| pals (advanced) | generalise `K.jeffBody/jeffFace/jeffArm`, `K.ffejBody`, `K.wizardShapes` into `K.pieceBody(c, edges={top,right,bottom,left}, lean, dx, dy)`; random edge types (knob/notch/tab/flat), body hue, mood (grin/hmm/shout/custom), accessory (hat, eyepatch, beard, scarf), arm pose | 64x64 `sticker` (+ `-dark`) | piece body shapes, face sets, arm tabs, accessories | semi==0, bw==0, margin>=3 (same asserts as cast scripts); piece silhouette readable at 38 px (cast rule); knob/notch must not touch frame; each pal's edge tuple unique within run | medium: Opus masters needed |

## 6. Phased build order
| Phase | Deliverable | Who | Tokens (rough) |
|---|---|---|---|
| P0 Prereqs | gvlib tidy: drop dead halo pens, add `C.cream` + keep `C.halo` alias, add protected-pixel set, replace Windows/absolute paths with `GV.ROOT`/`app.params.root` fallback; golden test (re-render `cast-jeff-point.lua`, `gnome-hat.lua`, `apple-chutney.lua`, compare bytes to shipped PNGs); `.gitignore` entries | Sonnet; Opus reviews diff once | S 120K + O 30K |
| P1 Skeleton | `gv.py setup/doctor`, jobs/runner/png/checks/rank/sheet, `gvrun.lua`, one trivial built-in archetype (round sticker) proving seed -> 12 candidates -> ranked sheet -> accept -> redo | Sonnet | S 350K |
| P2 Mine | `record.lua`, `mine`, kindmap, `parts ls/show/sheet`; run over all 1,706 scripts + cast + flowers + gnome-parts | Sonnet builds; Opus (or Josh) curates top ~150 kindmap names and tags 30 sample parts | S 400K + O 80K |
| P3 Cleanup | `gvclean.lua` + before/after sheet on 40 existing assets (must not change eyes/stitches) | Opus writes rules spec and reviews; Sonnet implements | O 60K + S 200K |
| P4 Shader | `gvshade.lua` `c:lit` + 30-asset A/B sheet; becomes default only after Josh approves | Opus design + implement; Sonnet tests | O 300K + S 100K |
| P5 Foods, seeds, items (first real categories) | 6 containers + 4 seed/packet + 10 item masters; `combos.json` + `foods --missing`; pairwise uniqueness gate | Opus masters (about 60-80K each, ~20 masters); Sonnet CLI glue/data | O 1.4M + S 300K |
| P6 Icons, garden, gnome-bits, acts | 12 icon masters, 9 plant kinds x stages, 5 gnome-bit slots, 6 act scene masters + prop library | Opus masters, Sonnet glue + keyword tables | O 1.8M + S 500K |
| P7 Banners | 6 banner masters + ridge/band generators | Opus masters, Sonnet glue | O 400K + S 150K |
| P8 NPCs, creatures | 10 bust + 12 creature masters; expect hand-polish | Opus (needs the most review) | O 1.8M + S 300K |
| P9 Pals | `K.pieceBody` generalisation + 6 masters + accessories + `--dark` | Opus masters, Sonnet glue | O 450K + S 150K |
| Total | | | about O 6.3M, S 2.6M tokens (Opus 80K/master is the measured scale: HANDOFF reports 37-55K per asset with gvlib, helpers rewritten add more) |

Sonnet can build alone: P1, glue and data in P2/P5-P9, tests. Needs Opus: shader (P4), cleanup rules (P3 spec), every master, kindmap curation. Rule from HANDOFF: Opus draws art, Sonnet does support.

## 7. Verification per phase (concrete commands)
Setup once: `python3 aseprite-source/gv/gv.py setup && python3 aseprite-source/gv/gv.py doctor` (expects "render OK, semi=0").
| Phase | Commands / pass criteria |
|---|---|
| P0 | `AppRun -b --script-param out=/tmp/gold/ --script aseprite-source/extras-pixel/scripts/cast-jeff-point.lua` then `cmp /tmp/gold/jeff-point.png game/assets/img/puzzles/cast/jeff-point.png` (identical); same for `apple-chutney.lua` vs its png; `grep -n "halo=" aseprite-source/gvlib/gvlib.lua` shows no pens; eye still cream `#f2e4c0` |
| P1 | `gv.py doctor`; `gv.py icons --arch round --count 12 --seed 1 --dry-run` then without `--dry-run`; open `out/icons/*/sheet.html`; `gv.py redo out/icons/*/png/<f>.png` byte-identical; re-run with same seed gives identical hashes (`sha1sum out/.../png/*.png` twice) |
| P2 | `gv.py mine --limit 50` then `gv.py mine`; `gv.py parts ls --kind leaf | wc -l` (>200); `gv.py parts sheet --kind bowl` sheet looks right; re-composite one mined asset from its recorded parts and diff vs its PNG (expect identical before outline) |
| P3 | `gv.py clean-test --assets 40` writes before/after sheet; script asserts eye/stitch/seam/button pixels unchanged (protected set), orphan count down, semi/bw still 0 |
| P4 | `gv.py shade-test --assets 30`; sheet original vs `lit`; checks still pass; Josh signs off before default changes |
| P5 | `gv.py foods --sync && gv.py foods --missing` (count = recipes.txt rows minus PNGs in `ph/`); `gv.py foods --name berry-tart --count 12 --top 4`; uniqueness: `gv.py rank out/foods/<run> --dupes` reports no pair IoU >= 0.85; 38/32 px thumbnails readable on sheet; `gv.py foods --missing --render --count 3` completes, all hard checks pass |
| P6 | per category one run with `--count 12`; hard-check failure rate < 10% of renders; `gv.py gnome-bits --composite` stacks cleanly on body/face; `gv.py acts --name act-cast_a_line` frame hash equals `act-hand.png` frame |
| P7 | `gv.py banners --key forest --count 6`; PNG exactly 480x120, alpha all 255, sky bands 4-6 |
| P8 | `gv.py npcs --count 10`; eye-pattern check passes both eyes on all kept; Josh compares against existing `npc-*` on sheet |
| P9 | `gv.py pals --count 24 --seed 1`; edge tuples all unique; readable at 38 px; `--dark` file border is `#f2e4c0` |
Global: `python3 -m unittest discover aseprite-source/gv/tests` (png codec round-trip, ramp port vs Lua, combos parser, checks on fixture PNGs, darken port vs `tools/darken.py` on one sample).

## 8. Risks
- Uniqueness vs recombination (Josh rejected recoloured templates): mitigate with the pairwise gate, 3+ axes, and by labelling output "first pass: pick then polish".
- Part scaling and mined-part compatibility: parts were drawn at specific proportions with hand-tuned gloss; mixing can leave wrong crescent or contour. Re-run shading on assembled composites rather than pasting finished pixels; keep paste-as-is only for tiny props.
- Shader may produce extra shade blobs (violates "one crescent"). Cap thresholds; A/B gate.
- Cleanup can eat deliberate 1 px accents (eyes, stitches, glints): protected-set required, test in P3.
- Aseprite headless: AppImage may need FUSE (use `--appimage-extract`, done in `setup`), `app.params` order quirk, ~0.5-1 s start-up per process (batch variants per process); `json` module not assumed.
- Lua `math.random` seeding is not guaranteed stable: own RNG in `gvgen.lua`.
- Keyword lookup (`--name acorn-nut`) will guess wrong sometimes; `--arch` always overrides. Quality of defaults depends on `keywords.json` coverage.
- Dark variants are a recolour (as `darken.py`), not a redraw; fine for first pass.
- `art-style-guide.md` can be overwritten by `tests/build_guide_md.py`; the shared palette and ramp recipe in `palettes.json` must be a copy, not a link. Re-diff against the guide when it changes.
- Scope: 10 categories is large; foods + seeds + items first (best payoff, highest ceiling).

## 9. Open questions for Josh
1. Subject input without Claude: OK to use `--name <slug>` + keyword table + `--arch`, or do you want a tiny hand-edited `subjects.json` (slug -> archetype, palette, notes) per category?
2. Foods "known combos": only the 99 dishes in `recipes.txt`, or also hypothetical ingredient pairs (e.g. every crop pair) that the game may allow later? Is a dish named by slug (`ph/<slug>.png`) always the right file?
3. "Action cards": confirm these are the Do-tab scene cards (`acts/act-*.png`, 144x108), not the `ico-*` icons or `gather/slot-*`.
4. "Puzzle Pals": random piece shape only, or also named recurring characters with fixed traits? How many edge types (knob/notch/tab/flat) and should they match a real jigsaw grid?
5. Scale rule: mined parts, scaled only by whole factors, OK? Or must every part be at its drawn size?
6. Is the uniqueness bar (IoU < 0.85 vs all accepted) the right strictness, and is "first pass then polish by Opus" acceptable for NPCs/creatures/pals?
7. Output home: `aseprite-source/gv/out` (gitignored) and `accepted/` (tracked) acceptable, or should accepted files go straight into `final/`?
8. Should `gv.py` also write dark variants for scenes/banners, or sprites only (current plan: sprites only, as `darken.py` is used now)?
9. OK to edit `gvlib.lua` (P0 tidy + protected pixels) given every shipped asset depends on it? Plan guards this with the golden byte-compare test.
10. Pillow: stdlib-only is fully supported; Pillow only adds a PNG contact sheet. Fine to leave HTML sheets as the default?

# Pantry + Gourmand art: first batch, cost and plan

Status (2026-10-30): **batch 1 drawn (12 assets), nothing beyond it.** Waiting for Josh's look at the sheet before drawing the rest.

- Sheet (4x and 1x): `aseprite-source/img-redraw-full/sheets/pantry-batch1.png`
- PNGs (live in the game): `game/assets/img/ph/<slug>.png`. `ph_path()` takes `.png` before `.svg` and `item_pic()` uses it when an item has no `image`, so art an admin uploads still wins.
- Sources: `aseprite-source/img-redraw-full/scripts/ph/<slug>.lua` (gvlib, Linux paths) and `.../aseprite/ph/<slug>.aseprite`

## Batch 1 (one of every form)
| form | slug | check |
|---|---|---|
| jam (icon) | apricot-jam | semi=0 pureBW=0 margin=5 |
| chutney | plum-chutney | semi=0 pureBW=0 margin=3 |
| pickle | pickled-okra | semi=0 pureBW=0 margin=4 |
| ferment | kombucha | semi=0 pureBW=1 (pale dot) margin=4 |
| cordial | lemon-cordial | semi=0 pureBW=1 margin=3 |
| dried | dried-figs | semi=0 pureBW=0 margin=3 |
| spread | peanut-butter | semi=0 pureBW=0 margin=5 |
| P2 dish | khichdi | semi=0 pureBW=0 margin=3 |
| P2 dish | falafel | semi=0 pureBW=1 margin=4 |
| gourmand bust 80x100 | npc-pomeroy-crumbworth | semi=0 pureBW=0, sides >=4 (bleeds off the bottom) |
| gourmand decor | second-spoon | semi=0 pureBW=0 margin=3 |
| gourmand nav (icon) | nav-gourmand | semi=0 pureBW=1 margin=6 |

Verified:
- On a fresh install, `item_pic()` resolves all 9 items to `assets/img/ph/<slug>.png`. `ph_path('npc-pomeroy-crumbworth')` and `nav_icon('gourmand')` resolve to the new PNGs.
- `bash tests/ci_suites.sh images` passes (ok, 0 failed).

## Toolchain
Aseprite 1.3.18 AppImage runs headless here: `--appimage-extract` to `/tmp/aseq`, then `squashfs-root/AppRun -b --script x.lua`. Each render takes about 0.1 s. gvlib already has the black-border post-pass. Nothing was installed (PIL 12.3 was already present, used only for the sheet).

Render one asset: `/tmp/aseq/squashfs-root/AppRun -b --script aseprite-source/img-redraw-full/scripts/ph/<slug>.lua`. Add `--script-param out=<dir>/ --script-param ase=<dir>/` to stage the files elsewhere.

## Measured cost (one Opus agent, 12 assets)
- **Time:** about 7 minutes of wall clock from the first script to the last re-render (measured from timestamps). Reading the docs and specs, the CI run and the sheet took about 5 minutes more.
- **Revisions:** 5 of 12 needed a second pass and 1 needed a third. Fixes:
  - okra pods merged into one block
  - kombucha cloth did not read
  - peanut label read as an animal
  - falafel broken face too small
  - bust: the brows looked angry, the backdrop read as a mane and the napkin was too small
  - second-spoon pot too shallow
  - falafel cone touched the frame (it failed the margin check)
- **Tokens (estimate, not billed):**
  - Output: about 20-25K. The 12 scripts are 24.9 KB, plus the edits.
  - Input: about 45 turns at a 40-110K context, mostly cached reads.
  - Total: about **$1.5-2.0 for the batch, about $0.13-0.17 per asset.**
  - Prices are Opus 5.5 at $4 / $20 / $0.20 cached per million tokens.
  - This matches the earlier measured figure of about 21K Opus tokens per asset, roughly $0.10-0.16.
- Roughly 40% of the batch cost was one-off setup (handoffs, gvlib API, lookup code, CI). A batch of 12-15 assets per agent spreads that cost best. Groups of 3 (the Stage B pattern) pay the setup cost 4-5 times as often.

## Projection for the rest
| what | count | est. cost | wall time |
|---|---|---|---|
| remaining Pantry preserves | 130 | $17-24 | about 1.5 h for one agent; about 15-20 min as a workflow (10 agents x 13) |
| remaining P2 dish/jar specs | 14 | $2-3 | in the same run |
| optional re-spec of look-alike jars (Sonnet) | about 90 | $2-4 | about 10 min |
| **total** | **144 drawn** | **about $21-31** | |

Add 10-20% for the redos Josh flags (Stage B history).

## Spec problems found (fix before drawing at scale)
1. **Templated jars, the main risk.**
   - 89 of the 137 preserve specs use the identical jar `rrect x 18..46, y 22..54 (r7)` with the identical lid `x 17..47, y 14..24`.
   - The must-read lines collapse to 7 templates that differ only by `#colour`:
     - "upright jar ... gold cap" (30)
     - "tall jar ... pale brine" (22)
     - "round-bellied bottle with a cork" (20)
     - "cloth-tied lid ... bubbles" (19)
     - "tall jar ... chunky fill" (18)
     - "drawstring linen bag" (16)
     - wide squat jar (12)
   - Drawn as written, this is exactly the recolour templating Josh rejected (feast dishes, seed packets). The 18 jams plus 7 marmalades would be 25 near-identical orange/red jars.
   - In batch 1 I varied each silhouette by hand (fluted lid on the chutney, standing pods in the pickle, draped cloth on the ferment, knurled wide lid on the spread, an emblem on every label). That will not survive a mechanical run.
   - **Recommend:** a cheap Sonnet re-spec pass that gives every preserve a sharper `distinct:` line. Options:
     - its own vessel: hex jar, bail-top, wax-sealed crock, stoneware pot, tin, swing bottle, paper twist, bottle with a dropper
     - its own lid treatment: fluted, cloth, wax drip, cork, ribbon
     - a fruit emblem on the label
     - a visible ingredient silhouette inside the jar (whole okra, lemon wedges, peppers, garlic bulbs)
   - Within a form, vary the vessel. Never vary only the colour.
2. **Wrong boilerplate on non-glass items.** All 16 bag specs (dried fruit, candied, marzipan, chili flakes) say "Glass lit upper-left ... no edge stitch on glass" and "seam along the lid/cap base", but a linen bag has no lid. It should get an edge stitch instead (that is what I drew on dried-figs).
3. **Pure white.** 41 preserve specs and 2 gourmand specs ask for `#ffffff` bubbles or highlights. The brief allows white only as the pale-ramp dot, so I used `#f6fbf0` / `#fbf6e8` / `#fbfdfe`. The specs should say this so artists do not trip `bw`.
4. **Gourmand specs still say "PLACEHOLDER first: red border plus THIS IS PLACEHOLDER"** (all 3). That line was for the placeholder phase. I drew final art; delete the line before any re-run.
5. **npc-pomeroy-crumbworth:**
   - The brows "raised at the outer ends" read as angry. I drew short arches instead.
   - The `#c9a96e` backdrop is almost the fur colour and read as a lion's mane, so I used pale lilac `#b9a6d6`.
   - The spec's "4x4 dark eyes" conflict with the locked eye, so I used the locked eye.
   - The napkin at the spec size was hidden by the head, so I widened it to x16..65 so it carries the silhouette as the spec intends.
6. **All 16 P2 dish specs share the same "gloss spot (21,36)" note.** For many of them that point is off the food (falafel, poi leaf), so ignore it.
7. **The spec coordinates often touch the frame.** Examples: second-spoon bowl `ry11` at y14 reaches y3, nav napkin knot reaches y57, falafel cone tip at y58. With a 2-3 px outline plus the 1 px border, these fail `margin >= 3`, so the artist has to shrink them. Spec writers should keep the art inside 5..58.
8. **There are no SVG placeholders on disk for these slugs**, so until real art lands the game falls back to the emoji. Because of that, the drawing order matters more than for re-skins.

## Recommended order
1. Josh reviews `pantry-batch1.png` (style, and whether a varied jar per recipe is wanted).
2. Re-spec the look-alike preserves (item 1 above; Sonnet, about $3) and fix the boilerplate (items 2-4).
3. Draw the most visible items first:
   - the 14 remaining P2 dishes and jars (Pomeroy's menu, served daily)
   - the preserves Pomeroy asks for in `game/includes/data/gourmand.txt`
4. Then the rest of the preserves by form, interleaved so no agent draws two of one form: jams and marmalades (25), pickles and kimchi (22), cordials (20), ferments (19), chutneys and relishes (18), dried and candied (16), spreads, cheese and other (12+).
5. Duplicate scan (ratio > 0.80, script in `full/HANDOFF-image-generation.md`), then a sheet per form, then `tests/ci_suites.sh images`.

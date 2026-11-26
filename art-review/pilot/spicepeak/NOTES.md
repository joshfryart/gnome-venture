# Spicepeak pilot: 6 Puzzle Pals redrawn as merged creature-pieces

Staging only. Nothing under `game/` was touched. Rerun: `python3 art-review/pilot/spicepeak/draw_pilot.py`.
Files: `<key>.png` (64 x 64 master), `<key>-36.png` (36 x 36, re-rasterised from the same shapes with its own eyes and mouths, plus knobs 12 to 15% larger so tabs survive; not a resize), `compare.png` (OLD | NEW 64 | NEW 36 at 4x on light #f1ece0 and dark #2a1a10, with the source cell).

How I read the shape codes (`claude/plan-puzzle-pals.md` section 6, `PPAL_SHAPES` / `PPAL_KNOBS` in `game/includes/puzzle_pals.php`): T = tab out, B = blank in, F = flat. Corner = 2 flat sides, edge = 1 flat side, inner = none. The letters list the non-flat sides; the code does not fix which side is which, so I picked the rotation that best fits each creature. Knob styles: round, keyhole, peg (square), tri, double (two lobes), hook. Hook blanks are cut as a comma-shaped hole, because a ring-shaped blank leaves a floating island of body.

## The pals

**sp-saffron-snip, Saffron Snip** (corner-BB, round). A saffron crocus. The flat W and S sides are the terrace step it grows from. Two pointed purple outer petals rise at the top corners. The round N blank is the open cup, with three red saffron threads standing in it. The round E blank bites into the green sepal body. Palette: cell 2-6 (terrace green, beige stone wall along the flat bottom, teal leaf blade from the picker's hat). Crocus purple comes from the picture's own `#8a5aa8`.
*Verdict: squint PASS (a corner piece with two clear round bites), name PASS but weak (a purple flower bud; at 36 px the petals can read as ears), picture PASS.*

**sp-yak-yonder, Yak Yonder** (edge-TTB, double). A laden yak, seen from the front. Its hooves stand on the flat S side. The N double tab is two orange bundles roped on its back, and the E double tab is a saddlebag. The W double blank is cut into its shaggy side. Cream horns break out at the top corners. Palette: cell 5-5's tiger moth (orange with a cream zigzag, on the packs and the chest blanket) on yak brown from the bridge yak.
*Verdict: squint PASS, name PASS (the strongest of the six), picture PASS.*

**sp-chilli-chime, Chilli Chime** (inner-TBTB, peg). A long red chilli whose tip curls right. The N peg tab is its green stalk, and the S peg tab is a small brass chime bell hanging from the tip. The square peg blanks E and W pinch its shoulders. Palette: cell 9-6, the souk (chilli-garland red, spice gold, tea-green stalk).
*Verdict: squint PASS (vertical, square pegs and notches), name PASS but weak (the wide shoulders and green cap can read as a strawberry; at 64 px the bell looks more like a tag than a bell), picture PASS for colour. The cell is mostly brown shelving; the pal uses its reds and golds, not the brown.*

**sp-stupa-snug, Stupa Snug** (inner-TTTT Plus, double). A small white stupa. The N double tab is the gold finial, with a thin spire. The E and W double tabs are lavender mitts, and the S double tab is two lavender feet. It has the painted stupa eyes with arched lids and the little red curl nose, the gold zigzag band, base windows, and a string of five prayer flags over the dome. Palette: cell 8-2 (stupa white, lavender mountain, flag red, blue, green and yellow, gold zigzag).
*Verdict: squint PASS (a clear plus shape; the side tabs look a bit like dog bones), name PASS, picture PASS.*

**sp-teal-ferry, Teal Ferry** (inner-TTBB, hook). The flower ferry, floating on its own band of teal river. The N hook tab is the ferryman's brass boat hook, and the E hook tab is a curled wooden prow. The hook blanks are cut into the cabin (W) and into the river (S). It has an arched teal canopy on two posts, pink garland flowers along the rail, and the face on the curved wooden hull. Palette: cell 6-6 (river teal and foam, boat wood, garland pink).
*Verdict: squint PASS, name PARTIAL (it reads as a boat on water at 64 px; at 36 px it is closer to "a box with a canopy"), picture PASS.*

**sp-lofty-kite, Lofty Kite** (rare, whimsy-kite, tri). A diamond kite. The whimsy shape is the kite itself, with tri tabs on its NW and SE edges and tri blanks on its NE and SW edges. It has cross spars, a ribbon tail with two bow ties, and eyes that look down ("looks down on everything"). The top half is saffron and orange like the kite over the ridge; the bottom half is sky teal, because cell 4-0 is mostly sky.
*Verdict: squint WEAK (knobs on diagonal edges make the outline busy, a bit like a star, and the tabs read as ears more than as jigsaw tabs), name PASS (diamond, spars and tail say kite), picture PASS.*

Summary: 4 strong (Yak, Stupa, Saffron, Chilli), 1 adequate (Ferry), 1 weak on the puzzle read (Kite). The weakest name test is Chilli (could be a strawberry). The weakest squint test is Kite.

## Checks (run by the script, last run)
- Sizes: 64 x 64 and 36 x 36, RGBA. Alpha is only 0 or 255 in all 12 files. No #000000 pixel. The outline is umber #2a1a10, 1 px, 4-adjacent.
- Colours per file: 13 to 22 (limit about 40). Saffron 17/15, Yak 15/16, Chilli 13/13, Stupa 20/19, Ferry 18/17, Kite 22/21.
- Silhouettes: all 6 are unique at both sizes. The most alike pair is Saffron vs Ferry (IoU 0.68 at 64 px, 0.70 at 36 px; both are rectangles with two cuts). Every other pair is lower.
- Looked at `compare.png` across 4 iterations. Fixes: crocus petals (a flat purple slab became pointed petals), chilli (strawberry, then a taller tapered pod), ferry (box, then canopy + hull + river; hook blanks no longer leave islands), kite (smaller tri knobs, sky-teal bottom, tabs coloured like their quadrant), stupa (spire added, mitts made lavender).

## Pipeline
- Script: `art-review/pilot/spicepeak/draw_pilot.py`. Python 3 + Pillow only, deterministic. Each pal is one function of about 30 to 50 lines, built from shape predicates (rect, ellipse, polygon, thick path, and a generic `knob(kind, style, point, normal)` that also works on diagonal edges for whimsy shapes). Parts are painted in order. The renderer adds rim light, a lower-right crescent shade, the dashed felt stitch (64 px only), eyes, mouth and blush helpers, and the umber outline. The same functions draw at 64 and 36 px, with small-size branches (`c.small`).
- Ramps are copied from the picture's own scene script (`aseprite-source/scenes-pil/jigsaw_spicepeak.py`), so palettes match the picture exactly.

**Cost per pal (this pilot):** about 15 to 25 minutes of agent time, or roughly 40k to 80k tokens, for design, code and 2 to 3 look-and-fix loops. The kit itself (renderer, knobs, compare sheet) was a one-off of about 1 hour. Scaling to 570 pals at the pilot rate is roughly 150 to 230 agent-hours. That is too much to do without the changes below.

**Before scaling to all 570:**
1. Move the kit (renderer, knobs, eyes, checks, compare sheet) into a shared module, for example extending `aseprite-source/pals/palib.py` with a "merged" mode, and leave only the per-pal function in each picture script. Read the ramps from each `jigsaw_<slug>.py` automatically.
2. Add a written concept step first: one line per pal ("thing + which part is which tab or blank + motif"), produced in bulk from the briefs (`tools/pal_briefs.py`) and approved by the owner before drawing. Most of the iteration time went on concepts that did not read (strawberry chilli, box ferry), not on pixels.
3. Automate the squint test: downscale the silhouette to 18 px and check that each tab and blank still changes the outline; flag rosters where any pair has IoU above about 0.75.
4. Make one review sheet per picture, and have the owner pass or fail it, so failures go back as single-pal rework.
5. Risks: subjects that do not fit a rectangle (people, animals in profile; the yak only works face-on); knobs on diagonal whimsy edges (see Kite) need their own rules, for example knobs only on the two longest edges; 36 px loses mouths and small props, so the core idea has to be in the silhouette and the main colour blocks; style drift across about 95 pictures unless the kit stays fixed; and gameplay sizing, since the old perch art is 36 px and the old yard art is 64 px, and these files would replace both.

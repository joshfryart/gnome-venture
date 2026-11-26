# Spicepeak pilot: 6 Puzzle Pals redrawn as merged creature-pieces

Staging only. Nothing under `game/` was touched. Rerun: `python3 art-review/pilot/spicepeak/draw_pilot.py`.
Files: `<key>.png` (64 x 64 master), `<key>-36.png` (36 x 36, re-rasterised from the same shapes with its own eyes and mouths, plus knobs 12 to 15% larger so tabs survive; not a resize), `compare.png` (OLD | NEW 64 | NEW 36 at 4x on light #f1ece0 and dark #2a1a10, with the source cell).

How I read the shape codes (`claude/plan-puzzle-pals.md` section 6, `PPAL_SHAPES` / `PPAL_KNOBS` in `game/includes/puzzle_pals.php`): T = tab out, B = blank in, F = flat. Corner = 2 flat sides, edge = 1 flat side, inner = none. The letters list the non-flat sides; the code does not fix which side is which, so I picked the rotation that best fits each creature. Knob styles: round, keyhole, peg (square), tri, double (two lobes), hook. Hook blanks are cut as a comma-shaped hole, because a ring-shaped blank leaves a floating island of body.

## The pals

**sp-saffron-snip, Saffron Snip** (corner-BB, round). *Round 2.* A saffron crocus head. The body is a square corner piece: flat W and S sides, round blanks N and E. The top half is one purple crocus cup: two outer petals with rounded tips at the top corners wrap a paler centre petal. The N blank is the gap where the petals open. Three bold red saffron stigmas with flared orange tips fan up around that blank; they are the signature. Thin green crocus leaves sit either side of the cup, the face is on the green below the cup, and there is a terrace step along the flat bottom. Palette: cell 2-6 (terrace green, beige stone wall, teal and green). Crocus purple comes from the picture's own `#8a5aa8`.
*Verdict: squint PASS (a square corner piece with two round bites), name PASS (a flower cup with red threads; the three stigmas can be read together as a "V", but no longer as ears or a crown), picture PASS.*

**sp-yak-yonder, Yak Yonder** (edge-TTB, double). A laden yak, seen from the front. Its hooves stand on the flat S side. The N double tab is two orange bundles roped on its back, and the E double tab is a saddlebag. The W double blank is cut into its shaggy side. Cream horns break out at the top corners. Palette: cell 5-5's tiger moth (orange with a cream zigzag, on the packs and the chest blanket) on yak brown from the bridge yak.
*Verdict: squint PASS, name PASS (the strongest of the six), picture PASS.*

**sp-chilli-chime, Chilli Chime** (inner-TBTB, peg). *Round 2.* A square chilli-bundle body, built the same way as the Yak. It is a flat, glossy red square under a smooth green calyx cap. The N peg tab is the stalk, with a curl. The S peg tab is a small brass chime bell. The square peg blanks E and W are cut into its sides. A souk garland hangs across its middle: a gold thread with three orange chillies. I removed the stitch line and the leafy zigzag cap, because those made it read as a strawberry. Palette: cell 9-6 (chilli red, spice orange and gold, green stalk).
*Verdict: squint PASS (the peg piece outline is now unmistakable), name PARTIAL (the stalk curl and the chilli garland say chilli, but on its own the red square could pass for a bell pepper or tomato; it is the weakest name of the six), picture PASS for colour (the cell's brown shelving is not used).*

**sp-stupa-snug, Stupa Snug** (inner-TTTT Plus, double). A small white stupa. The N double tab is the gold finial, with a thin spire. The E and W double tabs are lavender mitts, and the S double tab is two lavender feet. It has the painted stupa eyes with arched lids and the little red curl nose, the gold zigzag band, base windows, and a string of five prayer flags over the dome. Palette: cell 8-2 (stupa white, lavender mountain, flag red, blue, green and yellow, gold zigzag).
*Verdict: squint PASS (a clear plus shape; the side tabs look a bit like dog bones), name PASS, picture PASS.*

**sp-teal-ferry, Teal Ferry** (inner-TTBB, hook). *Round 2.* The flower ferry. It is a square piece divided into three bands: a heap of garland flowers aboard (pink, magenta and marigold on green, with a little mast and a red pennant, the ferryman's hat colour); a curved wooden hull with an upswept stern and prow, carrying the face; and a band of teal river with foam. I rotated the tabs to E and S: the E hook tab is the prow curling out of the hull, and the S hook tab is a grey anchor hook hanging under the water. The hook blanks are N and W, cut into the flower heap. Nothing is cut into the river any more, so it no longer looks like legs. Palette: cell 6-6 (river teal and foam, boat wood, garland pink, gnome red).
*Verdict: squint PASS, name PASS (boat on water with flowers aboard; at 36 px the hull curve and water band still read), picture PASS.*

**sp-lofty-kite, Lofty Kite** (rare, whimsy-kite, tri). A diamond kite. The whimsy shape is the kite itself, with tri tabs on its NW and SE edges and tri blanks on its NE and SW edges. It has cross spars, a ribbon tail with two bow ties, and eyes that look down ("looks down on everything"). The top half is saffron and orange like the kite over the ridge; the bottom half is sky teal, because cell 4-0 is mostly sky.
*Verdict: squint WEAK (knobs on diagonal edges make the outline busy, a bit like a star, and the tabs read as ears more than as jigsaw tabs), name PASS (diamond, spars and tail say kite), picture PASS.*

Summary after round 2: Yak, Stupa, Saffron and Ferry pass all three tests. Chilli passes squint and picture but is only partial on name (it can read as a red pepper). Kite is still weak on squint. Yak, Stupa and Kite were not changed in round 2.

## Checks (run by the script, last run)
- Sizes: 64 x 64 and 36 x 36, RGBA. Alpha is only 0 or 255 in all 12 files. No #000000 pixel. The outline is umber #2a1a10, 1 px, 4-adjacent.
- Colours per file: 13 to 22 (limit about 40). Saffron 17/19, Yak 15/16, Chilli 17/15, Stupa 20/19, Ferry 21/20, Kite 22/21.
- Silhouettes: all 6 are unique at both sizes. The most alike pairs are Chilli vs Ferry at 64 px (IoU 0.68) and Saffron vs Ferry at 36 px (IoU 0.70).
- Looked at `compare.png` across 4 iterations. Fixes: crocus petals (a flat purple slab became pointed petals), chilli (strawberry, then a taller tapered pod), ferry (box, then canopy + hull + river; hook blanks no longer leave islands), kite (smaller tri knobs, sky-teal bottom, tabs coloured like their quadrant), stupa (spire added, mitts made lavender).
- Round 2 (owner feedback): I redrew Chilli, Ferry and Saffron and looked at `compare.png` and zoomed sheets 3 more times. Fixes: the stigma "V" competed with the face, so the face moved to the leaves; the chilli stitch and zigzag cap read as strawberry seeds and leaves, so I removed them and made the garland chillies orange so they show; the ferry's S blank in the river looked like legs, so I rotated the tabs to E and S (anchor).

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

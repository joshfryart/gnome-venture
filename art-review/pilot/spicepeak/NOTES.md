# Spicepeak pilot: 6 Puzzle Pals redrawn as merged creature-pieces

Staging only. Nothing under `game/` was touched. Rerun: `python3 art-review/pilot/spicepeak/draw_pilot.py`.
Files: `<key>.png` (64 x 64 master), `<key>-36.png` (36 x 36, re-rasterised from the same shapes with its own eyes and mouths, plus knobs 12 to 15% larger so tabs survive; not a resize), `compare.png` (OLD | NEW 64 | NEW 36 at 4x on light #f1ece0 and dark #2a1a10, with the source cell).

How I read the shape codes (`claude/plan-puzzle-pals.md` section 6, `PPAL_SHAPES` / `PPAL_KNOBS` in `game/includes/puzzle_pals.php`): T = tab out, B = blank in, F = flat. Corner = 2 flat sides, edge = 1 flat side, inner = none. The letters list the non-flat sides; the code does not fix which side is which, so I picked the rotation that best fits each creature. Knob styles: round, keyhole, peg (square), tri, double (two lobes), hook. Hook blanks are cut as a comma-shaped hole, because a ring-shaped blank leaves a floating island of body.

## The pals

**sp-saffron-snip, Saffron Snip** (corner-BB, round). *Round 2.* A saffron crocus head. The body is a square corner piece: flat W and S sides, round blanks N and E. The top half is one purple crocus cup: two outer petals with rounded tips at the top corners wrap a paler centre petal. The N blank is the gap where the petals open. Three bold red saffron stigmas with flared orange tips fan up around that blank; they are the signature. Thin green crocus leaves sit either side of the cup, the face is on the green below the cup, and there is a terrace step along the flat bottom. Palette: cell 2-6 (terrace green, beige stone wall, teal and green). Crocus purple comes from the picture's own `#8a5aa8`.
*Verdict: squint PASS (a square corner piece with two round bites), name PASS (a flower cup with red threads; the three stigmas can be read together as a "V", but no longer as ears or a crown), picture PASS.*

**sp-yak-yonder, Yak Yonder** (edge-TTB, double). A laden yak, seen from the front. Its hooves stand on the flat S side. The N double tab is two orange bundles roped on its back, and the E double tab is a saddlebag. The W double blank is cut into its shaggy side. Cream horns break out at the top corners. Palette: cell 5-5's tiger moth (orange with a cream zigzag, on the packs and the chest blanket) on yak brown from the bridge yak.
*Verdict: squint PASS, name PASS (the strongest of the six), picture PASS.*

**sp-chilli-chime, Chilli Chime** (inner-TBTB, peg). *Round 3.* A hanging bunch of three long, tapered chillies (deep red, red at the front with the face, and orange-red), tied at the top. The bunch is the piece. The three pods pack into the square body, with shelf-maroon shadow between them. The N peg tab is the tied green stalks, with a gold cord wrap and one curled stalk end. The S peg tab is a brass chime bell hanging from the front pod's tip. The square peg blanks E and W bite into the outer pods. Below the blanks the pod tips taper off, so the bottom edge is three points, not a flat line. Palette: cell 9-6 (chilli-garland red, spice gold, shelf maroon-brown, green stalks).
*Verdict: name PASS (reads as a bunch of chillies at 64 and 36 px; no longer a strawberry or tomato), picture PASS, squint PASS but the weakest square of the inner pieces (peg top, bell bottom and both square notches are clear, but the pointed pod tips make the lower outline jagged rather than straight).*

**sp-stupa-snug, Stupa Snug** (inner-TTTT Plus, double). A small white stupa. The N double tab is the gold finial, with a thin spire. The E and W double tabs are lavender mitts, and the S double tab is two lavender feet. It has the painted stupa eyes with arched lids and the little red curl nose, the gold zigzag band, base windows, and a string of five prayer flags over the dome. Palette: cell 8-2 (stupa white, lavender mountain, flag red, blue, green and yellow, gold zigzag).
*Verdict: squint PASS (a clear plus shape; the side tabs look a bit like dog bones), name PASS, picture PASS.*

**sp-teal-ferry, Teal Ferry** (inner-TTBB, hook). *Round 2.* The flower ferry. It is a square piece divided into three bands: a heap of garland flowers aboard (pink, magenta and marigold on green, with a little mast and a red pennant, the ferryman's hat colour); a curved wooden hull with an upswept stern and prow, carrying the face; and a band of teal river with foam. I rotated the tabs to E and S: the E hook tab is the prow curling out of the hull, and the S hook tab is a grey anchor hook hanging under the water. The hook blanks are N and W, cut into the flower heap. Nothing is cut into the river any more, so it no longer looks like legs. Palette: cell 6-6 (river teal and foam, boat wood, garland pink, gnome red).
*Verdict: squint PASS, name PASS (boat on water with flowers aboard; at 36 px the hull curve and water band still read), picture PASS.*

**sp-lofty-kite, Lofty Kite** (rare, whimsy-kite, tri). A diamond kite. The whimsy shape is the kite itself, with tri tabs on its NW and SE edges and tri blanks on its NE and SW edges. It has cross spars, a ribbon tail with two bow ties, and eyes that look down ("looks down on everything"). The top half is saffron and orange like the kite over the ridge; the bottom half is sky teal, because cell 4-0 is mostly sky.
*Verdict: squint WEAK (knobs on diagonal edges make the outline busy, a bit like a star, and the tabs read as ears more than as jigsaw tabs), name PASS (diamond, spars and tail say kite), picture PASS.*

Summary after round 3: Yak, Stupa, Saffron and Ferry pass all three tests. Chilli passes name and picture, and passes squint with a jagged lower edge. Kite is still weak on squint. Round 3 changed only Chilli.

## Checks (run by the script, last run)
- Sizes: 64 x 64 and 36 x 36, RGBA. Alpha is only 0 or 255 in all 12 files. No #000000 pixel. The outline is umber #2a1a10, 1 px, 4-adjacent.
- Colours per file: 13 to 22 (limit about 40). Saffron 17/19, Yak 15/16, Chilli 19/18, Stupa 20/19, Ferry 21/20, Kite 22/21.
- Silhouettes: all 6 are unique at both sizes. The most alike pairs are Chilli vs Ferry at 64 px (IoU 0.68) and Saffron vs Ferry at 36 px (IoU 0.70).
- Looked at `compare.png` across 4 iterations. Fixes: crocus petals (a flat purple slab became pointed petals), chilli (strawberry, then a taller tapered pod), ferry (box, then canopy + hull + river; hook blanks no longer leave islands), kite (smaller tri knobs, sky-teal bottom, tabs coloured like their quadrant), stupa (spire added, mitts made lavender).
- Round 2 (owner feedback): I redrew Chilli, Ferry and Saffron and looked at `compare.png` and zoomed sheets 3 more times. Fixes: the stigma "V" competed with the face, so the face moved to the leaves; the chilli stitch and zigzag cap read as strawberry seeds and leaves, so I removed them and made the garland chillies orange so they show; the ferry's S blank in the river looked like legs, so I rotated the tabs to E and S (anchor).
- Round 3: I redrew Chilli as a hanging bunch and reviewed it 3 times (zoom, `compare.png`, dark background). Fixes: the outer pods were too thin around the blanks and read as a "T", so I widened the body and moved the blanks down and made them smaller; two stalk curls read as antennae, so I kept one.

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

## Kit for scale-up (how one agent draws one pal)

Everything lives in `draw_pilot.py` and needs only Pillow. Copy the kit part (everything above `# ===... the six pals`) into a shared module, for example `aseprite-source/pals/mergedkit.py`, then write one function per pal.

**Geometry. All coordinates are in 64-unit space**, so the same code rasterises at 64 and 36 px:
- `rect(x0, y0, x1, y1)`, `ell(cx, cy, rx, ry)`, `poly(points)`, `thick_path(points, width)`. Each returns a predicate f(x, y) -> bool.
- `knob(kind, style, mx, my, nx, ny, r=4.5, nw=2.6, flip=False)`: a tab (`'T'`, union it) or blank (`'B'`, pass it in `minus=`). It sits on the side line through (mx, my), with outward unit normal (nx, ny), so it also works on diagonal whimsy edges. Styles: round, peg, tri, double, hook. Keyhole is not implemented yet; port it from `palib.knob_shape`. A tab reaches about 2r + 2 units out, and a blank cuts about 2r + 3 units in, so leave that much body behind every blank.
- Side order in a shape code is free. Rotate the T/B pattern to whichever sides suit the creature.

**Canvas `C(n)`**:
- `c.small` is True at 36 px. Multiply knob radii by `K = 1.15 if c.small else 1.0`.
- `c.m(*preds, minus=(...))` returns a pixel set.
- `c.add(mask, ramp, stitch=None)` paints a part. Later parts paint over earlier ones; the union of all parts is the silhouette. A ramp is (base, dark, light), taken from the picture's `jigsaw_<slug>.py`.
- `c.edge(mask, col)` draws an inner contour where one part sits on another.
- `c.line(points, col)`, `c.px(x, y, col)` (pixel coords) and `c.P(x, y)` (64-unit to pixel) are for details.
- `c.eye(x, y, disc=False, look=(dx, dy))`, `c.smile(x, y)` and `c.blush(x, y)` have separate 64 px and 36 px versions; that is where the 36 px "reduction" happens. Use `disc=True` on dark bodies.
- `render()` adds the rim light (upper left), the crescent shade (lower right, 2 px, or 1 px at 36), the dashed stitch (64 px only), the overlays, and the 1 px umber outline (4-adjacent). The output has hard alpha.

**Checks**: `check(img)` (size, alpha only 0 or 255, colour count, no #000000). `main()` also checks that silhouettes are unique and reports the most alike pair (IoU) per roster, and `compare()` builds the review sheet. Keep both in every run, and fail a roster if the IoU is above about 0.75.

**Recipe per pal (about 40 lines)**: (1) write one line first: thing + which side is which tab or blank + motif from the cell; (2) build the core and knobs, then `body = c.m(core, tabs..., minus=blanks)`; (3) paint 3 to 6 parts with picture ramps; (4) add the face last, on the biggest calm area; (5) run the script, look at a 6x zoom at 64 and 36 px on light and dark backgrounds, and fix; (6) record an honest verdict for each test.

**Failure modes seen in this pilot (check for these first)**:
1. Creature-shaped blob: the outline follows the creature and the piece disappears (Chilli round 1). Keep a square-ish core with straight sides between knobs.
2. Piece with a picture on it: a box with a face, and the thing only in the paint (Ferry rounds 1 and 2). The thing's main cue (hull curve, cup, horns) must reach the outline or fill the body.
3. Spikes at corners read as ears or a crown (Saffron round 1). Round the tips, and make the signature detail (stigmas) larger than the shape gimmick.
4. Decor that reads as something else: dashed stitches on red read as strawberry seeds, and a zigzag green cap reads as strawberry leaves (Chilli round 2). Leave the stitch off small busy bodies.
5. A blank cut into a narrow band reads as legs (Ferry round 2, water band). Put blanks into the large mass and rotate the shape if needed.
6. A ring-shaped hook blank leaves a floating island of body. The kit now cuts hook blanks as a solid comma.
7. A face next to a V-shaped detail becomes a beak or owl (Saffron round 2). Keep the face away from strong lines.
8. Knobs on diagonal whimsy edges make the outline busy (Kite). Use smaller knobs, or put them on only two edges.
9. At 36 px: 1 px threads vanish (use width 2.6 or more units), stitches are dropped, and mouths shrink to 4 px. The idea has to live in the silhouette and the big colour blocks.
10. The umber outline disappears on the dark #2a1a10 background. That is by design (same as the old stickers), but judge the silhouette on the light sheet.


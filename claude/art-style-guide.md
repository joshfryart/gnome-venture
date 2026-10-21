# Hearthlight: Gnome Venture art style guide (v2, FINAL, frozen after 10 iterations)

**Philosophy.** Every picture is a die-cut sticker lit by one warm lamp: cream halo, warm umber line, one lower-right cel shade.
Chunky, readable at 32px, cosy not glossy. Restyle, do not redraw: source shapes stay, the treatment unifies. Source of truth: `hearth.py` (`restyle(src, name)`).
u = min(viewBox w, h) / 64. All numbers below are in u unless stated.

## Palette and tokens
| Token | Hex | Use |
|---|---|---|
| umber | `#2a1a10` | outline, ink (replaces `#2b2b2b`, `#000`), pupils, marks |
| halo | `#f2e4c0` | sticker rim (v1 was `#f4ead2`; trimmed so it does not glare on `#1b1b1b`/`#241d17`, still invisible-safe on `#fffaf0`) |
| ground shadow | `#6a4528` @ .5 + `#f2e4c0` ring @ .3, 1u | under standalone objects |
| rim light | `#fff1c8` @ .26 | top-left sliver |
| glint | `#fffaf0` @ .8 | one specular spot |
| shade tints (hue of dominant fill) | green `#17361c`, red `#5a1410`, blue `#12324a`, dusk `#2e1a5a`, gold `#5a3008`, wood `#4a1c10`, stone `#3a2236` | cel crescent, @ .34 (scenes .24) |
| characters shade | `#3a1c10` @ .34 | creatures and npcs |
Warmed remap (REMAP in hearth.py): wood `#8c4a1a #a5663a #44281c`, gold-tan `#dcb06a`, stone plum-greys `#968f96 #6a6070 #d6c9b6`, moss `#58a03e #2e5a2c #b0bc66`, water `#256a80 #3f93b2`.
Char remap: taupe fur `#8f7060 #a38f80`, cream `#e6d2ae #f8eed2`, rose `#d9667f`, pale water `#b8d8d2`, red `#9c2a1e`.
Dark page `#1b1b1b` / cards `#241d17` (cream hairline, 2px hard shadow); light page `#f4f0e0` / cards `#fffaf0`. Pure `#fff` only as glint/eye.

## Core rules (items, tools, foods, crops, props; the default path)
1. **Halo**: silhouette copy, fill+stroke halo colour, **3.2u** per side, round join/cap, bottom layer. npc portraits x0.6 (1.9u).
2. **Outline**: silhouette copy above the halo, umber, **1.9u** per side (ring stays 1.5u visible). Pen tiers per leaf: bbox < 9u: -0.4u; > 26u: +0.3u (halo follows).
3. **Silhouette inclusion**: skip strokes < 2.6 (except char antennae/stalks >= 5u long), circles r < 3 (become round-cap dots), white strokes, opacity < .3, ground shadow, `<text>`, inner emblems scaled < .6. Pruned: shapes inside a bigger ellipse, duplicate paths (widest only).
4. **Shade**: ONE crescent: full bbox rect minus an ellipse at (.40W, .36H) with radii .52 of the silhouette bbox, clipped to the silhouette. Light is top-left always. Stages use fixed bbox (8,4,56,60) and fixed tint.
5. **Rim light**: second crescent offset (.56, .57), radii .68, `#fff1c8` @ .26. Skipped for npc, chars (LEAN), nav, stages, trimmed icons.
6. **AO**: ellipse at bbox bottom (rx .62w, ry .2h) shade tint @ .22, clipped; skipped for diagonal/thin things (bee hoe trowel spade rake wand staff stick), nav, chars, stages, h/w <= 16.
7. **Glint**: one ellipse (rx 1.6r, ry r, r = max(1.5, .07 min dim)), rotated -38deg, at (.3, .28) of the largest filled leaf, clipped. Only if bbox >= 22u; none on chars, npc, nav, stages, fences.
8. **Ground shadow**: source `#000` ellipse becomes warm `#6a4528` @ .5 with a 1u cream ring @ .3; never in halo/outline/clip. No ring on nav or hedges.
9. **Material marks** (top 2-4 shapes >= 14u, <= 3 marks, merged, clipped): wood 3 umber ticks .4; stone 2 cream streaks; water 1 wave; leaf 1 centre vein `#17361c`; soil 3 pebbles `#f0d49a`; shell 2 arcs (rx >= 10 only). None on chars, nav, stages, hedges.
10. **Inner contour**: 1u umber @ .55 on shapes >= 12u (off for nav, hedge, chars, and as a trim rung).
11. **Thin wood**: straight shafts widened to **6.6u** (soil 500 `#a5663a`), detail wood lines become umber 2.4u. Fit step counts this widening.
12. **Fit**: if the silhouette comes within **3.4u** of the frame, scale (k < 1) to a 4.2u margin about the box centre; if it already fits but is off-centre, shift minimally to a 3.6u margin. Scenes, tiles, npc, stage, fences, hedges, logos exempt. Rotated rects/ellipses count with their rotated corners.

## Per category
- **Scenes** (first child a full-size rect: banner-, land-, guide-): no halo; frame inset 1.6u umber @ .5; shade .24; <= 8KB.
- **Tiles** (`tile-*`): no halo/outline/shadow; one shared grain path `M12 20h4M44 8h3M26 46h4M52 38h3M8 56h3M36 28h3` umber 1u @ .14; seamless 4x4.
- **Stages** (`stage-*`): 4 steps share mound, frame, tint; base is pixel-identical across steps. `stage-tree-4`, `stage-nut-4` crowns shrink x.85 about (32,50) so the top halo is not clipped.
- **Hedges / fences** (`*-hedge-*`, `*-border-*`, `picket-/wattle-fence-*`; straight corner tee cross end gate): one lattice, **6.4u pitch** (hedge dots as round-cap paths), same y band, width and phase on every piece, rails run past the edges. Fixed band shade, no per-piece glint/marks/inner/ground ring: runs join with no seam.
- **Creatures / npcs** (LEAN): 1-decimal numbers; no rim/AO/marks/glint/inner contour; transforms baked into geometry (rotated ellipses and paths become arcs); whisker hairlines become umber @ .55 1u; translucent white wings become solid `#e6f1ec`.
  **Eye recipe** (`eye_pass`): white disc `#fffaf0`, umber ring (.5 opacity, only r >= 2.6), umber pupil r >= 1.25 (1.55 x), cream glint only if pupil >= 3.1; all as round-cap dot paths drawn above the shade.
- **Swarm fallback** (char > 3.9KB): ellipses (aspect <= 3.2) become round-cap capsules in halo/outline; hairline legs/antennae leave halo/outline, widths snap to 1/1.5 so same-colour limbs bucket-merge across individuals; clip keeps only shapes >= 20% of the largest; tiny marks inside a bigger bbox are pruned.
- **Nav** (24px): no rim/AO/glint/marks/inner/rx/ground ring; integer coords; rx < 3.5 dropped.
- **Hats, landmarks, buildings, tools, broken-, feast-**: full sticker; keep 4u clear margin after the halo.

## Size tiers and caps
| Class | Hard cap | Trim ladder (first rung <= 3.5KB wins) |
|---|---|---|
| banner-, land-, guide- | 8KB | none |
| creature-, npc- | 4KB | LEAN, then swarm fallback at > 3.9KB |
| everything else | 4KB (soft 3.6KB) | 1 full; 2 no rim/AO/glint; 3 + no inner contour; 4 + no marks; 5-7 same + capsule silhouettes + rx <= 1.6u dropped |
Byte tricks (all in hearth.py): >= 3 same-colour same-r circles become one dots path; abutting equal-width rects union in the silhouette; the fit transform is baked into geometry so clip copies stay transform-free; rotated own `rotate()` ellipses/rects fold under translate+scale; `merge_shapes` buckets same-style leaves.
Current full set (1,428 ph icons): 0 errors, 0 over hard cap, avg 2.3KB, max non-scene 3,986B.

## Banned
`<script> <style> style= filter xlink href <image> <foreignObject> on*=`; `<use>`; gradients (flat cel only); cold grey outlines; text; > 5 hues per icon; halo on tiles or fence joins. Keep `role="img"` + `aria-label`. Numbers: 2 decimals (chars 1). CSP is style-src 'self'.
IDs: clipPath id = `hl-` + full slug (v1 truncation caused 101 duplicates); must be unique across the whole set. viewBox never changes.

## How to run
```
cd art/iter/i10           # hearth.py lives here; repo ph/ is read-only
python3 all.py .          # restyle ALL ph icons -> svg-all/; prints errors, over-cap by category, dup ids, forbidden, viewBox, size vs original
python3 run_iter.py .     # 24 samples -> svg/, caps check
python3 rand60.py . SEED  # stratified random 60 + checks + random60-412/1400.png (try seeds 1-23)
python3 edgecheck.py svg-all   # renders every icon at 64px, flags halo touching the frame, blank/tiny icons
python3 rungs.py NAME...  # byte size at each trim rung for one icon
python3 final.py . ; python3 progression.py .   # final-*.png, progression-*.png
```
Adoption: copy `hearth.py` to `tests/hearth.py`, write `svg-all/*.svg` over `ph/` (keep names), re-run the validators in the repo CI.
New art: draw plain shapes in palette colours, ink `#2b2b2b`, no halo/shade; run `restyle`; check 32/64/128 on both pages; 412px sheet has no horizontal scroll.

## Review checklist
- [ ] Reads at 32px on `#1b1b1b` and `#f4f0e0`; nothing important is only a glint
- [ ] Halo 3.2u / outline 1.9u umber; shade lower-right; no clipped halo (edgecheck clean)
- [ ] Thin parts thickened or excluded; shafts 6.6u
- [ ] ids `hl-{slug}` unique; <= cap; no banned strings; viewBox unchanged
- [ ] Tiles seamless; fences join; stages keep the base fixed

## Iteration log
| # | Focus | Key change |
|---|---|---|
| 0 | pilot baseline | halo 3.4u + umber 1.9u + one fixed crescent; hl- ids |
| 1 | silhouette | wood shafts >= 6.6u, umber detail lines, 1u inner contour |
| 2 | colour warmth | warmed REMAP, hue-tinted shade, halo `#f6e9c9`, stroke-width hoist |
| 3 | shading depth | bbox-sized shade ellipse + cream rim-light crescent |
| 4 | glints + grounding | warm ground shadow with cream ring, AO band, single rotated glint |
| 5 | materials | wood/stone/water/leaf/soil/shell marks, byte guard ladder |
| 6 | characters | eye recipe (disc, ring, pupil, glint), warm char palette, bee wings |
| 7 | legibility + size diet | size tiers (inner >= 12u, marks >= 14u), baked transforms, shape merging, nav diet |
| 8 | family consistency | hedge lattice, fixed stage frame, tile grain |
| 9 | polish + theme balance | halo `#f2e4c0` 3.2u, pen tiers, fences on lattice, 4.2u fit margin |
| 10 | final freeze | swarm fallback, capsule/rect-union/dot bytes, fit 3.4u + shift, full-set run: 0 errors, 0 over cap |

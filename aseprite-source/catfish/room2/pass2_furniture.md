# Pass 2: polish notes for room A furniture (P3)

Review images: `out_furn/_view/review/p2/` (`<key>_8x.png` or `_4x.png` on #c78d52, `<key>_half2x.png` for 0.5x, `<key>.txt` for the half-grid ascii).
Coordinates are on the half grid (canvas = export/2). "Contour" means the gvlib inner contour. It is on by default for `S.part`, because `outline=false` sets `contour=true`. It paints #4a2c1a or #2a1a10 wherever a part touches an earlier part.

## Changes, highest priority first

1. **`make()`: clean the outline after `c:outline` and before the shadow block** (only when `not meta.noline`). Run 2 passes. Count only in-bounds 4-neighbours that hold a pixel (`c.pix`).
   - An empty px with >=3 neighbours gets `#2a1a10` (a pinhole).
   - A px that is not in `sil`, has <=1 neighbour and has no 4-neighbour in `sil` gets `nil` (a stray outline px).
   - This fixes these pinholes: cushion (31,1), bowl (18,0), books (4,8) and (8,8), plant (3,5) and (12,5), cattree (3,42).
   - It removes these strays: bowl-plain (16,0), books (17,0), cattree (21,25).
   - Leaf tips, petfish (8,2) and petbell (0,9) touch body pixels, so they stay.
2. **Remove the false contours at joins.** Add `contour = false` to these parts:
   - cattree `post()`: `{cres=2, gloss=false}` -> `{cres=2, gloss=false, contour=false}`. This removes the #2a1a10 bar on rows 29 and 48, x10-15, which reads as a slot. The post's 1 px contact (GREEN.shade on the slab below) stays.
   - scratch `post`: the same change. This removes the dark row 31, x4-9.
   - scratch `cap`: add `contour=false`. This removes the #4a2c1a row 5, x4-9. Then add `c:fill(c:rect(5,5,8,5), GREEN.shade)` after the cap, as the ball's contact.
   - toybox front face: see #5.
   - plant: in `leaf()`, add `contour=false` (see #6).
3. **Cattree top bed: the edge is green.** `slab()` always fills `edge` with GREEN.shade, so the pink bed sits on a green band (rows 10-12). The dip also turns the whole top PINK.shade.
   - Add a 7th argument `edgecol` to `slab()`: `c:fill(edge, edgecol or GREEN.shade)`.
   - Top bed: `slab(12.5, 8, 8, 2, PINK, false, PINK.shade)`, with no gloss.
   - Delete `c:fill(c:ellipse(12.5,7.5,5,1), PINK.shade)`.
   - Then `c:paint(rows, 4, 6, {R=PINK.rim, B=PINK.base, S=PINK.shade})`:
   ```
   .....RRRRRRRR.....   y6
   .RRRSSSSSSSSSSBBB.   y7  far inner wall shaded
   .RRBBBBBBBBBBBBBS.   y8
   .BBBBRRRRRRRRBBSS.   y9  near lip lit
   .SSSSBBBBBBSSSSSS.   y10
   .SSSSSSSSSSSSSSSS.   y11
   .....SSSSSSSS.....   y12
   ```
   This adds no new colours (the sprite stays at 16).
4. **Cattree bell: open the dark blob.** Outline fills x6-9, rows 38-44.
   - String `line{{4,32},{4,37}}` -> `line{{3,33},{3,35}}`.
   - Bell `ellipse(4.5,39,2,2)` -> `ellipse(3.5,38,2,2)`.
   - Check: x8 is transparent on rows 36-41, and x3 is transparent on rows 43-45.
5. **Toybox front: the lip merges with the face.** Rows 7-9 are all WOOD.rim, and there is a stray contour dash of #4a2c1a at (5..7,8) under the yarn.
   - Front face opts -> `{cres=3, gloss=false, contact=false, contour=false, rim=false}`.
   - After the front-rim `S.flat`: `c:fill(c:rect(2,8,20,8), WOOD.shade)` (the under-lip shadow).
   - Gloss tick: `c:px(3,9,"#f5cf6a"); c:px(4,9,"#f5cf6a")`.
   - Keep the x1 WOOD.rim column.
   - Result, top to bottom: row 7 rim, row 8 shade, row 9 base plus the tick, rows 10-11 felt, row 12 seam, row 13 base. The sprite stays at 16 colours.
6. **Plant pot top: no lit lip, and 3 dark rows (18-20) cut the leaves off the pot.**
   - In all three leaf polys, change y 19 -> 18.
   - Delete the `ellipse(7.5,19.5,6.5,1)` rim fill and the `ellipse(7.5,19.5,5,0.5)` soil fill.
   - Replace them with:
     - `c:fill(c:rect(2,19,14,20), TERRA.rim)`
     - `c:fill(c:rect(4,19,12,19), "#5e2f1e")` (soil row; leaves rise from it)
   - Keep row 21 as TERRA.shade.
   - Rows 18-21 then read: leaf base / rim+soil / rim / shade.
7. **Fancy bowl: the side wall is hidden.** The `body` poly sits entirely under the rim, and the cream dots sit on the lip.
   - `body = c:rect(5,6,16,7)`.
   - `foot = c:rect(7,8,14,8)`.
   - Dots: `c:paint({"g.g.g.g"}, 7, 7, {g=CREAM})`, i.e. x7, 9, 11, 13 on the wall.
   - Delete the foot `c:seam`.
   - Meta: `foot={5,16}, shadow_over=true`.
   - Rows: 6 = lip x6-15 (PINK.rim) with a wall px at x5 and x16; 7 = wall plus dots; 8 = gold foot; 9-10 = shadow.
8. **Rug band: remove the diagonal tone split.** It makes a hard step mid-band at export x≈342. Change `band:each(...)` -> `c:fill(band, "#e8d0a0")`. This takes the rug from 8 to 7 colours.
9. **`make_view_furn.py checks()`: add (d).** For every sprite without `noline`, sample the half grid (`px[2x,2y]`):
    - pinholes == 0: empty cells with >=3 opaque 4-neighbours, not counting `#9a6b3f`.
    - strays == 0: outline px (#2a1a10, #4a2c1a, #74462a) with <=1 opaque neighbour and no body neighbour.

    Print the coordinates on failure.
10. **`review()`:** write `_8x.png` when width < 60 (else `_4x`), plus `<key>_half2x.png`: 0.5x NEAREST, then up 2x on #c78d52.

## Acceptance
- GV report ALL OK. Colours: cattree 16, toybox 16, rug 7, the rest unchanged or lower.
- checks() (a)-(d) pass.
- Ascii checks (half grid):
  - cattree rows 29 and 48, x10-15 hold no #2a1a10 or #4a2c1a.
  - cattree rows 10-12 hold no #3f7a3a or #5f9e48.
  - scratch row 31, x4-9 is not #2a1a10.
  - toybox (5..7,8) is #8a4f2a.
  - plant row 19 x4-12 is #5e2f1e, row 20 x2-14 is #e08a5a, and row 18 contains no outline tones between x2 and x14.
  - bowl row 7 has #f2e4c0 at x7, 9, 11, 13.
- At 8x: the cattree bell has a floor-coloured gap between it and both the post and the base.
- At 0.5x: the bed top reads pink with a darker back wall, the plant leaves join the pot, and the bowl shows rim, wall and foot as 3 bands.

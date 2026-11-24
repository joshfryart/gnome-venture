# Pass 1: perspective notes for room A furniture (P3)

Review images: `out_furn/_view/review/`.
All coordinates below are **half-grid** (canvas = export/2) unless marked "export".

**Floor maths** (from the seams in make_view_furn.py): x_k lines meet at VP (240,-83) export. Rule for the ellipse squash of a round top at export y:
`k(y) = 0.36 * (y + 83) / 323`. So k(240)=.36, k(204)=.32, k(170)=.28, k(132)=.24, k(76)=.18.
Now: cushion .24, bowls .23, tree slabs side-on (k≈0), rug top 3 px too wide.

## Changes, highest priority first

1. **Shadow rule, `make()` lines 43-49.** The shadow is 0.8 x sprite width, centred. It is narrower than the cattree, scratch and toybox bases, so they float. Replace it with a footprint shadow shifted 1 grid right (light comes from the upper left):
   `meta.foot={x0,x1}`, row S.h-2: x0..x1+1, row S.h-1: x0+2..x1+1. Values: cushion {3,36}, bowl-plain {3,15}, bowl {4,17}, toybox {1,20}, cattree {1,24}, scratch {1,12}. Yarnball: `shadow=false` (#8).
2. **Cushion, 80x30 -> 80x36.** `top = ellipse(19.5, 7, 17, 6)` (k .35). `side = shift(0,1)+shift(0,2)`. Add the cushion rim and dip: `inner = ellipse(19.5, 7.5, 11, 3.5)` filled PINK.base. Paint `inner:cut(inner:shift(1,1))` PINK.shade (upper-left inner wall) and `inner:cut(inner:shift(-1,-1))` PINK.rim (lower-right inner wall, lit). Delete the 3 tuft lines. Move `button` -> (19, 8). Seam -> `{{5,12},{12,14},{27,14},{34,12}}`. Gloss -> {8,3}, on the rim ring.
3. **Bowl-plain, 36x14 -> 36x18 (18x9 grid).** Opening as an ellipse (k .33), not a lozenge. `c:paint` these 7 lines at (0,1); the silhouette is every painted cell. Legend: R TERRA.rim, B TERRA.base, S TERRA.shade, k WOOD.rim, K WOOD.base.
   ```
   ....RRRRRRRRRR....
   ..RRSSSSSSSSSSRR..
   .RRSkKkKkKkKkKSRB.
   .RRkKkKkKkKkKkKRB.
   ..RRRRRRRRRRRRRBB.
   ...BBBBBBBBBBBSS..
   ....SSSSSSSSSS....
   ```
4. **Bowl (fancy), 44x18 -> 44x22 (22x11).** Same structure: rim `ellipse(10.5, 3.5, 9.5, 3)`, opening `ellipse(10.5, 3.5, 7.5, 2)`. The top row of the opening is PINK.shade (far wall) and the rest is kibble (k/K checker). Front lip is the rim ellipse's bottom row, in PINK.rim. Body `poly{{2,4},{19,4},{16,7},{5,7}}` PINK. Foot `rrect(6,7,15,8,1)` GOLD. CREAM dots `g.g.g` at (8,6). Seam {{6,8},{15,8}}.
5. **Cattree platforms become ellipse tops with 2-row edges.** Draw order is back to front: base, lower post, mid, upper post, top bed (posts end at the ellipse centre row, so they sit *on* the slab).
   - base: `ellipse(12.5, 48, 11.5, 3)` + `shift(0,1..2)` edge in GREEN.shade (k .26 at export 154)
   - lower post: `rect(10, 31, 15, 48)`
   - mid: `ellipse(12.5, 29, 10.5, 2.5)` + 2-row edge (k .22)
   - upper post: `rect(10, 10, 15, 29)`
   - top bed: `ellipse(12.5, 8, 8, 2)` + 2-row edge, dip `ellipse(12.5, 7.5, 5, 1)` PINK.shade (k .18)
   - seams on the edge rows: {{2,50},{23,50}}, {{3,31},{22,31}}
   - bell string `line{{4,32},{4,37}}`, bell `ellipse(4.5, 39, 2, 2)`
6. **Rug: match the floor seams.** The top corners sit 3 px outside the VP lines. In `trap()`, `11.5` -> `13`. In the json, the quad becomes `[[101,247],[379,247],[353,186],[127,186]]` (spec §5 shows 124/356; record that in "note"). The rug is a floor decal, so set `noline=true` and drop the raised olx outline. Instead, paint `m:edge()` in GREEN.shade, and repaint its front row (y 30) in `#4a2c1a` as a 2 px lip. Flatten the tufts to 5x3: `{"..c..","cgggc","..c.."}` at x-2.
7. **Toybox: add the top face (k .24) and keep 44x34.** WOOD front face `rect(1,8,20,13)`. Felt band rows 10-11 (rim row 10, shade row 11), seam row 12. Top face: back rim `rect(2,4,19,4)` WOOD.rim, interior `rect(2,5,19,6)` `#5e2f1e`, front rim `rect(1,7,20,7)` WOOD.rim. Toys: yarn `ellipse(6,3,3,3)`, pink toy poly shifted +0,-1. Draw them after the interior and before the front rim, so the rim cuts their bottoms. Button (9,9).
8. **Yarn anchors.** Origin + size does not equal the anchor (ball bottom 205, patch bottom 206; anchor 204). Set the yarnball origin to (145,186) and the yarnpatch origin to (134,184). Also set yarnball `shadow=false`, so only the patch shadow (x148-167 export, offset right of the ball centre at 154) is used.
9. **Scratch post** (export y≈170, k .28). Base `rrect(1,29,12,33,2)` -> `ellipse(6.5, 31, 6, 2)` + 1-row edge GREEN.shade. Draw the post `rect(4,7,9,31)` after the base. Cap `rrect(2,5,11,8,1)` -> `ellipse(6.5, 6.5, 5, 1.5)` + 1-row edge. Seam {{2,32},{11,32}}.
10. **Plant pot opening.** Change `rect(1,19,14,20)` rim -> `ellipse(7.5, 19.5, 6.5, 1)` TERRA.rim. Inside it, add soil `ellipse(7.5, 19.5, 5, 0.5)` `#5e2f1e`, drawn before the leaves, so the leaves rise out of the soil.
11. **Books and bookstack (camera is above them).** Books: shade row `8-b[3]+1` -> CREAM page row at `8-b[3]`, cols b1+1..b2. Bookstack: top book (MOSS) row 2 -> MOSS.rim (top face), row 3 MOSS.base.
12. **json.** New sizes as above; origin = anchor - anchor_px (rug and yarn explicit). Add `"perch"` (export) points for cats: cushion [64,226]; cattree [434,152],[434,114],[434,74]; toybox none.
13. **make_view_furn.py `checks()`.** Add:
    - (a) `origin[1]+h == anchor[1]` and `origin[0]+w//2 == anchor[0]` for every sprite
    - (b) rug: each side line from the bottom corner toward (240,-83) hits y 186 within ±1 of the quad corner
    - (c) floor sprites: the rightmost `#9a6b3f` px > the rightmost body px in the last 4 rows
    - (d) write `_view/review/<key>_4x.png` on #c78d52, plus `preview_half.png` (0.5x NEAREST)

## Acceptance
- GV report ALL OK (semi 0, bw 0, ≤16 colours, new sizes).
- Measured ellipse ry/rx (outline excluded) within ±.04 of k(y): cushion .35, bowls .33, tree base .26, mid .24, top .18–.25, scratch base .33 (2/6 is the smallest step).
- At 4x, every floor piece's shadow is visible on the right and bottom only. No transparent row between the body and the shadow.
- At 0.5x: the cushion dip, bowl openings and tree tops read as tops; rug sides parallel to the nearest seams.
- checks() (a)–(c) pass. The anchors for model(u,d) stay within 4 px.

# Stitched Toy: artist brief (Part D + addenda, condensed)
Hand-stitched felt toys with enamel gloss. Hard pixels, one light from the upper left. Reference: the v09 ladybird and the approved pilots in `img-redraw-pilot/png/`.

## Pixels and sizes
- Every pixel is a solid palette colour or fully transparent. No anti-aliasing, blends, gradients or dither.
- 64x64 on the 64 grid. `npc-*` busts are 80x100. Map stops are 32 to 48. Scenes are drawn on a grid of about 100 px and written out at 2x.
- Parts, limbs and shafts are at least 2 px wide (icons 3). Stitches, glints and highlights are 1 px accents only.
- It must read at 32 and 16 px: main body colour, dark head, eyes.

## The layers (gvlib does these)
- No cream halo (retired 2026-10-22). Everything outside the art is transparent, then a post-pass adds a 1 px `#000000` border on every transparent pixel 4-adjacent to art (stickers, icons and busts; enclosed cream pockets under 8 px are kept). Draw with at least 3 px of room inside the frame for it. Scenes, banners, tiles and landing art are unchanged.
- Outline: 2 px (busts 1) plus 1 px on the lower right. It is selective by light: `#74462a` lit, `#4a2c1a` middle, `#2a1a10` shaded. Never `#000000` inside the art; black appears only as the 1 px outer border.
- One crescent per part at the lower right: shade, then deep at the edge, plus a 1 px bounce on the lower-right edge and a 1 px rim on the upper-left.
- An enamel gloss comma and dot on the lit upper-left. It is the brightest thing on the object.
- Inner contour: 1 px umber where a big shape overlaps another. Contact shadow: 1 px of the lower part's shade under the overlapping part. No other shade shapes.

## Palette (hex)
| use | colours |
|---|---|
| border / outline | `#000000` 1 px outside only / `#74462a` `#4a2c1a` `#2a1a10` |
| red (gloss, dot, rim, base, bounce, shade, deep) | `#ff9158` `#ffc27a` `#f2793a` `#dd3a2a` `#b8452f` `#ae2a2a` `#6b1b2c` |
| dusk dark heads (rim, base, shade, gloss) | `#7b66b4` `#3e2f66` `#291d4a` `#a894dc` |
| moss (gloss, rim, base, bounce, shade, deep) | `#c8d77a` `#a4b86a` `#7ab55c` `#6a9a3a` `#4a8a3e` `#2f5a2a` |
| wood (gloss, rim, base, bounce, shade, deep) | `#ecc58a` `#d9a660` `#b07a45` `#a8582f` `#8a4f2a` `#5e2f1e` |
| water (gloss, rim, base, bounce, shade, deep) | `#c8ecdc` `#8fcbd8` `#3f8fb0` `#5a86b8` `#2f6290` `#2a3c6c` |
| gold (gloss, rim, base, bounce, shade, deep) | `#fff1c8` `#f5cf6a` `#e8a317` `#d0862a` `#b8661a` `#7a3a14` |
| skin (gloss, rim, base, bounce, shade, deep) | `#ffe2a8` `#f9d49c` `#e9b98a` `#d9885a` `#c47a52` `#8a4234` |
| legs / spots | `#54447f` with a lit top `#7b66b4` / `#35161f` with glint `#5e2a3a` |
| thread gold | `#f5cf6a`, shade `#e8a317`, button holes `#8a4a1c` |
| Part A bases | soil `#3d2a1c` `#7a4a1f` `#9a6b3f` `#c9a96e` `#f1ece0`; petal `#e46a9b` `#f6b8cf`; stone `#5b6470` `#8b8f96` `#c9c5bc`; ember `#d6322b` `#e0501f` `#f08a24` |
- Any other colour: take the Part A base and run `GV.ramp("#base")`. That gives gloss toward yellow-orange +35%, shade toward red-violet -22%, deep -45%, bounce = shade warmed +8%, rim = gloss -10%. Say which family you borrowed.
- Pale subjects (cream, paper, bone, dust, hair): gloss `#fff3c8`, dot `#ffffff` (the only white allowed), rim `#f5b860`, and an umber outline on every side.

## Stitched-toy signature (where there is a real join)
- Seam: thread gold 2 on / 1 off. Put it on lid joins, hems, a seam down a back, halves of a body, a collar, a brim, a strap or a plinth lip.
- Button: 4x4 cut-corner gold with two diagonal holes, at the head of a seam (collar, lid, shoulder pin, tent door).
- Edge stitch: a 1 px ring 2 px inside a fabric body edge. Skip it over the gloss. Use it on felt bodies, cuffs and cushions, not on glass, metal or wood.
- Banners and landing art may have a hem stitch along the top and bottom edges.

## Faces and shapes
- Eyes are locked: a 5x5 cream disc with cut corners, a 3x3 `#2a1a10` pupil and a 1 px cream glint at its upper-left. Set them wide. On heads under 20 px wide, use a 3x3 disc with a 2x2 pupil.
- Chibi build: a big head (about 5/6 of the body width) and a squat body. Limbs are 2 px lavender and bent. Antenna tips end in a 4x4 club.
- Markings are diamonds or beans, evenly varied.

## Do not
- No blush or cheek patches, dither bands, zipper or double-wide stitching, blobby random markings, or shading under 2 px limbs.
- No second light direction, extra shade blobs, pure black or white, semi-transparent pixels, or a cream halo.
- `broken-*`: the same drawing plus damage (crack, snapped or chipped part, a loose piece), with the same colours. Keep the original file names.

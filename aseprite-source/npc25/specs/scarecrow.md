# NPC 2.5D spec: scarecrow

Sir Barnaby, a walking scarecrow, proud of his hat. No folk sprite; designed for the npc25 family (straw-hat mouse, mole, hedgehog).
Output: `aseprite-source/npc25/scarecrow/scarecrow-{front,back,side}.png`, copied to `game/assets/img/npc25/`.
Body plan: **biped**, stiff-armed. Drawn in `lib/species_scarecrow.lua` (`S.draw_figure`).

## 1. Canvas
- Views `front`, `back`, `side` (side faces right). 512x80 RGBA, 8 frames of 64x80. Frames 1-2 idle, 3-8 walk.
- Hard pixels, transparent background, ground shadow only.

## 2. Ground line and size
- Feet line y 71 in all frames (boot soles row 70 + outline; the shadow holds row 71).
- Ground shadow: ellipse rows 65-71, x 18-45, `#74758c` rim, `#aaa9b8` centre, ink contour where boots stand in it.
- Head top (hat crown, outline row): y 6 on frame 1, y 5 on frame 2; never above y 5.
- Max width 40 px on idle frame 1 (crow beak and straw cuffs included).

## 3. Palette (look 1)
- Outline `#2b1c26`.
- Burlap (sack head, trousers): `#ecd3a0` hi, `#d6b47c` base, `#a9845a` shade, `#7a5a44` deep.
- Coat (faded teal): `#6a9aa0`, `#4f7a86`, `#3a5668`, `#2e3e50`.
- Felt hat and boots: `#8a6a58`, `#6e4e44`, `#523840`, `#3d2a34` (also face stitches).
- Straw: `#f6dc7a`, `#e0b046`, `#b07c34`. Rust patch / hat band / neck twine: `#c2573c`, `#8a3a46`.
- Crow (quirk): `#6a6080` hi, `#4a4058` base, `#342c40` shade; beak straw; eye glint cream `#fff4d6`.
- Cheek `#e8a098`. Shadow `#aaa9b8`, `#74758c`.

## 4. Per-view features
- front: sack head with button eye (left), cross-stitch eye (right), stitched upturned smile, pink cheeks; straw V at the collar; rope belt with knot; rust patch on the chest, mustard patch on the hem; mismatched buttons; stiff arms out and down with straw bursting from the cuffs; patched trousers, straw at the ankles, felt boots.
- back: sack with a stitched seam and twine knot at the nape; hat back with a teal patch; big rust patch between the shoulders, mustard patch low left; rope belt.
- side (right): profile sack with nose knob, one button eye, smile; hat brim profile; coat with front closure; near arm a stiff rod, far arm darker behind; legs swing as stiff rods under the coat.
- Hat (all views): wide battered brim drooping on one side, dented crown leaning, rust band, a patch.
- Quirk (all views): small crow perched on Sir Barnaby's right shoulder (viewer-left in front, viewer-right in back, toward the back of the near shoulder in side), facing outward; bobs its head on walk frames 4 and 7, tail tips up on frames 2, 5, 8. Quirk colour `#4a4058`.

## 5. Animation tables
Same biped tables as field-mouse. Arms and legs are rigid rods pivoting at shoulder and hip (side view: arm swing = arm offset x 2.5 px, leg swing = x 2 px).

| frame | body y | head y | feet L/R | arms L/R |
|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 |
| 3 | 0 | 0 | 0 / -2 | +2 / -2 |
| 4 | -1 | -1 | 0 / -1 | +1 / -1 |
| 5 | -1 | -1 | -1 / 0 | 0 / 0 |
| 6 | 0 | 0 | -2 / 0 | -2 / +2 |
| 7 | -1 | -1 | -1 / 0 | -1 / +1 |
| 8 | -1 | -1 | 0 / -1 | 0 / 0 |

## 6. Checklist
- [ ] 3 files, 512x80, alpha 0/255, no pure black/white, outline on every edge, palette_list only
- [ ] feet line 71; head top 6/5; idle-1 width <= 40
- [ ] frames 1/2 differ, walk frames pairwise differ, views differ
- [ ] crow visible in every frame of every view

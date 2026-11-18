# NPC 2.5D spec: squirrel

Stage 1 + 3 (Opus). Source look: `game/assets/img/ico/ico-squirrel.png` (no folk sprite exists; fur colours sampled from the icon). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/squirrel/squirrel-{front,back,side}.png`. Copied to `game/assets/img/npc25/`.
Body plan: **biped (mammal)**, same frame as the dormouse and field-mouse. Game species name: Squirrel (file key `squirrel`).

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip.
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80. Frames 1-2 idle, 3-8 walk.
- Transparent background, no ground shadow (bipeds carry none), hard pixels only.

## 2. Ground line and size
- Feet line: lowest opaque row = **y 71** in all 8 frames.
- Head top (ear-tuft tips, outline row included): y 8 on frame 1, y 7 on frame 2; never above y 7.
- Max width: 42 px on idle frame 1 in every view, tail included.

## 3. Palette (look 1)
- Outline: `#2b1c26`, 1 px, outside only.
- Fur ramp (red squirrel): hi `#ec8a44`, base `#d26a36`, shade `#a8452e`, deep `#6e2a2c` (ear tufts, toe lines, nose).
- Cream (muzzle, chest, belly): `#f3e2bf`, shade `#d9b98c`.
- Waistcoat (moss): base `#6a9a48`, shade `#46704a`, deep `#2f4a42`.
- Hazelnut sack (quirk): hi `#e6cc90`, base `#c9a86a`, shade `#a07a48` (also the strap); hazelnut `#8f5f3a`.
- Cheeks `#f5809f`. Eyes: 2x3 ink pill with a cream glint.

### Looks (tint swaps)
- Look 1 (as drawn) above. Look 2: grey squirrel, fur base `#8a8aa0`, waistcoat `#5d74a8`. Look 3: dark morph, fur base `#6a3f2e`, waistcoat `#d0503e`. Ramps by the art guide section 4 recipe.

## 4. Per-view features
- front: tall pointed ears with dark tufts; two eyes, cream muzzle, dark nose, pink cheeks; cream chest and belly between the two open waistcoat panels; strap from the viewer's-left shoulder to the sack on the viewer's-right hip; tail rising behind the body on the viewer's left, tip curling out.
- back: ears with tufts, back of head; full waistcoat back; strap across the back to the sack on the viewer's-left hip; the big tail in front of the back, rising from the rump on the viewer's right to above the shoulder, tip curling out.
- side (right-facing): snout with cream lower jaw and dark nose, one eye, one tufted ear; waistcoat with cream belly in front; near arm, far arm in shade; near leg, far leg in shade; tail behind in a tall S-curl from the rump up to the back of the head; sack hanging on the near hip behind, strap over the shoulder.
- Quirk (all views): a burlap hazelnut sack (about 7x8 px) with one hazelnut peeking out of the tied neck. Follows body y and sways on x with the arm on its side.

## 5. Animation tables
`{body, head, footL, footR, armL, armR}`, the six-frame biped cycle shared with hedgehog and dormouse.

| frame | body y | head y | feet L/R | arms L/R | note |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | idle, tuft top y 9 (outline 8) |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe |
| 3 | 0 | 0 | 0 / -2 | 2 / -2 | L contact |
| 4 | -1 | -1 | 0 / -1 | 1 / -1 | L loaded |
| 5 | -1 | -1 | -1 / 0 | 0 / 0 | L swings |
| 6 | 0 | 0 | -2 / 0 | -2 / 2 | R contact |
| 7 | -1 | -1 | -1 / 0 | -1 / 1 | R loaded |
| 8 | -1 | -1 | 0 / -1 | 0 / 0 | R swings |

- Tail follows body y and its tip sways 1 px with the arm swing; sack follows body y.
- Side view: feet also slide on x (stride), as the dormouse.

## 6. Checklist
`python3 check.py squirrel` = RESULT PASS (size, alpha, no black/white, outline on every edge, feet row 71, head tops 8/7, width <= 42, palette only, frames differ).

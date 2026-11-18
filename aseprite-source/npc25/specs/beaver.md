# NPC 2.5D spec: beaver

Stage 1+3 (Opus). No folk sprite exists; colours follow the beaver foreman art (`game/assets/img/mini/mini-beaver-foreman.png`). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/beaver/beaver-{front,back,side}.png`. Copied to `game/assets/img/npc25/`.
Body plan: **biped (mammal)**, stocky. Art: `lib/species_beaver.lua` `S.draw_figure`.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip.
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80. Frames 1-2 idle, 3-8 walk.
- Background transparent. No ground shadow (same as the other mammals). Hard pixels only.

## 2. Ground line and size
- Feet line: lowest opaque row = **y 71** in all 8 frames (outline row under the soles; the flat tail also rests on the ground).
- Head top: y 9 (frame 1, beanie top outline), y 8 on frame 2. Nothing above y 8.
- Max width: 42 px on idle frame 1 in every view, tail, axe and sticks included.

## 3. Palette (look 1)
- Outline: `#2b1c26`, 1 px, outside silhouette only.
- Fur ramp: hi `#c98d58`, base `#b97a4a`, shade `#864c33`, deep `#51302b`.
- Muzzle / cut wood: `#e8b982`. Teeth and glints: cream `#fff4d6`. Nose and tail hatch: `#3d2532`. Cheek: `#f5809f`.
- Tail: base `#51302b` (fur deep), crosshatch `#3d2532`, rim `#864c33`.
- Knit beanie: hi `#e8705a`, base `#d0503e`, shade `#9a3a36`.
- Work apron (garment): hi `#7fa2d0`, base `#6188bc`, shade `#465c92`, deep `#323c66`.
- Sticks: hi `#d8b47a`, base `#b08a58`, shade `#7a5a3c`. Twine `#e8c262`.
- Axe head: steel hi `#d6d4de`, base `#aaa9b8`, shade `#74758c`.

## 4. Per-view features
- front: round head, two ink eyes, dark nose, two buck teeth below the mouth, pink cheeks, round ears beside the beanie; apron bib with straps and a pocket; stubby arms; big dark hind feet; tail tip between the feet; axe upright in the viewer-right hand; stick bundle slung across the back, ends poking out over the viewer-left shoulder and at the right hip.
- back: beanie back with ribbed band, ears; apron straps crossed and waist tie; stick bundle across the back (full, twine bands); flat paddle tail hanging to the ground between the feet, crosshatched; axe in the viewer-left hand.
- side (right-facing): blunt snout with nose, one eye, one ear, teeth under the snout; beanie profile; apron front; flat paddle tail lying on the ground behind; stick bundle on the back (edge-on, tied by a twine strap across the chest); near arm holds the axe, far arm and far leg in shade.
- Quirk (all views): a small woodcutter's axe (steel head) plus a twine-tied bundle of sticks. `S.quirk.hex` = stick base `#b08a58`.

## 5. Animation tables
Same six-frame biped cycle as the hedgehog. Rows `{body, head, footL, footR, armL, armR}`.

| frame | body y | head y | feet L/R | arms L/R |
|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 |
| 3 | 0 | 0 | 0 / -2 | 2 / -2 |
| 4 | -1 | -1 | 0 / -1 | 1 / -1 |
| 5 | -1 | -1 | -1 / 0 | 0 / 0 |
| 6 | 0 | 0 | -2 / 0 | -2 / 2 |
| 7 | -1 | -1 | -1 / 0 | -1 / 1 |
| 8 | -1 | -1 | 0 / -1 | 0 / 0 |

- Sticks, apron and axe follow body y; the axe follows its hand. The tail stays on the ground (side) or follows body y (back).
- Every walk frame differs from every other walk frame and from both idle frames.

## 6. Checklist
- three files, 512x80, alpha 0/255 only, no pure black/white, outline on every edge
- lowest opaque row 71; head top 9 / 8; idle-1 width <= 42
- frames 1/2 differ; 3-8 pairwise differ; only palette colours from section 3
- teeth, tail and axe + sticks readable at 1x

# NPC 2.5D spec: crab

Stage 1+3 (Opus). No folk sprite exists for the crab; look taken from `game/assets/img/mini/mini-shore-crab.png` (red shell, orange claws, stalk eyes). Shared ground with the gnome: `game/assets/img/gnome25/`.
Output: `aseprite-source/npc25/crab/crab-{front,back,side}.png`. Copy to `game/assets/img/npc25/`.
Body plan: **crab** (own `draw_figure`, no draft helper). Eight walking legs, two raised claws.

## 1. Canvas
- Views: `front`, `back`, `side`. Side faces right; left-facing is a flip.
- Each file: 512x80 PNG, RGBA, 8 frames of 64x80. Frames 1-2 idle, 3-8 walk.
- Background transparent. Hard pixels only.

## 2. Ground line and size
- Feet line: lowest opaque row = **y 71** in all 8 frames (ground shadow outline, as frog / snail).
- Ground shadow: ellipse rows ~64-70 + outline row 71, x ~15-48, `#aaa9b8` light and `#74758c` shade.
- Head top (check.py SPEC): **y 14** on idle frame 1, y 13 on frame 2, never above y 13. The flag pole knob is the highest point.
- Max width: **46 px** on idle frame 1 (claws and leg tips included).
- Broad and low: carapace y ~39-59, claws raised to y ~15-33, eyes on stalks at y ~29-35.

## 3. Palette (look 1)
- Outline `#2b1c26`.
- Shell ramp (carapace, legs, stalks): hi `#ff8a5c`, base `#e8493b`, shade `#b52e3f`, deep `#6e2038`.
- Claw ramp: hi `#ff8a5c`, base `#d98322`, shade `#8f4a1f`, deep `#6e2038` (finger tips deep).
- Eyes cream `#fff4d6`, ink pupil. Cheeks `#f5809f`. Mouth `#6e2038`.
- Sailor cap: hi `#6188bc`, base `#2f6a92`, shade `#3a3e6e`, band `#fff4d6`.
- Flag (quirk): cloth `#f5b82e`, shade `#d98322`, pole `#8f4a1f`, knob `#ffe38a`.
- Shadow `#aaa9b8`, `#74758c`.

## 4. Per-view features
- front: wide oval carapace with 3 front-edge teeth per side, smile and cheeks on the front rim, two stalk eyes looking at the viewer, navy sailor cap perched on the shell between the stalks, three spiky legs per side splayed to the ground, both claws raised with open pincers; flag in the viewer-right claw, pennant pointing inward.
- back: carapace back with hi speckle and two shade grooves, stalk eyes from behind (no pupils), cap from behind with two ribbon tails, legs and claws mirrored, flag in the viewer-left claw.
- side (moving right): the crab walks sideways, so the side view stays broad: face turned a little right (mouth and cheek shifted right, pupils look right, stalks lean right), leading (right) legs reach out, trailing (left) legs push in, pennant streams back to the left.
- Garment: navy sailor cap with cream band. Quirk (all views): a little yellow pennant on a pole held in one claw. It bobs with the claw and its tail flaps per frame.

## 5. Animation tables
`{body y, head y, footL, footR, armL, armR}` (`N.offsets`). Head y moves the stalks, cap, claws and flag. Arms: claw clack (+ = pincer open, - = claw dips 1 px). Legs alternate: left legs 1 and 3 lift with footL, left leg 2 with footR; right side opposite.

### Idle
| frame | body | head | feet L/R | arms L/R | notes |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | base, top y 14 |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe, top y 13 |

### Walk (scuttle)
| frame | body | head | feet L/R | arms L/R |
|---|---|---|---|---|
| 3 | 0 | 0 | 0 / -2 | 2 / -2 |
| 4 | -1 | -1 | 0 / -1 | 1 / -1 |
| 5 | -1 | -1 | -1 / 0 | 0 / 0 |
| 6 | 0 | 0 | -2 / 0 | -2 / 2 |
| 7 | -1 | -1 | -1 / 0 | -1 / 1 |
| 8 | -1 | -1 | 0 / -1 | 0 / 0 |

Pennant tail flaps on a 3-frame cycle; every walk frame differs.

## 6. Checklist
512x80 x3, alpha 0/255, no pure black/white, outline on every edge, lowest row 71, tops 14/13 (none above 13), idle-1 width <= 46, frames differ, only palette colours, flag visible in every frame of every view.

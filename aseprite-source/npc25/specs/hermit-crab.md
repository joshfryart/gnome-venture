# NPC 2.5D spec: hermit-crab

Game name: Hermit Crab. No folk source sprite; designed fresh to match the npc25 family.
Output: `aseprite-source/npc25/hermit-crab/hermit-crab-{front,back,side}.png`, copied to `game/assets/img/npc25/`.
Body plan: **crawler** (like the snail). Art: `S.draw_figure` in `lib/species_hermit-crab.lua`.

## 1. Canvas
- Views `front`, `back`, `side` (side faces right). 512x80 PNG, 8 frames of 64x80; frames 1-2 idle, 3-8 walk.
- Transparent background, hard pixels, 1 px outline `#2b1c26`, no pure black/white, light from upper left.

## 2. Ground line and size
- Feet line: lowest opaque row y 71 in all frames (ground shadow rows 65-70 + outline, `#aaa9b8` / `#74758c`).
- Head top (the hat on the shell tip): y 10 on frame 1, y 9 on frame 2, never above y 9.
- Max width: 42 px on idle frame 1 (claws and shadow included).

## 3. Palette (look 1)
- Outline `#2b1c26`.
- Crab ramp: hi `#f2906a`, base `#d85a40`, shade `#a63c3c`, deep `#6e2a3a`.
- Shell ramp (sandy whelk): hi `#f2dcb0`, base `#d8b07a`, shade `#a87c56`, deep `#6e4c4a` (sutures, aperture).
- Hat (quirk): hi `#7ea6d4`, base `#4a6ea8`, shade `#2f4778`, band `#f5b83a`.
- Kerchief: `#5ca24c`, shade `#3f7a44`. Glint cream `#f6ead0`. Shadow `#aaa9b8`, `#74758c`.

## 4. Per-view features
- front: tall conical whelk shell behind (5 slanted whorls, dark sutures); the crab sits in the dark shell aperture with a cream lip; red carapace with a smile; two red eyestalks with ink eyeballs (cream glint) in front of the shell; big claw on the viewer's left, small claw on the right; green kerchief knotted at the chest; two jointed walking legs a side, knees high, tips splayed.
- back: the whole shell, crab rump under it with the kerchief knot, claws on arms at both sides, legs as front. Eyes hidden by the shell.
- side (right-facing): shell tip up and back, aperture lower right, crab head and body coming out of it, near and far eyestalks, big claw held forward, kerchief at the neck, three near legs (lit) and two far legs (shaded).
- Quirk (all views, every frame): a tiny blue cap with a gold band on the shell tip (`S.quirk.hex` `#4a6ea8`). It follows body y and sways 1 px on x with the walk (frames 4-5 right, 7-8 left), as do the eyestalks.
- Garment: green kerchief.

## 5. Animation tables
`{body, head, footL, footR, armL, armR}`; arms = claw lift (- = up).

| frame | body y | head y | feet L/R | claws L/R | note |
|---|---|---|---|---|---|
| 1 | 0 | 0 | 0 / 0 | 0 / 0 | idle |
| 2 | -1 | -1 | 0 / 0 | 0 / 0 | breathe |
| 3 | 0 | 0 | 0 / -2 | +1 / -1 | R legs lift |
| 4 | -1 | -1 | 0 / -1 | 0 / 0 | |
| 5 | -1 | -1 | -1 / 0 | -1 / +1 | |
| 6 | 0 | 0 | -2 / 0 | -1 / +1 | L legs lift |
| 7 | -1 | -1 | -1 / 0 | 0 / 0 | |
| 8 | -1 | -1 | 0 / -1 | +1 / -1 | |

Legs alternate in crab pairs (inner L with outer R). Walk frames differ pairwise (checked).

## 6. Result
- `bash npc25/run.sh hermit-crab`: RESULT PASS. Note: `check.py` has no `QUIRK` entry for hermit-crab, so the quirk-colour check is not run; the hat is drawn in every frame anyway.
- Weak spots: shell spiral bands are faint at 1x; side legs are thin; face is small under the tall shell.

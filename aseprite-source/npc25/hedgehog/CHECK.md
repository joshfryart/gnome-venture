# Stage 4 check: hedgehog

Result: PASS (all checklist items)

## check.py output (summary, 50 lines, all PASS)
RESULT PASS, exit 0. Covers size 512x80, alpha 0/255, no #000000/#ffffff,
outline #2b1c26, feet row 71 in all 8 frames, head tops 9/8, idle1 width 40 (side 39),
idle 1 vs 2 differ, walk 3-8 pairwise differ, front/back/side differ.

## Checklist (spec section 6)
- [PASS] three files present: hedgehog-front/back/side.png
- [PASS] 512x80 RGBA, 8 frames of 64x80
- [PASS] alpha only 0 or 255
- [PASS] no #000000, no #ffffff
- [PASS] outline #2b1c26 present (script); edges checked on sheet.png
- [PASS] feet line: lowest opaque row 71 in all frames
- [PASS] head top: f1 y9, f2 y8, none above y8
- [PASS] idle f1 width <= 40 (front/back 40, side 39)
- [PASS] each view non-empty in every frame
- [PASS] frames 1,2 differ; frames 3-8 differ pairwise
- [PASS] lantern visible in every view (sheet.png)
- [PASS] palette: 19 colours, all in spec section 3 (look 1)

## Visual concerns
- Walk in front and back views is subtle: feet move 1-2 px, close to idle at 1x.
- Belt lantern is 3x4 px and hard to read at game scale.

Sheet: aseprite-source/npc25/hedgehog/sheet.png

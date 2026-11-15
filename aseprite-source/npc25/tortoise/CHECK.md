# Stage 4 check: tortoise

Result: PASS (all checklist items)

## check.py output (summary, 50 lines, all PASS)
RESULT PASS, exit 0. Covers size 512x80, alpha 0/255, no #000000/#ffffff,
outline #2b1c26, feet row 71 in all 8 frames, head tops 10/9, idle1 width 44,
idle 1 vs 2 differ, walk 3-8 pairwise differ, front/back/side differ.

## Checklist (spec section 6)
- [PASS] three files present: tortoise-front/back/side.png
- [PASS] 512x80 RGBA, 8 frames of 64x80
- [PASS] alpha only 0 or 255
- [PASS] no #000000, no #ffffff
- [PASS] outline #2b1c26 present (script); edges checked on sheet.png
- [PASS] feet line: lowest opaque row 71 in all frames
- [PASS] head top: f1 y10, f2 y9, none above y9 (sprout is visible above)
- [PASS] idle f1 width 44 or less
- [PASS] each view non-empty in every frame
- [PASS] frames 1,2 differ; frames 3-8 differ pairwise
- [PASS] flowerpot visible in every view (sheet.png)
- [PASS] palette: 18 colours, all in spec section 3 (look 1)

## Visual concerns
- Side view: overalls and near leg sit apart from the shell with a visible gap, so the figure can read as two pieces.
- Walk swing is small in front and back views; the tortoise walk is close to idle at 1x.

Sheet: aseprite-source/npc25/tortoise/sheet.png

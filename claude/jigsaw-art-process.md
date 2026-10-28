# Jigsaw picture art: the 3-pass method (Joshua likes this; 2026-10-28)
Used for the gallery pictures (the Places pictures are existing scenes cut by `tools/gen_place_crops.py`, no passes needed). Proven on Maplewold: v0 -> v1 -> v2, duplicate-cell pairs 22 -> 4 -> 2.

## Spec (every gallery picture)
- 300 x 200 hard-pixel grid, exported 6x nearest = **1800 x 1200 (3:2)** JPEG q90 + 450 x 300 thumb, by `save_pic()` in `aseprite-source/scenes-pil/jigsaw_common.py`. Written to `game/assets/img/jigsaw/<slug>.jpg` and `<slug>-thumb.jpg`. Built-in list: `JIGSAWS` in `game/includes/jigsaw.php` (add a row; it seeds itself).
- House style: hard pixels only (no blends, dither or gradients), three-tone umber outline on raised objects, light from the upper left, warm "Stitched Toy" look (`claude/art-style-guide.md` Part D, `pixlib.py` header). Under ~100 colours.
- Jigsaw rules: detail over the **whole** frame (no calm corners, no big flat sky or lawn); every cell of the 12 x 8 grid should hold something distinct (a piece of sky needs a cloud, bird, kite or balloon); no text, no logo, no frame; no near-symmetric centre; a clear focal path for the eye; readable at 450 x 300.
- One script per picture: `aseprite-source/scenes-pil/jigsaw_<slug>.py` (re-runnable, deterministic: seeded generators; use a second generator for new details so earlier layout does not shift).

## The 3 passes (run one after the other, never in parallel)
| Pass | Who | What | Output |
|---|---|---|---|
| 0 Draft | Sonnet or Opus (main session) | Brief (below) -> `jigsaw_<slug>.py` renders a full composition: sky/far layer, mid layer, focal subject, foreground, characters, litter | `scratch/iter0/` |
| 1 Art-director pass | Opus, **medium** effort, one agent | Read the full-size render; critique honestly (composition, depth, flat/empty zones, floating objects, colour variety, outline consistency, thumbnail readability); fix the 6-8 biggest problems in the script; up to 3 render loops | `scratch/iter1/` + script copy |
| 2 Polish pass | Opus, **medium** effort, a NEW agent given pass 1's "still weak" notes but told to critique independently | Fix those plus anything new; check the four corners and the centre band; keep it coherent, not noisy | `scratch/iter2/` + script copy |
After pass 2: run `python3 tools/jigsaw_cell_check.py <render>.jpg` (FLAT cells, DUP pairs at Advanced 12 x 8; must pass) and look at the 450 x 300 thumb. If it fails or Joshua wants more, a pass 3 uses the same prompt on the iter2 output. Joshua reviews v0 / v1 / v2 side by side (`SendUserFile`), then picks; the chosen script is committed and its render copied into `game/assets/img/jigsaw/`.
Rules for the agents: only edit the picture script (and `jigsaw_common.py` for truly shared helpers); never touch `game/`, never commit; reply with what was wrong / changed / remains (max ~12 lines).

## Brief template (pass 0)
`Picture: <title> (<category>). Setting: <one sentence>. Focal subject: <...>. 6-8 required props: <...>. Characters: <gnome / creature doing something>. Palette: <4 colours>. Time of day / weather: <...>. Must include in the 12 x 8 grid: sky object(s), a path/line leading in, ground detail in all bottom cells.`
Regions list for the launch set (14): Maplewold (done to v2), Maizehollow, Dunewhisper, Blossomreach, Sunsprinkle Isles, Rainroot Reaches, Mistmoor, Olivewhistle Shore, Birchbramble Steppe, Greatcanopy, Thornacre Savanna, Spicepeak, Monsoon Tangle, Coralscatter. Take props and palette from the region's own text/landmarks so the picture matches the game.

## Cost note
A pass is one agent, about 100k tokens. 14 pictures x 2 agent passes = 28 agent runs; run them one picture at a time, passes in order, several pictures can run side by side with each other (not passes of the same picture).

## Pals link
Pal art briefs (`claude/plan-puzzle-pals.md` section 6) read each picture's four dominant colours and motifs from the finished render, so pals are made AFTER a picture's pass 2 is approved.

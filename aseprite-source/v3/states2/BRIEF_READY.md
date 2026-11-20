# Ready (!) animation for every LEVEL of a garden building

CONTEXT: In a cosy gnome garden game, each building has art for level 1, 2 and 3 and a 4-frame looping READY animation (something is waiting for the player: a gold "!" badge in the top-right corner plus 2 or 3 life motions). Today the ready animation only exists on top of the LEVEL 1 art. Your job: make the ready animation for LEVEL 2 and LEVEL 3 too, matching each level's art, in the same style as the existing level 1 ready animation.

READ FIRST
- Shared brief /tmp/ase/states2/BRIEF.md (canvas sizes, anchor (W/2, H-10), style rules, the ready-state description and each building's ready motion in its table row).
- For each assigned building <b>: the repo script /home/user/gnome-venture/aseprite-source/v3/states2/<b>.lua (READ-ONLY source: it draws empty, l1, l2, l3 and the l1 ready animation; find how level art and the ready motion are drawn) and the existing outputs /home/user/gnome-venture/aseprite-source/v3/states2/<b>/<b>-sheet.png and <b>-ready.png (view with the Read tool).
- Art guide /home/user/gnome-venture/aseprite-source/v3/art-style-guide-v3.md (hard pixels only: no dither, gradients, semi-transparency; 1 px ink outline #2b1c26; light from upper left; no pure black or white) and lib docs /home/user/gnome-venture/aseprite-source/v3/lib/README.md.

WHAT TO MAKE (per building)
- <b>-ready-l2.png and <b>-ready-l3.png: horizontal strips of 4 frames (4W x H) at scale 1, same canvas, same anchor, same cast shadow as the level art. The base is that level's art exactly (it must match <b>-l2.png / <b>-l3.png pixel for pixel in frame-independent areas). Add the same kind of ready motions as level 1 (the table row), repositioned to the level's own art (for example steam from the new pots, sparkle on the new tray, bees around the taller hive, the new extension wobbling), 2 or 3 clearly visible motions per frame loop, each visible at 100% zoom.
- The gold "!" badge (round gold circle, ink outline, about 9 px across, cream "!") in the TOP-RIGHT corner of the canvas, bobbing 0,-1,0,+1 px over the 4 frames, identical to level 1's badge. If level 3 is wider and reaches the corner, keep the badge fully inside the canvas and not covering the building.
- <b>-ready-l1.png: copy of the existing <b>-ready.png (do not redraw level 1) so there are three consistent files.
- <b>-ready-sheet.png: contact sheet at scale 2 on a light-green background: three rows (l1, l2, l3), 4 frames each (build with Python PIL, Image.NEAREST).

HOW: write your script to /tmp/ase/states2/<b>_ready.lua (new file; copy what you need from the repo script; do NOT edit any other script) and run
`/tmp/ase/squashfs-root/AppRun -b --script-param out=/tmp/ase/states2/<b>/ --script /tmp/ase/states2/<b>_ready.lua`
It must NOT overwrite <b>-empty.png, -l1/-l2/-l3.png or -ready.png (other agents are improving the empty state in the same folder). Check: view the contact sheet with the Read tool, confirm motions and badge read at 1x, the base art matches the level art, alpha only 0 or 255, nothing clipped. Loop up to 4 rounds per building. Do NOT touch any file under /home/user/gnome-venture. The fence has no levels: skip it. Finish with ONE short line per building: done or what is weak.

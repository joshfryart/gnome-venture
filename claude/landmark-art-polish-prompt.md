You are doing a LOW-effort polish pass on finished unique-location scene art for Gnome Venture (Stitched Toy pixel style, Aseprite + Lua). Repo /home/user/gnome-venture (branch checked out; DO NOT git commit/push; the lead commits). Release 2.0.86 ships these, so only fix real problems; do not redesign.

Your scenes are listed below (slugs). For each: PNG `game/assets/img/wonders/<slug>.png` (480x270), script `aseprite-source/final/scripts/wonders/<slug>.lua` (uses lmlib.lua in the same folder, some also h3lib/w5lib), brief in `claude/landmark-art-briefs.md` (search the slug).

DO PER SCENE:
1. Read the PNG (Read tool shows images). Also make a half-size nearest-neighbour copy with PIL (240x135, then view it): mobile shows it small. Judge: is the focal subject clear, does it match the brief text and its thing-to-do, are characters/faces readable, anything blobby, faint, tiny, hidden, ugly or culturally off?
2. If it is already good, leave it alone (say OK). If something is clearly weak, make the SMALLEST script edit that fixes it (bigger/clearer subject, stronger contrast on a faint key element, clearer eyes, remove a mess, fix a wrong detail), re-run, view again. Max 2 edit rounds per scene.
Known notes from the first pass (fix only if you agree): spider web faint/gold (lair-hollow-of-the-silverback-spider); drums small (haven-drum-circle-market); dolphin eyes small (wonder-pink-river-dolphin-pools); stone frog faint, door small (wonder-the-stepped-seed-temple); tea cup and picker faces (wonder-tea-garden-slopes); hedgehog reads brown blob (haven-thatchtop-tearoom); salamander an orange blob (lair-smokecap-caldera); pack wolves read as rocks (lair-of-the-grey-wolf-king); snow-crown edge faint (lair-snowcrown-peak); small hoard (wonder-the-mirror-salt-flat); squirrel unclear (wonder-the-amber-woods); diver blobby (wonder-pearl-diver-cove); grey stork body (wonder-stork-chimney-village).
Regions: CSA = Central & South Asia; WCA = West & Central Africa; ESA = East & Southern Africa; SA = South America; the rest are as their names read.

RULES (L.finish asserts them): hard pixels only, palette colours or GV.ramp, no semi-transparent pixels, no pure black/white, no black border in scenes, hem stitch stays (L.finish adds it), no text in the picture. Rules detail: claude/art-style-guide.md Part D/E, aseprite-source/gvlib/README.md.

RUNNING ASEPRITE (shared AppImage extraction collides between agents, so use a private copy):
  mkdir -p <SCR>/<you> && cd <SCR>/<you> && cp <SCR>/ase.AppImage . && ./ase.AppImage --appimage-extract >/dev/null   (once)
  then: ./squashfs-root/AppRun -b --script-param out=<SCR>/<you>/<slug>.png --script-param ase=<SCR>/<you>/<slug>.aseprite --script /home/user/gnome-venture/aseprite-source/final/scripts/wonders/<slug>.lua
  SCR=/tmp/claude-0/-home-user-gnome-venture/0d6b526d-69cf-58c2-85bd-728cb7cc3450/scratchpad
Iterate with out/ase params pointing at your private dir; when a scene is final, run it once WITHOUT out/ase params so it overwrites the repo PNG and .aseprite. Never edit a PNG by hand. Only touch your own scenes' files.

REPORT: one short list `slug -> OK (unchanged)` or `slug -> fixed: <what>` or the problem. No code.

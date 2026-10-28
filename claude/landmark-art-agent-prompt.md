You are drawing unique-location scene art for Gnome Venture in the "Stitched Toy" pixel style, with Aseprite driven by Lua. Repo: /home/user/gnome-venture (branch already checked out; DO NOT run git commit/push or touch other agents' files; the lead commits).

YOUR JOB: draw the scenes in your range of `claude/landmark-art-briefs.md` (the list in the order of its `## ` headings; your range is given below, counted from 0). One bespoke Lua script per scene.

READ FIRST (short): 
- aseprite-source/final/scripts/wonders/wonder-lighthouse-of-the-lost-lantern.lua : the approved reference (composition, parts, hem, crab). Look at its PNG: game/assets/img/wonders/wonder-lighthouse-of-the-lost-lantern.png
- aseprite-source/final/scripts/wonders/lmlib.lua : shared helpers (sky ramps, stars, clouds, water, ground mask, hem, finish).
- aseprite-source/gvlib/README.md and brief.md : gvlib API and palette rules. Style rules: claude/art-style-guide.md Part D and Part E (scene section).

OUTPUT per scene: script `aseprite-source/final/scripts/wonders/<slug>.lua`, and (written by L.finish) `game/assets/img/wonders/<slug>.png` + `aseprite-source/final/aseprite/wonders/<slug>.aseprite`. Slug is the heading's slug exactly. 480x270 (240x135 grid at 2x) via `L.new()`.

RUN (Aseprite works headless; AppImage already prepared):
  cd /tmp/claude-0/-home-user-gnome-venture/0d6b526d-69cf-58c2-85bd-728cb7cc3450/scratchpad && ./ase.AppImage --appimage-extract-and-run -b --script-param out=<YOURDIR>/<slug>.png --script-param ase=<YOURDIR>/<slug>.aseprite --script /home/user/gnome-venture/aseprite-source/final/scripts/wonders/<slug>.lua
Use a private preview dir <YOURDIR> = that scratchpad path + /<yourname>/ (mkdir it) while iterating. When happy, run once WITHOUT out/ase params so files land in the repo. Run scripts one at a time; Aseprite batch is slow-ish, that is fine.

LOOK AT EVERY PNG with the Read tool (it shows images) and fix what looks wrong; crop+upscale with PIL (python3 -I not required for your own files) to check small details like faces. Up to ~3 iterations per scene; ship a good clear picture rather than a perfect one.

ART RULES (must pass; L.finish asserts semi==0 and no pure black/white):
- Hard pixels, palette colours from gvlib/brief.md or `GV.ramp("#hex")`. No gradients/dither/anti-alias. Scene mode: NO black border, 3-tone outline on raised objects only (gvlib does this per c:part), crescent shade lower-right, light from upper left. Gold hem stitch top+bottom (L.finish does it).
- Scene must read at half size (mobile): big clear shapes, a clear focal subject, a strong silhouette, a clear foreground / midground / background. Paint the scene: this canvas is larger than a banner so use the room (sky, distance, props, small details and life).
- Depict the location's description and its thing-to-do (brief text, success text) literally and charmingly: gnome-scale folk world, felt-toy cute, warm, a little funny. Creatures/folk are chibi: big head, squat body. Eyes on characters/creatures: 5x5 cream disc, 3x3 #2a1a10 pupil, cream glint (c:eye) (3x3/2x2 if tiny). No blush patches.
- Vary light across the set (day/dawn/dusk/night/storm/warm via L.SKY, or your own) to suit the place; indoors/caves: draw a cutaway or lit interior with an arch/opening. Region flavour matters (CA Central America, CB Caribbean, CSA Colombia/Andean, EA East Asia, EE Eastern Europe, ESA East/Southern Africa, MENA, NA North America, NWE, OC Oceania, SA South America, SE South Europe, SEA Southeast Asia, WCA West/Central Asia...). Respect cultures: charming gnome-scale versions, no caricature.
- Lairs: show the boss's lair and the boss, imposing but cute-menacing (it's a kids' game: no gore).
- Pixel rules: parts at least 2 px wide; stitches/glints 1 px; keep text out of the picture.
- Do not draw a player gnome unless the brief needs one. Keep the focal subject away from the bottom 6 and top 6 rows (hem).

WHEN DONE reply with ONE short list: slug -> OK or the problem. Do not paste code. If a script cannot be made to work after 3 tries, skip it and say so.

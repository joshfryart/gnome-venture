# Prompt for the next AI: fight rigs and creature art (written 2026-11-10)

You are taking over the fight animation and creature art work on Gnome Venture (PHP game, repo `joshfryart/gnome-venture`). Owner: Josh. He tests on his phone and sends screenshots with red circles. A circle with no words means "this looks wrong": ask or fix, do not guess silently. Replies to him: short, exact, no filler.

## Where things stand
Branch `claude/adoring-edison-eb86cu` (pushed, no PR, not merged, no version bump, no release zip). Do not push to main or open a PR unless Josh says so.

**Done and in the game code on this branch**
- Gnome re-rigged: head, beard, scarf, eyelid, elbows. Beard and scarf are springs. Blink, 5 fidgets, hop back after Pluck / Attack, new guard and snack.
- Engine (`game/assets/fightengine.js`): one sheet per actor (row 0 paint, row 1 ink; all ink behind all paint = one outline), bone tree, generic springs, blink and fidget timers, moves `peck, swoop, strike, smash`, a ResizeObserver so the stage follows its own width.
- All 117 enemies + 7 crew rigged from the mini archetype code: `tools/fight/rig_minis.lua` writes `game/assets/img/fight/rig-<slug>.png` and `game/assets/fightrigs.js`. Motion per body type: `game/assets/fightarch.js` (13 body types).
- One light art pass on the OLD creature style (commit `f6ad7092`, 57 minis changed game-wide; revert that commit alone to undo).
- Game wiring: `includes/fight_scene.php`, `includes/layout.php`, `assets/fightscene.js`, `gnome_parts.php?p=sheet`, `includes/gnome_rig.php`.

**Proposal only, NOT in the game** (`aseprite-source/v3/creature25/`)
- Three creatures redrawn in the 2.5D gnome's style (same `v3/lib/hp.lua` library, palette, 1 px ink outline, the gnome's `form` / `under` painters and eye): wild boar, great hawk, bullfrog. Richness pass and quirk pass done. Josh had the hawk's stray feather removed.
- They are rigged and animated in a demo: `creature25.lua` (stills; `rig=1` writes sheets + `creature25-rigs.js`), `creature25-arch.js` (leaf and crest springs, snort puff, the fly), `build_demo.py`, `demo.html`.
- Artifacts Josh has seen: stills https://claude.ai/artifact/86GMYhpAjazrDHkd1RU6gG , rigged https://claude.ai/artifact/Uje1pTmge5PkdEmUNsCwMo , first engine showcase https://claude.ai/artifact/La9cvmEvSbYKwWUUmPnicF

## What Josh has NOT decided yet (ask, do not assume)
1. Does he approve the new creature style for roll-out to all creatures?
2. If yes: all 124, or enemies first? Keep the pedestal minis elsewhere in the game (lists, trek) or replace those too?
3. Anything to change in the three examples first. Known weak spots I told him about: hawk tail tips are blobby, the kinked crest reads as a stub, the boar's broken far tusk barely shows.

## Most likely next task: roll the new style out
Plan I would follow (confirm with Josh first):
- Do NOT hand-draw 124 creatures. Write one drawing routine per body type in the new style, driven by the existing spec table (`opus-test-run/scripts/minis/enemies.lua`: slug, size, archetype, colours, features). The three examples are the templates for quad / bird / frog. Still to design: bug (ant, beetle, plain, moth, wasp), worm, snake, snail, crab, spider, golem, wisp, octo, folk.
- Draw in parts from the start with the `T(c, "part")` tag pattern in `creature25.lua`, and return bones `{id, parent, pivot x, pivot y, under}`. Keep the part ids the body type's poses already use (see the skeletons in `fightrigs.js` and the comments at the top of each block in `fightarch.js`), so the existing motion works unchanged. New parts (a leaf, a puff) get springs or pose tracks in an arch extension like `creature25-arch.js`.
- Map each creature's colours onto Hearth Pop ramps (`aseprite-source/v3/lib/palette.lua`); the old minis use a different palette.
- Quirks are per creature, not per body type. Keep a small quirk table by slug.
- Sheet scale: the gnome is 64 px = 2 board cells. Use `size: 1.087` (see `creature25-arch.js`) or change `PXC` so new sheets match him.
- When approved, the new generator replaces `tools/fight/rig_minis.lua` output; `game/assets/fightrigs.js` and the `rig-*.png` sheets are regenerated. Decide with Josh what happens to `game/assets/img/mini/mini-*.png`.
- Show him a batch (one per body type) as an artifact BEFORE doing all of them.

## Other open items
- Phone performance never measured (a boss worm is about 30 animated layers). Josh has not confirmed the fight looks right on his phone.
- Reduced motion only jumps to the end; shake and flashes are not dropped.
- One attack per creature. Villagers are rigged only for the 7 crew. Aphid swarm is still a single picture (its mini comes from `opus-test-run/scripts/mini-aphid-swarm.lua`).
- Only attack frames of the new three were checked frame by frame; hit, run, knock-out and fidgets were not.

## How to work here
- Read first: `claude/animating-2-5d-sprites.md` (section 2b is current), `claude/fight-anim-engine.md` (last update block), `aseprite-source/v3/lib/CHEATSHEET.md`, `___Handoff_Oct24READ`.
- Aseprite: `aseprite-source/Aseprite_1.3.18.6-x64.AppImage --appimage-extract` into a scratch folder, then run `squashfs-root/AppRun -b ...`. Do not commit a mode change on the AppImage (`chmod 644` it back).
- Rebuild game rigs: `GV_ROOT=$PWD/ RIG=1 <AppRun> -b --script tools/fight/rig_minis.lua`
- Rebuild the gnome sheet: `php tools/gnome_rig_parts.php`
- New-style stills: `<AppRun> -b --script-param out=<dir>/ --script aseprite-source/v3/creature25/creature25.lua`; rigs: add `--script-param rig=1`; demo: `python3 aseprite-source/v3/creature25/build_demo.py out.html`
- Gates, run before every commit that touches the engine or rigs: `node tools/fight/smoke.js` (about 6 minutes, every rig), `bash tests/fight_scene.sh` (the game page in a browser).
- Review motion by contact sheet, not by guessing: `node tools/fight/sheet.js '<events json>' 8 300 out.png <slug> foe 8 2` (also `fidget:<name>` and `idle`).
- One-file showcase of the game rigs: `python3 tools/fight/build_demo.py out.html --showcase`
- Pose conventions that bite: creatures face RIGHT; `+r` is clockwise, so a hanging limb swings BACK with `+r` and a head nods DOWN; pose x/y are figure units, up is negative; a pose's `dur` must equal its move's `dur`; never key follow-through, make the part a spring.
- The mini archetype script (`opus-test-run/scripts/minis/lib.lua`) still draws the minis; without `RIG=1` its output must stay byte-identical unless you mean to change the art. Check by regenerating and diffing against `game/assets/img/mini/`.
- Commits: clear message, end with the Co-Authored-By and Claude-Session lines the session gives you. No model names in the repo.

## First message to Josh
Ask the three undecided questions above in one short message, with the two artifact links. Do not start the roll-out before he answers.

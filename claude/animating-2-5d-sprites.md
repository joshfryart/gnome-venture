# Animating 2.5D sprites (Gnome Venture fight engine)

For anyone adding a creature, a move, or a quirk. Engine: `game/assets/fightengine.js` + `.css`. Demo: `game/fight_demo.html`. Plan and history: `claude/fight-anim-engine.md`.

## 1. What this is
- A fight is a **list of events** rolled by PHP (`{from, to, move, dmg, miss, crit, pop}`). The engine only **plays it back**. No game logic in the animation.
- Look: a tilted board (one CSS perspective), upright flat sprites standing on it. Think paper puppets on a tilted table.
- Motion comes from **maths, not frames**: few key poses, tweened by the browser (Web Animations API), plus a little physics for secondary motion (hat, curl). Adding a move or creature = adding **data**, not code.
- Everything is CSS + WAAPI + CSSOM styles. No inline `style=` in markup (CSP). No canvas, no libraries.

## 2. The pipeline (art to screen)
1. **Art**: a sprite is cut into **parts** (64x80 PNGs, all in the same frame coordinates, so they stack with no offsets). Gnome: `torso, legB, legF, armB/armF (same image), hat, tip`.
2. **Rig data** (`RIGS`): which parts, in what order, pivot (px) of each, brightness dim for far limbs, lag (ms), which parts are physics bodies.
3. **Poses** (`POSES`): per-part keyframe tracks (rotation, small x/y). Whole-limb motion: run cycle, swing, flop.
4. **Moves** (`MOVES`): whole-body keyframes (travel, lean, squash and stretch, brightness, fade) + `hit` beat, `fx`, `swoosh`, `dust`, which `pose` to play.
5. **Physics** (rAF loop): springs on `hat` and `tip`, driven by how the head moves. Free-flight when the hat is knocked off.
6. **Events** in, promise out: `play(list)`, `together(list)`.
7. **Review** with contact sheets and a GIF (section 7), **gate** with `smoke.js`.

## 3. Conventions (get these wrong and everything mirrors)
- Art faces **right**. The engine mirrors with `scaleX(-1)` for the left side. Draw one facing only.
- In a move: `x` = fraction of the **reach** to the target (1 = touching), `dx` = cells, `y` = cells (**up is negative**), `sx/sy` scale, `r` degrees, `b` brightness, `o` opacity. Positive `x/dx/r` mean **toward the opponent**, so one move serves both sides.
- In a pose: `r` is clockwise-positive screen rotation, so **positive r swings a limb BACK, forward is negative** (gnome faces right). `x/y` are gnome-frame px.
- Key = `[ms, {props}, ease-into-next]`. The **ease belongs to the segment that starts at that key**. First key at 0, last key **at `dur`** (the validator checks).
- `hit` is the ms of the contact beat (damage number, burst, hit-stop, target reaction fire there). Put the fastest part of the move just before it.
- Reach = distance minus half each sprite width, so sprites touch but never overlap. Set `w/h` (cells) on the rig; creature sizes in `SIZE`.
- Time scales with `speed`; hit-stop pauses live animations; reduced-motion skips to the end (speed x40).

## 4. Recipes
**New move** (e.g. `bite`): copy the nearest move in `MOVES`. Anticipation first (pull back 15 to 25% of the reach, squash `sx 1.1, sy .9`), then a fast ease-in to contact at `hit`, overshoot squash at contact (`sx 1.12, sy .88`), ease-out recovery. Add it to `ATTACK[slug]` if a creature uses it by default.

**New pose**: tracks per part; the torso leads, limbs follow (offset keys by 20 to 60 ms for drag). Opposite limbs get opposite rotations. Loops: first and last key identical; `loops:Infinity` in the pose. Reuse a loop inside a move: `pose:{use:'run', dur:350, loops:2}` (`len` is the base duration, handled for you).

**New creature**: drop `mini-<slug>.png` (80x80, faces right), add `ATTACK` and `SIZE` rows: it works at once as a single picture. To give it limbs: add a spec to `tools/creature_rig_parts.py` (`--grid` prints a measured grid; head mask, leg boxes, belly row, fill colour), run it, add a `CRIT[slug]` entry (parts in back-to-front order, pivots printed by the tool), reuse `QUAD` poses or write its own. Boar is the worked example. Other creatures **still single pictures**; goal: a parts rig like the gnome (body, head, jaw, front and back legs, tail), cut by a script like `tools/gnome_rig_parts.php`, same `POSES` shape. Do this boar and wolf first.

**Secondary motion** (the cheap magic): never script follow-through by hand. Make the part a spring body (`phys:1`) driven by the host's measured movement (`stepHat`). Hat lag, tilt and the whipping curl all come free on every move. Same recipe for a beard, scarf tail, tail.

**Quirk budget**: one memorable beat per move (shimmy before the rush, dust on run-ins, cheer, dizzy stars, hat pop and refit). Quirk is character, keep it short (under 1.5 s) and skippable by speed.

## 5. Rules of the renderer (hard-won)
- **Do not use 3D planes for actors.** We tried upright planes inside a `preserve-3d` board: Chrome depth-sorts them against the tilted tiles, so any rotated or lying body vanished. Now: the board is one transform; each actor is a **flat, screen-aligned picture placed at the projected position of its feet** (`proj()` via DOMMatrix) with the local perspective scale; `z-index = row`.
- Anything that leaves the body (a fallen hat) is **re-parented to a fixed ghost frame** at the actor's spot (`hatTo`), and moved back on refit. Otherwise it rides the body's transforms.
- Held end poses (`keep`) are committed with `commitStyles()` then cancelled (no fill-forward leaks).
- Pose `offset` must be in 0..1: use `len` when a `use` pose changes `dur`.
- Rotate and scale only on `.fe-body` / part layers; position only through `place()`. Mixing them breaks the projection.
- `destroy()` the engine before re-creating on the same host (stops the rAF loop and the resize hook).

## 6. Art spec for a part rig
- Frame 64x80 per part (gnome); creature frame to be set per rig. All parts share one frame origin.
- Pivot = joint centre in frame px. Arms at the shoulder, legs at the hip, torso at the hips, hat at the brow, tip at its base.
- Order = back to front. Far limbs get `dim ~.75` for depth.
- Tint: parts are untinted PNGs today; per-player colours (hat, beard, scarf) must be composed per player with the same args as `gnome25_url`. `gnome25_compose($view,$cols,$skip)` can skip layers.
- Cutting from existing art: `php tools/gnome_rig_parts.php [hat=#.. beard=#.. scarf=#.. out=dir]`. Filter stray pixels by row and column (the cut shows brim underside and trim fragments if you do not). Anything hand-drawn (the arm) is a placeholder until it is redone in Aseprite/Lua.
- Anything that must come off (hat) needs the thing under it drawn (bald dome with three hairs).

## 7. Tools (`tools/fight/`)
| Command | What |
|---|---|
| `node tools/fight/smoke.js` | Gate. Data lint (`FightEngine.validate()`), 6 creatures x 7 scenarios, no page errors, no NaN transforms, hat ends worn with no ghost frame, KO leaves hat down, reduced-motion path fast. Run before every commit that touches the engine. |
| `node tools/fight/sheet.js '<events>' 8 250 out.png [slug] [me\|foe]` | Contact sheet of one actor over time, slow motion, 3x pixels. Review a move by looking at one image. |
| `node tools/fight/gif.js out.gif ['<events>'] [slug] [width]` | Crisp, tightly cropped GIF (renders wide, no upscaling). Needs ffmpeg. |
| `python3 tools/fight/build_demo.py out.html` | One self-contained HTML (css, js, images inlined) to share or publish as an artifact. |
| `php tools/gnome_rig_parts.php` | Re-cut the gnome parts. |
Playwright and ffmpeg are in the cloud container. `Math.random` is pinned in the tools so frames repeat.

## 8. Review checklist (look at a sheet, tick each)
- Anticipation visible before the big action? Contact frame reads (squash, flash, burst)? Recovery eases, not snaps?
- Sprites touch, never overlap, at contact. Feet on the shadow at rest.
- Limbs swing the right way (forward = negative r). Far limb dimmer.
- Hat lags, tilts, curl whips; it pops when a hit takes HP below 25% (or KO / `pop:true`), tap ring shows between turns, tap = refit + heal event; fallen hat stays on the ground; refit ends straight.
- Number pops inside the stage; HP bar updates at the hit beat, not before.
- KO lies on the ground, not in it. Guard ring gone after flee.
- Left-facing mirror is correct; slow motion (x0.3) looks the same, only slower.

## 9. Critique of what we built
**Good**: data-driven moves and poses; server-authoritative; physics gives character for free; flat projection is robust; small (one JS, one CSS, a few PNGs); CSP-safe.
**Weak**:
- Only the gnome has limbs. Creatures are pedestal pictures: they cannot hit-react, KO or show personality beyond squash and a lunge. Biggest quality gap.
- Hand-written one-line key arrays are hard to read and review. Mitigated by the validator; a small authoring tool (preview a single move in a loop) would help more.
- The arm is code-drawn, untinted parts, hand-picked pivots. Art is not in the Aseprite/Lua pipeline yet, so it is not reproducible from source files.
- Frame capture is video-based and non-deterministic (rAF + timers). Good enough for review; not a pixel-regression test.
- No PHP-side tests of the event log. Not wired into `adventure.php` (on `main`, but unused by the game). Sound is out of scope (Josh: no sound).
- Reduced-motion is "jump to the end"; it should also drop shake, camera push and flashing.
- Dark theme and low-end phones (many springs, drop-shadow filters) not profiled.
**Fixed in this refinement**: engine had no teardown (each re-mount leaked an rAF loop and a resize hook; now `destroy()`); mistakes in move/pose data only showed up as a runtime crash (now `validate()`); tools lived in a scratch folder (now `tools/fight/`); GIFs were upscaled blurry with dead space (now native and cropped); no gate (now `smoke.js`).

## 10. Roadmap (in order)
1. Creature part rigs (boar, wolf), same `POSES` shape, plus hit and KO for them.
2. Tinted gnome parts per player; arm redone in Aseprite/Lua; parts built from `aseprite-source/`.
3. Wire into `adventure.php` behind `gnav_tiles`: event log from `trail_token_event` / `encounter_creature`, replace the popover.
4. Spring bodies for beard and scarf; idle fidgets (hat tip, beard stroke, blink).
5. Full reduced-motion path.
6. A `?move=bite` loop preview page for authors.

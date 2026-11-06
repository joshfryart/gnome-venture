# Fight animation engine (own engine, rough pass 2026-11-05)

Goal: fluid 2.5D fights on the trail tile map (mockup B: tilted board, upright sprites, HP bubbles over tiles). Cheap to author, cheap in tokens.
Mockup: https://claude.ai/artifact/Jrj4LnTBFpVe3Sx8Eg9hRu (source was scratchpad `trailfight.html`; same ideas as below). Status: BRAINSTORM, nothing in game yet. Today fights open as the old encounter popover (`adventure.php:354`).

## Core idea
Fluid = motion maths, not many drawn frames. Few key poses + code tweens. Adding a creature or move = data, never new code.

## Pieces
1. **Rig data** (one JSON/PHP array per actor): sheet path, frame size (gnome25 = 64x80, 8 frames), named clips `{frames:[..], fps, loop}`, anchor (feet), facing.
2. **Move table** (shared by all actors): `strike`, `hit`, `ko`, `guard`, `flee`, `idle`. Each = a track list `[t_ms, prop, value, ease]` over x, y, scale, rot, flash, shake. Props only: translateX/Y, scaleX/Y, rotate, brightness.
3. **Motion rules** (free polish): anticipation (pull back 15% first), squash and stretch on lunge/land, ease-out on hit recoil, hit-stop 60-80ms on contact, small board shake on big hits, shadow shrinks with lift, damage number floats and fades, KO = tilt, drop, fade.
4. **Runner**: one small JS file. Reads a move, runs it with Web Animations API (`el.animate`) so the browser does the tweening. Sequence = promise chain: `await run(me,'strike'); await run(foe,'hit'); await run(foe,'strike')...`. Needs no inline `style=` (CSP): set CSS vars/WAAPI only. Respect `prefers-reduced-motion` (skip to end state).
5. **Sprite clips**: CSS `steps(n)` background-position on the sheet. Reuse walk strip for lunge, flash the idle frame for hit. Only draw extra frames when a move needs a new pose (attack, KO).
6. **Variants for free**: gnome25 tint layers (hat/beard/scarf), CSS filter for flash/poison/frozen; flip with scaleX(-1) so one facing is drawn.
7. **Layout**: grid cell size `--c`; actors sit N cells apart, lunge = (gap - 1) cells so they never overlap (mockup bug fixed 2026-11-05: gnome col 2, boar col 7, lunge 160%).
8. **Server stays truth**: the fight result (damage, who dies) is rolled in PHP as today; the page only plays the log back as a script of moves. No game logic in the animation.

## Token savers
- One spec (this file) + one move table: new fights never re-explain the rig.
- Art by script: Lua loops over frames/params in `aseprite-source/v3/`; Haiku-level agent can batch sprite frames, Sonnet checks one contact sheet.
- Test by snapshot: headless Playwright shot at fixed times (0, 150, 300 ms) of each move, one contact sheet to look at, not live runs.
- Ship slim: engine = one JS + one CSS + JSON, so the release zip stays tiny.

## Rough build order
1. Move table + runner with the current gnome and boar (no new art).
2. Hook to the fight log (`trail_token_event`, `encounter_creature`) behind the `gnav_tiles` flag.
3. Replace the encounter popover on tile maps with HP bubbles + buttons (option B).
4. Draw missing poses: gnome attack/hit/KO, boar idle/attack/hit/KO, then other creatures by script.
5. Tests: snapshot contact sheet, reduced-motion path, double-tap safe (queue moves).

## Open questions for Josh
- Keep mini pedestal creature art, or draw real battle sprites?
- Fights from 2.5D delve/lair maps too, or trail only first?
- Sound hooks per move (hit, KO)?

## Update: limb rig for the gnome (2026-11-05)
- Gnome is now a PARTS rig, not a strip: `torso` (hat, head, beard, body), `legB`, `legF` (boots), `armB`, `armF`. All parts are 64x80 in the same frame coordinates, so they stack without offsets; each rotates about a pivot (torso 32,64; legs 28/36,63; arm shoulder 33,48).
- Cut by `tools/gnome_rig_parts.php` from the real `gnome25` side idle frame (`gnome25_compose` got a `$skip` list). The ARM IS NEW PIXEL ART drawn in that script (the old gnome had none, hands tucked in the beard); redraw it in Aseprite/Lua later. Parts are untinted for now: tinted parts must be composed per player (same args as `gnome25_url`).
- `POSES` in `fightengine.js` (idle, run, pluck, guard): per-part keyframes `[ms,{r,x,y},ease]`. Positive r = swing BACK, forward = negative. A move names its pose (`pluck: pose:'pluck'`), or reuses a loop (`flee: pose:{use:'run',dur:350,loops:2}`).
- Pluck = wind up (arm cocked back, lean back) -> run in (leg stride) -> arm whip at the hit beat (ms 440) -> recover.
- Next: hit/KO limb poses, walk pose for board movement, far-arm/leg depth, tinted parts, same part rigs for creatures (head, jaw, legs, tail).

## Update: 5 iterative passes (2026-11-06)
1. Limb poses for hit (flail, knockback), dodge (leap, legs tuck), KO (arms flop, legs buckle, fade); softer contact lean on pluck.
2. `walk` pose and an `enter` move (run in from off-board, parts run cycle); `together([...])` plays events in parallel (both sides enter at once).
3. Arm swoosh arc at the swing beat (`swoosh:` ms on a move), far leg dimmed for depth.
4. Polish: damage numbers pop to the side of the head (clamped inside the stage), crit pushes the camera in for a beat, easing on the shake.
5. Verified by contact sheets: pluck, enter, hit, KO, guard (ring + raised arms), flee, creature pounce. Fixed: pose `use` + `dur` made offsets > 1 (added `len`), guard ring kept after flee, damage numbers clipped at the top.
Still open: creature part rigs (all creatures are still pedestal pictures), hit/KO for creatures, tinted gnome parts, redraw arm in Aseprite/Lua, wiring into `adventure.php`.

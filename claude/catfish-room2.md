# Cat Fish room2 (the canvas room)

Setting `catfish_room2` (Admin > Settings): `0` off (the old 320x200 page), `1` admins only, `2` on for everyone (default). `catfish_room2_on()` in `game/includes/catfish.php` reads it.
The old page is untouched when it is off; `catfish_stage_html()` hands over to `catfish_room2_stage_html()` only when it is on and `assets/img/catfish/room2/manifest.json` exists.

## What it is
- **Page shell** (`game/catfish.php`, `assets/catfish_shell.js`, the `.cfr2` block at the end of `assets/catfish.css`): the room first, then a shop drawer holding three panels (`.cfdp`): Shop (upgrades), Shelter (adopt), More (the hub). Under 1000 px it slides in from the right over a scrim (Esc or the close button shuts it). From 1000 px it is a permanent 360 px rail. A one-time "turn your phone" chip shows in portrait (localStorage `cf_turn`). Without JS the panels are plain blocks.
- **Engine** (`assets/catfish_room.js`): one 480x270 canvas. Floor point (u,d) -> screen: `y = 268 - 158 d^0.8`, `x = 240 + (u-.5) 720 (1-.45 d)`; cats draw at scale `1 - .58 d` (1/16 steps). Draw order: sky, wall, floor, sunbeam, wall things, furniture and cats sorted by foot y, window, front plate, dusk/night tint, rain, lure, wand, fish, pops.
- **Play**: tap the floor = the wand casts (frames 2, 3/4/5, 6, 1), the lure flies and lands, the cat chases and pounces; the catch pays. Tap a dangling fish = pays x1.5. A catch of a far throw (d >= .55) pays x1.25. Tap a ready active room thing = `petuse`. Keyboard: three hidden buttons (`.cfr2key`).
- **Cats**: run (12 frames side, flipped for left), toward/away (8), zoom (6, the zoomies: sideways off the screen and back in), idle (18 old-art poses: sit, blink, wiggle, stalk, pounce, nap, catch, tail flick, ear twitch, yawn, stretch, wash, swat, jump, happy). Idle cats pick a variety move every 5 to 12 s. Other cats wander, nap on the cushion (lazy ones), tag each other, join a throw sometimes, and climb the cat tree when it is owned. `prefers-reduced-motion`: no wandering, zoomies or variety; the cat steps to the lure. `?cffast=1` shortens the idle waits (tests).
- **Room things** draw in their slots (boxes in `PSLOT` in catfish_room.js); the old `cf-pet-<key>.png` art is reused.

## Payout API
`catfish_play($uid, $n, $seq, $rod = 0, $far = 0)`: `n` taps in the batch, of which `rod` were on the fish (x`CATFISH_ROD_MULT` 1.5) and `far` were far catches (x`CATFISH_FAR_MULT` 1.25). Both are clamped to `n` (and `far` to `n - rod`), and the best multipliers are applied first, so a client can never be paid for more than `n` taps. The API (`catfish_api.php`) passes `$_POST['rod']` and `['far']` on tick, buy and petuse. Client: `window.CFPlay.tap('rod'|'far'|'catch')` in `assets/catfish.js` uses the same token bucket and batching as a fish tap.

## Art pipeline
Source: `aseprite-source/catfish/room2/` (Aseprite Lua + Python: `cf_run80.lua`, `cf_zoom.lua`, `cf_run_fb.lua`, `cf_room_a*.lua`, `cf_props_room2.lua`, the `*_coats.py` recolour scripts; specs in the `*_spec.md` files). The 4 improvement passes' notes are `pass{1-4}_*.md`.
Pack for the web: `python3 -I tools/catfish_room2_pack.py` (needs Pillow). It rewrites `game/assets/img/catfish/room2/` completely:
- `cat/<set>/<layer>.png`: one horizontal strip per layer, sets `run`, `zoom`, `toward`, `away`, `idle` (idle comes from the old 64x64 art in `assets/img/catfish`; alias frames blink, tailflick and eartwitch fall back to idleA's file for layers they do not own).
- `room/` plates, `furn/` furniture, `props/` lure, wand, shadow, dust, streak, and `manifest.json` (layout, depth model, furniture list, wand frames, strip sizes).
Layers compose in the browser, once per cat and set: body, erase mask (`ears-clear`, `tail-clear`; idle erases after the pattern), part (folded ears, bobtail), pattern (`-fold` variant for folded ears, except idle), eyes. Re-run the packer after changing any source art, then bump `APP_VERSION` so the browser reloads it.

## Not in room2 yet
Collars on the stage cats, the seasonal bits, the old stage's pet buttons (replaced by canvas taps), cat-tree play beyond perching.

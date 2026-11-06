# Fight animation: build plan (2026-11-06)

Status: engine, gnome part rig, hat physics, tools, guide are done and on `main` (not wired into the game; nothing player-visible yet). Guide: `claude/animating-2-5d-sprites.md`. Notes: `claude/fight-anim-engine.md`. Gate for every step: `node tools/fight/smoke.js` passes + one contact sheet or GIF looked at.

Model hint: Haiku = batch art by script, Sonnet = engine and wiring, one contact-sheet check each.

## Phase 1: player gnome designs (small, do first)
1. `game/gnome_parts.php?hat=&beard=&scarf=`: run `gnome25_compose` per part layer, cache by colour hash (like `gnome_sprite.php`), return one atlas PNG. Demo and engine read it instead of the fixed PNGs. Fallback to default colours on error.
2. Layer-split art: hat, hat outline, tip, bald dome as their own Aseprite layers; `tools/gnome_rig_parts.php` cuts by layer, not by row and column.
3. Slot contract in data: pivots and hat-physics numbers per design.
4. `smoke.js` design matrix: N designs (extreme colours), parts non-empty, pivots inside parts, contrast check, hat pop and refit pass; one 12-design contact sheet.
Done when: any hat, beard and scarf colour a player can pick plays every move with no artefacts.

## Phase 2: creatures get limbs (biggest quality gap)
1. Boar part rig (body, head, jaw, legs F/B, tail) cut by script from existing art or redrawn; `POSES` for run, charge, hit, KO.
2. Wolf, then bear, frog, ram, scorpion. Reuse the pose shape; per-creature numbers in data.
3. Creature hit, KO, dodge, idle fidgets. Tail or ear spring bodies (same recipe as the hat).
Done when: every creature has charge/pounce, hit, KO and idle on parts, and `smoke.js` covers them.

## Phase 3: wire into the game
1. Event adapter: PHP fight log (`trail_token_event`, `encounter_creature`) to `{from,to,move,dmg,miss,crit,pop}`; server stays authority.
2. Mount on tile maps behind the `gnav_tiles` flag, replacing the encounter popover (`adventure.php:354`); HP bubbles and buttons as in mockup B.
3. Safe paths: double-tap queue, reconnect mid-fight (jump to end state), `prefers-reduced-motion` (also drop shake, camera push, flashing).
4. PHP test for the event adapter; keep `smoke.js` in CI.
5. Release: version bump, `CHANGELOG.md`, slim zip (engine is one JS + one CSS + a few PNGs).
Done when: a real trail fight plays on the map with no popover, on phone width, light and dark.

## Phase 4: style and polish
- Beard and scarf spring bodies, idle fidgets (hat tip, beard stroke, blink), more quirks per move.
- Sound hooks per beat (`hit`, `ko`, `pop`, `cheer`).
- Arm redrawn in Aseprite/Lua; art built from `aseprite-source/`.
- Profile on a low-end phone (springs, drop-shadow filters); `?move=` loop preview page for authors.

## Open questions for Josh
- Fights from 2.5D delve and lair maps too, or trail only first?
- Which hat and beard shapes (not only colours) are planned, so the slot contract fits them?
- Sound: yes or no for the first release?

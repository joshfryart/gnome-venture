# Delve mockup 3: route map with chambers
Open `index.html` (uses real art from `game/assets/img`). Dashed bar = demo switches: mood (Grotto / Mine / Flooded) and visit (First / Replay / Pal sent). Tap a node to peek; "Go this way" swaps the room card. `?theme=dark&mode=pal&mood=flood` also works.

**Concept:** a delve is a branching map of chambers (fight, tough fight, treasure, shrine, puzzle, Mo the mole, mystery, guardian + chest). You pick the next branch; red stitches show danger. Each chamber is a room card with 2-3 real choices (fight, hum them to sleep, offer a glowcap). Each delve has a mood with one rule. A party strip shows the gnome and 2 Puzzle Pals with HP and level.

**Changes vs today:** today = 5 rooms in a fixed order, a random roll per room (45% creature / 25% trap / 30% find), the only choice is "next" or "leave", and the walk map (`delve_map.php`) is just tiles between those rooms. New: you choose the route, rooms have choices, pals take part, and the mood changes the rules.
**Replay:** the whole map is shown, 2 rooms change, ropes you tied become shortcuts, the guardian shows "Bested ×N". **Pal sent:** cleared delves only; the pal sneaks (never fights the guardian), brings finds back and marks a door that needs you.

**Risks:** pals fighting needs a party mode in combat (the Puzzle Pals plan ruled out P2 for now); choice odds need a balance sim; mood text needs writing for 14 delves; once a day stays, but a longer run may feel like a chore; fog and pal runs need new state (extend `walk_scene.state`).
**Effort:** L (map generator + room-card engine + choices data file + pal-run timer). A cut-down M: keep today's rules, add branching map + 2 choices per room, no pal runs.

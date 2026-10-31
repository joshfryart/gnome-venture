# Delve mockup 1: top-down tile map

Open `index.html` (links the real `game/assets/style.css` + art). Shots: `phone.png`, `desktop.png` (find moment), `phone-chest.png`. Demo URL flags: `?find`, `?chest`, `?hoard`, `?theme=light`.

**Concept:** the delve is one 15x15 floor you uncover. Torch light (3 hard bands, line of sight) reveals tiles; seen-but-dark tiles stay as memory. Tap a lit tile to walk (BFS). Things sit *on* the floor: pickups, chests, a key and locked door, tripwires (Grotto Glim spots them 2 tiles out, walk stops), a moss shrine (heal + relight), a foe, a way down. One verb bar under the map; a felt "find" card pops on every pickup; chests get the big dialog moment. Party strip shows gnome + 2 Puzzle Pals with HP and Lv. Minimap + 7 find pips pull you to explore.

**Vs today:** today = 11x11 map with 5 numbered room doors; walking is free and empty, rooms roll fight/problem/find in a list. Here the floor itself holds the content, energy-per-room becomes torch fuel per step, and walls auto-join from the trek sheet (`trek-wall-u-auto`, A2 quarters) instead of the code-drawn SVG.

**Risks:** content per floor (hand layouts or a generator that places keys/doors/traps safely); balance of torch vs energy economy; 225 buttons per view is fine but needs server-side walk validation like `dm_walk`; pal combat is still undecided (fight stays today's screen); 7-column view under 400 px.

**Effort:** L (new floor generator + item/trap tables + walk_scene state + UI). An M slice: keep the 5 rooms, add torch/fog/LOS, floor pickups and the find card.

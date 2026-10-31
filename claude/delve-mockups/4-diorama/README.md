# Delve mockup 4: diorama + lantern clock

**Concept.** Each chamber is one illustrated scene (layered SVG cave + real game sprites). 3-5 glinting hotspots: blue = quiet (secrets), orange = loud (loot, wakes things), green = way on. Every action burns 1 lantern oil, and the lantern's light in the scene shrinks with it. Quiet play finds a hidden nook that refills oil; greed blows away the beetle's z's until it wakes. Fights happen in the same scene: turn banner, HP over heads, 3 verbs (Bonk, pal trick, Scurry). One-line journal, party strip with 2 Puzzle Pals (Lv badge, HP).

**Vs today.** Today a room is a dice roll (creature 45% / problem 25% / find 30%) shown as text rows or a tile map. Here the player chooses what to touch, and risk is visible (quiet/loud tag, odds, oil cost) before tapping. Energy per room becomes oil per action inside a room.

**Open.** `index.html` via any local server from the repo root (paths reach `game/assets/img`). States: `?state=fight|dark|secret`, `&theme=dark`. Click through for the demo loop.

**Risks.** Needs authored chambers (hotspot sets per landscape, ~3-4 rooms x 14 lands) or a kit of parts; scene art per landscape; hotspot positions must survive phone sizes (44 px targets get tight with 6). Oil vs energy vs lantern tool tiers needs one balance pass. More taps per delve: keep chambers to 2-3 actions.

**Effort.** L (new delve state machine + chamber data + scene art). An M slice: one shared scene kit, hotspots drawn from today's room kinds, oil = the lantern tool.

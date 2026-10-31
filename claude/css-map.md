# style.css map (generated 2026-10-31, build 2.3.92 + polish block)

Sections by their own banner comments. Line counts, not a design judgement. `style.css` is 6603 lines.

| Start line | Lines | Banner |
|---|---|---|
| 4 | 82 | 1. Tokens |
| 86 | 29 | 2. Reset and type |
| 115 | 189 | 3. Shell |
| 304 | 141 | 4. Components |
| 445 | 1059 | 5. Pages |
| 1504 | 5 | 6. Motion: everything off for people who ask |
| 1509 | 76 | 7. Phone: fixed action bars sit just above the bottom bar |
| 1585 | 17 | GPS v0.9.3 |
| 1602 | 83 | Map rework v0.9.3 |
| 1685 | 97 | v0.9.6: wide screens (1200px and up): folding menu, middle page, right column. Below 1200px nothing  |
| 1782 | 44 | v0.9.7 Petal sinks: Curio Cabinet, dyes, building looks, signposts |
| 1826 | 85 | v0.9.9 part A: flowers (arranging, drying rack, seed packets, show, florists). Art is inline SVG; co |
| 1911 | 108 | v1.0.0 wave 3: together & coming back (townsfolk, Hollow jar + Pulse, friends, First Week, welcome b |
| 2019 | 24 | v1.0.0 wave 2b: orders, market day, price drift |
| 2043 | 142 | v1.0.0 wave 1: rest stops (types, slots, villagers, passport, adopt) |
| 2185 | 494 | v1.0.0 wave 2a: the garden lives (seasons, weather, pests, companions, animals) |
| 2679 | 747 | v1.4.7: Snail Race, Guess the Weight and Lost Letters polish (assets/race.js, marrow.js, letters.js) |
| 3426 | 609 | v1.8.0 Treks |
| 4035 | 20 | v1.9.3 road: ambient line, result card, off-path/explore/delve rows |
| 4055 | 443 | v1.9.4 road: choice and meeting cards, wonder text, and everything on the road, wilds, delve and lan |
| 4498 | 54 | v2.0.20 trek mini-map |
| 4552 | 226 | v2.0.32 Stitched Toy chrome ===== |
| 4778 | 66 | v2.0.33 Stitched Toy, everywhere else ===== |
| 4844 | 40 | v2.0.38 scene stage (assets/stage.js) and fallbacks |
| 4884 | 15 | v2.0.39 Villagers page |
| 4899 | 40 | v2.0.40 Trek stage and drawers |
| 4939 | 28 | v2.0.42 softer pop-overs: lighter dimming, no blur, a slow fade in and out, no harsh focus ring |
| 4967 | 17 | v2.0.43 Adventure stage and one-screen layout |
| 4984 | 258 | v2.0.44 the hoop map |
| 5242 | 136 | 2.0.67: Gather satchel (scoped .gx) |
| 5378 | 1 | 2.0.67: felt cards, Do tab and town page |
| 5379 | 25 | v2.0.67 workstream B: rest-stop Do cards + main-stop town page (mockup2 Do screen, mockup3 town) === |
| 5404 | 8 | section heads |
| 5412 | 48 | felt action cards |
| 5460 | 194 | TOWN / DO (workstream B only) |
| 5654 | 16 | 2.0.67: stage tint |
| 5670 | 1 | 2.0.67: item squares (.itm) |
| 5671 | 28 | v2.0.67 item squares, wave 1 (approved mockup 4: claude/art-variants/mockup4/items.css) ===== |
| 5699 | 18 | the grid: 3 columns on a phone, then 4 / 5 / 6 by the grid's own width |
| 5717 | 111 | the square |
| 5828 | 12 | the shop basket bar (shop_basket_html: form.basket > .blist + .bfoot) as the mockup's leather strip; |
| 5840 | 1 | 2.0.67: item squares, pickers and crafting |
| 5841 | 12 | v2.0.67 item squares, wave 2: crafting ingredients, the gift picker, garden / town pickers, market-d |
| 5853 | 6 | crafting (includes/craft_view.php): one recipe card per row on a phone so the ingredients get the 3- |
| 5859 | 18 | pickers (dialog.picker > .pickbox): the square grid scrolls between the head and the foot |
| 5877 | 30 | market-day basket (marketday.php): label.mkopt.itmcell = a checkbox + its square; checked reads as p |
| 5907 | 246 | v2.0.84: World > Go tab: header chips, pick-a-place map, felt route cards |
| 6153 | 47 | v2.1.11 phone wander layout: map left, place + result + story right, actions in 2 rows, gather and n |
| 6200 | 137 | Pantry D2 (master-detail): jar chips + search + kind chips + master-detail. Scoped under .pantry2; t |
| 6337 | 145 | Shelves (mockup design 3): the Satchel tab and the Crafting tabs other than the Pantry. Scoped under |
| 6482 | 69 | 2.3.6 Crafting area map (includes/craft_map.php) |
| 6551 | 9 | v2.3.3 pal jobs: "pals home with loot" notice (Today, My Gnome) BEGIN |
| 6560 | 6 | delve v2 hazards + torch bar (delve redo agent) |
| 6566 | 5 | Alchemy potions (Lucky Draught box on a pal trip) |
| 6571 | 11 | 2.3.7 Crafting scene objects open their own recipes (includes/craft_map.php: craft_obj_pick, craft_o |
| 6582 | 22 | polish (unreleased, no version bump yet): audit findings 1-4 (claude/polish-audit.md) |

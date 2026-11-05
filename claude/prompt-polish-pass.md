# Start prompt: richness and polish pass over every rest stop picture, the Treehouse and the Pal Yard

Copy everything below the line into a new AI session. Hand back when done.

---

Repo `joshfryart/gnome-venture`. Make your OWN new branch from `main` (name it `polish-<yourid>`). Commit and push often, never push to `main`, no PRs, do NOT change `APP_VERSION` or `CHANGELOG.md` (Josh releases). Josh wants short, direct replies and exact facts. Art tool: Aseprite 1.3.18 CLI + Lua. You judge your own work by LOOKING at the PNGs (open them, zoom, compare), not by trusting the script ran.

## Goal
Take the 17 "Here" place pictures, the Treehouse and the Pal Yard from "first single pass" to "rich and finished", in the SAME look. This is a polish pass: more detail, life and craft. It is NOT a redesign. Josh already approved the look (hero-scale gate view, Hearth Pop v3).

## What exists (do not rebuild, edit the sources)
- Stop and place pictures, 480x270, in `aseprite-source/v3/here-gate/places/`: `here-stop-camp`, `-ferry`, `-herb`, `-inn`, `-jetty`, `-mill`, `-orchard`, `-shrine`, `-spring`, `-tower`, `-workshop`, plus `here-village`, `here-haven`, `here-wonder`, `here-delve`, `here-lair`, `here-generic`. Each has `.lua` / `.png` / `.aseprite` / `.layout.json` (`{w,h,horizon,view,spots[{k,name,x,y,box}],stand[],compass_clear}`).
- Treehouse and Pal Yard in `aseprite-source/v3/tree-yard/`: `treehouse.lua`, `yard.lua`, `dress.lua`, `common.lua`, outputs in `out/` (`tree-house`, `yard-pals`, `tree-dress-rug`, `-lights`, `-telescope`, `-banner`) and `tree-house.layout.json`, `yard-pals.layout.json`.
- Style: `aseprite-source/art-style-guide-v3.md`, `aseprite-source/v3/lib/README.md`, `lib/CHEATSHEET.md`, helpers `lib/hp.lua`, `lib/hpx.lua`, `lib/palette.lua`. Read `aseprite-source/v3/HANDOFF.md` first. Method notes at the end of `claude/todo-art-v3.md` ("METHOD", gate view, parametric looks).
- Importer that puts them in the game: `tools/import_gate_layouts.py` (places) and the copies in `game/assets/img/scenes/` (`here-<key>.png`, `tree-house.png`, `yard-pals.png`, `tree-dress-*.png`). Lint: `php tools/lint_here.php`.

## Hard rules (these break the game if missed)
1. **Layout JSON is a contract.** Keep every spot `k`, `name`, `x`, `y`, `box` and every `stand` point and `compass_clear` where it is, unless a box must move for a clearly better picture; if you move one, keep it inside the picture, keep the ground at the `stand` points flat and empty, and keep the compass corner (bottom-right `compass_clear`) free of important detail. Re-run `php tools/lint_here.php` and `bash tests/ci_suites.sh here images css_lint`; they must pass.
2. **Each named spot must be readable and distinct** at phone size (the picture shows at about 0.86x on a 412 px screen, pills are drawn over it). The thing a pill names (Campfire Kettle, Ferry bell, Watermill ...) must be an obvious object inside its `box`, 56 px or bigger, with a 12 px gap to its neighbours. Do not hide a spot under a tree or a gate pillar.
3. **No people, animals or gnomes painted into the scenes.** Villagers are sprites placed on the `stand` points in code. Empty, flat, clear ground there.
4. **Single native size and pixel rules.** 480x270 (treehouse and yard: same as their current size), hard pixels only, no semi-transparent pixels, no pure black or white, 1 px ink outline `#2b1c26` on props, no anti-aliasing, no blur, no gradients that are not dithered or banded. Colour is not capped; use 5 to 6 tone ramps with a warm light and a cool shadow.
5. **Keep file names and the key set.** Same `.lua/.png/.aseprite/.layout.json` names; export the final PNG over the old one in `places/` and `tree-yard/out/`. Do not rename, do not add keys. Copy to `game/assets/img/scenes/` with the importer (`python3 tools/import_gate_layouts.py` for places; copy the tree-yard PNGs to the same names there). Do not touch `game/` PHP.
6. **Time and weather are code.** Do not paint rain, snow or night into the base picture; the base is a calm golden-hour day. (A later pass adds overlays.)

## What "rich" means (check each picture against this list)
- **Depth in four layers**: sky and far hills; mid ground with silhouettes; the main props; a foreground frame (gate frame, lantern, bunting, leaves) that does not hide a spot. Atmospheric perspective: far things lighter and cooler.
- **Material cues**: wood grain on beams and planks, stone courses with a few chips, thatch and shingle texture, moss and lichen on the north side, rope, rust, cloth folds. Not noise: 2 to 3 deliberate marks per surface.
- **Light**: one clear key light (top left), rim light on the main props, cast shadows that all fall the same way, warm glow from lanterns, fires and windows on nearby surfaces.
- **Lived-in detail**: each place gets 6 to 10 small story props that say what happens there (camp: kettle, bedrolls, drying line, stacked wood; ferry: coiled rope, lantern post, oars, crates; herb: drying bundles, trellis, watering can; inn: sign, barrels, a coat on a peg; mill: sacks, wheel spray, flour dust; orchard: ladders, baskets, windfalls; shrine: offerings, ribbons, candles; spring: stepping stones, cups, ferns; tower: flags, a ladder, a telescope; workshop: tools on a wall, shavings, a half-built thing; jetty: nets, buoys, planks, gulls NOT painted). Props must not touch spot boxes in a way that confuses them.
- **Flora and ground variety**: 3 or more plant kinds per picture, ground with 2 or 3 tones and a few worn path pixels leading to the road, small flowers or leaves, no copy-paste repeats of the same tree.
- **Landscape variety**: the 11 stops use a palette per landscape in code; do not make all 11 the same green. Each should be recognisable in one glance by silhouette and colour.
- **Known weak spots to fix first** (Josh and the art agents flagged): camp flames, ferry dock, wild-trail trees; and any "flat" area bigger than 60x40 px with one colour.

## Treehouse and Pal Yard specifics
- **Treehouse** (cutaway, 4 rooms: parlour, loft, cellar, plus the puzzles, catfish, contests, books and yard spots): each room needs furniture and a purpose (parlour: hearth, armchair, rug anchor; loft: bunks and a window; cellar: barrels, jars; puzzles: a table with a half-done jigsaw; catfish: a tank with a pixel fish silhouette; contests: a rosette and trophy shelf; books: a full shelf with varied spines). Wood and bark texture on the trunk, roots reaching down, leaves in the canopy, light shafts through windows. Keep the pal perch areas (see the layout) clear and flat.
- **Dress layers** (`tree-dress-rug`, `-lights`, `-telescope`, `-banner`): same canvas as the treehouse, transparent, hard pixels, they must line up with the base at 0,0. Make the string lights have a warm 1 px glow ring in a lighter tone (no alpha), the rug a woven pattern with fringe, the banner a stitched crest, the telescope brass highlights and a tripod.
- **Pal Yard** (6 job sites: garden, trip/trail head, delve mouth, station, sick bay, noticeboard): each site is an obvious silhouette with its own colour accent; paths connecting them; a fence or hedge frame; a few pal-sized clear spots. Same flat-ground rule for `stand` points.

## Method and cost
- Work one picture at a time. For each: open the current PNG, list what is flat or missing against the checklist, edit the `.lua` (or add a `-polish` Lua step that loads the old art and adds layers on top, if that is cheaper), render, LOOK at it at 100 percent and at 0.86 scale, fix, then lint. Max 2 fix rounds per picture.
- Make a before/after contact sheet per group (`aseprite-source/v3/review/polish-places.png`, `polish-treeyard.png`) for Josh.
- Order: weak spots first (camp, ferry, jetty), then the other 8 stops, then village/haven/wonder/delve/lair/generic, then treehouse and dress layers, then yard.

## Hand back
Reply with: (1) per picture: what you added, one line; (2) the contact sheets; (3) files changed; (4) `lint_here.php` and suite results; (5) any spot box you moved (old and new); (6) anything you could not make better and why; (7) branch name.

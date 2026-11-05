# Start prompt: wire in the v3 art and nav pieces that exist but are not in the game yet (copy into a new AI session, hand back when done)

Repo `joshfryart/gnome-venture`. Make your own new branch from `main`, commit and push often, never push to `main`, no PRs, do NOT change `APP_VERSION` or `CHANGELOG.md` (Josh releases). Josh wants short, exact replies. Read first: `claude/plan-graphical-nav.md`, `claude/art-brief-here.md`, `claude/todo.md`, `claude/todo-art-v3.md`, `handoff-codechangesforart.md`. Run `tests/ci_suites.sh` suites for anything you touch and report real results.

Art rule everywhere: a missing image shows NOTHING extra (no emoji circle, no blank disc). Text labels are always centred.

## 1. Rest-stop villager art (art done, code not wired)
- Art: `aseprite-source/v3/folk/sprites/folk-<species>-<n>.png` (63, each 256x96 = 4-frame idle strip, feet baseline y=90) and `folk/portraits/folk-<species>-<n>.png` (63, 80x100). Species: grasshopper ladybird bumblebee beetle wren moth snail tortoise frog toad dragonfly gecko butterfly firefly hedgehog field-mouse wood-mouse hare cricket mole shrew (20 species x 3 = 63 incl. all listed; the folder listing is the truth). `STOP_SPECIES` also uses plain "Mouse" (mountain, tundra): map it to field-mouse.
- Code: `game/includes/stop_folk.php` (`STOP_SPECIES`) and `local.php::stop_folk_img()` currently pick art by species only. Change to pick variant `n` = 1 + (crc32(villager name or id) % number of variants present), so a villager always gets the same art. Fallback to the old species image, then the bust.
- Export: sprites to `game/assets/img/sprite/`, portraits to wherever the stop-folk portrait code reads (find it; same `ph/` mechanism the named NPCs use is fine). Do not rename the source files.

## 2. Gnome rig with directions (art done, code not wired)
- Art: `aseprite-source/v3/gnome-dir/` (front/back/side layer strips, 512x80 = 8 frames: 2 idle + 6 walk; `recolor.py` = the tint method; 10 recolourable layers). Plan the player-gnome sprite for the Here scenes: walk to a tapped spot with turning. Wire only what the art supports: pick view by direction (left = mirrored side), play walk frames while moving, idle otherwise; tint layers client-side from the player's customised colours (see `handoff-codechangesforart.md` section 4). Behind a setting with a fallback to the current bust. Report what is missing.

## 3. Gate-view Here scenes and the new nav chrome (design agreed with Josh)
Test art (Josh approved the hero-scale style): `aseprite-source/v3/here-gate/` use `here-market-maplewold-v5.png` (town) and `pilot-market-grassland_maplewold.png` / `pilot-market-desert_adobe.png` (market-hamlet road stop, same layout `pilot-market.layout.json`); older tries (`here-market-maplewold*.png` other versions, `here-stop-grassland*.png`) are rejected, ignore them; layouts: each `.layout.json`; `mockup-maplewold.png`, plus mockups in chat history). Layout JSON there has `spots` with `name`, `stand` points and `compass_clear`. Do:
- Add those layouts into `game/includes/data/here_layouts.json` as new keys (Admin → Picture layouts must still lint: `php tools/lint_here.php`) and copy the PNGs to `game/assets/img/scenes/` under keys the lookup can use (slug or kind-landscape). Keep placeholders working.
- **No circles anywhere.** Remove painted exit circles/stubs from the new scenes' rendering path. The 8 compass exits are NOT drawn on the map.
- **Compass** (bottom-right, 44 px) opens a **Routes popover**: one row per route, named by DESTINATION (e.g. "Lakeside Haven", "Mill Road Rest Stop"), nearest first, one tap travels (keep the existing cost check). Data comes from the existing exits.
- **World globe icon** (left of the compass) opens a **World map popover**, with a button to open the **Region map**. Reuse existing world/region pages; do not rebuild them.
- **Spots**: every spot is a link to its area, with a centred name tag under it; tags never overflow the picture; on small phones tags show on tap/hold only. Hit areas come from the JSON (invisible): a spot may have `box:[x0,y0,x1,y1]` (a whole building front or area, boxes never overlap); if there is no `box`, use a 56x56 box around x,y. The painted object or facade itself is the button; the name tag is centred in the box. Tapped state: gold corner brackets + lit tag.
- **NPC slots**: villager sprites stand on the `stand` points (up to 6), scale smaller toward the horizon (try 0.55 to 0.95 by feet y; max 4 to 5 villagers shown).
- Phone caveat: a 480 px scene on about 412 px scales 0.86; keep picture 1:1 on a crisp integer scale where possible, else nearest-neighbour.

## 4. Things the wander card and fights already allow (see `claude/todo.md` wander section)
Only wire what has art. Do not draw art. List what is still missing in your report.

## Hand back
Reply with: (1) what you wired, per section, (2) files changed, (3) tests run and results, (4) anything blocked or left, (5) branch name.

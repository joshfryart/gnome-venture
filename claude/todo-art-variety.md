# Art wanted for the variety project (2.0.76 on)

Rule: every placeholder is a white square with a red border and the words THIS IS PLACEHOLDER (`tools/gen_placeholder_art.py`). To finish one: draw the real art, save it over the same file name and size, tick the box. Placeholders must never ship as final.

## FIRST PASS DRAWN, merged to main in 2.0.80, APPROVED by Joshua 2026-10-28 ("love the art")
Ticked = art drawn over the placeholder and approved (a later polish pass is optional). Sources: `aseprite-source/extras-pixel/scripts/variety-{stage,folk}.lua`, `variety-tier-<kind>.lua`; .aseprite in `extras-pixel/aseprite/`. Run with `AppRun -b --script-param k=v --script X.lua` (params BEFORE --script). Weak spots to redraw if Joshua wants: stage-gather (handle hides contents), folk gecko (frog-like) / shrew (mouse-like) / moth (owl-like), tiers shrine-1, mill-1, inn-2, jetty-2, herb-2, orchard-2/3, ferry-3/4, tower-1 (gate not ladder), tower-3, spring-1/2/3, camp-1. Stage icons are the 64 grid scaled 1.5x (uneven pixels at large size); tiers 1-4 of each kind are 48-grid x2 or native 96. Light/dark variants not made.

## Stage verb icons (2.0.76)
Build-stage verb icons, shown at 20px on the repair card (stage list + button). 96x96 placeholders; draw as normal `ico` art (64 grid, house outline/halo rules in `claude/art-style-guide.md`), light and dark if the style needs it.
- [x] `game/assets/img/steps/stage-haul.png`: hauling building materials (a sack, a block, a plank bundle)
- [x] `game/assets/img/steps/stage-gather.png`: gathering finds (a basket with shells, ferns, roots)
- [x] `game/assets/img/steps/stage-feed.png`: feed the crew (a steaming pot or a bowl)
- [x] `game/assets/img/steps/stage-light.png`: lighting the place (a lantern or a candle)
- [x] `game/assets/img/steps/stage-clear.png`: clearing (an axe or a spade, or a broom)

## ART TODO FOR A FUTURE AI: a picture for every stop activity (Aseprite)
**Full checklist of all 810 activities (55 existing + 265 wave + 490 regional): `claude/todo-art-acts.md`** (generated; rerun after merging the 2.0.78 data). First pass is DRAWN for the 55 existing ones, the 4 kind cards (craft/collect/tend/contest), all 265 wave activities (w1-w5) and the 14 first regional ones (na_/ca_): 338 total. ALL 810 activities now have a first-pass scene (the 476 `r_*` regional ones too; see `claude/todo-art-acts.md`). Weak spots per card were listed in the agents' reports (typical: tiny props, shared gnome sprite, busy backgrounds); redraw on Joshua's review. Scripts `variety-act-g6..g24.lua`. First pass of the original 55 is DRAWN on branch `claude/art-first-pass` (Sonnet high, flat pixels in the shipped act-card frame; `act-ringtoss`/`act-shells` overwritten). Weak, redraw if wanted: gossip (bench hides torsos), porter (reads as backpack), grind (spout unclear), skim_stones (tiny stone, empty beach), herb_tea, saw_planks, dress_stone (mirrored light), tall_tale (snail), quiet_hour (legs), star_vigil (not looking up), scan_horizon (faint smoke), firewood (face hidden), bench_rest, egg_boil. All gnomes share one sprite; mirrored scenes light from the right. Scripts `aseprite-source/extras-pixel/scripts/variety-act-g1..g5.lua`.
**Do this:** draw one small scene per rest-stop activity in Aseprite and save it as `game/assets/img/acts/act-<slug>.png` (144x108 PNG, same size and look as the existing `act-*.png` Do-tab cards). No code change: `stop_act_art()` in `includes/stops.php` uses a file named for the activity's slug first, then the old slug map, then the kind card (`act-craft.png` etc.), then `act-any.png`.
- **Which:** every activity in `includes/data/stop_acts.txt`, `stop_acts_regional.txt` and `stop_acts_waves.txt` (skip `tt_*`, those are upgrade acts), and every activity added in future waves. Run `python3 tools/missing_act_art.py` for the list that still has no picture (slug, name, stop kind, kind, blurb = the brief); all 810 now have a first-pass scene (`tools/missing_act_art.py` shows none missing on branch claude/art-first-pass). Do them by region (35 each) and by stop kind (waves `w1_` to `w5_`); the original ~50 mostly share kind cards and can go last.
- **Each scene:** the blurb's moment in one glance. A red-hatted gnome doing the thing (mending a net, staring down a gull), the stop kind's props behind, daylight unless the activity has a `when` (night, rain, winter, dawn: show it). Simple shapes, few colours, no text, nothing that needs the name to be understood. Variety matters: different poses, props, framing.
- **How:** follow `aseprite-source/HANDOFF.md`, `claude/art-style-guide.md` Part D (Stitched Toy: 1 px black border, palettes, canvas rules) and the library `aseprite-source/gvlib`. Look at `game/assets/img/acts/act-hand.png`, `act-rod.png`, `act-fire.png` for the target look. Keep the `.aseprite` source and the Lua script with the other act sources in `aseprite-source/`.
- **Also still placeholder (red border, THIS IS PLACEHOLDER):** the four kind cards `act-craft.png`, `act-collect.png`, `act-tend.png`, `act-contest.png`. Do those first; they show for any craft/collect/tend/contest without its own picture.
- **Ask Joshua before drawing at scale** (his rule: cost estimate and a first batch for approval, Opus draws, one contact sheet to review).

## Stop upgrade pictures (2.0.77; first pass drawn)
Themed stop upgrade pictures, 96x96 placeholders at `game/assets/img/stoptiers/<kind>-<tier>.png`, shown at 24px beside each upgrade on the adopt panel and the plaque. 12 kinds x 4 tiers. Draw as small `ico`-style art, one per upgrade (name in brackets); replace the file, tick the box.
- [x] market: 1 striped awning, 2 weighing house, 3 fountain square, 4 market hall
- [x] mill: 1 sack hoist, 2 mill sluice, 3 flour loft, 4 bakehouse hall
- [x] inn: 1 hearth bench, 2 stable yard, 3 singing room, 4 grand dining hall
- [x] shrine: 1 stone lantern path, 2 prayer bell, 3 wishing pool, 4 pilgrims' hall
- [x] jetty: 1 plank pier, 2 net racks, 3 smokehouse, 4 fish supper hall
- [x] herb: 1 drying rack, 2 seed shed, 3 hive row, 4 tea house
- [x] workshop: 1 workbench, 2 forge corner, 3 crane and pulley, 4 makers' hall
- [x] orchard: 1 picking ladders, 2 cider press, 3 grafting bench, 4 harvest barn
- [x] ferry: 1 landing steps, 2 toll house, 3 second boat, 4 boatmen's hall
- [x] tower: 1 sturdy ladder, 2 signal beacon, 3 map room, 4 watchers' hall
- [x] spring: 1 stone steps and rail, 2 changing house, 3 egg-boiling stones, 4 bathhouse hall
- [x] camp: 1 log seats, 2 cookfire ring, 3 storytelling stage, 4 great lodge
(Still nice to have: a stop header picture that changes per tier; the files are named by kind and tier, e.g. `mill-1.png`. Not wired yet, nice to have: a stop header picture that changes as tiers are built.)

## Villager species pictures (2.0.77 villager overlay; first pass drawn)
Rest-stop villagers show a picture of their species in the overlay (72px). Nine species already use our drawn icons (mouse, bee, hedgehog, snail, frog, beetle, butterfly, cricket, ladybird: `assets/img/ico/ico-<species>.png`). These eleven have no art yet and show a red PLACEHOLDER square at `game/assets/img/folk/<species>.png` (draw 64x64 pixel art, same file name; the code uses the file as soon as it is replaced). Ideally later: a few looks per species, and the same pictures on the villager rows.
- [x] hare  - [x] wren  - [x] mole  - [x] tortoise  - [x] moth  - [x] shrew  - [x] gecko  - [x] dragonfly  - [x] toad  - [x] grasshopper  - [x] firefly

## In the game as PLACEHOLDER (2.0.78, new stop activity kinds)
Do-tab card pictures, 144x108 PNG like the other `assets/img/acts/act-*.png`. One per new kind; any single activity can later get its own closer picture (see `STOP_ACT_ART_SLUG` in `includes/stops.php`).
- [ ] `game/assets/img/acts/act-craft.png`: making something (hands and a tool, a half-made thing on a bench)
- [ ] `game/assets/img/acts/act-collect.png`: spotting things (a gnome with a spyglass and a notebook)
- [ ] `game/assets/img/acts/act-tend.png`: a chore over many days (a gnome with a watering can or rake at a row)
- [ ] `game/assets/img/acts/act-contest.png`: a friendly contest (two gnomes squaring up, hands out)
Nice to have: own pictures for the regional ones, and a "Birds of the Maplewold" journal page picture per collection (the checklist shows only as text for now).

## In the game as PLACEHOLDER (2.0.79, road cards and the Road Journal)
- [x] Road card kind icons, 24px on the card label, `game/assets/img/roadkinds/<kind>.png`: fork (a signpost with two arrows), riddle (a question mark in a leaf), trade (two hands swapping a basket), chain (linked acorns), sketch (a notebook and pencil)
- [x] Road Journal picture per region, 48px beside the region's page, `game/assets/img/journal/<code>.png` (na ca cb sa nwe se ee mena wca esa csa ea sea oc): a small drawing of something typical of the region, as if sketched in a journal
- Later: a picture per sketch page (6 per region) shown when you stamp it.

## Wanted soon (not made yet: add a placeholder when the verb ships)
Build-stage verbs still to come (one icon each, same folder, `stage-<verb>.png`): carry (a parcel with a road), befriend (two gnomes shaking hands), trial (a small trophy or a target), vigil (a moon and a lantern), wait (an hourglass), decorate (a flag or a flower pot), craft_on_site (a hammer on an anvil), fetch_lore (a scroll).

## Nice to have (larger pieces, ask Joshua)
- [ ] Before/after pictures for the nine pilot places: Market of a Thousand Chilies, The Stepped Seed Temple, Cenote of Echoes, Jaguar Root Caves, Driftwood Tavern, Sunken Gnome Galleon, The Singing Waterfall, Mangrove Root Maze, Turtle Nesting Beach (ruined / mended, to sit on the repair card). Not wired yet.
- [ ] A small "progress" picture for a clear stage (cleared in stages: 1/3, 2/3, 3/3).

## 2.0.79 road cards and Road Journal: first pass DRAWN (branch claude/art-first-pass, not yet approved)
- [x] Road card kind icons `game/assets/img/roadkinds/{fork,riddle,trade,chain,sketch}.png` (96x96). Weakest: trade (reads as a basket with sleeves), chain (zigzag at 24px). Script `aseprite-source/extras-pixel/scripts/variety-roadkinds.lua`.
- [x] Road Journal pictures `game/assets/img/journal/{na,ca,cb,sa,nwe,se,ee,mena,wca,esa,csa,ea,sea,oc}.png` (96x96, cream journal page each): maple leaf, maize cob, conch, pan pipes, post box, olive sprig, sunflower, date palm, djembe, acacia, snow peak with flags, torii gate, straw hat, kiwi. Weakest: cb, wca, oc, mena. Scripts `variety-journal-a.lua`, `variety-journal-b.lua`.
- Later (unchanged): a picture per sketch page (6 per region).

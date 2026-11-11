# Maplewold Trail Sights: what the P2 rows cannot do yet

Status: TODO list (2026-11-11). Rows: `game/includes/data/trail_sights_maplewold.txt` (82 rows, lint clean). Ideas: `claude/sights/ideas-maplewold.md`.
Each row holds the simple version (base verb + goodies the reward grammar can pay). Everything below needs engine work or new items in a later phase.
Line kinds: QUEST (line + beat), VILLAGER (who, when, what), NEW ITEMS, MINIGAME, OTHER (mechanics not in the grammar: game-time costs, counters, tier-gated odds, stance, two buffs at once ...).

## Global notes
- Slugs: route 228's pictures have no route number (`haybales`, `scarecrow`, `ford`, `pondmill`, `apple`, `hedgerow`), so the rows use those names, not `228-...` as in the ideas file.
- Verb clashes with the 5 example rows: `232-berrypatch` is "Pick berries" (clover patch has Pick), `232-crossroads` is "Read sign" (old milestone has Read). Rename one side if the ideas' single verbs are wanted.
- Items replaced with an existing one: lupine / milkweed / goldenrod / trillium -> `cut-lupine` / `cut-milkweed` / `cut-goldenrod` / `cut-trillium`; green bean pods -> `green-bean`.
- Goodies dropped (no item): white clover, maple sap, flour, maple syrup, toffee, marshmallow, lost mitten, map scrap, message bottle, scarf, glowcap repair kit, glow-cap decor, Star Chart (13).
- Only one stat buff slot (`ev_stat`) is used by `buff=`: a second buff in the same row would overwrite the first, so each row has at most one buff.
- `fp=` was not used anywhere: it befriends a random folk of the walk's start place, not the named villager.
- Tool-tier odds ("Sturdy tool: ...", "Fine pick: ...") are paid at the base tier: the grammar has no tier condition.
- Quest task kind `sight` (plan 0.4) is needed for every QUEST line below.

## 228 The Maplewold Market to Poppyburrow
### haybales
- QUEST: Q2 Sap to Stack, beat 4 (find a hen-egg the hens hid).
- VILLAGER: Posy Thistledown asleep in it, se=summer dp=day; wake her (charm 10) -> lullaby, +1 Hardiness 60 min.
- OTHER: the nap should cost 1 game hour and be capped at 1 a day (row: 0 energy, en=3, 10 min, cd 5.5 days).
### scarecrow
- QUEST: Q1 Bramble's Picnic List, beat 5.
- OTHER: take "one crop or flower" (any): the row takes a `carrot`. SECRET: dress him in all four seasons -> Almanac page "Mr. Pleased, a year in hats" (per-player seasonal counter).
### ford
- QUEST: Q1 optional bonus beat.
- VILLAGER: Dorrit Snailwick, dp=dawn; hop together = no roll, +1 friendship, escort errand.
### pondmill
- VILLAGER: Fennick Hollowell, se=summer dp=dusk; race him -> which shop has a sale tomorrow.
- MINIGAME: pick 1 of 3 leaf boats (TEACH: the pick mini-game). SECRET: 5 wins in a row, the wheel bows (streak counter).
### apple
- VILLAGER: Moss Sedgemoor, se=autumn 50% of shakes; leave a white clover -> "fine, one", +1 friendship.
- NEW ITEMS: white clover (`white-clover`).
### hedgerow
- QUEST: Q1 beat 3.
- VILLAGER: Clover Puddlejump on Market rest days dp=dawn; trim her way (sense 10) -> 5 Petals.
- OTHER: `butterfly-scales` should need a Sturdy forage tool (paid at Worn now).

## 232 The Maplewold Market to Honeybrook
### 232-beehive
- QUEST: Q1 beat 4.
- VILLAGER: Mabel Pennywhistle, we=sun se=spring,summer; no roll with her; bring `meadowsweet` -> `beeswax`; she fixes the sign (Almanac giggle).
### 232-berrypatch
- QUEST: Q1 beat 2.
- VILLAGER: Alder Pennywhistle, dp=dawn; pick 3 -> punnet swap for 8 Petals.
- OTHER: SECRET: leave one berry at dawn -> next visit `ladybird-charm` 15% (row pays 5% at dawn, no "leave one" memory).
### 232-logbridge
- VILLAGER: Clover Brambleby on away days (to cousin Bunty in Shellhollow); cross together = +2 friendship, deliver parcel to Bunty.
- OTHER: crossing with a pal/villager beside you skips the nimble 8 check (needs pal-beside check). `birch-log` should need an axe.
### 232-well
- QUEST: Q3 Which Nettle?, alternative letter drop.
- NEW ITEMS: Mister Plink (frog name, Almanac).
- MINIGAME: knock a pattern, pick 1 of 3 rhythms.
- OTHER: SECRET knock three times at night -> loan of `singing-pebble` for 1 game day (+1 Charm while carried): needs a timed loan; left out of the row.
### 232-crossroads
- QUEST: Q3 finale (nail the fifth arrow "Nettles: BOTH WAYS").
- VILLAGER: Tobias Trundle's shell-shop here on his Maplewold half-days (buy seed).
- OTHER: the read should list where each traveller is today and which villagers are away; Almanac page "The Lunch Signpost" on first read (row: first:xp=10 only).
### 232-picnicrise
- QUEST: Q1 finale; Bramble turns up we=sun after beats 1-6; first villager errand (carry `garden-honey` to Alder Pennywhistle).
- VILLAGER: Bramble Mossfoot, we=sun dp=day; share food = +2 friendship.
- OTHER: eat one snack here and its buff lasts twice as long (row: en=2 instead).

## 236 The Maplewold Market to Cloverholt
### 236-wildflowers
- QUEST: Q1 beat 1; opens the Almanac Sights chapter.
- VILLAGER: Basil Teaspoon, se=summer afternoons; tells which flower his bees want (that flower grows 10% faster for 1 game day).
- OTHER: "no cooldown for the lore" (row: normal 5.5-day cooldown, because the flowers pay).
### 236-dandelions
- QUEST: Q1 beat 6.
- OTHER: we=wind should give +1 Trail find on the NEXT section (row: find=1 now). SECRET: blow on your gnome's birthday -> Almanac page + Luck all day.
### 236-stonebridge
- QUEST: Q3 beat 1 (2 mixed-up letters in the cubby).
- OTHER: lost post should be a deliver errand (sealed letter, 10 Petals): row pays c=10@40. SECRET: bow 10 times -> Almanac page "Sir Trickle" (per-player counter).
### 236-beanpoles
- QUEST: Q3 beat 2.
- VILLAGER: Dorrit Thistledown on away days (to cousin Posy, Poppyburrow); fetch errand for 3 `wheat`.
- OTHER: the main point, tomorrow's weather forecast for the Maplewold, needs a forecast output.
### 236-windmill
- QUEST: Q2 beat 3.
- VILLAGER: Barnaby Nettlebed, we=wind; hold a sail (grit 10) -> `timber-plank`.
- NEW ITEMS: flour (2 `wheat` -> flour, double on we=wind; no wind costs 30 game minutes).
### 236-haywagon
- QUEST: Q7 Wickerby Sled Derby, beat 3.
- VILLAGER: Pomeroy Crumbworth on festival days (hp=); serve a Maplewold dish, he rates it.
- OTHER: should take "any seed" (no any-of-a-kind take). SECRET: feed 5 visits running -> Almanac page "Sparrow & Sons, Hauliers".

## 304 Poppyburrow to Acornby
### 304-oakarch
- QUEST: Q7 beat 2.
- VILLAGER: Sorrel Rushworth, dp=day; hold the tape -> `oak-log` once per season.
- OTHER: height marks kept in the Almanac, dated by game day.
### 304-hollowtrunk
- QUEST: Q6 Wren's Woodland Census, beat 2 (Almanac critter page `orb-spider`).
- OTHER: SECRET say hello 3 times -> spider hammock: +energy on your next Burrow/Nestle/Bask.
### 304-acorndrop
- QUEST: Q7 beat 1 (`acorn-cap` x4).
- MINIGAME: Nimble power game, 5 taps, caps x1-4 by score (row: nimble 9 check).
### 304-owloak
- QUEST: Q6 beat 1 (`tawny-owl` critter page, dp=dusk,night).
- VILLAGER: Wren Thimblewick, dp=dusk on her Maplewold days; seed-for-forage swap.

## 305 Honeybrook to Birchhollow
### 305-birchtunnel
- VILLAGER: Elm Crumblewick on away days (to cousin Fennel, Pebblestead); herb tip +20% `chanterelle` next forage.
- OTHER: the rumour should name a Maplewold section where a Trail find is rarer today (row: find=1). `birch-log` should need an axe.
### 305-birchcurtain
- VILLAGER: Fennel Crumblewick as the extra trunk, we=fog (row pays her `bright-feather` 50% on fog).
- MINIGAME: pick the right count, 1 of 3.
### 305-fernhollow
- VILLAGER: Posy Mossgrove is the snail, se=spring,summer; +1 friendship, `snail-trail-glaze` 20%.
### 305-sunclearing
- QUEST: Q6 beat 3 (the rabbit).
- VILLAGER: Hazel Nettlebed, dp=day sunny; tell her -> `beeswax` once a week.
- NEW ITEMS: white clover (25%).

## 306 Cloverholt to Mossgate
### 306-mosslog
- QUEST: Q3 beat 3.
- VILLAGER: Nettle Cobblefield of Mossgate, dp=dawn, waiting for her post.
- OTHER: "say nice bridge" as a free second option (row: charm buff always).
### 306-dripgrotto
- VILLAGER: Rue Wickerby building a drip-clock; good rhythm -> `glowing-bead` 30% (row: 10% to anyone). SECRET we=rain: Lyra Fiddlewing teaches "Grotto Waltz" (Almanac) + Luck all day.
- MINIGAME: rhythm power game.
### 306-mossgate
- QUEST: Q3 beat 4.
- VILLAGER: Nettle Cobblefield of Mossgate, dp=dusk; ask together -> +1 Luck until sleep.
- OTHER: pressed `cut-trillium` once per season (row: 10% in spring).
### 306-toadsteps
- QUEST: Q6 beat 4 (the toad).
- OTHER: scout output: show the next section's Trail finds until you leave (row: reveal@15 + items).

## 307 Poppyburrow to Shellhollow
### 307-tideline
- QUEST: Q4 The Lantern That Wandered Off, beat 2.
- NEW ITEMS: message bottle (1%, a real other player's note: phase 4 bottle post).
- OTHER: "after a storm" means the day after we=storm; row uses we=storm now.
### 307-barnacles
- VILLAGER: Yarrow Mossgrove, dp=dawn, on her way to cousin Posy in Mossgate; `fishermans-stew` once a week.
### 307-shellhollow
- VILLAGER: Willa Gillyflower, dp=dusk; give her an echo -> a five-part tale, one part per visit (Almanac page when complete).
- OTHER: a pool of funny echo lines (one win line now). SECRET: say "Willa" at night -> location of a rare find on route 314.
### 307-sandcastle
- VILLAGER: Bunty Brambleby, se=summer dp=day; add a seventh tower -> 10% off one inn rest.
- OTHER: "Sandcastle Corporal" rank ladder, one rank per salute (5 ranks), then `crab-claw` as a medal (per-player counter).

## 308 Honeybrook to Pebblestead
### 308-pebblebar
- VILLAGER: Fennel Crumblewick keeps the skip record, dp=dusk; beat 7 -> `sea-glass` + name on the record stone (Almanac).
- MINIGAME: skim power game, count the skips.
### 308-kelpline
- QUEST: Q4 beat 1 (the lantern's brass hook).
### 308-rockpool
- VILLAGER: Wick Kettleby, dp=day; wave in signals -> +1 friendship + flag lesson (Almanac).
- OTHER: every 5th wave over your visits -> `seed-pearl` (per-player counter; row pays 3%).
### 308-tidesteps
- VILLAGER: Burdock Oakenpot, dp=dawn; peer with him -> map scrap.
- NEW ITEMS: map scrap (marks 1 Trail find on route 314).
- MINIGAME: peer into 1 of 3 teacup pools.

## 309 Cloverholt to Iciclecrest
### 309-frozenpond
- VILLAGER: Sorrel Fiddlewood, se=winter dp=day; skate with her -> +2 friendship, +1 Nimble 60 min.
- OTHER: outside winter the button should say "Paddle" (per-season verb); `arctic-char` seen under the ice -> Almanac critter page.
### 309-snowmen
- QUEST: Q5 A Letter for the Den, optional (the snowmen point north).
- NEW ITEMS: scarf (SECRET: give the carrotless snowman a `carrot` -> next visit it has a scarf and leaves `lemming-fluff` x2).
- MINIGAME: pick the best snowman (no wrong answer).
### 309-icecave
- VILLAGER: Moss Windlass; sells `sea-salt` x2 for 6 Petals, +1 Hardiness 60 min.
- OTHER: shelter = no energy cost for the next 3 steps of the walk (row: en=2).
### 309-auroraledge
- QUEST: Q5 beat 3 (dp=night, the sky ribbon points to the Den).
- OTHER: Almanac page "The Aurora" on first night use (row: first:xp=5).

## 310 Poppyburrow to Snowcombe
### 310-driftpass
- QUEST: Q7 beat 5.
- MINIGAME: pick the right order of 3 turns; win = this section's walk costs 10 game minutes less.
### 310-sledtrack
- QUEST: Q7 finale (se=winter, race day, always a tie).
- VILLAGER: Elm Wickerby, se=winter dp=day; good run -> `birch-log`.
- NEW ITEMS: lost mitten (1 per player; return to Posy Thistledown -> +3 friendship, bell rung for you).
- MINIGAME: power game for distance.
### 310-combridge
- QUEST: Q7 beat 4.
- OTHER: `fossil-shell` should need a Sturdy pick, `frost-crystal` a Fine pick (paid at Worn now).
### 310-icicurtain
- VILLAGER: Hazel Nettlebed on away days se=winter (visiting Barnaby); she hums along -> `beeswax`.
- MINIGAME: ring a tune, pick 3 icicles.
- OTHER: SECRET hidden 4th button "Lick": tongue stuck, -1 energy, Almanac page "Told You".

## 311 Honeybrook to The Sugar Shack
### 311-taprow
- QUEST: Q2 beat 1 (3 maple sap).
- NEW ITEMS: maple sap (60%; row pays coins instead); a red-maple leaf sketch page for the Road Journal 10%.
### 311-bucketstacks
- QUEST: Q2 beat 2 (borrow two buckets).
- VILLAGER: Clover Brambleby, se=spring dp=dawn; 1 Petal per bucket level (max 12).
- NEW ITEMS: spare tin bucket loan (+1 bucket-tool gather on the next coast route; a borrow flag).
- MINIGAME: stack power game, how high before the wobble.
### 311-sugarshack
- QUEST: Q2 beat 5 (sap -> syrup).
- VILLAGER: Clover Puddlejump, se=spring dp=day; +2 friendship.
- NEW ITEMS: maple syrup (swap 3 maple sap -> 1 syrup), toffee (se=winter 20%).
### 311-pancakelane
- QUEST: Q2 finale (flip while Pomeroy rates it).
- VILLAGER: Pomeroy Crumbworth on festival days (hp=); high flip -> "four spoons" and an invite to serve him a course.

## 312 Cloverholt to Thousand Rings Stump
### 312-ringlog
- VILLAGER: Dorrit Thistledown, dp=day; tie her guess -> `chanterelle` x2.
- MINIGAME: guess the age, 1 of 3, with a streak.
- OTHER: `oak-log` should need an axe, `heartwood` a Fine axe.
### 312-woodpecker
- QUEST: Q6 beat 5.
- MINIGAME: rhythm reply.
- OTHER: SECRET 3 good duets in one season -> next Tune or Ring wins without a roll.
### 312-toadring
- VILLAGER: Dorrit Snailwick, se=autumn dp=dusk; +2 friendship, `toad-jewel` once.
- OTHER: +1 to EVERY stat for 10 game minutes (row: +1 Grit, one buff slot). SECRET dp=dusk we=fog: Almanac page "Two Inches".
### 312-bramble
- VILLAGER: Nettle Cobblefield of Cloverholt, se=summer dp=dawn; approves your manners, +1 friendship.
- MINIGAME: "one more?" choice: greedy = bramble snag, -1 energy; honest = jam left on a stump NEXT visit (row: jam 10% now).
### 312-greatstump
- QUEST: Q6 finale (Tansy's pin flag, road card `na-sketch-thousand-rings`).
- OTHER: a pool of history lines; Almanac page on first trace; the seed should be an uncommon-tier old seed.
### 312-larder
- QUEST: Q6 beat 6.
- OTHER: should take any nut (`hazelnut`, `walnut` or `chestnut`; row takes `hazelnut`); no nut -> a single acorn cap and a stare.

## 313 Poppyburrow to Beaverdam Tunnels
### 313-beaverdam
- QUEST: Q8 Beaver Paperwork, beat 3 (plug a leak with a `birch-log`).
- VILLAGER: Beaver Foreman, dp=day; good patch -> "Hired!" (Almanac) + 15 Petals.
- OTHER: optional take of a `birch-log` for a bigger reward (row: the free stick version).
### 313-mudslide
- QUEST: Q8 beat 4.
- OTHER: cosmetic "muddy gnome" state until rain or a spring visit.
### 313-lodge
- QUEST: Q8 beat 2 (the Foreman's lunch order).
- VILLAGER: Sorrel Rushworth, dp=day; `timber-plank` once per season.
### 313-stickgate
- QUEST: Q8 beat 1.
- MINIGAME: pick the right stick, 1 of 3; win = the section's walk is 1 step shorter.
- OTHER: SECRET shared stick counter: dropped (Sights are never shared, plan 0.3); could become a private count.
### 313-tunnelmouth
- QUEST: Q8 beat 5 (straighten the Welcome sign).
- NEW ITEMS: glowcap lantern repair kit (5%).
- OTHER: the buff should be a delve buff (+1 Sense) for the next Beaverdam Tunnels run, not 60 minutes; Almanac page on first light; free "straighten the sign" option (+1 Charm).
### 313-glowtunnel
- QUEST: Q8 finale (deliver lunch).
- NEW ITEMS: glow-cap garden decor (SECRET: hush 3 times, one follows you home).
- OTHER: Sneak stance +2 to the check; Hunt stance = they all hide, nothing.

## 314 Honeybrook to Lighthouse of the Lost Lantern
### 314-driftwood
- QUEST: Q4 beat 3.
- MINIGAME: pick a shape: dragon (+1 Grit 60 min), chair (+3 energy), sofa (+1 Hardiness) (row: the sofa, en=2). SECRET sofa 3 visits running -> Almanac biography.
- OTHER: `driftwood` should need an axe.
### 314-shellpile
- VILLAGER: the `hermit-crab-hoarder` sorter (friendly); give a `spiral-shell` -> `cowrie-shell`.
- MINIGAME: pick left spiral / right spiral / "chaos" (chaos: the crab faints, gives a `tide-shell`).
### 314-steppingrocks
- QUEST: Q4 beat 4 (offer a `sardine` or `mackerel`).
- OTHER: no roll when you carry a fish (take-or-check choice). SECRET after Q4: seal pup waits at dusk with `seed-pearl` (row: 5% at dusk for everyone).
### 314-causeway
- VILLAGER: Burdock Oakenpot times the tides; tide note on your map (Almanac) + `tide-shell`.
- OTHER: waiting should take 20 game minutes; impatient cancel = wet socks, -1 energy.
### 314-lanternrocks
- QUEST: Q4 finale (hum the lantern back alight).
- VILLAGER: Keeper Marram, dp=dusk; hum with her -> lantern oil refill (lantern tool wear -1).
- NEW ITEMS: Keeper Marram (new named folk); lantern oil refill.
- OTHER: buff should last "until dark ends"; we=fog also +1 Luck (one buff slot).
### 314-gullparliament
- QUEST: Q4 beat 5.
- MINIGAME: pick the petition (more chips / less wind / free passage); the vote is random, Charm nudges it (row: charm 10 check).
- OTHER: carried = show a hidden Trail find on this section (row: find=1); denied should still drop a `gull-feather` 20% (no reward on a lose line).

## 315 Cloverholt to Den of the Great White Owl
### 315-gate
- QUEST: Q5 beat 4.
- MINIGAME: riddle (road-card riddle kind).
- OTHER: right answer = hint card about the Den boss; wrong = "Owl? Still yes." and nothing.
### 315-lamps
- VILLAGER: Wick Kettleby, se=winter dp=dusk on away days; light one together -> +2 friendship, `beeswax-candles`.
- OTHER: buff should last until you leave the route (row: 120 min).
### 315-slope
- VILLAGER: Dorrit Thistledown, se=autumn,winter dp=day; tickle a tree for her -> +2 friendship.
- OTHER: fail "fwump on you, -1 energy" has no stat in the idea, so the row has no check. `pine-log` should need an axe.
### 315-fort
- VILLAGER: Barnaby Nettlebed, se=winter; win and he says "adequate", +1 friendship.
- MINIGAME: snowball game, pick 1 of 3 throws vs the `grumpy-lemming`.
### 315-stream
- VILLAGER: Sorrel Fiddlewood on away days se=winter; lends her hole (no rod needed).
- OTHER: an ice-fishing table (row: the land's rod table + `arctic-char` 15%).
### 315-bridge
- QUEST: Q5 beat 5.
- OTHER: win = this step costs no energy (row: Grit buff only).
### 315-feather
- QUEST: Q5 beat 6.
- OTHER: preened 3 times -> the Den boss fight starts Calm (her first turn is a yawn).
### 315-cairns
- QUEST: Q5 beat 7.
- OTHER: should take ANY feather (row takes `hen-feather`); shared feather counter dropped (never shared), could be a private count with milestone rewards.
### 315-doormat
- QUEST: Q5 beat 8.
- OTHER: Charm should last until you leave the lair (row: 120 min). SECRET wipe on 3 visits -> `owl-pellet` + thank-you Almanac page.
### 315-den
- QUEST: Q5 finale (hand over the letter).
- OTHER: show the boss card, its soft spot and the Sneak option (archetype J scout); Almanac page "The Great White Owl" on first blink (row: first:xp=30).

## 316 Poppyburrow to Aurora Camp
### 316-skyhill
- VILLAGER: Fennick Hollowell, dp=night se=winter; +2 friendship, an old wish (Almanac).
- MINIGAME: at night pick 1 of 3 boons (+energy, +Luck, a seed) (row: en=2 at dusk/night, xp by day).
### 316-starstones
- QUEST: Q5 beat 1.
- NEW ITEMS: Star Chart (one Almanac page per season); title Stargazer (four seasons charted -> `frost-crystal` + title).
- MINIGAME: lay the missing stone, pick 1 of 3.
- OTHER: SECRET dp=night se=winter we=frost -> the stones point at a hidden find on route 309.
### 316-auroracamp
- VILLAGER: Lyra Fiddlewing, dp=night on her Maplewold half-days; a free song buff.
- NEW ITEMS: marshmallow (20%).
- OTHER: toast bread (`herb-flatbread`, `cornbread`, any bread) -> +4 energy (needs an any-of take); Almanac page "Toast under the Aurora" at night.
### 316-kettletree
- QUEST: Q5 beat 2 (the raven wants tea and a `shiny-quartz`).
- VILLAGER: Tobias Trundle's tea break; brew him a cup -> 10% off his seed today.
- OTHER: brew swap: `meadowsweet` -> `meadowsweet-tea`, `mint` -> `mint-tea` (needs an optional take; row: the hot-water version, en=1).

## Quest rewards and titles still missing (from the 8 lines)
- Titles: Flapjack Friend (Q2), Derby Marshal (Q7), Stargazer (starstones).
- Q4 named folk Keeper Marram; Q5 boss hint card and +5% Charm in the lair; Q8 "Beaver-approved" delve buff and build-plan discount.

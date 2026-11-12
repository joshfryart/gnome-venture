# Trail Sights: ideas for the 82 Maplewold landmarks

Status: IDEAS ONLY (2026-11-11). No code. Builds on `claude/plan-trail-sights.md` (archetypes A-J, engine, data row shape).
Scope: the 82 hand-drawn Maplewold set pieces (`claude/maplewold-trail-maps/maplewold_landmarks.json`), the first Sights players meet.
Captions come from `maplewold_trail_maps_22wide.json`; every hook below grows out of its caption, so the picture, the caption and the button tell one story.

## 0. Ground rules for this file

- **One Sight = one verb.** 82 spots, 82 different verbs (check in section 4).
- **USE tags** on every spot: **Q** = quest beat (lines in section 1), **V** = villager travel point, **G** = goodie. Every spot has at least two.
- **TEACH** = a gentle first-time lesson (shown once, as a one-line hint in the result toast). **SECRET** = for returning players, never hinted.
- Conditions use the stop-act grammar: `dp=dawn,day,dusk,night`, `se=spring,summer,autumn,winter`, `we=sun,cloud,rain,storm,frost,heat,wind,fog,snow`.
- Odds are per use, before the tool tier rule. Default cooldown 5.5 game days, 1 use, as in the plan, unless a spot says otherwise.
- Items in `code` are grep-confirmed in `game/includes/data/*.txt` (slug, or the display name for creature drops). `(new)` = does not exist yet.
- Fail is never worse than "-1 energy and a funny line". No KO, no item loss.

### Who lives here (from a fresh install: `stop_folk.php` names folk from the village slug, so every world has the same people)

| Place (stop type) | Villagers (species, personality, role) |
|---|---|
| The Maplewold Market (town) | Bramble Mossfoot (Hedgehog, Cheerful), Clover Puddlejump (Ladybird, Grumpy; gives Wren's Journey "The Sugar Shack"), Fennick Hollowell (Snail, Dreamy); all at Maple & Furrow |
| Poppyburrow (shrine) | Moss Sedgemoor (Field Mouse, Grumpy, Keeper), Dorrit Snailwick (Field Mouse, Eager, Pilgrim), Posy Thistledown (Hare, Sleepy, Bell-ringer) |
| Honeybrook (market) | Alder Pennywhistle (Ladybird, Chatty, Stallholder), Mabel Pennywhistle (Bumblebee, Dreamy, Pedlar), Clover Brambleby (Grasshopper, Chatty, Weigher) |
| Cloverholt (herb) | Nettle Cobblefield (Cricket, Chatty, Herbalist), Basil Teaspoon (Cricket, Sleepy, Beekeeper), Dorrit Thistledown (Hedgehog, Eager, Forager) |
| Acornby (workshop) | Rue Wickerby (Shrew, Dreamy, Tinker), Sorrel Rushworth (Wood Mouse, Proud, Carpenter) |
| Birchhollow (herb) | Elm Crumblewick (Beetle, Proud, Herbalist), Hazel Nettlebed (Wood Mouse, Curious, Beekeeper) |
| Mossgate (shrine) | Nettle Cobblefield (Wood Mouse, Eager, Keeper), Posy Mossgrove (Snail, Sleepy, Pilgrim) |
| Shellhollow (inn) | Bunty Brambleby (Tortoise, Warm, Innkeeper), Yarrow Mossgrove (Dragonfly, Generous, Cook), Willa Gillyflower (Frog, Dreamy, Storyteller) |
| Pebblestead (tower) | Fennel Crumblewick (Wren, Warm, Watcher), Burdock Oakenpot (Wren, Warm, Cartographer), Wick Kettleby (Snail, Chatty, Signaller) |
| Iciclecrest (spring) | Moss Windlass (Moth, Fussy, Bath-keeper), Sorrel Fiddlewood (Moth, Cheerful, Soaker) |
| Snowcombe (workshop) | Elm Wickerby (Mouse, Chatty, Tinker), Barnaby Nettlebed (Beetle, Proud, Carpenter) |
| Travellers (`npc_life.php`) | Tobias Trundle (merchant), Lyra Fiddlewing (minstrel), Wren Thimblewick (naturalist), Pomeroy Crumbworth (gourmand) |
| Landmark folk | Lighthouse keeper ("a stout gnome in a knitted cap", `na-lost-lantern`; name her **Keeper Marram (new)**), the Great White Owl (`chain-na-owl-den`), Beaver Foreman (`creatures.txt`), the Sugar Shack cook (`na-pancake-flip`) |

**The generator gave us families for free.** Shared surnames across towns: Crumblewick (Birchhollow / Pebblestead), Wickerby (Acornby / Snowcombe, both Tinkers), Nettlebed (Birchhollow / Snowcombe), Mossgrove (Shellhollow / Mossgate), Brambleby (Honeybrook / Shellhollow), Thistledown (Cloverholt / Poppyburrow), Pennywhistle (both Honeybrook). And two different villagers are both called **Nettle Cobblefield** (Cloverholt and Mossgate). The game already says an away villager is "visiting family" (`gclock_npc_away`, 25% of game days). **Design hook: on an away day a villager is not just gone, they are on the road, at a Sight between their home and their relative's.** That is the main source of villager travel points below (an "away" villager at a Sight can chat, take a gift and offer one small thing; friendship counts as normal, so it is not extra farming, just a new place to find them).

---

## 1. Quest lines (8)

Each beat is a Sight use with a quest flag; the Sight still pays its normal goodie. Lines are short (5-9 beats) and can be done in any order unless marked →.

### Q1. Bramble's Picnic List (STARTER: teaches Sights)
Giver: Bramble Mossfoot (Market). "A picnic is just a walk with snacks at the end. Here is my list!" Ticks off one teaching Sight per lesson, spread over the three Market routes so a new player meets it whichever road they take first.
1. `236-wildflowers` Sniff: what a Sight is (button appears within 3 tiles; this one is free). Opens the Almanac **Sights** chapter (first Almanac page).
2. `232-berrypatch` Pick: first gather, no tool needed.
3. `228-hedgerow` Trim: first tool use (forage tool), and what a tool tier does.
4. `232-beehive` Peek: first stat check, and that failing is safe (a bee boops you).
5. `228-scarecrow` Dress: a Sight can take an item from your Satchel.
6. `236-dandelions` Blow: cooldowns ("grows back in about 5 days").
7. → `232-picnicrise` Picnic: eat any snack here with Bramble (she turns up on a sunny day after beats 1-6), then **first villager errand**: carry the leftover `garden-honey` to Alder Pennywhistle in Honeybrook.
Reward: `walking-stick`, 60 XP, Almanac page "My first picnic", Bramble friendship +2.

### Q2. Sap to Stack (pancakes for the spring fair)
Giver: Clover Puddlejump (Market), after Wren's Journey chapter "The Sugar Shack" (`journey.php`, same Clover). "The roof is fixed. Now I need PANCAKES. Lots. Don't look at me like that." `se=spring` beats marked *.
1. `311-taprow` Tap*: 3 maple sap (new).
2. `311-bucketstacks` Stack: borrow two clean buckets (Clover Brambleby weighs them).
3. `236-windmill` Grind (`we=wind` best): 2 `wheat` → flour (new).
4. `228-haybales` Burrow: find a `hen-egg` the hens hid in the maze.
5. `311-sugarshack` Stir: sap → maple syrup (new).
6. → `311-pancakelane` Flip: the `pancakes` recipe is real (hen-egg + wheat), flip a stack in the lane while Pomeroy Crumbworth rates it in spoons.
Reward: 3 `pancakes`, 1 maple syrup (new), Clover smiles (an Almanac page titled "Clover smiled"), title Flapjack Friend (new).

### Q3. Which Nettle? (the mixed-up post)
Giver: either Nettle Cobblefield. Letters for "N. Cobblefield" keep going to the wrong one. The herbalist cricket gets candle orders; the keeper mouse gets nettle-tea orders.
1. `236-stonebridge` Bow: the polite bridge has a letter cubby; 2 mixed-up letters inside.
2. `236-beanpoles` Eavesdrop: the beans gossip which Nettle ordered what.
3. `306-mosslog` Stroke: Nettle of Mossgate waits here, a bit damp, for her post.
4. `306-mossgate` Ask: the moss suggests nicknames, "Nettle Cricket" and "Nettle Mouse".
5. → `232-crossroads` Read: you nail a fifth arrow to the signpost: "Nettles: BOTH WAYS".
Reward: friendship with both Nettles, `beeswax-candles` x2, Almanac page "Which Nettle?". After this, each Nettle sends the other a thank-you parcel once a season: a free deliver errand.

### Q4. The Lantern That Wandered Off
Giver: Keeper Marram (new) at the Lighthouse of the Lost Lantern; extends road cards `na-lost-lantern` / `chain-na-lantern-shore`. Routes 307, 308, 314 (wonder, L8).
1. `308-kelpline` Untangle: the lantern's brass hook, wound in kelp.
2. `307-tideline` Comb: flipper prints and a bit of lantern glass (`sea-glass`).
3. `314-driftwood` Imagine: the driftwood dragon is pointing north-east. Probably.
4. `314-steppingrocks` Coax: the seal pup has the lantern on its nose; offer a `sardine` (or `mackerel`, as on the road card).
5. `314-gullparliament` Petition: the gulls vote to let a gnome carrying a lantern pass. (Motion carried, 61 to 40, one abstention.)
6. → `314-lanternrocks` Hum: hum the lantern back alight.
Reward: `stone-lantern` (decor), `sea-glass` x2, Almanac page, and SECRET afterwards: the seal pup waits at `314-steppingrocks` at dusk with a gift.

### Q5. A Letter for the Den (returning players, L28 road)
Starts from road card `na-owl-letter` (or from Sorrel Fiddlewood in Iciclecrest). This is the long, walk-it-yourself version; it never starts a fight. Teaches that the boss at the end is kind and has a soft spot.
1. `316-starstones` Chart: lay the stones; they show which way is North.
2. `316-kettletree` Brew: the raven (`chain-na-owl-raven`) gives directions for tea and a `shiny-quartz`.
3. `309-auroraledge` Gaze (`dp=night`): the sky ribbon points toward the Den.
4. `315-gate` Answer: "Owl? Yes." You answer the gate's riddle.
5. `315-bridge` Test: the snow bridge holds a gnome and one letter.
6. `315-feather` Preen: smooth the giant feather; the letter's seal matches it.
7. `315-cairns` Crown: top a cairn with any feather.
8. `315-doormat` Wipe: wipe your feet. She notices.
9. → `315-den` Blink: hand over the letter. "From my cousin in the south!"
Reward: `Owl Feather`, a hint card for the Den boss (what calms it), +5% Charm in that lair for 1 game day, Almanac page.

### Q6. Wren's Woodland Census
Giver: Wren Thimblewick (naturalist), on her Maplewold days. Tansy's field guide needs Maplewold critters. Each beat = one Almanac critter page.
1. `304-owloak` Hoot (`dp=dusk,night`): the sleepy owl (`tawny-owl`, friendly here).
2. `304-hollowtrunk` Duck: the spider who says hello (`orb-spider`, friendly here).
3. `305-sunclearing` Bask (`we=sun`): the rabbit in the sun square.
4. `306-toadsteps` Climb: the toad at the top step.
5. `312-woodpecker` Duet: the woodpecker's slow song.
6. `312-larder` Barter: the squirrel who is not watching.
7. → `312-greatstump` Trace: hand in at the stump; Tansy's pin flag "Good apples" is still in one ring (`na-sketch-thousand-rings`).
Reward: an old NA seed (seed=1, uncommon tier), Wren friendship +3, a Tansy clue line for Wren's Journey.

### Q7. The Wickerby Sled Derby (winter)
Cousins Rue Wickerby (Acornby) and Elm Wickerby (Snowcombe), both Tinkers, each swear their sled is faster. Barnaby Nettlebed (Snowcombe carpenter) judges. Routes 304, 236, 310.
1. `304-acorndrop` Catch: acorn caps for runners' bearings (`acorn-cap` x4).
2. `304-oakarch` Measure: Sorrel Rushworth measures Rue's runners against the arch.
3. `236-haywagon` Feed: the sparrows give up the wagon's spare seat cushion.
4. `310-combridge` Chip: sharpen the runners on the comb ridge.
5. `310-driftpass` Zigzag: walk the course; zig, zag, zig.
6. → `310-sledtrack` Sled (`se=winter`): race day. It is a tie. It is always a tie.
Reward: `birch-log` x3, `timber-plank`, title Derby Marshal (new), friendship with both Wickerbys.

### Q8. Beaver Paperwork (Beaverdam Tunnels, delve L10)
Giver: the Beaver Foreman at `313-lodge`. "Everything is a lumber order." Feeds the real build plan rows for Beaverdam Tunnels (`build_plans.txt`: bail, rescue lodge tools, brace).
1. `313-stickgate` Unlatch: get in politely.
2. `313-lodge` Taste: try the bark stew; take the Foreman's lunch order.
3. `313-beaverdam` Patch: plug a leak with a `birch-log`.
4. `313-mudslide` Slide: fastest way to carry `river-clay` down.
5. `313-tunnelmouth` Light: light a lantern; straighten the Welcome sign.
6. → `313-glowtunnel` Hush: tiptoe in to deliver lunch to the crew.
Reward: `rope` x2, 1 build-plan stage discounted (half the `river-clay`), delve buff "Beaver-approved" (+1 Sense first 3 rooms).

---

## 2. All 82 spots

### 228 The Maplewold Market → Poppyburrow (grassland, L1, 3 sections)

**`228-haybales`** · 🌾 **Burrow** · Hay maze "that has never once fooled a goat". Burrow in for a nap: +6 energy, costs 1 game hour (TEACH: some Sights spend game time; cap 1 nap a day).
Q: Q2 beat 4. · V: Posy Thistledown (Poppyburrow bell-ringer, Sleepy) is already asleep in it on summer `dp=day`; wake her gently (charm 10) and she rings you a lullaby: +1 Hardiness 60 min. · G: `hen-egg` 20%, `hen-feather` 30%.

**`228-scarecrow`** · 🎩 **Dress** · He "looks very pleased with himself". Give him one crop or flower as a buttonhole (TEACH: Sights can take an item). He looks even more pleased; the crows notice.
Q: Q1 beat 5. · G: crows leave a `bright-feather` 35% or a `shiny-trinket` 10%; give a `carrot` and he gets a nose: guaranteed `pretty-feather`. SECRET: dress him in all four seasons → Almanac page "Mr. Pleased, a year in hats".

**`228-ford`** · 🪨 **Hop** · Stones "worn smooth by a thousand small boots". Nimble 9 (TEACH: first crossing; fail = wet socks, -1 energy, still across).
Q: Q1 (optional bonus beat for players on this road). · V: Dorrit Snailwick (Poppyburrow pilgrim) waits here at `dp=dawn` for someone to hop with; hop together = no roll and +1 friendship, and she offers an escort errand. · G: `river-clay` 25%, `minnow` 20%; `we=rain` `golden-carp` 2% (it was sheltering under stone 4).

**`228-pondmill`** · ⛵ **Sail** · A wheel "that turns for the fun of it". Fold a leaf boat and race it round the wheel race: pick 1 of 3 boats (TEACH: the pick mini-game).
V: Fennick Hollowell (Market, Dreamy snail) sails boats here at `dp=dusk` in `se=summer`; race him and he tells you which shop has a sale tomorrow. · G: winning boat brings back `meadowsweet` 40% or a `perch` 15%; SECRET: 5 wins in a row, the wheel stops for one turn to bow.

**`228-apple`** · 🍎 **Shake** · "The apples are not for you. Probably." Shake the lone tree in its ring of clover.
V: Moss Sedgemoor (Poppyburrow keeper, Grumpy) owns it and appears `se=autumn` 50% of shakes: leave a `white-clover` and he grumbles "fine, one" (+1 friendship, which he denies). · G: `apple` 45% (`se=autumn` 2 apples), `dried-apple-rings` 5% (someone left them to dry on a branch).

**`228-hedgerow`** · ✂️ **Trim** · "Trimmed by someone with strong opinions." Needs a forage tool (TEACH: first tool use; tool tier unlocks the rarer row).
Q: Q1 beat 3. · V: Clover Puddlejump is the someone, on Market rest days `dp=dawn`; trim it her way (sense 10) and she gives you 5 Petals and a sniff of approval. · G: `wild-strawberries` (`se=summer`) 35%, `meadowsweet` 30%, `ramsons` (`se=spring`) 20%; Sturdy tool: hedge-topiary clippings = `butterfly-scales` 8% `we=sun`.

### 232 The Maplewold Market → Honeybrook (grassland, L1, 3 sections)

**`232-beehive`** · 🐝 **Peek** · "A no-visitors sign they can't spell." Peek under the lid: Sense 9 (TEACH: first stat check; fail = a bee boops your nose, -1 energy, "they are very sorry").
Q: Q1 beat 4. · V: Mabel Pennywhistle (Honeybrook pedlar, a Bumblebee) visits "my cousins" `we=sun` `se=spring,summer`; with her there, no roll, and she fixes the sign's spelling for an Almanac giggle; bring her `meadowsweet` → `beeswax`. · G: `garden-honey` 30%, `wild-honeycomb` 6%.

**`232-berrypatch`** · 🫐 **Pick** · "Mostly eaten already by someone small." No tool (TEACH: first gather; everything you pick goes to the Satchel).
Q: Q1 beat 2. · V: Alder Pennywhistle (Honeybrook stallholder) buys berries here `dp=dawn`; pick 3 and he swaps you a punnet for 8 Petals. · G: `raspberry` 40%, `blueberry` 30%, `wild-strawberries` `se=summer` 25%. SECRET: pick at `dp=dawn` and leave one berry; next visit the someone small (a field-mouse child) has left a `ladybird-charm` 15%.

**`232-logbridge`** · 🤝 **Share** · "Wide enough for two gnomes who like each other." Cross with a pal or villager beside you for friendship; alone it is a Balance 8 check.
V: Clover Brambleby (Honeybrook weigher) on away days, walking to cousin Bunty Brambleby in Shellhollow; cross together = +2 friendship (counts as the day's chat) and she gives you a parcel for Bunty (deliver errand). · G: alone and win: `chanterelle` from the log's moss `we=rain` 25%, `birch-log` (axe) 15%.

**`232-well`** · 🚪 **Knock** · "Knock, and something polite knocks back." Knock a pattern (pick 1 of 3 rhythms); the well answers.
G: right rhythm: `frogspawn` (`se=spring`) 25%, a dipper of cold water (+3 energy) 40%. SECRET: knock three times at `dp=night` → the polite something is a frog called Mister Plink (new) who lends you a `Singing Pebble` (trek item) for 1 game day: +1 Charm while you carry it. · Q: Q3 alternative letter drop (the well also gets misdelivered post).

**`232-crossroads`** · 🪧 **Read** · "Four arrows, all of them pointing at lunch." Free (0 energy). Read the signpost: where each traveller is today (Tobias, Lyra, Wren, Pomeroy) and which Maplewold villagers are away (TEACH: villagers move about; away days).
Q: Q3 finale (the fifth arrow). · V: Tobias Trundle sets up his shell-shop here on his Maplewold half-days (buy his seed without going into town). · G: first read: Almanac page "The Lunch Signpost" + 10 XP.

**`232-picnicrise`** · 🧺 **Picnic** · "A flat spot that is clearly for sitting on." Eat one snack from your Satchel here: its buff lasts twice as long (TEACH: food buffs).
Q: Q1 finale, first villager errand. · V: Bramble Mossfoot picnics here `we=sun` `dp=day` (the Market's slow afternoons); share food = +2 friendship. · G: picnic crumbs bring a `ladybird-charm` 5%; `se=summer` `dp=dusk` a `cricket-chirp` 20%.

### 236 The Maplewold Market → Cloverholt (grassland, L1, 3 sections)

**`236-wildflowers`** · 🌸 **Sniff** · Flowers "all nodding hello". Free, 0 energy, no cooldown for the lore (TEACH: the very first Sight; opens the Almanac Sights chapter).
Q: Q1 beat 1. · V: Basil Teaspoon (Cloverholt beekeeper, Sleepy) dozes here on `se=summer` afternoons; nudge him and he says which flower his bees want this week (that flower grows 10% faster in your garden for 1 game day). · G: a cut flower by season (1/use): `lupine` spring, `milkweed` summer, `goldenrod` autumn, 25%.

**`236-dandelions`** · 🌬️ **Blow** · "Sneeze, and make a hundred wishes at once." Blow a clock; the seeds scatter (TEACH: cooldown; "the clocks grow back in about 5 days").
Q: Q1 beat 6. · G: a random flower seed (seed=1) 30%; `we=wind` the seeds fly far: +1 Trail find on the next section 50%. SECRET: blow on your gnome's birthday → "a hundred wishes" Almanac page and +1 Luck all day.

**`236-stonebridge`** · 🙇 **Bow** · "The bridge insists." It is a very proper bridge: bow (Charm 9) and it lets you look in its letter cubby.
Q: Q3 beat 1. · G: lost post: a sealed letter to deliver for 10 Petals 40%; a forgotten `herb-flatbread` 10%; fail: "The bridge pretends not to see you." SECRET: bow 10 times over many visits → the bridge tells you its name (Almanac page "Sir Trickle").

**`236-beanpoles`** · 👂 **Eavesdrop** · "Every bean is talking about the weather." Listen in: shows **tomorrow's weather** for the Maplewold (unique: the only forecast Sight).
Q: Q3 beat 2. · V: Dorrit Thistledown (Cloverholt forager) on away days, heading to cousin Posy in Poppyburrow, stops to argue with the beans; she gives a fetch errand for 3 `wheat`. · G: `green bean` pods (new) 30%; `we=rain` the beans are too busy complaining: +1 Sense 30 min.

**`236-windmill`** · ⚙️ **Grind** · "Sails going round, grinding nothing at all." Give it something to grind: 2 `wheat` → flour (new). `we=wind`: double. No wind: it grinds slowly (costs 30 game minutes).
Q: Q2 beat 3. · V: Barnaby Nettlebed (Snowcombe carpenter, Proud) mends the sails on `we=wind` days, visiting brother-of-a-cousin Hazel; help hold a sail (Grit 10) → a `timber-plank`. · G: windmill mice give a sack of chaff = `plain-compost` 30%.

**`236-haywagon`** · 🐦 **Feed** · "A family of sparrows in the driving seat." Scatter any seed for them; they "drive" for a bit and chirp road gossip.
Q: Q7 beat 3. · V: Pomeroy Crumbworth (gourmand) on festival days lunches on the wagon tailboard; serve him a Maplewold dish and he rates it here (same spoons as his page). · G: `pretty-feather` 30%, `hen-feather` 20%; SECRET: feed them 5 visits running → they move over and you may sit in the driving seat: Almanac page "Sparrow & Sons, Hauliers".

### 304 Poppyburrow → Acornby (forest, L1, 2 sections)

**`304-oakarch`** · 📏 **Measure** · "Like a doorway someone grew on purpose." Stand under it and mark your height on the root (Almanac keeps every mark, dated by game day).
Q: Q7 beat 2. · V: Sorrel Rushworth (Acornby carpenter, Proud) measures it `dp=day` for "a proper door, at last"; help hold the tape → he gives an `oak-log` once per season. · G: `oak-gall` 25%, `acorn-cap` 20%.

**`304-hollowtrunk`** · 🕷️ **Duck** · "Don't mind a spider's hello." Duck through: the spider says hello (it is a big `orb-spider`, polite here, never a fight).
Q: Q6 beat 2. · G: a strand of `Glow Silk` (part) `dp=dusk,night` 15%; `stag-beetle-shell` 15%; SECRET: say hello back 3 times over 3 visits → the spider knits a tiny hammock: +energy on your next Burrow/Nestle/Bask.

**`304-acorndrop`** · 🌰 **Catch** · "Wear a hat, or don't, they're only small." Catch acorns in your hat: Nimble power game (5 taps).
Q: Q7 beat 1. · G: `acorn-cap` x1-4 by score, `se=autumn` doubled; a `hazelnut` 10%; fail: "Bonk. They're only small."

**`304-owloak`** · 🦉 **Hoot** · "Someone inside is saying 'hoo' in a sleepy way." Hoot back. `dp=day`: a sleepy grumble. `dp=dusk,night`: a proper answer.
Q: Q6 beat 1. · V: Wren Thimblewick sketches here `dp=dusk` on her Maplewold days; hoot well and she swaps a seed for any forage (her normal deal, at this spot). · G: `dp=dusk,night` `Owl Feather` 20%, `Owl Pellet` 10% ("a very tidy compliment").

### 305 Honeybrook → Birchhollow (forest, L1, 2 sections)

**`305-birchtunnel`** · 🤫 **Whisper** · "Like friends sharing one big secret." Whisper in; a rumour whispers back: names a section of a Maplewold route where a Trail find is rarer today.
V: Elm Crumblewick (Birchhollow herbalist, Proud) on away days, heading to cousin Fennel in Pebblestead; whispers his herb tip (+20% `chanterelle` on your next forage) · G: rumour 100% (that is the goodie), `birch-log` (axe) 20%. `we=fog`: the trees whisper louder: two rumours.

**`305-birchcurtain`** · 🔢 **Count** · "A crowd that has forgotten why it came." Count the trunks (pick the number 1 of 3).
G: right count: `birch-log` 30%, `pine-resin` 15%. SECRET: `we=fog` there is always one trunk too many; count it and the extra trunk is Fennel Crumblewick in a grey coat, birdwatching (V: Pebblestead watcher, visiting Elm); she shows you a `bright-feather` 50%.

**`305-fernhollow`** · 🌿 **Nestle** · "A small snail has the best seat." Ask the snail to budge (Charm 9), then nestle: +4 energy, +1 Sense 30 min (a calm nap, no game hours).
V: the snail is Posy Mossgrove (Mossgate pilgrim, Sleepy) on her slow pilgrimage `se=spring,summer`; she shares the seat, +1 friendship, and gives a `snail-trail-glaze` 20%. · G: `fiddleheads` `se=spring` 35%, `sphagnum` 20%.

**`305-sunclearing`** · ☀️ **Bask** · "The sun lands in a square, and a rabbit is sitting in it." Only `we=sun` (else: "the square is having a day off"). Bask with the rabbit: +1 Hardiness 60 min.
Q: Q6 beat 3. · V: Hazel Nettlebed (Birchhollow beekeeper, Curious) notes the rabbit every sunny `dp=day`; tell her what you saw → she gives `beeswax` once a week. · G: the rabbit nudges a `white-clover` your way 25%; four-leaf find (new, "Four-Leaf Clover") 1%.

### 306 Cloverholt → Mossgate (forest, L1, 2 sections)

**`306-mosslog`** · 🟢 **Stroke** · "You wouldn't call it a bridge. It would." Stroke the moss; it purrs (the log is pleased to be called a bridge).
Q: Q3 beat 3. · V: Nettle Cobblefield of Mossgate (Keeper, Eager) waits here for the post `dp=dawn` (damp, cheerful). · G: `Living Moss` (part) 20%, `chanterelle` `we=rain` 30%; say "nice bridge" (free option) → +1 Charm 30 min.

**`306-dripgrotto`** · 🎵 **Tune** · "The drips keep time, more or less." Tap pebbles along with the drips: rhythm power game.
V: Rue Wickerby (Acornby tinker, Dreamy) is building a drip-clock here; good rhythm → he gives you a part he no longer needs: `Glowing Bead` 30%. · G: `river-clay` 25%; SECRET: `we=rain` the drips play a whole tune; Lyra Fiddlewing (if in the Maplewold) teaches it to you: Almanac page "Grotto Waltz", +1 Luck all day.

**`306-mossgate`** · 🗝️ **Ask** · "Two mossy gateposts and no gate. The moss says that's on purpose." Ask permission to pass; the moss always says yes, and something else.
Q: Q3 beat 4. · V: Nettle Cobblefield of Mossgate tends it after her shrine shift `dp=dusk`; ask together → shrine blessing: +1 Luck until you sleep. · G: a moss-blessed `Mossy Shell` 15%; once per season, the moss gives you an old pressed `trillium` flower.

**`306-toadsteps`** · 🍄 **Climb** · "Like stepping stones up a green stair." Climb (Nimble 9): from the top you see the next section: its Trail finds show on the map until you leave (unique: the scout Sight).
Q: Q6 beat 4 (the toad on the top step). · G: `Toad Slime` (part, "pleasantly springy") 10%, `chanterelle` 20%; fail: you slide down three soft caps, "boing".

### 307 Poppyburrow → Shellhollow (coast, L1, 2 sections)

**`307-tideline`** · 🐚 **Comb** · "The tide has gone out and left its homework." Beachcomb the line. `dp=dawn` the tide has left the most.
Q: Q4 beat 2. · G: `spiral-shell` 40%, `sea-glass` 15%, `cowrie-shell` 8%; `we=storm` after a storm: `driftwood` and `bladderwrack` 30% each. SECRET: a message bottle (new) 1%: "hello" from a real other player's note (the bottle-post idea, phase 4).

**`307-barnacles`** · 😁 **Grin** · "Barnacles, which all look like they're smiling." Grin back (Charm 8). They are delighted.
V: Yarrow Mossgrove (Shellhollow cook, Generous) picks mussels here `dp=dawn` and shares: a bowl of `fishermans-stew` once a week, on her way to cousin Posy in Mossgate. · G: `blue-mussels` 30%, +1 Charm 60 min on a win (barnacle grins are catching).

**`307-shellhollow`** · 📣 **Echo** · "Echoes if you say 'hello'." Say something; the echo says something funnier back (a short pool of lines).
V: Willa Gillyflower (Shellhollow storyteller, Dreamy frog) collects echoes `dp=dusk`; give her one and she tells you a five-part tale, one part per visit (Almanac page when complete). · G: `tide-shell` 20%; SECRET: say "Willa" at `dp=night` → the hollow echoes back the location of a rare find on route 314.

**`307-sandcastle`** · 🏰 **Salute** · "Six towers, one flag, and a crab in charge." Salute the crab captain; it inspects you.
V: Bunty Brambleby (Shellhollow innkeeper, Warm) builds castles with inn guests `se=summer` `dp=day`; help add a seventh tower → she pays a room discount voucher (10% off one inn rest). · G: the crab issues you a `tide-shell` 25% and a "Sandcastle Corporal" Almanac rank that goes up one per salute (5 ranks, then `Crab Claw` (part) as a medal, freely given).

### 308 Honeybrook → Pebblestead (coast, L1, 2 sections)

**`308-pebblebar`** · 🪨 **Skim** · "Pebbles in every colour, all lovely to hold." Skim one: power game, count the skips.
V: Fennel Crumblewick (Pebblestead watcher, Warm) keeps the skip record `dp=dusk`; beat it (7+) → she gives `sea-glass` and writes your name on the record stone (Almanac). · G: a pretty pebble to keep: `flint` 30%, `Singing Pebble` (trek item) 2%.

**`308-kelpline`** · 🌿 **Untangle** · "To be admired and politely not eaten." Something is tangled in it: free it (Nimble 9). It is usually a very relieved shrimp.
Q: Q4 beat 1. · G: `kelp-frond` 40%, `bladderwrack` `we=storm,wind` 30%, `urchin-test` 8%. Fail: you are now also tangled; the shrimp untangles you.

**`308-rockpool`** · 👋 **Wave** · "A crab inside who waves one claw. Wave back." Wave; the crab keeps count of how many times you have waved.
V: Wick Kettleby (Pebblestead signaller, Chatty) teaches the crab signal flags here `dp=day`; wave in signals → +1 friendship and a flag lesson (Almanac). · G: `sea-salt` 25%; every 5th wave over your visits the crab hands you a `seed-pearl` (it was saving it).

**`308-tidesteps`** · 🔍 **Peer** · "Each holding a pool the size of a teacup." Peer into one teacup (pick 1 of 3).
V: Burdock Oakenpot (Pebblestead cartographer, Warm) maps every teacup pool `dp=dawn`; peer with him → he gives a map scrap (new) that marks 1 Trail find on 314. · G: per cup: `samphire` 30%, `urchin-test` 15%, `sardine` 20%; "a very small fish, very cross" 35%.

### 309 Cloverholt → Iciclecrest (tundra, L1, 2 sections)

**`309-frozenpond`** · ⛸️ **Skate** · "Polished like a plate. Gnomes walk round it. Mostly." `se=winter` skate a figure (Nimble 10); other seasons it's a pond and the button says "Paddle".
V: Sorrel Fiddlewood (Iciclecrest soaker, Cheerful) skates here between hot soaks `se=winter` `dp=day`; skate with her → +2 friendship and a warm-up: +1 Nimble 60 min. · G: win: `arctic-char` seen under the ice (Almanac) + `Frost Crystal` 5%; fail: sit-down slide, -1 energy, "graceful, in its way".

**`309-snowmen`** · 🥕 **Judge** · "Each with a different, very serious carrot." Judge the gallery: pick the best snowman. There is no wrong answer; each one has a fan.
Q: Q5 (optional; the snowmen all point north). · G: the winner's builder sends a thank-you: `carrot` 40%, `hot-cocoa` 8%. SECRET: one snowman has no carrot; give it a `carrot` → next visit it has a scarf (new) and leaves you `Lemming Fluff` x2 "for warmth".

**`309-icecave`** · 🧊 **Shelter** · "A very cold, very polite smile." Only `we=snow,storm,frost` (else "the cave is lovely but you're fine"). Shelter: no energy cost for the next 3 steps of the walk.
V: Moss Windlass (Iciclecrest bath-keeper, Fussy) keeps the spring's bath salts cool here; shelter with her and she sells `sea-salt` x2 for 6 Petals and fusses your scarf straight (+1 Hardiness 60 min). · G: `Frost Crystal` 10%, `fossil-shell` (pick) 3%.

**`309-auroraledge`** · 🌌 **Gaze** · "Clear ice where the sky shows through, pink and green." `dp=night`: gaze up through it: +1 Luck until sleep. `dp=day`: your reflection, slightly greener.
Q: Q5 beat 3. · G: Almanac page "The Aurora" (first night use), `snow-moth-dust` `se=winter` `dp=night` 25%; SECRET: `dp=night` `we=frost` a falling glint = `Frost Crystal` 15%.

### 310 Poppyburrow → Snowcombe (tundra, L1, 2 sections)

**`310-driftpass`** · ↯ **Zigzag** · "Take the zig, then the zag, then the zig." Pick the right order of 3 turns: win = a shortcut, this section's walk costs 10 game minutes less.
Q: Q7 beat 5. · G: `cottongrass` 30%, `crowberries` `se=autumn` 25%; wrong order: you arrive where you started, slightly snowier.

**`310-sledtrack`** · 🛷 **Sled** · "Worn smooth by small cheerful gnomes, and one lost mitten." Whee: power game for distance.
Q: Q7 finale. · V: Elm Wickerby (Snowcombe tinker, Chatty) tests sleds here `se=winter` `dp=day`; a good run → he gives a sled-runner `birch-log`. · G: the lost mitten (new) 1 per player: return it to Posy Thistledown in Poppyburrow (it's hers) → +3 friendship, she rings the bell for you. `snow-moth-dust` 10%.

**`310-combridge`** · ⛏️ **Chip** · "All its teeth pointing politely down." Chip a little ice and stone from the ridge: needs a pick tool.
Q: Q7 beat 4. · G: `flint` 35%, `fossil-shell` (Sturdy+ pick) 6%, `Frost Crystal` (Fine pick) 4%; the ridge says "ow, politely" on a fail.

**`310-icicurtain`** · 🎐 **Ring** · "Icicles that chime when you pass. Please don't lick them." Ring a tune (pick 3 icicles); a nice tune = +1 Charm 60 min.
V: Hazel Nettlebed (Birchhollow) on away days in `se=winter`, visiting Barnaby Nettlebed in Snowcombe; she hums along and gives `beeswax` for the cold lips. · G: `Frost Crystal` 8%. SECRET: there is a hidden 4th button, "Lick". Tongue stuck. -1 energy. Almanac page "Told You".

### 311 Honeybrook → The Sugar Shack (grassland, haven, L1, 2 sections)

**`311-taprow`** · 🍁 **Tap** · "Each with a little bucket. Drip, drip, drip." `!se=spring` (other seasons: "the maples are resting"). Collect a bucket of sap.
Q: Q2 beat 1. · G: maple sap (new) 60%; a red-maple leaf for the Road Journal (sketch page) 10%; ties to road card `na-sap-bucket`.

**`311-bucketstacks`** · 🪣 **Stack** · "Waiting for the sap to get its act together." Stack buckets tall: power game, how high before wobble.
Q: Q2 beat 2. · V: Clover Brambleby (Honeybrook weigher, Chatty) weighs buckets for the Sugar Shack `se=spring` `dp=dawn`; she pays 1 Petal per bucket level of your stack (max 12). · G: tall stack: a spare tin bucket loaned = +1 bucket-tool gather on the next coast route (new, borrow flag).

**`311-sugarshack`** · 🥄 **Stir** · "A chimney that smells of pancakes." Stir the big syrup pan for the cook: swap 3 maple sap (new) → 1 maple syrup (new); or just stir: 10 XP and a sticky spoon.
Q: Q2 beat 5. · V: Clover Puddlejump visits the mended shack she rebuilt (Wren's Journey) `se=spring` `dp=day`; stir with her → +2 friendship, and she is very nearly cheerful. · G: a lick of syrup: +2 energy 100%; toffee (new) `se=winter` 20%.

**`311-pancakelane`** · 🥞 **Flip** · "Smells so strongly of pancakes it is hard to walk straight." Flip one (Nimble 10; road card `na-pancake-flip` style).
Q: Q2 finale. · V: Pomeroy Crumbworth (gourmand) rates flips here on festival days; a high flip earns "four spoons" and an invite to serve him a course. · G: `pancakes` 30% (caught it!), 70% "on your head, which is also nice"; `custard-tart` 3%.

### 312 Cloverholt → Thousand Rings Stump (forest, wonder, L8, 3 sections)

**`312-ringlog`** · ⏳ **Guess** · "Count them. Then lose count. Start again." Guess the log's age (pick 1 of 3); right = Lore XP and a streak.
V: Dorrit Thistledown (Cloverholt forager, Eager) counts rings here `dp=day` while waiting for mushrooms; tie with her guess → she shares her basket: `chanterelle` x2. · G: `oak-log` (axe) 20%, `heartwood` (Fine axe) 2%.

**`312-woodpecker`** · 🥁 **Duet** · "Knocking out a very slow song." Tap a reply on the next tree (rhythm).
Q: Q6 beat 5. · G: good duet: `stag-beetle-shell` 25%, `oak-gall` 25%; SECRET: 3 good duets in one season → the woodpecker teaches you a beat that makes your next `Tune` or `Ring` Sight win without a roll, once.

**`312-toadring`** · 🍄 **Twirl** · "Step inside and you feel exactly one inch taller." Twirl in the ring: +1 to every stat for 10 game minutes ("one inch").
V: Dorrit Snailwick (Poppyburrow pilgrim) visits the ring each `se=autumn` `dp=dusk`; twirl together → +2 friendship and she gives a `Toad Jewel` (part) once. · G: `chanterelle` 20%; SECRET: `dp=dusk` `we=fog` you feel TWO inches taller: Almanac page "Two Inches".

**`312-bramble`** · 🍇 **Pluck** · "The berries are right there. You may have one." Pluck exactly one. The Sight then offers "one more?": say no.
V: Nettle Cobblefield of Cloverholt (herbalist) gathers bramble leaves for tea `se=summer` `dp=dawn`; she watches, approves of your manners, +1 friendship. · G: honest (one only): `wild-berry-jam` jar left on a stump next visit 30%, `raspberry` 100%. Greedy: a bramble snag, -1 energy, "fair".

**`312-greatstump`** · 🔍 **Trace** · "Rings go back before your grandmother's grandmother." Trace one ring back with your finger: a little history line and Lore XP (the wonder's own Lore theme).
Q: Q6 finale. · G: old seed (seed=1, uncommon) 10%, `acorn-cap` 30%; first trace: Almanac page; links to road card `na-sketch-thousand-rings`.

**`312-larder`** · 🐿️ **Barter** · "The squirrel will pretend not to watch." Leave a nut (`hazelnut`, `walnut` or `chestnut`); the squirrel "accidentally" leaves something better.
Q: Q6 beat 6. · G: `candied-chestnuts` 15%, `acorn-cap` x3 50%, `shiny-trinket` 10% (it has a collection); no nut: a single acorn cap and a stare.

### 313 Poppyburrow → Beaverdam Tunnels (forest, delve, L10, 3 sections)

**`313-beaverdam`** · 🦫 **Patch** · "Tidy as a drawer." Plug a leak with a `birch-log` (or a stick for free: smaller reward).
Q: Q8 beat 3. · V: the Beaver Foreman (`creatures.txt`, friendly at the dam) inspects your patch `dp=day`; a good patch → "Hired!" (Almanac) and 15 Petals. · G: `river-clay` 30%, `minnow` 15%.

**`313-mudslide`** · 🛝 **Slide** · "Shiny as a plum, where somebody has clearly been sliding for fun." Slide down. You are now muddy (cosmetic, "muddy gnome" until rain or a spring visit).
Q: Q8 beat 4. · G: `river-clay` 50%, `perch` at the bottom pool 15%; +1 Nimble 60 min ("you're slippery").

**`313-lodge`** · 🥣 **Taste** · "Someone is cooking in there. Smells like bark stew." Taste a spoon (Hardiness 9): warm buff +1 Grit 60 min, or "it's very... barky".
Q: Q8 beat 2 (the Foreman's lunch order). · V: Sorrel Rushworth (Acornby carpenter) visits to admire beaver joinery `dp=day`; tasting with him → he gives a `timber-plank` once per season. · G: a bowl to go: `garden-vegetable-soup` 10%.

**`313-stickgate`** · 🪵 **Unlatch** · "A latch made of a smaller stick." Find the right stick to lift (pick 1 of 3): opens a side gap, the section's walk is 1 step shorter.
Q: Q8 beat 1. · G: spare sticks: `birch-log` 20%; SECRET: add your own stick (free) → a shared counter on the gate ("this gate has 1,204 sticks"); at each 100, everyone who added one gets a beaver thank-you: 20 Petals.

**`313-tunnelmouth`** · 🏮 **Light** · "A tiny 'Welcome' sign, hung slightly crooked." Needs a lantern (`tin-lantern` or better): light it here = delve buff (+1 Sense) for the next Beaverdam Tunnels run (archetype J).
Q: Q8 beat 5 (also straighten the sign: free option, +1 Charm "tidy"). · G: first light: Almanac page; `glowcap-lantern` repair kit (new) 5%.

**`313-glowtunnel`** · 🍄 **Hush** · "They are shy, but not unfriendly." Tiptoe (Sense 10, Sneak stance +2): the glow-caps brighten for you.
Q: Q8 finale. · G: win: `Glowing Bead` 25%, `firefly-glow` 10%; Hunt stance: they all hide, "rude", nothing. SECRET: hush 3 times → one glow-cap follows you home: a garden glow decor (new).

### 314 Honeybrook → Lighthouse of the Lost Lantern (coast, wonder, L8, 3 sections)

**`314-driftwood`** · 🐉 **Imagine** · "A dragon, a chair, a very tired sofa." Pick a shape to imagine: dragon (+1 Grit 60 min), chair (+3 energy), sofa (+1 Hardiness; it's just comfy).
Q: Q4 beat 3. · G: `driftwood` (axe) 35%, `bladderwrack` 15%; SECRET: imagine the sofa 3 visits running → Almanac page "The Very Tired Sofa, a biography".

**`314-shellpile`** · 🌀 **Sort** · "Sorted by someone with very strong feelings about spirals." Sort a handful the sorter's way (pick: left spiral / right spiral / "chaos").
V: the sorter is a `hermit-crab-hoarder` (friendly here, never a fight) who wants a fourth shell; give it a `spiral-shell` → `cowrie-shell` back. · G: `spiral-shell` 40%, `cowrie-shell` 10%; "chaos": the crab faints dramatically, gets up, gives you a `tide-shell` to make you stop.

**`314-steppingrocks`** · 🦭 **Coax** · "The sea sloshing happily underneath." A seal pup lives here; coax it over (Charm 10, or no roll with a fish).
Q: Q4 beat 4. · G: the pup brings you a `sardine` 30% or a `Sea Glass` 15%; SECRET after Q4: `dp=dusk`, it waits with a `seed-pearl` 5%.

**`314-causeway`** · 🌊 **Wait** · "Nobody has fallen in. Nobody who'll admit it." Wait for the tide (spends 20 game minutes): best at `dp=dawn,dusk`.
V: Burdock Oakenpot (Pebblestead cartographer) times the tides here; wait with him → he marks the exact best time on your map (Almanac tide note) and gives a `tide-shell`. · G: `blue-mussels` 30%, `samphire` 20%; impatient (cancel): wet socks, -1 energy.

**`314-lanternrocks`** · 🎶 **Hum** · "Lit by something that sounds like humming." Hum along (Charm 9): the lanterns brighten: +1 Sense until dark ends.
Q: Q4 finale. · V: Keeper Marram (new) hums here `dp=dusk`; hum with her → she gives an oil refill (lantern tool wear -1, new). · G: `Glowing Bead` 10%; `we=fog` the lanterns hum back louder: +1 Luck too.

**`314-gullparliament`** · 📜 **Petition** · "A hundred gulls in rows, mid-way through a very important meeting." Submit a petition (pick: more chips / less wind / free passage). They vote (random, Charm nudges it).
Q: Q4 beat 5. · G: motion carried: `Gull Feather` 40% + the gulls show a hidden Trail find on this section; denied: "Order! Order!" and a `Gull Feather` dropped in protest 20%. Uses `herring-gull` as friendly here.

### 315 Cloverholt → Den of the Great White Owl (tundra, lair, L28, 5 sections)

**`315-gate`** · ❓ **Answer** · Sign: "Owl? Yes." The gate asks a riddle (the road-card riddle kind); answer right: a hint card about the Den boss (archetype J, but earned).
Q: Q5 beat 4. · G: right answer: `snow-moth-dust` 20% + 10 Lore XP; wrong: the sign just says "Owl? Still yes."

**`315-lamps`** · 🔥 **Warm** · "Each with a warm yellow bulb and one snowflake on its hat." Warm your hands: +1 Hardiness until you leave the route (stacks with nothing else).
V: Wick Kettleby (Pebblestead signaller) lights the lamps `se=winter` `dp=dusk` on his away days ("visiting the Owl, she's practically family"); light one with him → +2 friendship, he gives `beeswax-candles`. · G: catch the snowflake off a lamp's hat: `snow-moth-dust` 15%.

**`315-slope`** · 🌲 **Tickle** · "The snow slides off their shoulders with a soft 'fwump'." Tickle a pine: fwump. Underneath: something.
V: Dorrit Thistledown (Cloverholt forager) gathers resin here `se=autumn,winter` `dp=day`; tickle a tree for her (fwump on her, she laughs) → +2 friendship. · G: `pine-resin` 35%, `pine-log` (axe) 20%; fail: fwump on you, -1 energy.

**`315-fort`** · ⚪ **Lob** · "Walls knee-high, built by someone very serious about it." A snowball game (pick 1 of 3 throws) against the serious builder, a `grumpy-lemming` (friendly here, still grumpy).
V: Barnaby Nettlebed (Snowcombe carpenter, Proud) inspects the fort's joinery `se=winter`; win the lob and he admits it is "adequate" (+1 friendship). · G: win: `Lemming Fluff` x2 (it throws them in surrender), +1 Grit 60 min.

**`315-stream`** · 🎣 **Ice-fish** · "A stream gone to glass." Archetype E: rod path, ice-fishing table, 1 per day, shares rod wear.
V: Sorrel Fiddlewood (Iciclecrest) ice-fishes here on away days `se=winter`; she lends you her hole (no rod needed, Worn tier). · G: `arctic-char` 30%, `trout` 15%, `Frost Crystal` caught on the line 3%.

**`315-bridge`** · 🧱 **Test** · "Sturdier than it looks." Tap-test it (Sense 11): win = cross at a jog (no energy for this step) and a bit of confidence (+1 Grit 30 min).
Q: Q5 beat 5. · G: `Snowy Plume` drifted into the blue-shadow ditch 8%; fail: "it holds; you just squeaked".

**`315-feather`** · 🪶 **Preen** · "A single white feather the size of a gnome, standing like a flag." Smooth it (gently). It glows a little.
Q: Q5 beat 6. · G: `Snowy Plume` 10%, `Owl Feather` 20%; preened 3 times over visits = the owl starts the boss fight Calm (her first turn is a yawn, see Den boss notes).

**`315-cairns`** · 👑 **Crown** · "Each topped with a feather. Someone has been very patient." Crown a bare cairn with any feather you carry (`hen-feather`, `bright-feather`, `Gull Feather`...).
Q: Q5 beat 7. · G: a shared counter (archetype I): "this cairn line has 3,112 feathers"; your first crown pays 20 XP; at each 500 world-wide, everyone who added one gets `Owl Feather`.

**`315-doormat`** · 🧹 **Wipe** · "A doormat made of moss, and a very big, very soft 'hoo'." Wipe your feet. That's it. That's the Sight.
Q: Q5 beat 8. · G: manners: +1 Charm until you leave the lair; SECRET: wipe on 3 separate visits → the owl leaves a tidy `Owl Pellet` on the mat "as a compliment" and a thank-you Almanac page.

**`315-den`** · 👀 **Blink** · "Two big kind eyes inside, blinking slowly." Blink slowly back (archetype J scout): shows the boss card, its soft spot and the Sneak option; never starts the fight.
Q: Q5 finale. · G: first blink: Almanac page "The Great White Owl" + 30 XP; `Snowy Plume` 5% (she sheds when happy).

### 316 Poppyburrow → Aurora Camp (tundra, haven, L1, 2 sections)

**`316-skyhill`** · 🌠 **Wish** · "Perfect for lying down and counting nothing in particular." `dp=night`: wait for a shooting star and wish (pick 1 of 3 small boons: +energy, +Luck, a seed). `dp=day`: cloud shapes, 10 XP.
V: Fennick Hollowell (Market, Dreamy) lies here `dp=night` `se=winter` "counting nothing"; wish with him → +2 friendship, he tells you a wish he made years ago (Almanac). · G: the boon itself; `cottongrass` 25%.

**`316-starstones`** · 🗺️ **Chart** · "Flat stones laid in the shape of the sky." Lay the missing stone (pick 1 of 3): tonight's star chart page (new item "Star Chart", an Almanac page per season).
Q: Q5 beat 1. · G: four seasons charted → `Frost Crystal` + title Stargazer (new); SECRET: `dp=night` `se=winter` `we=frost` the stones point at a hidden find on route 309.

**`316-auroracamp`** · 🔥 **Toast** · "Tents, a banked fire and a kettle, with green lights doing slow dances overhead." Toast something on the banked fire: bread (any bread/flatbread: `herb-flatbread`, `cornbread`) → +4 energy; or toast your toes (free): +2 energy.
V: Lyra Fiddlewing (minstrel) plays here `dp=night` on her Maplewold half-days; toast with her → a free song (her paid song buff, here once per visit). · G: a marshmallow (new) 20%; `dp=night` Almanac page "Toast under the Aurora".

**`316-kettletree`** · ☕ **Brew** · "A tree hung with kettles and mugs, clinking." Pick a mug, brew: swap `meadowsweet` → `meadowsweet-tea`, or mint → `mint-tea`; nothing to brew → hot water: +1 energy.
Q: Q5 beat 2 (the raven wants tea and a `shiny-quartz`). · V: Tobias Trundle (merchant) takes his tea break here on Maplewold days; brew him a cup → 10% off his seed today. · G: `crowberry-cordial` (a mug someone left full) 5%.

---

## 3. Notes for the build

- **New items needed (all optional, each can fall back to a confirmed item):** maple sap, maple syrup, flour, green bean pods, toffee, marshmallow, lost mitten, map scrap, Star Chart, message bottle, Four-Leaf Clover (exists as `four-leaf-clover` in the items table but not in a data .txt; check), scarf, glowcap repair kit, glow-cap decor, Mister Plink and Keeper Marram (names). Titles: Flapjack Friend, Derby Marshal, Stargazer.
- **Mechanics this file assumes beyond the plan:** away villagers found at a Sight (V tags; reuse `gclock_npc_away` + the existing chat/gift actions); a "forecast" output (`236-beanpoles`); a "scout" output that reveals Trail finds (`306-toadsteps`, `314-gullparliament`, `308-tidesteps`); per-player counters over visits (`308-rockpool`, `307-sandcastle`, `236-stonebridge`); a hidden button (`310-icicurtain`); cosmetic state (muddy gnome).
- **Teaching order** (Q1 + TEACH tags): Sniff (Sight + Almanac) → Pick (gather) → Trim (tool) → Peek (stat check, safe fail) → Dress (give item) → Hop (crossing) → Burrow (game time) → Blow (cooldown) → Picnic (food buff + first errand) → Read (villagers move about) → Eavesdrop (weather matters) → Sail (pick mini-game).
- **Villagers given a travel point:** all 25 stop folk + 3 Market folk + 4 travellers + keeper + owl + Beaver Foreman. Two Nettles get separate spots.

---

## 4. Uniqueness check

Every verb, once (82):

| # | Verb | Slug | # | Verb | Slug | # | Verb | Slug |
|---|---|---|---|---|---|---|---|---|
| 1 | Burrow | 228-haybales | 29 | Ask | 306-mossgate | 57 | Patch | 313-beaverdam |
| 2 | Dress | 228-scarecrow | 30 | Climb | 306-toadsteps | 58 | Slide | 313-mudslide |
| 3 | Hop | 228-ford | 31 | Comb | 307-tideline | 59 | Taste | 313-lodge |
| 4 | Sail | 228-pondmill | 32 | Grin | 307-barnacles | 60 | Unlatch | 313-stickgate |
| 5 | Shake | 228-apple | 33 | Echo | 307-shellhollow | 61 | Light | 313-tunnelmouth |
| 6 | Trim | 228-hedgerow | 34 | Salute | 307-sandcastle | 62 | Hush | 313-glowtunnel |
| 7 | Peek | 232-beehive | 35 | Skim | 308-pebblebar | 63 | Imagine | 314-driftwood |
| 8 | Pick | 232-berrypatch | 36 | Untangle | 308-kelpline | 64 | Sort | 314-shellpile |
| 9 | Share | 232-logbridge | 37 | Wave | 308-rockpool | 65 | Coax | 314-steppingrocks |
| 10 | Knock | 232-well | 38 | Peer | 308-tidesteps | 66 | Wait | 314-causeway |
| 11 | Read | 232-crossroads | 39 | Skate | 309-frozenpond | 67 | Hum | 314-lanternrocks |
| 12 | Picnic | 232-picnicrise | 40 | Judge | 309-snowmen | 68 | Petition | 314-gullparliament |
| 13 | Sniff | 236-wildflowers | 41 | Shelter | 309-icecave | 69 | Answer | 315-gate |
| 14 | Blow | 236-dandelions | 42 | Gaze | 309-auroraledge | 70 | Warm | 315-lamps |
| 15 | Bow | 236-stonebridge | 43 | Zigzag | 310-driftpass | 71 | Tickle | 315-slope |
| 16 | Eavesdrop | 236-beanpoles | 44 | Sled | 310-sledtrack | 72 | Lob | 315-fort |
| 17 | Grind | 236-windmill | 45 | Chip | 310-combridge | 73 | Ice-fish | 315-stream |
| 18 | Feed | 236-haywagon | 46 | Ring | 310-icicurtain | 74 | Test | 315-bridge |
| 19 | Measure | 304-oakarch | 47 | Tap | 311-taprow | 75 | Preen | 315-feather |
| 20 | Duck | 304-hollowtrunk | 48 | Stack | 311-bucketstacks | 76 | Crown | 315-cairns |
| 21 | Catch | 304-acorndrop | 49 | Stir | 311-sugarshack | 77 | Wipe | 315-doormat |
| 22 | Hoot | 304-owloak | 50 | Flip | 311-pancakelane | 78 | Blink | 315-den |
| 23 | Whisper | 305-birchtunnel | 51 | Guess | 312-ringlog | 79 | Wish | 316-skyhill |
| 24 | Count | 305-birchcurtain | 52 | Duet | 312-woodpecker | 80 | Chart | 316-starstones |
| 25 | Nestle | 305-fernhollow | 53 | Twirl | 312-toadring | 81 | Toast | 316-auroracamp |
| 26 | Bask | 305-sunclearing | 54 | Pluck | 312-bramble | 82 | Brew | 316-kettletree |
| 27 | Stroke | 306-mosslog | 55 | Trace | 312-greatstump | | | |
| 28 | Tune | 306-dripgrotto | 56 | Barter | 312-larder | | | |

82 verbs, 0 duplicates. Near-clashes checked and split by reward + story beat:

- **Rest family** (Burrow / Nestle / Bask / Shelter / Picnic / Toast / Warm): Burrow = energy for game time (hay nap); Nestle = small energy + Sense, needs the snail's say-so; Bask = sun-only Hardiness; Shelter = storm-only free steps; Picnic = doubles a food buff; Toast = cooks bread for energy; Warm = route-long Hardiness. No two give the same thing.
- **Crossings** (Hop / Share / Bow / Test / Wait / Coax / Zigzag / Unlatch): stat check + clay (Hop), friendship crossing (Share), manners + lost post (Bow), Sense check + free step (Test), tide timing + mussels (Wait), seal + fish (Coax), shortcut in minutes (Zigzag), shortcut in steps (Unlatch).
- **Sound family** (Knock / Hoot / Whisper / Eavesdrop / Echo / Tune / Ring / Hum / Duet): frog well, owl feathers, find rumour, weather forecast, story parts, drip-clock bead, icicle charm buff, lantern Sense buff, woodpecker beetle shell. Different payoffs.
- **Wishes** (Blow / Wish): dandelion = seed + next-section find, teaches cooldown; skyhill = night-only boon choice. Split.
- **Shell pickers** (Comb / Sort / Peer / Salute): beachcomb by tide (Comb), crab's spiral preference trade (Sort), 1-of-3 teacup pools + map scrap (Peer), rank ladder ending in a medal (Salute).
- **Read vs Trace vs Guess vs Count:** signpost of who is where (Read), ring history + old seed (Trace), age quiz streak (Guess), trunk count with a fog secret (Count).
- **Scout outputs:** Climb (whole next section), Petition (this section, by vote), Peer (map scrap for route 314), Echo secret (a find on 314 at night), Chart secret (a find on 309). Different sources, different triggers.

**Spots I could not make fully unique:** none. Softest pair: `312-woodpecker` Duet and `306-dripgrotto` Tune are both rhythm games; they stay apart because Duet answers a creature (Almanac critter, beetle shell) and Tune keeps time with water (a villager's drip-clock, Glowing Bead).

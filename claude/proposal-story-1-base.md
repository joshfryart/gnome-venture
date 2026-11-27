# PROPOSAL: Story pass 1, the base story ("The Round")

Status: PROPOSAL ONLY (2026-11-27). No code. Pass 1 of the story: premise, cast, structure, themes, arc per band.
Pass 4 review: corrected in place (adoption facts, Standing table, Hearth tier, ceremony name). See `claude/proposal-story-4-review.md`.
Builds on: `claude/proposal-maplewold-bands-and-seals.md` (bands, Standing, Seals, "Hollow in Disrepair"), `includes/journey.php`, `includes/stops.php`, `stop_adopt.php`, `stop_living.php`, `stop_folk.php`, `data/stop*.txt`.
Fixed and not reopened: no Trek story, no Tansy / Hollowheart, Journey = fill the Almanac, Wren = guide and letter-writer, bands and Seal rules as settled.

New names used below (all proposals): **the Round** (the old yearly walk of the roads), **Roundwalkers** (who walked it), **the Waythread** (the mycelium under the roads), **the Long Quiet** (the years since the Round stopped), **the Roll** (the list of keepers, the Almanac's last page).

## 1. Premise

Under every road of the Hollow runs the Waythread, one old fungus that links stop to stop. It glows where a lamp is lit and folk pass, and a glowing road is how a gnome at one stop knows the next stop is kept and worth walking to. Once a year the Roundwalkers walked the whole ring of roads: they lit lamps, mended what was broken, carried post, and wrote down what they saw in the Almanac. Then, about a lifetime ago, the Round thinned out. Nobody ended it. Each walker thought someone else had the next stretch. One lamp went unlit, the next stop saw a dark road and stayed home, the bench rotted because no one sat on it, and the dark spread down the roads at walking pace. That is the Long Quiet: no war, no curse, no culprit, only a job that became nobody's. The stops are still there and folk still live at them, making do. The gardens went the same way: Roundwalkers carried seed from stop to stop (the seed swap is what is left of that), and when they stopped, each area's best crop thinned to a few tired plants in a weedy stop bed. The cure is the same in all 14 areas: someone makes a stop their own (adopts it), raises it, replants its bed, comes back often enough to be a Regular, and helps the folk who were cut off. Wren's Almanac is the new edition, written for the first time by someone who is doing the mending. **"The Almanac complete"** means: 14 area sections, each bound with its Seal, plus the one page Wren cannot write herself, the Roll of the Hollow's keepers, signed by you. It means the book is true again, and the Round is somebody's job.

The mystery that runs under it: the old Almanac's last page (the old Roll) is missing, and no one remembers whose turn it was.

## 2. Wren

- **Role**: naturalist and bookbinder. She writes the Almanac's cover notes and guides, and binds each section when you earn its Seal. She never gives orders: she says what the old book claimed and what she hopes is still true.
- **Travel rule (new, ties her to stops)**: Wren walks one area behind you with a handcart of pages. She will only walk a lit road. Once you hold an area's Seal she arrives and sets up her writing desk at your Hearth stop there (section 4). So mending the road is literally what lets Wren come.
- **Voice**: keep the voice of the existing letters. "Dear friend,", short, warm, concrete (syrup, a slow walk over a bridge, a rude ostrich), a little wry, never grand. She notices small things and names people. No lore dumps.
- **What she wants**: an Almanac that is true today, not a copy of an old one. Underneath: she was trained to describe the Round and has never seen it walked. She wants to walk it once.
- **Letters, per area (3, all delivered by Pell the post-gnome, section 3)**:
  1. **Cover note** (on first arrival): what the old Almanac said about this area, one thing she doubts, the first dark stop to look at. Replaces the chapter intro.
  2. **First-lamp note** (the first stop in the area that you raise to tier 1): two or three lines, thanks, and one local tip. Short on purpose.
  3. **Seal letter** (at 80% Standing): four fixed parts. (a) thanks, naming a real thing you did (your Hearth stop and its plaque line, a villager you befriended); (b) one **correction**: "The old book said X. I have crossed it out and written Y."; (c) one piece of the Roll mystery (band-level, section 5); (d) which doors are now open and what the next area lacks. Then the bound section, the region guide and the benefit, as `journey_finish` does now.
- **Form of address** grows with the bands, reusing the existing titles: "Dear friend" (band 1), Field Hand / Pathfinder (band 2-3), "Dear Companion" (band 4), "Dear Keeper" (band 5 and the end).

## 3. Core cast (recurring, they travel)

How they travel: each has multi-day stop threads (`stop_threads.txt`, region-scoped, Regulars and up, one beat a day; after the pass 4 trim, Pell, Morelby, Linnet and the Stranger have one per band, the others bands 1-2 only), and shows up as a stop happening at their favoured stop type once a stop of that type in the area is tier 1 or better. So you meet them by lighting stops and coming back. None is ever required for a Seal.

| # | Who | Want | Quirk | Favours | Story job |
|---|---|---|---|---|---|
| 1 | **Pell Quickthistle**, post-gnome | To empty a sack of letters that could not be delivered during the Long Quiet | Reads every address aloud, never a letter | inn | Carries Wren's letters. Source of "deliver" errands. His sack gets lighter per Seal |
| 2 | **Bodkin and Thrum**, tinker siblings with a cart | To finish one job without arguing | Each measures everything, and they never agree | workshop | They are the builders: they turn up when a stop is one hand-in from its next tier |
| 3 | **Ottilie Kettlewick**, travelling cook | One supper where every seat at the table is taken | Counts chairs, sets a place for whoever is missing | mill, inn (bakehouse and hall) | Arrives when a stop reaches tier 4. Hosts each Seal supper |
| 4 | **Fenna Reedwhistle**, ferrywoman | To cross every water in the Hollow once | Names every boat, including ones that are not hers | ferry, jetty | Runs the water doors (Tide Track, Ferry Cove, Smugglers' Tide) |
| 5 | **Warden Hobb Stiles**, head of the gate Wardens | For his beacon to be answered by another beacon | Counts everything and gives it as a percentage | tower | The Warden voice at every door: says exactly what Standing is missing |
| 6 | **Fusby Crumb**, last clerk of the old Road Office | For things to be done properly, in triplicate | Stamps everything. Has a form for mending and no one to file it with | market | Stamps the passport (`stop_pass.php`). Comic friction, always comes round |
| 7 | **Professor Puff Morelby**, mycologist | To prove the Waythread is one single living thing | Talks to the ground, measures glow with a jam jar | herb, spring | Explains the glow, a little more each band, mostly wrongly at first |
| 8 | **Sorrel Inkpot**, apprentice mapmaker | A map with no blank bits | Gets lost in every area | tower (map room), camp | The recurring "Lost" errand. Her map fills as your Standing does and becomes the last-page drawing |
| 9 | **Linnet Hayloft**, fiddler | A tune that every stop knows the chorus of | Cannot be persuaded to stop | orchard, camp | Collects the four notes the road hums (the "singing well" thread, the Dreamy chat line). One phrase added per band |
| 10 | **The Grey Cloaks**, and the eldest of them, **the Stranger** | Not said | Leave small gifts, pay for tea with a button, give no name | shrine, camp | The mystery. Already in the data: the `shrine_day` happening and the `stranger` thread (the map stitched in the coat lining) |

Local faces stay local: Clover Puddlejump, Hazel Dewberry, Willow Rootstock and the other chapter NPCs keep their area's flagship Repair.

**The gentle opposing force: the Long Quiet itself**, with one question attached: who was meant to walk the Round last, and where is the old Roll?
- It shows as dark lamps, and as lanterns that "only like certain hands" (the `lantern` thread already says this).
- Lair creatures are not its servants. Each has simply moved into a part of the road that went empty (the Great White Owl into the aurora fields). Beaten or charmed, it gives the place back or becomes its guardian.
- **Pay-off**: the Stranger is the last Roundwalker. The old Roll was never stolen: they cut it out and stitched it into their coat because they could not bring themselves to write "the Round ended with me". They have walked alone ever since, lighting single lamps, which is why a few lamps were always found lit. At the end they hand the page over. Nobody is beaten. The Quiet ends because the job has a name on it again.

## 4. The stop system as story

Facts this is built on (current code): one adopter per stop; only the adopter can hand in for tiers; fee 300 Petals; slots 1, +1 per stop built to its Hall, cap 3 (`stop_adopt_limit`); releasing a stop keeps its tier for everybody; only tier 4 stops need monthly upkeep (any gnome can pay) and lose a tier if unpaid; Regular = 3 things done at a stop, Local 20, Pillar 60 or adopter; threads need Regular. Also (pass 4): **only road villages can be adopted** (`on_road` check in `place_ui.php`), so an area has 3 to 7 adoptable stops (the Maplewold 3, all on the prairie); off-road villages still have stop activities, stamps and Regulars, but no tiers. A stop at tier 4 cannot be adopted at all (only upkeep). The fee is the setting `stop_adopt_cost` (default 300).

### What a stop looks like
Tier names below are the plain ones in `stop_tiers.txt`. Each stop type shows its own themed name (`stop_tier_themes.txt`: Striped awning, Sack hoist, Stone lantern path...).

| Tier | Name | Look | What it means in the story | What comes alive |
|---|---|---|---|---|
| 0 | Dark stop (unadopted) | Lantern post unlit, shutters half up, weeds in the lane, notice board leaning. Folk are home and its plain activities still work | "Making do." Nobody is in charge of it | Base acts, the mending acts (`mend_board`, `tidy_yard`), chat. Road on both sides is dark |
| 1 | Bench & lantern post | The lamp is lit. A bench under it | **Lit.** Somebody keeps this place. The Waythread wakes here | Glow on the road. Cast can visit. Wren's first-lamp note |
| 2 | Little stall | Awning, goods, a dusk lantern walk | **Open.** Trade and news move again | Deliver errands to and from here, market-type happenings, Pell's rounds |
| 3 | Wishing well | A well (or pool, hives, map room, by type) | **Rooted.** The Waythread comes to the surface: the well hums its four notes | Linnet's and Morelby's threads. Hidden places near here are hinted |
| 4 | Long-table hall | A hall with one long table | **Home.** The whole road can sit down together | Ottilie, the `host_table` act, Wren's desk after the Seal. This is your **Hearth stop** |

### The glow
- A road segment between two neighbouring stops glows when both are tier 1 or better. Its brightness is the lower of the two tiers (1 faint moss-light, 4 bright).
- Shown on the area trail map, and in words on the stop card ("The road north is lit as far as ...").
- Off-road routes (Fen Path, Cairnback Climb...) glow from the road stop they hang off.
- The glow is shared: a stop raised by anyone is lit for everyone. What is personal is your Standing and your Regular status.

### An area at 80%
Most lamp posts lit, so the main road glows end to end with a few dark gaps left for later. A Hearth stop with a stall (a hall with a long table for those who build one). Stalls open at the busier stops. Three or four cast members passing through. The flagship Repair reopened. The door stop lit, with its Warden satisfied. Nothing is "finished": 100% is for those who want it.

### The intended loop (the spine of every area)
Arrive at a dark stop, stamp it, do three things (Regular), adopt it, raise it to tier 1, **hand it back to the road** (release keeps the tier), walk to the next. At off-road villages (no tiers) the loop is: stamp, become a Regular, help its folk. Pick one road stop per area as the Hearth stop: the main line asks for it at tier 2 (bands 1-2), tier 3 (band 3) or tier 4 (bands 4-5); a Hall earlier is optional. Come back to stops you lit for their threads, one beat a day, whenever you like.

### 4b. The gardening thread (every area)
- **Why gardens matter to the road**: the Waythread is a root fungus. Crops grow better over a lit road, and a planted bed feeds the thread back. Morelby's jam jar glows brightest next to a full bed. This is the story reason for the existing `native_plus` benefit.
- **The Seed Bed**: each area has one **signature crop** (a real crop of the region, table in section 5) whose good strain is nearly lost, and one garden-type stop that owns its bed: a herb croft, orchard camp or old mill where the area has one, else the Hearth stop. At tier 0 the bed is weeds with one surviving plant.
- **What the gnome does** (all with existing systems, at leisure):
  1. Get the seed: from the stop's seed swap (staple), the area market (uncommon), or as a rare find (treasure crops, used as optional extras only, never as the signature).
  2. Grow and harvest it in any of your gardens in that area.
  3. Hand harvest in at the bed's stop (a Seed Bed entry on the stop card, like a build stage: 3 hand-ins, growing in size by band). The first hand-in needs the bed's stop lit (tier 1) when it is a road stop, or you a Regular there when it is an off-road village (no tiers there), so **the bed follows the lamp**. The stop type named per area is flavour: any garden-type village, else the Hearth stop.
  4. Plant one or more native flowers for the area's pollinators: the bed stays in bloom.
- **What it does for the stop network**: a full bed turns on that stop's garden acts and happenings for everybody (seed swap stocked with the signature seed, `harvest_glut`, `berry_rush`, bake day), feeds the Larder meter, and supplies the home-cooked meals that tier 4 halls and Ottilie's suppers already ask for. The signature crop is on the table at the Seal supper.
- **Almanac**: the signature crop gets a "Restored by" line on its page, and Wren's cover note for each area names the crop the old book praised and that she cannot find.
- **Cast**: Linnet and Ottilie ask for it by name; Fusby insists on weighing it; Morelby measures it.

### Standing: proposed table (replaces the one in the bands doc, sums to 100)

| Part | Old | New | Notes |
|---|---|---|---|
| **Stops: the road mended** | 0 | **30** | three sub-rows below |
| Wren's flagship Repair done | 20 | 15 | existing chapter stages |
| Road villages and off-road places found | 25 | 10 | |
| Folk: Friend 5 + stop threads 5 + errands 5 | 10 | 15 | threads: 3 finished in the area = full 5; errands: 5 done in the area = full 5 |
| **Gardening: the beds replanted** | 10 | **15** | three sub-rows below (Josh: gardening is in every area's quest line) |
| Delve cleared | 15 | 5 | |
| Lair beaten, charmed, or its peaceful act | 15 | 5 | charm happens on the fight board, so it is still a fight; the peaceful act (e.g. the Owl's three evenings) is not |
| Almanac pages for the area | 5 | 5 | places, crops and folk pages only; creature pages need fights |

Stops row, with N = road stops in the area, counting only stops where you are a Regular or better:
- **Lit, 14**: 14 x (stops at tier 1+) / N.
- **Raised, 10**: 10 x min(1, sum of those stops' tiers / 2N). Full marks at an average of tier 2.
- **Hearth, 6**: the best stop in the area that you adopted (now or as founder) or paid upkeep into: tier 1 = 1, tier 2 = 2, tier 3 = 4, tier 4 = 6.

Gardening row (section 4b for the story):
- **Grown, 5**: 5 x (the area's staple and uncommon crops you have harvested) / (how many it has). Existing `grow` count.
- **Signature crop restored, 6**: the area's Seed Bed (grow the signature crop, hand the harvest in at its stop). 2 per hand-in, 6 when the bed is full.
- **In flower, 4**: one of the area's 12 native flowers grown to bloom = 2, three = 4.

What the weights do:
- Gardening is 15 of 100 in every area. It is never the only way to 80 and never skippable for 100.
- Without touching stops the most you can reach is 70. **The Seal needs the road.**
- Without delve and lair the most is 90 (95 where the lair has a peaceful act). **A gnome who never fights can earn every Seal** with 10 points to spare (the old table left exactly 80, so one missed page or a Hearth below tier 4 blocked them).
- Every step and every Standing row is a high-water mark: once met it stays met, even if a tier-4 stop later loses a tier to unpaid upkeep.
- Tier counts whoever raised it, so a late gnome in a busy world is not locked out: they become a Regular at lit stops and pay upkeep into a Hall for the Hearth points.
- Standing should be a high-water mark: it never goes down, and a Seal is never lost (see question 2).
- Numbers are unsimulated. The Maplewold has 3 adoptable road stops (10 villages, 7 off-road): lighting all 3 alone costs about 3 x (300 fee + 200 Petals + 8 materials), a Hearth at tier 2 another 400 Petals and 13 materials. Needs the same sim pass as the XP budget.

## 5. Arc per band

Every area has the same shape: dark road, first lamp, Hearth stop, folk helped, Seal. What changes per band is which part of the network is broken, so the story climbs the tier ladder. (All four tiers are buildable everywhere; the band theme only says what the story looks at.)

### Band 1. Maplewold, 1-15: "The first lamp"
- **Theme**: a place is kept because someone decides to keep it. **Tone**: home, cosy, autumn light, small stakes.
- **Network problem**: the lamps. Every lantern post on the home roads is out. Tier 1 is the lesson.
- **Gardening thread**: signature crop **wild rice** (uncommon), flower **goldenrod**. The Seed Bed is the Fens stop's paddy (beat 4). Lead-in: oats and the other staples on the prairie from the first day; apples and hops for the cider and bake days in the Maplewood. Optional treasure: cranberry in the Fens.
- **Roll mystery piece**: the old Almanac has a stub where its last page was cut out. Wren had never noticed.

Beats, zone by zone (stop types named are what the landscape allows, to be matched to the real villages). Pass 4: the Maplewold's 3 adoptable stops are all prairie road villages; in zones 2-6 the stop beats happen at off-road villages (stamp, Regular, folk), and the lamps are lit back on the prairie road:
1. **Bramblesweep Prairie (1-4)**. Wren's first letter and the blank Almanac. The first dark market hamlet: stamp, three chores, Regular, adopt (first adoption free, see question 3), Bench & lantern post. First glowing segment. Fusby stamps the passport and objects to the lack of paperwork. Pell brings the first-lamp note. Flagship Repair: the Sugar Shack roof (existing chapter, Clover Puddlejump). Garden: Wren's first seed packet (oats, lentil); harvest two staples and try the seed swap. Folk: a lost lamb; Sorrel Inkpot, lost within sight of the road. Thread: "The lantern that went out" (first hint that lamps choose hands).
2. **Old Maplewood (4-7)**. Old mill and tinkers' workshop. Teaches hand it back and walk on: light a second stop. Bodkin and Thrum argue the mill sluice into place. Creature trouble at the mill sacks (fight or charm). Thousand Rings Stump: the rings are wide for the years of the Round and thin for the Long Quiet, the first sign of how long it has been. Garden: apples and hops for the mill's bake day; Morelby's jam jar glows brighter by a planted bed than a bare one.
3. **Foghorn Shallows (7-10)**. Jetty, ferry landing, tower. Repair: the Lighthouse of the Lost Lantern, the biggest lamp in the Maplewold. Teaches tier 2 (stall, trade). Fenna Reedwhistle and the tide-locked ferry on the Tide Track: the first closed door, with Hobb's first "not yet, and here is why". Thread: "The ferryman's hat". Folk: a stranded fisher.
4. **Beaverdam Fens (8-11)**. Wetland stops on a flooded causeway. The beavers built over the road because no one kept the sluice: a council to settle (the Dam Debt), not an enemy. Heron Stilt Village found. Delve: Beaverdam Tunnels. Teaches tier 3: the well here hums four notes ("The singing well"). Linnet Hayloft writes them down. Garden: the Seed Bed. The beavers' flood drowned the old wild-rice paddy; once the sluice is agreed, replant it and hand in three harvests (uses the existing `r_na_knock_rice` act).
5. **The Frostbitten North (11-13)**. Shrine, hot spring, tower. Repair: the Aurora Camp lamps. Ottilie's first supper, three chairs short. The camp cook's wolf to shoo. Grey Cloaks at the moss shrine, leaving gifts. The `stranger` thread can start here: tea paid with a button.
6. **Cairnback Ridge (12-15)**. Watchtower and workshop. The cairns are the Roundwalkers' markers, one stone per walker per year, and the newest stones are very old. Repair: rebuild the cairns. From the tower at night you see the road you lit, as a line of light back to the prairie, ending at your Hearth stop (a prairie road stop, at tier 2 or more).
7. **Capstone: Den of the Great White Owl (15)**. The Owl has kept the aurora fields dark on purpose. Beaten or charmed, the terms are the same: the Aurora Road stays lampless, lit by the aurora, and the Owl guards it.
- **Seal ceremony, "The Lighting"**: Hobb fires the Cairnback beacon. The glow runs down the road to both border stops. Ottilie lays a table at your Hearth stop (trestles outside if it is not yet a hall). Linnet plays the first phrase. Wild-rice and apple dishes are on the table. Wren arrives on foot for the first time, binds the Maplewold section at the table, and reads the correction aloud. Roads to Maizehollow and Mistmoor were always open: the Seal adds the high road (Cairnback Climb) and the Northern Rim Pass.

### Band 2. Maizehollow and Mistmoor, 15-25: "Open the stalls"
- **Theme**: neighbours. A lit stop is not much use if nothing moves between stops. **Tone**: busy, sociable; dry heat in one, soft fog in the other.
- **Network problem**: the links. Stops survive but the things between them are out: Maizehollow's cisterns and granary (the Larder meter), Mistmoor's footbridges and ley stones lost in fog. Tier 2 is the lesson: stalls, post, carrying things from one stop to another.
- **Gardening thread**: Maizehollow **amaranth** (flower: marigold), bed at the granary-side mill or herb croft; corn, black bean and chili as the staples the Granary stores. Mistmoor **barley** (flower: heather), bed at the old mill by the Footbridge; rye and leek as staples, lingonberry for the fells. In both the crop is what the stalls have been missing: tier 2 stalls sell it once the bed is full.
- **Maizehollow**: wells and stores. The Granary stays the flagship. Dark stops are thirsty. Folk: a trader lost in the Quetzal Tangle. Cenote Underway as the delve.
- **Mistmoor**: sight. In the fog a lamp is the only way to find the next stop. The Footbridge stays the flagship. Ley Walk: each standing stone you reach glows and links. Folk: the fell-herder's goats, a smuggler who wants out.
- **Roll mystery piece**: Pell's sack holds letters addressed to "The Walker, wherever met". Nobody has collected them in his lifetime.
- **Seal ceremony, "Two lamps"** (needs both Seals; played out in the optional chapter "The Crossing", pass 2): Hobb's beacon in Maizehollow and its twin in Mistmoor answer each other across the Maplewold, the first time in his lifetime it has been answered. All five tier 3 doors open the moment the second Seal is earned. Fenna takes the first ferry out.

### Band 3. Sunsprinkle, Rainroot, Olivewhistle, Birchbramble, 25-35: "Across the water"
- **Theme**: reaching. What do you owe a place you cannot see from your own door? **Tone**: breezy, adventurous, salt and wide skies.
- **Road note (pass 4)**: only Olivewhistle (to Dunewhisper) and Birchbramble (to Spicepeak) have roads on into tier 4. Sunsprinkle and Rainroot lead only to each other and (Rainroot) to the Coralscatter, a tier 5 door.
- **Network problem**: the gaps. Sea, river, marsh and steppe split the road, and the Waythread does not seem to cross them. Ferries, jetties, lighthouses and towers carry the light instead. Tier 3 is the lesson: at every well and pool the same four notes, on both sides of the water.
- Flagships kept: Lighthouse (CB), Canoe Jetty (SA), Hill Windmill (SE), Drying Barn (EE).
- **Gardening thread**: crops that have to be carried over water to be shared, so each bed sits at a ferry-side orchard or croft. Sunsprinkle **breadfruit** (frangipani). Rainroot **yerba mate** (passionflower), the drink of every jetty. Olivewhistle **olive** (lavender), pressed at the Hill Windmill's stop. Birchbramble **buckwheat** with plum (chamomile), dried in the Drying Barn.
- Morelby's theory breaks (it cannot cross the sea) and mends (it does, it is simply deep).
- **Roll mystery piece**: lamps found already lit on islands no one has kept. Someone is still walking.
- **Seal ceremony, "Lamps on the water"** (renamed in pass 4: "The Crossing" is the band 2 joint chapter): per area, the first lit boat of the season goes out from your Hearth stop and every jetty and tower it passes lights behind it.

### Band 4. Dunewhisper, Spicepeak, Greatcanopy, Thornacre, 35-45: "The long table"
- **Theme**: hospitality. A stop is a promise to strangers. **Tone**: vast, starry, slower and quieter. The cosiest suppers in the emptiest places.
- **Network problem**: distance. Stops are days apart across dune, peak, deep forest and savanna, and the travellers who used to keep them (caravans, pilgrims, herders) stopped coming. One dark stop breaks a whole road. Tier 4 is the lesson: a hall with a table makes a stop worth a long walk.
- Flagships kept: Oasis Waterwheel (MENA), Tea Terraces (CSA), Storyteller's Platform (WCA), Waterhole Pump (ESA). The Oasis That Moves is the Waythread surfacing where it likes.
- **Gardening thread**: the crop that feeds a stranger at the end of a long walk; each bed supplies its hall's table. Dunewhisper **date** (damask rose), palms by the oasis stop. Spicepeak **turmeric** with ginger (sacred lotus) below the terraces; the Tea Terraces flagship stays, tea itself is a treasure and optional. Greatcanopy **fonio** (wild gardenia). Thornacre **teff** (king protea); coffee optional.
- The Grey Cloaks turn out to be the last of the Roundwalkers' households, still leaving gifts at shrines out of habit. The Stranger sits at your table once and leaves before pudding.
- **Roll mystery piece**: the Stranger's coat lining, seen once: a map of the Hollow and a page sewn inside it.
- **Seal ceremony, "Every seat"**: Ottilie's supper at your Hearth stop. The table is full for the first time in her life but for one chair, which she sets anyway.

### Band 5. Blossomreach, Monsoon Tangle, Coralscatter, 45-55: "The far end is the near end"
- **Theme**: return. A round has no end, only the place you started. **Tone**: festive and a little wistful. Blossom, monsoon, reef.
- **Network problem**: the ring is open. These are the oldest stretches of the Waythread and they are bright in patches, but the Round does not join up: the last link is the closed road from Blossomreach to Clovercove in the Maplewold, the dead end you passed at level 1.
- Flagships kept: Red Bridge (EA), Stilt Boathouse (SEA), Reef Garden (OC, renamed and with Tansy removed: the reef is where the Waythread's hum can be heard out loud).
- **Gardening thread**: the oldest gardens, where the thread and the roots are plainly one thing. Blossomreach **persimmon** (cherry blossom), an orchard by the Red Bridge. Monsoon Tangle **rice** (sampaguita), paddies under the Stilt Boathouse. Coralscatter **taro** (tiare), the Reef Garden's beds running into the shallows.
- Linnet's tune gets its last phrase at the reef. Sorrel's map has three blank bits left, then none.
- **Roll mystery piece**: the Stranger stops leaving. They wait for you at the Clovercove Gatehouse, on the far side.
- **Seal ceremony, "The last lamp"**: per area, the area's oldest lamp, one that "only likes certain hands", lights for you.

## 6. The final act: the Almanac's last page

Trigger: all 14 Seals. No new area, no boss, no timer.

1. **The gate.** The Clovercove road opens from the Blossomreach side. This is the one door that needs every Seal. Walking it closes the ring: you come home to the Maplewold from the east, by the short road, past the first stop you ever lit.
2. **The Stranger.** At the Clovercove Gatehouse the Stranger unpicks their coat lining and hands you the old Roll, the page cut from the old Almanac. Every line is a name and a year. The last line is theirs. The line under it is blank. They say very little. They ask if there is tea.
3. **The last page.** Wren binds the old Roll into the new Almanac and adds a fresh leaf facing it. This is the one page she does not write.
   - Left: **the Whole Map**, Sorrel's, no blank bits, the Waythread drawn in as one lit ring.
   - Right: **the Roll of Keepers**. Live from the world: every stop in the Hollow with the name on its plaque (founder and present keeper), yours among them, and your own line under the Stranger's: "Walked the Round, and it did not end."
   - Below it, blank lines. The Almanac is complete and the Roll is open. Gnomes who come after sign beneath.
4. **The supper.** Ottilie's table at your first Hearth stop, one dish from each of the 14 signature crops (anything you grew is used; nothing extra is asked for). Every chair taken: the tenth is the Stranger's. Linnet plays the whole tune and the well joins in. Hobb counts and, for once, gives no percentage. Fusby files the form.
5. **Wren's last letter**: she is setting out to walk the Round herself, the long way, and will write from each stop.
- **The Almanac's garden pages**: 14 crops marked "Restored by" you. Wren's last correction: "The old book said these were grown here once. Grown here."
- **Rewards (replace the Hollowheart tree and title)**: title "Roundwalker"; a Keeper's Lantern for the yard (decor, glows faintly on warm evenings, same slot as the old `hollowheart-tree`); the Round as an open-ended leisure loop afterwards (walk the ring, pay upkeep, finish threads). Nothing closes.

## 7. Open questions for Josh

0. **Off-road adoption (pass 4).** Only road villages can be adopted, so the Maplewold has 3 stops to light. Open adoption to all villages (drop the `on_road` check) so every zone has lamps? The main line in pass 2 now works either way.
1. **Who can build.** Today only a stop's adopter can hand in for its tiers. The Standing row above avoids needing a change (Regular + tier by anyone, and upkeep counts for Hearth). Is that enough, or should any Regular be able to chip in to a tier, so mending a road is shared work?
2. **Upkeep against "no timers, no fail states".** Tier 4 stops lose a tier each unpaid month. Proposed: keep it as world flavour, but make Standing a high-water mark and Seals permanent. Or switch the tier loss off?
3. **Adoption cost and slots.** The loop is "light it, hand it back, walk on" within 1 to 3 slots and a 300 fee per adoption. Proposed: first adoption free (Wren's gift), fee kept after. Keep the fee on every re-adoption, lower it, or waive it inside the Maplewold?
4. **The Stranger.** Fine as the last Roundwalker with no tie to Wren (as written)? An optional extra is that Wren was to be their apprentice and nobody came for her. I left it out as too close to the dropped Tansy plot. Say if you want it.
5. **The ending's door (and one gardening check).** Are the 14 signature crops right (wild rice, amaranth, barley, breadfruit, yerba mate, olive, buckwheat, date, turmeric, fonio, teff, persimmon, rice, taro)? I chose staples or uncommons only, so no Seal waits on a rare find. Also: OK that the Clovercove road is the final link and needs all 14 Seals, so the story ends at home rather than in the Coralscatter?

# Ideas: the 43 end pieces (`end-*`) as unique places

Status: BRAINSTORM ONLY (2026-11-11). No code. Archetype **J, "scout the place ahead"** from `claude/plan-trail-sights.md`: peek, listen, read tracks, light a light. Never a fight. A lair scout may hint at the boss (a stat it tests, when it naps) but never shows its numbers.

**What makes the 43 unique.** There are only 8 drawings, but each slug only ever stands before 1 to 5 real places (`trail_maps.json`, the route's `to`). So every spot is tied to its **destination(s)**, its land, a **day-part / season / weather** (`dp= se= we=`), one **villager personality** (`FAV_KINDS` in `npc_life.php`: Chatty, Cheerful, Warm, Generous, Eager, Grumpy, Shy, Fussy, Proud, Curious, Dreamy, Sleepy) and a **verb that no other spot uses**.

**Conventions**
- Items in `backticks` are grep-confirmed in `game/includes/data/*.txt` (gatherables, crafts, recipes, crops, creature drops). Anything marked **(new)** does not exist yet.
- Rewards use the stop-act grammar (`c= xp= en= item= crop= buff=stat:n:min fp=`). Odds are per use, before the cooldown (5.5 game days per section).
- Named villagers already exist: travellers Tobias Trundle (Generous tortoise merchant), Lyra Fiddlewing (Cheerful grasshopper minstrel), Wren Thimblewick (Curious naturalist), Pomeroy Crumbworth (Fussy dormouse food writer); calling mentors Burdock Deepdelve, Zinnia Fuzzbottom, Captain Bracken Spurwing, Sorrel Inkcap, Tumble Waymarsh, Juniper Kettleby. "A Shy local" = any villager of that personality from the destination's region.
- Quest tasks need one new event kind: `T|...|event|sight|slug=end-...|1|label` **(new kind `sight`)**, fired when a Sight is used.

---

## 1. Quest lines (8)

Every end piece is a beat in at least one line.

**Q1. The Lamplighter's Round** (Burdock Deepdelve, Rootwarden; all 5 `end-delve-2-*` lantern lines)
"Somebody put up these lanterns and then forgot them. Shall we not forget them?"
1. `end-delve-2-forest`: Burdock hands you a taper (new); light the first lantern before Salt Mine Galleries.
2. `end-delve-2-wetland`: float a candle into Mangrove Root Maze (needs `beeswax-candles`).
3. `end-delve-2-rainforest`: talk a firefly into an empty lantern (Jaguar Root Caves or Firefly Caves).
4. `end-delve-2-desert`: trim the sooty wicks on the Long Wall Walk or Rose-red Canyon City.
5. `end-delve-2-island`: shoo the wick-stealing gulls off the Pirate-gull Grottoes line. Finale: all five lit inside one season. Reward `glowcap-lantern` x1, title *Lamplighter* (new).

**Q2. A Lullaby for Big Friends** (Lyra Fiddlewing; all 7 `end-lair-2-*` thresholds)
Lyra wants to write a lullaby for the sleepy giants, "so they wake up nicer". Each threshold gives one **Snore Note** (new, a quest token).
1. `end-lair-2-tundra`: count the Frost Toad's snores (the line starts here: "even toads need a lullaby").
2. `end-lair-2-wetland`: the Hurricane Crab's click-clack sideways walk.
3. `end-lair-2-forest`: the Tiger Moth's wing-dust rustle.
4. `end-lair-2-coast`: the Box Jelly Queen's slow glow-pulse.
5. `end-lair-2-rainforest`: the Silverback Spider's web hum.
6. `end-lair-2-desert`: the Sand Scarab's rolling rhythm.
7. `end-lair-2-mountain`: three sets of footprints, three different beats. Finale: Lyra plays the *Big Friends Lullaby* (new song) on any village green; reward buff *Hushed Steps* (new: Sneak a little easier at every lair, 3 game days) + an Almanac page.

**Q3. The Scout's Field Notes** (Captain Bracken Spurwing, Thornblade; all 3 `end-lair-1-*` long approaches)
"A Hedge Knight looks before leaping. Ideally a long look."
1. `end-lair-1-desert`: watch the heat shimmer before the Jade Dragon-fly.
2. `end-lair-1-island`: read the tail-drag to the Dragonlizard Den.
3. `end-lair-1-mountain`: peek over the ridge at the Grey Wolf King or Smokecap Caldera.
4. Then `defeat` or `befriend` any one of those three bosses (existing task kinds). Reward *Scout's Spyglass* (new trinket: +1 Sense on every end-piece scout).

**Q4. Wren's Gate Rubbings** (Wren Thimblewick; the 8 `end-wonder-1-*` gates)
Wren collects crayon rubbings of wonder gates. Each gate scout gives a **Gate Rubbing** (new) with a riddle line.
1. `end-wonder-1-rainforest`: Wren hands you the paper and crayon here (start).
2. Any 6 of `end-wonder-1-coast`, `-desert`, `-forest`, `-island`, `-mountain`, `-wetland`.
3. `end-wonder-1-grassland` at dusk: Wren waits by the gate and reads the riddle lines in order; they rhyme. Reward 1 old-world seed (`*seed` of the region), title *Gate Gazer* (new).

**Q5. The Book of Hushes** (Sorrel Inkcap, Seedkeeper; the 8 `end-wonder-2-*` hushes)
In each hush the place "is about to speak". Write down what it nearly says. Each scout writes one **Hush Page** (new).
1. Start: `end-wonder-2-forest` (the quietest, Sorrel says, "except the library").
2. Then `-coast`, `-desert`, `-grassland`, `-island`, `-mountain`, `-rainforest` in any order.
3. Finale: `end-wonder-2-wetland`, outside the Mud Mosque Library: bind the book. Reward *Book of Hushes* (new hovel decor) + `sages-draught` x1.

**Q6. Follow Your Nose** (Pomeroy Crumbworth; the 5 `end-haven-1-*` paths)
"A good writer smells the supper before he sees it." At each path guess the dish drifting down; right guesses earn **Spoons** (his rating unit).
Beats: `end-haven-1-grassland` (scones or painted-egg bread), `end-haven-1-coast` (mint tea), `end-haven-1-island` (kava), `end-haven-1-tundra` (sauna buns, new), `end-haven-1-wetland` (noodle steam / flower honey). Finale: eat a home-cooked meal at any haven (`eat` homecooked=1). Reward title *Good Nose* (new), `feast-berry-honey-cake` x1.

**Q7. Rest Here, Repainted** (Tobias Trundle; the 3 `end-haven-2-*` last turns)
Tobias painted every "Rest Here" sign 60 years ago and they are fading. Bring `red-ochre`.
1. `end-haven-2-grassland`: repaint any one of the five (the back of the sign has his old initials).
2. `end-haven-2-coast`: straighten and repaint a sea-wind sign.
3. `end-haven-2-island`: Tobias meets you at the Driftwood Tavern turn and signs the last sign. Reward Petals c=120, `scute-wind-chime` x1.

**Q8. The Echo Map** (Tumble Waymarsh, Wayfinder; the 4 `end-delve-1-*` mine mouths)
Tumble maps delves "by ear". Each mine mouth adds a page to the **Echo Map** (new: shows the first room of that delve before you enter).
Beats: `end-delve-1-coast` (tide line), `end-delve-1-desert` (wet a finger), `end-delve-1-mountain` (drop a pebble), finale `end-delve-1-rainforest` (shout hello: the echo answers in Tumble's voice, he is already inside). Reward title *Echo Reader* (new), `hiking-staff` x1.

---

## 2. All 43 spots

Format: **slug** · verb · destinations (route) · then hook / Quest / Villager / Goodie.

### Havens, path (`end-haven-1-*`): "a smell of something warm"

**`end-haven-1-grassland`** · 👃 Sniff the breeze · Painted Egg House (385), Thatchtop Tearoom (359)
Hook: guess what's in the oven (Sense 11); right = the haven holds one for you (rest price -10% today). Q6 beat 1.
Villager: a **Chatty** local walking home from the tearoom (dp=dusk) tells you today's shelf item (free shop peek). Goodie: `herb-flatbread` 20% se=spring; `hen-egg` (painted, Egg House only) 15%.

**`end-haven-1-coast`** · 🍃 Follow the mint · Spice Souk (397)
Hook: a thread of mint-tea steam picks the right alley; follow it (Lore 11) = you arrive at the souk 10 game minutes sooner. Q6.
Villager: a **Generous** stall runner (dp=dawn) hands out a free sample: `mint-tea` x1 once per walk. Goodie: `saffron` 8% we=heat.

**`end-haven-1-island`** · 👏 Clap the rhythm · Kava Circle (468)
Hook: slow clapping drifts down the path; clap along (Charm 11) and the circle saves you a seat (rest price -25% today). Q6.
Villager: a **Dreamy** islander walks to the circle on clear nights (dp=night, we=sun/cloud), shares a story, fp=1. Goodie: `coir-fibre` 25%; `kava` crop 5%.

**`end-haven-1-tundra`** · ♨️ Count the steam puffs · Northern Lights Sauna (364)
Hook: puffs = free benches inside; an odd number means the aurora shows tonight (true hint: the sauna's night Luck buff is likelier). Q6.
Villager: a **Grumpy** regular trudges here on snow days (we=snow); walk with him and he grumbles you a `hot-cocoa`. Goodie: `cottongrass` 25%; `crowberries` 30% se=autumn.

**`end-haven-1-wetland`** · 👋 Wave at the boats · Floating Flower Market (432), Floating Market (455)
Hook: a cheerful wave (Charm 10) and a passing boat waves back, tossing a flower; a bad wave splashes you (-1 en, a giggle). Q6.
Villager: a **Cheerful** boat gnome poles to market at dawn (dp=dawn); ride along = skip the last stretch (new: short hop). Goodie: a region flower 20%; `lotus-root` 15% se=summer.

### Havens, last turn (`end-haven-2-*`): the hand-painted "Rest Here" sign

**`end-haven-2-grassland`** · 🪧 Read the back of the sign · Cherry Blossom Teahouse (443), Market of a Thousand Chilies (323), Drum Circle Market (411), Gaucho Gnome Ranch (347), Baobab Inn (422)
Hook: the back says today's thing in each haven's own hand (blossom count / chili heat / tonight's drum song / which pony is friendly / rooms free). Q7 beat 1.
Villager: a **Sleepy** villager naps against the post (dp=day, we=sun); let them sleep = buff=luck:1:60; wake them = they apologise with `cornbread`. Goodie: `wild-berry-jam` 10%.

**`end-haven-2-coast`** · 🔨 Straighten the sign · Olive Press Piazza (372), Lemon Grove Monastery (373), Turtle Nesting Beach (337)
Hook: the sea wind tips it every night (Grit 11 to fix); at Turtle Beach in summer it points the hatchlings the wrong way, turn it seaward = Charm buff there. Q7.
Villager: a **Fussy** monk checks the sign is level each dawn (dp=dawn); if it is, `lemon` x1. Goodie: `sea-salt` 25%; `Sea Glass` 6% we=storm.

**`end-haven-2-island`** · 📯 Blow the tavern conch · Driftwood Tavern (335)
Hook: one toot means "one more for supper"; a toot back means a table is free (peek at the bar's stock, free). Q7 finale.
Villager: **Lyra Fiddlewing** stops here on her way to play (when she is in the Sunsprinkle Isles): a song on the path for half price. Goodie: `coconut` 30%.

### Wonders, gates (`end-wonder-1-*`): "you can feel it in your shoes"

**`end-wonder-1-coast`** · ✨ Count the glimmers · Glowworm Grotto (470), Lantern Festival River (456)
Hook: count the lights (Sense 12) and they make a shape; name it = an Almanac constellation page (new) + first-visit XP. Q4. Best dp=dusk,night.
Villager: a **Shy** local comes at night to look, speaks only in whispers: teaches the `firefly-jar` recipe. Goodie: `firefly-glow` 20% dp=night.

**`end-wonder-1-desert`** · 😎 Shade your eyes · The Mirror Salt Flat (352)
Hook: after rain the flat shows the sky twice; read it (Sense 12) = tomorrow's weather shown on the card (true forecast). Q4.
Villager: a **Curious** villager measures the reflection with a stick; give `desert-glass`, get buff=sense:1:120. Goodie: `desert-glass` 15% we=heat; Mirror Salt Crystal (new) 5% we=rain.

**`end-wonder-1-forest`** · 🟠 Squint through amber · The Amber Woods (386)
Hook: a bead of amber hangs on the gate; hold it to the light (dp=day) and see the old seed trapped inside = tells which seed you can dig here today. Q4.
Villager: an **Eager** young digger with a far-too-big spade (se=spring); help carry it = `pine-resin` x2. Goodie: `pine-resin` 30%; Amber Seed (new) 3%.

**`end-wonder-1-grassland`** · 🎵 Hum with the stones · The Standing Stones (360), The Hanging Garden Ruins (398)
Hook: at dusk the gate hums; match the note (Lore 12) and it hums back = double first-visit XP. Q4 finale.
Villager: **Wren Thimblewick** waits here at dusk in autumn (se=autumn, dp=dusk) to read rubbings and swap one seed. Goodie: `meadowsweet` 25% se=summer.

**`end-wonder-1-island`** · 🌀 Trace the maze · The Labyrinth Isle (375)
Hook: the gate carving is the maze in tiny; trace it (Nimble 11) = the card tells you the first right turn. Q4.
Villager: a **Proud** local who "solved it 40 times" says you traced it wrong (you did not): fp=1 for being polite. Goodie: `spiral-shell` 25%; `olive` 10% se=autumn.

**`end-wonder-1-mountain`** · 🐐 Call the goats · Goat Path Vineyards (374), The Sky City Ruins (348)
Hook: a goat answers and trots off; follow it = 10 game minutes saved; in autumn it comes back with grapes in its beard. Q4.
Villager: a **Warm** vintner comes down at harvest (se=autumn) with a basket for helpers: crop= grape x2. Goodie: `goat-hair` 20%; `edelweiss` 8% se=summer.

**`end-wonder-1-rainforest`** · 🖐️ Make a gate rubbing · The Stepped Seed Temple (324), Root-wrapped Temple (459), The Singing Waterfall (338)
Hook: three carvings (steps / roots / falling water); the rubbing shows one riddle line for that temple. Q4 START: Wren gives the paper here.
Villager: a **Fussy** gate-sweeper (dp=dawn); wipe your feet first and she hints the riddle. Goodie: `bromeliad-seeds` 20% we=rain; `morpho-scales` 8%.

**`end-wonder-1-wetland`** · 🦩 Stand on one leg · Flamingo Shallows (426)
Hook: flamingos only let in gnomes who stand like them (Nimble 12); a wobble = a plop in the shallows (-1 en, wet socks, everyone laughs kindly). Q4.
Villager: a **Cheerful** feather-crafter (on market days) swaps your `pretty-feather` for a Flamingo Feather (new). Goodie: `dragonfly-wing` 10%; `cattail-root` 20%.

### Wonders, the hush (`end-wonder-2-*`): "as if the place were about to speak"

**`end-wonder-2-coast`** · 🐚 Hold a shell to your ear · Pearl Diver Cove (446), Sunken Gnome Galleon (336)
Hook: the shell "says" where divers found pearls today / which seed chest on the galleon is open (a hint for inside). Q5.
Villager: a **Chatty** pearl diver dries off on the rocks (dp=day, we=sun) and gossips: one rumour (`teahouse_rumours`). Goodie: `seed-pearl` 8% dp=dawn; `urchin-test` 20%.

**`end-wonder-2-desert`** · 🤫 Whisper a question · Cenote of Echoes (326), The Oasis That Moves (400)
Hook: at the Cenote the echo answers in a rhyme; at the Oasis the wind whispers which village it is in today (true and useful). Q5.
Villager: a **Dreamy** wanderer who follows the Oasis shares `date-syrup` (dp=dusk). Goodie: `desert-sage` 25%; `dried-dates` 10%.

**`end-wonder-2-forest`** · 🦶 Tiptoe in · The Thousand Gates (444), Panda Bamboo Grove (445), Fairy-ring Clearing (361), Tea Garden Slopes (434), Stone Head Watchers (472)
Hook: tiptoe (Sneak stance helps) and see the first thing: a red gate swinging / a panda yawning / mushrooms leaning in / pickers mid-song / a stone head opening one eye. Q5 START.
Villager: a **Sleepy** keeper naps by the path (dp=day); don't wake them = they leave `bamboo-shoot`. Goodie: `chanterelle` 20% we=rain; crop `tea` 10% se=spring.

**`end-wonder-2-grassland`** · 🫳 Put a hand on the ground · The Silk Road Caravanserai (433), The Great Migration (423)
Hook: rumbling = the herd passes today (Migration: buff=luck:1:120); jingling = a caravan is in (Caravanserai: one extra seed swap). Q5.
Villager: a **Generous** caravan gnome who walks the silk road swaps `dried-figs` for any seed. Goodie: `cricket-chirp` 20% dp=dusk; `butterfly-scales` 10% se=summer.

**`end-wonder-2-island`** · ⭐ Find the first star · Starpath Canoe (469), Volcano Spice Gardens (457)
Hook: dp=dusk only; name the first star (Lore 12) = your next Trail walk is 10 game minutes shorter (wayfinding). Q5.
Villager: a **Proud** navigator paddles in at dusk and corrects your star name kindly; xp=8. Goodie: crop `vanilla` 5% se=summer; `coral-fragment` 20%.

**`end-wonder-2-mountain`** · 🌬️ Catch your breath · Prayer-flag Pass (436), Cedar Sanctuary (399), Coffee Ceremony Hut (424)
Hook: three slow breaths in thin air = en=+1 and a smell clue (flags snapping / cedar / coffee roasting). The only end piece that gives energy back. Q5.
Villager: a **Warm** coffee-hut host walks down at dawn with a flask: `cold-brew-coffee` x1. Goodie: `slate-shard` 20%; `silk-bunting` 3% we=wind.

**`end-wonder-2-rainforest`** · 🧘 Sit very still · Gorilla Glade (413), Pink River Dolphin Pools (350)
Hook: sit long enough (Sense 12) and a gorilla sits beside you / a dolphin blows a bubble ring = buff=charm:1:120 for the wonder. Q5.
Villager: a **Shy** villager brings fruit to the glade on rainy mornings (we=rain, dp=dawn); help carry = crop `mango` x1. Goodie: `rubber-sap` 20%.

**`end-wonder-2-wetland`** · 🪽 Count the wingbeats · Stork Chimney Village (388), Mud Mosque Library (412)
Hook: count the storks' wingbeats = which chimney they land on (sometimes yours: a letter); at the Library, swallows = how many scrolls are out today. Q5 FINALE.
Villager: an **Eager** letter-carrier waits for a stork with mail (dp=day); she hands you a real Letter from a friend villager (new hook into `letters.php`). Goodie: `river-clay` 25%.

### Delves, mine mouth (`end-delve-1-*`): "breathes cool air and old echoes"

**`end-delve-1-coast`** · 🌊 Read the tide line · Sea-cave Smugglers' Run (362)
Hook: the wet line on the rock says when the caves are walkable (Lore 12) = the first room is a dry one. Q8 beat 1.
Villager: a **Grumpy** retired smuggler on a barrel (dp=dusk) now sells honest `rope` at half price. Goodie: `bladderwrack` 30%; `Pearl` 3% we=storm.

**`end-delve-1-desert`** · ☝️ Wet a finger · The Red Rock Songlines (473), Fynbos Fire Trails (427)
Hook: the cool draught says which way the long song goes / which trail burned lately (skip the scorched room hint). Q8.
Villager: a **Curious** songline walker hums at dawn; learn a verse = buff=lore:1:60. Goodie: `red-ochre` 25%; `flint` 15%.

**`end-delve-1-mountain`** · 🪨 Drop a pebble · Snowleopard Ledges (437)
Hook: count until it clinks = how many ledges before the first rest spot inside. Q8.
Villager: a **Proud** mountain guide walks the first ledge with you for one `goat-cheese` (Nimble +1 in the delve). Goodie: `rock-crystal` 12%; `geode` 6% se=winter.

**`end-delve-1-rainforest`** · 📣 Shout hello · The Canopy Bridges (414), Anaconda Hollows (351)
Hook: the echo comes back from above (bridges) or along the creek (hollows) = first room hint; on a lucky day a howler monkey shouts back. Q8 FINALE.
Villager: a **Cheerful** bridge-mender climbs up at dawn; carry her `rope` = xp=10 and a safer first bridge. Goodie: `fiddleheads` 25% se=spring; `laterite-clay` 15%.

### Delves, lantern line (`end-delve-2-*`): "please bring your own light"

**`end-delve-2-forest`** · 🏮 Light a lantern · Salt Mine Galleries (387)
Hook: needs `tin-lantern` (or any lantern); lit = buff=sense:1:60 for the delve. Q1 START.
Villager: a **Shy** salt miner comes out at dusk to sit by a lit lantern; leaves `rock-dust` as thanks. Goodie: `oak-gall` 15%; `beeswax-candles` 5%.

**`end-delve-2-wetland`** · 🕯️ Float a candle · Mangrove Root Maze (339)
Hook: needs `beeswax-candles`; the candle drifts in and shows which channel the current takes = the safe route through the first fork. Q1.
Villager: a **Dreamy** boat gnome collects floated candles at the far side; returns one as a Lucky Wick (new, +1 Luck in the next delve). Goodie: `mangrove-root` 25%; `sphagnum` 20%.

**`end-delve-2-rainforest`** · 🐛 Borrow a firefly · Jaguar Root Caves (325), Firefly Caves (460)
Hook: ask nicely (Charm 11) and a firefly moves into an empty lantern: free light, no lantern item needed. Q1. dp=night easier.
Villager: an **Eager** young lantern-keeper counts fireflies at night and lets you name one (Almanac line). Goodie: `firefly-jar` 4% dp=night; crop `cacao` 8%.

**`end-delve-2-desert`** · ✂️ Trim the wicks · The Long Wall Walk (447), Rose-red Canyon City (401)
Hook: the wind made them sooty; trim them (Nimble 12) = they burn bright: one fewer wrong turn in the delve. Q1.
Villager: a **Fussy** lamp inspector walks the line at dusk and grades your trimming "in flames" (3 flames = c=20). Goodie: `mesquite-pods` 20%; `Desert Rose Stone` 4%.

**`end-delve-2-island`** · 🪶 Shoo the gulls · Pirate-gull Grottoes (376)
Hook: gulls sit on the lanterns stealing wicks; shoo them (Grit 11) or toss a `sardine` and they drop what they stole. Q1 FINALE.
Villager: a **Generous** fisher gnome swaps `sardine` x2 for your help. Goodie: gull drop: `minnow` 30%; a Shiny Button (new, collectible) 5%.

### Lairs, long approach (`end-lair-1-*`): "something big is thinking about you"

**`end-lair-1-desert`** · 🫧 Watch the shimmer · Lair of the Jade Dragon-fly (448)
Hook: the heat haze ripples in pairs of wings: hint "it is quick, Nimble matters"; offers Sneak. Q3. we=heat shows more.
Villager: a **Proud** lair-watcher tells a tall tale about the dragon-fly (dp=day): xp=6. Goodie: `Lizard Scale` 6%.

**`end-lair-1-island`** · 〰️ Read the tail-drag · Dragonlizard Den (458)
Hook: an S-shaped drag in the sand; fresh and warm = it is sunbathing (we=sun: "it is slow and full, Grit matters"). Offers Sneak. Q3.
Villager: a **Sleepy** beachcomber in the shade swears the lizard once napped next to him; fp=1. Goodie: `Coconut Husk` 10%; `pink-sand` 20%.

**`end-lair-1-mountain`** · 🔭 Peek over the ridge · Lair of the Grey Wolf King (389), Smokecap Caldera (327)
Hook: you see the Wolf King on a rock counting his pack (and losing count) / a salamander tail glowing in the crater (dp=night glows brighter). Shows the boss + a stat hint; offers Sneak. Q3.
Villager: a **Grumpy** shepherd who lost a sock to the wolf; find it nearby (Sense 11) = `wild-honeycomb` x1. Goodie: `Bushy Tuft` 8%; `Storm Feather` 4% we=storm.

### Lairs, threshold (`end-lair-2-*`): "the kind of place a very large friend might sleep"

**`end-lair-2-coast`** · 🪼 Spot the jelly-glow · Reef of the Box Jelly Queen (471)
Hook: count the glow pulses in the shallows: slow = she is sleepy (Sneak bonus), fast = come back later. Q2.
Villager: a **Chatty** reef warden at dusk warns you, then gives `samphire` "for courage". Goodie: `Eel Skin` 6%.

**`end-lair-2-desert`** · 📏 Measure the rut · Tomb of the Sand Scarab (402)
Hook: the dung-ball rut is "very respectably round"; its width says if the scarab has grown since your last visit (level hint). Q2.
Villager: a **Curious** beetle scholar measures it too, compares notes: xp=8. Goodie: `scarab-shell` 20%; `Wyrm Scale` 4%.

**`end-lair-2-forest`** · 🦋 Pick up a wing-scale · Temple of the Tiger Moth (435)
Hook: dust on the circle, gold and brown; its swirl says which way she sleeps (dp=day asleep, dp=night awake: "Charm works better than Grit"). Q2.
Villager: a **Dreamy** moth-watcher with a lantern at night; share the light = fp=1. Goodie: `wing-scale` 40%; `Antler Shard` 4%.

**`end-lair-2-mountain`** · 🐾 Read the footprints · Forge of the Cinder Wyrm (377), Condor's Crag (349), Snowcrown Peak (425)
Hook: the classic J scout: warm clawed prints / three-toed prints in a feather drift / big soft paws in snow. Shows the boss, one weakness hint, offers Sneak. Q2 finale beat.
Villager: **Captain Bracken Spurwing** himself checks this circle on his rounds (every 7th game day): a free Thornblade tip. Goodie: `bright-feather` 15%; `Golden Talon` 3%.

**`end-lair-2-rainforest`** · 🕸️ Pluck a web thread · Hollow of the Silverback Spider (415)
Hook: one gentle pluck: low hum = she is home, high hum = out picking fruit (come back for an easier start). Q2.
Villager: a **Fussy** silk weaver collects loose threads at dawn (dp=dawn); help = `silk-thread` x1. Goodie: `heartwood` 8%.

**`end-lair-2-tundra`** · 💤 Count the snores · Barrow of the Frost Toad (363)
Hook: each snore frosts the grass; many snores = a long nap = Sneak bonus. Q2 START (Lyra waits here the first time).
Villager: a **Warm** villager brings the toad a blanket on snow days (we=snow), "he is an old friend". Goodie: `Frost Crystal` 10% we=frost; `snow-moth-dust` 15%.

**`end-lair-2-wetland`** · 🦀 Follow the sideways tracks · Lair of the Hurricane Crab (340)
Hook: sideways, then sideways again (Nimble 11); you find its snack stash: hint "it is grumpy when hungry, bring food". Q2.
Villager: an **Eager** crab-sitter waits at low tide (dp=dawn) to feed it; bring `blue-mussels` = c=25. Goodie: `blue-mussels` 25%; `Titan Claw` 3%.

---

## 3. Uniqueness check

**Verbs (43, all different):** Sniff the breeze · Follow the mint · Clap the rhythm · Count the steam puffs · Wave at the boats · Read the back of the sign · Straighten the sign · Blow the tavern conch · Count the glimmers · Shade your eyes · Squint through amber · Hum with the stones · Trace the maze · Call the goats · Make a gate rubbing · Stand on one leg · Hold a shell to your ear · Whisper a question · Tiptoe in · Put a hand on the ground · Find the first star · Catch your breath · Sit very still · Count the wingbeats · Read the tide line · Wet a finger · Drop a pebble · Shout hello · Light a lantern · Float a candle · Borrow a firefly · Trim the wicks · Shoo the gulls · Watch the shimmer · Read the tail-drag · Peek over the ridge · Spot the jelly-glow · Measure the rut · Pick up a wing-scale · Read the footprints · Pluck a web thread · Count the snores · Follow the sideways tracks.
Near-twins kept apart on purpose: the four "Count ..." verbs count different things (steam / lights / wingbeats / snores) in different kinds; the four "Read ..." verbs read different surfaces (sign / tide / tail-drag / footprints).

**Clashes found and fixed while writing**
- `Sea Glass` was the goodie at both `end-haven-2-coast` and `end-delve-1-coast`: delve now `Pearl` 3%.
- `seed-pearl` at `end-wonder-2-coast` and `end-delve-2-island`: gulls now drop `minnow` / Shiny Button (new).
- `sea-salt` at `end-haven-2-coast` and the salt miner at `end-delve-2-forest`: miner now gives `rock-dust`.
- `silk-thread` at `end-wonder-2-grassland` and `end-lair-2-rainforest`: caravan now swaps `dried-figs`.
- `bright-feather` (wonder-1-wetland swap) vs `end-lair-2-mountain`: swap now gives Flamingo Feather (new).
- `Frost Crystal` at `end-haven-1-tundra` and `end-lair-2-tundra`: only the lair keeps it.
- `scarab-shell` at `end-delve-2-desert` and `end-lair-2-desert`: delve now `Desert Rose Stone`.
- `dragonfly-wing` (wonder-1-wetland) vs `end-lair-1-desert`: the lair now `Lizard Scale`.
- `pink-sand` at `end-wonder-1-desert` and `end-lair-1-island`: the salt flat now gives Mirror Salt Crystal (new).
- `goat-hair` at `end-wonder-1-mountain` and the shepherd at `end-lair-1-mountain`: shepherd now gives `wild-honeycomb`.
- Villager personality repeats (e.g. Eager at wonder-2-wetland, delve-2-rainforest, wonder-1-forest, lair-2-wetland) are fine: different region, time and offer. No two spots share verb + main goodie + story beat.

**Every spot has at least 2 of 3 uses:** all 43 have a quest beat (Q1-Q8) AND a villager point AND a goodie.

**Could not make fully unique:** none. Weakest: `end-wonder-2-forest` (5 places) and `end-haven-2-grassland` (5 places) share one verb across many destinations; the hook text changes per destination, so each route still reads differently.

**Questions for Josh**
1. Real forecast at `end-wonder-1-desert` and the Oasis whereabouts at `end-wonder-2-desert`: OK to give true info for free?
2. Lair hints name one stat ("Nimble matters"): enough, or too much of a spoiler?
3. Q2 lullaby buff *Hushed Steps* makes Sneak easier at every lair: fine, or lair-by-lair only?

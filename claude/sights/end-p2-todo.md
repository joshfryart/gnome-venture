# End pieces Trail Sights: what the P2 rows cannot do yet

Status: TODO list (2026-11-11). Rows: `game/includes/data/trail_sights_end.txt` (43 rows, lint clean). Ideas: `claude/sights/ideas-end-pieces.md`.
Each row holds the simple version: the scout verb, XP + `first:xp=`, a hint written into the win line, one goodie at modest odds (all items exist), `reveal` where the idea shows a place. Everything below needs engine work or new items later.
Line kinds: QUEST, VILLAGER, NEW ITEMS, MINIGAME, PER-DESTINATION TEXT, OTHER (mechanics not in the grammar).

## Global notes
- Verbs shortened for the 24-character lint limit: `end-haven-2-grassland` "Read the sign's back" (idea: "Read the back of the sign"), `end-lair-2-wetland` "Follow sideways tracks" (idea: "Follow the sideways tracks").
- Goodies dropped for lack of an item: none. Every backticked goodie in the ideas exists. Only the (new) items are missing (listed per slug).
- Stand-ins for (new) items: Shiny Button -> `shiny-trinket`; Lucky Wick -> `buff=luck:1:60`; Flamingo Feather -> `pretty-feather` as a plain drop; wetland "region flower" -> `cut-blue-lotus`.
- Villager points are folded in as a conditional goodie where the villager hands out an existing item at a set time (mint tea at dawn, lemon at dawn, hot cocoa on snow days, cold brew at dawn, rock dust at dusk, silk thread at dawn, samphire at dusk, date syrup at dusk, mango on rainy dawns, bamboo shoot by day, c=20 at dusk). The person, the swap and the friendship are TODO.
- `fp=` was not used: it befriends a random folk of the walk's start place, not the named villager.
- One stat buff slot (`ev_stat`): at most one `buff=` per row.
- Every lair scout "offers Sneak" (a Sneak bonus at the lair): not in the grammar. The stat hint is in the win line only.
- Hints are fixed text, not true state (tide, current channel, snore count, glow speed, forecast). A real hint needs per-use state from the place.
- Quest task kind `sight` (`T|...|event|sight|slug=end-...|1|label`) is needed for every QUEST line below. Quest tokens Snore Note, Gate Rubbing, Hush Page, Echo Map page, Spoons are all new.

## Havens, path (`end-haven-1-*`)
### end-haven-1-grassland
- QUEST: Q6 Follow Your Nose, beat 1 (guess the dish, earn Spoons).
- VILLAGER: a Chatty local walking home from the tearoom, dp=dusk: free shop peek of today's shelf item.
- OTHER: a right guess should hold one for you (rest price -10% today). `hen-egg` should be painted and only for the Painted Egg House.
- PER-DESTINATION TEXT: scones (Thatchtop Tearoom) / painted-egg bread (Painted Egg House).
### end-haven-1-coast
- QUEST: Q6 beat (mint tea).
- VILLAGER: a Generous stall runner, dp=dawn, free `mint-tea` once per walk (row: 15% at dawn).
- OTHER: arrive 10 game minutes sooner (no time token); `reveal` stands in for "the steam knows the way".
### end-haven-1-island
- QUEST: Q6 beat (kava).
- VILLAGER: a Dreamy islander, dp=night we=sun/cloud, shares a story, +1 friendship.
- OTHER: a seat saved = rest price -25% today. `kava` was a crop= reward, paid as the item.
### end-haven-1-tundra
- QUEST: Q6 beat (sauna buns).
- VILLAGER: a Grumpy regular on snow days, walk with him -> `hot-cocoa` (row: 20% we=snow).
- NEW ITEMS: sauna buns.
- OTHER: puffs = free benches inside; the odd-number aurora hint should raise the sauna's night Luck buff odds (row: a Luck buff at dusk/night).
### end-haven-1-wetland
- QUEST: Q6 beat (noodle steam / flower honey).
- VILLAGER: a Cheerful boat gnome, dp=dawn, ride along = skip the last stretch (short hop).
- PER-DESTINATION TEXT: Floating Flower Market (flower honey) / Floating Market (noodle steam).
- OTHER: "a region flower" is fixed to `cut-blue-lotus`.

## Havens, last turn (`end-haven-2-*`)
### end-haven-2-grassland
- QUEST: Q7 Rest Here, Repainted, beat 1 (repaint with `red-ochre`; Tobias's initials on the back).
- VILLAGER: a Sleepy villager napping against the post, dp=day we=sun: let them sleep = Luck buff (row: buff on that condition), wake them = `cornbread` (row: 15% always). Needs a choice.
- PER-DESTINATION TEXT: blossom count (Cherry Blossom Teahouse) / chili heat (Market of a Thousand Chilies) / tonight's drum song (Drum Circle Market) / which pony is friendly (Gaucho Gnome Ranch) / rooms free (Baobab Inn).
### end-haven-2-coast
- QUEST: Q7 beat 2 (straighten and repaint).
- VILLAGER: a Fussy monk, dp=dawn, `lemon` if the sign is level (row: 20% at dawn).
- OTHER: at Turtle Nesting Beach in summer, turn the sign seaward = a Charm buff there.
- PER-DESTINATION TEXT: Olive Press Piazza / Lemon Grove Monastery / Turtle Nesting Beach.
### end-haven-2-island
- QUEST: Q7 finale (Tobias signs the last sign; c=120 + `scute-wind-chime`).
- VILLAGER: Lyra Fiddlewing when she is in the Sunsprinkle Isles: a half-price song.
- OTHER: free peek at the tavern bar's stock.

## Wonders, gates (`end-wonder-1-*`)
### end-wonder-1-coast
- QUEST: Q4 Wren's Gate Rubbings (a gate).
- VILLAGER: a Shy local at night, teaches the `firefly-jar` recipe.
- NEW ITEMS: an Almanac constellation page (unlock target).
- MINIGAME: name the shape the lights make.
- PER-DESTINATION TEXT: Glowworm Grotto / Lantern Festival River.
### end-wonder-1-desert
- QUEST: Q4 (a gate).
- VILLAGER: a Curious villager measuring the reflection; give `desert-glass` -> Sense +1 120 min (row: Sense buff after rain).
- NEW ITEMS: Mirror Salt Crystal (5% we=rain).
- OTHER: the true tomorrow forecast on the card (question 1 for Josh). The line only says gnomes read it there.
### end-wonder-1-forest
- QUEST: Q4 (a gate).
- VILLAGER: an Eager young digger, se=spring, help carry the spade -> `pine-resin` x2 (row: 30% x2 in spring).
- NEW ITEMS: Amber Seed (3%).
- OTHER: dp=day only for the amber hint; tell which seed you can dig here today.
### end-wonder-1-grassland
- QUEST: Q4 finale at dusk (riddle lines read in order; old-world seed + title Gate Gazer).
- VILLAGER: Wren Thimblewick, se=autumn dp=dusk, reads rubbings and swaps one seed.
- PER-DESTINATION TEXT: The Standing Stones / The Hanging Garden Ruins.
- OTHER: double first-visit XP at dusk is paid as a second `first:xp=15?dp=dusk`.
### end-wonder-1-island
- QUEST: Q4 (a gate).
- VILLAGER: a Proud local who "solved it 40 times", +1 friendship for being polite.
- MINIGAME: trace the maze.
- OTHER: the first right turn should come from the real Labyrinth map; the line says "right" always.
### end-wonder-1-mountain
- QUEST: Q4 (a gate).
- VILLAGER: a Warm vintner, se=autumn, `grape` x2 for helpers (row: 30% x1 in autumn).
- OTHER: follow the goat = 10 game minutes saved (row: `reveal`).
- PER-DESTINATION TEXT: Goat Path Vineyards / The Sky City Ruins.
### end-wonder-1-rainforest
- QUEST: Q4 START (Wren hands you paper and crayon here).
- VILLAGER: a Fussy gate-sweeper, dp=dawn, wipe your feet and she hints the riddle.
- NEW ITEMS: Gate Rubbing (quest token with a riddle line).
- PER-DESTINATION TEXT: steps (The Stepped Seed Temple) / roots (Root-wrapped Temple) / falling water (The Singing Waterfall), one riddle line each.
### end-wonder-1-wetland
- QUEST: Q4 (a gate).
- VILLAGER: a Cheerful feather-crafter on market days, swaps `pretty-feather` for a Flamingo Feather.
- NEW ITEMS: Flamingo Feather (row drops `pretty-feather` instead).

## Wonders, the hush (`end-wonder-2-*`)
### end-wonder-2-coast
- QUEST: Q5 The Book of Hushes (a Hush Page).
- VILLAGER: a Chatty pearl diver, dp=day we=sun, one rumour from `teahouse_rumours`.
- PER-DESTINATION TEXT: where divers found pearls today (Pearl Diver Cove) / which seed chest is open (Sunken Gnome Galleon).
### end-wonder-2-desert
- QUEST: Q5 (a Hush Page).
- VILLAGER: a Dreamy wanderer who follows the Oasis, `date-syrup` at dusk (row: 15% dp=dusk).
- PER-DESTINATION TEXT: the Cenote of Echoes answers in rhyme / the Oasis That Moves tells which village it is in today (question 1 for Josh). Row: `reveal`.
### end-wonder-2-forest
- QUEST: Q5 START.
- VILLAGER: a Sleepy keeper, dp=day, don't wake them -> `bamboo-shoot` (row: 15% dp=day).
- OTHER: Sneak stance should help (no stance condition in the grammar). `tea` was a crop= reward, paid as the item.
- PER-DESTINATION TEXT: a red gate swinging (The Thousand Gates) / a panda yawning (Panda Bamboo Grove) / mushrooms leaning in (Fairy-ring Clearing) / pickers mid-song (Tea Garden Slopes) / a stone head opening one eye (Stone Head Watchers).
### end-wonder-2-grassland
- QUEST: Q5 (a Hush Page).
- VILLAGER: a Generous caravan gnome swaps `dried-figs` for any seed.
- PER-DESTINATION TEXT: rumbling, the herd passes today, Luck +1 120 min (The Great Migration) / jingling, a caravan is in, one extra seed swap (The Silk Road Caravanserai). Row: Luck +1 60 min everywhere.
### end-wonder-2-island
- QUEST: Q5 (a Hush Page).
- VILLAGER: a Proud navigator at dusk corrects your star name kindly, xp=8 (row: `first:xp=10`).
- OTHER: your next Trail walk 10 game minutes shorter (row: `reveal`). `vanilla` was a crop= reward, paid as the item.
- PER-DESTINATION TEXT: Starpath Canoe / Volcano Spice Gardens.
### end-wonder-2-mountain
- QUEST: Q5 (a Hush Page).
- VILLAGER: a Warm coffee-hut host at dawn with a flask, `cold-brew-coffee` (row: 15% dp=dawn).
- PER-DESTINATION TEXT: flags snapping (Prayer-flag Pass) / cedar (Cedar Sanctuary) / coffee roasting (Coffee Ceremony Hut).
### end-wonder-2-rainforest
- QUEST: Q5 (a Hush Page).
- VILLAGER: a Shy villager brings fruit on rainy mornings; help carry -> `mango` (row: 15% we=rain dp=dawn).
- PER-DESTINATION TEXT: a gorilla sits beside you (Gorilla Glade) / a dolphin blows a bubble ring (Pink River Dolphin Pools).
- OTHER: the Charm buff should hold "for the wonder" only (it is a plain 120 min buff).
### end-wonder-2-wetland
- QUEST: Q5 FINALE outside the Mud Mosque Library (bind the book: Book of Hushes decor + `sages-draught`).
- VILLAGER: an Eager letter-carrier, dp=day, hands you a real Letter from a friend villager (hook into `letters.php`).
- NEW ITEMS: Book of Hushes (hovel decor).
- PER-DESTINATION TEXT: storks pick a chimney, sometimes yours (Stork Chimney Village) / swallows = scrolls out today (Mud Mosque Library).

## Delves, mine mouth (`end-delve-1-*`)
### end-delve-1-coast
- QUEST: Q8 The Echo Map, beat 1.
- VILLAGER: a Grumpy retired smuggler, dp=dusk, honest `rope` at half price (row: `rope` 10% at dusk).
- OTHER: a win should make the first room a dry one.
### end-delve-1-desert
- QUEST: Q8 beat.
- VILLAGER: a Curious songline walker at dawn, learn a verse = Lore +1 60 min (row: buff at dawn).
- PER-DESTINATION TEXT: which way the long song goes (The Red Rock Songlines) / which trail burned lately, skip the scorched room (Fynbos Fire Trails).
### end-delve-1-mountain
- QUEST: Q8 beat.
- VILLAGER: a Proud mountain guide walks the first ledge for one `goat-cheese` (Nimble +1 in the delve): needs a take + a delve-scoped buff.
- OTHER: the ledge count should be the real number of ledges before the first rest spot.
### end-delve-1-rainforest
- QUEST: Q8 FINALE (the echo answers in Tumble's voice; title Echo Reader + `hiking-staff`).
- VILLAGER: a Cheerful bridge-mender at dawn; carry her `rope` = xp=10 and a safer first bridge.
- OTHER: first room hint; a howler monkey shouts back on a lucky day.
- PER-DESTINATION TEXT: echo from above (The Canopy Bridges) / along the creek (Anaconda Hollows).

## Delves, lantern line (`end-delve-2-*`)
### end-delve-2-forest
- QUEST: Q1 The Lamplighter's Round START (Burdock hands you a taper). Finale reward `glowcap-lantern` + title Lamplighter.
- VILLAGER: a Shy salt miner at dusk by a lit lantern, leaves `rock-dust` (row: 20% dp=dusk).
- NEW ITEMS: taper.
- OTHER: the Sense buff should last for the delve only. Row needs a lantern tool tier 1 (`tin-lantern` or better).
### end-delve-2-wetland
- QUEST: Q1 beat 2.
- VILLAGER: a Dreamy boat gnome returns a Lucky Wick (+1 Luck in the next delve).
- NEW ITEMS: Lucky Wick (row: Luck +1 60 min).
- OTHER: the channel hint should be the real safe route through the first fork. Row takes 1 `beeswax-candles`.
### end-delve-2-rainforest
- QUEST: Q1 beat 3.
- VILLAGER: an Eager young lantern-keeper counts fireflies at night and lets you name one (Almanac line).
- OTHER: easier at dp=night (no condition on the DC); "free light, no lantern needed" should count as a lantern in the delve. `cacao` was a crop= reward, paid as the item.
- PER-DESTINATION TEXT: Jaguar Root Caves / Firefly Caves.
### end-delve-2-desert
- QUEST: Q1 beat 4.
- VILLAGER: a Fussy lamp inspector at dusk grades your trimming in flames (3 flames = c=20; row: c=20 20% at dusk).
- MINIGAME: the flame grade.
- OTHER: one fewer wrong turn in the delve.
- PER-DESTINATION TEXT: The Long Wall Walk / Rose-red Canyon City.
### end-delve-2-island
- QUEST: Q1 FINALE (all five lit in one season).
- VILLAGER: a Generous fisher gnome swaps `sardine` x2 for your help.
- NEW ITEMS: Shiny Button (row: `shiny-trinket` 5%).
- OTHER: "or toss a `sardine`": a second way past the Grit check (take=sardine:1 instead of the roll).

## Lairs, long approach (`end-lair-1-*`)
### end-lair-1-desert
- QUEST: Q3 The Scout's Field Notes, beat 1. Reward Scout's Spyglass (new trinket: +1 Sense on every end-piece scout).
- VILLAGER: a Proud lair-watcher, dp=day, tall tale, xp=6.
- NEW ITEMS: Scout's Spyglass.
- OTHER: offers Sneak; we=heat "shows more" (row: +2 XP in heat).
### end-lair-1-island
- QUEST: Q3 beat 2.
- VILLAGER: a Sleepy beachcomber in the shade, +1 friendship.
- OTHER: offers Sneak; the "sunbathing, Grit matters" hint should only show with we=sun.
### end-lair-1-mountain
- QUEST: Q3 beat 3, then defeat or befriend one of the three bosses.
- VILLAGER: a Grumpy shepherd who lost a sock to the wolf; find it (Sense 11) -> `wild-honeycomb` (row: 10% plain drop, no check).
- OTHER: offers Sneak; the caldera glows brighter at dp=night.
- PER-DESTINATION TEXT: the Wolf King counting his pack and losing count (Lair of the Grey Wolf King) / a salamander tail glowing in the crater (Smokecap Caldera). Row keeps the counting line, unnamed.

## Lairs, threshold (`end-lair-2-*`)
### end-lair-2-coast
- QUEST: Q2 A Lullaby for Big Friends (a Snore Note: the slow glow-pulse).
- VILLAGER: a Chatty reef warden at dusk, `samphire` "for courage" (row: 20% at dusk).
- OTHER: slow pulses = Sneak bonus, fast = come back later (needs state; the line always says slow).
### end-lair-2-desert
- QUEST: Q2 (a Snore Note: the rolling rhythm).
- VILLAGER: a Curious beetle scholar compares notes, xp=8.
- OTHER: the rut width should say if the scarab has grown since your last visit (level hint, needs per-gnome state).
### end-lair-2-forest
- QUEST: Q2 (a Snore Note: the wing-dust rustle).
- VILLAGER: a Dreamy moth-watcher with a lantern at night; share the light = +1 friendship.
- OTHER: asleep at dp=day, awake at dp=night (the line says she sleeps by day).
### end-lair-2-mountain
- QUEST: Q2 finale beat (three sets of footprints, three beats).
- VILLAGER: Captain Bracken Spurwing on his rounds every 7th game day: a free Thornblade tip.
- OTHER: shows the boss, one weakness hint, offers Sneak.
- PER-DESTINATION TEXT: warm clawed prints (Forge of the Cinder Wyrm) / three-toed prints in a feather drift (Condor's Crag) / big soft paws in snow (Snowcrown Peak).
### end-lair-2-rainforest
- QUEST: Q2 (a Snore Note: the web hum).
- VILLAGER: a Fussy silk weaver at dawn, help = `silk-thread` (row: 15% at dawn).
- OTHER: low hum = home, high hum = out picking fruit (easier start): needs state; the line always says low.
### end-lair-2-tundra
- QUEST: Q2 START (Lyra waits here the first time).
- VILLAGER: a Warm villager brings the toad a blanket on snow days.
- OTHER: many snores = Sneak bonus.
### end-lair-2-wetland
- QUEST: Q2 (a Snore Note: the click-clack walk).
- VILLAGER: an Eager crab-sitter at low tide (dp=dawn); bring `blue-mussels` = c=25 (take + coin on a time condition: needs a conditional take).

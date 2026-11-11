# Shared land Trail Sights: what the P2 rows cannot do yet

Status: TODO list (2026-11-11). Rows: `game/includes/data/trail_sights_shared.txt` (89 rows, lint clean; the other 5 shared pieces are the examples in `trail_sights.txt`). Ideas: `claude/sights/ideas-shared-land.md`.
Each row holds the simple version (base verb + goodies the reward grammar can pay). Everything below needs engine work or new items in a later phase.
Line kinds: QUEST (line + beat), VILLAGER (who, when, what), NEW ITEMS, MINIGAME, OTHER (mechanics not in the grammar).

## Global notes
- Verb clashes with Maplewold: daisy ring "Count" -> "Measure up", lagoon edge "Peer" -> "Mirror".
- Items replaced with an existing one: blackberries -> `raspberry`; dandelion seed -> `seed=1` (random local seed); rope-cattail -> `rope`; Bluebell Bulb -> `bluebell-seed`; Cactus Bloom -> `nopal-seed`; Dew Pearl -> `clean-dew`; Flat Salt -> `sea-salt`; Orchid Cutting -> `cut-moth-orchid`; Heron's Programme Notes -> `long-feather`; Lantern Fruit Seed -> `lanternroot`; Giant's Bark Curl -> `cork-bark`; Brass Button / Wishing Coin / Marrowby's Wooden Coin -> a few coins (`c=`); Pine-Snow Cone -> `en=1`; Gull's Medal -> `gull-feather`; Bell Shell -> `tide-shell`.
- `fp=1` stands in for most villager points: it befriends a random villager of the walk's start town, not the named one.
- Stat checks stand in for every "pick kind" / "power kind" mini game (root tangle, mud skippers, scree, ice steps ...).
- Only one stat buff slot is used by `buff=`, so each row has at most one buff (conditional ones never overlap).
- Quest task kind `sight` (plan 0.4) is needed for every QUEST line below (KITE, HAT, BRIDGE, HELLO, STARS, PICNIC, SONG, TRADER, LADDER).
- Clover patch, shell heap, rope bridge, old milestone and reef shallows keep their example rows; their QUEST / VILLAGER / NEW ITEMS from the ideas file are still open (BRIDGE 4, TRADER 4, Clover Ledger, Five-Leaf Clover, Left-Handed Spiral, Starfish Friend, Knot Book, Milestone Collector).

## Grassland
### grassland-the-plank-footbridge
- QUEST: BRIDGE 1.
- VILLAGER: Proud villager, dp=dawn, away day; rate the bridge (charm 10) -> +3 friendship.
### grassland-the-picnic-knoll
- QUEST: PICNIC 1 and 6.
- VILLAGER: Warm villager, se=summer dp=day, shares custard tart (row: 30% custard-tart at that time).
- NEW ITEMS: Tiny Thank-You Seed (row: `seed=1@8`).
- OTHER: snack buff lasts twice as long here.
### grassland-the-bramble-gap
- MINIGAME: "One Opinion": Grumpy villager stuck halfway, dp=day, away day; agree (charm 11 or luck 12) -> Grumpy's Hedge-Shears.
- NEW ITEMS: Grumpy's Hedge-Shears, Lost Sock (joke item). Blackberries paid as `raspberry`.
### grassland-the-shepherd-s-wall
- VILLAGER: Fussy villager, dp=dusk, gives `hen-feather` for manners (row: 30% at dusk).
- MINIGAME: "Count the Sheep": three night uses -> Sleep-Counter buff (+2 energy at next sleep) (row: 25% +1 energy at night).
- NEW ITEMS: Tuft of Fleece.
### grassland-the-wind-combed-meadow
- QUEST: KITE 1 (Kite-String Spool, new).
- VILLAGER: Dreamy kite-maker, we=wind dp=day; fly a kite -> +1 sense (row: the sense buff on windy days, no villager).
- OTHER: after KITE, a line of tomorrow's weather.
### grassland-the-dandelion-drift
- MINIGAME: "Wish Delivery": a villager in the next town thanks you 3 game days later (+5 friendship).
- VILLAGER: Shy villager, se=spring, whispers their wish (fp +2) (row: `fp=1@20?se=spring`).
### grassland-the-sleepy-windmill
- QUEST: PICNIC 2.
- VILLAGER: Sleepy villager on the sacks, dp=dawn; wake gently (sense 10) -> `pancakes` (row: 10% pancakes at dawn).
- NEW ITEMS: Picnic Flour (swap 2 grain -> 1 flour; row pays coins instead, double chance on windy days).
### grassland-the-daisy-ring
- MINIGAME: "Who Measured?": measure in 3 seasons -> a Fussy villager's grandmother with a ruler.
- NEW ITEMS: Daisy-Chain Crown (+charm). Dew Pearl paid as `clean-dew`.
### grassland-the-lonely-scarecrow
- QUEST: HAT 1 and 5 (Sir Barnaby, new).
- VILLAGER: Shy villager, dp=dusk, tells the scarecrow their worries; sit with them (+2 friendship).
- OTHER: `black-feather` added as a crow goodie (not in the ideas).
### grassland-the-hay-cart-ruts
- QUEST: TRADER 5.
- VILLAGER: Cheerful villager, se=autumn dp=day, hay-ride to the next section (skip 10 game minutes).

## Forest
### forest-the-lantern-branch
- VILLAGER: the Wick-Keeper (Sleepy), dp=dusk, away day; if you trimmed it last time, leaves a `tin-lantern` once (needs "trimmed last time" state).
- MINIGAME: "Keep It Lit": 3 different nights -> title Lamplighter.
### forest-the-root-tangle-crossing
- MINIGAME: pick the right three steps (pick kind, n=3); row uses nimble 10.
- VILLAGER: Eager young villager, dp=day, root race (nimble 11) -> +3 friendship.
- NEW ITEMS: Root-Race Ribbon.
### forest-the-spring-and-the-pebbles
- VILLAGER: Wren Thimblewick, dp=dawn; trades a seed for any pebble found today.
### forest-the-owl-watch-bough
- QUEST: HAT 2 (dp=night, trade a `hen-feather`).
- MINIGAME: "Owl Manners": 3 wins -> Almanac sighting Bough Owl.
- OTHER: `owl-feather` 10% added (not in the ideas).
### forest-the-glow-moss-grotto
- VILLAGER: Shy villager's reading nook, we=rain; borrow a book, return it next visit -> +5 friendship.
- NEW ITEMS: Glow-Moss Nightlight, Bookmark Snail (the row has no item goodie at all).
### forest-the-fern-tunnel
- VILLAGER: Grumpy villager, we=rain; walk together -> +3 friendship.
- NEW ITEMS: Fern-Drip Hat Charm.
### forest-the-acorn-scatter
- MINIGAME: three holes (pick kind); "Bad Day, Good Day": 3 autumn days -> Hazel's gift.
- NEW ITEMS: Squirrel's Spare Key; Hazel Fluster (named squirrel). `hazelnut` 15% in autumn added.
### forest-the-hollow-oak
- QUEST: PICNIC 3 (six acorn teacups).
- VILLAGER: Chatty villagers, se=winter dp=day; sixth seat -> gossip hint about a Trail find ahead.
- OTHER: "needs a cooked item" (any cooked food) cannot be a `take=` (needs one slug).
### forest-the-mushroom-ring
- VILLAGER: Dreamy villager, we=fog, dances in the ring; join (luck 10) -> +4 friendship.
- NEW ITEMS: Toadstool Stool (decor).
### forest-the-mossy-stair
- VILLAGER: Warm elderly villager, dp=dawn; carry her basket (escort) -> `raspberry-jam` (row: 8% at dawn).
- NEW ITEMS: Brass Button (row: a few coins).
### forest-the-woodcutter-s-stump
- MINIGAME: "Axe in the Stump": first win ever -> Teeny Axe (+1 to Snip at the bramble gap). Ideas DC grit 13, row 12.
- VILLAGER: Proud retired woodcutter, se=autumn, gives `oak-log` (row: 15% in autumn).
- NEW ITEMS: Teeny Axe.
### forest-the-fallen-log-bridge
- QUEST: BRIDGE 2.
- MINIGAME: "Politeness Contest": bow 5 times on one walk -> 30 xp.
### forest-the-bluebell-glade
- QUEST: SONG 4.
- VILLAGER: Lyra Fiddlewing, se=spring dp=dawn; free song, +1 charm (row: the charm buff then, no Lyra).
- OTHER: check easier in spring (no seasonal DC in the grammar). Bluebell Bulb paid as `bluebell-seed`.

## Wetland
### wetland-the-mud-skipper-flats
- MINIGAME: pick a winner (pick kind); row uses luck 11.
- VILLAGER: Eager villager, dp=day, runs a book: right pick +3 fp (row: `fp=1@20?dp=day`).
- NEW ITEMS: Mudskipper Medal.
### wetland-the-stilt-house
- QUEST: LADDER 1 and 5.
- VILLAGER: Sleepy owner, dp=dusk, away day: after LADDER, a nap (+3 energy, 1 h).
- OTHER: reply should depend on the hour. `woven-basket` (a tool) cut to 5% from the ideas' 10%; biscuit not paid.
### wetland-the-willow-curtain
- VILLAGER: Shy villager behind it, we=fog; talk without looking (sense 11) -> +4 friendship.
- NEW ITEMS: Willow Withies, Icicle Chime (row: seasonal goodies from existing items instead).
### wetland-the-peat-bank
- VILLAGER: Grumpy library lover, we=rain; guess the book -> +4 friendship and an Almanac lore page.
- NEW ITEMS: Bog-Pressed Bookmark.
### wetland-the-frog-choir
- QUEST: SONG 1.
- VILLAGER: Cheerful tenor, dp=dusk se=spring; join (charm 10) -> +3 friendship (row: charm buff at dusk).
### wetland-the-boardwalk-gap
- QUEST: BRIDGE 3 (`timber-plank`).
- OTHER: either/or (fit a plank OR hop nimble 9) is not in the grammar; row is the hop at nimble 10.
- MINIGAME: "The Missing Plank": return it 3 sections later -> Plank's Gratitude (new, coaster).
### wetland-the-lily-pad-ford
- VILLAGER: frog-species villager, we=rain, coaches: next crossing Sight +2.
### wetland-the-dragonfly-bend
- VILLAGER: Fussy seamstress, se=summer dp=day; bring 3 `dragonfly-wing` -> Blue-Stitch Hat Patch (new).
### wetland-the-reed-causeway
- QUEST: LADDER 2.
- VILLAGER: Generous villager, dp=dawn, cutting reeds; help bundle -> rope-cattail (no such item; row: 10% `rope` at dawn).
### wetland-the-heron-s-post
- VILLAGER: Proud critic, we=fog; agree it was "luminous" -> +3 friendship.
- MINIGAME: "Encore": 3 foggy days -> heron drops a `perch` (row: 10% perch on foggy days).
- NEW ITEMS: Heron's Programme Notes (row: `long-feather`).

## Mountain
### mountain-the-scree-slope
- MINIGAME: step on the right stones (pick kind; row uses nimble 12); "Scree Song": 3 weathers -> Scree Xylophone (new, decor).
- VILLAGER: Chatty villager, dp=day se=summer, sings along (+2 fp).
### mountain-the-pine-shelf
- VILLAGER: Shy villager, we=wind, holding on too -> +4 friendship.
- NEW ITEMS: Pine-Snow Cone (row: 10% +1 energy in winter).
### mountain-the-wind-notch
- QUEST: KITE 2 (we=wind).
- VILLAGER: Dreamy villager, dp=dusk; say what the notch played (lore 10) -> +3 fp.
- NEW ITEMS: Pocket Whistle.
- OTHER: "headwind" in bad weather (a penalty) not done; row gives a nimble buff in wind/storm and +1 energy on calm days.
### mountain-the-goat-ledge
- QUEST: LADDER 3.
- VILLAGER: Warm goatherd, se=spring, gives `goat-hair` if the goat let you sit (row: 20% in spring).
- OTHER: "offer a snack" could be a `take=` once a snack slug is picked.
### mountain-the-waterfall-mist
- VILLAGER: Dreamy painter, dp=dawn; hold her brushes -> Waterfall Sketch (new, decor).
- NEW ITEMS: Bottled Rainbow (row: luck buff on sunny days instead).
### mountain-the-eagle-s-rest
- QUEST: STARS 3 (dp=night, not fog).
- VILLAGER: Grumpy villager, dp=dawn; leave them alone properly (sense 11) -> +5 fp later in town.
### mountain-the-stone-hut
- QUEST: LADDER 4.
- VILLAGER: Sleepy villager on holiday, se=winter, away day; toast bread -> `hot-cocoa` (row: 15% in winter).
- NEW ITEMS: Visitors' Book page.
- OTHER: "needs a log" is `take=pine-log:1` (any log would be nicer); rest should take 1 game hour.
### mountain-the-echo-wall
- QUEST: SONG 2.
- MINIGAME: "Out-Cheek the Echo": 3 charm 12 wins -> title Last Word. Random cheeky echo line.
- NEW ITEMS: Echo Pebble.
### mountain-the-switchback-bend
- VILLAGER: Tobias Trundle, dp=day; walk one bend with him (escort) -> his rare seed 20% cheaper.
- OTHER: the missed find should be one land `rand:forage`; row uses `find=1@15` and `reveal@10`.
### mountain-the-cairn-pass
- MINIGAME (shared, P4): every 100 stones from all players -> Cairn Token (new) for everyone who added one; shared count on the card.
- VILLAGER: Proud villager, we=snow; add to his cairn (+3 fp) or the shared one (+xp).

## Coast
### coast-the-lighthouse-shadow
- QUEST: STARS 5 (dp=night).
- VILLAGER: the Keeper (new, Generous mole), dp=night we=fog; fish-shoal tip: next fishing Sight +1 catch.
- OTHER: `moonfish` should need a rod; row needs a lantern (to signal) and pays it without a rod.
### coast-the-kelp-line
- VILLAGER: Pomeroy Crumbworth, se=summer dp=dusk; 2 `bladderwrack` for his review -> spoon rating, 40 xp.
### coast-the-rope-and-net-rack
- QUEST: HAT 3.
- VILLAGER: Grumpy fisher, dp=dawn; mend a net (lore 10) -> `sardine` x2 (row: 20% at dawn, no check).
- NEW ITEMS: Gull's Medal of Not Really Trying (row: `gull-feather`).
### coast-the-bottle-post
- QUEST: HELLO 1.
- MINIGAME (shared, P4): leave a note for the next player, read theirs (moderated).
### coast-the-tide-pool-steps
- MINIGAME: "Crab Court": judge fairly on 3 visits -> Crab Gavel (new, keepsake).
- VILLAGER: Curious villager, dp=day, low tide, counts crabs (+2 fp).
### coast-the-stranded-rowboat
- VILLAGER: Grumpy old fisher, we=storm; help push -> +4 fp (row: `fp=1@20?we=storm`).
- OTHER: at dawn high tide, row a short hop (skip 1 section's walk time). Grit 11 check added (not in the ideas).
### coast-the-sandbar-causeway
- VILLAGER: Eager villager, dp=dusk, times you; beat their time -> +3 fp; 5 wins -> title Sandbar Sprinter.
### coast-the-barnacle-wall
- MINIGAME: "The Barnacle Joke Book": 5 different jokes over 5 visits -> Almanac lore pun.
- NEW ITEMS: Barnacle Giggle.
### coast-the-dune-grass-sweep
- QUEST: KITE 3.
- VILLAGER: Lyra Fiddlewing, we=wind dp=dusk; be her audience -> +1 charm (row: the charm buff then, no Lyra).
### coast-the-driftwood-arch
- VILLAGER: Cheerful villager, we=wind; share a snack -> +3 fp (row: `fp=1@15?we=wind`).
- MINIGAME: "Wind Rhythm" (pick kind) x3 -> Arch Shell Mobile (new, decor).
### coast-the-sea-stack-gap
- VILLAGER: Eager villager, se=summer, dare (grit 11) -> Dare Pebble (new).
- OTHER: the nimble buff is 20 min as written.

## Desert
### desert-the-sun-bleached-bones
- VILLAGER: Curious villager, dp=day; stop them asking (charm 10) -> +3 fp.
- OTHER: rest 20 game minutes.
### desert-the-salt-flat
- MINIGAME: "Write It Big": collect your name letter by letter -> Salt Sign (new, decor).
- VILLAGER: Pomeroy, we=heat; give 1 salt -> spoon rating, 30 xp.
- NEW ITEMS: Flat Salt (row: `sea-salt` 25%, no bucket needed; ideas: bucket 35%).
### desert-the-shade-awning
- VILLAGER: Sleepy villager, dp=day, away day; nap beside them (luck 9) -> +4 fp.
- NEW ITEMS: Dream Souvenir; random Dream line per nap.
- OTHER: nap 2 game hours.
### desert-the-red-rock-arch
- QUEST: STARS 4 (dp=dusk).
- VILLAGER: Dreamy villager, dp=dusk; share the glow -> +3 fp.
### desert-the-sand-ripple-lane
- QUEST: TRADER 2.
- MINIGAME: "Washboard Band" (power kind) -> 25 xp and an Almanac song line.
### desert-the-waystone-cluster
- QUEST: TRADER 3.
- VILLAGER: Chatty villager, se=autumn; hint for the next town's market.
- OTHER: the rumour should mark a Trail find on this route (row: `reveal@10`).
### desert-the-dry-riverbed
- MINIGAME: "The River Visits": on a rain day dig for a guaranteed River's Postcard (new).
- NEW ITEMS: Old River Pebble.
- OTHER: no spade tool; row needs a pick.
### desert-the-mirage-pool
- QUEST: HELLO 3.
- VILLAGER: Wren Thimblewick, we=heat; say what you felt (lore 11) -> seed trade.
- NEW ITEMS: Mirage Marble (row: energy and a random find instead).
### desert-the-cactus-garden
- QUEST: HAT 4.
- VILLAGER: Proud brave waterer, dp=dawn, away day; let them show off -> +3 fp.
- NEW ITEMS: Cactus Bloom (row: `nopal-seed`).
### desert-the-trader-s-tent-poles
- QUEST: TRADER 1 (Old Marrowby, new).
- VILLAGER (after TRADER): Old Marrowby, se=autumn, barter stall: 3 of one land find for 1 of another.
- NEW ITEMS: Marrowby's Wooden Coin (row: coins).
### desert-the-well-and-its-rope
- QUEST: PICNIC 4.
- VILLAGER: Generous villager, we=heat dp=day, cold water +2 energy (row: `en=2` then, no villager).
- NEW ITEMS: Wishing Coin (row: `c=5@6`).

## Rainforest
### rainforest-the-stepping-roots
- VILLAGER: gecko-species villager, we=rain, race; let them win +3 fp, beat them 30 xp.
### rainforest-the-giant-fern-glade
- MINIGAME: "Who Is It?": 3 rounds, Almanac sightings.
- VILLAGER: Eager villager, dp=day, plays seeker -> +3 fp (row: `fp=1@15?dp=day`).
- NEW ITEMS: Giant Fern Spores.
### rainforest-the-orchid-tree
- VILLAGER: Proud gardener, dp=dawn se=spring; honest answer -> +3 fp and an Orchid Cutting (row: 5% `cut-moth-orchid` then).
### rainforest-the-canopy-gap
- VILLAGER: Dreamy villager, we=sun dp=day; share the sunbeam -> +3 fp.
### rainforest-the-parrot-perch
- QUEST: KITE 4 (swap a `bright-feather`).
- MINIGAME: "Parrot Phrasebook": 5 translations -> Parrot Phrasebook (new, +1 charm with travellers).
### rainforest-the-vine-bridge
- QUEST: BRIDGE 5.
- VILLAGER: Lyra Fiddlewing, we=wind; plays along -> +1 nimble (row: the nimble buff on windy days, no Lyra).
- NEW ITEMS: Vine Twine.
### rainforest-the-fallen-giant
- MINIGAME: "How Old?": 3 weathers -> Almanac page + 50 xp.
- VILLAGER: Warm villager, dp=dusk, sit with them -> +3 fp.
- NEW ITEMS: Giant's Bark Curl (row: `cork-bark`).
### rainforest-the-rain-drum-leaf
- QUEST: SONG 5 (we=rain).
- MINIGAME: drum along (power kind).
- VILLAGER: Cheerful villager, we=rain dp=day, dances -> +3 fp (row: `fp=1@20` then).
- NEW ITEMS: Raindrop Bead.
### rainforest-the-lantern-fruit
- MINIGAME: "Lantern Path": 3 on one night -> no fog penalty on this route that night.
- VILLAGER: Shy villager, dp=night; give them a lantern fruit -> +5 fp.
- NEW ITEMS: Lantern Fruit (the picked glow itself), Lantern Fruit Seed (row: `lanternroot` 6%).
### rainforest-the-mist-pool
- VILLAGER: Pomeroy Crumbworth, we=fog dp=dawn; describe the flavour (lore 10) -> 2-spoon review, 40 xp.
- NEW ITEMS: Soup-Mist Jar.

## Island
### island-the-hammock-palms
- QUEST: HELLO 5 (Pinchwell, new crab pen-pal).
- VILLAGER (after HELLO): Pinchwell's letter waits here, dp=day.
- OTHER: rest 1 game hour.
### island-the-tide-cave
- MINIGAME: "Low Tide Room": dp=dawn, once per season, a `rand:uncommon` find (row: `find=1@20?dp=dawn`, no season cap).
- VILLAGER: Sleepy villager, we=cloud; breathe quietly -> +3 fp.
- NEW ITEMS: Cave Echo Shell.
### island-the-shell-bell-tree
- QUEST: SONG 3.
- MINIGAME: chime a tune (pick kind).
- VILLAGER: Lyra Fiddlewing, dp=dusk; duet -> +1 charm (row: the charm buff at dusk, no Lyra).
- NEW ITEMS: Bell Shell (row: `tide-shell`).
### island-the-sand-spit
- QUEST: HELLO 2.
- VILLAGER: Curious villager, dp=dawn; look with them (sense 11) -> +3 fp and an Almanac sea-bird.
### island-the-rope-swing
- VILLAGER: Eager villager, se=summer dp=day, scores your splash (luck) -> +4 fp.
- OTHER: grit only for the big splash; row makes the whole swing a grit 12 check.
### island-the-palm-lean
- QUEST: KITE 5.
- MINIGAME: "What Is It Holding?" (after KITE): something new each season.
- NEW ITEMS: Beach Ball (decor).
### island-the-coconut-grove
- QUEST: PICNIC 5.
- VILLAGER: Pomeroy Crumbworth, se=summer, a coconut for his review -> `coconut-curry` share (row: 5% in summer).
### island-the-lagoon-edge
- MINIGAME: "Reflection Gnome": 3 calm visits (sun or cloud) -> Mirror Pebble (new, keepsake).
- VILLAGER: Shy villager, dp=dawn, practising with their reflection; talk to them -> +4 fp.
- NEW ITEMS: Lagoon Glass Bead; Striped Minnow Almanac sighting.

## Tundra
### tundra-the-snow-fort
- MINIGAME: "Better Snacks": bring `hot-cocoa` -> snowball standoff (nimble 10) -> Snow-Fort Banner (new, decor).
- VILLAGER: Cheerful villager, we=snow, defends the fort -> +4 fp (row: `fp=1@20?we=snow`).
### tundra-the-lone-fir
- VILLAGER: Warm villager, se=winter dp=dusk, hangs an ornament -> +4 fp and a Fir Ornament (new).
### tundra-the-aurora-rise
- QUEST: STARS 2 (dp=night, likelier in winter).
- VILLAGER: Dreamy villager, dp=night se=winter, share a wish -> +4 fp.
- NEW ITEMS: Aurora Ribbon.
- OTHER: "+1 luck tomorrow" paid as a 4-hour luck buff at dusk/night.
### tundra-the-frozen-stream
- QUEST: HELLO 4.
- MINIGAME: ice-fishing with a rod (`arctic-char` table); row pays `arctic-char` 10% with no rod.
- NEW ITEMS: Frost Window Pane (row: `frost-crystal` 6%).
### tundra-the-ice-shelf-steps
- MINIGAME: play the tune (pick kind; row uses nimble 11); "Squeak Scale": 3 frosty days -> title Ice Pianist.
- VILLAGER: Eager villager, we=frost, requests a song -> +3 fp.
- NEW ITEMS: Squeaky Ice Chip.
### tundra-the-star-chart-stones
- QUEST: STARS 1 (dp=night).
- VILLAGER: Wren Thimblewick, dp=night; copy a star together -> seed trade.
- NEW ITEMS: Stargazer's Chalk (shared mark for the next player, P4).
- OTHER: an Almanac star entry per use (row: extra xp at night).

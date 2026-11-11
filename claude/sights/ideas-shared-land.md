# Sight ideas: the 94 shared land set pieces

Status: IDEAS ONLY (2026-11-11). Nothing built. Feeds phase P2 of `claude/plan-trail-sights.md`.

## How to read this
- One block per slug from `claude/trail-landmarks/setpieces.json` (non-`end-*`). Line 1: slug, button **icon + verb**, the hook. Line 2: its USES.
- **QUEST** = a beat of a cross-spot line below (code + step), or **Mini** = a one-spot quest. **VILLAGER** = a villager point: who turns up, when (`dp` day-part, `se` season, `we` weather, all rest-stop syntax), what they ask or give. Villagers named by personality (`npc_life.php` FAV_KINDS) or by the four travellers (Tobias Trundle, Lyra Fiddlewing, Wren Thimblewick, Pomeroy Crumbworth). Plain villagers appear here on their **away day** (`gclock_npc_away`), so "away" means "out walking the Trail".
- **GOODIE** = a random find: condition + rough odds per use. Existing slugs (checked by grep in `game/includes/data/*.txt`) are in `code`; invented ones are marked **(new)**.
- Every spot has its own verb (no verb is used twice), so no two spots share verb + reward + beat. Quest beats only fire while that line is open; otherwise the spot runs its normal Sight.
- Shared pieces repeat on many routes, so the quest beat triggers at **any** placement of that slug.

## Cross-spot quest lines (9)
Each line starts from a villager's request in town (a Notice Board favour at Acquaintance, the full line at Friend). Beats can be done in order only; each beat is a Sight use (normal energy, no extra cooldown).

**KITE · The Runaway Kite** — given by a **Dreamy** villager (a kite-maker) who watched her best kite sail off "towards everywhere".
1. `grassland-the-wind-combed-meadow`: wind the trailing string onto a spool → Kite-String Spool (new).
2. `mountain-the-wind-notch` (needs `we=wind`): the tail ribbon flaps in the notch; catch it.
3. `coast-the-dune-grass-sweep`: the grass bows the way the kite went; find its paper bow in the stalks.
4. `rainforest-the-parrot-perch`: a parrot wears the kite's painted eye as a hat; swap it a `bright-feather`.
5. `island-the-palm-lean`: the palm is leaning because it is holding the kite. Shin up and free it.
Reward: the Runaway Kite (new) flies over your hovel; title **Wind Reader**; the wind-combed meadow now tells tomorrow's weather.

**HAT · Sir Barnaby's Sunday Hat** — given by a **Fussy** villager (a hatter) who cannot bear the scarecrow's tiny hat.
1. `grassland-the-lonely-scarecrow`: Sir Barnaby (new, the scarecrow) explains the crows "borrowed" his Sunday hat in pieces.
2. `forest-the-owl-watch-bough` (`dp=night`): the hatband lines the owl's nest; trade it a `hen-feather`.
3. `coast-the-rope-and-net-rack`: the gull is guarding the crown, badly; relieve it of duty.
4. `desert-the-cactus-garden`: the hat feather is stuck on the bravest cactus; water it and it lets go.
5. `grassland-the-lonely-scarecrow`: the hatter stitches it on the spot.
Reward: Hatter's Thimble (new, +charm on gifts); the crows bring you a `shiny-trinket` every 7 game days.

**BRIDGE · The Bridgewarden's Rounds** — given by a **Proud** villager who has "inspected every bridge in the Hollow except the ones he hasn't".
1. `grassland-the-plank-footbridge`: praise the bridge; it stands a little taller.
2. `forest-the-fallen-log-bridge`: bow to the log so it wobbles back politely; tuck moss under the end.
3. `wetland-the-boardwalk-gap`: fit a `timber-plank` in the gap (the little hop is retired with honours).
4. `mountain-the-rope-bridge`: retie the third knot with `rope`.
5. `rainforest-the-vine-bridge`: pluck the vines until the hum is in tune.
Reward: Bridgewarden's Badge (new): every Skill-crossing Sight gets +2 on its roll; title **Bridgewarden**.

**HELLO · The 'Hello' Letters** — given by a **Shy** villager who found the bottle-post note and is too shy to answer it.
1. `coast-the-bottle-post`: write back "hello" for them.
2. `island-the-sand-spit`: a reply bottle at the tip: "hello again. who is this?"
3. `desert-the-mirage-pool`: a note half in the shimmer: "are you real? I am a bit real."
4. `tundra-the-frozen-stream`: a note under the ice: "it is cold here. hello."
5. `island-the-hammock-palms`: the writer is the crab in the hammock, Pinchwell (new). Introduce the Shy villager by letter.
Reward: Seaside Stationery (new); Pinchwell writes every 7 game days with a `cowrie-shell`; the Shy villager +40 friendship.

**STARS · Wren's Star-Wheel** — given by **Wren Thimblewick** (naturalist, Curious) at any town she is visiting.
1. `tundra-the-star-chart-stones` (`dp=night`): trace the chart onto paper.
2. `tundra-the-aurora-rise` (`dp=night`, likelier `se=winter`): lie back and match the green to the chart.
3. `mountain-the-eagle-s-rest` (`dp=night`, not `we=fog`): find the Thimble, a constellation only visible from the eagle's rock.
4. `desert-the-red-rock-arch` (`dp=dusk`): the arch frames the evening star exactly; mark it.
5. `coast-the-lighthouse-shadow` (`dp=night`): signal the keeper, who lends a lens to finish the wheel.
Reward: Pocket Star-Wheel (new): Sight cards show which Sights are special at night; Wren trades you one rare seed.

**PICNIC · The Picnic for Everyone** — given by a **Generous** villager who wants the whole town on one blanket.
1. `grassland-the-picnic-knoll`: measure the dent (it is exactly picnic-sized).
2. `grassland-the-sleepy-windmill`: grind grain into Picnic Flour (new).
3. `forest-the-hollow-oak`: borrow six acorn teacups from the oak's tea party.
4. `desert-the-well-and-its-rope`: lower the bucket for well-cold water (lemonade).
5. `island-the-coconut-grove`: stare down the guiltiest coconut until it drops.
6. `grassland-the-picnic-knoll`: spread it all out.
Reward: Patchwork Picnic Blanket (new) decor; every villager in that town +10 friendship; the knoll gives a feast buff ever after.

**SONG · Lyra's Hollow Round** — given by **Lyra Fiddlewing** (minstrel, Cheerful) who needs five sounds for a new song.
1. `wetland-the-frog-choir`: the choir has lost its low note; conduct until it turns up.
2. `mountain-the-echo-wall`: shout the note; the echo gives it back, cheekier (that is the version Lyra wants).
3. `island-the-shell-bell-tree`: chime the right shell.
4. `forest-the-bluebell-glade` (`se=spring` easier): listen for the ring nobody else hears.
5. `rainforest-the-rain-drum-leaf` (`we=rain`): drum the beat.
Reward: Song Sheet: The Hollow Round (new); whenever Lyra is on a green she plays it for you: +1 nimble for the day.

**TRADER · The Trader Who Went Home** — given by **Tobias Trundle** (merchant tortoise, Generous) who wants to find his old teacher.
1. `desert-the-trader-s-tent-poles`: a "back soon" note signed Old Marrowby (new); hang a lantern so he can find the way.
2. `desert-the-sand-ripple-lane`: read a cart wheel's wobble in the ripples.
3. `desert-the-waystone-cluster`: introduce yourself; the three stones name a farm "past the grass".
4. `grassland-the-old-milestone`: scrub it; it points, confidently, the right way for once.
5. `grassland-the-hay-cart-ruts`: follow them to the cart, and Marrowby, happily retired.
Reward: Marrowby's Old Price Book (new, better prices at travellers); the tent poles become a weekly barter stall (Marrowby visits on `se=autumn` days).

**LADDER · The Ladder That Went for a Walk** — given by a **Sleepy** villager who lives in a stilt house and would like to get in.
1. `wetland-the-stilt-house`: call up; nobody answers (the ladder is gone).
2. `wetland-the-reed-causeway`: the reeds nod towards a ladder-shaped gap.
3. `mountain-the-goat-ledge`: the goat used the ladder to reach a snack; share yours and it gives the ladder up.
4. `mountain-the-stone-hut`: the ladder is propped by the chimney enjoying the view; light the stove so it comes in to warm up.
5. `wetland-the-stilt-house`: the ladder walks itself home.
Reward: Feather Pillow (new, naps restore +1 energy); the stilt house becomes a free nap Sight for you.

---

## All 94 spots

### Grassland (12)

**`grassland-the-plank-footbridge`** · 🎖️ **Praise** — Tell the proud bridge it is a fine bridge; it stops creaking and you cross with a spring.
QUEST BRIDGE 1. · VILLAGER: Proud villager, `dp=dawn`, away day: asks you to rate the bridge out of ten (charm 10) → +3 friendship. · GOODIE: `we=rain`, 15%: a `minnow` jumps out of the ditch onto the planks.

**`grassland-the-picnic-knoll`** · 🧺 **Spread a cloth** — Sit in the picnic-shaped dent and eat a snack: snack buff lasts twice as long here.
QUEST PICNIC 1 + 6. · VILLAGER: Warm villager, `se=summer dp=day`: shares a slice of `custard-tart` (30%). · GOODIE: 8%: an Ant Delegation carries off one crumb and leaves a Tiny Thank-You Seed (new, random flower).

**`grassland-the-bramble-gap`** · ✂️ **Snip** — Trim the brambles so two gnomes and two opinions fit.
Mini "One Opinion": a Grumpy villager is stuck halfway (`dp=day`, away day) and won't budge until you agree with him (charm 11 or luck 12) → he gives Grumpy's Hedge-Shears (new, keepsake). · GOODIE: `se=autumn`, 40%: `blackberries`; 3%: a sock someone left in 1987 (new, Lost Sock, joke item).

**`grassland-the-shepherd-s-wall`** · 🚪 **Shut the gate** — Open and shut the decorative gate properly, even though the wall is mostly elsewhere.
VILLAGER: Fussy villager, `dp=dusk`: checks you shut it and gives `hen-feather` "for manners". · Mini "Count the Sheep": `dp=night`, count the sheep hopping the wall (three uses on three nights) → Sleep-Counter buff (new, +2 energy at next sleep). · GOODIE: 12%: Tuft of Fleece (new) caught on the stones.

**`grassland-the-wind-combed-meadow`** · 🪁 **Wind the string** — Reel in the kite string that trails over the path; something is on the other end, very far away.
QUEST KITE 1. · VILLAGER: Dreamy kite-maker, `we=wind dp=day`: flies a kite with you, +1 sense buff. · GOODIE: `we=wind`, 20%: `storm-feather`; after KITE done: a line of tomorrow's weather.

**`grassland-the-dandelion-drift`** · 🌬️ **Blow a wish** — Blow the drift into the sky and make a wish.
Mini "Wish Delivery": your seeds land in the next town on the route; 3 game days later a villager there thanks you for the dandelions (+5 friendship, random villager). · VILLAGER: Shy villager, `se=spring`, hiding in the fluff, whispers what they wished for (fp +2). · GOODIE: 25%: `dandelion` seed.

**`grassland-the-sleepy-windmill`** · ⚙️ **Grind** — Feed a grain crop in; the sails turn slowly and you get flour (swap 2 grain → 1 Picnic Flour (new)).
QUEST PICNIC 2. · VILLAGER: Sleepy villager naps on the flour sacks at `dp=dawn`; wake gently (sense 10) and they bake you `pancakes`. · GOODIE: `we=wind`, 30%: the sails rush, double flour.

**`grassland-the-daisy-ring`** · 📏 **Measure** — Get out a tape and measure the ring. It is perfect to the hair.
Mini "Who Measured?": measure it in 3 different seasons; the third time you catch a Fussy villager's grandmother with a ruler. She gives you a Daisy-Chain Crown (new, +charm). · GOODIE: `dp=dawn`, 15%: Dew Pearl (new), a drop of dew that refuses to dry.

**`grassland-the-clover-patch`** · 🍀 **Hunt for four** — Everyone checked every leaf. Check again anyway (luck 12).
VILLAGER: Eager villager with a clipboard of checked leaves, `we=rain`: asks you to recheck the new leaves → +3 friendship and a copy of The Clover Ledger (new, lore). · GOODIE: 30%: `white-clover` seed; 1 in 60: Five-Leaf Clover (new) hiding under a snail, the one nobody checked.

**`grassland-the-lonely-scarecrow`** · 🎩 **Tip your hat** — Greet Sir Barnaby (new); the crows like him, so they like you.
QUEST HAT 1 + 5. · VILLAGER: Shy villager, `dp=dusk`, tells the scarecrow their worries; sit with them (+2 friendship). · GOODIE: 10%: the crows drop a `glowing-bead`.

**`grassland-the-old-milestone`** · 🧽 **Scrub** — Scrub the moss off the worn numbers. Each time it reads something new: "4½ to Somewhere", "Not far now", "Ask a goat".
QUEST TRADER 4. · Mini "Milestone Collector": read 6 different messages → Almanac page + 60 xp. · GOODIE: `we=rain` (moss soft), 25%: `living-moss`.

**`grassland-the-hay-cart-ruts`** · 🛞 **Follow the ruts** — Walk in the ruts a little way; they always go home.
QUEST TRADER 5. · VILLAGER: Cheerful villager, `se=autumn dp=day`, gives a hay-ride to the next section (skip 10 game minutes). · GOODIE: 25%: `straw-mulch` fallen from the long-gone cart.

### Forest (13)

**`forest-the-lantern-branch`** · 🕯️ **Trim the wick** — Trim the old lantern's wick when its keeper is away; it burns brighter all night.
VILLAGER: the Wick-Keeper, a Sleepy villager, `dp=dusk`, away day: if you trimmed it last time he leaves a `tin-lantern` (once). · Mini "Keep It Lit": trim it on 3 different nights → title **Lamplighter**. · GOODIE: `dp=night`, 20%: `firefly-glow`.

**`forest-the-root-tangle-crossing`** · 🦵 **Step high** — The roots are a puzzle with one answer: pick the right three steps (pick kind, n=3).
VILLAGER: Eager young villager, `dp=day`, races you over the roots (nimble 11) → +3 friendship and a Root-Race Ribbon (new). · GOODIE: win, 6%: `heartwood` knot that came loose.

**`forest-the-spring-and-the-pebbles`** · 💧 **Sip** — Cup your hands and sip: +1 energy, very fresh.
VILLAGER: Wren Thimblewick, `dp=dawn`, between towns: tests the water and trades a seed for any pebble you found today. · GOODIE: 8% (15% `se=spring`): `singing-pebble`.

**`forest-the-owl-watch-bough`** · 🦉 **Pretend not to look** — Stand under the bough and very carefully don't look at the owl (sense 11). It approves.
QUEST HAT 2. · Mini "Owl Manners": succeed 3 times and the owl names you in its diary (Almanac sighting: Bough Owl). · GOODIE: `dp=night`, 15%: `pretty-feather`.

**`forest-the-glow-moss-grotto`** · 🌙 **Read by moss-light** — Sit in the glowing hollow and read: +lore buff for the walk.
VILLAGER: Shy villager's secret reading nook, `we=rain`: they let you borrow a book; return it next visit → +5 friendship. · GOODIE: 4% `dp=night`: Glow-Moss Nightlight (new); 10%: a Bookmark Snail (new, harmless, wanders off).

**`forest-the-fern-tunnel`** · ☔ **Duck under** — Duck under the drips (nimble 10); fail = soggy hat, a laugh, nothing worse.
VILLAGER: Grumpy villager, `we=rain`, walks here "because it's raining anyway"; walk with them (+3 friendship, they admit it's nice). · GOODIE: `we=rain`, 30%: `fiddleheads`; 2%: a Fern-Drip Hat Charm (new, keeps rain off one walk).

**`forest-the-acorn-scatter`** · 🐿️ **Tidy the acorns** — Help Hazel Fluster (new, a squirrel having a very bad day) put acorns back in three holes (pick kind).
Mini "Bad Day, Good Day": tidy on 3 days in `se=autumn` → Hazel gives a Squirrel's Spare Key (new: one Forest find each walk is an acorn bonus). · GOODIE: 35%: `acorn-cap`.

**`forest-the-hollow-oak`** · 🫖 **Pour tea** — Pour for six in the hollow (needs a cooked item); a warm rest, +energy.
QUEST PICNIC 3. · VILLAGER: Chatty villagers, `se=winter dp=day`, hold Oak Tea; take the sixth seat for a gossip hint about a Trail find ahead. · GOODIE: 20%: `mint-tea`.

**`forest-the-mushroom-ring`** · 🍄 **Walk round** — Walk round the ring three times (never through): +1 luck for the walk.
VILLAGER: Dreamy villager, `we=fog`, dances inside the ring; join in (luck 10) → +4 friendship. · GOODIE: `we=rain`, 25%: `chanterelle`; 2%: Toadstool Stool (new, decor).

**`forest-the-mossy-stair`** · 🧹 **Sweep** — Sweep the steps for the next small boots. There is always one more step than last time.
VILLAGER: Warm elderly villager, `dp=dawn`, climbing slowly: carry her basket up (escort) → `raspberry-jam`. · GOODIE: 10%: Brass Button (new) worn smooth by many boots.

**`forest-the-woodcutter-s-stump`** · 🪓 **Tug the tiny axe** — Try to pull the very small axe out of the very big stump (grit 13).
Mini "Axe in the Stump": the first win ever gives the Teeny Axe (new, keepsake; +1 to Snip at the bramble gap). · VILLAGER: Proud retired woodcutter, `se=autumn`, tells how it got stuck ("it was a very small argument") and gives an `oak-log`. · GOODIE: 15%: `oak-gall`.

**`forest-the-fallen-log-bridge`** · 🙇 **Bow back** — The log wobbles politely, so bow back; it holds still.
QUEST BRIDGE 2. · GOODIE: 12%: `stag-beetle-shell` from under the bark. · Mini "Politeness Contest": bow 5 times on one walk and the log bows lower: 30 xp and a giggle.

**`forest-the-bluebell-glade`** · 🔔 **Listen for the ring** — Kneel and listen (sense 12, easier `se=spring`); the bluebells really do ring.
QUEST SONG 4. · VILLAGER: Lyra Fiddlewing, `se=spring dp=dawn`, tuning her fiddle to the glade: one free song (+1 charm buff). · GOODIE: `se=spring`, 18%: Bluebell Bulb (new, a garden flower).

### Wetland (10)

**`wetland-the-mud-skipper-flats`** · 🏁 **Fire the starter** — The skippers race for no reason; give them one. Pick a winner (pick kind).
VILLAGER: Eager villager, `dp=day`, runs a book on the skippers: right pick doubles their thanks (+3 fp). · GOODIE: right pick, 20% (`we=rain` 35%): Mudskipper Medal (new, trinket).

**`wetland-the-stilt-house`** · 🪜 **Call up** — Call up to the house on stilts; the reply depends on the hour.
QUEST LADDER 1 + 5. · VILLAGER: Sleepy villager (owner), `dp=dusk`, away day: after LADDER, offers a nap (+3 energy, 1 h). · GOODIE: 10%: a `woven-basket` lowered on a string, with a biscuit in it.

**`wetland-the-willow-curtain`** · 🌿 **Part the curtain** — Part the willow; what is behind changes by season (spring nest, summer shade, autumn leaf pile, winter icicle chimes).
VILLAGER: Shy villager hides behind it on `we=fog`; talk without looking (sense 11) → +4 friendship. · GOODIE: 25%: Willow Withies (new, for basket crafts); `se=winter` 8%: Icicle Chime (new, decor).

**`wetland-the-peat-bank`** · 📖 **Sniff the pages** — It smells of rain and old books, so sniff out which book (lore 11).
VILLAGER: Grumpy villager (library lover), `we=rain`, reads on the bank; guess their book right → +4 friendship and a book recommendation (Almanac lore). · GOODIE: 30%: `sphagnum`; 5%: Bog-Pressed Bookmark (new).

**`wetland-the-frog-choir`** · 🎼 **Conduct** — Wave a reed and conduct the rehearsal; good tempo = a little xp and a frog bow.
QUEST SONG 1. · VILLAGER: Cheerful villager, `dp=dusk se=spring`, sings tenor with the frogs; join (charm 10) → +3 friendship. · GOODIE: `se=spring`, 12%: `frogspawn` (for a garden frog pond).

**`wetland-the-boardwalk-gap`** · 🔨 **Mend the plank** — Fit a `timber-plank` in the gap (or just hop: nimble 9).
QUEST BRIDGE 3. · Mini "The Missing Plank": after you mend it, the lost plank turns up 3 sections later, floating; return it → Plank's Gratitude (new, a carved coaster). · GOODIE: 10%: `bog-iron` under the boards.

**`wetland-the-lily-pad-ford`** · 🐸 **Hop** — Hop pad to pad (nimble 11); fail = one wet foot.
VILLAGER: a frog-species villager, `we=rain`, coaches your hopping: next crossing Sight +2. · GOODIE: 15%: `golden-carp` glimpsed and caught by hand (rare, 3%); 20%: `cattail-root`.

**`wetland-the-dragonfly-bend`** · 🧵 **Watch the stitching** — Watch dragonflies stitch the air blue; follow one seam with your eyes (sense 10).
VILLAGER: Fussy seamstress villager, `se=summer dp=day`, studies the stitches: bring her 3 `dragonfly-wing` → a Blue-Stitch Hat Patch (new, +nimble). · GOODIE: `we=sun`, 20%: `dragonfly-wing`.

**`wetland-the-reed-causeway`** · 👋 **Nod back** — The reeds nod hello. Nod back. They nod more.
QUEST LADDER 2. · VILLAGER: Generous villager, `dp=dawn`, cutting reeds for thatch: help bundle → `rope-cattail`. · GOODIE: 25%: `cattail-fluff`.

**`wetland-the-heron-s-post`** · 👏 **Applaud** — Clap for the heron on its stage; it does the one-leg pose, very slowly, twice.
VILLAGER: Proud villager (a critic), `we=fog`: asks your review of the heron; agree it was "luminous" → +3 friendship. · Mini "Encore": applaud on 3 foggy days → the heron drops you a `perch` as a bouquet. · GOODIE: 6%: Heron's Programme Notes (new, lore).

### Mountain (11)

**`mountain-the-scree-slope`** · 🪨 **Play the scree** — The stones tick and chatter; step on the right ones to play a tune (pick kind), or sneak across silently.
Mini "Scree Song": play it in 3 weathers → Scree Xylophone (new, decor). · VILLAGER: Lyra not here; Chatty villager, `dp=day se=summer`, sings along badly (+2 fp). · GOODIE: 20%: `slate-shard`; 4%: `rock-crystal`.

**`mountain-the-pine-shelf`** · 🤗 **Hug a pine** — Hug a pine that is clinging on for dear life. It feels better.
VILLAGER: Shy villager, `we=wind`, also holding on; hold on together → +4 friendship. · GOODIE: 30%: `pine-resin`; `se=winter` 10%: Pine-Snow Cone (new, snack, +1 energy).

**`mountain-the-wind-notch`** · 🎐 **Fly a ribbon** — Hold a ribbon in the notch; the wind plays it. Wind buff or headwind by weather.
QUEST KITE 2. · GOODIE: `we=wind`, 15%: a stray tune caught in the ribbon, Pocket Whistle (new, +1 charm next talk). · VILLAGER: Dreamy villager, `dp=dusk`, listens to the notch; tell them what it played (lore 10) → +3 fp.

**`mountain-the-goat-ledge`** · 🐐 **Share a snack** — Offer the unbothered goat a snack; it remains unbothered, but shares the view.
QUEST LADDER 3. · VILLAGER: a goatherd (Warm), `se=spring`: gives `goat-hair` if the goat let you sit. · GOODIE: 12%: `edelweiss` the goat was guarding.

**`mountain-the-rope-bridge`** · 🪢 **Retie** — Retie a loose knot (lore 11) before crossing; the bridge sways happily.
QUEST BRIDGE 4. · Mini "Knot Book": retie 5 times → Bridge Knots (new, Almanac page; +craft for `rope`). · GOODIE: `we=wind`, 10%: `spider-silk` from the handrail.

**`mountain-the-waterfall-mist`** · 🌈 **Catch a rainbow** — Hold out a jar in the mist when the sun is out (`we=sun dp=day`).
VILLAGER: Dreamy painter villager, `dp=dawn`, paints the falls; hold her brushes → a small painting (new, Waterfall Sketch, decor). · GOODIE: `we=sun`, 6%: Bottled Rainbow (new, lights a room); always +1 energy from the cool mist.

**`mountain-the-eagle-s-rest`** · 🦅 **Think alongside** — Sit beside the eagle's boulder and think a big thought. +lore buff.
QUEST STARS 3. · VILLAGER: Grumpy villager, `dp=dawn`, comes here "to be left alone"; leave them alone properly (sense 11) and they thank you later in town (+5 fp). · GOODIE: 5%: `bright-feather` the eagle didn't need.

**`mountain-the-stone-hut`** · 🔥 **Light the stove** — Light the empty hut's stove (needs a log): rest an hour, warm buff.
QUEST LADDER 4. · VILLAGER: Sleepy villager on holiday, `se=winter`, away day: invites you to toast bread → `hot-cocoa`. · GOODIE: 8%: Visitors' Book page (new, a silly note from a past guest).

**`mountain-the-echo-wall`** · 📣 **Shout** — Shout something nice; the echo shouts back something cheekier (a random line).
QUEST SONG 2. · Mini "Out-Cheek the Echo": win 3 charm 12 checks and the echo gives in: title **Last Word**. · GOODIE: 10%: Echo Pebble (new, repeats your last toast).

**`mountain-the-switchback-bend`** · 🔭 **Look back** — Look back down the way you came; you spot something you missed.
VILLAGER: Tobias Trundle, `dp=day`, plodding up between towns; walk with him one bend (escort) → his rare seed for 20% less. · GOODIE: 15%: you spot a missed Trail find below and it rolls down to you (one land `rand:forage`).

**`mountain-the-cairn-pass`** · 🗿 **Add a stone** — Add a stone to the cairns; the shared count on the Sight card goes up.
Mini (shared, P4): at every 100 stones placed by all players on that pass, everyone who added one gets a Cairn Token (new). · VILLAGER: Proud villager, `we=snow`, insists his cairn is tallest; add to his (+3 fp) or to the shared one (+xp). · GOODIE: 6%: `geode` under the stone you picked.

### Coast (12)

**`coast-the-lighthouse-shadow`** · 🔦 **Signal** — Flash your lantern when the beam sweeps past; the far lighthouse flashes back.
QUEST STARS 5. · VILLAGER: the Keeper (new, a Generous mole), `dp=night we=fog`: signals a fish-shoal tip, next fishing Sight on this route +1 catch. · GOODIE: `we=fog`, 10%: `moonfish` drawn in by the light (needs rod).

**`coast-the-kelp-line`** · 🎀 **Tie a bow** — The kelp is neat as a ribbon, so finish it with a bow.
VILLAGER: Pomeroy Crumbworth, `se=summer dp=dusk`, between festivals: bring 2 `bladderwrack` for his kelp-crisp review → a spoon rating and 40 xp. · GOODIE: 30%: `bladderwrack`; 5%: `seed-pearl` tangled in the ribbon.

**`coast-the-rope-and-net-rack`** · 💂 **Relieve the guard** — Take over from the gull, who is guarding the nets badly. Guard them well for a bit.
QUEST HAT 3. · VILLAGER: Grumpy fisher villager, `dp=dawn`, mending nets: mend one (lore 10) → `sardine` x2. · GOODIE: 10%: Gull's Medal of Not Really Trying (new, joke trinket).

**`coast-the-bottle-post`** · ✉️ **Write back** — Read the note ('hello') and write a reply.
QUEST HELLO 1. · Mini (shared, P4): leave a short note for the next player; read theirs (moderated like Messages). · GOODIE: 8%: the bottle holds a `sea-glass` instead of a note.

**`coast-the-tide-pool-steps`** · 🦀 **Hear out a crab** — Every crab has an opinion; listen to one fully (charm 10). Fail = it was a long opinion.
Mini "Crab Court": two crabs dispute a pool; judge fairly on 3 visits → Crab Gavel (new, keepsake). · VILLAGER: Curious villager, `dp=day`, low tide, counts crabs with you (+2 fp). · GOODIE: 25%: `tide-shell`.

**`coast-the-stranded-rowboat`** · 🚣 **Push off** — Patch and push the rowboat; at dawn high tide (`dp=dawn`) the sea "apologises" and you row a short hop (skip 1 section's walk time).
VILLAGER: Grumpy old fisher, `we=storm`, says the boat is his and the sea owes him; help push → he softens (+4 fp). · GOODIE: 20%: `driftwood` patch left over.

**`coast-the-sandbar-causeway`** · 🏃 **Dash across** — Dash along the sandbar before the water shuffles in (nimble 11).
VILLAGER: Eager villager, `dp=dusk`, times you with a shell-clock; beat their time → +3 fp and title chance **Sandbar Sprinter** (5 wins). · GOODIE: 15%: `sea-glass` glinting.

**`coast-the-barnacle-wall`** · 🤫 **Tell a joke** — Don't tickle them. Whisper a joke instead (charm 11); the barnacles clack with laughter.
Mini "The Barnacle Joke Book": tell 5 different jokes over 5 visits → they tell you one back (Almanac lore, very bad pun). · GOODIE: 25%: `blue-mussels`; `we=storm` 5%: Barnacle Giggle (new, a shell that clicks when touched).

**`coast-the-dune-grass-sweep`** · 🎭 **Curtsy** — The grass bows like an audience; curtsy back and it applauds (rustles).
QUEST KITE 3. · VILLAGER: Lyra Fiddlewing, `we=wind dp=dusk`, practises on the "audience"; be her audience too → +1 charm buff. · GOODIE: 15%: `samphire` in the hollows.

**`coast-the-driftwood-arch`** · 🐚 **Clack the shells** — Clack the hanging shells into a rhythm.
VILLAGER: Cheerful villager, `we=wind`, rests in the arch's shade: share a snack → +3 fp. · Mini "Wind Rhythm": match the wind's rhythm 3 times (pick kind) → Arch Shell Mobile (new, decor). · GOODIE: 18%: `cowrie-shell`.

**`coast-the-sea-stack-gap`** · 🦶 **Paddle** — Paddle in the spray between the rocks; tickly. +1 energy, +nimble buff for 20 minutes.
VILLAGER: Eager villager, `se=summer`, dares you to paddle further (grit 11) → they pay up a Dare Pebble (new). · GOODIE: `we=storm`, 12%: `urchin-test` thrown up by the spray.

**`coast-the-shell-heap`** · 🌀 **Sort the spirals** — Sort shells into "proper spiral" and "not a spiral" (pick kind). The sorter will check.
VILLAGER: Fussy villager (the sorter), `dp=day`, inspects your work: perfect sort → +5 fp. · GOODIE: 25%: `spiral-shell`; 2%: Left-Handed Spiral (new, extremely rare, the sorter gasps).

### Desert (11)

**`desert-the-sun-bleached-bones`** · 🪑 **Sit on the fish** — The very friendly fish lay down to be a bench. Sit; it was always for sitting. Rest 20 min.
VILLAGER: Curious villager, `dp=day`, desperate to ask about it; stop them asking (charm 10) → +3 fp and they sit too. · GOODIE: 10%: `fossil-shell` from its fin.

**`desert-the-salt-flat`** · 🧂 **Crunch** — Crunch-walk across in a pattern; it sounds wonderful. With a bucket: scoop salt.
Mini "Write It Big": crunch your name in the salt; next day the wind has tidied it, leaving one letter (collect your whole name → Salt Sign (new, decor)). · GOODIE: bucket, 35%: Flat Salt (new, cooking). · VILLAGER: Pomeroy, `we=heat`, wants salt for a recipe; give 1 → spoon rating, 30 xp.

**`desert-the-shade-awning`** · 😴 **Nap** — Nap 2 hours under the faded awning; `we=heat` bonus energy.
VILLAGER: Sleepy villager, `dp=day`, away day, already napping; nap quietly beside them (no snoring: luck 9) → +4 fp. · GOODIE: each nap gives one random Dream line; 10%: a Dream Souvenir (new, a weird little item from the dream).

**`desert-the-red-rock-arch`** · 🌅 **Stand in the glow** — Stand under the arch at low sun (`dp=dawn/dusk`); the glow warms: +grit buff.
QUEST STARS 4. · VILLAGER: Dreamy villager, `dp=dusk`, watches the glow; share it → +3 fp. · GOODIE: `dp=dusk`, 12%: `red-ochre` crumbs shining.

**`desert-the-sand-ripple-lane`** · 〰️ **Read the ripples** — The ripples are a washboard and a book: read which way the wind went and who walked here.
QUEST TRADER 2. · Mini "Washboard Band": run a stick along the ripples (power kind) → 25 xp and a song line in the Almanac. · GOODIE: 15%: `desert-glass`.

**`desert-the-waystone-cluster`** · 🤝 **Introduce yourself** — Say hello to the three leaning stones; they remember every traveller.
QUEST TRADER 3. · VILLAGER: Chatty villager, `se=autumn`, leans with the stones and gossips; you get a hint for the next town's market. · GOODIE: 10%: a waystone tells a rumour that marks a Trail find on this route.

**`desert-the-dry-riverbed`** · ⛏️ **Dig** — Dig in the river's old bed (spade); the river left things behind.
Mini "The River Visits": on a rare `we=rain` day the river comes back for one night; dig then for a guaranteed River's Postcard (new). · GOODIE: 15%: `desert-rose-stone`; 6%: Old River Pebble (new).

**`desert-the-mirage-pool`** · 🫧 **Reach in** — Reach into the shimmer; your hand is mostly in water, a little bit not.
QUEST HELLO 3. · VILLAGER: Wren Thimblewick, `we=heat`, studies how real it is; tell her what you felt (lore 11) → trade one seed. · GOODIE: 8%: Mirage Marble (new, a marble with a pool in it).

**`desert-the-cactus-garden`** · 🚿 **Water** — Water the neat row of cacti, carefully. Somebody is brave; today it is you.
QUEST HAT 4. · VILLAGER: Proud villager (the brave waterer), `dp=dawn`, away day: hands you the watering can if you stand still while they show off → +3 fp. · GOODIE: `se=spring`, 15%: Cactus Bloom (new, flower).

**`desert-the-trader-s-tent-poles`** · 🏮 **Hang a lantern** — Hang a light on the poles in case the trader comes back in the dark.
QUEST TRADER 1. · VILLAGER (after TRADER): Old Marrowby (new), `se=autumn`, sets up a barter stall here: swap 3 of a land find for 1 of another land. · GOODIE: 10%: a forgotten trade token, Marrowby's Wooden Coin (new).

**`desert-the-well-and-its-rope`** · 🪣 **Lower the bucket** — Lower the patient bucket; it comes up full (bucket tool or none).
QUEST PICNIC 4. · VILLAGER: Generous villager, `we=heat dp=day`: shares cold well water → +2 energy. · GOODIE: 6%: the bucket comes up with a Wishing Coin (new) someone dropped years ago.

### Rainforest (10)

**`rainforest-the-stepping-roots`** · 🧗 **Climb the roots** — Climb the green stairs out of the mud (nimble 10).
VILLAGER: a gecko-species villager, `we=rain`, races you up; let them win → +3 fp; beat them → 30 xp. · GOODIE: 20%: `laterite-clay` on your boots.

**`rainforest-the-giant-fern-glade`** · 🫣 **Hide and seek** — Hide under ferns taller than you; something finds you.
Mini "Who Is It?": 3 rounds; each finds you someone new (a frog, a villager's child, a very calm snail) → Almanac sightings. · VILLAGER: Eager villager, `dp=day`, plays seeker → +3 fp. · GOODIE: 15%: Giant Fern Spores (new, plant).

**`rainforest-the-orchid-tree`** · 💐 **Admire** — Admire each orchid out loud (charm 10); the tree preens.
VILLAGER: Proud gardener villager, `dp=dawn se=spring`: asks which orchid is best; any honest answer → +3 fp and an Orchid Cutting (new). · GOODIE: 12%: `bromeliad-seeds` dropped among the orchids.

**`rainforest-the-canopy-gap`** · ☀️ **Sunbathe** — Stand in the column of sun; warm and bright: +sense buff.
VILLAGER: Dreamy villager, `we=sun dp=day`, lies in the sunbeam; share it → +3 fp. · GOODIE: `we=sun`, 20%: `butterfly-scales`; `we=rain` (the column turns to sparkle) 8%: `morpho-scales`.

**`rainforest-the-parrot-perch`** · 🦜 **Translate** — The parrots argue in three languages; translate one argument (lore 12). Both sides think they won.
QUEST KITE 4. · Mini "Parrot Phrasebook": translate 5 arguments → Parrot Phrasebook (new, +1 charm with travellers). · GOODIE: 8%: a parrot drops a `bright-feather` mid-argument.

**`rainforest-the-vine-bridge`** · 🎻 **Pluck** — Pluck a vine as you cross; the bridge hums a note back (nimble 10).
QUEST BRIDGE 5. · VILLAGER: Lyra Fiddlewing, `we=wind`, between towns: plays along with the bridge → +1 nimble buff. · GOODIE: 15%: Vine Twine (new, crafting string).

**`rainforest-the-fallen-giant`** · 🚶 **Walk the trunk** — The path goes along the trunk; walk it end to end and count the rings at the broken end.
Mini "How Old?": count rings in 3 weathers; the answer is "older than the Hollow" → Almanac page + 50 xp. · VILLAGER: Warm villager, `dp=dusk`, sits on the trunk; sit with them → +3 fp. · GOODIE: 18%: Giant's Bark Curl (new, decor).

**`rainforest-the-rain-drum-leaf`** · 🥁 **Drum** — Tap the huge leaf along with the rain (power kind).
QUEST SONG 5. · VILLAGER: Cheerful villager, `we=rain dp=day`, dances to it → +3 fp. · GOODIE: `we=storm`, 10%: Raindrop Bead (new, a drop that set hard).

**`rainforest-the-lantern-fruit`** · ✨ **Pick a glow** — Pick one friendly glowing fruit; it lights your next night walk (+sense at night).
Mini "Lantern Path": pick 3 on one night (`dp=night`) and the path is lit: no fog penalty on this route that night. · VILLAGER: Shy villager, `dp=night`, only dares walk the Trail with a lantern fruit; give them one → +5 fp. · GOODIE: 6%: Lantern Fruit Seed (new).

**`rainforest-the-mist-pool`** · 🍲 **Stir** — Stir the mist like soup; see what bobs up.
VILLAGER: Pomeroy Crumbworth, `we=fog dp=dawn`, insists it smells of soup; describe the flavour (lore 10) → 2-spoon review and 40 xp. · GOODIE: 15%: `rainbow-fish` bobs up (rod not needed); `we=fog` 5%: Soup-Mist Jar (new, decor).

### Island (9)

**`island-the-hammock-palms`** · 🛏️ **Ask to share** — Ask the crab politely if you may share the hammock (charm 11). Win = rest 1 h.
QUEST HELLO 5. · VILLAGER (after HELLO): Pinchwell (new, the crab) is your pen-pal; `dp=day`, a letter waits here. · GOODIE: 10%: `coconut` falls (gently) into the hammock.

**`island-the-tide-cave`** · 🌊 **Breathe with** — Breathe in and out with the cave; calm buff (+lore for the walk).
Mini "Low Tide Room": at `dp=dawn` the cave breathes out fully; step in once → a secret shelf with a random `rand:uncommon` find (once per season). · VILLAGER: Sleepy villager, `we=cloud`, naps to the breathing → +3 fp if you breathe quietly. · GOODIE: 12%: Cave Echo Shell (new, plays the sea).

**`island-the-shell-bell-tree`** · 🎶 **Chime** — Chime the shells in a little tune (pick kind).
QUEST SONG 3. · VILLAGER: Lyra Fiddlewing, `dp=dusk`, between towns: duet → +1 charm buff. · GOODIE: 12%: a shell falls: Bell Shell (new, door chime decor).

**`island-the-sand-spit`** · 👉 **Point** — Stand at the tip and point the same way the spit points. Something is out there.
QUEST HELLO 2. · VILLAGER: Curious villager, `dp=dawn`, wants to know what it points at; look with them (sense 11) → +3 fp and they name a sea-bird (Almanac). · GOODIE: 18%: `pink-sand`.

**`island-the-rope-swing`** · 🤸 **Swing** — Swing out and splash into the deep blue pool (grit 10 for a big one).
VILLAGER: Eager villager, `se=summer dp=day`, scores your splash: 9/10 or better (luck) → +4 fp. · GOODIE: big splash, 10%: `coral-fragment` from the bottom.

**`island-the-reef-shallows`** · 🤿 **Snorkel** — Snorkel the warm shallows; the fish show you around (better fish table with a rod).
VILLAGER: Wren Thimblewick, `we=sun`, counts fish species; help her → one seed trade. · GOODIE: 25%: `reef-fish`; 3%: Starfish Friend (new, rides on your hat for a walk, +1 luck).

**`island-the-palm-lean`** · 🌴 **Shin up** — Shin up the leaning palm (nimble 12) to see what it's holding.
QUEST KITE 5. · GOODIE: 20%: `coir-fibre`; `we=wind` 6%: a lost Beach Ball (new, decor). · Mini "What Is It Holding?" (after KITE): the palm holds something new each season: a hat, a kite, a crab, a cloud (lore + xp).

**`island-the-coconut-grove`** · 🥥 **Stare down** — Stare at each coconut until the guilty one gives itself up (sense 12).
QUEST PICNIC 5. · VILLAGER: Pomeroy Crumbworth, `se=summer`, asks for one coconut for a curry review → `coconut-curry` share. · GOODIE: 30%: `coconut`.

**`island-the-lagoon-edge`** · 🪞 **Gaze** — Gaze into the glass-clear lagoon; your reflection waves first.
Mini "Reflection Gnome": 3 calm visits (`we=sun` or `we=cloud`) and the reflection hands you a Mirror Pebble (new, keepsake). · VILLAGER: Shy villager, `dp=dawn`, practises talking to their reflection; talk to them instead → +4 fp. · GOODIE: 10%: Striped Minnow sighting (Almanac) and a Lagoon Glass Bead (new).

### Tundra (6)

**`tundra-the-snow-fort`** · 🚩 **Raise the flag** — Re-raise the fort's flag; it has seen better battles and better snacks.
Mini "Better Snacks": bring `hot-cocoa` to the fort → a friendly snowball standoff (nimble 10), win = Snow-Fort Banner (new, decor). · VILLAGER: Cheerful villager, `we=snow`, defends the fort; join their side → +4 fp. · GOODIE: 15%: `snow-moth-dust`.

**`tundra-the-lone-fir`** · 🎄 **Shake the snow off** — Gently shake off some of the fir's snow so it can stand up straight (watch your hat).
VILLAGER: Warm villager, `se=winter dp=dusk`, hangs one ornament on it each year; help → +4 fp and a Fir Ornament (new). · GOODIE: 25%: `crowberries`; 5%: `cloudberry` under the snow.

**`tundra-the-aurora-rise`** · 🌌 **Lie back** — Lie back on the rise and watch the sky do green things (`dp=night`); +1 luck tomorrow.
QUEST STARS 2. · VILLAGER: Dreamy villager, `dp=night se=winter`, makes a wish on each colour; share a wish → +4 fp. · GOODIE: `dp=night`, 8%: Aurora Ribbon (new, a strip of green light for the hovel).

**`tundra-the-frozen-stream`** · 🪟 **Peer through** — Peer through the bright ice like a window; fish peer back.
QUEST HELLO 4. · Mini ice-fishing: with a rod, `arctic-char` table. · GOODIE: 20%: `arctic-char` (rod); 6%: Frost Window Pane (new, a flake of clear ice that never melts).

**`tundra-the-ice-shelf-steps`** · 🎹 **Squeak a tune** — Step on the squeaky ice steps in order to play a tune (pick kind).
Mini "Squeak Scale": play the full scale on 3 frosty days (`we=frost`) → title **Ice Pianist**. · VILLAGER: Eager villager, `we=frost`, requests a song; play it → +3 fp. · GOODIE: 10%: Squeaky Ice Chip (new, squeaks in your satchel).

**`tundra-the-star-chart-stones`** · ✏️ **Trace** — Trace the scratched constellations with a finger (`dp=night` best); +lore xp and an Almanac star.
QUEST STARS 1. · VILLAGER: Wren Thimblewick, `dp=night`, between towns: copies a star with you → seed trade. · GOODIE: 8%: Stargazer's Chalk (new, lets you add a mark the next player sees, P4).

---

## Uniqueness check
**Verbs (94, all different):** Praise, Spread a cloth, Snip, Shut the gate, Wind the string, Blow a wish, Grind, Measure, Hunt for four, Tip your hat, Scrub, Follow the ruts · Trim the wick, Step high, Sip, Pretend not to look, Read by moss-light, Duck under, Tidy the acorns, Pour tea, Walk round, Sweep, Tug the tiny axe, Bow back, Listen for the ring · Fire the starter, Call up, Part the curtain, Sniff the pages, Conduct, Mend the plank, Hop, Watch the stitching, Nod back, Applaud · Play the scree, Hug a pine, Fly a ribbon, Share a snack, Retie, Catch a rainbow, Think alongside, Light the stove, Shout, Look back, Add a stone · Signal, Tie a bow, Relieve the guard, Write back, Hear out a crab, Push off, Dash across, Tell a joke, Curtsy, Clack the shells, Paddle, Sort the spirals · Sit on the fish, Crunch, Nap, Stand in the glow, Read the ripples, Introduce yourself, Dig, Reach in, Water, Hang a lantern, Lower the bucket · Climb the roots, Hide and seek, Admire, Sunbathe, Translate, Pluck, Walk the trunk, Drum, Pick a glow, Stir · Ask to share, Breathe with, Chime, Point, Swing, Snorkel, Shin up, Stare down, Gaze · Raise the flag, Shake the snow off, Lie back, Peer through, Squeak a tune, Trace.

Since every verb is used once, no verb + reward pair can repeat. Checks on rewards and story beats:
- **Existing goodie items: each is the main goodie at one spot only.** Clashes found while drafting and fixed: `singing-pebble` (spring and echo wall → echo wall now Echo Pebble (new)); `heartwood` (root tangle and fallen giant → fallen giant now Giant's Bark Curl (new)); `living-moss` (milestone and grotto → grotto now Glow-Moss Nightlight / Book Mark Snail); `fossil-shell` (bones only); `geode` (cairn pass only; riverbed now Old River Pebble); `golden-carp` (lily-pad ford only); `seed-pearl` (kelp line only); `moonfish` (lighthouse only; tide cave now Cave Echo Shell); `bright-feather` (KITE swap item and parrot perch goodie: same land, same bird, so the parrot goodie is the payoff of that swap; accepted as one story); `cattail-fluff` (reed causeway only); `sardine` (net rack only); `coconut` (grove goodie; hammock 10% falls → kept as a different beat, a fall into a hammock vs a stare-down).
- **Travellers at more than one spot, each with a different ask:** Lyra (bluebell: free song; dune grass: be her audience; vine bridge: plays the bridge; shell-bell: duet). Wren (spring: water test; mirage: how real; reef: fish count; star stones: copy a star). Pomeroy (kelp crisps, salt, mist soup, coconut curry). Tobias (switchback escort; TRADER giver). All different story beats.
- **Quest beats:** 9 lines, 43 spots, no spot carries two lines (picnic knoll, scarecrow and stilt house each carry first + last beat of their own line only).
- **Shared spots (P4):** cairn pass (stone count), bottle post (notes), star-chart stones (chalk mark): three different shared mechanics.
- **Conditions spread (rough count):** dawn ~14, dusk ~13, night ~11, rain ~12, fog ~7, wind ~11, sun ~6, heat ~5, storm ~4, snow 2, frost 2; every season used. No spot was left non-unique.

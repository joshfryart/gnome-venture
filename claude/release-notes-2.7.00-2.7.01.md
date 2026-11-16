# Release notes for players: 2.7.00 and 2.7.01

Final text, 2026-11-16. Facts from CHANGELOG.md 2.7.00 and 2.7.01. 2.7.01 is not released yet: post its part when it goes up.

**Josh's decision:** wearables, the Tailor and the new puzzle fights stay OUT of the public notes until `pfight_v1` is on for everyone. They are in the internal section at the end, ready to post on that day. Flood Boots are a wearable, so the public "Flooded roads" line does not name them.

---

## Announcement (ready to paste)

> **Gnome Venture 2.7.00: the roads have character now.**
> Some Trail routes are ferries, tunnels, mountain passes, toll roads, overgrown tracks or flooded lanes, each with its own cost or tool. Every route has a camp spot where you can sleep, nap or wait for energy. Sights give better rewards that grow with the region, and nine places now look ruined while they are ruined. Full notes below.

---

## 2.7.00 (public)

### Roads are not all the same any more
- **Ferries.** Some crossings are by boat: 20 Petals a crossing.
- **Tunnels.** You need a good enough lantern to go through.
- **Passes.** You need a good enough walking staff to climb them.
- **Toll roads.** Pay 10 Petals for a safer, quicker road, or take the old road for free.
- **Overgrown roads.** Slow going. An axe clears them.
- **Flooded roads.** Slow going.
- Route cards and the Almanac tell you what kind of road you are on.

### Camp spots
- Every Trail route has one camp spot.
- **Sleep** and **Nap** there are free and safe.
- **Wait** 10 to 60 minutes: you get 1 energy for every 2 minutes. A creature may find you while you wait (half as likely on a paid toll road).

### Sights give better rewards
- Sights now check the conditions they talk about.
- Rewards grow with the level of the region you are in.
- Some Sights give you a discount at a shop.

### Ruins look like ruins
- Nine places now show their own ruined picture while they are ruined.

## 2.7.01 (public, when it goes up)

### New looks
- New pictures for 14 Puzzle Pals, in the yard and on the treehouse perches.
- New pictures for 6 creatures and 3 villagers.

### Not in these versions yet
- New Trail icons, the rest of the Puzzle Pal pictures, new looks for 77 stops, and redrawn ground pictures.

---

## INTERNAL: when pfight_v1 goes live (do not post before)

Add these to the notes on the day the setting `pfight_v1` is on for everyone. Until then only admins see any of it.

### Flooded roads (add to the road list)
- Flood Boots in your satchel halve the slowdown on a flooded road.

### New puzzle fights
- **A chain fires in a fixed order:** environment pieces first, then Guard, then set-up pieces, then Hurt and Charm, then Heal.
- **The creature no longer gets a free piece** just before your turn ends.
- A fight you had already started keeps its old rules.

### Wearables and the Tailor
- **Six wearables:** Flood Boots, Wayfarer's Hat, Work Gloves, Travel Cloak, Trail Pack, Yarn Scarf.
- Each one is also **one puzzle piece**. Switch it on in a Keepsake slot of your Puzzle box (1 slot, 2 from level 15, 3 from level 25, 4 from level 40).
- Most come in **two cuts**: two different pieces on the same item. You pick the cut when the item is made.
- **Three ranks:** Common, Lined, Fine. A better rank makes the piece stronger.
- **Where to get them:** the Tailor makes the Boots, Gloves and Cloak. Twigg's sells the Hat (level 5) and the Pack (level 15). The Scarf comes from Cat Fish. Five Sights can also give you a Common one now and then: the scarecrow (Wayfarer's Hat), the mudslide (Flood Boots), the icicle curtain (Travel Cloak), the woodcutter's stump (Work Gloves) and the mossy stair (Trail Pack).
- **The Tailor** is a new garden building (garden level 6, 1,800 Petals). It has 3 levels.
  - Lining a wearable (Common to Lined, Lined to Fine) works 30% of the time, plus 8% for every Tailor level you own across your gardens (up to 78%).
  - A lining that fails gives you a Tailor's Thread. 5 Threads make the next lining a sure thing.
  - Changing the cut costs 1 Thread, or nothing with a level 2 Tailor.
  - A level 3 Tailor makes your first craft each game day free.
  - A Fine wearable counts as a Rare piece. You can wear it as Lined if your deck already has 3 Rare pieces.
- Every Guard wearable also pricks the creature for 2 when you play it.
- Your gnome wears what you wear: it shows on your gnome's picture.
- The Almanac has a page for wearables.

### Gentler first fights
- Your first 3 fights with the new puzzle rules are gentler: no Thornburst in the environment, creature pieces carry no tags (no Quick, Poison and the like), and creature pieces hit a little softer.
- Your 4th fight starts with a short **"New today"** line that says what has changed.

### Clearer warnings
- When you pick a piece, a lit spot whose chain would cost you health has a red edge. Hover it with a mouse to see why, for example: "Costs you 4 health: it fires the Garden Snail's Snap."
- Place the piece there and the line above End turn says it. Undo takes it back.
- In your first 5 fights, End turn asks once before a move that costs health when a safe spot was open. Tap End turn again to play it anyway.

### Better help sheet
- The "?" sheet says how a fight is won and lost, what the numbers on a lit spot mean, and what a combo is. Each rule has its own small picture.

### Fixes
- The Bramble piece's text says what it really does: in your chain it fills the creature's Yield bar by a tenth; in the creature's chain you lose a tenth of your health.
- The level 3 Tailor's text says it is the first **craft** each day that is free.
- Evade now also stops that round's poison, even after it made a Hurt miss.

### Not in this list yet
- The first-fight teaching (fixed first fight, guided turns, Hint button, defeat recap, Try again) is still being built for 2.7.01 and untested. Add it here once it is released.

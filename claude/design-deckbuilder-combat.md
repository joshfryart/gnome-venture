# Puzzle board combat as a deckbuilder: design review (2026-11-12)

Design only. No game code changed. Mockups: `claude/mockups/deckbuilder-mockups.html` (390 px first; starter pick, Puzzle box, pre-fight swap, in-fight hand and board).
Josh's brief: combat should feel like a deckbuilder with equipment. Pals and tools add pieces, pieces come from every part of the game, a new player picks a starter deck, a Puzzle box page manages it, swaps happen only before a fight, expiry is reviewed, and every creature gets its own pieces plus region pieces.

## 1. Current state (what is already there)

| Area | Finding | Where |
|---|---|---|
| A deck already exists | The **Puzzle box** is a list of tile keys, one copy each. Capacity is 8 at level 1, +1 per 3 levels, 14 max; at least 6, and at least 1 Hurt. Stored as JSON in `user_pbox` (table made on first use). Page `puzzlebox.php`, linked from `gnome.php:246` and the 🧩 button on the fight screen. | `pfight.php:179-220` (`pf_box*`, `pf_collection`), `pfight_game.php:50-80`, `game/puzzlebox.php` |
| What a gnome owns | Base six (Swing, Dodge, Rest, Charm, Snack, Hide), 17 level unlocks (Soothe at L4 up to Smash at L16, "interim until the crafting hook exists"), plus one calling tile (tier II/III adds +2 each). 30 tile defs in total. | `pfight.php:68-114`, `pf_unlocks():171` |
| Pals | Up to 2 equipped pals **replace** a gnome tile (they do not add one). Type comes from the pal's skills and Boon, value is 4 + skill + 2 x rarity. Pal tiles cannot be upgraded. | `pfight_game.php:86-109`, `pf_player_deck():159` |
| Tools | No link to combat. The toolbelt has 19 tool types at tier 1-4 (Worn, Sturdy, Fine, Masterwork), and the best tool of each type is used automatically ("no need to equip"). | `tools.php:17-60`, `inventory.php:73` |
| Upgrades | Finishing puzzles banks offers (3 a day). Each pick puts one mod (common, uncommon or rare) on one tile key. | `pfight_game.php:644-770`, `PF_MODS` |
| Hand and draw | Hand cap 5, draw 3 a round, reshuffle from discard. With a 10-14 tile box, a 5-turn fight cycles the deck about once. | `PF_HAND_CAP`, `PF_DRAW`, `pfb_end_round()` |
| Expiry | Every piece expires `PFB_LIFE` = 3 rounds after it is placed (`pfb_expire`). Creature pieces also fall away after 2 firings (`PFB_FOE_FIRES`). The page shows an hourglass cue and an "x1" badge. | `pfboard.php:14,19,339` |
| Creature decks | Built from **size + temper** only (Lunge, Snap, Brace, Feint, Recover, then Rend or Shy Back, then Slam and Bulk for large, then Crush and Scheme for bosses). Only **5 of 88** species have a signature tile (`PF_SIGNATURE`). The playtest lists about 15 groups of creatures with identical decks. | `pfight.php:230-254`, `pfight_data.php:11-17` |
| Creature tags are mostly inert | In `pf_apply`, Hurt tags (pierce, poison, trip, quick, bash) only work for `me`. A creature Hurt with a tag does nothing extra. Guard tags (hold, thorns, evade) work for both sides. A creature Trick does nothing on its own, only through combos. So creature identity needs a few foe-side effects. | `pfight.php:356-419` |
| Region | The fight does not know the region. Creatures are keyed by landscape (`creatures.txt`); the expedition carries `region` (`adventure.php:305-320`). The fight starts at `adventure.php:426` via `pfight_html` and then `pfight_state` (`pfight_game.php:112`), which builds the deck once into `$enc['pf']`. | |
| JS port | `tools/pfengine.js` mirrors `foeDeck`, `PF_SIGNATURE` and `PFB_LIFE`. Any engine or data change must change it too (`tests/pfengine_js.sh`). | `pfengine.js:24,83,269` |

**Pending proposals, settled.** P2 (blank multiplier 1.0), P1-A4 (numbers on lit cells) and P4 (join/add guard + 3-group x2.0) are **already in the engine** (2.6.66; `pfboard.php:17-22`, `pfb_cell_preview`). The `claude/todo.md` line 90 "PUZZLE BOARD next" is stale on those three and should be trimmed. Still open from P7: group placements get no numbers or `!`; creature guard soaking your Hurt is silent (show "creature guard N" and "Hurt 9 (4 blocked)" from `e['blocked']`); the blank leaving is reported as "EXPIRED ... creature" (skip `by === 'none'`, say "The blank centre is gone"); `add` gives no ANC/SIDE help (list legal adds from `pfb_group_options`). Those are build step 1 below. Not built: P1-A3 (x0.5 hurt-link) and the JS demo cell numbers.

## 2. The deck model

### 2.1 Two parts: Kit and Gear
- **Kit (you choose):** the pieces you pack from your collection. The starter size is **X = 10**.
- **Gear (equipped, added automatically):** each tool on your **fight belt** adds its piece, and each equipped pal adds its piece. Gear pieces are **added** to the deck. They no longer replace a tile, so `pfight_pal_tiles`' swap rule goes.
- Deck in a fight = Kit + Gear, about 15 at mid level. Hand 5, draw 3: a deck of 15 cycles about once in a 5-turn fight, which keeps the draw varied without feeling random.

| | Level 1 | Level 12 | Level 24 | Level 30+ |
|---|---|---|---|---|
| Kit size (min 8, max) | 10 | 12 | 14 | 15 |
| Fight belt tool slots | 2 | 3 | 3 | 4 (L20+) |
| Pal slots (existing party) | 2 | 2 | 2 | 2 |
| Typical deck | 14 | 17 | 19 | 21 |

Kit max = `10 + floor(level / 6)`, at most 15 (replaces `pf_box_capacity`). Min 8. A thin deck is a valid strategy: it is more consistent but runs out sooner.

### 2.2 Where pieces come from (every part of the game)

| Source | How you get it | Rank from | Count | Example pieces |
|---|---|---|---|---|
| Basics | owned at start | – | 6 | Swing, Dodge, Rest, Charm, Snack, Hide |
| Knacks (today's unlocks) | level, later crafting | – | 17 | Jab, Brace, Sting, Lull, Smash |
| Calling | your calling | calling tier I-III | 6 (+6 at tier III) | Bark Wall; tier III adds a 2nd piece, e.g. Rootwarden "Deep Roots" (guard, hold) |
| Tools (Gear) | own the tool; put it on the fight belt | tool tier 1-4 | 19 | Hoe: "Hoe Hook" (hurt, pierce); Rod: "Reel In" (trick); Lantern: "Glare" (charm, lull); Staff: "Sweep" (guard, evade) |
| Puzzle Pals (Gear) | equip the pal | pal rarity | 570 (generated) | type from Boon effect, knob from the pal's knob, tag from a rare pal's active Boon |
| Crops | harvest a crop **kind** (9 kinds) | food mastery tier 1-4 (`food_mastery.php`) | 9 | Herb: "Herb Poultice" (heal, mend); Spice: "Pepper Puff" (hurt, poison); Grain: "Oat Cake" (guard, hold); Fruit: "Juicy Bite" (item) |
| Crafts | craft in a category | `craft_mastery_category_tier` | about 6 | Garden: "Compost Lob" (hurt, poison); Alchemy: "Tonic" (heal, quick); Tool Shed: "Spare Handle" (guard, bash) |
| Regions | earn that region's Gardening Guide | number of guides held | 14 | Mistmoor "Mist Veil" (guard, evade); Spicepeak "Monsoon Spice" (hurt, quick) |

Pal pieces are generated, not authored. The type comes from the existing Boon/skill mapping (`pfight_game.php:88-99`). The knob family comes from the pal's knob: round, tri → body; keyhole, double → mind; peg, hook → craft. A pal piece's edges therefore match its jigsaw shape.

### 2.3 Rank (rarity)
One four-step scale for every source, drawn as the rim trim on the piece (still on the "still to build" art list).

| Rank | Tool tier | Pal | Mastery | Value | Extra |
|---|---|---|---|---|---|
| I Common | Worn | common | 1 | base | – |
| II Uncommon | Sturdy | uncommon | 2 | +2 | – |
| III Rare | Fine | rare | 3 | +4 | gains its tag |
| IV Masterwork | Masterwork | – | 4 | +5 | tag, life 4 (sticks a round longer) |

Deck caps: at most **3 Rare** and **1 Masterwork** (2 at level 25) across Kit + Gear. Without the caps the best deck is "all top rank", and the choice is gone.

### 2.4 Deck rules
1. Kit: min 8, max by level; one copy of each piece; basics up to 2 copies (two Swings is fine).
2. At least 1 Hurt piece, as today (bosses have no charm bar). Warn, but do not refuse, below 2.
3. Rank caps as in 2.3.
4. **No changes during a fight.** The deck is built once when `$enc['pf']` is created (already true). Changes are made in the Puzzle box, or on the pre-fight screen (2.6).
5. A broken tool (`tool_broken_owned`) leaves the belt until it is mended. Fights do **not** wear tools.
6. Upgrades (`user_pmod`) stay per piece key and now fit tool, crop, craft and region pieces too. Pal pieces stay un-upgradable.

### 2.5 Starter deck: first board fight
- Trigger: a gnome with no saved deck (`user_pdeck` row missing) meets a creature with board mode on. The fight start is gated **before** `pfight_state` creates `$enc['pf']` (`adventure.php:426`), so the creature waits.
- Screen: "Pack your first Puzzle box". **4 fixed core** pieces (Swing, Dodge, Rest, Charm) plus **pick 6 of 12** offered. The 12 always include your calling piece, your 2 best tools, your equipped pals' pieces (shown as Gear, free), 1 home-region crop piece and the rest from Knacks you own. Three one-tap kits (Bold, Steady, Kind) pre-fill the 6 for players who do not want to choose.
- Must hold 2 or more Hurt pieces before Confirm is lit. After that, the box is open to edit at any time outside a fight.
- Existing players: migrate `user_pbox` into the new Kit (same keys), set the belt to the 2 best gathering tools, and show the Puzzle box once with a "New: Gear" note. They do not go through the starter pick.

### 2.6 Swapping before a fight
- **Puzzle box page:** full edit. Tabs: Kit, Fight belt, Pals, Upgrades. Reachable from the hovel (a new 🧩 spot), the gnome page (exists) and the menu.
- **Pre-fight screen (new):** when a creature appears, before the board, show the creature card (size, temper, its knob lean, the region piece it carries) and allow **up to 2 swaps** (Kit or belt), then "Fight". Skipping it is one tap. Once the board is up, the 🧩 button on the fight screen shows the deck read-only.

### 2.7 Expiry: review and tune
- Today all pieces live 3 rounds; creature pieces also fall away after 2 firings. Data (P9): the creature fire budget is what manages re-fire, and the 3-round expiry mainly keeps the 7x5 board turning over. Keep both.
- **Change:** make life a piece stat, `life` 2-4 (default `PFB_LIFE` 3). Fleeting pieces (Quick and crop snacks) get 2; Masterwork and Hold pieces get 4. That gives deckbuilding a "board presence" axis without new rules. Creature pieces stay at 3 + fire budget 2; boss Hold pieces get 3 firings (the untested "some stick longer" knob, to measure).
- **Labels:** every piece shows ⌛ and its rounds left (3, 2, 1). On its last round the badge turns amber and reads "last". Creature pieces also show fires left (x2, x1). The blank's leaving reads "The blank centre is gone (round 1 over)".

## 3. Creature pieces: every creature unique, plus region pieces

**Scheme.** Creature deck = **core 4** (2 Hurt, 1 Guard, 1 Recover or Feint by temper) + **2 species pieces** (authored, each with a tag) + **size extras** (large +1, boss +2 authored, keeping the boss order) + **region pieces** of the region the fight is in (small/medium get 1, large and boss get 2). Each species also gets a **knob lean**: about 60% of its knobs and holes in one family (body, mind or craft), so some of your pieces fit it better. The pre-fight screen shows the lean, which is a reason to swap.

Engine support needed (foe side; today these tags do nothing for creatures): **pierce** (ignores your guard), **poison** (2 ticks on your HP), **quick** (creature draws 1), **trip** (you draw 1 fewer next round, not a lost action), **bash** (adds its guard). Hold, thorns and evade already work for creatures.

### 3.1 Sample: 11 creatures

| Creature (size, level, temper) | Species piece 1 | Species piece 2 | Lean | Size extra | Plays like |
|---|---|---|---|---|---|
| Aphid Swarm (S1, gentle) | Swarm: hurt 2, quick | Honeydew: heal, life 2 | mind | – | many weak pieces, keeps drawing |
| Garden Snail (S1, gentle) | Slime Trail: guard, hold (exists) | Shell Tuck: guard, evade | body | – | slow, hard to hurt; Pierce or Charm beats it |
| Paper Wasp (M6, hostile) | Sting: hurt, poison (exists, add tag) | Paper Nest: guard, thorns | craft | – | punishes Hurt-only boxes |
| Bog Leech (M6, hostile) | Latch: hurt, poison | Slick: guard, evade | body | – | a wearing fight; bring Rest or Herb pieces |
| Shore Crab (M7, gentle) | Pinch: hurt, pierce | Shell Up: guard, hold | body | – | guard through your guard |
| Red Fox (L16, hostile) | Sly Pounce: trick (exists) | Quick Bite: hurt, quick | mind | Den Dash: trick | Ambush combos (trick then hurt) |
| Tawny Owl (L17, gentle) | Silent Swoop: hurt, pierce | Hoot: trick | mind | Feather Fluff: guard | rewards Charm, punishes stacked guard |
| Badger (L18, hostile) | Dig In: guard, hold | Maul: hurt, heavy | body | Bash Back: hurt, bash | builds guard, then cashes it in |
| Bramble Wolf (L22, hostile) | Howl: trick (exists) | Bramble Bite: hurt, bash | craft | Pack Circle: guard, thorns | thorny; Ambush plus Bash |
| Dune Wyrm (boss 30) | Sand Swallow: hurt, heavy | Burrow Under: guard, evade | body | Quake: hurt, trip; Shed Skin: heal | trips your draw, then big hits |
| Jade Jaguar (boss 32) | Jade Gaze: trick | Pounce: hurt, pierce | mind | Stalk: guard, evade; Rake: hurt, poison | Ambush-Pierce; read the order |

Values follow the current archetype formula (`$v` from the damage die). Species pieces sit at about `$v` (Hurt) and `2/3 $v` (Guard). Retune with `tests/pfboard_tune.php`; aim for no size row moving more than 5 points.

### 3.2 Region pieces (each region: one Hurt piece and one other; small/medium get only the non-Hurt one)

| Region | Hurt piece | Other piece | From the climate trait |
|---|---|---|---|
| The Maplewold | Cold Snap: hurt, trip | Frost Bark: guard, hold | crisp winters |
| Maizehollow | Ash Spit: hurt, pierce | Dry Spell: trick | volcanic ash, dry spells |
| The Sunsprinkle Isles | Breaker: hurt, quick | Sea Breeze: heal, life 2 | breeze, quick regrowth |
| The Rainroot Reaches | Canopy Drop: hurt, heavy | Humus Hide: guard | rainforest |
| Mistmoor | Bog Grip: hurt | Mist Veil: guard, evade | soft rain, mist |
| Olivewhistle Shore | Stone Throw: hurt, bash | Terra Wall: guard, hold | stony red soil |
| Birchbramble Steppe | Short Fuse: hurt, quick | Black Earth: heal | short, hot summers |
| The Dunewhisper | Sandsting: hurt, poison | Heat Shimmer: guard, evade | dry heat |
| The Greatcanopy | Downpour: hurt | Laterite Crust: guard, thorns | rainy season |
| Thornacre Savanna | Highland Charge: hurt, heavy | Thornbush: guard, thorns | highland, thorn scrub |
| Spicepeak | Monsoon Spice: hurt, poison | River Silt: heal | monsoon, spices |
| Blossomreach | Petal Storm: hurt, quick | Terrace Wall: guard, hold | four seasons, terraces |
| The Monsoon Tangle | Paddy Surge: hurt, bash | Steam: trick | steamy |
| The Coralscatter | Coral Cut: hurt, pierce | Island Time: guard, hold | coral, slow travel |

The same data, with a `me` flag, gives the player's region pieces (2.2): earn a region's Guide and you own its "Other" piece as a Kit piece.

## 4. Data and schema changes
- `game/includes/data/pf_pieces.txt` (new, linted): `key|name|source|ref|type|v|knob|col|up|tag|life|blurb`. Authored edges (see "Authored edges" at the end): `knob` = family of the right knob, `col` = family of the top and bottom edges, `up` = 1 when the column knob is on top (0 = hole on top). The left edge is always a hole of the type's family. The same three columns go into `pf_class_pieces.txt`, `pf_creature_pieces.txt` and `pf_region_pieces.txt`. Sources: basic, knack, calling, tool, crop, craft, region. The tile library moves out of `pf_tiles()`, which reads the file (cached). Pal pieces stay generated.
- `game/includes/data/pf_creature_pieces.txt` (new): `slug|lean|n|type|v_mult|knob|tag` (2-4 rows per species). It replaces `PF_SIGNATURE`; tag `sig` becomes the real tag.
- `game/includes/data/pf_region_pieces.txt` (new): `region|slot(hurt/other)|n|type|v_mult|knob|tag|life`.
- Table `user_pdeck` (made on first use like `pbox_ensure`): `user_id PK, kit TEXT (json keys), belt TEXT (json tool types), ver INT, made_at`. On first load, migrate from `user_pbox`, then leave `user_pbox` unused.
- Tile instance gains `life` (int) and `rank` (1-4). `pfb_expire` uses `$p['tile']['life'] ?? PFB_LIFE`. The view sends `life_left` (`pfb_view`, `pfb_snap`).
- Fight start: pass `region` (from `$exp`/the route) into the creature row, so `pf_foe_deck($c)` can add region pieces. Treks (`trek_fight.php`) pass none and get no region piece.
- `pf_apply`: foe-side pierce, poison (a `me.poison` tick in `pfb_end_round`), quick, trip (`me.slowdraw`), bash.
- `pf_player_deck`: Kit + Gear. Pals are added, not swapped; tool pieces are ranked by `tool_tier`; rank caps are checked in a new `pf_deck_check` (replaces `pf_box_check`).
- JS port: `pfengine.js` gets the same tables (generated from the txt files by `tools/build_pf_artifact.py`) and life and foe tags; extend the parity test.

## 5. Build order (small steps, each shippable behind `pfight_open`)
1. **Clarity leftovers (P7):** group-spot numbers, creature guard readout, blank expiry label, `add` help, "rounds left" number on pieces. Trim the stale todo line.
2. **Per-piece life** in engine and JS (default 3, so nothing changes yet); view `life_left`; regression test.
3. **Foe-side tags** (pierce, poison, quick, trip, bash); tests that fail on the old engine; tune table.
4. **Creature pieces data** for all 88 creatures plus lean; lint; retune (the 15 duplicate-deck groups go away).
5. **Region into the fight** plus region pieces data; tune per region (one row per region in `pfboard_tune.php`).
6. **Piece catalogue file** plus new sources (tools, crops, crafts, regions, pal-as-addition) in `pf_collection`; no UI yet; sims with random legal decks.
7. **`user_pdeck`** plus migration plus `pf_deck_check` (size, rank caps, Hurt).
8. **Puzzle box v2 page** (Kit, Belt, Pals, Upgrades tabs) and the hovel spot.
9. **Starter pick** gate (new gnomes) and the one-time "New: Gear" note (existing gnomes).
10. **Pre-fight swap screen** (up to 2 swaps).
11. Balance: deck-variety bots, a 100-fight agent round, then **a human session** (still never done).

## 6. Risks
- **Power creep:** bigger decks of ranked pieces make fights easier. Rank caps and a retune (`PFB_FOE_MULT`) at steps 4, 6 and 9.
- **Deck bloat:** 20+ pieces dilute the hand, so good pieces show up late. Kit max and belt slots are the brakes; watch turns per fight.
- **Authoring load:** 88 creatures x 2-4 pieces, 19 tools, 9 crops, about 6 crafts, 14 regions x 2. Ship in batches; archetype fallback stays.
- **Edge legality:** a strong knob lean can leave a hand with no linking move (forced flat placements). Lint: every species keeps at least 1 knob in each family.
- **Pal change:** pals now add instead of replacing. That is a buff and changes the pal party's value; measure it.
- **Existing boxes:** migration must never leave a gnome with an illegal deck (fall back to the default, as `pf_box` does).
- **Parity:** every data change also goes into the JS port; build the JS tables from the txt files to avoid drift.
- **Treks** still use the old fight; their creatures get no region pieces until treks move to the board.

## 7. Open questions for Josh (recommended answer first)
1. **Starter deck size X?** Recommend **10** (4 fixed core + pick 6 of 12, or a one-tap kit); Gear comes on top.
2. **How many tools add a piece?** Recommend a **fight belt of 2 slots (3 at L12, 4 at L20)**, not every tool owned (19 would swamp the deck).
3. **Pals add or replace?** Recommend **add** (each equipped pal adds its piece), and retire the swap rule.
4. **Swaps right before a fight:** recommend **up to 2 swaps** on a pre-fight screen with the creature card; full edits only in the Puzzle box; none once the board is up.
5. **Expiry:** recommend **keep 3 rounds as the default** and add per-piece life 2-4 (Fleeting/Masterwork). Creature pieces stay at 3 + fire budget 2; boss Hold pieces get 3 firings (measure).
6. **Rank caps:** recommend at most **3 Rare and 1 Masterwork** per deck (2 Masterwork at L25).
7. **Tools in fights:** recommend **no wear from fights**; a broken tool leaves the belt until mended.
8. **Creature knob lean** (60% one family, shown before the fight so you can swap for it)? Recommend **yes**, with a lint that keeps every family present.

## DECIDED by Josh 2026-11-12 (answers to Q1-Q8)
1. Starter deck 10: 4 core + pick 6 of 12 (one-tap kit allowed).
2. 2 toolbelt tools add a piece each. NO max deck size (strategy). Slots grow by a BELT UPGRADE (craft or buy), not by level (Q9).
3. Pals add a piece, ONLY active party pals.
4. Swaps: UNLIMITED before the fight, none during.
5. Expiry: keep 3-round default; per-piece 2-4; label on piece.
6. Rarity caps per deck: max 3 Rare, 1 Masterwork.
7. Tool WEAR: a tool loses 2 durability each time ITS piece is played; broken = unusable until fixed, leaves the belt. Repair = a CRAFTED repair item from materials (Q10, Q11). Durability: 20 base, +4 per rank (Q12). Belt: 3 tiers, BOUGHT only (no crafting), slots 2/3/4 (Q13).
8. Creature pieces by layers: 4 base from creature TYPE, + extra from REGION, + extra from monster RARITY or boss tag, + 3 UNIQUE to the creature. Lean not a separate idea.
Next: mockups review by Josh, then build step 1 (clarity items) + engine step for creature tags.
9. Creature TYPE = animal class, ~6: Critter, Bird, Beast, Reptile/Amphibian, Water, Plant/Fungus (Q14). `creatures.txt` has no type column yet: add one and tag ~95 creatures. Each class gets a fixed BASE 4 (2 Hurt, 1 Guard, 1 class trick: Critter quick, Bird evade, Beast bash, Reptile poison, Water trip, Plant thorns/heal). TODO: Claude drafts the table + mockup for Josh to approve (Q15).

## Creature classes: base 4 (draft)

Status: draft for Josh to approve (Q15). Implements DECIDED item 8 and 9. Layer order for a creature deck: **4 BASE (class)** + **region pieces** (3.2) + **rarity / boss pieces** (size extras in 3) + **3 UNIQUE** (authored per creature). So a small creature plays about 4 + 1 + 0 + 3 = 8 pieces, a boss about 4 + 2 + 2 + 3 = 11, in the same boss order idea as today.

`v` is a multiple of the archetype `$v` (`pf_foe_deck`: `round(((die+1)/2 + bonus) * PF_FOE_DMG)`, boss uses `PF_FOE_BOSS`). Guard = about 2/3 of `$v` is the current Brace, so a class Guard sits at 0.6-0.7. Life is 3 unless stated (2 = fleeting). Fire budget stays 2 per creature piece. Every class trick is a Trick-type piece (so it is the "1 class trick" slot and is not counted as a Hurt); its tag is the class identity. Poison/quick/trip/bash/pierce need the foe-side engine support listed in section 3.

### Class tables

**Critter** (swarms, bugs, spiders and their kin). Lean: **mind**. Identity: cheap and fast, keeps drawing. Total Hurt 1.7x, a little under the norm because Quick gives it extra plays.

| Piece | Type | Effect | v | Knob | Tag | Life |
|---|---|---|---|---|---|---|
| Nip | hurt | small bite | 0.9 | mind | - | 3 |
| Sting | hurt | small stab | 0.8 | craft | - | 3 |
| Chitin Shell | guard | thin carapace | 0.6 | body | - | 3 |
| Skitter | trick | creature draws 1 extra | 0.4 | mind | quick | 2 |

**Bird** (wings and feathers). Lean: **craft**. Identity: hard to pin down; the first hit often misses.

| Piece | Type | Effect | v | Knob | Tag | Life |
|---|---|---|---|---|---|---|
| Peck | hurt | quick jab | 1.0 | mind | - | 3 |
| Talon Dive | hurt | swoop | 1.1 | craft | - | 3 |
| Wing Cover | guard | feathers shield | 0.6 | body | - | 3 |
| Flutter Off | trick | next hit on it misses | 0.4 | craft | evade | 3 |

**Beast** (furred land animals). Lean: **body**. Identity: builds guard and cashes it in. Biggest group (30), so the baseline.

| Piece | Type | Effect | v | Knob | Tag | Life |
|---|---|---|---|---|---|---|
| Claw | hurt | plain strike | 1.0 | body | - | 3 |
| Maul | hurt | harder strike | 1.1 | mind | - | 3 |
| Brace | guard | stands firm | 0.7 | body | - | 3 |
| Shoulder Barge | trick | adds its current guard to its next hit | 0.5 | craft | bash | 3 |

**Reptile / Amphibian** (scales, skin, slow blood). Lean: **craft**. Identity: damage over time, the fight gets worse if it drags.

| Piece | Type | Effect | v | Knob | Tag | Life |
|---|---|---|---|---|---|---|
| Bite | hurt | plain bite | 0.9 | body | - | 3 |
| Tail Lash | hurt | sweep | 0.9 | craft | - | 3 |
| Scale Guard | guard | tough hide | 0.7 | mind | - | 3 |
| Venom Spit | trick | 2 poison ticks on your HP (about 0.5 v each) | 0.5 | craft | poison | 3 |

**Water** (sea, river, bog, shell and claw). Lean: **body**. Identity: slows your draw, then hits.

| Piece | Type | Effect | v | Knob | Tag | Life |
|---|---|---|---|---|---|---|
| Snap | hurt | pincer or jaw | 1.0 | body | - | 3 |
| Splash | hurt | wet slam | 0.9 | mind | - | 3 |
| Slick Hide | guard | slippery shell | 0.7 | body | - | 3 |
| Undertow | trick | you draw 1 fewer next round | 0.4 | mind | trip | 3 |

**Plant / Fungus** (growing things and their spirits). Lean: **mind**. Identity: slow, spiky, outlasts you. The class has the fewest creatures (4), so it can be a little stronger without hurting balance.

| Piece | Type | Effect | v | Knob | Tag | Life |
|---|---|---|---|---|---|---|
| Lash Vine | hurt | whip | 0.9 | craft | - | 3 |
| Spore Puff | hurt | cloud | 0.8 | mind | - | 3 |
| Bramble Coat | guard | hits on it hurt the hitter | 0.7 | body | thorns | 3 |
| Sap Mend | trick | recovers a little (heal) | 0.4 | mind | heal | 3 |

Plant note: Josh wrote "thorns/heal". Draft puts thorns on the Guard and heal on the class slot, so the Plant is the only class whose 4th piece is a heal-effect (type kept as a trick for the slot, effect heal). If that is one tag too many, drop heal and make the class slot a plain thorns trick.

### Balance notes
- **Hurt budget:** every class gets 1.7-2.1x `$v` of Hurt across its 2 pieces; compare with today's archetype (two hits at 1.0 plus a Rend at 1.1 for hostile). Classes are weaker in raw Hurt than the archetype because the unique 3 and region pieces add more.
- **Guard** 0.6-0.7: Critter and Bird lower (they rely on quick or evade), Beast, Reptile, Water and Plant 0.7.
- **Trick slot** 0.4-0.5: its value matters little, the tag is the point. Poison at 0.5 over 2 ticks is the most damaging, so Reptile Hurt stays at 0.9.
- **Danger combos:** Critter quick + unique Hurt-quick (e.g. Aphid Swarm) can fire 3-4 pieces a turn; cap with the fire budget 2 and test Gnat Cloud. Reptile poison + region poison (Dunewhisper, Spicepeak) stacks; stack cap proposal: poison ticks do not stack, a second poison refreshes. Water trip + region trip (Maplewold) is the other stack: cap at 1 draw lost.
- **Knob families:** each class lists all three families in its 4 pieces; this keeps the lint "every species has at least 1 knob in each family" true before uniques are added. The class lean is a tendency, not a rule, and is shown as a bar on the creature card.
- **Class sizes** (from the table below): Beast 30, Critter 17, Reptile/Amphibian 15, Bird 11, Water 11, Plant/Fungus 4. Plant is thin; if Josh prefers, fold Plant/Fungus into Beast and keep 5 classes (open question below).
- **Retune:** run `tests/pfboard_tune.php` once the foe tags exist; aim for no size row moving more than 5 points.

### CLASS TAG TABLE
`slug=Class`, `?` = unsure (13). Order within a class follows `creatures.txt`.

**Critter** (17 creatures, 5 unsure)
```
aphid-swarm=Critter
ant-scouts=Critter
gnat-cloud=Critter
sand-fleas=Critter
dusk-moth=Critter
dung-beetle=Critter
earwig=Critter
cave-glowworm=Critter
paper-wasp=Critter
ember-beetle=Critter
leafcutter-column=Critter
giant-bumblebee=Critter
garden-snail=Critter
leopard-slug=Critter
orb-spider=Critter
dune-scorpion=Critter
giant-centipede=Critter
```

**Bird** (11 creatures, 0 unsure)
```
carrion-crow=Bird
herring-gull=Bird
grey-heron=Bird
tawny-owl=Bird
great-hawk=Bird
snow-owl-monarch=Bird
storm-eagle=Bird
fern-cassowary=Bird
ptarmigan-flock=Bird
pelican-parliament=Bird
griffon-vulture=Bird
```

**Beast** (30 creatures, 3 unsure)
```
grumpy-lemming=Beast
barn-rat=Beast
tunnel-mole=Beast
frost-hare=Beast
mischief-monkey=Beast
red-fox=Beast
raccoon=Beast
arctic-fox=Beast
badger=Beast
bramble-wolf=Beast
jungle-tiger=Beast
cloud-leopard=Beast
savanna-hyena=Beast
honey-badger-brute=Beast
thunder-yak=Beast
outback-dingo=Beast
cliff-ram=Beast
wolverine=Beast
wild-boar=Beast
beaver-foreman=Beast
giant-anteater=Beast
tufted-lynx=Beast
black-bear=Beast
glacier-bear=Beast
prairie-bison=Beast
desert-camel=Beast
lichen-reindeer=Beast
sea-otter-bandit=Water
salt-sea-lion=Water
jade-jaguar=Beast
```

**Reptile/Amphibian** (15 creatures, 1 unsure)
```
bullfrog=Reptile/Amphibian
sun-lizard=Reptile/Amphibian
grass-snake=Reptile/Amphibian
mire-toad=Reptile/Amphibian
ancient-snapper=Reptile/Amphibian
dune-wyrm=Reptile/Amphibian
delta-gharial=Reptile/Amphibian
emerald-python=Reptile/Amphibian
spice-monitor=Reptile/Amphibian
sand-viper-matriarch=Reptile/Amphibian
dust-sidewinder=Reptile/Amphibian
poison-dart-frog=Reptile/Amphibian
desert-gila-dragon=Reptile/Amphibian
desert-tortoise=Reptile/Amphibian
reef-turtle=Reptile/Amphibian
```

**Water** (11 creatures, 1 unsure)
```
shore-crab=Water
tide-crab-knight=Water
coconut-crab-titan=Water
reef-leviathan=Water
mangrove-crab-king=Water
reef-eel-lord=Water
deep-octopus=Water
hermit-crab-hoarder=Water
bog-pike=Water
clam-lurker=Water
bog-leech=Water
```

**Plant/Fungus** (4 creatures, 3 unsure)
```
moss-golem=Plant/Fungus
thistle-beast=Plant/Fungus
will-o-wisp=Plant/Fungus
old-bramblehorn=Plant/Fungus
```
Judgement calls behind the `?` tags: spiders, scorpions and centipedes are arachnids or myriapods but read as "bugs" to a gnome, so Critter; snails and slugs are land invertebrates, so Critter too (Water was the alternative for the snail); sea otter and sea lion are mammals living on the coast (Beast or Water); Reef Turtle could be Reptile or Water; Jade Jaguar Spirit is a spirit (Beast or Plant); Thistle Beast, Will-o'-Wisp and Old Bramblehorn are the only Plant/Fungus candidates, so Plant stays small.

Data: add a `class` column to `creatures.txt` (after `size`), values `insect|bird|beast|reptile|water|plant`; the base 4 live in a new `pf_class_pieces.txt` (`class|n|type|v_mult|knob|tag|life`).

Open: (a) keep 6 classes or fold Plant into Beast; (b) poison and trip stacking caps above; (c) mockup screen 5 shows the layers.
10. DECIDED (Q16-Q19): keep 6 classes (Plant/Fungus stays). Class "Insect" renamed CRITTER (insects, spiders, scorpion, centipede, snail, slug; trick quick). Sea otter bandit, salt sea lion, bog leech = Water; reef turtle = Reptile/Amphibian; jade jaguar = Beast; thistle beast, will-o-wisp, old bramblehorn = Plant/Fungus. No `?` tags left. Stacking caps for poison/trip still untested.
11. DECIDED (Josh): Pre-fight screen: Auto-use current deck option (remembered per player); creature card still shown; active deck shown read-only (with a way to turn Auto off and edit); then Let's fight.

## Authored edges (DECIDED by Josh 2026-11-12, ideas 1-3: authored edges, harmony meter, flip)

Replaces the crc32 hash for the top and bottom edges (`pfb_edges`). Sim and numbers: `claude/design-board-strategy.md`, "Sim 4". Built so far only in the design demo (`tools/pfdemo_v1/data.js`, `edgesOf`); game code not changed.

**Rule (one piece = four edges, no flat edges):**
- **Left:** a hole of the piece's TYPE family (as today: Hurt and Guard body; Heal, Charm and Soothe mind; Trick and Item craft).
- **Right:** a knob of the authored `knob` family (as today: what the piece leads into).
- **Top and bottom:** one knob and one hole of the piece's COLUMN family `col`. Sourced pieces use the source family: **pals body, tools craft, crops mind, crafts craft**. Basics, knacks, calling and region pieces use their TYPE family.
- **Way up (`up`):** Hurt, Charm and Trick pieces carry the column knob on top and the hole below; Guard, Heal, Soothe and Item the other way round.
- **Same type connects by design:** two pieces of the same type and column family always stack (Swing on Jab, Dodge on Brace). Two pieces of one family but a different way up (Swing on Dodge) link after one of them is flipped.
- **Flip:** once a turn, free, the player swaps the top and bottom edges of the piece they are about to place. It stays flipped. The creature does not flip.
- **Creatures:** the class lean is the column family of 3 pieces in 5 of the creature's deck (base 4, region, size, unique, in deck order); the other 2 use their type family. The way up alternates by type as for the player.
- **Lint:** every legal deck must have a linking move on 90% of turns or more (the harmony meter's "hand links" number; sim 4 measured 95-96% with the starter deck).

**Puzzle box: deck harmony meter.** Under the Teamwork row: "Link rate" (share of piece-next-to-piece placements inside the deck that link, on any side, flip allowed), "hand links" (chance a hand of 5 has a piece that links to one of 2 other deck pieces) and a body / mind / craft bar of the deck's knob families. Hint: mixed sources give Teamwork, one family gives easy chains.

**Player pieces (demo catalogue)**

| Piece | Type | Source | Left | Right | Top | Bottom |
|---|---|---|---|---|---|---|
| Swing | hurt | basic | hole body | knob mind | knob body | hole body |
| Dodge | guard | basic | hole body | knob body | hole body | knob body |
| Rest | heal | basic | hole mind | knob craft | hole mind | knob mind |
| Charm | charm | basic | hole mind | knob craft | knob mind | hole mind |
| Thorn Cut | hurt | calling | hole body | knob craft | knob body | hole body |
| Jab | hurt | knack | hole body | knob craft | knob body | hole body |
| Snack | item | basic | hole craft | knob body | hole craft | knob craft |
| Hide | trick | basic | hole craft | knob body | knob craft | hole craft |
| Oat Cake | guard | crop | hole body | knob craft | hole mind | knob mind |
| Herb Poultice | heal | crop | hole mind | knob body | hole mind | knob mind |
| Brace | guard | knack | hole body | knob craft | hole body | knob body |
| Soothe | soothe | knack | hole mind | knob mind | hole mind | knob mind |
| Hum | charm | knack | hole mind | knob body | knob mind | hole mind |
| Pierce | hurt | knack | hole body | knob mind | knob body | hole body |
| Frost Bark | guard | region | hole body | knob body | hole body | knob body |
| Pepper Puff | hurt | crop | hole body | knob body | knob mind | hole mind |
| Berry Burst | hurt | crop | hole body | knob mind | knob mind | hole mind |
| Juicy Bite | item | crop | hole craft | knob craft | hole mind | knob mind |
| Honey Glaze | charm | crop | hole mind | knob mind | knob mind | hole mind |
| Tonic | heal | craft | hole mind | knob mind | hole craft | knob craft |
| Compost Lob | hurt | craft | hole body | knob body | knob craft | hole craft |
| Spare Handle | guard | craft | hole body | knob mind | hole craft | knob craft |
| Mist Veil | guard | region | hole body | knob mind | hole body | knob body |
| Cold Snap | hurt | region | hole body | knob body | knob body | hole body |
| Monsoon Spice | hurt | region | hole body | knob body | knob body | hole body |
| Lull | charm | knack | hole mind | knob craft | knob mind | hole mind |
| Shield Bash | hurt | knack | hole body | knob mind | knob body | hole body |
| Roll | guard | knack | hole body | knob body | hole body | knob body |
| Hoe Hook (Steel Spade) | hurt | tool | hole body | knob body | knob craft | hole craft |
| Glare (Masterwork Lantern) | charm | tool | hole mind | knob craft | knob craft | hole craft |
| Sweep (Ash Staff) | guard | tool | hole body | knob mind | hole craft | knob craft |
| Reel In (Reed Rod) | trick | tool | hole craft | knob body | knob craft | hole craft |
| Chop (Hatchet) | hurt | tool | hole body | knob body | knob craft | hole craft |
| Net Toss (Bug Net) | hurt | tool | hole body | knob craft | knob craft | hole craft |
| Bark Badger | guard | pal | hole body | knob craft | hole body | knob body |
| Acorn Nip | heal | pal | hole mind | knob mind | hole body | knob body |
| Samara Spin | hurt | pal | hole body | knob body | knob body | hole body |
| Moth Glow | charm | pal | hole mind | knob body | knob body | hole body |

**Class base 4** (lean = the family 3 pieces in 5 of a creature stack in; shown for the base 4 as dealt first)

| Piece | Type | Class (lean) | Left | Right | Top | Bottom |
|---|---|---|---|---|---|---|
| Nip | hurt | Critter (mind) | hole body | knob mind | knob mind | hole mind |
| Sting | hurt | Critter (mind) | hole body | knob craft | knob mind | hole mind |
| Chitin Shell | guard | Critter (mind) | hole body | knob body | hole mind | knob mind |
| Skitter | trick | Critter (mind) | hole craft | knob mind | knob craft | hole craft |
| Snap | hurt | Water (body) | hole body | knob body | knob body | hole body |
| Splash | hurt | Water (body) | hole body | knob mind | knob body | hole body |
| Slick Hide | guard | Water (body) | hole body | knob body | hole body | knob body |
| Undertow | trick | Water (body) | hole craft | knob mind | knob craft | hole craft |
| Peck | hurt | Bird (craft) | hole body | knob mind | knob craft | hole craft |
| Talon Dive | hurt | Bird (craft) | hole body | knob craft | knob craft | hole craft |
| Wing Cover | guard | Bird (craft) | hole body | knob body | hole craft | knob craft |
| Flutter Off | trick | Bird (craft) | hole craft | knob craft | knob craft | hole craft |
| Lash Vine | hurt | Plant / Fungus (mind) | hole body | knob craft | knob mind | hole mind |
| Spore Puff | hurt | Plant / Fungus (mind) | hole body | knob mind | knob mind | hole mind |
| Bramble Coat | guard | Plant / Fungus (mind) | hole body | knob body | hole mind | knob mind |
| Sap Mend | trick | Plant / Fungus (mind) | hole craft | knob mind | knob craft | hole craft |
| Bite | hurt | Reptile / Amphibian (craft) | hole body | knob body | knob craft | hole craft |
| Tail Lash | hurt | Reptile / Amphibian (craft) | hole body | knob craft | knob craft | hole craft |
| Scale Guard | guard | Reptile / Amphibian (craft) | hole body | knob mind | hole craft | knob craft |
| Venom Spit | trick | Reptile / Amphibian (craft) | hole craft | knob craft | knob craft | hole craft |
| Claw | hurt | Beast (body) | hole body | knob body | knob body | hole body |
| Maul | hurt | Beast (body) | hole body | knob mind | knob body | hole body |
| Brace | guard | Beast (body) | hole body | knob body | hole body | knob body |
| Shoulder Barge | trick | Beast (body) | hole craft | knob craft | knob craft | hole craft |

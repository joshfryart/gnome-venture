# PROPOSAL: Level bands, new routes, Seals and Wren's Journey rewrite

Status: PROPOSAL ONLY (2026-11-27). No code. Josh to veto/pick.
Reading: "Mapleworld" = The Maplewold (NA). "First three areas" = Maplewold + its two road neighbours (Maizehollow CA, Mistmoor NWE).
Builds on: `includes/progression.php` (REGION_LEVELS), `includes/roads.php` (ROAD_PAIRS), `includes/journey.php` (Wren's Journey), `data/zones.txt`, `data/landmarks.txt`.

## 1. What is here now
- Levels: NA 1, CA 4, NWE 6, CB 8, SE 10, SA 12, EE 14, MENA 17, EA 20, CSA 23, SEA 26, WCA 29, ESA 32, OC 35. Seven regions in L1-14.
- Gate: none. Level is a "recommended" badge. Roads are always open. Fast travel needs one walk there.
- Maplewold: 4 zones (Prairie, Old Maplewood, Foghorn Shallows, Frostbitten North), 10 villages, 6 landmarks. Roads: NA-CA, NA-NWE, NA-EA (dead end Clovercove).
- Journey: 4 chapters only (NA, CA, NWE, CB). Each = 4 tasks + 3 build stages. 14 regions, 10 chapters missing.
- XP (xp_for_level, steep from L10, +15%): total XP to L5 2,000 · L10 16,500 · L15 75,650 · L25 625,700 · L35 2.51M · L45 7.04M.
- Creature data tops at Lv 37 (roads.php note). Lairs sit at region level + 4.

## 2. Bands (the spine)
Rule: a band = the levels you earn by finishing that area. Bands of ~10 levels. Siblings share a band and can be done in any order.

| Tier | Areas | Band | Total XP at top |
|---|---|---|---|
| 1 Home | Maplewold | 1-15 | 75.7k |
| 2 Twin neighbours | Maizehollow, Mistmoor | 15-25 | 626k |
| 3 Second ring | Sunsprinkle (CB), Rainroot (SA) off CA · Olivewhistle (SE), Birchbramble (EE) off NWE | 25-35 | 2.5M |
| 4 Far ring | Dunewhisper (MENA), Spicepeak (CSA), Greatcanopy (WCA), Thornacre (ESA) | 35-45 | 7.0M |
| 5 Edge | Blossomreach (EA), Monsoon Tangle (SEA), Coralscatter (OC) | 45-55 | 16M |

Notes:
- Map graph already fits: CA gives CB+SA, NWE gives SE+EE, those give MENA/CSA/ESA/WCA, then EA/SEA/OC.
- Tier 4-5 break the Lv 37 creature cap. Either add creatures, or compress tiers 4-5 into 35-40 and reuse. Needs Josh call (see section 8).
- Inside an area, zones ladder: zone 1 = band floor, last zone + lair = band top. Lair = band top (Owl 15, not 10).

### Maplewold 1-15 (6 zones, was 4)
| Zone | Lv | Status |
|---|---|---|
| Bramblesweep Prairie | 1-4 | exists |
| Old Maplewood | 4-7 | exists |
| Foghorn Shallows | 7-10 | exists |
| **Beaverdam Fens** (wetland) | 8-11 | NEW. NA already has `mountain, wetland` in REGION_EXTRA_LANDS |
| Frostbitten North | 11-13 | exists |
| **Cairnback Ridge** (mountain) | 12-15 | NEW |
Capstone: Den of the Great White Owl, Lv 15.

### Twin neighbours 15-25
Each of CA and NWE runs 15-25 over its 4 zones (15-17, 18-20, 21-23, 24-25 + lair). Player alternates or finishes one. Both are "Tier 2": finishing both is what opens tier 3 fully (see section 4).

## 3. New routes (off existing roads)
Rule: a new route hangs off a road village or a zone, never replaces a road. Roads stay gentle. New routes = side/wild kind, level from the band.

### Maplewold
1. **Fen Path**. Off the NA-NWE road, village 2. Beaverdam Fens. Hidden: Heron Stilt Village (haven), Dam Debt (wonder), Beaverdam Tunnels delve moves here (now floats). Loops back to Foghorn Shallows. L8-11.
2. **Cairnback Climb**. Off the NA-CA road, village 3. Cairnback Ridge. Cairnback Pass (wonder), Cairn Keeper's Hut (haven), Hollow Peak delve. L12-15. End: Smokecap foothills in CA = the "high road" shortcut (opens after Maplewold Seal).
3. **Aurora Road**. Frostbitten North -> Aurora Camp -> Owl's Den. L11-15. Past the Den: **Northern Rim Pass** to Long Night Fells (NWE). Hard route, L15-18, opens after the Owl.
4. **Tide Track**. Foghorn Shallows -> Lantern Lighthouse -> **Ferry Landing**. Ferry to Sunsprinkle (CB) shown but tide-locked. Opens at tier 3 gate.
5. Clovercove (existing dead end to Blossomreach): stays closed beyond the village. Gains a "Clovercove Gatehouse" Wren note: "too far, come back at 45".

### Maizehollow (CA)
1. **Cenote Underway**: delve linking Cactusbristle Barrens to Quetzal Tangle. L17-21.
2. **Ash Road**: Smokecap Volcanoes -> Cloudcorn Terraces (haven/wonder). L22-25. Meets Cairnback Climb.
3. **Isthmus Track**: south over the land bridge to Rainroot Reaches (SA). Gate door.
4. **Ferry Cove**: coast to Sunsprinkle (CB). Gate door.

### Mistmoor (NWE)
1. **Ley Walk**: Standing Stones to Fairy-ring Clearing to Barrow. Stones link as fast-travel nodes inside the region. L16-22.
2. **Fell Pass**: Long Night Fells east to Birchbramble Steppe (EE). Gate door.
3. **Smugglers' Tide**: sea caves to Olivewhistle Shore (SE). Gate door.
4. Northern Rim Pass joins here (from the Maplewold).

Counts: Maplewold +4 routes, +2 zones, ~8 new places. CA/NWE +4 and +3 routes, ~6 new places each. Data: `routes`, `roads` (kind side/wild), `landmarks.txt`, `zones.txt`, trail maps (not drawn; art brief needed).

## 4. Completion and Seals (the gate)
Each area has an **Expedition Standing** (0-100%) on its Wren page. Count what already exists:

| Part | Weight | Source (exists) |
|---|---|---|
| Wren chapter done | 20 | `user_quests` |
| Road villages and off-road places found | 25 | explore / `find` task |
| Townsfolk at Friend (not just Acquaintance) | 10 | friends.php |
| Staple and native crops harvested | 10 | `grow` task |
| Delve cleared | 15 | delves |
| Lair beaten or charmed | 15 | lairs |
| Almanac pages for the area | 5 | encyclopedia |

- **80% Standing = Area Seal** (a Waymark jar of Tansy's seed). Items: Maplewold Seal, Maizehollow Seal, Mistmoor Seal, ...
- Gates:
  - Tier 1 and 2: open roads. Level badge only. (Josh: "past the first three" is the first lock.)
  - Tier 3 doors (Isthmus, Ferry Cove, Fell Pass, Smugglers' Tide, Tide Track) need **both** Maizehollow and Mistmoor Seals. Hmm: 1 seal per door is looser. Default: the seal of the area you leave. Open question 4.
  - Tier 4+: seal of the area you leave, same rule.
- Each gate has a Warden NPC (a gnome at the last village) with a line from Wren. No seal: they tell you what is missing ("Fens 62%: the Dam Debt, 2 hidden places").
- Fast travel: unchanged (walk once), but a Seal-locked door still needs the Seal.
- Level fix: do **not** hard-block by level. The XP budget does that (below).

### XP budget (why the Seal also means "right level")
- Each band must be completable without grinding: area completion pays ~85% of the band's XP, grinding the rest.
- Past the band top: action XP in that area x0.25 (existing `add_action_xp` has a scale hook). Stops "stay and farm Maplewold to L20".
- Completion XP sources: chapter, first finds, delve, lair, friends, Seal. These use `add_xp` directly (not scaled).
- Numbers (Maplewold 75.7k to L15) need a sim before locking: see `claude/balance-2.7.27-sims.md` for method. I did not run a sim.

## 5. Wren's Journey rewrite
### Spine
Keep: Tansy Greenwhistle, Wren's field guide, clue chain ("south", "mist that never lifts", island names, olive light). Add:
- The roads are a **mycelium network**. Tansy left to wake it: one **Heartroot knot** per area. A Seal = a wake-up jar she hid.
- Hollowheart = the root all roads run to. "Sleeps where the reef sings" = Coralscatter (OC), end of the map.
- Each act ends on a letter and a bigger jump in the map.
- Tone unchanged: small local helps, funny NPCs, warm.

### Acts
| Act | Area | Levels | Chapters |
|---|---|---|---|
| I Wake the Roots | Maplewold | 1-15 | 7 |
| II The Two Doors | Maizehollow + Mistmoor | 15-25 | 4 + 4 + joint finale |
| III Along the Coast and Steppe | CB, SA, SE, EE | 25-35 | 1 per area + 1 per branch |
| IV The Long Road | MENA, CSA, WCA, ESA | 35-45 | per area |
| V The Hollowheart | EA, SEA, OC | 45-55 | per area + finale |

### Act I chapters (Maplewold)
| # | Lv | Zone | Chapter | Beat |
|---|---|---|---|---|
| 1 | 1-4 | Prairie | The Sugar Shack | exists. Add: Tansy's initials on a sap bucket |
| 2 | 4-7 | Old Maplewood | The Thousand Rings | read the stump: Tansy's mark at ring 40 (she was here 40 years back) |
| 3 | 7-10 | Foghorn Shallows | The Lantern | relight the Lost Lantern; keeper saw Tansy sail |
| 4 | 8-11 | Beaverdam Fens | The Dam Debt | NEW. Beaver Council, rebuild the dam, fen herbs |
| 5 | 11-13 | Frostbitten North | The Aurora Camp | NEW. Camp lamps; Tansy's frozen notebook |
| 6 | 12-15 | Cairnback Ridge | The Keeper's Cairns | NEW. Stack the cairns, open the pass |
| 7 | 15 | Owl's Den | What the Owl Guards | Capstone: the owl holds Tansy's first jar. Maplewold Seal. Letter: two ways, south or mist |

### Act II chapters
Maizehollow: Granary (exists, retime to 15-17) / The Cenote Echo / The Ash Road Terraces / Smokecap Caldera (lair, Seal).
Mistmoor: Footbridge (exists, retime 15-17) / The Leys / The Long Night Fell / Barrow of the Frost Toad (lair, Seal).
Joint finale **The Crossing**: both Seals fit one stone door, shows a map, names two islands "coral" and "olive". Opens tier 3.
Fix a canon bug: the CB chapter's letter points to Olivewhistle and is chapter 4 today. After the rewrite CB/SA/SE/EE are all siblings; Wren's letters name two next stops each.

### Chapter shape (reuse journey_seed)
Each chapter stays: 4 tasks (visit, grow, friend, find) + 3 build stages + Wren letter + benefit. New: (a) a **clue** line (Tansy's trail), (b) a **Standing** link: chapter = 20% weight, (c) boss chapters end on the lair.
Benefits stay one per chapter (native_plus, sell_bonus, free_travel, weekly_crate). Need ~8 more benefit types for chapters 5-30, or reuse with bigger numbers.
Count: ~7 + 8 + 1 + 8 + 14+ ... roughly 40 chapters at full scale. Ship Act I + II first (≈20).

## 6. Delivery order
1. Config only: new REGION_LEVELS bands, Owl Lv 15, region `min_level` update + migration step for existing gnomes.
2. Standing meter on Wren's page (read-only, no gates).
3. Seals + Wardens at the 5 tier 3 doors.
4. New Maplewold zones/routes (data + art brief).
5. Act I chapters 2-7 (data).
6. Act II routes and chapters.
7. Tier 3 and onward: one area per release.
Existing worlds: players already in tier 3+ keep access (grandfather via region_visits).

## 7. Risks
- XP: steep formula plus x0.25 past band can feel like a wall. Sim first.
- Journey data is currently code (`journey_seed`). 40 chapters in code is heavy: move to a `data/journey_chapters.txt`.
- New zones need trail maps and landscapes; none drawn.
- Grandfathering: don't lock gnomes already past the doors.
- Creature cap 37.

## 8. Decisions for Josh
1. Confirm Maplewold alone is L1-15 (not Maplewold + CA + NWE).
2. Tier 4-5: add creatures above 37, or compress bands to 35-40?
3. Seal threshold 80% ok? Any part you want weighted more (combat vs exploring)?
4. Tier 3 door needs the seal of the area you leave, or both Tier 2 seals?
5. Hard block by Seal only, or also Wren-warden level warning?
6. Tansy / Hollowheart / mycelium-wake story: keep, or different spine?

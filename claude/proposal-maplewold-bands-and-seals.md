# PROPOSAL: Level bands, new routes, Seals and Wren's Journey rewrite

Status: PROPOSAL ONLY (2026-11-27). No code. Josh to veto/pick.
Pass 4 review (2026-11-27): corrected in place, see `claude/proposal-story-4-review.md`. Section 5 is superseded by `proposal-story-1-base.md` / `proposal-story-2-quests.md`; the Standing table in section 4 now matches the base story.
Reading: "Mapleworld" = The Maplewold (NA). "First three areas" = Maplewold + its two road neighbours (Maizehollow CA, Mistmoor NWE).
Builds on: `includes/progression.php` (REGION_LEVELS), `includes/roads.php` (ROAD_PAIRS), `includes/journey.php` (Wren's Journey), `data/zones.txt`, `data/landmarks.txt`.

## 1. What is here now
- Levels: NA 1, CA 4, NWE 6, CB 8, SE 10, SA 12, EE 14, MENA 17, EA 20, CSA 23, SEA 26, WCA 29, ESA 32, OC 35. Seven regions in L1-14.
- Gate: none. Level is a "recommended" badge. Roads are always open. Fast travel needs one walk there.
- Maplewold: 4 zones (Prairie, Old Maplewood, Foghorn Shallows, Frostbitten North), 10 villages, 6 landmarks. Only 3 villages are on a road (Poppyburrow, Honeybrook, Cloverholt, all Bramblesweep Prairie; `lay_roads` takes starter-zone villages first). The other 7 are off-road. Only road villages can be adopted (`place_ui.php` checks `on_road`), so the Maplewold has 3 adoptable stops; most areas have 3 to 7. Roads: NA-CA, NA-NWE, NA-EA (dead end Clovercove).
- Journey: 4 chapters only (NA, CA, NWE, CB). Each = 4 tasks + 3 build stages. 14 regions, 10 chapters missing.
- XP (xp_for_level, steep from L10, +15%): total XP to L5 2,000 · L10 16,500 · L15 75,650 · L25 625,700 · L35 2.51M · L45 7.04M.
- Creature data tops at Lv 37 (roads.php note). Lairs sit at region level + 4 (`LAIR_LEVEL_1115`, roads.php), except the Owl (10) and the Silverback Spider (20).
- Fixed routes are clamped to Lv 40 (`route_danger`, adventure.php ~179).

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
- Map graph (`ROAD_PAIRS`, checked in pass 4): it does **not** fully fit. Tier 2 to 3: CA-CB, CA-SA, NWE-SE, NWE-EE (good). Tier 3 to 4: only SE-MENA and EE-CSA. **Sunsprinkle (CB) and Rainroot (SA) have no road to any tier 4 area.** Inside tier 4: MENA-WCA, MENA-CSA, WCA-ESA, ESA-CSA. Tier 4 to 5: only CSA-EA and CSA-SEA. **SA-OC joins tier 3 straight to tier 5.** NA-EA is the Clovercove dead end. Inside tier 5: EA-SEA, SEA-OC.
  - Consequences: every tier 5 area is reached through Spicepeak (or the SA-OC road); WCA and ESA are side pockets of tier 4; CB and SA lead on only to OC. Fixes are in section 4 (gates) and open item 1 of the review.
- Tier 4-5 go past the Lv 37 creature cap: add creatures 38-55 (settled).
- Inside an area, zones ladder: zone 1 = band floor, last zone + lair = band top. **Lair rule (one rule, pass 4): lair = band top.** Owl 15, tier 2 lairs 25, tier 3 35, tier 4 45, tier 5 55. The creature list (`proposal-creatures-38-55.txt`) uses the same rule. This replaces "region level + 4" in `LAIR_LEVEL_1115`.

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
Note: the new zones' places (Fens, Ridge) are off-road, so they hold no adoptable stops unless adoption is opened to off-road villages (review, open item 2).

### Twin neighbours 15-25
Each of CA and NWE runs 15-25 over its 4 zones (15-17, 18-20, 21-23, 24-25 + lair). Player alternates or finishes one. Both are "Tier 2": finishing both is what opens tier 3 fully (see section 4).

## 3. New routes (off existing roads)
Rule: a new route hangs off a road village or a zone, never replaces a road. Roads stay gentle. New routes = side/wild kind, level from the band.

### Maplewold
1. **Fen Path**. Off the NA-NWE road, village 2 (check which region that village is in; road villages alternate). Beaverdam Fens. Hidden: Heron Stilt Village (haven), Dam Debt (wonder), Beaverdam Tunnels delve moves here (now floats). Loops back to Foghorn Shallows. L8-11.
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

Pass 4: the table below is the one in `proposal-story-1-base.md` section 4 (the only Standing table; keep them identical). Sums to 100. A gnome who never fights can reach 90 (95 where the lair has a peaceful act), so 80 has slack.

| Part | Weight | Source |
|---|---|---|
| Stops: lit 14, raised 10, Hearth 6 | 30 | stops, Regular count |
| Wren's flagship Repair done | 15 | chapter stages |
| Road villages and off-road places found | 10 | explore / `find` |
| Folk: Friend 5, stop threads 5, errands 5 | 15 | friends.php, threads, errand log |
| Gardening: grown 5, signature bed 6, in flower 4 | 15 | harvest log, Seed Bed |
| Delve cleared | 5 | delves |
| Lair beaten, charmed, or its peaceful act | 5 | lairs |
| Almanac pages for the area (places, crops, folk; not creature pages) | 5 | encyclopedia |

- **80% Standing = Area Seal** (Wren's bound Almanac section). Items: Maplewold Seal, Maizehollow Seal, Mistmoor Seal, ...
- Gates:
  - Tier 1 and 2: open roads. Level badge only. (Josh: "past the first three" is the first lock.)
  - Tier 3 doors need **both** Maizehollow and Mistmoor Seals (settled). The doors are the four **existing** roads CA-CB (Ferry Cove), CA-SA (Isthmus Track), NWE-SE (Smugglers' Tide), NWE-EE (Fell Pass), gated at their last tier 2 village, plus the new Tide Track ferry (NA-CB). The names are the gate stretches of those roads, not extra roads; otherwise the open roads would bypass the gate.
  - The Seal is checked the moment both are held. Nothing else (no chapter, no ceremony step) stands between the two Seals and the doors.
  - Tier 4 doors (only SE-MENA and EE-CSA exist): the Seal of the area you leave. Roads between siblings of the same tier (CB-SA, MENA-WCA, MENA-CSA, WCA-ESA, ESA-CSA, EA-SEA, SEA-OC) are open once you are in that tier.
  - Tier 5 doors: CSA-EA and CSA-SEA need the Spicepeak Seal. **SA-OC** skips tier 4: proposed, it needs any one tier 4 Seal (to confirm, review open item 1).
  - Clovercove (NA-EA): needs all 14 Seals (the final chapter).
- Each gate has a Warden NPC (Hobb Stiles's Wardens, a gnome at the last village) with a line from Wren. No seal: they tell you what is missing ("Fens 62%: the Dam Debt, 2 hidden places").
- Fast travel: unchanged (walk once), but a Seal-locked door still needs the Seal.
- Level fix: do **not** hard-block by level. The XP budget does that (below).

### XP budget (why the Seal also means "right level")
- Each band must be completable without grinding: area completion pays ~85% of the band's XP, grinding the rest.
- Past the band top: action XP in that area x0.25 (existing `add_action_xp` has a scale hook). Stops "stay and farm Maplewold to L20".
- Completion XP sources: chapter, first finds, delve, lair, friends, Seal. These use `add_xp` directly (not scaled).
- Numbers (Maplewold 75.7k to L15) need a sim before locking: see `claude/balance-2.7.27-sims.md` for method. I did not run a sim.

## 5. Story: The Hollow in Disrepair (replaces the Tansy / Hollowheart spine)
Pass 4: superseded in detail by `proposal-story-1-base.md` and `proposal-story-2-quests.md`; kept as the first sketch.
Josh decisions (2026-11-27): no Trek story; no Tansy hunt. Keep the main Journey quest = **fill the Almanac** (Wren's field guide). The Hollow is run down; the gnome fixes it and helps its folk, at leisure.

### Spine
- Wren is finishing the Almanac, one area at a time. Her letters and the area guide stay. The Almanac is the progress book: every page you earn is a thing you did, found or fixed.
- The Hollow is in disrepair: roofs, bridges, wells, lamps, roads. Each area has a Repair List. Mending things wakes the area (more folk out, shops restock, new places show).
- No big villain. No race. Everything is optional and in any order inside an area. Leisure first: nothing times out, no failure state.
- Seal (80% Standing) = "the area's Almanac section is complete": Wren binds the section and the next road door opens.

### Three kinds of Almanac content per area
1. **Repairs** (the build stages, kept from `journey_seed`): hand in materials, a place reopens. Sugar Shack, Granary, Footbridge, Lighthouse stay as the first repair of their area. Add 4-6 more per area (well, mill, noticeboard, ferry steps, lamp posts). Each reopened place gets a daily action (JOURNEY_SPOTS already does this).
2. **Folk errands** (the living world): a villager asks for help, tied to the world as it runs.
   - *Lost*: a gnome is stranded off the path; find them in a hidden place (uses explore / hidden places), walk them back to their village (an escort: travel to a named stop).
   - *Creature trouble*: a creature is raiding the cabbages or blocking a bridge; fight or charm it (uses fights and lairs, scaled to the band).
   - *Missing thing*: a lost lantern, a runaway goat, a letter to deliver (carry item A to village B).
   - *Fix-up aid*: bring meals, tools, plants for a neighbour.
   - *Friend favours*: grow with friendship levels (existing).
   Errands are posted on the town noticeboard and by NPCs at their clockwork spots (`npc_clockwork`). A few at a time, never a list of 40.
3. **Discoveries**: hidden places, creatures met, crops grown, recipes, wonders. Each earns its Almanac page (existing). Standing counts them.

### Almanac page, per area ("Section")
Wren's cover note, the guide (crops, soil), then three tabs: Repairs ✔/☐, Folk (who needs what), Finds. Standing % shown on top. Pages fill as you go; no page is gated behind another.

### Act shape (reuse chapters, bands unchanged)
| Part | Area | Levels | Repairs (examples) | Folk errands (examples) |
|---|---|---|---|---|
| I | Maplewold | 1-15 | Sugar Shack roof, Thousand Rings Stump, Lantern, Beaverdam dam, Aurora Camp lamps, Cairns, Owl's Den gate | lost lamb on the prairie, beaver council dispute, stranded fisher at the Shallows, aurora-camp cook needs a wolf shooed |
| II | Maizehollow, Mistmoor | 15-25 | Granary, Cenote steps / Footbridge, Ley stones | trader lost in the Quetzal Tangle, fell-herder's goat flock, smuggler wants out |
| III-V | each area, in order of the band table | 25-55 | per area, same shape | per area |

### Chapter data (what to build)
- Keep the table `quest_chapters`: tasks (visit/grow/friend/find) and build stages are already the Repair List. Add task kinds: `help` (complete N folk errands), `escort`, `defeat`.
- Errands live in a new data file (`data/journey_errands.txt`): area, zone, giver, kind, target place/creature, reward, level band. Spawned by clockwork, cooldown per gnome.
- Wren letters: rewrite the 4 existing outros to drop "Tansy" and "seed". New outro line: what the next area needs. Prologue (`JOURNEY_PROLOGUE`) rewritten: Wren finishing the Almanac, the Hollow wants mending.
- Benefits: keep one per chapter; add one per Repair (small) so leisure play is paid.

## 6. Delivery order
1. Config only: new REGION_LEVELS bands, Owl Lv 15, region `min_level` update + migration step for existing gnomes.
2. Standing meter on Wren's page (read-only, no gates).
3. Seals + Wardens at the 5 tier 3 doors (gating the four existing tier 2-3 roads plus the Tide Track ferry).
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
- Creature cap 37 (list for 38-55 drafted). Route clamp 40 in `route_danger` must go to at least 57; `REGION_LEVELS` and `LAIR_LEVEL_1115` need the new bands.
- Graph: CB and SA have no tier 4 road; SA-OC skips tier 4 (section 2).

## 8. Decisions (settled 2026-11-27)
1. Maplewold alone is L1-15: yes.
2. Add creatures above Lv 37 for tiers 4-5 (no compressing). Needs a creature list for 38-55.
3. 80% threshold: yes.
4. Tier 3 doors need **both** tier 2 Seals (Maizehollow and Mistmoor).
5. A Seal is the only hard block. Wardens say what is missing; no level lock.
6. Tansy / Hollowheart: dropped. New spine in section 5.

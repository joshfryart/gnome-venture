# Story pass 4: review log

Status: REVIEW (2026-11-27). No game code changed. Corrections are made in place in `proposal-maplewold-bands-and-seals.md`, `proposal-story-1-base.md`, `proposal-story-2-quests.md`, `proposal-story-3-flavor.md` and `proposal-creatures-38-55.txt` (each has a "Pass 4" line at the top).
Superseded in part by `PROPOSAL-HOLLOW-MASTER.md` section 12 (ruling 3: Stops row maths for N = 10; ruling 12: no Puzzle Pal rewards).
Checked against: `roads.php` (ROAD_PAIRS, LAIR_LEVEL_1115, on_road, lay_roads), `progression.php` (REGION_LEVELS), `stop_adopt.php`, `place_ui.php`, `stop_living.php`, `landmarks.php` (ensure_lair_bosses), `adventure.php` (route_danger), `data/{creatures,pf_creatures,landmarks,zones,region_crops,flowers,stop_tiers}.txt`, `claude/route-list.md`.

## What was wrong, and the fix

| # | Problem | Fix |
|---|---|---|
| 1 | **Only road villages can be adopted** (`on_road` in `place_ui.php`). The Maplewold has 10 villages but 3 road stops (Poppyburrow, Honeybrook, Cloverholt, all prairie). Main-line steps asked to adopt and light stops in zones 2-6 of the Maplewold and zones 3-4 of Maizehollow and Mistmoor, where there is nothing to adopt. The base story's "14-stop Maplewold" was wrong. | New step kind `regular zone:N` (stamp + 3 things, works at off-road villages). Adopt/raise steps now name road stops only: the Maplewold adopts its 3 prairie stops over M1, M2, M4; Maizehollow and Mistmoor adopt 2 each. Cost note fixed. |
| 2 | Busy world: an `adopt` step fails if every road stop is held by someone else or is a Hall (a tier 4 stop cannot be adopted at all). | Every `adopt` step has `alt=regular` at a tier 1+ road stop. Stop types (mill, inn, jetty) are flavour, not requirements. Named havens (Baobab Inn, Kava Circle, Thatchtop Tearoom...) are landmarks, not stops: rule added, rows fixed. |
| 3 | M6 required a tier 4 Hall at L14 (about 2,500 Petals of tiers for one stop, contrary to "tier 1 is the band 1 lesson"); M4 required tier 3; C4 required 4 stalls with 1 slot. | M6: Hearth at tier 2 (a stop you founded counts), Hall optional. M4 tier 3 optional. C4: 2 stalls. |
| 4 | Tier 4 upkeep decay could undo a finished step or Standing. | Steps latch; Standing rows are high-water marks (stated in both story docs). |
| 5 | Standing: a non-fighter reached **exactly** 80 only by maxing every other row (Hearth tier 4, all pages, all places). "Charm" happens on the fight board, so it is not a peaceful option. Creature Almanac pages need fights. Bands doc still had the old table. | New table, sums to 100: stops 30, Repair 15, finds 10, folk 15 (adds errands), gardening 15, delve 5, lair 5 (counts a peaceful lair act), pages 5 (non-creature). Non-fighter ceiling 90-95. Bands doc now carries the same table. |
| 6 | **Road graph**: the bands doc said "CA gives CB+SA ... those give MENA/CSA/ESA/WCA". False: CB and SA have no road to tier 4; SA-OC goes tier 3 straight to tier 5; tier 5 is reachable only via CSA (and SA-OC). Five of the 14 Seal letters pointed down roads that do not exist (CB to WCA, SA to ESA, MENA to EA, WCA to SEA, ESA to OC). | Graph written out in the bands doc. Gates: tier 4 doors SE-MENA, EE-CSA; tier 5 doors CSA-EA, CSA-SEA (Spicepeak Seal); SA-OC proposed at "any tier 4 Seal". Five letters rewritten to real neighbours (pass 3 assumption line replaced). |
| 7 | Tier 3 "doors" (Isthmus Track, Ferry Cove, Fell Pass, Smugglers' Tide) were drawn as new routes while the existing roads CA-CB, CA-SA, NWE-SE, NWE-EE stay open: the gate could be walked round. | The doors are the gate stretches of those four existing roads, plus the Tide Track ferry. |
| 8 | "The Crossing" chapter put extra steps (deliver a lantern, bake, escort Wren, adopt a Ferry Landing that is not a road stop) between the two tier 2 Seals and the doors: a second hard block. | Doors open at step 1 (both Seals held). Steps 2-6 are optional celebration. Ferry Landing step is `regular`. Duplicate Field Hand title removed (it comes with the 3rd Seal). |
| 9 | Ceremony name clash: "The Crossing" (band 2 chapter) vs "The crossing" (band 3 ceremony). | Band 3 ceremony renamed **"Lamps on the water"**. |
| 10 | Creatures: the seven lair-boss rows would import as active roaming bosses with the same names as the existing generated `boss-<lair>` guardians (duplicates), and would not be used by the lairs. Note 3 missed that Dragonlizard Den also gets a "Guardian of ..." name. Lair rule disagreed (floor + 4 = 42/50 vs bands doc "band top"). | Lair rows are now `#L|` overrides, at **band top** (45 / 55) in both docs. 60 importable lines. Semicolon and "shadow" removed from descriptions; slug `whisperwood-panda` renamed `great-panda` to match its name. Trim list no longer offers creatures the quests use. Coverage checked: no landscape gap over 3 levels from 38 to 53+. Drop names all exist. |
| 11 | Flavor: two exclamations in a row ("A pedlar came through! From the next stop!"). `na-s03` alt used garlic (no Maplewold crop). Off-road villages have no tiers, so the dark/lit stop text had no rule for them. | Fixed. Lentil instead of garlic. Lit rule for off-road villages added. No Tansy/Hollowheart/Trek text left except "removed/dropped" notes (grepped). Signature crops and flowers all match `region_crops.txt` / `flowers.txt` (cherry blossom = slug `sakura`, noted). |
| 12 | Count over target: 94 side quests + 36 cast threads = 130 (target 80-100). | Cut applied: cast threads 36 to 20 (bands 3-5 only for Pell, Morelby, Linnet, the Stranger; Fusby band 1 to a chat line). The 14 happening errands become one-off happening acts that keep their extras. **80 side quests + 20 threads = 100.** Reward tables unchanged. |

Checked and fine: gardening is a required step in every Maplewold, Maizehollow and Mistmoor chapter, in S2 of every tier 3-5 chapter and in the final chapter, and is 15 of Standing in every area. Every main-line `defeat` has a peaceful `alt`. Escorts wait forever; no step is timed or failable. Seal letters have the four fixed parts. Bands match Josh's decisions (Maplewold 1-15, tier 2 15-25, both tier 2 Seals for tier 3, Seal the only hard block, creatures added above 37).

## Code and data changes the proposals now need (for the build plan, not done)
- `REGION_LEVELS`: NA 1, CA/NWE 15, CB/SA/SE/EE 25, MENA/CSA/WCA/ESA 35, EA/SEA/OC 45, plus `min_level` migration.
- `LAIR_LEVEL_1115` replaced by band-top lairs (15/25/35/45/55) with a boot step for existing worlds (as `medium_lair_levels_1115`).
- `route_danger` clamp `min(40, ...)` raised to at least 57.
- Lair-guardian override step for `boss-<slug>` rows (name, level, drops, description), for new and existing worlds.
- 60 rows into `creatures.txt` (strip `*new`), 7 new items, `pf_creatures.txt` rows for board fights; re-place the Lv 38-40 pf variants.
- Seal gate on the four tier 2-3 roads and the SA-OC, CSA-EA, CSA-SEA roads; Wardens.
- Step kinds `adopt`, `raise`, `regular`, `plant`, `deliver`, `escort`, `defeat`, `help`, `seal`, with latching.

## Open for Josh (8)
1. **SA-OC and the dead-end Isles.** SA-OC skips tier 4 (proposed: needs any tier 4 Seal). Sunsprinkle and Rainroot lead nowhere in tier 4. Accept, or add a road (e.g. a CB-WCA sea crossing)?
2. **Off-road adoption.** Allow adopting any village (drop the `on_road` check) so every zone has lamps to light? The main line now works either way, but the "light the road" fantasy is thin with 3 Maplewold stops.
3. **Tier 5 through Spicepeak only.** With the current graph, Spicepeak's Seal is required for Blossomreach and the Monsoon Tangle. OK?
4. **First adoption free** and the 300 fee on re-adoption (3 adoptions in the Maplewold main line).
5. **Tier 4 upkeep vs "no fail states"**: keep the monthly tier loss as world flavour (steps and Standing latch), or switch it off?
6. **Happening errands as acts**: OK that the 14 `H` errands are acts that keep their extras, not quests?
7. **Standing weights** (new table) and all Petal/XP/hand-in numbers are unsimulated; sim before locking, together with the XP budget and fights at Lv 45 and 55 (d20 maths stops mattering there; flee is near impossible at 55).
8. **Puzzle Pals as companions** (4 extras) and the Stranger with no tie to Wren: confirm.

## Decisions on the 8 open items (2026-11-27, Claude's answers for Josh to veto)
1. **Dead ends.** Add two sea/land roads so tier 3 leads on: Sunsprinkle to Greatcanopy (CB-WCA) and Rainroot to Thornacre (SA-ESA). They match the Seal letters. SA-OC stays, gated by any tier 4 Seal.
2. **Off-road adoption.** Yes: any village can be adopted. Off-road villages cap at tier 2 (no Hall). Standing N counts adoptable stops, so the Maplewold counts 10, not 3. Re-check the Stops row maths.
3. **Tier 5 via Spicepeak.** OK. Tier 5 also opens through SA-OC (any tier 4 Seal).
4. **Adoption fee.** First adoption in an area free; the 300 fee applies to re-adoption.
5. **Upkeep.** Keep tier 4 monthly loss as flavour. Steps and Standing latch. Tiers 1-3 never decay.
6. **Happening errands.** Yes: one-off stop acts that keep their extras.
7. **Companions and the Stranger.** Puzzle Pals as companion rewards: yes. Stranger has no tie to Wren: yes.
8. **Crops and numbers.** The 14 signature crops are confirmed. Run the balance sim (Standing, XP, Petals, Lv 45-55 fights) before any weight is locked.

## Update (Josh, 2026-11-27)
- No new crops: the 14 signature crops already exist (verified against `crops.txt`).
- Puzzle Pals remain released by jigsaw; the Maplewold jigsaw (Advanced or Expert) is now M1 step 2, a Lv 1 step.
- Puzzle Pal spawns rewritten to reachable regions only. See `game/includes/puzzle_pals.php` (`ppal_spawn_nodes`, `ppal_spawn_prune`, `ppal_spawns`) and `game/includes/progression.php` (`accessible_regions`, `region_gate_open`).

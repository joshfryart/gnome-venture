# Maplewold Trail Sights: what the data still cannot do (engine gaps)

Status: TODO list (2026-11-12, after the P2b data upgrade). Data: `game/includes/data/trail_sights_maplewold.txt`, `trail_sight_folk_maplewold.txt`, `trail_sight_quests_maplewold.txt`, `trail_sight_items_maplewold.txt`, `trail_sight_pages_maplewold.txt`, `trail_sight_newfolk_maplewold.txt`. Lint: 219 rows, 0 problems. Art: `maplewold-art-todo.md`.
Everything the grammar can express is in the data. What is left needs engine work.

## Engine / lint gaps found in this pass
- **Lint rejects `fpto=Name@village`** (`trail_sight_lint` reads the `@` as a chance). Workaround: which-nettle's giver is the Mossgate Nettle (`@v-na-2-3`) and `fpto=Nettle Cobblefield:2` (lowest id = Cloverholt in a fresh install; twin risk on other sites); sled-derby's giver is Elm (`@v-na-4-2`), `fpto=Rue Wickerby:2` (unique name).
- **`tally=` ignores `?cond`** (counted on every win), so "dress the scarecrow in all four seasons" and "four seasons charted" are 4 uses (`scarecrow-hats`, `charts`), not 4 seasons. `?tl=key:N` tokens pay on every use after N (milestones use low odds or once-only titles/pages).
- **`nocheck` does not apply to `pick:` checks** (only stat checks). No pick Sight has a nocheck villager now.
- **A wrong pick spends the use** for the whole cooldown; the quest-beat pick Sights (`310-driftpass`, `312-woodpecker`, `313-stickgate`, `314-driftwood`, `314-gullparliament`, `316-starstones`) have 2 uses so a wrong guess can be retried.
- **`give=` rows can be repeated** as often as the gnome has the item on a day the villager is there; their rewards are kept below the item's value (Alder's punnet: 3 raspberries for 110).
- **Quest beats cannot give items**: the owl letter comes from `316-starstones` (`first:`) and from Sorrel Fiddlewood at `316-kettletree` (40%).

## Still impossible, per idea
- **Game time and walk effects**: haybales nap costs 1 game hour; 236-windmill no-wind 30 minutes; 314-causeway wait 20 minutes and "impatient: -1 energy"; 309-icecave no energy for the next 3 steps; 315-bridge free step; 310-driftpass 10 minutes shorter; 313-stickgate 1 step shorter.
- **Next-section / map outputs**: 236-dandelions +1 Trail find on the next section; 306-toadsteps shows the next section's finds; 314-gullparliament shows a hidden find; 305-birchtunnel names a section; 307-shellhollow night secret and 316-starstones winter secret (a find on route 314 / 309); map-scrap marking a find.
- **Buffs with other lengths or targets**: "until you sleep", "until you leave the route / lair", "until dark ends", a delve buff for the next Beaverdam Tunnels run, +1 to every stat (312-toadring), two buffs in one row (314-lanternrocks fog Luck), +5% Charm in the Den only.
- **Choice of reward in a pick** (314-driftwood dragon/chair/sofa buffs, 316-skyhill night boon, 309-snowmen "no wrong answer"): a pick has one right answer.
- **Hidden button**: 310-icicurtain "Lick" (Almanac "Told You").
- **Streaks and "in a row"**: 228-pondmill 5 wins in a row, 312-ringlog streak, 236-haywagon 5 visits running, 314-driftwood sofa 3 visits running (all made private tallies instead).
- **Any-of takes**: scarecrow "any crop or flower" (takes `carrot`), 312-larder any nut (`hazelnut`), 315-cairns any feather (`hen-feather`), 236-haywagon any seed (no take), 316-auroracamp any bread, 316-kettletree tea swaps (`meadowsweet` -> tea, `mint` -> tea), 232-picnicrise "eat any snack here, double buff".
- **Tool-tier odds** (Sturdy/Fine tool rows): hedgerow butterfly scales, combridge fossil/frost crystal, ringlog oak log/heartwood, axe-only logs.
- **Time-limited loans and flags**: Mister Plink's singing pebble for a day (now a 4-hour Charm buff), spare tin bucket, lantern oil refill (tool wear -1), muddy gnome, the seal pup's gift only after Q4, preened 3 times = the Owl fight starts Calm, woodpecker's beat (next Tune/Ring sure).
- **Villager timing words**: away days, Maplewold half-days of travellers, Market rest days, festival days (Pomeroy rows are plain chances and stay hidden until the Gourmand opens), once per week / season goodies (low odds instead), Basil's flower +10% growth, Elm's +20% chanterelle, Fennick's sale tip, Tobias's 10% seed discount, Moss Windlass selling sea salt for Petals, Bunty's inn voucher.
- **Birthday**: 236-dandelions birthday wishes (now a 10-blow tally page).
- **Quest starts and rewards**: Sap to Stack should wait for Wren's Journey chapter "The Sugar Shack" (gated on Bramble's Picnic List instead); Q8 half-price build-plan stage; the Den boss hint card (now `hint=creature`); Q6 Tansy clue for Wren's Journey (now an Almanac page); after-quest parcels between the Nettles.
- **Real other players' notes**: message bottle (phase 4 bottle post).

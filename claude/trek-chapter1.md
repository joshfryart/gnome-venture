# Treks: Chapter I outline (draft, 2026-10-17)

Trek "The Withering", Chapter I: **The Wilting Rows** (topsoil layer).
Goal: teach every system once, recruit the first 3 trailmates, end on the blight hook.
Length: about 3-4 h (1 week at 30 min/day). Map about 40x40, roughly 300 walkable tiles, about 60-80 fights on Hunt.
Creature band: levels 15-19 (same size-based stats as creatures.txt).

## Trailmates 1-3 (picked by Claude, Joshua OK'd "you pick")
Use the calling mentors (CALLING_MENTORS in includes/calling_quests.php). They exist on every install, already have a calling, species, personality and a bio, so there is no new NPC to seed.
1. **Burdock Deepdelve**, mole, Warm, Rootwarden (tank). Knew Gloomtooth before the blight, which gives the boss fight real weight. Grumpy-gentle rather than grumpy.
2. **Zinnia Fuzzbottom**, bumblebee, Cheerful, Bloomcaller (healer).
3. **Captain Bracken Spurwing**, stag beetle, Proud, Thornblade (fighter). He fits the Beetle Bridge: the stag beetle patrols are his old troop gone blight-sick, and the duel is his pride talking.
- The other 5 featured trailmates (later chapters): Sorrel Inkcap (Seedkeeper), the Wayfinder and Brewroot mentors, Wren Thimblewick (curious naturalist), + 1 new.
- Story note: the mentors leave their lodges while on a trek in the story only. In town they stay at their lodges as normal (no change to calling chapters).
- Check at build: friendship works on mentor NPC ids the same as townsfolk.

## Problems this chapter solves
- New players at L15 may not be Acquaintance (20 pts) with any trailmate, which would leave no party. Fix: each recruit scene gives +20 friendship (sets them to Acquaintance if lower). Later chapters recruit the rest the same way.
- NAME CLASH #2: "Companions" already means companion planting (companions.txt). Party members are called **Trailmates** in the UI, and the data file is `trek_crew.txt`.
- Level: the gnome uses its real gnome level and calling tier. Trailmates sit at gnome level −2 (min 13). Trek XP only buys skill points.

## Fatigue (party-wide bar, 0-100)
- +1 per 2 tiles walked, +3 per fight, +2 per extra round past 5 in a fight.
- 60+ Tired: −1 attack and armour for everyone.
- 85+ Worn out: −2 attack and armour, encounters ×1.5.
- 100: can't walk, only Make camp.
- Rest:
  - Camp (fixed spot): fatigue to 0, full HP, bank finds, swap party. Free.
  - Make camp (anywhere with no foe next to you): fatigue −50, HP +50%. Uses 1 Camp Kit. Without a kit: free, but 30% chance of an ambush fight first.
- Hard walking tiles (mud, roots) cost 2x fatigue.

## Camp Kit (decided: bought, not crafted)
- 60 Petals (setting `trek_campkit_price`). For scale: one L15 road find pays about 40-50 Petals; a daily job pays 50-90.
- Sold at every trek camp + the general store. Carry max 3 (setting `trek_campkit_max`).
- Expected use: 3-5 per chapter, so about 200-300 Petals per chapter.
- Later option: price scales with gnome level. Not needed for v1.

## Map zones (in play order)

1. **The Root Gate** (start). A crack opens under the Hollow square. Blackened roots poke through. Solo gnome.
   - Teaches: tap-to-walk, first fight (Withered Aphids), Snack.
   - Tutorial mercy: KOs before the first camp lose nothing.

2. **The Wormway**. Narrow worm tunnels, a maze-lite.
   - Burdock is pinned under a fallen stone (he came down to sniff out what was souring the soil). Free him, then he joins.
   - Teaches: party fights, Ability (Bark Skin covers an ally), Guard.

3. **Lantern Stump: CAMP**. A hollow stump with glowworm lanterns, run by a mole-folk innkeeper.
   - Teaches: bank finds, the KO rule, Fatigue, Camp Kits on sale, fast travel point.
   - The first Camp Kit is free here.

4. **The Grubfields**. A wide open area of soft soil, the main grinding zone.
   - Mud tiles teach fatigue cost.
   - Side spot A, **Old Gnome Cellar**: a locked chest. The key drops from a Grubfield beetle (guaranteed by the 3rd kill). Holds 2 Camp Kits and Petals.

5. **Mycel Hamlet**. A little village of mushroom-folk, half of it blighted.
   - Zinnia is tending the sick caps (she followed the wilting flowers down).
   - Mini-quest: fetch 3 Clean Dew from the Dew Pools (short detour, 3 fights). Then she joins.
   - Teaches: heal ally, the quest log, the ! marker.
   - Side spot B, **Worm Choir**: an old worm asks a riddle. Answering right (2 tries) gives a trek-only seed, **Lanternroot**. Seedkeeper in the party later: auto-answer.

6. **Beetle Bridge**. A root bridge over a dark drop, with sleeping stag beetle patrols (Bracken's lost watch, blight-sick).
   - Teaches: 🤫 Sneak. Waking a patrol = a hard fight, not a KO trap.
   - Bracken guards the far end and demands a duel (party vs him, stops at 1 HP, no KO risk). Win = he joins. Lose = retry free.
   - After this point, pick any 3 trailmates at camp.

7. **The Black Rows**. Blighted topsoil, where the new creature family Blightlings appears: grey, corrupted versions of normal creatures (Withered Aphid, Rot Snail, Ashen Ant). Same stats, +1 poison on hit.
   - Mini-boss: **Blight Mother** (a swollen aphid queen). She spawns 1 small add every 4th round (max 3 alive, 4 in all).
   - Side spot C, **Glowworm Grotto**: hidden tile, revealed only with a Wayfinder in the party. Holds a rare find + a Book entry.

8. **BOSS: Gloomtooth, the Blind Mole**. Burdock's old cellar-mate, sick with blight; his digging made the tunnels.
   - Round pattern, shown one round ahead on the fight card:
     - Claw: hits one trailmate.
     - Burrow: can't be hit next round, then bursts up for big damage to a random member. Guard halves it.
     - Quake: hits everyone at 50%. Bark Skin shines here.
   - At 30% HP he enrages: attacks twice.
   - Win: Gloomtooth is cured, not killed, and leaves a black **Blight Shard** that hums and points down. Chapter II hook (clay layer).

## Rewards (Chapter I)
- Petals (amount from a setting), Lanternroot seed, Velvet Pelt + Digging Claw (boss).
- Book (encyclopedia) entries: Chapter I page, Blightlings, Gloomtooth, Lantern Stump.
- Friendship: +20 at each recruit, then +1 per 20 fights together (daily cap).
- No hat or passport stamp yet: those come at the end of the whole trek.

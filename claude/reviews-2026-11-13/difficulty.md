# Creature difficulty review: puzzle combat v1, 2.6.94 (4x4 board)

All numbers come from the real engine (`game/includes/pfboard.php`, `pfdeck.php`) run through a copy of `tests/pfboard_tune_v1.php`. The repo was not edited.
Work files are in `/tmp/claude-0/-home-user-gnome-venture/61d29fdb-51dd-5c70-9df1-3360659d574b/scratchpad/opus/difficulty_work/`:
- `tune.php` is the harness copy. It adds a slug, level, max HP, bar and worst one-turn HP loss to every JSON row. It also adds these env hooks: `ONLY` (slugs), `PER` (seeds per creature), `LV` (level-scaled creature factor per size), `BAND`, `DBF`.
- `drun.sh` runs the sims on 4 shards. `an.py` builds the per-creature tables and `band.py` the size x level-band tables.
- Raw JSONL for every run is in the same folder.

Note: other agents write to `scratchpad/opus/` as well (their `run.sh` replaced mine mid-run). I moved all my work into `difficulty_work/` and re-ran everything that might have been affected, so the numbers below come from that folder.

## 1. Baseline (2.6.94, chain bot, 40 seeds per creature, 88 creatures)

| offset (gnome minus creature) | small | medium | large | boss |
|---|---|---|---|---|
| +4 | 99% (22% HP lost) | 96% (36%) | 91% (51%) | 93% (57%) |
| 0 | 85% (47%) | 76% (60%) | 82% (62%) | 86% (64%) |
| -4 | 72% (59%) | 37% (84%) | 64% (76%) | 74% (73%) |
| -8, boss only (30 seeds) | | | | 50% (85%) |

These match the brief's figures (85/76/81/87 and 72/39/60/74).

The other bots at 2.6.94:
- **Look bot** (`lookAll.jsonl`, 8 seeds per creature): wins 100% at level for every size and loses 15-17% HP. It wins 100% against every one of the 88 creatures.
- **Smart bot** (`basesmart.txt`): wins 100% at level and 99-100% at 4 under, losing 8-15% HP (11-22% at 4 under).
- **Boss at 8 under:** look still wins 100% and loses 22% HP.

The design doc's targets were chain about 70%, and look about 97% losing 23-29% HP. The 4x4 board made fights easier on both counts: chain is 5-17 points above 70%, and careful play loses about two-thirds of the HP it used to.

## 2. Difficulty by creature level: the main problem

Within a size, difficulty falls steeply as the creature's level rises. Chain bot at offset 0 (`band_chain.md`):

| size | lv 1-5 | lv 6-10 | lv 11-15 | lv 16-20 | lv 21-25 | lv 26-30 | lv 31-35 | lv 36-40 |
|---|---|---|---|---|---|---|---|---|
| medium | 52% (n=40, orb spider only) | 59% | 89% | 93% | - | 96% | 98% | - |
| large | - | - | 56% | 76% | 86% | 89% | 85% | 82% |
| boss | - | - | - | - | - | 89% | 78% | - |

At 4 under, medium lv 6-10 wins 14% and large lv 11-15 wins 23%. Medium lv 26-30 still wins 88%.

**Why.** Creature piece value is ((die+1)/2 + floor(L/4)) x 1.4 x size factor, and the bar is 5 + 0.4L. The gnome grows faster than both:
- **Gnome HP:** 20 + 3L.
- **Gnome mean Hurt value** (`vals.txt`): 5.9 at L8, 9.2 at L14, 15.7 at L28.
- **Gnome deck total:** steps up from 140 at L10 to 206 at L12. This is the sim gnome's belt, tier and pal-rank milestones in `tv_sources`.

As a result:
- **Creature Hurt per piece, as a share of gnome HP at the same level:** 11-12% for medium L8-9, 9% for medium L17, 7-8% for medium L27-35, 8% for large L14-25, 6% for large L37 and for every boss.
- **Bar divided by gnome mean Hurt:** about 8 hits for medium L8 and about 6 hits for medium L27.

Both ratios move about 35% in the gnome's favour between L8 and L28. Across all 88 creatures, win at level correlates with "creature Hurt per piece / gnome HP" at r = -0.42. It correlates with "bar / gnome Hurt" at only r = -0.12.

## 3. Per creature (offset 0 and -4, 40 seeds each; full list in `per_creature_chain.md`)

Ten hardest and ten easiest, ranked by win at 0 plus win at -4:

| creature | size | lv | win 0 | win -4 | win +4 | HP lost at 0 | env share of HP lost at 0 | worst one-turn loss at 0 |
|---|---|---|---|---|---|---|---|---|
| sun-lizard | medium | 8 | 28% | 0% | 90% | 87% | 18% | 39% |
| carrion-crow | medium | 9 | 30% | 0% | 88% | 92% | 17% | 39% |
| grass-snake | large | 14 | 38% | 0% | 75% | 90% | 36% | 32% |
| barn-rat | medium | 8 | 52% | 2% | 95% | 83% | 16% | 32% |
| tunnel-mole | medium | 9 | 57% | 0% | 100% | 80% | 25% | 31% |
| orb-spider | medium | 5 | 52% | 5% | 100% | 81% | 40% | 29% |
| herring-gull | medium | 10 | 60% | 12% | 98% | 73% | 16% | 35% |
| paper-wasp | medium | 6 | 68% | 8% | 88% | 75% | 23% | 30% |
| shore-crab | medium | 7 | 55% | 20% | 100% | 77% | 35% | 25% |
| frost-hare | medium | 11 | 78% | 2% | 88% | 65% | 25% | 29% |
| spice-monitor | medium | 27 | 98% | 82% | 100% | 37% | 9% | 19% |
| clam-lurker | large | 23 | 95% | 85% | 100% | 48% | 30% | 20% |
| giant-bumblebee | large | 23 | 90% | 90% | 100% | 52% | 32% | 21% |
| old-bramblehorn | boss | 30 | 92% | 92% | 98% | 59% | 33% | 22% |
| savanna-hyena | medium | 29 | 95% | 92% | 98% | 48% | 20% | 22% |
| garden-snail | small | 1 | 95% | 95% | 100% | 25% | 2% | 17% |
| bramble-wolf | large | 22 | 98% | 95% | 100% | 47% | 25% | 20% |
| outback-dingo | medium | 35 | 98% | 95% | 98% | 44% | 27% | 23% |
| leafcutter-column | medium | 17 | 100% | 95% | 100% | 32% | 19% | 19% |
| aphid-swarm | small | 1 | 100% | 100% | 95% | 34% | 5% | 23% |

Spread of per-creature win at level: medium sd 21 points (28% to 100%, 6 creatures under 60%), large sd 12 (38% to 98%), small sd 9, boss sd 9.

The outliers are almost all the first creatures of a size: medium L5-11 and large L14. On top of that level effect there is a deck effect. Decks with 4 Hurt pieces out of 8, including Pierce and Quick (Bird: crow, gull; Beast: barn rat), are harder than guard-heavy decks at the same level (`decks.txt`).

Mean win at level by class: Bird 72% (n=11), Reptile/Amphibian 77%, Critter 82%, Water 83%, Beast 83%, Plant/Fungus 92%.

The outliers are hard only for the chain bot. On the 10 hardest creatures:
- **Look:** 100% at level, 89-100% at -4 (`lookHard.jsonl`).
- **Smart:** 100% at level, 80-100% at -4 (`smartHard.jsonl`).

## 4. Damage per turn against gnome HP, and burst

Chain bot at offset 0 (`burst.md`):

| size, creature lv | mean worst one-turn loss (% of max HP) | fights with a one-turn loss of 40% or more | HP lost per turn |
|---|---|---|---|
| medium L1-10 | 30% | 16% | 10.9% |
| medium L11-20 | 24% | 7% | 7.5% |
| large L11-20 | 28% | 11% | 9.0% |
| large L21-30 | 23% | 4% | 7.5% |
| boss L21-30 | 24% | 3% | 7.4% |

Look loses at most 13-15% in one turn.

About 7-11% of HP per turn over 6-9 turns is sensible for a 70% target. The low-level spikes are not: a single reply can take about 40%, which matches the playtest where 50 HP fell to 20 in one turn.

Two things to fix:
- **The AIM shows face value.** It should show the doubled value when the aimed cell, or the chain it will fire, holds a Sun. This is UI; I did not sim it.
- **Low-level burst.** The level change in section 6 lowers it.

## 5. Bosses (no charm bar)

At level a boss is the easiest non-small size for the chain bot (86%), and for the look bot it is no threat at all: 100% win at level and at 8 under, losing 15% and 22% HP. A boss Hurt piece averages about 6% of gnome HP (PF_FOE_BOSS 0.78 x PFB_BOSS_MULT 1.2 x 0.45).

So the environment does most of the harm in a boss fight. It causes 55-60% of the HP the chain bot loses and 70-75% of what the look bot loses (large: 42-48%, medium L1-10: 32%).

Because a boss cannot be charmed or run from and plays a fixed order, the fight plays as a long attrition against Thornburst and Bramble, not a duel with the boss. Bosses roam up to 8 levels above the gnome (`pick_creature`, 6% of rolls). Even there, look wins 100%, and only the chain bot struggles (50%).

## 6. Proposed changes (tested)

### A. Level-scaled creature factor for medium and large, plus a boss raise (run H, 40 seeds, `H.txt`, `band_H.md`, `per_creature_H.md`)

Multiply the v1 creature piece values (`$fm` in `pfb_new`) by:
- **medium:** clamp(1 + 0.06 x (L - 12), 0.80, 1.35), which is 0.80 at L8 or below, 1.0 at L12, 1.24 at L16 and 1.35 at L18 or above.
- **large:** clamp(1 + 0.03 x (L - 20), 0.82, 1.20), which is 0.82 at L14, 1.0 at L20 and 1.2 at L27 or above.
- **boss:** x1.15, which means PFB_V1_FOE_MULT boss goes from 0.45 to 0.52.
- **small:** unchanged.
- **bars:** unchanged.

| offset | small | medium | large | boss |
|---|---|---|---|---|
| 0 | 85% (47% HP lost) | 79% (60%) | 80% (65%) | 80% (71%) |
| -4 | 72% | 34% | 59% | 64% |
| +4 | 99% | 95% | 89% | 86% |

Level bands at offset 0, before and after:
- **medium:** lv 6-10 goes from 59% to 72%, lv 11-15 from 89% to 88%, lv 16-20 from 93% to 83%, lv 26-30 from 96% to 84%.
- **large:** lv 11-15 goes from 56% to 77%, lv 21-25 from 86% to 83%, lv 26-30 from 89% to 80%.

At 20 seeds per creature (run G), medium sd fell from 21 to 15 points and large stayed at 11. Smart is unchanged: 100% at level and 99-100% at -4 (`Hsmart.txt`). Look wins 100% at level and 96% for medium at -4 (`Glook.jsonl`).

### B. Optionally, also x1.2 on top of A for every size (`V1 foe_x 1.2`, 15 seeds per creature)

This restores the pre-4x4 target:
- **Chain at level:** small 66%, medium 69%, large 64%, boss 64%.
- **Look at level:** 98-100%, losing 18-19% HP.
- **Chain at -4:** small 55%, medium 24%, large 42%, boss 47%.

At x1.4 chain drops to 47-58%, which is too harsh. I recommend A now, and B if careful players should feel the creature again.

### Tried and rejected

- **Foe-only linear level slope** (+0.015 per level, A run): flattened too little. Medium L6-10 went to 72%, but large L11-15 stayed at 57% and bosses fell to 76%.
- **floor(L/3) level bonus instead of floor(L/4)** (`db3`): made low levels harder too (medium L6-10 at 40%).
- **Softer environment** (Thornburst and Bramble 0.10 to 0.07, `env07`): win rates barely moved (78-91%), fights grew to 9-10 turns, and the boss env share only fell from about 55% to 48%.

### Per-creature

After A, the remaining under-60% creatures at 20 seeds per creature (run G) are carrion-crow, sun-lizard, orb-spider and tunnel-mole. With n=20 per creature the error is about 11 points, so confirm them at 40+ seeds before trimming any one creature. The likely cause is a Hurt-heavy class deck (Bird or Reptile at 4/8 Hurt). A cleaner fix than per-creature numbers is to cap the class base deck at 3 Hurt pieces out of 8 below creature level 12. I did not test this.

## 7. Not verified

- **The sim gnome is synthetic** (`tv_sources`, `tv_player`: belt slots at L10 and L20, tool tiers, pals at L3 and L8, three knacks). The L10 to L12 deck jump drives part of the medium cliff. Real players' decks may differ.
- **Region:** each fight's region is drawn by seed (14 regions); I did not test per region.
- **Encounter mix:** I did not sim how often real players meet each offset. `pick_creature` draws ordinary creatures from the gnome's level -6 to +2 (offsets -2 to +6), so offset -4 mainly applies to roaming bosses (up to +8). Scaled road creatures (`scale_creature`) were not simulated.
- **Bots are not people:** the chain, look and smart bots are not Haiku or human players. The AIM-with-Sun display and a Hurt cap for class decks are untested.
- **No smart-bot run** on proposal B or at -8.
- **Seed counts:** 40 per creature for the baseline and A, 15-20 for the variants, 6-10 for look and smart.

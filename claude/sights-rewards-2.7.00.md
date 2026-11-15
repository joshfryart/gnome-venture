# Sights rewards pass 2.7.00: the proposal (Josh approves the number before it goes live)

**What is there today.** 219 Sight rows. Petals and XP rewards come in two shapes:
- `xp=3:1` (239 tokens): a base plus a part per level of the place where the walk began (`stop_rewards`, `stop_level`), times the setting `stop_reward_percent`. These already grow with the region. Left alone.
- `xp=10` (71 tokens: 51 are `first:xp=10`, the first-ever use of a Sight): flat, the same in the Maplewold and in the Ocean. These are the ones that do not scale.

**Proposal.** A flat Petals or XP reward grows by **3% for every region level above 1** (the build plans use 2.5%; the setting takes whole percents). At level 1 nothing changes.

| Region | Level | Factor (3%) | `xp=10` becomes | `xp=5` becomes |
|---|---|---|---|---|
| NA | 1 | x1.00 | 10 | 5 |
| CA | 4 | x1.09 | 11 | 5 |
| NWE | 6 | x1.15 | 12 | 6 |
| CB | 8 | x1.21 | 12 | 6 |
| SE | 10 | x1.27 | 13 | 6 |
| SA | 12 | x1.33 | 13 | 7 |
| EE | 14 | x1.39 | 14 | 7 |
| MENA | 17 | x1.48 | 15 | 7 |
| EA | 20 | x1.57 | 16 | 8 |
| CSA | 23 | x1.66 | 17 | 8 |
| SEA | 26 | x1.75 | 18 | 9 |
| WCA | 29 | x1.84 | 18 | 9 |
| ESA | 32 | x1.93 | 19 | 10 |
| OC | 35 | x2.02 | 20 | 10 |

**How it is built.** `trail_sight_flat_scale()` in `game/includes/trail_sights.php`, used in `trail_sight_do` for every plain reward token. The setting `sights_flat_pct_per_level` is **0 (off) by default**; Admin > Settings can change it. Proposed value: **3**.

**To approve.** Say "approve 3" (or another number) and I set the default and add a boot step that writes it. Until then nothing changes in the game.

**Not changed:** the per-level rewards (`xp=3:1`), item rewards, energy rewards, villager friendship rewards, titles. Items and energy do not scale in this proposal.

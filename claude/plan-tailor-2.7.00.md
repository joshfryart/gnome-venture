# The Tailor (2.7.00): a garden building for wearables (plan; nothing built)

Josh, 2026-11-15: the Tailor is a **garden building**. It must be built in **at least one garden** before wearables can be crafted. "Extra garden building should increase yield by 1 per level of that tailor", applied to the **better Fine tier chance** (answers "1,2" and "Better Fine tier chance").

## What I read that as (confirm or correct)
- **Unlock:** a gnome who owns a Tailor in any of their gardens can craft wearables (Crafting page, category Wearables, like Tools needs a Tool Shed).
- **Tailor power** = the sum of the levels (1 to 3) of every Tailor the gnome owns, one per garden. So a second Tailor in another garden adds its level on top ("1": a Tailor's level counts; "2": more gardens with a Tailor count too).
- **Yield bonus** = +1 power point per level, and each power point raises the chance that a crafted wearable comes out one tier better (Common to Lined, Lined to Fine). Proposed: **+8% per power point**, capped at **48%** (6 points = two level-3 Tailors). A wearable never jumps two tiers. Fine stays under the Rare cap (answer 5).
- Nothing else changes: a Tailor of any level makes the same wearables from the same parts.

## The building (follows `BUILDINGS` / `BUILDING_UPGRADES` in `includes/gardens.php`)
| | |
|---|---|
| key / name | `tailor`, Tailor, 🧵 |
| garden level to build | 6 (after Beehive, like Silkworm Shelf at 7) |
| cost | 1800 Petals (+ upgrade cost percent as the other buildings) |
| description | "Lets you craft wearables for your Keepsake slots. Each level of every Tailor you own makes a better cut more likely." |
| level 2 | "Better cut: +8% chance a wearable comes out one tier better (counts with every Tailor you own)." |
| level 3 | "Master cut: another +8%, and the first wearable you craft each day costs no energy." (optional: ask) |

## Where it is built into the game
- `BUILDINGS` + `BUILDING_UPGRADES` (new key), art `assets/img/...` (a garden building picture: art list), Almanac page.
- Crafting category `wearables` with `needs building = tailor` in `crafting.php` (the same field as `tools` => `tool_shed`); recipes in `crafts.txt`.
- `tailor_power(uid)` = sum of `building_level(plot, 'tailor')` over the gnome's plots; `tailor_tier_chance(power)`; applied in the wearable craft step (roll once per craft).
- The six wearables, their pieces and slots: `claude/proposal-wearables-2.7.00.md`, with Josh's answers in `claude/todo.md` (Trail Pack = a Trick, scarf = fixed Charm 3, no overlap with friend pieces, Flood Boots carried).

## To do before building
1. Josh confirms the reading above (especially: power = sum of levels across gardens; +8% a point; cap 48%).
2. Re-do the wearable effects so none repeats Keeper or Plenty (answer 8), and make the Trail Pack a Trick (answer 3).
3. Art: the building, six item icons, three avatar layers in three views plus the rig (answer 4: all in 2.7.00).

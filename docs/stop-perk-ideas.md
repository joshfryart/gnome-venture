# Stop perks: account-wide, gone in 7 game days (brainstorm)

Today: a full meter (Repairs, Larder, Cheer) at one stop = 7 days of "one more thing to do at that stop" (`stop_perk_bonus`, `STOP_PERK_DAYS`).
Problem: acts at stops now work differently, so that bonus does nothing. Change: a full meter gives the **player** a perk that works **everywhere**, for 7 game days (`gclock_my_date`). Meters stay as they are.

## Rules (recommended)
- Meter fills -> pick 1 of 2 perks from that meter's pool (the stop type seeds which 2 show).
- Same perk again = refresh to 7 days, no stack. Max 3 running; a 4th drops the one ending soonest.
- Show in the header effects list (`active_effects`) with days left.
- Small numbers. Perks are a nudge, not a power spike.

## Repairs pool (mend, craft)
| Perk | Effect |
|---|---|
| Steady Hands | Craft time -20% |
| Mender's Luck | 15% a craft gives an ingredient back |
| Sharp Tools | Garden actions cost 1 less energy (min 1) on every 3rd action |
| Sturdy Boots | Walking on roads: 10% chance an encounter is skipped |
| Good Bones | Gnome health regen +25% |

## Larder pool (cook, gather, tend, forage)
| Perk | Effect |
|---|---|
| Full Pockets | Gathering: +1 on 20% of finds |
| Seasoned | Home-cooked dishes give +20% energy |
| Green Thumb | Harvests: 10% chance of +1 |
| Slow Simmer | Preserve and cook timers -20% |
| Packed Lunch | First meal each day lasts +30% longer |

## Cheer pool (play, lore, trade, rest)
| Perk | Effect |
|---|---|
| Spring in Step | Walk time -15% |
| Good Company | Friendship points from chat and gifts +25% |
| Silver Tongue | Shops: sell +5%, buy -5% |
| Bright Mood | XP from actions +10% |
| Sound Sleep | Sleep and naps restore +10% more |

## Other ideas to weigh
- **Stop flavour**: perk name and picture follow the stop type (Mill: "Floury Fingers" is Larder; Shrine: "Calm Mind" is Cheer).
- **Catch-up**: perks ending tomorrow show a nudge on the Here page.
- **Combo**: all three meters' perks running at once = small "Well Travelled" bonus (+5% Petals from sales).
- **Pass it on**: spend a running perk to gift half its days to a friend.
- **Legacy**: keep the old stop-local "one more thing" as a flavour line only.

## Build notes
- Store: reuse `stop_prog` rows `perk:<meter>` per stop for the old data, add `player_perks` (user_id, key, until, from_location_id).
- Read in one place: `player_perk(uid, key)`; hook the pools above at the few call sites (crafting timer, gather yield, harvest, walk time, shop price, XP, sleep).
- Admin settings for each number. Test: fills, refresh, cap of 3, expiry on game-day change.

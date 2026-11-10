# Game time vs real time: audit (2.6.36)

Rule of thumb: anything about **one gnome's own day** (open hours, who is around, daily limits, "today") should follow that gnome's game clock (`gclock_my_date()`, `gclock_my_hour()`, `gclock_my_dow()`; they fall back to the real Hollow clock when `game_clock_on` is off). Anything **shared between players** (market, contests, fair, weekly rankings) stays on the real Hollow clock.

## Already game-time (checked in code)
- Open hours of town places, incl. Plaza of the Bells 18-23 (`spot_closed`), shop staff (`staff_on_duty`), villagers at a spot or out and about (`npcs_at_spot`, `here_npcs`), time of day and weather art (`hollow_now`, `hollow_daypart`), festival day of month (`town.php` festival code), villagers away (`gclock_npc_away`).

## Fixed in 2.6.36
- **Town daily uses** (`town_uses`: "Join the dance", every place action with a daily limit, the festival treat) counted by the **real** Hollow day, so the Plaza's dance reset at real midnight while its hours ran on game time. Now `town_use_day()` = the gnome's game date. `town_day()` stays real for NPC-to-NPC meetings (`town_social.php`), which are the same for everyone.

## Per-gnome "today" still on the real clock (candidates, need a decision)
| Where | What resets at real midnight |
|---|---|
| `villagers.php:106`, `road_life.php:675` | Chat once a day per villager (`last_talk`) |
| `events.php:62,68` | Random event daily maximum (`event_day`) |
| `landmarks.php:45` (`landmark_day`) | Wonder and haven once-a-day actions |
| `flowers.php:19,24` | Flower daily counters (`flower_daily`) |
| `place_ui.php:321` | Stop "collect the welcome" (`perk_day`) |
| `social169.php` | Garden waterings per helper per day (this one crosses players: keep real) |
| `road_life.php:555-556` | Where road travellers are: real date and 3-hour block. Should follow the walker's game hour |
| `gourmand.php:242` | Which dish he shows (hour of the real day) |

## Shared or world-wide: keep real
Market day and prices (`market100.php`), orders (`trade.php`), job board periods (`jobs.php`), weekly sinks (`sinks.php`), Cat Fish shelves and weeks (`catfish.php`), contests and fair, Gourmand's monthly tour, Village Show, player-to-player visits.

## Open design questions
1. **Exploit check.** Moving a daily limit onto game days means a gnome who sleeps twice in a real day gets two chats, two wonders, two dances. Sleep already costs the day's time, so this is probably the point, but caps like the Petal caps (real-clock by design) must not move.
2. **Mixed days.** A "daily" reward that pays Petals or XP could be farmed by napping. Suggest: only move **free-to-do limits** (chat, dance, wonder look) to game days; leave **paying** limits (Petal sources) on the real clock, or make them game-day AND real-day capped.
3. **Display.** Where a limit resets, say "after you next sleep" instead of "tomorrow".
4. **Clock off.** Every function above must keep working when `game_clock_on` is 0 (they do: `gclock_my_*` fall back).

## Suggested next steps
1. Move chat, wonder look, flower dailies and the welcome onto game days (after question 2).
2. Road travellers and the Gourmand's dish follow the walker's game hour.
3. Add `tests/game_time.php`: set `game_minute`, assert each above flips with the game hour and day, not the real one.

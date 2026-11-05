# Living stops: a new way to use acts (PROPOSAL, nothing built)

Written 2026-11-05 from reading `stops.php` (`stop_pool`, `stop_do`, `stop_state`), `stop_acts*.txt`, `stop_folk.php`, `stop_adopt.php`, `stop_looks.php`.

## 1. What is wrong now (why it feels placeholder)
- An act is a **stateless menu item**. `stop_pool()` picks a few by type + time/season/weather + a daily hash. Nothing you do changes the place.
- Every stop of a type offers the same things. 1,667 acts, but a visit feels the same because each act is "tap, roll, get Petals/XP".
- **No memory.** The place does not know you, other players, or yesterday. `stop_prog` exists (per user per stop) but only the multi-visit `tend` kind uses it.
- **No calendar.** Only the clock (dawn/day/dusk/night), the season and the weather change what is offered. No market days, festivals, repairs, arrivals.
- **The picture never changes** except by time/weather look. What you did leaves no mark.
- Adoption tiers (build/upkeep) are the only slow-changing thing, and acts do not feed them.

## 2. The idea: acts become verbs on a stop that has STATE
A stop keeps a small persistent state. Acts read it and change it. The picture, the folk lines, the news board and the offer list all show it.

### 2a. Four layers of state (smallest first)
1. **Happening of the day** (per stop, per day, shared by everyone). A director picks one from `stop_happenings.txt`: *market day, storm damage, harvest glut, travelling trader, lost goat, festival prep, quiet day, a visitor from another stop*. It sets a headline ("The ferry rope snapped in the night"), re-ranks the offer (2 to 3 happening acts first), and picks a picture overlay.
2. **Stop meters** (per stop, shared, slow). Each is a named bar acts fill: *Repairs, Larder, Lanterns, Cheer, Tidiness*. Filling a bar changes the stop for a few days (see 2d). Draining happens with time and weather. This is the "changes over time" part, and it plugs into adoption: the adopter's upkeep and tier set the floor, visitors move it above.
3. **Familiarity** (per player per stop): Stranger, Regular (5 visits or 3 acts), Local (20), Pillar (adopter or 60). Unlocks acts, folk lines, a named seat, and small perks. Replaces "stamp collected" as the only relationship.
4. **Threads** (per player per stop, multi-visit). Little stories of 3 to 5 beats across days, driven by a villager: *the missing hen*, *the leaky roof*, *the rival bakers*. The existing `craft / collect / tend / contest` kinds are the seeds; a thread is a `tend` with story text, branching and a payoff that also moves a meter.

### 2b. Act data stays; it gains tags and effects (no rewrite of 1,667 acts)
Add optional columns to the act rows (or a sidecar `stop_act_tags.txt`, keyed by slug, so old rows need no edit):
- `needs=` state conditions: `meter:repairs<40`, `fam>=regular`, `happening=market_day`, `thread=hen:2`.
- `moves=` state effects: `meter:repairs+8`, `fam+1`, `thread=hen:+1`.
- `tags=` themes used by happenings: `repair, cook, music, trade, night, rescue, craft`.
Untagged acts keep working as today (generic filler), so migration is gradual.

### 2c. The director replaces the daily hash
`stop_pool()` today: core (fixed per stop) + a few daily random extras. New order, same slot count (`stop_slots`):
1. Happening acts (up to 3, tagged to today's happening)
2. Acts that answer a low meter ("The roof needs hands")
3. A thread beat if one is open for this player
4. Familiarity-gated acts (Regular/Local)
5. Core + diverse extras as now (`stop_diverse` unchanged)
Everything is deterministic from `(stop slug, UTC day)` like now, so no per-view randomness and easy to test.

### 2d. What players SEE change (this is the vibrancy)
- **Picture overlays, not redraws.** Keep the 810 drawn act stills and the stop looks. Add small transparent prop layers per state (`prop-<type>-<name>.png`: bunting, mended fence, extra stalls, lanterns lit, snow-shovelled path, broken rope). The Here scene already has layers and `here_layouts.json` slots; props are the same mechanism the Treehouse and Pal Yard use. 12 to 20 props cover most happenings.
- **Headline strip** on the stop card: today's happening plus the lowest and highest meter in words ("Larder: nearly bare").
- **Folk lines** pick from state: new rows in `stop_chat.txt` with `happening=` and `meter=` conditions (the condition parser `stop_cond_ok` already exists).
- **Notice board** (a card on the stop): "Coming up" (next calendar events), "Needs help" (low meters), "Done lately" (last 5 completions by name, so players see each other).
- **News/Journal**: a stop whose meter completes posts one line to the road journal and the world page.

### 2e. Calendar (cheap, high value)
`stop_calendar.txt`: rules like `every Saturday | market | type=market`, `first Sun of month | festival | any`, `Jun 21 | midsummer | all`, `region=SA Feb | carnival`. The director reads it; a festival day forces a happening and a meter goal ("Fill the lantern string: 0/60"). Reuses real UTC dates like upkeep does.

## 3. A worked example (Maplewold ferry, Saturday)
- Happening: *Rope snapped overnight*. Headline strip says so; picture overlay `prop-ferry-broken-rope`.
- Offer: "Haul the new rope" (check, grit, moves repairs+8), "Calm the waiting travellers" (charm, moves cheer+3), "Row the first run" (needs fam>=regular, pays double), then the usual core.
- 60 repairs total across all visitors that day fixes it; overlay swaps to `prop-ferry-new-rope`, the ferryman's chat changes ("Best rope on the river"), a journal line is posted, the adopter gets a small perk (keeps upkeep easy).
- A Regular who did 3 rope acts gets a thread: *the ferryman's missing hat* (4 beats over a week) with a cosmetic hat reward.

## 4. Build order (each step ships alone)
1. **State store**: tables `stop_state` (stop, meter, value, updated_at), `stop_day` (stop, date, happening, goal), extend `stop_prog` use for familiarity. Time-decay computed on read (no cron needed).
2. **Director + headline strip**, with 6 happenings that need NO new art (text only: market day, quiet day, traveller, lost item, rainy cosy, harvest glut). Tag 40 existing acts.
3. **Meters + moves/needs** on acts, notice board card, folk-line conditions.
4. **Calendar** file and 4 festivals.
5. **Prop overlays** (art): 12 props first for the three happenings with the most visible effect.
6. **Threads** (3 sample threads), then admin editor for happenings/threads (like Admin > Stop activities).
Admin page + tests per step (`tests/stops100.sh` pattern; add `tests/stopstate.php` for director determinism and decay).

## 5. Rules and guard rails
- Shared state must not be griefable: meters only go down by time/weather, never by a player action; per-player daily cap on meter gain (e.g. 30 per stop) so one player cannot finish everything.
- Energy and reward budget: happening acts must pay about the same as core acts; the reward is variety and visible change, not more Petals (`balance_sim.php` Walks check).
- Everything has a no-script path (forms post as today) and CSP-safe classes (no inline styles).
- Offline players lose nothing: no mandatory daily thing.

## 6. Answers this gives to the open art/act questions
- **Redraw all 1,667 acts?** No. Keep the stills. Spend the art on ~15 state props plus the 4 placeholder kind cards (`act-craft/collect/tend/contest`).
- **Used-only?** Moot. Untagged acts stay as filler.

## 7. DECISIONS (Josh, 2026-11-05)
1. **Meters are per player only** (stored in `stop_prog`, key `meter:<name>`), not shared. No griefing, no cap logic needed. The happening of the day stays shared by everyone at that stop (it is computed from stop + date, no state).
2. **A full meter gives something extra for the area**: read as a perk on that stop for that player (e.g. an extra slot or a small bonus for some days, and a line in the Journal). Exact perk: decide when step 3 is built.
3. **Text first.** Step 2 (director, headline, folk lines) built; picture props later.
4. Happenings: Josh left it open, so I picked 8: quiet day, market day, traveller, lost thing, cosy weather, harvest glut, repair day, still night (`stop_happenings.txt`). Change freely.
5. **Craftmap: draw the 14 scenes.** (Art task, not started.)

## 8. BUILT 2.5.72 (UNRELEASED, branch only): step 2
- `data/stop_happenings.txt` (8), `stop_happening()`, `stop_happenings()`, `stop_act_tags()` (acts tagged by keywords in name and blurb, `STOP_TAG_WORDS`) in `stops.php`.
- `stop_now()` now carries `hp` (the happening id), so `hp=<id>` works as a condition in folk chat (10 new lines in `stop_chat.txt`).
- `stop_pool()`: up to 3 happening acts first (taken out of the daily rotation, total offered unchanged); returns `happening`.
- Headline strip (`.st-hap`) on the town stop card and on a happening act's card on the Here picture.
- Tests: `tests/stops100.php` section "happenings" (129 checks pass in `stops100.sh`).
- Next: step 3 (per-player meters + `needs=`/`moves=` on acts, notice board, perk), step 4 calendar, 5 props, 6 threads.

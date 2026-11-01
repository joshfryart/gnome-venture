# Plan: villager brains (feel alive, no model, no downloads)

Status: planning only. Nothing built.

## Goal
Villagers feel alive when you talk to them: they remember you, have moods, react to the world, gossip, and rarely repeat. Nothing for the player to download. Runs on the existing PHP + MySQL + vanilla JS stack. No LLM.

## Key idea
"Alive" is mostly **state + memory + callbacks + variety**, not language generation. A villager is a small saved record plus a **storylet engine**: authored lines carry conditions on the state, and a salience-weighted pick chooses the best one. Writing is cheap to ship and 100% on-brand; the engine is a few hundred lines.

## Brain record (~500 bytes per villager, table `npc_brain`)
- `traits`: warm, curious, grumpy, chatty (0-9), seeded from `personality`; plus 1 verbal tic and 1 pet topic.
- `needs`: social, rest, hunger, purpose (0-100) + `last_tick`.
- `mood`: derived from needs + recent events (not stored separately).
- `mem`: <=8 structured facts with salience and day (`gift:item`, `weather:storm`, `heard:npcB:fact`), decay, evict lowest.
- `now`: activity + place from `npc_schedules`.
- Per player (`npc_bond`): affinity, times met, first/last seen day, last topics (ring of 6), liked gift, one open "thread" (something they asked you).
All capped, so storage is bounded.

## The engine
1. **Lazy catch-up** on view (no cron): replay `min(elapsed/tick, 48)` ticks of need decay, schedule moves, mood drift. Co-located villagers roll a seeded "meeting" and swap one memory, so rumours spread with zero cost.
2. **Line selection** (extends the existing `stop_chat.txt` format: `when | personalities | line`): add conditions on bond, memory, needs, days-away, your level, garden, season, weather. Score = specificity + salience; down-weight lines the player has heard recently (per-bond history); random among top 3.
3. **Light grammar** (Tracery-style `#tag#` expansion) for slot fill: item names, places, your name, the villager's tic. One line template yields dozens of variants.
4. **Dialogue state, not one-liners:** tap choices (Greet, Gift, Ask about X, Gossip, Bye). Each choice sets a topic; the reply can be a follow-up to the last one. A conversation of 3-4 beats feels far more alive than 4 unrelated lines.
5. **Effects:** a line may carry safe effects (mood +1, affinity +1, remember X, open a thread). Never grants Petals/items beyond the existing capped systems.

## What makes it *feel* alive (cheap tricks, ordered by payoff)
1. **Callbacks:** "You gave me that turnip last Tuesday." "Back already? Three days ago you were off to the Fen."
2. **Noticing you:** comments on your level, a ready harvest, a new hat, weather, season, time of day.
3. **Initiative:** they ask you something, hold a grudge, or gossip about another named villager (real shared memory).
4. **Mood that shows:** tired = short lines and yawns; chatty = longer; grumpy = cranky but fair.
5. **Non-repetition:** history per bond, so repeats are rare.
6. **Pacing polish:** short "thinking" beat, emote/sprite change, text typed in, tic words. Tiny CSS/JS, big effect.
7. **Consistent voice:** each villager's line pool and tic differ; hand-write 25-40 lines each for the stars, shared pool for the rest.

## Pitfalls and fixes
- **Authoring load is the real cost.** Mitigate: grammar variants, shared pools by personality, ship 5-6 hero villagers first, grow content over releases. A big model offline (me) can draft lines for you to edit; none ships to players.
- **Feels scripted once seen through.** Mitigate: callbacks and gossip need real state; keep history so no repeats; track coverage in admin.
- **Combinatorial bugs** (a line references a memory that is missing). Mitigate: conditions are checked, slot fill falls back to a generic word, unit test every line against fixtures.
- **Race safety:** global villager state updated with conditional UPDATEs (README conventions); player can nudge mood only a small clamp per day.
- **Economy leaks:** effects whitelist; no new repeatable Petal source.
- **Privacy/safety:** all text is authored, so no moderation risk; nothing player-typed is stored or shown.
- **Testing:** sim is pure and seeded; golden tests on selection; SQLite suites need no extras.
- **Upgrades:** `brain_v` + `boot_step` migration; memories are structured so they survive text edits.
- **Perf:** O(1) per view, a few small row reads.

## Phases
1. **Brain state + lazy tick** for the rest-stop folk (`stopfolk.php`, `stops.php`); admin page showing a villager's brain.
2. **Storylet selector + grammar** over an extended `stop_chat.txt` format; non-repeat history. Port the existing lines.
3. **Dialogue beats + callbacks + effects** with 5-6 hero villagers fully written.
4. **Gossip + initiative + mood presentation** (tics, emotes, pacing).
5. **Roll out** to the rest of the villages with shared pools; coverage report in admin.
Ship after phase 2: it already beats today.

## Optional later
A tiny hand-rolled Markov/n-gram "mutterer" (few KB of data, no download worth noting) for idle barks and names. Only if authored lines feel thin.

## Open questions
1. Start with rest-stop folk, or `npcs` in the main hollow too?
2. Private per-player memory (recommended) or some shared world memory?
3. Do you want to help write the hero villagers' voices, or should I draft 25-40 lines each for you to edit?
4. Do guests get brains?

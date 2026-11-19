# End pieces Trail Sights: what still cannot be done (engine gaps)

Status: checked line by line 2026-11-19 (Sights fourth pass, `claude/trail-2.7.08-notes.md` "Fourth pass"). DONE = in the engine (and in the data where it says so); OPEN = still not possible, with what it needs. Rows `trail_sights_end.txt` (43), folk `trail_sight_folk_end.txt` (50), quests `trail_sight_quests_end.txt` (8 lines), items `trail_sight_items_end.txt` (7), pages `trail_sight_pages_end.txt` (7), newfolk `trail_sight_newfolk_end.txt` (7). Lint clean. Ideas: `ideas-end-pieces.md`. Grammar: `GRAMMAR.md`.

## Test gap (not data)
- DONE (checked 2026-11-19): `tests/trail_sights.php` passes the right pick, knows `anylast` / `firstlast`, hands over `needs` items, runs gated lines after their gate and counts only `sight:` pages; every end line runs to its end.

## Per-destination text (one slug stands before several places)
- DONE 2.7.08 (engine): `to=` and `{cond}` line variants. Written for end-wonder-2-forest (5 places), end-haven-2-grassland (5), end-lair-1-mountain (2).
- OPEN (writing only, no engine work): per-place lines for haven-1-grassland / wetland, haven-2-coast, wonder-1-coast / grassland / mountain / rainforest, wonder-2 coast / desert / grassland / island / mountain / rainforest / wetland, delve-1-desert / rainforest, delve-2-rainforest / desert, lair-2-mountain.

## State hints
- DONE 2.7.08: `hint=tide`, `hint=moon`; a line can depend on the weather (`{we=sun}`), so the Dragonlizard sun line can be written (a data line).
- DONE 2.7.08 third pass A: first room of a delve (`hint=firstroom`), glow-pulse / snore / web hum / rut width (`hint=glow|snore|webhum|rut`).
- OPEN: current channel / ledge count (the delve map has no such value: needs a delve fact to read), the Oasis's village today (wonder-2-desert: needs the Oasis schedule exposed as a hint), which seed can be dug today (wonder-1-forest: needs a per-day seed pick), the real first turn of the Labyrinth (its pick is a random per-day pick, not a map).
- OPEN: lair stat hints ("Nimble will matter") stay fixed text. Needs: a hint kind that reads the lair boss's strongest stat.

## Effects outside the Sight
- Shop effects: DONE 2.7.00 `disc=rest|shop`; in the data 2026-11-19: rest price -10% (`end-haven-1-grassland` `disc=rest:10:180`) and -25% (`end-haven-1-island` `disc=rest:25:180`), for 180 real minutes rather than "today". OPEN: free shop peek of today's shelf, the tavern bar peek (need a read-only shop / tavern view from the Trail), Lyra's half-price song, the smuggler's half-price rope (need a discount scoped to one service / item).
- Walk time: DONE 2.7.08 third pass A (`nxt=quick`, `nxt=skip`); in the data 2026-11-19: `end-wonder-2-island` `nxt=quick:10` (name the first star), the boat gnome at `end-haven-1-wetland` `nxt=skip` (ride along). `nxt=skip` now never jumps past a fight that waits. Not changed: haven-1-coast, wonder-1-mountain (keep `reveal`; the ideas give no time). OPEN: "your NEXT walk is shorter": needs an effect kept past the walk's end (`sec=` can aim at a named stretch of a named route, not at "whatever walk comes next").
- Delve- or lair-scoped buffs: DONE 2.7.06 `buff=stat:N:delve`; in the data 2026-11-19: `end-delve-2-forest` and `-rainforest` `buff=sense:1:delve`, `end-delve-2-wetland` `buff=luck:1:delve`. DONE `buff2=` (a second buff in a row). OPEN: Charm "for the wonder" (needs a wonder scope), one fewer wrong turn / a dry first room / a safer first bridge / a firefly that counts as a lantern (need delve hooks: `delve_v2`), the Sneak bonus inside a lair (Hushed Steps: needs a stance modifier in the lair code), the Scout's Spyglass "+1 Sense on every end-piece scout" (needs a carried-item effect on Sight checks).
- OPEN: pick difficulty by time (a pick has no difficulty; the night `nocheck` villager stays). A stat check can now depend on the time: `charm:11?dp=night:9` (fourth pass).
- DONE 2.7.08 third pass B: letters (`letter=<key>`; Tuck Bumbleby at end-wonder-2-wetland).
- OPEN: Almanac lines per firefly named (delve-2-rainforest): needs free text from the player (a name field), an owner decision (moderation).

## Villager timing words
- DONE 2.7.00 `gd=7:0` ("every 7th game day"). NOT in the data: Captain Spurwing at lair-2-mountain is a mentor / fixed villager, the clockwork never lets him travel and the lint refuses the row (tried 2026-11-19). Needs: a mentor allowed out on a given day (clockwork), or another villager for the tip.
- DONE (role hours, 2026-11-14): "when Lyra is in the Sunsprinkle Isles" = a travelling NPC row with no `dp=` follows her circuit (haven-2-island). DONE 2.7.08 `mk=yes` (market days).
- OPEN: choices: let the sleeper sleep (Luck) or wake them (cornbread) at haven-2-grassland, "or toss a sardine" as a second way past the gulls' Grit check: both need a check alternative that is an item (`grit:11+take=sardine:1`), a new check kind. "Any seed" for the caravan swap (wonder-2-grassland): needs `give=any-<kind>` (give= takes one item; seeds are a category, not a kind).
- DONE 2.7.08: a Sight row's `take=` may carry `?cond`.

## Quest gaps
- Q1 "all five lanterns lit inside one season": DONE in the engine (2.7.06, the 11th `Q|` column = game days). NOT set on `lamplighters-round`: a timed line drops its progress when late. Needs: Josh's yes and the number of game days.
- Q2 finale: DONE 2.7.08 third pass B (`@green`). OPEN: the Hushed Steps buff (Sneak easier at every lair for 3 game days): needs a lair-stance modifier; the reward stays Nimble +1 240 min.
- Q4 / Q5 "start at X": DONE 2.7.08 second pass (`firstlast`); in the data 2026-11-19: `gate-rubbings` and `book-of-hushes` are `firstlast` (they were `anylast`).
- Q6: BY DESIGN: Pomeroy is hidden until the Gourmand opens; his line still runs. No work.

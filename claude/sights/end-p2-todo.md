# End pieces Trail Sights: what still cannot be done (engine gaps)

Status: 2026-11-12, pass 2. Rows `trail_sights_end.txt` (43), folk `trail_sight_folk_end.txt` (50), quests `trail_sight_quests_end.txt` (8 lines), items `trail_sight_items_end.txt` (7), pages `trail_sight_pages_end.txt` (7), newfolk `trail_sight_newfolk_end.txt` (7). Lint clean. Ideas: `ideas-end-pieces.md`.
Everything the grammar can express is in the data now (picks, true hints, sneak/pal bonuses, tallies with title/page milestones, nocheck and give villagers, the design's missing villagers as newfolk, anylast / @boss / @meal / gates / needs, titles, pages). What is left:

## Test gap (not data)
- `tests/trail_sights.php` predates the pass-2 grammar: its every-route run calls `trail_sight_do` with no `pick` (all pick Sights are refused "Choose one"), its quest walk does not know `anylast` (it tries the last beat first), `needs` (no items given) or gates (the gating line is never done), and the "one Almanac page per Sight" count includes the `page=` pages. Those checks fail for every set using the new grammar; the test needs updating (owner of the engine/tests).

## Per-destination text (one slug stands before several places)
- A line cannot know which place the route leads to. Variants stay general ("a gate, or a panda, or a stone head"); per-place lines for haven-1-grassland/wetland, haven-2-grassland/coast, wonder-1-coast/grassland/mountain/rainforest, wonder-2 coast/desert/forest/grassland/island/mountain/rainforest/wetland, delve-1-desert/rainforest, delve-2-rainforest/desert, lair-1-mountain, lair-2-mountain need a `to=` condition (destination slug).

## State hints with no hint kind
- Real tide / current channel / ledge count / first room of a delve (delve-1-*, delve-2-wetland), glow-pulse speed / snore count / web hum / rut width since last visit (lair-2-*), the Oasis's village today (wonder-2-desert), which seed can be dug today (wonder-1-forest), the real first turn of the Labyrinth (the pick is random per day, not the map). Needs more `hint=` kinds.
- Lair stat hints ("Nimble will matter") stay fixed text; the we=sun-only Dragonlizard hint cannot be a conditional line (lines have no conditions).

## Effects outside the Sight
- Shop effects: rest price -10% / -25% (haven-1-grassland, -island), free shop peek of today's shelf, the tavern bar peek, Lyra's half-price song, the smuggler's half-price rope.
- Walk time: arrive 10 game minutes sooner / skip the last stretch / next walk shorter (haven-1-coast, haven-1-wetland, wonder-1-mountain, wonder-2-island). Rows use `reveal`.
- Delve- or lair-scoped buffs: Sense/Luck/Nimble "for the delve", Charm "for the wonder", one fewer wrong turn, a dry first room, a safer first bridge, a firefly that counts as a lantern, the Sneak bonus inside a lair (Hushed Steps); the Scout's Spyglass "+1 Sense on every end-piece scout" (it is a one-use 240 min buff item). One `buff=` per row still.
- Pick difficulty by time (Borrow a firefly easier at night: done with a night `nocheck` villager instead).
- Letters: wonder-2-wetland letter-carrier handing a real Letter (`letters.php` hook).
- Almanac lines per firefly named (delve-2-rainforest).

## Villager timing words missing
- "every 7th game day" (Captain Spurwing at lair-2-mountain), "when Lyra is in the Sunsprinkle Isles" (haven-2-island), "market days" (feather-crafter). Rows use plain chances.
- Choices: let the sleeper sleep (Luck) or wake them (cornbread) at haven-2-grassland; "any seed" for the caravan swap (wonder-2-grassland; give= needs one item); "or toss a sardine" as a second way past the gulls' Grit check (a take on a lose path).
- A conditional take: the crab-sitter only at low tide is a dawn `give=` villager (fine), but a Sight row's `take=` cannot have `?cond`.

## Quest gaps
- Q1 "all five lanterns lit inside one season": no time limit on a line.
- Q2 finale "Lyra plays on any village green": the finale beat is the lair-2-mountain Sight with 6 Snore Notes; no "at a village" beat kind. Hushed Steps buff: replaced by Nimble +1 240 min.
- Q4 / Q5 "start at X": anylast lines may begin at any beat; a fixed FIRST beat plus a fixed last one is not an order.
- Q6: Pomeroy is hidden until the Gourmand opens; his line still runs (he only gives the reward friendship).

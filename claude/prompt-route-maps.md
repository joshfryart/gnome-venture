> **Status 2026-11-07:** this prompt describes the original flat 11 x 7 sections (the game now plays 22 x 7). The planned new design is 30 x 18 sections with a wandering road that enters and leaves on any edge (`claude/plan-route-map-bends.md`, prototype in `claude/bend-prototype/`, rules in `tools/bend_rules.py`, check with `tools/lint_trail_bends.py`). Use this prompt only for the old flat format.

# Prompt for another AI: one authored Trail map per route

## Purpose
Gnome Venture is a cosy garden-and-adventure web game. When a player walks a route (a path between two places) the game shows the walk as **tile sections**, one after the other ("Trail to Meadowmere, Section 1 of 3"). Today every section is **random** (a winding corridor), so every route feels the same. We want each route to have its **own hand-made map**: a long strip of ground split into **3 sections**, walked left to right, with things on it that belong to that spot, so a player who walks Maplewold to Maizehollow remembers the old mill ford, and a different route has a different feature.

Small to medium: **each section is 11 tiles wide x 7 tall**, so one route is 33 x 7 laid end to end. Do not make it bigger. The game's camera shows about 9x9 tiles at a time and the player taps tiles to walk.

## Route list
The full list is in `route-list.md` (generated from the game's own routes): id, from, to, land, number of sections. 246 routes, grouped by region. Do **one region at a time**. The number of sections is not always 3 (2 to 5): make exactly as many as the line says.

## Tile characters (ASCII, exactly these)
- `#` wall: trees, rock, water too deep to cross, hedge. The route's edge. Never leave floor on the outer border except the entry and exit.
- `.` floor you can walk. `,` rough floor (walkable, looks different: grass, gravel, mud). Use both so it does not look flat.
- `S` entry: section 1 only, on the **left edge** (x=0). Sections 2 and 3 start at the same place the previous one ended.
- `9` exit: on the **right edge** (x=10) of every section.
- `E` a fight spot, `F` a find spot (a thing to pick up). Both sit on floor. They are markers; the game rolls what they are.

## Rules for each section
1. Exactly 7 rows of exactly 11 characters.
2. One clear walkable path from the entry (or the left edge) to the `9`. Check it. No sealed loops, no dead-end only maps.
3. **Continuity**: the `9` row of section 1 is the row the player appears on in section 2, and so on. So section 2 has floor at x=0 on that row (use `S`-less floor `.`) and the whole strip reads as one long map.
4. Width: floor 2 to 4 tiles wide in places so it is not a one-tile tunnel, with some nooks and a side pocket to explore. At least one **choice** per section (two ways round something, one longer and one with a find).
5. 0 to 2 `E` and 1 to 3 `F` per section. Never within 2 tiles of the entry or the exit. Put finds off the main line so exploring pays.
6. Each section has **one set piece unique to this route**: a ford, a fallen log bridge, a shrine, an old waystone, a beaver dam, a lone orchard, a cave mouth, a washed-out road, a windmill. Shape the floor so the set piece is visible in the map (the ford is a gap of floor between two walls, the shrine sits in a round clearing). Name it.
7. Let the land decide the feel: forest = tight winding with clearings; coast = long open beach with rock walls; mountain = steep zig-zag switchbacks; desert = wide open with few walls; wetland = lots of walls (water) and a narrow causeway; island = short, round. Keep it friendly: nothing grim.
8. Two routes must never share a map. If two routes are mirror images (A to B and B to A), they are the same route: do one map; the game reads it backwards.

## Output, per route, as JSON (one object, nothing else)
```json
{
  "route_id": 12,
  "from": "The Maplewold Market",
  "to": "Meadowmere",
  "land": "forest",
  "sections": [
    {
      "feature": "the old stone ford",
      "caption": "A shallow ford, stepping stones worn smooth.",
      "rows": ["###########", "#.....#...9", "..." ],
      "tokens": [[4, 3, "F"], [7, 2, "E"]]
    }
  ]
}
```
`rows` is the 7 strings. `tokens` repeats the E and F positions as `[x, y, "E" or "F"]` (so we can check them against the rows). `caption` is one short, kind sentence shown to the player under the map. Keep the voice of the game: warm, small, a little silly, no violence words.

## Check before you answer (do this for every section, show nothing, fix silently)
- 7 rows x 11 columns; only characters `# . , S 9 E F`.
- `S` only in section 1; one `9` in every section, on x=10.
- A path exists S/left edge to 9 using only `. , E F 9`.
- Section n's exit row = section n+1's entry row, and that cell is floor.
- E and F on floor, at least 3 tiles from entry and exit.

## What happens to your output
We paste each JSON into `game/includes/data/trail_maps.json`; a route with an entry uses it instead of the random generator. Fights, finds, energy and the in-between events stay as the game already does them.

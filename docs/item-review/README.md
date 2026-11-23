# Item review (docs only, no game code changed)

Review of every item at game 2.7.57. Read in this order:

1. `review.md` + `flags.json`: Opus review (59 verified findings: holes, exploits, redundancy, useless items). Ids (H1, EC1, R3, uA-1, B1, E1...) are used everywhere below.
2. `fixes.md`: proposed fix per finding, grouped A data-only / B small code / C needs owner decision.
3. `plan.md`: Fable plan to reuse existing items in recipes, crafting, mending.
4. `creature-parts.md` then `creature-parts-plan.md`: creature-part families, alchemy tool augments, kit mending, compost, other sinks. Phased build plan with file:line. Decisions are locked at the end of that file.
5. `items.json`: merged item graph (1912 items, 347 recipes, 41 shops). Built by Sonnet agents; UNVERIFIED, check the repo before relying on it. Known gaps: no edges for stop acts, Tailor, build plans, Sights, creature drops; "orphan" only means no recipe and no shop; some phantom nodes.
6. `nodemap/`: source of the node-map artifact (`index.html` + `items.json`, static page using d3 7.8.5 from cdnjs). Dashed gold links are planned features.

Locked decisions: augments stored per tool in new user_items columns (aug, aug_left), one slot, survive breakage and mending; part families (any-hide, any-plate, any-wing, any-ooze, any-silk, any-gem); tool-repair-kit also mends garden/gather tools (order: free shed mend, kit, Petals); Plate Edge 25% for 40 uses, may lift one tier above the tool gate; compost takes parts with no cap, excess banks; Plate to Shell Meal 2:1; Ooze quest with Pomeroy (Gourmand only); Silk Splice dropped, Silk Lashing added.

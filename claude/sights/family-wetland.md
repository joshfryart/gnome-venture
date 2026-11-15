# Wetland family (2.7.01)
Built
- `includes/trail_fam_wetland.php`: Reed-line ripples strip (one ring per wetland Sight, open/rest said in words), Stepping Stones tally, firefly row (8 lamps; lit count = 2 + 6 x darkness of the moon, only at dusk/night), villager chips. CSS block `tfwetland` / `tfw-*` in style.css (dark theme, reduced motion).
- Rows (trail_sights_shared.txt, wetland only): lily-pad-ford now `pick:3:Left pad;Middle pad;Right pad`, fail_en 1 (a miss costs only energy), `tally=stones` + gift at 5, title Stone Hopper at 12. Boardwalk gap: extra bog-iron chance at stones 5 (the chain). Reed causeway: `firefly-light` 15% at dusk/night, 30% at new moon (`mo=new`).
- Item: `trail_sight_items_fam_wetland.txt` firefly-light (art needed: `ph/firefly-light.png`).
- Quest "The Dragonfly Bend Count" (`trail_sight_quests_fam_wetland.txt`, giver Pip Oakenpot, `anylast`): spring/summer/autumn counts at the bend (se=), Fig Hollowell at the causeway (npc), Pip at dusk (npc, new folk row in `trail_sight_folk_fam_wetland.txt`).
- Test: `tests/trail_fam_wetland.php/.sh`.
Open
- Ripples are a strip, not animated on the tiles (no tile hook). Winter has no beat: the line needs a spring, summer and autumn visit (about a game year).
- Wetland Sights are not tied to the moon anywhere else; the Flood Boots rule from the proposal is not built.
- Pip's old summer-day folk rows stay; his dusk row is the finale. Tally is lifetime.

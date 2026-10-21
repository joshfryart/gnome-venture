# Chapter III-a: The Humming Deep (draft title, for Joshua)

> III-b "The Knock Below" (v2.0.22) continues this chapter below the Still Gate: see `claude/trek-chapter3b.md`. The Still Gate now opens after Old Gneiss.

Cosy-eerie deep rock. The blight is cured, not killed. A slow knock from below gets closer. Nothing says what knocks.

## Zones (map 40x50, ~517 walkable tiles, main route ~190 steps, ~20 min)
- t Shale Stair (Lv20 shale-slater, quartz-snail)
- u Lamp Niche (the camp, quiet)
- v Glimmer Vein (chalk wall, quiet bench, Wayfinder nook, Knock Door riddle, Tapping Door)
- w Echo Hollow (Wren Thimblewick, Warm Ledge old camp, Old Gneiss)
- x Still Landing (the Still Gate: closed; bumping it pays ch3a_end; III-b opens it)

## Spots
start, ore cart, camp, chalk wall, rest bench, Wayfinder nook (loose clay), riddle door (2 tries, Seedkeeper reads it), gate, Wren (recruit), old camp, Old Gneiss (mini-boss), Still Gate. Only existing tiles and spot types.

## Wren Thimblewick
Bloomcaller, recruited here. Crew moment reuses st.bless (+1 to hit and armour until the next fight ends). +20 friendship on join, join card as for the others.

## Old Gneiss (mini-boss, script `gneiss` in includes/trek_ch3.php)
Moves hit / brace / slam, shown a round ahead. Brace: takes half. Slam: 2x blow on a random friend. Under 35% the shell cracks: no more brace, takes 120%. He tires from round 3 (+12% damage taken per round, up to +120%). The deep hum mends every living friend 4% a round. Tougher by 30% for each healer or Bark Skin giver beyond the first (Bloomcaller, Seedkeeper, Rootwarden, Brewroot); this evens out parties with and without a healer.

## Numbers (trek Lv15-16 on entry, no knacks)
- Creatures: shale-slater 20, quartz-snail 21, pale-olm 21, echo-bat 22, gravel-centipede 23; boss old-gneiss 24.
- Zone tune (hp%|atk|ac|dmg): t 330, v 345, w 335, x 355. Random fights ~85-90% for four.
- Milestones: ch3_wren 450, ch3_gneiss 1100, ch3a_end 900 (settings trek_ms_*).
- Old Gneiss (gnome 17, mates 16, all 35 parties): see the sim table in the commit notes. Median ~89, worst ~70.

## Gate
Setting `trek_chapters_open` (default 2). Players go down only to chapters at or below it; admins always can. A closed chapter shows "coming soon" and costs nothing. A player already inside stays.

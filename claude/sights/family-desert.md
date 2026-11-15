# Family: desert (2.7.01)
Built
- UI: `includes/trail_fam_desert.php` + CSS "Desert family" block. Shown for a section with a `desert-` mark. Day: sun strength 0-5 by hour (+1 in heat), water gauge (5 - sun) as pips + words, shimmer on the heading at sun 4+ (CSS, reduced-motion off), shade list. Dusk/night: cool strip with the moon (name, day of 28) and which cool-night Sights pay tonight. Caravan Stop line at the tent poles, up to 2 villager chips.
- Moon (`mo=`): bones `en=1?dp=night/mo=full,waxing-gibbous,waning-gibbous`; mirage pool extra marble `@20?dp=night/mo=full` (edited in trail_sights_shared.txt, desert rows only). Well now gives `item=well-water:1`.
- Caravan Stop: new item `well-water` (`trail_sight_items_fam_desert.txt`, art todo: `ph/well-water.png`). Tobias Trundle row at tent poles `gd=7:0` (folk fam file), `give=well-water:1,seed=1,tally=caravan-trades,fp=1`. He is a traveller (no clockwork key): his circuit decides if he is there.
- Quest "Lanterns for the Long Way Home" (gate quest:trader-went-home, giver Tobias): lantern at poles (dusk), then npc= Ivy Brambleby (arch), Yarrow Lanternby (ripple lane), Orla Teaspoon (well), all dusk; finale at poles `dp=dusk/gd=7:0`. New dusk folk rows for Yarrow and Orla.
- Test: `tests/trail_fam_desert.php/.sh`.
Open
- Water gauge is derived from sun/hour, not a real drain (no state token); Shade pips are static.
- Finale "Tobias in his own region" not checkable: only 7th day + dusk. A beat cannot name a traveller.
- Tally is lifetime; `caravan-trades` has no milestone payout yet.

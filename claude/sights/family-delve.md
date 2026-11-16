# Family: delve (2.7.01)
Built
- UI: `includes/trail_fam_delve.php` + CSS block "Delve family" (style.css). Shows when a mark slug starts `end-delve-`. Torch bar: torch reach 1-5 (ring + pips + words): day 5, dusk/dawn 4, night = 1 + moon light x3 (new 1 .. full 4), +1 per lit mouth. Torch per mouth (lit = used this cooldown), Lamplighter's Round live count (lantern-line mouths), Torchbearer tally, 2 villager chips. No JS.
- Game: all 9 `end-delve-*` rows (trail_sights_end.txt) got `tally=delve-torches`, `c=5:1?tl=delve-torches:3`, `title=Torchbearer?tn=delve-torches:12`, `buff=sense:1:60@35?mo=new;waning-crescent;waxing-crescent/dp=night`.
- Quest "The Book of Hushes: Doorways Down" (`delve-hushes`, `trail_sight_quests_fam_delve.txt`, giver Sorrel Inkcap = mentor, never a beat): pebble (plain), then npc= Mabel (dawn), Ulric Acorncap (dusk), Ferrin Sedgemoor (night), Juniper Windlass (dusk). Uses existing folk rows; all free villagers with windows.
- Test: `tests/trail_fam_delve.php/.sh`.
Open
- "Reach shrinks over steps" is moon/daypart based, not per step (no per-step state in ctx).
- Lamplighter's Round "timer" not built (no timing token); shown as lit-this-cooldown count. Tally is lifetime (see family-forest.md).
- The Sight "silence" (no chat/fight) is story only.
- trail_sights fails on `wonder-postcards` (wonder family, not mine).

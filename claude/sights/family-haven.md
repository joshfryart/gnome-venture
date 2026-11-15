# Family: haven (2.7.01)
Built
- UI: `includes/trail_fam_haven.php` + CSS block "Haven family" (style.css). Shows when a mark slug starts `end-haven-`. Moon of the day (full = bedtimes +1 h, new = -1 h), guest book (one line per villager in the section's haven folk rows: "signed" if friendship >= 1, else "blank line"), bedtime round (fixed bed 8-10 pm per name via hollow_unit, moon shift; "up" / "tuck in now" the hour before / "asleep" bed to 6 am). No JS.
- Game "Bedtime Rounds": all 8 `end-haven-*` rows got `tally=tucked?dp=dusk;night`, `c=5:1?tl=tucked:3/dp=dusk;night`, `title=Night-Light Keeper?tn=tucked:10`, a night luck buff at full/gibbous moon, and sea glass at low tide (`ti=low`) on the two coast rows.
- Quest "The Guest Book" (`trail_sight_quests_fam_haven.txt`, giver Tobias, gate `quest:rest-here-repainted`): sign's back (plain), then npc= Alder (dawn), Sorrel (dawn), Posy (night), Tilly (dusk). Tobias is never an npc= beat. Uses the existing folk rows in trail_sight_folk_end.txt (no new rows needed).
- Test: `tests/trail_fam_haven.php/.sh`.
Open
- "Right order" of tucking in is shown, not enforced (no engine token for order); tally is lifetime and has no daily reset (same gap as forest).
- Lyra, Tobias, Pomeroy have no clockwork: they sign the book but have no npc= beats; Pomeroy is hidden before the Gourmand opens.
- The strip uses friendship >= 1 as "met"; Sight appearances are not logged separately.

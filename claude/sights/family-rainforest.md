# Family: rainforest (2.7.01)
Built
- UI: `includes/trail_fam_rainforest.php` + CSS block "Rainforest family" at end of style.css. Shown when a mark slug starts `rainforest-`. "Canopy layers": two `<details name="tfr-layer">` (floor open, canopy closed; browser makes them exclusive), no JS. Lists each Sight ready/resting in words. Under it: Mist Pool Tally count + way to the title, moon name (full moon at night is said), up to 2 villager chips (deduped) from npc_cw_sight_lines.
- Game "Mist Pool Tally": mist-pool, rain-drum-leaf, canopy-gap rows got `tally=mist-pools` and `title=Mist Keeper?tn=mist-pools:12`. Full-moon night bonuses: mist-pool dew-pearl, orchid-tree cut-moth-orchid, lantern-fruit longer sense buff (all `dp=night/mo=full`).
- Quest "The Orchid That Opens at Night" (`trail_sight_quests_fam_rainforest.txt`, giver Quill Thistledown): all 5 beats `dp=night`; beats 2/4/5 are npc= (Posy Marrowby at lantern fruit, Juniper Puddlefoot at fallen giant, Quill at orchid tree). New night folk rows in `trail_sight_folk_fam_rainforest.txt` (Juniper, Quill).
- Test: `tests/trail_fam_rainforest.php/.sh` (strip, tally to the title, mo=full cond, chips, quest to the end with a miss that says when).
Open
- Sights cannot be truly hidden on the map: "some Sights only visible in canopy" is only the floor/canopy list (needs a map layer token).
- "Fill all pools in one day" not enforced: tally is lifetime (see family-forest.md); needs `tally=key@day`.
- Quest does not need a lantern tier (no tier token) and Pomeroy (Gourmand, festival camps) is not used.
- Full moon only bonuses rows; the quest itself has no `mo=` beat gate (beat `when` could take `mo=full` if wanted).
- Tally keys are one shared `mist-pools`, not one per pool.

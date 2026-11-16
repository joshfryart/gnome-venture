# Family: wonder (2.7.01)
Built
- UI: `includes/trail_fam_wonder.php` + CSS block "Wonder family" (style.css). "Postcard frame": for each `end-wonder-*` mark in the section a framed card (land emoji, gate/hush, moon postmark with phase and day, sticker slot "sticker stuck"/"empty sticker slot" from trail_sight_uses), then the 16-slot album (found/empty in words), Look Closer tally, up to 2 clockwork chips (villagers due at the wonders). No JS.
- Game "Look Closer": all 16 wonder rows are `pick:3:detail;detail;detail` (hidden-detail guess, right one fixed per gnome and game day) with `tally=wonder-looks` and `title=Sharp Eye?tn=wonder-looks:8`; the 3 old pick rows kept their picks. Moon bonuses `mo=` on 11 rows (full moon desert glass/sage/cricket chirp, new moon glow items). Stat checks (sense, nimble, lore) on 4 rows replaced by the pick; wetland/island/rainforest lose lines kept, 8 new lose lines written.
- Quest `wonder-postcards` "Wren's Gate Rubbings: Postcards" (`trail_sight_quests_fam_wonder.txt`, giver Wren, 5 beats seq): forest gate; desert (npc Marigold Nettlebed); mountain dawn; wetland (npc Tuck Bumbleby); island hush at dusk (npc Juniper Honeycomb). Existing folk rows used, none added.
- Test: `tests/trail_fam_wonder.php/.sh`.
Open
- Look Closer is one detail per use ("find 3 things" is 3 labels, one right), not 3 separate finds per wonder; needs a per-Sight multi-find token.
- Sticker = "used at least once" (trail_sight_uses rows are purged after 120 days: a very old sticker can vanish; a lifetime per-slug tally would fix it).
- Perrin Hollowell (island gate) is a post villager (no clockwork), so not an npc= beat. Wren is a traveller: giver only.
- Sprites: no art added (emoji). The 2.5D art for the 16 wonders is the wonder end-art TODO.

# Pal sprites test batch (art-2701), one pass, no fix round
Sizes: perch 36x36 (treehouse perch sprites are shown at w=36 h=36 in `hub_pages.php`), yard 64x64 (size of the existing pal stickers in `game/assets/img/pals/`; the Pal Yard display size was not found in code, so this is a guess).
Pals are per-picture rows in `game/includes/data/puzzle_pals.txt` (570 rows, 6 callings), not a few kinds. These 6 are from Maplewold, one per calling, key = game pal key, so the files can become `game/assets/img/pals/<key>.png`:
| file prefix | game key | calling | rarity | quirk |
|---|---|---|---|---|
| acorn-nip | mw-acorn-nip | seedkeeper | common | spare acorn forgotten in its cap |
| husk-hopper | (maizehollow) mh-husk-hopper | bloomcaller | common | husk leaf worn as a hat |
| bark-badger | mw-bark-badger | rootwarden | uncommon | bracket mushroom on its back |
| fourwind-finch | mw-fourwind-finch | wayfinder | uncommon | four compass tail feathers |
| samara-spin | mw-samara-spin | thornblade | rare | spinning maple key, thorn-edged wing, hovers |
| sap-drip | mw-sap-drip | brewroot | common | tiny fly stuck in its middle |
Files: `<name>-perch|yard.{lua,aseprite,png}`; each .lua loads `_common.lua` (scaled helpers) and `<name>.def.lua` (the drawing, 64-grid, shared by both sizes; perch drops fine detail and uses eyeSmall, yard uses eyeLocked). HP.assertClean passes on all 12. Not eyeballed or iterated; not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <name>-perch.lua`.

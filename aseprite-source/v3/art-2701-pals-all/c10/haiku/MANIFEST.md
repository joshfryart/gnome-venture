# Puzzle Pals chunk c10, Haiku first pass

Eight pals from `worklist.json` index 10, drawn in Aseprite Lua in the Hearth Pop style. Quick pass, no fix round.
Sizes: yard 64x64, perch 36x36 (hand-built at that size, not a downscale). Yard uses `c:eyeLocked`, perch uses `c:eyeSmall`.
Shared helper `_haiku.lua` is a copy of the Haiku helper (lib path unchanged, plus an `O.H` hash-noise helper).
Every sprite passes `HP.assertClean` (0 semi-transparent px, 0 pure black or white, 0 isolated px).

| key | name | rarity | calling | design | quirk |
|---|---|---|---|---|---|
| pl-cnd-5 | Nest Wobble | uncommon | bloomcaller | twig nest with an egg face on a cloud | a loose twig swings off the cloud edge |
| pl-cnd-6 | Grand Condor Plume | rare | thornblade | giant condor feather with gold quill and trim | wind dashes trail off the left side (it still floats) |
| pl-owl-1 | Pinfeather Hush | common | seedkeeper | soft brown feather with a face | cream hush line rises from the tip |
| pl-owl-2 | Nightglow Fleck | common | wayfinder | moon-chip disc with craters | cream glints off the fleck |
| pl-owl-3 | Aurora Thread | common | bloomcaller | banded green and purple yarn ball | green and purple tassels |
| pl-owl-4 | Owlet Peep | uncommon | thornblade | sleepy owlet, lids down, double ear tufts | peep marks off the beak |
| pl-owl-5 | Snowcrag Halo | uncommon | rootwarden | snow mound with a hollow | aurora arc over the hollow |
| pl-owl-6 | Great White Plumelet | rare | wayfinder | fluffy white plume with aurora-dipped tips | aurora tips and sparkles |

Files: `<key>-yard.{lua,aseprite,png}` (64x64) and `<key>-perch.{lua,aseprite,png}` (36x36) for each key.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.
Not copied into game/.

Weakest / edge cases: pl-cnd-6 yard runs to the top-left edge (0 px left margin); pl-owl-6 and pl-owl-3 perch and pl-owl-5 perch touch the bottom edge (0 px margin). Owl-6 yard eyes sit on a white plume (low contrast against the cream eye disc). Quick pass, not visually reviewed in a contact sheet.

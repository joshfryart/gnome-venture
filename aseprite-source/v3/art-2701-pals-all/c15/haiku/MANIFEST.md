# Puzzle Pals chunk c15, Haiku quick pass (art-2701-pals-all/c15/haiku)

Eight pals from `../../worklist.json` index 15 (the pl-jdf and pl-bjq picture families). Each pal is a yard
sprite (64x64, `c:eyeLocked`) and a hand-drawn perch sprite (36x36 at its own size, `c:eyeSmall`, on a wooden
ledge). 16 sprites as `.lua` + `.aseprite` + `.png`. Built on `lib/hp.lua` through a small helper `_h.lua`
(own file, nothing copied from other pal folders). Every sprite passes `HP.assertClean` (0 semi-transparent,
0 pure black/white). Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | rarity | calling | design | quirk |
|---|---|---|---|---|---|
| pl-jdf-3 | Jade Shimmer | common | rootwarden | sea/moss faceted gem-blob | sun sparkles off its corners |
| pl-jdf-4 | Jadewing Quartet | uncommon | thornblade | small green head, four sky wing bits in an X | one wing lags behind |
| pl-jdf-5 | Lantern Eye Pair | uncommon | rootwarden | dusk-iron lantern, gold window, two eyes | glint when the dragonfly flies |
| pl-jdf-6 | Lotus Perch | rare | bloomcaller | pink lotus with a face in the cup, gold stamens | jade dragonfly naps on a petal, ink notes |
| pl-bjq-1 | Tentacle Wisp | common | seedkeeper | pink bulb head on a swaying tentacle | ink music notes off the head |
| pl-bjq-2 | Clownfish Peek | common | rootwarden | ember fish with cream stripes peeking over pink coral | coral hides the lower half |
| pl-bjq-3 | Bell Bead | common | bloomcaller | blue bell with gold clapper on a hook | cream sound ticks on both sides |
| pl-bjq-4 | Gold Spike Tiara | uncommon | thornblade | four gold spikes over a heap of sea/sky bubbles | a face peeks out of the centre bubble |

Weak spots (quick pass, not reviewed by an Opus pass): pl-bjq-2 coral mound is large and blobby at 64 px; the
clownfish perch is the same mound at small size; pl-jdf-4 wings are plain sky with one vein each; pl-jdf-5 has
no halo, so the glow reads only through the sparkles.

# Puzzle Pals c06, Haiku first pass (art-2701-pals-all/c06/haiku)

Quick single pass, Hearth Pop style, drawn in Aseprite Lua with the v3 lib (`v3/lib/hp.lua`).
Sizes: yard 64x64, perch 36x36 (hand-built at that size, not a downscale).
Yard uses `c:eyeLocked`, perch uses `c:eyeSmall`. Every sprite passes `HP.assertClean`
(0 semi-transparent, 0 pure black or white). Not copied into game/.

Shared helper `h06.lua` (output paths, finish, save). Run:
`AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (same for `-perch`).

| key | name | rarity | calling | shape / knob | design | quirk |
|---|---|---|---|---|---|---|
| sp-chilli-chime | Chilli Chime | common | brewroot | inner-TBTB / peg | round moss-green pal, chilli garland with gold bells | sound ticks beside the bells |
| sp-stupa-snug | Stupa Snug | uncommon | rootwarden | inner-TTTT / double | dusk-violet pal under a white stupa dome, gold spire | prayer flags pegged on one string |
| sp-teal-ferry | Teal Ferry | uncommon | thornblade | inner-TTBB / hook | teal pal in a wood ferry boat with a flower, waving | gold fish waving from the river |
| sp-lofty-kite | Lofty Kite | rare | wayfinder | whimsy-kite / tri | sea-blue diamond kite, gold frame and spar, three ribbon tails | eyes low on the diamond, looking down |
| br-petal-pinch | Petal Pinch | common | bloomcaller | corner-TT / round | round pink pal, wood pocket of petals, one petal held up | falling petal at top left |
| br-koi-kin | Koi Kin | common | seedkeeper | edge-TBT / keyhole | orange koi with gold patch, fins and tail, in a pond | two smaller orange cousins in the pond |
| br-panda-puff | Panda Puff | common | brewroot | inner-TTTB / peg | fluffy peach-cream panda with dark ears and patches, bamboo stalk | the stalk is bitten at the top |
| br-pagoda-pin | Pagoda Pin | uncommon | rootwarden | inner-TTTT / double | three-tier pagoda with ember roofs, gold spire | arm points straight up at the spire |

Files per key: `<key>-yard.{lua,aseprite,png}` (64x64) and `<key>-perch.{lua,aseprite,png}` (36x36).

Weakest: lofty-kite perch is thin, panda fur reads peach rather than white (kept as a quick-pass palette choice),
koi cousins are small blobs at yard size, teal-ferry and koi water bands run full width to the edge (no margin).
Quick pass, no fix round.

# Puzzle Pals chunk c13, Haiku first pass (art-2701-pals-all/c13/haiku)

Single-pass drawings of worklist.json index 13: 8 pals, each a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, `c:eyeSmall`) as `.lua` + `.aseprite` + `.png`. 16 sprites total. Built directly on `v3/lib/hp.lua` (own scripts, no copies of other pal folders). `HP.assertClean` passes on all 16. Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | rarity | calling | shape / knob | yard design | quirk |
|---|---|---|---|---|---|---|
| pl-sbs-5 | Dewweb Eye | uncommon | bloomcaller | inner-BBBB / hook | round silk web-disc, dusk hole for the face, six dew beads | dew drop falling off the lower right |
| pl-sbs-6 | Silverback Spool | rare | seedkeeper | whimsy-spider / peg | spool barrel with wood ends, gold ferrules, spider legs | two music notes drifting off the top right |
| pl-gwk-1 | Fang Chip | common | thornblade | corner-TT / hook | ivory fang with a chipped notch, growl mouth | small moon in the top left |
| pl-gwk-2 | Pawprint Cuff | common | rootwarden | edge-TTB / double | puffy snow cuff, cheeks, sparkle | pawprint pressed into the lower right |
| pl-gwk-3 | Moonpale Mantle | common | seedkeeper | inner-TBTB / peg | night-blue draped cloth, pale moon on the front | pale glow ring round the moon |
| pl-gwk-4 | Crown Points | uncommon | thornblade | inner-TTTT / tri | gold crown band with four sharp points | petal-pink jewels at both band ends |
| pl-gwk-5 | Howl Echo | uncommon | rootwarden | inner-TTBB / hook | rounded sea-blue howl, open mouth | two echo rings, each smaller, off the top right |
| pl-gwk-6 | Grey Wolf Whistle | rare | wayfinder | whimsy-wolf / double | silver wolf-head whistle, gold ear tips and collar seam | sound ticks at the snout |

Pals of this set differ in species and prop: the two rings (Dewweb Eye, Howl Echo) differ in body (web disc vs round howl with echo arcs); the two cloth pals differ in shape (tall cuff pillow vs draped mantle); the two seedkeepers differ in body (spool vs mantle).

Known weak spots (first pass, for the Opus passes): pawprint on the cuff reads as a grey blob at 50%; perch spider legs on the spool are one px and faint; Crown Points perch points are small; Dewweb Eye yard beads are 2x2 and may vanish at 25%.

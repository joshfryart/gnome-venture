# Puzzle Pals chunk c12, Haiku first pass (art-2701-pals-all/c12/haiku)

Quick first pass on worklist.json index 12: 8 pals, each a yard sprite (64x64) and a perch sprite (36x36, hand-drawn at its size, not a downscale). 16 sprites as `.lua` + `.aseprite` + `.png`. Built on `v3/lib/hp.lua` directly (no Opus helper). Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | rarity | calling | shape | quirk |
|---|---|---|---|---|---|
| pl-cwy-3 | Scorch Sliver | common | rootwarden | inner-TBBB | smoke curl off the tip |
| pl-cwy-4 | Spine Spark | uncommon | thornblade | inner-TTTT | sparkles on the spike tips |
| pl-cwy-5 | Ash Wreath | uncommon | rootwarden | inner-BBBB | unlit ember in the hollow |
| pl-cwy-6 | Last Forge Flame | rare | wayfinder | whimsy-flame | dragon in a thought bubble |
| pl-sbs-1 | Silkthread Tuft | common | seedkeeper | corner-TT | dangling sticky strand |
| pl-sbs-2 | Web Snag | common | wayfinder | edge-BTB | hat snagged on the web |
| pl-sbs-3 | Buttress Tangle | common | rootwarden | inner-TBTB | hollow under the knot |
| pl-sbs-4 | Eightlegs Clasp | uncommon | thornblade | inner-TTTT | raised wiggling leg |

Checks: `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). Pal-level palettes are the Hearth Pop ramps, except a custom silk ramp for pl-sbs-1 (off-palette pixels reported, not an error). Eyes: yard `eyeLocked`, perch `eyeSmall` only. Not copied into game/. Not a finished pass: no Opus polish, no closer-look details beyond the quirk.

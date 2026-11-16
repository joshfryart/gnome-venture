# Puzzle Pals chunk c01, Opus richness pass (art-2701-pals-all/c01/opus3)

This pass builds on `../opus2/` for chunk 1 of `../../worklist.json` (list index 1). There are 8 pals, each with a
yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, drawn at its own size, `c:eyeSmall`). That makes 16
sprites, each saved as `.lua`, `.aseprite` and `.png`. Concepts, silhouettes and quirks are the same as in opus2.
This pass adds material texture, hue-shifted 5-6 tone ramps, upper-left light with one lower-right core shade, rim
light, bounce light and small secondary details. Perches keep fewer, bolder details than the yards. The style is a
sibling of `art-2701-batch3/pals/opus3`. `HP.assertClean` passes on all 16: 0 semi-transparent pixels and 0 pure
black or white pixels, and every PNG has only alpha 0 or 255. Nothing was copied into game/.

`_opus.lua` is the opus2 helper with three additions:
- `O.pits`: porous cup texture. Each cup has a dark upper-left lip and a lit lower-right wall.
- `O.blendN`: mixes two normal fields.
- `O.rows`: paints pixel rows.

To render a sprite, run `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

## Weaknesses from opus2, now fixed
- **rr-hammock-hush perch:** the dense eye patches are now a 1 px sloth stripe that runs outward and up from each pill. The pills and the cream mask read cleanly at 1x.
- **rr-highland-ring perch:** the hole is now a taller, rounded arch ringed by stone. It has a dark inner arch at the top and a lit sill at the bottom. The snow cap sits above the arch, with drips only on the outer shoulders.
- **mm-skerry-seal (yard and perch):** the uninvented fish reads at 1x now. On the yard it is a bigger dashed outline (2 on, 1 off) with a forked tail, a fin and an eye. On the perch it is a bold 9x5 outline with two gaps.
- **mm-kite-knot perch:** the huff puff moved left and down, so there is air between it and the kite.

## Per pal

| key | richness added (yard; perch gets the bold subset) | quirk |
|---|---|---|
| ss-coral-cuff | Hue-shifted coral ramp. The cylinder light was moved so the core shade sits off the face centre. Polyp-cup texture, a lit lip ring, a twisted two-strand gold braid with a sea-glass clasp, a starfish on the lit side, barnacles in the shade, a pearl in the cuff, pink anemone tips and bubbles. | clownfish behind the sea fan |
| ss-lagoon-loop | An inner sand wall gives the hole depth, with a wet shadow line. The water bands follow the bowl. Added coral heads under the water, caustic ripples, the palm's reflection, wind ripples and pebbles in the sand, toes, a crab peeking over the rim and a message bottle. | palm islet (the glint still winks) |
| rr-hammock-hush | Fur hangs in downward strands, lit on the upper-left and dark in the shade. Added algae flecks, a twill weave and stripe seams on the hammock (the old checker is gone), tassels, bark grain and a knot. A sloth moth hides in the fur. | thought cloud with three dots |
| rr-bromeliad-bolt | Red-blushed leaf tips, spines with dark teeth, lapped sheath seams (dark edge with a lit lip), wavy silver scurf bands kept off the face, bark lines on the root feet, a drip on the cup lip, a tadpole in the cup, and a frog with real red eyes, pupils and a pale throat. | thirsty tree frog |
| rr-highland-ring | The granite is now a warm violet-grey, so it separates from the cool snow. Added feldspar, biotite and mica flecks, hairline cracks, lichen on the shaded side, a blue cast shadow under the snow hem, a dark inner arch, a lit sill and snow sparkles. | summit flag |
| mm-skerry-seal | Ringed harbour-seal spots, a wet sheen on the back, pale whiskers, cracks and a wet band on the rock, mussels and a limpet, ripple dashes, a lighthouse door and two lamp-beam ticks. | the uninvented fish, now readable |
| mm-peat-sip | Each brick has its own tone and fibre streaks. Added an eave shadow, grass tufts on the turf, a sod edge with roots and a drooping fringe, soot on the chimney, an ember glow in the flue, and a tiny steaming teacup by the right foot. | smoke curling into a music note |
| mm-kite-knot | The dotted weave was replaced by a ripstop thread grid kept off the face. Added fold ridges beside the spars, a stitched hem, spar tips at the corners and a teal patch sewn over a tear. | the tail tied in a big pink bow |

## Weakest
- ss-coral-cuff yard: the barnacles read as small grey nubs, not clear cones.
- ss-lagoon-loop yard: the crab on the rim is a small red blob. At 1x it reads as "something red", not clearly a crab.
- rr-hammock-hush yard: the sloth moth is only a few pixels and is easy to miss. That is intended, but it may be too subtle.
- rr-highland-ring perch: the top is a little boxy because of the new thick snow mound.

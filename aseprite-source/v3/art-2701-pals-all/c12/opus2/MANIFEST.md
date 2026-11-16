# Puzzle Pals chunk c12, Opus second pass (art-2701-pals-all/c12/opus2)

Second pass on worklist.json index 12, built on `../haiku/` (same keys, names, callings, concepts). 8 pals, each a
yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16
sprites as `.lua` + `.aseprite` + `.png`. Style matches `c00/opus3` and `art-2701-batch3/pals/opus3`: 5-6 tone
hue-shifted ramps, upper-left light, rim light + cool bounce, material texture via `O.tex`, 1px ink `#2b1c26`, one
quirk from the blurb plus a smaller closer-look detail. `_opus.lua` is an unchanged copy of the c00/opus3 helper.
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | what it is now | haiku problem fixed | quirk / closer look |
|---|---|---|---|---|
| pl-cwy-3 | Scorch Sliver | slim leaning wyrm-scale shard, three hard facets with a bright ridge, soot-charred base | read as a leaf or pepper, flat red | smoke curl off the point / one hot crack in the char |
| pl-cwy-4 | Spine Spark | quenched blue steel ball on stubby feet, four spikes in temper colours (blue, violet, bronze, straw) | red blob with yellow horns (devil read, same red as cwy-3) | upper-right spike popping in a sparkler burst / hammer dimples |
| pl-cwy-5 | Ash Wreath | wreath of twisted burnt twigs in cool ash grey, charred twig ends, thick lower rim carries the face | plain grey ring (tyre), face floating in the hole | unlit matchstick tucked in the top like a candle / one last ember in the ash |
| pl-cwy-6 | Last Forge Flame | low round flame curled like a sleeping cat in an iron forge dish on coals, tail tongue wrapped round, edge-in heat toning, half-lidded drowsy eyes (rare: sparkles) | upright flame on a red puddle (candle/ketchup), yellow core killed eye contrast | dream bubble with a tiny violet dragon / hot cracks in the coals |
| pl-sbs-1 | Silkthread Tuft | wide fluffy silver-lilac silk tuft, spiral spun strands, loose thread loop on top, worried brows and wobbly mouth | flat grey cloud with antennae | a leaf stuck to its flank / sticky thread with a glossy bead |
| pl-sbs-2 | Web Snag | torn web scrap hanging from a twig, silk-knot hub carries the face, thin un-outlined radial threads and broken rungs, a thick hook-thread arm | blue disc + unreadable purple blob | red gnome hat hanging on the hook, held out to hand back / dew bead on a rung |
| pl-sbs-3 | Buttress Tangle | two flared buttress roots arching over a dark hollow, big cream wound-silk ball in the mouth with thread arms out to the roots | yellow ball between brown cones (sun on hills) | acorn stash peeking out of the dark / tiny red mushroom at the root foot |
| pl-sbs-4 | Eightlegs Clasp | silverback spider from the front clasping a twig: silver abdomen with plum chevron, thick jointed plum legs fanned at different knee heights | flat purple spider, tangled legs, no clasp | back right leg up and wiggling / six tiny extra eyes above the big two |

Family check: cwy-3..6 are a red shard, a blue steel spike-ball, a grey twig wreath and an orange curled flame in a
dish (none share species, palette or pose; also clear of cwy-1 cinder flake and cwy-2 slag drip). sbs-1..4 are a
cool lilac fluff tuft, a pale blue hanging web knot, a warm cream wound ball in a root arch and a plum/silver spider
(clear of sbs-5 web disc and sbs-6 spool).

Weak spots left: sbs-1 thread loop can read as a bag handle; sbs-3 perch acorn is only a few pixels; sbs-4 perch
legs are busy at 1x; cwy-6 yard dragon is small (readable at 2x and up).

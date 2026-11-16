# Puzzle Pals c08, Opus second pass (art-2701-pals-all/c08/opus2)

Eight pals from worklist.json index 8, redrawn from the Haiku first pass in `../haiku/`. Same keys, names, callings
and concepts; style matches `art-2701-batch3/pals/opus3/` and `art-2701-opus/pals/`. Yard 64x64 uses `c:eyeLocked`;
perch 36x36 is hand-built at its size with `c:eyeSmall` pills. Every script draws its own shapes with `_opus.lua`
(copy of opus3's helper: per-pixel light, rim light, bounce, texture). `HP.assertClean` passes on all 16
(0 semi-transparent, 0 pure black/white). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | rarity | fixed | quirk |
|---|---|---|---|---|
| cs-snorkel-snip | Snorkel Snip | common | gold balls are now real shells (ribbed scallop, spiral whelk); J-tube snorkel with mouthpiece; dive mask on the brow; teal flippers | bubbles rising from the snorkel |
| cs-octo-ogle | Octo Ogle | common | stick legs became tapering, hooked tentacles with suckers; spotted mantle; trinket is a gold ring with teal gem held up at eye height | the gold ring it ogles, twinkling |
| cs-anemone-nudge | Anemone Nudge | common | blob became a bubble-tip anemone (lilac tentacle crown, grooved coral column, reef stone); clownfish has fins, tail, eye, ink-edged bands | a long tentacle nudges the clownfish's tail |
| cs-claw-sail | Claw Sail | uncommon | flag became a true crab-claw sail (curved V spars, concave top, seams); crab rides a carved outrigger canoe on lapping sea | huge grin with a row of teeth |
| cs-grotto-glim | Grotto Glim | uncommon | snowman stack became a rearing segmented glowworm with teal glow spots, lantern tail, glow-bead antennae | "ooh" mouth at silk threads of glow beads (yard top margin 0 on purpose: threads hang from the roof) |
| cs-keel-drift | Keel Drift | rare | land turtle became a sea turtle (paddle flippers, plastron, scutes with lit plate edges); gold-trimmed rim, barnacles, weed tuft; head turned to us | the slow wink |
| pl-frt-1 | Rime Crumb | common | round blob became cut-gem ice (flat toned facets, ridge bevels, crown shards, crack, frozen flecks); feet joined to the body; wide toad mouth | each croak puffs a frost cloud and a snowflake |
| pl-frt-2 | Puddle Croak | common | gumdrop frog became a warty frost toad (parotoids, frosted warts, heavy lids) sunk in an ice-rimmed puddle; real eighth notes | humming a lullaby with a closed smile, notes drifting up |

Weakest: Claw Sail perch eyes sit low on short stalks (readable but tight); Octo Ogle tentacles sit close together
at 36 px; Keel Drift yard plastron is a plain pale band.

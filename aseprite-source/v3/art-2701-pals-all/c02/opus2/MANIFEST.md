# Puzzle Pals chunk 2, Opus second pass (art-2701-pals-all/c02/opus2)

Chunk 2 of `../../worklist.json` (Olivewhistle / Birchbramble), redrawn on top of the Haiku first pass in `../haiku/`.
Same concepts, keys, callings and quirks (one quirk per pal, from its blurb). Siblings of `art-2701-batch3/pals/opus3/` and `art-2701-opus/pals/`.
Sizes: yard 64x64 (`c:eyeLocked`), perch 36x36 hand-built at its own size (`c:eyeSmall`, fewer, bolder details).
Files: `<key>-yard|perch.{lua,aseprite,png}` (48 files). `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). Not copied into `game/`.
`_opus.lua` = opus3 helper plus `O.retone` (repaint part of a lit mask from another ramp at the same tone index: net mesh, glaze bands, countershading). `_tools/run.sh` runs scripts, `_tools/sheet.py` makes contact sheets.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | rarity | design | Haiku weak spot fixed | quirk |
|---|---|---|---|---|
| ow-net-nudge | common | round sea-teal pal, net worn as a hood gathered into a round cork float (round knob), red float hem, netting needle tucked in | lattice covered the whole body (checked ball); now open mesh on the crown only, clean face | red fish being nudged along by its flipper |
| ow-olive-pip | common | glossy olive with waxy bloom, stalk + two lanceolate silver olive leaves (double knob), arm hugging a gnarled olive tree | grass-blade ears; perch tree touching the body; now real olive leaves and tree, 2 px clear | red heart carved into the tree's bark |
| ow-jar-hum | common | terracotta amphora: rolled lip, slit loop handles, cream wave-band shoulder, ring foot, cork with wooden peg (peg knob), humming "o" | read as a potion flask; hum was 2 px dots; now amphora + gold music notes | tiny oil jar beside it humming back |
| ow-sun-glint | uncommon | gold sun disc dipping into a sea strip, three fat cream-tipped crown rays (tri knob) + side rays in their own amber ramp, gold reflection path | 7 colours, thin rays; now 6-tone ramps, fat rays with a seam | mid-wink, a sparkle popping off the closed eye |
| ow-press-ring | uncommon | upright granite millstone, hole set high, two stone nubs (double knob), oak press lever through the hole with an iron band | lever faint, drip 1 px; now warm 4 px oak beam, 2 px oil run | golden oil runs from its lip, fat hanging drop, gold puddle |
| ow-harbour-leap | **rare** | countershaded dolphin in a high arc over a block breakwater, big head with full eye, gold hook-tipped dorsal fin (hook knob), splash crown, sparkles | thin head, tiny eye, dot splash; now a big head and real splash | red buoy marking the exact landing spot |
| bb-slushbelly | common | icy granular slush blob slumping into its meltwater puddle, snowball knob (round) with a sunflower seed in it, shy sideways eyes, worried brows | eye-drip lost at small size; now drips bulge past the silhouette (outlined) + falling drop | melting while you look: side drips and a falling drop |
| bb-gander-gait | common | plump cream-white gander mid-march, thick S-neck, big head, orange beak, keyhole crest tuft (keyhole knob), scalloped wing, one foot raised | thin neck, small head, 2x2 dot chicks; now thick neck, real goslings | goslings marching behind in a line (yard: three, last one out of step) |

Weakest: ow-harbour-leap splash crown on the left is a soft teal blob; bb-gander-gait perch pill eye sits small in the head (standard 2x3);
ow-press-ring perch hole is crowded by the lever; ow-olive-pip canopy olives are only dark dots; ow-net-nudge mesh is subtle at 1x (reads as a lighter hood).

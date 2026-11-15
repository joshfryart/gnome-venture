# Puzzle Pals batch 3, Opus richness pass (art-2701-batch3/pals/opus3)

Third pass, built on `../opus2/` (each script starts from its opus2 twin; Haiku first pass in `../haiku/`). Same 8 pals,
game keys, callings and quirks; siblings of `../../../art-2701-opus/pals/`. Goal: richer without losing silhouette or
readability. Yard 64x64 uses `c:eyeLocked`; perch 36x36 is hand-built at its size with `c:eyeSmall` pills and fewer,
bolder details than the yard. `HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white). Not copied
into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <name>-yard.lua`.

`_opus.lua` = opus2's helper plus three richness tools:
- `rim=true` on `O.shade/O.shadeN`: silhouette pixels facing the upper-left light go one tone up (rim light).
- `bounce="#hex"` (+ `bmax`): silhouette pixels facing lower-right that sit in the dark tones get a cool bounce colour.
- `O.tex(c, idx, tok, ramp, f)`: re-tones a lit part by ramp steps (fur, grain, flecks, strands), so texture keeps the lighting.

| pal | richness added | weakness fixed | closer-look quirk |
|---|---|---|---|
| toadstool-tuck | sparse cap freckles, wart cast shadows, cap rim light, fanned gills, stem fibres + cool bounce, frilly annulus skirt | cap 2 px higher, cap-shadow band narrowed: two lit stem rows above the locked eyes plus a brow line (no longer tucked under the gills) | one fairy-ring mushroom is a red baby Tuck with eyes open (perch: red baby cap) |
| kapok-nook | combed silky strands in the floss, floss rim light, speckled pod skin with lit lip and bounce, bark flecks + bounce | perch: full 2x3 pills now show; sleepiness moved to a dark lid arc above each pill | lit round window above the castle door, red welcome mat on the step |
| shell-skip | axial growth ribs on each whorl, band flecks, shell rim + violet bounce, pebbly carapace, pale leg-joint bands, barnacle on the spire | (none listed) | a tiny bubble trapped in the sea-glass bead |
| stone-sentry | granite feldspar/mica flecks (thinned round the face), bedding line, rim + sky bounce, lit moss tufts, a sprout, un-outlined puddle | (none listed) | one drizzle drop has landed on its pebble nose |
| mate-mumble | toasted mottling, burnt-in zigzag + dot band, rim + plum bounce, engraved rim ticks, yerba stalk bits, straw rim | (none listed) | a stray yerba leaf stuck to its cheek |
| glimmer-frog | skin freckles + granular bumps, head/thigh rim light, teal bounce, granular belly | (none listed) | one glow spot on its thigh is a tiny llama (it croaks about llamas) |
| cocopaddle | hairy coir strokes, hull bounce, mast grain, lit leaflet edges, two-plane sea with wave lines and foam caps | swell rebuilt: back swell wider than the hull with a rolling crest, front wave laps the hull foot and swallows the blade (perch too; perch grin raised 1 px above it) | the bottle's rolled note is tied with a red ribbon |
| gatepost-hoot | crown streaks, scalloped feather rows, wing primaries, rim + bounce, end-grain rings, post lichen | perch: wider heart disc (two 4 px lobes), pill eyes 7 px apart in dark sockets, beak between, ridge line | a sheep tally (four strokes and a slash) scratched into the post (yard only) |

Weakest: shell-skip yard (the growth ribs read more as sand grain than as ribs); glimmer-frog llama spot is only
recognisable at 4x and up (intended as a find, but partly overlapped by the thigh edge); cocopaddle perch grin sits
1 px above the wave crest, tight; kapok-nook perch lid arcs can read slightly skeptical rather than sleepy.

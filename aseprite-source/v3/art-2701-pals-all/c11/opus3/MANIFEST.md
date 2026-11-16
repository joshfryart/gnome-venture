# Puzzle Pals chunk c11, Opus richness pass (art-2701-pals-all/c11/opus3)

Richness pass on chunk 11 of `../../worklist.json` (Dragonlizard Den + Forge of the Cinder Wyrm), built on `../opus2/`.
8 pals. Each has a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-drawn at that size, `c:eyeSmall`
pills), so 16 sprites, each as `.lua` + `.aseprite` + `.png`. Keys, names, callings and concepts are unchanged. The six den
pals are still six different species. These are siblings of `c00/opus3` and `art-2701-batch3/pals/opus3`: 5-6 tone
hue-shifted ramps, light from the upper left, one lower-right shade, rim light, bounce light, and material texture.
`_opus.lua` is the opus2 helper plus one tool, `O.bumps`: raised beads drawn as a lit pixel with its shade pixel to the
lower right, used for scales, granules, hammer pits and limestone pits.
`HP.assertClean` passes on all 16: 0 semi-transparent pixels, 0 pure black/white, 1px ink `#2b1c26`. Nothing was copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|
| pl-dlz-1 Scalecrust Tot | bead scales on head, body and tail; crust plates with a crackle line and a lit lip; deep throat in the laugh; cool bounce | - | an older flake already lies on the ground by its foot |
| pl-dlz-2 Tongue Flicker | granule beads, ridged casque, saw-tooth crest, bark grain and node, leaf midribs, sticky pad on the tongue tip | busy body texture is now sparser beads | it is colour-matching: the toes gripping near the blossom have gone pink |
| pl-dlz-3 Tail Tick | plum-to-butter 6-tone ramp, tubercle beads, leopard rosettes (dark ring, warm core), brow beads, lit band lips on the tail, slab lichen | gecko body was flat in tone (lower ambient, so the form now turns) | a pale worn dent on the pebble where the tail always hits; a seed by the slab |
| pl-dlz-4 Diamond Spur | pebbly beads, pale fringe spines each with its own shadow, horn growth rings, brow spikes, darker gem sockets | - | it copied its pattern: three tiny pale diamonds run down its tail |
| pl-dlz-5 Karst Yawn | limestone pits with lit lips, lichen, root hairs, wet sheen on the lower lip, rim and bounce on the feet | scratchy fern is now one clean tapering frond cut into paired leaflets, with a pale rachis | a water drop forming on a stalactite (plus the sleeping bat) |
| pl-dlz-6 Mossback Monitor (rare) | bead scales, ocellus rosettes (cream ring, dark eye), pale jaw line, forked tongue tip | small yard head is now much bigger, the moss cushion smaller and the smile clear; perch head enlarged to match | dewdrop on the curled leaf tip; a third toadstool only a button poking up |
| pl-cwy-1 Ember Flake | bevelled crust plates (ash-lit upper-left lip, dark lower-right lip), warm red cast beside the cracks, white-hot junctions, ash flecks, warm ember bounce | - | a tiny flame flickering out of a crown crack, like a candle it forgot to blow out |
| pl-cwy-2 Slag Drip | hammered iron, lit top bevel, domed rivets, iron glowing dull red under the slag, cooling crust flakes on the neck, warm bounce, puddle ripples | dithered red base is now a solid wavy band | a bubble rising in the bulb, and the drip's glow reflected on the beam's underside |

Perches keep fewer, bolder marks than the yards: sparse beads, the same ramps, rim and bounce, and the key quirk.
The ember flake perch keeps its pale ash face plate so the eyes read.

Weak spots left:
- The dlz-2 yard eye-turret rings are mostly hidden by the locked eye disc.
- The dlz-6 yard legs and body read a little busy where the bead scales and rosettes meet.
- The cwy-1 perch's orange crack glow is large around the face sides.
- The toadstool button (dlz-6), the water drop (dlz-5) and the tail diamonds (dlz-4) are only a few pixels, by design.

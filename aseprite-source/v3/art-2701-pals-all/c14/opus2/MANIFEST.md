# Puzzle Pals chunk c14, Opus second pass (art-2701-pals-all/c14/opus2)

Second pass on chunk 14 of `../../worklist.json` (Lair of the Hurricane Crab, Lair of the Jade Dragon-fly), built on `../haiku/`.
8 pals, each a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, drawn at that size, `c:eyeSmall` pills): 16 sprites as `.lua` + `.aseprite` + `.png`.
Same keys, callings and concepts as haiku. The look matches c00/opus3 and batch3/opus3: 5-6 tone hue-shifted ramps, light from the upper left, rim light and a cool bounce, one quirk from the blurb plus one smaller detail you notice on a closer look.
`_opus.lua` is the c00/opus3 helper, copied unchanged (tools only).
`HP.assertClean` passes on all 16: 0 semi-transparent pixels, 0 pure black or white, 1px ink `#2b1c26`. Nothing was copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | second-pass design | haiku problem fixed | quirk / closer look |
|---|---|---|---|---|
| pl-hcr-1 | Lightning Pinch | the pal is a single lightning crab pincer: a fat palm with the face, a hooked upper finger and a lower finger opened wide with serrated edges, balanced on a zigzag bolt | was a gold ball holding two blue mitts | snapping at a sneeze puff, with sparks across the jaws / thornblade frown, and the bolt scorches the ground |
| pl-hcr-2 | Shell Splinter | a broken piece of orange crab carapace: the smooth old rim on the upper left, straight broken facets that show the pale shell thickness, dark red spots, two stub legs | was a flat red pentagon that read as a pepper | mid-rattle: shake ticks, a chattering zigzag mouth, a loose crumb hopping beside it / an old scratch, a gust curl |
| pl-hcr-3 | Gust Ribbon | one long leaf ribbon chasing its own tail round a loop; it twists at the top to show its pale underside and ends in a pointed leaf head with a midrib and veins | was a green hood around a blue face plate | a dashed wind loop inside the ring, with flutter ticks / a bite notch in the ribbon edge |
| pl-hcr-4 | Whirl Pincer | four jointed crab arms curling the same way round a sandy carapace hub, each ending in an open pincer with dark tips | was four straight sticks (it read as a jack or a molecule) | swish arcs trail the spin / belly-plate seams on the hub, one chipped fingertip |
| pl-hcr-5 | Eye of the Storm | a small hurricane seen from above: a storm-cloud ring with three spiral arms and swirl grooves, a shadowed eye wall, and a calm blue eye that holds the face | was a flat grey tyre | a tiny pink flower floating still in the calm eye / loud-wind streaks outside |
| pl-hcr-6 | Gale Islander | a coral pocket crab with raised claws and three legs a side, carrying a sand island with a foam-ringed shore and two ringed palm trunks whose fronds and coconuts all blow one way | the palms were 1px sticks, and the island was a hat | the palms bending over in the gale / a starfish on the beach |
| pl-jdf-1 | Wing Jot | a tilted flake of jade dragonfly wing: dark leading-edge vein, long veins and cross-veins making cells, a glass glint, a jagged root, the face in one large clear cell | was a faceted blue gem | hum rings over the tip and a dotted drift trail / an amber pterostigma near the tip |
| pl-jdf-2 | Reedleg Cling | a jade dragonfly nymph (bulging eyes, wing-padded thorax, banded abdomen with three tail spikes) holding two golden reeds with three jointed legs a side; a cattail sits on the right reed | was a brown egg with 1px stick legs | claws dug in, reeds bowed toward it, a bead of effort sweat / a dewdrop on the left reed |

How the pals in each picture differ:
- Hurricane Crab: a yellow lightning claw on a bolt; a domed orange shell fragment with a broken edge; a green leaf ring; a red four-arm pinwheel; a grey cloud spiral; a coral crab carrying an island.
- The crab pals use different species, colours and poses. Lightning Pinch is one claw. Whirl Pincer is four arms on a hub. Gale Islander is a whole crab carrying an island.
- The ring pals differ too. Gust Ribbon is a leaf with its face on the leaf head. Eye of the Storm has its face in the hole of a cloud ring.
- Jade Dragon-fly: a glass wing fragment, and a whole nymph on reeds.

Weak spots that remain:
- Wing Jot is the weakest read. Its vein network can look like crackle glass rather than a wing, and its perch face sits on a narrow body.
- The Whirl Pincer perch pincers are only a 1-2 px notch.
- The Shell Splinter shading bands step diagonally across the dome.
- The Gale Islander perch claws touch the shell sides.
- The Lightning Pinch sneeze puff is small and reads as a pale cloud only up close.

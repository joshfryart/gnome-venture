# Stop looks, Maplewold style: Opus third pass, richness (art-2701 batch 3)

This pass builds on `../opus2/`. It has the same 8 names: mill, shrine, jetty, herb, workshop, orchard, tower, camp.
Each one is `<type>.{lua,aseprite,png}`: 480x270, native 1x, one layer. All 8 pass `HP.assertClean`: no semi-transparent pixels and no pure black or white. Each picture has 199-259 colours, up from about 110.
To render: `./_run.sh mill shrine ...`, which calls `squashfs-root/AppRun -b --script-param out=<dir>/ --script <type>.lua`. `_zoom.py` makes nearest-neighbour crops for review.
The frame is unchanged: palette, sky bands, clouds, hills, horizon y=112, slab road, gate, bunting, lanterns and the compass corner.

## Frame upgrades (`_frame.lua`, shared by all 8)
- **Depth planes.** Every pixel records its plane (`F.depth(n)`) and its object id. A new id starts at each rim and each depth call.
  - Back row (1) is mixed 30% toward a cool haze `#ecdcd8`.
  - Mid row (2) is mixed 13% toward the same haze.
  - Near row (3) gets an **upper-left rim light**: the first pixel inside each object's dark rim on the top and left is mixed 34% toward a warm `#ffeec0`.
  - The gate is drawn last, as plane 4, and is not touched.
- **Foliage.** Crowns are clumped. Each leaf clump is lit from the upper left and uses 6 tones (glint, hi, base, shade, deep, plus the edge rim). Clumps have dark undersides and the whole crown darkens to the lower right. The gate crowns keep the old flat look.
- **Materials.**
  - Thatch: layered 4 px courses with combed strands, ragged dark lips and sunlit ticks.
  - Plaster: lime-wash streaks and a damp darker base.
  - Timber: grain.
  - `F.planks`: board seams, grain streaks, knots and a lit lip.
  - `F.water`: pale far water, dark lip under the bank, lit ripple pairs and cream glints.
- **Ground.** The ground has a job. Grass tufts grow taller nearer the viewer, and there are fallen maple leaves and pebbles.
- **Gnome.** `F.gnome` is now 28 px and reads at 50%. It has a tall floppy cone hat, eyes, a round lit nose, cheeks, a cream beard, a belted coat, sleeves and hands. It returns the working hand's position, so the scenes put real tools in it. The old 20 px figure is `small = true`, used for far gnomes.
- **Life helpers.** `F.smoke` (rising, drifting puffs that get lighter as they rise), `F.birds`, `F.washing`, `F.hen`, `F.sprite` (hand-placed rimmed pixel sprites used for the animals and quirks), `F.rimLight`, `F.mix` and `F.shift`.

## Per picture
| type | richness added | quirk (now readable at 50%) |
|---|---|---|
| mill | Hazed far wheat and cottage. Chimney smoke column. Plank dock and footbridge. Textured mill pond with a mother duck and 3 ducklings. Hoist gnome hauling the rope. Three hens. Sack-carrier gnome. Flour trail leading to a mouse. Birds. | A big white duck riding the wheel paddle, wearing a red gnome hat |
| shrine | Copper-tile roof channels with moss. Plank hall walls. Basin water with two koi. Incense burner with a smoke curl. Crows on the torii. Gnomes sweeping a leaf pile (with broom), ringing the bell and hanging an ema. | A fox kit posing on the plinth beside the stone fox, wearing the stone fox's red bib (the statue's neck is bare) |
| jetty | Lake depth: pale far water, sandy shallows, deeper near water. Lit ripple pairs that widen with nearness. Glints, lily pads, a leaping fish with rings, gulls. Deck plank grain and pile shadows. Fisher gnome holding the rod. Tar-brush gnome. A tabby cat eyeing the fish basket. Smoke. | A big heron (crest, striped white neck, gold beak) lifting a fish out of the bucket |
| herb | **Lavender fixed.** The rows now run across the view as round bushes with spikes and green furrows, banded by depth (height = d²/C). Rows thinner than 3 px become one solid hazed band, so nothing shimmers. **Hollyhocks** now sway, with big blooms low, smaller ones higher and green buds at the tip. Bees, butterflies, cottage smoke. Two far gnomes in the lavender, a harvest gnome with a basket, a gnome watering with a can. | A ginger tabby curled asleep in a catnip bed with a butterfly on its ear. The opus2 cat sat inside the compass corner and was never visible. |
| workshop | Weatherboard grain on the barn. A real forge smoke column. Gnomes: smith with a raised hammer and apron, carpenter at the bench, sawyer, plank carrier, winch hand. A dog asleep by the forge. Birds. | A robin's nest on the crane beam with three gaping chicks, and the robin arriving with a worm |
| orchard | **Four tree kinds**: round apple, tall pear, wide old spreader, young staked tree with a guard. Red, gold and green fruit, three leaf ramps, random lean. Mown stripes and a shade band under each row. Depth by row. Gnomes: press turner, picker holding a fresh apple, crate packer, a little one on the swing. A pig at the windfalls, a blackbird pecking. | A big hedgehog trundling off with an apple and a leaf on its spines |
| tower | Sandstone, lichen and grey blocks mixed into the coursing, with a big-block plinth. The stone store moved back into the haze, which clears the crowded right middle. Guardhouse smoke and washing line. Gnomes: guard with spear and dog, archer with bow, bell ringer, lookout, a sentry waving from the top. Crows. | A big carrier pigeon landing on the dovecote, wings up, with a cream scroll and a red ribbon |
| camp | **New road's-end landmark**: a striped two-peak mess marquee with pennants and stove smoke. **The back log seat is now long and visible**, with a lute player on it. Fire smoke column. Gnomes toasting and holding a mug. A far gnome pegging washing. A dog asleep by the fire. A rabbit at the woodpile. Birds. | A big raccoon climbing out of the green pack with a bandit mask, a sausage in its paws and a ringed tail |

## Weaknesses (honest)
- The rim light is automatic. It mostly shows as a warm lip on big objects; on thin poles it can brighten the whole pole.
- The haze is a flat mix per plane. It is not graded with distance inside a plane.
- Orchard: the far row trees are small and sparse compared with the market's density. The spreader trees look a little like umbrellas.
- Lavender: the near rows read as neat loaves rather than loose bushes.
- Animal sprites are hand-placed and small. The workshop dog, the jetty cat and the orchard pig read at 100% but not at 50%.
- Camp: the marquee reads as a circus big top.
- Jetty: the leaping fish is a grey blob.
- Tower: the stone variety is subtle under the mid haze.
- No `here_layouts.json` stand points. Nothing has been copied into `game/`.

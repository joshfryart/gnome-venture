# Stop looks, Maplewold style: Opus third pass, richness (art-2701 batch 4)

This pass builds on `../opus2/`. It covers the same three types: **inn, ferry, spring**. Each one is `<type>.{lua,aseprite,png}`: 480x270, native 1x, one layer, gate view, grassland_maplewold.

## Frame
Each script loads the batch 3 opus3 frame read-only: `aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua`. That gives the same palette, sky, clouds, hills, horizon y=112, slab road, gate, haze on the back and mid rows, and the upper-left rim light on the near row. Nothing in the frame was changed. The new helpers are inline in each script: reeds, the willow and the laid rope.

## Weaknesses from opus2, fixed
| opus2 weakness | fix |
|---|---|
| Spring: the brook was narrow at the bridge, and the parapets were slim | The brook is 13-21 px wide and winds from the basin overflow to the road. It has current lines, glints, stones with foam lips and reeds along the banks. The road crosses it on a **real stone bridge**: parapets about 9 px thick with lit coping, side walls with arched mouths, voussoirs and foam where the water goes in and out, moss, lichen, and a robin on the coping. |
| Spring: the boulders were fairly round | Each boulder has split-stone cracks (a dark zig-zag with a lit lip) and lichen rosettes. |
| Ferry: the tow rope was a thin 1 px line | It is now a 2 px laid rope with an ink rim, a lit top strand and twist marks. It runs from the raft's front post, sags over the water with drips and goes into the hauler's hands. A 2 px tail runs to the coil. It reads at 50%. |
| Ferry: the willow was a flat green cap | The weeping willow is rebuilt. It has a forked trunk and a lumpy dome. Dark back curtains give it volume, and lit front strands have leaf ticks. There are autumn-gold flecks, tips trailing in the water, and a reflection. |
| Ferry: the raft deck was hidden by the figures | The raft is deeper and the figures stand further back, so the front planks show. The raft has a broken reflection and a bow wave. |
| Inn: the drinkers were hidden from the chest down | The table is lower, so the drinkers show down to the belt. A dog is asleep under the table. |
| Inn: the festoon and the hay cart overlapped | The festoon string is raised and flatter, and its lanterns now clear the hay. |

## Richness added
- **Inn.**
  - Moss cushions on the old thatch, and a pigeon on the ridge.
  - A gnome leaning out of an upstairs window beating a striped rug, with dust flying.
  - A goat tied to the hitching rail, chewing the tether.
  - The barn's washing line, hazed with the back row.
- **Ferry.**
  - Grass overhangs the near bank, with pebbles in the wet sand.
  - A fisher gnome sits on an upturned bucket, rod over the reeds, with a creel holding a fish.
  - A goose stretches its neck at the apple gnome.
- **Spring.**
  - A gnome hauls a water cart, slopping over (barrel planks, iron hoops, a spoked wheel).
  - Dragonflies over the water.
  - Washing strung from the cottage to the birch.
  - More birds.
- **Quirks** (unchanged, all read at 50%):
  - Inn: the ginger tabby asleep on the tankard sign.
  - Ferry: the hen in a red gnome hat riding the raft.
  - Spring: the frog in a red gnome hat showering under the spout.

## Checks
- All three pass `HP.assertClean`, under the same scene rules as the Maplewold market: no semi-transparent pixels, no pure black or white.
- Colours: inn 263, ferry 314, spring 291 (opus2 had 244, 297 and 281).
- Re-render: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <type>.lua`.

## Weaknesses (honest)
- **Spring.**
  - The bridge's side walls are short, so the arched mouths are partly hidden by the reeds and the cart.
  - The bottom-right corner stays plain ground, because the frame repaints it as the compass corner.
- **Ferry.**
  - The goose and the fisher's creel fish are small sprites: they read at 100% but are faint at 50%.
  - The willow sits close to the right gate post.
- **Inn.**
  - The moss patches are flat blobs.
  - The washing behind the barn is faint under the back-row haze.
  - The dog under the table is small.
- Nothing is wired into `game/`.

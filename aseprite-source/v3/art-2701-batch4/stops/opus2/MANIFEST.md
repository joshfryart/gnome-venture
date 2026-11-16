# Stop looks, Maplewold style: Opus second pass (art-2701 batch 4)

This pass builds on `../haiku/`. It covers three types: **inn, ferry, spring**. Each one is `<type>.{lua,aseprite,png}`: 480x270, native 1x, one layer, gate view, grassland_maplewold.

## Shared frame
Each script loads the opus3 frame read-only, by absolute path: `aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua`. That gives the same palette, sky, clouds, hills, horizon y=112, slab road, gate, bunting, lanterns, compass corner, depth haze and rim light as the batch 3 looks. Nothing from the frame is copied here.

## Layouts (each one different)
| type | hero and where it sits | what says the stop type | quirk (reads at 50%) |
|---|---|---|---|
| inn | A big two-storey coaching inn fills the **left**: deep thatch with dormers, a jettied timber-framed upper floor, glowing bay windows with geranium boxes, a porch hood, two smoking chimneys. A gallows sign post by the road hangs a big tankard board. | The tankard sign. A beer garden on the right under a cluster maple: a long trestle table with three gnomes raising mugs, festoon lanterns and a barrel stack. A waiter crossing the road with a tray of mugs. The innkeeper with a mug on the step, and a chalk menu board. | A big ginger tabby (about 40x17 px) asleep on top of the inn sign. Its tail hangs over the tankard and "z z z" rise from it. The haiku cat was 10 px. |
| ferry | A river runs **across** the whole view. The road stops at a plank landing. The ferry raft is the **centre** hero, mid-river and coming in. | The ferryman poles the raft. A traveller with a bundle, milk churns and an apple crate ride on it. A gnome on the landing hauls it in by the tow rope. On the near bank: the ferry bell on a frame, a painted raft sign, a ticket booth with a gnome in the hatch, waiting travellers on a bench with luggage, and cargo waiting to cross. On the far bank: the road goes on from a far landing, past the ferryman's house with its bell post and lantern, and a gnome waves. | A big white hen in a red gnome hat (17x24 px) riding the raft on a red trunk |
| spring | A big mossy rock outcrop on the **right**, with a dressed sandstone face and a carved stone gnome head. Water arcs from its mouth into a wide stone basin. | A second trickle from a crack fills a gnome's pail. The basin overflows into a brook that winds down-left, under a stone-parapet bridge on the road, into a lily pond in the bottom-left. A well-head with a gnome winding the bucket. A stall selling clay jugs of spring water. A gnome with two pails on a yoke. A gnome washing laundry at the pond. A water-drop sign. | A big green frog in a red gnome hat on a lily pad in the basin, eyes shut, being showered by the spout |

## What changed from the haiku pass
- **Composition.** Haiku put every landmark small and centred, with a lot of empty ground. Now each picture has a hero in a different place: inn left, raft centre, spring right. Mid and foreground props fill the ground.
- **Depth.**
  - Back row (hazed, plane 1): the road's-end coach barn and cottage for the inn, the far bank cottage and reeds for the ferry, the hamlet with its chapel spire for the spring.
  - Mid row (plane 2): the hay cart, the ferryman's house and willow, the birches.
  - Near row (plane 3, with rim light): heroes, gnomes and props.
- **Ramps.**
  - Spring rocks are a new warm field-stone ramp with 7-facet lighting, thick moss cushions with hanging edges and a dark back mass.
  - The carved head is a sandstone ramp set against a dark niche.
  - The river has graded far-to-near water, current streaks, glints and broken bank reflections.
- **Ferry reeds.** Cattail beds are now clumps of 2 px blades with rims and 3 tones, plus brown heads: 18-24 px tall on the near bank, with a dense row along the far bank. The haiku reeds were a few 1 px strokes.
- **Gnomes.** Every working gnome uses the 28 px figure and holds a real tool or object: mug, tray, barrel, pole, rope, pail, jug, yoke, washboard, ticket. Only far gnomes are the 20 px `small` figure.

## Checks
- All three pass `HP.assertClean`, under the same scene rules as the Maplewold market: no semi-transparent pixels, no pure black or white.
- Colours: inn 244, ferry 297, spring 281.
- Re-render: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <type>.lua`. Each script writes its own `.aseprite` and `.png` to this folder.

## Weaknesses (honest)
- **Inn.**
  - The table drinkers are hidden from the chest down by the table.
  - The festoon string and the far hay cart overlap a little.
- **Ferry.**
  - The willow crown is a flat green cap.
  - The tow rope is a thin 1 px line and is easy to miss at 50%.
  - The raft deck is mostly hidden by the figures on it.
- **Spring.**
  - The brook is narrow where it meets the bridge.
  - The parapets read as a bridge, but they are slim.
  - The boulders are still fairly round.
- Nothing is wired into `game/`, and there are no `here_layouts.json` stand points.

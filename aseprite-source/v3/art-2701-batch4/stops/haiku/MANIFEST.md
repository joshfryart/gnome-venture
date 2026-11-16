# Stop looks, Maplewold style: Haiku first pass (art-2701 batch 4)

Three new types, first pass: **inn, ferry, spring**. Each is `<type>.{lua,aseprite,png}`: 480x270, native 1x, one layer, gate view, grassland_maplewold.

## Shared frame
Each script draws on the opus3 frame, read-only, by absolute path: `aseprite-source/v3/art-2701-batch3/stops/opus3/_frame.lua`. Same palette, sky, clouds, hills, horizon y=112, slab road, gate beam, posts, bunting, lanterns and plain compass corner. Nothing is copied into this folder except the outputs.

## Pictures
| type   | landmark at road's end                          | set pieces                                   | gnomes                                  | joke                                  |
|--------|-------------------------------------------------|----------------------------------------------|-----------------------------------------|---------------------------------------|
| inn    | two-storey plaster inn, thatch-and-tile, porch awning | hanging tankard sign; hay cart with barrels | innkeeper with a mug; gnome by the cart | a cat asleep on top of the inn sign   |
| ferry  | shingled ferry house with a lantern pole, on the far bank | ferry boat tied to a post; wooden landing and rope drum | ferryman poling the boat; small far-bank gnome | a hen in a tiny red hat as passenger  |
| spring | stone arch with a tiled roof and a water spout  | stone basin pool with lily pads; wooden well-head with bucket | gnome filling a pail; gnome hauling the rope | a green frog in a red hat on the rim  |

Layouts differ: inn is centred on the road with the cart right and the trough left; ferry runs the river across the middle, road into the water, boat on the right; spring has the arch centred, the pool front-left and the well right.

## Checks
- All three pass `HP.assertClean`: no semi-transparent pixels, no pure black or white. Colours: inn 191, ferry 171, spring 165.
- Re-render with `cd` into this folder and run `/tmp/claude-0/ase/squashfs-root/AppRun -b --script <type>.lua`. Each script writes its own `.aseprite` and `.png` here.

## Notes for the Opus passes
- The inn cat is small at 1x (about 10 px). It needs more body to read.
- The frog in the spring scene is small. A larger frog or a bigger hat would help.
- The ferry's far-bank reeds are only a few strokes. Ferry and spring could use a second row of props.
- Nothing is wired into `game/`, and there is no `here_layouts.json` entry yet.

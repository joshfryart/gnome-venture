# Stop looks, Maplewold style: Opus second pass (art-2701 batch 3)

Same 8 types and names as `../haiku/`: mill, shrine, jetty, herb, workshop, orchard, tower, camp.
Each is `<type>.{lua,aseprite,png}`, 480x270, native 1x, one layer. All pass `HP.assertClean`
(no semi-transparent pixels, no pure black or white). Run: `AppRun -b --script-param out=<dir>/ --script <type>.lua`.

## Frame (`_frame.lua`)
Rebuilt as a faithful port of `v3/here-gate/pilot-market.lua` (the shipped
`here-stop-market-grassland_maplewold.png`): same palette, sky bands, clouds, hills, horizon y=112, ground fan,
slab road (VP 240,112), gate beam texture, bunting edges, lantern drip, plain compass corner (380-480 x 230-270).
The Haiku frame had dropped parts of the market recipe; restored: building braces + middle rail, roof highlight,
attic window, chimney (now runs down behind the roof instead of floating). Like the market, no ink outline on the
opaque scene; objects get a 1 px rim in their ramp's edge tone. New shared furniture: `gnome` figure, sack, crate,
barrel, rock, bush, fences, sign, `eraseGround`. Extra ramps: lav, iron, skin, apple.

## Changes vs Haiku (all 8 were sparse: 2-4 props on empty ground, no figures, weak type read)
Every picture now follows the market's density: a landmark at the road's end, a left and a right hero, back-row
buildings, foreground vignettes, 1-3 gnomes doing the type's job, and one quirk.

| type | road's end | heroes and vignettes | quirk |
|---|---|---|---|
| mill | windmill with lattice sails | plaster mill house with overshot wheel, flume and mill race into a pond; granary with sack hoist and dock; millstones; cart of sacks; wheat field with stooks; sheaves | duck riding a wheel paddle |
| shrine | flared-roof hall on a stone terrace | red torii over the road, paired stone lanterns receding, fox statues, pagoda, purification basin pavilion, bell frame, roped sacred maple, ema rack, raked gravel, bamboo, gnome sweeping | real fox kit beside the stone fox |
| jetty | road runs to a shore; right half is a lake | plank jetty on piles, rowboat, lamp post, gnome fishing, boathouse on stilts, far sail; fisher cottage, fish rack, net frame with floats, upturned boat being tarred, creels | heron stealing from the fish bucket |
| herb | rose trellis arch with a gate | lavender rows to the hills, thatched herbalist cottage with drying bundles and mortar sign, glasshouse, four different raised beds, potting table, bee skeps, tiered herb mound, hollyhocks | cat asleep in the catnip |
| workshop | gantry crane lifting a log over the lumber yard | forge with glowing hearth, chimney, bellows, anvil and smith; open carpenter's barn with tool wall and bench; sawhorse with a half-sawn plank; grindstone; wheels; woodpile | bird's nest with chicks on the crane beam |
| orchard | great old apple tree with a rope swing | apple-tree rows in perspective both sides, cider press with juice into a bucket, apple heaps, crates, jugs, picker on a ladder, wheelbarrow, red barn, windfalls | hedgehog with an apple on its spines |
| tower | round stone watchtower with lit beacon and flag | crenellated wall along the horizon, banners lining the road, guardhouse with shield, spear rack, shields, training dummy, archery targets, alarm bell, stone store, dovecote, telescope, beacon wood | carrier pigeon with a scroll |
| camp | small ridge tent | campfire in a stone ring with tripod pot, log seats and three gnomes, cream bell tent glowing inside, covered wagon, washing line between trees, firewood stack, camp kitchen, bedrolls | raccoon in a backpack with a sausage |

## Weaknesses (honest)
- Gnome figures are tiny (about 20 px) and simple; arms and held tools read only at 100%.
- Quirks are small: the shrine fox kit and the jetty heron read; the tower pigeon's scroll and the workshop nest are hard to see at 50%.
- jetty: the lake surface is flat light water with dash ripples; the heron is small.
- herb: the lavender rows still shimmer a little where the rows turn thin; the hollyhocks are stiff.
- orchard: ground between the tree rows is plain; the row trees repeat one shape.
- tower: the tower is plain grey stone, little variety of material; the bell frame and store crowd the right middle.
- camp: the fire's back log seat is hidden; the far ridge tent at the road's end is a weak landmark.
- No `here_layouts.json` spots/stand points yet; nothing copied into `game/`.

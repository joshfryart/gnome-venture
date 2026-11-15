# art-2701 batch4, wear, OPUS second pass (opus2, 8 icons)

These 8 icons are full redraws at 64x64 in Hearth Pop. None of them repaints the Haiku PNG or the game base. Each one is the same item as the game's `ph/<slug>.png`: same parts, colours and layout. Every part is drawn again with the v3 lighting library: per-pixel normals, snapped to a 6-tone ramp. Material texture goes in as tone bias, so it follows the light. All icons use hard pixels and the 1 px ink `#2b1c26` outline from `c:finish`. There are no semi-transparent pixels, no pure black or white, and no pixel on the canvas edge. `HP.assertClean` runs in `W.save` and passes on all 8; a separate PIL check also passed. Nothing in `game/`, `../haiku/` or any other folder was touched.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

Helpers:
- `_w.lua` wraps `items/batch2/_bbg.lua` (read only). It provides cylinder normals, `lit`, `speck`, `sep`, a curly `fleece` band, `shift` and `save`.
- `_hat.lua` draws all three hat ranks from one function.
- `_scarf.lua` draws both scarf ranks from one function.

Rank rules:
- **Lined** has cream fleece (6-tone, cool deep) at the openings and no gold.
- **Fine** has gold-only trim and embroidery and a gleam, and no fleece.

At 32 px the Lined hat has a white brim edge and the Fine hat a gold brim edge with a gold-framed band. The Lined scarf has a white neck ring and white cuffs.

| Name | Changes vs Haiku | Quirk | Weaknesses |
|---|---|---|---|
| flood-boots | Full redraw. Glossy rubber is lit per pixel on a 6-tone green, with a broken specular streak down each shaft, a toe-cap shine and ankle crinkles. The tan cuffs are rolled, with a dark mouth, a fold line and a tucked lip. The sole has a lit welt and tread lugs. The front boot casts a shadow on the back boot. A water run goes down the front shaft and drops sit at the toe. | A yellow rubber duck living in the back boot, peeking over the cuff | The cuffs are cleaner than before but a little brown and flat. The front boot's foot is still a fairly square block. |
| work-gloves | Full redraw. Each finger is its own lit tube with a deep seam to its neighbour. There are knuckle creases with a lit lip, a lit knuckle ridge, a pillowed palm and sparse pores. The rolled cuff has a contact row, a cream saddle stitch and a worn hem. The front glove casts a shadow on the back one. | A pink earthworm draped over the back glove's little finger | The palms are plain next to the fingers. The worm is only 2 px thick, so it reads as a pink hook at 32 px. |
| trail-pack | Full redraw. The canvas has a soft weave. The flap is shaped with angled corners, a turned hem with a canvas-thread stitch, and a contact shadow. The side pockets have seams and running stitch. The bedroll is a real cylinder with cord ties, cream stripes and a spiral end. The strap is grained and has a punched hole, and the brass buckle is bevelled. The lavender sprig is kept. | A blue enamel camp mug hanging by its wire handle from the right pocket, with a chip in the enamel | The weave is still busy at 100%. The mug's wire handle is faint. |
| yarn-scarf | Full redraw. The loop is a lit torus and the tails are tubes, all with knit chevrons and a rib groove that follow each tube. The red and teal stripes run along the knit. The knot is a separate wrap with a dark edge and folds. The left tail crosses over the right with a separation line. The fringes are kept. | A wooden knitting needle with a red ball end still threaded through the right tail, the working yarn looping off it | The layout is more symmetric than the base scarf. The knot reads as a band rather than a tied knot. |
| yarn-scarf-lined | Same drawing as yarn-scarf (siblings). The fringes are replaced by fat fleece cuffs that bulge past the knit, with a contact shade above them. A fleece lining runs round the inner rim of the neck loop. | A darned pink heart patch on the left tail | The inner-rim fleece is 2 px, thinner than the cuffs. |
| wayfarers-hat | Full redraw. The felt crown has nap speckle, a centre crease (dark fold with a lit lip) and side pinches. The brim is a lit ellipse with a rolled lip, a dark 3 px underside and the crown's cast shadow. The red band is grosgrain, with ribs and a ribbon knot. The feather has a curved vane, a pale quill, diagonal barbs and a notch. | A ladybird walking on the brim | The ladybird reads only at 64 px. The brim's left end is a little blunt. |
| wayfarers-hat-lined | Same hat. A thick cream fleece lining is turned out round the whole brim edge, with lumpy curls below the rim, plus a fleece sweatband edge under the band on the lit side. | A fleece tuft caught on the feather quill | The tuft is tiny and is lost against the pale quill. |
| wayfarers-hat-fine | Same hat. Gold twisted braid binds the brim edge. The band has gold edging top and bottom with gold zig-zag embroidery between. The knot is now a gold ring buckle, and a gold clasp pins the feather. Gleam: a cream sparkle off the clasp. | A tiny gold acorn charm hanging from the buckle-knot | The zig-zag is busy at 64 px. The acorn is about 3x5. |

All 8 were checked at 4x and 6x on grey and dark, and as 32 px and 16 px box downscales. Each icon reads as its game base item. Lined and Fine stay distinct at 32 px.

Note: the Lined and Fine hats and the Lined scarf are built on these new commons, not on the game's existing rank icons. The game's `wayfarers-hat-lined` and `-fine` already carry gold on the brim; these replace that look.

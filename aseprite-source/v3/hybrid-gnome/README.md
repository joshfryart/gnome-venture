# gnome-player rig (recolourable layers)

The art is `../gnome-player.lua` / `../gnome-player.png` and has not been changed. `gnome-rig.lua` runs that script
as it is, with an instrumented HP canvas. It records which drawing step painted each pixel last and writes each
step's pixels to its own layer. Stacking the layers gives back `gnome-player.png` exactly. `python3 recolor.py --verify`
checks this and reports 0 differing pixels out of 30,720.

```
/tmp/aseq/squashfs-root/AppRun -b --script-param out=<this dir>/ --script gnome-rig.lua   # rebuild layers
python3 recolor.py --hat "ember red" --tunic 3a86b0 --beard ginger --skin skinB out.png   # 384x80 strip
python3 recolor.py --skin '#9c6642' --frame 1 --scale 4 one.png                          # one frame, x4
python3 recolor.py --verify          # default recolour == gnome-player.png
python3 recolor.py --preview preview.png
```

## Layers (each a 384x80 strip: 6 frames of 64x80, idle 1-2, walk 3-6, feet baseline y=70)
Order from bottom to top. The layers are disjoint: every pixel belongs to exactly one layer, so the order only matters by convention.

| # | file | role | contents |
|---|---|---|---|
| 0 | gnome-shadow.png | fixed | 2-tone stone ground shadow |
| 1 | gnome-outline.png | fixed | 1 px ink `#2b1c26` outline |
| 2 | gnome-boots.png | boots | boots |
| 3 | gnome-tunic.png | tunic | tunic and sleeves |
| 4 | gnome-scarf.png | scarf | scarf ring, tail, fringe |
| 5 | gnome-skin.png | skin | head, ears, nose, hands |
| 6 | gnome-beard.png | beard | beard, moustache, notches |
| 7 | gnome-face.png | fixed | eyes (ink + cream glint), nose glint, cheeks (petal) |
| 8 | gnome-hat.png | hat | cone, rim, floppy tip |
| 9 | gnome-trim.png | trim | bell and hat-band stitch (gold by default) |

`gnome-rig.aseprite` holds the same 10 layers with the idle and walk tags.

## Tinting: palette mapping
Tintable layers use only these marker greys: hi `#f0f0f0`, base `#b4b4b4`, shade `#787878`, deep `#3c3c3c`.
Each grey is replaced with the matching step of a 4-tone ramp. Fixed layers keep their real colours.
A role takes one of three values:
- a **preset** name from `rig.json`. Palette presets store the exact Hearth Pop ramp.
- a **hex** base colour. The ramp is built with the recipe below.
- nothing. The role then uses its `default` preset, which is the ramp the gnome was drawn with.

The skin and scarf/trim defaults have their deep step folded to `wood.deep`, as in the original.

Recipe (HSL; `recolor.py`, `recolor.js` and `rig.json` use the same maths, and the JS was checked bit-identical to the Python on 3,004 colours and 12 composites):

- hi: hue moves 10° toward 45° (yellow), L + 0.30·(1−L), S unchanged
- shade: hue moves 8° toward 270° (violet), L·0.80, S·0.80
- deep: hue moves 20° toward 270°, L·0.55, S·0.60

L is clamped to the range 0.03–0.97. Channels are rounded with `floor(v*255+0.5)`. The constants were fitted to the 11 guide ramps; the plain guide wording oversaturated the shadows, especially on light colours.

`recolor.js` (no dependencies) provides `GnomeRecolor.compose(rig, layers, colours)`, which takes ImageData, canvas or `{width,height,data}` and returns `{width,height,data}`. It also provides `rampFromBase(hex)` and `resolve(rig, role, spec)`.

## Presets (12 per role + `default`)
- hat: ember red, gold, moss, sea, dusk, petal, wood, stone, sky, plum, navy, forest
- tunic: sea, moss, dusk, ember red, wood, stone, petal, gold, navy, forest, mustard, plum
- scarf: gold, ember red, moss, sea, dusk, petal, sky, stone, cream, teal, berry, orange
- beard: white, snow, grey, silver, ginger, ginger wood, auburn, blond, honey, chestnut, black-brown, lilac
- boots: wood, tan, dark leather, black-brown, oxblood, stone, ember red, moss, sea, dusk, gold, petal
- skin: skinA, skinB, skinC (guide ramps), porcelain, rose, tan, olive, bronze, umber, deep, moss sprite, dusk sprite
- trim: gold, silver, copper, brass, ember red, moss, sea, dusk, petal, sky, wood, cream

## Limits
- The layers are pre-occluded, because each pixel is in the layer that was drawn last there. Hiding a layer leaves a hole; for example, there is no hair under the hat. A swap of hat shape would need new art.
- The eyes are fixed ink pills. On skinC, umber and deep, the pupil has low contrast; only the cream glint reads well. Cheeks (fixed petal) also fade on dark skin. Possible fix: a light rim or an alternative eye layer for dark skin.
- The `hi` grey appears only in the hat and beard (the gnome's 2 pops). The other parts were drawn with base, shade and deep only.
- The nose glint and the beard pop are cream in the default. The beard pop becomes the beard's hi tone; the nose glint stays cream.
- A beard close to the skin tone (for example chestnut with umber skin) merges with the face, because there is only an inner deep line between them. Choose contrasting pairs.
- If `gnome-player.lua` is edited, re-run `gnome-rig.lua`. It finds the drawing steps by anchor comments and calls in `frame()` (see `ANCHORS`). It stops with an error if a colour falls outside its layer's ramp or a pixel has no section. Then run `--verify`.

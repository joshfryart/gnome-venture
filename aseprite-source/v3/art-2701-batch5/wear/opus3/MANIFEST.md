# art-2701 batch5, wear, Opus redraw of the cut-b Travel Cloak family (opus3, 3 icons, 64x64)

`travel-cloak-b` was still drawn on the old folded cloak. All three cut-b icons now use the hanging cloak on its wooden peg, the same drawing as the base, Lined and Fine. Hearth Pop rules apply: hard pixels, 1 px ink `#2b1c26`, no semi-transparent pixels, no pure black or white. `HP.assertClean` runs on every save (`O.save4`), and all three report semi=0 and blackWhite=0. Nothing outside this folder was changed, and the source PNGs were only read.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

The helper `_o5.lua` reuses `art-2701-batch4b/wear/opus2/_o4.lua` and adds the following:
- `O.texture`: the opus3 cloak texture, using the same rules as batch3 opus3 Fine. It adds a twill fleck, a yellow-green rim on the lit left edge and shoulders, and a teal bounce on the lower right. The base cut-b now has the same material treatment as its ranks.
- `O.patchB` adds the cut-b mark and its quirk:
  - **The patch:** a 10x10 rust tartan on the shaded right skirt. It has an ochre stripe and a plum over-check, lit in three levels from the upper left. A turned-under seam ring carries a cream running stitch, 2 on 1 off, with darker thread on the shade side. The top-right corner lifts where its stitch has come undone, and the patch casts a 1 px contact shadow on the right and below.
  - **The quirk:** a moth-nibbled hole in the lit left skirt. It has a scalloped bite edge, a dark inside, a lit lower lip and pale frayed fibres. The moth that nibbled it flutters just off the left edge, with pale wings, dark spots and two ink antennae.
- `O.cutb` and `O.graftB` build base+texture (T) and base+texture+patch (B). The ranks copy in every pixel where B differs from T, so all three icons carry the same patch, hole and moth, pixel for pixel.

| Name | Built from | Notes |
|---|---|---|
| travel-cloak-b | `art-2701-opus/wear/travel-cloak.png` + texture + patch | Keeps the base's orange hem leaf, as the other cut-b icons keep their base quirk (for example the boots' drip). 46 colours. |
| travel-cloak-b-lined | `art-2701-batch3/wear/opus3/travel-cloak-lined.png` + graft | Fleece ruff, fleece facings and blanket-stitch. The Lined darn on the left skirt is unpicked, so the icon tells one mend story: the tartan patch. 52 colours. |
| travel-cloak-b-fine | `art-2701-batch3/wear/opus3/travel-cloak-fine.png` + graft | Gold brooch with garnet, gold-piped facings and hem, and filigree curls. The gold bee is unpicked: it sat where the patch goes, and the moth is this icon's insect. 55 colours. |

## Checks
I viewed every icon at 6x on grey and on dark, and as 32 px and 16 px box-downscales.
- **32 px:** the red tartan square on the green skirt reads clearly on all three. The moth and the hole read.
- **16 px:** the patch still shows as a red dot. Lined and Fine stay apart: the white ruff and V on Lined against the gold V, brooch and hem on Fine.

## Weaknesses
- The hole is about 4x4 and reads as a dark nibble at 32 px. At 16 px only the patch carries the cut-b read.
- The moth is 9x5 and floats off the silhouette, so it widens the icon's bounding box on the left.
- The game PNGs in `game/assets/img/ph/` are not updated. They need the export step.

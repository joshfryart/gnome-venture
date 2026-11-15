# art-2701-next8, Haiku fourth pass (haiku4): small adjustments

Base: `../opus3/`. Every script was copied and re-run. Before any edit, the regenerated PNGs matched the opus3 PNGs byte for byte. Only `travel-cloak-b.lua` has an edit. The other seven scripts are unchanged copies, and their outputs are identical to opus3. `HP.assertClean` passes on all 8 (0 semi-transparent, 0 pure black or white). Palette, ink and style are unchanged. The scope was small, local fixes only; no redesign and no added richness.

| icon | result |
|---|---|
| hum | **Unchanged.** I checked the notch in the wing-tip outline at (33,4). Filling it would let `finish()` add a new spur at (33,3), so it stays. The gold inlay line is a colour choice, not a pixel fault. |
| lull | **Unchanged.** The busy craters on the violet horn need the crater redrawn, not a few pixels. The Z shade pixels are intentional. |
| bond | **Unchanged.** The knot and tassels are small at 32 px, but any change would be a redraw. The frayed tips are intentional. |
| pluck | **Unchanged.** The tall composition and the embroidered diamond that reads as a button need layout changes. The sky lift arcs are as intended. |
| mend | **Unchanged.** The dark-red pixels inside the tear are the crack's shaded interior, not strays. The thimble silhouette would need a redraw to change. |
| thorns | **Unchanged.** The leaf serration is a 1 px step at 64 px. Making it visible means reshaping the outline, which is a redraw. |
| trail-pack-b | **Unchanged.** The arrow reading as an upload sign is a satin-stitch choice. The base pack is unchanged by design. |
| travel-cloak-b | **Changed (20 px, in the script before `saveIcon`).** The patch's right edge stepped out 3 px on the lower rows, and its whip stitches sat off the fabric. The patch is now a square 8x9 (x 44..51, y 22..30) with a straight brown edge on x=51. The stitches sit on x=52, alternating cream and shadow like the top row. The lower-right protrusion (x 52..55, rows 27..31) returns to the cloak wool `#264a3c`. The moth, the top stitches and the rest of the patch are unchanged. Every colour used is already in this icon. |

# art-2701 batch3, wear, OPUS second pass (8 rank variants)

These are the same 8 Lined and Fine icons as `../haiku/`, at 64x64. Each script loads its base PNG read-only and hand-places pixels on top. Every icon uses hard pixels and a 1 px ink `#2b1c26` outline, with no semi-transparent pixels and no pure black or white. `HP.assertClean` passes on all 8 (it runs in `_o2.lua` O.save). Nothing in `game/` or `../haiku/` was touched.

Re-run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

`_o2.lua` provides:
- `O.wool`: curly fleece over a pixel set. It uses a 5-tone cream ramp lit from the upper left, with staggered curls, a lit top edge, a shaded bottom and right edge, and optional rolled-form rows.
- `O.paint`: char-map overlays.
- `O.remap`: boxed colour swaps.
- `O.reink`: re-inks the silhouette after any part grows past it, and clears orphaned ink.

## Rank language (same on all four)
- **Lined** uses cream sheepskin or fleece only, with no gold. The lining is a big readable mass at an opening or edge, with a tufted or shaggy outline and a contact shadow under it.
- **Fine** uses gold only, with no cream masses. It adds gold trim or piping, one embroidered or cast gold motif, and one cream glint as the gleam.
- At 32 px, Lined reads as "white fluffy edge" and Fine reads as "yellow lines and a sparkle".

## Bases
- The cloak is built on the Opus `art-2701-opus/wear/travel-cloak.png` (the hanging cloak, which replaces the game's folded `ph/travel-cloak.png`).
- The boots, gloves and pack are built on the game's `ph/*.png` (cut a).
- The silhouettes are unchanged except for fleece tufts 1-2 px past the edge on the Lined icons.

| Name | Changes vs Haiku | Remaining weaknesses |
|---|---|---|
| travel-cloak-lined | Haiku had thin cream strips on the V and tufts on the hem. Now a shaggy 3 px fleece ruff rings the neck hole (the old tan lining roll, grown into sheepskin). Fleece facings run down both front edges and widen from 1 to 3 px toward the hem. A dark fold line sits where each facing turns under the wool, and the corners turn back at the hem. The hem tufts were dropped, which keeps the scallops clean. | The ruff is fairly regular, close to a ring. The top of the facings is a single 1 px cream line. |
| travel-cloak-fine | The wooden toggle is now a cast gold clasp with a garnet and a cream glint. Haiku's dotted gold lines were replaced with 2 px solid gold piping on both V edges (lit on the left, shaded on the right). A 2 px gold band follows the scalloped hem, starting right of the leaf so the leaf stays orange. There is a soft sheen on the lit shoulder. | The sheen is subtle. The garnet is 2x2 and only a red dot at 32 px. |
| flood-boots-lined | Haiku had striped tan cuff tops, which were weak. Now both turned-down cuffs are whole curly sheepskin, with a tufted top edge (1 px above the old top), a rolled light-to-dark form, and tufts spilling over the shaft with a green contact shadow. | The back boot's tufts over its dark mouth row are only 1 px. |
| flood-boots-fine | The cuffs are now polished chestnut leather instead of tan, so they no longer look like the base. Gold piping runs on each cuff top and fold. A chestnut ankle strap crosses both boots with a cast gold buckle and a glint. The specular streak on the front shaft is brighter. | The buckle is 6x6 and small at 32 px; the chestnut and gold carry the read. |
| work-gloves-lined | Haiku put fleece above the stitch row, in the wrong place. Now a thick fleece lining rolls out of each cuff mouth: 5-6 rows with a wavy top into the leather, and tufts hanging below the cuff, 1 px wider than the cuff. | The back glove's band is partly hidden behind the front one. |
| work-gloves-fine | Gold piping sits at the top of each cuff, the stitch row is in gold thread (the base quirk), and a gold binding runs along each cuff mouth. A 7x7 gold diamond is embroidered on the back of the front glove, and a gold snap with a cream glint sits on the front cuff. | The diamond can read as a gem rather than embroidery. The snap is 2x3. |
| trail-pack-lined | Haiku's one dashed row was subtle. Now a fat fleece collar (5 rows, tufted top over the roll, puffing 2 px past both sides) sits at the mouth. The flap hem turns back as a 4-5 row fleece band with tufts, split by the strap. A dark canvas shadow sits under both, and a brighter fleece ramp lifts it off the oat canvas. | Cream on oat is still the lowest-contrast pairing in the set. At 32 px the collar reads, but the hem band is soft. |
| trail-pack-fine | A twisted gold cord binds the mouth. A 2-row gold braid runs on the flap hem. Two gold fern sprigs are embroidered either side of the strap. The strap has a brass aglet, and the buckle has a cream glint. | At 16 px Lined and Fine both read as a light band across the pack; the difference shows from 32 px. The ferns can look like wheat. |

Checked on grey and dark at 300%, 32 px and 16 px against the base. Each icon reads as the same item, and Lined and Fine differ at 32 px on all four.

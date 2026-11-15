# art-2701-rest / opus3: Opus richness pass on the 8 opus2 icons

These are not exported to game/. Names and sizes match `../opus2/`: 7 trail map markers at 32x32 and `wayfarers-hat-b` at 64x64. Each icon has `<name>.lua`, `.aseprite` and `.png`. Each script builds on its opus2 script; the drawing was extended, not restarted.

All 8 pass `HP.assertClean`: 0 semi-transparent pixels and no pure black or white. Every trail marker has the 1 px ink `#2b1c26` outline from `c:finish`, and no non-ink pixel sits on the canvas edge (checked). The hat keeps the base hat's own outline and its pixels; only the patch area changes. The helpers `_trail.lua` and `_p.lua` are unchanged copies from opus2.

Rebuild one icon: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

I checked every icon at 8x, 2x, 1x and 16 px (box downscale) on map green (`#6fa84a`) and on dark. I also put all 7 markers in one row next to the 8 finished `art-2701-opus/trail` markers. They read as one set, and each keeps its own dominant hue.

## Fixes for the opus2 weaknesses

| opus2 weakness | opus3 fix |
|---|---|
| The delve hat read as a flame at 1x | The hat is now crimson felt with a cream fur trim, straight cone sides and the tip leaning over. The orange curl is gone, and a dark contact row separates it from the cream rim. It reads as a gnome hat at 32 px and as a red cone at 16 px. |
| The overgrown axe head was small (6x4) | The head is now an 8x6 bearded wedge with a narrow poll round the handle, a concave beard, a bright bevelled edge, a specular streak and a dark bite line in the stump. It is the brightest thing in the icon, so it reads at 16 px. |
| The wonder outline was boxy | The posts have flared, settled feet. The lintel has sagged 1 px on its right half and lost a chip off the end. Ivy trails over the left end and down the post, and a fallen slate chunk lies at the right foot. The outline is no longer a rectangle. |
| The hat's moon was only a fleck at 16 px | The corduroy is a deeper moss green, and the moon is a 6x8 crescent, 3 px thick, so it holds as a cream mark at 16 px. The competing gold star is gone. |
| Others: haven chimney hidden, wonder robin 4x4, lair horns straight, overgrown road short, flooded far stub, market loaf and mouse | See the per-icon notes below. |

## Richness added per icon

| name | richness added | quirk | remaining weaknesses |
|---|---|---|---|
| wayfarers-hat-b | Deeper 3-zone moss corduroy (wales lit left, shaded right), a faded corner, a darker hem and gold whip stitches. The moon has a satin-stitch thread line and a shade side. | The moon has dozed off: an ink lash for a closed eye and a pink cheek | The lash is a 2 px diagonal and reads only at 64 px. The felt crown is unchanged base art. |
| trail-haven | The chimney is taller and stands clear of the thatch, with stone courses, staggered joints, a cap with an under-shadow and a bounce pixel. The lit corner of the wall has a rim light. The door has iron strap hinges. A window box under the glowing window holds pink and yellow flowers. The ridge has binding twists, and there are weathered mossy straw patches. | The chimney smoke has puffed into a pink heart, now full size and drifting right on a wisp | The mossy straw patches are subtle and could read as smudges. |
| trail-wonder | The slate shows strata bedding lines. There are lichen rosettes, cracks with a lit lip and a fresh broken face. The lintel underside is lit by the portal glow, and two motes drift out of it. Three ivy tones break the outline. | The robin, redrawn with a cocked tail, an orange breast, an eye and a gold beak, leans over the lintel edge to peer into the glow | The robin's eye merges with the outline at 1x. The sagged lintel can also read as two slabs. |
| trail-delve | Each sandstone block has its own tone and a lit corner past each joint. There is a course line on the drum, a rim light on the lit flank, and a chip and a moss tuft in the front joint. The far wall of the shaft is laid in courses, with its left face in shadow. A treasure chest's gold lid sits at the bottom with a warm bounce on the wall. The ladder has grain, knots and rope lashings, and the rail tops are lit. | A gnome's hat left on the rim; someone is already down there | The chest is 4x2 and reads as a gold glow, not a chest. The block tones are slightly busy at 8x. |
| trail-lair | The horns sweep out and curl back in like a bull's, with ridge rings and polished tips. A cool reflected-light line runs inside the lower-right rim. There are strata ledges (a lit lip over a dark seam), weathered pits on the dome, and an old bone in the hoard. | The red prize rosette now has a gold heart and splayed tails | The ridge rings are faint. The rosette tails sit low against the dark rock. |
| trail-overgrown | The crown has serrated, lit leaf tips and vein chevrons on three clumps. The road runs deeper into the arch and fades into shadow. The stump has growth rings, a heart and bark plates. | The bramble cane has wound round the axe handle and put out a new leaf | The handle is thin, and the cane hides part of it. |
| trail-flooded | The far road is now a low, wide rise with a lit crest edge, grass tufts on the verges and converging ruts. A lit bank lip runs where the water laps the near road. The signpost has a wobbling reflection under the water line and nail knots on its board. Cattails stand on the far right bank. | A frog on the signboard, now with a glint in its eye | The far road is still a simple shape. The water ramp was not pushed further. |
| trail-market | The awning shows canvas pleats (a lit ridge on each teal fold, a shaded trough in each cream fold). The posts have turned beads. The counter has nail heads and grain streaks. The loaf is a scored crusty loaf with cream slashes and a glint (no longer an orange mound). The cabbage has veins. | The grey mouse, now bigger with a pink ear, an eye and a tail, runs off with an apple | The pleats make the stripes slightly less crisp at 16 px. The jars are unchanged. |

Off-palette colours are reported, not errors: colour is not capped in the v3 guide.

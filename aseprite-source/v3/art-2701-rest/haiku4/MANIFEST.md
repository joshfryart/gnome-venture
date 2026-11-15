# art-2701-rest / haiku4: small adjustment pass on the 8 opus3 icons

Input: `../opus3/` (same names and sizes). Scope was small, local fixes only: no redesign, no new richness, palette and style unchanged. Every script passes `HP.assertClean` (0 semi-transparent pixels, no pure black or white) and `HP.report` shows 0 isolated pixels. The helpers `_trail.lua` and `_p.lua` are unchanged copies from opus3.

Rebuild one icon: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<this dir>/ --script <this dir>/<name>.lua`

## Per icon

| name | result | change |
|---|---|---|
| trail-delve | changed | The chest is now a real 6x4 chest (dark edge, gold lid with a highlight, brown body, gold lock) instead of a 4x2 glow. The floor glint moved off the chest. Gold bounce on the wall is kept. |
| trail-wonder | changed | Robin head gets one more body pixel above the eye (`a` at the crown), so the eye is enclosed by feather instead of touching the outline. |
| trail-lair | changed | Rosette tails moved from `#c23a3e` to the brighter `#e8493b` so they show against the dark rock. Horn ridges: four dark ring marks added across the narrow horns (left y7, y12; right y6, y11), so the ridges read at 1x. |
| trail-haven | unchanged | Chimney, smoke, door and window box read cleanly at 8x. The mossy straw patches are subtle but are not a few-pixel fix. |
| trail-overgrown | unchanged | Axe head and stump read at 8x. The thin handle is a silhouette question, not a local pixel fix. |
| trail-flooded | unchanged | Water, bank lip, signpost and cattails are clean. The far road shape is not a few-pixel fix. |
| trail-market | unchanged | The awning pleats still read as stripes at 8x. No isolated or stray pixels found. |
| wayfarers-hat-b | unchanged | Patch, moon and whip stitches are clean at 4x. The closed-eye lash is a 2 px diagonal, which is intended. |

## Still open (not fixed in this pass)

- trail-delve: the chest reads as a chest at 8x but is only a few pixels at 1x. A larger chest would be a redraw.
- trail-lair: the ridges are now visible but still narrow. Full ridge rings would need the horns redrawn wider.
- trail-wonder: the robin eye is clear at 8x. At 1x it is a single dark pixel in a small bird.
- trail-haven, trail-overgrown, trail-flooded, trail-market, wayfarers-hat-b: the opus3 MANIFEST notes were reviewed. They are unchanged here because the fix is a redraw, not a few pixels.

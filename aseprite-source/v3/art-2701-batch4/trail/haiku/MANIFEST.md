# Trail map markers, batch 4, Haiku first pass (32x32, not exported to game/)
Same family as `../../../art-2701-opus/trail/`. Native 32x32, 1px ink outline (`c:finish`), `HP.assertClean` passes on all three. Rebuild: `AppRun -b --script-param out=<this dir>/ --script <name>.lua`. Scripts load `lib/hp.lua` directly, no shared helper.

| name | design | quirk | weak spots |
|---|---|---|---|
| rest | plank bench with back rail, moss bedroll tied with gold cord, iron-framed gold lantern on its own post | cream moth by the lantern | moth is a little busy at 16px; bench posts read long |
| signpost | wooden post on a two-plank foot, upper arrow right, lower arrow left, gold nails | red ribbon knotted at the top | arrows are plain (no lettering) |
| hazard | red cloth warning flag (swallowtail) on a dark pole, cream exclamation mark, crossed planks at the foot | small gold bell under the flag | bell is small, barely reads at 16px |

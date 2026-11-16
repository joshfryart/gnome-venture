# Puzzle Pals chunk c01, Opus second pass (art-2701-pals-all/c01/opus2)

Second pass over the Haiku first pass in `../haiku/` for chunk 1 of `../../worklist.json` (list index 1). There are 8 pals,
each with a yard sprite (64x64, `c:eyeLocked`) and a perch sprite (36x36, hand-built at its own size, `c:eyeSmall`).
That makes 16 sprites, each as `.lua`, `.aseprite` and `.png`. Each pal keeps its Haiku concept and has one quirk from
its blurb. The style matches `art-2701-batch3/pals/opus3` and `art-2701-opus/pals`: per-pixel light into 5-6 tone
ramps, rim light and bounce, material texture and a 1px ink `#2b1c26` outline. `HP.assertClean` passes on all 16, with
0 semi-transparent pixels and 0 pure black or white. Nothing was copied into game/.

`_opus.lua` is the opus3 helper with two additions: `O.cylN` (cylinder normals) and `O.seg` (pixel line).
`_w/sheet.py` makes contact sheets and `_w/run.sh` renders sprites.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | calling | rarity | design | fix over Haiku | quirk |
|---|---|---|---|---|---|---|
| ss-coral-cuff | Coral Cuff | rootwarden | uncommon | porous coral-pink open cuff (dark inside, front lip, gold braid), stubby feet, 4 rim knobs, each with a different reef: red staghorn, orange sea fan, yellow tubes, teal anemone | reads as a band now, and the 4 reefs differ (they were 4 identical red pins) | a clownfish peeks out behind the sea fan |
| ss-lagoon-loop | Lagoon Loop | seedkeeper | uncommon | plump sand torus with grain and shells; the hole holds a lagoon going deep to shallow, with a foam line and wet rim | bigger hole with real water depth; tube form instead of a flat disc | a palm islet in the lagoon (a sun glint winks beside it) |
| rr-hammock-hush | Hammock Hush | bloomcaller | common | mossy sloth hanging upside down under a striped hammock on a branch: toes hooked over the cloth, arms dangling, tuft falling, mouth above the eyes, pink bloom in the tuft | it now really hangs upside down, and gravity cues make the flip read | a thought cloud with three dots |
| rr-bromeliad-bolt | Bromeliad Bolt | thornblade | uncommon | the pal is a bromeliad: banded leaf-sheath urn, stiff spined crown leaves with midribs, red heart bracts, a glossy cup of rain; cross brows and a clamped one-tooth mouth | used to read as a tomato with grass; body and crown are now one plant | a thirsty red-eyed tree frog on a leaf tip eyes the water |
| rr-highland-ring | Highland Ring | rootwarden | uncommon | tall granite hoop with an open hole, scalloped snow cap and icicles, a cloud drifting through the hole, heather at its foot, smug face | used to read as a diving helmet; the hole is open now | a summit flag in the snow |
| mm-skerry-seal | Skerry Seal | wayfinder | common | spotted harbour seal on a wet skerry (barnacles, wrack, sea), head raised and barking at a red-and-cream lighthouse with a lit lamp | rebuilt head (muzzle, nose, open mouth); the lighthouse no longer reads as a spray bottle | an "uninvented" fish: a dotted pencil outline above it |
| mm-peat-sip | Peat Sip | brewroot | common | peat croft: staggered fibrous peat-brick walls, mounded turf roof with flowers, stone chimney, foundation-stone feet, humming "o" mouth | used to read as a coconut; it now reads as a cottage | one smoke puff curls into a music note |
| mm-kite-knot | Kite Knot | thornblade | uncommon | tilted diamond kite, 4 billowing ember and gold panels with hem and weave, spars as creases, cross ink brows, pout, huff puff, S-curve tail | it tilts and moves now, and the panels give it structure | the tail is tied in a big pink bow |

Weakest:
- rr-hammock-hush perch: the eye patches around the pills are dense at 1x.
- rr-highland-ring perch: the snow cap squares off the top of the hole.
- mm-skerry-seal yard: the dotted fish only reads at 2x and up.
- mm-kite-knot perch: the huff puff touches the kite edge.

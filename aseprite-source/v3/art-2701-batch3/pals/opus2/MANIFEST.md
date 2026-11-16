# Puzzle Pals batch 3, Opus second pass (art-2701-batch3/pals/opus2)

Second pass over the Haiku first pass (`../haiku/`). Same 8 pals, same game keys and callings, redrawn from scratch in the
style of the finished Opus pals (`../../../art-2701-opus/pals/`): 6-tone pillow/sphere lit ramps via hpx, 1px ink `#2b1c26`
outline, part separation lines, one quirk each. Yard 64x64 uses `c:eyeLocked`; perch 36x36 is its own hand-built
script (own coordinates, `c:eyeSmall` pill eyes, fewer details), not a downscale. `HP.assertClean` passes on all 16
(0 semi-transparent, 0 pure black/white). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <name>-yard.lua`. `_opus.lua` = shared tools (copy of the Opus helper, lib path for this folder).

| file prefix | game key | calling | rarity | design | quirk | changes vs Haiku |
|---|---|---|---|---|---|---|
| toadstool-tuck | mm-toadstool-tuck | bloomcaller | common | fly-agaric: domed red cap with raised cream warts, pink gill skirt, plump stem face, one hand up counting | ring of tiny tan fairy-ring mushrooms | gills, shaded warts, arms; eyes framed by a lower lid so cream discs read on the cream stem; perch face 10 px tall (was tiny) |
| kapok-nook | rr-kapok-nook | seedkeeper | common | silky kapok floss cloud in a split olive pod with pointed ends, dark seeds, half-lidded snoozing face | knobbly root knuckle with an arched castle door, gold knob, red pennant | was a white blob on a disc; now pod + floss + real root with bark grain; door is a framed arch, not a dot |
| shell-skip | ss-shell-skip | wayfinder | common | coral hermit crab under a tall gold turban shell (whorl grooves), eyes on stalks, one leg kicked mid-skip | blue sea-glass bead held up in its claw | shell had no form; added spire, dark aperture, claw, stalks, ink grin; floating pearl dropped |
| stone-sentry | mm-stone-sentry | rootwarden | uncommon | chipped moor-grey standing stone, moss mantle with drips, lichen, crack, brow ledge, pebble nose, flat "I am a rock" mouth | its own drizzle cloud over its shoulder | round boulder became a standing stone with material cues; perch face now fills the stone (was small) |
| mate-mumble | rr-mate-mumble | brewroot | common | polished calabash gourd, burnt-in dot band, silver rim, yerba crown, silver bombilla with gold collar, pursed humming mouth | two music notes off the straw tip | haiku gourd read as a potato with a leaf; now a mate gourd with rim, yerba and straw |
| glimmer-frog | rr-glimmer-frog | wayfinder | rare | jade tree frog, eye domes, folded hind legs, toe pads, pale belly, glowing gold back spots, wide ink grin | glowing gold throat sac puffed mid-croak | clearer frog silhouette (hind legs, domes), glow moved from belly to spots + sac, three un-outlined glow motes |
| cocopaddle | ss-cocopaddle | thornblade | rare | coir-fibre half coconut hull with face (a coconut pore as nose), cream rim, driftwood mast, palm-frond sail, thorn-tipped paddle in hand | message in a bottle bobbing alongside | checkered water line replaced by a shaded swell; cloth sail became a frond; added paddle; flag dropped; perch eyes on pale flesh patches |
| gatepost-hoot | mm-gatepost-hoot | seedkeeper | rare | tawny owl, ear tufts, heart-shaped cream disc, beak open mid-hoot, spotted folded wings, scalloped breast, talons on a weathered post with rail stub + iron hinge | tuft of sheep wool snagged on a nail | post no longer touches the bottom edge (4 px yard, 1 px + shadow perch); owl reads as an owl, not a cat; hoot rings dropped |

Weakest: kapok-nook perch (sleepy lid over the 2x3 pills makes the eyes read as dots at 1x); gatepost-hoot perch
(eyes sit close inside a small facial disc); cocopaddle yard (the swell is thin, the hull hides most of it);
toadstool-tuck yard (eyes tuck right under the gill skirt, reads as peeking, which is intended but tight).

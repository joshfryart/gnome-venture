# Haiku pal pass (art-2701-batch3/pals/haiku)

Eight new Puzzle Pals, one quick pass, drawn in Aseprite Lua in the Hearth Pop style.
Sizes: yard 64x64, perch 36x36 (hand-built at that size, not a downscale).
Yard uses `c:eyeLocked`, perch uses `c:eyeSmall`. Every sprite passes `HP.assertClean`.
Shared helper `_haiku.lua` is a copy of the Opus `_opus.lua` with the lib path pointed at `aseprite-source/v3/lib`.

| file prefix | game key | calling | rarity | region | design | quirk |
|---|---|---|---|---|---|---|
| toadstool-tuck | mm-toadstool-tuck | bloomcaller | common | mistmoor | red-capped toadstool with cream spots, face on the stem | moss fairy-ring dots pressed into the ground |
| kapok-nook | rr-kapok-nook | seedkeeper | common | rainroot | fluffy kapok seed-pod napping on a root, eyes shut | tiny wooden root door with a gold knob |
| shell-skip | ss-shell-skip | wayfinder | common | sunsprinkle | ribbed gold shell with a pink hermit body and stubby legs | a pearl stuck on top of the shell |
| stone-sentry | mm-stone-sentry | rootwarden | uncommon | mistmoor | flat-topped grey boulder with a moss tuft and stubby arms | a ladybird resting on its head |
| mate-mumble | rr-mate-mumble | brewroot | common | rainroot | dried gourd cup with a gold band and a metal straw | humming notes rising from the straw |
| glimmer-frog | rr-glimmer-frog | wayfinder | rare | rainroot | green frog, bulging eyes on top of its head, sea-blue glowing belly | glowing belly and glow spots on the back |
| cocopaddle | ss-cocopaddle | thornblade | rare | sunsprinkle | half coconut boat with cream flesh rim and a sky-blue sail | an ember flag at the top of the mast |
| gatepost-hoot | mm-gatepost-hoot | seedkeeper | rare | mistmoor | brown owl with ear tufts and cream facial disc, on a wooden gatepost | a ring of sky-blue hoot marks above the post |

Files: `<name>-yard.{lua,aseprite,png}` (64x64) and `<name>-perch.{lua,aseprite,png}` (36x36) for each pal.
Run: `AppRun -b --script-param out=<dir>/ --script <name>-yard.lua`.
Not copied into game/. Checks: zero semi-transparent px, zero pure black or white px, outline and isolated-pixel checks clean.
Weakest: gatepost-hoot yard post runs to the bottom edge (0 px margin); toadstool and stone-sentry perch faces are small. Quick pass, no fix round.

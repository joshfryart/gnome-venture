# Puzzle Pals chunk c01, Haiku first pass (art-2701-pals-all/c01/haiku)

First pass for chunk 1 of `../../worklist.json` (list index 1): 8 pals, each a yard sprite (64x64, `c:eyeLocked`)
and a perch sprite (36x36, hand-built at its size, `c:eyeSmall`), 16 files total. Built only on `lib/hp.lua`
(`_haiku.lua` is a small helper: canvas, finish, assertClean, save). `HP.assertClean` passes on all 16.
Shape and knob (jigsaw geometry) are not drawn; the art is the creature. Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | name | calling | rarity | design | quirk | weak spots |
|---|---|---|---|---|---|---|
| ss-coral-cuff | Coral Cuff | rootwarden | uncommon | petal-pink cuff band with gold stitch | four ember reefs on four knobs, sparkle on each tip | reefs thin at 36 px |
| ss-lagoon-loop | Lagoon Loop | seedkeeper | uncommon | sand-gold ring with sea-blue hole | the lagoon winks (sparkle), right eye is a wink | hole reads small on the perch |
| rr-hammock-hush | Hammock Hush | bloomcaller | common | moss pal hanging head-down in a gold hammock | thought cloud with three dots | upside-down face reads odd at 1x |
| rr-bromeliad-bolt | Bromeliad Bolt | thornblade | uncommon | ember body in a crown of moss spikes | rain cup in the crown, stubby arm over it | leaves are thin on the perch |
| rr-highland-ring | Highland Ring | rootwarden | uncommon | stone hoop with a snow cap | summit flag on a wood pole | pole thin on the perch |
| mm-skerry-seal | Skerry Seal | wayfinder | common | stone seal barking on a rock | bark marks, lighthouse behind | head is weakest form; lighthouse crowds the rock |
| mm-peat-sip | Peat Sip | brewroot | common | wood-brown peat dome, moss cap | chimney puffs smoke, teacup in front | cup small on the perch |
| mm-kite-knot | Kite Knot | thornblade | uncommon | ember kite with gold border and dusk spars | bow-tied tail, huff puffs, angry brows | brows read soft at 36 px |

Weakest overall: mm-skerry-seal (head and lighthouse layout), rr-hammock-hush (upside-down read).

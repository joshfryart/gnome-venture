# creatures/haiku: first pass (Haiku), 8 weak creature pictures

Each new `<name>.png` keeps the size and file name of the game picture it would replace.
`<name>.before.png` is the current game version (copied from `game/assets/img/`, unchanged).
Nothing under `game/` was touched. Every `.lua` runs with `HP.assertClean` (no semi-transparent pixels, no pure black or white).
Run: `/tmp/claude-0/ase/squashfs-root/AppRun -b --script-param out=<dir>/ --script <name>.lua`

## Replaced (8)

| # | Game file | Size | What was wrong | First-pass change |
|---|---|---|---|---|
| 1 | `game/assets/img/mini/mini-blight-mother.png` | 101x81 | Purple blob with a tangled black smear and a gear-like head; no clear body plan. | Bloated violet abdomen with a smaller thorax and head, glassy sky wings, three back spikes, ember crack glow, one moss bud (quirk), jointed legs. |
| 2 | `game/assets/img/mini/mini-paper-wasp.png` | 75x56 | Legs were dark blobs under the body; wasp waist not readable. | Slim waist, banded gold abdomen, three long thin bent leg pairs, clear wings, one curled antenna (quirk). |
| 3 | `game/assets/img/mini/mini-bog-leech.png` | 61x31 | Read as a green caterpillar with a leaf; no sucker ends. | Segmented moss body with a sucker at each end, sheen band along the top (quirk), dot eye on the head. Dew leech (`mini-dew-leech.png`) NOT redrawn, see below. |
| 4 | `game/assets/img/mini/mini-basalt-borer.png` | 81x49 | Purple grub with horns, muddy segments, head unclear. | Stone-grey segmented grub, ring cuts between segments, drill-cone head with pale mandibles, ember vein glow (quirk), stubby legs. |
| 5 | `game/assets/img/mini/mini-clam-lurker.png` | 61x45 | Pink shell with a white blob head that read as a bird or cat. | Open clam: ribbed lower shell, raised upper shell on a hinge, pearly flesh with one eye and a tooth row (quirk). |
| 6 | `game/assets/img/folk/portrait/folk-butterfly-1.png` | 80x100 | Face read as a brown blob with no clear nose; coiled proboscis was a scatter of dark dots. | Variant 1 only. Proboscis replaced with a 2x2 button nose (rule 7 insect face); the mouth now reads. Head, hat, wings, eyes unchanged. |
| 7 | `game/assets/img/folk/portrait/folk-moth-1.png` | 80x100 | Brown coiled nose read as a muddy dot. | Coiled proboscis nose replaced with a 2x3 button nose (lit tip, dark underside). Eyes (locked, socket rings), hat, antennae, overalls unchanged. |
| 8 | `game/assets/img/folk/portrait/folk-tortoise-1.png` | 80x100 | Shell hidden behind the torso and read as a brown smudge; neck dominant. | Shell dome raised (centre y 98 to 92, rx 38 to 37), so the scute rings show on both sides above the bib. Neck, head, eyes, hat unchanged. |

## Not redrawn (left for a later pass)

- `game/assets/img/fight/rig-*.png` (fight rig sheets, multi-part strips), including `rig-blight-mother`, `rig-paper-wasp`, `rig-bog-leech`, `rig-basalt-borer`, `rig-clam-lurker`. Only the still `mini-*.png` is redrawn here. These sheets are built by `aseprite-source/v3/creature25/gen.lua` (writes `game/assets/img/fight/` and `fightrigs.js`), so the fight art will not match these stills until the rig is rebuilt or redrawn by hand. Opus pass should decide.
- `mini-dew-leech.png` (61x23): the second leech. Weak too, but the list asked for 8 pictures and the bog leech was chosen to represent "leeches".
- `game/assets/img/folk/sprite/folk-butterfly-1.png`, `folk-moth-1.png`, `folk-tortoise-1.png` (256x96 strips). Only the portrait (the villager face) is redrawn. The strips are not reviewed here.
- Variants 2 and 3 of the butterfly, and variants 2 and 3 of moth/tortoise. Only variant 1 changed.

## Method and limits

- Scripts are self-contained apart from `aseprite-source/v3/lib/hp.lua`. Mini stills use the same canvas sizes as the originals, with the ground shadow near the bottom and the figure centred in the frame. Portraits copy the existing `folk/portraits` scripts (the paths now point to `v3/lib`) and change only the parts named above.
- Locked and small eyes were not redesigned (rule 7).
- Off-palette colours are reported for the two folk portraits (about 4,600 to 5,000 px); the source scripts use the same colours, so this is inherited, not new. Opus pass should review.
- Outlines and palette were checked by `HP.report`; no pure black or white, no semi-transparent pixels.
- Haiku first pass: changes are targeted, not full re-draws. The Opus pass should re-cut silhouettes where these notes say "weak".

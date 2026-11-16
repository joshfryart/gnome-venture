# Puzzle Pals chunk 3, Opus second pass (art-2701-pals-all/c03/opus2)

Chunk 3 = `worklist.json[3]`. Built on the Haiku first pass in `../haiku/`; each pal keeps its concept, calling and quirk idea, but every sprite is redrawn.
Files are named by game key: `<key>-yard.{lua,aseprite,png}` (64x64, `c:eyeLocked`) and `<key>-perch.{lua,aseprite,png}` (36x36, drawn by hand at that size with `c:eyeSmall`).
`_opus.lua` is copied unchanged from `art-2701-batch3/pals/opus3/_opus.lua`. `_tools/run.sh` renders the sprites and builds a preview sheet; `_tools/sheet.py` makes the sheet.
`HP.assertClean` passes on all 16 sprites: 0 semi-transparent pixels, 0 pure black or white. Nothing was copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | rarity / calling | design | quirk | fixed from Haiku |
|---|---|---|---|---|
| bb-samovar-puff | common / brewroot | brass pear urn with a fluted lower body, an engraved band, ring handles, crowned collar, chimney | open tap overflowing a little cup on a saucer | the two grey balls of steam are now one curly puff; the spout is now a real tap |
| bb-catkin-crown | uncommon / rootwarden | moss-tufted ball, birch-bark band, five beaded catkins arching outward | gold sneeze: three pollen puffs and a sparkle | the prongs are now lumpy, beaded catkins; the pollen puffs read at both sizes |
| bb-chimney-nest | uncommon / seedkeeper | brick chimney (the face) on a slate roof slice, stone cap, wide twig nest, dozing stork with a red bill | striped sock drying on a nest twig | full rebuild: the loaf-on-a-box shape is gone; the perch keeps a clean plaster face panel |
| bb-homing-stork | rare / wayfinder | white stork mid-stride, black flight feathers, S-neck, red bill and legs, gold scarf with a streaming end; 2 sparkles | a tiny cottage with a lit window hanging from its bill | the teal wing and thin legs are gone; the house is now readable |
| dw-sherbet-sip | common / brewroot | peach Moroccan teapot with gold bands, domed lid, mint sprig, looped handle | one drop hopping out of the tea glass | the arm is gone: its own spout swoops above its head and pours a 2 px stream into a gold-rimmed glass |
| dw-scarab-roll | common / wayfinder | side-view iridescent scarab, striated elytra, round face thorax, clubbed antenna, 2 px jointed legs, large sand ball | gold coin stuck in the ball | larger eyes, legs and coin |
| dw-lantern-lark | common / seedkeeper | crested lark sitting on a sagging lantern string, 3/4 head, open beak, streaked breast, wing with feather rows, two paper lanterns | the sung note is violet | the wing smear now has feather rows; the perch has a pale face mask so the pill eyes read |
| dw-canyon-crown | uncommon / rootwarden | sandstone boulder, rose-red cliff-band crown with a mesa, an arched butte and a spire, with strata | tiny cactus rooted on the mesa | the arch is now a clear enclosed hole (7x8 in the yard, 3x4 on the perch); the body is sand, not grey |

Weakest: the chimney-nest twig texture reads more as noise than as single sticks, and the nest is a flat ellipse. The scarab-roll yard is wide and low, which leaves empty space at the top. The perch strings and pour streams are only 1-2 px.

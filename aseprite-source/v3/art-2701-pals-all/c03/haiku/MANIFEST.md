# Puzzle Pals chunk 3, Haiku first pass (art-2701-pals-all/c03/haiku)

Chunk 3 = `worklist.json[3]`: bb-* and dw-* (birchbramble, dunewhisper). Each pal has a yard sprite 64x64
(`<name>-yard.*`) and a hand-built perch sprite 36x36 (`<name>-perch.*`), each with `.lua`, `.aseprite`, `.png`.
`_haiku.lua` is the shared helper (copy of c02's). All 16 pass `HP.assertClean` (0 semi-transparent, 0 pure
black/white). Shape and knob from the worklist are not drawn; calling and rarity are reflected in the design.

| key | name | rarity / calling | design | quirk | weak spots |
|---|---|---|---|---|---|
| bb-samovar-puff | Samovar Puff | common / brewroot | brass samovar, chimney, left handle, drip spout | tea drips from the spout onto a saucer | steam wisps read as two grey balls on top; spout is thin |
| bb-catkin-crown | Catkin Crown | uncommon / rootwarden | moss blob, gold band, four catkins | gold pollen sneeze sprays out to the right | catkins read as prongs; pollen spray faint at perch size |
| bb-chimney-nest | Chimney Nest | uncommon / seedkeeper | twig nest on a brick chimney, cream stork rising out | red bow tied on the nest rim | nest reads as a loaf; brick reads as a box; stork neck thin |
| bb-homing-stork | Homing Stork | rare / wayfinder | tall cream stork, gold beak and scarf, teal wing | house bundle on its back with a lit window; two sparkles (rare fancier) | house bundle small at 64 px; perch legs thin |
| dw-sherbet-sip | Sherbet Sip | common / brewroot | squat peach teapot, mint sprig on lid, long high spout | thin mint stream from the spout into a gold cup | stream is 1 px wide at yard size; eyes small |
| dw-scarab-roll | Scarab Roll | common / wayfinder | teal domed beetle pushing a sand ball | gold coin stuck in the sand ball | coin is only 2x2; perch legs and eye are small |
| dw-lantern-lark | Lantern Lark | common / seedkeeper | sand-brown lark on a branch, lantern on a thread from the beak | gold music note floats above the lantern | wing reads as a smear; perch eye is small in a small head |
| dw-canyon-crown | Canyon Crown | uncommon / rootwarden | grey stone blob, rose-red crown of three peaks | natural arch cut through the middle peak | arch is 2 px tall at yard size and hard to read; crown peaks thin at perch size |

Edge contact (perch, 0-1 px margin): homing-stork (right), lantern-lark (right), scarab-roll (left). Nothing clipped.
Weakest overall: chimney-nest (the nest and brick chimney read as blocks). Opus passes should fix silhouettes first.

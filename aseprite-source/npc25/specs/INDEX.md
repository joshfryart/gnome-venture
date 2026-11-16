# NPC 2.5D specs: index (stage 1)

Stage 1 output for the 23 remaining species. Hedgehog and tortoise are done (`hedgehog.md`, `tortoise.md`). Gnome NPCs reuse the player rig and are skipped. 'Mouse' NPCs use field-mouse.

| species | body plan | quirk | batch | helper (draft_common.lua) | head top T / width W |
|---|---|---|---|---|---|
| bat | flyer | umbrella | 8 | none (write draw_figure) | 7 / 44 |
| beetle | six-legged | tiny parcel | 5 | none (write draw_figure) | 8 / 36 |
| bumblebee | flyer | honey pot | 7 | none (write draw_figure) | 8 / 40 |
| butterfly | flyer | ribbon | 7 | none (write draw_figure) | 8 / 42 |
| cricket | hopper | fiddle bow | 3 | none (write draw_figure) | 7 / 40 |
| dormouse | biped (mammal) | nightcap | 2 | `M.draw` | 9 / 38 |
| dragonfly | flyer | pocket watch | 7 | none (write draw_figure) | 8 / 46 |
| field-mouse | biped (mammal) | wheat stalk | 1 | `M.draw` | 9 / 40 |
| firefly | flyer | glowing bulb | 8 | none (write draw_figure) | 8 / 36 |
| frog | hopper | lily-pad hat | 3 | none (write draw_figure) | 9 / 36 |
| gecko | biped (mammal) | scarf | 2 | `M.draw` | 9 / 40 |
| grasshopper | hopper | satchel | 3 | none (write draw_figure) | 7 / 38 |
| hare | hopper | walking stick | 4 | none (write draw_figure) | 7 / 36 |
| ladybird | six-legged | spotted umbrella bag | 5 | none (write draw_figure) | 9 / 40 |
| mole | biped (mammal) | mining lamp | 2 | `M.draw` | 9 / 40 |
| moth | flyer | lantern shade | 8 | none (write draw_figure) | 8 / 42 |
| shrew | biped (mammal) | pencil behind ear | 1 | `M.draw` | 9 / 42 |
| snail | crawler | mail satchel on the shell | 6 | none (write draw_figure) | 8 / 44 |
| stag-beetle | six-legged | tiny shield | 5 | none (write draw_figure) | 8 / 40 |
| stick-insect | six-legged | twig-hat | 6 | none (write draw_figure) | 7 / 34 |
| toad | hopper | mossy hat | 4 | none (write draw_figure) | 9 / 38 |
| wood-mouse | biped (mammal) | acorn-cap helmet | 1 | `M.draw` | 9 / 40 |
| wren | flyer | tiny scroll | 8 | none (write draw_figure) | 9 / 40 |

## Batches (parallel Opus runs, grouped by body plan)

- Batch 1: field-mouse, wood-mouse, shrew (biped (mammal))
- Batch 2: mole, dormouse, gecko (biped (mammal))
- Batch 3: cricket, frog, grasshopper (hopper)
- Batch 4: hare, toad (hopper)
- Batch 5: beetle, ladybird, stag-beetle (six-legged)
- Batch 6: stick-insect, snail (crawler, six-legged)
- Batch 7: bumblebee, butterfly, dragonfly (flyer)
- Batch 8: firefly, moth, wren, bat (flyer)

## Notes for stages 2-4
- Body plans: biped 6 (field-mouse, wood-mouse, shrew, mole, dormouse, gecko), hopper 5 (cricket, frog, grasshopper, hare, toad), six-legged 4 (beetle, ladybird, stag-beetle, stick-insect), flyer 7 (bumblebee, butterfly, dragonfly, firefly, moth, wren, bat), crawler 1 (snail).
- Gecko is not in the brief's plan list; folk art stands upright, so it is specced as biped.
- Helper: only `draft_common.lua` `M.draw` exists and it is a biped draft. Hopper, six-legged, crawler and flyer need a `draw_figure` written in stage 2 (or in stage 3 for the species file).
- Flyers have no ground shadow; the dangling left foot holds row 71. Hoppers keep the shadow, which keeps row 71 opaque on airborne frames.
- check.py: `SPEC` only has hedgehog and tortoise. Add each species' (T, W) from the table, and an apex allowance of T-3 for hopper and flyer (walk frame 5), as in the specs.
- Sources: 19 species have folk art (`folk-<s>-1..3`). Bat, dormouse, stag-beetle and stick-insect have none; their colours come from the NPC sprites (`npc-gloam`, `npc-pomeroy-crumbworth`, `npc-bracken-spurwing`, `npc-old-twigg`), and looks 2-3 are derived.
- Quirk overlap: grasshopper `satchel` and snail `mail satchel` are both from the brief. They are kept apart by colour (tan strap vs brown with cream letter); flag it if a player can confuse them at 16 px.
- Walk tables are per body plan and were checked for six distinct rows each (no two identical).

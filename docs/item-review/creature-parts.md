# Creature parts: uses proposal (decisions locked: per-tool augment columns, family currencies, compost no cap, Plate Edge 25% / 40 uses)

## Families (match by slug suffix, like Sight `take=any-<suffix>`)
| Family | Suffixes |
|---|---|
| Hide | pelt, skin, hide, fur, hair, wool, mane, tuft, fluff |
| Plate | shell, scale, scute, plate, husk, claw, horn, fang, tooth, pincer, spine, quill, stinger |
| Wing | feather, plume, wing, down |
| Ooze | slime, gland, sac, ink, dust |
| Silk | silk, thread, ball |
| Gem | pearl, bead |

Code: one helper `part_family(slug)`; extend `craft_stock` (crafting.php:163) so recipes can ask `any-hide:3`.

## Alchemy tool augments (new columns user_items.aug VARCHAR, aug_left INT; one augment per tool copy; migration needed)
| Augment | Cost | Effect |
|---|---|---|
| Hide Binding I/II | 3 Hide + rope / +beeswax or rare Hide | +25% / +50% wear limit |
| Plate Edge | 5 Plate + flint | 25% chance a find rolls one rarity up, 40 uses |
| Wing Fletch | 4 Wing | extra forage bonus roll, 25 uses |
| Gem Charm | 1 Gem + 2 Ooze | luck bonus on finds/drops, 30 uses |
| Ooze Salve | 3 Ooze | next 3 mends cost 0 Petals (counts as free shed mend; fixes EC7) |
| Silk Splice | 4 Silk + tool-repair-kit | Broken tool becomes mendable by kit (reforge path) |

Augments sell for less than inputs. Augment is lost when the tool breaks unless Silk Splice used.

## Compost (no cap, per decision)
Hide/Wing/Silk part = 3 scraps; Ooze = 4 scraps toward worm-castings; Plate grinds to shell-meal (1 part -> 1). Adds an "Add parts" button to the Compost Bin. Setting `part_scrap_value` (admin) per family.

## Other sinks
- Tailor: wearable materials accept any-hide / any-silk / any-wing (absorbs the 112 identical pairs)
- Build plans: stages accept any-plate / any-hide
- Pals/pets: treats and nests from Hide; Wing for pal growth
- Creature Codex: donate 3 parts of a creature to complete its entry (one-time reward)
- Hovel: trophy wall displays one part per creature
- NPC quests: Tanner weekly Hide/Plate lots; Pomeroy wants Ooze; collector wants one rare part per region; rag-and-bone buyer pays flat low rate (price floor)
- Fair/contests: creature diorama category
- Gifts: NPCs like specific families

## Open questions
See chat.

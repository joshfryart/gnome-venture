# The 42 legendary crop pieces: draft for review (nothing built)

2026-11-15. Follows Josh's answers: **legendary = the 42 "treasure" crops** (`region_crops.txt`, the ones that give a permanent stat bonus); **unlocked by harvesting the crop N times** (proposal: N = 5); **strength follows your mastery of that crop** (rank I to IV adds +0 / +2 / +4 / +5, as crop pieces do now); **the piece matches the crop's stat** (fruit and tree = luck, nut = lore, spice = charm, sugarcane = grit); **build 2 or 3 new effects** (Keeper, Plenty, Simmer: two pieces each).

Values are the rank I value. They count for the Larder (3, 4 at level 10, 5 at level 20): a legendary piece competes with the kind pieces for those slots. The three kinds of effect words are the ones already in the game (Pierce, Bash, Hold, Thorns, Evade, Poison, Trip, Bond, Hum, Lull, Pluck and the built-in knacks Tender, Leech, Spiky, Soft touch, Warm, Finisher, Hardy). Words in CAPITALS are the new effects.

## The three new effects (each is on two pieces)

| Effect | Text | Engine work | Pieces |
|---|---|---|---|
| **KEEPER** | Keeps in your hand until you play it | `pfb_end_round`: the redraw loop skips a Keeper piece; `pf_draw` then fills to 5; JS twin | Cranberry Preserve, Quince Jelly |
| **PLENTY** | Next round you pick from 6 pieces | `pf_apply` sets a flag on the player; `pfb_end_round` deals one more (the mirror of the creature's Trip, which deals one fewer); JS twin | Buckthorn Zing, Coffee Rush |
| **SIMMER** | Heals you 2 at the start of your next 2 turns | `pf_apply` sets 2 charges; tick beside the poison tick in `pfb_end_round`; JS twin; a replay line like poison's | Pecan Pie, Tea Leaf |

Each needs: the hook in PHP and the JS twin, a line in `PF_TAGS_V1` and the icon, tests, the parity run, and the bots taught what a kept piece, a sixth piece and a heal over time are worth (`pfb_score`), then a balance sim with these in the deck. Estimated 2 to 3 days of work for the three.

## The pieces

| # | Crop | Stat | Piece | Type | Value | Effect | Text |
|---|---|---|---|---|---|---|---|
| 1 | Blueberry | luck | **Blueberry Burst** | Heal | 4 | Tender (+2) | Heals a bit more than it looks. |
| 2 | Cloudberry | luck | **Cloudberry Gold** | Item | 5 | Soft touch | A rare sweet snack; also calms the creature. |
| 3 | Cranberry | luck | **Cranberry Preserve** | Guard | 5 | KEEPER | Keeps in your hand until you play it. |
| 4 | Gooseberry | luck | **Gooseberry Prickle** | Guard | 4 | Spiky | Pricks the creature for 2 when played. |
| 5 | Sea Buckthorn | luck | **Buckthorn Zing** | Heal | 5 | PLENTY | Next round you pick from 6 pieces. |
| 6 | Sugarcane | grit | **Cane Crush** | Hurt | 6 | Leech | Heals you a little when it hits. |
| 7 | Almond | lore | **Almond Crack** | Hurt | 5 | Pierce | Ignores the creature's guard. |
| 8 | Brazil Nut | lore | **Brazil Nut Bash** | Hurt | 6 | Bash | Adds your guard to the hit, using it up. |
| 9 | Cashew | lore | **Cashew Calm** | Soothe | 5 | - | Its next hits do less. |
| 10 | Chestnut | lore | **Chestnut Roast** | Hurt | 5 | Warm | A quarter of its damage also counts as Charm. |
| 11 | Hazelnut | lore | **Hazelnut Hide** | Guard | 4 | Hold | Some guard stays up into your next turn. |
| 12 | Kola Nut | lore | **Kola Jolt** | Hurt | 5 | Finisher | +3 when the Yield bar is past 60%. |
| 13 | Macadamia | lore | **Macadamia Smash** | Hurt | 7 | - | The plain big hit. |
| 14 | Pecan | lore | **Pecan Pie** | Heal | 5 | SIMMER | Heals you 2 at the start of your next 2 turns. |
| 15 | Pistachio | lore | **Pistachio Pop** | Trick | 3 | Pluck | Tries to lift an item from the creature. |
| 16 | Shea | lore | **Shea Shield** | Guard | 4 | Hardy (+2) | A thick butter coat. |
| 17 | Walnut | lore | **Walnut Crack** | Hurt | 6 | Pierce | Ignores the creature's guard. |
| 18 | Saffron Crocus | charm | **Saffron Thread** | Charm | 6 | Bond | The creature warms to Charm for the fight. |
| 19 | Caper | charm | **Caper Pop** | Guard | 3 | Evade | The creature's first hit misses. |
| 20 | Cardamom | charm | **Cardamom Hum** | Charm | 5 | Hum | It will not hit as hard this turn. |
| 21 | Grains of Paradise | charm | **Paradise Lull** | Charm | 5 | Lull | It loses its next turn. |
| 22 | Black Pepper | charm | **Pepper Sting** | Hurt | 5 | Poison | Hits again for the next 2 turns. |
| 23 | Cinnamon | charm | **Cinnamon Swirl** | Charm | 5 | Soft touch | Also calms the creature. |
| 24 | Clove | charm | **Clove Prick** | Hurt | 4 | Trip | It skips its next turn. |
| 25 | Ginseng | charm | **Ginseng Root** | Heal | 6 | Tender (+2) | Heals 2 more. |
| 26 | Nutmeg | charm | **Nutmeg Whisper** | Charm | 6 | Hum | It will not hit as hard this turn. |
| 27 | Vanilla | charm | **Vanilla Cream** | Charm | 6 | Soft touch | Also calms the creature. |
| 28 | Wasabi | charm | **Wasabi Burn** | Hurt | 6 | Poison + Finisher | Poison, and +3 late in the fight. |
| 29 | Tea | luck | **Tea Leaf** | Heal | 3 | SIMMER | Heals you 2 at the start of your next 2 turns. |
| 30 | Açaí | luck | **Açaí Bowl** | Heal | 5 | Soft touch | Heals and calms the creature. |
| 31 | Ackee | luck | **Ackee Surprise** | Item | 4 | Tender (+2) | A snack that heals more. |
| 32 | Baobab | luck | **Baobab Bark** | Guard | 6 | Hold | Guard that stays up into your next turn. |
| 33 | Cacao | luck | **Cacao Bite** | Charm | 5 | Bond | The creature warms to Charm for the fight. |
| 34 | Carob | luck | **Carob Crust** | Guard | 5 | Hardy (+2) | A thick crust. |
| 35 | Coffee | luck | **Coffee Rush** | Hurt | 4 | PLENTY | Next round you pick from 6 pieces. |
| 36 | Durian | luck | **Durian Stink** | Guard | 5 | Thorns | Hurts the creature when it hits you. |
| 37 | Finger Lime | luck | **Lime Pearls** | Heal | 4 | Soft touch | Pops sour, heals, and calms the creature. |
| 38 | Kava | luck | **Kava Calm** | Soothe | 6 | - | Its next hits do less. |
| 39 | Mangosteen | luck | **Mangosteen Gold** | Heal | 6 | - | The plain big heal. |
| 40 | Quince | luck | **Quince Jelly** | Guard | 6 | KEEPER | Keeps in your hand until you play it. |
| 41 | Salak | luck | **Snakeskin Plate** | Guard | 5 | Evade | The creature's first hit misses. |
| 42 | Yuzu | luck | **Yuzu Zest** | Item | 4 | Soft touch | A sharp snack; also calms the creature. |

## Checks I made

- 42 pieces, one per treasure crop, no crop left out (the list comes from `region_crops.txt`).
- No two pieces share the same type, effect and value (checked by script on this draft; a test would enforce it).
- Balance: values 3 to 7 at rank I; the strongest plain hits are Macadamia Smash (Hurt 7) and the poison / finisher mixes (Hurt 6). Today's kind pieces sit at 3 to 5. A test would require every legendary piece to be within +2 of a same-type kind piece at the same rank.
- Types by stat: lore (11 nuts) = Hurt, Soothe, Guard, Pluck; charm (11 spices) = Charm and poison Hurts; luck (19 fruit and trees) = Heal, Item, Guard, Charm, Soothe; grit (sugarcane) = Hurt. The family spread keeps a Larder of 3 to 5 able to cover Hurt, Guard, Heal and Charm.

## Things to decide

1. **N for the unlock** (harvests of that crop). I proposed 5. The legendary crops take 5 to 6 time units to grow, so 5 harvests is a real commitment; 3 would be kinder.
2. **Your look at the 42.** Tell me which to change. Typical edits: swap an effect, move a value, rename.
3. **What happens to the 9 kind pieces?** They stay for the common crops, so Garden Greens and the others do not go away.
4. **Cacao, Tea, Coffee** are the three most player-known names here. They carry Charm, Simmer and Plenty: say if you would rather Coffee were Hurt-heavy and Cacao a heal.
5. **Art:** one tinted generic crop piece picture per piece for now; hero art later if you want it.

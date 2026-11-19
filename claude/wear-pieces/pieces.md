# Wearable puzzle pieces v2: unique effects (280)

Written against the 2.7.00 quick rules (fixed rank order, a placed piece always touches and fits a neighbour, one piece a turn, Keeper only on Guards). No effect talks about firing order or a lone piece. Each is its own trigger + payoff pair (210) or a hand-written rule (70 Rare). Needs new engine support (`design3.py` TRIG/PAY); nothing is installed in `game/`.

**Value** is the piece base (the game adds stat, level/3 and rank: Lined +2, Fine +4). **Petals** = Tailor price of the Common rank; Lined x1.5, Fine x2.5. **Tailor** = lowest Tailor level that can craft it. Numbers inside effects ({a}, {b}) grow with region and rarity.

## The Maplewold (NA, region level 1)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Sugarbush Snow Boots | Common | **Snowdrift Trip** | hurt | 3 | If a creature piece is in its chain, the creature skips its next turn. | 1200 | 1 |
| 2 | Birchwood Clog | Common | **Clog Knock** | hurt | 3 | If it sits on the creature's aim cell, deal 2 extra damage. | 1200 | 1 |
| 3 | Lakeland Snowshoe | Uncommon | **Snowshoe Skim** | guard | 4 | If you played no Hurt last turn, the creature's next Hurt misses. | 3200 | 2 |
| 4 | Prairie Stitch Boots | Uncommon | **Prairie Kick** | hurt | 4 | If it is linked to a Guard, it ignores the creature's guard. | 3200 | 2 |
| 5 | Loon-Down Slippers | Rare | **Loon Hush** | soothe | 4 | Cuts the creature's hits by 4 this round. If its Yield bar is under half, your next hand has 1 extra piece. | 8000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Splint Pack Basket | Common | **Splint Stash** | item | 4 | If you hold 2 or more Hurts in your hand, your next hand has 1 extra piece. | 1200 | 1 |
| 2 | Firewood Pack Frame | Common | **Hearth Warmth** | heal | 2 | If you are under half health, heal 1 at the start of each of your next 2 turns. | 1200 | 1 |
| 3 | Portage Sack | Uncommon | **Portage Dig** | trick | 3 | If the creature has no Hurt on the board, small chance to lift an item from the creature. | 3200 | 2 |
| 4 | Sap-Run Bucket | Uncommon | **Syrup Snack** | item | 5 | In the first two rounds of the fight, heal 3. | 3200 | 2 |
| 5 | Toboggan Pack | Rare | **Toboggan Run** | hurt | 6 | Deals its number plus 2 for every piece in its chain. | 8000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Lumber-Check Jacket | Common | **Check Wall** | guard | 3 | If the creature hit you last turn, each hit this guard blocks adds 1 to the bar. | 1200 | 1 |
| 2 | Goldenrod Down Vest | Common | **Down Puff** | guard | 3 | If an environment piece is in its chain, gain 2 guard. | 1200 | 1 |
| 3 | Prairie Duster | Uncommon | **Duster Mend** | guard | 4 | If it is linked to a Guard, heal 3. | 3200 | 2 |
| 4 | Lodge Cardigan | Uncommon | **Cardigan Calm** | soothe | 2 | If you are under half health, cut the creature's hits by 1 this round. | 3200 | 2 |
| 5 | Frostline Parka | Rare | **Parka Bulwark** | guard | 6 | Gain 4 guard that stays up one more turn. If the creature has a Hurt on the board, each hit it blocks adds 2 to the bar. | 8000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Maple Mantle | Common | **Maple Flutter** | trick | 2 | If it is linked to a Hurt, the piece it links to gets +1. | 1200 | 1 |
| 2 | Birch Poncho | Common | **Chickadee Chirp** | charm | 3 | If the creature has a Guard on the board, add 2 Charm. | 1200 | 1 |
| 3 | Northern Lights Cloak | Uncommon | **Aurora Sheen** | charm | 4 | If its Yield bar is past half, your Charm counts 10% more for the rest of the fight. | 3200 | 2 |
| 4 | Harbour Slicker Cape | Uncommon | **Slicker Shrug** | guard | 4 | If the creature has guard up, the creature's next Hurt misses. | 3200 | 2 |
| 5 | Pine-Needle Shawl | Rare | **Pine Wrap** | guard | 6 | Keeper. Gain 4 guard. The turn you play it, your next Charm this fight also adds 4. | 8000 | 3 |

## Maizehollow (CA, region level 4)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Lattice Huaraches | Common | **Huarache Dash** | hurt | 3 | If it sits next to the creature's aim cell, your next hand has 1 extra piece. | 1500 | 1 |
| 2 | Tooled Ankle Boots | Common | **Tooled Stomp** | hurt | 3 | If it is linked to a Guard, deal 2 extra damage. | 1500 | 1 |
| 3 | Indigo Leg Wraps | Uncommon | **Leg-Wrap Brace** | guard | 4 | If the creature has a Hurt on the board, it stays 1 more round(s) on the board. | 4000 | 2 |
| 4 | Ixtle Slippers | Uncommon | **Ixtle Slip** | guard | 4 | If the creature hit you last turn, the creature's next Hurt misses. | 4000 | 2 |
| 5 | Market Platform Clogs | Rare | **Platform Thud** | hurt | 6 | Deal 4 extra damage. If it is linked to a Guard (Riposte), the creature's strongest piece also loses 2. | 10000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Carrier Frame | Common | **Carrier Grip** | guard | 3 | If you hold a Guard in your hand, gain 2 guard. | 1500 | 1 |
| 2 | Maize Net Bag | Common | **Maize Net Bite** | item | 4 | If you are under half health, heal 2. | 1500 | 1 |
| 3 | Palm Basket Pack | Uncommon | **Basket Rummage** | trick | 3 | If its chain has 3 or more pieces, small chance to lift an item from the creature. | 4000 | 2 |
| 4 | Loom-Cloth Bundle | Uncommon | **Bundle Poultice** | heal | 3 | If you are poisoned, end your poison and heal 1. | 4000 | 2 |
| 5 | Dry-Spell Water Pack | Rare | **Water-Pack Sip** | heal | 5 | Heal 4 and next round pick from 6 pieces. If your chain has no Guard, heal 2 more. | 10000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Bloom Smock | Common | **Smock Bloom** | guard | 3 | If you hold a Charm in your hand, each hit this guard blocks adds 1 to the bar. | 1500 | 1 |
| 2 | Pleated Shirt-Jacket | Common | **Pleat Shield** | guard | 3 | In the first two rounds of the fight, the next Guard you place gets +2. | 1500 | 1 |
| 3 | Fringed Leather Vest | Uncommon | **Fringe Sway** | guard | 4 | If it sits on the edge of the board, the creature's next Hurt misses. | 4000 | 2 |
| 4 | Quilted Cotton Coat | Uncommon | **Quilt Wall** | guard | 4 | If you have played 2 or more Guards this fight, it stays 1 more round(s) on the board. | 4000 | 2 |
| 5 | Indigo Field Jacket | Rare | **Indigo Mend** | guard | 6 | Gain 4 guard and heal 2. Each hit it blocks heals you 2 more. | 10000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Hearthstripe Poncho | Common | **Hearth Stripe** | charm | 3 | If you took no damage last turn, add 2 Charm. | 1500 | 1 |
| 2 | Dappled Rebozo | Common | **Rebozo Hum** | charm | 3 | If it sits in one of the four inner cells, cut the creature's hits by 1 this round. | 1500 | 1 |
| 3 | Palm Rain Cape | Uncommon | **Palm Cape Calm** | soothe | 2 | If the creature has 2 or more pieces on the board, the creature's strongest piece loses 1. | 4000 | 2 |
| 4 | Agave-Fibre Mantle | Uncommon | **Fibre Veil** | trick | 3 | If it sits in a corner, the next Hurt you place gets +3. | 4000 | 2 |
| 5 | Sun Hood Cloak | Rare | **Sun-Hood Shade** | guard | 6 | Gain 4 guard. If its Yield bar is past half, also cut the creature's hits by 2 this round. | 10000 | 3 |

## Mistmoor (NWE, region level 6)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Alder Clogs | Common | **Alder Splash** | guard | 3 | If it sits on the creature's aim cell, the creature's next Hurt misses. | 1800 | 1 |
| 2 | Drain Brogues | Common | **Brogue Drain** | guard | 3 | If it is linked to a Guard, end your poison and heal 1. | 1800 | 1 |
| 3 | Felted Fleece Boots | Uncommon | **Felt Hush** | soothe | 2 | If you hold a Guard in your hand, cut the creature's hits by 1 this round. | 4800 | 2 |
| 4 | Birch-Bark Slippers | Uncommon | **Bark Slip** | hurt | 4 | If the creature has a Hurt on the board, a chain of 3 or more does not use it up. | 4800 | 2 |
| 5 | Herringbone Gaiters | Rare | **Gaiter Lunge** | hurt | 6 | Pierce. If it is linked to a Trick (Ambush), your next hand has 1 extra piece. | 12000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Peat Creel | Common | **Creel Catch** | trick | 2 | From round 3 on, small chance to lift an item from the creature. | 1800 | 1 |
| 2 | Waxed Roll-top | Common | **Roll-Top Snack** | item | 4 | If your discard pile holds 5 or more pieces, your next hand has 1 extra piece. | 1800 | 1 |
| 3 | Heather Frame | Uncommon | **Heather Rest** | heal | 3 | If you played no Hurt last turn, heal 1 at the start of each of your next 2 turns. | 4800 | 2 |
| 4 | Bark Box Pack | Uncommon | **Bark Box Fort** | guard | 4 | If you hold 2 or more Hurts in your hand, Keeper: it stays in your hand if you do not play it. | 4800 | 2 |
| 5 | Fleece Bundle | Rare | **Bundle Bind** | guard | 6 | Keeper. While it waits in your hand, every other Guard you place gets +2. | 12000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Cable-Knit Long Coat | Common | **Cable Wall** | guard | 3 | If the creature has 2 or more pieces on the board, gain 3 guard. | 1800 | 1 |
| 2 | Waxed Field Jacket | Common | **Waxed Shed** | guard | 3 | If the creature hit you last turn, the creature's strongest piece loses 1. | 1800 | 1 |
| 3 | Tweed Waistcoat | Uncommon | **Tweed Thorn** | guard | 4 | If its chain has 3 or more pieces, each hit this guard blocks adds 1 to the bar. | 4800 | 2 |
| 4 | Tanbark Smock | Uncommon | **Tanbark Mend** | guard | 4 | If it is linked to a Guard, heal 1 at the start of each of your next 2 turns. | 4800 | 2 |
| 5 | Eiderdown Coat | Rare | **Eiderdown Nest** | guard | 6 | Gain 5 guard that stays up one more turn. If you are under half health, heal 2 as well. | 12000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Heather Shawl | Common | **Heather Hum** | charm | 3 | If the creature has guard up, cut the creature's hits by 1 this round. | 1800 | 1 |
| 2 | Mustard Rain Cape | Common | **Mustard Drizzle** | soothe | 2 | If a creature piece is in its chain, cut the creature's hits by 1 this round. | 1800 | 1 |
| 3 | Sheepskin Mantle | Uncommon | **Sheepskin Snug** | charm | 4 | If it is linked to a Guard, add 4 Charm. | 4800 | 2 |
| 4 | Rush Thatch Cape | Uncommon | **Thatch Drip** | guard | 4 | If you took no damage last turn, the creature's next Hurt misses. | 4800 | 2 |
| 5 | Woad Mist Cloak | Rare | **Woad Moth** | trick | 5 | The piece it links to gets +5. If that piece is a Charm, it also cuts the creature's hits by 2 this round. | 12000 | 3 |

## The Sunsprinkle Isles (CB, region level 8)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Plait Sandals | Common | **Palm-Plait Skip** | guard | 4 | If it sits on the edge of the board, a chain of 3 or more does not use it up. | 2100 | 1 |
| 2 | Mahogany Clogs | Common | **Mahogany Clack** | hurt | 4 | If it is linked to a Guard, the next Hurt you place gets +3. | 2100 | 1 |
| 3 | Sisal-Sole Slippers | Uncommon | **Sisal Soft-Step** | hurt | 5 | If an environment piece is in its chain, deal 4 extra damage. | 5600 | 2 |
| 4 | Mangrove Gaiters | Uncommon | **Mangrove Grip** | guard | 5 | If it sits in a corner, it stays 1 more round(s) on the board. | 5600 | 2 |
| 5 | Curl-Toe Reef Booties | Rare | **Reef Hop** | hurt | 6 | Trip: the creature skips its next turn. If its chain has 3 or more pieces, the creature's strongest piece also loses 2. | 14000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Market Basket Pack | Common | **Market Haul** | item | 5 | From round 3 on, heal 3. | 2100 | 1 |
| 2 | Calabash Carrier | Common | **Calabash Brew** | heal | 3 | If you are at full health, heal 1 at the start of each of your next 2 turns. | 2100 | 1 |
| 3 | Net-Roll Bundle | Uncommon | **Net-Roll Snare** | trick | 4 | If the creature has 2 or more pieces on the board, remove the creature's weakest piece from the board. | 5600 | 2 |
| 4 | Batik Sea Sack | Uncommon | **Sea-Sack Salve** | heal | 4 | If the creature hit you last turn, heal 4. | 5600 | 2 |
| 5 | Bamboo Frame Pack | Rare | **Bamboo Bounty** | heal | 6 | Heal 5. Next round pick from 6 pieces, or from 7 if you hold a Guard in your hand. | 14000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Breeze Smock | Common | **Breeze Smock** | guard | 4 | If it sits next to the creature's aim cell, the creature's next Hurt misses. | 2100 | 1 |
| 2 | Indigo Wrap-Coat | Common | **Wrap Wall** | guard | 4 | If it is linked to a Hurt, the next Guard you place gets +3. | 2100 | 1 |
| 3 | Check-Weave Jacket | Uncommon | **Weave Thorn** | guard | 5 | If the creature has guard up, each hit this guard blocks adds 1 to the bar. | 5600 | 2 |
| 4 | Sailcloth Longcoat | Uncommon | **Sailcloth Brace** | guard | 5 | From round 3 on, it stays 1 more round(s) on the board. | 5600 | 2 |
| 5 | Sunset Batik Vest | Rare | **Sunset Mend** | guard | 7 | Gain 5 guard. When this guard soaks a Hurt, heal 2 and add 2 Charm. | 14000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Thatch Rain Cape | Common | **Thatch Hush** | soothe | 2 | If you are under half health, the creature skips its next turn. | 2100 | 1 |
| 2 | Hibiscus Shawl | Common | **Hibiscus Charm** | charm | 4 | If you hold a Charm in your hand, your Charm counts 10% more for the rest of the fight. | 2100 | 1 |
| 3 | Sea-Breeze Poncho | Uncommon | **Breeze Poncho** | trick | 4 | If it is linked to a Guard, a chain of 3 or more does not use it up. | 5600 | 2 |
| 4 | Mangrove Hood | Uncommon | **Mangrove Cover** | guard | 5 | If you played no Hurt last turn, Keeper: it stays in your hand if you do not play it. | 5600 | 2 |
| 5 | Shell-Scallop Capelet | Rare | **Scallop Shine** | charm | 7 | Add 5 Charm. If it is linked to 2 or more pieces, the creature skips its next turn. | 14000 | 3 |

## Olivewhistle Shore (SE, region level 10)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Shoreline Rope Slips | Common | **Rope-Slip Slide** | hurt | 4 | If it sits on the edge of the board, your next hand has 1 extra piece. | 2400 | 1 |
| 2 | Sunpath Sandals | Common | **Sunpath Stride** | guard | 4 | If its chain has 3 or more pieces, a chain of 3 or more does not use it up. | 2400 | 1 |
| 3 | Corkbark Clogs | Uncommon | **Cork Knock** | hurt | 5 | If the creature has guard up, it ignores the creature's guard. | 6400 | 2 |
| 4 | Thyme-Hill Wraps | Uncommon | **Wrap Stay** | guard | 5 | If you took no damage last turn, it stays 2 more round(s) on the board. | 6400 | 2 |
| 5 | Harvest Treaders | Rare | **Harvest Tread** | hurt | 7 | Deal 6 extra damage and heal 3 for each Guard in its chain. | 16000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Olive Picker's Creel | Common | **Creel Pick** | item | 5 | If you hold a Guard in your hand, next round you pick from 6 pieces. | 2400 | 1 |
| 2 | Fisher's Float Net | Common | **Float-Net Haul** | trick | 3 | If its Yield bar is past a quarter, your next hand has 1 extra piece. | 2400 | 1 |
| 3 | Amphora Frame | Uncommon | **Amphora Pour** | heal | 4 | In the first two rounds of the fight, heal 2 at the start of each of your next 2 turns. | 6400 | 2 |
| 4 | Sailcloth Seabag | Uncommon | **Seabag Stash** | item | 6 | If your discard pile holds 5 or more pieces, heal 5. | 6400 | 2 |
| 5 | Lemon-Grove Satchel | Rare | **Lemon Zest** | heal | 6 | Heal 6 and cut the creature's hits by 3 this round. If the creature has guard up, add 3 Charm too. | 16000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Net-Mender's Smock | Common | **Mender Wall** | guard | 4 | If it sits next to the creature's aim cell, each hit this guard blocks adds 2 to the bar. | 2400 | 1 |
| 2 | Goatherd's Fleece Vest | Common | **Vest Hold** | guard | 4 | If you are under half health, it stays 2 more round(s) on the board. | 2400 | 1 |
| 3 | Olive-Grove Quilt Jacket | Uncommon | **Olive Quilt** | guard | 5 | If you hold a Charm in your hand, heal 5. | 6400 | 2 |
| 4 | Vintner's Long Coat | Uncommon | **Long Guard** | guard | 5 | If it sits on the edge of the board, the next Guard you place gets +5. | 6400 | 2 |
| 5 | Sun-Stripe Tunic Coat | Rare | **Stripe Spike** | guard | 7 | Gain 6 guard. Each hit it blocks adds 6 to the bar; a Hurt that is fully blocked is removed from the board. | 16000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Shepherd's Felt Cape | Common | **Shepherd Hum** | charm | 4 | If you hold 2 or more Hurts in your hand, cut the creature's hits by 2 this round. | 2400 | 1 |
| 2 | Lemon-Fringe Shawl | Common | **Fringe Soft** | charm | 4 | If it sits in a corner, add 4 Charm. | 2400 | 1 |
| 3 | Loom-Stripe Poncho | Uncommon | **Stripe Tidy** | trick | 4 | If it sits in one of the four inner cells, small chance to lift an item from the creature. | 6400 | 2 |
| 4 | Whitewash Sun Mantle | Uncommon | **Whitewash Glare** | guard | 5 | If its Yield bar is under a quarter, the creature's next Hurt misses. | 6400 | 2 |
| 5 | Sea-Squall Capelet | Rare | **Squall Lull** | charm | 4 | Add 6 Charm. If it is the only Charm in your chain, the creature skips its next turn. | 16000 | 3 |

## The Rainroot Reaches (SA, region level 12)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Latex Puddle Boots | Common | **Latex Splash** | guard | 4 | If the creature has a Guard on the board, the creature's next Hurt misses. | 2700 | 1 |
| 2 | Puna Wool Booties | Common | **Puna Warm** | guard | 4 | If you have played 2 or more Guards this fight, heal 4. | 2700 | 1 |
| 3 | Plaited Fibre Sandals | Uncommon | **Fibre Stride** | hurt | 5 | If it is linked to a Hurt, your next hand has 1 extra piece. | 7200 | 2 |
| 4 | Balsa Bark Clogs | Uncommon | **Balsa Bump** | hurt | 5 | If you took no damage last turn, deal 5 extra damage. | 7200 | 2 |
| 5 | Striped Leg Wraps | Rare | **Wrap Trip** | hurt | 6 | Trip: the creature skips its next turn. If its chain has 3 or more pieces, deal 6 extra damage. | 18000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Striped Bundle Cloth | Common | **Bundle Basics** | item | 5 | If it is linked to a Hurt, heal 4. | 2700 | 1 |
| 2 | Cone Vine Basket | Common | **Basket Pick** | item | 5 | If it is linked to a Guard, next round you pick from 6 pieces. | 2700 | 1 |
| 3 | Highland Carry Frame | Uncommon | **Highland Carry** | heal | 4 | If its chain has 3 or more pieces, heal 2 at the start of each of your next 2 turns. | 7200 | 2 |
| 4 | Leaf-Flap Satchel | Uncommon | **Flap Rummage** | trick | 4 | If its Yield bar is past half, small chance to lift an item from the creature. | 7200 | 2 |
| 5 | Market Net Bag | Rare | **Net Feast** | heal | 6 | Heal 6, plus 1 for every 2 pieces in your discard pile (up to 3 extra). Next round pick from 6 pieces. | 18000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Fleece Vest | Common | **Fleece Hold** | guard | 4 | If the creature hit you last turn, it stays 2 more round(s) on the board. | 2700 | 1 |
| 2 | Shingle Leaf Smock | Common | **Shingle Thorn** | guard | 4 | If you have played 2 or more Hurts this fight, each hit this guard blocks adds 2 to the bar. | 2700 | 1 |
| 3 | Warp-Stripe Jacket | Uncommon | **Warp Mend** | guard | 5 | If you are poisoned, heal 2 at the start of each of your next 2 turns. | 7200 | 2 |
| 4 | Bark-Cloth Tunic Coat | Uncommon | **Bark Ward** | guard | 5 | If the creature has a Hurt on the board, the creature's strongest piece loses 2. | 7200 | 2 |
| 5 | Kapok Puffer | Rare | **Kapok Cushion** | guard | 7 | Keeper. Gain 6 guard; if it stayed in your hand through a round, gain 6 more. | 18000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Striped Poncho | Common | **Poncho Hum** | charm | 4 | If it is linked to a Guard, your Charm counts 10% more for the rest of the fight. | 2700 | 1 |
| 2 | Thatch Rain Cape | Common | **Thatch Cover** | soothe | 2 | If the creature has a Guard on the board, cut the creature's hits by 2 this round. | 2700 | 1 |
| 3 | Feather Shoulder Mantle | Uncommon | **Feather Flash** | charm | 5 | If its Yield bar is past half, add 5 Charm. | 7200 | 2 |
| 4 | Cloud-Forest Shawl | Uncommon | **Shawl Veil** | trick | 4 | If an environment piece is in its chain, the piece it links to gets +2. | 7200 | 2 |
| 5 | Indigo Hooded Cloak | Rare | **Dusk Lull** | charm | 7 | Add 6 Charm and cut the creature's hits by 3 this round. If its Yield bar is past half, the creature skips its next turn. | 18000 | 3 |

## Birchbramble Steppe (EE, region level 14)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Birchweave Shoes | Common | **Birchweave Hop** | guard | 5 | If you played no Hurt last turn, a chain of 3 or more does not use it up. | 3000 | 1 |
| 2 | Snowdrift Felt Boots | Common | **Boot Hold** | guard | 5 | If the creature has no Hurt on the board, it stays 2 more round(s) on the board. | 3000 | 1 |
| 3 | Poppy Hide Moccasins | Uncommon | **Moccasin Trip** | hurt | 6 | If it sits in a corner, the creature skips its next turn. | 8000 | 2 |
| 4 | Rider's Red Boots | Uncommon | **Rider's Charge** | hurt | 6 | If its chain has 3 or more pieces, deal 5 extra damage. | 8000 | 2 |
| 5 | Sunflower Straw Sandals | Rare | **Straw Sun Skip** | hurt | 8 | If you played no Hurt last turn, deal 6 extra damage and the next Hurt you place gets +3. | 20000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Birchbark Pester | Common | **Pester Pick** | trick | 4 | If it is linked to a Guard, small chance to lift an item from the creature. | 3000 | 1 |
| 2 | Harvest Wicker Basket | Common | **Wicker Feast** | item | 6 | If you hold 2 or more Hurts in your hand, next round you pick from 6 pieces. | 3000 | 1 |
| 3 | Beekeeper's Frame | Uncommon | **Frame Honey** | heal | 5 | If the creature hit you last turn, heal 2 at the start of each of your next 2 turns. | 8000 | 2 |
| 4 | Flat-weave Satchel | Uncommon | **Weave Stash** | item | 7 | If it sits on the edge of the board, heal 5. | 8000 | 2 |
| 5 | Fleece Drawsack | Rare | **Sack Rest** | heal | 7 | Heal 6 and shuffle 3 pieces from your discard pile back into your draw pile. | 20000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Sheepskin Longcoat | Common | **Longcoat Thorn** | guard | 5 | If an environment piece is in its chain, each hit this guard blocks adds 2 to the bar. | 3000 | 1 |
| 2 | Stitched Felt Vest | Common | **Felt Vest Hold** | guard | 5 | If the creature has a Guard on the board, it stays 2 more round(s) on the board. | 3000 | 1 |
| 3 | Red-stitch Linen Smock | Uncommon | **Red-Stitch Mend** | guard | 6 | If you are at full health, the next Guard you place gets +5. | 8000 | 2 |
| 4 | Quilted Steppe Coat | Uncommon | **Quilt Veil** | guard | 6 | If the creature has guard up, the creature's strongest piece loses 2. | 8000 | 2 |
| 5 | Hedgehog Knit Cardigan | Rare | **Hedgehog Quill** | guard | 8 | Gain 6 guard. Each hit it blocks adds 3 to the bar, and 3 more while the creature has 3 or more pieces on the board. | 20000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Shaggy Shepherd Cape | Common | **Shaggy Hum** | charm | 5 | If you are under half health, add 4 Charm. | 3000 | 1 |
| 2 | Poppy Field Shawl | Common | **Shawl Bond** | charm | 5 | If the creature has a Hurt on the board, your Charm counts 10% more for the rest of the fight. | 3000 | 1 |
| 3 | Birch Hooded Mantle | Uncommon | **Mantle Lull** | charm | 6 | If it sits in one of the four inner cells, the creature skips its next turn. | 8000 | 2 |
| 4 | Wheatfield Poncho | Uncommon | **Wheat Poncho** | soothe | 4 | If it sits on the edge of the board, cut the creature's hits by 2 this round. | 8000 | 2 |
| 5 | Fox-collar Capelet | Rare | **Fox-Collar Lift** | trick | 7 | Pluck with twice the usual chance (once a fight). The piece it links to gets +3. | 20000 | 3 |

## The Dunewhisper (MENA, region level 17)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Dune Slippers | Common | **Dune Slip** | guard | 5 | If it sits in one of the four inner cells, the creature's next Hurt misses. | 3300 | 1 |
| 2 | Palm-Rope Sandals | Common | **Rope Spring** | hurt | 5 | If you are at full health, your next hand has 1 extra piece. | 3300 | 1 |
| 3 | Indigo Wrap Boots | Uncommon | **Wrap Brace** | guard | 6 | If you hold a Charm in your hand, gain 6 guard. | 8800 | 2 |
| 4 | Camel-Pad Overshoes | Uncommon | **Camel-Pad Plod** | hurt | 6 | If the creature has 2 or more pieces on the board, deal 6 extra damage. | 8800 | 2 |
| 5 | Cedar Bath Clogs | Rare | **Clog Soak** | hurt | 8 | Poison 3 for 3 turns. If it is linked to a Guard, also cut the creature's hits by 3 this round. | 22000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Goatskin Waterskin | Common | **Waterskin Sip** | heal | 4 | If it is linked to a Hurt, heal 2 at the start of each of your next 2 turns. | 3300 | 1 |
| 2 | Date-Palm Basket | Common | **Basket Treat** | item | 6 | If you took no damage last turn, heal 5. | 3300 | 1 |
| 3 | Kilim Saddle-Bag | Uncommon | **Saddle Dig** | trick | 5 | If it is linked to a Guard, your next hand has 1 extra piece. | 8800 | 2 |
| 4 | Copper-Pot Frame | Uncommon | **Copper Pot Boil** | heal | 5 | If it is linked to a Hurt, next round you pick from 6 pieces. | 8800 | 2 |
| 5 | Bottle-Gourd Sling | Rare | **Gourd Gift** | item | 8 | Heal 7 and add 7 Charm. If its Yield bar is past half, the creature skips its next turn. | 22000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Loom-Stripe Vest | Common | **Loom Vest Hold** | guard | 5 | If it sits on the creature's aim cell, it stays 2 more round(s) on the board. | 3300 | 1 |
| 2 | Braided Cord Jacket | Common | **Braided Thorn** | guard | 5 | If its chain has 3 or more pieces, the next Guard you place gets +5. | 3300 | 1 |
| 3 | Sand-Robe Coat | Uncommon | **Sand-Robe Slip** | guard | 6 | If you are under half health, the creature's next Hurt misses. | 8800 | 2 |
| 4 | Quilted Night Coat | Uncommon | **Quilt Mend** | guard | 6 | In the first two rounds of the fight, end your poison and heal 2. | 8800 | 2 |
| 5 | Caravan Leather Jerkin | Rare | **Jerkin Keep** | guard | 8 | Keeper. Gain 7 guard; if it was kept through a round, it also stays up one more turn. | 22000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Camel-Wool Hooded Cape | Common | **Camel Hood Hum** | charm | 5 | If it is linked to a Guard, cut the creature's hits by 2 this round. | 3300 | 1 |
| 2 | Indigo Shawl | Common | **Indigo Shawl** | charm | 5 | If an environment piece is in its chain, your Charm counts 10% more for the rest of the fight. | 3300 | 1 |
| 3 | Palm-Leaf Sun Cape | Uncommon | **Palm Sun Calm** | soothe | 4 | If you are at full health, the creature's strongest piece loses 2. | 8800 | 2 |
| 4 | Rose-Madder Mantle | Uncommon | **Madder Veil** | trick | 5 | If you played a Hurt last turn, small chance to lift an item from the creature. | 8800 | 2 |
| 5 | Goat-Hair Tent Cape | Rare | **Tent-Cape Lull** | charm | 3 | Add 5 Charm; the creature skips its next turn. If it skipped one earlier this fight, its strongest piece also loses 3. | 22000 | 3 |

## Blossomreach (EA, region level 20)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Hemp-Cord Sandals | Common | **Hemp Skip** | guard | 5 | If it sits next to the creature's aim cell, it stays 3 more round(s) on the board. | 3600 | 1 |
| 2 | Rain Clogs | Common | **Clog Splash** | hurt | 5 | If you played no Hurt last turn, deal 6 extra damage. | 3600 | 1 |
| 3 | Indigo Stitch Boots | Uncommon | **Stitch Pierce** | hurt | 6 | If its Yield bar is past half, it ignores the creature's guard. | 9600 | 2 |
| 4 | Steppe Felt Boots | Uncommon | **Felt Boot Stay** | guard | 6 | If you have played 2 or more Guards this fight, the creature's next Hurt misses. | 9600 | 2 |
| 5 | Snow Straw Boots | Rare | **Snow Straw Trip** | hurt | 2 | Trip: the creature skips its next turn. If it is linked to a Trick, deal 6 extra damage and your next hand has 1 extra piece. | 24000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Bamboo A-Frame | Common | **Frame Haul** | item | 6 | If its chain has 3 or more pieces, next round you pick from 6 pieces. | 3600 | 1 |
| 2 | Forager's Basket | Common | **Forager's Feast** | item | 6 | From round 3 on, heal 3 at the start of each of your next 2 turns. | 3600 | 1 |
| 3 | Knotted Cloth Bundle | Uncommon | **Bundle Pluck** | trick | 5 | If the creature has a Guard on the board, small chance to lift an item from the creature. | 9600 | 2 |
| 4 | Lacquer Tea Chest | Uncommon | **Chest Steep** | heal | 5 | If you hold a Charm in your hand, heal 3 at the start of each of your next 2 turns. | 9600 | 2 |
| 5 | Quilted Silk Satchel | Rare | **Satchel Rest** | heal | 7 | Heal 8. Each other Heal or Item in its chain heals 4 more. | 24000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Indigo Work Jacket | Common | **Work Wall** | guard | 5 | If the creature has 2 or more pieces on the board, the next Guard you place gets +6. | 3600 | 1 |
| 2 | Padded Winter Vest | Common | **Vest Thorn** | guard | 5 | If it is linked to a Hurt, each hit this guard blocks adds 3 to the bar. | 3600 | 1 |
| 3 | Spring Wrap Coat | Uncommon | **Wrap Mend** | guard | 6 | If you are at full health, heal 7. | 9600 | 2 |
| 4 | Fleece-Lined Jacket | Uncommon | **Jacket Keep** | guard | 6 | If the creature hit you last turn, Keeper: it stays in your hand if you do not play it. | 9600 | 2 |
| 5 | Ramie Summer Jacket | Rare | **Summer Jacket** | guard | 8 | Gain 8 guard. The first hit it blocks each round also heals you 4. | 24000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Straw Rain Cape | Common | **Cape Frog** | charm | 5 | If it is linked to a Hurt, add 6 Charm. | 3600 | 1 |
| 2 | Plum Snow Hood | Common | **Plum Hood Hush** | soothe | 3 | If the creature hit you last turn, cut the creature's hits by 3 this round. | 3600 | 1 |
| 3 | Maple Shawl | Uncommon | **Maple Shawl** | charm | 6 | If it sits on the edge of the board, your Charm counts 10% more for the rest of the fight. | 9600 | 2 |
| 4 | Felt Herder's Poncho | Uncommon | **Herder's Pluck** | trick | 5 | If the creature has no Hurt on the board, your next hand has 1 extra piece. | 9600 | 2 |
| 5 | Blossom Capelet | Rare | **Blossom Lull** | charm | 8 | Add 8 Charm. The next two Charm pieces you place this fight add 4 more each. | 24000 | 3 |

## Spicepeak (CSA, region level 23)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Curl-Toe Slippers | Common | **Curl Pounce** | hurt | 6 | If the creature has a Hurt on the board, deal 6 extra damage. | 3900 | 1 |
| 2 | Felted Snow Boots | Common | **Snow Stand** | guard | 6 | If it sits on the edge of the board, it stays 3 more round(s) on the board. | 3900 | 1 |
| 3 | Toe-Ring Sandals | Uncommon | **Toe-Ring Pierce** | hurt | 7 | If it sits on the creature's aim cell, it ignores the creature's guard. | 10400 | 2 |
| 4 | Stilt Clogs | Uncommon | **Stilt Stomp** | hurt | 7 | If you have played 2 or more Hurts this fight, remove the creature's weakest piece from the board. | 10400 | 2 |
| 5 | Wrapped Hide Boots | Rare | **Yak Wrap Stand** | guard | 9 | Gain 8 guard; the creature's next Hurt misses and the missed Hurt adds 4 to the bar. | 26000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Chili Cone Basket | Common | **Cone Feast** | item | 7 | If the creature has a Hurt on the board, heal 6. | 3900 | 1 |
| 2 | Ikat Saddle Satchel | Common | **Satchel Pluck** | trick | 5 | If its chain has 3 or more pieces, the piece it links to gets +3. | 3900 | 1 |
| 3 | Porter's Frame Pack | Uncommon | **Porter Haul** | item | 8 | If you hold a Charm in your hand, your next hand has 1 extra piece. | 10400 | 2 |
| 4 | Block-Print Bundle | Uncommon | **Bundle Brew** | heal | 6 | If an environment piece is in its chain, heal 7. | 10400 | 2 |
| 5 | Stacked Tin Pack | Rare | **Tin Tiffin** | heal | 8 | Heal 8 now and 4 at the start of each of your next 3 turns. | 26000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Ikat Robe Coat | Common | **Ikat Robe Wall** | guard | 6 | If you have played 2 or more Guards this fight, the creature's strongest piece loses 3. | 3900 | 1 |
| 2 | Kantha Patch Vest | Common | **Patch Thorn** | guard | 6 | If it sits in one of the four inner cells, each hit this guard blocks adds 3 to the bar. | 3900 | 1 |
| 3 | Fleece-Collar Jacket | Uncommon | **Collar Mend** | guard | 7 | If you played a Hurt last turn, heal 3 at the start of each of your next 2 turns. | 10400 | 2 |
| 4 | Mirror-Work Smock | Uncommon | **Smock Glint** | guard | 7 | If a creature piece is in its chain, the creature's next Hurt misses. | 10400 | 2 |
| 5 | Turmeric Wrap Coat | Rare | **Wrap Keep** | guard | 9 | Keeper. Gain 8 guard and heal 4 for each piece left in your hand. | 26000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Leaf Rain Hood | Common | **Palm Hood Hum** | charm | 6 | If it is linked to a Hurt, cut the creature's hits by 3 this round. | 3900 | 1 |
| 2 | Fine Wool Shawl | Common | **Wool Shawl** | charm | 6 | If you are at full health, your Charm counts 10% more for the rest of the fight. | 3900 | 1 |
| 3 | Felt Shepherd Cape | Uncommon | **Felt Cape Calm** | soothe | 5 | If its chain has 3 or more pieces, the creature skips its next turn. | 10400 | 2 |
| 4 | Striped Yak Poncho | Uncommon | **Poncho Pluck** | trick | 6 | If the creature hit you last turn, small chance to lift an item from the creature. | 10400 | 2 |
| 5 | Indigo Dot Cloak | Rare | **Indigo Dot Lull** | charm | 9 | Add 8 Charm. If the creature has guard up, its guard drops by 8. | 26000 | 3 |

## The Monsoon Tangle (SEA, region level 26)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Paddy Stilt-Clogs | Common | **Clog Surge** | hurt | 6 | If it sits in one of the four inner cells, deal 7 extra damage. | 4200 | 1 |
| 2 | Pandan Sandals | Common | **Pandan Skip** | guard | 6 | If its chain has 3 or more pieces, your next hand has 1 extra piece. | 4200 | 1 |
| 3 | Ikat Leech-Wraps | Uncommon | **Wrap Guard** | guard | 7 | If you played no Hurt last turn, heal 8. | 11200 | 2 |
| 4 | Rattan Trail Boot | Uncommon | **Rattan Rush** | hurt | 7 | If it sits next to the creature's aim cell, it ignores the creature's guard. | 11200 | 2 |
| 5 | Mudflat Paddles | Rare | **Paddle Trip** | hurt | 9 | Trip: the creature skips its next turn. Every creature piece on the board also loses 4 once. | 28000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Rattan Back-Basket | Common | **Back Basket** | item | 7 | If the creature has a Hurt on the board, next round you pick from 6 pieces. | 4200 | 1 |
| 2 | Bamboo Ladder-Pack | Common | **Pack Rummage** | trick | 5 | If the creature has a Hurt on the board, your next hand has 1 extra piece. | 4200 | 1 |
| 3 | Batik Bundle | Uncommon | **Batik Bundle** | heal | 6 | If you have played 2 or more Guards this fight, heal 3 at the start of each of your next 2 turns. | 11200 | 2 |
| 4 | Nipa Thatch Pack | Uncommon | **Thatch Snack** | item | 8 | If you hold a Heal in your hand, heal 8. | 11200 | 2 |
| 5 | Water-Jar Pack | Rare | **Jar Plenty** | heal | 8 | Heal 9. Next round pick from 6 pieces, or from 7 if you placed a Heal last round. | 28000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Indigo Batik Smock | Common | **Smock Wall** | guard | 6 | If you have played 2 or more Hurts this fight, gain 7 guard. | 4200 | 1 |
| 2 | Pandan Weave Vest | Common | **Pandan Vest** | guard | 6 | If you hold a Charm in your hand, it stays 3 more round(s) on the board. | 4200 | 1 |
| 3 | Ikat Wrap-Jacket | Uncommon | **Ikat Wrap Mend** | guard | 7 | If you are under half health, end your poison and heal 3. | 11200 | 2 |
| 4 | Kapok Puffer | Uncommon | **Kapok Keep** | guard | 7 | If the creature has guard up, Keeper: it stays in your hand if you do not play it. | 11200 | 2 |
| 5 | Mangrove Oilcloth | Rare | **Oilcloth Slip** | guard | 9 | Gain 9 guard; the creature's next Hurt misses. If the creature has no pieces on the board, its next piece loses 4. | 28000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Frond Rain Cape | Common | **Palm Frond Hum** | charm | 6 | If it sits next to the creature's aim cell, cut the creature's hits by 3 this round. | 4200 | 1 |
| 2 | Banana-Leaf Hood | Common | **Hood Calm** | soothe | 4 | If it sits in a corner, cut the creature's hits by 3 this round. | 4200 | 1 |
| 3 | Batik Shawl | Uncommon | **Batik Shawl** | charm | 7 | If it sits in one of the four inner cells, your Charm counts 10% more for the rest of the fight. | 11200 | 2 |
| 4 | Net-Veil Mantle | Uncommon | **Net-Veil Pluck** | trick | 6 | If an environment piece is in its chain, small chance to lift an item from the creature. | 11200 | 2 |
| 5 | Monsoon Poncho | Rare | **Monsoon Lull** | charm | 9 | Add 9 Charm. The creature's next two Hurts do half damage. | 28000 | 3 |

## The Greatcanopy (WCA, region level 29)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Sole Sandals | Common | **Palm Sole Skip** | guard | 6 | If it sits next to the creature's aim cell, a chain of 3 or more does not use it up. | 4500 | 1 |
| 2 | Mudwader Wraps | Common | **Mudwader Trip** | hurt | 6 | If its Yield bar is under a quarter, the creature skips its next turn. | 4500 | 1 |
| 3 | Rainroot Clogs | Uncommon | **Rainroot Bash** | hurt | 7 | If you have played 2 or more Guards this fight, deal 8 extra damage. | 12000 | 2 |
| 4 | Ochre Trail Boots | Uncommon | **Ochre Boot** | guard | 7 | If it is linked to a Guard, it stays 3 more round(s) on the board. | 12000 | 2 |
| 5 | Plantain Slippers | Rare | **Plantain Quick** | hurt | 9 | Deal 9 extra damage. If it is linked to another Hurt (Double Swing), that Hurt gets +4 more. | 30000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Calabash Pack | Common | **Gourd Plenty** | item | 7 | If you took no damage last turn, next round you pick from 6 pieces. | 4500 | 1 |
| 2 | Raffia Cone Basket | Common | **Cone Snack** | item | 7 | If you played a Hurt last turn, heal 7. | 4500 | 1 |
| 3 | Indigo Bundle | Uncommon | **Indigo Bundle** | trick | 6 | If you hold 2 or more Hurts in your hand, small chance to lift an item from the creature. | 12000 | 2 |
| 4 | Tooled Satchel | Uncommon | **Satchel Brew** | heal | 6 | If the creature has guard up, heal 3 at the start of each of your next 2 turns. | 12000 | 2 |
| 5 | Bamboo Frame Pack | Rare | **Frame Stew** | heal | 8 | Heal 9 now and 4 at the start of each of your next 2 turns. Your next hand has 1 extra piece. | 30000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Strip-Weave Smock | Common | **Smock Thorn** | guard | 6 | From round 3 on, each hit this guard blocks adds 3 to the bar. | 4500 | 1 |
| 2 | Mudcloth Vest | Common | **Mudcloth Hold** | guard | 6 | If it is linked to a Hurt, it stays 3 more round(s) on the board. | 4500 | 1 |
| 3 | Raffia Rain Coat | Uncommon | **Raffia Rain Slip** | guard | 7 | If it is linked to a Guard, the creature's next Hurt misses. | 12000 | 2 |
| 4 | Adire Jacket | Uncommon | **Adire Mend** | guard | 7 | If you are poisoned, gain 8 guard. | 12000 | 2 |
| 5 | Kapok Jerkin | Rare | **Kapok Jerkin** | guard | 9 | Keeper. Gain 9 guard, +4 for each round it stayed in your hand. | 30000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Plantain Leaf Cape | Common | **Cape Hum** | charm | 6 | If the creature hit you last turn, add 7 Charm. | 4500 | 1 |
| 2 | Strip-Weave Shawl | Common | **Strip Shawl** | charm | 6 | If you have played 2 or more Guards this fight, your Charm counts 10% more for the rest of the fight. | 4500 | 1 |
| 3 | Indigo Hood Mantle | Uncommon | **Mantle Calm** | soothe | 5 | If the creature has no Hurt on the board, cut the creature's hits by 3 this round. | 12000 | 2 |
| 4 | Raffia Poncho | Uncommon | **Poncho Lull** | charm | 6 | If you hold a Charm in your hand, the creature skips its next turn. | 12000 | 2 |
| 5 | Scaleleaf Mantle | Rare | **Scale Mantle** | guard | 9 | Gain 9 guard, +4 for each Charm in its chain. | 30000 | 3 |

## Thornacre Savanna (ESA, region level 32)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Acacia Sandals | Common | **Sandal Skip** | guard | 7 | If you are at full health, a chain of 3 or more does not use it up. | 4800 | 1 |
| 2 | Highland Trek Boots | Common | **Trek Hold** | guard | 7 | If it is linked to a Hurt, the creature's next Hurt misses. | 4800 | 1 |
| 3 | Sisal Slippers | Uncommon | **Slip Pierce** | hurt | 8 | If an environment piece is in its chain, it ignores the creature's guard. | 12800 | 2 |
| 4 | Stripe Gaiters | Uncommon | **Gaiter Finish** | hurt | 8 | If its Yield bar is past half, deal 9 extra damage. | 12800 | 2 |
| 5 | Baobab Clogs | Rare | **Baobab Thud** | hurt | 10 | Deal 8 extra damage for each piece in its chain and remove the creature's weakest piece from the board. | 32000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Coiled Basket Pack | Common | **Pack Plenty** | item | 8 | If its chain has 3 or more pieces, heal 8. | 4800 | 1 |
| 2 | Calabash Carrier | Common | **Gourd Brew** | heal | 6 | If you are under three quarters health, heal 8. | 4800 | 1 |
| 3 | Grain Sack Pack | Uncommon | **Grain Sack Meal** | item | 9 | If the creature has a Guard on the board, heal 9. | 12800 | 2 |
| 4 | Acacia Frame Pack | Uncommon | **Frame Rummage** | trick | 7 | If its Yield bar is past half, the piece it links to gets +4. | 12800 | 2 |
| 5 | Herder's Satchel | Rare | **Herder Satchel** | heal | 9 | Heal 10 and next round pick from 6 pieces; each Hurt you place that round gets +5. | 32000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Barkcloth Smock | Common | **Bark Thorn** | guard | 7 | If it is linked to a Guard, each hit this guard blocks adds 4 to the bar. | 4800 | 1 |
| 2 | Stripe Weave Vest | Common | **Stripe Vest** | guard | 7 | If the creature has no Hurt on the board, the next Guard you place gets +8. | 4800 | 1 |
| 3 | Highland Wool Coat | Uncommon | **Highland Mend** | guard | 8 | If you took no damage last turn, heal 4 at the start of each of your next 2 turns. | 12800 | 2 |
| 4 | Savanna Field Jacket | Uncommon | **Jacket Slip** | guard | 8 | If it sits next to the creature's aim cell, the creature's strongest piece loses 4. | 12800 | 2 |
| 5 | Beaded Tunic-Coat | Rare | **Bead Tunic** | guard | 10 | Gain 10 guard, +5 for each other piece type in its chain. | 32000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Check Blanket Wrap | Common | **Check Wrap Hum** | charm | 7 | If you hold a Charm in your hand, cut the creature's hits by 4 this round. | 4800 | 1 |
| 2 | Highland Shawl | Common | **Highland Shawl** | charm | 7 | In the first two rounds of the fight, your Charm counts 10% more for the rest of the fight. | 4800 | 1 |
| 3 | Banana-Leaf Rain Cape | Uncommon | **Rain Calm** | soothe | 6 | If you played a Hurt last turn, the creature's strongest piece loses 4. | 12800 | 2 |
| 4 | Dust Mantle | Uncommon | **Dust Mantle** | charm | 8 | If it is linked to a Guard, the creature skips its next turn. | 12800 | 2 |
| 5 | Indigo Dot Shawl | Rare | **Dot Shawl** | trick | 9 | The piece it links to gets +5. If that piece is a Charm, it adds 10 more. | 32000 | 3 |

## The Coralscatter (OC, region level 35)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Reef Sandals | Common | **Reef Skip** | guard | 7 | If you hold a Heal in your hand, your next hand has 1 extra piece. | 5100 | 1 |
| 2 | Gully Fleece Boot | Common | **Gully Hold** | guard | 7 | If the creature hit you last turn, a chain of 3 or more does not use it up. | 5100 | 1 |
| 3 | Drover's Pull-ons | Uncommon | **Drover Pierce** | hurt | 8 | If the creature has a Hurt on the board, it ignores the creature's guard. | 13600 | 2 |
| 4 | Flax Wading Wraps | Uncommon | **Flax Wade Trip** | hurt | 6 | If the creature has guard up, the creature skips its next turn. | 13600 | 2 |
| 5 | Mangrove Clog | Rare | **Clog Crush** | hurt | 10 | Deal 11 extra damage. If its Yield bar is past half, the creature also skips its next turn. | 34000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Flax Basket Pack | Common | **Flax Plenty** | item | 8 | If you hold a Charm in your hand, next round you pick from 6 pieces. | 5100 | 1 |
| 2 | Coconut String Bag | Common | **Coconut Snack** | item | 8 | If a creature piece is in its chain, heal 9. | 5100 | 1 |
| 3 | Bushman's Swag | Uncommon | **Swag Rummage** | trick | 7 | If you played no Hurt last turn, small chance to lift an item from the creature. | 13600 | 2 |
| 4 | Bamboo Frame Pack | Uncommon | **Frame Simmer** | heal | 7 | If it sits in a corner, heal 4 at the start of each of your next 2 turns. | 13600 | 2 |
| 5 | Pouch Pack | Rare | **Pouch Provision** | heal | 9 | Heal 11. Next round pick from 6 pieces, and at the end of that round your strongest unplayed piece stays in your hand. | 34000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Drover's Oilskin | Common | **Oilskin Thorn** | guard | 7 | If the creature has a Hurt on the board, each hit this guard blocks adds 4 to the bar. | 5100 | 1 |
| 2 | Bush Check Smock | Common | **Check Hold** | guard | 7 | If it is linked to a Guard, the next Guard you place gets +9. | 5100 | 1 |
| 3 | Bark-cloth Vest | Uncommon | **Bark Vest Mend** | guard | 8 | If the creature has a Hurt on the board, heal 4 at the start of each of your next 2 turns. | 13600 | 2 |
| 4 | Reef Sail-cloth Jerkin | Uncommon | **Sail Jerkin Slip** | guard | 8 | If you played a Hurt last turn, the creature's next Hurt misses. | 13600 | 2 |
| 5 | Gum-dyed Cardigan | Rare | **Gum-dye Keep** | guard | 10 | Keeper. Gain 11 guard; after two rounds in your hand it also stays up one more turn and each hit it blocks adds 5 to the bar. | 34000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Frond Rain Cape | Common | **Frond Cape Hum** | charm | 7 | If the creature has a Hurt on the board, cut the creature's hits by 4 this round. | 5100 | 1 |
| 2 | Fleece Mantle | Common | **Mantle Bond** | charm | 7 | If it is linked to a Hurt, your Charm counts 10% more for the rest of the fight. | 5100 | 1 |
| 3 | Hibiscus Pareo | Uncommon | **Pareo Calm** | soothe | 6 | If it is linked to a Hurt, the creature skips its next turn. | 13600 | 2 |
| 4 | Red-dust Poncho | Uncommon | **Red-Dust Lull** | charm | 8 | If its Yield bar is past half, the creature skips its next turn. | 13600 | 2 |
| 5 | Storm-petrel Hood | Rare | **Petrel Hood** | trick | 9 | Pluck, sure to work. The creature's strongest piece loses 11 and your next hand has 1 extra piece. | 34000 | 3 |

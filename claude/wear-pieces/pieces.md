# Wearable puzzle pieces v2: unique effects (280)

Every effect is its own trigger + payoff pair (210 Common/Uncommon) or a hand-written rule (70 Rare). No effect repeats. These need new engine support (triggers and payoffs below); nothing is installed in `game/`.

**Value** is the piece base (the game adds stat, level/3 and rank: Lined +2, Fine +4). **Petals** = Tailor price of the Common rank; Lined x1.5, Fine x2.5. **Tailor** = lowest Tailor level that can craft it. Numbers inside effects ({a}, {b}) grow with region and rarity.

## The Maplewold (NA, region level 1)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Sugarbush Snow Boots | Common | **Snowdrift Trip** | hurt | 3 | If nothing is linked to it, the creature skips its next move. | 1200 | 1 |
| 2 | Birchwood Clog | Common | **Clog Knock** | hurt | 3 | If it fires last in its chain, deal 2 extra damage. | 1200 | 1 |
| 3 | Lakeland Snowshoe | Uncommon | **Snowshoe Skim** | guard | 4 | If you have not played a Hurt this round, the creature's first hit next turn misses. | 3200 | 2 |
| 4 | Prairie Stitch Boots | Uncommon | **Prairie Kick** | hurt | 4 | If a Guard fired just before it, this piece ignores guard. | 3200 | 2 |
| 5 | Loon-Down Slippers | Rare | **Loon Hush** | soothe | 4 | Cuts its next hits by 4. If its Yield bar is under half, draw 2 as well. | 8000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Splint Pack Basket | Common | **Splint Stash** | item | 4 | If you hold 2 pieces or fewer, draw 1. | 1200 | 1 |
| 2 | Firewood Pack Frame | Common | **Hearth Warmth** | heal | 2 | If you are under half health, heal 1 at the start of each of your next 2 turns. | 1200 | 1 |
| 3 | Portage Sack | Uncommon | **Portage Rummage** | trick | 3 | If the creature has no pieces on the board, small chance to lift an item from the creature. | 3200 | 2 |
| 4 | Sap-Run Bucket | Uncommon | **Syrup Snack** | item | 5 | In the first round of the fight, heal 3. | 3200 | 2 |
| 5 | Toboggan Pack | Rare | **Toboggan Run** | hurt | 6 | Fires last in its chain and deals 4 extra damage for every piece in the chain, then falls off the board. | 8000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Lumber-Check Jacket | Common | **Check Wall** | guard | 3 | If the creature just hit you, a blocked hit pricks it for 2. | 1200 | 1 |
| 2 | Goldenrod Down Vest | Common | **Down Puff** | guard | 3 | If you have no guard up, gain 2 guard. | 1200 | 1 |
| 3 | Prairie Duster | Uncommon | **Duster Mend** | guard | 4 | If you have guard up, heal 3. | 3200 | 2 |
| 4 | Lodge Cardigan | Uncommon | **Cardigan Calm** | soothe | 2 | If you are under half health, cut its next hits by 1. | 3200 | 2 |
| 5 | Frostline Parka | Rare | **Parka Bulwark** | guard | 6 | Gain 4 guard. If the creature has 2 or more Hurts on the board, gain 4 more and it stays 2 more round(s). | 8000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Maple Mantle | Common | **Maple Flutter** | trick | 2 | If a Hurt fired just before it, double the value of the next piece in its chain. | 1200 | 1 |
| 2 | Birch Poncho | Common | **Chickadee Chirp** | charm | 3 | If a piece of its own type is linked to it, add 2 Charm. | 1200 | 1 |
| 3 | Northern Lights Cloak | Uncommon | **Aurora Sheen** | charm | 4 | If its Yield bar is past half, your Charm fills 10% more for the rest of the fight. | 3200 | 2 |
| 4 | Harbour Slicker Cape | Uncommon | **Slicker Shrug** | guard | 4 | If the creature has guard up, the creature's first hit next turn misses. | 3200 | 2 |
| 5 | Pine-Needle Shawl | Rare | **Pine Wrap** | guard | 6 | Keeper. Once per fight, when you play it, your next Charm also fills the Yield bar by 4. | 8000 | 3 |

## Maizehollow (CA, region level 4)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Lattice Huaraches | Common | **Huarache Dash** | hurt | 3 | If it fires first in its chain, draw 1. | 1500 | 1 |
| 2 | Tooled Ankle Boots | Common | **Tooled Stomp** | hurt | 3 | If you have guard up, deal 2 extra damage. | 1500 | 1 |
| 3 | Indigo Leg Wraps | Uncommon | **Leg-Wrap Brace** | guard | 4 | If a Trick fired just before it, this piece stays 1 more round(s) on the board. | 4000 | 2 |
| 4 | Ixtle Slippers | Uncommon | **Ixtle Slip** | guard | 4 | If the creature just hit you, the creature's first hit next turn misses. | 4000 | 2 |
| 5 | Market Platform Clogs | Rare | **Platform Thud** | hurt | 6 | Fires last in its chain. Deals 4 extra damage, and the creature loses 2 value on its strongest piece. | 10000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Carrier Frame | Common | **Carrier Grip** | guard | 3 | If your hand is full, gain 2 guard. | 1500 | 1 |
| 2 | Maize Net Bag | Common | **Maize Net Bite** | item | 4 | If you are under half health, heal 2. | 1500 | 1 |
| 3 | Palm Basket Pack | Uncommon | **Basket Rummage** | trick | 3 | If its chain has 3 or more pieces, small chance to lift an item from the creature. | 4000 | 2 |
| 4 | Loom-Cloth Bundle | Uncommon | **Bundle Poultice** | heal | 3 | If you are poisoned, end your poison and heal 1. | 4000 | 2 |
| 5 | Dry-Spell Water Pack | Rare | **Water-Pack Sip** | heal | 5 | Heal 4. Next round, pick from 6 pieces. If the day is dry (no guard played this round), heal 2 more. | 10000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Bloom Smock | Common | **Smock Bloom** | guard | 3 | If a Charm fired just before it, a blocked hit pricks it for 2. | 1500 | 1 |
| 2 | Pleated Shirt-Jacket | Common | **Pleat Shield** | guard | 3 | In the first round of the fight, your next Guard gets +2. | 1500 | 1 |
| 3 | Fringed Leather Vest | Uncommon | **Fringe Sway** | guard | 4 | If it sits on the edge of the board, the creature's first hit next turn misses. | 4000 | 2 |
| 4 | Quilted Cotton Coat | Uncommon | **Quilt Wall** | guard | 4 | If you have played 2 or more Guards this fight, this piece stays 1 more round(s) on the board. | 4000 | 2 |
| 5 | Indigo Field Jacket | Rare | **Indigo Mend** | guard | 6 | Gain 4 guard and heal 2. When it is blocked down to zero, it heals you 2 more. | 10000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Hearthstripe Poncho | Common | **Hearth Stripe** | charm | 3 | If you took no damage last turn, add 2 Charm. | 1500 | 1 |
| 2 | Dappled Rebozo | Common | **Rebozo Hum** | charm | 3 | If it sits next to the blank centre, cut its next hits by 1. | 1500 | 1 |
| 3 | Palm Rain Cape | Uncommon | **Palm Cape Calm** | soothe | 2 | If the creature has 3 or more pieces on the board, its strongest piece loses 1 value. | 4000 | 2 |
| 4 | Agave-Fibre Mantle | Uncommon | **Fibre Veil** | trick | 3 | If it sits in a corner, your next Hurt gets +3. | 4000 | 2 |
| 5 | Sun Hood Cloak | Rare | **Sun-Hood Shade** | guard | 6 | Gain 4 guard. If the Yield bar is past half, the creature's next piece fires at half value. | 10000 | 3 |

## Mistmoor (NWE, region level 6)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Alder Clogs | Common | **Alder Splash** | guard | 3 | If it fires last in its chain, the creature's first hit next turn misses. | 1800 | 1 |
| 2 | Drain Brogues | Common | **Brogue Drain** | guard | 3 | If it fires first in its chain, end your poison and heal 1. | 1800 | 1 |
| 3 | Felted Fleece Boots | Uncommon | **Felt Hush** | soothe | 2 | If your hand is full, this piece stays in your hand if unplayed. | 4800 | 2 |
| 4 | Birch-Bark Slippers | Uncommon | **Bark Slip** | hurt | 4 | If a Trick fired just before it, this piece does not count toward the chain limit. | 4800 | 2 |
| 5 | Herringbone Gaiters | Rare | **Gaiter Lunge** | hurt | 6 | Pierce. If it fires first in its chain, draw 2; if it fires last, deal 2 extra damage. | 12000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Peat Creel | Common | **Peat Creel Catch** | trick | 2 | From round 3 on, small chance to lift an item from the creature. | 1800 | 1 |
| 2 | Waxed Roll-top | Common | **Roll-Top Snack** | item | 4 | If your discard holds 5 or more pieces, draw 1. | 1800 | 1 |
| 3 | Heather Frame | Uncommon | **Heather Rest** | heal | 3 | If you have not played a Hurt this round, heal 1 at the start of each of your next 2 turns. | 4800 | 2 |
| 4 | Bark Box Pack | Uncommon | **Bark Box Fort** | guard | 4 | If you hold 2 pieces or fewer, this piece stays in your hand if unplayed. | 4800 | 2 |
| 5 | Fleece Bundle | Rare | **Fleece Bundle Bind** | guard | 6 | Keeper. While it is in your hand, your other Guards get +2. | 12000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Cable-Knit Long Coat | Common | **Cable Wall** | guard | 3 | If the creature has 3 or more pieces on the board, gain 2 guard. | 1800 | 1 |
| 2 | Waxed Field Jacket | Common | **Waxed Shed** | guard | 3 | If the creature just hit you, its strongest piece loses 1 value. | 1800 | 1 |
| 3 | Tweed Waistcoat | Uncommon | **Tweed Thorn** | guard | 4 | If its chain has 3 or more pieces, a blocked hit pricks it for 3. | 4800 | 2 |
| 4 | Tanbark Smock | Uncommon | **Tanbark Mend** | guard | 4 | If it fires first in its chain, heal 1 at the start of each of your next 2 turns. | 4800 | 2 |
| 5 | Eiderdown Coat | Rare | **Eiderdown Nest** | guard | 6 | Gain 4 guard. It stays 2 more round(s). If you are under half health, it also heals you 2. | 12000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Heather Shawl | Common | **Heather Hum** | charm | 3 | If the creature has guard up, cut its next hits by 1. | 1800 | 1 |
| 2 | Mustard Rain Cape | Common | **Mustard Drizzle** | soothe | 2 | If nothing is linked to it, gain 1 extra redraw(s) this fight. | 1800 | 1 |
| 3 | Sheepskin Mantle | Uncommon | **Sheepskin Snug** | charm | 4 | If you have guard up, add 3 Charm. | 4800 | 2 |
| 4 | Rush Thatch Cape | Uncommon | **Thatch Drip** | guard | 4 | If you took no damage last turn, the creature's first hit next turn misses. | 4800 | 2 |
| 5 | Woad Mist Cloak | Rare | **Woad Moth** | trick | 5 | The next piece in its chain is placed as if it had a matching knob; if that piece is a Hurt, add 2 Charm. | 12000 | 3 |

## The Sunsprinkle Isles (CB, region level 8)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Plait Sandals | Common | **Palm-Plait Skip** | guard | 4 | If it sits on the edge of the board, this piece does not count toward the chain limit. | 2100 | 1 |
| 2 | Mahogany Clogs | Common | **Mahogany Clack** | hurt | 4 | If a Guard fired just before it, your next Hurt gets +3. | 2100 | 1 |
| 3 | Sisal-Sole Slippers | Uncommon | **Sisal Soft-Step** | hurt | 5 | If you have no guard up, the creature's first hit next turn misses. | 5600 | 2 |
| 4 | Mangrove Gaiters | Uncommon | **Mangrove Grip** | guard | 5 | If it sits in a corner, this piece stays 1 more round(s) on the board. | 5600 | 2 |
| 5 | Curl-Toe Reef Booties | Rare | **Reef Hop** | hurt | 7 | Trip. If this is its chain's first piece, the creature also loses 2 value on its strongest piece; if last, deal 2 extra. | 14000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Market Basket Pack | Common | **Market Haul** | item | 5 | From round 3 on, heal 3. | 2100 | 1 |
| 2 | Calabash Carrier | Common | **Calabash Brew** | heal | 3 | If you are at full health, heal 1 at the start of each of your next 2 turns. | 2100 | 1 |
| 3 | Net-Roll Bundle | Uncommon | **Net-Roll Snare** | trick | 4 | If the creature has 3 or more pieces on the board, knock its weakest piece off the board. | 5600 | 2 |
| 4 | Batik Sea Sack | Uncommon | **Sea-Sack Salve** | heal | 4 | If the creature just hit you, gain 4 guard. | 5600 | 2 |
| 5 | Bamboo Frame Pack | Rare | **Bamboo Bounty** | heal | 6 | Heal 5. Next round pick from 6 pieces; if your hand was full, keep one of the unpicked pieces. | 14000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Breeze Smock | Common | **Breeze Smock** | guard | 4 | If it fires first in its chain, the creature's first hit next turn misses. | 2100 | 1 |
| 2 | Indigo Wrap-Coat | Common | **Indigo Wrap Wall** | guard | 4 | If a Hurt fired just before it, your next Guard gets +3. | 2100 | 1 |
| 3 | Check-Weave Jacket | Uncommon | **Weave Thorn** | guard | 5 | If the creature has guard up, a blocked hit pricks it for 4. | 5600 | 2 |
| 4 | Sailcloth Longcoat | Uncommon | **Sailcloth Brace** | guard | 5 | From round 3 on, this piece stays 1 more round(s) on the board. | 5600 | 2 |
| 5 | Sunset Batik Vest | Rare | **Sunset Mend** | guard | 7 | Gain 5 guard. When the creature plays a Hurt into it, heal 2 and add 2 Charm. | 14000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Thatch Rain Cape | Common | **Thatch Hush** | soothe | 2 | If you are under half health, the creature skips its next move. | 2100 | 1 |
| 2 | Hibiscus Shawl | Common | **Hibiscus Charm** | charm | 4 | If a Charm fired just before it, your Charm fills 10% more for the rest of the fight. | 2100 | 1 |
| 3 | Sea-Breeze Poncho | Uncommon | **Breeze Poncho** | trick | 4 | If you have guard up, this piece does not count toward the chain limit. | 5600 | 2 |
| 4 | Mangrove Hood | Uncommon | **Mangrove Cover** | guard | 5 | If you have not played a Hurt this round, this piece stays in your hand if unplayed. | 5600 | 2 |
| 5 | Shell-Scallop Capelet | Rare | **Scallop Shine** | charm | 7 | Add 5 Charm. If it is linked to 2 or more pieces, the creature skips its next move. | 14000 | 3 |

## Olivewhistle Shore (SE, region level 10)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Shoreline Rope Slips | Common | **Rope-Slip Slide** | hurt | 4 | If it sits on the edge of the board, draw 1. | 2400 | 1 |
| 2 | Sunpath Sandals | Common | **Sunpath Stride** | guard | 4 | If its chain has 3 or more pieces, this piece does not count toward the chain limit. | 2400 | 1 |
| 3 | Corkbark Clogs | Uncommon | **Cork Knock** | hurt | 5 | If the creature has guard up, this piece ignores guard. | 6400 | 2 |
| 4 | Thyme-Hill Wraps | Uncommon | **Thyme Wrap Stay** | guard | 5 | If you took no damage last turn, this piece stays 1 more round(s) on the board. | 6400 | 2 |
| 5 | Harvest Treaders | Rare | **Harvest Tread** | hurt | 7 | Fires last in its chain and deals 5 extra damage. Heal 2 for each Guard in the chain. | 16000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Olive Picker's Creel | Common | **Olive Creel Pick** | item | 5 | If your hand is full, next round you pick from 6 pieces. | 2400 | 1 |
| 2 | Fisher's Float Net | Common | **Float-Net Haul** | trick | 3 | If it is linked to 2 or more pieces, draw 1. | 2400 | 1 |
| 3 | Amphora Frame | Uncommon | **Amphora Pour** | heal | 4 | In the first round of the fight, heal 1 at the start of each of your next 2 turns. | 6400 | 2 |
| 4 | Sailcloth Seabag | Uncommon | **Seabag Stash** | item | 6 | If your discard holds 5 or more pieces, this piece stays in your hand if unplayed. | 6400 | 2 |
| 5 | Lemon-Grove Satchel | Rare | **Lemon Zest** | heal | 6 | Heal 5 and cut its next hits by 2. If you have no guard up, it also draws you 2. | 16000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Net-Mender's Smock | Common | **Net-Mender Wall** | guard | 4 | If it fires first in its chain, a blocked hit pricks it for 3. | 2400 | 1 |
| 2 | Goatherd's Fleece Vest | Common | **Fleece Vest Hold** | guard | 4 | If you are under half health, this piece stays 1 more round(s) on the board. | 2400 | 1 |
| 3 | Olive-Grove Quilt Jacket | Uncommon | **Olive Quilt** | guard | 5 | If a Charm fired just before it, heal 4. | 6400 | 2 |
| 4 | Vintner's Long Coat | Uncommon | **Vintner's Long Guard** | guard | 5 | If it sits on the edge of the board, your next Guard gets +4. | 6400 | 2 |
| 5 | Sun-Stripe Tunic Coat | Rare | **Sun-Stripe Spike** | guard | 7 | Gain 5 guard. A blocked hit pricks it for 5; a hit that is fully blocked also costs it a piece. | 16000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Shepherd's Felt Cape | Common | **Shepherd Hum** | charm | 4 | If you hold 2 pieces or fewer, cut its next hits by 1. | 2400 | 1 |
| 2 | Lemon-Fringe Shawl | Common | **Lemon Fringe Soft** | charm | 4 | If it sits in a corner, add 3 Charm. | 2400 | 1 |
| 3 | Loom-Stripe Poncho | Uncommon | **Loom Stripe Tidy** | trick | 4 | If it sits next to the blank centre, small chance to lift an item from the creature. | 6400 | 2 |
| 4 | Whitewash Sun Mantle | Uncommon | **Whitewash Glare** | guard | 5 | If its Yield bar is under a quarter, the creature's first hit next turn misses. | 6400 | 2 |
| 5 | Sea-Squall Capelet | Rare | **Squall Lull** | charm | 7 | Add 5 Charm. If it is the only Charm this round, the creature skips its next move. | 16000 | 3 |

## The Rainroot Reaches (SA, region level 12)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Latex Puddle Boots | Common | **Latex Splash** | guard | 4 | If a piece of its own type is linked to it, the creature's first hit next turn misses. | 2700 | 1 |
| 2 | Puna Wool Booties | Common | **Puna Warm** | guard | 4 | If you have played 2 or more Guards this fight, heal 3. | 2700 | 1 |
| 3 | Plaited Fibre Sandals | Uncommon | **Fibre Stride** | hurt | 5 | If a Hurt fired just before it, draw 2. | 7200 | 2 |
| 4 | Balsa Bark Clogs | Uncommon | **Balsa Bump** | hurt | 5 | If you took no damage last turn, deal 4 extra damage. | 7200 | 2 |
| 5 | Striped Leg Wraps | Rare | **Stripe Wrap Trip** | hurt | 7 | Trip. If its chain has 3 or more pieces, also deal 5 extra damage and draw 3. | 18000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Striped Bundle Cloth | Common | **Bundle Basics** | item | 5 | If it fires first in its chain, heal 3. | 2700 | 1 |
| 2 | Cone Vine Basket | Common | **Vine Basket Pick** | item | 5 | If a Guard fired just before it, next round you pick from 6 pieces. | 2700 | 1 |
| 3 | Highland Carry Frame | Uncommon | **Highland Carry** | heal | 4 | If its chain has 3 or more pieces, heal 2 at the start of each of your next 2 turns. | 7200 | 2 |
| 4 | Leaf-Flap Satchel | Uncommon | **Leaf-Flap Rummage** | trick | 4 | If its Yield bar is past half, small chance to lift an item from the creature. | 7200 | 2 |
| 5 | Market Net Bag | Rare | **Market Net Feast** | heal | 6 | Heal 5, plus 3 for every piece left in your hand. Next round pick from 6 pieces. | 18000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Fleece Vest | Common | **Fleece Hold** | guard | 4 | If the creature just hit you, this piece stays 2 more round(s) on the board. | 2700 | 1 |
| 2 | Shingle Leaf Smock | Common | **Shingle Thorn** | guard | 4 | If you have played 2 or more Hurts this fight, a blocked hit pricks it for 3. | 2700 | 1 |
| 3 | Warp-Stripe Jacket | Uncommon | **Warp Mend** | guard | 5 | If you are poisoned, heal 2 at the start of each of your next 2 turns. | 7200 | 2 |
| 4 | Bark-Cloth Tunic Coat | Uncommon | **Bark-Cloth Ward** | guard | 5 | If a Trick fired just before it, its strongest piece loses 2 value. | 7200 | 2 |
| 5 | Kapok Puffer | Rare | **Kapok Cushion** | guard | 7 | Keeper. Gain 5 guard. If it was kept a round, gain 5 more. | 18000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Striped Poncho | Common | **Stripe Poncho Hum** | charm | 4 | If you have guard up, your Charm fills 10% more for the rest of the fight. | 2700 | 1 |
| 2 | Thatch Rain Cape | Common | **Rain Thatch Cover** | soothe | 2 | If a piece of its own type is linked to it, this piece stays in your hand if unplayed. | 2700 | 1 |
| 3 | Feather Shoulder Mantle | Uncommon | **Feather Flash** | charm | 5 | If its Yield bar is past half, double the value of the next piece in its chain. | 7200 | 2 |
| 4 | Cloud-Forest Shawl | Uncommon | **Cloud Shawl Veil** | trick | 4 | If you have no guard up, cut its next hits by 2. | 7200 | 2 |
| 5 | Indigo Hooded Cloak | Rare | **Indigo Dusk Lull** | charm | 7 | Add 5 Charm. The creature's next piece fires at half value; if its Yield bar is past half, it skips instead. | 18000 | 3 |

## Birchbramble Steppe (EE, region level 14)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Birchweave Shoes | Common | **Birchweave Hop** | guard | 5 | If you have not played a Hurt this round, this piece does not count toward the chain limit. | 3000 | 1 |
| 2 | Snowdrift Felt Boots | Common | **Snowdrift Boot Hold** | guard | 5 | If the creature has no pieces on the board, this piece stays 2 more round(s) on the board. | 3000 | 1 |
| 3 | Poppy Hide Moccasins | Uncommon | **Poppy Moccasin Trip** | hurt | 6 | If it sits in a corner, the creature skips its next move. | 8000 | 2 |
| 4 | Rider's Red Boots | Uncommon | **Rider's Charge** | hurt | 6 | If its chain has 3 or more pieces, add 5 Charm. | 8000 | 2 |
| 5 | Sunflower Straw Sandals | Rare | **Straw Sun Skip** | hurt | 8 | Quick. Fires first: draw 3. If no Hurt fired before it this round, deal 6 extra damage. | 20000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Birchbark Pester | Common | **Pester Pick** | trick | 4 | If a Guard fired just before it, small chance to lift an item from the creature. | 3000 | 1 |
| 2 | Harvest Wicker Basket | Common | **Harvest Wicker Feast** | item | 6 | If you hold 2 pieces or fewer, next round you pick from 6 pieces. | 3000 | 1 |
| 3 | Beekeeper's Frame | Uncommon | **Hive Frame Honey** | heal | 5 | If the creature just hit you, heal 2 at the start of each of your next 2 turns. | 8000 | 2 |
| 4 | Flat-weave Satchel | Uncommon | **Flat-Weave Stash** | item | 7 | If it sits on the edge of the board, gain 2 extra redraw(s) this fight. | 8000 | 2 |
| 5 | Fleece Drawsack | Rare | **Fleece Sack Rest** | heal | 7 | Heal 6. If your discard holds 5 or more pieces, return 3 of them to your deck. | 20000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Sheepskin Longcoat | Common | **Longcoat Thorn** | guard | 5 | If you have no guard up, a blocked hit pricks it for 4. | 3000 | 1 |
| 2 | Stitched Felt Vest | Common | **Felt Vest Hold** | guard | 5 | If a piece of its own type is linked to it, this piece stays 2 more round(s) on the board. | 3000 | 1 |
| 3 | Red-stitch Linen Smock | Uncommon | **Red-Stitch Mend** | guard | 6 | If you are at full health, your next Guard gets +5. | 8000 | 2 |
| 4 | Quilted Steppe Coat | Uncommon | **Steppe Quilt Veil** | guard | 6 | If the creature has guard up, its strongest piece loses 2 value. | 8000 | 2 |
| 5 | Hedgehog Knit Cardigan | Rare | **Hedgehog Quill** | guard | 8 | Gain 6 guard. Each hit it blocks pricks the creature for 3; a creature at 3 or more board pieces takes 3 extra. | 20000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Shaggy Shepherd Cape | Common | **Shaggy Hum** | charm | 5 | If you are under half health, add 4 Charm. | 3000 | 1 |
| 2 | Poppy Field Shawl | Common | **Poppy Shawl Bond** | charm | 5 | If a Trick fired just before it, your Charm fills 10% more for the rest of the fight. | 3000 | 1 |
| 3 | Birch Hooded Mantle | Uncommon | **Birch Mantle Lull** | charm | 6 | If it sits next to the blank centre, the creature skips its next move. | 8000 | 2 |
| 4 | Wheatfield Poncho | Uncommon | **Wheatfield Poncho** | soothe | 4 | If it sits on the edge of the board, this piece stays in your hand if unplayed. | 8000 | 2 |
| 5 | Fox-collar Capelet | Rare | **Fox-Collar Lift** | trick | 7 | Lift an item from the creature for sure once a fight; after that, +3 to Pluck chances and draw 3. | 20000 | 3 |

## The Dunewhisper (MENA, region level 17)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Dune Slippers | Common | **Dune Slip** | guard | 5 | If it sits next to the blank centre, the creature's first hit next turn misses. | 3300 | 1 |
| 2 | Palm-Rope Sandals | Common | **Palm-Rope Spring** | hurt | 5 | If you are at full health, draw 2. | 3300 | 1 |
| 3 | Indigo Wrap Boots | Uncommon | **Indigo Wrap Brace** | guard | 6 | If a Charm fired just before it, gain 5 guard. | 8800 | 2 |
| 4 | Camel-Pad Overshoes | Uncommon | **Camel-Pad Plod** | hurt | 6 | If the creature has 3 or more pieces on the board, deal 5 extra damage. | 8800 | 2 |
| 5 | Cedar Bath Clogs | Rare | **Cedar Clog Soak** | hurt | 8 | Poison 3 for 3 turns. If it is linked to a Guard, the poison also cuts its Hurts by 3. | 22000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Goatskin Waterskin | Common | **Waterskin Sip** | heal | 4 | If it fires last in its chain, heal 2 at the start of each of your next 2 turns. | 3300 | 1 |
| 2 | Date-Palm Basket | Common | **Date Basket Treat** | item | 6 | If you took no damage last turn, heal 4. | 3300 | 1 |
| 3 | Kilim Saddle-Bag | Uncommon | **Saddle-Bag Rummage** | trick | 5 | If you have guard up, draw 2. | 8800 | 2 |
| 4 | Copper-Pot Frame | Uncommon | **Copper Pot Boil** | heal | 5 | If it fires first in its chain, next round you pick from 6 pieces. | 8800 | 2 |
| 5 | Bottle-Gourd Sling | Rare | **Gourd Gift** | item | 9 | Heal 6. Give the creature a gift: add 6 Charm, and it skips its next move if its Yield bar is past half. | 22000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Loom-Stripe Vest | Common | **Loom Vest Hold** | guard | 5 | If it fires last in its chain, this piece stays 2 more round(s) on the board. | 3300 | 1 |
| 2 | Braided Cord Jacket | Common | **Braided Thorn** | guard | 5 | If its chain has 3 or more pieces, your next Guard gets +4. | 3300 | 1 |
| 3 | Sand-Robe Coat | Uncommon | **Sand-Robe Slip** | guard | 6 | If you are under half health, the creature's first hit next turn misses. | 8800 | 2 |
| 4 | Quilted Night Coat | Uncommon | **Night Quilt Mend** | guard | 6 | In the first round of the fight, end your poison and heal 2. | 8800 | 2 |
| 5 | Caravan Leather Jerkin | Rare | **Jerkin Keep** | guard | 8 | Keeper. Gain 6 guard; when it leaves your hand unplayed at round end, gain 3 guard anyway next round. | 22000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Camel-Wool Hooded Cape | Common | **Camel Hood Hum** | charm | 5 | If it fires first in its chain, cut its next hits by 2. | 3300 | 1 |
| 2 | Indigo Shawl | Common | **Indigo Shawl Bond** | charm | 5 | If you have no guard up, your Charm fills 10% more for the rest of the fight. | 3300 | 1 |
| 3 | Palm-Leaf Sun Cape | Uncommon | **Palm Sun Calm** | soothe | 4 | If you are at full health, its strongest piece loses 2 value. | 8800 | 2 |
| 4 | Rose-Madder Mantle | Uncommon | **Madder Veil** | trick | 5 | In its last round on the board, small chance to lift an item from the creature. | 8800 | 2 |
| 5 | Goat-Hair Tent Cape | Rare | **Tent-Cape Lull** | charm | 8 | Add 6 Charm. The creature loses its next move; if it already skipped one this fight, it also loses 3 value on its strongest piece. | 22000 | 3 |

## Blossomreach (EA, region level 20)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Hemp-Cord Sandals | Common | **Hemp Skip** | guard | 5 | If it fires first in its chain, this piece stays 2 more round(s) on the board. | 3600 | 1 |
| 2 | Rain Clogs | Common | **Rain Clog Splash** | hurt | 5 | If you have not played a Hurt this round, add 4 Charm. | 3600 | 1 |
| 3 | Indigo Stitch Boots | Uncommon | **Indigo Stitch Pierce** | hurt | 6 | If its Yield bar is past half, this piece ignores guard. | 9600 | 2 |
| 4 | Steppe Felt Boots | Uncommon | **Felt Boot Stay** | guard | 6 | If you have played 2 or more Guards this fight, the creature's first hit next turn misses. | 9600 | 2 |
| 5 | Snow Straw Boots | Rare | **Snow Straw Trip** | hurt | 8 | Trip. If it is alone in its chain, deal 6 extra damage and gain 3 extra redraw(s) this fight. | 24000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Bamboo A-Frame | Common | **Bamboo Frame Haul** | item | 6 | If its chain has 3 or more pieces, next round you pick from 6 pieces. | 3600 | 1 |
| 2 | Forager's Basket | Common | **Forager's Feast** | item | 6 | From round 3 on, heal 2 at the start of each of your next 2 turns. | 3600 | 1 |
| 3 | Knotted Cloth Bundle | Uncommon | **Knot Bundle Pluck** | trick | 5 | If a piece of its own type is linked to it, small chance to lift an item from the creature. | 9600 | 2 |
| 4 | Lacquer Tea Chest | Uncommon | **Tea Chest Steep** | heal | 5 | If a Charm fired just before it, heal 2 at the start of each of your next 2 turns. | 9600 | 2 |
| 5 | Quilted Silk Satchel | Rare | **Silk Satchel Rest** | heal | 7 | Heal 6. Keeper. While kept, your Heal pieces heal 3 more. | 24000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Indigo Work Jacket | Common | **Indigo Work Wall** | guard | 5 | If the creature has 3 or more pieces on the board, your next Guard gets +4. | 3600 | 1 |
| 2 | Padded Winter Vest | Common | **Padded Vest Thorn** | guard | 5 | If a Hurt fired just before it, a blocked hit pricks it for 4. | 3600 | 1 |
| 3 | Spring Wrap Coat | Uncommon | **Spring Wrap Mend** | guard | 6 | If you are at full health, heal 5. | 9600 | 2 |
| 4 | Fleece-Lined Jacket | Uncommon | **Fleece Jacket Keep** | guard | 6 | If the creature just hit you, this piece stays in your hand if unplayed. | 9600 | 2 |
| 5 | Ramie Summer Jacket | Rare | **Ramie Summer Jacket** | guard | 8 | Gain 6 guard. The first hit it blocks each round also heals you 3. | 24000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Straw Rain Cape | Common | **Straw Cape Frog** | charm | 5 | If it fires first in its chain, add 4 Charm. | 3600 | 1 |
| 2 | Plum Snow Hood | Common | **Plum Hood Hush** | soothe | 3 | If the creature just hit you, cut its next hits by 2. | 3600 | 1 |
| 3 | Maple Shawl | Uncommon | **Maple Shawl Bond** | charm | 6 | If it sits on the edge of the board, your Charm fills 10% more for the rest of the fight. | 9600 | 2 |
| 4 | Felt Herder's Poncho | Uncommon | **Herder's Pluck** | trick | 5 | If the creature has no pieces on the board, draw 2. | 9600 | 2 |
| 5 | Blossom Capelet | Rare | **Blossom Lull** | charm | 8 | Add 6 Charm. The next two Charm pieces you play this fight add 3 more. | 24000 | 3 |

## Spicepeak (CSA, region level 23)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Curl-Toe Slippers | Common | **Curl-Toe Pounce** | hurt | 6 | If a Trick fired just before it, deal 5 extra damage. | 3900 | 1 |
| 2 | Felted Snow Boots | Common | **Felt Snow Stand** | guard | 6 | If it sits on the edge of the board, this piece stays 2 more round(s) on the board. | 3900 | 1 |
| 3 | Toe-Ring Sandals | Uncommon | **Toe-Ring Pierce** | hurt | 7 | If it fires last in its chain, this piece ignores guard. | 10400 | 2 |
| 4 | Stilt Clogs | Uncommon | **Stilt Stomp** | hurt | 7 | If you have played 2 or more Hurts this fight, knock its weakest piece off the board. | 10400 | 2 |
| 5 | Wrapped Hide Boots | Rare | **Yak Wrap Stand** | guard | 9 | Gain 7 guard. The creature's first Hurt next turn misses; if it was a Pierce, it also pricks the creature for 3. | 26000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Chili Cone Basket | Common | **Chili Cone Feast** | item | 7 | If you are under half health, gain 2 extra redraw(s) this fight. | 3900 | 1 |
| 2 | Ikat Saddle Satchel | Common | **Ikat Satchel Pluck** | trick | 5 | If its chain has 3 or more pieces, double the value of the next piece in its chain. | 3900 | 1 |
| 3 | Porter's Frame Pack | Uncommon | **Porter Haul** | item | 8 | If it fires last in its chain, draw 2. | 10400 | 2 |
| 4 | Block-Print Bundle | Uncommon | **Print Bundle Brew** | heal | 6 | If it fires first in its chain, gain 6 guard. | 10400 | 2 |
| 5 | Stacked Tin Pack | Rare | **Tin Tiffin** | heal | 8 | Heal 7 now and 3 at the start of each of your next 3 turns. | 26000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Ikat Robe Coat | Common | **Ikat Robe Wall** | guard | 6 | If you have played 2 or more Guards this fight, its strongest piece loses 2 value. | 3900 | 1 |
| 2 | Kantha Patch Vest | Common | **Kantha Patch Thorn** | guard | 6 | If it sits next to the blank centre, a blocked hit pricks it for 5. | 3900 | 1 |
| 3 | Fleece-Collar Jacket | Uncommon | **Fleece Collar Mend** | guard | 7 | In its last round on the board, heal 2 at the start of each of your next 2 turns. | 10400 | 2 |
| 4 | Mirror-Work Smock | Uncommon | **Mirror Smock Glint** | guard | 7 | If nothing is linked to it, the creature's first hit next turn misses. | 10400 | 2 |
| 5 | Turmeric Wrap Coat | Rare | **Turmeric Wrap Keep** | guard | 9 | Keeper. Gain 7 guard. Heal 3 for every piece in your hand when it fires. | 26000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Leaf Rain Hood | Common | **Palm Hood Hum** | charm | 6 | If your hand is full, cut its next hits by 2. | 3900 | 1 |
| 2 | Fine Wool Shawl | Common | **Wool Shawl Bond** | charm | 6 | If you are at full health, your Charm fills 10% more for the rest of the fight. | 3900 | 1 |
| 3 | Felt Shepherd Cape | Uncommon | **Felt Cape Calm** | soothe | 5 | If its chain has 3 or more pieces, the creature skips its next move. | 10400 | 2 |
| 4 | Striped Yak Poncho | Uncommon | **Yak Poncho Pluck** | trick | 6 | If the creature just hit you, small chance to lift an item from the creature. | 10400 | 2 |
| 5 | Indigo Dot Cloak | Rare | **Indigo Dot Lull** | charm | 9 | Add 7 Charm. If the creature has guard up, its guard drops by 7. | 26000 | 3 |

## The Monsoon Tangle (SEA, region level 26)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Paddy Stilt-Clogs | Common | **Stilt Clog Surge** | hurt | 6 | If it sits next to the blank centre, deal 5 extra damage. | 4200 | 1 |
| 2 | Pandan Sandals | Common | **Pandan Skip** | guard | 6 | If its chain has 3 or more pieces, draw 3. | 4200 | 1 |
| 3 | Ikat Leech-Wraps | Uncommon | **Leech Wrap Guard** | guard | 7 | If you have not played a Hurt this round, heal 6. | 11200 | 2 |
| 4 | Rattan Trail Boot | Uncommon | **Rattan Rush** | hurt | 7 | If it fires first in its chain, this piece ignores guard. | 11200 | 2 |
| 5 | Mudflat Paddles | Rare | **Paddle Trip** | hurt | 9 | Trip. The creature also loses 4 value on every piece on its board, once. | 28000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Rattan Back-Basket | Common | **Rattan Back Basket** | item | 7 | If a Trick fired just before it, next round you pick from 6 pieces. | 4200 | 1 |
| 2 | Bamboo Ladder-Pack | Common | **Ladder Pack Rummage** | trick | 5 | If nothing is linked to it, draw 3. | 4200 | 1 |
| 3 | Batik Bundle | Uncommon | **Batik Bundle Brew** | heal | 6 | If you have played 2 or more Guards this fight, heal 3 at the start of each of your next 2 turns. | 11200 | 2 |
| 4 | Nipa Thatch Pack | Uncommon | **Nipa Thatch Snack** | item | 8 | If the creature just hit you, heal 6. | 11200 | 2 |
| 5 | Water-Jar Pack | Rare | **Water-Jar Plenty** | heal | 8 | Heal 7. Pick from 6 pieces next round, and keep any one you do not use. | 28000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Indigo Batik Smock | Common | **Batik Smock Wall** | guard | 6 | If you have played 2 or more Hurts this fight, gain 5 guard. | 4200 | 1 |
| 2 | Pandan Weave Vest | Common | **Pandan Vest Thorn** | guard | 6 | If a Charm fired just before it, this piece stays 3 more round(s) on the board. | 4200 | 1 |
| 3 | Ikat Wrap-Jacket | Uncommon | **Ikat Wrap Mend** | guard | 7 | If you are under half health, end your poison and heal 3. | 11200 | 2 |
| 4 | Kapok Puffer | Uncommon | **Kapok Keep** | guard | 7 | If the creature has guard up, this piece stays in your hand if unplayed. | 11200 | 2 |
| 5 | Mangrove Oilcloth | Rare | **Oilcloth Slip** | guard | 9 | Gain 7 guard. Its first hit next turn misses; if it has no pieces left, it also loses 4 value on its next piece. | 28000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Frond Rain Cape | Common | **Palm Frond Hum** | charm | 6 | If it fires last in its chain, cut its next hits by 3. | 4200 | 1 |
| 2 | Banana-Leaf Hood | Common | **Banana Hood Calm** | soothe | 4 | If it sits in a corner, gain 3 extra redraw(s) this fight. | 4200 | 1 |
| 3 | Batik Shawl | Uncommon | **Batik Shawl Bond** | charm | 7 | If it sits next to the blank centre, your Charm fills 10% more for the rest of the fight. | 11200 | 2 |
| 4 | Net-Veil Mantle | Uncommon | **Net-Veil Pluck** | trick | 6 | If you have no guard up, small chance to lift an item from the creature. | 11200 | 2 |
| 5 | Monsoon Poncho | Rare | **Monsoon Lull** | charm | 9 | Add 7 Charm. Its next two pieces fire at half value. | 28000 | 3 |

## The Greatcanopy (WCA, region level 29)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Palm-Sole Sandals | Common | **Palm Sole Skip** | guard | 6 | If it fires first in its chain, this piece does not count toward the chain limit. | 4500 | 1 |
| 2 | Mudwader Wraps | Common | **Mudwader Trip** | hurt | 6 | If its Yield bar is under a quarter, the creature skips its next move. | 4500 | 1 |
| 3 | Rainroot Clogs | Uncommon | **Rainroot Bash** | hurt | 7 | If you have played 2 or more Guards this fight, deal 6 extra damage. | 12000 | 2 |
| 4 | Ochre Trail Boots | Uncommon | **Ochre Boot Hold** | guard | 7 | If nothing is linked to it, this piece stays 3 more round(s) on the board. | 12000 | 2 |
| 5 | Plantain Slippers | Rare | **Plantain Quick** | hurt | 9 | Fires first. Draw 4. If a Hurt of yours fires later in the chain, it gets +7. | 30000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Calabash Pack | Common | **Calabash Plenty** | item | 7 | If you took no damage last turn, next round you pick from 6 pieces. | 4500 | 1 |
| 2 | Raffia Cone Basket | Common | **Raffia Cone Snack** | item | 7 | In its last round on the board, this piece stays in your hand if unplayed. | 4500 | 1 |
| 3 | Indigo Bundle | Uncommon | **Indigo Bundle Pluck** | trick | 6 | If you hold 2 pieces or fewer, small chance to lift an item from the creature. | 12000 | 2 |
| 4 | Tooled Satchel | Uncommon | **Tooled Satchel Brew** | heal | 6 | If the creature has guard up, heal 3 at the start of each of your next 2 turns. | 12000 | 2 |
| 5 | Bamboo Frame Pack | Rare | **Bamboo Frame Stew** | heal | 8 | Heal 7 now and 4 at the start of each of your next 2 turns; the second heal also draws you 4. | 30000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Strip-Weave Smock | Common | **Strip Smock Thorn** | guard | 6 | From round 3 on, a blocked hit pricks it for 5. | 4500 | 1 |
| 2 | Mudcloth Vest | Common | **Mudcloth Hold** | guard | 6 | If it is linked to 2 or more pieces, this piece stays 3 more round(s) on the board. | 4500 | 1 |
| 3 | Raffia Rain Coat | Uncommon | **Raffia Rain Slip** | guard | 7 | If it is linked to 2 or more pieces, the creature's first hit next turn misses. | 12000 | 2 |
| 4 | Adire Jacket | Uncommon | **Adire Mend** | guard | 7 | If you are poisoned, gain 6 guard. | 12000 | 2 |
| 5 | Kapok Jerkin | Rare | **Kapok Jerkin** | guard | 9 | Keeper. Gain 7 guard; the longer it stays in your hand, the more it gives (+4 each round). | 30000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Plantain Leaf Cape | Common | **Plantain Cape Hum** | charm | 6 | If the creature just hit you, add 5 Charm. | 4500 | 1 |
| 2 | Strip-Weave Shawl | Common | **Strip Shawl Bond** | charm | 6 | If you have played 2 or more Guards this fight, your Charm fills 10% more for the rest of the fight. | 4500 | 1 |
| 3 | Indigo Hood Mantle | Uncommon | **Indigo Mantle Calm** | soothe | 5 | If the creature has no pieces on the board, this piece stays in your hand if unplayed. | 12000 | 2 |
| 4 | Raffia Poncho | Uncommon | **Raffia Poncho Lull** | charm | 7 | If a Charm fired just before it, the creature skips its next move. | 12000 | 2 |
| 5 | Scaleleaf Mantle | Rare | **Scaleleaf Mantle** | guard | 9 | Gain 7 guard. Each Charm you play this round adds 4 guard to it. | 30000 | 3 |

## Thornacre Savanna (ESA, region level 32)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Acacia Sandals | Common | **Acacia Sandal Skip** | guard | 7 | If you are at full health, this piece does not count toward the chain limit. | 4800 | 1 |
| 2 | Highland Trek Boots | Common | **Highland Trek Hold** | guard | 7 | If a Guard fired just before it, the creature's first hit next turn misses. | 4800 | 1 |
| 3 | Sisal Slippers | Uncommon | **Sisal Slip Pierce** | hurt | 8 | If you have no guard up, this piece ignores guard. | 12800 | 2 |
| 4 | Stripe Gaiters | Uncommon | **Stripe Gaiter Finish** | hurt | 8 | If its Yield bar is past half, deal 7 extra damage. | 12800 | 2 |
| 5 | Baobab Clogs | Rare | **Baobab Thud** | hurt | 10 | Fires last. Deal 8 extra damage per piece in the chain, and knock its weakest piece off the board. | 32000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Coiled Basket Pack | Common | **Coiled Pack Plenty** | item | 8 | If its chain has 3 or more pieces, this piece stays in your hand if unplayed. | 4800 | 1 |
| 2 | Calabash Carrier | Common | **Gourd Brew** | heal | 6 | If the creature just hit you, gain 3 extra redraw(s) this fight. | 4800 | 1 |
| 3 | Grain Sack Pack | Uncommon | **Grain Sack Meal** | item | 9 | If a piece of its own type is linked to it, heal 7. | 12800 | 2 |
| 4 | Acacia Frame Pack | Uncommon | **Frame Rummage** | trick | 7 | If its Yield bar is past half, next round you pick from 6 pieces. | 12800 | 2 |
| 5 | Herder's Satchel | Rare | **Herder's Satchel** | heal | 9 | Heal 8. Pick from 6 pieces next round; every Hurt among them is +4 this round. | 32000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Barkcloth Smock | Common | **Barkcloth Thorn** | guard | 7 | If a Guard fired just before it, a blocked hit pricks it for 6. | 4800 | 1 |
| 2 | Stripe Weave Vest | Common | **Stripe Vest Hold** | guard | 7 | If the creature has no pieces on the board, your next Guard gets +6. | 4800 | 1 |
| 3 | Highland Wool Coat | Uncommon | **Highland Mend** | guard | 8 | If you took no damage last turn, heal 3 at the start of each of your next 2 turns. | 12800 | 2 |
| 4 | Savanna Field Jacket | Uncommon | **Field Jacket Slip** | guard | 8 | If it fires first in its chain, its strongest piece loses 3 value. | 12800 | 2 |
| 5 | Beaded Tunic-Coat | Rare | **Beaded Tunic-Coat** | guard | 10 | Gain 8 guard. For each distinct piece type you have played this round, gain 4 more. | 32000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Check Blanket Wrap | Common | **Check Wrap Hum** | charm | 7 | If a piece of its own type is linked to it, cut its next hits by 3. | 4800 | 1 |
| 2 | Highland Shawl | Common | **Highland Shawl Bond** | charm | 7 | In the first round of the fight, your Charm fills 10% more for the rest of the fight. | 4800 | 1 |
| 3 | Banana-Leaf Rain Cape | Uncommon | **Banana Rain Calm** | soothe | 6 | In its last round on the board, its strongest piece loses 3 value. | 12800 | 2 |
| 4 | Dust Mantle | Uncommon | **Dust Mantle Lull** | charm | 8 | If it fires first in its chain, the creature skips its next move. | 12800 | 2 |
| 5 | Indigo Dot Shawl | Rare | **Indigo Dot Shawl** | trick | 9 | The next Charm in its chain adds 8 more, and the next Hurt gets +4. | 32000 | 3 |

## The Coralscatter (OC, region level 35)

### Footwear

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Reef Sandals | Common | **Reef Skip** | guard | 7 | If a Guard fired just before it, draw 3. | 5100 | 1 |
| 2 | Gully Fleece Boot | Common | **Gully Hold** | guard | 7 | If the creature just hit you, this piece does not count toward the chain limit. | 5100 | 1 |
| 3 | Drover's Pull-ons | Uncommon | **Drover Pierce** | hurt | 8 | If a Trick fired just before it, this piece ignores guard. | 13600 | 2 |
| 4 | Flax Wading Wraps | Uncommon | **Flax Wade Trip** | hurt | 8 | If the creature has 3 or more pieces on the board, the creature skips its next move. | 13600 | 2 |
| 5 | Mangrove Clog | Rare | **Mangrove Clog Crush** | hurt | 10 | Heavy. Fires last, deals 8 extra damage, and the creature skips its next move if its Yield bar is past half. | 34000 | 3 |

### Backpack

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Flax Basket Pack | Common | **Flax Plenty** | item | 8 | If it fires last in its chain, next round you pick from 6 pieces. | 5100 | 1 |
| 2 | Coconut String Bag | Common | **Coconut Snack** | item | 8 | If you are at full health, gain 3 extra redraw(s) this fight. | 5100 | 1 |
| 3 | Bushman's Swag | Uncommon | **Swag Rummage** | trick | 7 | If you have not played a Hurt this round, small chance to lift an item from the creature. | 13600 | 2 |
| 4 | Bamboo Frame Pack | Uncommon | **Frame Simmer** | heal | 7 | If it sits in a corner, heal 3 at the start of each of your next 2 turns. | 13600 | 2 |
| 5 | Pouch Pack | Rare | **Pouch Provision** | heal | 9 | Heal 8. Keep every unplayed piece in hand this round; next round pick from 6. | 34000 | 3 |

### Coat

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Drover's Oilskin | Common | **Oilskin Thorn** | guard | 7 | If it fires last in its chain, a blocked hit pricks it for 6. | 5100 | 1 |
| 2 | Bush Check Smock | Common | **Bush Check Hold** | guard | 7 | If you have guard up, your next Guard gets +6. | 5100 | 1 |
| 3 | Bark-cloth Vest | Uncommon | **Bark Vest Mend** | guard | 8 | If nothing is linked to it, heal 3 at the start of each of your next 2 turns. | 13600 | 2 |
| 4 | Reef Sail-cloth Jerkin | Uncommon | **Sail Jerkin Slip** | guard | 8 | In its last round on the board, the creature's first hit next turn misses. | 13600 | 2 |
| 5 | Gum-dyed Cardigan | Rare | **Gum-dye Keep** | guard | 10 | Keeper. Gain 8 guard. When the creature plays a Hurt, you may play this from hand for free in response. | 34000 | 3 |

### Cloak

| # | Item | Rarity | Piece | Type | Value | Effect | Petals | Tailor |
|---|---|---|---|---|---|---|---|---|
| 1 | Frond Rain Cape | Common | **Frond Cape Hum** | charm | 7 | If nothing is linked to it, cut its next hits by 3. | 5100 | 1 |
| 2 | Fleece Mantle | Common | **Fleece Mantle Bond** | charm | 7 | If it fires first in its chain, your Charm fills 10% more for the rest of the fight. | 5100 | 1 |
| 3 | Hibiscus Pareo | Uncommon | **Pareo Calm** | soothe | 6 | If it fires last in its chain, the creature skips its next move. | 13600 | 2 |
| 4 | Red-dust Poncho | Uncommon | **Red-Dust Lull** | charm | 8 | If its Yield bar is past half, the creature skips its next move. | 13600 | 2 |
| 5 | Storm-petrel Hood | Rare | **Storm-petrel Hood** | trick | 9 | Lift an item for sure; the creature's strongest piece loses 8 value, and you draw 4. | 34000 | 3 |

# One piece per crop, each with its own effect: proposal (nothing built)

2026-11-15. For Josh to pick from. Source data: `game/includes/data/crops.txt` (194 crops plus 3 cover crops, 9 kinds), `pf_pieces.txt` (today's 9 kind pieces), `pfdeck.php` (`pfd_sources`, `pfd_build`), the tags in `pfight.php` (`PF_TAGS_V1`, `PF_MODS`) and Fable's `fable/piece-effects.md`.

## Where we are

- Today a crop gives one piece per KIND (9): growing a tomato or an onion gives the same Garden Greens. 194 crops, 9 pieces.
- Step 1 (2.6.989) is in: the Larder holds 3 crop pieces (4 at level 10, 5 at level 20), new pieces arrive off.
- So a gnome plays with 3 to 5 crop pieces at a time. A piece per crop is mostly about what you can CHOOSE from, and about each crop being a thing of its own.

## The tension

194 unique effects is not possible, and would not be readable: a player has to be able to say what a piece does in one line. So "unique" has to be built from parts. Three ways to get there, cheapest first.

| | A. Built from parts | B. Hero crops plus parts | C. New effects too |
|---|---|---|---|
| What | Every crop gets its own piece: own name, picture tint, text, and a unique COMBINATION of type, tag, built-in knack and value from the effects the engine already has | A. plus about 30 notable crops (Tomato, Potato, Corn, Vanilla, Coconut ...) get a hand-written effect that is not a combination | B. plus the new effect kinds from `piece-effects.md` (Keeper, Plenty, Simmer, Sturdy, Pairs) used on crops |
| Engine work | None. Generated pieces, like pal pieces (`pfd_pal_pieces`) | A hook per hero effect (PHP, JS twin, parity) | Several new hooks, bot teaching, sims |
| Uniqueness | Name, text and the exact combination are unique per crop (at least 3 types x 4 tags x 7 knacks x 6 values to draw from per kind) | Heroes are truly unique | Most varied |
| Risk | Low. Two crops can feel alike if their combos differ by 1 point | Medium: 30 hand-balanced pieces | High: dead-effect trap (Quick, Heavy and life are dead today) |

My recommendation: **A first, B for about 20 heroes next**, C only for the dish pieces where the effect suits the food (feast, preserve).

## How A works (rules a player can learn)

1. **Kind sets the type family** (the player already half-knows this):

| Kind | Crops | Type family | Tags it draws from |
|---|---|---|---|
| vegetable | 43 | Heal, Guard | mend, hold, evade |
| tuber | 5 | Guard | hold, thorns |
| legume | 14 | Charm | bond, hum, lull |
| grain | 16 | Guard, Heal | hold, mend |
| fruit | 22 | Heal, Item (a snack) | none, snack |
| tree | 55 | Hurt, Guard | heavy, hold, thorns |
| nut | 11 | Hurt | pierce, bash |
| herb | 13 | Heal, Charm | mend, lull |
| spice | 15 | Hurt | poison, pierce, trip |

2. **Tier (1 fast to 6 slow) sets the base value**, slow crops hit harder: 2 at tier 1 up to 6 at tier 6 (today's kind pieces sit at 3 to 5). Your mastery of that crop adds the usual rank bonus.
3. **Perennial crops (keep producing) get a built-in knack** (Leech, Spiky, Tender, Soft touch, Warm, Finisher: already coded). Annuals get none. So about 60 perennials are the "special" pieces.
4. **The crop's own name picks the rest by a fixed hash** (so it never changes between versions): which tag of the family and which knack, with a check that no two crops of a kind get the same type, tag, knack and value. The check lives in a test.
5. **Knob family**: all crops stay in the mind family, as today, so crop pieces link to each other and to pals less than to tools. (A choice to confirm below.)

Example pieces (illustrative, not final numbers):

| Crop | Kind, tier | Piece |
|---|---|---|
| Tomato | vegetable, 3 | **Tomato Splat**: Heal 5, mend (heals a bit more while you are low) |
| Onion | vegetable, 3 | **Onion Sting**: Guard 4, evade (the creature's first hit misses) |
| Potato | tuber, 3 | **Spud Wall**: Guard 5, hold (some guard stays up into your next turn) |
| Pea | legume, 2 | **Pea Whisper**: Charm 3, bond (it warms to Charm for the fight) |
| Maize | grain, 4 | **Cornbread Crust**: Guard 5, hold, Tender |
| Strawberry | fruit, 3, perennial | **Berry Burst**: Item 4, Soft touch (also calms it) |
| Coconut | tree, 6, perennial | **Coconut Drop**: Hurt 8, heavy, Finisher |
| Walnut | nut, 6, perennial | **Walnut Crack**: Hurt 7, pierce, Leech |
| Black Pepper | spice, 6, perennial | **Pepper Storm**: Hurt 6, poison, Warm |
| Basil | herb, 2 | **Basil Calm**: Heal 3, mend |

## What it does to the rest

- **Collection screen:** 194 pieces cannot be a flat grid. The Puzzle box needs a Crops tab with a search box and a filter by kind. The Larder row at the top shows the 3 to 5 you packed.
- **Old gnomes:** the 9 kind pieces become the first crop of each kind they grew (Garden Greens becomes the tomato piece they have mastered most). Their packed choice carries over; nothing is lost.
- **Deck model sims:** `tv_sources` models 14 to 22 pieces. With slots the Larder is at most 5, so the sims only need the Larder filled with typical crop pieces. A balance check: no crop piece may beat a calling or tool piece of the same rank by more than 1 point (a test over all 194).
- **Rarity:** rank comes from that crop's mastery, as the kind pieces do now, so the Rare cap (3) still applies.
- **Art:** one generic crop piece picture tinted per crop (the piece art already tints by creature). Per-crop art is not needed.
- **Files:** `pfdeck.php` (`pfd_sources` reads a crop slug instead of a kind, a `pfd_crop_pieces()` generator beside `pfd_pal_pieces`), `pfdeck_view.php` (Crops tab, search, filter), `tests/pfdeck_v1.php` (uniqueness and balance over all crops), data: a small override file `pf_crop_pieces.txt` for the heroes.

## Questions for Josh

1. **A, B or C?** (My pick: A now, about 20 heroes in B after you have played it.)
2. **Cover crops** (clover, rye): no piece, or a weak Heal piece each? (My pick: no piece, they are for the soil.)
3. **Knob family:** all crops in the mind family (as today), or by kind (vegetables body, nuts craft, spices mind)? Mixed families make crop pieces link to tools and pals more. (My pick: by kind, it gives crop pieces a reason to sit beside different neighbours.)
4. **Slow crops hit harder** (tier 6 gives Hurt 8 and so on)? That rewards patience and matches the 2.6.989 Larder (few slots, so a strong piece matters). (My pick: yes, capped at +4 over a tier-3 crop.)
5. **Heroes:** which crops matter most to you? Tell me up to 20 and I will write their effects by hand.

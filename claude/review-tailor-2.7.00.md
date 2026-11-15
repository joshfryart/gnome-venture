# Review: the Tailor and the six wearables (2.7.00)

Read-only review, 2026-11-15. No game file was changed and no sim was run. Checked against `pfight.php` (`pf_apply`, `PF_TAGS_V1`, `PF_MODS`), `pfboard.php`, `pfdeck.php`, `gardens.php`, `gnome25.php`, `data/pf_pieces.txt`.

## 1. Verdict
- The building gate is fine. The yield rule as planned is a chore: about 16 crafts in a gnome's life, then the Tailor is dead.
- The roll saves a few materials. A level 3 Tailor costs 9,900 Petals plus 21 stone, 21 planks, 11 rope for +24%. The sensible build is one level 1 Tailor, never upgraded.
- Six single pieces are thin, and three copy a level 6 to 15 knack almost exactly (Roll, Mending, and now Bond or Pluck).
- Variety is nearly free: the piece file already takes a per-piece tag, knack and column family, so "cuts" and "patches" are data rows, not engine work.
- Art can drop from three new layers (72 frames) to one new layer plus palette swaps.

## 2. The five biggest problems
1. **No repeatable use.** 4 base crafts + 12 linings and the building is finished. Nothing brings the player back, and levels 2 and 3 add only a number.
2. **The roll can hurt.** A lucky Fine counts as Rare. With 3 Rares in the deck, `pfd_build` marks the 4th `out = cap`, so the lucky gloves cannot be worn. A failed roll gives nothing, so players re-craft and collect junk duplicates.
3. **The gate leaks.** Hat and Pack are bought at Twigg's and the Cloak is found: half the set needs no Tailor. Wearables are "from level 1" but the Tailor needs garden level 6 and 1,800 Petals.
4. **Power above 6 is wasted.** Four gardens give 12 points, the cap is reached at 6. Tailors 3 and 4 do nothing.
5. **Dead or copied effects.** For the player on this board Quick, Heavy, Sticky and Lucky do nothing (the hand is redrawn; `pfboard.php` never reads `redraws`). Soothe and Item take no tag except Keeper, Plenty, Simmer. A Trick takes only Pluck. So the Hat cannot stay a Soothe, and the Pack as a Trick can only be Pluck.

## 3. Revised wearables
Every tag below is read in `pf_apply` for that type. Leech is the knack column (`m`), already used by a legend piece. Base + stat + level / 3 + rank, as today.

| Wearable | Piece | Type, base, knob | Tag | Rules text | Obtained | Avatar |
|---|---|---|---|---|---|---|
| Flood Boots | Puddle Hop | Guard 3, body | evade | Its first hit next turn misses, and poison ticks do nothing. | Tailor craft; Sights on flooded routes | existing `boots` layer, palette swap |
| Wayfarer's Hat | Tip of the Hat | Charm 2, mind | bond | Your Charm fills 10% more for the fight, up to 3 times. | Twigg's 300, level 5 (admin-only) | band and feather: small overlay on `hat` |
| Work Gloves | Firm Grip | Hurt 3, craft | knack leech | Heals you 1 + a sixth of the hit when it lands. | Tailor craft | hands as a fifth marker grey in `skin` |
| Travel Cloak | Wrap Up | Guard 3, mind | mend | Heals you 2 as well. | found from level 10; Tailor craft | new `back` layer |
| Trail Pack | Rummage | Trick 2, body | pluck | Adds its number to a Hurt or Guard fired right after it. Small chance to lift the creature's item. | Twigg's 800, level 15 (admin-only) | same `back` layer; straps in front view |
| Yarn Scarf | Yarn Wrap | Charm 3, craft | none | A plain Charm. | Cat Fish, 12 Yarn | existing `scarf` layer |

**Second cut** (chosen at craft time, same item and art, one more data row each): Boots "Stand Fast" Guard 3 hold; Hat "Soft Word" Charm 2 hum; Gloves "Shove" Hurt 3 bash; Cloak "Burr Cloak" Guard 3 thorns. Pack and Scarf have one cut.

**Roles** (reason to swap): Boots for Reptiles and poisoners; Hat for Beasts (Grudge punishes blocking) and long fights; Gloves for short fights and Plants; Cloak for Critter swarms; Pack for item farming and Ambush.

**Outfits without a new rule:** the existing combos already pair them. Cloak or Boots then Gloves = Riposte; Pack then Gloves = Ambush; Pack then a Guard = Bait; Hat feeds Scarf through Bond. Print these on the item pages.

Not verified: that "Shove" (bash) reads guard built in the same board chain, and Hold carried from last turn. No wearable carries Trip or Lull (rule book 10.5 open).

## 4. Revised Tailor
Kept as Josh decided: building required; power = sum of Tailor levels across gardens; each point +8% for one tier better, cap 48%, never two tiers.

| Level | Cost (existing upgrade settings) | Garden level | Adds |
|---|---|---|---|
| 1 | 1,800 Petals | 6 | Craft and line wearables; pick the cut. |
| 2 | 2,700 + 6 stone, 6 planks, 3 rope | 8 | **Patch bench**: a patch sets the piece's column family (body, mind or craft; the file's `/COLUMN` field). 2 Cottongrass, swappable. **Re-cut**: change the cut for 2 Coir Fibre. |
| 3 | 5,400 + 15 stone, 15 planks, 8 rope | 10 | **Daily commission**: a villager orders one garment at half materials; pays Petals and 1 Thread. First craft a day costs no energy. **Dye**: palette recolour of a worn layer, style only. |

- **Roll**: once per craft, on the result. Base craft: Common to Lined. Lining: Lined to Fine. Fine lining: no roll.
- **Pity**: a failed roll gives 1 Thread. 5 Threads = one sure step up.
- **Rare cap**: a Fine wearable can be worn "as Lined" (a switch in the Puzzle box), so luck is never a loss.
- **Points 7 to 12**: +5% commission Petals each, so a third and fourth Tailor still pay.
- **Gate**: bought and found wearables stay Common without a Tailor; cuts, lining, patches need one.
- **Columns**: do not make all six body family. Default to the type's family, changed by the patch.

## 5. Simulate before shipping
1. Section 5 again with the new six, Common, Lined, Fine, decided slots; pass = wins within 3 points, at most half a turn longer.
2. Pluck stacking: each play is a new try until one succeeds (`min(35, 8 + 3 x luck)`%, halved on a boss). Lift rate per fight with 1, 2, 3 Pluck pieces at luck 0, 5, 9.
3. Bond stacking: Hat + knack Bond + Sweet Pea + Saffron against large and boss creatures (turns to Yield).
4. A Fine Trick before the biggest Hurt (Ambush adds the Trick's value): largest single hit at levels 28 and 40.
5. Level 40 with four slots earned; the harness stops at 32.
6. The 3 Rare cap: Fine wearable against trophy against Rare legend piece. How often is the wearable the one left out?
7. All-body columns against per-type columns, with two pals in the party.
8. Teach the bot that Evade stops poison, then Boots against Reptiles.
9. Tailor economy: Petals, materials and crafts to reach 3 Fine at power 1, 3, 6, with and without pity.
10. "Shove" after a Hold guard: largest hit.

## 6. Questions for the owner
1. Does the roll apply on the base craft, the lining, or both?
2. May a Fine wearable be worn as Lined, and is the 5-Thread pity acceptable?
3. Two Charm wearables (Hat with Bond, Scarf plain): fine? Otherwise the Hat becomes Guard 2 thorns, "Brim Down".
4. Two cuts per wearable on the same art: wanted, or one piece per item?
5. May Cloak and Pack share one back layer (Pack drawn over Cloak), and Gloves and Boots be palette swaps?
6. Should Hat and Pack stay shop items that need no Tailor?
7. Points above 6: wasted, or the commission bonus?

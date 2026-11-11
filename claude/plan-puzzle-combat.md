# Puzzle Combat: design proposal (rev 2, no code yet)

Status: proposal. Replaces the option-menu fight with a deckbuilder of jigsaw tiles. Sources: user Q&A, Fable 5.2 review. Open items are marked **(open)**.

## 1. Rollout
- All fight kinds: road, lair, delve, Trek. Behind a flag (`pfight_open`), admins first. Old engine stays while the flag is off; its golden/balance tests must stay green.
- Build order: (1) solo fights through `combat_turn` (road/lair/delve), (2) Trek party mini-decks.
- No no-JS fallback for the new screen (old form-POST fight stays when flag off).

## 2. Turn loop
- Start hand 5. Each turn draw 3, hand cap 5. **Decided: after your 4-tile chain the foe plays +1 tile** (so a max chain is a gamble, not always right).
- One shared strip across the top. You play a chain of 1-4 tiles, then the foe replies with a chain. Strip scrolls right; newest is current. Played tiles go to the owner's discard; the draw pile reshuffles from discard when empty. The strip is a visual log of about one round.
- **Decided:** player goes first.
- Effects resolve left to right on confirm. One POST per chain with a turn number (double tap ignored). Server authoritative; never send deck order or the foe's hand.

## 3. Tiles and fit
- A tile has a left and right socket (knob or hole) in one of 3 families: Body (round/peg), Mind (keyhole/double), Craft (tri/hook). Colour + shape + glyph (never colour only).
- **Fit is a bonus, not a gate.** Any tile can start or extend a chain. A snug link gives extra value and enables combos. Foiling: if your open end does not fit the foe's planned tile, that tile loses its bonus (and the foe may swap to a fitting tile in hand).
- Pal pieces: knob = right-end family; left socket from effect type; flat sides of corner/edge pieces are wild. Knob counts are skewed (Mind 273 / Body 208 / Craft 89 of 570), so families may be rebalanced or Craft accepted as rare.
- Effect types: Hurt, Guard, Heal, Charm, Soothe, Trick, Item.
- Stats scale numbers, no d20: Grit -> Hurt, Nimble -> Guard, Hardiness -> HP, Luck -> redraw (1 per 4 Luck/turn), Charm stat -> Charm/Soothe, Lore -> Trick/Item, level adds to tile values. Crits are replaced by combos; remap `crit_from`, `atk_nimble`, pal luck-crit and knacks.

## 4. Combos
Type-based (so they appear), not tied to named tiles, and also across the seam. Examples: Trick>Hurt = Ambush (x2), Guard>Hurt = Riposte (also your Guard onto the foe's Hurt), Hurt>Hurt = Double Swing, Soothe>Charm = Calm Charm, Charm>Item = Win Over, Taunt>Guard = Bait. Each gets an Almanac entry.

## 5. Why a 4-chain is not always best
Open end exposure, hand thinning, setup-before-payoff order, and foiling. See section 2 for the draw-rule fix.

## 6. Goals and pay
- **Decided:** one resolve bar per creature; Hurt and Charm both fill it, each scaled by a per-species multiplier (hostile: Hurt x1, Charm x0.5; gentle the reverse). Mixed chains still progress. Outcome (see off vs charmed) = which type dealt most. Soothe lowers foe aggression. **"Other" goal cut:** only see off and charm.
- Every creature can be seen off or charmed, at different costs; hostile species cost more to charm. Story bosses stay see-off only unless authored otherwise.
- Pay: see off = normal XP + drops. **Decided:** Charm = full XP, `calling_event('befriend')` quest credit, and a species-specific gift instead of drops (gift table authored with archetype decks). **Bloomcaller stays special:** their Charm/Soothe tiles have bigger numbers and their charmed gifts are a rarer tier. Watch calling-quest inflation now that every calling can charm.
- Defeat unchanged: wake where you started, no item loss. Language: "see off", not "kill".
- **Decided:** Run is a button outside the deck; always works vs non-boss (no reward, no loss); disabled vs bosses.

## 7. Decks
- Gnome base 6: Swing, Dodge, Rest, Charm, Snack, Hide. Soothe, Offer, Taunt unlock/craft later (crafting hook).
- Calling 6 unique tiles. Tier II/III **upgrade** tiles (not +2 added); lost on calling change.
- Puzzle Pals: each of the 2 pals **swaps in**, replacing one gnome tile with a stronger pal tile; tile generated from calling, perk, rarity, stats (570 pals cannot be hand-authored). Deck stays about 14-16. **Decided:** existing in-fight pal skills (ward, edge, mend, kindle) and active Boons convert into the pal's tile (no double-dip). Out-of-fight pal perks stay unchanged.
- Snack/Item tiles must consume real snacks and respect `snack_limit`.
- Trek: each member (companion) has a mini-deck and plays its own chain **Decided:** members play in sequence on the one strip (last 4 shown); each member's chain is 1-4 tiles. **(open: per-round tile cap, foe targeting; build second)**. `trek_fight.php` per-member HP, cooldowns, ally targeting and boss scripts (Old Pinch hold) need mapping.

## 8. Creatures
- About 8 archetype decks keyed by size and temperament, plus 1-2 signature tiles per species, in a separate runtime data file (not a new `creatures.txt` column: `import_creatures_txt` skips existing slugs). 88 creatures: 10 small, 26 medium, 43 large, 9 boss.
- Foe hand 3 (boss 4), shows hand count + intent icon. Bosses keep authored patterns as ordered decks.
- Pace targets: 2-3 turns small, 4-5 large, 6-8 boss. Foe HP derived from pace (target turns x expected Hurt/turn), not the old size formula. No auto-play.
- Stall cap (old `fight_on` cap 30 rounds): set a turn cap with a gentle resolution.

## 9. UI (412px phone)
- Strip top, scene middle, hand bottom. Strip shows the last 4 tiles plus an enlarged open end.
- Tap builds the chain (numbered order badges + Undo); drag optional (`touch-action: none`). Live preview of totals and open end.
- Server sends per-tile values + combo table; client only sums. aria-labels ("Swing, Hurt 6, ends Mind"), aria-live for the foe's reply, strip scroll stops under `prefers-reduced-motion`. No inline styles (CSP `style-src 'self'`).

## 10. Tests
Keep old goldens green with flag off. New: seeded-shuffle golden; bot sims (greedy, always-foil, charm-only, stall) over all 88 creatures; invariants (tile conservation, no turn without a legal move, every fight ends within N turns).

## 11. Still open
1. Trek per-round tile cap and foe targeting (build second). 2. Species gift table and charm multipliers per archetype. 3. Knob-family rebalance (Craft rare).

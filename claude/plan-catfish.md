# Cat Fish (working title): Lazy Rod

Incremental game under Games. A toy fishing rod sways by itself with plushie fish on strings. Your adopted cat catches fish and drops **Kibble**. Spend Kibble on upgrades. **Nap** (prestige) resets for **Yarn** (permanent multiplier). Idle: server time only, 50% offline, 8h cap.

Gate: `catfish_open()` = admin, or setting `catfish_open` = 1 (Games hub tile hidden while off). All names start `catfish_` / `cf_`.

## Cats (adoptable, generated)
A cat is one integer **seed**; traits come from a seeded RNG, nothing else stored.
- Shelter shows 3 cats. Seed = `crc32(user_id|date|slot)`, so it rolls daily with no table spam.
- First adoption free. Later ones cost Kibble (grows with cats owned). Max cats 4 (shelter upgrades raise it).
- Traits: pattern (solid, tabby, tuxedo, calico, pointed, spotted*), colour (8, 2 rare), eyes (5, odd-eyed very rare), ears (normal, folded*), tail (normal, bobtail), personality (Lazy, Hyper, Sneaky, Greedy, Dreamy), quirk (1 in 6, flavour).
- Rarity score from trait weights: Common, Uncommon, Rare, Legendary.
- Personality perks (small, capped): Lazy +25% offline cap, Hyper +15% Kibble while page open, Sneaky rare-fish chance, Greedy +10% Kibble, Dreamy +10% Yarn.

## Upgrades (16 nodes, cost `base * 1.15^n`, x2 at 10 / 25 / 50 owned)
Fish (+fish x3, silk tail, catnip stuffing), Rod (longer string, spring, motor, double rod), Room (sunbeam, rug, scratch post, window bird), Cat (3 breed boosts).

## Rewards
- **R1 Collection:** Cat Book (pattern x colour pages), badges (First Adoption, 3 Cats, First Nap, Odd-Eyed Finder).
- **R2 Yarn and shelter:** Nap gives Yarn. Spend Yarn on shelter reroll, Rare Shelter, extra cat slots. Petals only as one-time milestones, weekly cap 100 (`game_petals()`).
- **R3 Gnome tie-in:** weekly Cat Show (themed, server-rolled judges from traits and rarity, cosmetic ribbons), cat on a garden bed, Puzzle Pals +2% Kibble each, festival week x2 Yarn.

## Tables
`cats` (id, user_id, seed, name, adopted_at), `catfish_state` (user_id, kibble, yarn, upgrades JSON, active_cat_id, last_tick, naps), `cat_book` (user_id, pattern, colour). Created lazily by `catfish_ensure()` (same pattern as `puzzles_ensure()`).

## Art (~63 sprites, layered and tinted in code)
Grayscale body 8 frames, pattern overlays 6 x 4 key frames, eyes 2, ear/tail variants 4, fish / rod / room / UI ~15, badges and ribbons ~10. Week 1 uses CSS and emoji placeholders.

## Model split
Sonnet builds. Haiku for tests, mechanical edits, art-brief lists. Opus for the mid-week and end-of-week reviews.

## TODO

**Week 1**
- [x] Plan saved
- [x] `includes/catfish.php`: constants, gate, `catfish_ensure()` schema
- [x] Seed generator + rarity (`catfish_cat($seed)`)
- [x] Shelter (3 daily), adopt, rename, switch
- [x] Tick + offline calc (50%, 8h cap), server time only
- [x] 8 starter upgrades, cost curve, buy endpoint
- [x] `catfish.php` page, `catfish_open` setting, Games hub tile
- [ ] Version bump + CHANGELOG entry (only at release; feature stays hidden behind `catfish_open`)
- [x] Placeholder art, no inline script or style (CSP)
- [ ] `tests/catfish.sh` and a ci_suites entry
- [ ] Opus mid-week review

**Week 2:** full 16-node tree, Nap + Yarn, personalities, Cat Book + badges, test growth, Opus end-of-week review.
**Week 3:** shelter upgrades, milestone Petals with cap, Opus mid-week review.
**Week 4:** Cat Show, garden bed cat, Pals bonus, final art, balance, CHANGELOG, Opus end review.

## Rules
Tick uses server time only. Petals capped. Race-safe buys (conditional UPDATE + rowCount). CSRF on every POST. No inline style or script. Keep this list current; leave a handoff note in `claude/handoff.md` before a session ends.

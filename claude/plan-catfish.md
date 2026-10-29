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

## Art: see `claude/catfish-art-brief.md` (the art todo, about 80 sprites). Original estimate below.
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
- [x] `tests/catfish.sh` and CI entry (40 checks)
- [x] Opus mid-week review. Fixed: tick dropped part-earned Kibble (clock now moves only by seconds paid), RNG now true mulberry32 (16-bit multiply, matches JS), adopt posts shelter day (today or yesterday), welcome message uses cleaned name, API rate limit 60 per 10 min, JS shows buy messages and refreshes bonus text. Test server leak fixed (trap order).
- Note: cats cap is 2 now (`catfish_slots`), raised to `CATFISH_MAX_CATS` (4) by Yarn shelter upgrades in week 3.
- Note: a gap of 300 s or less counts as page-open (100%, no cap). A background tab earns full rate. Decide in week 2 balance whether to keep.

**Week 2**
- [x] Full 16-node tree (4 branches), percent upgrades shrunk 5x, base 600 Kibble/h, growth 1.18 (sim: `scratchpad/sim.php`, first Nap about 27 min active)
- [x] Nap + Yarn (Yarn = floor(sqrt(run/500)), +10% Kibble each, Dreamy +10% Yarn)
- [x] All 5 personalities (Sneaky rare fish, Dreamy Yarn)
- [x] Cat Book (adopted pattern x colour) + derived badges on profile
- [x] Tests grown for week 2 (about 95 checks incl. replay + mutation-checked)
- [x] Opus end-of-week review. Fixed: page reload replay (paid seconds now rounded up), Yarn runaway (cube root + Yarn^0.6 bonus, sim: 8 h runs go 312k -> 27M over 6 Naps), overflow caps (kph 1e12, cost 1e15, gain cap), Cat Book now records shelter cats seen (badges by count: 12, half, all), Dreamy 10% before rounding, Full house fixed at 2 cats, polling shows 429 and pauses when hidden, Nap block refreshes, Cat Book a11y. Cube root float bug (64 -> 3.99999) fixed.
- Balance note: sim5.php (scratchpad) shows longer runs pay better; revisit in week 4. Short 30 min runs give 1 Yarn each, so the first Nap is a taster.
**Week 3**
- [x] Shelter upgrades (Yarn): Swap a cat (1 Yarn, 3 a day per spot), Bigger home (5 then 20 Yarn, cap 4 cats), Rare Shelter (3 then 10 Yarn, best of 2-3 cats). Spending never lowers the Kibble bonus (it follows Yarn earned).
- [x] Adopt posts the shelter cat's seed, so a stale form or a changed shelter cannot adopt the wrong cat
- [x] Petal milestones (one-time, `give_petals`, weekly cap = setting `catfish_petal_cap`, default 100, 0 = off; milestones that do not fit wait for next week)
- [x] Tests for week 3 (138 checks)
- [x] Opus mid-week review. Fixed: a milestone bigger than the cap could never pay (now capped), claim ran before shelter cats entered the Book, yesterday's-shelter fallback only in the first hour after the UTC reset, claim exits early once all 6 are paid, slots reuse loaded state, Rare label and Swap aria-labels. Not changed: seedless adopt posts still use the slot's current cat (the page always posts a seed).
- Open decision for the owner: Rare Shelter 2 plus 3 swaps a day makes a legendary show on about 42% of days (4.4% with no upgrades). Cats cannot be deleted and only 4 fit, so left as is. Tighten by lowering CATFISH_REROLL_MAX if wanted.

**Week 4**
- [x] Weekly Cat Show (themed, seeded judges + theme/rarity bonus, ribbons on profile, no Kibble/Yarn influence)
- [x] Active cat on the garden page (read only, no row created by visiting)
- [x] Puzzle Pals +2% Kibble each (follows PPAL_PARTY_LEVEL, max 10), festival doubles Nap Yarn
- [x] Art todo (`claude/catfish-art-brief.md`) + `catfish_img()` PNG-or-emoji helper
- [x] Version 2.0.89, CHANGELOG, README line. Feature stays off for players (`catfish_open`)
- [x] Tests (about 190 checks); security190, prog, events, puzzles, games2, garden100, puzzle_pals, jigsaw and upgrade_check from 2.0.88 pass (jigsaw failed once inside a long multi-suite run, passed on 3 reruns)
- [x] Opus end review (verdict: ship once finding 1 fixed). Fixed: Pals table creation inside the tick lock (dropped ppal_ensure and the level query; bonus needs no gnome level), dead 'already judged' check, ribbon art on the game page, duplicate-column race, changelog count. Left: show week uses UTC like the shelter and Petal cap (README says Halifax midnight for game weeks; decide if the show should follow).
- [ ] Real art, layered cat renderer, recolor script (needs Joshua's 3 decisions in the art brief)
- Not done on purpose: release zips (build_update only on milestone releases)

## Rules
Tick uses server time only. Petals capped. Race-safe buys (conditional UPDATE + rowCount). CSRF on every POST. No inline style or script. Keep this list current; leave a handoff note in `claude/handoff.md` before a session ends.

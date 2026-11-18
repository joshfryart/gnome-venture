# Balance 2.7.08: creature and piece data (2026-11-17)

Scope: the 2.7.07 open data items (todo sections 0 / 3 / 4). Data and tune tables only, plus two one-line gates for the tier III calling pieces (below). Scripts used live in the session scratchpad (not in the repo): `win.php` (region windows), `abdup.php` / `abfix.php` (ability pairs), `legend.php` (legend flatten), `fit.php` + `step.php` + `an.php` (refit on all 319 creatures; `tests/pf_bots.php` and `tests/pfboard_tune_v1.php` still list only the 88 `creatures.txt` rows, so `fit.php` adds the 231 variants of `pfd_creature_rows()` and reads a `TUNEFILE`), `dil.php` (deck dilution).

## 1. Region windows (DONE in the second pass, below)

Rule (SPEC 4.1): a row of level Lv has a window in region R when R holds one of its lands and `Lv-2 <= R <= Lv+6` (bosses: `R >= Lv-8`). Count: **23 rows** = 15 variants (L35-40) + 8 base rows.

- The 15 variants (ratel-pair, emu-mob, lava-beetle, gorse-beast, goliath-heron, old-brock, elder-mire-toad, conger-brute, elder-tiger, mangrove-crab-emperor, musk-ox, reef-eel-tyrant, alpha-dingo, kraken-spawn, ibex-patriarch) all list top regions (SEA / WCA / ESA / OC) that hold their land. Those regions walk at the GNOME's level (spawn-review), so a gnome of L36+ meets them there; the "no window" is the region-level rule, not a dead row. No region can host L38-40 by region level (top region OC 35).
- Changed: **alpha-dingo ESA -> ESA,OC** (dingoes are Coralscatter animals; OC has desert; the sibling dingo-pup-pack has another cond). Tried and reverted: kraken-spawn + OC (its `D11` would then share OC coast with garfish, item 3); emu-mob + OC (same cond and window as cassowary-chick-creche in OC forest).
- The 8 base rows (`*`, level and lands from `creatures.txt`) cannot get a window from data: their level / lands live in the `creatures` table and no importer updates an existing row (`import_creatures_txt` / `import_pf_creatures` only insert). Needs a boot step (like `medium_lair_levels_1115`). Proposed moves:

| base row | now | proposed | window then |
|---|---|---|---|
| mischief-monkey | L15 rainforest | L14 | SA 12 |
| leafcutter-column | L17 rainforest | L14 | SA 12 |
| arctic-fox | L17 tundra | L16 | EE 14 (+tundra, explore) |
| desert-tortoise | L24 desert | L22 | EA 20 |
| reef-turtle | L16 island | L12 (SE 10) or L24 (SEA 26) | |
| glacier-bear | L26 tundra | + mountain land | ESA 32 |
| lichen-reindeer | L28 tundra | + mountain land | ESA 32 |
| snow-owl-monarch | boss L30 tundra | + mountain land | ESA 32 |

(A level move also moves its tune row: refit those rows after.)

**DONE (second pass, 2026-11-18)**: the 8 base rows have a window now. `tests/creature_windows.sh` scripts the SPEC 4.1 rule over all 319 rows (base rows read the world's `creatures` table; L35+ rows in SEA / WCA ESA / OC are the gnome-level exception): 0 rows without a window (8 before: the 8 base rows; the 15 L35-40 variants pass by that exception).
- Data: `creatures.txt` (fresh worlds) as the table above; reef-turtle **L12 (SE 10)**, not L24: both pass `Lv-2 <= R <= Lv+6`, but L12 keeps its authored `Kelp Frond:25@reg=CB/SE` drop alive (at L24 its only window is SEA, where that drop never falls), is the smaller move (-4 vs +8), and keeps it apart from the family's top row (leatherback L32 OC). It shares SE island with turtle-hatchling-dash (L10 small), allowed by SPEC 4.1 since their conds differ (the hatchlings are `dp=night`). Petals of the 5 moved rows (`pf_creatures.txt`) re-set to the SPEC 5.2 rule at the new level (mischief 13-25, leafcutter 7-13, arctic-fox 15-27, desert-tortoise 19-35, reef-turtle 12-22).
- Existing worlds: boot step `creature_windows_2708` (`bootstrap.php`, after `medium_lair_levels_1115`) runs `creature_windows_2708()` (`includes/adventure_data.php`, table `CREATURE_WINDOWS_2708`): a creature still at the OLD level / lands gets the new one, hp / attack / defense / dmg_bonus / xp re-derived as `import_creatures_txt()` builds them, and its Almanac page's Level / Found in text and sort order. Idempotent (only old values change; an admin's own edit stays); the test checks an old world comes out byte-equal to a fresh one and a second run changes nothing.
- Tune rows refit (chain bot, the 2.7.08 fit step, 10 x 60 + 3 x 150 seeds, then a sweep at 600): mischief-monkey 1.115 / 1.000, leafcutter-column 2.235 / 1.009, arctic-fox dropped (1.0 / 1.0), desert-tortoise 1.110 / 1.000, reef-turtle 1.100 / 1.000. Fresh 360-seed check (other seeds): mischief 69, arctic-fox 70, reef-turtle 63, leafcutter 83, desert-tortoise 67 (targets large 68 / medium 85). With the old rows at the new levels they were 68 / 79 / 60 / 100 / 81. PHP `data/pf_creature_tune.txt` and JS `PFB_V1_TUNE` changed in those 5 entries only; `tests/pfengine_js.sh` ok (parity). glacier-bear / lichen-reindeer / snow-owl-monarch only gained a land: no level move, no refit.
- Left: the base rows' regional drops whose region is outside the new window (arctic-fox `Lemming Fluff@reg=NA/NWE`, desert-tortoise `Prickly Pear@reg=CA/MENA`, glacier-bear / lichen-reindeer `@reg=NA/NWE/EE`) still never drop by the region-level rule (they never could before either: those rows had no window). A data choice for Josh: move the `@reg` to the new window region or leave them as walk-level drops.

## 2. Refit (DONE)

All 319 creatures, chain bot, build std, gnome at the creature's level. Fit: ln(foe_x) steps toward the size target (logit slope 4, shrink n/(n+6)); the part foe_x cannot take inside [0.42, 3.1] goes to bar_x (slope 3) inside [0.52, 2.15]; a row whose foe_x is free hands bar_x back toward 1. 6 rounds x 12 seeds, 3 x 24, 1 x 36, then a FRESH 36-seed check (other seeds than the fit). Targets: small 83 / medium 85 / large 68 / boss 78.

| | before (head tune, after items 3-5, 36 seeds) | after (fresh 36 seeds) |
|---|---|---|
| median small / medium / large / boss | 89 / 81 / 72 / 69 | 83 / 86 / 69 / 81 (boss = 11 rows) |
| > 12 points from the size median, raw | 95 | 27 |
| > 12 + 1 SE (the report's measure) | 52 | 4 (herring-gull 64, cactus-beast 61, snow-bunting-flurry 61, tide-crab-paladin 39: noise level) |
| tune rows on a clamp (foe_x <= 0.4 or >= 3.2, bar_x <= 0.5 or >= 2.2) | 30 (31 in the report) | 0 |

The 13 listed in the todo (goliath-frog, musk-ox, giant-clam, glacier-bear, frilled-lizard, ratel-pair, army-ant-column, ptarmigan-flock, caracal, frost-hare, ember-beetle, raven-pair, kraken-spawn) are all inside 12 + 1 SE now. Still at a fit limit (deck very weak for the level: a deck edit is the clean fix): house-centipede-skitter and midge-cloud (bar_x 2.15), bullfrog, hermit-crab-convoy, shore-earwig (foe_x 3.1). `data/pf_creature_tune.txt` 300 rows (was 322); JS `PFB_V1_TUNE` rebuilt from the file (one line, `tests/pfengine_js.sh` parity).

## 3. Variant pairs sharing an ability string (DONE)

Definition that gives 76: two variant rows with the same ability string, a shared land, levels within 8 and a shared region. Card texts are fixed per id (`PFB_ABIL[5]`), so a `(k=v)` override would make the card wrong: ids were swapped instead, cost kept where possible.
- 55 rows changed, 76 -> **0** pairs. N ids swapped within their tier (drain1 -> regrow1 / enrage1 ..., drain2 -> plated2 / toughhide2 / wary2), an E variant with a D (no N) dropped to its E base kind (swarm-dense+D12 -> swarm+D12, current-hard+D12 -> current+D12, venom-long+D2 -> venom-trail+D2; expm -0.1), grudge-slow <-> grudge-fury, and 6 D-only rows got a tier I effect that fits the signature (marsh-harrier D1+ambush1, fire-ant-raiders D3+stagger1, tundra-fox / ice-floe-seal / musk-ox / aardvark D5+enrage1, army-ant-column D8+wary1, luna-moth D8+ambush1; expm +0.1). night-heron keeps ambush1 (tern-squadron moved instead).
- Family rule kept (every family's strings pairwise distinct), at most 2 ids a row. Loader tests use the fixture: `pfboard_v1_abil` passes.

## 4. Calling tier III second pieces (DONE)

`data/pf_pieces.txt`, ref `CALLING:3` (owned from calling tier III). Value = type base - tag cost + 2; the calling tier bonus (+4 at tier III) comes on top, as for the first piece.

| calling | piece | type / tag | v |
|---|---|---|---|
| rootwarden | Deep Roots | guard hold | 5 |
| bloomcaller | Bloom Bond | charm bond | 5 |
| thornblade | Barbed Cut | hurt poison | 4 |
| seedkeeper | Seed Swap | trick pluck | 4 |
| wayfinder | Side Path | guard evade | 4 |
| brewroot | Slow Brew | heal simmer | 3 |

Code (two one-line gates, no fight-engine logic): `pfd_build()` owned check for `calling` reads `ref` as `calling[:tier]` against `$src['ctier']` (`game/includes/pfdeck.php`); `pf_tiles()` skips a ref with `:` so the old tile library and the JS parity stay as they were (`game/includes/pfight.php`). Like every new piece it arrives switched off (New).

## 5. Legendary piece spread (DONE)

v = type base + 2 (legend premium) - tag cost - built-in knack cost (1 each; keep / plenty / bond / hum / lull / pluck 1, poison / trip / bash / evade / thorns / simmer 2). `tests/pfdeck_v1.php` forbids two legend pieces with the same type, tag, knack and value, so a tied pair keeps its old order: the lower at the formula value, the next +1. 22 of 42 changed (e.g. Macadamia 7 -> 6, Brazil Nut Bash 6 -> 4, Wasabi 6 -> 3 (poison + finisher), Kava 6 -> 5, Ackee / Yuzu 4 -> 6, Cloudberry 5 -> 7). Every piece is now at the formula or +1 (before: -2 .. +3 off it). Spread by type before -> after: hurt 4-7 -> 3-6 (all of it tags), guard 3-6 -> 4-6, heal 3-6 -> 3-5, item 4-5 -> 6-7, soothe 5-6 -> 4-5, charm 5-6 unchanged, trick 3 -> 4.

## 6. Deck dilution at 24-28 pieces (DONE: measured, no change)

Creatures L16-30 (145, no bosses), gnome at their level, the tuner's model gnome. The model deck there is 18-19 pieces; "pad" switches every owned knack on (28-31 pieces).

| deck | pieces | chain win % | turns | look win % |
|---|---|---|---|---|
| model | 18-19 | 79.7 | 6.39 | 99.8 |
| pad (all knacks on) | 28-31 | 73.3 | 6.60 | 100.0 |
| pad trimmed to the 20 highest values | 20 | 74.0 | 6.36 | |
| pad trimmed to the 16 highest values | 16 | 77.1 | 6.11 | |

A big deck costs a weak player about 6 points and a good one nothing; a size cap does not help (a value-trimmed 20 is no better than 30: what matters is the mix, which the gnome already chooses: new pieces arrive off). Recommendation: no tunable change; if wanted, a deck-screen hint past ~24 pieces (UI, not data).

## Tests

See the final run in the hand-off. Pre-existing failures not caused by this data: `pf_creatures_import` "puzzle Charm ($full) gives the full Petals" (the +25% charm reward, 4-7 range in the test), `pf_piece_text` (6 text checks: Quick / Heavy / Boon / Soothe texts changed by other work).

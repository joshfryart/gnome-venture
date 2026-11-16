# Creature pass balance report, 2.7.01 (policy D)

Harness: `tests/pfboard_tune_v1.php` logic (chain bot, model gnome, 4x4, blank centre, layered decks, region by seed), extended to the 230 variants (`pfd_creature_rows(true)`) by a scratch copy; offsets = gnome level minus creature level; 4 shards. Final run: 318 creatures, chain 3x seeds (36 base / 24 variant fights per creature and offset), look 1x. Noise: a creature's win % is +-8-10 points; size totals +-2.

## Final constants

`game/includes/pfboard.php` and the JS twin `tools/pfengine.js` (same values; `bash tests/pfengine_js.sh`: 1012 fights match).

| constant | small | medium | large | boss |
|---|---|---|---|---|
| `PFB_V1_FOE_MULT` | 0.93 | 0.70 | 0.415 | 0.585 |
| `PFB_V1_BAR_MULT` | 1.378 | 1.7743 | 1.7193 | 0.9158 |
| `PFB_V1_LEVEL` (slope, ref, lo, hi) | 0.05, 6, 1.0, 1.8 | 0.05, 12, 0.85, 1.25 | 0.025, 22, 0.85, 1.10 | flat |

`PFB_V1_BAR_EASE_MEDIUM = [0.30, 12, 24]`: medium Yield bar x 0.30 up to creature level 12, linear to x 1.0 at level 24 (SPEC 7.2 start was 0.80, 12, 19).
`data/pf_creature_tune.txt`: 278 rows (`slug|foe_x|bar_x`), all 88 audit rows folded in. JS twin: `PFB_V1_TUNE` + `v1Over()` in `pfengine.js` (rebuild the table line from the file when it changes).
Deviations from SPEC 7.1 (option A numbers): medium FOE 0.70 (A: 0.5568), large 0.415 (0.4309), boss 0.585 (0.6026), small 0.93 (0.8807). Reason: the variants (230, small and medium from level 1 to 40) shifted the size medians, and the medium ease makes low-level mediums easier at every offset, so the foe constant carries the difference. Small gets a level curve (x1.0 to level 6, +5% a level, cap 1.8) because small now runs to level 40.

## Win % (chain), all 318, median creature per size

| size | | +4 | 0 | -4 | -8 |
|---|---|---|---|---|---|
| small | audit 2.7.00 (88) | 100 | 85 | 79 | 79 |
| small | start of this run (318) | 97 | 85 | 55 | 33 |
| small | final (318) | 100 | 83 | 46 | 17 |
| medium | audit | 100 | 95 | 59 | 31 |
| medium | start | 96 | 88 | 58 | 26 |
| medium | final | 96 | 83 | 50 | 17 |
| large | audit | 98 | 93 | 75 | 37 |
| large | start | 94 | 82 | 60 | 31 |
| large | final | 96 | 81 | 58 | 29 |
| boss | audit | 93 | 89 | 72 | 37 |
| boss | start | 92 | 80 | 61 | 28 |
| boss | final | 92 | 79 | 61 | 32 |

Size means at level (final): small 81, medium 85, large 81, boss 82. Base rows only / variants only at level: small 76 / 82, medium 89 / 83, large 81 / 80, boss 83 / 78. Fight length (turns) 5.1 / 5.4 / 7.6 / 7.7; HP lost 66 / 64 / 74 / 77 %.

Medium by creature level (final, mean win %):

| level | +4 | 0 | -4 | -8 |
|---|---|---|---|---|
| 1-7 (n 9) | 100 | 89 | 50 | 48 |
| 8-12 (n 22) | 99 | 91 | 41 | 14 |
| 13-18 (n 29) | 96 | 87 | 45 | 4 |
| 19+ (n 87) | 92 | 81 | 53 | 27 |

Look bot (ceiling): see "Look bot" below.

## Acceptance (SPEC 7.4 / task)

| target | result |
|---|---|
| chain at level 78-84 per size | small 81, large 81, boss 82 pass; medium 85 (median 83) borderline: low-level mediums (lv 1-18) sit at 87-91 so -4 stays above 45 |
| medium -4 above 45 | 49 overall; 41 for lv 8-12 and 45 for lv 13-18 (below target): no further lowering of the bar keeps both at-level and -4 (a lv 8-14 medium: win at level 85 = -4 38, 95 = -4 55, measured) |
| medium -8 >= 35 (lv 5-18) | not met (48 / 14 / 4). Cause is the gnome progression (+6-9 % per level at L5-14), not a constant: a per-size or per-creature multiplier cannot flatten an 8-level gap. Not a task criterion |
| no creature more than 12 points from its size median at level | 37 of 318 raw (> 12), 1 beyond 12 + 1 SE (lemming-kit-scurry, retuned after the run to 0.81). The audit's 135 at-level outliers (start of this run: 135) are gone |
| every creature 60-95 at level | 19 of 318 outside (noise at n 24-36; 100 % rows are small lv 9-16 and medium lv 7-13 with weak decks) |
| every creature 35-90 at -4 | 44 outside, nearly all medium lv 7-14 below 35 (gnome L3-10) and small lv 1-3; not fixable by constants |
| fights 5-8 turns | 5.1 / 5.4 / 7.6 / 7.7 pass |
| HP lost 50-70 % | small 66, medium 64 pass; large 74, boss 77 over by 4-7 points (one-bar fights end close) |

## Method (how the tune was fitted)

1. Start state: option A constants, ease [0.50, 12, 24], 295 tune rows. Chain: 85 / 88 / 82 / 80 at level, 135 creatures more than 12 from the size median.
2. Raised small and medium FOE (0.8807 to 0.93, 0.65 to 0.70). Ease floor tested at 0.50 / 0.35 / 0.25 (medium -4 for lv 8-12: 21 / 52 / 81 at the old tune): floor 0.30 chosen.
3. Fit loop (`fit2`): per creature, ln(foe_x) steps toward 81 % at level (weight 0.7) and the size mean at -4 clamped 50-62 % (weight 0.3), logit slope 4, shrunk by n/(n+6), damp 1.0-1.2; medium lv 1-14 aims at 90 % at level so their -4 stays near 45; clamp 0.5-3.0; 12 rounds in total (about 24 fights per creature a round).
4. Hand pass for 14 creatures that stayed 100 % or 50 % (bimodal: a small change of foe_x flips them): bar_x 1.2-1.5 for hermit-crab-hoarder, pika-sentry, shore-crab, thistle-beast, land-crab-march; foe_x moves for lichen-golem, dune-snail, stickleback-shoal, ant-scouts, lemming-kit-scurry, tree-frog-chorus, jaguarundi, jungle-crow, clam-lurker.

## Remaining outliers (final run)

At level, beyond 12 points and 1 SE of the size median: lemming-kit-scurry (50, retuned). Raw only (within noise): 36 more, spread over all sizes.
At -4 below 35 (structural, gnome L3-10 against medium lv 7-14 and the two lowest smalls): hermit-crab-hoarder 16, pika-sentry 19, shore-crab 9, thistle-beast 6, lichen-golem 12, tree-frog-chorus 3, dune-snail 23, land-crab-march 48 ok, plus about 30 more medium lv 8-14 rows.
Family shapes outside the 2-3 variant plan (roster, not balance): tufted-lynx, griffon-vulture, dune-scorpion have 4 variants; dune-wyrm and storm-eagle 1; jade-jaguar none (bosses: only 2 boss variants exist).

## Look bot

Chain = floor, look = ceiling. Final look run (12 / 8 fights per creature and offset), win %: small 100 / 100 / 98 / 81 at +4 / 0 / -4 / -8; medium 100 / 100 / 94 / 80; large 100 / 100 / 100 / 98; boss 100 across. No size below 95 % at level (100 %); medium -4 94 (bases 83), small and medium -8 81 / 80. Ceiling holds.

## Needs a human

Human playtest of: medium lv 5-14 against gnome L1-10 (hardest band, ease 0.30 makes the bar very short there: 5-6 turn fights), the boss variants (2 only), HP lost 74-77 % for large and boss, and the real decks (model decks omit the 42 legendary pieces and wearables).

## Files

`game/includes/data/pf_creatures.txt` (318 rows, merged A-D, sizes written in full, 17 columns, no duplicate slug or name), `game/includes/data/pf_creature_tune.txt`, `game/includes/pfboard.php`, `tools/pfengine.js`. Not edited: `tests/pfboard_tune_v1.php` (it still lists only the 88 creatures.txt rows; the variant run used a scratch copy that adds `pfd_creature_rows(true)` variants and a `TUNEFILE` override. Port it before the next tune).

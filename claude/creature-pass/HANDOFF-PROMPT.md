# Orchestrator prompt: roll the creature pass into 2.7.01

You are the orchestrator. Repo: joshfryart/gnome-venture. The creature pass lives on branch `ccr-0df52ad6-jm533i` (based on main = 2.7.00). Do not rebuild it. Find it, finish it, verify it, roll it into 2.7.01.

## 1. Find the work
- `git fetch origin ccr-0df52ad6-jm533i`; read `git log main..origin/ccr-0df52ad6-jm533i` and `git diff --stat main...origin/ccr-0df52ad6-jm533i`.
- Docs, all in `claude/creature-pass/`:
  - `hp-audit.md`: HP/win-rate audit (formulas, curves, outliers, target options A/B/C).
  - `spawn-review.md`: where creatures spawn (picker, routes, gaps G1-G12, bugs B1-B15, variant table 4.3).
  - `SPEC.md`: binding spec (17-column data format, 41 ability ids incl. 8 new engine effects, 10 AI styles, drops policy, HP policy D).
  - `drops-notes.md`, `verify-content.md`, `data/pf_creatures_{A,B,C,D}.txt` (writer batches, already merged).
- Code: `game/includes/data/pf_creatures.txt` (318 rows: 88 base + 230 variants), `data/pf_creature_tune.txt` (per-creature foe/bar multipliers), `pfboard.php` (abilities `PFB_ABIL`, AI scorer, balance constants), `pfight.php`, `pfdeck.php` (loader/overlay), `adventure.php` (`pick_creature` region filter, `win_fight` drop gates, petals/exp), `adventure_data.php` (`import_pf_creatures`, `pfc_parse_drops`), `schema.php` (`creature_drops.reg/lvmin/lvmax`), `bootstrap.php` (boot step `creatures_2701`), `tools/pfengine.js` (JS twin), tests: `pfboard_v1_abil.php`, `pfboard_v1_ai.php`, `pf_creatures_import.php/.sh`, `pf_creatures_fixture.txt`.

## 2. Owner decisions (final, do not re-ask)
All 88 creatures, 2-3 variants each as separate named creatures; each variant has unique deck, unique ability, AI style, region list, drops (items %, petals range, exp, region/level gates). New engine effects allowed. HP target = option D (equal ~80% chain-bot win at level + per-creature fixes + lower bar for low-level mediums so medium -4 is not a cliff). Region filter: yes. Bugs B1-B3 (fresh-install route ids off by one from 239, lair stretch counts, lair boss spot gives a normal creature): list only, do not fix. Tundra and island gap variants: fill. Owner reviews before merge; no PR unless asked.

## 3. Known open defects (fix these first)
1. 86 drop gates `@lv>=N` have N above the creature's own level, so they never open (`creature_drop_open` tests fight level). Fix data (N = own level, or use `@lv<=`/`@reg`) or define the gate relative to the row level.
2. Variant counts: jade-jaguar 0; dune-wyrm 1; storm-eagle 1; dune-scorpion, tufted-lynx, griffon-vulture have 4 (cut to 3). Only 2 boss variants exist; bosses need 2-3 each.
3. Number-tweak decks (only 1 of 3 pieces differs): arctic-fox-kit/tundra-fox, rock-crab-pincher/mangrove-crab-emperor, tundra-vole-swarm/ibex-patriarch, ocelot/snow-lynx, cockle-bed/giant-clam, gyrfalcon/condor, ice-floe-seal/elephant-seal-bull, reindeer-calf-herd/caribou-bull.
4. Never spawn: bark-scorpion L19, coati-band L19 (set L20 or region CB/SA). Region/level mismatch: palm-thief-crab, rock-crab-pincher, glass-frog, camel-calf. Overlapping siblings: pangolin/aardvark, wildcat/ocelot, jaguarundi/elder-tiger, fishing-cat/jaguarundi (make regions disjoint or conds differ).
5. "Black Truffle" declared twice; 23 `@reg` gates cover all of a row's regions (no-op): see `verify-content.md` F9.
6. Balance not met: chain bot at level small 83, medium 83 (mean 85), large 81, boss 79; but small -4/-8 fell to 46/17 (was 79/79), medium -4/-8 = 50/17. Target: 78-84 at level per size, medium -4 above 45, small -4 not worse than 65, no creature more than 12 pts from its size median. Re-tune via `pf_creature_tune.txt`, `PFB_V1_*` constants (keep JS twin in step).
7. `tests/pfdeck_v1.php` has 3 stale assertions (expects 88 creatures; now 318 rows, class sizes and 954 unique pieces). Update. Register `pf_creatures_import` in `.github/workflows/ci.yml`. `trek_fight.php` (~line 1210) reads `creature_drops` ungated (no effect today).
8. Bump `APP_VERSION` to 2.7.01, write the CHANGELOG entry (new: variants, abilities, AI, drops, region filter, balance D), update `game/README.md` if it lists data files. Known flake: `pfdeck_v1` "tool pieces were played in the fight". `pfboard_v1.sh` can print FAIL lines yet end "all ok": grep `^FAIL`.
9. Not done anywhere: no human playtest (all numbers are bots), variant art (art notes only), player-text and tone review, creature-card UI check on a phone, Almanac page review for 230 new creatures, the 42 legendary crop pieces and wearables are not in the model gnome.

## 4. How to run it
- Use a workflow or agents; give each agent exclusive file ownership; agents must not run git; you commit.
- Order: (a) content fix agents (defects 1-5) by batch A-D files then re-merge; (b) balance agent (defect 6) using `php tests/pfboard_tune_v1.php chain 4,0,-4,-8 2 i/4 json` in 4 shards, look bot sample, files in `claude/creature-pass/balance-report.md`; (c) tests/CI/version/changelog (7-8); (d) two independent verifiers (engine, content), instructed to refute, not confirm.
- Gate: `bash tests/pfengine_js.sh`, `php tests/pfboard_v1_abil.php`, `php tests/pfboard_v1_ai.php`, `bash tests/pfboard_v1.sh` (grep FAIL), `bash tests/ci_suites.sh pf_creatures_import pfdeck_v1`, `php -l` on changed files, a full fight per row.
- Report: counts, before/after balance tables, remaining outliers, and open questions for the owner. Stop for owner review before releasing a zip (`releases/`).

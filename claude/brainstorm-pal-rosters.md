# Design: unique Puzzle Pal rosters with game-linked combat Boons (v2, no lighting)

Status: DECIDED BY JOSHUA 2026-10-31, ready to build in steps. No code changed yet. Source: todo.md "ADDED 2026-10-31" item 3.
v1 of this doc had a "lit by a game hook" scheme. **Joshua dropped it as too obtuse.** This version has no conditions:
every Boon always works the same. Opus brainstorm, trimmed and rewritten.

Request: "Every roster of puzzle pals should be unique. Have the Mapleworld roster be the base. The pals should
interact with some part of the game and give a varying bonus to combat; passive or a skill they can use."

"Mapleworld" = the gallery picture **The Maplewold** (slug `maplewold`, keys `mw-*`). Pal names, art, stats, callings
and blurbs of all 570 pals stay as they are.

## Joshua's decisions
1. **Boons replace the calling skills** for any pal that has a Boon row (the rare's "second calling skill" too).
   Calling still sets stats, the default perk and Pal Jobs.
2. **Rares have the only active skills; commons and uncommons are passive.** Every rare gets one active (once per fight).
3. **No lighting scheme, no "hook" conditions.** So also no `ppal_hook_log` table and no trackers. The Expert trophy keeps
   its existing +4 perk and gets nothing new.
4. **Boon names and lines are approved in batches**, like pal names.
5. Maplewold is the template every roster varies from; it ships first.

---

## 1. How it works today (short)

- **Roster** = all rows in `game/includes/data/puzzle_pals.txt` sharing a `pic_slug`: always 6 pals, 3 common / 2 uncommon /
  1 rare. 95 rosters, 570 pals: 14 gallery + 81 Places (18 haven, 35 wonder, 14 delve, 14 lair; slugs `pl-*`).
- Only `calling` and `rarity` decide a pal's combat skill (`PPAL_SKILLS`, passive, road / lair / delve fights only, never
  Treks or contests). The `perk` column is `-` on all 570 rows. So **570 pals share just 18 combat profiles**, and 71 of the
  95 rares are wayfinders (Fleet Foot). That is the problem.

| Calling | Skill | C / U / R | Code hook |
|---|---|---|---|
| rootwarden | Thorn Ward: damage taken -N | 1/2/3 | `combat_turn` creature turn |
| thornblade | Keen Edge: damage +N | 1/1/2 | `gnome_combat` `dmg_bonus` |
| wayfinder | Fleet Foot: armour and running +N | 1/2/3 | `gnome_combat` `ac`, `flee_roll` |
| seedkeeper | Mend: heal N each round | 1/2/3 | `combat_turn` start |
| brewroot | Sip: snacks heal +N% | 10/20/40 | `combat_turn` snack |
| bloomcaller | Lucky Petal: crit +N% | 1/2/4 | `gnome_combat` `luck_crit` |

Party sums are capped (`PPAL_SKILL_CAP`: ward 4, edge 3, foot 4, mend 4, sip 60, petal 6); party max 2.
- Standing rules: passive skills add no dice (`combat_math_golden` runs with no pals, pal branches must draw no
  `random_int` when none come along); Treks have no pals; an equipped pal cannot be on a job.
- Uniqueness tools: `tools/lint_puzzle_pals.py` (14 columns, unique key and name, 3/2/1 mix, no shared shape+knob,
  rare is `whimsy-*`) and `tools/pal_unique_check.py` (art only). Nothing checks bonuses.
- The Maplewold is the only roster that holds all 6 callings exactly once: a clean template.

---

## 2. The idea: a Boon per pal

A **Boon** = one combat **effect** + a short name and one line of text. The **game system** a pal "touches" is what
the effect acts on (snacks, Pantry jars, drinks, drops, XP, the road, your callings). No conditions: it always applies.
Rarity sets the size from one table, so balance lives in one place. A rare also carries an **active** (section 4).

Variety comes from: which of 16 effects each pal has (different per slot, different across rosters), rarity size, and
the rare's active.

### 2.1 The Maplewold base roster

| Pal | Rarity | Boon | Effect (system it touches) | Value |
|---|---|---|---|---|
| Acorn Nip | C | *Acorn Cache* | `mend`: heal N at the start of each round (Health) | 1 |
| Leaf Tuck | C | *Leaf Pile* | `guard`: the first N creature hits each fight are halved (new) | 1 hit |
| Sap Drip | C | *Sticky Sweet* | `sip`: snacks heal +N% (Pantry jars and snacks) | 10% |
| Bark Badger | U | *Borrowed Coat* | `ward`: damage taken -N | 2 |
| Fourwind Finch | U | *Four Ways* | `foot`: armour and running +N (Roads) | 2 |
| Samara Spin | R | *Whirligig* + active *Helicopter Key* | `edge`: damage +N; active Strike | 2; Strike 6 |

6 different effects. Slot pattern every roster inherits: **3 commons** = a heal-type, a defence-type, a utility/economy-type;
**2 uncommons** = a defence and a mobility/offence; **1 rare** = the roster's signature (offence or twist) plus its active.

---

## 3. Making every other roster unique

### 3.1 Effects (16, no new dice in any passive)

| Effect | What it does | System | C / U / R | Party cap |
|---|---|---|---|---|
| `ward` | damage taken -N | Fighting | 1/2/3 | 4 |
| `edge` | damage +N | Fighting | 1/1/2 | 3 |
| `foot` | armour and running +N | Roads | 1/2/3 | 4 |
| `mend` | heal N each round | Health | 1/2/3 | 4 |
| `sip` | snacks heal +N% | Pantry | 10/20/40 | 60 |
| `petal` | crit chance +N% (existing roll) | Luck | 1/2/4 | 6 |
| `guard` NEW | first N creature hits each fight halved | Fighting | 1/1/2 hits | 3 |
| `rally` NEW | once a fight at 30% HP or less, heal N | Health | 4/7/12 | one trigger |
| `first` NEW | to-hit +N on round 1 only | Fighting | 2/3/5 | 6 |
| `kindle` NEW | your calling ability is stronger by a step (Bark +1 round, Spore +2, Brew +1 tick, Aimed +2, Flurry +1, charm +2) | Callings | 1/1/1 | 2 |
| `spoils` NEW | creature drop chance +N% after a win (same roll, not befriend) | Gathering / loot | 5/10/20 | 30 |
| `lesson` NEW | Fighting XP +N% after a win (floor, no roll) | Skills | 5/10/20 | 30 |
| `feast` NEW | a snack heals N extra HP flat | Pantry | 1/2/4 | 8 |
| `tonic` NEW | the gnome's drink buff (Alchemy) is +N stronger while fighting | Alchemy | 0/1/1 (step) | 2 |
| `bulwark` NEW | +N max HP for the fight | Health | 2/4/8 | 12 |
| `slip` NEW | running away +N (flee roll only, not armour) | Roads | 1/2/3 | 4 |

(`tonic` as a 0 common means commons never carry it; it is an uncommon / rare effect.) Values are a first guess for the
sim (5.1). Point budget so effects trade fairly: 1 ward = 1 mend = 1 foot = 1 edge = 20% sip = 2% petal = 1 guard hit =
4 rally HP = 2 bulwark HP = 1 feast.

### 3.2 Rules (checked by lint)

1. **In a roster**: 6 different effects (a repeat of one effect is a warning only if the theme demands it).
2. **Across rosters**: no two rosters share 4 or more of their 6 effects ("TOO ALIKE a ~ b, shared 4/6"). With 16 effects
   there are 8,008 possible 6-sets, plenty for 95.
3. **Rares**: each rare's `(passive effect, active)` pair is unique across all 95 rosters (16 effects x 8 actives = 128).
4. **Theme first**: pick the effect that fits the pal's blurb and picture (jar/brew = `sip` or `feast`, tide/slippery =
   `slip`, tough = `bulwark`). Calling is only a tie-breaker, so the 71 rare wayfinders are not all Fleet Foot.
5. **No per-row numbers**: rows name the effect; values come from the table.
6. **Fallback**: a pal with no Boon row plays exactly as today. Ships one roster at a time. Uploaded (generated) rosters
   get a crc32-seeded Boon like their names.

### 3.3 Derivation per roster (same flow as the approved Places pipeline)
1. Copy the Maplewold slot pattern.
2. Draft tool `tools/pal_boons_draft.py SLUG` proposes 6 effects, rotating through the table seeded by crc32(slug),
   nudged by blurb words, and avoiding any rare pair already used.
3. Opus reviews against the blurb and picture, writes Boon names and lines.
4. Lint proves rules 1 to 3. Joshua approves names and lines per batch.

Worked example, Sunsprinkle Isles (draft): Shell Skip (C) `spoils` "Tideline Pockets"; Palm Fidget (C) `slip`;
Tide Tuck (C) `guard`; Coral Cuff (U) `ward`; Lagoon Loop (U) `petal`; Cocopaddle (R) `first` + active "Paddle Rush".
Shares 0 of 6 effects with the Maplewold.

### 3.4 Data and lint
New file `game/includes/data/puzzle_pal_boons.txt` (the 570-row file, its lint format and the art tools stay untouched):
```
# key|boon name|effect|active|line      (active only on a rare: strike|shield|patch|snare|sap|daze|... or -)
mw-acorn-nip|Acorn Cache|mend|-|Patches you up with an acorn it found again.
mw-samara-spin|Whirligig|edge|strike|A maple key that learned to fly, and to hit.
```
Lint: `tools/lint_puzzle_pals.py --boons FILE`: key exists, one row per key, valid effect and active, `active` only on
a rare, rules 1 to 3, Boon names unique and at most 24 chars, lines at most 120, curly apostrophes, no `|`.
`--require-boons` turns "pal has no Boon" into an error after the last batch. Prints a fingerprint per roster
(`maplewold: mend guard sip ward foot edge+strike`) for review sheets. PHP test `tests/puzzle_pal_boons.php`: loader
agrees with the lint, every effect and active exists in code.

### 3.5 Engine sketch
`ppal_boons($u)` sums equipped pals' Boon effects, applies caps, and snapshots them into the fight JSON
(`expeditions.encounter`, key `pb`) at the first `combat_turn`, so swapping pals mid-fight changes nothing and
`fight_odds` reads the same numbers. `gnome_combat($u, true)` keeps its signature; with no pals it returns today's array
(golden-safe). Setting `ppal_boons` (0/1); off = today's `PPAL_SKILLS`.

---

## 4. Rare actives (all 95 rares, once per fight)

- **Use**: once per fight, uses your turn (the creature still acts), like the calling ability. Never automatic:
  `fight_on`, `auto_resolve` and Fight certainty only send `attack`. Fixed numbers, no dice. A rare keeps its passive Boon.
- **Action pool** (8, rares pick one; unique with the passive):

| Active | Effect | Value |
|---|---|---|
| Strike | can't-miss hit for fixed damage | 6 |
| Shield | next 2 creature hits -N | 3 |
| Patch | heal N now | 10 |
| Snare | your next flee always works, +2 armour | - |
| Sap | poison on the creature, 2 more ticks than Bitter Brew | 2 ticks |
| Daze | creature skips its next turn (lairs: -50% next hit instead) | once |
| Rouse | your calling ability is refreshed if already used | once |
| Gust | creature -2 to hit for 3 rounds | 3 rounds |

- **State**: one more flag in the encounter JSON (`pa`), no schema change. Golden replays explicit actions only; a new
  action nobody sends cannot move it.
- **Code**: `game/adventure.php` POST whitelist (`['attack','ability','flee']`, ~line 59) gets `palskill`;
  `combat_turn` new `case 'palskill'` (refuse if `pa` set or no rare along); buttons in all fight renders
  (`adventure.php` ~287, `layout.php` ~468 and ~485, delve v2 card if separate); replay logs the line.
- **Risks**: add a NEW golden section with fixed seeds per active and a "pals along, passive" table, recorded after
  review, in the release that adds the engine; phone clutter (put the pal button on the ability row, two half-width
  buttons); Daze not on lair bosses; `fight_odds` ignores actives (same as the calling ability today). No daily charges
  (they would need storage).

---

## 5. Balance guardrails and build plan

### 5.1 Guardrails
- A Boon is worth about what the pal's calling skill is worth today for that rarity (point budget in 3.1), so nobody's
  power changes a lot on switch-on; the new effects and actives add variety, not a big jump.
- Caps stay (`PPAL_SKILL_CAP` plus the new caps in 3.1); two pals with the same effect still hit the cap.
- Sim gate before flipping (new `claude/pal-boons-sim.php`, real `combat_turn`, levels 5 to 40, small and large foes):
  even-level win rate with a Boon party at most +10 points over today's skills; average HP lost not under half of today's;
  no fight band newly "certain" for auto-resolve because of Boons; actives checked on their own.
- Pal Jobs rolls (`pj_roll_trip`, `pj_roll_delve`) do NOT use Boons in v1. Treks and contests never.

### 5.2 Build plan (small releases, each behind `ppal_boons`, OFF)
1. **B1 engine + Maplewold.** Boons file with 6 rows, loader, 16 effects, snapshot, `ppal_boons` setting, My Gnome and
   Pal Book lines, lint `--boons`. Tests: each Maplewold Boon through whole `combat_turn` rounds (extend
   `puzzle_pals_party.php`); golden unchanged on a fresh install; record "pals along" golden section.
2. **B2 sim + numbers.** `claude/pal-boons-sim.php`, tune the table, Joshua plays with it on.
3. **B3 rare actives** (setting `ppal_boon_active`): action, buttons, new golden section. Maplewold's Samara Spin first.
4. **B4 gallery rosters (13).** Draft tool, Opus review, Joshua approves names and lines, lint.
5. **B5 Places rosters (81)** in four batches: haven, wonder, delve, lair. After the last: `--require-boons`; generated
   rosters get seeded Boons.
6. **B6 flip + player news** (with `ppal_open` / `ppal_party` whenever Joshua opens Pals).

Each release: `php -l`, `puzzle_pals.sh`, `paljobs.sh`, golden on a fresh `walk.sh` install, slim zip as usual.

---

## 6. Still open (small, my recommendation applies unless Joshua says otherwise)
- Final Maplewold effect list and Boon names (table 2.1) for Joshua's OK before B1.
- Effect values in 3.1 are first guesses; the sim in B2 sets them.
- Pal Adventuring level does NOT scale Boons (Pal Jobs keeps that). Perk column stays `-` (not in this project).
- Treks stay pal-free.

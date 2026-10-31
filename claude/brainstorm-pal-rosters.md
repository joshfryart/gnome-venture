# Brainstorm: unique Puzzle Pal rosters with game-linked combat bonuses

Status: BRAINSTORM for Joshua to approve. No code changed. Source: todo.md "ADDED 2026-10-31" item 3.
Request: "Every roster of puzzle pals should be unique. Have the Mapleworld roster be the base. The pals should
interact with some part of the game and give a varying bonus to combat; this could be passive or a skill they can use."

"Mapleworld" here means the gallery picture **The Maplewold** (slug `maplewold`, keys `mw-*`). Names, art, stats,
callings and blurbs of all 570 pals stay as they are. Everything below adds a new layer on top.

---

## 1. How it works today

**What a "roster" is in the data.** `game/includes/data/puzzle_pals.txt` has one row per pal, 14 columns:
`pic_slug|key|name|rarity|calling|grit|nimble|hardiness|luck|piece|shape|knob|perk|blurb`. A roster is every row that
shares a `pic_slug`: always 6 pals, 3 common / 2 uncommon / 1 rare. 95 rosters, 570 pals:
14 gallery (Regions) pictures + 81 Places pictures (18 haven, 35 wonder, 14 delve, 14 lair; slugs `pl-*`).
Uploads with no authored rows get a generated roster (`ppal_place_roster`, crc32 seeded).

**Where a pal's bonuses come from.** Only two columns matter for play, and neither makes rosters unique:
- `perk` (non-combat): `-` on all 570 rows, so every pal uses its calling's default (`PPAL_CALLING_PERK`:
  gather / road / finder / tinker / bloom). Units 8/15/30% (road 1/2/4 points), Expert trophy +4, caps 50% (road 5).
- `calling` -> combat skill (`PPAL_SKILLS`, passive, road / lair / delve fights only, never Treks or contests):

| Calling | Skill | C / U / R | Hook in code |
|---|---|---|---|
| rootwarden | Thorn Ward: damage taken -N | 1/2/3 | `combat_turn` creature turn |
| thornblade | Keen Edge: damage +N | 1/1/2 | `gnome_combat` `dmg_bonus` |
| wayfinder | Fleet Foot: armour and running +N | 1/2/3 | `gnome_combat` `ac`, `flee_roll` |
| seedkeeper | Mend: heal N each round | 1/2/3 | `combat_turn` start |
| brewroot | Sip: snacks heal +N% | 10/20/40 | `combat_turn` snack |
| bloomcaller | Lucky Petal: crit +N% | 1/2/4 | `gnome_combat` `luck_crit` |

A rare also carries a second calling's skill at common strength (`PPAL_SKILL_SECOND`). Party sums are capped
(`PPAL_SKILL_CAP`: ward 4, edge 3, foot 4, mend 4, sip 60, petal 6). Party max 2 (setting 1 to 3).

So a pal's whole combat identity is `(calling, rarity)`: **18 profiles shared by 570 pals**. Two rosters with the
same calling mix play identically. Callings are skewed too (86 common seedkeepers, 71 rare wayfinders, 9 common
thornblades), so most rares are Fleet Foot. That is the problem this doc solves.

**Rules that must keep holding.** No extra dice in passive skills (`combat_math_golden` stays green; it runs with no
pals along, so pal branches must be inert and draw no `random_int` when no pal comes along). Treks have no pals. Pals
are puzzle pieces: they come from solving pictures, wait on the map, go on Pal Jobs (Adventuring / Gardening XP,
HP), or come along (party). An equipped pal cannot be on a job.

**Uniqueness tools today.** `tools/lint_puzzle_pals.py`: 14 columns, unique key, unique name across ALL pictures,
3/2/1 mix, no shared shape+knob in a roster, rare must be `whimsy-*`, stats band per rarity, valid perk/calling.
`tools/pal_unique_check.py`: art only (silhouette IoU > 0.86 AND palette overlap > 0.80 = TOO ALIKE).
Nothing checks bonuses, because bonuses are not per pal yet.

**Why the Maplewold works as the base.** Its 6 pals hold all 6 callings exactly once (Acorn Nip seedkeeper, Leaf Tuck
bloomcaller, Sap Drip brewroot, Bark Badger rootwarden, Fourwind Finch wayfinder, Samara Spin thornblade). Only a
few rosters do that. It is a clean template: 6 slots, 6 different effects.

---

## 2. The idea: a Boon per pal

Each pal gets one **Boon** (working name; "knack" is taken by Treks, "skill" by the 6 above):
- an **effect** in a fight (from the archetype table, 3.2),
- a **hook**: one part of the game that "lights" it (3.3),
- a **mode**: passive (all pals) or active (rares only, optional, section 4),
- a short name and one line of text (new text, needs Joshua's OK like names do).

**How it varies.** The effect always works at its base value (the floor = today's skill strength for that rarity, so
no player loses anything). When the hook is met the Boon is **lit** and adds its lit bonus. Lit state is read once
at the start of each fight and shown on My Gnome / Pal Book as "🍁 lit today". Rarity sets both numbers.
So the bonus varies three ways: per pal (effect), per day/place (hook), per rarity (size).

### 2.1 The Maplewold base roster

| Pal | Rarity, calling | Game system (hook) | Mode | Boon and combat effect | Base | Lit |
|---|---|---|---|---|---|---|
| Acorn Nip ("hides acorns, forgets where") | C, seedkeeper | **Gathering**: you gathered anything today | passive | *Acorn Cache*: Mend, heal N at the start of each round | 1 | 2 |
| Leaf Tuck ("folds into a leaf pile") | C, bloomcaller | **Seasons**: Hollow season is autumn (`hollow_season()`) | passive | *Leaf Pile*: the first N creature hits each fight are halved (new effect `guard`) | 1 hit | 2 hits |
| Sap Drip ("sticky, sweet, a little late") | C, brewroot | **Pantry**: the snack eaten is a Pantry preserve | passive | *Sticky Sweet*: snacks heal +N%; lit = Pantry jars heal more, and 2 HP more at the start of the next round ("a little late") | +10% | +20% and +2 next round |
| Bark Badger ("wears a tree's coat and shares it") | U, rootwarden | **Garden**: you watered a garden plot today (`plots.last_watered`) | passive | *Borrowed Coat*: damage taken -N | 2 | 3 |
| Fourwind Finch ("points four ways") | U, wayfinder | **Roads / map**: a road fight (exp kind `walk`, not delve, lair or explore) | passive | *Four Ways*: armour and running +N | 2 | 3 (and running +2 more) |
| Samara Spin ("a maple key that learned to fly") | R, thornblade | **Puzzles**: you solved the Maplewold jigsaw today (`puzzle_runs` day + status done), or hold its Expert trophy | passive (active option, 4.4) | *Whirligig*: damage +N, and your calling ability is stronger (new effect `kindle`, +1 step) | +2 dmg, kindle 1 | +3 dmg, kindle 2 |

Check: 6 different effects (mend, guard, sip, ward, foot, edge+kindle), 6 different hooks (gather, season, pantry,
garden, road, puzzle). The rare replaces today's "second calling skill" with `kindle`, its roster signature.

### 2.2 Rarity scaling per slot

The numbers are NOT per row. They come from one table by (effect, rarity), so the balance lives in one place (3.2).
The slot pattern every roster inherits from the Maplewold:
- **3 commons**: one healing-type effect, one defence-type, one utility/economy-type. Hooks are everyday actions.
- **2 uncommons**: one defence, one mobility/offence. Hooks need a small choice (where you fight, what you tended).
- **1 rare**: the roster's signature: an offence effect plus a twist (kindle / spoils / rally), hooked to the pal's
  own picture or place where possible. The only pal allowed an active Boon.

---

## 3. Deriving every other roster as a unique variant

### 3.1 Rules

1. **Slots**: every roster keeps the Maplewold shape (3.2 slot pattern above). Rarity mix and order are already fixed.
2. **In a roster**: 6 different effects and 6 different hooks (Maplewold-style). An effect's family can repeat once
   if a roster's theme demands it (lint warning, not error).
3. **Across rosters**: no two rosters share 4 or more of their 6 `(effect, hook, arg)` triples. (Same idea and
   output style as `pal_unique_check.py`: "TOO ALIKE a ~ b, shared 4/6".)
4. **Rare signature**: each rare's `(effect, hook, arg)` is unique across all 95 rosters.
5. **Theme first**: the hook fits the picture and the blurb. Region pictures use their landscape and the everyday
   systems; Places pick from their kind's pool (3.4). Calling is only a tie-breaker for the effect, so the 71 rare
   wayfinders do not all become Fleet Foot.
6. **No per-row numbers**: rows name the effect, hook and arg; values come from the table. Balance stays central.
7. **Fallback**: a pal with no Boon row plays exactly as today (`PPAL_SKILLS`). Lets us ship one roster at a time.
   Generated rosters (uploads) get a crc32-seeded Boon from their kind's pool, like their names.

### 3.2 Effect archetypes (no new dice in any passive)

| Effect | What it does | C / U / R base | Lit adds | Party cap | Where in code | Dice? |
|---|---|---|---|---|---|---|
| `ward` | damage taken -N | 1/2/3 | +1/+1/+2 | 4 | creature turn | no |
| `edge` | damage +N | 1/1/2 | +1/+1/+1 | 3 | `dmg_bonus` | no |
| `foot` | armour and running +N | 1/2/3 | +1/+1/+2 | 4 | `ac`, `flee_roll` | no |
| `mend` | heal N each round | 1/2/3 | +1/+1/+2 | 4 | round start | no |
| `sip` | snacks heal +N% | 10/20/40 | +10/+20/+20 | 60 | snack | no |
| `petal` | crit chance +N% | 1/2/4 | +1/+2/+2 | 6 | `luck_crit` (existing roll) | no |
| `guard` NEW | first N creature hits each fight halved | 1/1/2 | +1 | 3 hits | creature turn, enc counter `pg` | no |
| `rally` NEW | once a fight, at 30% HP or less, heal N | 4/7/12 | +3/+4/+6 | one trigger (largest) | after creature turn, enc flag `pw` | no |
| `first` NEW | to-hit +N on round 1 only | 2/3/5 | +2 | 6 | `attack_roll` bonus arg, enc round `rd` | no (same roll) |
| `kindle` NEW | calling ability stronger: Bark +1 round, Spore +2, Brew poison +1 tick, Aimed +2, Flurry +1 a hit, charm +2 | 1/1/1 step | +1 step | 2 steps | ability branch | no |
| `spoils` NEW | each creature drop roll +N% after a win (not befriend) | 5/10/20 | +5/+5/+10 | 30 | `win_fight` threshold | no (same roll) |
| `lesson` NEW | Fighting XP +N% from a win | 5/10/20 | +5/+5/+10 | 30 | `win_fight` | no (`ppal_scale` is a roll: use a floor instead) |

12 effects. Mobility/offence/defence/heal/economy all covered. `spoils` and `lesson` are weak in a fight on purpose;
they fill common slots on economy-themed rosters (havens, markets).

### 3.3 Hooks (game systems a pal can touch)

All read once at fight start and snapshotted (3.6). "Free" = data already in the fight.

| Hook | Game system | Lit when | Cost / storage |
|---|---|---|---|
| `land:<landscape>` | Map / regions | the fight is in that landscape (`exp_scene` land; 9 landscapes) | free |
| `season:<s>` | Hollow clock | `hollow_season()` = s (4 seasons) | free |
| `clock:<day/night>` | Game clock (2.0.93) | Hollow hour in the band | free |
| `place:<walk/explore/delve/lair>` | Roads, explore, delves, lairs | `exp['kind']` matches | free |
| `foe:<small/large>` | Creatures | creature size | free |
| `health:<low/full>` | Health (2.3.5) | fight starts under 50% / at full | free |
| `calling` | Callings | gnome calling = pal calling | free |
| `trophy` | Jigsaw | gnome holds the pal's picture's Expert trophy (`ppal_has_trophy`) | 1 cached query |
| `puzzle` / `puzzle:own` | Jigsaw | solved any / this pal's picture today (`puzzle_runs`) | 1 query |
| `garden` | Gardens | watered a plot today (`plots.last_watered`) | 1 query |
| `pantry` | Pantry | snack is a preserve (sip-type), or a Pantry batch finished today | free / 1 query |
| `craft` | Crafting, Alchemy | a drink buff is active (meal-buff slot) or crafted today | free / NEW tracker |
| `gather` | Gathering | gathered today | NEW tracker |
| `catfish` | Cat Fish | played / fed today | check table, maybe NEW tracker |
| `jobs` | Pal Jobs | this pal is Adventuring 5+ (`ppal_found.a_xp`, `PJ_DELVE_SAFE`) | 1 query |
| `market` | Shop / market | sold something today | NEW tracker (low priority) |

NEW trackers: one tiny table `ppal_hook_log (user_id, day, hook)` with a unique key, written by one line at each
hooked action (gather, craft, catfish, market). Additive schema, self-migrating like `ppal_ensure()`. The old unused
columns `users.ppal_day` / `ppal_count` should NOT be reused (unclear meaning on live sites).

With args, hooks give about 35 distinct triggers x 12 effects x 3 rarities: plenty for 570 unique pals.

### 3.4 Theme pools for deriving rosters

| Roster group | Count | Hook pool (pick 6 different) | Effect lean |
|---|---|---|---|
| Gallery regions | 14 | `land:<own landscape>`, `season`, `gather`, `garden`, `pantry`, `puzzle:own`, `clock`, `place:walk`, `catfish` | like Maplewold, rotated |
| Haven places | 18 | `garden`, `pantry`, `craft`, `catfish`, `market`, `health:full`, `trophy` | `sip`, `mend`, `spoils`, `lesson`, `ward` |
| Wonder places | 35 | `clock`, `season`, `place:explore`, `puzzle`, `trophy`, `land:*` | `petal`, `first`, `foot`, `kindle` |
| Delve places | 14 | `place:delve`, `health:low`, `jobs`, `craft`, `foe:small`, `clock:night` | `guard`, `rally`, `mend`, `foot` |
| Lair places | 14 | `place:lair`, `foe:large`, `health:low`, `calling`, `jobs` | `edge`, `ward`, `rally`, `kindle` |

**Derivation steps per roster** (mirrors the approved Places pipeline: draft, Opus review, Joshua approves):
1. Copy the Maplewold slot pattern.
2. Draft tool `tools/pal_boons_draft.py SLUG` proposes effect + hook per slot: crc32(slug) rotation through the
   group's pools, nudged by blurb words (water/tide -> `land:coast`, night/moon -> `clock:night`, jar/brew -> `pantry`).
3. Opus reviews against the blurb and the picture (titles lied before), writes Boon names and lines.
4. Lint (3.5) proves rules 2 to 4. Joshua approves names and lines per batch.

Worked example, Sunsprinkle Isles (draft, to show the shape): Shell Skip (C) `spoils@gather` "Tideline Pockets";
Palm Fidget (C) `foot@clock:day`; Tide Tuck (C) `guard@land:coast`;
Coral Cuff (U) `ward@season:summer`; Lagoon Loop (U) `petal@catfish` (the lagoon winks at your cat); Cocopaddle (R) `first@puzzle:own` +
active "Paddle Rush". Shares 0 of 6 triples with the Maplewold.

### 3.5 Validation and the lint tools

Data: a NEW file `game/includes/data/puzzle_pal_boons.txt`, so the 570-row file, its 14-column format, its lint and
the art tools stay untouched:
```
# key|boon name|effect|hook|arg|mode|line
mw-acorn-nip|Acorn Cache|mend|gather|-|passive|Patches you up with an acorn it found again.
mw-samara-spin|Whirligig|edge|puzzle|own|passive|Spins in on the wind when its picture is fresh in your mind.
```
Lint: extend `tools/lint_puzzle_pals.py` with `--boons FILE` (default the file above when present), same "problems"
output and exit code:
- key exists in `puzzle_pals.txt`; one row per key; effect, hook and arg valid (landscapes parsed from
  `adventure_data.php` `LANDSCAPES`, seasons from `HOLLOW_SEASONS`); `active` only on a rare;
- rule 2 (distinct effects and hooks per roster), rule 3 (shared triples >= 4 = TOO ALIKE), rule 4 (rare signature);
- Boon names unique across all, <= 24 chars; line <= 120; curly apostrophes; no `|`;
- `--require-boons` turns "pal has no Boon" from a note into an error (switch on after the last batch);
- prints one fingerprint per roster (`maplewold: mend@gather guard@season:autumn ...`) for review sheets.
`pal_unique_check.py` stays art-only. PHP test `tests/puzzle_pal_boons.php` checks the loader agrees with the lint and
that every effect/hook in the data exists in PHP.

### 3.6 Engine sketch (for the build, not now)

- `ppal_boons(array $u, array $exp, array $enc)`: equipped pals -> Boon rows -> hook states -> summed and capped
  values. Snapshot into the encounter JSON at the first `combat_turn` (like `fight_prep` stores `hs`): `$enc['pb']`.
  Hooks are read once per fight, a mid-fight swap of pals changes nothing, and `fight_odds` can read the same numbers.
- `gnome_combat($u, true)` keeps its signature; the `pal` key carries the snapshot values. A gnome with no pals
  returns the same array as today (golden-safe).
- Setting `ppal_boons` (0/1). Off = today's `PPAL_SKILLS`.

---

## 4. Active skill option

### 4.1 Why it was rejected before, and what changed
2.2.2 NEXT item 2: "needs fight state and golden-test care". The fight state already exists: the road / lair / delve
fight stores `expeditions.encounter` JSON with `used` (calling ability), `bark`, `poison`, `snacks`, `hs`. A pal
skill needs one more flag there. No schema change for once-per-fight. The golden test replays explicit actions only
(section 5 lists attack, ability, flee, snack...); a new action that nobody sends cannot move it.

### 4.2 Design
- **Who**: the rare only (95 actives, one per roster: part of its signature). Commons and uncommons stay passive.
  A rare with an active keeps its passive Boon too.
- **Use**: once per fight, uses your turn (the creature still acts), like the calling ability. Lit = stronger.
- **Never automatic**: `fight_on`, `auto_resolve` and Fight certainty never use it (they send `attack` only).
- **No dice**: fixed numbers, so RNG order stays simple to record.
- **Action pool** (rares pick one; unique per roster with the passive):

| Active | Effect | Base / lit |
|---|---|---|
| Strike | can't-miss hit for fixed damage | 6 / 9 |
| Shield | next 2 creature hits -N | 3 / 5 |
| Patch | heal N now | 10 / 15 |
| Snare | your next flee always works | - / also +2 armour |
| Sap | poison on the creature, 2 more ticks than Bitter Brew | 2 / 3 ticks |
| Daze | creature skips its next turn (not on lair bosses) | once / once + guard 1 |

- Maplewold: Samara Spin, "Helicopter Key" = Strike 6, lit 9 (solved its picture today).

### 4.3 Code it touches
- `game/adventure.php` POST whitelist (`in_array($do, ['attack', 'ability', 'flee'])`, line ~59): add `palskill`.
- `combat_turn` new `case 'palskill'`: refuse if `$enc['pa']` set or no rare along; set `$enc['pa'] = key`.
- Buttons in BOTH fight renders: `adventure.php` ~287 and `layout.php` ~468 and ~485 (the two compact forms), plus
  delve v2 if it has its own fight card. Show the pal sticker, "Used this fight" when spent.
- Fight replay (`$_SESSION['fight_replay']`) logs the line like other moves.

### 4.4 Risks
- **Golden**: existing table unchanged (no pals, no new action). Add a NEW section with fixed seeds for each active,
  recorded only after review, plus a "pals along, passive" table. Do it in the same release as the engine.
- **Phone clutter**: a fight already shows attack, ability, snack, flee, fight on, auto. Put the pal button on the
  ability row (two half-width buttons).
- **Double submit / back button**: covered by the existing lock + transaction + PRG; `pa` is inside the same row.
- **Daze vs bosses** and lair scripts: exclude Daze on lairs, or make it "-50% next hit" there.
- **Odds lie**: `fight_odds` ignores actives (same as the calling ability today). Acceptable.
- **Daily charges** (if wanted instead of once a fight) DO need storage: `ppal_found.sk_day`, `sk_n` (additive).
  Recommend not doing charges.

---

## 5. Balance guardrails and build plan

### 5.1 Guardrails
- Floor = today: every base value equals today's `PPAL_SKILLS` value for that rarity, so switching on loses nobody
  anything. Lit values are at most one rarity step up.
- Party caps stay (`PPAL_SKILL_CAP` plus the new caps in 3.2). Two pals with the same effect still hit the cap.
- Budget: a lit rare + lit uncommon party should be at most about 1.4x today's best rare + uncommon party.
  Rough points: 1 ward = 1 mend = 1 foot = 1 edge = 20% sip = 2% petal = 1 guard hit = 4 rally HP.
- Sim gate before flipping (new `claude/pal-boons-sim.php`, real `combat_turn`, levels 5 to 40, small/large foes):
  even-level win rate with a lit party at most +10 points over today's skills; average HP lost not under half of
  today's; no fight band newly "certain" for auto-resolve because of Boons.
- Hooks must be reachable in a few minutes of normal play; at least 3 of a roster's 6 hooks need no new purchase;
  no hook reads other players; `health:low` gives defence/healing only (no damage reward for low HP).
- Pal Jobs rolls (`pj_roll_trip`, `pj_roll_delve`) do NOT use Boons in v1. Treks and contests never.
- Expert trophy: keep its perk +4; optionally "trophy = always lit" (question 5).

### 5.2 Build plan (small releases, each behind `ppal_boons`, OFF)
1. **B1 engine + the Maplewold.** Boons file with 6 rows, loader, 12 effects, hook snapshot, `ppal_hook_log` +
   the `gather` writer, `ppal_boons` setting, My Gnome / Pal Book lines with "lit today". Lint `--boons`.
   Tests: each Maplewold Boon lit and unlit through whole `combat_turn` rounds (extend `puzzle_pals_party.php`);
   golden unchanged on a fresh install; record "pals along" golden section. Other 89 rosters play as today.
2. **B2 sim + numbers.** `claude/pal-boons-sim.php`, tune the table, Joshua plays with `ppal_boons` on.
3. **B3 gallery rosters (13).** Draft tool, Opus review, Joshua approves names and lines, lint.
4. **B4 Places rosters (81)** in four batches: haven, wonder, delve, lair (plus the `craft`, `catfish`, `market`
   trackers as their hooks appear). After the last batch: `--require-boons`; generated rosters get seeded Boons.
5. **B5 (optional) rare actives** behind `ppal_boon_active`: action, buttons, new golden section.
6. **B6 flip + news** (with `ppal_open` / `ppal_party` whenever Joshua opens Pals to players).

Each release: `php -l`, `puzzle_pals.sh`, `paljobs.sh`, golden on a fresh walk.sh install, slim zip as usual.

---

## 6. Open questions for Joshua (with my recommendation)

1. **What "Maplewold is the base" means.** (a) its 6 Boons are the template every roster varies from, or (b) the
   Maplewold keeps today's plain skills and the others vary. **Rec: (a)**, and the Maplewold ships first as the model.
2. **Hook not met: floor or nothing?** **Rec: floor = today's value**, hook lights a bonus. Nobody loses power, and
   "varying" comes from lit days/places.
3. **Do Boons replace the calling skills?** **Rec: yes for pals with a Boon row**; the rare's second calling skill
   is replaced by its signature. Calling still sets stats, the default perk and Pal Jobs.
4. **Active skills now or later?** **Rec: later (B5), rares only, once per fight, uses the turn, no dice.**
   Passives first so B1 to B4 never touch the fight buttons.
5. **Expert trophy = always lit?** **Rec: yes** for that picture's pals. A clear reward for the 216-piece solve,
   and it ties pals back to being puzzle pieces.
6. **New per-day trackers (`ppal_hook_log`)** for gather / craft / Cat Fish / market. **Rec: yes**, one small
   additive table. Without it the Boons can only use free and existing-table hooks (still enough for B1 bar `gather`;
   Acorn Nip could swap to `land:forest` if you say no).
7. **Should Boons change pal job results** (trips, delve re-runs)? **Rec: no in v1.** Pal Jobs balance was just set.
8. **Should pal Adventuring level scale the Boon?** **Rec: not now**; only as the `jobs` hook (lit at A5+).
9. **Vary the `perk` column per roster too** (all 570 are `-` today)? **Rec: not in this project.** Boons already
   link each pal to a game system; perks can be a later pass.
10. **Boon names and lines** are new text on 570 pals. **Rec: approve per batch** (Maplewold 6, gallery 78, then
   each Places kind), the same flow as pal names.
11. **Treks stay pal-free** (standing rule). **Rec: keep.**

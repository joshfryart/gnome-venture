# Puzzle combat v1: plan for week 1 (cut, tell the truth) and week 2 (two bets)

Base: branch `ccr-c7be547b-crd9f9`, HEAD `3e76b2f4` (2.6.94 + AIMSTICK, level curve, boss retune). Planner only: no repo file was changed.
Sources: `scratchpad/fable/critique.md`, `rules.md`, `turnflow.md`, `deck.md`; `scratchpad/opus/balance.md`, `difficulty.md`, `strategy.md`; `scratchpad/hk/f*.json`, `r*.json`.
`scratchpad/fable/learn.md` does NOT exist (checked). This plan does not use it.

## Summary (15 lines)

1. VERIFIED: `tests/pf_play.php` (the haiku and critique harness) builds the OLD archetype creature deck (Lunge, Snap, Feint, Recover, Brace, Rend...) AND the old stage-A player deck. All 30 saved playtest states contain 0 creature tags and 0 tool, crop, pal or region pieces.
2. The sims are right. `tests/pfboard_tune_v1.php` uses `pfd_foe_row` (layered decks) and `DECK=real` (deck model) by default. So does the live game (`pfight_game.php:129`). Every sim number in rules / deck / balance / difficulty / strategy stands.
3. What changes: every playtest-only claim about creatures or Teamwork is void. Fixing the harness is task T1, and it blocks the final playtest. The cuts still stand on sim evidence.
4. Compatibility: each cut is a key in `pfb_v1_cfg`, read through a new helper, `pfb_v1r()`. A key missing from a saved state means the 2.6.94 rule, so fights already under way keep their rules. Old non-v1 fights stay byte for byte.
5. Pure config (rules already have a switch): Teamwork (`team2`/`team3` = 1) and per-piece life (`life` = 0).
6. Small code behind a new switch: set-aside, must-link (player only), refused pass, flip limit, Wind and Mud (left out of the environment deck).
7. Code removal (no fight state involved): the harmony meter and the Teamwork row in the box.
8. One bar: damage plus charm fill one bar (x1.15 long). The larger share names the ending. Bosses take Charm at x0.6, and a boss fight always ends "seen off".
9. Aim total: a dry run of the committed aim on the board as it is now, giving the health it takes, the bait damage and the reasons (Sun, combo, pieces fired). It is shown again after your move. Lit cells stay as they are, per Josh's decision of no reply number.
10. Hand: full redraw every round (unplayed pieces go to the discard, draw 5). Kits: Bold is the default and every kit has 4 Hurt; a custom starter needs at least 3 Hurt. Replay: 5 s at most, a board tap skips it, and reduced motion means skip.
11. Week 2 (a), a board that lasts: use-up spends only creature and environment pieces, and the creature's aimed Hurt breaks your piece on the aimed cell instead of re-picking. Variant (b) and (c)-alone run as sim controls only.
12. Week 2 (b): one readable rule per class, built on existing tags and code (Wind's push becomes Water's, Bramble placement becomes Plant's), plus a boss that commits its next piece. No search changes.
13. New metric "real choice" (look bot, 2-ply over the top 6 moves; two different pieces within 10% of the value span) and "own piece on board at turn start". Both are added to the tuner in T2, before anything changes.
14. There are 22 tasks. The engine tasks are serial (`pfboard.php` + `pfengine.js`), the page tasks are serial (`pfboardv1_part.js`), and the box, harness and tuner tasks run beside them. There are 3 checkpoints for Josh.
15. Do NOT build: smarter creature search (2-ply measured no gain), creature combine (it widens the skill gap), flat bar or foe changes per size (they push L10 to 83-91%), new pieces, or deck-layer features.

---

## 1. Verification

### 1.1 Creature (and player) deck in the harness and the sims

| Tool | Creature deck | Player deck | Evidence |
|---|---|---|---|
| Live game | layered `pfd_foe_row($c, pfd_exp_region($exp))` | deck model `pfight_me` | `game/includes/pfight_game.php:129-130` |
| `tests/pfboard_tune_v1.php` (all opus/fable sims) | layered by default (`FOE=layers`), region rotates with the seed | deck model (`DECK=real`, `tv_sources` -> `pfd_tiles`) | lines 42-44, 155 |
| `tests/pfengine_js.php` (parity) | layered only in mode `v1d`, archetype in the other modes | deck model only in `v1d` | lines 140-145 |
| `tests/pf_play.php` (haiku plus critique fights) | **archetype**: `pfb_new(pp_player($lv), $all[$slug] + ['region'=>...])`. The row has no `deck`, so `pf_foe_deck` builds Lunge/Snap/Brace/Feint/Recover (+Rend or Shy Back, +Slam/Bulk, boss +Crush/Scheme) | **old stage A**: `pf_player_deck(...)` from `pf_collection`, with no kit, tool, pal, crop or region pieces | `tests/pf_play.php:25-33, 108`; `pfight.php:260-287` |

Measured on the 30 saved states `scratchpad/hk/f1..f30.json`:
- creature tile names: Brace 30, Lunge 30, Feint 30, Recover 30, Snap 30, Rend 17, Bulk 15, Slam 15, Shy Back 13, Scheme 5, Crush 5, Burrow 2 (a signature piece);
- creature tile tags: all 166 are `''`;
- player tile sources: basic 162, knack 105, calling 15 (no `pal`, `tool` or `crop`).

The same Lunge/Snap set is used for all 88 creatures in the harness, with values scaled by die and level. The tuner does build the real layered decks.

What this changes:
1. **The sims were not wrong.** Every rate in `rules.md`, `deck.md`, `balance.md`, `difficulty.md` and `strategy.md` comes from the tuner with layered decks. The case for cutting and for the two bets rests on those sims and is unaffected.
2. **The playtests were wrong in three specific ways.** Do not cite them for these:
   - creature identity: "I could not tell the Grass Snake from the Bullfrog" (critique section 5). The haiku testers never met a class piece or a tag: poison (Venom Spit), trip (Undertow), evade (Flutter Off), bash (Shoulder Barge), thorns (Bramble Coat), quick (Skitter).
   - Teamwork: "0 of 29 playtests mention it". It was impossible in the harness, because no piece had a pal, tool or crop source. The Teamwork cut stands on the sim (-0.2 / -1.1 points) only.
   - kits: the harness never dealt Bold, Steady or Kind.
3. **Priority change:** fixing the harness (T1) comes first. It blocks the final playtest, and it is cheap and independent. The class-rule bet (week 2b) stays: `strategy.md` measured on layered decks that random moves give +3 to +8 pp and 2-ply gives nothing. The per-class rules must build ON the existing class tags, not ignore them.
4. Playtest findings that do NOT depend on the deck still hold. They come from the page or the rules, which are shared: the refused pass, "health" against "hp", the aim being under its real value, unexplained combos, and the hand clogging.

### 1.2 Where each cut lives

Legend: P = `game/includes/pfboard.php`, J = `tools/pfengine.js`, V = `tools/pfboardv1_part.js` plus `tools/build_pfboardv1.py`, which generate `game/assets/pfboardv1.js` (run `python3 tools/build_pfboardv1.py`; `game/assets/pfboard.js` must stay byte for byte), G = `game/includes/pfight_game.php`, D = `game/includes/pfdeck.php` / `pfdeck_view.php`, H = `tests/pf_play.php`, U = `tests/pfboard_tune_v1.php`, M = `tools/pfdemo_v1/*` (rebuild with `tools/build_pf_demo_v1.py`).

| Cut | Lives in | Saved-state need | Kind |
|---|---|---|---|
| Set aside / join / add / group | P `pfb_play` ('j','h','c'), `pfb_connect`, `pfb_place_group`, `pfb_group_*`, `pfb_must_link` (held group), `pfb_pass` (group spots), `pfb_view['held']`, `pfb_cell_preview('c')`; J same names; base `pfboard.js` `joinOptions`/`renderOpts` (`#pf-opts`); G pass form; H join/add/group commands; U `tv_joins`, smart bot; tests `pfboard_v1.php`, `pfengine_js.php` candidates | A fight holding a group must still be able to place it, so the switch is read from state with the old default | new switch `aside` (code gate, nothing deleted) |
| Teamwork | P `pfb_fire` (`team2`/`team3`), view `team2/3`; J `fire`; V chip (line 208), hand source icon (192-193), help text; D/M Teamwork row in the box; H text | already in cfg | **pure config** (`team2`=`team3`=1.0) plus UI gates |
| Must-link (player) | P `pfb_must_link`, `pfb_cells`, `pfb_place`; J `mustLink`; base `pfboard.js` `mustLink` (page lighting); V `countCells`/`usable` reasons | old states keep it | new switch `must` (player only; the creature keeps it) |
| Refused pass | P `pfb_pass` (refusal loop lines 1213-1217); J `pass`; G pass form and the `pf-pass` button; V hint "No piece fits"; H `pass` | old states keep refusal | new switch `freepass` |
| Flip once a turn | P `pfb_can_flip`/`pfb_flip` (`flipt`, `ft`); J `canFlip`/`flip`; V `unflipPrev`, `flipLabel`; build rule "picking a different piece takes back this turn's flip"; tests `pfboard_v1.php` 275-281, `pfv1_flip.sh/.js`; U `tv_places` | old states keep the limit | new switch `flip1` (1 = once a turn) |
| Per-piece life 2/3/4 | P `pfb_v1_tile`, `pfb_life`; J `v1Tile`/`lifeOf`; V pips (all show 3 when off), card "stays N" | already in cfg | **pure config** (`life`=0) |
| Harmony meter | D `pfd_harmony` (pfdeck.php:352, used at :538), `pfdeck_view.php:94-110`; M `pfd.js:122-147`, `views.js:53-61`; tests `pfdeck_v1.php:316-321`, `pbox_v1.sh:95` | none (box only) | **code removal** (replace with a Hurt count line) |
| Wind and Mud | P `pfb_env_deck` (from `data/pf_env.txt` plus region leans `=NA|wind+1`, `=CSA|mud+1`, ...); J `envDeck`; V help sheet loops over all 6 kinds (line 285) | the environment deck is drawn into the state at `pfb_new`, so old fights keep theirs automatically | new switch `nowm` (deck filter). **Keep** all Wind and Mud fire and render code for old fights |
| Hand clog (top-up) | P `pfb_end_round:1201`; J `endRound`; H/V text | old states keep top-up | new switch `redraw` |
| Two bars | `game/includes/pfight.php` `pf_check_end` (shared with OLD fights, so gate on `$s['v1']`); P `pfb_new` (boss `cm`, bar length); J `checkEnd`/`pfbNew`; G `pfight_bar_html` (:379-395), result card; base `pfboard.js` bar update (build replacement); U `tv_value` (`max(fh,bar)` becomes the sum); M `views.js:226-232` | old states keep two bars | new switch `onebar` |
| Aim face value | P `pfb_intent` (plan), `pfb_view['aim']`; J `intent`/`view`; G `pfight_preview_out`; V aim chip; H CREATURE AIM line | none needed: a missing `tot` means old display | new `pfb_aim_total()`; `aimtot` switch |
| Replay 14.6 s | base `pfboard.js` `maybeReplay` (step 950, BAN 1500, tt 300), V `replayStart`, `usedStep` (850/800), build replacements; `prefers-reduced-motion` used only for CSS (`pfboard.js:71`) | none (page only, every v1 fight) | page code |
| Default kit Steady, 2 Hurt | D `PFD_KITS`, `PFD_KIT_DEFAULT`, `pfd_starter_check` ("at least two"); M `pfd.js`; tests `pfdeck_v1.php:87, 244-250` | a player's chosen starter is saved and is not touched; only "not chosen yet" players change | data |

**State compatibility pattern.** Earlier versions did it this way: `$s['v1']` holds the fight's cfg at `pfb_new`, and old keys stay (`V1_OLD` in `tests/pfboard_v1.php:7`; the 2.6.74 terrain path survives as `env 0, ground 1, events 1`). New keys need one more step, because `pfb_v1_cfg` is only read at `pfb_new`, so a saved 2.6.94 state simply lacks the key. Rule: **every new key is read through `pfb_v1r($s, $k)` = `$s['v1'][$k] ?? PFB_V1_PRE[$k]`**, where `PFB_V1_PRE` holds the 2.6.94 behaviour. JS has `v1r(s, k)` with the same table. `pfb_view` emits the resolved values, so the page never guesses.

---

## 2. Design decisions (firm)

**D1 One shared bar** (switch `onebar`, new fights 1).
- What it is: one bar, length = today's `fh.max` x **1.15** (`PFB_V1_ONEBAR_BAR`; rules.md prototype: x1.15 restored length, large 7.7 against 7.8 turns, win 83/83). Hurt adds to `fh.now` (x `hm`), Charm adds to `bar.now` (x `cm`); both stay as separate counters. The bar shows their sum.
- When the fight ends: `round(fh.now + bar.now, 1) >= fh.max`.
- The ending: `charmed` if `bar.now > fh.now` and the creature is charmable (cm > 0 and not a boss); otherwise `seen_off`. Rewards stay as they are (`win_fight($charm)`).
- Bosses: `cm` = `PF_HOSTILE_CM` (0.6) instead of 0, so Charm pieces are no longer dead (r26). A boss ending is always `seen_off`, because the story has no charmed boss.
- Creature heal and guard reduce only the damage share. Charm stays immune (today's hidden advantage, now visible).
- Why: charm wins 0% of fights against large creatures, 14% of the deck is dead against bosses, and charm progress is thrown away. This is the smallest rule that makes Charm count everywhere without a new reward path.
- Stays the same: hostile Charm x0.6, gentle Hurt x0.8.

**D2 Aim total** (switch `aimtot`).
- `pfb_aim_total($s)` dry-runs the committed plan on a copy (`aimforce`, exactly as `pfb_foe_turn` would) and returns:
  - `hp`: health you lose (with your current guard);
  - `g`: guard of yours it eats;
  - `bait`: damage to the creature from YOUR pieces its chain fires;
  - `heal`: its own heal;
  - `n`: pieces fired;
  - `why`: list of short strings: `"Sun x2"`, `"combo Ambush"`, `"fires your Jab"`, `"fires Bramble"`, `"Quick: plays again"`, `"Mud -25%"`.
- It is computed (1) at intent time and stored as `plan.tot`, and (2) after your placement, through `pfb_play(..., dry=true, withAim=true)`, returning `aim` or `['broken'=>'cell'|'edge']`. `pfight_preview_out` passes it to the plan text.
- Lit cells stay unchanged: no reply number, per Josh's decision (rules.md section 2).
- Also show the creature's guard on the status line: `status.foe_block`.
- Why: hits of 2x the shown number or more come on 16-37% of Hurt aims; the bait play becomes visible without breaking the lit-cell decision.

**D3 Hand** (switch `redraw`): **full redraw.** At the end of the round, every unplayed hand piece goes to the discard (flip state cleared), then you draw `PF_HAND_CAP - slow` (5, or 4 when tripped).
- Why: no extra tap or UI mode (a free discard costs a tap and a choice panel on a phone), and no clog at all. Slay the Spire does this.
- Trip ("draw one fewer") and Quick (+1 now) keep their meaning.
- The free discard is NOT built.

**D4 Kits.**
- Default kit `bold`.
- Every one-tap kit holds 4 Hurt with the core Swing:
  - Bold: unchanged (CALLING, jab, swing#2, pierce, snack, c:grain);
  - Steady: CALLING, jab, swing#2, pierce, brace, r:HOME;
  - Kind: CALLING, jab, swing#2, pierce, hum, soothe.
- The offer holds exactly 4 Hurt (core swing, jab, pierce, swing#2; Thorn Cut for thornblade), so a minimum of 4 would leave no choice. The custom starter minimum goes from 2 to **3** Hurt.
- Saved starters are untouched.
- Evidence: Steady 63% / 39% against Bold 79% / 56% (levels 1-4 / 5-10), and Steady fights last 10 turns.

**D5 Replay ≤ 5 s at 1x.**
- No "Your turn" banner before your own chain.
- The environment step merges into the creature's step: no environment banner, and both pieces drop in one 400 ms step.
- Creature banner 700 ms; event step 600 ms; use-up step 500 ms; the leaving step (now 800 ms unscaled) scaled to 300 ms.
- Then a hard cap: if the scheduled total is over 5000 ms, all timings are multiplied by 5000/total.
- A pointerdown anywhere on the board or the dock during the replay = Skip.
- `matchMedia('(prefers-reduced-motion: reduce)')` and no stored speed means default speed `0` (skip).
- Applies to every v1 fight, old saves included (presentation only).

**D6 Board that lasts (week 2a).** Pick (a)+(c), two switches.
- `keepmine` (variant a): a chain of 3+ uses up the creature's and the environment's pieces that fired. Yours stay, and still count toward the 3. Yours leave only by life (3 rounds for all once `life`=0) or by D6c.
- `aimhit` (variant c): if YOUR piece stands on the creature's aimed cell and the aimed piece is Hurt, the creature strikes it instead of re-picking:
  - a Guard piece of value >= the hit survives, otherwise your piece breaks (goes to your discard);
  - you take no damage, and the creature's piece goes to its discard (turn spent);
  - a non-Hurt aim on a taken cell still re-picks, as today.
- What replaces use-up for your pieces: expiry after 3 rounds plus being struck.
- Why this combination, not (c) alone: (c) does not make anything last. Use-up still wipes your pieces, and 40-68% of turns start with none of yours (rules.md section 5).
- Why not (a) alone: re-fired own pieces with no stake. Use-up fully off gave 3.4-5.2-turn fights and 98-100% for the careless bot. (a)+(c) gives blocking a cost and Guard pieces a job.
- Why not (b) ("only the placed piece is spent"): the 4x4 board fills, and dead turns (6-14%) and pieces with no cell (14-17%) grow.
- (b) and (c)-alone are built as sim-only switches for the comparison. The decision rule is in T15.

**D7 One rule per creature class (week 2b)** (switch `kinds`). All 6 classes in `pf_class_base.txt` / `pf_creature_class.txt`, plus the boss. Each rule is one sentence on the creature card and one chip. None touches `pfb_search` scoring beyond what the rule mechanically does.

| Class (count) | Rule | Built on |
|---|---|---|
| Critter (17) | **Swarm:** plays 2 pieces a turn, each at x0.6 value; the aim shows the first, a chip says "+1 small piece" | `pfb_foe_len` |
| Bird (10) | **Two aims:** shows its two best moves on different cells; plays the first whose cell is still open (first preferred); you must take both cells to make it re-pick | `pfb_intent`, `pfb_foe_turn` |
| Beast (28) | **Grudge:** each time you block its aim (take the cell, or D6c strikes your piece), its Hurt counts +25% (max 3 stacks, shown as a chip); a hit that lands on you clears it | `pfb_foe_turn`, `pfb_fire` value |
| Water (13) | **Current:** after its piece lands, one of your pieces touching it slides one cell straight away from it, if free (Wind's push code, freed by the Wind cut) | `pfb_env_fire` wind branch |
| Plant/Fungus (4) | **Grows:** after its turn it puts a Bramble environment piece on a free cell touching its piece (at most one of its own Brambles out); the Bramble fires for whoever chains it | `pfb_env_place` placement code |
| Reptile/Amphibian (15) | **Venom trail:** when one of its pieces leaves the board, that cell is venom for 2 rounds (`ter` kind `venom`); a piece you place there gives you poison 2 x 2 rounds (existing poison path) | `$s['ter']`, `pfb_end_round` poison |
| Boss (9) | **Two turns:** at intent it also commits its next turn's PIECE (a hand piece other than the aimed one, chosen by search on the board after its aim lands); next round that piece is forced, cell chosen then | `pfb_intent`, `plan.next` |

- Class counts come from `pf_creature_class.txt` (95 rows incl. trek); the tuner runs 88 creatures.
- Classes not in the data: none (Insect, Amphibian and Fungus are folded into the six).
- Why: difference today is stat-deep (Bird 72% to Plant 92% at level), while decisions are worth 3-8 pp. Readable rules give identity without search.

---

## 3. Sim protocol (every task that names sim numbers)

- Runner, saved as `scratchpad/plan/sim.sh LABEL BOT OFFSETS MULT 'V1JSON'`: 4 shards with `xargs -P 4` as in `scratchpad/envrun.sh`, output to `scratchpad/plan/out/LABEL.BOT.SHARD.jsonl`, then `cat ... | php tests/pfboard_tune_v1.php agg`.
- Standard set:
  - `chain 0,-4 MULT 1` (207-215 fights per size and offset, se about 3 pp);
  - `look 0,-4 MULT 0.5`;
  - `smart 0 MULT 0.5`;
  - with `CHOICE=1` (from T2), `look 0 MULT 0.5`.
- Paired seeds: the tuner seeds by slug, level and k, so before and after are paired. A gap of 3 pp or less is noise.
- Baseline today (CHANGELOG 3e76b2f4):
  - chain at level 83 / 79 / 85 / 88-92 (small / medium / large / boss); 4 under 69 / 36 / 67 / 73-78; boss 7.6 turns;
  - look and smart 99-100% wins; health lost: look 12-15%, smart 10-14%.
- Targets (owner's): chain about 70-80% at level; look and smart not above about 95-100% unless the change is about stakes; fights 6-8 turns.
- Week-1 cuts that are "inert" must land within noise (±3 pp chain, ±1 turn). The balance retune is ONE task (T13), after all week-1 rules are in. Do not retune per task.

---

## 4. Tasks

Every engine task changes the PHP engine and `tools/pfengine.js` in the same commit. It must keep these green:
- `bash tests/pfengine_js.sh`
- `php tests/pfboard_v1.php`
- `bash tests/pfboard_v1_page.sh`
- `bash tests/pfv1_flip.sh`
- `bash tests/pbox_v1.sh`
- `python3 tools/build_pfboardv1.py --check`
- `php tests/pfdeck_v1.php`

Any expectation that legitimately changes is named in the task. Write the test first and watch it fail (`.claude/rules/test-standards.md`). Add a CHANGELOG "Unreleased" bullet with the numbers. Do not bump the version. Commit on the branch, do not push unless told.

### Phase A: groundwork (T1, T2 in parallel; then T3)

**T1. Harness deals the real decks.** Size S. Files: `tests/pf_play.php` only. Parallel: yes.
- Change:
  - `pp_player($lv)` builds the deck like `tv_player` (require `tests/pfboard_tune_v1.php` for `tv_sources`, or copy its 10 lines): `pfd_tiles(pfd_fight_entries($src), $st, [], $src['calling'], $src['ctier'])`.
  - `new` wraps the creature in `pfd_foe_row($c, REGION ?: array_keys(pfd_region_pieces())[(crc32($slug)+$seed) % 14])` (`require pfdeck.php`).
  - Keep an escape hatch: arg 8 `old` = today's decks.
  - The `pp_show` piece line prints `tag` (already) and `layer` (base/reg/rar/uni).
- Test first: new `tests/pf_play_decks.sh`:
  - (a) `php tests/pf_play.php new $T/s.json grass-snake 14 7 v1`, then assert with php that the state's foe tiles hold a `Bite` or `Venom Spit` piece (Reptile base) and no `Lunge`;
  - (b) the player tiles include a `src` of `tool`;
  - (c) `... v1 '' old` still has `Lunge`.
  - It fails today on (a) and (b).
- Acceptance: the test passes, and the old 30 assignments still start (`new` runs for all 30 slugs in `scratchpad/hk/assign.json`).
- Risk: requiring the tuner file runs its CLI guard. It returns early when not the main script (line 142), so it is safe.

**T2. Tuner: per-row identity, the real-choice metric, the board-persistence metric; baseline run.** Size M. Files: `tests/pfboard_tune_v1.php` only. Parallel with T1 and T7 is NOT allowed (T7 changes kits and so the baseline).
- Change:
  - JSON rows gain `slug`, `class` (`$cr['class']`), `clv` (creature level).
  - New counters:
    - `mine0`: turns that start with none of your pieces on the board;
    - `dead`: turns where no legal action gives any progress (Δ(fh+bar) <= 0, no guard or heal gain, 1-ply);
    - `real`, `plyflip`, `cturns`: only when `CHOICE=1` and bot `look`.
  - **Real choice**, defined exactly:
    - Rank all legal actions by 1-ply `tv_value` and take the top 6.
    - For each, compute V2 = `0.35*v1 + 0.65*best own follow-up` (the `tv_smart` formula, no peeking at the draw).
    - a1 = argmax V2. a2 = the best V2 among actions whose hand-piece key differs from a1's (a pass counts as its own key).
    - span = V2(a1) - min(V2 of the top 6).
    - A turn is **real** if span >= 0.02 and V2(a1) - V2(a2) <= 0.10 x span.
    - **plyflip** = argmax v1 ≠ a1.
  - Print the per size: `real %`, `dead %`, `plyflip %`, `own-piece-at-start %` = 1 - `mine0`/turns. Add `agg` support for these and a `CLASS=1` env var that groups by class instead of size.
  - Read the new rules: `tv_value` uses `(fh.now + bar.now)/fh.max` when `pfb_v1r($s,'onebar')`, and `tv_joins` returns [] when `!pfb_v1r($s,'aside')`. Write these behind `function_exists('pfb_v1r')` so T2 lands before T3.
- Test first: `tests/pfboard_tune_v1_metrics.php`: a hand-built state with two equal Hurt pieces on two cells gives `real` = 1, and a state with one piece only gives `real` = 0. It fails before the change (no function).
- Then run the standard set on HEAD with label `base0` and save it in `scratchpad/plan/out/`. This is the paired baseline for everything. Expected chain at level about 83 / 79 / 85 / 88-92. Record `real`. The critique guesses it is under 20%; the target later is about 50%.
- Risk: CPU. CHOICE costs about a smart run, so use look `MULT 0.5`.

**T3. Compat framework (no behaviour change).** Size S-M. Files: P, J, `tests/pfboard_v1.php`, `tests/pfengine_js.php`. Serial: first engine task.
- Change:
  - P: add `PFB_V1_PRE` = `['aside'=>1,'must'=>1,'freepass'=>0,'flip1'=>1,'nowm'=>0,'redraw'=>0,'onebar'=>0,'aimtot'=>0,'keepmine'=>0,'aimhit'=>0,'useroot'=>0,'kinds'=>0]` and `function pfb_v1r(array $s, string $k)`.
  - `pfb_v1_cfg` gets the same keys with their **new-fight defaults set equal to PRE for now**. Each later task flips its own default, so every task is a one-line revert.
  - `pfb_view['v1']` emits all of them resolved.
  - J: `PFB_V1_PRE`, `v1r`, `v1Cfg` keys, view the same.
  - `tests/pfboard_v1.php`: add `const V1_294 = ['team2'=>PFB_TEAM2,'team3'=>PFB_TEAM3,'life'=>1] + PFB_V1_PRE;` (the full 2.6.94 rule set).
  - `tests/pfengine_js.php`: add mode `v1pre` (`opt v1 = V1_294`) and keep `v1` and `v1d` on defaults, so parity covers both rule sets from here on.
- Test first: in `pfboard_v1.php`, "a 2.6.94 state with none of the new keys resolves every key to PRE", built by unsetting the keys on a fresh state and round-tripping it through json. It fails (no `pfb_v1r`).
- Acceptance: all suites green; tuner `chain 0 MULT 0.25` is identical to `base0` on the same shards (no change at all).

### Phase B: week 1 engine cuts (serial on P and J: T4 -> T5 -> T6 -> T8 -> T9 -> T10)

**T4. Pure-config cuts: Teamwork, per-piece life, Wind and Mud.** Size S. Files: P (`pfb_v1_cfg` defaults `team2`=`team3`=1.0, `life`=0, `nowm`=1; `pfb_env_deck($size,$region,bool $nowm)` drops kinds `wind` and `mud` after the region leans, called from `pfb_new` with `pfb_v1r`), J (`v1Cfg`, `envDeck`), tests.
- Test first (`tests/pfboard_v1.php`, new section "week 1 cuts"):
  - a NEW medium fight: `team2 === 1.0`, no tile has `life`, and the environment deck (`draw` + `next`) has no `wind`/`mud`, checked for regions NA and SEA (both lean toward them);
  - a state made with `V1_294` still has wind in NA over 20 seeds.
  - It fails before the change.
- Existing expectations that legitimately change:
  - the Teamwork checks (`pfboard_v1.php` ~228-240) and the life checks (~313-324) must now build their fights with `['v1' => V1_294]`;
  - `pfboard_v1.php:409` "those fights use every rule" must run with `V1_294` (Teamwork and Wind would never occur under the new rules);
  - `pfboard_v1_env.php` decks under default lose 2 kinds; pin `V1_294` where it counts Wind or Mud.
- Sims vs `base0`: chain within ±3 pp per size (Teamwork off -0.2/-1.1 and life 2-vs-4 77.5/79.6 say inert; Wind 0.1-0.55 pushes a fight; Mud never fires). Look and smart unchanged. Record the environment pieces placed per fight.
- Risk: the deck is smaller (small: 8 -> 6 pieces), so Sun, Bramble and Thornburst come about 1.3x as often. Watch "env cost" in the tuner's env line. If the careless bot's health lost from the environment rises by more than 3 pp, report it in T13; do not fix it here.

**T5. Set-aside off, must-link off (player), free pass.** Size M. Files: P, J, tests (`pfboard_v1.php`, `pfengine_js.php`), H (commands refuse with "Not in this fight." when the switch is off), U nothing (T2 did it). Depends on T4.
- Change:
  - `aside`=0 default: `pfb_play` refuses 'j','h','c' with 'Those moves are not valid.' unless `pfb_v1r(aside)` or a held group already exists (a saved group can still be placed).
  - `pfb_must_link($s,'me')` returns false when `!pfb_v1r(must)`.
  - `freepass`=1: `pfb_pass` skips the refusal loop.
  - Fix in `pfb_pass` (turnflow): set `$w['lastfoe']=[]; $w['gone']=[]` as `pfb_play` does (2.6.88).
  - J mirrors all of it. Parity `candidates()` offers j/h/c only when on, and a pass in some turns when `freepass`.
- Test first:
  - a new fight refuses `['j',0,1,'R']`;
  - a `V1_294` fight accepts it;
  - a new fight with a linking cell available also lights a fitting non-linking cell (it did not before);
  - `pfb_pass` succeeds with legal moves on a new fight and is refused on `V1_294`;
  - after a pass, `$s['gone']` holds only this round's leavers.
  - All of these fail before the change.
- Legit changes: `pfboard_v1.php:311` ("pass is refused while a piece fits when flipped") gets pinned to `V1_294`; the set-aside and group sections are pinned to `V1_294`.
- Sims: chain within ±3 pp. `rules.md`: no must-link, identical to the decimal; free pass, no change; set-aside off, smart bot 100% both ways. Smart health lost within ±3. Legal moves per turn rise from 14 to 16-18 (rules.md), so check the tuner's speed.

**T6. Flip without a limit.** Size S. Files: P (`pfb_can_flip`: when `!flip1` any piece with `ed` may flip any number of times; `pfb_flip` stops setting `flipt`/`ft`), J, `tests/pfboard_v1.php`. Depends on T5.
- Test first: on a new fight, flipping piece 0 and then piece 1 both succeed and both stay flipped; on `V1_294` the second is refused. It fails before the change.
- Legit changes: `pfboard_v1.php:276-281` (once-a-turn checks) are pinned to `V1_294`. The view's `flip.used` stays false for new fights. `tests/pfv1_flip.sh/.js` changes in T12, not here: the page must not run `unflipPrev` when `!V1.flip1`.
- Sims: within noise; the tuner's flips per fight may rise.

**T7. Box and kits: harmony meter out, Bold default, 4-Hurt kits.** Size S-M. Files: `game/includes/pfdeck.php` (`PFD_KITS`, `PFD_KIT_DEFAULT='bold'`, `pfd_starter_check` minimum 3 with the text "Bring at least three Hurt pieces.", delete `pfd_harmony` and the `harmony` key at :538), `pfdeck_view.php` (replace the harmony block :104-110 and the Teamwork row with one line "Hurt pieces: N of M", plus a hint below 3 Hurt per 10: "Few Hurt pieces: fights will be long"), `game/assets/pfv1box.js` if it reads `harmony`, `tools/pfdemo_v1/pfd.js` and `views.js` (same), `tests/pfdeck_v1.php`, `tests/pbox_v1.sh`. Parallel: yes, with T3-T6, T8-T10 (no shared file), but only AFTER T2's baseline is saved. Rebuild the demo with `python3 tools/build_pf_demo_v1.py`.
- Test first (`pfdeck_v1.php`):
  - each kit in `PFD_KITS` with the core has >= 4 Hurt for every calling;
  - `PFD_KIT_DEFAULT === 'bold'`;
  - a 2-Hurt pick is refused;
  - `pfd_box` output has no `harmony` key.
  - It fails before the change.
- Legit changes:
  - `pfdeck_v1.php:249` (the "two" text becomes "three");
  - `pfdeck_v1.php:316-321` (harmony checks) deleted;
  - `pbox_v1.sh:95` expects the Hurt line instead of the `harm` meter;
  - `pfboard_v1_page.sh:40,58` still posts `kit=steady`, which stays valid.
- Sims (the tuner rotates bold/steady/kind by level): chain at level should RISE. deck.md: Bold 79.3/56.4 against Steady 63.3/39.2 at levels 1-4 / 5-10. Expect about +5 to +10 pp at low levels and fights shorter (Steady 10.1 turns). Record it; T13 retunes. Also run `php` of `scratchpad/opus` early levels if available, otherwise chain `0 MULT 1` restricted to creature levels 1-10 with `ONLY` (add the `ONLY` slug filter to the tuner here if T2 did not).
- Risk: the Kind kit now holds Hum and Soothe (-4.6, -2.6) and still nothing for charm players. Accepted; Charm gets its value from D1.

**T8. One shared bar.** Size M. Files: `game/includes/pfight.php` (`pf_check_end`: when `!empty($s['v1']['onebar'])` use the sum rule and the ending of D1; the non-v1 path unchanged byte for byte in behaviour), P (`pfb_new`: when onebar, bar max x `PFB_V1_ONEBAR_BAR`=1.15 and boss `cm = PF_HOSTILE_CM`; `pfb_v1_cfg` default `onebar`=1), J (`checkEnd`, `pfbNew`), H (one line: "BAR a/b (damage x, charm y); fill it to win; the larger share decides: charmed or seen off"), tests. Depends on T6. U already handles `tv_value` (T2).
- Test first:
  - a v1 onebar fight with fh 10 + bar 11 of 21 ends `charmed` (gentle), and with fh 11 + bar 10 ends `seen_off`;
  - a boss with bar > fh ends `seen_off`, and its Charm moves `bar.now` (cm 0.6);
  - `V1_294` keeps two bars;
  - a non-v1 `pf_new` fight keeps `pf_check_end` exactly (the existing flag-off block `pfboard_v1.php:59-77` stays green).
  - It fails before the change.
- Legit changes: `pfboard_v1.php:414-434` (the charm-bar full checks and "60 fights of a charm-first player") pin `V1_294` or are rewritten for the sum. The 2.6.78 one-decimal rule must hold for the sum, so rewrite the 20.66-of-20.7 check for onebar too.
- Sims:
  - win % stays within noise of the T7 numbers (rules.md: large 83/83, medium 74 -> 82, on 2.6.94);
  - charm wins (look) small/medium about 21% / 8% (rules.md);
  - turns within ±0.5 of T7.
  - New: a deck of 1 Hurt + 7 Charm (`tv_sources` variant, env `KIT=charm` in the tuner) gains over 56%. This is the stake: "the kind gnome stops losing".
- Risk: the boss bar plus Charm may make bosses easier. Boss chain is now 88-92; if over 92, reduce boss Charm to x0.4 in T13.

**T9. Full hand redraw.** Size S. Files: P (`pfb_end_round:1201`: when `pfb_v1r(redraw)`, move the hand to the discard with `flip`/`ft` unset, then `pf_draw($s,'me',PF_HAND_CAP - $slow)`), J (`endRound`), H text ("Your hand is redrawn every round"), tests. Depends on T8.
- Test first: a new fight whose hand piece X was not played has X in the discard after the round, and the hand has 5 (4 when tripped); `V1_294` keeps X. It fails before the change.
- Sims: chain is expected UP. More Hurt seen per turn; deck.md says composition is everything. Record it. Dead turns (`dead`) should FALL from 6-14% (rules.md); target under 6%. Hand pieces with no legal cell were 14-17%; add that counter to the tuner if it is cheap.
- Risk: with a deck of 14 the discard reshuffles every 2-3 rounds. Fine.

**T10. Aim total.** Size M. Files: P (new `pfb_aim_total`; `pfb_intent` stores `plan.tot` when `aimtot`; `pfb_play` gets a 6th param `bool $withAim=false` that adds `'aim'` to dry results; view `aim.tot`, `status.foe_block`), J (same), G (`pfight_preview_out` calls with `withAim` and returns `aim`), H (CREATURE AIM line prints "hits you for H (why: ...); your pieces it fires deal B to it"), tests. Default `aimtot`=1. Depends on T9.
- Test first:
  - a board where the aimed Hurt 4 piece links into a Sun and a creature Hurt 3: `tot.hp` equals the health actually lost when the round is played with no move of yours that touches it, `why` contains "Sun x2";
  - a board where its chain fires your Jab: `tot.bait > 0`;
  - after a placement on the aim cell, dry `aim.broken === 'cell'`.
  - It fails before the change.
- Acceptance metric (tuner counter `aimgap`): on creature turns with an unbroken aim, the mean |shown total - actual| < 1 health point. Exceptions: quick extra pieces and poison ticks are listed in `why`, not counted. Today mean shown/actual is 5.7/8.8 medium, 7.3/11.8 large.
- No balance change expected; chain ±3.
- Risk: CPU, one extra dry place per intent (cheap). Do NOT compute it inside `pfb_cell_preview`.

### Phase C: week 1 page and retune

Page tasks are serial among themselves (shared V): T11 -> T12. T11 can start right after T3 (it needs no flags).

**T11. Replay at most 5 s, tap to skip, reduced motion.** Size M. Files: `tools/pfboardv1_part.js`, `tools/build_pfboardv1.py` (replacements on `maybeReplay`: step, BAN, banner order, no "Your turn" before own chain, environment merged), the regenerated `game/assets/pfboardv1.js`, `tests/pfv1_charm.js` (expectations), and a new `tests/pfv1_replay.js` run from `pfv1_charm.sh`'s setup. Parallel with T4-T10.
- Test first, in a real browser with Playwright (as `pfv1_charm.sh`): after End turn on the 13-event replay seed (`pbox_v1_seed.php`), it asserts:
  - control returns in ≤ 5.2 s at 1x;
  - a board tap 0.5 s into the replay returns control within 0.4 s;
  - with `reducedMotion: 'reduce'` and no stored speed, the replay is skipped (≤ 0.6 s);
  - no "Your turn" banner shows before the creature's.
  - It fails today (14.5 s measured).
- Legit changes: `pfv1_charm.js:85` (the "Your turn" banner check) now expects the creature banner only; `pfboard.js` unchanged (checked by `--check`).
- Risk: the replay walks bars from snapshots, so a scale factor must also scale `afterLeave` and the bar walk. The chip/round spoilers (turnflow "shown too early") are not in scope.

**T12. Page for the week-1 rules.** Size M-L. Files: V and build replacements (gate on `V1.aside`, `V1.must`, `V1.freepass`, `V1.flip1`, `V1.team2>1`, `V1.onebar`, `V1.aimtot`, `V1.nowm`), G (`pfight_bar_html` one bar with a damage segment and a charm segment and the label "Bar 23 of 40: damage 15, charm 8"; the pass form merges into End turn: label "Pass" when nothing is placed and `freepass`; the result card text unchanged), `game/assets/pfv1.css` (bar segments), `tests/pfboard_v1_page.sh`, `tests/pfv1_flip.js`, `tests/pbox_v1_shots.js`, `tools/pfdemo_v1/views.js` (one bar). Depends on T10, T11 and T7 (box line).
- Changes:
  - hide `#pf-opts` (set-aside row) when `!V1.aside`, but keep it for a saved group;
  - lighting without must-link: pass `must=false` into `countCells` and base `mustLink`;
  - no `unflipPrev` and no "Flip used" when `!V1.flip1`;
  - Teamwork chip and hand source icon only when `team2>1`;
  - help sheet:
    - drop the Teamwork sentence and the "once a turn" flip text when off;
    - list only the environment kinds in this fight's deck;
    - add "A piece of the creature linked into your chain fires for the creature; Thornburst hurts whoever fires it" (rules.md's two hidden rules);
    - add "If its aim fires one of your pieces, your piece works for you";
  - aim chip: "Aims Snap: hits you for 9 (Sun x2, fires your Jab: 6 to it)", with the reasons folded behind a tap;
  - after placing, the plan line shows the dry `aim` ("its aim is broken: it will pick again" / "now hits 3");
  - creature guard on the status row;
  - "health" for the creature bar renamed to "bar" (rules.md item 3) in fight text.
- Test first (`pfboard_v1_page.sh`):
  - page data has `"aside":0`, `"freepass":1`, `"onebar":1`, and `aim` has `"tot":{`;
  - no `id="pf-pass"` button when `freepass`;
  - the preview answer holds `"aim":`.
  - `pfv1_flip.js`: flip piece A, pick piece B, flip B: both stay flipped.
  - All fail before.
- Legit changes:
  - `pfboard_v1_page.sh:64` (the v1 data regex gains keys);
  - `:77` `"flip":{"on":true,"used":true}` becomes `used:false`;
  - `pfv1_flip.js` auto-unflip expectations replaced (the auto-unflip stays tested on a `V1_294` fight seeded by `pbox_v1_seed.php` with an override, or is dropped and noted);
  - `pbox_v1_shots.js:96-97` team chip.

**T13. Week-1 retune and the full table.** Size M. Files: P and J constants only (`PFB_V1_BAR_MULT`, `PFB_V1_FOE_MULT`, `PFB_V1_ONEBAR_BAR`, boss Charm factor), `tests/pfboard_v1.php` section 10 numbers, CHANGELOG. Depends on T4-T12.
- Run the standard set plus `chain -8` for boss. Tune with `V1='{"bar_x":..,"foe_x":..}'` maps by size until:
  - chain at level 70-80 in every size;
  - 4 under: medium no lower than the current 36, large no lower than 67;
  - look ≤ 100% (stakes are week 2's job), health lost reported;
  - turns 6-8 (small: report the share of 1-2 turn fights, 24-25% today);
  - `dead` < 6%;
  - charm wins against large creatures > 0.
- Then bake the multipliers into the constants (and the JS copy) and re-run once to confirm.
- Report a before/after table (`base0` against week 1) incl. `real %`, `plyflip`, own-piece-at-start.
- Risk: one global multiplier per size cannot fix level bands (balance.md). Keep `PFB_V1_LEVEL` and touch only the size factors.

**CHECKPOINT 1 (Josh).** Before week 2. Josh plays 3-5 fights on the page with `pfight_v1` on: new rules, one bar, aim total, the 5 s replay. Read T13's table.
- Questions for Josh:
  - Is the one bar's charm ending right for rewards?
  - Is redraw better than clog?
  - Is the page calmer?
- Nothing in week 2 starts before his go.

### Phase D: week 2a, a board that lasts

**T14. Switches `keepmine`, `aimhit`, `useroot` (default OFF).** Size M. Files: P (`pfb_spend`: skip `by==='me'` when keepmine; when `useroot` spend only the root piece; `pfb_foe_turn`: the strike branch of D6c with an event `{by:'foe', strike:true, id, broke:bool, guard:int}`), J, H (show the strike event: "STRUCK: its Claw hit your Dodge on 2,1 (Dodge breaks)"), tests. Depends on CHECKPOINT 1.
- Test first:
  - with keepmine, a 3-chain of yours plus a creature piece leaves your pieces and removes the creature's;
  - with aimhit, your Swing on the aimed cell plus a Hurt aim of 6 removes the Swing, your health is unchanged, and no re-pick happens;
  - a Guard 7 on the cell survives a hit of 6;
  - a non-Hurt aim still re-picks.
  - It fails before the change.
- Parity: `pfengine_js.php` `v1chaos` adds the three switches to its random rule sets.

**T15. Board variant bake-off and decision.** Size M (CPU). Files: none in the repo except the default flip in P and J and CHANGELOG. Depends on T14.
- Run the standard set plus `CHOICE=1` on 5 configs: W1 (week 1 as shipped), A (`keepmine`), C (`aimhit`), A+C, B (`useroot`). Each config gets a quick `bar_x` sweep {0.9, 1.0, 1.15, 1.3} on chain at level, to compare at equal difficulty.
- Decision rule (written now, applied blind):
  - Pick **A+C** if, at its best `bar_x`:
    - chain at level is 70-80;
    - turns are 6-8;
    - own-piece-at-start ≥ 70% for look (today 54-60%);
    - `real %` ≥ W1 + 10 pp;
    - `dead` ≤ W1.
  - Else pick the best of C or A on `real %` that meets the first two.
  - Else keep W1 and report.
  - B is a control only and is never shipped.
- Then set the winner's defaults on, put its `bar_x` into the constants, re-run once, and update `pfboard_v1.php` defaults.
- Also look at stakes: look health lost should RISE toward 20-29% (design doc target 23-29%, difficulty.md). Look wins may drop below 100%: that is the point here, but not below 90% at level.

**T16. Page for the strike and the lasting board.** Size S-M. Files: V and the build script (replay step for the `strike` event: a crack on the piece; the aim marker over YOUR piece reads "it will strike this piece"; help text "Block its aim with a piece: a Hurt aim breaks that piece instead of hitting you; a Guard at least as strong holds"), `tests/pfboard_v1_page.sh`. Depends on T15 and T12.
- Test first: the page data of a seeded state with your piece on the aim cell has `aim.on` = your piece id, and the replay has a `strike` step. It fails before the change.

**CHECKPOINT 2 (Josh).** Bake-off table plus 3 fights on the page. Go or no-go for the class rules.

### Phase E: week 2b, one rule per class (engine serial T17 -> T18 -> T19 -> T20; page T21 after)

All of these sit behind `kinds` (default 0 until T22). The class comes from `$c['class']` (`pfd_foe_row`), and it is stored in the state at `pfb_new` as `$s['foe']['kind']`, so old states have none. Rule numbers are constants (`PFB_KIND_*`) in P and J. The rule text is a new column in `data/pf_class_base.txt` (`=Class|lean|rule text`; the parser ignores extra cells today), and the boss text is a constant.

**T17. Framework plus Boss "two turns" plus Bird "two aims".** Size M. Files: P (`pfb_intent`: for a boss, `plan.next` = piece key and name, value chosen by search on a copy after the aim lands, then forced next round; for a Bird, `plan.alt` = the best move on a different cell; `pfb_foe_turn`: a Bird tries plan, then alt, then re-picks; a boss forces `plan.next`'s piece), J, data column, tests.
- Test first:
  - a Bird with plan cell taken plays alt (no `reaim`);
  - a Bird with both taken re-picks;
  - a boss plays the `next` piece shown last round.
  - It fails before the change.

**T18. Water "current" plus Plant "grows".** Size M. Files: P (after the creature's placement: Water pushes one touching piece of yours away, reusing the wind push in `pfb_env_fire`, factored out into `pfb_push`; Plant: after its turn, place a Bramble env tile from `pfb_env_table()['pieces']['bramble']` on a free touching fitting cell, tagged `own`, max 1 out), J, tests. Event shapes reuse `env:'fire', kind:'wind', moved` and `env:'place'`, so the page already knows how to draw them.
- Test first: a Water creature's placement moves your adjacent piece by one; a Plant's turn leaves exactly one Bramble touching its piece. It fails before the change.

**T19. Beast "grudge" plus Critter "swarm".** Size S-M. Files: P (Beast: `foe.grudge` +1 when its plan is blocked or struck, max 3, its Hurt values x(1 + 0.25 x grudge) in `pfb_fire` for `by==='foe'`, reset when a hit lands; Critter: `pfb_foe_len` returns 2 and its tiles are scaled x0.6 at `pfb_new`), J, tests.
- Test first:
  - a Beast blocked twice hits for round(v x 1.5);
  - a Critter places 2 pieces a turn.
  - It fails before the change.

**T20. Reptile "venom trail".** Size M. Files: P (`pfb_spend`/`pfb_expire`: a creature piece of a Reptile that leaves marks `ter["x,y"]='venom'` with `ven` rounds = 2; `pfb_place` for `me` on venom: `me.poison` += 2, `poison_v` = max(…, 2); `pfb_end_round` decays venom), J, tests.
- Check: `ter` non-empty makes the mud checks run, and they look only for `'mud'`. Safe, but the parity test must cover it.
- Test first: a Reptile's used-up piece leaves venom, and your piece placed there poisons you for 2 rounds. It fails before the change.

**T21. Page for the class rules.** Size M. Files: V and the build script (two aim marks for a Bird; "then: Crush 14" under a boss aim; Grudge stacks chip; Swarm "+1" chip; venom cells drawn like the old ground cells (`drawGround` exists for 2.6.74 `ter`) with a new `venom` style in `pfv1.css`; creature card rule line in the pre-fight screen (G `pfight_html` pre-fight) and on `pfdeck_view.php:249`'s creature view), help sheet "This creature" row, `tests/pfboard_v1_page.sh` (one seeded fight per class: page data has `kind` and the rule text). Depends on T20 and T16.

**T22. Class retune, final sims, harness playtest, metric report.** Size L (mostly CPU and agents). Files: P and J (`kinds` default 1, `PFB_KIND_*` numbers), CHANGELOG, `tests/pf_play.php` (show the class rule line and the struck/next/alt lines), a new `scratchpad/plan/hk2/brief.md`. Depends on T21.
1. Sims:
   - standard set plus `CLASS=1` aggregation;
   - per class, chain at level 70-85 and within 10 pp of each other (today Bird 72 to Plant 92);
   - rule fires ≥ 1 per fight on average (count from the events);
   - look not above about 97% unless T15 already set stakes;
   - turns 6-8;
   - `real %` ≥ T15 value + 5 pp; report `plyflip`;
   - tune only `PFB_KIND_*`, never search.
2. Full bot sim table: chain 0/-4/-8, look 0/-4, smart 0, by size and by class, with `real`, `dead`, own-piece-at-start and `aimgap` columns, against `base0`, W1 and T15.
3. Playtest:
   - 30 fights through the fixed harness (T1), with `scratchpad/hk/assign.json`'s slugs, levels, offsets and seeds;
   - styles: replace `setaside` and `flipper` with `blocker` (block or bait the aim) and `classread` (name the creature's rule after turn 2), keep the others;
   - new brief from `scratchpad/hk/brief.md` minus join/add/group;
   - report JSON fields unchanged, plus `"creature_rule_noticed": "text"` and `"aim_total_matched": "yes|no + numbers"`.
   - Run by haiku agents, one fight each, as before.
   - Compare with r1-r30: fairness mean (3.2 of 5 before; target ≥ 3.8), count of "dull" moments, count of "aim unfair" notes (10 reports before), count of reports that can name the creature's rule (target ≥ 20 of 30).

**CHECKPOINT 3 (Josh).** Final table plus playtest summary, then real phones with five real people (critique section 10).

---

## 5. Order and parallel lanes

| Lane | Tasks (serial within a lane) | Shared files |
|---|---|---|
| Engine | T3 -> T4 -> T5 -> T6 -> T8 -> T9 -> T10 -> [CP1] -> T14 -> T15 -> T17 -> T18 -> T19 -> T20 -> T22 | `pfboard.php`, `pfengine.js`, `pfight.php` (T8 only), `tests/pfboard_v1.php`, `tests/pfengine_js.php` |
| Page | T11 (from T3 on) -> T12 (after T10, T7) -> T13 -> [CP1] -> T16 (after T15) -> T21 (after T20) | `pfboardv1_part.js`, `build_pfboardv1.py`, `pfight_game.php`, `pfv1.css` |
| Box/kits | T7 (after T2's baseline is saved) | `pfdeck.php`, `pfdeck_view.php`, `pfv1box.js`, demo `pfd.js`/`views.js` |
| Harness/tuner | T1 and T2 first (parallel with each other); T22's harness edits later | `pf_play.php`, `pfboard_tune_v1.php` |

T13 waits for both lanes. One agent at a time per lane. `tools/pfdemo_v1/views.js` is touched by T7 and T12, so T12 goes after T7. Every engine task that changes defaults must run the 4 suites plus parity before handing back.

## 6. Do NOT build

- **Smarter creature search** (2-ply, lookahead, reading your reply): "A real 2-ply creature gains nothing that can be measured (every cell within ±3 pp)" (strategy.md).
- **Creature combine / set-aside for the creature:** the careless bot -8 to -18 pp, careful players WIN MORE EASILY (strategy.md, task B).
- **Flat per-size bar or foe changes to fix level walls:** "Every bar or foe cut big enough to help L8 pushes L10 to 83-91%" (balance.md). Use `PFB_V1_LEVEL` only.
- No cell reply numbers on lit cells (Josh). The aim total sits on the aim and in the plan text only.
- No new player pieces, collection hooks, pal or Trick reworks, or deck cap in these two weeks. They are valid (deck.md recs 2, 3, 5, 6, 12, 13), but they are the deck layer the critique says to freeze.
- No softer environment numbers (`env07`: wins barely moved, fights 9-10 turns). No removal of Sun-for-both-sides (rules.md "do not change").
- No removal of use-up for the creature or the environment (fights 3.4-5.2 turns, 98-100% without it).
- Do not delete Wind, Mud, set-aside or two-bar code paths: saved fights and `V1_294` parity need them. A later cleanup can remove them once no 2.6.94 fight can be in progress.
- Do not edit `game/assets/pfboard.js` or `game/assets/pfboardv1.js` by hand (generated or frozen).
- Free discard (D3 picks redraw). The Flip button folded into lit cells (turnflow rec 9) and the 27 px End turn shift are polish for later.

## 7. Risks and open points

- **Pass, redraw and one bar all make the game easier** for the careless bot. T13 is where that is paid back. If chain goes over 90% after T8 or T9, stop and tell Josh before T13.
- **The tuner gnome is synthetic** (`tv_sources`), and T7 changes it (kits rotate by level). Every comparison after T7 is against T7-or-later runs, never `base0` alone.
- **Wind and Mud removal shrinks the environment deck** by 2 of 8 to 2 of 10 pieces depending on size. Bramble and Thornburst come more often, and Bramble already gives 9-26% of the bar. Watch the env cost line from T4.
- **Boss Charm under one bar** may make bosses trivially charm-able in damage terms. A boss can never end "charmed", and T13 may lower boss `cm`.
- **The real-choice metric is new and bot-defined.** Its thresholds (10% of span, span ≥ 0.02 in `tv_value` units) are a first guess. T2 must print the distribution of the gap/span ratio so Josh can see where 10% sits.
- **Saved fights** with a held set-aside group, a used flip or two bars must play out. Each switch task carries a test on a json round-tripped state with the keys removed.
- `pfengine_js.sh` covers the default rule set (`v1`, `v1d`) and `v1pre` from T3 on. Any parity failure blocks the lane.
- Not verified by this planner: timing of tuner runs at MULT 1 on this box (4 cores), and the page code paths in the Trail pop-up.

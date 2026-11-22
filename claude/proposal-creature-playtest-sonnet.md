# Proposal: Sonnet playtest of puzzle combat against all 319 creatures (2026-11-21)

Status: PROPOSAL ONLY. Nothing here has been run; no game code changed. Needs Josh's go-ahead, and his explicit opt-in for the Workflow script in section 4.

## 1. Goal, and what Sonnet adds over the bots

The 2.7.10 bots (`tests/pf_bots.php`, report `claude/bots-report-2.7.10.md`) measure win %, turns, turn-cap % and health lost. They cannot say *why*. A Sonnet tester playing like a careful new player adds judgement:

- **Clarity**: which line of the fight text, class rule (`CLASS RULE:` line) or creature piece it misread, and on which turn.
- **Fairness**: did a loss feel earned, or come from a hidden reply, a forced self-hurting move, an environment piece, or a hand with no real choice.
- **Fun**: dull turns (one legal move), swingy turns (luck decided it), fights that drag past the size target.
- **Dominant strategies**: "always do X" plans that win without reading the board (the bots only play their fixed rule).
- **Rule confusion vs tune**: a loss where the newbie bot wins is a text problem, not a tune row problem. The bots cannot tell these apart.

Non-goal: setting tune numbers. Retunes stay on the chain-bot fit (`claude/balance-2.7.08-notes.md` section 2). Sonnet flags; bots measure.

Prior art: the 2.6.60 / 2.6.63 haiku rounds (`claude/pf-playtest-plan.md`, `claude/pf-agents/pf-playtester.md`, data in `docs/playtest-data/`). Lessons kept: agents report non-bugs as bugs, improvise "random" play, and under-use options `show` does not list. That agent file is stale (7x5 board, 2.6.60 rules); write a new one.

## 2. How one Sonnet tester plays one fight

Harness: `tests/pf_play.php` (CLI, no DB, no server; verified 2026-11-21: `php tests/pf_play.php new S.json grass-snake 14 7 v1` prints a 4x4 board, about 3.8 KB of text). Mode `v1` = the live v1 rules with the blank opening and environment pieces. Region left empty: the harness picks it as the bots do (`crc32(slug)+seed) % 14`).

Per fight, run from `/home/user/gnome-venture`, STATE in the run folder:

```
php tests/pf_play.php new   $RUN/$SLUG-f1.json $SLUG $LEVEL $SEED v1 [REGION]   # prints the board, hand, legal cells with per-cell numbers
php tests/pf_play.php start $RUN/$SLUG-f1.json HANDIDX SIDE                      # hidden opening, SIDE = L R T B
php tests/pf_play.php flip  $RUN/$SLUG-f1.json HANDIDX                           # free, once a turn
php tests/pf_play.php place $RUN/$SLUG-f1.json HANDIDX X Y                       # one action a turn
php tests/pf_play.php pass  $RUN/$SLUG-f1.json                                   # only when nothing fits
php tests/pf_play.php show  $RUN/$SLUG-f1.json
```

(`join` / `add` / `group` only when `show` lists them; set-aside is out of a new v1 fight.) Every action is appended to `STATE.log` (one json line), which is the replay record for bugs.

What the tester sees: only the harness text (bar, HP, guard, creature intent and AIM, board, environment NEXT pieces, class rule, piece list with life and source, hand with legal cells and `d c h n` previews, WHAT HAPPENED events). The creature's hand and draw pile are never printed.

Rules for the tester (put in the agent file `claude/pf-agents/pf-sonnet-tester.md`, model `sonnet`, tools Bash + Write only):
- Never read engine source, `game/`, `tests/*.php`, or the STATE json (it holds the creature's hand and draw pile: hidden information). Only harness output.
- Play to win as a thoughtful first-time player: read the text, make a plan, one command at a time; write a one-line reason per move into the report's `moves` notes.
- Stop at `FIGHT OVER`. Engine turn cap is `PF_TURN_CAP = 24` (`game/includes/pfight.php:34`, result `stall`). Agent cap: 40 commands per fight (refused moves count); past it, result `abandoned`.
- A refused move (exit 2, `REFUSED:`) changes nothing: read the reason, count it in `refused`.

## 3. Matrix per creature (3 fights, 957 total)

| fight | gnome level | build | play intent | seed index k |
|---|---|---|---|---|
| F1 | = creature level | std | win | 0 |
| F2 | creature level - 4 (min 1) | std | win | 1 |
| F3 | = creature level | rotates by creature index mod 3: `pals`, `norare`, `charm` | win (`charm` = std deck, aim to fill the charm bar; a boss has no charm, so a boss gets `pals`) | 2 |

- Why -4, not the bots' -8: the human script (bots report, step 5) and the 2.7.08 fit policy ("a gnome 4 levels under them is not lost") use 4. The bots already cover -8 / +8 cheaply.
- `charm` is a bot *playstyle* in `tests/pf_bots.php`, not a deck build (`PB_BUILDS = std, pals, norare`); here it is a play intent on the std deck.
- Seeds: the pf_bots formula, so Sonnet and bots get the same creature row and region: `SEED = 500 + 13*k + CREATURE_LEVEL + 1000*(crc32(slug) % 97)` (`tests/pf_bots.php:189`). Caveat: `pb_fight` calls `mt_srand($seed)` before `pfd_foe_row`, `pf_play.php` does not; confirm in the pilot that the opening hands match, else add the `mt_srand` to the harness.

### Harness prerequisites (test tooling only, no game code; each with a regression test in `tests/pf_play_decks.sh`)

1. **The 231 variants**: `pf_play.php` (`pp_creatures`) and `tests/pfboard_tune_v1.php` (`tv_creatures`) read only the 88 rows of `game/includes/data/creatures.txt`. Verified: `pf_play.php list 400` prints 88; `new ... fly-swarm ...` exits "unknown creature". The 319 live in `game/includes/data/pf_creatures.txt` (`pfd_creature_rows()`, `game/includes/pfdeck.php:115`; 88 families; sizes small 67 / medium 146 / large 95 / boss 11). The 2.7.08 refit did this in a scratch `fit.php` that is not in the repo. Add a shared loader for both.
2. **BUILD argument**: `pf_play.php` deals only the std deck (`pp_player`). Add an optional build (`std|pals|norare`) reusing `pb_player()` from `tests/pf_bots.php`.
3. **Bot baseline on 319**: after (1), `php tests/pf_bots.php chain,look,newbie,charm 0,-4 3 std,pals,norare $i/8 json` for `i=0..7`, then `php tests/pf_bots.php agg < all.jsonl`. Same seeds as section 3.

## 4. Batching, parallelism, cost

- **Unit**: one Sonnet agent per creature, plays F1-F3 in order (sees its own earlier fights: useful for "did I learn the creature" and dominant-plan notes), writes one report file.
- **Order**: waves of whole families (base + variants together, 88 families), sorted by size then home region, about 20 creatures a wave, 16 waves. Bosses (11) in one wave so one synthesis pass compares them.
- **Parallelism**: 10-20 agents at once (the harness is stateless PHP per call; STATE files are per agent, so no clash). Each agent gets its own folder: `$RUN=/tmp/.../scratchpad/pfs/<slug>/` (scratch, not the repo).
- **Tokens (estimate, measure in the pilot)**: about 15-25 commands a fight, each about 1-1.5 k tokens of output plus reasoning; context reaches roughly 100-150 k by F3. Per creature about 3 M input tokens (mostly cache reads) and 30-40 k output. At Sonnet 5.5 rates ($2 / $10 per MTok, cache reads $0.10) that is roughly $0.7-1.2 a creature, **about $250-400 for all 319**, plus one synthesis pass. Wall time about 20-30 min per agent: 16 waves x 20 parallel = about 6-8 hours.
- **Workflow script (only with Josh's explicit opt-in)**: a Workflow would (a) read the creature list, (b) compute level / build / seed per fight, (c) spawn the Sonnet tester per creature with a fixed prompt, wave by wave, (d) validate each report against the schema and re-run a creature once on invalid JSON, (e) run the aggregator. Without opt-in: the same, dispatched by hand as Agent calls, a wave per turn.

## 5. Report schema (one file per creature: `pfs/<slug>.json`)

```json
{
  "slug": "", "family": "", "size": "small|medium|large|boss", "creature_level": 0,
  "fights": [{
    "id": "F1", "gnome_level": 0, "build": "std|pals|norare", "intent": "win|charm", "seed": 0, "region": "",
    "result": "seen_off|charmed|defeat|stall|abandoned",
    "turns": 0, "hp_left_pct": 0, "refused": 0, "longest_chain": 0,
    "fair_1_5": 0, "fun_1_5": 0, "difficulty": "too_easy|right|too_hard",
    "why_lost_or_won": "1 sentence",
    "dull_or_swingy_turns": ["turn N: what"],
    "confusing": [{"turn": 0, "text": "exact quoted line", "what_i_thought": "", "what_happened": ""}],
    "bugs": [{"command": "exact", "output": "exact quote", "expected": ""}],
    "moves": ["turn N: command | reason"]
  }],
  "creature": {
    "fair_1_5": 0, "fun_1_5": 0,
    "dominant_strategy": "plan that wins without reading the board, or none",
    "class_rule_clear": true, "class_rule_note": "",
    "tune_suspect": "too_hard|too_easy|swingy|none", "tune_note": "1 sentence, with the fight ids"
  }
}
```

Quote output, never invent numbers. `turns`, `result` and `hp` are cross-checked against `STATE.log` by the aggregator (the log is ground truth).

## 6. Triage

Aggregator (a small PHP script, scratch or `tests/`): joins each report with the bot rows (same slug, offset, build) and the tune row in `game/includes/data/pf_creature_tune.txt` (slug|foe_x|bar_x; missing = 1.0 / 1.0). Output: one table per size, then a flag list:

| flag | rule | goes to |
|---|---|---|
| RETUNE-HARD | Sonnet loses F1 or F2 AND chain bot at offset 0 under 60% (size targets small 83 / medium 85 / large 68 / boss 78) | chain-bot refit of that row |
| RETUNE-EASY | Sonnet wins F2 (-4) with over 60% health left, says too_easy, AND look bot over 98% | refit (lower bar_x or raise foe_x) |
| CLARITY | Sonnet loses where the newbie bot wins 80%+, or the same `confusing` text in 3+ creatures | harness / page text fix, not the tune |
| BUG | any `bugs` entry that replays from `STATE.log` | `bug-report`, regression test first |
| DOMINANT | same `dominant_strategy` in 10%+ of creatures, or across a whole class | design note for Josh |
| TUNE-ROW | `tune_suspect` set on a row at a fit clamp (foe_x 0.42 / 3.1, bar_x 0.52 / 2.15; e.g. `ant-scouts 2.909`) | refit, check deck instead (as 2.7.08 did for skitter / midge) |
| CLASS | a class rule rated unclear in 3+ of its creatures | `PFB_KIND_TEXT` wording |

Three fights per creature is noise for win rate: a flag needs Sonnet AND the bot data to agree, or a repeated text finding. Never retune from Sonnet alone. After a retune: the bot run again, plus a Sonnet re-run of only the flagged creatures.

## 7. Risks, questions, rollout

Risks
- **Harness text is not the page text**: the CLI shows per-cell previews (`d c h n`) the live page may show differently. Clarity findings about harness wording must be split from page wording (tag each `confusing` item `harness|rule`).
- **Not the live progression**: `pf_play` runs full v1 rules; learner fights 1-3, staged rules (Thornburst from gnome level 5, `pfight_thorn_level`), wearables and Keepsakes are not modelled. Early-game feel still needs the human script (bots report, "Human playtest script").
- **Hidden information leak**: the STATE json holds the creature's hand. The prompt forbids reading it; check `STATE.log`-adjacent tool calls in the pilot, or wrap the harness so state lives outside the agent's folder.
- **Sonnet plays better than most people**: treat its win rate as near the look bot, not a new player; the newbie bot is the low baseline.
- Cost and time overrun if fights run long; the 40-command cap and the pilot's measured tokens bound it.

Open questions for Josh
1. OK to make the three test-only harness changes in 3.x (variants, BUILD, bot run on 319)?
2. Offsets: 0 and -4 enough, or also +4?
3. Budget: about $250-400 for the full run acceptable? Workflow script, or hand-dispatched waves?
4. Should the tester also get the page's rules card / "New today" text as its only primer (closer to a real player), or learn only from the harness?
5. Where do results live: `docs/playtest-data/round3-2.7.47.tar.gz` (as rounds 1-2) plus a report in `docs/`?

Phased rollout
- **Phase 0 (no Sonnet)**: harness prerequisites + tests; bot baseline on 319; write `claude/pf-agents/pf-sonnet-tester.md`.
- **Phase 1 pilot, 10 creatures (30 fights)**: bot outliers both ways and every size, base and variant: `cloud-leopard`, `frost-hare`, `gnat-cloud` (bot 0%); `aphid-swarm`, `garden-snail`, `honey-badger-brute` (bot 100%); `great-hawk`, `snow-owl-monarch` (bosses); variants `fly-swarm` (small L12), `tide-crab-paladin` (large L30). Measure tokens, minutes, invalid reports, false bug reports; fix the prompt and harness text; confirm seeds match the bots.
- **Phase 2**: one wave (about 20 creatures, one size) to test the aggregator and flags.
- **Phase 3**: remaining waves; synthesis report; retune list goes to the chain-bot fit, text list to the page.

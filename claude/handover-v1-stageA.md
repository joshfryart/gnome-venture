# v1 board rules, stage A handover (2.6.74 build; engine only)

Stage A put the v1 puzzle-combat BOARD RULES into the real game, behind the admin setting `pfight_v1`. Not done here (later stages): data and deck model (B), page UI (C), version bump, changelog, zip (D). Version is still 2.6.73.

Design sources: `claude/design-board-strategy.md` (DECIDED blocks, "Sim results 3", "Sim 4", "Player-facing terrain text"), `claude/design-deckbuilder-combat.md` ("Authored edges"). The rules were ported from the approved demo (`tools/build_pf_demo_v1.py` patches, `tools/pfdemo_v1/`) and the PHP sim copy (`tools/pfsim/v1bundle/`).

## The flag
- Setting `pfight_v1` (`includes/functions.php`, admin settings): `0` Off (default), `admin` Admins only. The code also reads `1` as everyone (`pfight_v1_on()` in `pfight_game.php`); that option is not offered in the settings yet.
- It works inside `pfight_open` (the fight has to be a puzzle fight at all). With it on for a gnome, a NEW fight is ALWAYS a board fight, whatever `pfight_mode` says.
- `pfb_new($me, $c, $seed, ['v1' => true, 'blank' => ...])` starts a v1 fight. `'v1' => [...]` may switch single rules (tests, sims): see `pfb_v1_cfg`.
- **Save migration:** a v1 fight carries `$s['v1']` (its rule numbers). A fight without that key plays exactly the old rules, so fights under way keep their rules when the flag changes either way. Flag off = no new state keys, no new tile fields, same events (old tests and the JS parity traces are unchanged).

## Rules built (all in `game/includes/pfboard.php`, mirrored in `tools/pfengine.js`)
| # | Rule | Where |
|---|---|---|
| 1 | Board size by creature size: small 5x4, medium 5x5, large 7x5, boss 7x6 | `PFB_SIZE`, `$s['w']`, `$s['h']`, `pfb_w($s)`, `pfb_h($s)` (every loop and the centre) |
| 2 | Ground: sunny x2 (Hurt and Charm), bramble 10% of max health per terrain turn, mud blocks links. 1-2 steps from the centre, counts by size, both sides | `pfb_seed_ground`, `pfb_ter`, `pfb_fire` (sunny), `pfb_check` / `pfb_links` / `pfb_group_cells_l` (mud), `pfb_env_turn` (bramble) |
| 3 | Terrain turn after the creature's turn; events forecast one round ahead: sunbeam, bramble creep, puddle, gust, thorn burst (1 a round small, 2 others). Thorn burst on creature pieces halved. Order: events land, bramble pricks, then old pieces expire | `pfb_forecast` (called in `pfb_intent`), `pfb_env_turn` (top of `pfb_end_round`), `pfb_env_events`, `pfb_env_line`, `pfb_ground_set` (cap: the oldest cell of a kind goes) |
| 4 | Use-up: a chain that fires 3+ pieces removes every piece that fired, both sides, to the owner's discard | `pfb_fire` (`$s['fired']`), `pfb_spend` |
| 5 | Aim: the creature's next piece and cell, chosen at the end of the round, stored, shown, played. Cell taken or piece gone: it picks again at full value (no fumble). Lit-cell numbers: own chain only, no reply number | `pfb_intent` (`$s['foe']['plan']`), `pfb_foe_turn`, `pfb_cell_preview` |
| 6 | Teamwork: your pieces in a chain you start come from 2 of pal / tool / crop: +30%; all 3: +60% | `pfb_fire`, tile field `src`, `pfb_src` |
| 7 | Authored edges instead of the crc32 hash. Left hole = type family, right knob = `r` (type family when a piece has none), top and bottom = one knob and one hole of the column family (pals body, tools craft, crops mind, crafts craft, others their type family). Hurt, Charm, Trick carry the knob on top. Creatures: 3 pieces in 5 (deck order) use the lean family | `pfb_author_edges`, `pfb_v1_tile`, `pfb_v1_tiles`, `pfb_lean`, `pfb_edges` (uses tile `ed`; no `ed` = old hash) |
| 8 | Flip: once a turn, free, swap top and bottom of a hand piece; flipping the same piece back gives the flip back; it stays flipped on the board and comes back unflipped | `pfb_flip`, `pfb_can_flip` |
| 9 | Piece life per piece, 2-4 rounds, default 3 (Quick pieces 2, Hold pieces 4 unless the piece says otherwise) | `pfb_life`, tile field `life` |
| 10 | Creature values and bars by size | `PFB_V1_FOE_MULT`, `PFB_V1_BAR_MULT` |

## Constants (PHP names; the JS has the same)
`PFB_SIZE`, `PFB_GROUND` (sunny / bramble / mud: 2/2/1, 3/2/1, 3/3/1, 4/3/1), `PFB_GROUND_DIST` [1, 2], `PFB_EVENTS` (1, 2, 2, 2), `PFB_EVENT_KINDS`, `PFB_EVENT_NAME`, `PFB_USEUP` 3, `PFB_SUN_MULT` 2.0, `PFB_BRAMBLE` 0.10, `PFB_BRAMBLE_FOE` 1.0, `PFB_THORN` 0.10, `PFB_EVENT_FOE` 0.5, `PFB_TEAM2` 1.3, `PFB_TEAM3` 1.6, `PFB_TEAM_SRC`, `PFB_SRC`, `PFB_SRC_FAM`, `PFB_UP`, `PFB_CLASS_LEAN`, `PFB_LIFE_MIN` 2, `PFB_LIFE_MAX` 4, `PFB_V1_BAR_MULT` 1.12 / 1.12 / 1.12 / 0.88, **`PFB_V1_FOE_MULT` 0.72 / 0.54 / 0.56 / 0.62**.
Unchanged and still applied in v1: `PFB_LIFE` 3 (default), `PFB_FOE_FIRES` 2, `PFB_FOE_FIRE_MULT` 1.15, `PFB_BOSS_MULT` 1.2, `PFB_BLANK_FOE_MULT` 1.0, set-aside groups.

## Retune (real engine, 88 creatures, `tests/pfboard_tune_v1.php`, about 210 fights per cell, noise about 4 points)
The demo's JS numbers (0.72 / 0.53 / 0.41 / 0.46, 9 demo creatures) were too soft on the real creatures for large and boss (chain bot 90% and 94%). Retuned: large 0.56, boss 0.62, medium 0.54, small kept.

| Bot | Level | small | medium | large | boss |
|---|---|---|---|---|---|
| chain | at level | 74 / 56 / 5.0 | 69 / 64 / 6.6 | 70 / 68 / 7.4 | 71 / 68 / 8.5 |
| chain | 4 under | 75 / 53 / 3.3 | 34 / 85 / 6.1 | 41 / 84 / 7.6 | 63 / 76 / 8.6 |
| chain | 8 under | 75 / 53 / 3.3 | 24 / 89 / 4.6 | 21 / 93 / 6.9 | 31 / 90 / 8.6 |
| look | at level | 96 / 20 / 5.9 | 97 / 22 / 7.5 | 97 / 23 / 7.7 | 100 / 21 / 7.8 |
| look | 4 under | 99 / 19 / 3.5 | 78 / 43 / 9.5 | 89 / 36 / 10.1 | 96 / 30 / 9.1 |
| look | 8 under | 99 / 19 / 3.5 | 61 / 57 / 8.8 | 69 / 55 / 10.8 | 93 / 39 / 10.8 |
| smart | at level | 100 / 15 / 4.5 | 100 / 13 / 6.0 | 100 / 15 / 6.1 | 100 / 13 / 6.5 |
| smart | 4 under | 100 / 16 / 3.0 | 98 / 23 / 8.0 | 100 / 20 / 7.6 | 100 / 17 / 6.8 |
| smart | 8 under | 100 / 16 / 3.0 | 91 / 34 / 8.5 | 94 / 31 / 9.6 | 100 / 24 / 8.4 |

Win % / health lost % / turns. Targets: chain about 70% at level (met: 69-74), smart 90% or more (met: 100), 6-8 turns (small 4-5): chain 5.0 / 6.6 / 7.4 / 8.5, smart 4.5 / 6.0 / 6.1 / 6.5. Deck: the default sim gnome with made-up sources (1 pal, 2 tool, 2 crop). Re-run after stage B gives real decks and creature layers: `php tests/pfboard_tune_v1.php chain 0` (15 s), `look`, `smart` (2 minutes per level on 4 shards: 5th argument `i/4`, 6th `json`).

## State fields (only in a v1 fight)
- `$s['v1']`: the rule numbers: `ground, nsun, nbr, nmud, sun, bramble, br_foe, events, nev, thorn, ev_foe, limit, aim, team2, team3, edges, flip, life, foe, bar`.
- `$s['w']`, `$s['h']`.
- `$s['ter']`: `"x,y" => 'sun' | 'br' | 'mud'`, oldest first.
- `$s['envs']`: the forecast, `[['kind' => sunbeam|creep|puddle|gust|thorn, 'x', 'y', 'dir' => L|R|T|B or null]]`.
- `$s['envlog']`: what the last terrain turn did, `[['k', 'x', 'y', 'me' => health you lost, 'foe' => bar points, 'dir', 'moved' => [id, by, n, x, y], 'on' => [id, by, n], 'ids' (bramble)]]`.
- `$s['foe']['plan']`: the aim, `['k', 'n', 't', 'v', 'tag', 'x', 'y']` or null (tripped, no move). `$s['reaim']`: 1 when it could not play its aim last turn.
- `$s['me']['flipt']`: the turn in which the flip was used (0 = free). Tile `flip` (true while flipped), `ft` (turn it was flipped in).
- Tiles (both sides): `src`, `life`, `ed` (the four authored edges). Optional authoring fields a tile definition may carry (passed through by `pf_make_tile`): `src`, `life`, `col` (column family), `up` (knob on top), `edges` (all four edges, or `false` = keep the hashed edges).
- Temporary inside a turn: `fired`, `firedby`, `aimforce`. Spent pieces carry `used` (whose chain used them up); it shows in `$s['gone'][]['used']`.

## Events (what `pfb_play` / `pfb_pass` return)
- Every event has `ta`: `me`, `foe` or `env`.
- Piece events gain `sun` (1: fired on a sunny cell), `tw` (1.3 / 1.6: Teamwork). The first event of a chain gains `used` (ids the chain used up).
- Terrain events come after the creature's: `['by' => 'env', 'ta' => 'env', 'env' => kind or 'bramble', 'k' => 'env:kind', 'n' => name, 't' => 'env', 'x', 'y', 'me', 'foe', 'dir', 'moved', 'on', 'ids', 'barnow', 'fhnow', 'hpnow', 'gnow']`. `pfight_line` gives the log line, `pfight_chip_event` a chip with `by` `env`; `pfight_chips_board` skips them. The replay list in the encounter (`$enc['replay']`) carries them with `ta` `env`, `id` null.

## API and actions for the UI stage
- **Flip:** POST `do=pfb_flip`, `hand=<index>`, `turn`, `nonce` (wired in `adventure.php` and `pfight_do`). Free: no creature turn, the last replay stays. Engine: `pfb_flip($s, $handIdx, $turn)` returns an error or null; also the move `['f', handIdx]` through `pfb_play` (returns `'free' => true`). Allowed during the opening (the start piece can be flipped).
- **Lit-cell numbers:** POST `do=pfb_cells` as before. In a v1 fight each cell is `['dmg', 'ch', 'hp', 'n', 'used', 'tw', 'sun', 'end']` (no `rp`), and the answer has a second map `flipped` (the same numbers with the piece flipped; empty when it may not be flipped). Engine: `pfb_cell_preview($s, $handIdx, $flip = false)`.
- **View** (`pfb_view`, also copied into the page's `#pf-data`: `v1`, `round`, `ter`, `envs`, `envlog`, `aim`, `reaim`, `flip`):
  - `v1`: `limit, sun, bramble, br_foe, thorn, ev_foe, team2, team3` and the switches `ground, events, aim, flip, life, edges` (for the help text and legend).
  - `ter`, `envs` (each with `n` = name and `on` = the piece on the mark), `envlog`, `aim`, `reaim`, `flip` = `['on', 'used']`, `w`, `h`.
  - `pcs[]`: plus `life`, `left` (rounds it still stays, this one included; 1 = it goes at the end of this round), `src`, `flip`, `ter`. `hand[]`: plus `life`, `src`, `flip`, `canflip`. `held.pcs[]`: plus `life`, `src`, `flip`. `gone[]`: plus `used`.
- `pass` is refused while a piece would fit flipped ("You still have a piece that fits somewhere when you flip it.").
- Player-facing words for ground, events, aim and chains: `claude/design-board-strategy.md`, "Player-facing terrain text".

## Tests (all pass)
| Test | What |
|---|---|
| `bash tests/pfboard_v1.sh` | 108 checks: flag-off parity (same fight with and without the opt, whole old fight, save and load), each rule and each rule switch, flip, use-up, terrain, events, Teamwork, size, life, 176 whole v1 fights with invariants. Nine engine mutations were run against it; each fails at least one check |
| `bash tests/pfboard_v1_page.sh` | 33 checks on the page: gating (unset, admin setting with a non-admin and an admin), a fight under way keeps its rules, page data, `pfb_flip`, `pfb_cells`, a whole v1 fight, no PHP warnings |
| `bash tests/pfengine_js.sh` | JS port = PHP over 528 fights, 16986 actions (352 old fights as before, plus 176 v1 fights with flips, random rule switches, made-up sources, authored overrides) |
| Old suites | `pfboard_fixes`, `pfboard_sim`, `pfboard`, `pfboard_js`, `pfight`, `pfight_sim`, `pfight_js`, `pfmap`: unchanged and passing |

Both new suites are in `tests/ci_suites.sh` (self-installing list) and `.github/workflows/ci.yml`.
Harness: `php tests/pf_play.php new STATE SLUG LEVEL SEED v1` (or `v1classic`), new command `flip STATE HANDIDX`. `show` prints ground on the grid, the aim, the forecast, life, source, flipped cells and USES-UP / TEAM / SUN marks; terrain events and used-up pieces appear under WHAT HAPPENED.

## Known gaps
1. **No v1 page UI.** `game/assets/pfboard.js` and `pfight.css` are untouched. With the flag on, an admin gets a working board of the right size and can play, but ground, forecast marks, the aim, the flip button, life labels and terrain replay steps are not drawn (the data is in `#pf-data`). Terrain events reach the old replay as entries with `by` `env`; how `pfboard.js` treats them was not checked in a browser. History chips for terrain have class `pf-chip env` with no CSS yet.
2. **No real sources, classes or authored pieces yet** (stage B). Every existing piece gets a default: base six `basic`, calling piece `calling`, `pal:` pieces `pal`, `f:` pieces `creature`, the rest `knack`. So Teamwork can only fire through pal pieces until tools and crops exist. Creatures have no class column: the lean comes from `$c['lean']`, else `$c['class']`, else a hash of the slug. The creature decks are still the old size/temper archetypes, not the layered decks; the demo's creature-side tags (pierce, poison on you, quick, trip, bash) are NOT ported.
3. **The aim often does not happen.** The creature re-aims 1.7-4.2 times a fight (chain bot). With authored edges there are no flat joints, so a new neighbour makes the aimed piece illegal more often than in sim 3. Free for the player; may read as a wrong forecast.
4. **Balance was measured with made-up sources and the old creature decks.** Retune after stage B. Medium and large creatures under level are hard for the chain bot (34% / 41% at 4 under).
5. `tests/pfboard_tune.php` (old greedy table) was not changed; it measures the old rules only.
6. The JS `cellPreview` covers v1 fights only (the old numbers were never in the JS port).
7. `tools/build_pf_demo_v1.py` now builds the demo from `tools/pfengine.js` as of commit 614072fc (the pre-port engine), because its patches no longer apply to the ported file. The built demo is byte-identical to `claude/mockups/pf-demo-v1.html`.
8. Treks still use the old fight. MySQL, a phone and a human play session were not run. Full CI was not run; only the puzzle-fight suites.
9. Luck redraw (`pf_redraw`) is not in the JS port (it never was), so it is outside the parity test; in PHP it unflips the piece it discards.

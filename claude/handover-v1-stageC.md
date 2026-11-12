# v1 puzzle combat, stage C handover (2.6.74 build; the in-game UI)

Stage C built the real pages for the v1 puzzle combat, behind the admin setting `pfight_v1` (stage A's flag, default off). Not done here (stage D): version bump, release notes, zip. Version is still 2.6.73.

Stage A (board rules): `claude/handover-v1-stageA.md`. Stage B (data, deck model): `claude/handover-v1-stageB.md`.
Ported from the approved references: `claude/mockups/deckbuilder-ingame.html` (box, starter, pre-fight, result) and `tools/pfdemo_v1/` (fight: ground, forecast, aim, flip, faded hand, harmony, texts).

## Flag and parity
- Everything is inside `pfight_on($u) && pfight_v1_on($u)` (`pfv_on` in `pfdeck_view.php`). With `pfight_v1` off (or `admin` and a player who is not an admin) the pages are byte for byte the pages of commit `ba9c416c` (the commit before stage C): `tests/pbox_v1.sh` installs that commit next to the working copy and diffs `puzzlebox.php`, `gnome.php?tab=gnome`, `gnome.php?tab=stats`, `book.php` and the board fight page (same fight state in both).
- `pfboard.js`, `pfight.js`, `pbox.js`, `pfight.css`, `pfparts.js` are not changed. The v1 fight has its own script (below).
- With the setting off nothing new is loaded: `layout.php` and `gnome.php` only `require` the puzzle-fight code when the setting is `1` or `admin`.

**Stage D (2.6.74 release) changed this:** the belts, the Tool Repair Kit, its recipe and the belts' shelf are NOT made while `pfight_v1` is Off (`pfd_live`); `pfd_ensure()` makes them once on the first v1 use (`pfd_content_once`, marker setting `pfd_content`). The flag-off page check in `tests/pbox_v1.sh` now compares with the 2.6.73 release (`b2c83466`), version strings masked.

## Files
| File | What |
|---|---|
| `game/includes/pfdeck_view.php` (new) | All v1 page HTML: `pfv_on`, `pfv_assets`, `pfv_entries` (fight values and edges of deck entries), `pfv_desc`, `pfv_pc` (one piece cell), `pfv_deckbar` (deck bar, Teamwork, harmony), `pfv_starter_html`, `pfv_box_html`, `pfv_foe_card`, `pfv_prefight_html`, `pfv_adv_post`, `pfv_post` (pfd_post + old-box carry-over), `pfv_wear_rows`, `pfv_result_html`, `pfv_result_take` |
| `game/assets/pfv1.css` (new) | Box, starter, pre-fight, result (`.pfv ...`) and the v1 fight additions (`#pfight.pf-v1 ...`, `.pfv-*`). Scoped, so no other page changes |
| `game/assets/pfv1box.js` (new) | Box, starter and pre-fight: draws the piece art with `pfparts.js`, sets meter widths (`data-w`, `data-f`: no inline styles, CSP), detail line, starter picks, filter, sends the hidden form `#pfv-f` |
| `game/assets/pfboardv1.js` (new, GENERATED) | The v1 fight board script. Built by `python3 tools/build_pfboardv1.py` from `game/assets/pfboard.js` + `tools/pfboardv1_part.js`. Edit those two, not the output. `--check` compares (run by `tests/pbox_v1.sh`); a replacement that no longer applies stops the build |
| `tools/build_pfboardv1.py`, `tools/pfboardv1_part.js` (new) | The build: about 35 exact replacements in a copy of `pfboard.js`, plus the v1 part (state, texts, ground, marks, rows, popover, help, replay steps) |
| `game/puzzlebox.php` | v1 on: the new page (`pfv_box_html`), `$GLOBALS['AJAX_PAGE']` so its buttons update in place; `pfd_*` POSTs go through `pfv_post`; the redirect keeps the tab (`t`) |
| `game/adventure.php` | POST `pfv_go` and `pfd_*` on the adventure page (v1 only); shows the session result card after `page_header` |
| `game/includes/pfight_game.php` | `pfight_html`: the gate (starter, pre-fight). `pfight_do`: `$enc['prev']` (ground, forecast, aim before the turn), extra replay fields for terrain events, the session result (`$_SESSION['pfv_res']`). `pfight_board_html`: v1 class, rows, legend, Flip button and form, result card, page data, the v1 script. Terrain history chips have no type icon |
| `game/gnome.php`, `game/includes/layout.php` | Entry points: a "Puzzle box" tile in the Hovel's Gnome tab, a "Puzzle box" tile in the menu under You; the Stats tab's help line names the deck |
| `tests/pbox_v1.sh`, `tests/pbox_v1_shots.js`, `tests/pbox_v1_seed.php` (new) | The suite, the browser pass, the seeding |
| `tests/pfboard_v1_page.sh`, `tests/pfdeck_v1.sh` | Updated for the gate (`letsfight` helper: pack a starter, press Let's fight) and the new box page |

## Pages and routes
| Screen | Where | Root id |
|---|---|---|
| Starter pick | `puzzlebox.php` while no starter is chosen; and on `adventure.php` when a creature appears before a starter was chosen | `#pfv-starter` |
| Puzzle box | `puzzlebox.php` (`?t=kit` default, `?t=belt`, `?t=pals`) | `#pfv-box` |
| Pre-fight | `adventure.php`, a creature encounter whose fight is not dealt yet (`$enc['pf']` empty and `$enc['pfgo']` not set) | `#pfv-pre` |
| Fight | `adventure.php`, as before | `#pfight.pf-v1` |
| Result (win, charm) | Inside the fight page when it is won, with the reward button | `#pfv-res` |
| Result (loss, run, stall) | Top of the next `adventure.php` page, once (session `pfv_res`, dropped after 15 minutes) | `#pfv-res` |

### POST actions
| `do` | Page | Fields | Notes |
|---|---|---|---|
| `pfd_starter`, `pfd_toggle`, `pfd_equip`, `pfd_unequip`, `pfd_auto`, `pfd_fix` | `puzzlebox.php` | as in stage B, plus `t` (tab to return to) | Through `pfv_post` |
| the same | `adventure.php` | as in stage B | Only while a creature encounter is open; refused once the fight is dealt (except `pfd_auto`) |
| `pfv_go` | `adventure.php` | none | "Let's fight": sets `$enc['pfgo']`; the next page deals the fight. Refused without a starter |
| `pfb_flip` | `adventure.php` | `hand`, `turn`, `nonce` | Stage A's action; the page has the form `#pf-fform` |

### Ids and classes other code may rely on
- Box: `#pfv-box[data-locked]`, `#pfv-filt [data-g]`, `.pfv-g > li[data-g]`, `.pc[data-a=tog|info|spick][data-arg][data-on]`, `#pfv-info` (detail line; the button in it is `[data-pfv-act]`), `#pfv-auto`, `#pfv-f` (hidden form: `do`, `key`, `on`, `tool`).
- Starter: `#pfv-tray .pfv-ps`, `#pfv-offer`, `[data-kit]`, `#pfv-pips`, `#pfv-hurt`, `#pfv-n`, `#pfv-sgo`, `#pfv-picks` (holds the `pick[]` inputs).
- Pre-fight: `.foecard`, `.tally .L-base|L-reg|L-rar|L-uni`, `.pc.L-*`, `#pfv-cinfo`, `#pfv-go`.
- Fight: `#pfv-row` (turn order, chain dots `.dots`, `.tg.team`, `.tg.aim`, `.tg.ev[data-ev]`, status chips, `.tg.wear`), `#pfv-legend` (`[data-ter]`, `[data-a=turn|help|spd]`), `#pf-flip`, `#pf-fform`, `#pf-fhand`; on the board `.gc[data-ter]` (ground), `.gf` (ground frame and icon), `.mk.ev .mkb[data-ev]` (forecast mark), `.mk.zone`, `.mk.aim`, `.evflash`, `.pfv-used`, `.pfv-fnew`, `.xp` (life pips); in the hand `.pfv-off` (cannot be played: 38% and grey), `.pfv-flipped`, `.pfv-flipping`, `.src`; `.pfv-pop` (popover), `.pfv-sheet` (help).
- Result: `#pfv-res .resbadge.badge-win|badge-charm|badge-lose`, `.toolrow(.broken)`, `#pf-end`.

### Page data added to `#pf-data` (v1 fights only)
`prev` (`ter`, `envs`, `aim` before the last turn; null without a replay), `tools` (type => `n`, `left` before this fight, `max`), `box`, `turncap`, `toolwear`, `fires`; `hand[]` gains `tool`, `rank`; `replay[]` entries gain `env`, `x`, `y`, `dir`, `moved`, `ids`, `me`, `foe` (terrain events), `used`, `tw`, `sun`.

## What each screen does
1. **Puzzle box.** Deck bar with stacked sources (kit / belt / pals), Teamwork sources, harmony (link rate meter, "hand links", knob families, hint), Rare and Masterwork cap pips. Kit tab: source filter icons, "In the kit" and "Collection" grids; tap a piece for the detail line, then Take out / Pack. Belt tab: tier chips, 2-4 slots with durability bars, the tools list with Put on / Take off / Fix (Fix uses a Tool Repair Kit; the count is shown), a link to Twigg's for a bigger belt. Pals tab: the party's pieces and a link to the Pal Book (the party itself is changed there). "Auto-use my current deck" switch. Locked during a fight (note, no buttons).
2. **Starter.** 4 core pieces locked, 6 slots, three one-tap kits (they fill the slots; a second tap on a piece changes it), pick pips, Hurt chip (at least 2), Pack the box. Without script a kit button packs that kit at once. The gate: with the flag on, a creature encounter shows the starter pick first.
3. **Old boxes (`user_pbox`).** Not copied blindly: on the starter screen the old box's pieces that are on offer start picked; after the starter is packed, the old box's other pieces that the gnome owns are switched on (as far as kit rules and caps allow) and the message says how many.
4. **Pre-fight.** Creature card (picture, level, class icon and name, region, size and board, temper, lean), the layer tally (base 4 / region / size or boss / unique 3), its pieces with the values they play for; tap one for its line. Your deck: with Auto deck ON read-only with the note "Auto deck is active" and "Turn off and edit"; OFF with a bench and free swaps. Let's fight deals the fight; from then on the deck is locked (stage B's lock).
5. **Fight.** The whole board of the creature's size (no zoom window), ground cells with icons, legend chips and popovers (the texts of `claude/design-board-strategy.md`, "Player-facing terrain text", numbers from the fight's own rule values), "?" help (round, aim, chains, flip, terrain, events, speed), forecast marks with a word on the board and as chips, the aim marker and chip, lit-spot numbers without a reply number (plus "×N used" and "team"), chain dots and the Teamwork chip for the planned piece, Flip (once a turn; the piece turns over and is picked again), faded hand pieces with the reason on tap (checked against the server's lit cells in the browser pass), life pips on the board and in the hand, Teamwork source icons, tool wear chips. The replay: YOUR TURN, the creature's turn (its aim stays on the board while its banner shows), TERRAIN TURN ("events land, then bramble pricks"), each event one step: its mark flashes, the pieces it hit light up, the ground changes; pieces a chain used up leave after that side's chain. Speed chip: 1x, 2x, skip (kept in `localStorage` `pfvspd`); the old Skip button still ends a replay. Reduced motion: the new animations are off.
6. **Result.** Win or charm: badge, picture, your health, turns, tool wear rows (broken tools marked, "Fix in the box"), the reward button (the old "End fight"). Loss, run or stall: the same card on the next page.

## Tests
| Test | What |
|---|---|
| `bash tests/pbox_v1.sh` (new; in `tests/ci_suites.sh` and `.github/workflows/ci.yml`) | About 60 checks with curl: JS syntax, the fork is what the build gives, flag-off parity against commit `ba9c416c` (skipped when that commit is not in the checkout), gating, starter (refusals, picks, carry-over), box tabs, toggle, equip, unequip, fix, auto-use, the gate and the pre-fight screen (auto on and off), lock, the v1 fight page and its data, flip, result cards (win, left), no PHP warnings. Then the browser pass |
| `tests/pbox_v1_shots.js` (run by the suite; `SHOT=dir` keeps the pictures) | Playwright at 390px, light and dark: 19 pictures a theme (starter, box kit / belt / pals, pre-fight auto off / on, opening on a 7x6 board, faded hand, forecast popover, help, lit spots, flipped, planned turn, the three banners, a terrain event, result win, result left) with about 30 checks a theme (what must be on each screen, faded = no server spot, popovers, help, flip, in-place updates, no sideways overflow, no console errors) |
| `bash tests/pfboard_v1_page.sh`, `bash tests/pfdeck_v1.sh` | Stage A and B page tests, updated for the gate; all pass |
| Others run | `pfboard_v1`, `pfboard_fixes`, `pfboard_sim`, `pfboard`, `pfboard_js`, `pfight`, `pfight_sim`, `pfight_js`, `pfmap`, `pfengine_js`: pass |

Seeding for hand checks: `php tests/pbox_v1_seed.php GAME box | fight SIZE [auto] | midfight SEED TURNS | win | lose`.

## Known gaps
1. **No human play session, no real phone, no MySQL.** The pictures were checked at 390px in Chromium only.
2. **The old board's text is dark on dark in the light theme** (creature name, hint line, inspect card; seen in `pfight_v1` off, not caused by this stage). The v1 fight sets its own light ink; the old page was left alone to keep it byte for byte.
3. **The inspect card** (the piece being scored, at the bottom of the screen during a replay) is the old one: large text, it covers the hand while a turn plays.
4. **Pals:** the box shows the party's pieces; taking a pal along or sending it home is still done in the Pal Book (a link). No add / remove buttons in the box.
5. **Belt tiers** are shown, not bought, in the box (link to `shop.php`; Twigg's has no deep link to the belt).
6. **Without script** the box shows the pieces as value and name (no art) and pieces cannot be switched (the tools forms, auto-use and kit buttons do work). The fight needs script, as before.
7. **Replay detail:** ground changes are drawn when their event lands, but "the oldest patch fades" shows only at the end of the replay. A forecast chip in the replay says "pushes a piece" (the piece's name is only known for the current forecast). The use-up step treats creature pieces that fell away (fire budget) like used-up ones.
8. **Set-aside groups** (the "Or set aside with" chips) are still offered in a v1 fight and take room under the board; the design may want them gone.
9. **A creature without unique pieces** (a creature outside the 88 of `pf_creature_pieces.txt`, for example a lair guardian) shows no "Unique 3" layer on its card.
10. **Balance, seen while seeding:** a level 12 gnome with the seeded deck (Rare tools, two pals) beats a level 14 large creature in 3-4 turns with a greedy player. Stage B's balance gaps stand.
11. **Upgrades (`user_pmod`):** an offer waiting is not shown on the v1 box page (the old page's dialog is not ported); a piece's upgrade is named in its detail line. Offers are not lost, they wait.
12. `pfboardv1.js` is a fork: a fix to `pfboard.js` reaches it only through the build (the suite fails until it is rebuilt).
13. Treks still use the old fight. Full CI was not run; only the puzzle-fight suites.

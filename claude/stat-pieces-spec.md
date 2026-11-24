# Stat pieces: spec (2.7.58, puzzle fights)

Status: built, behind `pfight_statpieces` (Off / Admins only / Everyone, default Off). Not seen on a real phone; balance unplaytested.

## Rule
A gnome owns every stat piece whose tier its points in that stat reach. Stats: Nimble, Lore, Luck, Sense (not Grit, Hardiness, Charm). Points = the stat score (10 at the start, at most `stat_max`). Tiers: 0 (everyone), 10, 15, 20, 25, 30. 24 pieces: 4 at tier 0, 20 above. Packed into the deck by choice like counter knacks (off until switched on; `pfd_toggle` refuses a key the gnome does not own).
Numbers: a = 1 + points / 5, b = ceil(a / 2). A piece's own base number is v + points / vd, with the piece's own stat (not PF_STAT).
Shared Luck roll: min(90, 50 + 2 x Luck) %, rolled once per firing and cached; `roll` / `!roll` clauses read it.
Setting Off: nobody owns any, the tile carries no stat fx, fights are byte-for-byte unchanged (md5 tests in `tests/pfdeck_v1.php`).
v1 rules hold: no set-aside or grouping, flipping free, any fitting cell legal, one placement a round, one shared Yield bar.

## Where it lives
| what | file |
|---|---|
| piece rows (key, stat, tier, type, numbers, edges, tag, fx, text) and the format key | `game/includes/data/pf_stat_pieces.txt` |
| ownership, numbers, packing, setting gate | `game/includes/pfdeck.php` (`pfd_stat_pieces`, `pfd_stat_ab`, `pfd_stat_entry`, `pfd_statpieces_open`) |
| engine (clauses, `PFB_STAT_ACTS`, views `sight` `eyes` `snares`) | `game/includes/pfboard.php` (`pfb_stat_data`) |
| JS twin, must stay in parity | `tools/pfengine.js` (`PFB_STAT_ROWS`); `tests/pfengine_js.sh` |
| Puzzle box shelf (tier plates, locked pieces) | `game/includes/pfdeck_view.php`, `game/assets/pfv1box.js`, `pfv1.css` |
| board marks and chips | `game/assets/pfboardv1.js` (hand-patched; never run `tools/build_pfboardv1.py`) |
| animation | `claude/pf-anim/motifs/{stat_nimble,lore_pieces,luck_pieces,sense_pieces,stat_pieces}.js`, table `claude/pf-anim/stat-pieces.json`, built by `tools/build_pfanim.py` into `game/assets/pfanim-data.json` key `sp` |
| art | icons `game/assets/img/pfight/pieces/ico-stat-*.png` (32 px, `-s` 20 px), kit `game/assets/img/pfight/stat/` (README there), wired in `game/assets/pfparts47.js` |
| design inputs | `claude/stat-pieces-design/` (`code-brief.md`, `art-brief.md`, `stat24.json`, `tiers2-*.json` = all 60 designed, 36 reserve unbuilt, `motifs/` drafts) |

## The 24 pieces
| tier | Nimble | Lore | Luck | Sense |
|---|---|---|---|---|
| 0 | Sidestep (next to its aim: its next hit misses; on its aim: it skips) | Old Saying (boost linked piece; more with an environment in the chain) | Loaded Die (roll: linked piece fires twice, else once) | Sharp Eye (held: see the piece after its aim; played: its next piece loses a) |
| 10 | Skitter (evade; the piece that missed falls off) | Knot of Twine (`any` edges; boost b) | Hedge Rummage (Pluck on the Luck roll; miss: its next Hurt +b) | Soft Spot (strip a guard; your next Hurt +b) |
| 15 | Wrong Turn (shove its aim one cell) | Lantern Chain (+b to the chain, +a at 4 or more) | Long Shot (roll: fire twice; miss: next Hurt +a) | Not Fooled (no combos for its next turn) |
| 20 | Pinning Stance (a re-pick must touch it) | Weather Lore (next environment piece becomes Sun, Spring on large boards) | Magpie's Pinch (take its strongest hand piece, weakest on a miss) | Saw It Coming (blocked Hurts fall off; its next piece loses a) |
| 25 | Shadow Step (Keeper jumps in beside its aimed piece, once a fight) | Copybook (teach a tag, at most b a fight) | Turn of the Coin (strongest hand piece back to its draw pile, or -b) | Snare Field (b free cells become snares for 2 rounds, half value, hidden from it) |
| 30 | Phantom Footing (for 2 rounds you pick where its aimed piece lands) | Turn of the Tale (a linked creature piece becomes yours, once a fight) | Lucky Streak (roll until a miss, at most b; each hit refires a random piece) | Eyes of the Wood (held: see its hand and draw top; each piece it places loses a) |
Exact text and numbers: the data file.

## UI
Puzzle box shelf: owned stat pieces carry a tier plate (tier 0 none). Unreached pieces sit greyed, "Locked: Lore 15", with points to go in the sheet; they cannot be packed. Stat filter and legend count them. Board: snare cells (dashed ring, label, rounds left), Sharp Eye and Eyes of the Wood chips (`data.sight`, `data.eyes`), stolen creature pieces marked (hook), Copybook taught tag noted. All only with the setting on for that gnome.

## Animation and art
24 motifs (footwork trails, scroll and ink, dice and trapdoor, eye and leaf) in the pfanim build; same Full / Light / Off setting; only the gnome's own piece of that name uses it. Art ink `#2a1a10`, hard pixels. Kit: stat badges in the owner corner, `any` sockets (Knot of Twine), Spring tile and glyph, stolen hook, snare ring; each falls back to the old look if its file is missing.

## Tests
Suite `pf_stat_pieces` (`tests/pf_stat_pieces.sh`): `pf_stat_pieces.php` (plumbing, Off unchanged), `pf_stat_{luck,nimble,lore,sense,ui,art}.php`, then PHP / JS parity (`pfengine_js.php` modes `v1stat,v1luck,v1nimble,v1lore,v1sense`). Also `pfengine_js`, `pfdeck_v1`, `tests/pfanim_unit.js`. Run: `PORT_BASE=<20000..29000> bash tests/ci_suites.sh <suite>`.

## Open
- Weak icons to redraw: Knot of Twine, Lucky Streak, the Nimble 20 px set.
- 36 reserve pieces (`tiers2-*.json`) not built or animated.
- `pbox_v1` check "pfboardv1.js is what build_pfboardv1.py builds" fails (pre-existing): port the hand edits back into `game/assets/pfboard.js`.
- No real-phone or live play check; no balance pass; decide when the setting defaults on.

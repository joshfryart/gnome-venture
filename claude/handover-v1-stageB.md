# v1 deck model, stage B handover (2.6.74 build; data + deck model, no UI)

Stage B put the DATA and the DECK MODEL of the v1 puzzle combat into the real game, behind the admin setting `pfight_v1` (stage A's flag; default off). Not done here: the pages (stage C), version bump, release notes, zip (stage D). Version is still 2.6.73.

Design: `claude/design-deckbuilder-combat.md` (DECIDED 1-11, class tables, authored edges). Ported from the approved demo `tools/pfdemo_v1/data.js` and the demo engine patches in `tools/build_pf_demo_v1.py`. Stage A: `claude/handover-v1-stageA.md`.

## Flag and parity
- Everything is inside `pfight_v1_on($u)`. With the flag off: `pf_tiles()` returns exactly the old library (now read from `data/pf_pieces.txt`, falling back to `PF_TILES_BUILTIN`), `pf_foe_deck()` is the old archetype deck, no new state keys, no new tile fields. An old board fight plays to the same transcript as at commit 9f297fc3 (md5 check in `tests/pfdeck_v1.php` section 8); the JS parity traces of the old modes are unchanged.
- A v1 fight started under stage A (state has `v1` without `tags`) keeps playing without creature tags.
- The four tables are in `schema.php` (made by "Upgrade database" / the version bump in stage D) and are also made on first use (`pfd_ensure`).

**Stage D (2.6.74 release) changed this:** the belts, the Tool Repair Kit, its recipe and the belts' shelf are NOT made while `pfight_v1` is Off (`pfd_live`); `pfd_ensure()` makes them once on the first v1 use (`pfd_content_once`, marker setting `pfd_content`). The flag-off page check in `tests/pbox_v1.sh` now compares with the 2.6.73 release (`b2c83466`), version strings masked.

## Data files (`game/includes/data/`, all linted by `tests/pfdeck_v1.php`)
| File | Format | Rows |
|---|---|---|
| `pf_pieces.txt` | `key\|name\|source\|ref\|type\|v\|knob/edges\|tag\|life\|rarity\|blurb`. source: basic, knack, calling, tool, crop, craft, region. ref: knack = unlock level, calling = calling, tool = tool type, crop = crop kind, craft = recipe category, region = region code. Keys: `t:TYPE`, `c:KIND`, `k:CATEGORY`, `r:CODE`. knob/edges: right-knob family (`-` = flat), optional `/COLUMN` and `/up` or `/down`. life `-` = default. rarity: `0`, `1`-`4`, or `src` (rank of the player's source). | 30 old pieces (their order is `pf_tiles()`), 18 tools, 9 crops, 7 crafts, 14 regions |
| `pf_class_base.txt` | `class\|name\|type\|v_mult\|knob\|tag\|life`; `=Class\|lean`; class `@large` / `@boss` = size extras | 6 classes x 4, Slam, Scheme, Crush |
| `pf_creature_class.txt` | `slug=Class` | 88 (Critter 17, Bird 11, Beast 28, Reptile/Amphibian 15, Water 13, Plant/Fungus 4) |
| `pf_creature_pieces.txt` | `slug\|lean\|name\|type\|v_mult\|knob\|tag\|life` | 88 x 3 = 264, names unique |
| `pf_region_pieces.txt` | `code\|slot (hurt/other)\|name\|type\|v_mult\|knob\|tag\|life` | 14 x 2 |

`creatures.txt` is untouched. Pal pieces are generated (`pfd_pal_pieces`): type from skills and Boon, value `4 + skills + 2 x rarity`, right knob from the pal's jigsaw knob, column family body, rank = rarity.

## Creature decks and tags
- `pfd_foe_row($c, $regionCode)` adds `deck` (read by `pf_foe_deck`, PHP and JS), `class`, `lean`, `region`. Deck = 4 base (class) + region (small / medium: the "other" piece; large / boss: both) + size extras (large 1, boss 2) + 3 unique. Sizes in a region: 8 / 8 / 10 / 11. Piece keys `f:b0..3`, `f:g0..1`, `f:x0..1`, `f:u0..2`; tile fields `layer` (base, reg, rar, uni), `col`, `life`. Value = `v_mult x pfd_foe_v($c)`. Lean: 3 pieces in 5 (layer order) stack in the class family. A boss plays: one set-up piece, two Hurt pieces, repeat.
- The region is the expedition scene's region (`pfd_exp_region`). No region: no region piece.
- Engine (`pfight.php` `pf_apply`, `pfboard.php`, mirrored in `tools/pfengine.js`), on when `$s['v1']['tags']` (new rule switch, default 1):
  - **pierce** (Hurt): ignores your guard. **poison** (Hurt: a third of the hit; trick: half its value): 2 ticks on your health at the end of the round, after the terrain; at most `PF_POISON_CAP` 3 ticks wait, the stronger dose counts. **trip**: you draw 1 fewer next round (once a round). **quick**: the creature places one more piece that turn (once a turn). **bash** (Hurt): its guard is added and spent; (trick, Shoulder Barge): its next hit carries its guard once, the guard stays.
  - Against your hits: creature **evade** makes your first Hurt miss; creature **thorns** prick you (4% of max health, at least 2) when its guard blocks. Trick tags: quick, evade, bash, thorns, poison, trip, heal.
  - New state: `$s['me']['poison']`, `poison_v`, `slowdraw`, `$s['foe']['bashnext']`, `again`. Event fields `poisoned`, `tripped`, `bashed`, `evaded`, `pricked`. The poison tick is a terrain-log entry `k = poison` (event `env: poison`, line "The poison works on you").
  - View: `status` (`poison, poison_v, slowdraw, evade, foe_evade, foe_thorns, foe_bash, foe_slow, foe_poison`), `wear`; `pcs[]` gain `rank`, `layer`; `hand[]` gain `rank`, `tool`. `status` and `wear` are also in the page's `#pf-data`.
  - The creature's search values waiting effects (`pfb_score`).

## Player deck model (`game/includes/pfdeck.php`)
Deck = kit + gear. No maximum size. Caps: 3 Rare, 1 Masterwork (kit + gear). Kit minimum 8, at least 1 Hurt.
- **Starter:** 4 core (Swing, Dodge, Rest, Charm) + 6 of 12 offered (`PFD_OFFER`: calling piece or Taunt, Jab, Snack, Hide, Brace, Soothe, Hum, Pierce, a second Swing `swing#2`, Oat Cake, Herb Poultice, the home region piece), or a one-tap kit (`bold`, `steady`, `kind`). 2 or more Hurt pieces. Once only. A picked piece is owned from then on. Until chosen, fights play the Steady kit (nothing saved).
- **Owned pieces:** basics; knacks by level; your calling piece; a crop piece once a crop of that kind was grown (`user_food_mastery.grown`); a craft piece once something in that category was made (`user_recipes.made`); a region piece once its guide was read (`user_guides`). Crop, craft and region pieces are ON by default; knacks OFF. `pfd_toggle` switches.
- **Rank** (value +0 / +2 / +4 / +5; Masterwork life 4): tool tier; crop = best food mastery tier of the kind (min 1); craft = 1 + category mastery tier; region = by guides held (1, 3, 7, 12); pal = rarity (value not raised again).
- **Belt:** slots 2 / 3 / 4 = belt tier 1 / 2 / 3. Tier 1 is free. `stitched-fight-belt` (600, level 8) and `masterwork-fight-belt` (2500, level 18) are sold at Twigg's, work from the satchel, not tradable. A belt never set holds the best tools. A tool on the belt adds its piece (`t:TYPE`), ranked by the best tool of that type owned.
- **Wear:** durability 20 + 4 per rank above Worn. The engine adds `PFB_TOOL_WEAR` 2 to `$s['wear'][type]` each time the tool's piece is placed (also inside a set-aside group; not in dry runs). `pfight_do` saves it once when the fight is over, however it ended (`$enc['wearsaved']`). Wear = durability: the tool is broken for fights, its piece leaves the deck, it cannot be equipped. This is separate from the garden / gathering tool wear.
- **Repair:** item `tool-repair-kit`, recipe in `crafts.txt` (category `garden`, so no building is needed: flint, pine resin, coir fibre). `pfd_fix` uses one kit and sets the wear to 0.
- **Lock:** from the moment a puzzle fight is dealt until it is over, starter, toggle, equip and unequip are refused. Auto-use can still be changed.
- A fight never gets an illegal deck: a kit under 8 or without Hurt falls back to the default kit; pieces over a rarity cap are left out (`out = cap`).

### Tables
| Table | Columns |
|---|---|
| `pf_decks` | `user_id` PK, `starter` (chosen), `auto_use`, `belt_set`, `ver`, `made_at` |
| `pf_deck_pieces` | `user_id`, `piece_key` (PK both), `starter`, `active`, `pos` |
| `pf_belts` | `user_id`, `slot` (PK both), `tool_type` |
| `pf_tool_wear` | `user_id`, `tool_type` (PK both), `wear` |

### Functions
| Function | What |
|---|---|
| `pfd_deck($uid or row)` | The whole model: `pieces` (every owned piece + gear: `key, k, n, t, v, r, tag, src, ref, rank, life, blurb, gear, tool, starter, core, on, out`), `deck` (what a fight uses), `counts` (`n, kit, belt, pals, hurt, rare, mw, src, team`), `err`, `starter`, `offer`, `kits`, `belt` (`type, tier, max, wear, left, state` ok / broken / none / over), `slots`, `belt_tier`, `auto`, `harmony`, `locked` |
| `pfd_sources($u)` / `pfd_sources_blank()` / `pfd_build($src)` | Sources from the DB; the same shape for tests and sims; the pure builder |
| `pfd_validate($counts)` | Error or null |
| `pfd_set_starter($u, picks or kit name)`, `pfd_toggle($u, $key, ?bool)`, `pfd_equip_tool($u, $type, ?slot)`, `pfd_unequip($u, $type)`, `pfd_set_auto($u, bool)`, `pfd_fix($u, $type)` | Each returns an error string or null |
| `pfd_belt_slots($u)`, `pfd_belt_tier($u)` | 2-4, 1-3 |
| `pfd_wear($u)`, `pfd_wear_add($u, $wear)` | type => `tier, max, wear, left, broken`; add and return what broke |
| `pfd_harmony($entries)` | `n, link, hand, fam` (link rate, hand links, families) |
| `pfd_start_fight`, `pfd_end_fight`, `pfd_exp_region` | The hookup in `pfight_me`, `pfight_state`, `pfight_do` |
| `pfd_foe_row`, `pfd_foe_pieces`, `pfd_foe_v`, `pfd_class`, `pfd_catalog`, `pfd_classes`, `pfd_uniques`, `pfd_region_pieces`, `pfd_edges`, `pfd_tiles` | Data and creature side (for the creature card: layers, lean, class) |

### POST actions for the UI (`pfd_post($u, $do, $_POST)` returns `[ok, message]`; wired in `puzzlebox.php`, csrf as usual, only when `pfight_v1_on`)
| `do` | Fields |
|---|---|
| `pfd_starter` | `kit=bold\|steady\|kind` or `pick[]=KEY` x6 |
| `pfd_toggle` | `key=KEY`, optional `on=0\|1` |
| `pfd_equip` | `tool=TYPE`, optional `slot=N` |
| `pfd_unequip` | `tool=TYPE` |
| `pfd_auto` | `on=0\|1` |
| `pfd_fix` | `tool=TYPE` |

Debug helper: `puzzlebox.php?pfd=json` (v1 on) prints `pfd_deck` plus `wear` as JSON. The old Puzzle box page is unchanged.

## Balance (real engine, 88 creatures, layered decks, a typical deck by level: `tv_sources` in `tests/pfboard_tune_v1.php`)
Layered decks and tags made large creatures and bosses hit harder and fights shorter (before retune, chain bot at level: 81 / 77 / 69 / 66% wins, 6.0 / 5.4 / 5.0 / 6.6 turns). Retuned `PFB_V1_FOE_MULT` to **0.76 / 0.56 / 0.42 / 0.53** and `PFB_V1_BAR_MULT` to **1.0 / 1.3 / 1.6 / 1.0** (small / medium / large / boss).

| Bot | Level | small | medium | large | boss |
|---|---|---|---|---|---|
| chain | at level | 74 / 55 / 5.1 | 72 / 61 / 6.0 | 69 / 67 / 7.0 | 71 / 71 / 7.9 |
| chain | 4 under | 68 / 60 / 4.4 | 31 / 85 / 5.7 | 54 / 79 / 7.8 | 55 / 81 / 8.0 |
| chain | 8 under | 68 / 60 / 4.4 | 12 / 95 / 5.3 | 20 / 94 / 6.5 | 28 / 91 / 7.1 |
| look | at level | 96 / 21 / 5.8 | 92 / 33 / 6.6 | 98 / 29 / 7.5 | 98 / 27 / 7.3 |
| look | 4 under | 96 / 25 / 5.0 | 64 / 58 / 8.7 | 89 / 42 / 9.3 | 92 / 36 / 8.7 |
| look | 8 under | 96 / 25 / 5.0 | 34 / 78 / 10.0 | 63 / 64 / 10.2 | 85 / 52 / 10.2 |
| smart | at level | 100 / 15 / 4.4 | 99 / 21 / 5.2 | 100 / 17 / 6.5 | 100 / 19 / 6.3 |
| smart | 4 under | 100 / 17 / 4.1 | 88 / 40 / 7.9 | 100 / 21 / 8.0 | 100 / 23 / 7.7 |
| smart | 8 under | 100 / 17 / 4.1 | 69 / 57 / 10.2 | 91 / 38 / 9.7 | 100 / 33 / 8.6 |

Win % / health lost % / turns, about 210 fights a cell. Targets met at level: chain 69-74%, smart 99-100%, turns 5-8. Re-run: `php tests/pfboard_tune_v1.php chain 0` (`DECK=old` / `FOE=old` give the stage A deck and creatures).

## Tests
| Test | What |
|---|---|
| `bash tests/pfdeck_v1.sh` (new, in `ci_suites.sh` and `ci.yml`) | 150+ checks. Pure: data lint (88 creatures covered, keys unique, edges valid, class table, no orphan sources, kits legal), layers for all 88, every creature tag, 88 whole fights, deck from sources, starter, caps, belt, wear, harmony (every one-tap starter links on 90%+ of hands), flag-off parity. Database: tables, content, starter, toggle, sources, belt, wear / break / fix, auto, POST, fight hookup, lock. Page: gating, POST actions, a whole fight, wear saved. Eight engine and data mutations were run against it; each fails at least one check |
| `bash tests/pfengine_js.sh` | JS = PHP over 616 fights, 20321 actions (88 new `v1d` fights: layered creature decks and tags against deck-model decks) |
| Stage A and old suites | `pfboard_v1`, `pfboard_v1_page`, `pfboard_fixes`, `pfboard_sim`, `pfboard`, `pfboard_js`, `pfight`, `pfight_sim`, `pfight_js`, `pfmap`: all pass (also `craft`, `walk`) |

## Known gaps (for stage C and D)
1. **No UI.** No starter screen, Puzzle box v2 page, pre-fight screen, belt or repair UI, rank trim, life labels, status icons, creature card. The data for all of it is in `pfd_deck`, `pfd_foe_row` and the view. The starter is NOT gated: a gnome who has not chosen plays the Steady kit; stage C should send them to the starter pick before the fight is dealt (`pfight_html`, before `pfight_state`).
2. **The pre-fight screen and "Auto-use"** are only a stored flag (`pf_decks.auto_use`).
3. **Existing boxes are not migrated.** `user_pbox` is ignored in a v1 fight; upgrades (`user_pmod`) still apply by piece key (also to the new keys, but the old page only offers the old pieces).
4. **Belts have no level check in the shop** (shops have none): the level gate is on the slots, and the item text says so. The belts are sold at Twigg's only.
5. **Repair recipe category is `garden`** so that no Tool Shed is needed; move it to `tools` if Josh wants the shed to matter. No mastery link.
6. **18 tool types, not 19** (`TOOL_TYPES` has 18). 7 craft categories each have a piece (cooking and pantry included).
7. **Calling tier III second pieces** (design 2.2) are not authored. Pal pieces carry no Boon tag.
8. **Balance under level:** medium creatures 4-8 levels above the gnome are very hard for the chain bot (31% / 12%). The deck used in the sim is one typical profile; decks of 24-28 pieces at level 16-30 are diluted. No human session.
9. **Creature AI and tags:** the creature values poison, trip, evade and the like with fixed weights; it does not plan a Shoulder Barge before a hit. The aim is not re-shown for a Quick second piece.
10. Water's base 4 has only body and mind knobs (the approved table); with the unique 3 every creature has all three families (linted).
11. `tools/build_pf_artifact.py` does not build JS tables from the data files; the JS engine takes the layered deck in the creature row (`c.deck`), so it needs none. The demo's own sample data (`tools/pfdemo_v1/data.js`) is unchanged.
12. Treks still use the old fight. MySQL, a phone and full CI were not run.

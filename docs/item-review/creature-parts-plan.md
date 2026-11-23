# Creature parts: build plan

Repo `/home/user/gnome-venture/game`, read-only pass at 2.7.57 (`includes/bootstrap.php:5`). Paths are under `includes/` unless shown. Every file:line below was grepped in this pass. Nothing was run except `php tests/craft_tags.php`.

## How releases and upgrades work here (verified)

- Version: one literal, `bootstrap.php:5`. `tools/check_versions.sh` requires the top `## x.y.z` of `CHANGELOG.md` to match.
- Columns: add a row to the column list in `schema.php` (next to `user_items.wear`, `:1505-1506`). `db_migrate()` (`db.php:131-153`) probes each column and runs `ALTER TABLE ... ADD COLUMN` on SQLite and MySQL. It never changes or drops.
- One-time data steps: `boot_step('name_2758', fn)` inside the block at `bootstrap.php:103-640`, before `post_update_news` (`:626`). `db_version` is set at `:635` only when there were no migrate errors.
- Recipes: `ensure_crafts()` (`crafting.php:23-58`) inserts missing `crafts.txt` rows only. Editing a row needs a boot step.
- Settings: add to the array in `functions.php` (tool settings `:721-724`, compost `:649-651`, `:706-709`).
- CI: suite names are in `DEFAULT_SUITES` in `.github/workflows/ci.yml:69`, not in `tests/ci_suites.sh`. A suite fails on a line starting `FAIL`.

One release per phase is suggested: 2.7.58 to 2.7.62.

## Phase 0 (2.7.58): families and `any-<family>` in recipes

**Goal:** recipes can ask for a family; no behaviour change for existing rows.

- New `includes/parts.php`: `const PART_FAMILIES` (the six suffix lists), `part_family(string $slug, string $category): ?string`, `part_family_items(string $fam, bool $rareOnly = false): array`, `part_is_rare(array $item): bool` (`rarity >= 45`, the R threshold at `items.php:50`).
- Match only `items.category = 'part'`. Reason: forage items already used in recipes end in family suffixes (`stag-beetle-shell`, `dragonfly-wing`, `snow-moth-dust`, `seed-pearl`, `spiral-shell`). Deny-list `tailors-thread` (`wearables.php:415`, a pity currency that ends in `thread`).
- `craft_stock()` (`crafting.php:163-185`): a key `any-<fam>` or `rare-<fam>` returns `id => 0`, `name => 'any Hide part'`, `have` = sum, plus `any => [[id, have], ...]` sorted by `base_price` ascending. Plain `any-` never takes a rare part while a common one is left.
- New `craft_take(int $uid, array $s, int $n): bool`; use it in `craft()` at `crafting.php:279-284`, which today fails on `id < 1`.
- Scope: non-timed categories only (tools, garden, potions, building, decor). Cooking, pantry and pal jobs (`crafting.php:455`, `pantry.php:166`, `pal_jobs.php:771-1013`, `game_clock.php:365`) read `id` too; with `id = 0` they refuse, so leave them and keep `any-` out of those categories.
- Display: ingredient names are looked up by slug at `crafting.php:122-136`, `almanac_notes.php:339-386`, `items.php:31`, `shelves.php:75`. Add a label fallback for `any-`/`rare-` keys.
- Data: `crafts.txt` `shell-meal-plate|Shell Meal (creature plates)|garden|shell-meal:2|any-plate:3|2` (matches `shell-meal-*` glob, `data/craft_scenes.php:31`).
- Tests: new `tests/parts.php`, called from `tests/craft.sh` like `alchemy.php` (`craft.sh:84`): family of 12 sample slugs, forage excluded, cheapest-first, rollback when short.
- Rollback: delete the new rows from `recipes`; code revert is safe (no schema).
- Risk: low. Unverified: 247 of 483 drop names match no family (whisker 6, leg 3, ear 3, fleece 2, tail, talon, fin, bristle, chitin). Suggest adding whisker/fleece/bristle/ear/tail to Hide and talon/tine/chitin/leg to Plate; user call.

## Phase 1 (2.7.59): augments, kit mending

**Schema** (`schema.php` after `:1506`): `['user_items','aug','VARCHAR(24) NULL']`, `['user_items','aug_left','INT NOT NULL DEFAULT 0']`.

**Storage fact to fold in:** `user_items` is one row per (user, item) (`schema.php:230-236`), not one row per copy. Wear already lives on that row. So "per tool copy" means per owned tool item; spare copies share it.

**Survival:** `tool_break()` (`tools.php:358-366`) deletes the row when the last copy goes (`give_item`, `inventory.php:18`). Read `aug, aug_left` first; if no working copy remains, write them to the Broken row. `mend_tool()` (`:417-451`) copies them back when the Broken copy is exchanged (`:438-443`). `:444` resets only `wear`, so augments on a worn tool already survive.

**Items** (add to `ALCHEMY_ITEMS`, `alchemy.php:14-30`, category `supply`, made by `alchemy_ensure_items()` `:42`) and `crafts.txt` rows, category `potions`, energy 2:

| Slug | Ingredients | Effect | Uses |
|---|---|---|---|
| `aug-hide-binding` | `any-hide:3,rope:1` | wear limit +25% | permanent |
| `aug-hide-binding-2` | `rare-hide:1,any-hide:3,beeswax:1` | wear limit +50% | permanent |
| `aug-plate-edge` | `any-plate:5,flint:1` | 25% one rarity tier up | 40 |
| `aug-wing-fletch` | `any-wing:4` | 35% chance of +1 item per find | 25 |
| `aug-gem-charm` | `any-gem:1,any-ooze:2` | Luck +4 in the gather pick | 30 |
| `aug-ooze-salve` | `any-ooze:3` | next 3 Petal mends cost 0 | 3 |
| `aug-silk-lashing` | `any-silk:4,tool-repair-kit:1` | mends cost 1 fewer kit, minimum 1 | 40 mends |

Fitting: new `tool_fit_aug($uid, $toolItemId, $augItemId)` in `tools.php`, posted from the Satchel (`inventory.php:39` handles `mend`; tool cards at `:97`, `:143`; `tool_wear_html` `tools.php:465`). One slot; fitting replaces. Tier 3-4 tools (`effects.tier`) also take one `rare-<family>` part at fitting. Item base price 60% of ingredient value.

**Effect hooks**
- Wear limit: `tool_wear_limit($type, $tier)` (`tools.php:283`) has no user. Add `tool_wear_limit_for($uid, $tool)` and use it in `tool_use()` `:335`, `tool_left_text()` `:315`, `tool_wear_info()` callers.
- Rarity roll (verified, `gathering.php:78-146`): candidates are filtered by tool tier (`GATHER_RARITY` `:14`, common/uncommon/rare need tier 1/2/3), then one weighted pick, weights 60/30/15, non-common +3 per Luck (`:98-121`). There is no legendary gatherable.
- **Plate Edge hook: right after `$pick ??= reset($can);` (`gathering.php:121`).** If the picking tool's row has `aug-plate-edge` and `random_int(1,100) <= 25`, re-pick at random from `$here` with the same `tool` and the next rarity; spend a use only when a swap happens. Decision needed: may it ignore the tier gate (pick from `$missing`)? Recommended yes, one step only; otherwise it does nothing for a tier 1 tool.
- Gem Charm: add to `$luck` at `:99`. Wing Fletch: with the quantity bonuses at `:123-127`. Uses tick beside `tool_use()` at `:142`.
- Ooze Salve: in `mend_tool()` before the coin charge at `:435`, after the shed mend.

**Kit mending (user decision: yes).** In `mend_tool()` the order becomes: free shed mend, then kits, then Petals. Move the Glowcap kit spend (`:432`) after the free-mend check (fixes EC7). `pfd_fix()` (`pfdeck.php:909-917`) is unchanged.

- New setting `tool_mend_kits`, default `1,2,4,8` (tier 1-4). Tier 3 also takes 1 part of any family; tier 4 takes 1 rare part. Silk Lashing: one fewer kit, minimum 1.
- Sanity check against `tool_mend_percent` 15%, minimum 5 (`tools.php:380`), using `TOOL_ITEMS` prices (`:51-104`) and kit ingredients flint 8 + pine-resin 20 + coir-fibre 8 = 36 base, kit price 30 (`pfdeck.php:42`):

| Tier | Petal mend | Kits | Kit ingredient value |
|---|---|---|---|
| 1 (25-90) | 5-14 | 1 | 36 |
| 2 (250-520) | 38-78 | 2 | 72 |
| 3 (1200-1800) | 180-270 | 4 + part | 144 |
| 4 (6000) | 900 | 8 + rare part | 288 |

  Kits lose at tier 1, break even at tier 2 and save 45-70% at tiers 3-4, paid for in gather energy (coir-fibre is island-only, pine-resin uncommon). No loop: mending produces nothing sellable.
- Bulk row: `tool-repair-kit-silk|Tool Repair Kit (silk)|garden|tool-repair-kit:2|any-silk:2,flint:1|2`.
- EC6: `broken_item_id()` `tools.php:375` `tradable => 0`; boot step `broken_untradable_2759`: `UPDATE items SET tradable = 0 WHERE category = 'broken'`. `tool_trade_block()` (`:454-458`) also refuses a tool with `aug` set.
- EC5: reset wear at `:444` only when the stack had no working copy.
- Tool upgrade recipes consume the lower tool; in `craft()` carry `aug` to the output when both are tools. Unverified which recipes do this.

**Tests:** new `tests/augments.php` (run from `tests/tools.sh`): break/mend keeps `aug`; 40 Plate Edge uses then cleared; seeded 25% rate over 4000 picks within 22-28%; kit counts per tier; Lashing floor of 1; Glowcap kit kept when a shed mend is free; Broken copy cannot be gifted. Extend `tests/alchemy.php` ("8 potion recipes" becomes 15). `tests/schema_compare.php`, `tests/upgrade_check.sh`.

**craft_tags:** it already prints 4 FAILs today, including `garden recipes on no object: tool-repair-kit`; `craft.sh:51` shows only the last line, so CI does not fail. Add `"tool-repair-kit*"` to a garden object (`craft_scenes.php:30-34`) and `"aug-*"` to `mortar` and `still` (`:38`, `:41`).

**Rollback:** columns stay (harmless); delete the new recipes and items; set `tool_mend_kits` to `0,0,0,0` to switch kit mending off. **Risk: medium** (row deletion on break, trades).

## Phase 2 (2.7.60): compost

- `heap_add()` clamps at `need x compost_heap_max` (`gardens.php:228-231`) and `add_food_scraps()` takes only what fits (`:247-249`). Add `['garden_buildings','scrap_bank','INT NOT NULL DEFAULT 0']`.
- New `add_parts_to_heap($u, $plotId, array $itemQty)` beside `add_food_scraps` (`:236`): scrap points fill the heap, the rest goes to `scrap_bank`. In the collect path (`gardens.php:542`), after `scraps` drops, move bank into the freed room. Nothing is refused.
- Settings: `part_scraps_hide` 3, `part_scraps_wing` 3, `part_scraps_silk` 3, `part_scraps_ooze` 4, `part_shell_meal_parts` 1 (Plate parts per Shell Meal, given straight to the satchel).
- UI: "Add parts" button by the heap line (`garden.php:846`), new `do` next to `:49`.
- Balance flag: Shell Meal has two prices (`nutrients.php:65` 35, `:142` 15) and parts start at base 5, so 1:1 can be a sell arbitrage. Existing rows give 2 for 3 (`crafts.txt:37`). Recommend default 2 unless the user confirms 1.
- Tests: new `tests/compost_parts.php`: 100 Hide parts into a full heap, bank holds the excess, collect repeatedly, total points conserved.
- Rollback: hide the button; banked points remain in the column. Risk: low.

## Phase 3 (2.7.61): sinks

- **Tailor:** `wear_take()`/`wear_qty()` (`wearables.php:446-473`) take exact slugs; teach both `any-`/`rare-` via `part_family_items`. Materials come from `tools/build_wear_items.py` (`:34-36`), which writes `data/wear_items.txt`; change the generator, not the file. Lining mats at `wearables.php:482` gain an `any-silk:2` alternative. Tests: `tests/tailor.sh`, `tests/wearables.sh`.
- **Codex:** `pf_codex` is created lazily (`pfcodex.php:13-21`). Add table `pf_codex_parts (user_id, slug, given INT, done_at)` the same way; `pfcx_donate()` takes parts from that creature's `creature_drops` rows; at 3, one-time reward 40 Petals x creature level band and 20 XP. Button in `pfcx_sheet()` (`:138`). Tests: `tests/pfcodex.sh`.
- **Hovel trophy wall:** `data/hovel_decor.json` has no trophy slot; `hovel_decor_owned()` (`home_slim.php:84-89`) is marked as the place for new sources. Add slot `trophy` and table `user_trophies (user_id, creature_slug, item_id)`; one part per creature, consumed. Needs art; ships with a placeholder.
- **Fair:** add `'diorama' => ['🦔','Creature diorama',[]]` to `FAIR_CATS` (`fair.php:11-15`), following the kind-less `preserve` class. Score through `fair_keep_best()` (`:89`): distinct families x 10 + rare parts x 5, parts consumed on entry. `fair_enter()` text at `:120`. Tests: `tests/fair3.php`.
- **NPC quests:** Pomeroy exists only in the Gourmand (`gourmand.php:4`), which is off by default (`functions.php:461`), so an Ooze request there is invisible on a default install. Use Sight folk rows (`data/trail_sight_folk*.txt`, `take=any-<suffix>` at `trail_sights.php:400`, already live) and Job Board rows in `data/jobs.txt` (`deliver_gather` kind). Unverified whether the job importer accepts family tokens. Tests: `tests/trail_sights_lint.sh`.
- Rollback: each sink is its own table or data rows; remove the entry points. Risk: medium (five surfaces).

## Phase 4 (2.7.62): balance and docs

- Run `tests/balance_sim.php` and `tests/balance_pace.py` with augments on and off; target: an augmented tier 2 tool is worth under 15% more finds per energy.
- `CHANGELOG.md` entry per release, `update_news.php` player post, Almanac how-to line on mending (precedent `bootstrap.php:352`), guide rebuild (`tests/build_guide.py`).
- Add new suites to `DEFAULT_SUITES` in `ci.yml`.

## Decisions (locked by user)

1. Plate Edge may pick above the tool's tier gate, one rarity step only: YES.
2. Extend suffix lists to cover the 247 unmatched drops: YES (default; user did not object. Confirm before build).
3. Plate to Shell Meal ratio: 2:1.
4. Two copies of a tool share one augment; it stays on the working stack when one breaks: ACCEPTED.
5. Ooze quest lives with Pomeroy, Gourmand-only (invisible on default installs, by choice).

## Not verified

MySQL behaviour of the new columns; tool upgrade recipes that consume a tool; the job importer and family tokens; item counts in `items.json` (its `category` field is absent, so family counts here come from `data/creatures.txt` and `data/pf_creatures.txt` drop names); no test suite was run.

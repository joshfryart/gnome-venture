# Plan: crafting scene popover + food buff/energy text

Investigation only. No game code changed. Not committed. Paths under `game/`.

## 1. Premise check
- Satchel food already shows buff and energy: `items.php:109` (in `item_facts()`), shown at `shelves.php:90`.
- Cooking cards show both (`shelves.php:209`). Pantry jars too (`pantry_view.php:203`). Potion drinks too (`alchemy.php:129`).
- Missing: the shop sheet in `shop_tile()` (`shop_tiles.php`, sheet near `:118`). No caller builds buff text for it.
- Missing: craft cards never show the dish description. Only the buff subtitle.

## 2. Scene objects today
- Data: `includes/data/craft_scenes.php:6-54`. Row = `[id, label, x%, y%, w%, h%, globs | query]`.
- Render: `includes/craft_map.php:111-134`. Hotspot = `<a class="cmap-hs hs-<area>-<id>" href="?o=<id>">` (`:130`).
- Tap today: plain link. `?o=` filters the Shelves list on the same page (`craft_shelves.php:32, 37, 40`). No JS.
- CSS: frame `style.css:6508-6514`. Positions one rule per object from `:6516`.
- Pantry shares the header and `?o=` (`pantry_view.php:54, 57, 134`) but has its own list.
- Potions objects use `q=` links, not globs. Out of scope.

## 3. Recipe data and states
- Tables (`schema.php:143-163`): `recipes` (ingredients JSON, energy, category, slug, output_item_id). `user_recipes` (user, recipe, learned_at).
- Known: `craft_recipes()` (`crafting.php:105-144`). Row in `user_recipes` = known. Inserted on read once all ingredients were seen (`:131-138`).
- `can` = ingredients held only (`:123-141`). Energy, building, pots are not in it.
- Shelf status: `sh_craft_entries()` (`shelves.php:175`). `ok` = `can` and not a feast without Kitchen III.
- Bug: a recipe that needs a missing Kitchen or too much energy lands in "Ready". Acts text says why (`shelves.php:184-186`).
- Building gate: `craft_stations()` (`crafting.php:94-102`), enforced in `craft()` (`:221-225`). "Level" = Kitchen III for feasts only (`:227`).
- `?o=` tags: fnmatch globs on slug (`craft_map.php:18-22`). No recipe-to-object column. Computed per request.
- `tests/craft_tags.php`: each recipe of a tagged area hits an object; each object hits 2+ recipes; every glob matches.

## 4. Food text
- Data: `items.effects` JSON, e.g. `{"temp":{"hardiness":2,"minutes":240},"energy":11,"scrap":1}`, plus `items.edible`. Set in `catalog.php:203-217`, `gathering.php:35-39`.
- Builder: `buff_text()` (`crafting.php:502-517`) gives `⚡+N (🛡️ Hardiness +3 for 4 hours)`.
- Home dishes: `dish_energy()` (`gnome.php:371`). Minutes: `buff_minutes()` (`gnome.php:350`).
- Satchel list: `item_facts()` (`items.php:81-130`), line 109 calls `buff_text()` when edible.
- No single function covers every surface. Two builders: `buff_text()` (text) and `item_facts()` (list).
- Gap: home-cooked energy shows x115 but not the Brewroot `meal_energy_pct` perk added in `eat_item()` (`gnome.php` ~477).

## 5. Plan
**Data flow.** `craft_shelves()` already builds `$all` via `sh_craft_entries`. The popover reuses it: filter by `craft_tag_match()`, split into tabs. No new query.

**Tab rule (new).**
- Can craft: known, ingredients held, station ok, not feast-locked, `craft_fit() >= 1` (energy, pots).
- Missing: known, not Can craft.
- Unknown: not known.

**Endpoint.** None. Render all popovers into the page (5 small lists). No JSON, no fragment. CSP unchanged.

**Markup.**
- One `<dialog class="picker craftpop" id="pop-<area>-<id>" aria-labelledby="...">` per tagged object.
- Place after `craft_area_header()`, before `.shelves`, so shelf handlers (`site.js:2030-2066`) never see it.
- Tabs: `role="tablist"` buttons with counts. Rows: `<a href="?c=<area>&r=<id>#r<id>">`, no `id` (clashes with pills).

**Hotspot.** Keep `href="?o=<id>"` as no-JS fallback. Add `data-pop="pop-<area>-<id>"`. JS handles plain clicks only.

**JS.** New `assets/craftpop.js`, loaded only on the Satchel page (check how `chest.js` is included).
- Open with `gvOpenDlg()` (`site.js:2-4`). Close: native Esc, Android back, backdrop.
- Do not reuse `gvGarden()` picker wiring (`site.js:1230-1240`, garden only).
- Tab switch toggles `hidden`. Return focus to the hotspot on close.

**CSS.** `.craftpop` block after the `.cmap-*` rules (`style.css:6488-6515`). Reuse `dialog.picker`, `.pickbox`, `.pickhead`, `--tap`. Tabs at least 44px. Hotspots already exceed 44px at 390px (smallest about 88px tall). Check at 360px.

**A11y.** `showModal()` gives focus trap, Esc, inert page. Tabs use `aria-selected`; arrow keys optional. Rows are real link text.

**No-JS.** Dialogs stay hidden. Hotspots go to the `?o=` list, as today.

**Food text.**
1. Add `item_food_line(array $item, bool $homeCooked)` in `crafting.php` beside `buff_text()`. Same output.
2. Call it from `item_facts()` (`items.php:109`), `shelves.php:209`, `pantry_view.php:203`, and the shop sheet in `shop_tile()`.
3. Shop line goes between `$descH` and `$info`.

**Test plan.**
- `tests/craft.sh` (`:48-57` already check cmap and p2row): count `dialog.craftpop` per area. Per tab, rows equal the `?o=` list count. No `style=` or `<script>` in popover HTML.
- `tests/craft_tags.php`: unchanged.
- Extend `tests/itemsq.sh` and `tests/shopbasket.sh`: a food shop tile shows `⚡` and minutes.
- Run via `tests/ci_suites.sh`. Manual check at 360, 390, 1400 wide, light and dark.

**Risks.**
- Can-craft fix moves recipes out of "Ready". Visible count change.
- Recipes overlap objects (globs), so one recipe shows in several popovers. Expected.
- Pantry has its own row model and jar limit.
- A dialog inside `.shelves` would collide with shelf handlers. Keep it outside.

## 6. Ordered steps
1. [S] Fix Can-craft in `sh_craft_entries` (`shelves.php:175`): add station and energy. Effort S.
2. [S] Add `craft_pop_html()` in `craft_map.php` from `$all` + `craft_tag_match()`. Effort M.
3. [S] Call it in `craft_shelves.php` after line 45. Effort S.
4. [S] `item_food_line()` in `crafting.php`; swap the four call sites. Effort S.
5. [S] `assets/craftpop.js`: delegated click, tabs, focus return. Effort M.
6. [S] `.craftpop` CSS block in `style.css`. Effort S.
7. [S] Pantry popover with its own grouping (optional v2). Effort M.
8. [H] Extend `craft.sh`, `itemsq.sh`, `shopbasket.sh`. Effort S.
9. [H] CHANGELOG line and 390/1400 screenshots. Effort S.

## 7. Open questions for the owner
1. Popover row: open the recipe in the shelf (today's Make rules, one more tap), or craft inline?
2. OK to move recipes blocked by a missing building or energy out of "Ready"? Changes counts.
3. Pantry scene in v1, or cooking, tools, garden, decor, building first?
4. Shop sheet: buff and energy for every edible item, or only dishes?
5. Include the Brewroot energy perk in the home-dish energy number, or keep it hidden?

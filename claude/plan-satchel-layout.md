# Plan: Satchel layout (tiles, popovers, one home per item)

Investigation only. No game code changed. Not committed. Paths under `game/`.
Fresh DB counts (walk.sh copy, /tmp/satchel-audit): broken 56, decor 62, flower 173, food 243, forage 71, guide 14, misc 16, mulch 3, part 126, produce 217, seed 387, soil 11, supply 9, tool 58.

## 1. How the Satchel is built today

- Query: `includes/satchel_view.php:15-18` (user_items JOIN items, qty > 0).
- Group rule: `includes/shelves.php:36-39` `sh_bag_group()`. broken -> tool; packet -> seed; category in SH_BAG_GROUPS -> itself; anything else -> other.
- Groups: `shelves.php:25-26`. Eleven keys: seed, produce, flower, food, soil, mulch, forage, tool, decor, arrangement, other. Owner's list (8) omits Food, Decor, Arrangements.
- Other = category part + misc + guide + supply (165 kinds on a fresh install).
- Kind tag: `shelves.php:85`. Broken tool / Seed packet / Guide, else `ucfirst(category)` for Other (so "Part", "Misc", "Supply"), else group label with trailing "s" stripped.
- Show (?cat=): `satchel_view.php:19-22`, counts `:29-30`, empty categories hidden `:61`.
- Sort (?sort=): `satchel_view.php:23-25`, sorting `:32-46`. Default "type" = shelves in group order. Any other sort = one shelf "list" `:48-49`.
- Search: ?q= server-side on name only (`shelves.php:135` hay; `satchel_view.php:31`). Live filter in JS: `assets/site.js:2072-2089`.
- Layout: `satchel_view.php:56-90`. Shelves: `shelves.php:253-284` (details.shshelf, a.shpill, div.shpanel hidden, all in page). Crafting reuses it: `craft_shelves.php:119`.
- Entry + actions: `shelves.php:59-139` (status `:81`, eat/read/open/mend forms `:93-123`, Sell/Gift `:124-127`).
- Opening an item: pill tap opens its panel inline (`site.js:2034-2057`, ?open=id). No script: pill is a link (`shelves.php:270`). Forms POST to `inventory.php:10-39`.
- Dialog patterns: `site.js:1-10` (gvOpenDlg/gvCloseDlg), `site.js:1554-1580` (isheet), `includes/craft_map.php:142-178` + `assets/craftpop.js:1-30`. CSP `includes/functions.php:164`: no inline JS or style.

## 2. Duplicates (where each type is shown)

| Type (fresh-DB category) | Satchel today | Belt | Crafting (makes) | Other |
|---|---|---|---|---|
| Tools (tool, 58) | Tools shelf, In use / Spare tags | Per-job best tool table `inventory.php:66-69, 101-111`; best_tool `tools.php:187` | Crafting > Tools (17 recipes, `crafting.php:17`) | Garden jobs use best_tool |
| Broken tools (broken, 56) | Tools shelf + quick Mend `shelves.php:123` | Mend sub-tab `:129-142` AND Broken list `:143-147` on EVERY sub-tab | none | 3 places |
| Building materials: Dressed Stone, Rope, Timber Plank (part) | Other, tag "Part" | none | Crafting > Building (14 recipes, `crafting.php:18`) | Crafting > Tools ingredients (Hiking Staff uses plank + rope); Market stall lists part `shop.php:172` |
| Silk Thread (part, decor recipe output) | Other | none | Crafting > Yard & decor | none |
| Fern Tea (soil, no edible) | Soil (NOT Other) | none | Crafting > Garden supplies (`garden` recipe, fiddleheads:2) | Garden "Work in" picker `garden.php:246, 494, 632` |
| Worm Tea, Shell Meal, Kelp Meal, Plain Compost, Rich Loam, Rock Dust, Wood Ash, Worm Castings, Earthworm (soil) | Soil | none | Garden supplies (Earthworm: no recipe) | Garden picker |
| Garden Tonic (soil; output of potions recipe) | Soil + panel link "Pour on a garden square" `shelves.php:115-116` | none | Crafting > Potions | Garden picker |
| Leaf Mould, Straw Mulch, Wood Chips (mulch) | Mulch | none | Garden supplies | Garden "Spread" picker `garden.php:247, 603`; Wood Chips also a Timber Plank ingredient |
| Food Scrap, Cardboard Sheet (supply) | Other, tag "Supply" | none | Food Scrap: input to Plain Compost. Cardboard: no recipe | Compost bin scraps (tests/cook.sh:77) |
| Healing potions (supply) | Other, Drink buttons `shelves.php:112-114` | none | Crafting > Potions | Quick Drink |
| Cooked dishes, pot outputs (food, 85 recipes) | Food | none | Crafting > Cooking pot strip `craft_shelves.php:60-76` (in-progress and Collect) | none |
| Pantry jars (food, 156 recipes) | Food (e.g. Strawberry Jam, tests/pantry.sh:114) | none | Crafting > Pantry (`pantry_view.php`) | Jar badge `craft_map.php:73-76` |
| Flowers (flower, 173) | Flowers | none | none | Arrange tab picker `arrange.php:32` (inventory.php:50 links there) |
| Arrangements (arrangement) | Arrangements + "Enter the weekly show" `shelves.php:105-107` | none | none | Arrange tab `arrange.php:97-99` |
| Seeds, packets (seed 387, packet) | Seeds | none | none | none |
| Decor (decor, 62) | Decor + "Place in yard" `shelves.php:118` | none | Crafting > Yard & decor (15 recipes) | yard.php |
| Guides (guide) | Other, tag "Guide" | none | none | Read button |
| Misc (misc, 16: Camp Kit, Clay Pot, Wet Clay...) | Other, tag "Misc" | none | none (no recipe outputs misc) | none |

Holdings shown inside Crafting (conflicts with "make only"): "You have" ingredient lines `shelves.php:82-85, 142-151`; Shopping list `craft_shelves.php:98-113`.
Owner corrections: fern tea is Soil, not Other. The Satchel has 11 groups, not 8.

## 3. Proposed taxonomy: 8 tiles, one home each

| # | Tile | items.category in | sh_bag_group change |
|---|---|---|---|
| 1 | 🌱 Seeds | seed, packet | none |
| 2 | 🥕 Crops & finds | produce, forage | merge forage into produce (SH_BAG_GROUPS + sh_bag_group) |
| 3 | 🌸 Flowers | flower, arrangement | MAP: arrangement -> flower |
| 4 | 🍲 Kitchen | food | none (label "Food") |
| 5 | 🪱 Soil & mulch | soil, mulch | merge mulch into soil. MAP by slug: cardboard-sheet, food-scrap -> soil |
| 6 | 🧰 Tools | tool, broken | none |
| 7 | 🧱 Materials & decor | part, decor | MAP: part gets a key (today falls to other). Decor stays |
| 8 | 🧪 Potions & more | supply, guide, misc | MAP: supply, guide, misc get a key (today fall to other) |

- Add a singular `kind` per tile. The kind tag currently uses rtrim(label, "s") (`shelves.php:85`), which breaks for "Materials & decor".
- Garden Tonic stays in Soil & mulch (one home). Crafting Potions still shows it can be made.
- Belt keeps: the BEST tool per job, wear and Mend for worn tools, Upgrades pointer to Crafting > Tools. Broken list on the Mend sub-tab only. Spare tools: Satchel only.
- Crafting keeps: recipes you can make, with Make buttons. Drop "You have" lines and the Shopping list if approved.

## 4. Popover design (existing dialog pattern)

- Tiles: 8 `<a class="shtile">` squares (emoji, name, "N kinds · ×M"), href `?cat=<tile>`. Styles in `assets/style.css`.
- One `<dialog class="picker shpop" id="shpop-<tile>">` per tile, placed OUTSIDE `.shelves` (like craft_shelves.php:46) so the shelf handler never sees it.
- Dialog contents: pickhead (h3 + ✕ `data-pop-close`); search (client filter on data-hay, Enter = ?q=); filter chips as links (All, In use, Untasted, Rare: `f=`); Sort select (pickform GET); rows = existing a.shpill + div.shpanel. Row tap opens its panel inside the dialog.
- Open/close: new delegated `assets/shpop.js` (craftpop.js:4-30 shape). Esc and the X close; focus returns to the tile (craftpop.js:27-29).
- No-JS: tile = link `?cat=X`; chips, sort and search show above the list. Keep params cat, sort, q, open; add f; keep cat=untasted.
- Each item renders once (one home), so ids `i<id>` and `shp-i<id>` stay unique.

## 5. Test impact (tests/*.sh)

- `itemsq.sh:35-38`: one pill per item (`class="shpill`, `id="i`), one panel per item (`shp-i`), "grouped by type" expects `class="shshelf sh-seed"`. Update if shelves are renamed.
- `itemsq.sh:44`: `class="shpill off"`. `itemsq.sh:53`: sort=az must keep exactly one `class="shshelf `. Dialogs must not add shshelf.
- `images.sh:37`: `class="shpill`. `flowers.sh:29,52,138`: ?cat=flower / arrangement / seed must still render the list (flsvg).
- `craft.sh:75-76`: "Drink (+75% health)", "Pour on a garden square" in the page. `tools.sh:29`: Belt table. `yard.sh:166`: 'Decor' in page. `pantry.sh:114`: 'Strawberry Jam' in page.
- `polish_audit.js:9`, `shots.js:5`: re-shoot. No test greps "By type", "Show", "Sort" or the search text.

## 6. Ordered steps

1. [S] M: groups and mapping. shelves.php:25-39 (new keys, slug overrides, singular kind). Also shelves.php:85.
2. [S] M: Satchel tiles and per-tile dialogs. satchel_view.php:56-90 restructured. Keep cat/sort/q/open; add f.
3. [S] S: assets/shpop.js (delegated open/close/filter) and assets/style.css (.shtile, .shpop). Load like craftpop.js.
4. [H] S: Belt. Drop the Broken list from non-Mend sub-tabs (inventory.php:143-147).
5. [S] S: Crafting. Drop Shopping list (craft_shelves.php:98-113) and "You have" lines (shelves.php:82-85) if approved.
6. [H] S: update itemsq.sh:35-53 expectations; add tile checks; refresh help text (satchel_view.php header, inventory.php:97).
7. [S] S: verify. php -l, walk.sh, itemsq.sh, flowers.sh, craft.sh, shots.js (390px and desktop). Total: M to L.

## 7. Open questions for the owner

1. Eight tiles with merges (Crops & finds, Flowers, Soil & mulch, Materials & decor, Potions & more), or keep 11?
2. Garden Tonic: Soil (current) or Potions?
3. Food Scrap and Cardboard Sheet: move to Soil & mulch by slug (code map), or change their category in the data?
4. Crafting: drop "You have" lines and the Shopping list (pure can-make view), or keep "Still need" only?
5. Untasted: keep as a chip on Kitchen, or a tile of its own?

# Changelog

Newest first. Condensed. Dates 2026-10-17 to 2026-10-18.

## 2.0.35
- Fixed (broke in 2.0.31): garden bed icons were printed as escaped `<img` text; `tile_icon_html` in `includes/yard.php` now checks the `'<img class="phtile'` prefix.
- Fixed: `install.php` now requires `includes/pixel_art.php`, so a fresh install no longer dies on undefined `pixel_has()` while seeding items.
- No schema change.

## 2.0.34
- Trek map drawn from 46 Stitched Toy pixel tiles in `assets/img/trek` (`TK_PIXEL_TILES` switch; the player keeps their own gnome, `TK_PIXEL_ME` false).
- All sticker, icon and bust art now has no cream halo and a 1 px black border (map tiles and scenes unchanged).
- Style guide PDF rebuilt with an Aseprite / Stitched Toy section.
- No schema change.

## 2.0.33
- Stitched Toy carried across the rest of the site: garden, satchel, shops, kitchen/crafting, jobs, town/folk, rest stops, treks (party, plan, camp, scene pop-overs), maps chrome, games pages (race, guess, letters, practice results), festival/today, Almanac, puzzles (library + play mode), admin.
- style.css chrome sections snapped to the art palette in place (off-palette hex/rgba to nearest palette colour in CIELAB, white text to cream, black to umber), literal radii squared, blurred shadows made hard 2 px offsets, chrome gradients made stepped bands; trek pop-over frosted-glass blur removed. Game art (tool games, dig/memory/mushroom boards, yard + fences, pests, race track, mycelium maps, trek tiles, tilemap, mini-map, chest) left as drawn.
- New v2.0.33 block: panels get a crisp 2 px edge + hard drop (borders kept so selected states still recolour them); rest-stop types mapped to palette families (gold, ember, soil, moss, water, dusk, petal; admin-made hues keep the old formula) with a stitched banner and stepped dawn/dusk bands; garden plot framed; rarity tokens and dark-theme area defaults on the palette.
- puzzles.css: square board/tray, 2 px dot table, hard drag shadow, stitched win card; admin.css: framed sections and toolbar. `theme-color` / manifest colours now umber felt + cream. admin/hybrids.php inline `style=` (blocked by the CSP) replaced by class `qty`.
- No logic, class or ID changes. No schema change.

## 2.0.32
- Site layout restyled in the Stitched Toy look to match the pixel art: colour tokens (light + dark + area hues) now come only from the art palette (cream / umber felt, moss, gold thread); square pixel frames (box-shadow, notched corners, lit upper-left, 2 px lower-right drop) on boxes, tiles, tabs, chips, inputs, menu tiles, rail boxes and puzzle cards; felt-toy buttons that press down; umber felt header, phone bottom bar and footer with a gold hem stitch; area-colour title ribbon with a gold seam; stitched prize/event/hero cards; stitched `hr` with a button knot. No soft shadows or rounded corners left in the shared chrome.
- New UI art `assets/img/ui/` (button, felt-light/dark/umber tiles; Aseprite source `tests/gen_ui_chrome.lua`). Logged-out front page and How to play: square felt cards, scene and card pictures shown at whole-number scales only (1x/2x; phone cards side-by-side at 1/2).
- CSS only (style.css section 1 tokens + new block at the end, landing.css); no class or ID renamed, no PHP markup change. Player news entry added. No schema change.
- Fixed: the status strip (desktop) snapped its first chip half out of view when the chips overflowed (~900 px): `scroll-padding-inline`.
- Style guide PDF rebuilt (Part C tokens, type/space tables, component shots incl. a new stitched-card demo). `tests/build_guide.py` now also runs on Windows (file URLs, date format, pdftotext encoding).

## 2.0.31
- Pixel art (Stitched Toy) wired in: PNG-first art loading with SVG fallback (ph, ico, animals, landing, stops, gather), pixel flowers/bouquets (tinted), layered pixel gnome avatar, pixel chest, new puzzle GIFs, icons and share card. Puzzles page now uses the site layout. Art guide: Part D addenda. No schema change.

## 2.0.29
- Logged-out homepage and How to play page reworked in the Hearthlight look (warm hero card, one primary button, picture tiles, centred on desktop, real headings in guide folds); 7 landing scenes restyled. Review: claude/landing-review.md. No schema change.

## 2.0.28
- Art only: six weak icons redrawn (clap, party popper, watering can, flatbread, sailboat, grain); guide PDF rebuilt. No code or schema change.

## 2.0.24
- Emoji second pass: JS now shows our own icons (`gvIco()`, `gvIcoLine()`, `gvIcoNode()`, `gvLeads()` in `site.js`; no icon = emoji stays). Done in chest, fighton, gather-games, pest, tilemap, trekfight, trekscene, site.js toasts / crop select / energy lines, spit.js canvas gnome. CSS pin + leaf `content:` emoji are background icons.
- Fixed (broke in 2.0.23): Mushroom win celebration (checked for a leading 🏆 that PHP had swapped to an image), "New Almanac pages" toast folding, 🧺/🐦 toast ranking. `gvLeads()` handles both forms.
- `creature_pic()` (layout.php): duel box and lair boss use the creature's art when it exists, else the emoji icon. NPC portraits NOT used for `npc_icon()` (portraits are 400x500, per NPC; icon sites are species text).
- No schema change.

## 2.0.23
- Emoji are replaced by our own hand-drawn icons at render time (`includes/emoji_icons.php`, `ico_start()` output buffer): map of 480 emoji -> 269 `ico-*` icons (`includes/data/ico_map.php`, built from `tests/ico_map_source.json`). Admin setting `ico_swap` (default on; off = plain emoji). Player-typed text goes through `eu()` so it stays emoji.
- Small-icon pen mode in the Hearthlight restyle (ICO_HALO 6.0 u / ICO_OUT 3.4 u; large stickers keep 3.2 / 1.9).
- NEW Admin > Art & style guide: 36-page PDF (`tests/build_guide.py`, text in `tests/guide_src/`), download from the page. Art-rules text reconstructed from `tests/hearth.py`.
- world.php: 1 px sideways scroll fixed.
- JS-built and CSS `content:` emoji stay emoji for now (second pass, see todo "Emoji leftovers"). Test: `php tests/emoji_icons.php game`.

## 2.0.22
- Art only: all 1428 placeholder SVGs restyled in the Hearthlight look (warm palette, same names and viewBoxes, no code or schema change). No player news.

## 2.0.2
- Puzzles locked to admins for now (setting "Games: Puzzles open to every player", off by default). The Games tile is hidden for players.

## 2.0.1
- Treks: trailmates rebalanced so any party can win Chapter II bosses (all 20 parties 76–95% vs Pinch and Thrum). Riddles give 2 tries. Old campsites (2 in Chapter I, 3 in Chapter II): free rest, small ambush chance, optional KO checkpoint. Daily trek item cap setting (off by default). Unused text slots hooked up.
- Road: the "in sight" timer counts down live; clearer "then on to" wording.

## 2.0.0.1
- Puzzles: animated jigsaw game (puzzles.php, Games hub tile). No prizes, nothing saved on the server.
- New picture: Swaying Sunflower (generator: tests/gen_puzzle_sunflower.py). Also 6 pictures from the Jiggy Jigsaws source.
- Fitted to the site CSP: own CSS/JS files, pictures as files (no blob:, no web fonts).

## 2.0.0
- Treks Chapter I: story text bodies written as drafts for the 89 slots that had none (status draft, editable in Admin > Trek text).
- Upgrade step fills any empty trek body from its draft. Never overwrites a body Joshua wrote.
- Version numbering: 1.9.99 is followed by 2.0.0.

## 1.9.9
- Treks audit fixes across Chapters I and II; corrupt-state safety; new audit tests.
- Admin trek text: bad-input guards. Security pass (~45 bad-input POSTs, XSS, concurrency).

## 1.9.8
- Shop Buy/Sell as picture tiles with a quantity sheet and live total.

## 1.9.7
- Yard: tapping a glowing building collects and returns to the garden.

## 1.9.6
- Today page centring fixes.

## 1.9.5
- Treks no longer use gnome level for balance (`trek_base_level` 15). Chapter I/II retuned.

## 1.9.4
- Road choice cards, villagers and travellers met on roads, per-wonder text.
- Treks Chapter II-b: 15 new spots, riddle signposts, camp-to-camp travel, Slide, cold rest.

## 1.9.3
- Road life: anti-repeat for creatures, problems, finds; weather/season conditions; ambient road lines.

## 1.9.2
- Treks Chapter II-a "The Weeping Clay". Trek text editor upgrades (chapter tabs, drafts, in-game pencil).
- Today page merged into one page.

## 1.9.1
- Treks chapter engine: per-chapter runs, interlude hub "The Shard Hollow", data-driven chapters. MySQL migration verified live.

## 1.9.0
- Player's own gnome in Treks. Leave / Climb-out confirmations. Security fixes for Treks POSTs.

## 1.8.x
- 1.8.0 Treks Chapter I "The Wilting Rows" (party campaign). 1.8.4–1.8.8 fight redesign, tactics, auto playback, trail events, trek levels with milestone XP, map art.

## 1.7.x
- 1.7.0 Reactions merged into guestbook stamps. 1.7.2 Jobs → "Tasks" tabs; Together page. 1.7.3 menu regroup, desktop A4 side menu. 1.7.5 Tasks badge, Today greeting.

## 1.6.x
- 1.6.0 Mycelium cross-section world map and 14 region maps. 1.6.5 Dark mode default. 1.6.8 Email verification at sign-up, opt-in reminder emails, error log rotation.

## 1.5.x – 1.0.x
- 1.5 gathering mini-games; rest-stop cap. 1.4 garden animals, Seed Spitting physics. 1.1 crop breeding. 1.2 quail/silkworm/tortoise, player mentors. 1.0.0 "The Hollow Wakes Up": clock, seasons, weather, rest stops rewrite, orders, market day, social.

## 0.x
- Pre-1.0 history (regions, landmarks, gathering, crafting, trading, Job Board, admin updater, security pass). See git history.

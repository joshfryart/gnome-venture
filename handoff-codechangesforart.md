# Code changes needed to use the new pixel art

Companion to `HANDOFF.md` (section 6c). The art is drawn and zipped; **no game code has been changed**. This file lists what has to change in the game repo (`github.com/joshfryart/gnome-venture`, folder `game/`) so the art shows up, and how to do it without breaking anything. Line numbers refer to the repo as cloned on 2026-10-22 (sparse clone at `C:\Users\hello\AppData\Local\Temp\gv\`).

Work in a branch. No pushing or publishing without Josh's say-so.

## 0. Rules for every change

- **Additive, with fallback.** Check for the new file first, fall back to the old SVG/inline drawing if it is missing. Nothing breaks if a file is absent, and Josh can roll back by deleting files.
- **CSP is strict:** `default-src 'self'; img-src 'self' data:; style-src 'self'; script-src 'self'` (`includes/functions.php:158`). No inline `style=""`, no external hosts. SVG presentation **attributes** (`image-rendering`, `filter`, `color`) are fine; `<style>` blocks and `style=` are not.
- **Pixel art must scale crisply.** Every `<img>`/`<image>` showing a pixel PNG needs `image-rendering: pixelated` (CSS class in `assets/style.css`, or the `image-rendering="pixelated"` attribute inside SVG). Display sizes are not integer multiples of the canvas (64px art shown at 24/40/64 px), so expect some unevenness at 24 and 40; note it, do not blur.
- Test every page that shows the thing, at the real sizes, in dark and light themes if the site has both.

## 1. Getting the files onto the server

Two zips in `upload-zips\`:

| Zip | How | What it does |
|---|---|---|
| `gnome-venture-images-part1of3 / 2of3 / 3of3.zip` | Admin → Images, one at a time | 1,434 `ph` PNGs. The uploader (`includes/art_upload.php`) only accepts item/creature/NPC/nav-icon/building slugs and saves them under `uploads/items|creatures|npcs|nav|buildings|skins|yard/`. Everything else (`banner-*`, `stage-*`, `broken-*`, `tile-*`, ...) comes back "unmatched" by design; those are the ones that need section 2. |
| `gnome-venture-game-folder-overlay.zip` | Unzip over the game folder | 71 files under `game/`: `assets/img/flowers-pixel/`, `assets/img/gnome/`, `assets/img/puzzles/*.gif`, `assets/img/chest*.png`, icons, `share-card.*`, and `favicon.ico`. New art goes in **new folders**, so nothing existing is overwritten except the same-name GIFs, icons, favicon and share card. |

The full set (1,826 PNGs mirroring the repo folders) is in `final\png\`. The folders other than `ph` (`ico`, `animals`, `flowers`, `games`, `gather`, `landing`, `stops`) are **not** in the zips yet; they are static files the code references by path (section 2).

## 2. Static art: .svg references to .png (the big one)

About 90 `.svg` references in 20 files. The loaders:

- `includes/items.php:134` `art_path()`: whitelists `uploads/` or `assets/img/` **png/jpg/webp**, plus `.svg` only under `assets/img/animals/` and `assets/img/ph/`. So PNGs elsewhere under `assets/img/` already pass; `ph/*.png` and `animals/*.png` do **not**.
- `items.php:154` `ph_path()`: hard-codes `'assets/img/ph/' . $name . '.svg'`.
- `includes/emoji_icons.php`: the `ico/` icon set (274 files) swapped in for emoji; it scans `ico_dir()`.
- `includes/stop_pass.php:19`: reads a `stops/*.svg` file and **inlines** it (`preg_replace('/^<svg /'...)`), so it needs an `<img>` path instead.
- Other files with `.svg`: `assets/gather-games.js`, `pest.js`, `site.js`, `style.css`, `tilemap.js`, `trekmap.js`, `includes/admin_resources.php`, `almanac.php`, `animals120.php`, `animals140.php`, `friends.php`, `games.php`, `garden_critters.php`, `garden_world.php`, `yard.php`, `index.php`.

**Recommended approach (one helper, then mechanical swaps):**

1. Add `art_url(string $relNoExt): string` that returns `<rel>.png` if the file exists, else `<rel>.svg`. Use it in `ph_path()`, the emoji swap, `stop_pass.php` (emit `<img>` when PNG), and the JS/CSS spots.
2. Widen `art_path()` regex to allow `png` under `assets/img/ph/` and `assets/img/animals/`.
3. Add the pixelated CSS class to `<img>` output of `art_img()`, `ph_img()`, and the emoji swap's `<img>`.
4. Upload the remaining folders from `final\png\` to the matching `assets/img/` paths **as PNGs next to the SVGs** (do not delete the SVGs yet).
5. Check each of the 20 files above: grep `\.svg`, replace via the helper, load the page.

Hand-check these specifically: busts (NPC portraits were 400×500 in the original SVG pipeline; ours are **80×100**, so the displayed size needs an integer-friendly scale or leave as is), banners/tiles/scenes that are drawn at half size and written at 2×, and anything rendered as a CSS `background-image` in `assets/style.css`.

Unchanged and safe: `ph/palette.json` (never touch).

## 3. Same-name drop-ins (no code needed)

- `assets/img/puzzles/*.gif` (7): same names, same sizes, same frame counts and timings.
- `icon-32/192/512.png`, `apple-touch-icon.png`, `favicon.ico`, `share-card.jpg` (plus an extra `icon-16.png` and `share-card.png`). Same names and sizes. Check `manifest.json` and the `<head>` icon/og:image tags still point at them; clear caches (`url()` adds a `?v=` itself). The favicon holds 16 and 32 only (the original also had 48 and 64).

## 4. Flowers (needs real code, not just file swaps)

Files: `includes/flower_art.php`, `assets/arrange.js` (JS mirror of the same maths), `assets/style.css` (`.flsvg*`), `data/flower_looks.txt` (shape + tint per flower).

Today the heads are SVG files whose petals use `currentColor`; each is inlined into an SVG with `color="<tint>"` (`flower_head_g()` line 116). The PNGs are not recolourable that way, so:

**New files** (`flowers-pixel/`): for each of the 12 shapes `daisy rose tulip lily sunflower bell star pom orchid poppy spike cluster`: `<shape>.png` (full, for preview), `<shape>-petals.png` (**neutral grey, tint this**), `<shape>-centre.png` (fixed colour, draw untinted on top). All 64×64. Also `vase|jar|basket-back.png` and `-front.png` (200×150, same canvas as the old `viewBox="0 -30 200 150"`), `sprig-leaf|fern|eucalyptus.png` (64×96, stem base at (32,96), tip (32,8) as before), `packet.png` (64×64, label panel left empty).

**How to tint without breaking the CSP:** inside the inline SVG, use `<image href=".../x-petals.png" width="64" height="64" image-rendering="pixelated" filter="url(#tint-RRGGBB)"/>` with a per-tint filter in `<defs>`:

```
<filter id="tint-d9773a" color-interpolation-filters="sRGB">
  <feColorMatrix type="matrix" values="R 0 0 0 0  0 G 0 0 0  0 0 B 0 0  0 0 0 1 0"/>
</filter>
```

where R,G,B = tint channel / 255 (this is an exact multiply for the grey petals). Notes:
- The current code says "no ids, so any number can share a page". Filter ids break that rule, so name them by tint hex (`tint-<hex>`); duplicates on one page have identical content and are harmless. Emit each filter once per SVG, or once per page.
- The petals multiply to about **80% of the swatch colour** (bases are mid-light grey). Multiply the matrix gain by about 1.25 (values may exceed 1; they clamp) to land on the swatch colour, or lighten the petal bases in the art. Josh's call (open question in HANDOFF).
- `flower_dried_tint()` and `flower_mix()` already compute the tint hex; reuse them unchanged.
- Draw order per head: `-petals` (tinted), then `-centre` (untinted).
- Position: the old head `<g transform>` still works; put the image at x=0,y=0,w=64,h=64 inside it.

**Arrangements** (`arrangement_inner()` line 157, mirrored in `assets/arrange.js` line 37): change vessel back/front, sprigs and heads to the `<image>` versions. Vessel images go at x=0,y=-30,w=200,h=150 inside the existing `translate(0, my-16)` group. Sprig images at x=0,y=0,w=64,h=96 inside the existing `translate(-32 -96)` group. The `$seed`/crc32 maths and slot positions stay identical so PHP and JS still draw the same picture. `flower_vessel_parts()` currently splits one SVG on `<!--front-->`; replace with two images.

**Still vector after this:** the stems and the little leaves (`#3f8f4f`, `#4f9d5d` paths) are drawn in code. They will look flat next to pixel heads. Options: leave, or ask for pixel stem/leaf pieces as a follow-up art job.

**Seed packet:** `flower_packet_svg()` replaces `<!--HEAD-->` inside the packet SVG with a tinted head. With `packet.png`, draw the packet image, then the tinted head (scaled to about 0.5, centred in the label panel at roughly x17..47, y26..51).

Keep the old SVGs as the fallback when a PNG is missing.

## 5. Gnome builder (`gnome_avatar()`)

`includes/gnome.php:531`. Draws one 80×100 SVG from paths with `data-part="hat"|"beard"|"band"|"star"` and colours from `gnome_hat_color()`, the beard colour/dye, and `calling_tier()`. Used in 17 places (`gnome.php`, `profile.php`, `town.php`, `welcome.php` preview, `back.php`, `index.php`, `adventure.php`, `layout.php`, `sinks.php`, and **`trek.php:351` and `trek_art.php:316`**, which regex-extract the inner SVG markup and re-embed it at 24px, so the new markup must keep being a single `<svg ...>...</svg>` with a `viewBox="0 0 80 100"`).

**New files** (`assets/img/gnome/`, all 80×100, stack at 0,0): `gnome-shadow`, `gnome-body`, `gnome-face`, `gnome-beard` (tint), `gnome-hat` (tint), `gnome-band`, `gnome-star`.

Draw order: shadow, body, face, beard (tinted), hat (tinted), band if tier ≥ 2, star if tier ≥ 3. Same SVG wrapper, same width/height maths, `<image ... image-rendering="pixelated">` for each layer, and the same tint filter as section 4 using `gnome_hat_color()` and the beard colour. Dyes and the 8 hat / 6 beard swatches keep working because they only produce a hex.

Known art notes: the hat/beard outlines are dark neutral grey, so deep tints go very dark (about 80% of swatch, see the gain note above). The star sits 2 px lower than the old SVG. Ears were added to the face. If the PNG layers are missing, fall back to the existing vector avatar.

## 6. Chest (`assets/chest.js`)

Line 12 holds the chest as an inline SVG string with classes `cs-svg`, `cs-bodyg`, `cs-lid`, `cs-glow`, `cs-inside`, animated by CSS/JS (lid opens, glow). New art: `chest.png` (closed, full), `chest-body.png`, `chest-lid.png` (64×64, same canvas, stack exactly). Replace the string with an SVG that contains `<image>` for body, a `<g class="cs-lid">` wrapping the lid `<image>`, and keep a vector/CSS glow ellipse. The lid's rotation origin must be moved to the hinge (back edge of the lid, around y≈30 in the 64-grid): check the existing `transform-origin` in CSS. The lid has not been tried rotating, and has no halo below its rim band; verify it does not show a gap when open. Fall back to the old string if the images fail to load.

## 7. Admin (optional)

`admin/images.php` / `includes/art_upload.php`: nothing is required. If Josh wants the admin page to accept flower or gnome art later, add new `art_match()` kinds (`flower-<shape>[-petals|-centre]`, `gnome-<part>`) saving to `uploads/...`. Not needed if the overlay zip is used.

## 8. Code-drawn art NOT yet converted (decide per item)

These are generated by PHP/JS as vector shapes and were left alone on purpose. Replacing them means new sprite/tile art plus new drawing code. Suggested order by visibility/effort, each as an additive "if pixel set exists use it":

1. `includes/yard.php` fence/wall/hedge pieces (`fz-*`): note the **piece PNGs `{slug}-{end|straight|corner|tee|cross|gate}.png` already exist in the admin zips and the uploader supports them**; this may be only a render check.
2. Goals jar (`hollow_goals.php:295`), letter envelope (`letters.php:247`), weighing scale (`games.php:837`), sink graphics (`sinks.php:369`): small single objects; draw sprites, swap the `<svg>` for an `<img>`.
3. Maps (`maps.php`, `maps_myc.php`), tilemap backgrounds (`tilemap.php`), delve map, trek minimap, and trek tile art (`trek_art.php`): big procedural scenes. Needs a tileset plus a tile-placement renderer; a design job, not a swap. Ask Josh before starting.
4. `welcome.php`, `puzzles.php`, `arrange.php`, `site.js`: check what each draws before deciding.

## 9. Test checklist

- A page with each changed thing, at its real sizes: Gnome page, Profile, Town list, Welcome preview, Trek screen (24px avatar), Arranging screen (PHP and JS must match), Almanac, Garden, Games, Chest opening, a puzzle with each GIF, the share card via a link preview, the favicon in a fresh tab.
- Missing-file fallback: temporarily rename a PNG and confirm the old SVG/vector shows.
- Strict CSP: open the console, confirm no CSP violations.
- Hard reload (cache-busting `?v=` is added by `url()`, but old SVG may be cached).
- Rollback = delete the new folders/PNGs; fallbacks restore the old look.

## 10. Open questions for Josh

1. Tint darkness: scale the filter gain by about 1.25 (code), or lighten the hat/beard bases (art)?
2. Should stems and leaves in bouquets get pixel art too?
3. `pig.gif` has a thin umber ring around the locked eye; keep or remove?
4. NPC portraits are 80×100 (not 400×500): fine if scaled by CSS?
5. Convert the code-drawn maps/tiles/trek art, and in what order?
6. Switch all static `.svg` references to `.png` (section 2), then remove the SVGs, or keep both?

## 10. Update 2026-10-27 (route art)
New pixel art for the road-walk ribbon is in `game/assets/img/route/` (felt strip, pins, thread, gnome token, goal flag, danger pips, thorn pin); sources in `aseprite-source/route-mockups/` (Lua scripts draw them with the Aseprite CLI). The code that uses them is `route_ribbon_html()` and `route_fold_html()` in `game/includes/maps.php`. Still unused art: `scenes/map-world*.png`, `map-*.png`, `stop-*.png`. Big procedural maps (section 8, item 3) still need Josh's go-ahead.

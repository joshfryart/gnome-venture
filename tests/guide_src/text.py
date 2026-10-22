"""Text of the Gnome Venture style guide. Edit here, then run: python3 tests/build_guide.py
Markup (tiny): '## h2', '### h3', '- bullet', '1. step', '> note', '| a | b |' tables (2nd line = separator), ``` code ```,
**bold**, `code`. A line holding only {{NAME}} or {{NAME:arg}} is filled in by build_guide.py (palette, catalogue, screenshots ...).
SECTIONS = (id, part, title, body). part: 'front', 'a', 'b', 'c'."""

ABOUT = """
This is the one reference for how Gnome Venture looks: the Hearthlight art style, the inline icon system, and the UI style sheet.
It is **rebuilt from the real files**, so the icon pages and colour tables are never out of date.

## How to read it
- **Part A**: the art rules for every picture (placeholders, creatures, folk, nav).
- **Part B**: inline icons (`ico-*`): how emoji are swapped for our own drawings, and how to add one.
- **Part C**: the UI style sheet: colours, type, spacing, components, and Joshua’s UI rules.

## Rebuild it
```
python3 tests/build_guide.py
```
Output: `game/assets/guides/Gnome-Venture-Style-Guide.pdf`. Download it in Admin, Images & art, Art & style guide.
Run it whenever an icon, a colour token or a rule changes. Text lives in `tests/guide_src/text.py`; layout in `guide.css`; component demos in `components.html`.

## Where the facts come from
{{SOURCES}}
"""

A1 = """
Hearthlight is the house style of every placeholder picture, creature, folk portrait, nav icon and inline icon. One look, three layers, drawn on a **64 x 64 grid**. All widths below are in grid units **u** (u = shorter side / 64; so 1 u = 1 px at 64 px). Pen weights below are for large stickers (pictures, creatures, portraits). **Icons (`ico-` names) use heavier pens**: see the icon rules.

*Note: these rules are written from `tests/hearth.py`, `hearth_all.py` and `claude/handoff.md`. Text source for this PDF and for `claude/art-style-guide.md` is this file; no older hand-written guide was found.*

## The three layers
1. **Cream halo**: a thick sticker edge round the whole silhouette, `#f2e4c0`, 3.2 u out from the shape (stroke 6.4) on large stickers; icons use 6.0 u. It lifts the picture off dark and light pages alike.
2. **Umber line**: a warm near-black outline, `#2a1a10`, 1.9 u out from the shape (stroke 3.8) on large stickers; icons use 3.4 u. Never pure black.
3. **Cel shade**: one crescent at the lower right, clipped to the silhouette, in a dark tint of the picture’s main colour, opacity .34. One light direction for every picture.

{{LAYERS}}

## Small rules
- Eyes: umber pupil (at least 1.25 u radius) on a cream disc, with a small cream glint on big pupils. A dark eye on a dark fill gets a cream disc and a ring so it reads.
- Inner contour: 1.0 u umber line at 55% opacity between big shapes. Dropped first when a file runs over its size cap.
- Wood and shafts keep body: no wooden line thinner than 6.6 u wide.
- Hairlines (legs, feelers, whiskers) snap to 1 or 1.5 u. Under 1 u they vanish at 16 px.
- Folk portraits (`npc-*`) use 60% halo and outline, because the portrait frame crops them.
- Nav icons (24 px) use whole-number coordinates, and rounded corners under 3 u are dropped.
- Ground shadow: umber at 42% opacity, an ellipse under standing things. Inline icons have none.

## Palette
Every picture starts from the shared art palette (`assets/img/ph/palette.json`). The restyle then nudges a few cold steps warmer (table below). Shade = the next darker step of the same family.
{{PALETTE}}

### Warmth nudges (old to new)
{{REMAP}}

### Shade tints
The cel crescent is not black. It takes the tint of the picture’s dominant hue.
{{TINT}}
"""

A2 = """
## Specimens
Existing Hearthlight pictures from `assets/img/ph/`, shown at 96 px.
{{SPECIMEN}}

## Size caps
Every SVG has a byte budget. The restyle walks down a **trim ladder** until a file fits.
{{CAPS}}

### Trim ladder (richest first)
1. Full: rim light, ambient shade, glint, inner contour, material marks.
2. No rim / AO / glint.
3. Also no inner contour.
4. Also no material marks.
5. Capsule silhouettes: ellipses become round-cap strokes, small corner radii vanish.
6. Capsules, no inner contour.
7. Capsules, no inner contour, no marks.

## Checks every file must pass
- No `<script>`, `<style>`, `style=`, filters, gradients, `xlink`, `href`, `<image>`, `<foreignObject>`, `<use>` or `on*=` handlers.
- `viewBox` unchanged by the restyle.
- Every `clipPath` id is unique (`hl-<name>`), so two icons on one page never clash.
- Rendered at 64 px, the halo must **not touch the 1 px frame** and the picture must fill at least 3% of it. Scenes, tiles, fences and `npc-*` busts are exempt (they bleed by design).
- Names: lowercase, hyphens. Prefixes mean something: `creature-`, `npc-`, `nav-`, `banner-`, `land-`, `guide-`, `tile-`.

## New or changed pictures
1. Draw plain SVG (no effects) in the game palette.
2. Restyle **last**: `PYTHONHASHSEED=1 python3 -B tests/hearth_all.py game/assets/img/ph <out>`
3. Check edges: `python3 -B tests/hearth_edge.py <out>` (0 flagged).
4. Copy `<out>/*.svg` over `game/assets/img/ph/`. Never copy `palette.json`.
5. **Never** re-run `gen_ph_*.py` over restyled files. It would undo the style.

## Known weak spots
Ember beetle eyes are hard to read. Nav festival, friends, villagers and arranging mush together at 24 px. Nav account has low contrast on dark.
"""

B1 = """
Inline icons replace emoji **inside page text** with our own Hearthlight drawings. Same look everywhere, no phone-to-phone emoji differences.

## How the swap works
- It happens at **render time**. `includes/emoji_icons.php` runs as the page’s output buffer (`ico_start()` in bootstrap) and swaps emoji for `<img class="ico">`.
- The map is `includes/data/ico_map.php`: emoji to slug, decorative flag, accessible name. Keys have no U+FE0F.
- Files live in `assets/img/ico/{slug}.svg`. **No file = the emoji stays.** So a map row can be added before the art.
- Longest match wins (a flag or family sequence beats its first emoji).
- Only text nodes are swapped. Never attributes, `<option>`, `<title>`, `<select>`, `<textarea>`, `<script>`, `<style>`, `<svg>`, `<noscript>`.
- JSON, CSV, XML, redirects and downloads are skipped. Setting `ico_swap` (default on) turns it off.
- The icon is an `<img>`: copy and paste of the page gives nothing for it.

## Player text keeps its emoji
Anything a player typed must print with **`eu()`** (emoji become `&#x..;` and the swap skips them): garden names, critter names, trade and job notes, carving titles, feedback, report details.

## Known limits
Emoji inside JS-built strings, attributes, `<option>`, `<title>` and SVG text stay emoji. Player names or notes copied into notices or flash messages (stored as plain text) can get swapped.

## Decorative or named?
- **Decorative** (most): `alt=""`. The words next to it carry the meaning.
- **Named**: the icon stands alone (energy, Petals, locked, done). Give it an accessible name in the map row.
"""

B2 = """
## The grid
Every icon is a **64 x 64** `viewBox` and is drawn as a plain silhouette first. Keep shapes chunky: it must read at **16 px**.
- Keep the artwork at least **6.5 u** away from the frame. The halo (6.0 u for icons) plus anti-alias must stay inside.
- One clear shape, 2 or 3 colours from the palette, one crescent of shade. No fine detail under 1 u.
- Pen weights for icons (the restyle adds them; `ICO_HALO` / `ICO_OUT` in `tests/hearth.py`): **halo 6.0 u, outline 3.4 u**, so the cream ring sits 2.6 u beyond the outline. Large stickers keep 3.2 / 1.9. Icons are drawn as plain shapes: the build adds the pens.
- Size cap: 4096 bytes per icon. Typical is 1.5 to 3.5 KB.

## Sizes in the game
Icons are sized in **em**, so they follow the text they sit in. At body size that is 16 to 18 px. Allowed range inline: **16 to 24 px**. Bigger art (48 px and up) is not an inline icon: use a placeholder picture.
{{ICOCSS}}

## Seen at size
{{ICOSIZES}}

## Rules for placing icons
- Icon first, then words. Never an icon alone unless it has an accessible name.
- One icon per label. Do not stack two.
- Keep the same icon for the same thing everywhere (the map guarantees it).
- Do not recolour with CSS. The icon carries its own colours and halo.
"""

B3 = """
## Add an icon in 5 steps
1. **Draw** plain SVG on the 64 grid in `tests/ico_src/ico-<slug>.svg`. Flat fills from the palette. No gradients, text or filters.
2. **Map**: add one row to `includes/data/ico_map.php`:
```
'🐝' => ['ico-bee', true],
'⚡' => ['ico-energy', false, 'Energy'],
```
   The second value is “decorative” (true = no spoken name). Use false and a name when the icon stands alone.
3. **Restyle**: `PYTHONHASHSEED=1 python3 tests/ico_build.py restyle`. This writes `assets/img/ico/ico-<slug>.svg`. Never edit that folder by hand.
4. **Check**: `python3 -B tests/hearth_edge.py game/assets/img/ico` (0 flagged) and `php tests/emoji_icons.php game`.
5. **Regenerate this guide**: `python3 tests/build_guide.py`, then upload `assets/guides/` with the release.

## Naming
- Files: `ico-<slug>.svg`, lowercase, hyphens: `ico-watering-can.svg`.
- Name the **thing**, not the emoji: `ico-gnome-hat`, not `ico-pointy-hat-face`.
- One slug can serve several emoji (variants). Do not make near-duplicates.
- Prefixes `creature-`, `npc-`, `nav-` are for pictures, not inline icons.

## Do and don’t
{{DODONT:icons}}
"""

B4 = """
Everything in `assets/img/ico/`, read when this guide was built. Each card: the icon name, the emoji it replaces (from `ico_map.php`), then the icon at **48, 24 and 16 px** on a dark chip (the game’s dark surface) and a light chip.
{{CATSTATS}}
{{CATALOG}}
{{UNMAPPED}}
"""

C1 = """
All colours are **tokens** in `assets/style.css`, section 1 (`:root`). Components never hard-code a colour; dark mode only changes the tokens. Dark is the default. Dark overrides are always written `:root[data-theme="dark"] X`, never `@media (prefers-color-scheme)`.

Since v2.0.32 (**Stitched Toy chrome**) every token is a colour from the art palette (Part A families, the Part D table, or the Part D hue-shift recipe, marked in a CSS comment): cream and umber felt, moss for the main verb, gold thread for stitches. No pure black or white. The header, phone bottom bar and footer are umber felt (`--felt`) in both themes.

{{TOKENS}}

## Area hues
Each part of the game tints its pages through `--area*` tokens set by `body[data-area]`.
{{AREAS}}
"""

C2 = """
## Type
System font stack, no web fonts: `system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif`. Body is 16 px on phones and 15 px from 721 px up.
{{TYPE}}

## Space, shape, touch
{{SPACING}}

## Pixel frames (v2.0.32)
- No `border-radius` and no blurred shadows. A panel is framed with `box-shadow: var(--frame)`: 2 px edges, lighter on the lit upper-left (`--edge-lt`), darker lower-right (`--edge-dk`), a 2 px stepped `--drop`, notched corners. Rows inside a panel use `--frame-lite`.
- Frames take no layout space: give framed things about 4 px of room inside scrolling boxes.
- Buttons are felt toys: variants only set `--b-bg --b-hi --b-lo --b-ink --b-hover`. Margins are vertical only, so full-width buttons never overflow.
- Stitches are hard-stop stripes, 4 px on / 2 px off: `--hem` on felt, `--st-h` / `--st-v` for the edge stitch on special cards (prize, event, landing hero). Ordinary boxes stay unstitched.
- Pixel images use `.pix` (`image-rendering: pixelated`) at whole-number scales only. UI tiles live in `assets/img/ui/` (made by `tests/gen_ui_chrome.lua`, written at 2x).

## Breakpoints
- **Phone first**: design for about 412 px wide, dark. Base CSS is the phone.
- **721 px and up**: tablet and desktop. Gutter 24 px, header 60 px.
- **1200 px and up**: groups in the menu stay open (`.navfixed`), two-column tiles. Content never exceeds 1392 px.
- No sideways scroll at any width. Wide things wrap, fold or scroll *inside* their own box.
"""

C3 = """
Real markup and the real `style.css`, captured at build time. Each pair: dark (default) on the left, light on the right. Since v2.0.32 they show the Stitched Toy frames.
{{SHOTS}}
"""

C4 = """
These come straight from Joshua. They are checked on every screenshot before a release.

## The rules
1. **Centre things**: text, headings, cards, buttons, result lines. Check every screenshot for it.
2. **No sideways scrolling.** Ever.
3. **Phone first.** About 412 px, dark theme. Desktop is the same design with more room.
4. **Fold explanations.** Rules, hints and long text hide inside `details.fold`.
5. **Few words.** Short labels, short lines. If it needs a paragraph, fold it.
6. **Solid buttons only for the main verb.** Everything else is `ghost`.
7. **No lone full-width button** inside a wide desktop card.
8. **Equal tile grids** for action buttons. Rows of choices use `choice_row()`.
9. **Many-option filters** are a `<select>` in a GET form (`data-autosubmit`), not a wall of chips.
10. Keep the top bar slim.

## Build rules
- CSP is `style-src 'self'`: **no inline styles**. All CSS in `assets/style.css` (new work in the marked block at the end).
- Popups are `<dialog>` with `gvOpenDlg` / `gvCloseDlg`. Confirmations use `data-confirm` or `gvAsk`. Never `alert()` or `confirm()`. Never lock body scroll.
- Tap targets are at least 44 px (`--tap`). Small buttons are 36 px with a bigger hit area.
- In-place page loads need the page in `AJAX_PAGES`.
- Art falls back in order: real art, flower art, placeholder (`assets/img/ph/`), emoji.

## Do and don’t
{{DODONT:ui}}
"""

C5 = """
## Before you ship UI
- Look at it on a 390 px dark screenshot. Then light. Then 1200 px.
- Is everything centred? Any sideways scroll? Any wall of text that should be a fold?
- Is there more than one solid button in a card?
- Did new text use an emoji? Use an icon (or a plain word) instead. Player text goes through `eu()`.
- Run `php -l`, the suites in `claude/handoff.md`, then rebuild this guide.

## Keep the guide current
- Icons changed? Run `python3 tests/build_guide.py`.
- New component class or token? Add a demo to `tests/guide_src/components.html` and a line in `text.py`.
- New rule from Joshua? Add it to section C4 and to the do / don’t lists.
- Commit the new PDF with the release so Admin can serve it.
"""

SECTIONS = [
    ('about', 'front', 'About this guide', ABOUT),
    ('a1', 'a', 'Hearthlight: the look', A1),
    ('a2', 'a', 'Limits, checks and new art', A2),
    ('b1', 'b', 'Inline icons: how they work', B1),
    ('b2', 'b', 'Icon size and grid', B2),
    ('b3', 'b', 'Adding an icon', B3),
    ('b4', 'b', 'Icon catalogue', B4),
    ('c1', 'c', 'Colour tokens', C1),
    ('c2', 'c', 'Type, space and breakpoints', C2),
    ('c3', 'c', 'Components', C3),
    ('c4', 'c', 'Joshua’s UI rules', C4),
    ('c5', 'c', 'Checklist and upkeep', C5),
]
PARTS = {'front': None, 'a': 'Part A. Hearthlight art', 'b': 'Part B. Inline icons', 'c': 'Part C. UI style sheet'}

DODONT = {
  'icons': (
    ['Draw plain SVG on the 64 grid', 'Keep 6.5 u clear of the frame', 'Make it read at 16 px', 'Use palette colours', 'Run the restyle, then the edge check', 'One map row per emoji', 'Give a name to icons that stand alone', 'Print player text with <code>eu()</code>'],
    ['Gradients, text, filters, <code>&lt;style&gt;</code>, scripts', 'Strokes under 1 u', 'Hand-edit files in <code>assets/img/ico/</code>', 'Recolour an icon with CSS', 'Put emoji in new UI text', 'Rely on colour alone for meaning', 'Expect swaps in attributes, options, titles or JS strings', 'Re-run <code>gen_ph_*.py</code> over restyled art'],
  ),
  'ui': (
    ['Centre text, headings, cards, buttons', 'Fold explanations', 'Few words, short lines', 'One solid button per card', 'Tokens for every colour', 'Dark first, then check light', 'Equal tiles for actions', '<code>&lt;dialog&gt;</code> for popups'],
    ['Sideways scroll', 'Inline styles (CSP blocks them)', 'Hard-coded colours', '<code>@media (prefers-color-scheme)</code> for dark', '<code>alert()</code> / <code>confirm()</code>', 'Lone full-width button on desktop', 'Long text walls on the page', 'Emoji in new UI (use an icon)'],
  ),
}

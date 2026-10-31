---
name: Gnome Venture
description: Cosy garden-game UI in a Stitched Toy felt-and-stitch style, phone first, light and dark themes.
colors:
  bg: "#f1ece0"
  surface: "#fff3c8"
  surface-2: "#f2e4c0"
  ink: "#2a1a10"
  ink-2: "#4a2c1a"
  muted: "#74462a"
  line: "#c9a96e"
  line-2: "#9a6b3f"
  brand: "#2f5a2a"
  brand-soft: "#c8d09f"
  brand-line: "#7ab55c"
  accent: "#e8a317"
  accent-ink: "#7a4a1f"
  danger: "#a8241f"
  danger-soft: "#f6b8cf"
  info-soft: "#a9d6ea"
  info-ink: "#1f4a6a"
  purple: "#4e3a8a"
  focus: "#25637d"
  felt: "#3d2a1c"
  felt-ink: "#f2e4c0"
  thread: "#e8a317"
  dark-bg: "#2a1a10"
  dark-surface: "#3d2a1c"
  dark-ink: "#f2e4c0"
  dark-brand: "#7ab55c"
typography:
  body:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
  heading:
    fontFamily: "system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, sans-serif"
    fontWeight: 600
    lineHeight: 1.25
rounded:
  none: "0"
spacing:
  gutter-phone: "16px"
  gutter-desktop: "24px"
  tap: "44px"
  px: "2px"
components:
  button-primary:
    backgroundColor: "{colors.brand}"
    textColor: "{colors.felt-ink}"
    rounded: "{rounded.none}"
    height: "44px"
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.ink}"
    rounded: "{rounded.none}"
---

# Design System: Gnome Venture

> Extracted from `game/assets/style.css` tokens (section 1) and `claude/art-style-guide.md` Part C and D during the polish audit. The style guide stays the long form; this file is the short, agent-readable version. Values here are copied from the code, not invented.

## Overview
"Stitched Toy": the interface looks like felt and thread. Dark brown felt chrome (header, tab bars, hero banners) with a gold dashed stitch line, cream paper cards, hard pixel corners, and pixel art with a 1 px umber outline. Warm, low-contrast, friendly. Phone first at about 412 px; desktop (from 721 px) is the same design with a side menu and right rail.

## Colors
- **Paper:** `bg #f1ece0`, cards `surface #fff3c8`, inset `surface-2 #f2e4c0`. Dark theme swaps to `#2a1a10` / `#3d2a1c` with cream ink `#f2e4c0`.
- **Ink:** `ink #2a1a10`, `ink-2 #4a2c1a`, `muted #74462a`. Never pure black; shadows are warm (`--drop #c9a96e`, dusk `#291d4a` in dark).
- **Brand:** moss green `#2f5a2a` (solid fill with cream text), `brand-soft #c8d09f`, `brand-line #7ab55c`. Accent gold `#e8a317` for energy, thread and highlights. Danger ember `#a8241f`. Info water `#a9d6ea` / `#1f4a6a`.
- **Area hues:** `body[data-area]` sets `--area*` per page family: garden moss, world water, kitchen ember, book dusk purple, market gold, community petal. Pages without an area (admin) use brand.
- **Game art tokens** (soil, plot, rarity `--r-c/u/r/l`, map sea/road) are separate from text colours and do not change in dark mode except the map.
- Focus ring `--focus #25637d` (light), `#a9d6ea` (dark).

## Typography
One system sans stack for everything (`--font`), monospace only for code. Body 1rem / 1.5 (15px root on desktop, 16px on phone). Headings weight 600, line-height 1.25. Pixel-style display lettering is art, not font. Keep lines short; long text goes in a fold.

## Layout
- Tokens: `--gut 16px` phone, `24px` from 721 px; `--maxw 1392px`; `--hdr 52px / 60px`; `--bar 56px` bottom bar; `--strip 44px` status strip.
- One main breakpoint, 720/721 px. Straggler breakpoints at 1000, 1200, 520 and 480 px exist (consolidate in the polish plan).
- Phone: slim header, status strip, content, bottom bar (Garden, World, Satchel, Here, Tasks, More) and a menu sheet. Desktop: header, status strip, left menu of grouped icon tiles, content, right rail.
- Equal tile grids for action buttons; filters with many options are a `<select>` in a GET form.

## Elevation & Depth
No blur. Depth is stepped box-shadows in the pixel grid: `--shadow 2px 2px 0 var(--drop)` and `--shadow-2` (2px outline plus 6px offset). Hero banners and tab bars are felt with a gold dashed thread.

## Shapes
Hard pixel corners everywhere: `--radius 0`, `--radius-sm 0`, `--pill 0`. Components fake stepped corners with box-shadow frames; one art pixel is `--px 2px`.

## Components
- **Buttons:** solid only for the main verb, everything else `ghost`. Tap target `--tap 44px`; small buttons may look 36 px but need a 44 px hit area.
- **Tabs (`nav.tabs`)** for sections of a page; **folds (`details.fold`)** for rules, hints, long text.
- **Cards** on `surface`, cream with a stitch or pixel frame; status chips (`--chip-*`) for energy, gold, level.
- **Dialogs** are `<dialog>` with `gvOpenDlg` / `gvCloseDlg`; confirmations via `data-confirm` or `gvAsk`; never `alert()`/`confirm()`.
- **Icons:** own pixel art `nav-*` and `ph/*` first, then placeholder, then emoji fallback.

## Do's and Don'ts
Do:
- Centre text, headings, cards, buttons and result lines.
- Keep the top bar slim; keep labels to a word or two.
- Put new CSS in the marked block at the end of `style.css`, use tokens, check dark and light.
- Use `AJAX_PAGES` for in-place page loads.

Don't:
- No inline `style=` attributes (CSP `style-src 'self'`).
- No sideways scrolling, ever (also inside strips and tables).
- No lone full-width button inside a wide desktop card.
- No walls of chips for many-option filters; no body scroll lock; no pure black.

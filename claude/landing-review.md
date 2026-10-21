# Logged-out front page + How to play: review (2026-10-21, before the Hearthlight rework)

Pages: `game/index.php` (visitor branch), `game/guide.php`, `game/assets/landing.css`, `game/assets/img/landing/*.svg`. Shots: 412 dark/light, 900, 1400.

## Hierarchy
- `h1` "Gnome Venture" repeats the logo in the top bar 200px above it. The area rule under every `h1` (`body[data-area] main h1`) is green on the front page and **purple** on How to play (guide.php sits in the "book" area): a game-page convention that looks like a stray line here.
- Two stacked 54px buttons, both brand green (solid + outlined), read as two primaries. "Log in" is repeated twice per page as a big button.
- Desktop (900/1400): the logged-out side menu (Home / Log in / Join / Rules) keeps a 220px column, so the landing sits off-centre in the viewport. Owner rule: centre everything.
- Cards on a phone are picture-left rows: 6 rows x 130px = the whole second and third screens.

## First screen, 412px dark
- Scene, name, pitch, sub line and both buttons fit (buttons at y 372–490). The "No ads" line is cut by the fold on short phones. The scene has a cold blue sky on a dark green page; nothing on the first screen says "warm".

## CTA clarity
- Three wordings for one action: "Claim your plot, it's free" (top), "Start growing" (bottom), "Join" (menu). Keep the two editable ones, drop the duplicate Log in button (text link instead).
- How to play: the CTA pair sits above the content before a visitor has read a line; keep one solid button there, make it compact.

## Copy
- Short already (1.6.3 rewrite). Card lines are one sentence each. "You are what you eat" is cute but needs its line to make sense. Guide folds are 3–5 bullets: fine. FAQ feeds JSON-LD: keep.

## Accessibility
- Headings: How to play has `h1` then nothing until the FAQ `h2`s inside the last fold; the eight fold titles are plain `summary` text, so screen-reader heading navigation sees one section. Put an `h2` inside each `summary` (valid: summary may hold one heading), FAQ questions become `h3`.
- Tap targets: "How to play" link under the buttons is 14px text (~20px tall); footer theme switch 34px. Everything else >= 44px.
- Contrast (checked tokens): muted #9aa793 on #15201a 6.6:1, light #5f6a5a on #f6f4ec 5.4:1, outlined button #9fd3a9 on #1c2a22 9:1. OK.
- Alt text: scene and card `img` have `alt=""` (decorative, the text beside them carries it). The SVGs' own `role="img" aria-label` is ignored inside `<img>`: harmless.
- Focus: global `:focus-visible` outline on buttons; summary has its own. OK.
- The headline emoji and button emoji are swapped to `ico-*` at render, so phones agree.

## Performance
- Art is 2–7KB each, lazy-loaded cards, `fetchpriority="high"` on the scene. landing.css 3KB. The page still pulls the whole 385KB style.css (shared shell): out of scope here.
- Hero `width/height` attributes (360x170) match the viewBox, so no layout shift.

## CSP
- No `style=""`, no inline `<script>` (JSON-LD is a data block). Clean on both pages in the console.

## Consistency with the game
- Buttons use 14px radius and 54px height; the game uses 6px / 44px. Cards 14px vs 10px.
- Art is flat: no cream halo, no umber line, cold `#cfe8f3` skies. Every other picture in the game is Hearthlight (sticker halo + umber outline + warm palette).
- No sideways scroll at any width (scrollWidth == innerWidth everywhere).

## Plan (done in the rework)
1. Warm the skies, run `tests/hearth_all.py` over the landing scenes (sticker halo + umber frame, same as the rest of the art). Keep file names.
2. One solid button per block; Log in becomes a text link; "How to play" becomes a ghost button (44px).
3. Centred 2-column picture tiles on phones, 3 on desktop; hero in a warm `--accent-soft` card; no area rule under the `h1`.
4. Side menu hidden at >= 721px on these two pages only (links live in the page and footer) so the content is centred.
5. Guide: `h2` inside every fold summary, FAQ `h3`; warm fold cards with the icon in a cream chip; compact top CTA.

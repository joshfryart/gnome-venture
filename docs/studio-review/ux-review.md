# UX review: app shell + top pages (v2.4.63)

Method: Claude Code Game Studios `ux-review` + `ux-design` checks (flow, hierarchy, accessibility, redundancy), applied as ux-designer / ui-programmer / accessibility-specialist. Scope: `game/includes/layout.php`, `game/assets/style.css`, `garden.php`, `town.php`, `gnome.php`, `inventory.php` (+ `includes/satchel_view.php`), `adventure.php`, `book.php`, and `screenshots/after2/*`. Read-only review: nothing under `game/` was changed. No new features; every item below is a restyle, a removal or a copy fix.

**Verdict: NEEDS REVISION** (small, safe fixes; no redesign). Tiers: P1 = fix next release (real a11y failure or clear waste of the phone's scarce space), P2 = worthwhile polish, P3 = tidy-up.

Contrast ratios are computed (WCAG relative luminance) from the token values in `style.css`. Line numbers are for the current `style.css` / files.

Mockups for P1-1, P1-2, P1-3 and P2-1: `mockups/index.html`.

---

## P1

### P1-1. Two buttons open the same menu on a phone (redundant UI, wasted header width)
- Evidence: `layout.php:99` header `button.menubtn` ("Open menu") and `layout.php:395` bottom-bar `button.menubtn.more`, both `aria-controls="sidenav"`. `style.css:207-208` keeps the header one as an icon on phones; `screenshots/after2/garden-light-390.png` shows ☰ top right and "More" bottom right. `site.js:1787` wires all `button.menubtn` via `querySelectorAll`.
- Problem: same action twice; the header at 390px carries logo + energy + coins + ☰ and already needed a workaround (`style.css:3207-3213`, logo ellipsis). The thumb zone (bottom bar) is the better home.
- Change (CSS only, `style.css` marked block at end):
  ```css
  @media (max-width: 720px) { body.game:has(.bottombar) header .menubtn { display: none; } }
  ```
  Header keeps logo, energy, coins; logo gets ~52px back. Onboarding / admin / logged-out have no `.bottombar`, so they keep the header button.
- Risk: low. JS uses `querySelectorAll`, so one opener is enough; focus-return goes to the button actually used. `:has()` is already used in this file (`style.css:363`, `3068`). Check one thing: a browser without `:has()` simply keeps both (today's behaviour).

### P1-2. Selected-state controls fail contrast (1.72:1)
- Evidence: `style.css:6674` `.cptab[aria-selected="true"]` and `style.css:6765` `.shpdchip.on` set `background: var(--accent)` (#e8a317) with `color: var(--on-fill)` (#f2e4c0): **1.72:1** (needs 4.5:1). Every other selected tab (`style.css:371`) uses `--brand-fill` + `--on-fill` (6.4:1).
- Problem: the active recipe tab and the active Satchel filter chip are nearly unreadable; also the selection is signalled by colour only.
- Change: use the same pair as `.tabs a.on`:
  ```css
  .cptab[aria-selected="true"], .shpdchip.on { background: var(--brand-fill); color: var(--on-fill); border-color: var(--brand-fill); }
  ```
  Optional second cue: `.shpdchip.on::before { content: '✓ '; }`.
- Risk: low; pure colour change. Dark theme uses the same `--brand-fill`.

### P1-3. Status line hit areas on a phone are about 18px tall (target 44px)
- Evidence: phone strip `style.css:3122-3123`: `.stsum` is 36px high but the links inside (`.stl`: level, hearts, season, festival) are `inline-flex` text-height (~18px). The badge already gets a padded hit area (`style.css:6645-6646`); the links do not. Footer links were fixed the same way at `style.css:6642`.
- Change: extend the existing trick, no layout change:
  ```css
  .stsum .stl { position: relative; }
  .stsum .stl::after { content: ''; position: absolute; inset: -14px -6px; }
  ```
  (36px row + 14px up/down = 44px.)
- Risk: low. Hit areas of neighbouring links can overlap by a few px; with 12px gaps (`.stsum gap`) they do not.

### P1-4. Satchel tiles use 10.6-11.8px text and 35-45% opacity
- Evidence: `style.css:6754-6757`: `.shtile b` .74rem (11.8px), `.shtile small` .66rem (10.6px), `.shtile.empty` opacity .45, `.dim` .35; `.shtb` badge `.62rem` (9.9px) white on #2e8b3a = **4.31:1** (`style.css:6758`). Tiles are 84px wide on 390px (4 columns), so 12.5px labels still fit ("Materials" is the longest).
- Change: `b` 13px, `small` 12px (colour `--muted`, 6.7:1), `.shtb` 11px with `background: var(--brand-fill); color: var(--on-fill)`; `.empty` from opacity to `color: var(--muted)` + dashed border (already there); drop `.dim` opacity to .6. Same for `.shtile .shtm`.
- Risk: low; tiles are `aspect-ratio:1` so text growth is capped by the box; verify "Materials" at 13px does not wrap past two lines (`overflow-wrap:anywhere`).

### P1-5. Other text on colour that fails 4.5:1 (new 2.3.100+ blocks use hard-coded colours)
| Line | Rule | Pair | Ratio | Fix |
|---|---|---|---|---|
| `6658` | `.sqchip.warn` | #e08a2d on #fff3c8 | 2.41 | `color: var(--accent-ink); border-color: var(--accent)` (6.7) |
| `6664` | `.npkchip.low .npkm` | #e0704f on #fff3c8 | 2.86 | `color: var(--danger)` (6.4) + the existing ▼ glyph stays the non-colour cue |
| `6679` | `.cpfx` (`var(--good,#2f8a3a)`) | on #fff3c8 | 3.92 | `color: var(--brand-ink)` |
| `6681` | `.cpneed` (`var(--bad,#c0392b)`) | on #fff3c8 | 4.9 ok, but see below | `color: var(--danger)` |
- Root cause: `--good`, `--bad`, `--bg-2` are **not defined anywhere** (0 matches in `style.css`), so these rules always use the hard-coded fallbacks and ignore dark mode. Map them to existing tokens (`--brand-ink`, `--danger`, `--surface-2`) instead.
- Risk: low; colours only. Check dark theme once (`--brand-ink` is light green there).

---

## P2

### P2-1. Desktop (>=1200px) says everything twice
Evidence (`layout.php`, `style.css:1689-1697`, `screenshots/after2/garden-dark-1400.png`):
| Shown | Where | Duplicate |
|---|---|---|
| Season, day, weather | strip `hollow_chip` `layout.php:345` | right rail "The Hollow" `layout.php:726` |
| 🍳 / 🫙 N ready | strip `layout.php:347-348` | rail "Pots" `layout.php:730` |
| Go to Today | sidebar `layout.php:690` | rail "Today" box `layout.php:725` (a lone link) |
| Petals (coins) | header pill `layout.php:104` | sidebar `navstatus` `layout.php:688` |
| Log out | header `layout.php:110` | sidebar `navlogout` `layout.php:706` |
| Rules / Privacy | sidebar `navfoot` `layout.php:707` | page footer |
| Energy | header pill `layout.php:103` | strip `.st.energy` (only hidden on phones, `style.css:214`) |
- Problem: against Product Principle 3 ("calm over busy"); the strip wraps onto a second row on 1200-1400px (`style.css:6631`).
- Change (smallest set, all hide-only):
  1. At >=1200px hide the strip's season chip, pots/jars chips and energy chip (the rail and header carry them): `.statusstrip .st.energy, .statusstrip .st.hot:not(:has(a[href*="gnome.php"])), .statusstrip .hollow { display:none }` inside `@media (min-width:1200px)` (verify the real class on `hollow_chip`).
  2. Remove the rail "Today" box (`layout.php:725`) when the side menu is visible, i.e. drop `$today` (the menu's Today tile is at the top).
  3. Hide `.side .navlogout` on desktop (`@media (min-width:721px)`); the header has Log out.
  4. Drop the Petals line from `navstatus` on desktop, keep it for phones (the header pill shows it there too, so it can go on both; keep the destination text).
- Risk: medium-low. The strip chips are what the 1000-1199px range (no rail) relies on, so keep them below 1200. Rail sections are server-rendered, so nothing JS depends on the strip chips (check `site.js` for `.st.hot` live updates before shipping).

### P2-2. Satchel page repeats its own name four times
- Evidence: `inventory.php:44` `<h1>👜 Your Satchel</h1>`; tab "👜 Satchel" `inventory.php:46`; `satchel_view.php:60` and `:114` `<h2 class="p2title">👜 Satchel <small>N kinds · M things</small>`; "🧰 Your toolbelt →" link at the foot `satchel_view.php:136` duplicates the "🧰 Belt" tab (`inventory.php:48`).
- Change: keep h1 (document title for screen readers), change the h2 to a counts line only (`<p class="muted p2title">N kinds · M things</p>`), delete the `.shbelt` link. On the Belt view, the pouch strip (`inventory.php:99-110`) and the "Garden jobs" table repeat the same tool list: keep the table, fold the pouch strip into `details.helpfold` or delete it on phones (`.toolbelt .belt { display:none }` under 720px).
- Risk: low. Check nothing greps for the `shbelt` link text (tests under `tests/`).

### P2-3. Phone menu sheet targets are below 44px
- Evidence: `style.css:233-253`: `.navhome` 38px, `.navfeedback` 40px, `.navlogout .linkbtn` 40px, `.navtile` 54px (ok), `.navstaff summary` 36px, `.ntb` 10px text.
- Change: set those four to `min-height: var(--tap)`; the sheet already has `max-height:92vh; overflow-y:auto`, and the extra 4-8px does not push it past the screen.
- Risk: low.

### P2-4. Town: breadcrumb + tab row + h1 say the same thing
- Evidence: `town.php:124` crumbs `World > Town > Spot`, `town.php:144-148` `.placetabs` (starts with "Square" = the town), `town.php:150` h1 with the spot name. `.placetabs` is `position:sticky` and on desktop `overflow-x:auto` (`style.css:377`) = sideways scroll, forbidden by DESIGN.md; on phones it wraps into a 3-column grid (`style.css:3065-3068`) which can cost 3-4 rows above the content.
- Change: when `$spot` is set, drop the last two crumb segments (keep only "World >" as the back link), and make desktop `.placetabs` wrap like other tabs (`flex-wrap: wrap; overflow: visible` in the `min-width:721px` rule, delete `.placetabs { flex-wrap: nowrap; overflow-x: auto; }` from `style.css:377`).
- Risk: low-medium (the sticky behaviour of tabs on desktop changes once they wrap; make `.placetabs` `position: static` there too).

### P2-5. "Hover" copy on a phone-first game
- Evidence: `garden.php:525` "Hover a bed to see its yard bonuses." Phones have no hover; beds open with a tap.
- Change: "Tap a bed to see its yard bonuses." (use `Tap` only; keep desktop hint out). Same class of text: `adventure.php:370` instructions are one long paragraph; fold it into a `details.helpfold` ("How to move") because it is read once.
- Risk: none (copy).

### P2-6. My Gnome header repeats what the shell already shows
- Evidence: `gnome.php:113-116`: a status line with level + XP, garden count and **⚡ energy**: energy is in the header pill (`layout.php:103`), level in the strip, garden count in the "gardens" fact tile (`gnome.php:177`). `gnome.php:111` "Today →" repeats the menu's Today tile. Overview shows a "Stats" box with an "Open stats →" link (`gnome.php:183`) while "Stats" is also a tab (`gnome.php:161`).
- Change: remove the ⚡ and 🏡 parts of `p.status` (keep level + XP, that is the page's subject), remove the "Today →" link, keep "See your profile".
- Risk: none functionally; tests asserting that text, if any, need an update.

---

## P3

- **P3-1. Garden switcher repeats the h1.** `garden.php:341` h1 is the garden's name and `garden.php:348-354` (only with 2+ gardens) lists the same name as the active button. Fine as a control, but add `aria-pressed` / `aria-current="true"` to the `button.tab.on` (colour is the only "selected" cue today). The "Help" tab (`garden.php:375`, hired helpers) and the "🤝 Need help?" fold (`garden.php:433`) share a word with different meanings; rename the tab "Helpers".
- **P3-2. Garden info card.** `garden.php` "Garden level 3 · "The Green-Thumbed" · 12 of 16 beds planted" (screenshot) repeats the strip's "Garden level" chip on desktop. Keep on phones, hide the level part >=1200px.
- **P3-3. Style cascade debt (makes every header change risky).** `.hdr-pill` is styled in 10+ places (`127`, `206`, `3213`, `3603`, `3625`, `4591-4599`, plus `2347` for `.empty`); `.menubtn` 5 times. Consolidate into one block in a later cleanup; do not do it in the same release as P1.
- **P3-4. Rounded corners against the "hard pixel" rule.** `style.css:6758` (`border-radius:9px`), `6707` (`50%`), `6601` (`4px`), and 54 other `border-radius: Npx|50%` declarations. Replace with `var(--radius)` (0) where it is chrome (not a dot/avatar).
- **P3-5. Strip tab badges are 11px** (`style.css:3070`); raise to 12px and keep `min-width:1.5em`.
- **P3-6. Almanac header.** `book.php:108-112`: "pages N of M (X%)" text + progress bar + desktop strip chip "📖 Almanac 42/310" say the same; drop the percentage from the text (keep the bar and counts).
- **P3-7. Adventure.** `adventure.php:306` "What do you do?" / "Will you trade?" (a generic line above buttons that already say what they do); remove or keep only the riddle one. `adventure.php:392` and `:426` both state the knock-out rule ("you wake up..."); keep the one in the fold.
- **P3-8. Reduced motion.** Many `prefers-reduced-motion` blocks exist (`style.css:513`, `1505`, `2399`...) but `gvsheet` (`style.css:~264`) and the menu sheet slide are not covered; add `@media (prefers-reduced-motion: reduce){ .side{animation:none} }`.

---

## Checked and fine (no change)
- Skip link, focus ring (`style.css:111`, 2px, 6.3:1+ in both themes), `aria-current` on nav, `role="img"` + label on header pills, progress bars have `aria-label` (`layout.php:357,363`).
- Status strip no longer scrolls sideways on desktop (`style.css:6631-6634`) and uses a flat line on phones; gardens/tabs wrap instead of scrolling on phones (`style.css:3065`); `.gvtabs` wraps (`6648-6652`).
- Bottom bar: 56px, 5 destinations + More, badges have labels; Garden pip is a count, not colour-only.
- Muted text: 6.7:1 light (#74462a on #f1ece0), 7.5:1 dark.

## Suggested order
1. One CSS-only PR in the marked end block: P1-1, P1-2, P1-3, P1-4, P1-5, P2-3 (no PHP).
2. A tiny PHP/copy PR: P2-2, P2-4, P2-5, P2-6, P3-1, P3-6, P3-7.
3. P2-1 after checking the 1000-1199px range on a real device.
4. P3-3/P3-4 as a separate refactor.

Not assessed: screen-reader pass and 200% zoom (never tested per PRODUCT.md), real-device checks, `index.php` Today page (out of scope).

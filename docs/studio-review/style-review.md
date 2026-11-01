# Style consistency review: CSS and UI (v2.4.63)

Roles applied: art-director (visual identity vs DESIGN.md / art-style-guide) and technical-artist (cost, mechanics, safe changes). Asset-audit rule followed: every number below was measured from the files; anything not measurable is marked NOT ASSESSED. Nothing under `game/` was edited and nothing was committed.

Scope: `game/assets/style.css` (560,565 B, 6,784 lines, 5,747 rules; 116 KB gzipped), `puzzles.css` (40,344 B), `catfish.css` (48,202 B), `landing.css` (9,429 B). Method: a small CSS rule parser (comments stripped, media context tracked) plus grep over every `*.php`, `*.js`, `*.json`, `*.txt` under `game/` (6.6 MB of source; `uploads/` and `assets/img/` excluded). Line numbers refer to the files as they are now.

Mockups: `mockups/style-components.html`, `mockups/style-type-spacing.html`, `mockups/style-tokens-theme.html` (before/after, light and dark side by side).

## Summary

| # | Finding | Size | Priority | Mechanical and safe? |
|---|---|---|---|---|
| 1 | Dead selectors | 213 rules / 16.4 KB high-confidence (upper bound 622 rules / 37.6 KB) | P1 | Yes, after a DOM/grep gate |
| 2 | Hardcoded colours instead of tokens | 537 hex literals (288 distinct); 163 equal a token value; 71 near-miss | P1 | 163 yes; 71 need a look |
| 3 | Straggler breakpoints | 12 extra widths in style.css, 4 in puzzles, 2 in catfish, 3 in landing | P1 | No (layout), needs screenshots |
| 4 | Competing button, tab, chip, card systems | 4 button families, 12+ tab families, 104 `*card*` classes | P1 | No, design decision |
| 5 | Overridden and duplicated rules | 363 shadowed declarations (about 7.6 KB), 8 exact duplicate rules, `:root` tokens split over 8 blocks | P2 | Yes for exact duplicates and same-selector shadows |
| 6 | Dark-theme handling | 79 dark rules, 27 with raw hex; 3 token mismatches | P2 | Partly |
| 7 | Typography and spacing scale | 34 px font sizes, 183 of 886 off the proposed scale; 1,290 of 2,968 spacing values off a 2/4 px grid | P2 | Partly |
| 8 | Catfish and Puzzles are off-system | 8, 12, 999 px radii; grey fallbacks; white on gold 2.17:1 | P2 | Yes for radii and contrast |
| 9 | Undefined custom properties | 5 tokens used but never defined | P1 | Yes |
| 10 | Pure-black shadows, DESIGN.md drift | 33 `rgba(0,0,0,..)`; DESIGN.md states w600 headings, code ships w800 | P3 | Yes |

Bytes savable without any visual change: about 16.4 KB dead rules + about 7.6 KB shadowed declarations + 0.5 KB exact duplicates = about 24.5 KB raw, 4.4% of style.css. Token swaps (finding 2) are byte-neutral. A whitespace/comment minify step, not a CSS edit, would take style.css from 116,110 B to 89,498 B gzipped (see finding 11).

---

## 1. Dead selectors (P1)

Method: every class in every selector, tested against all tokens in the PHP/JS/JSON/TXT source. A rule is "fully dead" only if every comma alternative contains an absent class (a class inside `:not()` does not count). Then split by confidence.

| File | Classes in CSS | Absent from all source | Fully dead rules (upper bound) | Bytes | High-confidence (tier A) rules | Tier A bytes |
|---|---|---|---|---|---|---|
| style.css | 2,776 | 593 (435 with no dynamic-name evidence) | 622 of 5,747 (7.6% of rule bytes) | 37,614 | 213 | 16,384 |
| puzzles.css | 243 | 41 | 20 | 772 | 0 | 0 |
| catfish.css | 328 | 108 | 45 | 2,047 | 2 | 121 |
| landing.css | 41 | 3 | 15 (19.6% of file) | 1,555 | 15 | 1,555 |

Tier A means: class name is 5+ characters, has no 1-3 letter prefix (`t-`, `d-`, `r-`, `c-`, `p-`, `s-`) and no trailing digit, so it is not a PHP-composed variant like `.t-fence`, `.grade.g0`, `.gbr3`, `.cfrar.r-rare`, `.pjl2`. The upper-bound column includes those composed names, which are very likely alive; do not delete them without a runtime check.

Evidence (tier A, all confirmed by a second grep returning only the CSS file):
- landing.css: `.lp-scene` (17, 51), `.lp-cards` (34, 40, 55), `.lp-card` and its `img/h3/p` children (35-44, 56-57): about 1.5 KB. `index.php` uses `lp-hero`, `lp-frame`, `lp-bubble`, `lp-pitch`, `lp-sub` but none of these. (They appear in the DESIGN.md stitched-box list only through `.lp-card` inside multi-selector rules in style.css, which is a separate rule.)
- style.css `.landing .lhero`, `.landing .lshots` (1483-1496): no element has class `landing`.
- style.css families: `.gocard` (14 rules, lines 1279-3544, 1,311 B), `.regioncard` (9, 809-817), `.statcard(s)` (7, 748-782), `.goextra` (3546-3558), `.trekfight*` (3507-3689), `.shoprow` (1348-1356), `.spotcard` (1235-1239), `.navgroup` (187-189), `.gnomecard` (184-185, 4633), `.advbox` (856-859), `.explorecall` (942-943), `.statusstrip .st.lowenergy` (149-150), `.sortopts`/`.sortpick` (363-377, 575-577, 4731-4735: the selector appears inside shared tab lists, so only the single-class rules die).
- Whole sections were superseded rather than deleted: sections "Adventure bar" (834-975), "Almanac" (628-742) and "Games" (1011-1097) hold 215 of the dead rules (16.2 KB) in `5 pages`, and the v0.9-v1.0 "waves" hold 209 more under the upper-bound count.

Proposed safe change: delete the 213 + 15 + 2 tier A rules (selector lists get pruned, not whole rules, where a comma list mixes live and dead names).
- Gate before deleting: (a) rerun the token grep including `tests/`, `claude/*.html` and the forum/BBCode renderer (`includes/*bb*`); (b) crawl the 82 top-level pages as a logged-in and logged-out user with a script that dumps `document.querySelectorAll('*')` class names; confirm the dead set is disjoint; (c) screenshot diff at 412 and 1280 px.
- Risk: low for tier A; medium for the upper-bound list (dynamic class names). Class names stored in the database (forum posts, shows, signposts) are NOT ASSESSED because no DB is attached.
- Keep landing.css `.lp-*` rules if the front page redesign (Hearthlight cards) is planned; otherwise remove them.

## 2. Hardcoded colours not using tokens (P1)

Counted in declarations only (custom-property definitions excluded):

| File | Hex literals | Distinct | Equal to a DESIGN.md token | Notes |
|---|---|---|---|---|
| style.css | 537 | 288 | 163 | plus 184 `rgba()`, 16 `hsl()` |
| puzzles.css | 8 | 6 | 0 | `#2f7d4f` x3 as a `var(--accent, ...)` fallback |
| catfish.css | 211 | 33 | 16 | 136 are `#000` in `mask-image` (legitimate); real hardcodes: 75 |
| landing.css | 1 | 1 | 1 | clean |

Top literals that equal a token (swap to `var()`; byte-neutral, zero visual change):
`#2a1a10` x34 (`--ink` / `--ol`), `#fff3c8` x21 (`--surface`), `#f2e4c0` x17 (`--surface-2` / `--on-fill`), `#74462a` x12 (`--muted` / `--edge-lt`), `#f5cf6a` x12 (`--thread-bright`), `#4a2c1a` x8, `#f1ece0` x7, `#c9a96e` x6, `#3d2a1c` x5, `#2f5a2a` x4, `#a8241f` x3, `#e8a317` x3 (+8 in catfish).

Near-misses (within 14/255 of a token; probably typos or drift, 71 in style.css, 12 in catfish, 2 in puzzles):
- `#3a2410` x12 (racelane 2704-2705, catfish `.cfpop` 225): umber outline near `--felt #3d2a1c`/`--ol #2a1a10`.
- `#f4f1ea` x5 (1153-1156 picket fence art) and `#f4f0e0` x4 (trekmap focus 3944-3946): near `--bg`.
- `#a8231f` x4 (`.cptab[aria-selected]`, line 6674), `#a8281c` x2: `--danger` is `#a8241f`.
- `#2f6026`, `#2c5e2a`, `#234d22` (hedge art 1161-1213): moss variants; art, keep or move to `--t-*` art tokens.
- `#a06a40` (1043, 2377): `--line-2 #9a6b3f`. `#f2d06b` (1104): `--thread-bright`.

Off-palette inventions with repeat use: `#ffffff` x21 (focus outlines and counters on art), `#4f9a45` x6 and `#1f3f3a` (button lit/shaded edges, 4701), `#b07a10` x13 (gold deep, also `--chip-gold-line`), `#c0443a` x3 (hp bar, 6507), `#e08a2d`, `#f5c542`, `#58b34a`, `#e0704f`, `#2f8a3a`/`#2e8b3a`, `#c0392b`, `#8a5a2c` in the late blocks (6612-6700), `#e0aa48` and `#b07a28` (`.fbtn`, 5595), and catfish greys `#ddd x8`, `#eee`, `#333`, `#ccc`, `#999`, `#888`, `#3a3a44`.

Proposed changes:
1. Mechanical: replace the 163 exact-equal literals with the token (script, regex on declarations only, never inside `--token:` definitions, `url()`, or art blocks listed in section "yard"/"flowers"). Risk: low; some literals are intentionally fixed in dark mode (felt that "stays light in dark mode", style.css 5527). Skip rules inside `.gx`, `.vlcard`, `.ocard`, `.gcard`, `.fbtn`, `.mtabs` where the felt is deliberately theme-independent.
2. Snap the 71 near-misses after a visual check (design call): about 20 are art (fences, hedges), the rest are chrome.
3. Add 6 tokens to section 1: `--gold-deep #b07a10`, `--btn-hi #4f9a45`, `--btn-lo #1f3f3a`, `--btn-hover #2f6a3a`, `--danger-fill #a8241f` (see section 6), `--hp #c0443a`. Use them in the 40 or so places above.
4. Rewrite late-block fallbacks (`var(--good,#2f8a3a)`) to tokens (`--brand`, `--danger`).

## 3. Straggler breakpoints (P1)

DESIGN.md: one main breakpoint 720/721; "straggler breakpoints at 1000, 1200, 520 and 480 exist". Measured (rules and bytes inside each `@media`):

style.css
| Query | Rules | Bytes | First line |
|---|---|---|---|
| max 720 | 516 | 42,189 | 206 (keep) |
| min 721 | 129 | 8,021 | 36 (keep) |
| min 1200 | 94 | 9,014 | 1690 (the wide-screen shell: keep as the one documented "wide" tier) |
| min 1000 | 35 | 2,830 | 2183 |
| 721-1199 | 22 | 2,553 | 3395 |
| max 899 / min 900 | 31 / 30 | 1,188 / 1,160 | 3464 / 922 |
| max 520 / min 521 | 22 / 2 | 1,098 / 131 | 903 / 1016 |
| max 440 | 9 | 456 | 3210 |
| max 999, 721-999 | 5, 2 | 330, 92 | 3688, 6636 |
| min 1600, 1500 | 3, 1 | 190, 43 | 5184, 1697 |
| max 400, 380, 600; min 601, 801 | 4, 1, 1; 3, 1 | 178, 60, 108; 97, 59 | 5343, 5943, 4911; 1254, 1099 |

Other files: puzzles.css max 560 x25 rules (5 blocks), 640, 359, 340 and a duplicate 720; catfish.css max 519, 380; landing.css min 540, 800. DESIGN.md names 480, which does not exist as a media query (the 8 hits for 480px are `max-width` properties); it also omits 900, 600, 440, 400, 380, 800, 1500, 1600.

Proposal (design decision, not mechanical):
- Tiers: base = phone, `max-width:720` / `min-width:721` desktop, `min-width:1200` wide (rail), and one narrow-phone `max-width:400`. Map 1000/999/900/899/801/800 to 721 (or fold under 1200), 600/601/560/540/520/519/521 to 720/721, 440/380/359/340 to 400.
- Each remap changes layout between the old and new width. Needs screenshots at 360, 412, 521, 768, 1024, 1280. Start with puzzles.css and catfish.css (small), then the 61 rules at 899/900 and the 24 at 520/521.
- Risk: medium. Do not mix with finding 1 in the same commit.

## 4. Inconsistent button, card, tab and chip styles (P1, design decision)

**Buttons.** Four families with different corner, edge and weight rules:
- `.btn` (base 314-330, restyled 4701-4719): 44 px, 2 px stitched frame, lit/shaded edges, weight 700.
- `.fbtn` (5595): gold `#e0aa48`, own edge colours not in the palette, weight 800, `rgba(42,26,16,.55)` shadow.
- `.btn` variants coloured with hex rather than tokens (4713-4716: `#a8241f`, `#d6322b`, `#e8a317`, `#b07a10`); base `.btn.gold:hover` (323) hardcodes `#b07a10` and is then repainted.
- Other `*btn` classes: 27 (`gbtn`, `qbtn`, `optbtn`, `yobtn`, `belt__btn`, ...). Catfish buttons are bare `<button>` with 1 px `#ddd` borders and 8 px radius (catfish.css 321-354); `.pzchip` is a 999 px pill (puzzles.css 231).
- The base `.btn` block (314-330) is overridden by the Stitched Toy block (4701+): 100 declarations of base chrome are dead by cascade (see finding 5).
- Tap targets: `min-height` is 44 px in 103 places (`var(--tap)` 64 + 44px 39), but 40 px x40, 36 px x23, 32 px x21, 38 px x11, 30/34/28 px x11 more. DESIGN.md allows 36 px only with a 44 px hit area; only `.btn.small::after` and `.tabs a::after` provide one.

**Tabs.** At least 12 families: `.tabs`/`.chips`/`.crafttabs`/`.gardentabs`/`.ccfilter`/`.sortopts` (one shared rule, good), `.mtabs` (leather strip, 54 px, 5 columns, 5528-5540), `.gvtabs` (4 separate rule sets at 6001, 6009, 6086, 6125, 6163 and the polish override 6650; heights 36/32/auto), `.cptab` (2 px border, 44 px, 6672), `.pjtab` (puzzles), `.cftabs`/`.cfhub` (catfish, rounded), `.jqtabs`, `.st-tabs`, `.plantabs`, `.bagtabs`, `.placetabs`. Active colour is `--area-solid` in some, `--brand-fill` in others, `--accent` underline in `.mtabs`.

**Chips and tags.** 97 classes matching chip/pill/badge/tag; `.chip` is borderless with `--frame-lite` (4739), `.cfbadge` is a 999 px pill with a grey border, `.pzchip` 999 px, `.sqchip`/`.npkchip` (late block) use 1-2 px borders and rem sizes.

**Cards.** 104 `*card*` classes. `.box` is defined four times (305, 1291, 3621, 4682); the Stitched Toy `--frame` version is the live one. `.cfcard`, `.cfup/.cfshelf`, `.cfbtile` use 1 px `#ddd` and 8-12 px radii; `.gcard`, `.ocard`, `.vlcard` use felt art on purpose.

Proposal (see `mockups/style-components.html`): keep `.btn` (+ `.ghost`, `.gold`, `.danger`, `.small`), one `.tabs` (+ `.felt` variant replacing `.mtabs`), one `.chip`, `.box`/`.card` with `--frame`. Migrate the Catfish and Puzzles components to those classes in markup or by aliasing selectors in the new block. Do it one component family at a time. Risk: medium-high (touches markup in several PHP files, which is out of scope here).

## 5. Duplicated and overridden rules (P2)

- Same selector, same media context, declared again later: 294 selectors repeated (329 extra occurrences). Of those, 363 declarations are shadowed by a later one (about 7.6 KB). Examples: `h1` (95, 3622, 4575), `.banner .logo` (120, 4584, 6642), `.banner .tagline` (122, 3183, 4588), `.box` (305, 1291, 3621, 4682), `:focus-visible` (110, 4578), `hr` (100, 4697).
- Cross-layer: 212 of the 363 (about 4.7 KB) cross a section boundary. Base chrome 1-1503 is overridden by Stitched Toy 4552-4842 in 100 declarations, by the "waves" 1504-4551 in 50; waves are overridden by Stitched Toy in 23; the 4843-5399 block by 5400-end in 24.
- Exact duplicates (same context, selector and body): 8 rules, about 543 B: `.side a:hover` (164, 4625), `.mushboard .n1/.n2/.n4` (1069, 2514), `.trekplay` (3685, 4436), `:root[data-theme="dark"]` (5257, 5397), `.gx-h__sub` (5269, 5406), `.gvpage .palslots` (6122, 6179).
- Tokens are not in one place: `:root` is opened 8 times (5, 38, 2186, 2583, 4556, 5248, 5388, 5461) and dark `:root[data-theme="dark"]` 6 times (54, 2191, 2584, 5257, 5397, 5697). DESIGN.md says "put new CSS in the marked block at the end"; in practice 12 dated blocks append their own tokens.
- `!important` appears 29 times (style.css), 4 in catfish; most are legitimate (reduced motion, `.vh`, yard art overrides at 1155-1215).

Proposed safe changes (mechanical, scripted):
1. Delete the 8 exact duplicates (543 B). Risk: none.
2. For each (context, selector, property) with a later same-selector declaration in the same context, delete the earlier one (363, about 7.6 KB). The cascade cannot change because the later declaration wins for the identical selector; keep fallback pairs (`display:-webkit-box` then `flex`) by skipping properties inside one rule. Gate with computed-style diff on a page set. Risk: low.
3. Merge token blocks into section 1 in the same order (not mechanical in diff size but zero effect if order is preserved). Risk: low.
4. Longer term: remove the superseded base `.btn`, `.tabs a`, `.chip`, `.box` declarations from sections 4 and 5 instead of overriding them in section 4552+ (the 100 dead base declarations).

## 6. Dark-theme handling (P2)

Theme is chosen in `early.js` (reads `prefers-color-scheme`) and set as `:root[data-theme]`; there are zero CSS `prefers-color-scheme` rules, so no-JS visitors always get light. Acceptable, but write it in DESIGN.md.

- 79 dark rules in style.css, 73 of them component-level (8,577 B), 27 containing raw hex instead of re-assigning a token (`.st[data-dp]` 2061-2063 gradients, `.trekmap .tile` 3455, `.btn.ghost` 4713, form inset `#3d2a1c` 4727, ...). puzzles.css 7 (2 hex), catfish.css 2, landing.css 4.
- 10 uses of `:root[data-theme]` (presence selector, used only to out-rank earlier rules, 4710-4712) and 1 of `data-theme="light"`. Prefer `:root[data-theme="light"]`/tokens or `:where()`.
- Token mismatches in dark:
  1. `--danger` becomes orange `#f08a24` (line 60) while `.btn.red` hardcodes `#a8241f` (4713). Any rule reading `--danger` as a fill is orange in dark; `.btn.red` is red. Add `--danger-fill #a8241f` (both themes) and use it for fills; keep `--danger` for text.
  2. `--ink-2: #c9c5bc` (line 57) is a cool grey outside the palette; the warm equivalent is `#c9a96e` (`--muted`) or `#f2e4c0` at lower weight. Contrast of the current value on `#3d2a1c` is 7.89:1, so this is palette drift, not an a11y fail.
  3. `--muted` is `#74462a` in light and `#c9a96e` in dark; `--line` is `#c9a96e` then `#74462a`: tokens swap roles. Text in `--line` in dark (`#74462a` on `#2a1a10`) is 2.12:1; grep for `color: var(--line)` before reusing it as text.
- 201 rules put a literal hex in `color`/`background` and have no dark counterpart. Many are art or the intentionally always-light felt (5412-5650, `.vlcard`, `.ocard`, `.gcard`); the remainder (late blocks 6612-6700: `.sqchip`, `.npkchip`, `.cpfx`) are chrome on light backgrounds that become unreadable-by-accident risks in dark (for example `.cpfx { color: #2f8a3a }` on `#3d2a1c` is about 2.8:1, NOT ASSESSED visually).
- Catfish has one dark rule (`.cfrar` 33) and cool greys `#3a3a44`/`#eee`; its other surfaces rely on tokens so they follow the theme, but card fills fall back to `#ddd` if a token is missing.

Proposal: (a) add `--danger-fill`, fix `--ink-2` dark; (b) convert the 27 raw-hex dark overrides to token re-assignment where the token already exists (mechanical for 15, design call for the gradients); (c) triage the 201 with a dark-theme screenshot pass of the late-block pages (craft map, pantry, pal trips). Risk: medium for (a)/(c), low for (b).

## 7. Typography hierarchy and spacing (P2)

Font sizes in style.css: 886 px declarations (including `font` shorthand), 34 distinct values; 49 `rem`, 12 `em`. Distribution: 12 px x173, 13 px x192, 14 px x154, 11 px x52, 15 px x44, 16 px x43, 18 px x33, 20 px x26, 22 px x26, 26 px x20, 17 px x20; also 9, 9.5, 10, 11.5, 12.5, 13.5, 19, 21, 24, 28, 30, 34-56 px. 80 declarations are below 12 px.
- Proposed 10-step scale (`--fs-xs 11, sm 12, md 13, base 14, lg 16, xl 18, 2xl 22, 3xl 26, 4xl 32, hero 40`). 703 declarations (79%) already match. The 183 others: 15 px x44 (to 14 or 16), 17 x20 and 19 x6 (to 16/18), 20 x26 (to 18 or 22), 24 x11 (to 22 or 26), 28/30 x17, half pixels x31, 9/10 px x20 (to 11 floor, a design call).
- Heading hierarchy: `h1` is 22 px w600 (95), then 24 px w800 (4575), 26 px at 721+ (4576), `.ph h1` 26 px w800 (5164), `.book .bookpage h2` 22 px (650), `.toolbelt h2` 17 px (595). DESIGN.md says headings are weight 600 and line-height 1.25; the live value is 800 (4574). Decide which is right and update the loser.
- Units: puzzles/catfish mix `rem` (24 rem sizes in catfish, 49 in style.css late blocks) with the site's px scale. Because desktop root is 15 px and phone 16 px (88-89), `.85rem` is 12.75 px on desktop and 13.6 px on phone, so the same component differs by device.
- Spacing: 2,968 px values in padding/margin/gap; 1,678 on a 2/4 px grid, 1,290 not. Dominant steps: 8 (577), 6 (570), 4 (477), 10 (366), 2 (299), 12 (218). Off-scale: 14 x103, 3 x65, 1 x55, 18 x37, 5 x32, 7 x23, 9 x10, 22 x5. Gap values are the cleanest: 6 px x197, 8 px x179, 4 px x103, 10 px x101.
- Proposed 8-step spacing scale: `--sp-1 2, 2 4, 3 6, 4 8, 5 10, 6 12, 7 16, 8 24`; leave `--gut`, `--tap`. Snap 14 to 12 or 16, 18 to 16, 22 to 24, 3/5/7/9 to nearest step.

Mechanical status: add tokens now (safe). Rewriting values to tokens is not mechanical for font sizes (each +/- 1-2 px shift reflows text); spacing rewrite is mechanical only for exact matches (the 1,678 already on-grid), done in one pass with screenshot diff. See `mockups/style-type-spacing.html`.

## 8. Catfish and Puzzles stylesheets are off-system (P2)

- catfish.css: radii 8 px x6, 12 px x6, 999 px x3, 50% x3, 6 px, `50% 0` against DESIGN.md "hard pixel corners everywhere" (`--radius 0`). 33 `var()` uses against 211 hex; fallbacks `#ddd/#eee/#ccc/#999/#888`; fonts in rem. Note the two `#dc1414` placeholder outlines (373, 421).
- puzzles.css: `.pzchip` 999 px (231); `.pzchip.on { background: var(--accent); color: #fff }` is white on gold `#e8a317` = 2.17:1 (fails WCAG AA 4.5:1; large-text floor 3:1). Ink on gold is 7.72:1. Also `.gbcell.bad` `#d6372b`, `.ppsil img` filter brightness for dark (303).
- style.css late blocks (6500-6784): 7 radii not tokens (`progress.hpbar` 8 px at 6507, `.cmap-card` 12 px 6532, `.cmap-badge/-bar/-all` 999 px 6538-6548, `.cmap-strip a` 10 px 6551, `.cmap-scene` 12 px 6554, `.cmap-hs span` 999 px 6557, `.pjhome a` 999 px 6599) and earlier game blocks (`.mushboard` 14 px 2500, `.chestov .cs-card` 12 px 2558, `.pststage` 16 px 2588, `.racetrack` 12 px 2697, `.dv2*` 6-12 px 4209-4226, `.vcard` 6 px 4886, `.ysign` 6 px 1818). Total radius literals: 34 non-zero in style.css (116 are `0`, 88 `var(--radius)`, 61 `--radius-sm`, 45 `--pill`).
- The late blocks are formatted differently (single-line, no spaces, `.sqchip{border:1px solid ...}` at 6657) and use rem.

Proposed: set all 34 + 16 + 1 radius literals to `var(--radius)` (mechanical, except true circles such as avatar dots and `50%` art). Fix `.pzchip.on` to `color: var(--ol)` (one line, safe). Replace catfish greys by tokens (`var(--line)`, `var(--surface-2)`, `var(--ink)`). Risk: low-medium visual (pills become squares, which is the intended style).

## 9. Undefined custom properties (P1, safe)

Used with `var()` but defined nowhere in style.css: `--bg-2` (6657, `.sqchip` falls back to transparent), `--good` (6679, 6687) and `--bad` (6681) (fall back to off-palette `#2f8a3a` and `#c0392b`), `--card` (2858, 3522, falls back to transparent), `--panel` (1597, 1599, falls back to `rgba(0,0,0,.1)`). Others (`--zs`, `--sh`, `--sz`, `--x`, `--t`, `--d`, `--dl`, `--ox`, `--oy`) are set inline by PHP or JS and are fine.
Change: `--bg-2` to `var(--surface-2)`, `--good` to `var(--brand)`, `--bad` to `var(--danger)`, `--card` to `var(--surface)` (or delete the dead fallback), `--panel` to `var(--surface-2)`. Visual effect: `.sqchip`, `.cpfx` and `.cpneed` get on-palette colours; verify the two pages once. Risk: low.

## 10. Smaller items (P3)

- Pure-black shadows: 33 `rgba(0,0,0,..)` in style.css (18 in `box-shadow`, 5 background gradients, 2 filters) and 2 in catfish, against DESIGN.md "Never pure black; shadows are warm". Replace with `rgba(42,26,16,α)` (mechanical, same alpha). Exclude `.yard` grid lines (1128, 1218) if tuned against art.
- `#ffffff`/`white` x21 in style.css, x9 catfish, x1 puzzles: mostly outlines and counters on art; on a cream UI use `--felt-ink`/`--on-fill`.
- DESIGN.md drift: heading weight 600 (live 800), straggler list (480 does not exist; 900, 600, 440, 400, 380, 1500, 1600 missing), "`--pill 0`" while 7 `999px` literals remain.
- 29 `!important` in style.css; none need removal for this review.

## 11. Delivery and size notes (not a CSS edit)

- 45.7 KB of style.css is comments (8.2%); there are 312 blank lines and one 2,582-character line. Comments are useful as history, but a build step (strip comments and whitespace) takes style.css from 116,110 B to 89,498 B gzipped (-22.9%), puzzles 10,196 to 7,923, catfish 11,675 to 7,344, landing 2,825 to 2,054. Whether the host already minifies or compresses is NOT ASSESSED.
- style.css is 560 KB on every page. Page-specific blocks that could be split off like `puzzles.css` and `catfish.css` already are: treks (3426-4551, 89,938 B), games (2357-3425, 87,368 B). Out of scope for this review; mention for the next performance pass.

## Recommended order

1. Safe mechanical batch (one commit, script plus screenshot diff): finding 9 (5 tokens), exact duplicates and same-selector shadows (finding 5), 163 exact hex to token (finding 2), `.pzchip.on` contrast (finding 8), pure-black shadows (finding 10). About 8 KB removed, no visual change except the contrast fix and warmer shadows.
2. Dead selectors (finding 1) behind the DOM crawl gate: about 16 KB (tier A), then the dynamic-name remainder once a runtime class log exists.
3. Token additions (`--danger-fill`, `--btn-*`, `--gold-deep`, `--fs-*`, `--sp-*`) and dark fixes (finding 6).
4. Components and radii (findings 4, 8), one family at a time; then breakpoints (finding 3) with the screenshot matrix.
5. Update DESIGN.md after each step (heading weight, breakpoint list, new tokens).

Limitations: dead-selector results are static (class names created in the database or by obfuscated string building are NOT ASSESSED); no renders of the live app were taken, so visual claims (dark contrast of late-block chips, layout effect of remapped breakpoints) are marked as needing screenshots. Analysis scripts lived in the session scratchpad, not in the repo.

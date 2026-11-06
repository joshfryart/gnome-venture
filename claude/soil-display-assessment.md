# Garden soil display: assessment (no code changed)

Verified in: game/garden.php 536-690, game/includes/yard.php 515-540, game/includes/garden_logic.php:813 (soil_words), style.css 2992/3075 (soildet).
Not re-measured: pixel figures below are from the audit; panel estimates are mine.

## 1. What a player decides vs. reference

| Decision | Info needed | Keep visible? |
|---|---|---|
| What do I do now? | state (wild/tilled/settling/ready), plant, ready/thirsty, time left | Yes, always |
| Water it? | thirsty / watered-for-how-long | Yes, one chip |
| Add compost/improver? | fertility band (tired/ok/good), improver busy + timer | Yes, one chip |
| Will this crop thrive? | the crop's nutrient N/P/K level, only if < 35 or crop-specific | Only the one that matters |
| Mulch / weeds (no-till) | problems list only | Only failing items |
| What to plant? | probe best-crops (tier 2+) | Yes, empty tilled square only |
| Progress | care stars / no-till grade + bar | One line, bar OK |
| Reference | exact numbers, all 3 NPK, holds-water, soil life, upkeep checklist, "how stars work" prose, kit nag | Fold, closed |

Fact: today the fold is OPEN for planted squares (garden.php:618), so the biggest reference block shows when the player wants to harvest/water.

## 2. Duplicates confirmed in code

- Fertility x3: sqsum :543 (tired/okay/good, cut at 40/65), detail row :620 (soil_words, cut at 20/40/65/85: exhausted/tired/decent/rich/superb), tile title yard.php:536 (number). Scales disagree: 45 = "okay" vs "decent".
- NPK x2 when planted: crop "Feeds on..." help :553-556 and the table :624-628 with "feeds on this".
- Thirsty x3: :563 text, :622 row, selbar.
- Compost advice x4: :543, :641 help, :532 legend/help, garden_logic.php:1042 error. (The error is fine; it fires on action.)
- Care stars/grade in tile title (yard.php:524-530) and panel :643-687. Title is hover-only on phones, so it is useless there; harmless.
- Kit nag :630 on every square without a kit.

## 3. Options (planted square, 390px; today 1092px panel)

| | A. Tidy in place | B. Chips + closed fold + sticky actions | C. Bottom sheet for selected square |
|---|---|---|---|
| Panel height | ~480px (fold closed, dupes cut) | ~330px + closed fold bar 44px | ~0px in flow; sheet ~45% of viewport (~380px) overlay |
| Removes | open-by-default; Fertility/soil-life/watered rows from table when already in chips; kit nag to once per page; duplicate NPK line | all of A, plus sqsum prose, plantinfo help text, care-stars prose -> 1 line + "?" | all of B in-flow |
| Merges | one fertility scale (reuse soil_words everywhere; drop the 40/65 inline copy) | 3-4 status chips: state, fertility, water, crop-feeds-N/P/K if low; one "Next:" line | same as B |
| Moves | nothing | reference table + care/grade detail into the closed fold | panel DOM into a fixed sheet |
| Risk | low; fold hides numbers some players like | chip wording needs a pass; low-contrast chip states need color + text | JS needed, a11y focus/scroll-lock, desktop/phone divergence, in-place AJAX (data-inplace-show) must re-target; most breakage |
| Effort | S: garden.php, garden_logic.php (scale), style.css | M: garden.php, yard.php (title), style.css | L: garden.php, style.css, JS in assets/, tests |
| Fixes "panel starts below yard (y~998)" | No | Partly (with scroll-to) | Yes |

Critique of C: it solves the real phone problem (yard 800px sits above the panel) but costs the most and adds a new interaction surface. A and B reach 70% of the gain cheaply.

## 4. Recommendation: B, with one cheap piece of C (scroll the panel into view)

Ordered changes, each shippable alone:
1. Close the fold by default: drop `$p ? ' open'` at garden.php:618. Saves ~600px on planted squares. One line.
2. One fertility scale: put the word in one helper (soil_words thresholds, 5 bands); use it in sqsum :541-543, the row :620, and the tile title yard.php:536 (word + number). Delete the inline `$fw` copy.
3. Delete duplicate rows from the fold when the status line already says it: Watered row :622 (thirsty is in plantinfo), second NPK mention. In the table, keep only the crop's nutrient row highlighted; show the other two without prose.
4. One "Next:" line replaces compost/kit/method advice: priority order thirsty > ready > tired soil (add compost) > low crop nutrient > mulch/weeds (no-till) > till first. Reuse existing conditions; render one `<p class="next">`. Remove :641 help, :630 kit nag (move kit hint to the fold footer, once), and the "Compost... take a short time" help.
5. Status chips row replacing the sqsum two lines: `Tilled | growing Carrot | Soil tired | Thirsty`. Terse text, class-coded.
6. Care stars / no-till grade: one line `★2 Soil care · 3 harvests to ★3` with the bar; checklist (`ul.upkeep`) only lists failing items outside the fold, full list inside the fold; prose "A harvest with both earns..." goes behind a `?` details.
7. Phone scroll: on `?sel=` load, anchor to the panel (`#sqpanel`) so it starts at the top of the viewport. The existing `backtoyard` link covers return. Medium value, trivial.
8. Select-mode selbar (46->343px): collapse its action buttons into a 2-column grid, hide the "Select all crop" rows until needed. Separate task; do not bundle.

Expected panel: ~330px + fold bar vs 1092px. Whole page for planted+selected ~1600px vs 2366px.

## 5. Test impact

Searched tests/*.sh, *.php, *.js for: Soil details, Soil:, soildet, sqsum, Soil care, Soil improver, feeds on this, Holds water, add compost, Fertility, soil life, upkeep, Pick a square, selbar, Square N.

| Test | Reference | Impact |
|---|---|---|
| tests/yard.sh:57 | `grep -c 'Fertility' visit.php` (visitor page, prints a count, no assertion) | None unless the visit page changes. Echo only. |
| tests/itemsq_check.js:29-31 | `.selbar [data-sel="on"]`, `[data-open=...]` | Only if option 8 changes selbar markup. Keep selectors. |
| tests/garden100.php:278 | "too tired: pest stays" (a test name, not UI) | None |
| Others hit (cook.sh, rebuild.sh, trek_*.php, build_guide*.py, guide_src/text.py) | matched generic words (tired, upkeep) | None for this change. The guide text may describe the soil panel; check guide_src/text.py if wording is published. |

No test asserts the strings in the plan. Risk of breakage is low. Add one cheap check after change 2: scale function returns the same word for the same fertility across panel and tile title (a PHP unit in tests/garden100.php style).

CHANGELOG.md and any in-game help that quotes "Soil details" need a wording update.

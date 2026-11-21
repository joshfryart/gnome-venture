# Handoff: fold the Cat Fish restyle into the next update

Repo: joshfryart/gnome-venture. Branch with the work: `claude/catfish-code-review-6tmc22` (pushed). Current app version: 2.7.37 (`APP_VERSION` in `game/includes/bootstrap.php`).

## What to do
Fold this branch into the next release: bump the version, add a CHANGELOG entry, run the checks, and package per the repo's release process (see root README and `game/README.md`). Do not redo the work; review the three commits, fix only what breaks.

## What is on the branch
1. **Tap count fix** (`game/assets/catfish.js`, `game/includes/catfish.php`)
   - Bug: tap a fish, reload, Kibble was lower than shown. Cause 1: the page counted every tap, but the server pays from a bucket of 15 taps refilling 1 per 2 s. Cause 2: taps waited up to 30 s before reaching the server, and a reload raced the pagehide beacon.
   - Fix: `catfish_play_view` now returns `tok` (whole taps in the bucket). The JS mirrors the bucket (`tokens()`) and only adds Kibble for taps the server will pay. A tap schedules a sync 2 to 10 s later (never more than one per 10 s; the tick limit is 60 per 10 min).
   - The corner "×N" is the combo counter. It is cosmetic only (×5 jump, ×10 sparkles), no Kibble. Not a bug.
2. **Toy-Shop Shelf restyle** (`game/catfish.php`, `game/assets/catfish.css`; `catfish.js` untouched)
   - Top banner removed; a visually hidden `<h1 class="cfsr">Cat Fish</h1>` stays for screen readers.
   - Stage and Kibble counter are wrapped in `.cfdock` (pinned on phones, 2x zoom on desktop). The counter paragraph is built once into `$cfCount` and printed inside the dock when the stage exists, else in the old card.
   - Upgrades are cream tiles with red price tags (CSS only, same markup and ids). The More hub is a row of drawers.
   - All new CSS is one block at the end of `catfish.css`, headed `2.7.38 Toy-Shop Shelf`.
3. **Dark mode for the restyle** (same CSS block)
   - Colours come from `--cf-*` variables on `.cfpage`, overridden under `:root[data-theme="dark"] .cfpage`. Light theme is unchanged in look.

## Verified
- `php -l` and a JS syntax check pass.
- Ran the real page (PHP built-in server, SQLite) in dark and light at 390 px and 1280 px. No sideways scroll. Opened all 7 hub drawers and all 4 upgrade tabs in both themes; no wrongly bright backgrounds in dark mode.
- Screenshots and the A/B/C mockups are in `claude/mockups/` on the session machine only (git-ignored, not on the branch). Ask the owner for them if needed.

## Not verified, check these
- `tests/catfish.sh` could not run in the build sandbox (no database set up). Run it, and `tests/catfish_anim.js` and `tests/catfish_pets.js`. The tests may assert on banner markup (`cfbanner`) or the order of the stage and counter; update them if they do, since the banner removal is intended.
- Click-through: tap fish (counter matches after reload, including fast tapping), buy x1 and x10, tab switching, Nap, a scene swap after a buy (`swapScene` replaces only `.cfstagewrap`, which is inside `.cfdock`; confirm the dock survives it).
- Keyboard focus and screen reader: the page has no visible h1 now.
- The pinned dock takes about 250 px of a phone screen; judge on a real device.

## Known gaps (not done on purpose)
- No two-column desktop layout: the page only has a 640 px centre column between the site's side panels.
- The Room things map from mockup C is not in the real page; hub panels are only recoloured.
- Code size was not reduced. The big parts are the animation block in `catfish.js` and `catfish.php`; trimming them would change how the game looks, so ask the owner first.

## Rules
- Do not commit `config.php` or `data/*.sqlite`.
- Do not open a pull request unless asked.
- End commits with the attribution lines the session gives.

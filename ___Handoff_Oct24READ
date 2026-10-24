# Gnome Venture — Handoff (READ FIRST)
Date: 2026-10-24
Repository: https://github.com/joshfryart/gnome-venture
Default branch: main

## Working agreements
- The owner wants to see visual examples/mockups before any future commit or push that changes the UI. Do not commit/push layout work without explicit approval.
- Keep replies concise.
- The current task was explicitly approved for commit/push: implement the mobile adventure layout and commit/push all related work.
- For future UI changes, create a preview or mockup and ask for approval first.

## Current release / implementation
- Base on the repository's main branch at version 2.0.48.
- 2.0.48 includes Admin → Routes bulk setting for route wait time (minutes); individual route edits remain available.
- This change bumps the app and installer version to 2.0.49.
- Mobile adventure page: stage/banner first, travel action card directly beneath it, latest activity after the action, route map below the activity.
- Destination travel options are a compact collapsed summary by default; tapping it reveals the existing checkboxes and Save control.
- Desktop keeps the horizontal journey map. Mobile uses a vertical road map with alternating stop positions and readable labels.
- The vertical map is a new rendering helper in game/includes/maps.php. It uses the same underlying locations/routes and keeps the original journey_map_svg() for desktop.
- Related files: game/adventure.php, game/includes/maps.php, game/assets/style.css, game/includes/bootstrap.php, game/install.php, CHANGELOG.md.

## Validation / follow-up
- Run PHP lint on game/adventure.php, game/includes/maps.php, game/includes/bootstrap.php, game/install.php.
- Test on narrow widths around 390px, 412px, 430px, and desktop.
- Verify non-walk adventures (delves/lairs/exploration) retain their existing map behavior; vertical helper falls back to the existing map for exploration and returns blank for delve/lair because those use the track map.
- Verify collapsed route options and saving both checkboxes works.
- Check SVG label clipping/overlap for roads with many stops and ensure the gnome marker position tracks expedition step correctly.
- Build release package with the project's standard command: bash tests/build_update.sh 2.0.49 2.0.47 <ABSOLUTE_OUTDIR>; inspect generated manifest and zip contents before publishing.
- Do not claim live-site verification until tested on the actual hosted database/browser.

## Notes
- Avoid changing unrelated game mechanics or artwork while tuning the mobile layout.

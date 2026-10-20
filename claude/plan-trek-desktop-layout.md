# Plan: Trek fight layout on desktop (2.0.13) — written 2026-10-20, NOT built

Status: planned, waiting for Joshua's "go". Builds on 2.0.12 (branch trek-fight-touches, last commit ae95a00+; web zip sent 2026-10-20).

## Joshua's asks (in order)
1. Desktop map screen: the log lines + Sneak/Camp/Leave buttons go under the map (left column), into the empty space. Right column keeps the rest (status, map key, events, spot, trailmates).
2. Desktop fight: map stays in the left column (inert, token on the fight tile). In column 2 the character info / buttons / cards FADE OUT, the fight panel fades IN. When the fight ends the normal map cards fade back. (Chosen over: inline foe card sliding above the HUD; fight as a dialog; bottom sheet.)
3. Keep the combined foe pop-over (dialog.tkfoe) as is; no inline foe card for now.

## Why it is cheap
- trek.php: map screen is `.trekplay` (grid at >=1000px: map col 1 spanning rows, everything else forced to col 2 via `.trekplay > :not(.trekmapform) { grid-column: 2 }`, style.css ~3815). Fight screen is `.trekfightcol` (single column, max 560px).
- Make the fight render use the same grid: map (inert `trek_map_html`, read-only, like the existing `details.tkfmap` "Where it began") in col 1, `trek_fight_html` in col 2. Same map size/position in both renders so the token does not jump (one shared layout rule).
- Fade: existing view-transition name `trek-stage` (style.css ~3932). Page still reloads per action; it is a cross-fade, NOT a true in-page swap.
- Item 1 is CSS only: `.trekLatest`, `.tkfull`, `.trekacts` get `grid-column: 1; grid-row` below the map, same width as the map (max 520px, centred) or they stretch wider than the map.

## Work (one Sonnet task, then Opus review)
- trek.php: fight view on >=1000px renders map col + fight col in one grid wrapper; keep `$fightWalk` first-load behaviour ("!" over the token, `details.tkfmap` on phone only); on every fight load show the inert map on desktop (CSS hide below 1000px).
- style.css: append a new marked block at the END ("v2.0.13 trek desktop layout"); dark rules `:root[data-theme="dark"] X`; no inline styles (CSP); reduced-motion = no fade.
- assets/trekmap.js: "!" and walk path must still work with the map shown on fight loads; no double "!" on reload (server one-shot `trek_walk_take` already clears).
- Phone (<1000px): unchanged (single column, "Where it began" only on the first load).
- Tests: some may grep fight markup (tests/trek_*.php); update only what changed. Run treks.sh (243 ok expected), security190 (170 ok), walk.sh vs pristine, Playwright 1400 + 390 screenshots, Look at them.
- No fight maths, no schema, no news (Treks admin-only). Version 2.0.13 (numbering 2.0.10-2.0.19, then 2.0.20).

## Risks
- Map rendered on every fight screen: small server cost, map code is read-only.
- Map size must be identical in both renders or the token jumps.
- "!" + foe pop-over order unchanged: "!" first, then pop-over (trekfight.js busy-check covers open dialogs).
- Each round still reloads; seamless needs the in-page fight rebuild (below).

## Parked (not planned yet)
- In-page fight (no reload): medium risk, ~1 release; all other dialogs (plan sheet, scene, camp, foe pop-over, Auto replay) need converting to modal/top-layer, in-place page swaps must re-open the dialog; some tests grep fight markup. Decide after the phone test.
- Bottom sheet on phone (map top 35%, fight below): same cost as the dialog idea; keeps the map in view.
- Inline foe card above the HUD that slides the HUD down and folds into the fight rows: skipped in favour of the column fade.

## Open questions for Joshua (after the 2.0.12 phone test)
- Is the ~2.2 s foe pop-over too long? Is the "Where it began" map block too tall on phone?
- Phone: inline foe card instead of the pop-over (covers the top bar now)? My pick: inline on both if desktop goes the column-fade way; he did not answer.

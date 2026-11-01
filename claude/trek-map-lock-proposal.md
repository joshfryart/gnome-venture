# Trek: map always visible (proposal)

Mockup: `claude/trek-map-lock-mockup.html` (open in a browser, use the buttons). Based on a read-only review of the current code; nothing built yet and nothing run in a browser.

## Problem
On phones the Trek page is a long scroll. New cards (spot, event, milestone) sit above the map and push it down. The fight view folds the map (`details.tkfmap`), hides panels in "Plan each turn", and fades the fight panel in during round 1. Each of these changes page height, so the map jumps. The 2.4.62 scroll fix treats the symptom.

## Idea
Make the phone view one fixed screen that never scrolls. Everything else is a sheet over the lower part.

```
HUD        one line: party HP chips + fatigue        (inline, fixed)
MAP        9x9 grid, full width                      (inline, fixed, never moves)
STRIP      fixed height: place name / latest log line / foes + round feed
DOCK       Map | Party | Pack | Log  (+ Fight when in a fight)
SHEET      bottom sheet, up to ~55% of screen, covers STRIP and DOCK area, not the map
```

## What becomes a sheet
- Spot, event, crew and milestone cards, and the legend.
- Party, Pack and Log (the existing `aside.tkdrawer`, restyled as a tabbed bottom sheet).
- Fight actions (Attack, Guard, Snack, Retreat) and the round feed ("Show all").
- "Where it began" fold disappears: the map is already on screen.

## What stays inline
- Map, HUD bars, the strip (its last log line stays a live region for screen readers), the dock buttons.

## Rules that stop the jumping
1. The shell is `100dvh`; the map, HUD and dock have fixed heights. Only sheet content scrolls.
2. Sheets are non-modal: the map stays tappable and visible above (as the foe pop-over `tkfoe` already is).
3. Opening or closing a sheet never changes the layout behind it.
4. Round 1 fade (`tkhold`) and `tkfmap` fold removed on phones.
5. Desktop keeps the current two-column layout.

## Cost
About 5 files: `trek.php` (map and fight blocks), `style.css` (trek layout blocks plus sheet rules), `trekshell.js` (generalise drawer to a sheet, drop the 2.4.62 scroll fix), `trekfight.js` (Plan each turn and Auto replay depend on `.trekhealth` and `.trekstage`), plus small changes in `trekcamp.js` and `trekmap.js`. Roughly 300-500 lines, medium risk. The `dialog[open]` checks in `trekfight.js` and `trekcamp.js` must also count the new sheet.

## Open questions
- Map is 9x9 on phones. On a short phone (about 640px tall) map plus HUD plus dock leaves little strip. Option: shrink map to 7x7 view centred on the gnome.
- Should Plan each turn and Auto replay stay full-screen dialogs, as now? Recommended yes for the first pass.
- Escape, focus return and `inert` handling for the sheet need care (accessibility).

## Suggested order
1. Fixed shell + dock + sheet for Party/Pack/Log and spot cards (map view only).
2. Fight view into the strip and sheet.
3. Remove old fold, hold and scroll code.

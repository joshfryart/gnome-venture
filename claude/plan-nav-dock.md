# Nav dock: migration plan

Status: **phase 1 started** (flag and admin preview). Design: `nav_dock_mockups.html` at the repo root (interactive; every page has a row in its audit table). Icons: `art-nav-dock/` (25 pixel icons, source and PNGs). This plan is the order of work and the checklist per file.

## What changes for players

A landscape bottom dock replaces the header, status strip, bottom bar, menu sheet and (later) the right rail:
- four menu pieces (You, Hobbies, Out & about, Together) that open a strip of tile pieces (the same tiles as today's menu sheet);
- two page actions, left (helper) and right (the page's main verb), per page, with strips for lists, Select mode, switches and the Quick item in later phases;
- a status plate (energy, level, time, Petals) whose popover holds the numbers and the few links the menu cannot reach;
- play mode (a thin rail) for mini-games, typing hides the dock.

Portrait screens keep today's chrome. The dock draws in landscape on every screen size: phones, tablets and desktops (`@media (orientation: landscape)`). On a wide screen it also folds in the right rail: pots, boosts and tasks are the popover's second tab, and the message list sits under the top of the page, as on a phone. The popover's third tab holds what the menu sheet kept at its foot (feedback, rules, privacy, the site's own pages, moderation and admin links) plus Log out and the theme switch.

## Flag and rollout

Setting `nav_dock` (Admin → Settings, text): `0` off (default, the game is exactly as before), `admin` admins only (preview), `1` everyone. An admin can add `?dock=off` or `?dock=on` to any address to switch their own copy (cookie `gv_dock`).

Order: admin preview (decided: admins only, no tester list) → everyone in landscape → portrait lock in `manifest.json` → retire the old chrome.

Rollback: set `nav_dock` to `0`. Nothing is migrated in the database.

## Phase 1: flag, shell, admin preview (this change)

Done:
- `includes/dock.php`: `dock_settings()`, `dock_on()`, `dock_menus()`, `dock_status()`, `dock_actions()`, `dock_page_spec()`, `dock_html()`. Phase 1 actions are links and strips of links only (Games, Puzzles, the contest pages); every other page gets the defaults Back and Hovel.
- `includes/layout.php`: `nav_groups()` split out of `nav_sheet()` so the sheet and the dock list the same tiles with the same unlock rules and badges. Dock CSS and script are loaded only when `dock_on()`; body class `dock-on`; the markup is emitted in `page_footer()`.
- `includes/functions.php`: `nav_dock` merged into `settings_schema()`.
- `assets/dock.css`, `assets/dock.js`, `assets/img/nav/dock-*.png`.
- `assets/site.js`: the in-place page swap also swaps `.dockdata` (plate numbers and the page's two actions); `dock.js` re-reads them on `gv:swapped`.

Design rules the code follows (CSP `style-src 'self'`):
- no inline `style` attributes anywhere; `dock.js` places pieces through the style object; the data is a JSON data block;
- every class the dock draws is prefixed `dk-` (the game stylesheet already uses `tag`, `chip`, `badge`, `tile`, `row`, `st`, `soil`...);
- the game's `svg { max-width: 100% }` is reset inside `.dockroot` (the pieces overflow their box on purpose);
- if the script fails or the browser lacks `translate`/`rotate`, a plain list of links (`.dockfb`) stays visible, so the menu never disappears;
- the dock hides `header.banner`, `.statusstrip`, `.bottombar`, `nav.side` and `.rail` only inside the landscape media query; `.msglog.top` (the phone's message fold) is shown instead of the rail's message list.

Checked here: PHP lint, JS syntax, a static harness page (1) under the exact CSP, (2) with the game's `style.css`, at 844 x 390, light and strips/popover opened, no CSP violations. **Not run:** the game against a database (no MySQL in this environment), a real phone, the dark theme with the real stylesheet.

## Phase 2: page actions that post (admin preview)

Each page declares its pieces with `dock_declare()` (or a row in `dock_page_spec()`), returning the same shape the mockup uses. Needs: a form-post path from a dock piece (CSRF token in `.dockdata`, in-place result via the existing AJAX swap), per-tab overrides (the page reports its tab), disabled pieces with a reason chip.

Order (by use and risk): Garden (Select mode, Tools cycle), Satchel (Quick slot, Arrange), Tasks (Deliver, Post), World/Here/Town (Do here, Go), Shop (Buy | Sell switch, Single/Several), Crafting (All), Gnome/Hovel (Rest strip, Heal), Friends, Trading, Market day. The per-page proposal and its reasons are in the mockup's audit table and edge-case list.

Server pieces to add: a dock endpoint (or the existing page POSTs reused) for Select mode loops over per-square calls (Tend, Tasks requests, Friends requests/blocked, Pal jobs), Quit for Rain Barrel / Gnome Beds / Spit / Pest, a results screen for Worms / Memory / Spit / Pest, claim-all on First Week.

## Phase 3: play mode, adventure, combat

- Play mode rail for the mini-games and the editors (Yard keeps the dock with an Edit strip).
- Adventure: left = Quick item (read-only), right = Trail strip (Sights, Wander, Gather, Sneak, Hunt, Turn back).
- Combat is adventure combat: left Quick, right Combat strip (Creature popover, Flee); menus stay open (the fight is saved in `expeditions.encounter`).
- While on an expedition the game refuses some pages (see the mockup's table; already implemented in `dock_menus()`: World and Treks grey out "on the road", Here becomes Trail).

## Phase 4: retire the old chrome (only after phases 2 and 3 are stable)

Checklist of code that references the old chrome and must move first:
- `includes/tour.php`, `assets/tour.js`: steps point at `.bottombar a[href$="inventory.php"]`, `.shquick` and the menu button. Give the dock pieces stable anchors (`data-m`, `data-act`, `#dockplate`) and update every step that says "tap Satchel" or "open the menu".
- `assets/site.js`: bottombar (line ~1206, ~2337), sidenav and menubtn handlers (~2065), statusstrip swaps (~772, ~879).
- `assets/pfstage.js`, `assets/pfboardv1.js`, `assets/pfv1box.js`, `assets/workshop.js`: reference the old chrome; check each.
- Tests: `tests/here.sh` (checks the bottom bar Here link), `tests/polish_audit.js`, `tests/pbox_v1_shots.js` (clicks `.menubtn.more`).
- `includes/layout.php`: `status_strip()`, `dest_strip_html()` (the trip strip becomes a popover row), `right_rail()` (stays on wide screens; decide for landscape tablets).
- Admin pages keep their own layout; the dock never loads there (`!$admin`).

## Risks and mitigations

| Risk | Mitigation |
|---|---|
| CSP blocks inline styles | positions through the style object; JSON data block; an in-place test page under the exact header (done) |
| Class collisions with `style.css` | `dk-` prefix on everything the dock draws |
| Old browsers (`translate`, `rotate`, `color-mix`, `:has`) | feature check; plain link list stays visible |
| Visible height in landscape browsers (about 300–340 px) | dock is 106 px; strips close on tap outside; play mode and typing hide it |
| Muscle memory (today: one tap to Garden, World, Satchel, Here, Tasks) | consider remembering the last tile per menu; keep the bottom bar in portrait |
| Long-press (hold to open, hold to clear) | `-webkit-touch-callout: none`, `user-select: none`, always an alternative (the ▴ arrow, the ✕) |
| Double work in dock mode (nav_sheet and dock both compute badges and status) | badges are cached in the session for a minute; split `status_strip()` so both share one query set before phase 4 |
| In-place swaps | the dock lives outside `<main>`; `.dockdata` is swapped; `dock.js` re-reads on `gv:swapped` |
| Two navigation systems at once | accepted until phase 4; the flag keeps them apart |

## Decisions and open questions

Decided: (1) preview is for admins only; (2) the dock is for desktop as well as phones and tablets; (3) the right rail folds into the popover; (4) bigger screens get a bigger dock; (5) there is no trip strip in dock mode.

How (4) works: the dock is drawn at one size (about 106 px high at 844 wide) and `dock.js` scales the whole stage in steps of a quarter, from 1x up to 2x by screen width, never taller than about 28% of the screen height (1024 x 600 gets 1.25x, 1280 x 720 gets 1.5x, 1920 x 1080 gets 2x). The page clears it through `--dock-h` on the body. How (5) works: `.tripstrip` is hidden inside the landscape media query; the trip is a row in the popover's Now tab (the trail while walking, the route card while standing still). Portrait keeps its trip strip.

Still open:
1. Action icons (about 100 more emoji) stay emoji until drawn.
2. Phase 2 (page actions that post): Garden, Satchel, Tasks first.

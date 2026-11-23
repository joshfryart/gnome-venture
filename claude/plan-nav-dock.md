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

## Phase 2: page actions (admin preview). Started.

Decision: the dock never posts anything itself. A piece works a control the page already has (`dock_remote()` in `includes/dock.php`, resolved by `assets/dock.js`): it finds the first form on the page whose hidden `do` has a given value (or any element by selector) and clicks its button. So the page's own CSRF token, `data-confirm` dialog and in-place update all apply, nothing new has to exist on the server, and a page that does not have the control greys the piece ("none"). A piece can list candidates (the first one whose control is on the page wins: Give up or Re-roll), and a count badge can be read from a data attribute on the page. Pages that set `watch` get the dock redrawn when the page's buttons change (a `MutationObserver` on `<main>`, debounced).

Done (admin preview):
- **Garden, Beds tab:** left **Select** works the page's own "select squares" panel (`.selbar`). While it is on, a **Pick** strip (Empty, Improver, Tilling, Thirsty, Ready, None, with counts read from the page's `data-tiles`) and a green **Then** strip (Plant…, Work in…, Mulch…, Sheet mulch…, Till, Water, Harvest, Dig up) show by themselves, the left piece becomes **Done**, the right piece shows **Picked** with the count, and the four menus wait. Every tile clicks the page's own button, so the "…" choosers, the confirm for Till and Dig up and the energy checks are the page's. Right **All** is a strip of the page's own bulk forms (water_all, weed_all, harvest_all, pick_all, collect_all) with the page's counts. Other garden tabs: left Beds, right Hovel.
- **Tasks, Jobs tab:** left is Give up or Re-roll (whichever the page has), right is Hand in, Build or Take. **Requests tab:** right is Deliver or Favour.

- **Satchel Quick slot (phase 2b):** `users.quick_item_id` (added on demand by `quick_ensure_schema()`, also in `schema.php`), `includes/quick_slot.php` and `quick.php` (`do=set|clear|use`, CSRF, own item only, food and healing potions; refused in a fight). Satchel left piece: Quick (empty) → pick an item → Confirm; then it shows the item and uses it; ✕ clears, long-press (650 ms) clears. The dock posts a form to `quick.php`; `site.js` loads the reply in place. Tested on a SQLite install: set, use (qty 3→2), clear, bad item, no CSRF (400), GET (302), dock JSON `quick` filled. Fights and adventure use of Quick are phase 3.

- **Shop (Buy | Sell):** left works the page's basket button (Buy all / Sell all, grey until something is picked), right is the switch to the other tab. Checked on the SQLite install (dock JSON on both tabs). The Single/Several submenu is not needed: the shop's tiles already pick several into the basket.

- **More pages (admin preview):** Crafting tab of the Satchel (right: Collect all / Jars / Cook again strip); Gnome and Hovel (left Heal strip of the page's own potion and snack forms, right Rest strip of the sleeps and naps, from `gclock_rest_options()`); Town (left Do here strip: Wave, Sit, Snack, Game, Festival; right World); Here (Do here goes to Town, World); World (Here, Explore); Trading (List, Offer); Market day (Basket); Tasks Journey (Hand in, Finish, Crate) and Post (Take).
- **Adventure:** left is the Quick item, use only (`remote.quick = 'use'`; set it in the Satchel); right is the Trail strip (Sights, Gather, Wander, Sneak, Hunt, Turn back, each clicking the footer's own control) or, in a fight, Run away (`.pf-runf button` or the old `flee` form). Not run here: needs a live expedition. The Quick button still refuses in a fight (`quick_use`), and the puzzle fight's creature popover is not wired.
- **Play mode:** `dock_play()` names the mini-games and the two puzzles; `dock.js` draws a 34 px rail (back link, name, energy and time, Menu) instead of the dock; Menu opens the full dock, a tap outside closes it. Screenshots taken on a SQLite install (Memory, Shop).

- **Garden Tools:** the right piece's strip starts with Water, Harvest and Till tools. Arming one turns the page's select mode on and the left piece becomes Done ("tap a bed"); a tap on a bed clears the picks, picks that bed alone and clicks the page's own Water, Harvest or Till button (so the Till confirm and the energy checks are the page's). Tested on a SQLite install: a bed tap posted `do=batch&act=water&sq[]=3-0`.
- **Community garden (Together):** left Select: tap beds (ringed), a Pick strip (Thirsty, Weedy, Ripe, Empty, None) and a Then strip (Water, Weed, Harvest, Plant) post one `do=tend` with `acts[]=verb:bed` to `community.php`, which does one job per bed (one energy each) and stops at tiredness or the shift cap. Right: Tend strip (Tend, Take bed, Take store). Tested on SQLite: 3 beds planted in one post; the dock Select and Pick strips seen in a screenshot.
- **Pal jobs:** right Collect all, left Pals. Sending several pals at once was already on the page (ticked pals), so no new Select there.

- **Fights:** the right piece is a Fight strip: Creature (a popover tab with name, level, health, size and a line about it, read from `encounter_creature()`) and Run away (the puzzle fight's own `.pf-runf` button or the old `flee` form). In a fight the Quick piece eats the Quick item if it is a fight snack (a home-cooked snack): in the old fight it posts the page's own `snack` action; in a puzzle fight it posts the new `pf_quick` (`includes/pfight_game.php`): it checks the fight's nonce, the snack limit (`snacks_left`) and that you are hurt, eats one, heals, and does not use the turn. Other items grey with a reason ("not a snack"). Tested on SQLite in a live puzzle fight: health 4 to 10, one snack used. Tested with a fake expedition and encounter in the SQLite copy.

- **Yard:** left Save, right an Edit strip (Rotate, Shape, Size, Put away, Undo), all clicking the editor's own buttons.

Still to do (needs a live session or new design): (Select mode was asked for Tend and Pal jobs only, in the Garden style; Tasks requests and Friends stay single-action.) Friends and Villagers (no page forms: they keep Back and Hovel); the remaining emoji action icons (47 are drawn now: `art-nav-dock/gen_action_icons.py`, mapped through `DOCK_EMOJI_ICON` in `includes/dock.php`; a few are weak: buy, game, offer, finish, size, shape, tools, cook again); a real-phone and real-browser pass.

How it was tested here: the generated dock JSON for Garden and Tasks was loaded into a static page with a fake copy of the page's controls under the game's CSP; every strip tile, Select, Done and the bulk and job forms reached the right control, and the dock redrew when the fake page changed. Not tested against the real garden and tasks pages (no database here).

## Phase 3: play mode, adventure, combat

- Play mode rail for the mini-games and the editors (Yard keeps the dock with an Edit strip).
- Adventure: left = Quick item (read-only), right = Trail strip (Sights, Wander, Gather, Sneak, Hunt, Turn back).
- Combat is adventure combat: left Quick, right Combat strip (Creature popover, Flee); menus stay open (the fight is saved in `expeditions.encounter`).
- While on an expedition the game refuses some pages (see the mockup's table; already implemented in `dock_menus()`: World and Treks grey out "on the road", Here becomes Trail).

## Phase 4: retire the old chrome (only after phases 2 and 3 are stable)

Checklist of code that references the old chrome and must move first:
- **Done:** `includes/tour.php`, `assets/tour.js`: every step now also lists the dock's tile and its menu piece ("Tap You, then Almanac"); the old targets stay for portrait. `dock.js` fires `gv:dockdrawn` after each draw so the tour re-rings the new piece; the ring is drawn on dock pieces (`dock.css`). Found and fixed on the way: the tour wrote its hint text on every pass, which the dock saw as a page change and redrew in a loop. Old text, for reference: steps point at `.bottombar a[href$="inventory.php"]`, `.shquick` and the menu button. Give the dock pieces stable anchors (`data-m`, `data-act`, `#dockplate`) and update every step that says "tap Satchel" or "open the menu".
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

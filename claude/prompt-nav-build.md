# Start prompt: graphical navigation build (copy into a new AI session)

Task: build the code for Gnome Venture's graphical navigation, release A first. Repo `joshfryart/gnome-venture`.

**Read first (in order):** `CLAUDE.md` and `game/README.md` (conventions), `claude/plan-graphical-nav.md` (the whole plan, Josh's decisions are in its "Decisions" block), `claude/todo.md`, `claude/todo-art-v3.md` section C (art slots the code must match).

**Do now (no art needed):**
1. Phase 0 recon: read the files the plan lists. Write findings that differ from the plan into `claude/nav-recon.md` (10 lines max, with file:line).
2. Phase 1 foundations, new files only, nothing visible: `includes/here_layout.php` (pure functions `here_persp`, `here_bearing`, `here_assign_exits`, `here_place_npcs`), `includes/here_schema.php` (settings `gnav_on`=0, `gnav_tiles`=0, `gnav_enter_energy`=1, `gnav_login_here`=1; `users.start_page`; `here_layouts` table), `data/here_layouts.json` (layout contract in plan 1b), `tests/here.php` + `tests/here.sh`.
3. Phase 1b-2: generic scene engine `includes/hub_scene.php` + `assets/hubscene.js` (backdrop + hotspots + sprites + popover; CSP-safe inline SVG; no-JS works; text twin).
4. Phase 1e: `tools/gen_here_placeholders.py` so every later page can be built before art exists.
5. Then Phase 2a (Here page, read-only, behind `gnav_on`), 2b (sprites; placeholder if `assets/img/sprite/npc-<slug>.png` is missing), 2c (nav wiring: login, bottom bar, World strip, Account "Start on: Here / Home"). Stop there: that is release A. Do NOT start 2d (Trail tiles) or later phases.

**Rules (from the plan, do not break):**
- Additive + flagged. `gnav_on` off = today's game exactly. Old pages stay.
- Art optional: missing file falls back to placeholder then emoji, never a broken page.
- Logic stays in existing functions; hotspots are links into existing actions. One `route_enter_cost()` for every place that shows or charges the cost.
- CSP: no `style=`, no inline script. Every hotspot is a real `<a>`; actions are POST forms with CSRF on a confirm card, never from the picture.
- Canvas size comes from the layout JSON (`w`,`h`); do not hard-code 480x270 (Josh may change it).
- Player text says "Trail"; code and tables keep `road`.
- New tables via a `*_schema()` function; new settings via the `*_settings()` pattern in `trek_data.php`.

**Git:** work on your own new branch from `main`, commit and push often, never push to main, no PRs. Do not change `APP_VERSION` or CHANGELOG (Josh releases: the art release is 2.4.99, nav release A comes after). Do not touch `aseprite-source/` or `game/assets/img/`.

**Tests:** run the suites the plan's "Tests" section names plus `tests/here.sh` after each step. Report real failures; never skip a test to get green.

**Finish:** update the NOW block of `claude/todo.md` with what is built and what is left. Reply short and exact: files added, tests run with results, what Josh must check on the phone. Josh prefers short, exact replies.

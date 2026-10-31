# Site-wide polish plan (draft, 2026-10-31)

Built from `graphify-out/` (GRAPH_REPORT.md, SECTIONS.md, sections.json: 9,438 nodes, 494 communities, 14 sections), `claude/todo.md`, `docs/ui-consolidation-plan.pdf` and a few spot checks of the code. Nothing here is built yet. Joshua picks the order.

## 1. What the graph tells us about where polish is safe

| Layer | Sections | Rule for polish work |
|---|---|---|
| Shared hubs | Core (468 nodes), Player & Progression (314) | Do not change signatures. `q()` 809 edges, `q_val()` 598, `setting()` 529, `e()` 345, `url()` 188, `db()` 177. Add helpers, never rename. All hub edges are INFERRED (name-resolved), so grep before trusting "unused". |
| Gameplay | Trek, Roads, Garden & Almanac, Catfish, Delve, Puzzles & Pals, Economy, World & Social | Each is mostly self-contained. Polish one section per release. Presentation changes stay inside the section's own files. |
| Peer bridges | 10 connectors in SECTIONS.md (Roads<>World 108 edges, Economy<>World 77, Puzzles<>World 65, Economy<>Garden 58, Garden<>World 54 ...) | Touch a bridge symbol only with both sections' tests. Watch: `notify()` (trade.php), `exp_log()`/`player_node()` (adventure.php), `ts()`/`spend_energy()` (garden_logic.php), `landmark_day()`, `job_period_key()`. |
| Isolated | Admin, Live Browser Tooling (`.github/skills/impeccable`, 831 nodes, no game coupling), Docs & Design | Admin polish is low risk (light coupling, only 2 edges to Trek). Impeccable is a tool, not the site: leave it alone. |

Hot spots (largest files, most cross-community traffic): `style.css` (6,580 lines, one file, 59 `max-width:720px` and 44 `min-width:721px` blocks), `site.js` (2,089), `catfish.php` (1,647), `garden_logic.php` (1,512), `trek.php` (1,441), `maps_myc.php`, `puzzle_pals.php`, `yard.php`, `adventure.php`, `functions.php`, `stops.php`, `layout.php` (761). `layout.php` and `style.css` are the two files every page runs through, so they set the polish ceiling.

Graph caveats: the graph covers code and docs but not rendered pages. It cannot say what looks bad. Phase 0 supplies that. 2,106 nodes have 1 or no connection and 34 communities are mixed, so use file ownership in `sections.json`, not community ids.

## 2. Known polish debt (from todo.md and the PDF)

- Status strip overflows at 768px site-wide (2.3.8 follow-up).
- `PRODUCT.md` and `DESIGN.md` do not exist; impeccable `init`/`document` has been deferred since 2.3.0. Every design pass is working without a written target.
- World/Town/Stops UI consolidation plan (`docs/ui-consolidation-plan.pdf`) was never executed: 3 navigation surfaces, 3 villager surfaces, passport in 3 places, loose Seasons/Land on World Here. Its "dead villagers view" bug looks partly fixed since (`town.php:54`, v2.0.60), so recheck before phase 2.
- Unchecked on a phone: pal card on Here page, stacked pal button, top-bar HP bar, Crafting map hotspots, Pantry B icons, Potions box, Stamp passport folds, Pal Jobs tabs, Alchemy.
- Delve v2 fight card has no pal skill buttons; `delve_v2`, `ppal_boons`, `ppal_party` are OFF, so their UI has had little real use.
- Road-stop "do" activities ("come back, 1 of 3") are parked by Joshua. Out of scope.
- Weak art listed in todo: Yard & decor stepping stones, Building scene, Tools sledge; 14 delve hazard icons are emoji placeholders; potions art done.
- Test baseline is not clean: `gather150`, `social100`, `catfish`, `folkoverlay` fail on base, golden combat `road` section differs. Get a known baseline before changing CSS or markup.
- MySQL and full CI have not been run for 2.3.x.

## 3. Phases

Each phase ships as its own slim zip and CHANGELOG line. Phases 1 and 2 first; everything after depends on them.

### Phase 0: Audit and baseline (no code change, about 1 session)
1. Run `bash tests/ci_suites.sh` once, record the known failures in `claude/ci-2.3.x.md`. Fix or quarantine-by-note the stale ones (`catfish` was fixed in 2.3.92, recheck).
2. Screenshot every top-level page at 412px dark, 412px light, 768px, 1400px (`tests/readme_shots.sh` and `tests/shots.sh` give the pattern; `crawl.py` lists routes). Store in `docs/screens/polish-baseline/`.
3. Write the findings per page into a table: overflow, tap target under 44px, contrast, duplicated surface, empty state, wording.
4. Run impeccable `init` and `document` to create `PRODUCT.md` and `DESIGN.md` (closes a recurring todo). Base on `claude/art-style-guide.md` Part C tokens and the top of `style.css`.

### Phase 1: Foundations (Core, highest leverage)
1. Fix the 768px status-strip overflow in `layout.php`/`style.css`.
2. Audit breakpoints. 720 is the main one, with 520/480 stragglers. Pick one set (720 plus 1000/1200 for desktop) and fold the rest.
3. Split `style.css` by section behind the same `<link>` order (shell, forms, world, garden, trek, economy) or at least add a table of contents and group blocks. Pages already load `puzzles.css`, `catfish.css`, `landing.css`, `admin.css` separately, so the pattern exists. Do not change selectors in the same commit as the split.
4. Tokens: list colours, radii and spacing used outside `:root` and move the repeats to tokens. Check dark theme parity (`:root[data-theme="dark"]`).
5. Accessibility floor: focus ring on every interactive element, 44px tap targets, contrast on both themes, `prefers-reduced-motion` coverage (29 blocks exist already, check the new Pal/Trek ones), labels on icon-only buttons.
6. CSP: confirm no inline `style=` was added by recent work (`grep -c 'style="'` per file; the PDF requires none).
Tests: `tests/security*.sh`, `images.sh`, scene smoke, plus screenshot diffs from Phase 0.

### Phase 2: World, Town and Stops consolidation (Roads + World & Social, the biggest bridge: 108 edges)
Follow the existing six-step plan in `docs/ui-consolidation-plan.pdf`, in its order: extract to `includes/place_ui.php` with no visual change, one villager component, unified place tabs with redirects for old `?t=`, `?view=`, `seasons.php`, then World restructure (Go replaces Here + Travel), then the visual pass (phone bottom bar, desktop column). The six open decisions in the PDF need Joshua's answers first (main-stop Villagers scope, Here as top-level entry, phone bottom tab bar, unused stop/map art, Mossbottom switcher, Land for Sale placement). Gate: mockup to Joshua before the restructure step.
Tests: `scene_smoke`, roads, walk, explore, `villagers`, `stops100`, `social100`. Check incoming links named in the PDF (`index.php:126`, `shop.php:103`, `marketday.php:38`, gather.php `$back`).

### Phase 3: Per-section passes (one release each, in this order)
Order is by player traffic first, then by graph weight.
1. **Garden & Almanac** (745 nodes): garden, tend, yard are the daily loop. Check beds, tool bar, almanac fold behaviour on phone, empty states, energy messages.
2. **Economy & Crafting** (639): crafting map hotspot words (todo lists weak ones), Pantry rooms, market baskets, gourmand copy, shop shelves for the new potions, Potions/Strong-Grand packing gaps.
3. **Player & Progression** (314): My Gnome page (HP bar, Potions box, skills), top bar health bar, callings, Pal Book wording for Boons, player news for 2.3.9x.
4. **Puzzles & Pals** (683): Pal Jobs tabs and ledger, pal card on Here, stacked-active button, jigsaw library on phone, games hub consistency (12 mini games share little CSS).
5. **Catfish** (355): self-contained; polish `catfish.css`, pet shop art todo, text review (`petshops-text-review.md`).
6. **Trek** (2,305 nodes, mostly tests): desktop layout plan (`plan-trek-desktop-layout.md`), camp UI, fight screen at phone width, chapter text passes. Behind L15 and admin-only, so lowest visibility; do last of the player-facing sections.
7. **Delve & Pal Boons** (424): only when `delve_v2` is about to be switched on. Add pal skill buttons to the v2 fight card, 14 hazard icons, floor names.
8. **Admin** (136): light coupling; list pages, forms, settings labels, mobile admin nav (`admin_nav_sheet`). Low risk, good filler.

### Phase 4: Content and consistency sweep (cross-cutting, scripted)
- Copy: one voice for button verbs, flash messages, empty states. Grep `flash(`/`notify(` strings (`notify()` is a bridge, so change text only).
- Icons: `emoji_icons.php` test already exists; extend to flag emoji placeholders still shipping.
- Art gaps from todo (stepping stones, Building scene, Tools sledge, hazard icons) as a single art brief, using the existing `claude/art-briefs` process.
- Dead code and orphan assets: unused `stop-*.png`/`map-*.png`, unused 64x64 craftmap tiles, `claude/` sims. Check with the graph's isolated-node list (273 symbol nodes with 1 or no connections) but verify by grep, since hub edges are INFERRED.
- Docs: README screenshots regenerate (`readme_shots.sh`), `game/README.md`, handoff.

### Phase 5: Verification and release hygiene
Full CI list on SQLite, a MySQL run (never done for `ppal_jobs`, `ppal_found`, `ppal_spawns`), phone check by Joshua on the todo list, `tools/check_versions.sh`, CHANGELOG, slim zip and manifest per release.

## 4. Order of work and sizing

| # | Phase | Risk | Size | Needs from Joshua |
|---|---|---|---|---|
| 0 | Audit, baseline, PRODUCT/DESIGN | none | S | OK to run all tests |
| 1 | Foundations | low-medium | M | none |
| 2 | World/Town/Stops | medium-high | L | answers to six decisions, mockup sign-off |
| 3.1-3.3 | Garden, Economy, Player | low | M each | phone checks |
| 3.4-3.5 | Puzzles & Pals, Catfish | low | M each | phone checks |
| 3.6-3.8 | Trek, Delve, Admin | low | S-M each | whether Trek/Delve flags are going on |
| 4 | Content sweep | low | M | art decisions |
| 5 | Verify and release | low | S | uploads zips |

## 5. Guardrails

- Never change Core or Player & Progression function signatures during polish. Add wrappers.
- Presentation-only commits: markup and CSS, no query or schema changes. If a polish item needs a schema change, split it out.
- One CSS change set per release, with before/after screenshots at the four widths.
- Run test suites one at a time (they share /tmp files).
- Keep old URLs alive as redirects whenever a page or tab is merged.
- Do not touch `.github/skills/impeccable`, `graphify-out/`, or releases/archive.

## 6. Decisions needed from Joshua
1. Start with Phase 1 and 2, or section passes first?
2. The six open questions in the UI consolidation PDF (listed in Phase 2).
3. Is splitting `style.css` into several files acceptable given the CanSpace host and the one-file convention in README?
4. Which unchecked-on-phone items from todo.md should block the first polish release?
5. Any pages you already know look worst (to bring forward in Phase 3)?

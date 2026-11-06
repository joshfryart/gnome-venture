# Handoff: 2.4.94 to 2.4.96 (2026-11-03)

Main is 2.4.96 (`aea11f3a`). Slim zip `releases/GnomeVenture-2.4.96-web-update.zip` needs 2.4.93+ and carries everything since. Notes in CHANGELOG.md 2.4.94 to 2.4.96.

## 2.4.94 and 2.4.95 (built outside this repo)
Josh supplied the two slim zips; they were imported as one commit (their code is byte-identical to the repo, except for the 2.4.96 edits to `style.css`, `layout.php` and `bootstrap.php`). 2.4.94: admin "Start counting again" for XP sources (clears `xp_log`), Usage and Retention (settings `stats_reset_<area>`, `stats_usage_snap`); helpers in `includes/admin_helpers.php`. 2.4.95: `fresh_start.php` also clears lazily created tables (`FRESH_LAZY_TABLES`). 2.4.94 set `xp_steep_percent` to 20 and 2.4.95 put it back to 15 (the repo has 15). The CHANGELOG entries for both were rebuilt from the diff: check them.

## 2.4.96: Welcome flow
- `welcome.php`: helpers `welcome_progress()`, `welcome_wren()`, `welcome_cta()` and the three steps. Form fields and `do` values unchanged. `includes/onboard.php`: `pack_icon()`, `pack_slots()`, `swatch_tile()`. `assets/welcome.js` swaps the basket (all baskets are in the page; the checked one is server-rendered visible). `layout.php` loads it on `welcome.php`.
- CSS: block at the end of `style.css` ("v2.4.96 Welcome flow"). `.gnomemaker`, `.avatarcol`, `.swatches` stay (used by `customise.php`, `sinks.php`).
- Art: 11 PNGs from the design handoff. Village art path is `assets/img/villages/<slugify(name)>.png`, not the DB slug (`v-na-1-1`).
- Source brief and mockup: Josh's `welcome-handoff.zip` (not in the repo). Art sources and the gnome rig are only in that zip.

## Gotchas
- Local `main` in the build container was an old unrelated branch; push with `git push origin <branch>:main`.
- Region name "The Maplewold" makes the Wren line read "in the The Maplewold" (old data quirk, same as before).
- Build: `bash tests/build_update.sh 2.4.96 2.4.93 <outdir>`.

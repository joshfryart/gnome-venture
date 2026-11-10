# Prompt: build the 2.6.40 update zip and the Trail picture zips

You work on Gnome Venture (PHP game), repo joshfryart/gnome-venture. Work only on branch `ccr-0b462c90-quvi1t` (2.6.40, pushed, NOT merged to main). Push main only when Josh says so. No PR unless asked. Josh wants very short, exact replies; use they/them for people.

## Read first
1. `README.md` "Release process"; `claude/handoff.md` top entries (2.6.40, 2.6.39, 2.6.38) and its release rules.
2. `claude/todo.md` last three lines (2.6.38 / 2.6.39 / 2.6.40).
3. `CHANGELOG.md` top entry (2.6.40).

## State (already done, tested, committed)
- Version 2.6.40 is set (`game/includes/bootstrap.php`, CHANGELOG, `update_news.php`). `bash tools/check_versions.sh` passes.
- All 246 routes are 30x18 rich maps. Data: `game/includes/data/trail_maps/*_30x18.json`. Sprites: `game/assets/img/trail/obj/`. Ground pictures: `game/assets/img/trail/ground/<route>-<section>-r.png`, 665 files, all in git. The old 22x7 pictures are deleted.
- Engine: extra mini-bosses (`M` token), tool gates, Fish button. Tests passed: `php tests/trail_bendy.php`, `php tests/trail_authored.php`, `bash tests/ci_suites.sh trail_back trail_mini fight_scene_trail adventure`.
- The 2.6.39 slim zip and the 43 `upload-zips/...-r2-part*.zip` were deleted on purpose: 38 routes were re-baked afterwards, so they were stale.

## Your job
1. Do NOT re-bake or change any art or map data. A re-bake changes pixels and breaks pictures already uploaded. Do not run `tools/bake_trail_rich.py` or `tools/gen_bendy_trail_proto.py`.
2. Lint: `for f in game/*.php game/includes/*.php game/admin/*.php; do php -l $f; done`. Run the tests above once. If something fails, report it, do not "fix" data.
3. Slim update zip: `bash tests/build_update.sh 2.6.40 2.6.37 $PWD/releases slim` (needs 2.6.37 or newer on the site; Josh's site is on 2.6.38). Then remove the ground pictures from it: `zip -d releases/GnomeVenture-2.6.40-web-update.zip 'game/assets/img/trail/ground/*-r.png'`. Result must be about 1.5 MB, contain `game/includes/data/trail_maps/*.json` (15 files), `trail/obj/*.png`, no ground pictures. Check with `unzip -l`.
4. Admin > Images zips (flat PNG names, stored not compressed, 4 to 6 MB each) in `upload-zips/`:
   - Name `gnome-venture-trail-ground-r3-part<N>of<M>.zip`.
   - Contents: every `game/assets/img/trail/ground/*-r.png` EXCEPT the 41 Maplewold ones (routes 228, 232, 236, 304 to 316), which Josh already uploaded with 2.6.38. That is 624 pictures, about 43 parts, about 249 MB. Sort by route then section, fill each part up to about 6,000,000 bytes.
   - Check: the pictures of the 38 re-baked routes are in the zips as they are now in git (229 230 234 238 242 246 254 258 262 266 270 274 282 294 325 339 340 349 351 362 363 376 377 387 389 401 402 414 415 425 427 435 437 447 458 460 471 473). Do not use older zips.
   - Sanity: unzip one part into a scratch folder, the names must look like `260-1-r.png`; the part count and total file count (624) must add up.
5. Commit the zips and the manifest (`tests/manifests/2.6.40.txt`, made by `build_update.sh`). The repo is large: commit the image zips in a separate commit and push in two steps. If a push fails on size, tell Josh, do not delete art.
6. Update `claude/todo.md` (one line: zips built, counts, sizes) and `claude/handoff.md` before ending. A stop hook rejects uncommitted changes.

## Tell Josh (short)
- Slim zip name and size. Number of image parts and their names. Upload order does not matter. Until a section's picture is uploaded it shows the old random tile look.
- Gate tier is capped at 3 (Fine), not 4: the gathering tools have no tier 4.
- 2.6.38, 2.6.39 and 2.6.40 are not on main. Ask whether to merge.

## Hard rules
- Do not edit `tools/bend_rules.py` or any lint to make a map pass.
- Do not touch "Gather here". The Fish button is separate.
- Props are decor only. Island stays on coast art.
- Do not put pictures that are in `game/assets/img/trail/ground/` into the slim zip.

# Start prompt: hotspot button art for the picture pages (copy into a new AI session, hand back when done)

Task: draw the pixel-art BUTTONS that sit over the tap circles on Gnome Venture's picture pages (Here, Residential, Door, Workshop, Treehouse, Pal Yard), replacing the emoji bubbles. Repo `joshfryart/gnome-venture`. Josh's complaint: the live circles look bad and don't say "press me".

**Read first:** `claude/art-brief-here.md`, `aseprite-source/v3/lib/CHEATSHEET.md` (API, palette, workflow), `aseprite-source/v3/HANDOFF.md` (how v3 art is made), `game/includes/hub_scene.php` (how a hotspot is drawn: it already supports `'icon' => img path`, emoji is the fallback) and `game/includes/here_view.php` (the `$add('<key>', label, emoji, href…)` calls and the exit hotspots, `cls` = goal|locked|ruin).

**Design (do this):**
- One consistent plaque: a small wooden sign / pin with a warm cream rim and a 1 px dark rim in its own darker tone, so it never looks like scene art. Each file is **48x48 PNG, transparent outside the plaque, hard pixels, light from upper left, cool-violet shadow, warm light**, with a clearly drawn 32x32 icon centred on it. It must read as a button at 0.86x phone scale (use 2 px features; no 1 px dither or dotted lines).
- Exits: **8 arrow signposts**, one per compass direction (N NE E SE S SW W NW), each pointing the way it leads, same plaque family. Make a gold "your goal" version of each (`-goal`). Files `hs-exit-<A>.png`, `hs-exit-<A>-goal.png`. Locked and ruin states are done by code (grey or rubble tint), so draw no extra variant.
- Spot icons, one per key (file `assets/img/hs/hs-<key>.png`), first batch = the Here page, in this order of priority: `shops`, `homes`, `do`, `people`, `stop`, `garden`, `fire`, `shop`, `investigate`, `mouth` (also draw `mouth-lair`: a darker, scarier one), `wild`, `green`, `teahouse`, `board`, `library`, `books`, `rest`. Second batch: `knock`, `gift`, `back`, `next`, `prev`, `building`, `trip`, `delve`, `cellar`, `loft`. Third batch (workshop and treehouse): `cooking`, `pantry`, `tools`, `potions`, `decor`, `station`, `plate`, `sick`, `light`, `yard`, `catfish`, `puzzles`, `parlour`, `contests`.
- Pulse ring and hover brightening are done in CSS by code, not in the art.
- No text or letters in any icon (translation). No people or animals except tiny props where needed.
- Every icon recognisable at 32 px from silhouette and colour; each key visibly different from the others.

**Files and outputs:** sources in `aseprite-source/v3/hotspots/` (`hs-<key>.lua/.png/.aseprite`, one self-contained Lua per file, `HP.assertClean` passes, run Aseprite with `/tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script f.lua`; if Aseprite is missing check `aseprite-source/README.md`). Final PNGs go to `game/assets/img/hs/`. Make one contact sheet at 4x (all icons on a grey ground, and on the dark game brown #2b1c26) and Read it before you finish.

**Code step (small; keep the emoji fallback):** in `here_view.php` and the other picture pages, set each hotspot's `'icon'` to `url('assets/img/hs/hs-<key>.png')` when `pixel_has('assets/img/hs/hs-<key>.png')` else leave the emoji. Exits use `hs-exit-<A>[-goal].png` from the exit's compass letter `a` and `cls`. Do not change layouts or game logic. Run the repo's suites for these pages (`tests/here.sh` and whatever `claude/plan-graphical-nav.md` names) and report real results.

**Git:** your own new branch from `main` (it has the nav build and 2.5.04), commit and push often, never push to `main`, no PRs, do not change `APP_VERSION`, `CHANGELOG.md` or other art folders. Josh prefers short, exact replies.

**Hand back:** reply with (1) files added count per batch, (2) the contact sheet path, (3) weak icons you would redo, (4) tests run and results, (5) the branch name. Josh then releases it (probably 2.5.05).

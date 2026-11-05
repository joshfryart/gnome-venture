# Start prompt: scene lookup for the new town and stop pictures + wander card art hooks (copy into a new AI session, hand back when done)

Repo `joshfryart/gnome-venture`. Own new branch from `main`, commit and push often, never push to `main`, no PRs, do NOT change `APP_VERSION` or `CHANGELOG.md` (Josh releases). Josh wants short, exact replies. Read first: `claude/art-brief-here.md`, `claude/plan-graphical-nav.md`, `claude/todo.md` (ART TODO wander block, NOW blocks 2.5.03 to 2.5.17), `claude/todo-art-v3.md` (METHOD block), `claude/prompt-wire-art.md` (a separate AI handles the nav chrome, compass, globe, hit boxes and villager/gnome wiring: do NOT redo those). Rule everywhere: a missing image falls back silently (no broken image, no emoji disc or circle).

## 1. Scene lookup for the new gate-view pictures (code only, no drawing)
Art exists in `aseprite-source/v3/here-gate/` (pre-rendered 480x270 PNG + `.layout.json` pairs; schema `{w,h,horizon,view,spots[{k,name,x,y,box}],stand[],compass_clear}`):
- **Main towns** (15), `here-gate/towns/here-town-<key>.png` + layout, plus Maplewold `here-market-maplewold-v5.png` + layout. Map key to region code (verify against the `regions` table / `includes/town.php` TOWN_FLAVOUR, never guess): mossbottom = hub; maplewold NA; maizehollow CA; sunsprinkle CB; rainroot SA; mistmoor NWE; olivewhistle SE; birchbramble EE; dunewhisper MENA; greatcanopy WCA; thornacre ESA; spicepeak CSA; blossomreach EA; monsoontangle SEA; coralscatter OC. Town spot keys: green, tea, board, library, s1, s2, shops, wild (the region's two special places are the 2 `town_places` of that region: map s1/s2 to them by order in `data/towns.txt`; the Maplewold v5 file uses sugarshack, bakery, tavern, hall, stalls, store, guild, square, board, orchard: map those to its real town places or leave unlinked ones out and report).
- **Rest stops**: pre-rendered looks `pilot-market-<landscape>_<style>.png` (so far grassland_maplewold and desert_adobe) + `pilot-market.layout.json`, one per stop TYPE x look. Stop types: camp ferry herb inn jetty market mill orchard shrine spring tower workshop (table `stop_types`); more types and looks will arrive as `stop-<type>-<landscape>_<style>.png`. `<style>` is a regional architecture style chosen per region (maplewold, adobe, ...); put the region-code to style map in data (`includes/data/stop_looks.php`) so a new look is one line.
- Do: copy the PNGs into `game/assets/img/scenes/` with names the lookup uses, add their layouts into `includes/data/here_layouts.json` (round-trip with `json.dumps(indent=1, ensure_ascii=False)`; do not hand-format), extend the lookup in `here_layout.php` / `here_view.php` to this order: place slug, then (town) `town-<region code>`, then (stop) `stop-<type>-<landscape>_<style>`, `stop-<type>-<landscape>`, `stop-<type>`, then the existing kind-landscape, kind, generic. Spots with `box` use it as the hit area (the other AI implements box hit areas; if not merged yet, read `box` defensively and ignore it). Keep placeholders as the last fallback. `php tools/lint_here.php` must pass (extend it: sizes, `box` inside the canvas, boxes not overlapping, nothing in `compass_clear`). Add tests to `tests/here.php` for the lookup order (town by region, stop by type+landscape+style, fallbacks).
- The villager `stand` slots and spot names come from each layout. Spot labels for towns should use the town's real place names (teahouse name and drink from TOWN_FLAVOUR, green name) instead of the generic tags when available.

## 2. Wander card art hooks (code only, emoji fallbacks, ~10 lines each)
From the ART TODO block in `claude/todo.md`; wire each to optional files that do not exist yet:
- Banner strip `scenes/wander-<land>.png` (9 landscapes), plus `wander-deep.png` (Deep wilds, step 9+) and `wander-wild.png` (dangerous tiers), shown at the top of the card in place of the plain header (`wander_card_html()` in `adventure.php`).
- Four tier badges (24 px) `wander-tier-<gentle|wild|dangerous|deep>.png` next to "step N".
- Five move icons (24 px) `wander-<deeper|roam|back|return|visit>.png` replacing the emojis on the buttons.
- Found-place marker `wander-found.png` on the Visit button and card header.
- Step-off / step-back strip `wander-step.png` (4 to 6 frames, horizontal): optional, skippable, reduced-motion safe.
Add placeholders only through `tools/gen_here_placeholders.py` if you need to see layouts; do not commit fake final art.

## 3. Small cleanups
- Update `claude/plan-graphical-nav.md` status line and the `claude/todo.md` NOW block with what you built.
- Run `tests/ci_suites.sh here` and the suites that touch what you changed (adventure/wander, stops, roads). Report real results.

## Hand back
Reply with: (1) what you built per section, (2) files changed, (3) tests and results, (4) mapping gaps (Maplewold v5 spots, any town place without a spot), (5) what Josh must check on the phone, (6) branch name.

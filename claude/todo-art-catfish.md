# Cat Fish 2.2.x: art todo, split into lanes for parallel agents (2026-10-29)

Rules for every lane: read `claude/art-style-guide.md` and `claude/catfish-art-brief.md` first. Real art replaces the placeholder by the SAME file name. Work only in your lane's files (no two lanes share a file). Do not push to main, do not bump the version. Tools: `tools/catfish_recolor.py`, `tools/catfish_build_art.py`, `tools/gen_placeholder_art.py`. Aseprite sources go in `aseprite-source/catfish/`. Add each new PNG to the test manifest if `tests/catfish.sh` checks it.

## Lane A: gnome scarf (no overlap with other lanes)
- [x] (done, wired) `game/assets/img/gnome/gnome-scarf.png`, 80x100, same canvas as `gnome-hat.png`, tintable layer (grey shades, tinted like the hat).
- Code swap after art: `gnome_scarf_svg()` in `game/includes/gnome.php` -> `pixel_image()` with the scarf tint; drop the red dashed outline and `data-placeholder="1"`.

## Lane B: collars (cat frames)
- [x] (done, wired: `cf-collar-<colour>-<frame>.png`) Neck band on 4 key frames (idleA, pounce, catch, nap) x 6 colours; or one grey band recoloured by `tools/catfish_recolor.py`.
- Replaces CSS ring `.cfcol-<colour>` in `game/assets/catfish.css`. Check the band sits on all 8 coats.

## Lane C: room life (seasons + yarn balls)
- [x] (done, wired: `cf-season-*.png`) Seasonal bits 4-6 px: petal (spring), firefly (summer), leaf (autumn), flake (winter); optional room tint per season. Replaces the 8 CSS dots `.cfseason`, `.cfs-sp/su/au/wi`.
- [x] (done, wired: `cf-yarn-<n>-<colour>.png`) Yarn ball in rose, mint, violet, gold: recolour `cf-yarn-1..4.png`. Replaces `.cfball-*` CSS filter tint (then the CSS colour filter can go).
- [x] (redrawn `cf-yarn-1..4`, `cf-bird-1..3`) Follow-ups: rolling yarn sprite lacks thread and contact shadow; window bird sprite has a 1 px dark outline the overlay robin lacks.

## Lane D: Yarn panel icons
- [x] (done, wired: `cf-yi-<key>.png`, 64 x 64) 16x64 `cf-up-*`-style icons for: hold, stakeout, show2, buddy, keepsake, tune, catnip, treat, bio, collar, season, scarf, bunting, balls, titles (15). Replace the emoji in the Yarn panel rows.

## Lane E: pet shops (only after Joshua picks pet shops; designs in `claude/plan-catfish-petshops.md` section 7)
- [ ] 55 item sprites `cf-pet-<key>.png`, 32-48 px. Start with Steel-pan Chime.
- [ ] 11 shop banners `banner-<code>-pets` 480x120.
- [ ] 11 shopkeeper busts `npc-<slug>` 400x500.
- [ ] 8 slot positions in `room-layout.json` (`pet_slots`).
- [ ] Event props: golden fish, feather, stranger cat (reuse renderer), crumb of yarn.

## Lane F: animation polish (optional, last)
- [ ] Side-cat nap/bored frames that move; a 'watch' head turn.
- [ ] Known gap: catch and nap have no eye pixels, so odd-eyed shows nothing there.

## Not art
- Pals on the Adventure stage use existing equipped pal PNGs at 40 px; only a layout check is needed.

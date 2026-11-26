# Shipped debug and stand-in art: report

Scope: pfight `strip-*` debug masks, `patterns-*` red hatch, magenta key-colour socks, and the stand-in rig kits in `game/assets/img/fight/`. The fight-generic debug text scene was already replaced.

Method: every PNG under `game/assets/img/` (not `wearpiece/`) scanned for pure magenta, pure red and red-channel-only colours; only `pfight/` hit (plus dark catfish tails, which are fur). Each file's name, prefix and the code that builds the name searched in game/, tests/ and tools/. Moved files keep their path relative to `game/`, under `art-review/shipped-debug/assets/img/`.

## UNREFERENCED: moved (14), all from game/assets/img/pfight/parts/
example/strip-foe-trick-{part-base,part-B-hole-mind,part-L-hole-mind,part-R-knob-body,part-T-hole-craft,index,final}.png (old-kit worked example, nothing loads example/; writer is aseprite-source/pfight/layout/felt/gen_parts.py), example/board-demo{,-hand}.png and board-demo{,-pieces}.json (example board/data, not loaded), extras-preview.png (3x preview), ghost-demo-strip.png (the game builds the ghost in code), marks/marks-preview.png (3x preview; build_parts47.py skips "preview").

## NOT SHIPPED ART: masks the code reads and discards, left (12)
- parts/parts-{strip,hand}-{me,foe}.png (4): role-index sheets recoloured through rim.json by pfparts.js / pfparts47.js (used when pfight_jigsaw is 0); source for build_parts47/48.py and tools/build_pf_artifact.py.
- parts/patterns-{strip,hand}.png (2): 1-bit mark-colour masks (red = 255), read as pixels, never drawn.
- parts47|parts48/socks-{strip,hand}.png (4) and stat/socks-any-{strip,hand}.png (2): magenta is the atlas erase colour, turned into transparency to cut the socket hole. Checked by tests/pfparts48.sh, build_parts48.py --check, tests/pf_stat_art.php.

## LIVE ART flagged by mistake, left (8)
parts/icons-{strip,hand}.png (real cream/umber/mint icons) and joint-{h,v}.png in parts/, parts47/, parts48/ (umber and gold, real art).

## LIVE STAND-IN, left; needs a redraw (126)
fight/rig-*.png (125, each loaded by assets/fightrigs.js / fightscene.js; removing any breaks the fight scene) and fight/demo-gnome-side.png (tools/build_pf_artifact.py only). Worst per the review: rig-bog-pike, rig-will-o-wisp, rig-cloud-leopard, rig-clam-lurker, rig-crew-wren, rig-ptarmigan-flock, rig-bullfrog, rig-giant-bumblebee.

## Replaced
None: no live file was debug art a player could see.

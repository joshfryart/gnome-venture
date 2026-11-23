# Pal perch pass - handoff

Branch: `perch-pass` (from `main`). Game repo only; nothing here is in game/assets yet.

## Goal
36x36 perch sprites (chibi miniature of the pal on a small themed base) for the 428 `pl-<family>-<1..6>` pals that lack one.
Live perches: game/assets/img/pals/perch/ (142). Pal sprites (64x64): game/assets/img/pals/ (570).
Fallback when missing: the pal sprite itself (game/includes/hub_pages.php:129; pfdeck_view.php:241 only shows a 36px perch if the file exists).
Pal sprites can't be shrunk into perches: all have content >34px.

## What's here
- `tools/ollama-art/` - phased gvlib drawing pathway (ollama-art.ps1), scorer, batch perch scripts. Ollama is DROPPED; reference only. Needs Aseprite 1.3 headless and gvlib (aseprite-source/gvlib, docs README.md + brief.md).
- `aseprite-source/v3/perch-drafts/` - 93 GLM first drafts (<pal>.png + .lua). Unpolished. `_crop-vegetable-glm-v3/` is an unrelated saved test asset.
- `aseprite-source/v3/perch/` - existing procedural generator (README.txt, perch_gen.lua, build_params.py) covering 475 pals.
- Style examples (pal + perch pairs): bb-catkin-crown, ss-cocopaddle, mm-gatepost-hoot, pl-owl-4.

## Perch rules
36x36, transparent, 1px clear border, no semi-transparent pixels, 1px dark selective outline (not pure black), light from upper-left, head ~40-45% of height, big round eyes, tiny mouth, small themed base, soft shadow ellipse, 1-2 tiny accents from the pal, same palette, readable at 16px.

## Open items (in order)
1. Decide if the 428 perches are needed: look at the pfdeck_view fallback. If fine, stop and report.
2. If needed: contact-sheet the 93 drafts, keep good ones, redraw/polish the rest, draw the ~335 never drawn (reuse perch_gen.lua where it fits).
3. Copy finished PNGs to game/assets/img/pals/perch/ on this branch.
4. Optional code fixes: gvlib.lua ~421 (stitch ignores side="shade"); trek-pixel/scripts/trek-me.lua ~96-105 (`right` computed then overwritten; redundant `not (y >= 17)`); stale halo note in HANDOFF.md; hard-coded C:/Users/hello paths (ui-chrome.lua, gvlib/example.lua, gnome-common.lua, gnome-composite.lua).

## Don't
Touch the unrelated untracked storybook files; use Ollama; push to main or open a PR unasked.

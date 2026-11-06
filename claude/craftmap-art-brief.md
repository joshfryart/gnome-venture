# Crafting area map: art brief (pilot)

One 64 x 64 Stitched Toy tile picture per crafting area, gvlib "icon" mode. Shown on a tappable tile (~96 px, also ~40 px in a compact strip), so it must read at 1x, 0.5x and on a phone.
Style: claude/art-style-guide.md Part D, aseprite-source/gvlib/README.md + brief.md. House examples: aseprite-source/catfish/cf_icons.lua and PNGs in game/assets/img/catfish/cf-up-*.png.
Rules: hard pixels, alpha 0/255, hue-shifted ramps, 1 px #000000 border, three-tone umber outline, crescent shade lower right, light upper left, gloss comma, gold thread seam/stitch where a seam exists, parts >= 3 px, margin >= 3, <= ~28 colours, no text, no loaded symbols. One object, one clear silhouette, one dominant colour per area so the 7 tiles differ at a glance.

Pilot areas and subjects (dominant colour):
- cooking: black-iron skillet or pot on a tiny flame, steam curl, wooden spoon (red/orange)
- pantry: glass jar of jam, gingham cloth lid tied with gold twine (plum/purple)
- tools: hammer crossed with a trowel or spanner, wooden handles (steel blue + wood)
- potions: round flask, green potion, cork, 1-2 sparkles (teal/green)

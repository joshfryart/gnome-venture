# Pal brief: Lighthouse of the Lost Lantern

- Picture: `wonder-lighthouse-of-the-lost-lantern` (Places, 360x240 file px; Advanced cell 30x30 file px, 15x15 art px)
- Kind: **wonder** (keyhole knobs, sprites)
- Flavour: Help the keeper relight it; rewards coastal finds.
- Scene script note: wonder-lighthouse-of-the-lost-lantern.lua : unique-location scene (off-path "wonder"), 480 x 270 = 240 x 135 grid at 2x.
  Brief (wonder_text.txt): "The old lighthouse has gone dark. Its keeper, a retired crab, looks up hopefully, holding a wick."
  Thing to do: relight the lamp (check). Dusk, because the dark lamp must read. Scene mode: no black border, hem stitch top and bottom.
  Params: out=<png path> ase=<.aseprite path>   (--script-param BEFORE --script)
- Motif words: lighthouse, lost, lantern, unique, location
- Dominant colours: #50669b, #2e2038, #323e70

## Roster

Not authored yet (see claude/plan-places-pals.md s1). Draft 6 rows: 3 common, 2 uncommon, 1 rare.

## Rules (claude/plan-puzzle-pals.md s6)

- Every pal is a living jigsaw piece; its shape is its type. Roster of 6 = 3 common (corner + edge + plain inner), 2 uncommon (two of Plus inner-TTTT, Ring inner-BBBB, TTBB inner-TTBB, different knobs), 1 rare (a whimsy-* novelty piece cut to the place's subject).
- No two pals in a roster share shape+knob. Knob from the kind mood: keyhole knobs, sprites.
- Fill = one Advanced cell of this picture (the `piece` column, col-row on 12x8); at 15x15 art px it is nearly flat, so upscale it and use the 3 dominant colours above, calm tones. The place shows in palette + accessory.
- Face: eyes (3 styles), a mouth, stubby limbs on tabs, and one accessory per pal taken from the motif words.
- Rarity look: common = flat outline; uncommon = a second accent colour from the picture; rare = glow + sparkle mark and a signature accessory. The rarity frame stays CSS.
- Names are unique across all pictures (tools/dedupe_puzzle_pals.py); no NPC names; curly apostrophes only.

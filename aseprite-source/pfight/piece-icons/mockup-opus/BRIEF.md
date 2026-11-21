# Brief: hand-drawn pixel icons for creature pieces (Opus pass)

You draw one 32x32 and one 20x20 pixel icon per row in your batch file `batches/bNN.txt`.
Row format: `slug|Piece Name|type|tag|Creature|creature flavour text`. Type is hurt (orange), guard (blue), heal (green) or trick (yellow). Tag (quick, evade, thorns, ...) is optional gameplay flavour: a tiny cue is welcome only if it doesn't clutter.

## Approved reference (the user liked these 5 — match their quality and look)
- `mockup-opus/sheet.png` (view it), grids in `mockup-opus/grids/<slug>-32.txt` / `-20.txt`, palette setup in `mockup-opus/mockup.py`, renderer in `mockup-opus/pix.py` (imports TYPES from `../../gen_pfight.py`).
- Existing game icons: `game/assets/img/pfight/ico-hurt|guard|heal|trick|charm|soothe|item|bash|sting|thornhide.png` (+ `-s.png`). View them upscaled with PIL NEAREST.
- How each approved icon works: a typed character grid (one char per pixel, '.' clear). k ink, C cream, H white gloss, G gold; type chars B base, L light, D dark, E darkest; extra per-icon chars you define in a palette dict. The renderer adds the 1px ink edge and (32px only) a cream halo. Each size is drawn on its own, 20px is NOT a downscale.

## Quality bar
- One bold, readable silhouette filling most of the canvas; the type's base colour (B/L/D) dominates the shape. Think: what single image says this piece for this creature? Prefer the creature itself or its signature feature/action, simple and iconic, not a scene.
- Not sparse, not scattered, no stray floating dots. Hard pixels only. Light from top-left, 1-2px gloss.
- Within one creature the 3-4 pieces must look like a family (same creature design, different pose/action/feature) yet read apart from each other.
- Known weak points to avoid: animals that read as the wrong animal (give each a distinct signature: ears, snout, beak, horns, stripes...), thin 1px limbs that vanish at 20px, suckers/details that turn to noise.
- Iterate: render, view at 8x, critique, redraw. Check the 20px too.

## Deliverable (only inside `mockup-opus/bNN/`, your batch folder; touch nothing else, do NOT commit or push)
- `bNN/grids/<slug>-32.txt` and `-20.txt` for every row.
- `bNN/make.py`: your palette/ICON table + rendering (model on `mockup-opus/mockup.py`; import `pix` via sys.path to the parent folder). Writes `bNN/ico-<slug>.png` (32x32), `bNN/ico-<slug>-s.png` (20x20) and `bNN/sheet.png` (all icons at 32 and 20, upscaled, with ico-hurt/guard/heal/trick for comparison).
- Final report: 2-4 lines max: done count, any icon you consider weak (slug + why).

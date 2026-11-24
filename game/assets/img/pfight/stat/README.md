# pfight stat kit (art for the stat pieces)
Separate small PNGs; `parts48/` and its atlas.json are untouched. Hard pixels, no partial alpha, ink #2a1a10, no pure black/white. Drawn in the Opus pass (small art is hand-placed letter grids inside `kit.lua`; only the socket profile and the snare ring are computed, so they fit the v47 edges and the board pitch)
(sources and the Lua/Python that make them: `aseprite-source/pfight/stat-kit/`; re-render: `cd aseprite-source/pfight/stat-kit/scripts && /tmp/aseq/squashfs-root/AppRun -b --script kit.lua && python3 build.py`).
Sizes follow `parts48/atlas.json` (`sizes.strip`: piece 82x73, body 56x47 at (13,13), tab 13, badge 11; `sizes.hand`: piece 140x124, body 96x80 at (22,22), tab 22, badge 18).

| file (strip / hand) | size strip / hand | what |
|---|---|---|
| `socks-any-strip.png` / `-hand.png` | 164x73 / 280x124 | 2 cells of one piece size: cell 0 = `any-knob`, cell 1 = `any-hole`; all four sides in each cell, exactly like `socks-*` |
| `envtile-spring-<size>.png` | 82x73 / 140x124 | Spring environment tile (parchment body, blossom-pink dashed stitch), no glyph; one cell, same as an `envtiles-*` cell |
| `envglyph-spring-<size>.png` | 82x73 / 140x124 | its glyph (a five-petal pink blossom, gold eye, stem and two leaves, a dew drop on the right leaf), one cell, centred on atlas `glyph_centre` like `envglyphs-*` (about 20x19 / 34x32 with outline) |
| `snare-<size>.png` | 56x47 / 96x80 | the hidden snare: a dashed twine noose (an oval, 37x31 / 63x53) with three woven leaves (left, right, bottom) and a knot with two loose ends at the top, a BOARD CELL overlay (body/pitch size, not piece size) |
| `badges-stat-<size>.png` | 44x11 / 72x18 | 4 badges in one row: nimble, lore, luck, sense (cell 11x11 / 18x18, same plate and corner cut as `badges-*`) |
| `stolen-<size>.png` | 14x14 / 24x24 | steel fish-hook (barbed point up-left) with a violet thread still through its eye, for a creature piece taken by Turn of the Tale or Magpie's Pinch |

Order constants for code: `socks_any: ["any-knob","any-hole"]`, `stat_badges: ["nimble","lore","luck","sense"]`. Fixed-order sheets, no atlas entry (add one in code, e.g. `stat: {...}`).

## How code composites each
1. **Any sockets.** Same stamping as `build47`/`build48` for sockets: take the cell `i` (0 knob, 1 hole) of `socks-any-<size>.png`, crop the side with `sizes.<size>.socks[top|right|bottom|left]`, and for every pixel with alpha: pure magenta (255,0,255) = set the piece pixel transparent (the cut-out), any other colour = copy it. Edge kind string `any`: `ord.socks` would need `any-knob`/`any-hole` (family `any`). The knob is a kite (diamond) head on a short neck, made of three twisted strands (body red, mind violet, craft gold), each strand shaded light/base/shade across its width so it reads as twine; the strands keep one handedness on all four sides. The hole is the same profile cut out, with a 1 px ink rim and a 1 px rim in the three strand colours. Knob fills hole exactly (tested at pitch: 0 uncovered pixels, both sizes). Stamp order unchanged: tile, socks, glyph, plate, number, marks.
2. **Spring tile + glyph.** Draw `envtile-spring-<size>` as the piece body (instead of an `envtiles` cell: kinds order sun, bramble, rain, wind, mud, thorn, then `spring`), then sockets, then the glyph file at (0,0). No number, no owner badge. Both cells are full piece size.
3. **Snare.** Draw `snare-<size>.png` over the board CELL at the cell's body-origin (the cell is body-size 56x47 / 96x80, pitch = body), centred, after the cell background and before pieces/ghost. It is faint by dashing, never by alpha: each dash is a short twisted strand (pale, green, dark green), with ink on the outside edge (reads on light cells) and, at hand size, a pale-green inside edge (reads on dark cells). The ring is open at the top where the knot sits. If the cell is scaled, use the same whole-number factor as the piece canvas.
4. **Stat badges.** `drawImage(badges-stat-<size>, i*badge, 0, badge, badge, owner.x, owner.y, badge, badge)` with `i` = nimble 0, lore 1, luck 2, sense 3, at the same top-right slot as the owner badge (body (42,3) strip / (73,5) hand, i.e. piece (55,16) strip / (95,27) hand, `sizes.<size>.owner`).
5. **Stolen mark.** Draw `stolen-<size>.png` over the creature piece, at body (2,18) strip / (3,28) hand = piece (15,31) / (25,50): left of the glyph box, under the plate, clear of owner and star/flip badges. Drawn after the number. (Hand art is the same drawing redrawn at 24 px; for a 1.5x enlargement of the strip mark use strip art, as `marks/` do.)

## Notes (Opus pass)
Badge icons: nimble = double chevron, lore = page with a folded corner and ink lines, luck = four-leaf clover, sense = leaf with a midrib (the eye glyph is taken by the creature `eye` badge). Strip icons are 9x9 and hand icons 14x14, each drawn separately (not scaled). The badge plate copies `badges-*` (ink frame, cut corners, flat fill).
The strip stolen mark is 14 px, so the thread is a 1 px line; it reads as a hook on a line, but the hand art is much clearer.

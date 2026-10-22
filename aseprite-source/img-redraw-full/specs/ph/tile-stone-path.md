# ph/tile-stone-path
- canvas: 64x64, mode scene (seamless tile, full-bleed, no halo, no outline), 1x.
- subject: A flagstone path tile: irregular rounded grey and cream paving stones laid with dark grout gaps; plain and walkable.
- must-read-at-16px: cream stone at top right and cream stone at bottom left against grey stones and dark grout.
- distinct: seven irregular flagstones of mixed sizes (not a regular grid), only two cream stones on opposite corners.
- parts (back to front):
  1. grout fill: whole tile #6a6070
  2. stones, rrect r4, 3px grout gaps: (3,3)-(28,19) #968f96; (32,3)-(60,24) #d6c9b6; (3,23)-(22,42) #968f96; (26,28)-(46,42) #968f96; (50,28)-(60,43) #968f96; (3,46)-(32,60) #d6c9b6; (36,46)-(60,60) #968f96
  3. per-stone 1px rim #c9c5bc upper-left, 1px shade #5b6470 lower-right
  4. gloss: 4x2 light dash at (6,6)
  5. cracks: 3-4px lines #2a1a10 at (12,20),(44,8),(26,46),(52,38),(8,56),(36,28)
- joins: seamless on all four edges; keep grout continuous at x/y 0 and 63.
- face: none.
- notes: no halo, no thread stitch. Full-bleed.

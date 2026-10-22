# gather/pick-bg
- canvas: 200x200, mode scene (full-bleed, no halo), draw at half-size (100x100), write 2x.
- subject: Backdrop for a foraging/digging minigame: five wavy horizontal soil-and-rock strata from dark topsoil down to slate bedrock; calm, earthy, uncluttered so pickups read on top.
- must-read-at-16px: five distinct horizontal colour bands; light tan second from top, grey stone in the middle.
- distinct: layered wavy strata with a grey stone band holding a darker oval pebble and faint dark crack lines; no objects, no horizon, no sky.
- parts (final 200x200 coords, back to front):
  1. base fill: whole canvas #5b4430 (soil #3d2a1c / #7a4a1f family)
  2. topsoil band y 0..~48, wavy lower edge (54 at x50, 46 at x100): #6e5238; 4 pebble dots r2-3 #8a6c48
  3. sand band y ~50..~95, wavy edges: #b99c6b (soil #c9a96e); 4 lighter dots #d3b985
  4. stone band y ~95..~137: #7d8088 (stone #8b8f96/#5b6470); two curved 2px light streaks #9a9da6 at (10..70,112) and (110..180,118); dark oval #6b6e76 at (150,104) rx9 ry4
  5. clay band y ~138..~172: #a8643a (wood #a8582f); 3 lighter dots #c98550; short dark arc #7d4424 at (40..58,160)
  6. bedrock band y ~172..200: #4f5563 (stone #5b6470 darker); 3 dots #6b7280
  7. cracks: thin dark #2f241a zigzags (70,0)->(64,24)->(72,42); (130,100)->(126,120)->(136,134); (26,140)->(34,156)
  8. depth: bottom band uses the next-darker ramp shade; no gradient, no dither
- joins: none (optional thread-gold hem stitch along the top edge).
- face: none.
- notes: scene full-bleed, no halo; hard pixel bands; keep the centre calm for pickups.

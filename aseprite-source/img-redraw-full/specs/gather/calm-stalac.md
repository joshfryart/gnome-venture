# gather/calm-stalac
- canvas: 64x64, mode scene (full-bleed), 1x.
- subject: A calm cave stalactite hanging from the top edge, grey-green rock with one bright water drop gathering at the tip; quiet and still.
- must-read-at-16px: a tapering rock spike hanging from the top with a blue drop at the end.
- distinct: one wide stalactite bleeding off the top edge, tapering to a tip at (32,62), lit left half and darker right half.
- parts (back to front):
  1. rock mass: polygon (0,0),(64,0),(64,6),(54,20),(34,62),(30,62),(10,20),(0,6), base #7f8f86 (stone)
  2. lit left half: same shape, x<=32, base #9fb0a6
  3. highlight vein: 2px curve (14,8)->(20,30)->(28,52), #d3e0d8
  4. shade vein: 2px curve (46,10)->(44,30)->(36,50), #5e6e66
  5. water drop: ellipse (32,60) rx3 ry2.5, #bfe6f4 with 1px glint #fff3c8
- joins: none.
- face: none.
- notes: scene: bleeds off top and sides, no halo, outline per part. Keep the drop 2px above the bottom frame.

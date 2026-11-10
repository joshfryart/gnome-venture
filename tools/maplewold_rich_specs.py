"""Richness pass for the Maplewold bendy maps: what each tile LOOKS like. Read by tools/render_bendy_rich.py.
The tile rows in claude/maplewold-bendy-maps/route-<id>.json are NOT changed: this only dresses them.
One dict per section:
  looks   [(kind, x0, y0, x1, y1)]  look of the thicket (#) cells in a rect: haybale, fence, hedge, apple, pond, reeds, tree, bush, boulder
  rough   [(kind, x0, y0, x1, y1)]  look of the rough (,) cells in a rect: wheat, flowers, marsh, clover (default: tall grass)
  floor   [(kind, x0, y0, x1, y1)]  look of the plain floor (.) cells in a rect: furrows (a vegetable plot, still walkable)
  lm_at   {landmark name: (x, y)}   draw a landmark sprite on another tile than the data says (mockup only)
  props   [(kind, x, y)]            small things on free walkable tiles (never block); duck, rowboat, jetty go on water. Kinds: PROPS in the renderer
  scatter dict of extra ground scatter near a look: handled by the renderer (straw by bales, apples under apple trees, leaves by trees)
All streams come from the section's own `water` field."""
RICH = {}

RICH[228] = [
 dict(   # the scarecrow field, and the hay-bale maze
  looks=[("haybale", 6, 2, 13, 8), ("fence", 22, 2, 22, 5), ("fence", 24, 2, 24, 2), ("fence", 26, 2, 26, 2), ("boulder", 1, 12, 1, 12)],
  rough=[("wheat", 21, 5, 28, 11), ("flowers", 20, 12, 28, 16), ("clover", 6, 9, 13, 11), ("flowers", 12, 12, 17, 14)],
  floor=[("furrows", 23, 3, 25, 4), ("furrows", 7, 13, 11, 15)],
  props=[("goat", 8, 4), ("hen", 10, 4), ("hen", 13, 9), ("pitchfork", 11, 5), ("wheelbarrow", 15, 3), ("signpost", 21, 1), ("pumpkins", 21, 11), ("pumpkins", 28, 9),
         ("crows", 21, 10), ("crate", 14, 9), ("stump", 4, 10), ("basket", 6, 14), ("rabbit", 14, 15), ("log", 3, 9), ("sacks", 12, 13)]),
 dict(   # the stepping-stone ford, and the old mill pond
  looks=[("pond", 1, 11, 10, 16), ("fence", 21, 3, 25, 3), ("reeds", 25, 12, 25, 12), ("reeds", 23, 14, 23, 14), ("reeds", 26, 15, 28, 16), ("reeds", 20, 15, 21, 16),
         ("boulder", 15, 3, 15, 3), ("bush", 24, 1, 24, 1)],
  rough=[("marsh", 20, 9, 28, 16), ("marsh", 12, 9, 18, 14), ("flowers", 8, 1, 14, 6), ("clover", 20, 2, 27, 6)],
  lm_at={"ford": (9, 7)},
  props=[("duck", 6, 13), ("duck", 8, 15), ("rowboat", 4, 14), ("jetty", 10, 14), ("sacks", 12, 12), ("wheelbarrow", 15, 12), ("stump", 12, 3), ("crate", 12, 15),
         ("basket", 26, 8), ("rabbit", 25, 5), ("log", 6, 5), ("bench", 18, 4), ("hen", 11, 15)]),
 dict(   # the lone apple tree, and the hedge-row lane
  looks=[("apple", 3, 3, 10, 8), ("hedge", 3, 9, 11, 9), ("hedge", 19, 9, 27, 9), ("hedge", 3, 13, 10, 13), ("hedge", 20, 13, 27, 13), ("hedge", 8, 10, 8, 12),
         ("hedge", 22, 10, 25, 10), ("hedge", 24, 11, 24, 11),
         ("topiary", 3, 9, 3, 9), ("topiary", 11, 9, 11, 9), ("topiary", 19, 9, 19, 9), ("topiary", 27, 9, 27, 9), ("topiary", 3, 13, 3, 13), ("topiary", 10, 13, 10, 13),
         ("topiary", 20, 13, 20, 13), ("topiary", 27, 13, 27, 13)],
  rough=[("clover", 1, 1, 12, 8), ("marsh", 22, 14, 28, 16), ("flowers", 9, 10, 21, 12), ("flowers", 3, 14, 15, 16)],
  props=[("basket", 6, 4), ("basket", 4, 6), ("crate", 11, 6), ("ladder", 6, 5), ("signpost", 14, 1), ("stump", 19, 15), ("pumpkins", 4, 11), ("pumpkins", 26, 11),
         ("bench", 12, 11), ("wheelbarrow", 18, 12), ("rabbit", 5, 11), ("log", 17, 15), ("hen", 2, 7)]),
]

"""Richness pass for the Maplewold bendy maps: what each tile LOOKS like. Read by tools/render_bendy_rich.py.
The tile rows in claude/maplewold-bendy-maps/route-<id>.json are NOT changed: this only dresses them.
One dict per section:
  looks   [(kind, x0, y0, x1, y1)]  look of the thicket (#) cells in a rect: haybale, fence, hedge, apple, pond, reeds, tree, bush, boulder
  rough   [(kind, x0, y0, x1, y1)]  look of the rough (,) cells in a rect: wheat, flowers, marsh, clover (default: tall grass)
  floor   [(kind, x0, y0, x1, y1)]  look of the plain floor (.) cells in a rect: furrows (a vegetable plot, still walkable)
  lm_at   {landmark name: (x, y)}   draw a landmark sprite on another tile than the data says (mockup only)
  props   [(kind, x, y)]            small things on free walkable tiles (never block); duck, rowboat, jetty go on water. Kinds: PROPS in the renderer
  tree    "birch" | "maple"         what the plain trees of the section are (default: by land)
  auto    False = do not add the looks derived from the builder's stamps (see auto() below);  ambient False = no extra animals and bits
Ground scatter (straw by bales, apples under apple trees, shells by the sea ...) is the renderer's. All streams come from the section's own `water` field.
Kinds: LOOKS, ROUGH, PROPS in tools/render_bendy_rich.py."""
RICH = {}

RICH[228] = [
 dict(auto=False,   # the scarecrow field, and the hay-bale maze
  looks=[("haybale", 6, 2, 13, 8), ("fence", 22, 2, 22, 5), ("fence", 24, 2, 24, 2), ("fence", 26, 2, 26, 2), ("boulder", 1, 12, 1, 12)],
  rough=[("wheat", 21, 5, 28, 11), ("flowers", 20, 12, 28, 16), ("clover", 6, 9, 13, 11), ("flowers", 12, 12, 17, 14)],
  floor=[("furrows", 23, 3, 25, 4), ("furrows", 7, 13, 11, 15)],
  props=[("goat", 8, 4), ("hen", 10, 4), ("hen", 13, 9), ("pitchfork", 11, 5), ("wheelbarrow", 15, 3), ("signpost", 21, 1), ("pumpkins", 21, 11), ("pumpkins", 28, 9),
         ("crows", 21, 10), ("crate", 14, 9), ("stump", 4, 10), ("basket", 6, 14), ("rabbit", 14, 15), ("log", 3, 9), ("sacks", 12, 13)]),
 dict(auto=False,   # the stepping-stone ford, and the old mill pond
  looks=[("pond", 1, 11, 10, 16), ("fence", 21, 3, 25, 3), ("reeds", 25, 12, 25, 12), ("reeds", 23, 14, 23, 14), ("reeds", 26, 15, 28, 16), ("reeds", 20, 15, 21, 16),
         ("boulder", 15, 3, 15, 3), ("bush", 24, 1, 24, 1)],
  rough=[("marsh", 20, 9, 28, 16), ("marsh", 12, 9, 18, 14), ("flowers", 8, 1, 14, 6), ("clover", 20, 2, 27, 6)],
  lm_at={"ford": (9, 7)},
  props=[("duck", 6, 13), ("duck", 8, 15), ("rowboat", 4, 14), ("jetty", 10, 14), ("sacks", 12, 12), ("wheelbarrow", 15, 12), ("stump", 12, 3), ("crate", 12, 15),
         ("basket", 26, 8), ("rabbit", 25, 5), ("log", 6, 5), ("bench", 18, 4), ("hen", 11, 15)]),
 dict(auto=False,   # the lone apple tree, and the hedge-row lane
  looks=[("apple", 3, 3, 10, 8), ("hedge", 3, 9, 11, 9), ("hedge", 19, 9, 27, 9), ("hedge", 3, 13, 10, 13), ("hedge", 20, 13, 27, 13), ("hedge", 8, 10, 8, 12),
         ("hedge", 22, 10, 25, 10), ("hedge", 24, 11, 24, 11),
         ("topiary", 3, 9, 3, 9), ("topiary", 11, 9, 11, 9), ("topiary", 19, 9, 19, 9), ("topiary", 27, 9, 27, 9), ("topiary", 3, 13, 3, 13), ("topiary", 10, 13, 10, 13),
         ("topiary", 20, 13, 20, 13), ("topiary", 27, 13, 27, 13)],
  rough=[("clover", 1, 1, 12, 8), ("marsh", 22, 14, 28, 16), ("flowers", 9, 10, 21, 12), ("flowers", 3, 14, 15, 16)],
  props=[("basket", 6, 4), ("basket", 4, 6), ("crate", 11, 6), ("ladder", 6, 5), ("signpost", 14, 1), ("stump", 19, 15), ("pumpkins", 4, 11), ("pumpkins", 26, 11),
         ("bench", 12, 11), ("wheelbarrow", 18, 12), ("rabbit", 5, 11), ("log", 17, 15), ("hen", 2, 7)]),
]

def R(*a, **k): return dict(looks=list(k.pop("looks", [])), rough=list(k.pop("rough", [])), props=list(k.pop("props", [])), **k)
SEA_S = lambda y: ("sea", 0, y, 29, 17)
RICH[232] = [
 R(looks=[("berry", 19, 11, 23, 13), ("berry", 22, 13, 26, 15)], rough=[("flowers", 5, 7, 11, 13), ("flowers", 22, 11, 26, 15)],
   props=[("skep", 6, 9), ("skep", 10, 8), ("skep", 9, 11), ("basket", 21, 12), ("basket", 25, 14), ("wheelbarrow", 5, 11), ("signpost", 3, 8), ("bench", 14, 14)]),
 R(rough=[("clover", 17, 7, 25, 13)], props=[("bucket", 22, 11), ("bucket", 20, 11), ("bench", 23, 9), ("ladder", 24, 5), ("basket", 23, 5), ("duck", 5, 14), ("hen", 19, 12), ("crate", 26, 6)]),
 R(rough=[("gravel", 11, 2, 12, 15), ("gravel", 3, 12, 10, 12), ("gravel", 17, 3, 27, 3), ("clover", 20, 9, 26, 15)],
   props=[("signpost", 13, 12), ("picnic", 23, 12), ("basket", 25, 11), ("bench", 10, 11), ("pumpkins", 23, 15), ("wheelbarrow", 25, 15), ("lantern", 13, 10)]),
]
RICH[236] = [
 R(rough=[("flowers", 6, 10, 12, 16), ("flowers", 21, 0, 27, 6), ("flowers", 3, 1, 7, 5), ("clover", 17, 10, 23, 16)], props=[("bench", 12, 11), ("basket", 8, 12), ("skep", 24, 5), ("signpost", 3, 9)]),
 R(looks=[("beanpole", 20, 11, 27, 13)], floor=[("furrows", 20, 14, 27, 15), ("furrows", 20, 9, 27, 10)],
   props=[("wheelbarrow", 19, 12), ("basket", 21, 12), ("pumpkins", 23, 12), ("crate", 25, 12), ("pitchfork", 27, 12), ("duck", 5, 15), ("bench", 12, 9), ("hen", 18, 14)]),
 R(looks=[("haybale", 21, 9, 22, 9)], rough=[("clover", 11, 4, 15, 8)], props=[("sacks", 14, 8), ("sacks", 11, 7), ("pitchfork", 20, 9), ("hen", 22, 11), ("hen", 19, 11), ("crate", 15, 6), ("wheelbarrow", 23, 10), ("goat", 6, 14)]),
]
RICH[311] = [
 R(tree="maple", looks=[("maple", 10, 8, 25, 8), ("barrels", 20, 16, 22, 16), ("barrels", 11, 14, 13, 16)], rough=[("leaves", 8, 6, 27, 10)],
   props=[("bucket", 11, 9), ("bucket", 14, 9), ("bucket", 17, 9), ("bucket", 20, 9), ("bucket", 23, 9), ("sled", 24, 10), ("crate", 12, 13), ("sacks", 14, 14), ("lantern", 9, 8)]),
 R(tree="maple", looks=[("maple", 22, 2, 27, 4)], rough=[("gravel", 17, 3, 23, 9)],
   props=[("bucket", 22, 8), ("crate", 18, 7), ("sacks", 22, 6), ("bench", 18, 9), ("lantern", 23, 9), ("wheelbarrow", 17, 5), ("picnic", 9, 11), ("picnic", 6, 11), ("bench", 11, 11), ("hen", 20, 10)]),
]
RICH[304] = [
 R(looks=[("boulder", 17, 5, 21, 9)], rough=[("leaves", 5, 9, 11, 15)], props=[("owl", 9, 10), ("lantern", 19, 9), ("squirrel", 22, 7)]),
 R(rough=[("leaves", 20, 11, 24, 15)], props=[("owl", 13, 7), ("squirrel", 22, 12), ("squirrel", 24, 13), ("basket", 21, 14)]),
]
RICH[305] = [
 R(tree="birch", looks=[("birch", 13, 1, 14, 10), ("birch", 20, 1, 21, 10), ("birch", 10, 14, 26, 14)], rough=[("flowers", 14, 1, 20, 12)], props=[("lantern", 16, 2), ("bench", 18, 12), ("owl", 22, 12)]),
 R(tree="birch", rough=[("ferns", 15, 6, 21, 12), ("flowers", 3, 10, 9, 16)], props=[("picnic", 6, 14), ("fox", 8, 12), ("basket", 5, 12), ("stump", 19, 9)]),
]
RICH[306] = [
 R(looks=[("biglog", 17, 14, 23, 14), ("boulder", 8, 2, 12, 7)], rough=[("toadstools", 16, 13, 24, 15), ("glowcaps", 6, 1, 13, 8)], props=[("lantern", 9, 8), ("squirrel", 20, 13), ("owl", 23, 10)]),
 R(looks=[("boulder", 20, 1, 20, 16)], rough=[("toadstools", 10, 6, 18, 13)], props=[("lantern", 21, 13), ("lantern", 19, 13), ("fox", 8, 13), ("basket", 11, 11)]),
]
RICH[312] = [
 R(looks=[("biglog", 17, 12, 25, 12)], rough=[("leaves", 16, 10, 26, 14)], props=[("squirrel", 21, 11), ("owl", 13, 5), ("basket", 19, 13)]),
 R(looks=[("bramble", 2, 7, 13, 7), ("bramble", 2, 12, 13, 12), ("bigshroom", 22, 12, 22, 12)], rough=[("toadstools", 20, 10, 24, 14)], props=[("fox", 8, 10), ("basket", 14, 9), ("lantern", 19, 12)]),
 R(rough=[("leaves", 13, 10, 19, 16)], props=[("squirrel", 7, 6), ("squirrel", 5, 6), ("squirrel", 8, 5), ("crate", 6, 6), ("basket", 9, 6), ("sacks", 15, 14), ("lantern", 17, 12)]),
]
RICH[313] = [
 R(looks=[("sticks", 13, 1, 14, 16), ("pond", 15, 1, 22, 5), ("pond", 17, 13, 24, 16)], rough=[("mud", 22, 10, 28, 16)], props=[("beaver", 18, 3), ("beaver", 20, 14), ("log", 11, 6), ("stump", 10, 4), ("stump", 9, 12), ("log", 26, 12)]),
 R(looks=[("sticks", 14, 2, 14, 16), ("pond", 7, 1, 11, 4)], rough=[("mud", 8, 3, 10, 5)], props=[("beaver", 9, 2), ("log", 12, 13), ("stump", 11, 15), ("stump", 16, 13), ("lantern", 13, 12)]),
 R(looks=[("glowrock", 20, 6, 28, 9), ("glowrock", 20, 13, 28, 16)], rough=[("glowcaps", 0, 0, 29, 17)], props=[("lantern", 18, 10), ("lantern", 18, 12), ("crate", 17, 13), ("fox", 6, 12)]),
]
RICH[307] = [
 R(looks=[SEA_S(15)], rough=[("kelp", 1, 13, 28, 14)], props=[("rowboat", 6, 15), ("lobsterpot", 12, 12), ("lobsterpot", 13, 12), ("gull", 20, 6), ("gull", 22, 5), ("crab", 18, 12), ("driftlog", 8, 12)]),
 R(looks=[SEA_S(15), ("dunetuft", 1, 1, 28, 2), ("pond", 20, 10, 24, 14)], rough=[("shells", 4, 9, 10, 13)], props=[("bucket", 20, 10), ("crab", 22, 9), ("gull", 24, 9), ("rowboat", 10, 15), ("basket", 7, 11), ("lobsterpot", 15, 13)]),
]
RICH[308] = [
 R(looks=[SEA_S(14)], rough=[("pebbles", 8, 10, 27, 12), ("kelp", 9, 13, 16, 13)], props=[("rowboat", 22, 15), ("lobsterpot", 23, 11), ("gull", 19, 11), ("gull", 12, 11), ("driftlog", 6, 12), ("crab", 14, 12)]),
 R(looks=[SEA_S(14), ("pond", 17, 10, 23, 13)], rough=[("shells", 17, 8, 23, 12)], props=[("crab", 18, 9), ("crab", 22, 9), ("bucket", 20, 8), ("gull", 9, 11), ("lobsterpot", 11, 12), ("driftlog", 4, 11)]),
]
RICH[314] = [
 R(looks=[("sea", 8, 0, 29, 2), ("driftwood", 7, 12, 7, 12)], rough=[("shells", 15, 8, 21, 12), ("shells", 5, 9, 8, 11)], props=[("driftlog", 5, 11), ("driftlog", 9, 11), ("driftlog", 6, 13), ("basket", 19, 11), ("gull", 12, 4), ("rowboat", 20, 1), ("lobsterpot", 22, 4)]),
 R(looks=[("sea", 0, 12, 29, 17)], rough=[("shells", 20, 6, 24, 10)], props=[("lantern", 15, 7), ("lantern", 13, 3), ("gull", 4, 8), ("gull", 6, 10), ("rowboat", 22, 14), ("driftlog", 18, 10)]),
 R(looks=[("sea", 0, 14, 10, 17), ("driftwood", 13, 10, 13, 10)], props=[("lantern", 24, 9), ("lantern", 26, 7), ("lantern", 26, 11)] + [("gull", x, y) for x, y in ((12, 9), (14, 11), (16, 10), (15, 8), (12, 12), (17, 12), (13, 7), (18, 9))] + [("rowboat", 4, 15)]),
]
RICH[309] = [
 R(looks=[("snowman", 19, 3, 27, 3), ("snowman", 21, 12, 27, 12)], rough=[("ice", 4, 9, 14, 17)], props=[("sled", 16, 4), ("bucket", 22, 4), ("lamp", 18, 5), ("hare", 8, 8)]),
 R(looks=[("icewall", 15, 1, 16, 16), ("icicle", 20, 13, 27, 14)], props=[("lamp", 14, 7), ("lamp", 17, 7), ("arcticfox", 11, 6), ("sled", 22, 10)]),
]
RICH[310] = [
 R(looks=[("snowbank", 12, 1, 16, 5), ("snowbank", 12, 10, 16, 16)], rough=[("tracks", 3, 12, 25, 15)], props=[("sled", 20, 12), ("sled", 8, 14), ("lamp", 17, 6), ("lamp", 11, 8)]),
 R(looks=[("snowbank", 19, 12, 27, 13), ("icicle", 18, 14, 28, 14), ("icicle", 9, 1, 15, 1)], props=[("sled", 21, 11), ("lamp", 11, 3), ("snowyowl", 12, 2)]),
]
RICH[315] = [
 R(looks=[("snowwall", 2, 1, 3, 16)], rough=[("tracks", 4, 6, 28, 10)], props=[("lamp", x, y) for x, y in ((7, 9), (11, 7), (15, 9), (19, 7), (23, 9), (26, 7))]),
 R(looks=[("snowwall", 20, 10, 26, 14)], props=[("sled", 9, 6), ("lamp", 13, 5), ("campfire", 23, 11), ("bucket", 22, 13), ("crate", 24, 13), ("lamp", 18, 14)]),
 R(looks=[("icicle", 14, 6, 16, 10)], props=[("lamp", 13, 8), ("lamp", 17, 8), ("sled", 9, 6), ("arcticfox", 22, 12)]),
 R(looks=[("cairn", 18, 10, 27, 16)], rough=[("ice", 6, 1, 17, 6)], props=[("snowyowl", 22, 11), ("lamp", 18, 9)]),
 R(looks=[("snowbank", 22, 1, 28, 4), ("snowbank", 22, 10, 28, 16)], rough=[("tracks", 16, 5, 22, 12)], props=[("snowyowl", 20, 9), ("snowyowl", 22, 5), ("lamp", 21, 8), ("lantern", 23, 6), ("basket", 18, 10)]),
]
RICH[316] = [
 R(looks=[("snowbank", 17, 0, 23, 6), ] + [("starstone", x, y, x, y) for x, y in ((7, 6), (9, 4), (12, 7), (14, 4), (6, 9), (10, 5))], rough=[("tracks", 17, 6, 23, 8)], props=[("lamp", 19, 8), ("bench", 21, 8), ("snowyowl", 22, 7), ("lantern", 10, 7)]),
 R(rough=[("tracks", 11, 2, 17, 8)], props=[("tent", 12, 4), ("tent", 16, 4), ("campfire", 14, 6), ("bench", 12, 6), ("sled", 16, 7), ("crate", 15, 3), ("bucket", 18, 11), ("lantern", 18, 13), ("lamp", 11, 7)]),
]

def auto(rid, i, land, section):
    """Looks and rough kinds that follow from the stamps the builder used (tools/maplewold_bendy_specs.py) and from ponds in the section's water."""
    from maplewold_bendy_specs import SPECS
    L, Rg = [], []; bb = lambda cx, cy, r: (cx - r, cy - r, cx + r, cy + r); soft = {"grassland": "marsh", "forest": "marsh", "coast": "shells", "tundra": "snowdrift"}[land]
    for op in SPECS[rid][i].get("ops", []):
        k = op[0]
        if k == "fence": L.append(("fence", min(op[1], op[3]), min(op[2], op[4]), max(op[1], op[3]), max(op[2], op[4])))
        elif k == "orchard": L.append(("apple",) + tuple(op[1:5]))
        elif k == "hedgefield":
            x0, y0, x1, y1 = op[1:5]; L += [("hedge", x0, y0, x1, y0), ("hedge", x0, y1, x1, y1), ("hedge", x0, y0, x0, y1), ("hedge", x1, y0, x1, y1)]; Rg.append(("ploughed", x0 + 1, y0 + 1, x1 - 1, y1 - 1))
        elif k in ("pond", "marsh"): L.append(("pond",) + bb(op[1], op[2], op[3])); Rg.append((soft,) + bb(op[1], op[2], op[3] + 1))
        elif k == "drift": Rg.append(({"grassland": "flowers", "forest": "ferns", "coast": "dunegrass", "tundra": "snowdrift"}[land], op[1] - op[3], op[2] - op[4], op[1] + op[3], op[2] + op[4]))
        elif k == "dune": r = (op[1] - op[3], op[2] - op[4], op[1] + op[3], op[2] + op[4]); L.append(("dunetuft",) + r); Rg.append(("dunegrass",) + r)
        elif k == "rockstack": L.append(("boulder",) + bb(op[1], op[2], 1)); Rg.append(("pebbles",) + bb(op[1], op[2], 2))
        elif k == "tidepool": L.append(("pond",) + bb(op[1], op[2], 1)); Rg.append(("shells",) + bb(op[1], op[2], 2))
        elif k == "icelake": L.append(("icehole",) + bb(op[1], op[2], op[3])); Rg.append(("ice",) + bb(op[1], op[2], op[3]))
        elif k == "pines": Rg.append(("snowdrift",) + bb(op[1], op[2], op[3]))
        elif k == "log": L.append(("biglog", op[1], op[2], op[1] + op[3] - 1, op[2])); Rg.append(("leaves", op[1], op[2] - 1, op[1] + op[3] - 1, op[2] + 1))
        elif k == "clearing": Rg.append(("flowers",) + bb(op[1], op[2], op[3]))
    for wv in section.get("water", []):
        if "pond" in wv: L.append(("pond",) + bb(wv["pond"][0], wv["pond"][1], 2)); Rg.append((soft,) + bb(wv["pond"][0], wv["pond"][1], 3))
    return L, Rg

def rich_for(rid, i, route):
    """The full dressing of a section: the hand sketch in RICH on top of the derived looks."""
    r = dict(RICH.get(rid, [{}] * 9)[i])
    if r.get("auto", True):
        L, Rg = auto(rid, i, route["land"], route["sections"][i]); r["looks"] = L + list(r.get("looks", [])); r["rough"] = list(r.get("rough", [])) + Rg
    return r

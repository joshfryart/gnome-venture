-- banner-SE-pets: The Olive Pantry Pets, ochre shopfront in a whitewashed Mediterranean street
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 52, { "#78bce8", "#8ccaee", "#a4d8f2", "#c0e6f4", "#dcf0ee" }, "sky")
B.sun(c, 440, 22, 8, "#fff2a8", "#f2cc66", "#d4eaf0")
B.cloud(c, 80, 16, 44, "#ffffff", "#cde4f0") B.cloud(c, 380, 10, 30, "#ffffff", "#cde4f0")
-- sea strip behind
B.bands(c, 53, 62, { "#3a8ec4", "#4aa2cc", "#66b8d4" }, "sea")
-- street
B.bands(c, 100, 119, { "#d8b888", "#cfae7c", "#c4a270", "#b89868" }, "street")
B.bricks(c, L.rect(0, 101, 479, 119), R2.SAND, 14, 5, 0, 101)
-- left neighbour: whitewash, green shutters, bougainvillea
local nl = L.rect(0, 46, 146, 100)
B.solid(c, nl, R2.STONEW, 2, 2, "wall")
B.speck(c, nl, { R2.STONEW.L, R2.STONEW.b }, 0.04, 2)
local rl = L.poly({ { 0, 46 }, { 150, 46 }, { 146, 38 }, { 0, 38 } })
B.solid(c, rl, R2.CLAY, 1, 1, "roof") B.tiles(c, rl, R2.CLAY, 6, 3, 0, 38)
for _, wx in ipairs({ 18, 96 }) do
  B.solid(c, L.rect(wx, 56, wx + 14, 76), R.GREEN, 1, 1, "shutter")
  B.rectc(c, wx + 3, 58, wx + 11, 74, "#a8d4ea", "glass") B.rectc(c, wx + 3, 58, wx + 11, 59, "#e4f6ff", "glass") B.rectc(c, wx + 7, 58, wx + 7, 74, "#fff4d8", "frame")
  B.solid(c, L.rect(wx - 1, 77, wx + 15, 79), R.WOOD, 1, 1, "sill")
  B.pot(c, wx + 4, 77, R2.CLAY, 7, 4, R2.LEAF, R.PINK) B.pot(c, wx + 11, 77, R2.CLAY, 7, 4, R2.LEAF, R.RED)
end
B.solid(c, B.rr(60, 66, 80, 100, 3), R.WOOD, 1, 1, "door") B.planks(c, B.rr(61, 67, 79, 100, 3), R.WOOD, 4, 62)
B.px(c, { { 76, 84, R.GOLD.l } })
-- bougainvillea mass
local bg = L.ellipse(128, 66, 14, 12):add(L.ellipse(118, 76, 10, 8)):add(L.ellipse(136, 82, 8, 10))
B.solid(c, bg, R.PINK, 2, 2, "bloom") B.speck(c, bg, { R.PINK.L, R2.LEAF.m, R.PINK.D }, 0.18, 6)
-- right neighbour + cypress
local nr = L.rect(336, 44, 480, 100)
B.solid(c, nr, R2.STONEW, 2, 2, "wall") B.speck(c, nr, { R2.STONEW.L, R2.STONEW.b }, 0.04, 3)
local rr = L.poly({ { 332, 46 }, { 480, 46 }, { 480, 36 }, { 340, 36 } })
B.solid(c, rr, R2.CLAY, 1, 1, "roof") B.tiles(c, rr, R2.CLAY, 6, 3, 332, 36)
B.solid(c, L.rect(400, 56, 416, 76), R.WOOD, 1, 1, "shutter") B.rectc(c, 403, 58, 413, 74, "#a8d4ea", "glass") B.rectc(c, 403, 58, 413, 59, "#e4f6ff", "glass")
B.solid(c, L.rect(440, 56, 456, 76), R.WOOD, 1, 1, "shutter") B.rectc(c, 443, 58, 453, 74, "#ffd870", "glass")
B.solid(c, L.rect(350, 70, 370, 100), R2.TEALC, 1, 1, "door")
local cyp = L.ellipse(386, 70, 7, 28)
B.solid(c, cyp, R2.LEAFD, 2, 2, "tree") B.speck(c, cyp, { R2.LEAFD.l, R2.LEAFD.s }, 0.2, 5)
-- SHOP: ochre two-storey
local shop = L.rect(152, 32, 332, 100)
B.solid(c, shop, R2.OCHRE, 2, 3, "wall") B.speck(c, shop, { R2.OCHRE.l, R2.OCHRE.b }, 0.05, 8)
-- terracotta eave + cat-ear ridge
local roof = L.poly({ { 144, 34 }, { 340, 34 }, { 330, 18 }, { 154, 18 } })
B.solid(c, roof, R2.CLAY, 2, 2, "roof") B.tiles(c, roof, R2.CLAY, 7, 4, 144, 18)
B.solid(c, L.poly({ { 222, 18 }, { 222, 6 }, { 236, 18 } }):add(L.poly({ { 262, 18 }, { 262, 6 }, { 248, 18 } })):add(L.rect(222, 14, 262, 18)), R2.CLAY, 1, 1, "roof")
B.px(c, { { 224, 11, "#e8909e" }, { 224, 13, "#e8909e" }, { 260, 11, "#e8909e" }, { 260, 13, "#e8909e" } })
-- upper windows w/ shutters
for _, wx in ipairs({ 170, 224, 296 }) do
  B.solid(c, L.rect(wx, 40, wx + 14, 58), R2.OCHRE, 1, 1, "frame")
  B.rectc(c, wx + 2, 42, wx + 12, 56, "#ffd870", "glass") B.rectc(c, wx + 6, 42, wx + 6, 56, "#fff4d8", "frame")
  B.solid(c, L.rect(wx - 6, 40, wx - 2, 58), R.GREEN, 1, 1, "shutter") B.solid(c, L.rect(wx + 16, 40, wx + 20, 58), R.GREEN, 1, 1, "shutter")
end
B.solid(c, L.rect(222, 59, 240, 62), R.WOOD, 1, 1, "sill")
B.catSit(c, 231, 58, R.CREAM, { stripe = nil }) -- cat at upper window (quirk)
-- awning olive/cream
B.awning(c, 160, 282, 62, 9, R.GREEN, R.CREAM, 8)
-- window with goods
B.solid(c, L.rect(166, 76, 226, 99), R.WOOD, 1, 1, "frame")
B.bands(c, 78, 97, { "#ffd870", "#ffc858", "#f8b848" }, "glass", 168, 224)
B.rectc(c, 168, 88, 224, 89, R.WOOD.m, "shelf") B.rectc(c, 168, 90, 224, 90, R.WOOD.D, "shelf")
B.yarn(c, 176, 85, 3, R2.CORAL, true) B.yarn(c, 186, 85, 3, R2.BLUEC, true) B.fishToy(c, 202, 85, R2.TEALC, 11) B.yarn(c, 218, 85, 3, R.GOLD, true)
B.solid(c, L.rect(176, 92, 188, 98), R2.CLAY, 1, 1, "basket") B.fishToy(c, 204, 95, R.PINK, 9)
B.px(c, { { 168, 78, "#fff4d8" }, { 169, 78, "#fff4d8" } })
-- arched door
local door = L.rect(240, 76, 266, 100):add(L.ellipse(253, 78, 13, 9))
B.solid(c, door, R.WOOD, 1, 1, "door")
local inner = L.rect(243, 78, 263, 100):add(L.ellipse(253, 80, 10, 7))
B.fill(c, inner, "#ffd070", "glow") B.bands(c, 74, 99, { "#ffe08c", "#ffd070", "#f8b848" }, "glow", 243, 263)
inner:each(function(x, y) if not inner:has(x, y) then end end)
B.rectc(c, 243, 98, 263, 99, "#6a4128", "door")
B.fishToy(c, 253, 90, R2.TEALC, 11)
-- hanging gold cat-head sign
B.rectc(c, 292, 66, 292, 70, R.WOOD.D, "bracket") B.rectc(c, 286, 66, 305, 66, R.WOOD.D, "bracket")
B.emblem(c, 296, 80, 9, R.GOLD, R.WOOD)
B.px(c, { { 296, 71, "#5a3a28" }, { 296, 72, "#5a3a28" } })
-- step + cat
B.solid(c, L.rect(236, 100, 270, 104), R2.STONEW, 1, 1, "step")
B.catSit(c, 250, 99, R.CREAM, { stripe = R.ORANGE.m })
B.px(c, { { 246, 91, R.ORANGE.m }, { 247, 91, R.ORANGE.m }, { 254, 90, R.ORANGE.m }, { 255, 90, R.ORANGE.m } })
-- lemon tree pot (right of shop)
B.pot(c, 312, 112, R2.CLAY, 16, 12, nil)
B.solid(c, L.rect(311, 90, 313, 100), R2.TABBY, 1, 1, "trunk")
local lt = L.ellipse(312, 86, 13, 11)
B.solid(c, lt, R2.LEAF, 2, 2, "leaf") B.speck(c, lt, { R2.LEAF.L, R2.LEAF.s }, 0.14, 4)
for _, p in ipairs({ { 305, 84 }, { 314, 80 }, { 318, 88 }, { 308, 92 } }) do B.solid(c, L.ellipse(p[1], p[2], 2, 1.6), R.GOLD, 1, 1, "lemon") end
-- laundry line + olive jar
B.bunting(c, 150, 28, 4, 40, 6, { R.RED, R.CREAM, R2.TEALC, R.GOLD }, 9)
B.solid(c, B.rr(284, 108, 296, 118, 3), R2.CLAY, 1, 1, "jar") B.rectc(c, 287, 108, 293, 108, R.GREEN.m, "olive")
B.px(c, { { 288, 112, R.GREEN.m }, { 291, 114, R.GREEN.m }, { 290, 111, R.GREEN.L } })
B.finish(c, "banner-SE-pets")

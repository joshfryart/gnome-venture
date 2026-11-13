-- banner-CSA-pets: Spice Bazaar Pets, two-storey carved-wood shop in a foothill bazaar
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 74, { "#8cc0ec", "#9ccaf0", "#b0d6f2", "#c8e4f4", "#e0f0f2" }, "sky")
B.sun(c, 440, 22, 9, "#fff4c0", "#f6d880", "#d8ecf4")
B.cloud(c, 90, 20, 46, "#ffffff", "#cfe2f0")
-- snowy peaks
local function peak(x, y, w, h)
  B.part(c, L.poly({ { x - w, y + h }, { x, y }, { x + w, y + h } }), R2.GREYC, 2, 2, "peak")
  B.part(c, L.poly({ { x - w * .38, y + h * .38 }, { x, y }, { x + w * .38, y + h * .38 }, { x + w * .2, y + h * .3 }, { x, y + h * .46 }, { x - w * .2, y + h * .3 } }), R2.WHITE, 1, 1, "snow")
end
peak(40, 36, 50, 46) peak(120, 30, 44, 52) peak(380, 32, 54, 50) peak(450, 40, 40, 42)
B.bands(c, 78, 100, { "#a8c0a0", "#98b490" }, "foot")
-- ground
B.bands(c, 100, 119, { "#d8b888", "#d0ac7c", "#c4a070" }, "street")
B.speck(c, L.rect(0, 100, 479, 119), { "#f0d8a8", "#a8845c" }, 0.06, 3)
-- neighbour stalls (left & right)
local function stall(x0, x1, roofc)
  local w = L.rect(x0, 62, x1, 100)
  B.solid(c, w, R2.STONEW, 1, 1, "wall")
  B.solid(c, L.rect(x0 + 6, 70, x0 + 18, 82), R2.BLUEC, 1, 1, "win") B.rectc(c, x0 + 8, 72, x0 + 16, 80, "#ffd870", "glass")
  local rf = L.poly({ { x0, 62 }, { x1, 62 }, { x1 - 6, 52 }, { x0 + 6, 52 } }) B.solid(c, rf, R2.CLAY, 1, 1, "roof") B.tiles(c, rf, R2.CLAY, 6, 3, x0, 52)
  B.awning(c, x0, x1, 84, 6, roofc, R.CREAM, 6)
  for i = x0 + 6, x1 - 8, 12 do
    local cone = L.poly({ { i, 104 }, { i + 9, 104 }, { i + 4.5, 96 } })
    B.solid(c, cone, ({ R.ORANGE, R.RED, R.GOLD, R.GREEN })[1 + floor(((i - x0) / 12)) % 4], 1, 1, "spice")
  end
end
stall(0, 130, R.RED) stall(352, 480, R.GOLD)
-- SHOP
local lower = L.rect(150, 66, 338, 100)
B.solid(c, lower, R.WOOD, 2, 2, "wall") B.planks(c, lower, R.WOOD, 8, 152)
local upper = L.rect(172, 28, 316, 66)
B.solid(c, upper, R2.OCHRE, 2, 2, "wall") B.planks(c, upper, R2.OCHRE, 8, 174)
-- carved trim
B.rectc(c, 150, 66, 338, 67, R.CREAM.l, "trim") B.rectc(c, 150, 68, 338, 68, R.WOOD.D, "trim")
for x = 152, 336, 6 do B.px(c, { { x, 69, R.GOLD.m }, { x + 1, 69, R.GOLD.m }, { x, 70, R.GOLD.D } }) end
-- red tiled roof w/ cat-ear ridge ends
local roof = L.poly({ { 164, 30 }, { 324, 30 }, { 308, 10 }, { 180, 10 } })
B.solid(c, roof, R2.RED2, 2, 2, "roof") B.tiles(c, roof, R2.RED2, 8, 4, 164, 10)
B.solid(c, L.poly({ { 174, 12 }, { 172, -2 }, { 190, 10 } }), R2.RED2, 1, 1, "ear") B.solid(c, L.poly({ { 314, 12 }, { 316, -2 }, { 298, 10 } }), R2.RED2, 1, 1, "ear")
B.px(c, { { 174, 4, "#e8909e" }, { 174, 6, "#e8909e" }, { 314, 4, "#e8909e" }, { 314, 6, "#e8909e" } })
-- round cat-face window (upper)
B.solid(c, L.ellipse(244, 46, 14, 14), R.GOLD, 1, 1, "frame")
B.bands(c, 34, 58, { "#4a3a7a", "#5a4a8a" }, "glass", 232, 256)
local cf = L.ellipse(244, 48, 10, 8):add(L.poly({ { 236, 44 }, { 235, 35 }, { 242, 40 } })):add(L.poly({ { 252, 44 }, { 253, 35 }, { 246, 40 } }))
B.fill(c, L.ellipse(244, 46, 12, 12):clip(cf), "#ffe08c", "glow")
B.fill(c, cf, "#ffd870", "glow") B.px(c, { { 240, 47, B.INK }, { 248, 47, B.INK }, { 244, 51, "#e8909e" } })
for _, wx in ipairs({ 182, 276 }) do
  B.solid(c, L.rect(wx, 36, wx + 24, 58), R.WOOD, 1, 1, "frame") B.bands(c, 38, 56, { "#ffe08c", "#ffd070" }, "glow", wx + 2, wx + 22)
  B.rectc(c, wx + 12, 38, wx + 12, 56, R.WOOD.m, "bar")
end
B.catLoaf(c, 330, 66, R2.GINGER, { stripe = R2.GINGER.b, flip = true })
-- marigold garlands under the eave
local function garland(x0, x1, y)
  for x = x0, x1 do
    local yy = y + floor(3 * math.sin((x - x0) / (x1 - x0) * math.pi * 4))
    local k = floor((x - x0) / 3) % 2
    local col = k == 0 and R.ORANGE or R.GOLD B.put(c, x, yy, col.m, "bloom") B.put(c, x, yy + 1, col.s, "bloom") B.put(c, x, yy - 1, col.l, "bloom")
  end
end
garland(172, 312, 70)
-- prayer flags across
B.bunting(c, 0, 12, 176, 22, 10, { R2.BLUEC, R.CREAM, R.RED, R.GOLD, R2.LEAF }, 11)
-- ground floor counter with goods
B.solid(c, L.rect(158, 84, 330, 100), R.WOOD, 1, 1, "counter") B.rectc(c, 158, 84, 330, 85, R.WOOD.L, "counter")
B.solid(c, L.rect(158, 74, 330, 83), R2.BLUEC, 1, 1, "back") B.bands(c, 76, 82, { "#ffd070", "#f8b848" }, "glow", 160, 328)
for i, x in ipairs({ 168, 184, 200, 216, 232 }) do B.yarn(c, x, 79, 3, ({ R2.CORAL, R2.TEALC, R.GOLD, R.PINK, R2.BLUEC })[i], true) end
B.fishToy(c, 252, 79, R2.TEALC, 11) B.fishToy(c, 276, 79, R.ORANGE, 11)
-- spice baskets with cones on counter
for i, x in ipairs({ 172, 202, 232 }) do
  B.solid(c, L.rect(x, 88, x + 14, 98), R2.THATCH, 1, 1, "basket") B.solid(c, L.poly({ { x + 1, 88 }, { x + 13, 88 }, { x + 7, 80 } }), ({ R.RED, R.GOLD, R.ORANGE })[i], 1, 1, "spice")
end
-- ginger cat napping on a cushion on the counter
B.solid(c, B.rr(262, 82, 298, 88, 2), R.PINK, 1, 1, "cushion") B.catLoaf(c, 280, 82, R2.GINGER, { stripe = R2.GINGER.b })
B.lantern(c, 306, 70, R.GOLD, { cord = 3, h = 8 })
-- door hint at right
B.solid(c, L.rect(306, 84, 330, 100), R.BROWN, 1, 1, "door") B.rectc(c, 310, 88, 326, 98, "#ffc058", "glow")
-- tabby by step, pot
B.catSit(c, 150, 112, R2.TABBY, { stripe = R2.TABBY.D })
B.pot(c, 344, 114, R2.CLAY, 14, 11, R2.LEAF, R.GOLD)
B.bunting(c, 314, 22, 480, 12, 10, { R.GOLD, R.RED, R2.BLUEC, R.CREAM, R2.LEAF }, 11)
B.finish(c, "banner-CSA-pets")

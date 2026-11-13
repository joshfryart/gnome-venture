-- banner-CB-pets: Driftwood & Whisker, beach shack with cat-head gable (Caribbean)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
-- sky + sea + sand
B.bands(c, 0, 46, { "#86cdf0", "#9ad8f4", "#b0e2f6", "#c8ecf6", "#def4ee" }, "sky")
B.sun(c, 40, 24, 9, "#fff0a0", "#f0c860", "#d8f0f4")
B.cloud(c, 110, 14, 40, "#ffffff", "#cfe6f2") B.cloud(c, 410, 20, 50, "#ffffff", "#cfe6f2") B.cloud(c, 330, 10, 28, "#ffffff", "#cfe6f2")
B.bands(c, 47, 64, { "#4aaed0", "#3a9ec8", "#4ab4d0", "#5cc4d4", "#7ad4d8", "#a4e6dc" }, "sea")
for i = 0, 70 do local x, y = (i * 53) % 480, 48 + (i * 7) % 16 B.px(c, { { x, y, "#d8f8f4" }, { x + 1, y, "#d8f8f4" } }) end
B.bands(c, 65, 119, { "#f2d9a0", "#ecca88", "#e8c27e" }, "sand")
for x = 0, 479 do B.put(c, x, 65 + floor(1.5 + 1.5 * math.sin(x / 9)), "#fff4d0", "foam") end
B.speck(c, L.rect(0, 70, 479, 119), { "#fff0c0", "#d6a868", "#c8965a" }, 0.03, 2)
-- distant pastel houses behind
local function house(x, w, wall, roof)
  local body = L.rect(x, 42, x + w, 64)
  B.solid(c, body, wall, 1, 1, "far")
  local rf = L.poly({ { x - 2, 43 }, { x + w + 2, 43 }, { x + w - 2, 36 }, { x + 2, 36 } })
  B.solid(c, rf, roof, 1, 1, "far")
  B.rectc(c, x + 3, 49, x + 6, 53, "#3a6ea8") B.rectc(c, x + 3, 49, x + 6, 49, "#a8d8f4")
  B.rectc(c, x + w - 8, 54, x + w - 4, 64, "#8a5a34")
end
house(14, 30, R2.TEALC, R.RED) house(56, 26, R.GOLD, R2.TEALC) house(366, 28, R2.CORAL, R2.BLUEC) house(406, 32, R.GOLD, R.RED) house(446, 28, R2.TEALC, R.ORANGE)
-- palms
B.palm(c, 118, 100, 62, -10, R2.LEAF) B.palm(c, 372, 102, 58, 8, R2.LEAF, R2.TABBY)
-- SHOP: coral clapboard
local wall = L.rect(168, 52, 328, 100)
B.solid(c, wall, R2.CORAL, 2, 2, "wall")
B.clap(c, wall, R2.CORAL, 5, 52)
-- roof slab (tin)
local roof = L.poly({ { 160, 52 }, { 336, 52 }, { 326, 36 }, { 170, 36 } })
B.solid(c, roof, R2.RED2, 2, 2, "roof")
roof:each(function(x, y) if (x % 6) == 0 then B.put(c, x, y, R2.RED2.b, "detail") elseif (x % 6) == 1 then B.put(c, x, y, R2.RED2.l, "detail") end end)
-- cat-head gable
local gable = L.ellipse(248, 33, 26, 9):add(L.poly({ { 224, 36 }, { 222, 14 }, { 242, 26 } })):add(L.poly({ { 272, 36 }, { 274, 14 }, { 254, 26 } }))
B.solid(c, gable, R2.RED2, 2, 2, "roof")
B.speck(c, gable, { R2.RED2.l }, 0.04, 4)
B.px(c, { { 224, 20, "#e8909e" }, { 224, 22, "#e8909e" }, { 225, 24, "#e8909e" }, { 272, 20, "#e8909e" }, { 272, 22, "#e8909e" }, { 271, 24, "#e8909e" } })
-- round window with lit cream glass + cat eyes
local rw = L.ellipse(248, 33, 7, 5)
B.solid(c, rw, R.CREAM, 1, 1, "window")
B.px(c, { { 245, 32, B.INK }, { 245, 33, B.INK }, { 251, 32, B.INK }, { 251, 33, B.INK }, { 248, 35, "#e8909e" } })
-- gingerbread eave trim
for x = 164, 332, 4 do B.px(c, { { x, 53, "#fff4d0" }, { x + 1, 53, "#fff4d0" }, { x, 54, "#fff4d0" }, { x + 1, 55, "#ffe8b0" }, { x, 55, "#ffe8b0" } }) end
B.rectc(c, 160, 52, 336, 52, "#fff4d0")
-- window with ginger cat on cushion
local win = L.rect(188, 62, 244, 88)
B.solid(c, L.rect(185, 59, 247, 91), R.CREAM, 1, 1, "frame")
B.fill(c, win, "#ffd870", "glass")
B.bands(c, 62, 88, { "#ffd870", "#ffc858", "#f8b848" }, "glass", 188, 244)
B.rectc(c, 215, 62, 216, 88, R.CREAM.m, "frame")
B.rectc(c, 188, 82, 244, 83, R.WOOD.m, "frame") B.rectc(c, 188, 84, 244, 88, R.WOOD.s, "frame")
B.yarn(c, 197, 80, 3, R.PINK, true) B.yarn(c, 233, 80, 3, R2.TEALC, true)
B.rectc(c, 202, 77, 224, 81, "#e0608c", "cushion") B.rectc(c, 202, 77, 224, 77, "#f080a4", "cushion")
B.catLoaf(c, 213, 77, R2.GINGER, { stripe = R2.GINGER.b })
B.px(c, { { 188, 62, "#fff4d8" }, { 189, 62, "#fff4d8" }, { 190, 63, "#fff4d8" } })
-- shutters turquoise louvre
for _, sx in ipairs({ 173, 250 }) do
  local sh = L.rect(sx, 60, sx + 9, 92)
  B.solid(c, sh, R2.TEALC, 1, 1, "shutter")
  for y = 63, 90, 3 do B.rectc(c, sx + 1, y, sx + 8, y, R2.TEALC.s, "detail") B.rectc(c, sx + 1, y + 1, sx + 8, y + 1, R2.TEALC.L, "detail") end
end
-- striped awning over door side
B.awning(c, 262, 322, 58, 8, R.RED, R.CREAM, 6)
-- door turquoise with cat flap
local door = B.rr(274, 70, 304, 100, 2)
B.solid(c, door, R2.TEALC, 1, 1, "door")
B.planks(c, door, R2.TEALC, 5, 276)
B.rectc(c, 281, 75, 297, 84, "#ffd870", "glass") B.rectc(c, 281, 75, 297, 75, "#fff4d8", "glass")
B.rectc(c, 288, 75, 290, 84, R2.TEALC.m, "frame")

local flap = L.rect(283, 91, 295, 99)
B.solid(c, flap, R.WOOD, 1, 1, "flap")
B.rectc(c, 285, 93, 293, 97, R.WOOD.D, "flap") B.px(c, { { 289, 94, R.GOLD.m }, { 289, 95, R.GOLD.m }, { 288, 96, "#e8909e" }, { 290, 96, "#e8909e" } })
B.put(c, 301, 86, "#ffe68c") B.put(c, 301, 87, "#c47a22")
-- porch step + deck
local deck = L.rect(150, 100, 346, 107)
B.solid(c, deck, R.WOOD, 1, 1, "deck")
B.planks(c, deck, R.WOOD, 18, 151)
for x = 154, 344, 18 do B.rectc(c, x, 102, x + 4, 102, R.WOOD.l, "detail") end
-- fish sign bracket, right
B.rectc(c, 336, 56, 336, 74, R.WOOD.D, "bracket") B.rectc(c, 336, 56, 352, 56, R.WOOD.D, "bracket") B.rectc(c, 337, 57, 351, 57, R.WOOD.m, "bracket")
B.rectc(c, 350, 57, 350, 62, "#5a3a28", "rope")
local fish = L.ellipse(350, 68, 9, 4.5):add(L.poly({ { 357, 68 }, { 364, 62 }, { 364, 74 } }))
B.solid(c, fish, R.WOOD, 1, 1, "sign")
B.px(c, { { 344, 66, B.INK }, { 345, 66, B.INK }, { 346, 70, R.WOOD.D }, { 349, 69, R.WOOD.D }, { 352, 68, R.WOOD.D } })
-- fishing floats net on the left post
B.rectc(c, 158, 64, 158, 100, R.WOOD.D, "post") B.rectc(c, 159, 64, 159, 100, R.WOOD.m, "post")
for i, col in ipairs({ R2.TEALC, R.RED, R.GOLD }) do B.solid(c, L.ellipse(160 + (i % 2) * 5, 74 + i * 6, 3.4, 3.4), col, 1, 1, "float") end
B.px(c, { { 161, 70, "#5a3a28" }, { 161, 71, "#5a3a28" } })
-- string lanterns
B.lantern(c, 176, 56, R.GOLD, { cord = 3, h = 6 }) B.lantern(c, 322, 56, R.GOLD, { cord = 3, h = 6 })
-- front: hibiscus pot + curled cream cat + crab
B.pot(c, 156, 110, R2.TEALC, 14, 10, R2.LEAF, R.RED)
B.catLoaf(c, 262, 117, R.CREAM, { flip = false })
B.px(c, { { 228, 113, "#e07a52" }, { 229, 112, "#e07a52" }, { 230, 113, "#e07a52" }, { 227, 112, "#f08a62" }, { 231, 112, "#f08a62" }, { 229, 113, "#b8353a" } })
B.solid(c, L.ellipse(229, 114, 4, 2.4), R2.CORAL, 1, 1, "crab")
B.px(c, { { 225, 112, "#e07a52" }, { 233, 112, "#e07a52" }, { 227, 117, B.INK }, { 231, 117, B.INK }, { 228, 113, B.INK }, { 230, 113, B.INK } })
B.fill(c, L.rect(60, 112, 66, 112), "#e8d0a0")
B.finish(c, "banner-CB-pets")

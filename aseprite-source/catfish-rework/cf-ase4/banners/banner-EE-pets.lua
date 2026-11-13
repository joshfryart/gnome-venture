-- banner-EE-pets: Birch Hut Pets, carved log izba shop on the golden steppe among birches
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 70, { "#a8d8f0", "#b8e0f4", "#cce8f4", "#e0f0ee", "#f2f4e0" }, "sky")
B.sun(c, 56, 26, 9, "#fffbd0", "#f4e090", "#e8f4f4")
B.cloud(c, 130, 18, 48, "#ffffff", "#d4e6f0") B.cloud(c, 410, 16, 40, "#ffffff", "#d4e6f0")
local function hill(y0, amp, ph, ramp, step)
  for x = 0, 479 do
    local y = floor(y0 + amp * math.sin(x / step + ph) + amp * 0.4 * math.sin(x / (step * 0.4) + ph * 2))
    for yy = y, 119 do B.put(c, x, yy, (yy - y < 2) and ramp[1] or ramp[2], "hills") end
  end
end
hill(66, 4, 1, { "#a8c890", "#98bc84" }, 40)
hill(76, 4, 3, { "#e8d078", "#dcc468" }, 30)
B.bands(c, 92, 119, { "#d8b858", "#cca84c", "#c09c44", "#a8883c" }, "steppe")
B.speck(c, L.rect(0, 80, 479, 119), { "#f4e090", "#b8903c", "#8aa84a" }, 0.07, 3)
for x = 0, 479, 5 do if hsh(x, 7, 2) < 0.5 then B.put(c, x, 94 + floor(hsh(x, 3, 1) * 20), "#6a9a3a", "grass") B.put(c, x, 93 + floor(hsh(x, 3, 1) * 20), "#8ab84a", "grass") end end
-- path
B.part(c, L.poly({ { 216, 119 }, { 330, 119 }, { 300, 100 }, { 246, 100 } }), R2.SAND, 1, 1, "path")
-- birches
local function birch(x, y, h, w)
  local tr = L.rect(x, y - h, x + w, y)
  B.solid(c, tr, R2.WHITE, 1, 1, "trunk")
  for yy = y - h + 3, y - 2, 5 do B.rectc(c, x + (hsh(x, yy, 1) < .5 and 0 or 1), yy, x + 1, yy, "#2b1c26", "bark") end
  local cr = L.ellipse(x + w / 2, y - h - 6, 11, 11):add(L.ellipse(x + w / 2 - 5, y - h - 2, 7, 7)):add(L.ellipse(x + w / 2 + 6, y - h - 1, 7, 7))
  B.solid(c, cr, R2.LEAF, 2, 2, "leaf") B.speck(c, cr, { R2.LEAF.L, R2.LEAF.l, R2.LEAF.s }, 0.18, 7)
end
birch(30, 92, 34, 3) birch(66, 96, 26, 3) birch(110, 90, 36, 3) birch(390, 94, 30, 3) birch(430, 90, 38, 3) birch(462, 96, 28, 3)
-- far hut
local function farhut(x, y) B.solid(c, L.rect(x, y, x + 14, y + 8), R.WOOD, 1, 1, "far") B.solid(c, L.poly({ { x - 2, y }, { x + 16, y }, { x + 7, y - 7 } }), R.RED, 1, 1, "far") end
farhut(138, 84) farhut(372, 82)
-- SHOP log hut
local wall = L.rect(182, 52, 318, 100)
B.solid(c, wall, R.WOOD, 2, 2, "wall")
for y = 54, 98, 5 do B.rectc(c, 183, y, 316, y, R.WOOD.D, "log") B.rectc(c, 183, y + 1, 316, y + 1, R.WOOD.l, "log") for x = 183, 316 do if hsh(x, y, 3) < 0.2 then B.put(c, x, y + 2, R.WOOD.s, "grain") end end end
-- notched log ends at corners
for y = 54, 98, 5 do B.solid(c, L.ellipse(181, y + 2, 3, 2.4), R.WOOD, 1, 1, "log") B.solid(c, L.ellipse(319, y + 2, 3, 2.4), R.WOOD, 1, 1, "log") end
-- red felt gable roof
local roof = L.poly({ { 166, 56 }, { 334, 56 }, { 250, 14 } })
B.solid(c, roof, R.RED, 2, 3, "roof")
B.tiles(c, roof, R.RED, 8, 4, 166, 14)
-- cream carved bargeboards
for i = 0, 86 do
  local x1 = 166 + i * 1.0 local y1 = 56 - i * 0.49
  B.put(c, floor(x1), floor(y1) - 1, "#fff4d0", "bargeboard") B.put(c, floor(x1), floor(y1), "#ffe8b0", "bargeboard")
  B.put(c, floor(334 - i), floor(56 - i * 0.49) - 1, "#fff4d0", "bargeboard") B.put(c, floor(334 - i), floor(56 - i * 0.49), "#ffe8b0", "bargeboard")
  if i % 5 == 2 then B.put(c, floor(x1), floor(y1) + 1, "#fff4d0", "bargeboard") B.put(c, floor(334 - i), floor(56 - i * 0.49) + 1, "#fff4d0", "bargeboard") end
end
-- cat-ear finial at the ridge
B.solid(c, L.ellipse(250, 12, 8, 6):add(L.poly({ { 243, 12 }, { 242, 2 }, { 250, 8 } })):add(L.poly({ { 257, 12 }, { 258, 2 }, { 250, 8 } })), R2.GINGER, 1, 1, "finial")
B.px(c, { { 247, 11, B.INK }, { 253, 11, B.INK }, { 250, 13, "#e8909e" } })
-- gable round window w/ cat-face sign
B.emblem(c, 250, 40, 8, R.CREAM, R.WOOD)
-- lit window with cat on sill, shutters
B.solid(c, L.rect(196, 66, 232, 88), R.CREAM, 1, 1, "frame")
B.bands(c, 68, 86, { "#ffe08c", "#ffd070", "#f8b848" }, "glow", 198, 230)
B.rectc(c, 214, 68, 214, 86, R.CREAM.m, "frame") B.rectc(c, 198, 78, 230, 78, R.CREAM.m, "frame")
B.catLoaf(c, 206, 77, R2.GREYC, { stripe = R2.GREYC.D })
B.solid(c, L.rect(188, 64, 194, 90), R2.BLUEC, 1, 1, "shutter") B.solid(c, L.rect(234, 64, 240, 90), R2.BLUEC, 1, 1, "shutter")
B.px(c, { { 190, 70, R.CREAM.L }, { 191, 70, R.CREAM.L }, { 190, 75, R.CREAM.L }, { 191, 78, R.CREAM.L }, { 236, 70, R.CREAM.L }, { 237, 75, R.CREAM.L } })
B.solid(c, L.rect(194, 88, 234, 91), R.CREAM, 1, 1, "sill")
-- window box w/ tulips
for x = 198, 228, 6 do B.px(c, { { x, 87, R2.LEAF.m }, { x, 86, R.RED.m }, { x + 1, 86, R.RED.l }, { x + 1, 87, R2.LEAF.l } }) end
-- door (half-open warm) with arch trim
B.solid(c, L.rect(262, 62, 292, 100), R.CREAM, 1, 1, "frame")
B.fill(c, L.rect(266, 66, 288, 100), "#6a4128", "door")
B.bands(c, 66, 100, { "#ffd070", "#ffc058", "#f8a838" }, "glow", 270, 288)
B.solid(c, L.poly({ { 266, 66 }, { 270, 66 }, { 270, 100 }, { 266, 100 } }), R.BLUE, 1, 1, "door")
B.px(c, { { 268, 82, R.GOLD.l } })
-- hanging cat-face sign right of door
B.rectc(c, 296, 66, 296, 70, R.WOOD.D, "bracket") B.rectc(c, 296, 66, 308, 66, R.WOOD.D, "bracket")
B.emblem(c, 304, 78, 7, R2.GINGER, R.WOOD)
-- steps + bench with yarn & felt boot
B.solid(c, L.rect(258, 100, 296, 104), R2.SAND, 1, 1, "step")
B.solid(c, L.rect(142, 98, 176, 101), R.WOOD, 1, 1, "bench") B.solid(c, L.rect(146, 101, 148, 108), R.WOOD, 1, 1, "leg") B.solid(c, L.rect(170, 101, 172, 108), R.WOOD, 1, 1, "leg")
B.yarn(c, 150, 94, 3, R2.CORAL, true) B.yarn(c, 158, 95, 3, R2.BLUEC, true)
local boot = L.rect(164, 88, 169, 97):add(L.rect(164, 94, 173, 97))
B.solid(c, boot, R2.GREYC, 1, 1, "boot") B.rectc(c, 164, 88, 169, 89, R.CREAM.m, "cuff")
-- sunflowers
for _, p in ipairs({ { 340, 104, 12 }, { 352, 108, 16 }, { 326, 106, 9 } }) do
  B.rectc(c, p[1], 100 - p[3] + 104 - 100, p[1], p[2], R2.LEAF.m, "stem")
  local top = p[2] - p[3] - 4
  B.rectc(c, p[1], top + 4, p[1], p[2], R2.LEAF.m, "stem")
  B.solid(c, L.ellipse(p[1], top, 5, 5), R.GOLD, 1, 1, "flower") B.solid(c, L.ellipse(p[1], top, 2.4, 2.4), R.BROWN, 1, 1, "flower")
  B.put(c, p[1] - 1, top - 1, "#fff0a0")
end
-- chimney with smoke (stove)
B.solid(c, L.rect(296, 22, 306, 44), R.BROWN, 1, 1, "chimney") B.tiles(c, L.rect(296, 22, 306, 44), R.BROWN, 5, 4, 296, 22)
for i, p in ipairs({ { 302, 16 }, { 305, 10 }, { 301, 5 } }) do B.solid(c, L.ellipse(p[1], p[2], 3, 2.4), R2.WHITE, 1, 1, "smoke") end
B.finish(c, "banner-EE-pets")

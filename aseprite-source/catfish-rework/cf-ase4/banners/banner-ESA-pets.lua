-- banner-ESA-pets: Thornacre Trading Den, round clay trading hut under conical thatch on the savanna
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 70, { "#8cc8ec", "#a0d4f0", "#b8e0f2", "#d4ecf0", "#f0f0d8", "#fce8b0" }, "sky")
B.sun(c, 70, 28, 11, "#fffbd0", "#f8dc88", "#f0f0d0")
B.cloud(c, 150, 18, 50, "#ffffff", "#d4e6f0") B.cloud(c, 420, 22, 36, "#fffaf0", "#e8dcc8")
-- far mountain w/ snow cap
B.part(c, L.poly({ { 340, 70 }, { 392, 24 }, { 450, 70 } }), R2.GREYC, 2, 2, "peak")
B.part(c, L.poly({ { 376, 38 }, { 392, 24 }, { 408, 38 }, { 400, 36 }, { 392, 42 }, { 384, 36 } }), R2.WHITE, 1, 1, "snow")
-- dunes/grass bands
local function hill(y0, amp, ph, ramp, step)
  for x = 0, 479 do
    local y = floor(y0 + amp * math.sin(x / step + ph) + amp * 0.4 * math.sin(x / (step * 0.4) + ph * 2))
    for yy = y, 119 do B.put(c, x, yy, (yy - y < 2) and ramp[1] or ramp[2], "hills") end
  end
end
hill(70, 3, 0, { "#e8d090", "#dcc480" }, 40) hill(82, 4, 2, { "#f0cc6c", "#e6c060" }, 30)
B.bands(c, 96, 119, { "#e8b848", "#dcac40", "#cc9c38", "#bc8c30" }, "ground")
B.speck(c, L.rect(0, 84, 479, 119), { "#fff0a0", "#a8782a", "#c8a040" }, 0.07, 3)
for x = 4, 479, 6 do if hsh(x, 1, 6) < 0.4 then B.put(c, x, 98 + floor(hsh(x, 2, 1) * 20), "#8a6a20", "grass") B.put(c, x, 97 + floor(hsh(x, 2, 1) * 20), "#b89030", "grass") end end
-- tiny giraffe far + acacia small
local function acacia(x, y, s)
  B.solid(c, L.poly({ { x - 1, y }, { x - 1, y - 8 * s }, { x + 6 * s, y - 14 * s }, { x + 5 * s, y - 14 * s }, { x + 1, y - 8 * s }, { x + 2, y } }), R2.TABBY, 1, 1, "trunk")
  local cr = L.ellipse(x + 3, y - 15 * s, 14 * s, 3.4 * s):add(L.ellipse(x - 4 * s, y - 13 * s, 8 * s, 2.4 * s))
  B.solid(c, cr, R2.LEAF, 1, 1, "leaf") B.speck(c, cr, { R2.LEAF.L, R2.LEAF.s }, 0.12, 5)
end
acacia(40, 100, 1.5) acacia(120, 86, 0.8)
-- giraffe silhouette far
B.solid(c, L.rect(98, 74, 112, 81), R.GOLD, 1, 1, "giraffe") B.solid(c, L.poly({ { 108, 76 }, { 111, 62 }, { 114, 62 }, { 112, 76 } }), R.GOLD, 1, 1, "giraffe")
B.solid(c, L.ellipse(114, 61, 3, 2), R.GOLD, 1, 1, "giraffe") B.rectc(c, 99, 81, 99, 86, R.GOLD.s, "leg") B.rectc(c, 111, 81, 111, 86, R.GOLD.s, "leg")
B.px(c, { { 101, 76, R.BROWN.m }, { 105, 78, R.BROWN.m }, { 110, 70, R.BROWN.m }, { 109, 66, R.BROWN.m } })
-- baobab right
local bao = L.poly({ { 410, 108 }, { 418, 64 }, { 424, 40 }, { 448, 40 }, { 456, 64 }, { 466, 108 } })
B.solid(c, bao, R2.SAND, 2, 3, "trunk")
bao:each(function(x, y) if (x + floor(y / 9)) % 7 == 0 and hsh(x, y, 2) < .8 then B.put(c, x, y, R2.SAND.s, "bark") end end)
for _, p in ipairs({ { 418, 30 }, { 436, 22 }, { 456, 32 } }) do
  B.solid(c, L.tube({ { 436, 42 }, { (436 + p[1]) / 2, 36 }, { p[1], p[2] + 4 } }, function() return 2.2 end), R2.SAND, 1, 1, "branch")
  local cr = L.ellipse(p[1], p[2], 11, 5)
  B.solid(c, cr, R2.LEAF, 1, 2, "leaf") B.speck(c, cr, { R2.LEAF.L, R2.LEAF.s }, 0.15, 5)
end
B.solid(c, L.ellipse(430, 76, 3, 2), R.BROWN, 1, 1, "x")
-- SHOP: round clay hut
local wall = L.rect(170, 66, 330, 100):add(L.ellipse(250, 66, 80, 4))
B.solid(c, wall, R2.CLAY, 2, 3, "wall") B.speck(c, wall, { R2.CLAY.l, R2.CLAY.b }, 0.06, 2)
for x = 176, 324, 12 do B.rectc(c, x, 92, x + 5, 92, "#fff0c8", "paint") B.rectc(c, x + 3, 94, x + 8, 94, "#fff0c8", "paint") end
-- conical thatch
local roof = L.poly({ { 150, 70 }, { 350, 70 }, { 272, 22 }, { 228, 22 } })
B.solid(c, roof, R2.THATCH, 2, 3, "roof") B.thatch(c, roof, R2.THATCH)
for x = 154, 348, 3 do B.put(c, x, 70, R2.THATCH.D, "fringe") end
-- woven cat-head finial
B.solid(c, L.ellipse(250, 16, 8, 6):add(L.poly({ { 243, 16 }, { 242, 5 }, { 250, 12 } })):add(L.poly({ { 257, 16 }, { 258, 5 }, { 250, 12 } })), R.BROWN, 1, 1, "finial")
B.px(c, { { 247, 15, "#ffd070" }, { 253, 15, "#ffd070" }, { 250, 17, "#e8909e" }, { 244, 8, "#e8909e" }, { 256, 8, "#e8909e" } })
-- stall counter left under striped awning
B.awning(c, 176, 226, 70, 8, R.RED, R.CREAM, 7)
B.solid(c, L.rect(178, 90, 224, 100), R.WOOD, 1, 1, "counter") B.rectc(c, 178, 90, 224, 90, R.WOOD.L, "counter")
B.bands(c, 82, 89, { "#ffe08c", "#ffd070" }, "glow", 180, 222)
for i, x in ipairs({ 186, 196, 206 }) do B.yarn(c, x, 87, 3, ({ R2.CORAL, R2.TEALC, R.GOLD })[i], true) end
B.fishToy(c, 218, 87, R2.BLUEC, 8)
B.solid(c, L.rect(184, 80, 192, 90):clip(L.rect(0, 0, 0, 0)), R.WOOD, 1, 1, "x")
B.catLoaf(c, 212, 82, R2.GINGER, { stripe = R2.GINGER.b })
-- carved door w/ gold studs
local dr = L.rect(244, 78, 276, 100):add(L.ellipse(260, 80, 16, 8))
B.solid(c, dr, R.WOOD, 1, 1, "door") B.planks(c, dr, R.WOOD, 5, 246)
B.fill(c, L.rect(262, 80, 274, 100), "#ffc058", "glow")
for _, p in ipairs({ { 250, 88 }, { 250, 94 }, { 256, 91 } }) do B.put(c, p[1], p[2], "#ffd257") B.put(c, p[1], p[2] + 1, "#c47a22") end
B.rectc(c, 268, 86, 268, 98, R.BROWN.D, "x")
-- round woven basket sign w/ cat face
B.emblem(c, 296, 86, 11, R2.THATCH, R.BROWN)
B.dashes(c, 86, 286, 306, R2.THATCH.D)
-- clay pots
B.solid(c, B.rr(150, 96, 164, 112, 4), R2.CLAY, 1, 1, "pot") B.rectc(c, 152, 100, 162, 100, "#fff0c8", "paint") B.rectc(c, 152, 106, 162, 106, R2.CLAY.D, "paint")
B.solid(c, B.rr(166, 102, 176, 114, 3), R2.CLAY, 1, 1, "pot") B.rectc(c, 168, 106, 174, 106, "#fff0c8", "paint")
B.solid(c, L.ellipse(336, 112, 8, 4), R2.THATCH, 1, 1, "basket")
-- woven mat + lounging tabby
B.solid(c, L.poly({ { 262, 118 }, { 330, 118 }, { 324, 108 }, { 268, 108 } }), R.ORANGE, 1, 1, "mat")
for x = 268, 326, 8 do B.rectc(c, x, 109, x, 117, R.GOLD.m, "mat") end B.rectc(c, 270, 113, 326, 113, R.RED.m, "mat")
B.catLoaf(c, 298, 108, R2.TABBY, { stripe = R2.TABBY.D })
B.finish(c, "banner-ESA-pets")

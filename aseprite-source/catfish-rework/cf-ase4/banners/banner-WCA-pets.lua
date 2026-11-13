-- banner-WCA-pets: Drum & Den, round mud-brick house with zigzag bands, talking drums and weaver-bird tree
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 70, { "#b8e0c8", "#c8e8c0", "#d8eeb8", "#e8f2b0", "#f4f4b0" }, "sky")
B.sun(c, 70, 34, 10, "#fffbc8", "#f8e688", "#e8f4c0")
local function hill(y0, amp, ph, ramp, step)
  for x = 0, 479 do
    local y = floor(y0 + amp * math.sin(x / step + ph) + amp * 0.4 * math.sin(x / (step * 0.4) + ph * 2))
    for yy = y, 119 do B.put(c, x, yy, (yy - y < 2) and ramp[1] or ramp[2], "hills") end
  end
end
hill(60, 5, 1, { "#8cc078", "#7ab068" }, 36) hill(72, 4, 3, { "#5ea85c", "#4e9852" }, 26)
-- far tree line + huts
for x = 0, 479, 22 do B.solid(c, L.ellipse(x + 8 + (x % 3) * 3, 76, 12, 10), R2.LEAFD, 1, 1, "far") end
local function farhut(x, y) B.solid(c, L.rect(x, y, x + 12, y + 8), R2.CLAY, 1, 1, "far") B.solid(c, L.poly({ { x - 2, y }, { x + 14, y }, { x + 6, y - 8 } }), R2.THATCH, 1, 1, "far") end
farhut(120, 78) farhut(150, 80) farhut(392, 78)
-- ground: green meadow + dusty yard
B.bands(c, 92, 119, { "#4e9852", "#448a4c", "#3a7c46", "#32703e" }, "grass")
B.speck(c, L.rect(0, 92, 479, 119), { "#6ab85a", "#2a6038", "#8ad06a" }, 0.08, 2)
B.part(c, L.ellipse(250, 108, 150, 14), R2.SAND, 1, 1, "yard")
B.speck(c, L.ellipse(250, 108, 150, 14), { "#fff0b8", "#c8a064" }, 0.08, 4)
-- canopy ceiling + hanging vines
for x = 0, 479 do
  local d = 6 + floor(3 * math.sin(x / 7) + 2 * math.sin(x / 3.1 + 1))
  for y = 0, d do B.put(c, x, y, (y >= d - 1) and "#143a2c" or ((hsh(x, y, 1) < 0.3) and "#1f5a3a" or "#235e3a"), "canopy") end
end
for _, x in ipairs({ 24, 60, 130, 330, 400, 440 }) do for y = 7, 16 + (x % 13) do B.put(c, x, y, (y % 5 == 0) and "#6ac060" or "#2f7a48", "vine") end end
-- weaver-bird tree right
B.solid(c, L.poly({ { 414, 100 }, { 418, 56 }, { 430, 56 }, { 436, 100 } }), R2.TABBY, 1, 1, "trunk")
local crown = L.ellipse(424, 44, 38, 16):add(L.ellipse(400, 54, 20, 10)):add(L.ellipse(448, 54, 20, 10))
B.solid(c, crown, R2.LEAF, 2, 2, "leaf") B.speck(c, crown, { R2.LEAF.L, R2.LEAF.l, R2.LEAF.s }, 0.15, 5)
for _, p in ipairs({ { 400, 62 }, { 424, 64 }, { 448, 62 }, { 412, 68 } }) do
  B.rectc(c, p[1], 56, p[1], p[2] - 4, "#5a3a28", "rope")
  B.solid(c, L.ellipse(p[1], p[2], 4, 5), R2.THATCH, 1, 1, "nest") B.rectc(c, p[1] - 1, p[2] + 1, p[1] + 1, p[2] + 2, "#2b1c26", "hole")
end
B.solid(c, L.ellipse(409, 61, 3, 2.4), R.GOLD, 1, 1, "bird") B.px(c, { { 407, 60, "#2b1c26" } })
-- SHOP: round mud-brick body
local body = L.rect(176, 62, 324, 100):add(L.ellipse(250, 100, 74, 4))
B.solid(c, body, R2.CLAY, 2, 2, "wall") B.bricks(c, body, R2.CLAY, 10, 5, 178, 62)
-- painted zigzag bands
local function zig(y, col, base)
  for x = 178, 322 do local t = (x - 178) % 12 local d = t < 6 and t or 12 - t
    B.put(c, x, y + floor(d / 2), col, "paint") B.put(c, x, y + floor(d / 2) + 1, col, "paint") end
end
zig(66, "#fff4d8") zig(92, "#fff4d8")
B.rectc(c, 178, 72, 322, 73, R2.BLUEC.m, "paint") B.rectc(c, 178, 86, 322, 87, R2.BLUEC.m, "paint")
-- conical thatch roof with two cat ears
local roof = L.poly({ { 160, 66 }, { 340, 66 }, { 270, 20 }, { 230, 20 } })
B.solid(c, roof, R2.THATCH, 2, 3, "roof") B.thatch(c, roof, R2.THATCH)
B.solid(c, L.poly({ { 226, 24 }, { 222, 6 }, { 244, 18 } }), R2.THATCH, 1, 2, "ear") B.solid(c, L.poly({ { 274, 24 }, { 278, 6 }, { 256, 18 } }), R2.THATCH, 1, 2, "ear")
B.px(c, { { 225, 12, "#e8909e" }, { 225, 15, "#e8909e" }, { 275, 12, "#e8909e" }, { 275, 15, "#e8909e" } })
B.put(c, 250, 18, R2.THATCH.L)
-- round woven cat sign hanging on the roof edge
B.emblem(c, 250, 48, 8, R2.THATCH, R.WOOD)
B.dashes(c, 62, 162, 338, R2.THATCH.D)
-- warm arched door
local dr = L.rect(232, 76, 268, 100):add(L.ellipse(250, 78, 18, 12))
B.solid(c, dr, R.WOOD, 1, 1, "door")
B.fill(c, L.rect(236, 80, 264, 100), "#ffd070", "glow") B.bands(c, 70, 99, { "#fff0a8", "#ffd870", "#ffc058", "#f8a838" }, "glow", 236, 264)
B.rectc(c, 249, 70, 251, 99, R.WOOD.D, "x")
B.fill(c, L.rect(249, 70, 251, 99), "#ffd070", "glow")
B.catLoaf(c, 250, 100, R2.GINGER, { stripe = R2.GINGER.b })
-- kente bunting
B.bunting(c, 168, 62, 332, 62, 10, { R.RED, R.GOLD, R2.LEAF, R.NAVY or R2.BLUEC }, 9)
-- talking drums by the door (with a cat)
local function drum(x, y, h)
  local d = L.poly({ { x - 6, y - h }, { x + 6, y - h }, { x + 2, y - h / 2 }, { x + 5, y }, { x - 5, y }, { x - 2, y - h / 2 } })
  B.solid(c, d, R.WOOD, 1, 1, "drum")
  B.rectc(c, x - 5, y - h, x + 5, y - h + 1, "#f4e8c8", "skin")
  for yy = y - h + 4, y - 2, 4 do B.rectc(c, x - 2, yy, x + 2, yy, R.RED.m, "cord") end
end
drum(204, 106, 22) drum(218, 108, 18) drum(290, 108, 20)
B.catSit(c, 290, 87, R.CREAM, { s = 0.85, stripe = R2.TABBY.m })
-- calabash bowls stacked
for i = 0, 2 do B.solid(c, L.ellipse(312 + i * 2, 110 - i * 5, 9 - i * 2, 4), R2.THATCH, 1, 1, "bowl") B.rectc(c, 306 + i * 2, 109 - i * 5, 318 - i * 2, 109 - i * 5, R.WOOD.D, "rim") end
B.px(c, { { 312, 98, R.RED.m }, { 313, 98, R.GOLD.m } })
-- woven mat + cat nap, pot
B.solid(c, L.poly({ { 150, 118 }, { 196, 118 }, { 192, 108 }, { 154, 108 } }), R.RED, 1, 1, "mat")
for x = 156, 192, 6 do B.rectc(c, x, 110, x, 117, R.GOLD.m, "mat") end
B.catLoaf(c, 172, 108, R2.GREYC, { stripe = R2.GREYC.D })
B.pot(c, 340, 118, R2.CLAY, 16, 12, R2.LEAF, R.GOLD)
B.finish(c, "banner-WCA-pets")

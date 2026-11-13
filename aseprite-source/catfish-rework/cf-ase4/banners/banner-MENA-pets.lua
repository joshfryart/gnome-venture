-- banner-MENA-pets: Lantern & Lounge, whitewashed shop with gold cat-eared dome in a desert cave city
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 80, { "#b0683e", "#c27a48", "#d48e56", "#e4a464", "#f0bc78", "#f8d08c" }, "sky")
B.sun(c, 420, 40, 12, "#fff0b0", "#f6c868", "#f0c488")
B.cloud(c, 90, 36, 50, "#f8dcb0", "#e4b080") B.cloud(c, 300, 26, 34, "#f8dcb0", "#e4b080")
-- far dune city silhouette
for x = 0, 479 do local y = 70 + floor(4 * math.sin(x / 18) + 3 * math.sin(x / 5)) for yy = y, 100 do B.put(c, x, yy, "#d4a878", "city") end end
for _, p in ipairs({ { 10, 50, 22 }, { 52, 56, 18 }, { 90, 46, 26 }, { 370, 52, 20 }, { 440, 44, 28 }, { 410, 58, 16 }, { 138, 58, 16 } }) do
  B.part(c, L.rect(p[1], p[2], p[1] + p[3], 100), R2.STONEW, 1, 1, "city") B.part(c, L.ellipse(p[1] + p[3] / 2, p[2], p[3] / 2 - 1, 5):clip(L.rect(0, 0, 480, p[2])), R2.STONEW, 1, 1, "city")
  B.rectc(c, p[1] + 4, p[2] + 8, p[1] + 6, p[2] + 14, "#a08a70", "city")
end
-- cave ceiling band
for x = 0, 479 do
  local d = 5 + floor(3 * math.sin(x / 6) + 2 * math.sin(x / 2.3))
  if x % 19 < 5 then d = d + 8 - (x % 19) * 2 end
  for y = 0, d do B.put(c, x, y, (y >= d - 1) and "#3a2018" or ((hsh(x, y, 2) < .25) and "#6a4430" or "#5a3626"), "cave") end
end
-- ground
B.bands(c, 100, 119, { "#d8b888", "#d0ac7c", "#c4a070", "#b89464" }, "ground")
B.speck(c, L.rect(0, 100, 479, 119), { "#f0d8a8", "#a8845c" }, 0.06, 3)
-- palm left
B.palm(c, 44, 104, 46, 6, R2.LEAF)
-- SHOP
local wall = L.rect(164, 50, 316, 100)
B.solid(c, wall, R2.STONEW, 2, 2, "wall") B.speck(c, wall, { R2.STONEW.L, R2.STONEW.b }, 0.05, 2)
-- parapet
B.solid(c, L.rect(160, 44, 320, 52), R2.STONEW, 1, 1, "parapet")
for x = 164, 316, 12 do B.solid(c, L.rect(x, 38, x + 6, 44), R2.STONEW, 1, 1, "crenel") end
-- gold dome w/ cat ears
local dome = L.ellipse(240, 40, 30, 22):clip(L.rect(0, 0, 480, 44))
B.solid(c, dome, R.GOLD, 2, 3, "dome")
dome:each(function(x, y) if (x + y) % 6 == 0 and hsh(x, y, 1) < .6 then B.put(c, x, y, R.GOLD.b, "detail") end end)
B.solid(c, L.poly({ { 214, 30 }, { 212, 10 }, { 232, 22 } }), R.GOLD, 1, 1, "ear") B.solid(c, L.poly({ { 266, 30 }, { 268, 10 }, { 248, 22 } }), R.GOLD, 1, 1, "ear")
B.px(c, { { 214, 16, "#e8909e" }, { 214, 19, "#e8909e" }, { 266, 16, "#e8909e" }, { 266, 19, "#e8909e" } })
B.solid(c, L.rect(238, 6, 242, 14), R.GOLD, 1, 1, "finial") B.put(c, 240, 4, "#fff0a0")
B.solid(c, L.ellipse(240, 34, 4, 4), R2.TEALC, 1, 1, "eye")
-- horseshoe arch door glowing
local dr = L.rect(222, 70, 258, 100):add(L.ellipse(240, 72, 18, 14))
B.solid(c, dr, R2.BLUEC, 2, 2, "door")
local gl = L.rect(228, 72, 252, 100):add(L.ellipse(240, 74, 12, 11))
B.fill(c, gl, "#ffd070", "glow") B.bands(c, 62, 99, { "#fff0a8", "#ffd870", "#ffc058", "#f8a838" }, "glow", 228, 252)
gl:each(function(x, y) if not gl:has(x, y) then end end)
for y = 76, 99, 4 do B.rectc(c, 228, y, 252, y, "#d08838", "glow") end
B.rectc(c, 233, 86, 247, 99, "#c46a30", "rug")
B.px(c, { { 241, 80, "#fff4d8" } })
-- two striped awnings, left and right of door
B.awning(c, 172, 214, 60, 8, R2.BLUEC, R.CREAM, 6) B.awning(c, 266, 308, 60, 8, R2.BLUEC, R.CREAM, 6)
-- windows under awnings
for _, wx in ipairs({ 180, 280 }) do
  B.solid(c, B.rr(wx, 72, wx + 24, 94, 2), R.WOOD, 1, 1, "frame")
  B.bands(c, 74, 92, { "#ffe08c", "#ffd070", "#f8b848" }, "glow", wx + 2, wx + 22)
  B.rectc(c, wx + 12, 74, wx + 12, 92, R.WOOD.m, "bar")
  B.solid(c, L.rect(wx + 4, 86, wx + 9, 92), R2.CLAY, 1, 1, "toy") B.yarn(c, wx + 17, 87, 3, R2.TEALC, true)
end
-- brass lanterns
B.lantern(c, 166, 60, R.GOLD, { cord = 4, h = 9 }) B.lantern(c, 314, 60, R.GOLD, { cord = 4, h = 9 })
B.lantern(c, 218, 56, R.GOLD, { cord = 3, h = 6 }) B.lantern(c, 262, 56, R.GOLD, { cord = 3, h = 6 })
-- hanging cat sign right
B.rectc(c, 322, 54, 322, 62, R.WOOD.D, "bracket") B.rectc(c, 322, 54, 336, 54, R.WOOD.D, "bracket") B.rectc(c, 335, 55, 335, 60, "#5a3a28", "rope")
B.emblem(c, 335, 70, 8, R2.BLUEC, R.GOLD)
-- kilim rug in front
local rug = L.poly({ { 214, 119 }, { 266, 119 }, { 262, 102 }, { 218, 102 } })
B.solid(c, rug, R2.RED2, 1, 1, "rug")
for y = 105, 117, 4 do B.rectc(c, 218 - (y - 102) / 4, y, 262 + (y - 102) / 4, y, R.GOLD.m, "rug") end
for x = 226, 258, 8 do B.solid(c, L.poly({ { x, 109 }, { x + 4, 112 }, { x, 115 }, { x - 4, 112 } }), R2.TEALC, 1, 1, "rug") end
B.dashes(c, 118, 215, 265, R.CREAM.l)
-- cushion + ginger cat napping (left)
B.solid(c, B.rr(150, 106, 188, 114, 3), R2.BLUEC, 1, 1, "cushion") B.dashes(c, 110, 154, 184, R.GOLD.m)
B.catLoaf(c, 170, 106, R2.GINGER, { stripe = R2.GINGER.b })
-- cream cat by pots
B.catSit(c, 292, 112, R.CREAM, { stripe = R2.TABBY.m })
B.pot(c, 318, 118, R2.CLAY, 13, 12, R2.LEAF) B.pot(c, 338, 117, R2.CLAY, 11, 10, R2.LEAF, R.RED)
-- cactus
B.solid(c, L.rect(358, 90, 363, 118), R2.LEAF, 1, 1, "cactus") B.solid(c, L.rect(350, 100, 357, 104), R2.LEAF, 1, 1, "cactus") B.solid(c, L.rect(350, 94, 353, 104), R2.LEAF, 1, 1, "cactus")
B.px(c, { { 360, 88, R.PINK.m }, { 361, 88, R.PINK.l } })
B.finish(c, "banner-MENA-pets")

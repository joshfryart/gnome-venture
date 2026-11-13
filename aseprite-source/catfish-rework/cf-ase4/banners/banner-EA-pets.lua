-- banner-EA-pets: Blossom Lantern Cattery, tiled-roof cattery under paper lanterns, blossom dusk
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 80, { "#e47aa0", "#ea8cac", "#f0a0b8", "#f4b4c4", "#f8c8cc", "#fadcd2" }, "sky")
B.sun(c, 80, 40, 11, "#fff0d0", "#f8d8a8", "#f8d0d0")
B.cloud(c, 160, 22, 44, "#fff0ee", "#f0c4d0") B.cloud(c, 400, 30, 52, "#fff0ee", "#f0c4d0") B.cloud(c, 300, 14, 26, "#fff0ee", "#f0c4d0")
-- far hills
local function hill(y0, amp, ph, ramp, step)
  for x = 0, 479 do
    local y = floor(y0 + amp * math.sin(x / step + ph) + amp * 0.4 * math.sin(x / (step * 0.4) + ph * 2))
    for yy = y, 119 do B.put(c, x, yy, (yy - y < 2) and ramp[1] or ramp[2], "hills") end
  end
end
hill(76, 5, 1, { "#a8c890", "#8cb47e" }, 36) hill(88, 4, 4, { "#78b068", "#68a05c" }, 28)
B.bands(c, 100, 119, { "#d8c098", "#d0b68c", "#c8ac80", "#bea074" }, "path")
for x = 0, 479 do for y = 100, 119 do if hsh(floor(x / 4), floor(y / 3), 5) < 0.12 then B.put(c, x, y, "#e8d4ac", "stone") end end end
-- string lights/lanterns across the top
B.bunting(c, 0, 6, 150, 14, 8, { R.RED, R.GOLD, R.RED }, 12)
B.bunting(c, 330, 14, 478, 6, 8, { R.RED, R.GOLD, R.RED }, 12)
for x = 6, 140, 18 do B.lantern(c, x, 10 + floor(1.5 * math.sin(x / 22)), R.RED, { cord = 2, h = 5 }) end
-- cherry trees
local function sakura(x, y, rx, ry)
  B.solid(c, L.poly({ { x - 3, y }, { x - 1, y - 20 }, { x + 2, y - 20 }, { x + 4, y } }), R2.TABBY, 1, 1, "trunk")
  local m = L.ellipse(x, y - 24, rx, ry):add(L.ellipse(x - rx * .6, y - 18, rx * .6, ry * .6)):add(L.ellipse(x + rx * .6, y - 18, rx * .6, ry * .6))
  B.solid(c, m, R.PINK, 2, 3, "bloom") B.speck(c, m, { R.PINK.L, R.PINK.D, "#ffffff" }, 0.16, 6)
  for i = 0, 8 do B.put(c, x + floor((hsh(i, x, 3) - .5) * 40), y - 6 + floor(hsh(i, x, 4) * 14), R.PINK.l, "petal") end
end
sakura(46, 104, 22, 14) sakura(436, 104, 24, 15) sakura(110, 98, 14, 9)
-- stone lantern right
local function toro(x, y)
  B.solid(c, L.rect(x, y - 8, x + 5, y), R2.STONEW, 1, 1, "toro") B.solid(c, L.rect(x - 2, y - 14, x + 7, y - 9), R2.STONEW, 1, 1, "toro")
  B.rectc(c, x + 1, y - 13, x + 4, y - 11, "#ffd870", "glow") B.solid(c, L.poly({ { x - 4, y - 14 }, { x + 9, y - 14 }, { x + 2, y - 19 } }), R2.STONEW, 1, 1, "toro")
  B.solid(c, L.rect(x - 2, y, x + 7, y + 2), R2.STONEW, 1, 1, "toro")
end
toro(372, 106)
-- SHOP: wood body
local wall = L.rect(170, 62, 318, 100)
B.solid(c, wall, R.RED, 2, 2, "wall")
-- lower roof (skirt) + upper tiled roof, curved eaves
local lower = L.poly({ { 154, 70 }, { 334, 70 }, { 322, 58 }, { 166, 58 } })
B.solid(c, lower, R2.DUSKR, 2, 2, "roof") B.tiles(c, lower, R2.DUSKR, 8, 4, 154, 58)
local upper = L.poly({ { 170, 56 }, { 318, 56 }, { 302, 32 }, { 186, 32 } })
B.solid(c, upper, R2.DUSKR, 2, 2, "roof") B.tiles(c, upper, R2.DUSKR, 8, 4, 170, 32)
-- upturned eaves
B.solid(c, L.poly({ { 150, 70 }, { 160, 70 }, { 154, 62 } }), R2.DUSKR, 1, 1, "roof") B.solid(c, L.poly({ { 338, 70 }, { 328, 70 }, { 334, 62 } }), R2.DUSKR, 1, 1, "roof")
-- ridge with tabby asleep
B.solid(c, L.rect(188, 28, 300, 32), R2.DUSKR, 1, 1, "ridge") B.solid(c, L.poly({ { 184, 32 }, { 192, 32 }, { 186, 24 } }), R.GOLD, 1, 1, "ridge") B.solid(c, L.poly({ { 304, 32 }, { 296, 32 }, { 302, 24 } }), R.GOLD, 1, 1, "ridge")
B.catLoaf(c, 244, 28, R2.TABBY, { stripe = R2.TABBY.D })
-- noren curtain red w/ paw
B.solid(c, L.rect(208, 74, 262, 80), R.RED, 1, 1, "bar")
local noren = L.rect(212, 80, 258, 96)
B.solid(c, noren, R2.RED2, 1, 1, "noren")
for x = 223, 247, 12 do B.rectc(c, x, 82, x, 96, R2.RED2.D, "noren") end
B.fill(c, L.ellipse(235, 90, 4, 3), "#fff4d8", "paw") for _, p in ipairs({ { 230, 85 }, { 233, 83 }, { 237, 83 }, { 240, 85 } }) do B.put(c, p[1], p[2], "#fff4d8") B.put(c, p[1], p[2] + 1, "#fff4d8") end
-- warm lit interior beyond noren
B.fill(c, L.rect(212, 96, 258, 100), "#ffc058", "glow")
-- round window with black cat + window w/ maneki-neko
B.solid(c, L.ellipse(192, 82, 12, 12), R.GOLD, 1, 1, "frame") B.fill(c, L.ellipse(192, 82, 10, 10), "#ffd870", "glow") B.bands(c, 73, 91, { "#fff0a8", "#ffd870", "#f8b848" }, "glow", 183, 201)
L.ellipse(192, 82, 10, 10):each(function(x, y) end)
B.catSit(c, 192, 91, R2.GREYC, { s = 0.9, stripe = R2.GREYC.D })
B.solid(c, L.rect(270, 74, 310, 96), R.GOLD, 1, 1, "frame") B.bands(c, 76, 94, { "#ffe08c", "#ffd070", "#f8b848" }, "glow", 272, 308)
B.rectc(c, 290, 76, 290, 94, R.GOLD.m, "frame")
-- maneki-neko (white cat with raised paw, gold bell)
B.catSit(c, 281, 94, R.CREAM, { stripe = R2.GINGER.m })
B.solid(c, L.rect(285, 78, 287, 84), R.CREAM, 1, 1, "paw") B.px(c, { { 281, 88, R.GOLD.m }, { 281, 89, R.GOLD.l }, { 280, 88, R.RED.m }, { 282, 88, R.RED.m } })
B.yarn(c, 298, 90, 4, R.PINK, true)
-- lanterns at eaves
B.lantern(c, 164, 70, R.RED, { cord = 3, h = 10 }) B.lantern(c, 324, 70, R.RED, { cord = 3, h = 10 })
-- emblem sign above door
B.emblem(c, 235, 66, 6, R.CREAM, R2.DUSKR)
-- steps
B.solid(c, L.rect(166, 100, 322, 104), R2.STONEW, 1, 1, "step")
-- potted bonsai + fish toy
B.pot(c, 150, 112, R2.TEALC, 12, 9, R2.LEAFD)
B.catSit(c, 330, 112, R.CREAM, { s = 0.9, stripe = R2.GINGER.m })
B.finish(c, "banner-EA-pets")

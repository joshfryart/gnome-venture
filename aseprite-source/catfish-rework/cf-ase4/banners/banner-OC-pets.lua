-- banner-OC-pets: Reef & Purr, round fale with cat-face thatch on a lagoon islet at sunset
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 62, { "#f6a8a0", "#f8b8a4", "#f8c8a8", "#fad8b0", "#fce4b8", "#fcecc4" }, "sky")
B.sun(c, 60, 44, 12, "#fff6d0", "#f8d890", "#fad8b4")
B.cloud(c, 150, 18, 50, "#ffe8e0", "#f4b8b0") B.cloud(c, 380, 12, 44, "#ffe8e0", "#f4b8b0") B.cloud(c, 300, 30, 26, "#ffe8e0", "#f4b8b0")
-- lagoon bands
B.bands(c, 63, 119, { "#4ab8c8", "#3aaec8", "#32a2c4", "#2a94bc", "#3aa8c0", "#52bcc8", "#7ad0d0", "#a8e4d4" }, "lagoon")
for i = 0, 120 do local x, y = (i * 61) % 480, 64 + (i * 11) % 54 B.px(c, { { x, y, "#d8f8f0" }, { x + 1, y, "#d8f8f0" }, { x + 2, y, "#d8f8f0" } }) end
-- distant islands
B.part(c, L.ellipse(300, 64, 30, 5):clip(L.rect(0, 0, 480, 64)), R2.LEAFD, 1, 1, "island") B.part(c, L.ellipse(430, 64, 20, 4):clip(L.rect(0, 0, 480, 64)), R2.LEAFD, 1, 1, "island") B.part(c, L.ellipse(150, 64, 24, 4):clip(L.rect(0, 0, 480, 64)), R2.LEAFD, 1, 1, "island")
-- islet sand
local sand = L.ellipse(250, 108, 120, 12):clip(L.rect(0, 80, 480, 119))
B.solid(c, sand, R.CREAM, 1, 2, "sand")
B.speck(c, sand, { "#ffffff", "#d6b890" }, 0.06, 3)
B.dashes(c, 118, 150, 350, "#ffffff")
-- palm left w/ leaning trunk + frangipani garland
B.palm(c, 32, 112, 66, 8, R2.LEAF)
-- fale: posts
for _, x in ipairs({ 188, 226, 274, 312 }) do B.solid(c, L.rect(x, 78, x + 4, 104), R2.TABBY, 1, 1, "post") end
-- floor platform
B.solid(c, L.rect(176, 100, 328, 106), R.WOOD, 1, 1, "floor")
-- interior counter, warm
B.solid(c, L.rect(186, 70, 318, 100), R.BROWN, 1, 1, "interior")
B.bands(c, 72, 98, { "#ffd878", "#ffcc68", "#ffc058", "#f8a848" }, "glow", 188, 316)
B.solid(c, L.rect(190, 90, 314, 100), R.WOOD, 1, 1, "counter") B.rectc(c, 190, 90, 314, 90, R.WOOD.L, "counter")
for i, x in ipairs({ 200, 210, 220 }) do B.yarn(c, x, 87, 3, ({ R2.CORAL, R2.TEALC, R.GOLD })[i], true) end
B.fishToy(c, 240, 87, R2.BLUEC, 10)
B.catLoaf(c, 292, 90, R2.TABBY, { stripe = R2.TABBY.D })
B.rectc(c, 190, 80, 314, 80, R.WOOD.D, "shelf")
for i = 0, 6 do B.solid(c, L.ellipse(198 + i * 16, 77, 3, 3), ({ R.PINK, R.CREAM, R.PINK })[i % 3 + 1], 1, 1, "shell") end
-- domed thatch roof w/ cat ears
local roof = L.ellipse(252, 76, 92, 36):clip(L.rect(0, 0, 480, 76))
roof:add(L.rect(160, 70, 344, 76))
B.solid(c, roof, R2.THATCH, 3, 3, "roof") B.thatch(c, roof, R2.THATCH)
B.solid(c, L.poly({ { 192, 56 }, { 190, 34 }, { 218, 46 } }), R2.THATCH, 1, 2, "ear") B.solid(c, L.poly({ { 312, 56 }, { 314, 34 }, { 286, 46 } }), R2.THATCH, 1, 2, "ear")
B.thatch(c, L.poly({ { 192, 56 }, { 190, 34 }, { 218, 46 } }), R2.THATCH) B.thatch(c, L.poly({ { 312, 56 }, { 314, 34 }, { 286, 46 } }), R2.THATCH)
B.px(c, { { 192, 42, "#e8909e" }, { 192, 45, "#e8909e" }, { 193, 48, "#e8909e" }, { 312, 42, "#e8909e" }, { 312, 45, "#e8909e" }, { 311, 48, "#e8909e" } })
-- brass porthole eyes
for _, ex in ipairs({ 224, 280 }) do
  B.solid(c, L.ellipse(ex, 56, 11, 9), R.GOLD, 1, 1, "porthole")
  B.fill(c, L.ellipse(ex, 56, 8, 6), "#ffe08c", "glow") B.bands(c, 50, 62, { "#fff4b8", "#ffe08c", "#ffcc58" }, "glow", ex - 8, ex + 8)
  B.rectc(c, ex - 1, 50, ex, 62, "#2b1c26", "x") B.put(c, ex - 1, 51, "#ffffff")
  L.ellipse(ex, 56, 11, 9):each(function(x, y) end)
end
-- cowrie nose + whiskers
B.solid(c, L.ellipse(252, 62, 5, 3.4), R.PINK, 1, 1, "nose") B.rectc(c, 249, 62, 255, 62, R.PINK.D, "x")
for _, w in ipairs({ { 238, 62, 226, 64 }, { 238, 66, 226, 68 }, { 266, 62, 278, 64 }, { 266, 66, 278, 68 } }) do L.line({ { w[1], w[2] }, { w[3], w[4] } }):each(function(x, y) B.put(c, x, y, "#fff6dc", "whisker") end) end
-- tapa band under eave
local tapa = L.rect(176, 70, 328, 77)
B.solid(c, tapa, R2.CREAMC, 1, 1, "tapa")
for x = 178, 326, 6 do B.solid(c, L.poly({ { x, 71 }, { x + 3, 71 }, { x + 1.5, 76 } }), R.BROWN, 1, 1, "tapa") end
-- carved pole + fish sign + shell
B.solid(c, L.rect(348, 52, 352, 108), R.BROWN, 1, 1, "pole")
for y = 58, 100, 8 do B.solid(c, L.rect(346, y, 354, y + 3), R2.THATCH, 1, 1, "carving") end
B.solid(c, L.ellipse(350, 48, 5, 5), R.PINK, 1, 1, "shell") B.px(c, { { 349, 46, "#ffffff" } })
B.rectc(c, 354, 62, 362, 62, "#5a3a28", "rope")
B.solid(c, L.ellipse(370, 66, 9, 4.6):add(L.poly({ { 377, 66 }, { 384, 60 }, { 384, 72 } })), R2.TEALC, 1, 1, "sign") B.px(c, { { 364, 64, B.INK }, { 365, 64, B.INK } })
-- outrigger canoe with crab-claw sail + white cat
local hull = L.poly({ { 372, 106 }, { 450, 106 }, { 440, 114 }, { 382, 114 } })
B.solid(c, hull, R.WOOD, 1, 1, "canoe") B.rectc(c, 374, 107, 448, 107, R.WOOD.L, "canoe")
B.solid(c, L.rect(398, 92, 400, 106), R.WOOD, 1, 1, "mast")
B.solid(c, L.poly({ { 400, 92 }, { 428, 78 }, { 432, 96 }, { 400, 106 } }), R.CREAM, 1, 1, "sail")
L.line({ { 402, 96 }, { 428, 84 } }):each(function(x, y) B.put(c, x, y, R.RED.m, "sail") end)
B.solid(c, L.rect(380, 112, 436, 114), R.WOOD, 1, 1, "float")
B.catLoaf(c, 420, 106, R.CREAM, { stripe = R2.GINGER.m })
-- coral heads + turtle shallows
for _, p in ipairs({ { 56, 116 }, { 84, 118 }, { 438, 118 }, { 464, 116 } }) do
  for k = -1, 1 do B.solid(c, L.poly({ { p[1] + k * 5 - 2, p[2] }, { p[1] + k * 5, p[2] - 8 }, { p[1] + k * 5 + 2, p[2] } }), ({ R.PINK, R.ORANGE, R.PINK })[k + 2], 1, 1, "coral") end
end
B.solid(c, L.ellipse(116, 112, 7, 4.6), R2.LEAF, 1, 1, "turtle") B.solid(c, L.ellipse(124, 112, 3, 2.4), R2.LEAF, 1, 1, "turtle") B.px(c, { { 125, 111, B.INK } })
-- garland on the roof edge
for i = 0, 30 do local x = 176 + i * 5 B.solid(c, L.ellipse(x, 79 + floor(2 * math.sin(i * 0.9)), 1.6, 1.6), (i % 2 == 0) and R.PINK or R.CREAM, 1, 1, "bloom") end
B.finish(c, "banner-OC-pets")

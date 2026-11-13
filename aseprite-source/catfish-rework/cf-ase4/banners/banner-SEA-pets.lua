-- banner-SEA-pets: Monsoon Mew Market, stilt-house pet shop on a river boardwalk
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 70, { "#7ec4d8", "#92d0dc", "#aadcdc", "#c6e8d8", "#e4f0cc", "#f6ecb8" }, "sky")
B.sun(c, 60, 36, 10, "#fff4b8", "#f6d070", "#e8f0c8")
B.cloud(c, 160, 20, 46, "#ffffff", "#c8e4e0") B.cloud(c, 410, 26, 44, "#f8f8ee", "#c8e4e0")
-- far green hills
local function hill(y0, amp, ph, ramp, step)
  for x = 0, 479 do
    local y = floor(y0 + amp * math.sin(x / step + ph) + amp * 0.4 * math.sin(x / (step * 0.4) + ph * 2))
    for yy = y, 100 do B.put(c, x, yy, (yy - y < 2) and ramp[1] or ramp[2], "hills") end
  end
end
hill(66, 6, 0, { "#6aa88a", "#5a9a7c" }, 34) hill(76, 4, 3, { "#3f8a58", "#357a4e" }, 24)
-- far stilt hut + umbrellas
B.solid(c, L.rect(398, 62, 420, 72), R.WOOD, 1, 1, "far") B.solid(c, L.poly({ { 394, 62 }, { 424, 62 }, { 416, 52 }, { 402, 52 } }), R2.THATCH, 1, 1, "far") B.rectc(c, 404, 65, 408, 70, "#ffd870", "glass")
for _, x in ipairs({ 396, 404, 412, 420 }) do B.solid(c, L.rect(x, 72, x + 1, 90), R2.TABBY, 1, 1, "stilt") end
-- river
B.bands(c, 100, 119, { "#3a8ea8", "#2e7e9c", "#2a728e", "#266882" }, "river")
for i = 0, 90 do local x, y = (i * 47) % 480, 102 + (i * 5) % 16 B.px(c, { { x, y, "#8cd0d8" }, { x + 1, y, "#8cd0d8" }, { x + 2, y, "#8cd0d8" } }) end
-- boardwalk
local bw = L.rect(0, 92, 479, 100)
B.solid(c, bw, R.WOOD, 1, 1, "boardwalk") B.planks(c, bw, R.WOOD, 16, 2)
for x = 10, 479, 40 do B.solid(c, L.rect(x, 100, x + 3, 118), R2.TABBY, 1, 1, "pile") end
-- palm + banana plant left
B.palm(c, 40, 92, 56, -8, R2.LEAF)
local function banana(x, y)
  for _, a in ipairs({ -2.4, -1.9, -1.2, -0.7 }) do
    local m = L.tube({ { x, y }, { x + math.cos(a) * 12, y - 12 + math.sin(a) * 8 }, { x + math.cos(a) * 22, y + math.sin(a) * 4 } }, function(t) return 4 * math.sin(t * math.pi) ^ 0.6 + .8 end)
    B.solid(c, m, R2.LEAF, 1, 2, "leaf")
  end
  B.solid(c, L.rect(x - 1, y, x + 1, 92), R2.TABBY, 1, 1, "stem")
end
banana(96, 74)
-- SHOP: stilts
for _, x in ipairs({ 166, 214, 262, 310 }) do B.solid(c, L.rect(x, 90, x + 4, 108), R2.TABBY, 1, 1, "stilt") end
-- floor deck
B.solid(c, L.rect(154, 88, 334, 94), R.WOOD, 1, 1, "deck")
-- body
local body = L.rect(164, 52, 324, 88)
B.solid(c, body, R.WOOD, 2, 2, "wall") B.planks(c, body, R.WOOD, 6, 166)
-- front opening (shop counter view)
B.solid(c, L.rect(172, 62, 316, 86), R.BROWN, 1, 1, "frame")
B.bands(c, 64, 84, { "#ffe08c", "#ffd070", "#ffc058", "#f8b040" }, "glow", 174, 314)
-- shelves of rattan balls
B.rectc(c, 174, 72, 314, 72, R.WOOD.m, "shelf") B.rectc(c, 174, 73, 314, 73, R.WOOD.D, "shelf")
for i, x in ipairs({ 180, 190, 200, 212, 224 }) do B.solid(c, L.ellipse(x, 69, 3, 3), R2.THATCH, 1, 1, "toy") B.rectc(c, x - 2, 69, x + 2, 69, R2.THATCH.s, "detail") end
B.fishToy(c, 250, 69, R2.TEALC, 11) B.fishToy(c, 272, 69, R.PINK, 9)
-- batik counter
B.solid(c, L.rect(172, 78, 316, 88), R2.BLUEC, 1, 1, "counter")
for x = 176, 312, 8 do B.solid(c, L.poly({ { x, 83 }, { x + 3, 80 }, { x + 6, 83 }, { x + 3, 86 } }), R.GOLD, 1, 1, "batik") end
B.rectc(c, 172, 77, 316, 77, R.WOOD.L, "counter")
-- ginger cat on counter
B.catSit(c, 196, 77, R2.GINGER, { stripe = R2.GINGER.b })
-- kitten in paddy-hat bed
B.solid(c, L.ellipse(290, 79, 11, 5):clip(L.rect(0, 74, 480, 80)), R2.THATCH, 1, 1, "hat") B.catLoaf(c, 290, 77, R.CREAM, { stripe = R2.GINGER.m })
B.solid(c, L.poly({ { 278, 79 }, { 302, 79 }, { 296, 84 }, { 284, 84 } }), R2.THATCH, 1, 1, "hat")
-- gable roof with thatch + cat ears
local roof = L.poly({ { 150, 56 }, { 338, 56 }, { 290, 20 }, { 198, 20 } })
B.solid(c, roof, R2.THATCH, 2, 3, "roof") B.thatch(c, roof, R2.THATCH)
local gab = L.poly({ { 202, 54 }, { 286, 54 }, { 244, 22 } }):clip(L.rect(0, 0, 480, 54))
B.solid(c, L.poly({ { 198, 20 }, { 196, 6 }, { 214, 18 } }), R2.THATCH, 1, 1, "ear") B.solid(c, L.poly({ { 290, 20 }, { 292, 6 }, { 274, 18 } }), R2.THATCH, 1, 1, "ear")
B.px(c, { { 198, 12, "#e8909e" }, { 198, 14, "#e8909e" }, { 290, 12, "#e8909e" }, { 290, 14, "#e8909e" } })
B.emblem(c, 244, 34, 10, R.GOLD, R.WOOD)
-- scalloped awning teal/cream
B.awning(c, 168, 320, 55, 6, R2.TEALC, R.CREAM, 8)
-- lanterns
for _, x in ipairs({ 176, 208, 280, 312 }) do B.lantern(c, x, 62, R.GOLD, { cord = 3, h = 7 }) end
-- lantern strings across river sides
B.bunting(c, 0, 8, 150, 20, 10, { R.GOLD, R.RED, R2.TEALC }, 10) B.bunting(c, 340, 20, 480, 8, 10, { R.GOLD, R.RED, R2.TEALC }, 10)
-- sampan on river
local boat = L.poly({ { 376, 100 }, { 440, 100 }, { 430, 110 }, { 388, 110 } })
B.solid(c, boat, R.WOOD, 1, 1, "boat") B.solid(c, L.rect(398, 94, 420, 100), R2.THATCH, 1, 1, "canopy")
B.solid(c, L.rect(0, 0, 0, 0), R.WOOD, 1, 1, "x")
B.catLoaf(c, 428, 100, R2.GREYC, { flip = true })
-- crates on boardwalk right + fish drying
B.solid(c, L.rect(340, 80, 356, 92), R.WOOD, 1, 1, "crate") B.planks(c, L.rect(341, 81, 355, 91), R.WOOD, 5, 342) B.fishToy(c, 348, 76, R2.BLUEC, 9)
B.finish(c, "banner-SEA-pets")

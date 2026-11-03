-- ico-money-bag first draft (Sonnet). quirk: one coin has hopped out of the bag and is rolling away
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-money-bag")
local W = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
c:groundShadow(30, 57, 17, 2)
local bag = D.ell(30, 40, 16, 15)
bag:add(c:poly{ {24, 28}, {36, 28}, {40, 22}, {20, 22} })
D.lit(bag, W, 8)
-- gather folds at neck
for _, x in ipairs{ 24, 27, 30, 33, 36 } do D.ln(x, 28, x - 1 + (x > 30 and 2 or 0), 31, W[2]) end
-- top flare
local fl = c:poly{ {22, 22}, {24, 13}, {28, 17}, {32, 12}, {36, 17}, {40, 13}, {42, 22} }
D.lit(fl, W, 3)
D.fill(c:rect(22, 22, 42, 25), W[2])
-- rope tie
D.fill(c:rect(21, 24, 43, 27), D.GOLD[4]) D.fill(c:rect(21, 24, 43, 24), D.GOLD[6]) D.fill(c:rect(21, 27, 43, 27), D.GOLD[2])
for x = 22, 42, 4 do c:px(x, 25, D.GOLD[3]) c:px(x + 1, 26, D.GOLD[5]) end
-- dollar sign
D.fill(c:rect(31, 33, 32, 50), D.GOLD[5])
D.fill(c:rect(26, 35, 36, 37), D.GOLD[5]) D.fill(c:rect(26, 35, 28, 41), D.GOLD[5])
D.fill(c:rect(26, 41, 36, 43), D.GOLD[5]) D.fill(c:rect(34, 41, 36, 47), D.GOLD[5])
D.fill(c:rect(26, 47, 36, 48), D.GOLD[5])
D.fill(c:rect(26, 46, 28, 46), D.GOLD[5])
-- escaping coin
local coin = D.ell(52, 48, 5, 6)
D.lit(coin, D.GOLD, 3)
D.fill(c:rect(51, 45, 52, 51), D.GOLD[2]) c:px(50, 44, CR)
D.ln(46, 43, 44, 41, D.GOLD[4]) D.ln(45, 51, 43, 52, D.GOLD[4])
D.fin()

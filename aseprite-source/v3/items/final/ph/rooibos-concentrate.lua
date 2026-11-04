-- rooibos-concentrate (first draft, Sonnet). A slim glass bottle of deep red-amber rooibos syrup with a cork, a cream
-- label showing a needle sprig, a glass highlight streak and a shine on the liquid.
-- quirk: a thick drop of concentrate has run down from the cork and hangs on the neck.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("rooibos-concentrate")
c:groundShadow(32, 58, 13, 3)
local body = c:rrect(20, 26, 43, 56, 5)
local neck = c:rect(28, 15, 35, 27)
local glass = body:copy():add(neck)
A.lit(c, glass, "#cfeaf0", 2.4, { amb = .15 })
local liq = body:shrink(2):clip(c:rect(0, 32, 63, 63))
A.lit(c, liq, "#c8402a", 3.2, { amb = .1, wrap = .3 })
liq:each(function(x, y) if not liq:has(x, y - 1) then c:px(x, y, "#ff8a5c") end end)
c:px(24, 36, "#ffc4a0") c:px(25, 36, "#ffc4a0")
-- label
local lab = c:rect(24, 40, 39, 52)
c:fillMask(lab, "#fff4d6")
for x = 24, 39 do c:px(x, 52, "#e0c890") c:px(x, 40, "#e0c890") end
A.ln(c, 31, 50, 31, 43, "#3f7a44")
for i = 0, 2 do A.ln(c, 31, 49 - i * 2, 28, 47 - i * 2, "#5c9a52") A.ln(c, 31, 48 - i * 2, 34, 46 - i * 2, "#5c9a52") end
c:px(31, 42, "#c8402a")
-- glass streak
for y = 30, 54 do c:px(22, y, (y % 7 == 0) and "#cfeaf0" or "#f0fbff") end
-- cork + lip
A.lit(c, c:rect(27, 8, 36, 14), "#c9965a", 1.6)
for x = 27, 36 do c:px(x, 14, "#864c33") end
c:px(29, 10, "#e8c890") c:px(33, 11, "#a06a3a")
A.fin_ = nil
-- drip
for y = 15, 20 do c:px(36, y, "#a02e2c") end
A.drop(c, 36, 21, "ember")
A.fin()

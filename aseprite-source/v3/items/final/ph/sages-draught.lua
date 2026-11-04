-- sages-draught (first draft, Sonnet). A round-bellied glass flask of murky sage-green brew with a cork, a
-- little hang-tag on the neck, a pale sage leaf floating inside and a magic sparkle in the liquid.
-- quirk: a furry grey-green sage leaf is stuck to the cork like a feather.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("sages-draught")
c:groundShadow(32, 58, 14, 3)
local body = c:ellipse(31.5, 43, 15, 14.5)
local neck = c:rect(27, 15, 36, 32)
local lip = c:rect(25, 12, 38, 15)
local glass = body:copy():add(neck):add(lip)
A.lit(c, glass, "#cfeaf0", 3, { amb = .15 })
local liq = c:ellipse(31.5, 43, 12.5, 12):clip(c:rect(0, 36, 63, 63))
A.lit(c, liq, "#5e9a78", 5, { amb = .1, wrap = .3 })
liq:each(function(x, y) if not liq:has(x, y - 1) then c:px(x, y, "#a8d8b0") end end)
for x = 28, 36 do c:px(x, 20, "#8ac0a0") end
-- glass streak
for y = 36, 52 do c:px(20 + (y > 46 and 1 or 0), y, "#f0fbff") end
-- floating leaf
A.blade(c, 28, 50, 38, 46, 2.4, "#c4e0b0", { veins = { 3, 6 }, slant = 2 })
c:sparkle(36, 40)
-- cork
A.lit(c, c:rect(27, 6, 36, 12), "#c9965a", 1.6)
for x = 27, 36 do c:px(x, 12, "#864c33") end
-- sage leaf on the cork
A.blade(c, 35, 9, 47, 2, 3.2, "#9ab89a", { veins = { 3, 6, 9 }, slant = 2 })
-- tag
A.ln(c, 37, 16, 41, 19, "#f5b82e")
A.lit(c, c:rect(39, 20, 46, 27), "#fff4d6", 1)
A.ln(c, 41, 23, 44, 23, "#8a6fd0") A.ln(c, 41, 25, 43, 25, "#8a6fd0")
A.fin()

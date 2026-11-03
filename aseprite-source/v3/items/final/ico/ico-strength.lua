local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-strength: a flexed arm, fist up top-left, forearm angled down to an elbow, bulging bicep.
-- quirk: a little red heart tattoo on the bicep and one flying sweat drop.
local c = D.new("ico-strength")
D.cyl(c, 54, 50, 48, 34, function() return 6 end, D.SKIN, { amb = 0.1 })
D.cyl(c, 46, 50, 22, 24, function(t) return 6.2 - t * 1.4 end, D.SKIN, { amb = 0.1 })
D.lit(c, D.ell(42, 38, 10, 10), D.SKIN, 8, { amb = 0.1 })
D.disc(c, 49, 49, 6, D.SKIN)
local fist = c:rrect(10, 8, 28, 26, 4) D.lit(c, fist, D.SKIN, 6, { amb = 0.1 })
for _, x in ipairs{ 14, 18, 22 } do D.ln(c, x, 10, x, 14, D.SKIN[2]) end
D.rect(c, 11, 20, 27, 21, D.SKIN[2]) D.rect(c, 11, 8, 20, 8, D.SKIN[6]) c:px(26, 14, D.SKIN[2])
D.rect(c, 34, 36, 40, 38, D.RED[4]) D.rect(c, 35, 39, 39, 40, D.RED[4]) c:px(37, 41, D.RED[4]) c:px(35, 36, D.RED[6]) c:px(34, 36, D.RED[4])
c:fillMask(c:ellipse(56, 12, 2, 3), D.BLU[4]) c:px(55, 11, D.CREAM) D.rect(c, 56, 14, 57, 14, D.BLU[2])
D.fin()

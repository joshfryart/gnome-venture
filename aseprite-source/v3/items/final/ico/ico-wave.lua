local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-wave: rolling blue ocean wave with a foamy curl and a deep base swell.
-- quirk: a tiny orange fish is caught inside the curl.
local c = D.new("ico-wave")
local out = c:ellipse(31, 34, 24, 24)
local inn = c:ellipse(35, 40, 15, 16)
local cr = out:copy():cut(inn):clip(c:rect(0, 0, 63, 44))
cr:cut(c:rect(0, 0, 8, 63)):add(c:ellipse(12, 34, 6, 6):clip(c:rect(0, 28, 63, 44)))
D.lit(c, cr, D.BLU, 5)
local base = D.mk(5, 42, 58, 56, function(x, y) return y >= 43 + floor(sin(x / 4.5) * 1.6 + .5) end)
D.lit(c, base, D.BLU, 5)
D.mk(0, 0, 63, 63, function(x, y) return cr:has(x, y) and out:has(x + 2, y + 2) == false end):each(function(x, y) c:px(x, y, D.ICE[5]) end)
cr:edge():each(function(x, y) if y < 20 and x > 30 then c:px(x, y, CREAM) end end)
for _, p in ipairs{ {44, 12}, {50, 17}, {53, 24}, {40, 9} } do c:fillMask(c:ellipse(p[1], p[2], 1.5, 1.5), CREAM) end
local f = D.ell(34, 36, 4, 2.5, 0) D.lit(c, f, D.ORG, 2) c:fillMask(c:poly{ {29, 36}, {26, 33}, {26, 39} }, D.ORG[3]) c:px(37, 35, INK)
c:fillMask(c:rect(8, 49, 14, 49), D.ICE[4]) c:fillMask(c:rect(30, 51, 38, 51), D.ICE[4])
D.fin()

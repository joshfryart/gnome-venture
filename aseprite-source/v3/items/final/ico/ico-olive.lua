-- ico-olive first draft (Sonnet). quirk: an olive speared by a toothpick with a tiny flag
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-olive")
c:groundShadow(30, 57, 18, 2)
local ol = D.ell(29, 36, 17, 13, 0.55)
D.lit(ol, D.OLIVE, 8, { amb = .1 })
-- pimento at end
local hole = D.ell(18, 44, 5, 4, 0.5)
D.fill(hole, "#2c3a22")
D.lit(D.ell(18, 44, 3, 3, 0.5), "ember", 2)
c:px(17, 43, "#ffc09a")
-- leaf + stem
c:part(c:line({ {42, 24}, {46, 17} }, 3), "wood", { band = 1 })
D.leaf(46, 17, 58, 10, 4, "moss")
-- toothpick skewer
D.ln(8, 20, 42, 52, "#e8b982") D.ln(9, 20, 43, 52, "#e8b982") D.ln(8, 21, 42, 53, "#b97a4a")
D.ln(14, 24, 30, 40, "#fbe0a6")
D.fill(c:poly{ {4, 14}, {11, 16}, {9, 22}, {3, 20} }, "#f5809f") D.fill(c:poly{ {4, 14}, {8, 15}, {7, 17}, {3, 16} }, "#ffc4d8")
c:px(21, 31, CR)
D.fin()

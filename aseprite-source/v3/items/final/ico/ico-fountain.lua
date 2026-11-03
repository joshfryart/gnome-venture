local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fountain: two-tier stone fountain with a tall water jet.
-- quirk: a tiny yellow rubber duck floats in the lower basin.
local c = D.new("ico-fountain")
local jet1 = D.H.sweep({ {32,27},{31,2},{12,4},{20,27} }, function() return 1.5 end)
local jet2 = D.H.sweep({ {32,27},{33,2},{52,4},{44,27} }, function() return 1.5 end)
D.fill(jet1, "#78b4ea") D.fill(jet2, "#78b4ea")
D.fill(D.H.sweep({ {32,27},{32,10},{32,10},{32,8} }, function() return 1.5 end), "#b6dcf6")
local bowl = c:ellipse(32, 28, 13, 4):add(c:poly{ {19,28},{45,28},{37,34},{27,34} })
D.lit(bowl, D.STONE, 6)
D.fill(c:ellipse(32, 27, 11, 2), "#4a8acc")
local pil = c:rect(28, 33, 36, 48)
D.lit(pil, D.STONE, 5)
local base = c:ellipse(32, 50, 25, 7):add(c:rect(8, 46, 56, 52))
D.lit(base, D.STONE, 8, { amb = 0.08 })
D.fill(c:ellipse(32, 46, 22, 4), "#3a6aa6") D.fill(c:ellipse(32, 46, 19, 3), "#4a8acc")
D.fill(c:rect(24, 45, 28, 45), "#78b4ea") D.fill(c:rect(40, 47, 46, 47), "#78b4ea")
-- redo pillar over water
D.lit(pil, D.STONE, 5)
local duck = D.ell(48, 44, 4, 3, 0)
D.lit(duck, D.YEL, 3) D.lit(D.disc(51, 41, 2), D.YEL, 2) c:px(53, 41, "#e8872e") c:px(51, 40, INK)
D.fin()

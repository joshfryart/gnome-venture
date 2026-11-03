-- ico-otter first draft (Sonnet). quirk: it floats on its back hugging a pebble on its belly
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-otter")
local FUR = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
-- tail
D.lit(c:poly{ {46, 38}, {58, 36}, {60, 42}, {46, 44} }, FUR, 2)
-- body
D.lit(D.ell(34, 38, 18, 9), FUR, 6)
-- head
D.lit(D.ell(14, 35, 9, 8), FUR, 5)
-- muzzle
D.lit(D.ell(12, 40, 6, 4), "skinA", 2, { amb = .15 })
D.fill(c:rect(8, 38, 9, 39), INK) c:px(8, 38, CR)
-- whisker dots
c:px(10, 41, "#7a4036") c:px(14, 41, "#7a4036")
-- ear + closed eye
D.fill(c:rect(17, 28, 19, 29), FUR[2])
D.fill(c:rect(11, 33, 14, 33), INK) 
-- pebble on belly + paws
D.lit(D.ell(32, 33, 5, 4), "stone", 2)
D.lit(D.ell(26, 33, 3, 3), FUR, 1.5) D.lit(D.ell(38, 33, 3, 3), FUR, 1.5)
-- water
local w = c:rect(2, 46, 61, 57)
D.fill(w, "#5fc4c8") D.fill(c:rect(2, 46, 61, 47), "#b6f0e0") D.fill(c:rect(2, 52, 61, 57), "#3a86b0") D.fill(c:rect(2, 57, 61, 57), "#2a4a7a")
for x = 2, 61, 6 do D.fill(c:rect(x, 49, x + 2, 49), "#b6f0e0") D.fill(c:rect(x + 3, 54, x + 5, 54), "#5fc4c8") end
-- body slightly under water: ripple line
for x = 16, 52, 4 do D.fill(c:rect(x, 45, x + 1, 45), "#b6f0e0") end
D.fin()

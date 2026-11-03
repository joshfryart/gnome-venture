-- ico-orange first draft (Sonnet). quirk: a spiral of peel hangs down from the top and a juicy slice sits beside it
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-orange")
c:groundShadow(30, 57, 22, 2)
local fr = D.ell(25, 36, 17, 16)
D.lit(fr, D.ORG, 9, { amb = .1 })
-- dimples
for _, p in ipairs{ {16,40},{20,47},{27,50},{34,44},{12,32},{30,30},{22,28},{34,36},{19,36} } do c:px(p[1], p[2], D.ORG[2]) end
-- peel spiral hanging
local pl = c:line({ {38, 26}, {44, 34}, {40, 42}, {45, 50}, {42, 57} }, 3)
D.lit(pl, D.ORG, 1.5, { amb = .1 })
D.fill(c:rect(37, 26, 40, 27), D.ORG[4])
-- stem + leaf
D.fill(c:rect(24, 18, 26, 20), "#3f9150")
D.leaf(26, 20, 40, 10, 4, "moss")
c:px(32, 14, CR)
-- slice
local sl = D.ell(51, 49, 8, 8)
D.fill(sl, "#ffe8b0")
D.fill(sl:copy():shrink(1), "#ffb860")
for a = 0, 5 do
  local an = a * pi / 3 + 0.3
  D.ln(51, 49, floor(51 + cos(an) * 7 + .5), floor(49 + sin(an) * 7 + .5), "#ffe8b0")
end
D.fill(D.ell(51, 49, 1, 1), "#ffe8b0")
c:px(46, 44, CR)
D.fin()

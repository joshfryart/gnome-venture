local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- basil: a sprig with pairs of glossy ovate leaves up a square stem and a small purple-white flower spike on top. quirk: a tiny ladybird sits on the biggest leaf.
local c = D.new("basil")
D.ln(32, 56, 32, 14, "#5a8a48") D.ln(33, 56, 33, 14, "#3f7a44")
local pr = { {50, 11, 6.5}, {40, 11, 6}, {30, 9.5, 5.2}, {21, 7.5, 4.4} }
for i, p in ipairs(pr) do
  D.ln(32, p[1] + 2, 32 - p[2] + 3, p[1] - 2, "#3f7a44") D.ln(33, p[1] + 2, 33 + p[2] - 3, p[1] - 2, "#3f7a44")
  D.lf(32 - p[2] - 0, p[1] - 3, p[2], p[3] * .62, -0.45, D.LEAF2) D.lf(33 + p[2], p[1] - 3, p[2], p[3] * .62, 0.45, D.LEAF2)
end
for i = 0, 3 do
  D.lit(D.ell(30, 14 - i * 3.2, 1.8, 1.4, 0), D.PURP, 1.2) D.lit(D.ell(35, 14 - i * 3.2 - 1, 1.8, 1.4, 0), D.CRM, 1.2)
end
D.lf(32, 4, 1.6, 2.2, 0, D.PURP)
c:fillMask(D.ell(42, 44, 2.2, 1.8, 0), "#d4403a") c:px(42, 43, "#2b1c26") c:px(43, 45, "#2b1c26") c:px(41, 45, "#2b1c26")
D.fin()

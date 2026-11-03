local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- crop-vegetable: a cucumber lying on the diagonal, striped, warty, with a withered yellow flower at the blossom end.
-- quirk: a curly tendril spirals off the stem end.
local c = D.new("crop-vegetable")
local CUC = { "#1e4a2c", "#2d6a38", "#3f8a42", "#5aa84c", "#82c460", "#b4de88" }
c:groundShadow(32, 56, 20, 2)
local m, T, S = D.cyl(c, 12, 46, 50, 28, function(t) return 7.4 * sqrt(max(0.02, 1 - (2 * t - 1) ^ 8)) + 0.4 end, CUC)
m:each(function(x, y)
  local k = K(x, y) local s = S[k] or 0
  if abs(s - 0.1) < 0.12 or abs(s + 0.5) < 0.1 or abs(s - 0.62) < 0.1 then D.shift(c, x, y, CUC, 1) end
end)
for _, p in ipairs{ {26, 40}, {34, 33}, {41, 38}, {20, 44}, {44, 28}, {30, 44} } do D.shift(c, p[1], p[2], CUC, -2) end
for _, p in ipairs{ {21, 38}, {22, 37}, {23, 36}, {24, 35} } do c:px(p[1], p[2], "#dff0b8") end
c:px(22, 37, CREAM)
-- stem
c:part(c:line({ {49, 28}, {53, 25}, {56, 26} }, 2), "wood", { band = 1 })
-- flower at blossom end
local fl = c:ellipse(9, 49, 2.5, 2.5):add(c:rect(6, 46, 7, 47)):add(c:rect(10, 52, 11, 53)):add(c:rect(6, 52, 7, 53))
D.lit(c, fl, "gold", 2)
c:px(9, 49, "#8f4a1f")
-- tendril
D.spiral(c, 47, 15, 5, 1.7, "#5aa84c", nil, 0.5)
D.polyline(c, { {43, 25}, {44, 22}, {46, 20}, {50, 20} }, "#5aa84c")
D.fin()

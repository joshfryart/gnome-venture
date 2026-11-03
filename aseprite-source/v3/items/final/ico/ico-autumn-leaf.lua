local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-autumn-leaf: bold five-lobed maple leaf in burnt orange fading to red, strong veins, thick stalk.
-- quirk: a round hole munched through one lobe by a caterpillar.
local c = D.new("ico-autumn-leaf")
local R = { "#6e2038", "#b52e3f", "#d9482e", "#ee6c22", "#f9983a", "#ffc874" }
c:part(c:rect(30, 42, 33, 58), "wood", { band = 1 })
local m = c:poly{ {32, 6}, {37, 16}, {42, 12}, {41, 25}, {54, 21}, {49, 32}, {59, 38}, {46, 42}, {47, 49}, {36, 45}, {32, 47},
  {28, 45}, {17, 49}, {18, 42}, {5, 38}, {15, 32}, {10, 21}, {23, 25}, {22, 12}, {27, 16} }
m:cut(c:ellipse(46, 28, 2, 2))
D.lit(c, m, R, 5, { amb = 0.1 })
local V = R[1]
D.polyline(c, { {32, 47}, {32, 10} }, V)
for _, v in ipairs{ { {32, 36}, {12, 36} }, { {32, 36}, {52, 36} }, { {32, 30}, {16, 22} }, { {32, 30}, {50, 23} }, { {32, 20}, {24, 15} }, { {32, 20}, {40, 15} }, { {32, 42}, {22, 45} }, { {32, 42}, {42, 45} } } do
  D.polyline(c, v, V, m)
end
c:px(26, 14, R[6]) c:px(27, 14, R[6]) c:px(26, 15, R[6])
-- dew drop
c:fillMask(c:ellipse(22, 33, 1, 1), "#b6f0e0") 
c:px(21, 32, CREAM)
D.fin()

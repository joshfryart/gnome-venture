local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-arrow-right: a real arrow pointing right: wooden shaft, big sea-blue triangular head, feather fletching.
-- quirk: one fletching feather is cream, the other red, plucked from two different birds.
local c = D.new("ico-arrow-right")
c:part(c:poly{ {6, 28}, {16, 28}, {11, 16}, {2, 16} }, "ember", { band = 1 })
c:part(c:poly{ {6, 36}, {16, 36}, {11, 48}, {2, 48} }, { hi = "#ffffff" and "#fffaf0", base = "#fff4d6", shade = "#d8c8b0", deep = "#9a7a70" }, { band = 1 })
c:part(c:rect(8, 28, 42, 35), "wood", { band = 2 })
c:part(c:poly{ {38, 12}, {60, 32}, {38, 52} }:cut(c:poly{ {38, 12}, {44, 32}, {38, 52} }), "sea", { band = 3 })
c:part(c:poly{ {38, 20}, {50, 32}, {38, 44} }, "sea", { band = 2, inner = false })
c:fillMask(c:rect(42, 29, 46, 29), "#b6f0e0")
for y = 13, 18 do end
c:fillMask(c:rect(12, 31, 36, 31), "#864c33")
c:fillMask(c:rect(10, 29, 12, 29), "#e8b982")
D.move(c, 2, 0)
D.fin()

local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-arrow-left: blue chevron-headed arrow pointing left, slim shaft with a sharp notched head.
-- quirk: a green sprout has grown from the tail end of the shaft.
local c = D.new("ico-arrow-left")
c:part(c:rect(24, 26, 52, 37), "sea", { band = 3 })
c:part(c:poly{ {5, 32}, {30, 8}, {25, 32}, {30, 56} }, "sea", { band = 3 })
c:part(c:poly{ {5, 32}, {30, 8}, {30, 32} }, "sea", { band = 1, noshade = true, nopop = true, inner = false })
c:fillMask(c:rect(30, 28, 50, 28), "#b6f0e0")
c:fillMask(c:rect(8, 32, 26, 32), "#2a4a7a")
D.leaf(c, 52, 29, 61, 17, 4, "moss", { 3 })
D.leaf(c, 52, 33, 61, 44, 4, "moss", { 3 })
D.move(c, -2, 0)
D.fin()

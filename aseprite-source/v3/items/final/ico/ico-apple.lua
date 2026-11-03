local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-apple: bold rounded red apple icon with a big gloss and one big leaf, cut across by a bite.
-- quirk: a cream bite on the right shows the flesh and one dark seed.
local c = D.new("ico-apple")
local RED = { "#6e2038", "#b52e3f", "#e8493b", "#ff6a48", "#ff8a5c", "#ffc09a" }
c:groundShadow(32, 57, 15, 2)
local m = c:ellipse(25, 37, 11, 14):add(c:ellipse(39, 37, 11, 14)):add(c:ellipse(32, 41, 13, 12))
m:cut(c:ellipse(32, 24, 3, 2))
local bite = c:ellipse(50, 38, 5, 5):add(c:ellipse(50, 46, 4, 4)):add(c:ellipse(47, 41, 4, 4))
local body = m:copy():cut(bite)
D.lit(c, body, RED, 7, { amb = 0.05 })
local fl = HP.mask()
body:each(function(x, y) if bite:has(x + 1, y) or bite:has(x - 1, y) or bite:has(x, y + 1) or bite:has(x, y - 1) then fl:set(x, y) end end)
fl:grow(1):clip(body):each(function(x, y) c:px(x, y, "#fff0c0") end)
fl:each(function(x, y) c:px(x, y, "#fff8e4") end)
c:fillMask(c:rect(43, 40, 44, 42), "#6b3a28")
c:part(c:line({ {32, 25}, {33, 18}, {36, 11} }, 3), "wood", { band = 1 })
D.leaf(c, 36, 17, 53, 9, 6, "moss", { 4, 8 })
c:fillMask(c:rect(18, 30, 20, 34), "#ffd8c0") c:px(18, 30, CREAM)
D.fin()

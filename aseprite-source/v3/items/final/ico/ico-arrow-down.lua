local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-arrow-down: bold blue block arrow pointing down, fat stem and wide head with a lit bevel.
-- quirk: two gold rivets are hammered into the stem, and a water drop is about to fall from the tip.
local c = D.new("ico-arrow-down")
local stem = c:rect(24, 6, 39, 36)
c:part(stem, "sea", { band = 3 })
c:part(c:poly{ {9, 33}, {54, 33}, {32, 57} }, "sea", { band = 3, pop = { x = 14, y = 35, horizontal = true } })
c:fillMask(c:rect(26, 8, 27, 30), "#b6f0e0")
c:button(32, 14) c:button(32, 25)
c:px(31, 13, CREAM)
D.fin()

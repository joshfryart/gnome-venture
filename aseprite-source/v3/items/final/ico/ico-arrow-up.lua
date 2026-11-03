local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-arrow-up: bold blue arrow pointing up, wide pointed head, stem wrapped in two gold hazard bands.
-- quirk: a small cream star sparkle twinkles off the tip.
local c = D.new("ico-arrow-up")
c:part(c:rect(23, 28, 40, 57), "sea", { band = 3 })
c:part(c:poly{ {32, 5}, {56, 32}, {8, 32} }, "sea", { band = 3, pop = { x = 24, y = 18, horizontal = true } })
c:fillMask(c:rect(23, 41, 40, 44), "#f5b82e") c:fillMask(c:rect(23, 41, 40, 41), "#ffe38a") c:fillMask(c:rect(23, 44, 40, 44), "#d98322")
c:fillMask(c:rect(23, 50, 40, 53), "#f5b82e") c:fillMask(c:rect(23, 50, 40, 50), "#ffe38a") c:fillMask(c:rect(23, 53, 40, 53), "#d98322")
c:sparkle(49, 8)
D.fin()

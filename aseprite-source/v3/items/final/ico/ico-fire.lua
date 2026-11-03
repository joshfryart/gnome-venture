local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fire: bold three-layer flame, red outside, orange, yellow core.
-- quirk: two floating embers drift off on the right.
local c = D.new("ico-fire")
local out = c:ellipse(30, 42, 15, 15):add(c:poly{ {18,36},{32,5},{43,36} }):add(c:poly{ {14,38},{16,22},{24,34} }):add(c:poly{ {42,30},{50,36},{44,46} })
D.lit(out, D.RED, 9, { amb = 0.05 })
local mid = c:ellipse(30, 46, 10, 11):add(c:poly{ {22,40},{30,18},{38,40} })
D.lit(mid, D.ORG, 7, { amb = 0.05 })
local inn = c:ellipse(30, 50, 6, 7):add(c:poly{ {25,48},{30,32},{35,48} })
D.lit(inn, D.GOLD, 5, { amb = 0.05 })
D.fill(c:ellipse(30, 53, 3, 3), "#fff6c8")
D.lit(D.disc(52, 18, 2), D.ORG, 2) D.lit(D.disc(47, 9, 2), D.GOLD, 2)
D.fin()

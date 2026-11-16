-- Aurora Thread (pl-owl-3), yard sprite 64x64. Bloomcaller, common. A green and purple thread the owl wears like a scarf.
-- quirk: a yarn ball with two trailing tassels, one green and one purple.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-3-yard", 64)

local GRN = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local PUR = { "#3a2360", "#5b3a8c", "#7e58b8", "#a486d8", "#c9b3ea", "#e4d8f4" }

-- tassels first, behind the ball
local t1, n1 = O.tube({ { 28, 46 }, { 25, 52 }, { 22, 56 }, { 19, 60 } }, function(t) return 1.8 end)
O.shadeN(c, t1, n1, GRN, { amb = .3 })
local t2, n2 = O.tube({ { 38, 46 }, { 41, 52 }, { 44, 56 }, { 47, 60 } }, function(t) return 1.8 end)
O.shadeN(c, t2, n2, PUR, { amb = .3 })

local ball = c:ellipse(32, 30, 19, 18)
O.shade(c, ball, PUR, { sphere = { 28, 26, 18 }, amb = .2, wrap = .3, sep = PUR[1] })

-- green wraps across the ball
local function band(y0, y1)
  local m = ball:copy()
  m:cut(c:rect(0, 0, 63, y0 - 1))
  m:cut(c:rect(0, y1 + 1, 63, 63))
  return m
end
O.shade(c, band(20, 22), GRN, { R = 3, amb = .2, sep = GRN[1] })
O.shade(c, band(32, 34), GRN, { R = 3, amb = .2, sep = GRN[1] })
O.shade(c, band(42, 44), GRN, { R = 3, amb = .2, sep = GRN[1] })

-- hook knob: a loop of yarn on top
local loop, nl = O.tube({ { 32, 14 }, { 34, 8 }, { 40, 7 }, { 42, 11 } }, function(t) return 1.4 end)
O.shadeN(c, loop, nl, PUR, { amb = .3 })

c:eyeLocked(24, 25)
c:eyeLocked(36, 25)
O.dots(c, { { 30, 33 }, { 31, 34 }, { 32, 34 }, { 33, 33 } }, P.ink)

O.done(c, "pl-owl-3-yard")

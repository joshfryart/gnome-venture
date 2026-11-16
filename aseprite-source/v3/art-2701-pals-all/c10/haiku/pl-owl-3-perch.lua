-- Aurora Thread (pl-owl-3), perch sprite 36x36. Hand-built at this size.
-- quirk: a yarn ball with two trailing tassels.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-3-perch", 36)

local GRN = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local PUR = { "#3a2360", "#5b3a8c", "#7e58b8", "#a486d8", "#c9b3ea", "#e4d8f4" }

local t1, n1 = O.tube({ { 16, 26 }, { 14, 30 }, { 12, 33 }, { 10, 35 } }, function(t) return 1.2 end)
O.shadeN(c, t1, n1, GRN, { amb = .3 })
local t2, n2 = O.tube({ { 22, 26 }, { 24, 30 }, { 26, 33 }, { 28, 35 } }, function(t) return 1.2 end)
O.shadeN(c, t2, n2, PUR, { amb = .3 })

local ball = c:ellipse(18, 17, 11, 10)
O.shade(c, ball, PUR, { sphere = { 16, 15, 10 }, amb = .2, wrap = .3, sep = PUR[1] })

local function band(y0, y1)
  local m = ball:copy()
  m:cut(c:rect(0, 0, 35, y0 - 1))
  m:cut(c:rect(0, y1 + 1, 35, 35))
  return m
end
O.shade(c, band(8, 9), GRN, { R = 2, amb = .2, sep = GRN[1] })
O.shade(c, band(20, 21), GRN, { R = 2, amb = .2, sep = GRN[1] })

c:eyeSmall(14, 14) c:eyeSmall(20, 14)
O.dots(c, { { 17, 19 }, { 18, 19 } }, P.ink)

O.done(c, "pl-owl-3-perch")

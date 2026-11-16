-- Eye of the Storm (pl-hcr-5), perch sprite 36x36. Opus third pass (c14/opus3), hand-built at this size.
-- opus3: billowing lobed cloud rim, one crest crease per arm, cool bounce on the arms.
-- A small hurricane: storm-cloud ring with three spiral arms, shadowed eye wall, the calm blue eye with
-- 2x3 pill eyes.
-- quirk: a tiny pink flower floating still in the calm.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-hcr-5-perch", 36)
local cos, sin, pi, sqrt, atan = math.cos, math.sin, math.pi, math.sqrt, math.atan

local STRM = { "#2a2846", "#3e4266", "#5a6488", "#8292ac", "#b4c4d4", "#e0e9ee" }
local CALM = { "#3e6aa8", "#5c96d0", "#88c0e6", "#bce0f2", "#e2f4f8" }
local CX, CY = 18, 16

c:groundShadow(18, 32, 9, 1.5)
for k = 0, 2 do
  local a0 = 20 + k * 120
  local function P2(a, r) return CX + r * cos(a * pi / 180), CY + r * sin(a * pi / 180) * .9 end
  local x0, y0 = P2(a0, 7) local x1, y1 = P2(a0 - 30, 11.5) local x2, y2 = P2(a0 - 60, 14.5) local x3, y3 = P2(a0 - 95, 15)
  local m, n, TT = O.tube({ { x0, y0 }, { x1, y1 }, { x2, y2 }, { x3, y3 } }, function(t) return 2.8 * (1 - t) ^ .9 + .4 end)
  local I, T = O.shadeN(c, m, n, STRM, { amb = .3, wrap = .45, rim = true, bounce = "#6a5a8a", bmax = 2, sep = STRM[1] })
  O.tex(c, I, T, STRM, function(x, y, i) local t = TT[K(x, y)] if t and math.abs(t - .45) < .06 then return -2 end end)
end
local ring = c:ellipse(CX, CY, 8.5, 7.5)
for a = 0, 359, 45 do ring:add(c:ellipse(CX + 8.3 * cos((a + 15) * pi / 180), CY + 7.4 * sin((a + 15) * pi / 180), 2, 2)) end
local rI, rT = O.shade(c, ring, STRM, { sphere = { CX - 3, CY - 4, 13 }, amb = .32, wrap = .45, rim = true, bounce = "#6a5a8a", bmax = 2 })
O.tex(c, rI, rT, STRM, function(x, y, i)
  local dx, dy = x - CX, (y - CY) / .9
  local r = sqrt(dx * dx + dy * dy)
  local s = (atan(dy, dx) / (2 * pi) * 3 + r * .12) % 1
  if s < .1 and r > 7 then return -2 end
end)
local hole = c:ellipse(CX, CY + .5, 6.5, 6)
O.flat(c, hole, STRM[2], "wall")
local sky = c:ellipse(CX + .5, CY + 1, 6, 5.5)
O.shade(c, sky, CALM, { sphere = { CX - 2, CY - 2, 9 }, amb = .45, wrap = .55, cuts = { .25, .45, .65, .85 } })
c:eyeSmall(15, 14)
c:eyeSmall(20, 14)
O.dots(c, { { 17, 19 }, { 18, 19 }, { 19, 19 } }, P.ink)
O.dot(c, 14, 18, P.petal.base) O.dot(c, 23, 18, P.petal.base)
O.dots(c, { { 22, 20 }, { 21, 21 }, { 23, 21 } }, "#e0708a") O.dot(c, 22, 21, "#f6d25a")

O.done(c, "pl-hcr-5-perch")

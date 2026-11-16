-- Ash Wreath (pl-cwy-5), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Cool grey wreath of twisted burnt twigs, hollow set high so the lower rim carries the face; two charred
-- twig ends poke out. Face: 2x3 pills, cheeks, small smile.
-- quirk: the unlit matchstick tucked in the top, held up like a candle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-5-perch", 36)

local ASH  = { "#2e2c44", "#48465e", "#68667e", "#8e8ca2", "#b8b6c6", "#dddbe5" }
local CHAR = { "#2c1e28", "#3e2c34", "#584440" }

c:groundShadow(17, 32, 10, 1)
for _, t in ipairs({ { { 6, 13 }, { 4, 11 }, { 3, 10 }, { 2, 9 } }, { { 28, 22 }, { 30, 23 }, { 31, 23 }, { 33, 22 } } }) do
  local m, n = O.tube(t, function(s) return 1 - .3 * s end)
  O.shadeN(c, m, n, { CHAR[1], CHAR[1], CHAR[2], CHAR[2], CHAR[3], CHAR[3] }, { amb = .2 })
end
local ring = c:ellipse(17, 19, 12, 12)
ring:cut(c:ellipse(17, 15, 5.5, 4.5))
local rI, rT = O.shadeN(c, ring, X.pillow(ring, 3), ASH, { amb = .2, wrap = .4, rim = true, bounce = "#5a6a8e", bmax = 2 })
O.tex(c, rI, rT, ASH, function(x, y, i)
  if y >= 22 and y <= 28 and x >= 11 and x <= 23 then return 0 end
  local a = math.atan(y - 18, x - 17)
  local w = (a * 14 / math.pi) % 3
  if w < .9 then return -1 end
end)
O.mark(c, { { 7, 21 } }, "#e8493b")
-- matchstick
O.flat(c, c:rect(24, 4, 24, 9), "#b97a4a") O.mark(c, { { 24, 8 }, { 24, 9 } }, "#864c33")
O.shade(c, c:ellipse(24, 3, 1, 1.2), { "#6e2038", "#9a2a3c", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }, { sphere = { 23.5, 2, 2 }, amb = .3 })

O.dot(c, 11, 26, P.petal.base) O.dot(c, 23, 26, P.petal.base)
O.dots(c, { { 15, 27 }, { 16, 28 }, { 17, 28 }, { 18, 27 } }, P.ink)

O.done(c, "pl-cwy-5-perch", function(c)
  c:eyeSmall(13, 23)
  c:eyeSmall(20, 23)
end)

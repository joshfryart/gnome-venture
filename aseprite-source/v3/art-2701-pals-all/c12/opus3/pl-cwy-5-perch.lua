-- Ash Wreath (pl-cwy-5), perch sprite 36x36. Opus richness pass (c12/opus3), hand-built at this size.
-- Cool grey wreath of twisted burnt twigs, hollow set high so the lower rim carries the face; two charred
-- twig ends poke out. Face: 2x3 pills, cheeks, small smile.
-- quirk: the unlit matchstick tucked in the top, held up like a candle. richness: hue-shifted ash, two twig knots
-- in the silhouette, warm char in the low grooves, the last ember with a warm halo.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-5-perch", 36)

local ASH  = { "#2b2a46", "#45445f", "#65647d", "#8d8aa0", "#b9b4c2", "#e0dad8" }
local CHAR = { "#2c1e28", "#3e2c34", "#584440" }

c:groundShadow(17, 32, 10, 1)
for _, t in ipairs({ { { 6, 13 }, { 4, 11 }, { 3, 10 }, { 2, 9 } }, { { 28, 22 }, { 30, 23 }, { 31, 23 }, { 33, 22 } } }) do
  local m, n = O.tube(t, function(s) return 1 - .3 * s end)
  O.shadeN(c, m, n, { CHAR[1], CHAR[1], CHAR[2], CHAR[2], CHAR[3], CHAR[3] }, { amb = .2 })
end
local ring = c:ellipse(17, 19, 12, 12)
ring:add(c:ellipse(8, 10, 1.6, 1.6)) ring:add(c:ellipse(26, 28, 1.6, 1.6))
ring:cut(c:ellipse(17, 15, 5.5, 4.5))
local rI, rT = O.shadeN(c, ring, X.pillow(ring, 3), ASH, { amb = .2, wrap = .4, rim = true, bounce = "#5a6a8e", bmax = 2 })
O.tex(c, rI, rT, ASH, function(x, y, i)
  if y >= 22 and y <= 28 and x >= 11 and x <= 23 then return 0 end
  local a = math.atan(y - 18, x - 17)
  local w = (a * 14 / math.pi) % 3
  if w < .9 then return y > 23 and 0 or -1 end
end)
for k, i in pairs(rI) do -- warm char deep in the low grooves
  local x, y = k % 1024 - 256, k // 1024 - 256
  if c.own[y * c.w + x] == rT and y > 23 and not (y >= 22 and y <= 28 and x >= 11 and x <= 23)
    and (math.atan(y - 18, x - 17) * 14 / math.pi) % 3 < .9 then c.pix[y * c.w + x] = i <= 3 and "#3a2a36" or "#5a4648" end
end
O.mark(c, { { 6, 21 }, { 7, 22 } }, "#7a4a48") O.mark(c, { { 7, 21 } }, "#ff8a3c")
-- matchstick
O.flat(c, c:rect(24, 4, 24, 9), "#b97a4a") O.mark(c, { { 24, 8 }, { 24, 9 } }, "#864c33")
O.shade(c, c:ellipse(24, 3, 1, 1.2), { "#6e2038", "#9a2a3c", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }, { sphere = { 23.5, 2, 2 }, amb = .3 })

O.dot(c, 11, 26, P.petal.base) O.dot(c, 23, 26, P.petal.base)
O.dots(c, { { 15, 27 }, { 16, 28 }, { 17, 28 }, { 18, 27 } }, P.ink)

O.done(c, "pl-cwy-5-perch", function(c)
  c:eyeSmall(13, 23)
  c:eyeSmall(20, 23)
end)

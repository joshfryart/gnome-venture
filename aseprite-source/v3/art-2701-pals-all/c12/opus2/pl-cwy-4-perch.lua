-- Spine Spark (pl-cwy-4), perch sprite 36x36. Opus second pass (c12/opus2), hand-built at this size.
-- Quenched-steel ball on two stubby feet, four short spikes with temper colours (blue root, violet, gold tip).
-- Face: 2x3 pills, cheeks, a small surprised "o" mouth.
-- quirk: the upper-right spike pops in a little sparkler burst.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-cwy-4-perch", 36)

local STEEL  = { "#262848", "#383e6c", "#525f98", "#7488c2", "#a6bce2", "#dce8f6" }
local VIOLET = { "#2e1f48", "#4a2d6a", "#6e4290", "#9566b4", "#bb92d2", "#dcc4ea" }
local STRAW  = { "#6a4022", "#a0682a", "#d39a32", "#f2c248", "#ffe07a", "#fff3b8" }

c:groundShadow(17, 32, 9, 1)
for _, f in ipairs({ { 13, 29 }, { 20, 29 } }) do
  O.shade(c, c:ellipse(f[1], f[2], 2.5, 1.5), STEEL, { sphere = { f[1] - 1, f[2] - 1, 3 }, amb = .2, wrap = .3 })
end
for _, s in ipairs({
  { { 12, 15 }, { 10, 12 }, { 9, 10 }, { 7, 7 } },
  { { 22, 14 }, { 24, 11 }, { 25, 9 }, { 27, 6 } },
  { { 8, 21 }, { 6, 21 }, { 4, 21 }, { 2, 19 } },
  { { 26, 21 }, { 28, 21 }, { 30, 21 }, { 32, 19 } },
}) do
  local m, n, T = O.tube(s, function(t) return 2.2 * (1 - t) + .3 end)
  local I, Tk = O.shadeN(c, m, n, STEEL, { amb = .25, wrap = .35 })
  for k, i in pairs(I) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local t = T[k] or 0
    local R = t < .35 and STEEL or t < .62 and VIOLET or STRAW
    if c.own[y * c.w + x] == Tk then c.pix[y * c.w + x] = R[i]:lower() end
  end
end
local body = c:ellipse(17, 20, 9.5, 9)
O.shade(c, body, STEEL, { sphere = { 13, 16, 13 }, amb = .2, wrap = .4, rim = true, bounce = "#6a5aa0", bmax = 2, sep = STEEL[2] })
O.mark(c, { { 11, 15 }, { 12, 14 }, { 13, 14 } }, STEEL[6])
O.mark(c, { { 22, 26 } }, STEEL[2]) O.mark(c, { { 23, 27 } }, STEEL[4])

O.dot(c, 10, 22, P.petal.base) O.dot(c, 24, 22, P.petal.base)
O.dots(c, { { 16, 23 }, { 17, 23 }, { 15, 24 }, { 18, 24 }, { 16, 25 }, { 17, 25 } }, P.ink)
O.dots(c, { { 16, 24 }, { 17, 24 } }, "#a8384a")

O.done(c, "pl-cwy-4-perch", function(c)
  c:eyeSmall(13, 18)
  c:eyeSmall(20, 18)
  local tx, ty = 27, 5
  for _, d in ipairs({ { 1, 0 }, { 0, -1 }, { 1, -1 }, { -1, -1 }, { 1, 1 } }) do
    c:put(tx + d[1] * 2, ty + d[2] * 2, P.gold.base)
    c:put(tx + d[1] * 3, ty + d[2] * 3, P.cream)
  end
  c:put(tx - 3, ty, P.gold.base)
  c:put(7, 4, STRAW[5]) c:put(33, 17, STRAW[5])
end)

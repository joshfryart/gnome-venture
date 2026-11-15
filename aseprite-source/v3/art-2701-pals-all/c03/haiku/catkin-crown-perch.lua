-- Catkin Crown (bb-catkin-crown), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: a gold pollen sneeze sprays out to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("catkin-crown-perch", 36)
local MOSS = { "#24544a", "#3f9150", "#7cc35a", "#a8d870", "#c4e07a", "#e6f5b8" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local CAT = { "#6b4a1c", "#a87a2c", "#e0a83a", "#ffd760" }
c:groundShadow(17, 33, 9, 2)
O.flat(c, c:rect(11, 29, 13, 31), MOSS[2], "foot")
O.flat(c, c:rect(21, 29, 23, 31), MOSS[2], "foot")
local body = c:ellipse(17, 22, 9, 8)
O.shade(c, body, MOSS, { sphere = { 14, 18, 9 }, amb = .2, wrap = .35, sep = MOSS[1], rim = true })
for _, x in ipairs({ 11, 17, 23 }) do
  local top = (x == 17) and 3 or 6
  local m, n = O.tube({ { x, 14 }, { x, 11 }, { x, top + 2 }, { x, top } }, function(t) return 1.5 - 0.6 * t end)
  O.shadeN(c, m, n, CAT, { amb = .25, wrap = .3, sep = CAT[1] })
end
O.shade(c, c:rrect(8, 13, 26, 15, 1), GOLD, { R = 1, sep = GOLD[1] })
O.dots(c, { { 29, 19 }, { 31, 17 }, { 30, 21 }, { 32, 20 } }, GOLD[3])
c:eyeSmall(12, 20)
c:eyeSmall(20, 20)
O.dots(c, { { 15, 25 }, { 16, 26 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)
O.done(c, "catkin-crown-perch")

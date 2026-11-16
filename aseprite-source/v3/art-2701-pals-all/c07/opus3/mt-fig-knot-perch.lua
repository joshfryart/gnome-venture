-- Fig Knot (mt-fig-knot), perch sprite 36x36, hand-built at this size (opus3 richness pass, from opus2).
-- opus3: knobbly root-knot head (lumps on the silhouette, two root coils framing the face, bark fissures), aerial
-- roots dangling, moss and a lichen dot on the stone, fig speckle.
-- Pale-bark root-knot head with two lobed fig leaves and a dusk fig, two 2 px roots wrapping a seamed temple
-- stone and crossing in front, root feet on the ground. Pill eyes on the knot.
-- quirk: the red-sealed secret scroll pinned where the roots cross.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mt-fig-knot-perch", 36)

local BARK = { "#3e2a2a", "#5e4036", "#82604a", "#a8846a", "#c8a888", "#e2c8a8" }
local STN  = { "#3a3e48", "#565c64", "#7a7e80", "#9c9e98", "#bcbcb0", "#dcdac8" }
local LEAF = { "#1f4a3a", "#2f6a40", "#4a8c44", "#6aac4e", "#94cc62", "#c0e488" }
local FIG  = { "#2a1e44", "#45306e", "#6a4a9e", "#8a6fd0", "#b49ae6", "#dccaf6" }

c:groundShadow(18, 33, 12, 1.3)
local stone = c:rect(9, 19, 26, 31)
local sb = {} stone:each(function(x, y) if y == 25 or (y < 25 and x == 17) then sb[K(x, y)] = -2 end end)
O.shade(c, stone, STN, { R = 2, amb = .3, wrap = .45, bias = sb, sep = STN[1], rim = true })
O.dots(c, { { 9, 19 }, { 10, 19 }, { 26, 19 }, { 9, 20 }, { 25, 19 } }, "#7cc35a") O.dots(c, { { 12, 23 }, { 23, 29 } }, "#c8c87a")
O.dots(c, { { 27, 12 }, { 28, 13 } }, BARK[2])
O.shade(c, c:ellipse(28.5, 16, 2.2, 2.5), FIG, { sphere = { 27, 14, 4 }, amb = .3, sep = FIG[1], rim = true })
O.dot(c, 29, 17, FIG[5])
local FL = { { 0, 0 }, { -2, -1 }, { -4, -2 }, { -3, -3 }, { -1, -3 }, { -2, -5 }, { 0, -6 }, { 2, -5 }, { 1, -3 }, { 3, -3 }, { 4, -2 }, { 2, -1 } }
for _, L in ipairs({ { 14, 7, -1 }, { 21, 7, 1 } }) do
  local a = L[3] * .55 local ca, sa = math.cos(a), math.sin(a)
  local pts = {} for _, p in ipairs(FL) do pts[#pts+1] = { L[1] + p[1] * ca - p[2] * sa, L[2] + p[1] * sa + p[2] * ca } end
  O.shade(c, c:poly(pts), LEAF, { R = 1, amb = .32, sep = LEAF[1] })
end
local head = c:ellipse(17.5, 12, 7.5, 6.5)
head:add(c:ellipse(10.5, 9.5, 2, 2)) head:add(c:ellipse(24.5, 9.5, 2, 2)) head:add(c:ellipse(13, 17.5, 2.5, 1.5)) head:add(c:ellipse(22, 17.5, 2.5, 1.5))
local hI, hT = O.shade(c, head, BARK, { sphere = { 15, 9, 11 }, amb = .3, wrap = .45, sep = BARK[1], rim = true, bounce = "#6a6a9a", bmax = 2 })
O.tex(c, hI, hT, BARK, function(x, y, i) if (x < 12 or x > 23) and O.H(x, y // 2, 17) > .7 and i >= 2 then return -1 end end)
for _, a in ipairs({ { 10, 12, 9, 20 }, { 25, 12, 26, 19 } }) do
  for y = a[2], a[4] do O.dot(c, math.floor(a[1] + (a[3] - a[1]) * (y - a[2]) / (a[4] - a[2]) + .5), y, BARK[3]) end
  O.dot(c, a[3], a[4], BARK[6])
end
for _, p in ipairs({ { { 14, 6 }, { 9, 8 }, { 9, 15 }, { 14, 18 } }, { { 21, 6 }, { 26, 8 }, { 26, 15 }, { 21, 18 } } }) do
  local m, n = O.tube(p, function(t) return 1.1 end)
  O.shadeN(c, m, n, BARK, { amb = .3, wrap = .45, sep = BARK[1], rim = true })
end
local function root(p, w)
  local m, n = O.tube(p, w)
  O.shadeN(c, m, n, BARK, { amb = .3, wrap = .45, sep = BARK[1], rim = true })
end
root({ { 11, 15 }, { 6, 21 }, { 12, 29 }, { 25, 30 } }, function(t) return 1.5 - t * .3 end)
root({ { 24, 15 }, { 29, 22 }, { 22, 26 }, { 11, 23 } }, function(t) return 1.5 - t * .4 end)
root({ { 10, 29 }, { 8, 31 }, { 6, 32 }, { 4, 33 } }, function(t) return 1.2 - t * .6 end)
root({ { 25, 30 }, { 27, 32 }, { 29, 33 }, { 31, 33 } }, function(t) return 1.2 - t * .6 end)
c:eyeSmall(14, 10)
c:eyeSmall(20, 10)
O.dot(c, 12, 14, "#f5809f") O.dot(c, 23, 14, "#f5809f")
O.dots(c, { { 16, 15 }, { 17, 16 }, { 18, 16 }, { 19, 15 } }, "#3e1620")
O.flat(c, c:rect(15, 27, 20, 28), "#e8d4a8", "scroll") O.dots(c, { { 15, 27 }, { 15, 28 }, { 20, 27 }, { 20, 28 } }, "#c8a878")
O.flat(c, c:rect(17, 27, 18, 28), "#b52e3f", "seal")
O.done(c, "mt-fig-knot-perch")

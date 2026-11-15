-- Catkin Crown (bb-catkin-crown), yard sprite 64x64. Haiku pass, c03.
-- Rootwarden, uncommon. Round moss blob wearing a gold band with four fuzzy catkins standing up from it.
-- quirk: a gold pollen sneeze sprays out of the right side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("catkin-crown-yard", 64)

local MOSS  = { "#24544a", "#3f9150", "#7cc35a", "#a8d870", "#c4e07a", "#e6f5b8" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local CAT   = { "#6b4a1c", "#a87a2c", "#e0a83a", "#ffd760", "#fff0a0" }

c:groundShadow(32, 58, 17, 3)

-- stubby feet
O.flat(c, c:rect(21, 53, 26, 56), MOSS[2], "foot")
O.flat(c, c:rect(38, 53, 43, 56), MOSS[2], "foot")

-- body
local body = c:ellipse(32, 40, 16, 13)
O.shade(c, body, MOSS, { sphere = { 27, 34, 15 }, amb = .2, wrap = .35, sep = MOSS[1], rim = true, bounce = "#24544a", bmax = 2 })

-- four catkins standing up from the crown band
local heights = { { 19, 14 }, { 27, 9 }, { 37, 9 }, { 45, 14 } }
for _, h in ipairs(heights) do
  local x, top = h[1], h[2]
  local m, n = O.tube({ { x, 27 }, { x, 23 }, { x, top + 4 }, { x, top } }, function(t) return 2.2 - 0.9 * t end)
  O.shadeN(c, m, n, CAT, { amb = .25, wrap = .3, sep = CAT[1] })
  -- catkin scale flecks
  O.dots(c, { { x - 1, top + 6 }, { x + 1, top + 8 } }, CAT[5])
end

-- gold crown band across the top of the head
local band = c:rrect(18, 25, 46, 28, 1)
O.shade(c, band, GOLD, { R = 1, sep = GOLD[1] })

-- quirk: gold pollen sneeze sprays out to the right
O.dots(c, { { 51, 40 }, { 53, 38 }, { 55, 37 }, { 52, 43 }, { 55, 42 }, { 57, 40 } }, GOLD[3])
O.dot(c, 54, 39, GOLD[4])

-- face
c:eyeLocked(23, 36)
c:eyeLocked(36, 36)
c:cheek(20, 42)
c:cheek(39, 42)
O.dots(c, { { 28, 44 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 44 } }, P.ink)

O.done(c, "catkin-crown-yard")

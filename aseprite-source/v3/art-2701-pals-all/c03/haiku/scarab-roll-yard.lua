-- Scarab Roll (dw-scarab-roll), yard sprite 64x64. Haiku pass, c03.
-- Wayfinder, common. Teal-green beetle with a domed shell, pushing a sand ball along with its front legs.
-- quirk: a gold coin is stuck inside the sand ball.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("scarab-roll-yard", 64)

local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#b6f0e0", "#d4f6ee" }
local SAND  = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f6d8b0" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(34, 58, 22, 3)

-- sand ball, rolled forward on the left
local ball = c:ellipse(10, 46, 7, 7)
O.shade(c, ball, SAND, { sphere = { 8, 43, 7 }, amb = .25, wrap = .35, sep = SAND[1] })
O.dots(c, { { 6, 40 }, { 12, 42 }, { 8, 50 }, { 13, 49 }, { 4, 46 } }, SAND[5])
-- quirk: a gold coin stuck in the ball
O.flat(c, c:rect(10, 44, 11, 45), GOLD[3], "coin")
O.dot(c, 10, 44, GOLD[4])

-- front legs reaching the ball
for _, L in ipairs({ { { 22, 47 }, { 19, 49 }, { 17, 51 }, { 15, 52 } }, { { 24, 51 }, { 21, 53 }, { 19, 55 }, { 17, 56 } } }) do
  local m, n = O.tube(L, function(t) return .9 end)
  O.shadeN(c, m, n, SEA, { amb = .35, sep = SEA[1] })
end

-- domed shell
local shell = c:ellipse(35, 40, 14, 11)
O.shade(c, shell, SEA, { sphere = { 31, 34, 14 }, amb = .2, wrap = .35, sep = SEA[1], rim = true, bounce = "#2a4a7a", bmax = 2 })
-- wing-case seam down the middle
O.mark(c, { { 35, 32 }, { 35, 33 }, { 35, 34 }, { 35, 36 }, { 35, 38 }, { 35, 40 }, { 35, 42 }, { 35, 44 }, { 34, 46 } }, SEA[1])
-- shell pits
O.dots(c, { { 28, 38 }, { 42, 37 }, { 41, 46 } }, SEA[5])

-- back legs tucked under the shell
for _, L in ipairs({ { { 40, 48 }, { 42, 52 }, { 45, 54 }, { 48, 55 } }, { { 30, 49 }, { 29, 53 }, { 30, 56 }, { 31, 57 } } }) do
  local m, n = O.tube(L, function(t) return .9 end)
  O.shadeN(c, m, n, SEA, { amb = .35, sep = SEA[1] })
end

-- head with antennae
local head = c:ellipse(22, 41, 5, 5)
O.shade(c, head, SEA, { sphere = { 20, 38, 5 }, amb = .2, sep = SEA[1] })
local a1 = O.tube({ { 20, 37 }, { 18, 33 }, { 15, 30 }, { 12, 28 } }, function(t) return .6 end)
O.flat(c, a1, SEA[4], "antenna")
local a2 = O.tube({ { 23, 37 }, { 25, 33 }, { 27, 30 }, { 30, 28 } }, function(t) return .6 end)
O.flat(c, a2, SEA[4], "antenna")

-- face: locked eye, cheek, mouth
c:eyeLocked(18, 38)
O.dots(c, { { 20, 44 }, { 21, 44 } }, P.ink)

O.done(c, "scarab-roll-yard")

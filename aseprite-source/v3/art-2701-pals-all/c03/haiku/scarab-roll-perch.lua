-- Scarab Roll (dw-scarab-roll), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: a gold coin is stuck inside the sand ball.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("scarab-roll-perch", 36)
local SEA = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#b6f0e0", "#d4f6ee" }
local SAND = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f6d8b0" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
c:groundShadow(19, 33, 12, 2)
O.shade(c, c:ellipse(5, 26, 4, 4), SAND, { sphere = { 4, 24, 4 }, amb = .25, sep = SAND[1] })
O.dot(c, 4, 25, GOLD[3]) O.dot(c, 5, 25, GOLD[4])
O.dots(c, { { 3, 23 }, { 7, 28 } }, SAND[5])
local shell = c:ellipse(21, 21, 8, 6)
O.shade(c, shell, SEA, { sphere = { 18, 18, 8 }, amb = .2, wrap = .35, sep = SEA[1], rim = true })
O.mark(c, { { 21, 16 }, { 21, 17 }, { 21, 19 }, { 21, 21 }, { 21, 23 }, { 21, 25 } }, SEA[1])
local head = c:ellipse(12, 22, 3, 3)
O.shade(c, head, SEA, { sphere = { 11, 20, 3 }, amb = .2, sep = SEA[1] })
c:eyeSmall(11, 20)
for _, L in ipairs({ { { 15, 24 }, { 12, 27 }, { 9, 28 }, { 7, 29 } }, { { 25, 25 }, { 26, 28 }, { 28, 30 }, { 30, 31 } } }) do
  local m, n = O.tube(L, function(t) return .6 end)
  O.shadeN(c, m, n, SEA, { amb = .35, sep = SEA[1] })
end
O.done(c, "scarab-roll-perch")

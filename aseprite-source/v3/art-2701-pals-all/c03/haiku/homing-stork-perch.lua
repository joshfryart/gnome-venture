-- Homing Stork (bb-homing-stork), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- Rare: gold beak, scarf and a sparkle. quirk: the bundle on its back is a house with one lit window.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("homing-stork-perch", 36)
local STORK = { "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6", "#f4eee6", "#fff4d6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local EMBER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
c:groundShadow(18, 33, 8, 2)
for _, L in ipairs({ { { 15, 25 }, { 14, 28 }, { 14, 30 }, { 13, 32 } }, { { 19, 25 }, { 20, 28 }, { 20, 30 }, { 21, 32 } } }) do
  local m, n = O.tube(L, function(t) return .7 end)
  O.shadeN(c, m, n, GOLD, { amb = .3, sep = GOLD[1] })
end
local body = c:ellipse(17, 20, 7, 5)
O.shade(c, body, STORK, { sphere = { 14, 18, 7 }, amb = .2, wrap = .35, sep = STORK[1] })
local nm, nn = O.tube({ { 21, 18 }, { 23, 13 }, { 23, 10 }, { 24, 7 } }, function(t) return 2 - 0.5 * t end)
O.shadeN(c, nm, nn, STORK, { amb = .2, wrap = .35, sep = STORK[1] })
O.shade(c, c:ellipse(25, 6, 3, 3), STORK, { sphere = { 24, 5, 3 }, amb = .2, sep = STORK[1] })
local bm, bn = O.tube({ { 27, 6 }, { 29, 6 }, { 31, 6 }, { 34, 6 } }, function(t) return .9 - 0.3 * t end)
O.shadeN(c, bm, bn, GOLD, { amb = .3, sep = GOLD[1] })
c:eyeSmall(24, 5)
O.shade(c, c:poly({ { 4, 17 }, { 7, 13 }, { 10, 17 } }), EMBER, { R = 1, sep = EMBER[1] })
O.shade(c, c:rect(5, 17, 9, 22), EMBER, { R = 1, sep = EMBER[1] })
O.dot(c, 7, 19, GOLD[3]) O.dot(c, 8, 19, GOLD[4])
c:sparkle(31, 17)
O.done(c, "homing-stork-perch")

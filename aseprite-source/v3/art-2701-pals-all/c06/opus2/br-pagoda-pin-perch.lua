-- Pagoda Pin (br-pagoda-pin), perch sprite 36x36. Opus second pass (art-2701-pals-all/c06/opus2), hand-built at this size.
-- Same design as the yard, two tiers instead of three so the face wall stays big: ember roofs with swept-up
-- eave tips, wood walls with red posts, gold ringed spire joined to the roof, stone step, an arm with the
-- index finger pointing straight up. Face: c:eyeSmall pills, proud grin, cheeks.
-- quirk: its little pennant planted on the very tip of the spire (it was up there first).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("br-pagoda-pin-perch", 36)

local ROOF = { "#4a1420", "#7a1e26", "#aa2e2a", "#d24a32", "#ec7a4a", "#f8ae7a" }
local WALL = { "#4a2a22", "#6e4430", "#946240", "#b88458", "#d6a878", "#eccaa0" }
local GOLD = { "#7a3e1c", "#c4741f", "#f0aa2a", "#ffd866", "#fff0b0" }
local STON = { "#3a3446", "#58526a", "#7c7890", "#a4a2b4", "#c8c8d2" }

c:groundShadow(18, 33, 13, 1.5)
local step = c:rect(6, 29, 30, 31)
local sb = {} step:each(function(x, y) if y == 29 then sb[K(x, y)] = 1 end end)
O.shade(c, step, STON, { R = 1, amb = .3, bias = sb, rim = true, cuts = { .25, .45, .65, .85 } })
local function wall(x0, y0, x1, y1)
  local m = c:rect(x0, y0, x1, y1)
  local b = {} m:each(function(x, y) if y == y0 then b[K(x, y)] = -2 end end)
  O.shade(c, m, WALL, { R = 2, amb = .3, wrap = .4, bias = b, sep = WALL[1], rim = true })
  O.flat(c, c:rect(x0, y0 + 1, x0, y1), "#c0402e", "post") O.flat(c, c:rect(x1, y0 + 1, x1, y1), "#8e2a26", "post")
end
local function roof(y0, y1, xl, xr)
  local m = c:poly{ { xl + 5, y0 }, { xr - 5, y0 }, { xr - 1, y1 - 1 }, { xr + 1, y1 - 3 }, { xr + 1, y1 }, { xl - 1, y1 }, { xl - 1, y1 - 3 }, { xl + 1, y1 - 1 } }
  local b = {} m:each(function(x, y) if y == y1 then b[K(x, y)] = -3 elseif x % 3 == 0 then b[K(x, y)] = -2 else b[K(x, y)] = -1 end end)
  O.shade(c, m, ROOF, { R = 1, amb = .32, wrap = .45, bias = b, sep = ROOF[1], rim = true })
end
wall(8, 19, 28, 28)
roof(14, 19, 4, 32)
wall(13, 10, 23, 13)
roof(6, 10, 10, 26)
O.shade(c, c:rect(17, 2, 18, 6), GOLD, { R = 1, amb = .35, sep = GOLD[1], cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 16, 4 }, { 19, 4 } }, GOLD[3]) O.dot(c, 16, 4, GOLD[5])
O.flat(c, c:poly{ { 19, 1 }, { 22, 2 }, { 19, 3 } }, "#d83a40", "pennant")
O.dot(c, 19, 1, "#f06a6a")

c:eyeSmall(12, 21) c:eyeSmall(22, 21)
O.dots(c, { { 15, 25 }, { 16, 26 }, { 17, 26 }, { 18, 26 }, { 19, 26 }, { 20, 25 } }, P.ink)
c:cheek(9, 25) c:cheek(25, 25)

local arm, an = O.tube({ { 28, 25 }, { 31, 25 }, { 32, 23 }, { 32, 20 } }, function(t) return .9 end)
O.shadeN(c, arm, an, WALL, { amb = .35, sep = WALL[1] })
O.shade(c, c:rect(31, 18, 33, 20), WALL, { R = 1, amb = .4, sep = WALL[1] })
O.shade(c, c:rect(32, 14, 32, 17), WALL, { R = 1, amb = .5, sep = WALL[1] })

O.done(c, "br-pagoda-pin-perch")

-- Net Nudge (ow-net-nudge), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: a small ember fish tucked at its feet.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("net-nudge-perch", 36)

local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local EMBER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(18, 32, 9, 2)

O.shade(c, c:ellipse(18, 8, 2, 2), SEA, { R = 1, sep = SEA[1] })
local body = c:ellipse(18, 19, 10, 10)
O.shade(c, body, SEA, { sphere = { 15, 16, 9 }, sep = SEA[1] })
local net = {}
body:each(function(x, y) if (x - y) % 4 == 0 then net[#net + 1] = { x, y } end end)
O.mark(c, net, SEA[4])

c:eyeSmall(13, 18)
c:eyeSmall(22, 18)
c:cheek(10, 22)
c:cheek(24, 22)
O.dots(c, { { 17, 21 }, { 18, 21 } }, SEA[1])
O.dots(c, { { 15, 24 }, { 16, 25 }, { 17, 25 }, { 18, 25 }, { 19, 25 }, { 20, 24 } }, P.ink)

-- quirk: ember fish at the feet
O.shade(c, c:ellipse(6, 29, 3, 2), EMBER, { R = 1, sep = EMBER[1] })
O.shade(c, c:poly{ { 3, 29 }, { 1, 27 }, { 1, 31 } }, EMBER, { R = 1, sep = EMBER[1] })
O.dot(c, 7, 28, P.ink)

O.done(c, "net-nudge-perch")

-- Net Nudge (ow-net-nudge), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Wayfinder, common. A round sea-teal creature with a diamond net woven across its body.
-- quirk: a small ember fish is tucked at its feet, nudged towards the quay.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("net-nudge-yard", 64)

local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local EMBER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

c:groundShadow(32, 58, 16, 3)

-- round body with a knob on top
local knob = c:ellipse(32, 22, 3, 3)
O.shade(c, knob, SEA, { R = 1, sep = SEA[1] })
local body = c:ellipse(32, 37, 16, 15)
local idx, tok = O.shade(c, body, SEA, { sphere = { 28, 32, 14 }, sep = SEA[1] })

-- net: a diamond lattice of light lines across the body
local net = {}
body:each(function(x, y)
  if (x - y) % 6 == 0 or (x + y) % 6 == 0 then net[#net + 1] = { x, y } end
end)
O.mark(c, net, SEA[4])

-- face: locked eyes, cheeks, nose, smile
c:eyeLocked(24, 34)
c:eyeLocked(35, 34)
c:cheek(20, 41)
c:cheek(41, 41)
O.dots(c, { { 31, 40 }, { 32, 40 } }, SEA[1])
O.dots(c, { { 29, 43 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 33, 44 }, { 34, 43 } }, P.ink)

-- quirk: ember fish at the feet
local fish = c:ellipse(12, 51, 5, 3)
O.shade(c, fish, EMBER, { R = 1, sep = EMBER[1] })
O.shade(c, c:poly{ { 7, 51 }, { 3, 48 }, { 3, 54 } }, EMBER, { R = 1, sep = EMBER[1] })
O.dot(c, 14, 50, P.ink)

O.done(c, "net-nudge-yard")

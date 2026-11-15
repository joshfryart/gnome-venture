-- Golden Ring (mh-golden-ring), yard 64x64. Haiku pass, c01.
-- rootwarden, uncommon. A braided gold hoop whose hole is shaped like a pumpkin, with a face on its lower band.
-- quirk: the hole is a good harvest, a three-lobed pumpkin silhouette with a dark gold rim.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-golden-ring-yard", 64)

local GOLD = { "#5c3a14", "#8f5a1e", "#c98a2a", "#f0b448", "#ffd978", "#fff0b0" }
local INK  = P.ink

c:groundShadow(31, 58, 20, 3)

-- hole: three-lobed pumpkin silhouette
local hole = c:ellipse(31, 27, 10, 8)
hole:add(c:ellipse(24, 28, 5, 6))
hole:add(c:ellipse(38, 28, 5, 6))

-- ring: outer hoop minus the hole
local ring = c:ellipse(31, 32, 22, 22):copy():cut(hole)
local rb = {}
ring:each(function(x, y)
  if (x + y) % 4 == 0 then rb[K(x, y)] = -1 end -- braid twist
end)
O.shade(c, ring, GOLD, { R = 6, bias = rb })

-- dark gold rim around the hole
local rim = hole:copy():grow(1):clip(ring)
O.flat(c, rim, GOLD[1], "rim")

-- face on the lower band
c:eyeLocked(23, 42)
c:eyeLocked(35, 42)
c:cheek(21, 47)
c:cheek(39, 47)
O.dot(c, 31, 47, GOLD[1])
O.dot(c, 30, 46, GOLD[5])
O.dots(c, { {27,50},{28,51},{29,51},{30,51},{31,51},{32,51},{33,51},{34,50} }, GOLD[1])

O.done(c, "mh-golden-ring-yard")

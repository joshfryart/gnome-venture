-- Tide Tuck (ss-tide-tuck), yard 64x64. Haiku pass, c01.
-- brewroot, common. A sand mound with a scallop-shell hat, tucked into the sand, peeking up over a wave.
-- quirk: it tucks itself into the sand just before a wave; the wave's foam crest is drawn over its base.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("ss-tide-tuck-yard", 64)

local SAND = { "#5a3e2a", "#8f6b3e", "#c49a5c", "#e8c98a", "#f5e0b0", "#fff4d6" }
local SHEL = { "#8f3a3a", "#b5524a", "#d9735a", "#f08f7a", "#f8b8a0", "#ffd9c8" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0", "#e4f6ff" }
local INK  = P.ink

-- sand mound, the top half of the body
local mound = c:ellipse(31, 44, 20, 13)
O.shade(c, mound, SAND, { R = 6 })

-- scallop-shell hat: fan with ribs running out from a hinge
local shell = c:ellipse(31, 32, 12, 8)
shell:cut(c:rect(0, 40, 63, 63))
O.shade(c, shell, SHEL, { R = 4, sep = SHEL[1] })
for _, r in ipairs({ { {31,38},{24,33} }, { {31,38},{28,32} }, { {31,38},{34,32} }, { {31,38},{38,33} } }) do
  O.flat(c, c:line(r, 1), SHEL[2])
end

-- face peeking out of the sand: locked eyes, sand-grain nose, small mouth
c:eyeLocked(24, 46)
c:eyeLocked(34, 46)
c:cheek(20, 50)
c:cheek(41, 50)
O.dots(c, { {30,50},{31,50} }, SAND[1])
O.dots(c, { {28,53},{29,54},{30,54},{31,54},{32,54},{33,53} }, SAND[1])

-- wave: sea band with a foam crest, drawn over the base
local wave = c:poly{ {0,52},{10,49},{20,52},{31,49},{42,52},{52,49},{63,52},{63,63},{0,63} }
O.shade(c, wave, SEA, { R = 4, sep = SEA[1] })
O.dots(c, { {4,50},{5,50},{8,49},{14,50},{15,50},{19,51},{22,51},{27,48},{28,48},{35,48},{36,48},{40,50},{46,50},{47,50},{55,49},{59,50} }, SEA[5])

O.done(c, "ss-tide-tuck-yard")

-- Cob Scout (mh-cob-scout), yard 64x64. Haiku pass, c01.
-- wayfinder, common. A corn cob in a husk, wearing a straw scout hat, with a counting stick.
-- quirk: a counting stick with a tick mark for every row of kernels.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-cob-scout-yard", 64)

local GOLD = { "#8f4a1f", "#b5652a", "#d98322", "#f5b82e", "#ffe38a", "#fff2b8" }
local HUSK = { "#24544a", "#3f9150", "#5aa657", "#7cc35a", "#a6d670", "#c4e07a" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982", "#f3d2a0", "#f8e4c0" }
local INK  = P.ink

c:groundShadow(31, 58, 15, 3)

-- back husk leaves
O.shade(c, c:poly{ {22,56},{8,46},{10,34},{24,46} }, HUSK, { R = 2 })
O.shade(c, c:poly{ {40,56},{54,46},{52,34},{38,46} }, HUSK, { R = 2 })

-- cob with a kernel grid (dark seams every 4 px)
local cob = c:ellipse(31, 34, 12, 18)
local kb = {}
cob:each(function(x, y)
  if (x - 19) % 4 == 0 or y % 4 == 0 then kb[K(x, y)] = -1 end
end)
O.shade(c, cob, GOLD, { R = 7, bias = kb })

-- front husk wrapping the bottom of the cob
O.shade(c, c:poly{ {20,52},{22,42},{30,46},{28,56},{22,56} }, HUSK, { R = 2, sep = HUSK[1] })

-- straw scout hat: crown, brim, dark band, stitched top
local crown = c:rrect(23, 5, 39, 14, 3)
O.shade(c, crown, WOOD, { R = 3 })
local brim = c:ellipse(31, 15, 17, 3)
O.shade(c, brim, WOOD, { R = 2, sep = WOOD[1] })
local band = {}
for x = 24, 38 do band[#band + 1] = { x, 10 } end
O.dots(c, band, WOOD[1])
c:stitch({ {24,7}, {38,7} })

-- counting stick in the husk, one tick per kernel row
local stick = c:line({ {46,48}, {56,18} }, 1)
O.flat(c, stick, WOOD[3])
local tk = {}
for i = 1, 6 do
  local t = i / 7
  tk[#tk + 1] = { math.floor(46 + 10 * t + .5) + 1, math.floor(48 - 30 * t + .5) }
end
O.dots(c, tk, WOOD[1])

-- face: locked eyes, button nose with glint, grin
c:eyeLocked(23, 30)
c:eyeLocked(35, 30)
c:cheek(21, 36)
c:cheek(39, 36)
O.dot(c, 31, 37, INK)
O.dot(c, 30, 36, P.cream)
O.dots(c, { {27,40},{28,41},{29,41},{30,41},{31,41},{32,41},{33,41},{34,40} }, GOLD[1])

O.done(c, "mh-cob-scout-yard")

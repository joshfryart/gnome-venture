-- Teal Ferry (sp-teal-ferry), yard sprite 64x64. Opus richness pass (c06/opus3), built on c06/opus2.
-- Uncommon, thornblade. "Ferries flower boats down the teal river and waves at every fish."
-- A teal pal in a straw cone hat sitting in a wooden ferry canoe heaped with marigolds and pink blossoms, on a
-- small bounded patch of teal river.
-- Richness: woven straw hat (ring rows, cross-weave flecks, knot on the tip), plank seams, grain dashes and
-- pegs on the hull with a lit gunwale a dark hull reflection and lit wave crests on
-- the water, a ring ripple under the leaping fish, fish scales and fin rays, cool skin sheen on the pal.
-- quirk: it waves at a fish, and the fish leaping out of the river waves its fin back.
-- Closer look: one marigold has fallen overboard and floats behind the stern.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-teal-ferry-yard", 64)

local TEAL = { "#173c48", "#1f5e66", "#2a8486", "#43a8a2", "#74c8bc", "#b4e6d8" }
local RIV  = { "#1c4a5e", "#236a7a", "#2e8a92", "#4aaeae", "#86d0c8", "#c6ece2" }
local WOOD = { "#3a2422", "#5e3a2a", "#86573a", "#ad7c4f", "#cfa36c", "#ead0a0" }
local STRAW= { "#6e4a22", "#9a6a2c", "#c8963c", "#e4be5c", "#f6dc8a" }
local MARI = { "#a8401c", "#e0701e", "#f8a628", "#ffd660" }
local PINK = { "#a03a60", "#dc6a8c", "#f6a2b8", "#ffd2dc" }
local FISH = { "#7a2a1c", "#c4501e", "#f08030", "#ffb45a", "#ffe0a0" }
local BNC  = "#4c6a8a"
local H = O.H

-- the river patch
local riv = c:ellipse(32, 50, 29, 6)
riv:add(c:ellipse(14, 50, 9, 5)) riv:add(c:ellipse(50, 51, 10, 5))
local rb = {} riv:each(function(x, y) if (y == 50 and x % 9 < 3) or (y == 53 and (x + 4) % 11 < 3) then rb[K(x, y)] = 2 else rb[K(x, y)] = -1 end end)
local rI, rT = O.shade(c, riv, RIV, { R = 3, amb = .35, wrap = .4, bias = rb })
-- dark reflection of the hull straight under the boat, broken by the wave rows
O.tex(c, rI, rT, RIV, function(x, y, i) if y >= 49 and y <= 52 and x >= 10 and x <= 54 and (x + y) % 5 ~= 0 then return -1 end end)
-- closer look: a marigold fallen overboard, floating behind the stern
local fl = O.pat(c, 7, 49, { ".a.", "aba", ".a." }, { a = "#f8a628", b = "#a8401c" }, "float")
O.inkAround(c, fl, RIV[1])
O.mark(c, { { 6, 52 }, { 10, 52 }, { 11, 51 } }, RIV[6])

-- the pal (sitting low in the boat)
local body = c:ellipse(25, 34, 11, 10)
local tI, tT = O.shade(c, body, TEAL, { sphere = { 21, 30, 14 }, amb = .26, wrap = .35, rim = true, sep = TEAL[1] })
O.tex(c, tI, tT, TEAL, function(x, y, i) if H(x, y, 21) > .93 and i >= 3 and i <= 5 then return 1 end end) -- wet sheen flecks
-- straw cone hat
local hat = c:poly{ { 11, 26 }, { 39, 26 }, { 25, 13 } }
hat:add(c:ellipse(25, 26, 14, 1.5))
local hI, hT = O.shade(c, hat, STRAW, { sphere = { 21, 18, 14 }, amb = .3, wrap = .4, sep = STRAW[1], rim = true, cuts = { .22, .42, .62, .82 } })
-- woven straw: dark ring rows round the cone, cross-weave flecks between them
O.tex(c, hI, hT, STRAW, function(x, y, i)
  if y >= 26 then return (x % 2 == 0) and -1 or 0 end
  if y % 3 == 1 then return -1 end
  if y % 3 == 0 and (x + y) % 3 == 0 and i >= 2 then return 1 end
  if y % 3 == 2 and (x - y) % 3 == 0 then return -1 end
end)
O.dots(c, { { 25, 12 }, { 24, 13 } }, STRAW[5]) O.dots(c, { { 25, 13 }, { 26, 13 } }, STRAW[3]) -- tip knot
O.flat(c, c:rect(14, 27, 36, 27), TEAL[2], "brim shadow")
-- face
c:eyeLocked(17, 29)
c:eyeLocked(27, 29)
O.dots(c, { { 22, 36 }, { 23, 37 }, { 24, 37 }, { 25, 36 } }, P.ink)
c:cheek(15, 35) c:cheek(32, 35)

-- waving arm, up and to the right
local arm, an = O.tube({ { 33, 36 }, { 38, 34 }, { 41, 29 }, { 42, 23 } }, function(t) return 1.8 end)
O.shadeN(c, arm, an, TEAL, { amb = .3, wrap = .4, sep = TEAL[1] })
O.shade(c, c:ellipse(42.5, 21.5, 2.5, 2.5), TEAL, { sphere = { 42, 20, 3 }, amb = .35, sep = TEAL[1] })

-- canoe: low hull with upswept bow (right) and stern (left)
local hull = c:poly{ { 4, 37 }, { 9, 42 }, { 52, 42 }, { 59, 33 }, { 60, 35 }, { 55, 48 }, { 12, 48 }, { 5, 41 } }
local wb = {} hull:each(function(x, y) wb[K(x, y)] = -1 if y == 45 then wb[K(x, y)] = -2 end if y == 42 then wb[K(x, y)] = 1 end end)
O.shade(c, hull, WOOD, { R = 2, amb = .26, wrap = .4, bias = wb, sep = WOOD[1], rim = true, bounce = BNC, bmax = 2 })
-- plank seams, grain dashes, pegs
hull:each(function(x, y)
  local q = y * c.w + x
  if y == 44 or y == 47 then if x % 11 ~= 3 then c.pix[q] = WOOD[2] end
  elseif y > 42 and y < 48 and (x * 3 + y * 7) % 13 == 0 then c.pix[q] = WOOD[3] end
end)
O.dots(c, { { 20, 45 }, { 34, 45 }, { 44, 46 } }, WOOD[6])
O.dots(c, { { 21, 46 }, { 35, 46 }, { 45, 47 } }, WOOD[1])

-- flower cargo at bow and stern
local function bloom(x, y, R)
  O.shade(c, c:ellipse(x, y, 1.6, 1.6), R, { sphere = { x - 1, y - 1, 2 }, amb = .35, sep = R[1], cuts = { .3, .55, .8 } })
  O.dot(c, x, y, R[1])
end
for _, f in ipairs({ { 9, 40, MARI }, { 12, 39, PINK }, { 15, 40, MARI }, { 40, 40, PINK }, { 44, 39, MARI }, { 47, 40, PINK }, { 50, 39, MARI }, { 43, 41, MARI } }) do
  bloom(f[1], f[2], f[3])
end
O.dots(c, { { 18, 41 }, { 37, 41 } }, "#4eae5a") -- leaves tucked in

-- quirk: a fish leaping out of the river, waving a fin back
local fb = c:ellipse(53, 23, 4.5, 2.5)
O.shade(c, fb, FISH, { sphere = { 51, 21, 6 }, amb = .3, wrap = .4, sep = FISH[1], cuts = { .22, .42, .62, .82 } })
O.shade(c, c:poly{ { 57, 23 }, { 61, 19 }, { 61, 27 } }, FISH, { R = 1, amb = .3, sep = FISH[1], cuts = { .22, .42, .62, .82 } })
O.shade(c, c:poly{ { 52, 20 }, { 53, 15 }, { 55, 20 } }, FISH, { R = 1, amb = .45, sep = FISH[1], cuts = { .22, .42, .62, .82 } }) -- waving fin
O.dot(c, 50, 22, P.ink) O.dot(c, 49, 24, FISH[1])
O.dots(c, { { 53, 23 }, { 55, 22 }, { 54, 24 } }, FISH[3]) -- scales
O.dots(c, { { 59, 22 }, { 59, 24 }, { 60, 23 } }, FISH[2]) -- tail rays
O.dots(c, { { 51, 21 }, { 52, 21 } }, FISH[5])
-- front water lapping over the hull foot
local lap = c:ellipse(30, 50, 24, 2) lap:cut(c:rect(0, 0, 63, 48))
O.shade(c, lap, RIV, { R = 1, amb = .4, sep = RIV[2] })
O.dots(c, { { 14, 49 }, { 15, 49 }, { 30, 49 }, { 31, 49 }, { 44, 49 } }, RIV[6])
-- lit wave crests across the river and a ring ripple under the fish
O.mark(c, { { 6, 53 }, { 7, 53 }, { 8, 52 }, { 22, 54 }, { 23, 54 }, { 24, 53 }, { 40, 54 }, { 41, 54 }, { 42, 53 }, { 56, 52 }, { 57, 52 } }, RIV[5])
O.mark(c, { { 50, 46 }, { 51, 45 }, { 52, 45 }, { 56, 45 }, { 57, 45 }, { 58, 46 } }, RIV[6])
O.shift(c, 0, -3)

O.done(c, "sp-teal-ferry-yard", function(c)
  -- splash under the fish and wave ticks by both hands (un-outlined)
  for _, p in ipairs({ { 52, 26 }, { 54, 27 }, { 56, 26 }, { 46, 16 }, { 47, 15 }, { 46, 19 }, { 47, 19 }, { 52, 10 }, { 55, 10 } }) do
    if not c.pix[p[2] * c.w + p[1]] then c:put(p[1], p[2], RIV[6]) end
  end
end)

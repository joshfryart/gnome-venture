-- Eye of the Storm (pl-hcr-5), yard sprite 64x64. Opus third pass (c14/opus3, richness), built on c14/opus2.
-- opus3: a billowing scalloped cloud edge (cumulus lobes) instead of a smooth tyre rim, puffy crest bands
-- along the spiral arms, a tiny yellow lightning flicker in the cloud, and a green leaf being whipped round
-- in the loud wind outside (closer look).
-- Bloomcaller, uncommon, Lair of the Hurricane Crab. "A calm round hole in the middle of a very loud wind."
-- Haiku drew a flat grey tyre with a blue face plate. It is now a little hurricane seen from above: a ring of
-- storm cloud with three spiral arms flung out round it, swirl streaks and puffy lit crests, a shadowed eye
-- wall, and in the middle the calm hole of clear blue sky that is the face.
-- quirk: in all that wind, one tiny pink flower floats perfectly still inside the calm eye.
-- closer look: loud-wind streak lines whip past outside the arms.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-5-yard", 64)
local cos, sin, pi, floor, atan, sqrt = math.cos, math.sin, math.pi, math.floor, math.atan, math.sqrt

local STRM = { "#2a2846", "#3e4266", "#5a6488", "#8292ac", "#b4c4d4", "#e0e9ee" }
local CALM = { "#3e6aa8", "#5c96d0", "#88c0e6", "#bce0f2", "#e2f4f8" }
local FLWR = { "#a8405e", "#e0708a", "#f8a8b8" }
local WIND = "#d0dee6"
local CX, CY = 32, 30

c:groundShadow(32, 57, 15, 2.5)

-- spiral arms (counter-clockwise swirl), behind the ring
for k = 0, 2 do
  local a0 = 20 + k * 120
  local function P2(a, r) return CX + r * cos(a * pi / 180), CY + r * sin(a * pi / 180) * .9 end
  local x0, y0 = P2(a0, 13) local x1, y1 = P2(a0 - 25, 19) local x2, y2 = P2(a0 - 55, 23) local x3, y3 = P2(a0 - 85, 24)
  local m, n, TT = O.tube({ { x0, y0 }, { x1, y1 }, { x2, y2 }, { x3, y3 } }, function(t) return 5 * (1 - t) ^ .9 + .5 end)
  local I, T = O.shadeN(c, m, n, STRM, { amb = .3, wrap = .45, rim = true, bounce = "#6a5a8a", bmax = 2, sep = STRM[1] })
  -- puffy crests: a pale band then a dark crease every so often along the arm
  O.tex(c, I, T, STRM, function(x, y, i) local t = TT[K(x, y)] if not t or t < .12 then return end
    local f = (t * 5) % 1
    if f < .12 then return -2 elseif f < .26 and i >= 2 then return 1 end end)
end

-- the cloud ring
local ring = c:ellipse(CX, CY, 16, 14)
for a = 0, 359, 30 do -- cumulus lobes round the rim (billowing, not a smooth tyre)
  local r = 3 + (a // 30) % 2
  ring:add(c:ellipse(CX + 15 * cos((a + 10) * pi / 180), CY + 13.2 * sin((a + 10) * pi / 180), r, r))
end
local rI, rT = O.shade(c, ring, STRM, { sphere = { CX - 5, CY - 6, 21 }, amb = .32, wrap = .45, rim = true, bounce = "#6a5a8a", bmax = 2 })
-- swirl streaks: dark grooves spiralling in, pale puffy crests just ahead of them
O.tex(c, rI, rT, STRM, function(x, y, i)
  local dx, dy = x - CX, (y - CY) / .9
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx) / (2 * pi)
  local s = (a * 3 + r * .09) % 1
  if s < .08 and r > 11 then return -2 end
  if s > .08 and s < .15 and r > 11 and i >= 3 then return 1 end
end)

-- lobe creases: a dark arc under each billow so the lobes read
for a = 0, 359, 30 do
  local ax, ay = CX + 15 * cos((a + 10) * pi / 180), CY + 13.2 * sin((a + 10) * pi / 180)
  local r = 3 + (a // 30) % 2
  for d = -60, 60, 15 do
    local px, py = floor(ax + (r - .2) * cos((a + 10 + 180 + d) * pi / 180) + .5), floor(ay + (r - .2) * sin((a + 10 + 180 + d) * pi / 180) + .5)
    O.nudge(c, { { px, py } }, -1, STRM)
  end
end
-- a tiny lightning flicker deep in the cloud (lower left)
O.dots(c, { { 44, 36 }, { 43, 37 }, { 44, 38 }, { 43, 39 } }, "#f8d44a")
-- eye wall: a deep shadow band on the upper inside of the hole, then the calm sky disc
local hole = c:ellipse(CX, CY + .5, 10, 9)
O.flat(c, hole, STRM[2], "wall")
local sky = c:ellipse(CX + .5, CY + 1.5, 9, 8)
O.shade(c, sky, CALM, { sphere = { CX - 3, CY - 3, 14 }, amb = .45, wrap = .55, cuts = { .25, .45, .65, .85 } })
-- wall edge: lit lip on the lower inside (the far wall catches the light)
hole:each(function(x, y) if not sky:has(x, y) and y > CY + 4 then O.mark(c, { { x, y } }, STRM[4]) end end)

-- face in the calm
c:eyeLocked(26, 27)
c:eyeLocked(34, 27)
c:cheek(25, 33) c:cheek(38, 33)
O.dots(c, { { 30, 34 }, { 31, 35 }, { 32, 35 }, { 33, 34 } }, P.ink)

-- the still little flower, floating low right in the eye
O.dots(c, { { 37, 36 }, { 39, 36 }, { 38, 35 }, { 38, 37 } }, FLWR[2])
O.dot(c, 38, 36, "#f6d25a")
O.dots(c, { { 37, 35 } }, FLWR[3]) O.dots(c, { { 39, 37 } }, FLWR[1])

O.done(c, "pl-hcr-5-yard", function(c)
  -- loud wind streaks whipping round outside
  for _, L in ipairs({ { { 4, 18 }, { 5, 17 }, { 6, 17 }, { 7, 16 } }, { { 3, 24 }, { 4, 23 }, { 5, 23 } },
                       { { 57, 40 }, { 58, 41 }, { 59, 41 }, { 60, 42 } }, { { 58, 34 }, { 59, 35 }, { 60, 35 } },
                       { { 40, 4 }, { 41, 4 }, { 42, 4 }, { 43, 5 } }, { { 20, 56 }, { 21, 56 }, { 22, 57 } } }) do
    for _, p in ipairs(L) do if not c:get(p[1], p[2]) then O.dot(c, p[1], p[2], WIND) end end
  end
  -- a green leaf whipped round in the wind (closer look), with an ink edge of its own
  O.rows(c, 52, 9, { ".kkk.", "kgGlk", "kGgk.", ".kk.." }, { k = P.ink, g = "#4a9a4a", G = "#2a6640", l = "#9ccc68" }, "leaf")
end)

-- Talon Clutch (pl-cnd-4), yard sprite 64x64. Opus richness pass (c09/opus3), built on c09/opus2.
-- opus3: opus2's round pad on four toes could read as a round creature sitting on a rock; now a scaly shank
-- (overlapping scutes) rises out of a flatter pad up to a cuff of dark condor feathers at the top edge, so it reads
-- as the condor's foot standing on the rock.
-- Also: lit ridge and dark groove on each talon, scute rings with lit edges on the toes, lichen and grit on the
-- rock. closer look: a chip of stone breaking off, and one condor down feather snagged between two toes.
-- Rootwarden, uncommon, Condor's Crag. "Four curled talons that grip the crag and never let go."
-- A condor's foot gripping a lump of crag rock: a plump, scaly mauve-grey foot pad (the face) with four thick
-- ringed toes reaching down over the rock's lip, each ending in a curled dark horn talon hooked into the stone.
-- The rock is the crag's violet stone with a sandy top and gold-seamed cracks like the lair art.
-- quirk: it never lets go: the talons have dug in so hard the rock is cracking under each one, and a chip of
-- stone is breaking off, while the face stays grimly content.
-- closer look: a chip of stone breaking off the rock's right edge.
-- Fixes over haiku: purple ball on gold sticks over a grey bar (now a scaly foot with curled talons hooked over
-- a real rock), flat fills (now 6-tone scale, horn and stone ramps).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cnd-4-yard", 64)

local SCALE = { "#4a2e36", "#74505a", "#9c7680", "#c29ea4", "#e0c4c4", "#f4e2dc" }
local HORN = { "#5a4030", "#8a6a4a", "#c0a070", "#e6cc98", "#f8ecc8" }
local ROCK = { "#261e36", "#3a2e4c", "#544468", "#705c84", "#8e78a0", "#ae98b8" }
local SAND = { "#c9a479", "#e6c995", "#f5e3b8" }

c:groundShadow(32, 57, 23, 2)

-- the rock
local rock = c:poly({ { 9, 41 }, { 16, 38 }, { 26, 39 }, { 36, 37 }, { 47, 38 }, { 55, 40 }, { 56, 47 }, { 54, 52 }, { 56, 57 }, { 8, 57 }, { 10, 51 }, { 8, 46 } })
local rI, rT = O.shade(c, rock, ROCK, { R = 4, amb = .3, wrap = .45, rim = true, bounce = "#6f8fc0", bmax = 2 })
O.tex(c, rI, rT, ROCK, function(x, y, i)
  if (x == 21 or x == 42) and y > 50 then return -2 end
  if (x == 22 or x == 43) and y > 50 then return 1 end
  if H(x, y, 8) > .9 then return -1 end
  if i >= 4 and H(x, y, 9) > .9 then return 1 end
end)
O.dots(c, { { 11, 52 }, { 12, 52 }, { 12, 53 } }, "#8aa070") O.dot(c, 11, 53, "#b4c48a")
O.dots(c, { { 51, 54 }, { 52, 54 } }, "#8aa070")
rock:each(function(x, y) if not rock:has(x, y - 2) then c.pix[y * c.w + x] = (rock:has(x, y - 1) and SAND[1] or SAND[2]) end end)
-- gold seams
O.dots(c, { { 14, 47 }, { 15, 48 }, { 15, 49 }, { 16, 50 }, { 30, 51 }, { 31, 52 }, { 32, 52 }, { 33, 53 }, { 48, 48 }, { 48, 49 }, { 49, 50 } }, "#d9a040")

-- toes: from the pad down over the rock lip, each curling into a talon
local toes = {
  { { 24, 32 }, { 19, 35 }, { 16, 38 }, { 16, 43 } },
  { { 29, 35 }, { 27, 38 }, { 26, 40 }, { 26, 44 } },
  { { 35, 35 }, { 37, 38 }, { 38, 40 }, { 38, 44 } },
  { { 40, 32 }, { 45, 35 }, { 48, 38 }, { 48, 43 } },
}
local tips = {}
for ti, p in ipairs(toes) do
  local m, n, T = O.tube(p, function(t) return 3.6 - 1.2 * t end)
  local I, Tk = O.shadeN(c, m, n, SCALE, { amb = .28, wrap = .45, rim = true, sep = SCALE[1] })
  -- scale rings across the toe
  O.tex(c, I, Tk, SCALE, function(x, y, i)
    local t = T[K(x, y)]
    if t and math.floor(t * 9) % 2 == 0 and (t * 9) % 1 < .35 then return -1 end
    if t and math.floor(t * 9) % 2 == 0 and (t * 9) % 1 >= .35 and (t * 9) % 1 < .6 and i >= 3 then return 1 end
  end)
  tips[ti] = p[4]
end
-- talons: curled horn hooks into the rock
local claws = {
  { { 16, 43 }, { 15, 47 }, { 16, 49 }, { 18, 49 } },
  { { 26, 44 }, { 25, 48 }, { 26, 50 }, { 28, 50 } },
  { { 38, 44 }, { 39, 48 }, { 38, 50 }, { 36, 50 } },
  { { 48, 43 }, { 49, 47 }, { 48, 49 }, { 46, 49 } },
}
for ci, p in ipairs(claws) do
  local m, n = O.tube(p, function(t) return 2 * (1 - t) + .4 end)
  O.shadeN(c, m, n, HORN, { amb = .3, wrap = .5, cuts = { .25, .45, .65, .85 }, sep = HORN[1] })
  O.dot(c, p[1][1] + (ci <= 2 and -1 or 1), p[1][2] + 1, HORN[5]) -- glint on the hook
  O.dot(c, p[1][1] + (ci <= 2 and -1 or 1), p[1][2] + 2, HORN[4])
end
-- cracks spreading from under each talon
for _, cr in ipairs({ { { 19, 50 }, { 20, 51 }, { 20, 52 }, { 21, 53 } }, { { 29, 51 }, { 29, 52 }, { 30, 53 } },
                      { { 35, 51 }, { 35, 52 }, { 34, 53 } }, { { 45, 50 }, { 44, 51 }, { 44, 52 }, { 43, 53 } } }) do
  O.dots(c, cr, ROCK[1])
end

-- the shank: scaly leg rising out of the pad, with a cuff of dark condor feathers on top
local FEA = { "#1c1626", "#2e2438", "#463852", "#665676", "#8c7a9a" }
local shank = c:poly({ { 26, 24 }, { 28, 4 }, { 36, 4 }, { 38, 24 } })
local sI, sT = O.shade(c, shank, SCALE, { R = 3, amb = .28, wrap = .45, rim = true, bounce = "#6f8fc0", bmax = 2, sep = SCALE[1] })
O.tex(c, sI, sT, SCALE, function(x, y, i)
  local yy = y + ((x // 3) % 2)
  if yy % 3 == 0 then return -1 end                     -- scute edges
  if yy % 3 == 1 and i >= 3 then return 1 end           -- lit scute rim
end)
-- feather cuff: dark condor feathers hanging down over the top of the shank
local cuff = O.unionCircles({ { 26.5, 4.5, 2.5 }, { 30, 3.5, 3 }, { 34, 3.5, 3 }, { 37.5, 4.5, 2.5 } })
for _, f in ipairs({ { 25, 8 }, { 28, 10 }, { 31, 11 }, { 34, 10 }, { 37, 9 }, { 39, 7 } }) do
  cuff:add(c:poly({ { f[1] - 2.5, 3 }, { f[1] + .5, f[2] }, { f[1] + 2.5, 3 } }))
end
local cI, cT = O.shade(c, cuff, FEA, { R = 2, amb = .3, wrap = .5, rim = true, cuts = { .3, .5, .7, .86 }, sep = FEA[1] })
O.tex(c, cI, cT, FEA, function(x, y, i) if (x % 3 == 0 and y > 3) then return -1 end end)
O.dots(c, { { 25, 4 }, { 28, 2 }, { 29, 2 }, { 32, 2 }, { 33, 2 } }, FEA[5])

-- the pad: plump scaly dome (face)
local pad = c:ellipse(32, 29, 12.5, 8)
local pI, pT = O.shade(c, pad, SCALE, { sphere = { 28, 22, 14 }, amb = .3, wrap = .45, rim = true, bounce = "#6f8fc0", bmax = 2, sep = SCALE[1] })
local function face(x, y) return x >= 24 and x <= 40 and y >= 23 and y <= 33 end
O.tex(c, pI, pT, SCALE, function(x, y, i)
  if face(x, y) then return 0 end
  local r = (y + ((x // 3) % 2) * 1) % 3
  if r == 0 and x % 3 == 0 then return -1 end            -- reticulate scales
  if r == 1 and x % 3 == 1 and i >= 3 then return 1 end
end)

-- face: grim content
c:eyeLocked(25, 24)
c:eyeLocked(34, 24)
c:cheek(24, 30) c:cheek(38, 30)
O.dots(c, { { 29, 31 }, { 30, 31 }, { 31, 31 }, { 32, 31 }, { 33, 31 }, { 34, 31 } }, P.ink)
O.dots(c, { { 30, 32 }, { 33, 32 } }, SCALE[2])

-- a condor down feather snagged between the middle toes (closer look)
O.dots(c, { { 32, 40 }, { 32, 41 }, { 31, 42 }, { 33, 42 } }, "#efe4d4") O.dots(c, { { 32, 42 }, { 32, 43 } }, "#c9b8a8")

O.shift(c, 0, -1)
O.done(c, "pl-cnd-4-yard", function(c)
  -- a chip breaking off the rock lip on the right
  O.dots(c, { { 58, 50 }, { 58, 51 } }, ROCK[5])
  O.dots(c, { { 58, 54 } }, ROCK[4])
end)

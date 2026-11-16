-- Highland Ring (rr-highland-ring), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
-- Rootwarden, uncommon, Rainroot. "A cloud-cold hoop that claims to be the highest hoop in the world."
-- A tall standing hoop of cold blue granite with a REAL hole (you see through it), a scalloped snow cap with
-- icicles over the hole, a small cloud drifting through the hole, purple heather tufts at its foot.
-- The face sits on the heavy lower band; brows raised, smug little smile (it is bragging).
-- Fixes: the Haiku disc read as a diving helmet (filled window); now the hole is open, the snow cap and
-- icicles say "cold summit", the cloud makes the scale joke.
-- quirk: a tiny summit flag planted in the snow on top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("rr-highland-ring-yard", 64)

local STN  = { "#2c3048", "#434a68", "#5f6888", "#8590ac", "#aeb8cc", "#d0d8e4" }
local SNOW = { "#6a78a0", "#98a6c6", "#c4d0e4", "#e2eaf4", "#f2f6fa" }
local HEA  = { "#3e2450", "#6a3a78", "#9a54a0", "#c47cc0", "#e4aadc" }
local HGR  = { "#1f4a3c", "#2f6b46", "#4a8f4e" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }
local WOOD = { "#3a2228", "#5e3a2e", "#86563a", "#ad7a4c" }
local FLAG = { "#7c1c34", "#d23a3a", "#f06a4a" }

c:groundShadow(32, 57, 18, 3)

local outer = c:ellipse(32, 35, 16, 20)
local hole = c:ellipse(32, 31, 8, 10.5)
local ring = outer:copy():cut(hole)
local rb = {}
ring:each(function(x, y)
  if hole:has(x, y - 1) or hole:has(x, y - 2) then rb[K(x, y)] = -1 end -- under the hole: inner face in shade
  if y > 52 then rb[K(x, y)] = (rb[K(x, y)] or 0) - 1 end
end)
local rI, rT = O.shade(c, ring, STN, { R = 6, bias = rb, amb = .1, wrap = .3, sep = STN[1], rim = true, bounce = "#7a8ab8", bmax = 2 })
-- granite: mica glints and dark specks, away from the face
O.tex(c, rI, rT, STN, function(x, y, i)
  local face = x > 21 and x < 43 and y > 42 and y < 53
  local h = H(x, y, 13)
  if h > (face and .99 or .93) and i >= 2 and i <= 5 then return 1 end
  if h < (face and .01 or .05) and i >= 3 then return -1 end
end)
-- inner wall of the hole: a lit sliver on the right inside edge, dark on the left inside edge
hole:edge():each(function(x, y) end)
for y = 22, 40 do
  for x = 40, 42 do if ring:has(x, y) and hole:has(x - 1, y) then c:put(x, y, STN[5], rT) break end end
  for x = 24, 22, -1 do if ring:has(x, y) and hole:has(x + 1, y) then c:put(x, y, STN[2], rT) break end end
end

-- the cloud drifting through the hole (back half behind the ring is simply not drawn)
local cl = O.unionCircles{ { 29, 36, 3.5, 2.5 }, { 34, 35, 4, 3 }, { 38.5, 37, 3, 2 } }
cl:add(c:rect(26, 37, 41, 38))
cl:clip(hole:copy():shrink(1))
O.shade(c, cl, CLD, { R = 2, amb = .4, cuts = { .35, .6, .85 } })
-- the part of the cloud spilling out in front of the ring on the right
local cl2 = O.unionCircles{ { 44, 38, 3, 2.5 }, { 48, 39, 2.5, 2 } }
cl2:add(c:rect(42, 39, 49, 40))
O.shade(c, cl2, CLD, { R = 2, amb = .4, cuts = { .35, .6, .85 }, rim = true })

-- snow cap with scalloped hem
local snow = HP.mask()
outer:each(function(x, y)
  local hem = 23 + math.floor(2 * math.abs(math.sin((x - 16) * .55))) + ((x < 24 or x > 40) and 2 or 0)
  if y <= hem then snow:set(x, y) end
end)
snow:add(c:ellipse(32, 15, 9, 2))
snow:cut(hole)
local sI, sT = O.shade(c, snow, SNOW, { R = 3, amb = .3, wrap = .4, sep = SNOW[1], cuts = { .25, .5, .72, .88 }, rim = true })
O.tex(c, sI, sT, SNOW, function(x, y, i) if H(x, y, 41) > .94 and i >= 3 then return -1 end end)
-- icicles hanging into the hole
for _, ic in ipairs({ { 28, 22, 3 }, { 31, 21, 4 }, { 35, 21, 2 }, { 37, 22, 3 } }) do
  for k = 0, ic[3] - 1 do O.dot(c, ic[1], ic[2] + k, k == 0 and SNOW[4] or (k == ic[3] - 1 and SNOW[2] or SNOW[3])) end
end

-- heather tufts at the foot
for _, t in ipairs({ { 17, 52, -1 }, { 46, 52, 1 }, { 22, 55, -1 } }) do
  local x, y, s = t[1], t[2], t[3]
  O.dots(c, { { x, y + 2 }, { x + s, y + 1 }, { x + 2 * s, y + 2 } }, HGR[2]) O.dots(c, { { x, y + 3 }, { x + 1, y + 3 }, { x - 1, y + 3 } }, HGR[1])
  O.dots(c, { { x, y }, { x, y + 1 } }, HEA[3]) O.dot(c, x, y - 1, HEA[5]) O.dots(c, { { x + s, y }, { x + 2 * s, y + 1 } }, HEA[4])
  O.dot(c, x + 2 * s, y, HEA[5])
end

-- quirk: summit flag in the snow
O.seg(c, 33, 13, 33, 6, WOOD[3]) O.seg(c, 34, 13, 34, 7, WOOD[2])
O.dots(c, { { 35, 6 }, { 36, 6 }, { 37, 6 }, { 38, 6 }, { 39, 7 }, { 35, 7 }, { 36, 7 }, { 37, 7 }, { 38, 7 }, { 35, 8 }, { 36, 8 }, { 37, 8 } }, FLAG[2])
O.dots(c, { { 35, 6 }, { 36, 6 }, { 37, 6 } }, FLAG[3]) O.dots(c, { { 35, 9 }, { 36, 8 }, { 38, 7 } }, FLAG[1])
O.dot(c, 33, 5, "#f0b440")

-- face on the lower band: raised brows, smug smile
c:eyeLocked(23, 44)
c:eyeLocked(36, 44)
O.dots(c, { { 22, 42 }, { 23, 41 }, { 24, 41 }, { 25, 41 }, { 26, 42 } }, STN[1]) O.dots(c, { { 37, 42 }, { 38, 41 }, { 39, 41 }, { 40, 41 }, { 41, 42 } }, STN[1])
c:cheek(20, 50) c:cheek(42, 50)
O.dots(c, { { 28, 50 }, { 29, 51 }, { 30, 51 }, { 31, 51 }, { 32, 51 }, { 33, 51 }, { 34, 50 }, { 35, 49 } }, P.ink)

O.done(c, "rr-highland-ring-yard")

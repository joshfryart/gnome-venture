-- Stone Sentry (mm-stone-sentry), yard sprite 64x64. Opus richness pass (art-2701-batch3/pals/opus3), built on opus2.
-- Richness: salt-and-pepper granite grain, a faint bedding line, rim light on the stone's upper-left and a cool
-- sky bounce on the lower-right, tufted moss with lit tips and a sprout, a puddle under the drips.
-- Rootwarden, uncommon, Mistmoor. "Stands perfectly still in the drizzle and insists it is a rock."
-- A chunky standing stone (cool moor-grey, chipped facets, a crack, pale lichen rosettes) with a moss
-- mantle over its flat top, a heavy brow ledge, a pebble nose and a tight "I am a rock" mouth.
-- Stubby arms pressed stiffly to its sides, two flat stone feet.
-- quirk: its own private drizzle cloud hanging over its head, dripping on the moss; look closer and one drop
-- has landed on the tip of its pebble nose.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("stone-sentry-yard", 64)

local STN  = { "#33344a", "#4d4f67", "#6b6d86", "#8d8fa5", "#b0b1c2", "#d2d2dc" }
local MOSS = { "#1f4a3c", "#2f6b46", "#4a8f4e", "#72b35a", "#a2d070", "#cfe896" }
local LICH = { "#9aa070", "#c4c88e", "#e2e2b0" }
local CLD  = { "#5d6b8c", "#8696b4", "#b2c0d6", "#d9e3ee" }
local DROP = { "#3a86b0", "#5fc4c8", "#b6f0e0" }

c:groundShadow(32, 58, 18, 3)


-- feet
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 56, 4.5, 2), STN, { R = 1, amb = .25, sep = STN[1], rim = true })
end

-- arms, stiff at the sides
for _, ax in ipairs({ 14.5, 48.5 }) do
  local a = c:ellipse(ax, 41, 2.5, 6)
  O.shade(c, a, STN, { R = 1, amb = .3, rim = true, bounce = "#6f7ea0", bmax = 2 })
end

-- the stone: slightly tapered slab with chipped corners
local body = c:poly{ { 21, 17 }, { 28, 15 }, { 38, 16 }, { 44, 18 }, { 47, 26 }, { 48, 40 }, { 47, 52 }, { 44, 55 },
                     { 20, 55 }, { 16, 51 }, { 16, 36 }, { 17, 24 } }
local bb = {}
body:each(function(x, y)
  if x + y > 84 and x > 40 then bb[K(x, y)] = -1 end -- a chipped facet on the right
  if y > 52 then bb[K(x, y)] = (bb[K(x, y)] or 0) - 1 end -- base darker (contact)
end)
local bI, bT = O.shade(c, body, STN, { R = 6, bias = bb, amb = .2, wrap = .35, sep = STN[1], rim = true, bounce = "#6f7ea0", bmax = 2 })
-- granite grain: pale feldspar flecks and dark mica specks; a faint bedding line across the lower stone
O.tex(c, bI, bT, STN, function(x, y, i)
  local h = H(x, y, 17)
  local face = x > 19 and x < 45 and y > 26 and y < 43
  if h > (face and .985 or .94) and i >= 2 and i <= 5 then return 1 end
  if h < (face and .01 or .04) and i >= 3 then return -1 end
  if y == math.floor(49 - (x - 16) * .12) and H(x, y, 18) > .25 and i >= 2 then return -1 end
end)
-- facet edge + crack
O.mark(c, { { 44, 40 }, { 43, 41 }, { 42, 42 }, { 41, 43 }, { 40, 44 }, { 39, 45 } }, STN[5])
O.mark(c, { { 23, 41 }, { 24, 42 }, { 24, 43 }, { 25, 44 }, { 25, 45 }, { 24, 46 }, { 26, 46 }, { 26, 47 } }, STN[2])
O.mark(c, { { 22, 41 }, { 23, 42 } }, STN[5])
-- lichen rosettes
for _, l in ipairs({ { 36, 48 }, { 20, 30 }, { 42, 27 } }) do
  local x, y = l[1], l[2]
  O.mark(c, { { x, y }, { x + 1, y }, { x, y + 1 }, { x - 1, y + 1 }, { x + 1, y + 1 } }, LICH[2])
  O.mark(c, { { x, y } }, LICH[3]) O.mark(c, { { x + 1, y + 1 } }, LICH[1])
end

-- moss mantle draped over the flat top, with drips down the sides
local moss = c:ellipse(32, 19, 15, 4)
moss:add(c:ellipse(21, 22, 3, 3)) moss:add(c:ellipse(43, 23, 2.5, 3.5)) moss:add(c:ellipse(30, 22, 2, 2.5))
local mb = {}
moss:each(function(x, y) if (x * 5 + y * 3) % 7 == 0 then mb[K(x, y)] = -1 end end)
local mI, mT = O.shade(c, moss, MOSS, { R = 3, bias = mb, amb = .25, wrap = .4, sep = MOSS[1], rim = true })
O.tex(c, mI, mT, MOSS, function(x, y, i) if H(x, y, 31) > .82 and i >= 3 and i <= 5 then return 1 end end) -- lit tuft tips
-- a sprout growing out of the moss
O.dots(c, { { 31, 13 }, { 31, 12 } }, MOSS[3]) O.dots(c, { { 30, 11 }, { 29, 11 } }, MOSS[5]) O.dots(c, { { 32, 11 }, { 33, 10 } }, MOSS[4])
O.dots(c, { { 25, 15 }, { 26, 14 }, { 34, 14 }, { 39, 15 } }, MOSS[5]) -- tufts

-- face: heavy brow ledge, locked eyes, pebble nose, tight mouth
for _, ex in ipairs({ 23, 36 }) do
  O.mark(c, { { ex - 1, 29 }, { ex, 28 }, { ex + 1, 28 }, { ex + 2, 28 }, { ex + 3, 28 }, { ex + 4, 28 }, { ex + 5, 29 } }, STN[6])
  O.mark(c, { { ex, 29 }, { ex + 1, 29 }, { ex + 2, 29 }, { ex + 3, 29 }, { ex + 4, 29 } }, STN[2])
  c:eyeLocked(ex, 30)
end
local nose = c:rect(30, 34, 33, 37)
O.shade(c, nose, STN, { R = 1, amb = .45, sep = STN[2] })
O.dots(c, { { 30, 34 }, { 31, 34 } }, STN[6])
-- the drop that landed on its nose tip
O.dot(c, 32, 37, DROP[3]) O.dot(c, 33, 37, DROP[2]) O.dot(c, 33, 38, DROP[1])
O.dots(c, { { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 } }, STN[1])
c:cheek(20, 37) c:cheek(42, 37)
O.dots(c, { { 28, 41 }, { 29, 41 }, { 30, 41 }, { 31, 41 }, { 32, 41 }, { 33, 41 }, { 34, 41 }, { 35, 41 } }, P.ink)
O.dots(c, { { 27, 40 }, { 36, 40 } }, STN[2])

-- quirk: private drizzle cloud + drops, parked over its right shoulder
local cl = O.unionCircles{ { 42, 8, 3.5, 3 }, { 47.5, 6.5, 4, 3.5 }, { 52, 8.5, 3, 2.5 } }
cl:add(c:rect(39, 8, 54, 10))
O.shade(c, cl, CLD, { R = 2, amb = .35, cuts = { .3, .55, .8 }, rim = true })
O.dots(c, { { 39, 10 }, { 40, 10 }, { 41, 10 }, { 42, 10 }, { 43, 10 }, { 44, 10 }, { 45, 10 }, { 46, 10 }, { 47, 10 }, { 48, 10 },
            { 49, 10 }, { 50, 10 }, { 51, 10 }, { 52, 10 }, { 53, 10 }, { 54, 10 } }, CLD[1])
for _, d in ipairs({ { 42, 13 }, { 47, 14 }, { 51, 12 } }) do
  O.dot(c, d[1], d[2], DROP[3]) O.dot(c, d[1], d[2] + 1, DROP[2]) O.dot(c, d[1], d[2] + 2, DROP[1])
end

-- puddle from the drizzle beside the right foot: flat water on the ground, no ink outline
O.done(c, "stone-sentry-yard", function(c)
  for x = 46, 53 do c:put(x, 58, (x < 49) and "#b6f0e0" or "#8bc4ea") end
  for x = 47, 54 do c:put(x, 59, (x > 51) and "#5f9ad0" or "#8bc4ea") end
end)

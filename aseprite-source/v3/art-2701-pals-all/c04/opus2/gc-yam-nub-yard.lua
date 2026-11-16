-- Yam Nub (gc-yam-nub), yard sprite 64x64. Opus second pass (art-2701-pals-all/c04/opus2), from the Haiku pass.
-- Brewroot, common, Great Canopy. "A knobbly root that giggles whenever it is dug up."
-- A plump, lumpy yam tuber half out of a dark soil mound: ruddy mauve-brown skin with knobs, eye-pits and
-- hair rootlets, a yam vine with two heart leaves on top, the face mid-giggle (open laughing mouth, cheeks).
-- Fixed from Haiku: the smooth brown blob read as a dumpling or mud pile; now the knobbly silhouette, root hairs
-- and the soil it is coming out of make it a root, and the soil is a cooler colour so the two never merge.
-- quirk: a little garden trowel stuck in the soil beside it (it has just been dug up, hence the giggling).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("gc-yam-nub-yard", 64)

local YAM  = { "#3a1e2a", "#5e3238", "#864a44", "#a86a52", "#c99070", "#e3b896" }
local SOIL = { "#231c26", "#3a2e36", "#54443e", "#6e5a4e", "#8a7460" }
local LEAF = { "#173a2c", "#1f5a3a", "#2f7a3e", "#4f9e46", "#82c25a", "#bde28a" }
local IRON = { "#4d4f67", "#8d8fa5", "#d2d2dc" }
local HAND = { "#5e3a24", "#8a5a2a", "#b07e38" }

-- trowel behind the mound (right)
local blade = c:poly{ { 50, 44 }, { 55, 44 }, { 54, 52 }, { 52.5, 55 }, { 51, 52 } }
O.shade(c, blade, IRON, { R = 1, amb = .35, cuts = { .45, .8 } })
O.flat(c, c:rect(52, 40, 53, 43), IRON[1], "neck")
local hdl = c:rect(51, 31, 54, 39)
O.shade(c, hdl, HAND, { R = 1, amb = .3, wrap = .4, cuts = { .4, .75 }, sep = HAND[1] })
O.dots(c, { { 52, 32 }, { 52, 33 } }, "#d4a852")

-- tuber: knobbly union
local tub = O.unionCircles{ { 31, 39, 14.5, 13 }, { 19, 33, 5, 5 }, { 26, 26.5, 6, 5 }, { 37.5, 28, 5.5, 4.5 }, { 44, 39, 4.5, 5 }, { 17, 44, 4, 4 } }
local bias = {}
local tI, tT = O.shade(c, tub, YAM, { R = 7, amb = .06, wrap = .25, rim = true, bounce = "#7a6a9a", bmax = 2 })
-- eye-pits and skin rings
O.tex(c, tI, tT, YAM, function(x, y, i)
  if H(x, y, 13) > .955 and i >= 3 then return -2 end
  if (y * 2 + x) % 13 == 0 and H(x, y, 4) > .55 and i >= 4 then return -1 end
end)
for _, p in ipairs({ { 21, 30 }, { 40, 27 }, { 45, 36 }, { 15, 43 } }) do
  O.mark(c, { { p[1], p[2] } }, YAM[2]) O.mark(c, { { p[1] - 1, p[2] - 1 } }, YAM[6])
end

-- hair rootlets (thin, outlined so they read)
for _, r in ipairs({ { { 13, 36 }, { 11, 35 }, { 10, 33 } }, { { 46, 32 }, { 48, 30 }, { 49, 30 } }, { { 48, 44 }, { 50, 45 } }, { { 13, 47 }, { 11, 48 } } }) do
  for _, p in ipairs(r) do O.dot(c, p[1], p[2], YAM[2]) end
end

-- vine and heart leaves
local vine = O.tube({ { 30, 23 }, { 30, 18 }, { 33, 15 }, { 34, 11 } }, function() return .8 end)
O.flat(c, vine, LEAF[3], "vine")
for _, L in ipairs({ { 27.5, 13, -1 }, { 38.5, 9.5, 1 } }) do
  local h = O.unionCircles{ { L[1] - 1.6, L[2] - 1, 2.6, 2.4 }, { L[1] + 1.6, L[2] - 1, 2.6, 2.4 } }
  h:add(c:poly{ { L[1] - 4, L[2] }, { L[1] + 4, L[2] }, { L[1], L[2] + 4.5 } })
  local lI, lT = O.shade(c, h, LEAF, { R = 2, amb = .25, wrap = .4, sep = LEAF[1] })
  O.mark(c, { { math.floor(L[1]), L[2] }, { math.floor(L[1]), L[2] + 1 }, { math.floor(L[1]), L[2] + 2 } }, LEAF[3])
end

-- soil mound over the bottom
local mound = c:ellipse(31, 56, 26, 5.5)
mound:add(O.unionCircles{ { 13, 53, 4, 3 }, { 47, 53, 5, 3 } })
mound:cut(c:rect(0, 60, 63, 63))
local sI, sT = O.shade(c, mound, SOIL, { R = 3, amb = .2, wrap = .4, sep = SOIL[1], cuts = { .25, .45, .65, .85 } })
O.tex(c, sI, sT, SOIL, function(x, y, i) local h = H(x, y, 21) if h > .9 then return 1 elseif h < .08 then return -1 end end)
O.dots(c, { { 20, 52 }, { 21, 52 }, { 40, 52 } }, SOIL[5])

-- face, mid-giggle
c:eyeLocked(23, 33)
c:eyeLocked(35, 33)
c:cheek(20, 40) c:cheek(41, 40)
O.dots(c, { { 28, 40 }, { 29, 40 }, { 30, 40 }, { 31, 40 }, { 32, 40 }, { 33, 40 }, { 34, 40 },
            { 28, 41 }, { 34, 41 }, { 29, 42 }, { 33, 42 }, { 30, 43 }, { 31, 43 }, { 32, 43 } }, P.ink)
O.dots(c, { { 29, 41 }, { 30, 41 }, { 31, 41 }, { 32, 41 }, { 33, 41 } }, "#5a1e2a")
O.dots(c, { { 30, 42 }, { 31, 42 }, { 32, 42 } }, "#e86a6a")

O.shift(c, 0, 1)
O.done(c, "gc-yam-nub-yard", function(c)
  -- giggle ticks (not outlined)
  for _, p in ipairs({ { 8, 26 }, { 9, 25 }, { 7, 30 }, { 8, 30 }, { 46, 22 }, { 47, 21 }, { 50, 24 }, { 51, 24 } }) do c:put(p[1], p[2], "#f5d0a0") end
end)

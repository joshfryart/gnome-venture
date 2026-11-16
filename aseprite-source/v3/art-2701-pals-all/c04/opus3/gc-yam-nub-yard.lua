-- Yam Nub (gc-yam-nub), yard sprite 64x64. Opus richness pass (c04/opus3), built on c04/opus2.
-- Richness pass: hue-shifted skin ramp (violet deep to peach light), curved growth rings following the lumps,
-- eye-pits with a lit lower lip, papery flecks, leaf veins, crumbly soil with lit clods and grey pebbles, a riveted
-- trowel with handle grain and soil on its tip. Closer look: a little nick where the trowel caught it, showing pale
-- flesh, and an earthworm poking out of the soil to see what is so funny.
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

local YAM  = { "#361a2e", "#5c2e3c", "#844644", "#a86a52", "#ca926e", "#e6bc94" }
local FLESH = { "#e8d8b8", "#f6ecd2" }
local WORM = { "#8a3a4a", "#c8606a", "#ec9a98" }
local PEB  = { "#5a5a6a", "#8a8a96", "#b8b8c0" }
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
O.mark(c, { { 53, 34 }, { 53, 35 }, { 52, 37 }, { 53, 38 } }, HAND[1]) -- handle grain
O.mark(c, { { 52, 41 } }, IRON[3]) -- rivet
O.mark(c, { { 52, 52 }, { 53, 52 }, { 52, 53 }, { 53, 53 } }, SOIL[3]) -- soil on the blade tip

-- tuber: knobbly union
local tub = O.unionCircles{ { 31, 39, 14.5, 13 }, { 19, 33, 5, 5 }, { 26, 26.5, 6, 5 }, { 37.5, 28, 5.5, 4.5 }, { 44, 39, 4.5, 5 }, { 17, 44, 4, 4 } }
local bias = {}
local tI, tT = O.shade(c, tub, YAM, { R = 7, amb = .06, wrap = .25, rim = true, bounce = "#7a6a9a", bmax = 2 })
-- eye-pits and skin rings
O.tex(c, tI, tT, YAM, function(x, y, i)
  local face = y >= 31 and y <= 44 and x >= 19 and x <= 43
  if not face then
    -- curved growth rings, bowed around the body centre
    local r = (y - 39) + ((x - 31) / 9) ^ 2
    if math.floor(r) % 5 == 0 and H(x, y, 4) > .3 and i >= 3 then return -1 end
    if H(x, y, 13) > .955 and i >= 3 then return -2 end
  end
  if H(x, y, 17) > .965 and i >= 2 and i <= 4 then return 1 end -- papery flecks
end)
-- eye-pits: dark pit, lit lower lip
for _, p in ipairs({ { 21, 29 }, { 40, 27 }, { 45, 36 }, { 15, 43 }, { 27, 24 }, { 38, 47 } }) do
  O.mark(c, { { p[1], p[2] }, { p[1] + 1, p[2] } }, YAM[1]) O.mark(c, { { p[1], p[2] + 1 }, { p[1] + 1, p[2] + 1 } }, YAM[6])
end
-- closer look: the trowel's nick, pale flesh showing
O.mark(c, { { 44, 42 }, { 45, 42 }, { 44, 43 } }, FLESH[2]) O.mark(c, { { 45, 43 }, { 43, 43 } }, FLESH[1])
O.mark(c, { { 46, 42 }, { 46, 43 }, { 44, 44 }, { 45, 44 } }, YAM[2])

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
  local mx = math.floor(L[1])
  O.mark(c, { { mx, L[2] - 2 }, { mx, L[2] - 1 }, { mx, L[2] }, { mx, L[2] + 1 }, { mx, L[2] + 2 } }, LEAF[3])
  O.mark(c, { { mx - 1, L[2] - 1 }, { mx - 2, L[2] - 2 }, { mx + 1, L[2] - 1 }, { mx + 2, L[2] - 2 } }, LEAF[3]) -- side veins
end

-- soil mound over the bottom
local mound = c:ellipse(31, 56, 26, 5.5)
mound:add(O.unionCircles{ { 13, 53, 4, 3 }, { 47, 53, 5, 3 } })
mound:cut(c:rect(0, 60, 63, 63))
local sI, sT = O.shade(c, mound, SOIL, { R = 3, amb = .2, wrap = .4, sep = SOIL[1], cuts = { .25, .45, .65, .85 } })
O.tex(c, sI, sT, SOIL, function(x, y, i) local h = H(x, y, 21) if h > .9 then return 1 elseif h < .08 then return -1 end end)
-- lit clods (lit top, shaded underside)
for _, p in ipairs({ { 20, 52 }, { 40, 52 }, { 9, 56 }, { 30, 57 }, { 51, 55 } }) do
  O.mark(c, { { p[1], p[2] }, { p[1] + 1, p[2] } }, SOIL[5]) O.mark(c, { { p[1], p[2] + 1 }, { p[1] + 1, p[2] + 1 } }, SOIL[2])
end
-- grey pebbles
for _, p in ipairs({ { 24, 56 }, { 45, 58 }, { 14, 58 } }) do
  O.mark(c, { { p[1], p[2] } }, PEB[3]) O.mark(c, { { p[1] + 1, p[2] } }, PEB[2]) O.mark(c, { { p[1], p[2] + 1 }, { p[1] + 1, p[2] + 1 } }, PEB[1])
end
-- closer look: an earthworm poking out of the soil (left), curious
local worm = O.tube({ { 7, 54 }, { 6, 50 }, { 7, 47 }, { 9, 46 } }, function(t) return 1.1 end)
local wI, wT = O.shade(c, worm, WORM, { R = 1, amb = .35, wrap = .4, cuts = { .35, .7 }, sep = WORM[1] })
O.tex(c, wI, wT, WORM, function(x, y, i) if y % 2 == 0 and i >= 2 then return -1 end end) -- segments
O.dot(c, 9, 46, P.ink)

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

-- Slushbelly (bb-slushbelly), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Seedkeeper, common, Birchbramble. "Melts a little every time somebody is looking."
-- A pale-blue slush blob slumping into its own meltwater puddle: granular icy body with glints, a round snowball
-- on top (round knob) with a sunflower seed pressed into it (it keeps one safe). Shy face: big locked eyes glancing
-- sideways at you, a wobbly nervous mouth.
-- Fix vs Haiku: the eye-drip was 1 px and lost at 25%; the melt is now drips that bulge out past the
-- silhouette (so the outline carries them) plus a falling drop over the puddle; granular slush texture,
-- 6-tone ramps, a seed that reads as a seed.
-- quirk: it is melting because you are looking: two fat drips run off its side and a drop falls into the puddle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-slushbelly-yard", 64)

local SL   = { "#3e5a98", "#5a82c0", "#7ea8dc", "#a6caec", "#cae2f4", "#e6f2f8" }
local SNOW = { "#5e6c98", "#8a9cc0", "#b4c4da", "#d6e2ec", "#ecf2f4" }
local PUD  = { "#24587a", "#3a7ea2", "#5aa6c2", "#8acad8", "#bce6ea" }
local SEED = { "#2a2430", "#4a4250", "#8a8490", "#c8c2c4" }

-- meltwater puddle
local pud = c:ellipse(32, 53, 25, 4)
pud:add(c:ellipse(52, 55, 6, 2))
local pb = {}
pud:each(function(x, y) pb[K(x, y)] = 0 end)
local pI, pT = O.shade(c, pud, PUD, { R = 2, amb = .35, wrap = .4, cuts = { .25, .45, .65, .84 } })
O.tex(c, pI, pT, PUD, function(x, y, i) if y == 54 and (x % 9 < 4) then return 1 end end) -- ripple lines

-- body: blob slumping outward at the base
local body = c:ellipse(32, 35, 15, 13.5)
body:add(c:poly{ { 17, 40 }, { 47, 40 }, { 51, 51 }, { 13, 51 } })
body:add(c:ellipse(32, 49, 19, 3))
-- side drips that bulge past the silhouette
body:add(c:ellipse(48, 45, 2.5, 3))
body:add(c:rect(47, 39, 49, 43))
body:add(c:ellipse(15, 46.5, 2, 2.5))
local bb = {}
body:each(function(x, y) if y > 49 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, SL, { sphere = { 26, 28, 22 }, bias = bb, amb = .3, wrap = .4, rim = true, bounce = "#8a94cc", bmax = 2, sep = SL[1] })
-- granular slush: icy grains, lighter and darker
O.tex(c, bI, bT, SL, function(x, y, i)
  local h = H(x, y, 7)
  if h > .95 and i <= 5 then return 1 elseif h < .035 and i >= 3 then return -1 end
end)
-- glints
O.dots(c, { { 22, 26 }, { 23, 26 }, { 22, 27 }, { 26, 24 } }, SL[6])
-- drip highlights
O.dots(c, { { 47, 41 }, { 47, 42 }, { 47, 43 }, { 47, 44 } }, SL[6]) O.dots(c, { { 14, 45 }, { 14, 46 } }, SL[6])

-- snowball knob with a sunflower seed pressed into it
local sb = c:ellipse(32, 20, 6, 5)
local sI, sT = O.shade(c, sb, SNOW, { sphere = { 30, 18, 7 }, amb = .3, wrap = .35, sep = SNOW[1], rim = true, cuts = { .25, .45, .65, .84 } })
O.tex(c, sI, sT, SNOW, function(x, y, i) if H(x, y, 3) > .85 and i >= 2 then return -1 end end)
local seed = c:poly{ { 34, 13 }, { 37, 12 }, { 40, 13 }, { 39, 15 }, { 35, 17 } }
O.flat(c, seed, SEED[2], "seed")
O.dots(c, { { 36, 13 }, { 37, 13 }, { 38, 13 } }, SEED[4]) O.dots(c, { { 36, 15 }, { 37, 14 } }, SEED[3]) -- stripes
O.dots(c, { { 35, 16 }, { 38, 15 } }, SEED[1])

-- face: big eyes glancing sideways, nervous wobbly mouth
c:eyeLocked(23, 31)
c:eyeLocked(35, 31)
-- pupils pushed to the left (looking at you, shyly): repaint the inner 3x3
for _, ex in ipairs({ 23, 35 }) do
  for j = 1, 3 do for i = 1, 3 do c:put(ex + i, 31 + j, P.cream, { r = { name = "eye" } }) end end
  for j = 1, 3 do for i = 1, 2 do c:put(ex + i, 31 + j, P.ink, { r = { name = "eye" } }) end end
  c:put(ex + 1, 32, "#f4ecd8", { r = { name = "eye" } })
end
-- worried brows
O.dots(c, { { 25, 29 }, { 26, 28 }, { 27, 28 } }, SL[1]) O.dots(c, { { 36, 28 }, { 37, 28 }, { 38, 29 } }, SL[1])
O.dots(c, { { 20, 38 }, { 21, 38 } }, "#f5809f") O.dots(c, { { 41, 38 }, { 42, 38 } }, "#f5809f")
O.dots(c, { { 27, 41 }, { 28, 40 }, { 29, 41 }, { 30, 40 }, { 31, 41 }, { 32, 40 }, { 33, 41 }, { 34, 40 }, { 35, 41 } }, P.ink)

-- the falling drop (outlined part)
local drop = c:ellipse(55, 47, 1.2, 1.5)
drop:add(c:rect(55, 45, 55, 45))
O.flat(c, drop, SL[4], "drop")
O.dot(c, 55, 46, SL[6]) O.dot(c, 56, 48, SL[3])

O.shift(c, 0, -3)
O.done(c, "bb-slushbelly-yard")

-- Glimmer Frog (rr-glimmer-frog), yard sprite 64x64. Opus richness pass (art-2701-batch3/pals/opus3), built on opus2.
-- Richness: dark freckles and pale granular bumps in the skin, rim light on the head and back, a cool teal
-- bounce under the body and thighs, granular belly, gloss on the eye domes.
-- Wayfinder, rare, Rainroot. "Glows a little when it rains and croaks a tune about llamas."
-- A plump jungle tree frog, sitting: jade-green skin, big eye domes on top of the head with locked
-- eyes, folded hind legs, round toe pads, a pale belly and glowing gold spots along its back.
-- quirk: mid-croak, its throat sac blown up into a glowing gold bubble under its grin; look closer and one
-- of the glowing spots on its thigh is shaped like a tiny llama (it croaks a tune about llamas).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local function skin(c, I, T, R, seed) -- freckles and granular bumps
  O.tex(c, I, T, R, function(x, y, i)
    local h = H(x, y, seed)
    if h > .93 and i >= 3 then return -1 end
    if h < .05 and i >= 3 and i <= 5 then return 1 end
  end)
end
local BNC = "#2a7a74"
local c = O.canvas("glimmer-frog-yard", 64)

local FROG = { "#173a38", "#1f5a46", "#2b8450", "#47ab58", "#7fcd66", "#bce88c" }
local BELY = { "#6f9a68", "#9cc283", "#c4dea0", "#e2f0bf" }
local GLOW = { "#c98322", "#f5b82e", "#ffe38a", "#fff4c8" }
local PAD  = { "#2b8450", "#7fcd66", "#bce88c" }

c:groundShadow(32, 57, 20, 3)

-- hind legs folded at the sides
for _, s in ipairs({ { 15, 47, -1 }, { 49, 47, 1 } }) do
  local thigh = c:ellipse(s[1], s[2], 6.5, 6)
  local tI, tT = O.shade(c, thigh, FROG, { sphere = { s[1] - 2, s[2] - 3, 8 }, amb = .2, wrap = .35, rim = true, bounce = BNC, bmax = 2 })
  skin(c, tI, tT, FROG, 40 + s[1])
  -- long hind foot along the ground with 3 toe pads
  local fx = s[1] + s[3] * 4
  local foot = c:ellipse(fx, 55, 5, 1.5)
  O.shade(c, foot, FROG, { R = 1, amb = .3, sep = FROG[1] })
  for i = 0, 2 do
    local tx = fx + s[3] * (3 + i * 2) - s[3] * 2
    O.dots(c, { { tx, 56 } }, PAD[3])
  end
end

-- body
local body = c:ellipse(32, 44, 15, 12)
local bI, bT = O.shade(c, body, FROG, { sphere = { 27, 38, 18 }, amb = .2, wrap = .35, sep = FROG[1], bounce = BNC, bmax = 2 })
skin(c, bI, bT, FROG, 3)
-- head, wide and flat
local head = c:ellipse(32, 32, 17, 9)
-- eye domes
local domeL, domeR = c:ellipse(21.5, 24, 6, 5.5), c:ellipse(42.5, 24, 6, 5.5)
local hd = head:copy():add(domeL):add(domeR)
local hI, hT = O.shade(c, hd, FROG, { sphere = { 26, 24, 20 }, amb = .22, wrap = .35, rim = true })
skin(c, hI, hT, FROG, 7)
-- crease under each dome
O.mark(c, { { 16, 28 }, { 17, 29 }, { 18, 29 }, { 25, 29 }, { 26, 28 } }, FROG[3])
O.mark(c, { { 38, 28 }, { 39, 29 }, { 46, 29 }, { 47, 29 }, { 48, 28 } }, FROG[2])

-- pale belly
local bel = c:ellipse(32, 48, 9, 7)
bel:cut(c:rect(0, 56, 63, 63))
local eI, eT = O.shade(c, bel, BELY, { R = 3, amb = .4, cuts = { .3, .55, .8 } })
O.tex(c, eI, eT, BELY, function(x, y, i) if H(x, y, 19) > .86 and i >= 2 then return -1 end end) -- granular belly

-- quirk: glowing throat sac
local sac = c:ellipse(32, 40.5, 7, 4.5)
O.shade(c, sac, GLOW, { sphere = { 30, 38, 7 }, amb = .45, wrap = .5, cuts = { .3, .55, .8 } })
O.dots(c, { { 29, 38 }, { 30, 38 } }, "#fff4d6")

-- front legs + toe pads
for _, s in ipairs({ { 23, -1 }, { 41, 1 } }) do
  local arm, an = O.tube({ { s[1], 44 }, { s[1] + s[2], 48 }, { s[1] + s[2] * 2, 51 }, { s[1] + s[2] * 2, 54 } }, function(t) return 1.8 end)
  O.shadeN(c, arm, an, FROG, { amb = .3, sep = FROG[1] })
  local px = s[1] + s[2] * 2
  for _, d in ipairs({ -2, 0, 2 }) do
    O.flat(c, c:rect(px + d, 55, px + d, 55), PAD[2], "pad")
  end
  O.dot(c, px - 2, 55, PAD[3])
end

-- glow spots on the back and head
for _, g in ipairs({ { 13, 39 }, { 18, 45 }, { 32, 26 }, { 27, 24 }, { 37, 24 } }) do
  local x, y = g[1], g[2]
  O.mark(c, { { x, y }, { x + 1, y }, { x, y + 1 }, { x + 1, y + 1 } }, GLOW[2])
  O.mark(c, { { x, y } }, GLOW[4])
end

-- the llama-shaped glow spot on the right thigh
do
  local lx, ly = 49, 43
  local L = { ".#...", "##...", ".#..#", ".####", ".####", ".#..#" }
  for j, row in ipairs(L) do for i = 1, 5 do
    if row:sub(i, i) == "#" then O.mark(c, { { lx + i - 1, ly + j - 1 } }, (j <= 2) and GLOW[3] or GLOW[2]) end
  end end
  O.mark(c, { { lx + 1, ly + 3 } }, GLOW[3])
end

-- face
c:eyeLocked(19, 22)
c:eyeLocked(40, 22)
-- nostrils
O.dots(c, { { 29, 29 }, { 35, 29 } }, FROG[1])
O.dots(c, { { 29, 28 }, { 35, 28 } }, FROG[6])
c:cheek(15, 30) c:cheek(47, 30)
-- wide frog grin over the sac
O.dots(c, { { 17, 31 }, { 18, 32 }, { 19, 32 }, { 20, 33 }, { 21, 33 }, { 22, 34 }, { 23, 34 }, { 24, 34 }, { 25, 34 }, { 26, 34 }, { 27, 34 }, { 28, 34 }, { 29, 34 }, { 30, 34 }, { 31, 34 }, { 32, 34 }, { 33, 34 }, { 34, 34 }, { 35, 34 }, { 36, 34 }, { 37, 34 }, { 38, 34 }, { 39, 34 }, { 40, 34 }, { 41, 34 }, { 42, 34 }, { 43, 33 }, { 44, 33 }, { 45, 32 }, { 46, 32 }, { 47, 31 } }, P.ink)
O.dots(c, { { 30, 35 }, { 31, 35 }, { 32, 35 }, { 33, 35 }, { 34, 35 } }, FROG[2])

-- the glow: three cream motes drifting off its back (not outlined)
O.shift(c, 0, -3)
O.done(c, "glimmer-frog-yard", function(c)
  for _, m in ipairs({ { 8, 30 }, { 56, 27 }, { 54, 34 } }) do c:put(m[1], m[2], GLOW[3]) end
  c:put(8, 29, GLOW[4])
end)

-- Drum Tap (gc-drum-tap), yard sprite 64x64. Opus second pass (art-2701-pals-all/c04/opus2), from the Haiku pass.
-- Bloomcaller, common, Great Canopy. "Taps a rhythm on the pavilion and gets the rain to join in."
-- A goblet hand drum: pale goatskin head, a rope ring under the rim, the face on the round red-wood bowl,
-- zigzag rope lacing round the lower bowl down to a waist ring, a flared foot with carved notches, and one little
-- arm tapping the skin (motion ticks).
-- Fixed from Haiku: the flat red box with gold knobs read as a toy chest or cake; now the goblet silhouette,
-- the skin head and the lacing say "drum", and the shading is round instead of flat.
-- quirk: a rain drop joins in, bouncing off the drum head with a little splash crown.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("gc-drum-tap-yard", 64)

local WOOD = { "#3e1a22", "#6e2a2a", "#9e3e32", "#c85a3a", "#e88a52", "#f5b77a" }
local SKIN = { "#8a6a4a", "#b8956a", "#dcc094", "#f0dcb4", "#f8ecd0" }
local ROPE = { "#7a5a3a", "#c9a46a", "#ecd8a8" }
local DROP = { "#2f8a9a", "#5fc4c8", "#b6f0e0" }

c:groundShadow(32, 58, 17, 2.5)

-- goblet body: half width per row
local CX = 32
local function hw(y)
  if y <= 32 then local t = (y - 18) / 14 return 16.5 - 1.5 * t * t * 0 - (t > .6 and (t - .6) * 6 or 0) end
  if y <= 46 then local t = (y - 32) / 14 return 14.1 - 7.6 * math.sin(t * math.pi / 2) end
  local t = (y - 46) / 10 return 6.5 + 5 * t ^ 1.3
end
local body, bn = HP.mask(), {}
for y = 18, 56 do
  local w = hw(y)
  for x = math.floor(CX - w), math.ceil(CX + w) - 1 do
    local nx = (x + .5 - CX) / w
    if math.abs(nx) <= 1 then
      body:set(x, y)
      local ny = (y > 46) and .25 or ((y > 32) and -.1 or .05)
      local z = math.sqrt(math.max(.02, 1 - nx * nx))
      local l = math.sqrt(nx * nx + ny * ny + z * z)
      bn[K(x, y)] = { nx / l, ny / l, z / l }
    end
  end
end
local bI, bT = O.shadeN(c, body, bn, WOOD, { amb = .15, wrap = .4, rim = true, bounce = "#7a5a9a", bmax = 2 })
O.tex(c, bI, bT, WOOD, function(x, y, i) if (x * 3 + y) % 11 == 0 and H(x, y, 3) > .6 and i >= 3 then return -1 end end) -- wood grain

-- foot: darker band with carved notches
for y = 50, 56 do for x = 0, 63 do if body:has(x, y) then
  local i = bI[K(x, y)]
  c.pix[y * 64 + x] = WOOD[math.max(1, i - 1)]:lower()
end end end
for x = 22, 42, 4 do O.mark(c, { { x, 52 }, { x + 1, 52 }, { x, 53 } }, WOOD[1]) end
O.mark(c, (function() local t = {} for x = 20, 44 do t[#t+1] = { x, 50 } end return t end)(), WOOD[1])

-- rope rings and zigzag lacing
local function ring(y, x0, x1)
  for x = x0, x1 do
    if body:has(x, y) then O.mark(c, { { x, y } }, (x % 3 == 0) and ROPE[1] or ROPE[2]) end
    if body:has(x, y + 1) then O.mark(c, { { x, y + 1 } }, (x % 3 == 1) and ROPE[1] or ROPE[3]) end
  end
end
ring(19, 0, 63)
ring(44, 0, 63)
for k = 0, 9 do
  local x0 = 17 + k * 3
  for s = 0, 8 do
    local y = 35 + s
    local x = x0 + ((k % 2 == 0) and math.floor(s / 3) or -math.floor(s / 3)) + (k % 2 == 1 and 3 or 0)
    if body:has(x, y) then O.mark(c, { { x, y } }, (s % 2 == 0) and ROPE[3] or ROPE[2]) end
  end
end
ring(34, 0, 63)

-- skin head
local head = c:ellipse(CX, 17, 17, 3.6)
local hv = {}
head:each(function(x, y) hv[K(x, y)] = .55 + (16 - y) * .08 - (x - CX) * .012 end)
X.tone(c, head, hv, SKIN, { cuts = { .25, .4, .55, .75 } })
O.dots(c, { { 22, 15 }, { 23, 15 }, { 24, 15 } }, SKIN[5])

-- the tapping arm on the left
local arm, an = O.tube({ { 17, 28 }, { 11, 26 }, { 9, 17 }, { 14, 9 } }, function(t) return 1.7 end)
O.shadeN(c, arm, an, WOOD, { amb = .3, wrap = .4, sep = WOOD[1] })
O.shade(c, c:ellipse(16, 8.5, 2.2, 1.8), WOOD, { R = 1, amb = .4, sep = WOOD[1] })

-- quirk: a rain drop bouncing off the skin, with a splash crown
local drop = c:ellipse(44, 7, 1.6, 2.2) drop:add(c:rect(44, 3, 44, 5))
O.shade(c, drop, DROP, { sphere = { 43, 6, 3 }, amb = .35, cuts = { .45, .8 } })
O.dots(c, { { 40, 13 }, { 39, 12 }, { 48, 13 }, { 49, 12 }, { 44, 12 } }, DROP[2])

-- face
c:eyeLocked(22, 23)
c:eyeLocked(37, 23)
c:cheek(19, 29) c:cheek(43, 29)
O.dots(c, { { 29, 29 }, { 30, 30 }, { 31, 30 }, { 32, 30 }, { 33, 30 }, { 34, 30 }, { 35, 29 } }, P.ink)
O.dots(c, { { 31, 31 }, { 32, 31 }, { 33, 31 } }, "#c8404a")

O.shift(c, 0, 0)
O.done(c, "gc-drum-tap-yard", function(c)
  -- tap ticks by the hand (not outlined)
  for _, p in ipairs({ { 19, 11 }, { 20, 12 }, { 22, 10 }, { 23, 10 }, { 12, 6 }, { 11, 5 } }) do c:put(p[1], p[2] + 1, "#f5d0a0") end
end)

-- Lotus Lump (mt-lotus-lump), yard sprite 64x64. Opus richness pass (art-2701-pals-all/c07/opus3), built on opus2.
-- opus3: fine petal veins fanning up the bud and petals, a flushed deeper tip, rain beads on the pad (lit top, dark
-- foot), a curled-up back pad edge, splash crowns on the water; closer look: a raindrop balanced on the bud tip and a
-- baby bud poking out of the canal beside the pad.
-- Monsoontangle, common, bloomcaller. "Floats on the canal and sleeps through the whole downpour."
-- A plump lotus bud (pale cream-pink base flushing to deep pink at the pointed tip) with two cupped front petals
-- and two back petals fanning out, nested on a round lily pad with a notch and radial veins, floating on a ring
-- of ripples. Rain dashes fall around it.
-- Haiku fixes: the spiky crown became a real bud with layered petals; the lids now droop at the corners and
-- sit heavy over the eyes so it reads as asleep, not cross; the pad is round with a notch and veins.
-- quirk: a sleep bubble blown from its nose.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mt-lotus-lump-yard", 64)

local PET  = { "#7d2c5e", "#a83a72", "#d45c8e", "#f088a8", "#ffb4c8", "#ffe0e6" }
local PALE = { "#c47a92", "#e6a2b4", "#f8c8d0", "#fff0ea" }
local PAD  = { "#1f4a44", "#24544a", "#3f9150", "#62b058", "#9ad06a", "#c4e07a" }
local SEA  = { "#3a86b0", "#5fc4c8", "#b6f0e0" }
local SKY  = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }

-- water ripple ring (flat) under the pad
local rip = c:ellipse(32, 55, 25, 4.5) rip:cut(c:ellipse(32, 54.5, 23, 3.5))
O.flat(c, rip, SEA[2], "ripple")
-- lily pad with a notch toward the front-right
local pad = c:ellipse(32, 51, 22, 6.5)
pad:cut(c:poly{ { 33, 51 }, { 46, 58 }, { 52, 58 } })
local pv = {}
pad:each(function(x, y)
  local a = math.atan(y - 51, (x - 32) / 3.4)
  if math.abs(math.sin(a * 5)) < .12 then pv[K(x, y)] = 1 end
end)
O.shade(c, pad, PAD, { R = 3, amb = .3, wrap = .45, bias = pv, sep = PAD[1], rim = true })
O.dots(c, { { 13, 49 }, { 14, 48 }, { 15, 48 } }, PAD[6])
for x = 18, 46 do if pad:has(x, 45) and not pad:has(x, 44) then O.dot(c, x, 45, (x % 5 == 0) and PAD[6] or PAD[5]) end end -- curled back edge
-- rain beads on the pad
for _, b in ipairs({ { 15, 51 }, { 47, 50 }, { 20, 54 }, { 43, 53 } }) do
  O.dot(c, b[1], b[2], "#d8f4ee") O.dot(c, b[1], b[2] + 1, PAD[2]) O.dot(c, b[1] + 1, b[2], "#8bc4ea")
end

-- back petals fanning out
for _, s in ipairs({ { -1 }, { 1 } }) do
  local d = s[1]
  local bp = c:poly{ { 32 + d * 6, 47 }, { 32 + d * 15, 43 }, { 32 + d * 18, 36 }, { 32 + d * 18, 27 }, { 32 + d * 12, 32 }, { 32 + d * 8, 38 } }
  local pI, pT = O.shade(c, bp, PET, { R = 2, amb = .26, wrap = .4, sep = PET[1], rim = true })
  O.tex(c, pI, pT, PET, function(x, y, i) if (x + y * d) % 3 == 0 and H(x, y, 2) > .45 and i >= 3 then return -1 end end) -- veins
end
-- bud body: round with a pointed tip; pale at the base, deep pink at the tip
local bud = c:ellipse(32, 37, 13, 12)
bud:add(c:poly{ { 24, 30 }, { 31, 17 }, { 33, 17 }, { 40, 30 } })
bud:add(c:ellipse(32, 27, 6, 5))
local bb = {}
bud:each(function(x, y) if y < 23 then bb[K(x, y)] = -2 elseif y < 27 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, bud, PET, { sphere = { 27, 30, 20 }, amb = .34, wrap = .45, bias = bb, sep = PET[1], rim = true, bounce = "#8a6fd0", bmax = 2 })
-- fine veins fanning up toward the tip
O.tex(c, bI, bT, PET, function(x, y, i)
  local face = x >= 23 and x <= 41 and y >= 29 and y <= 42
  if face or y > 47 then return end
  local a = math.atan(x - 32, 50 - y)
  if math.floor(a * 14 + .5) % 2 == 0 and math.abs(a * 14 - math.floor(a * 14 + .5)) < .14 and i >= 3 then return -1 end
end)
-- petal seam lines up the bud
O.dots(c, { { 32, 21 }, { 31, 23 }, { 31, 24 }, { 30, 26 } }, PET[2])
O.dots(c, { { 33, 22 }, { 34, 24 }, { 35, 26 } }, PET[3])
-- front cupped petals (pale, wrapping the base)
for _, d in ipairs({ -1, 1 }) do
  local fp = c:poly{ { 32 + d * 2, 50 }, { 32 + d * 12, 49 }, { 32 + d * 15, 44 }, { 32 + d * 16, 37 }, { 32 + d * 11, 42 }, { 32 + d * 5, 46 } }
  local fb = {} fp:each(function(x, y) if y > 46 then fb[K(x, y)] = 1 end end)
  local fI, fT = O.shade(c, fp, PET, { R = 2, amb = .4, wrap = .45, bias = fb, sep = PET[1], rim = true })
  O.tex(c, fI, fT, PET, function(x, y, i) if (x * d + y) % 3 == 0 and y < 47 and H(x, y, 5) > .4 and i >= 4 then return -1 end end)
  O.dots(c, { { 32 + d * 6, 48 }, { 32 + d * 7, 48 }, { 32 + d * 8, 48 } }, PALE[4]) -- pale base
end

-- face: eyes under heavy, drooping lids (asleep)
for _, ex in ipairs({ 25, 35 }) do
  c:eyeLocked(ex, 31)
  for i = 0, 4 do for j = 0, 2 do c:put(ex + i, 31 + j, PET[3]) end end
  O.dots(c, { { ex, 33 }, { ex + 1, 34 }, { ex + 2, 34 }, { ex + 3, 34 }, { ex + 4, 33 } }, "#2b1c26")
  O.dots(c, { { ex, 34 }, { ex + 4, 34 } }, PET[4]) O.dots(c, { { ex - 1, 34 }, { ex + 5, 34 } }, "#2b1c26") -- lashes
  O.dots(c, { { ex + 1, 31 }, { ex + 2, 31 } }, PET[5]) -- lid sheen
end
c:cheek(21, 37) c:cheek(40, 37)
-- small sleepy mouth
O.dots(c, { { 28, 40 }, { 29, 40 } }, "#5a1e3a")

-- quirk: a sleep bubble blown from its nose
local bub = c:ellipse(36, 40.5, 3, 3)
O.flat(c, bub, SKY[3], "bubble")
c:ellipse(36, 40.5, 3, 3):cut(c:ellipse(36, 40.5, 2, 2)):each(function(x, y) c:put(x, y, SKY[2], { r = { name = "bubble" } }) end)
O.dots(c, { { 35, 39 }, { 34, 40 } }, SKY[4]) O.dot(c, 38, 42, SKY[1])
-- closer look: a raindrop balanced on the bud tip
O.flat(c, c:rect(31, 14, 32, 16), SKY[2], "drop") O.dot(c, 31, 15, SKY[4]) O.dot(c, 32, 16, SKY[1]) O.dot(c, 31, 13, SKY[2])
-- closer look: a baby bud poking out of the canal
local bab = c:poly{ { 55, 51 }, { 57, 45 }, { 58, 45 }, { 60, 51 } }
O.shade(c, bab, PET, { R = 1, amb = .35, sep = PET[1], cuts = O.CUTS })
O.dots(c, { { 57, 52 }, { 58, 52 } }, PAD[3]) O.dot(c, 57, 46, PET[6])

O.done(c, "mt-lotus-lump-yard", function(c)
  -- downpour dashes (un-outlined)
  -- splash crowns on the water
  for _, p in ipairs({ { 6, 56 }, { 58, 58 } }) do
    for _, q in ipairs({ { 0, 0 }, { -1, -1 }, { 1, -1 }, { -2, 0 }, { 2, 0 } }) do
      if not c:get(p[1] + q[1], p[2] + q[2]) then c:put(p[1] + q[1], p[2] + q[2], q[2] < 0 and SKY[4] or SKY[2], { r = { name = "splash" } }) end
    end
  end
  for _, p in ipairs({ { 8, 10 }, { 14, 18 }, { 20, 6 }, { 52, 8 }, { 57, 18 }, { 10, 30 }, { 54, 34 }, { 27, 4 }, { 40, 10 } }) do
    for k = 0, 2 do
      local x, y = p[1] - (k == 2 and 1 or 0), p[2] + k
      if not c:get(x, y) then c:put(x, y, SKY[k == 0 and 3 or 2], { r = { name = "rain" } }) end
    end
  end
end)

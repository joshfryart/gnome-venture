-- Sky Lantern (mt-sky-lantern), yard sprite 64x64. Opus second pass (art-2701-pals-all/c07/opus2), from the Haiku pass.
-- Monsoontangle, uncommon, rootwarden. "Drifts up at dusk and tells the rain to hurry along."
-- A rice-paper sky lantern: domed top, sides tapering to a bamboo hoop, glowing from inside (paper brightest in
-- the middle, deep ember at the edges), curved bamboo ribs, a little flame hanging on cross wires under the
-- hoop. Face on the paper with a raised brow and an open "hurry!" mouth.
-- Haiku fixes: the ribbon tails (read as legs) are gone; the shape is a real sky lantern (open bottom, hoop,
-- flame) instead of a capped festival lantern; the inner glow gives it a light source.
-- quirk: it is shooing a small grey rain cloud off to the right (speed lines behind the cloud, two drips).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mt-sky-lantern-yard", 64)

local PAP  = { "#7a2238", "#b52e3f", "#e0563a", "#f08a3e", "#fbb85a", "#ffe08e" }
local BAM  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local FLM  = { "#b52e3f", "#f08a3e", "#ffd45e", "#fff4d6" }
local CLD  = { "#5c5d78", "#7c7d96", "#a2a3b8", "#c8c8d8" }
local WIRE = "#6a4a40"

-- the flame on its wires (under the hoop)
O.dots(c, { { 21, 50 }, { 22, 51 }, { 23, 52 }, { 24, 53 }, { 25, 54 }, { 33, 50 }, { 32, 51 }, { 31, 52 }, { 30, 53 }, { 29, 54 } }, WIRE)
local fl = c:poly{ { 27, 51 }, { 29, 55 }, { 29, 58 }, { 27, 59 }, { 25, 58 }, { 25, 55 } }
O.flat(c, fl, FLM[2], "flame")
O.dots(c, { { 27, 54 }, { 26, 56 }, { 27, 56 }, { 28, 56 }, { 26, 57 }, { 27, 57 }, { 28, 57 } }, FLM[3])
O.dots(c, { { 27, 57 }, { 27, 56 } }, FLM[4]) O.dot(c, 27, 59, FLM[1])

-- paper body: dome + tapering sides
local body = c:ellipse(27, 18, 15, 12)
body:add(c:poly{ { 12, 18 }, { 42, 18 }, { 37, 49 }, { 17, 49 } })
body:add(c:ellipse(27, 30, 14, 12))
-- glow from inside: brightest centre-low (the flame), edges deep ember; a touch of upper-left sky light
local v = {}
body:each(function(x, y)
  local dx, dy = (x - 27) / 19, (y - 32) / 26
  local g = math.max(0, 1 - math.sqrt(dx * dx * 1.1 + dy * dy))
  v[K(x, y)] = math.min(1, .16 + g * 1.0 + math.max(0, -(dx + dy)) * .08)
end)
-- curved bamboo ribs (kept off the face)
local rb = {}
body:each(function(x, y)
  if x > 15 and x < 38 and y > 21 and y < 39 then return end
  local u = (x - 27) / (math.max(6, 15 - math.max(0, y - 30) * .25))
  for _, r in ipairs({ -.82, -.42, 0, .42, .82 }) do
    if math.abs(u - r) < .055 then rb[K(x, y)] = -1 end
  end
end)
local tok = { r = { name = "paper" } }
local bI = X.tone(c, body, v, PAP, { cuts = O.CUTS, bias = rb, tok = tok })
local bT = tok
-- paper fibre flecks (off the face)
O.tex(c, bI, bT, PAP, function(x, y, i) if not (x > 15 and x < 38 and y > 21 and y < 39) and H(x, y, 11) > .9 and i >= 3 then return -1 end end)
-- top vent knot
O.shade(c, c:rect(25, 5, 29, 7), BAM, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BAM[1] })
-- bamboo hoop at the open bottom
local hoop = c:ellipse(27, 49, 10.5, 2)
hoop:cut(c:ellipse(27, 48.5, 8.5, 1))
O.shade(c, hoop, BAM, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BAM[1], rim = true })
O.dots(c, { { 19, 48 }, { 20, 48 }, { 21, 48 } }, BAM[4])

-- face: determined brow, open "hurry!" mouth turned to the cloud
-- the paper round the eyes is held one tone under full glow so the cream discs keep their edge
for _, ex in ipairs({ 19, 30 }) do
  c:ellipse(ex + 2, 28, 4, 4):each(function(x, y) if c.pix[y * c.w + x] == PAP[6]:lower() then c:put(x, y, PAP[5], tok) end end)
  c:eyeLocked(ex, 26)
end
O.dots(c, { { 19, 24 }, { 20, 23 }, { 21, 23 }, { 22, 23 } }, PAP[2]) -- left brow
O.dots(c, { { 30, 22 }, { 31, 21 }, { 32, 21 }, { 33, 21 }, { 34, 22 } }, PAP[2]) -- right brow, raised high
c:cheek(16, 32) c:cheek(35, 32)
O.dots(c, { { 25, 33 }, { 26, 33 }, { 27, 33 }, { 28, 33 }, { 24, 34 }, { 29, 34 }, { 24, 35 }, { 29, 35 }, { 25, 36 }, { 26, 36 }, { 27, 36 }, { 28, 36 } }, "#3e1620")
O.dots(c, { { 25, 34 }, { 26, 34 }, { 27, 34 }, { 28, 34 } }, "#6e2038") O.dots(c, { { 25, 35 }, { 26, 35 }, { 27, 35 }, { 28, 35 } }, "#e8493b")

-- quirk: a small rain cloud being shooed off to the right
local cl = c:ellipse(51, 33, 6, 3.5)
cl:add(c:ellipse(48, 30.5, 3.5, 3)) cl:add(c:ellipse(53.5, 29.5, 3.5, 3.5))
cl:cut(c:rect(0, 36, 63, 63))
O.shade(c, cl, CLD, { R = 2, amb = .35, wrap = .45, cuts = { .3, .55, .8 }, sep = CLD[1], rim = true })
-- grumpy little cloud face is NOT added (one face per pal); two drips
O.dots(c, { { 48, 38 }, { 48, 39 } }, "#5f9ad0") O.dots(c, { { 54, 39 }, { 54, 40 } }, "#5f9ad0")

O.shift(c, -3, 0)
O.done(c, "mt-sky-lantern-yard", function(c)
  -- speed lines trailing the cloud (behind it, on the lantern side) and a warm ember below the flame
  for _, p in ipairs({ { 39, 29 }, { 40, 29 }, { 41, 29 }, { 38, 33 }, { 39, 33 }, { 40, 33 }, { 41, 33 }, { 40, 36 }, { 41, 36 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#fff4d6", { r = { name = "speed" } }) end
  end
  for _, p in ipairs({ { 21, 61 }, { 27, 61 } }) do if not c:get(p[1], p[2]) then c:put(p[1], p[2], "#ffd45e", { r = { name = "ember" } }) end end
end)

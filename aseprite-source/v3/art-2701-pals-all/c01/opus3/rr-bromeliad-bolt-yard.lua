-- Bromeliad Bolt (rr-bromeliad-bolt), yard sprite 64x64. Opus third pass (art-2701-pals-all/c01/opus3), richness
-- pass over opus2: leaf tips blush red (as real bromeliads do), dark-toothed spines along the leaf edges, lapped
-- sheath seams (dark edge, lit lip), wavy silver scurf bands across the urn kept off the face, root nubs with
-- bark lines, a drip running down the cup lip, a tadpole in the cup for the frog to stare at.
-- Thornblade, uncommon, Rainroot. "Keeps a cup of rain in its spiky crown and shares it with nobody."
-- The pal IS a bromeliad: a fat leaf-sheath urn (banded with silver scurf, like an Aechmea) with a crown of
-- stiff serrated leaves, a red heart of short bracts, and a cup of rainwater in the middle. Cross brows and a
-- clamped mouth: it is guarding the cup. Root nubs for feet.
-- Fixes: the Haiku body read as a tomato with grass; now body and crown are one plant, leaves are tapered
-- tubes with midribs and spines, the water cup is wide and glossy.
-- quirk: a tiny thirsty tree frog hangs on a leaf and eyes the water.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("rr-bromeliad-bolt-yard", 64)

local GRN  = { "#163a34", "#1f5a3e", "#2f7d44", "#4fa34e", "#86c862", "#c4e690" }
local RED  = { "#4a1428", "#7c1c34", "#b82c3c", "#e04848", "#f47c5c", "#fbb48a" }
local SEA  = { "#1d3f63", "#25628a", "#2f8fae", "#4fbcc4", "#8ee0d4", "#d2f6ea" }
local SILV = "#a8c8a0"
local FROG = { "#1f5a46", "#47ab58", "#9be070" }
local ROOT = { "#3a2228", "#5e3a2e", "#86563a" }

c:groundShadow(32, 57, 17, 3)
for _, fx in ipairs({ 24, 40 }) do
  O.shade(c, c:ellipse(fx, 54, 3.5, 2), { "#3a2228", "#5e3a2e", "#86563a", "#ad7a4c", "#d0a068", "#ecc890" }, { R = 1, amb = .25, rim = true })
  O.mark(c, { { fx - 1, 54 }, { fx + 1, 55 } }, "#5e3a2e") O.dot(c, fx + 2, 56, "#3a2228")

end

local function leaf(p, w, ramp, o)
  local m, n, T, S = O.tube(p, function(t) return w * (1 - t) ^ .8 + .4 end)
  local idx, tok = O.shadeN(c, m, n, ramp, { amb = .05, wrap = .25, sep = ramp[1], rim = true, name = o and o.name })
  -- midrib: one tone up along the centre line; spines: a lit tooth every few px on the outer edge
  O.tex(c, idx, tok, ramp, function(x, y, i)
    local s = S[K(x, y)] or 0
    if math.abs(s) < .25 and T[K(x, y)] < .85 then return 1 end
    if math.abs(s) > .8 and (x + y) % 4 == 0 then return (s > 0) and -2 or 2 end -- spines: lit teeth on top, dark below
    if (o and o.band) and math.floor(T[K(x, y)] * 9) % 3 == 1 and math.abs(s) < .8 and i <= 4 then return 1 end
  end)
  if o and o.tip then -- red blush toward the tip
    for k, i in pairs(idx) do
      local x, y = k % 1024 - 256, k // 1024 - 256
      if (T[k] or 0) > o.tip and c.own[y * c.w + x] == tok then c.pix[y * c.w + x] = RED[math.max(2, math.min(6, i))]:lower() end
    end
  end
  return m
end

-- back crown leaves (tall), then side leaves
leaf({ { 30, 30 }, { 29, 22 }, { 27, 14 }, { 25, 6 } }, 3.2, GRN, { band = true, tip = .84 })
leaf({ { 35, 30 }, { 37, 22 }, { 40, 14 }, { 43, 7 } }, 3.2, GRN, { band = true, tip = .84 })
leaf({ { 27, 31 }, { 22, 25 }, { 17, 20 }, { 11, 15 } }, 3.4, GRN, { band = true })
leaf({ { 37, 31 }, { 42, 25 }, { 47, 20 }, { 53, 16 } }, 3.4, GRN, { band = true, tip = .86 })
leaf({ { 26, 34 }, { 20, 32 }, { 14, 31 }, { 7, 29 } }, 3, GRN, { band = true, tip = .86 })
leaf({ { 38, 34 }, { 44, 32 }, { 50, 31 }, { 57, 29 } }, 3, GRN, { band = true, tip = .86 })

-- red heart bracts round the cup
leaf({ { 29, 31 }, { 25, 28 }, { 22, 26 }, { 19, 24 } }, 3, RED)
leaf({ { 35, 31 }, { 39, 28 }, { 42, 26 }, { 45, 24 } }, 3, RED)
leaf({ { 31, 30 }, { 30, 26 }, { 29, 23 }, { 28, 19 } }, 2.6, RED)
leaf({ { 33, 30 }, { 34, 26 }, { 35, 23 }, { 37, 19 } }, 2.6, RED)

-- the cup of rain
local cup = c:ellipse(32, 31, 8, 3)
O.shade(c, cup, RED, { R = 1, amb = .2, sep = RED[1] })
local water = c:ellipse(32, 30.5, 6.5, 2)
water:each(function(x, y)
  local col = (y <= 29) and SEA[2] or (y <= 30 and SEA[3] or SEA[4])
  if x > 35 and y <= 30 then col = SEA[1] end
  c:put(x, y, col, { r = { name = "water" } })
end)
O.dots(c, { { 28, 30 }, { 29, 30 } }, SEA[6]) O.dot(c, 30, 30, SEA[5]) O.dots(c, { { 33, 32 }, { 34, 32 } }, SEA[5])
O.dots(c, { { 33, 30 }, { 34, 30 } }, "#2b3a3a") O.dot(c, 35, 31, "#3a5050") -- tadpole

-- urn body: overlapping leaf sheaths
local body = c:ellipse(32, 43, 14, 11)
body:add(c:rect(22, 34, 42, 38)):add(c:ellipse(32, 34, 10, 1.5))
local bb = {}
body:each(function(x, y)
  -- sheath seams: each sheath edge is a curve, the pixel just right of a seam sits in shadow
  for _, sx in ipairs({ 22, 32, 42 }) do
    local seam = sx + (y - 44) * (sx - 32) / 22
    if math.abs(x - seam) < .6 and y > 35 then bb[K(x, y)] = -2 end
    if math.abs(x + 1 - seam) < .6 and y > 35 then bb[K(x, y)] = 1 end -- lit lip of the lapped sheath
  end
  if y > 51 then bb[K(x, y)] = (bb[K(x, y)] or 0) - 1 end
end)
local bI, bT = O.shade(c, body, GRN, { R = 6, bias = bb, amb = .1, wrap = .3, sep = GRN[1], rim = true, bounce = "#3f7a8a", bmax = 2 })
-- silver scurf bands across the sheaths (kept off the face)
O.tex(c, bI, bT, GRN, function(x, y, i)
  local face = x > 21 and x < 43 and y > 36 and y < 49
  if face then return end
  local w = (y + math.floor(1.6 * math.sin(x * .55) + .5)) % 5
  if w == 0 and y > 36 and i >= 2 and i <= 5 then return 1 end   -- silver scurf band
  if w == 1 and y > 36 and i >= 3 then return -1 end              -- its shadowed lower edge
end)
for x = 18, 46 do
  for y = 37, 53 do
    local face = x > 21 and x < 43 and y > 36 and y < 49
    local w = (y + math.floor(1.6 * math.sin(x * .55) + .5)) % 5
    if not face and w == 0 and c.own[y * 64 + x] == bT and x < 30 and H(x, y, 6) > .3 then c:put(x, y, SILV, bT) end
  end
end
-- a drip running down from the cup lip
O.dots(c, { { 39, 33 }, { 39, 34 } }, SEA[4]) O.dot(c, 39, 35, SEA[5])
for x = 20, 44 do if c.own[35 * 64 + x] == bT and H(x, 35, 9) > .4 then c:put(x, 35, SILV, bT) end end

-- face: cross brows, locked eyes, clamped mouth
c:eyeLocked(24, 40)
c:eyeLocked(35, 40)
O.dots(c, { { 23, 37 }, { 24, 37 }, { 25, 38 }, { 26, 38 }, { 27, 39 }, { 28, 39 } }, P.ink)
O.dots(c, { { 41, 37 }, { 40, 37 }, { 39, 38 }, { 38, 38 }, { 37, 39 }, { 36, 39 } }, P.ink)
O.dots(c, { { 29, 48 }, { 30, 47 }, { 31, 47 }, { 32, 47 }, { 33, 47 }, { 34, 47 }, { 35, 48 } }, P.ink)
O.dot(c, 32, 48, "#f4ecd8") -- one tooth, clamped
c:cheek(20, 46) c:cheek(43, 46)

-- quirk: thirsty tree frog sitting on the left leaf, eyeing the water
local FR = { "#2f6a2a", "#5aa83a", "#8cd84a", "#c8f07a" }
local fr = c:ellipse(15.5, 15, 2.5, 2)
fr:add(c:rect(13, 16, 18, 17))
O.shade(c, fr, FR, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
O.dots(c, { { 13, 12 }, { 14, 12 }, { 13, 13 }, { 18, 12 }, { 17, 12 }, { 18, 13 } }, "#e04848") -- red eyes
O.dots(c, { { 14, 13 }, { 17, 13 } }, P.ink) O.dots(c, { { 13, 12 }, { 17, 12 } }, "#f89a80")
O.dots(c, { { 13, 17 }, { 18, 17 }, { 12, 17 }, { 19, 17 } }, "#f0b440") -- sticky toes
O.dots(c, { { 14, 15 }, { 15, 15 }, { 16, 15 }, { 17, 15 } }, FR[1]) -- wide mouth
O.dots(c, { { 15, 16 }, { 16, 16 } }, "#e8f0a0") -- pale throat


O.done(c, "rr-bromeliad-bolt-yard")

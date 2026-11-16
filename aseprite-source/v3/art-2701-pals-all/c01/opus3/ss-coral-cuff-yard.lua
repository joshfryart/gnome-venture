-- Coral Cuff (ss-coral-cuff), yard sprite 64x64. Opus third pass (art-2701-pals-all/c01/opus3): richness pass
-- over opus2. Rootwarden, uncommon, Sunsprinkle. "Four tiny reefs on four small knobs."
-- A chunky coral-pink cuff (short open cylinder, dark inside seen over the front lip) on stubby feet, four rim knobs
-- each with its own reef: red staghorn, orange sea fan, yellow tube coral, a teal anemone with pink tips.
-- Richness: 6-tone hue-shifted coral ramp (violet shade, peach light), cylinder light from the upper-left with one
-- core shadow lower-right and a cool sea bounce, polyp-cup texture (dark upper lip, lit lower wall) kept off the
-- face, a separate lit lip ring, a twisted gold braid with a sea-glass clasp, a starfish clinging to the lit side,
-- two barnacles in the shade, bubbles off the anemone, a pearl on the floor of the cuff.
-- quirk: a clownfish peeks out from behind the sea fan.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-coral-cuff-yard", 64)

local COR  = { "#55203f", "#8a3155", "#c24a6a", "#e8717f", "#f69c96", "#fcd2be" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local RED  = { "#5a1630", "#9a2238", "#d23a3a", "#f06a4a", "#fba070" }
local ORG  = { "#6a2e24", "#b0522a", "#e8803a", "#f8b05a", "#fcd890" }
local YEL  = { "#6a4a1c", "#b88a28", "#ecc23a", "#f8e47a", "#fdf4b8" }
local TEAL = { "#173f4a", "#1f6a6a", "#2f9a8a", "#5cc8a8", "#a8ecc8" }
local STAR = { "#7a2e2a", "#c4572e", "#ee8f3e", "#fbc76a" }
local BUB  = { "#6aa8c8", "#bfe8f0" }
local BOUNCE = "#5a7ea0"

c:groundShadow(32, 57, 21, 3)

-- stubby feet with two toe creases
for _, fx in ipairs({ 23, 41 }) do
  local f = c:ellipse(fx, 54, 4.5, 2.5)
  O.shade(c, f, COR, { R = 1, amb = .25, sep = COR[1], rim = true, bounce = BOUNCE, bmax = 2 })
  O.mark(c, { { fx - 1, 55 }, { fx + 2, 55 } }, COR[2])
end

-- the cuff: open cylinder
local top = c:ellipse(32, 25, 20, 6)
local body = c:rect(12, 25, 52, 46)
body:add(c:ellipse(32, 46, 20, 6)):add(top)
local bn = O.blendN(O.cylN(body, 36, 25, -.12), X.pillow(body, 5), .75, .45)
local bb = {}
body:each(function(x, y)
  if y >= 49 then bb[K(x, y)] = -1 end
end)
local bI, bT = O.shadeN(c, body, bn, COR, { bias = bb, amb = .12, wrap = .32, sep = COR[1], rim = true, bounce = BOUNCE, bmax = 2 })
local function face(x, y) return ((x - 32.5) / 15) ^ 2 + ((y - 34) / 7.5) ^ 2 < 1 end
O.pits(c, bI, bT, COR, { sx = 5, sy = 4, seed = 3, skip = function(x, y) return face(x, y) or y < 30 or y > 52 end })

-- lip ring: the rounded top edge of the cuff, lit along the upper-left, darker where it turns away
local lip = c:ellipse(32, 25, 20, 6):cut(c:ellipse(32, 25, 16, 4))
lip:each(function(x, y)
  local lx = (x + .5 - 32) / 20
  local t
  if y < 25 then t = (lx < .1) and 6 or 5 else t = (lx < -.2) and 5 or 4 end
  if lx > .7 then t = t - 1 end
  if y >= 29 then t = t - 1 end
  c:put(x, y, COR[t], bT)
end)
-- the open top: inner back wall lit from above-left, dark well, shadow under the front lip
local hole = c:ellipse(32, 25, 16, 4)
hole:each(function(x, y)
  local col = COR[2]
  if y <= 22 then col = (x > 28) and COR[4] or COR[3] end
  if y == 23 then col = (x > 30) and COR[3] or COR[2] end
  if y >= 27 then col = COR[1] end
  c:put(x, y, col, bT)
end)
-- a pearl on the floor of the cuff
O.dot(c, 37, 25, "#f6e8f0") O.dot(c, 38, 25, "#c8a8c8") O.dot(c, 37, 26, "#b898bc") O.dot(c, 38, 26, "#8a6a94")
for x = 17, 47 do -- front lip highlight
  local dy = 4 * math.sqrt(math.max(0, 1 - ((x + .5 - 32) / 16.5) ^ 2))
  local y = math.floor(25 + dy + .5) + 1
  if c:get(x, y) then c:put(x, y, x < 34 and COR[6] or COR[5], bT) end
end

-- gold braid round the lower cuff: two strands twisting, lit on the left
for x = 12, 52 do
  local dy = 6 * math.sqrt(math.max(0, 1 - ((x + .5 - 32.5) / 21) ^ 2))
  local y = math.floor(41 + dy + .5)
  local g = (x < 24) and 5 or (x < 40 and 4 or 3)
  if x <= 13 or x >= 51 then g = 2 end
  local ph = x % 4
  if ph == 0 then c:put(x, y, GOLD[math.min(6, g + 1)], bT) c:put(x, y + 1, GOLD[g - 1], bT)
  elseif ph == 1 then c:put(x, y, GOLD[g], bT) c:put(x, y + 1, GOLD[g], bT)
  elseif ph == 2 then c:put(x, y, GOLD[g - 1], bT) c:put(x, y + 1, GOLD[math.min(6, g + 1)], bT)
  else c:put(x, y, GOLD[1], bT) c:put(x, y + 1, GOLD[2], bT) end
  if c:get(x, y + 2) then c:put(x, y + 2, COR[math.max(1, (bI[K(x, y + 2)] or 3) - 1)], bT) end -- braid shadow
end
-- clasp: a gold knot holding a sea-glass bead, front and centre under the smile
O.shade(c, c:ellipse(32.5, 47.5, 2, 1.5), GOLD, { R = 1, amb = .3, sep = GOLD[1] })
O.dots(c, { { 32, 47 }, { 33, 47 }, { 32, 48 } }, TEAL[4]) O.dot(c, 33, 48, TEAL[2]) O.dot(c, 32, 47, TEAL[5])

-- starfish clinging to the lit side
local sf = HP.mask()
for j, r in ipairs({ "...a...", "..aaa..", "aaaaaaa", ".aaaaa.", "..aaa..", ".aa.aa.", ".a...a." }) do
  for i = 1, #r do if r:sub(i, i) == "a" then sf:set(12 + i, 33 + j) end end
end
O.shade(c, sf, STAR, { R = 1, amb = .4, cuts = { .25, .5, .75 }, sep = STAR[1] })
O.dots(c, { { 16, 36 }, { 15, 36 } }, STAR[4]) O.dot(c, 16, 37, STAR[3])
O.dots(c, { { 14, 36 }, { 18, 36 }, { 16, 35 } }, "#fde0a0") -- bumps down each arm
-- barnacles in the shade, lower right: cream cones with dark mouths
for _, b in ipairs({ { 47, 38 }, { 49, 41 } }) do
  O.dots(c, { { b[1], b[2] }, { b[1] + 1, b[2] } }, "#d8c8c0") O.dot(c, b[1], b[2] + 1, "#a890a0") O.dot(c, b[1] + 1, b[2] + 1, "#8a7088")
  O.dot(c, b[1], b[2], "#f0e6dc")
end

-- knobs on the rim: two at the back, two at the sides
local KN = { { 16, 23 }, { 26, 20 }, { 38, 20 }, { 48, 23 } }
for _, k in ipairs(KN) do
  O.shade(c, c:ellipse(k[1], k[2], 2.5, 2), COR, { R = 1, amb = .3, sep = COR[2], rim = true })
end

-- reef 1: red staghorn branches, pale growing tips, polyp dots
local st = HP.mask()
st:add(c:line({ { 16, 21 }, { 16, 16 }, { 14, 13 }, { 13, 10 } }, 2))
st:add(c:line({ { 16, 17 }, { 19, 14 }, { 19, 11 } }, 2))
st:add(c:line({ { 15, 15 }, { 12, 15 } }, 1))
O.shade(c, st, RED, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 }, rim = true })
O.dots(c, { { 13, 10 }, { 19, 11 }, { 12, 15 } }, RED[5]) O.dots(c, { { 16, 18 }, { 14, 12 }, { 20, 13 } }, RED[2])

-- reef 2: orange sea fan on a short stalk, a lattice of veins
local fan = c:ellipse(25, 13, 4.5, 5)
fan:cut(c:rect(18, 17, 34, 25))
fan:add(c:rect(25, 15, 26, 19))
local fI, fT = O.shade(c, fan, ORG, { R = 2, amb = .3, cuts = { .25, .45, .65, .85 }, sep = ORG[1] })
O.tex(c, fI, fT, ORG, function(x, y, i)
  if y > 16 then return end
  local a = math.atan(x + .5 - 25.5, 17 - y)
  if (a * 3.2) % 1 < .3 then return -1 end
  if (y == 11 or y == 14) and i >= 3 then return -1 end -- cross veins
end)
O.dots(c, { { 23, 9 }, { 26, 8 }, { 21, 11 } }, ORG[5])
-- quirk: a clownfish peeking out from behind the fan (nose toward the tubes)
O.flat(c, c:rect(32, 10, 34, 12), ORG[4], "fish")
O.dot(c, 35, 11, ORG[4]) O.dot(c, 31, 10, ORG[3]) O.dot(c, 31, 12, ORG[3])
O.dots(c, { { 33, 10 }, { 33, 11 }, { 33, 12 } }, "#fcecd8") -- white band
O.dot(c, 34, 10, ORG[5]) O.dot(c, 34, 11, P.ink) -- eye
O.dot(c, 32, 12, ORG[2]) O.dot(c, 35, 12, ORG[2])

-- reef 3: yellow tube coral, open ends, a short one in front
for _, t in ipairs({ { 37, 14, 18 }, { 39, 11, 18 }, { 41, 13, 18 }, { 43, 16, 19 } }) do
  local tm = c:rect(t[1], t[2], t[1] + 1, t[3])
  O.shade(c, tm, YEL, { R = 1, amb = .3, cuts = { .3, .5, .7, .88 }, sep = YEL[1] })
  O.dot(c, t[1], t[2], YEL[1]) O.dot(c, t[1] + 1, t[2], YEL[2])
  O.dot(c, t[1], t[2] + 1, YEL[5])
end

-- reef 4: teal anemone, fronds curling out, pink tips
local an = HP.mask()
an:add(c:ellipse(48, 19, 3, 2))
for _, f in ipairs({ { 45, 17, 44, 13 }, { 47, 17, 46, 12 }, { 49, 17, 50, 12 }, { 51, 18, 53, 14 } }) do
  an:add(c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1))
end
O.shade(c, an, TEAL, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 44, 13 }, { 46, 12 }, { 50, 12 }, { 53, 14 } }, "#f79ab8")
O.dots(c, { { 47, 19 }, { 48, 19 } }, TEAL[5])
-- bubbles rising from the anemone
O.flat(c, c:rect(54, 9, 55, 10), BUB[1], "bub") O.dot(c, 54, 9, BUB[2])
O.dot(c, 52, 6, BUB[2])

-- face in the middle of the band
c:eyeLocked(23, 30)
c:eyeLocked(36, 30)
O.dots(c, { { 22, 29 }, { 23, 28 }, { 24, 28 } }, COR[2]) O.dots(c, { { 40, 28 }, { 41, 28 }, { 42, 29 } }, COR[2])
c:cheek(19, 36) c:cheek(43, 36)
O.dots(c, { { 29, 37 }, { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 }, { 34, 37 } }, P.ink)
O.dot(c, 31, 39, COR[2]) O.dot(c, 32, 39, COR[2])

O.done(c, "ss-coral-cuff-yard")

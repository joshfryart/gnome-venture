-- Coral Cuff (ss-coral-cuff), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
-- Rootwarden, uncommon, Sunsprinkle. "Four tiny reefs on four small knobs."
-- A chunky coral-pink cuff (a short open cylinder: you see the dark inside through the top) with porous coral skin,
-- a gold braided band and stubby feet. Four knobs on the rim, each carrying a different tiny reef:
-- red staghorn, an orange sea fan, yellow tube coral, a teal anemone.
-- Fixes: the cuff now reads as a band (open top, inner wall, rim light), the reefs are four different shapes
-- instead of four red pins, the face sits in the middle of the band.
-- quirk: a tiny striped fish peeks out from behind the sea fan.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ss-coral-cuff-yard", 64)

local COR  = { "#5a2340", "#8f3456", "#c94f6d", "#ef7a8a", "#f7a8a8", "#fcd6c8" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local RED  = { "#5a1630", "#9a2238", "#d23a3a", "#f06a4a", "#fba070" }
local ORG  = { "#6a2e24", "#b0522a", "#e8803a", "#f8b05a", "#fcd890" }
local YEL  = { "#6a4a1c", "#b88a28", "#ecc23a", "#f8e47a" }
local TEAL = { "#173f4a", "#1f6a6a", "#2f9a8a", "#5cc8a8", "#a8ecc8" }

c:groundShadow(32, 57, 21, 3)

-- stubby feet
for _, fx in ipairs({ 23, 41 }) do
  O.shade(c, c:ellipse(fx, 54, 4.5, 2.5), COR, { R = 1, amb = .25, sep = COR[1], rim = true })
end

-- the cuff: open cylinder, axis x = 32
local top = c:ellipse(32, 25, 20, 6)
local body = c:rect(12, 25, 52, 46)
body:add(c:ellipse(32, 46, 20, 6)):add(top)
local bn = O.cylN(body, 32.5, 21, -.1)
local pn = X.pillow(body, 5)
for k, v in pairs(bn) do -- soften the cylinder with a pillow so the band rounds over at top and bottom
  local q = pn[k]
  if q then
    local a, b, z = v[1] * .7 + q[1] * .5, v[2] * .7 + q[2] * .5, v[3] * .7 + q[3] * .5
    local l = math.sqrt(a * a + b * b + z * z) bn[k] = { a / l, b / l, z / l }
  end
end
local bb = {}
body:each(function(x, y) if y >= 49 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shadeN(c, body, bn, COR, { bias = bb, amb = .1, wrap = .3, sep = COR[1], rim = true, bounce = "#4a7690", bmax = 1 })
-- coral skin: polyp pores on a staggered grid, a lit lip above each
O.tex(c, bI, bT, COR, function(x, y, i)
  local face = x > 19 and x < 46 and y > 26 and y < 42
  if face then return end
  if y % 4 == 0 and (x + (y // 4) * 2) % 5 == 0 and i >= 2 then return -1 end
  if y % 4 == 3 and (x + ((y + 1) // 4) * 2) % 5 == 0 and i >= 2 and i <= 5 then return 1 end
end)
-- the open top: rim, inner wall, dark inside
local hole = c:ellipse(32, 25, 16, 4)
hole:each(function(x, y)
  local col = COR[2]
  if y <= 23 then col = (x > 30) and COR[4] or COR[3] end   -- far inner wall catches light
  if y >= 27 then col = COR[1] end            -- shadow under the front lip
  c:put(x, y, col, bT)
end)
for x = 17, 47 do -- front lip highlight
  local dy = 4 * math.sqrt(math.max(0, 1 - ((x + .5 - 32) / 16.5) ^ 2))
  local y = math.floor(25 + dy + .5) + 1
  if c:get(x, y) then c:put(x, y, x < 36 and COR[6] or COR[5], bT) end
end

-- gold braided band round the lower cuff
for x = 12, 52 do
  local dy = 6 * math.sqrt(math.max(0, 1 - ((x + .5 - 32.5) / 21) ^ 2))
  local y = math.floor(41 + dy + .5)
  local g = (x < 22) and 5 or (x < 40 and 4 or 3)
  if x <= 13 or x >= 51 then g = 2 end
  c:put(x, y, GOLD[g], bT) c:put(x, y + 1, GOLD[math.max(1, g - 1)], bT)
  if x % 3 == 0 then c:put(x, y, GOLD[math.min(6, g + 1)], bT) c:put(x, y + 1, GOLD[g], bT) end -- braid twist
  if x % 3 == 2 then c:put(x, y + 1, GOLD[1], bT) end
end

-- knobs on the rim: two at the back, two at the sides
local KN = { { 16, 23 }, { 26, 20 }, { 38, 20 }, { 48, 23 } }
for _, k in ipairs(KN) do
  O.shade(c, c:ellipse(k[1], k[2], 2.5, 2), COR, { R = 1, amb = .3, sep = COR[2], rim = true })
end

-- reef 1: red staghorn branches
local st = HP.mask()
st:add(c:line({ { 16, 21 }, { 16, 16 }, { 14, 13 }, { 13, 10 } }, 2))
st:add(c:line({ { 16, 17 }, { 19, 14 }, { 19, 11 } }, 2))
st:add(c:line({ { 15, 15 }, { 12, 15 } }, 1))
O.shade(c, st, RED, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 13, 10 }, { 19, 11 }, { 12, 15 } }, RED[5])

-- reef 2: orange sea fan on a short stalk, veins radiating from the stalk
local fan = c:ellipse(25, 13, 4.5, 5)
fan:cut(c:rect(18, 17, 34, 25))
fan:add(c:rect(25, 15, 26, 19))
local fI, fT = O.shade(c, fan, ORG, { R = 2, amb = .3, cuts = { .25, .45, .65, .85 }, sep = ORG[1] })
O.tex(c, fI, fT, ORG, function(x, y, i)
  if y > 16 then return end
  local a = math.atan(x + .5 - 25.5, 17 - y)
  local f = (a * 3.2) % 1
  if f < .3 then return -1 end
end)
O.dots(c, { { 23, 9 }, { 26, 8 }, { 21, 11 } }, ORG[5])
-- quirk: a clownfish peeking out from behind the fan (nose toward the tubes)
O.flat(c, c:rect(32, 10, 34, 12), ORG[4], "fish")
O.dot(c, 35, 11, ORG[4]) O.dot(c, 31, 10, ORG[3]) O.dot(c, 31, 12, ORG[3])
O.dots(c, { { 33, 10 }, { 33, 11 }, { 33, 12 } }, "#fcecd8") -- white band
O.dot(c, 34, 10, ORG[5]) O.dot(c, 34, 11, P.ink) -- eye
O.dot(c, 32, 12, ORG[2])

-- reef 3: yellow tube coral, open ends
for _, t in ipairs({ { 37, 14, 18 }, { 39, 11, 18 }, { 41, 13, 18 } }) do
  local tm = c:rect(t[1], t[2], t[1] + 1, t[3])
  O.shade(c, tm, YEL, { R = 1, amb = .3, cuts = { .3, .6, .85 }, sep = YEL[1] })
  O.dot(c, t[1], t[2], YEL[1]) O.dot(c, t[1] + 1, t[2], YEL[2])
end

-- reef 4: teal anemone, fronds curling out
local an = HP.mask()
an:add(c:ellipse(48, 19, 3, 2))
for _, f in ipairs({ { 45, 17, 44, 13 }, { 47, 17, 46, 12 }, { 49, 17, 50, 12 }, { 51, 18, 53, 14 } }) do
  an:add(c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1))
end
O.shade(c, an, TEAL, { R = 1, amb = .3, cuts = { .25, .45, .65, .85 } })
O.dots(c, { { 44, 13 }, { 46, 12 }, { 50, 12 }, { 53, 14 } }, TEAL[5])

-- face in the middle of the band
c:eyeLocked(23, 30)
c:eyeLocked(36, 30)
O.dots(c, { { 22, 29 }, { 23, 28 }, { 24, 28 } }, COR[2]) O.dots(c, { { 40, 28 }, { 41, 28 }, { 42, 29 } }, COR[2])
c:cheek(19, 36) c:cheek(43, 36)
O.dots(c, { { 29, 37 }, { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 }, { 34, 37 } }, P.ink)
O.dot(c, 31, 39, COR[2]) O.dot(c, 32, 39, COR[2])

O.done(c, "ss-coral-cuff-yard")

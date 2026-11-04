-- lychee-seed (aC21_4, Opus single pass). One big polished mahogany lychee seed (oblong, mirror gloss: two glints,
-- dark shade side, cool bounce) with the pale matte hilum cap at its stalk end, lying on a torn scrap of glossy
-- lanceolate lychee leaflet (pale midrib, pinnate veins, cool rim, AO + contact shadow). From the hilum end the seed has
-- sprouted: a slim bronze stem carrying a pinnate flush of coppery-red young leaflets, like a lychee's new growth.
-- quirk: a curled shard of knobbly red lychee shell lies beside the seed, pale inside up.
local NAME = "lychee-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC21_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#122e2a", "#1a4636", "#24623e", "#368046", "#58a255", "#8cc874" }
local VEIN, COOL, FIBRE = "#b4d888", "#38666c", "#c6d898"
local SEED = { "#24100e", "#401a14", "#64281a", "#8c3c22", "#b45a30", "#d88850" }
local HIL = { "#7a5a40", "#a88460", "#cdb088", "#e6d2a8" }
local BRZ = { "#3e1418", "#64201e", "#8c3426", "#b44e2e", "#d4743e", "#eca460" }
local STEM = { "#4a2a22", "#7a4a30", "#a87048", "#d0a070" }
local RED = { "#4e1028", "#7c1830", "#ad2338", "#d63c44", "#ef6a5c", "#ff9f86" }
local PITH = { "#d8a494", "#f0c8b4", "#fbe4d0" }
local ltok, stok, btok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "flush" } }

local SX, SY, SRX, SRY, SA = 25, 43, 9, 5.6, -0.22
local sm, sn = A.oval(SX, SY, SRX, SRY, SA, 0.8)
-- shell shard (quirk) mask
local shm, shn = A.oval(47, 42, 4.2, 2.8, 0.35, 0.6)

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(5, 55, 30, 52, 58, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.4 * sin(pi * min(1, t ^ 0.85 * 0.97 + 0.03)) ^ 0.62)
end, { fold = 0.36 })
local torn = A.tear(lm, 11, 47, 15, 60, 1.3, 6)
local bias = {}
X.ao(bias, lm, sm, 1, -1) A.cast(bias, lm, sm, 1, 2, -1)
X.ao(bias, lm, shm, 1, -1) A.cast(bias, lm, shm, 1, 1, -1)
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
local PER = 6.5
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local f = ((t * len - abs(s) * 6) / PER) % 1
  if f < 0.12 and abs(s) > 0.15 and abs(s) < 0.8 and t < 0.92 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and not torn:has(x, y) and LS[k] > 0.62 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, FIBRE, ltok) end end)
for _, q in ipairs{ { 50, 38 }, { 51, 38 }, { 52, 37 } } do if lm:has(q[1], q[2]) and not bias[K(q[1], q[2])] then c:put(q[1], q[2], LEAF[6], ltok) end end

-- sprout from the hilum end
local sp = { { 32, 40 }, { 36, 33 }, { 31, 26 }, { 34, 16 } }
local stm, stn = A.tube(sp, function(t) return 1.1 - 0.2 * t end)
stm:cut(sm)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function lf(ax, ay, cx, cy, bx, by, w)
  return A.leaf(c, ax, ay, cx, cy, bx, by, w, { ramp = BRZ, tok = btok, veins = true, vein = BRZ[6], per = 2.8, cut = stm, pw = 0.8 })
end
local a1 = lf(33, 25, 27, 21, 20, 23, 2.6)
local a2 = lf(34, 24, 40, 20, 47, 22, 2.6)
local a3 = lf(34, 18, 28, 14, 23, 15, 2.3)
local a4 = lf(35, 17, 40, 13, 46, 14, 2.3)
local a5 = lf(34, 16, 34, 13, 36, 9, 2.2)
for _, q in ipairs{ { 32, 25 }, { 35, 24 }, { 33, 18 }, { 35, 18 } } do c:put(q[1], q[2], BRZ[1], btok) end
-- root tip peeking under the seed's hilum end
c:put(34, 45, STEM[4], stok) c:put(35, 46, STEM[3], stok) c:put(36, 47, STEM[2], stok)

-- seed: polished shell, matte hilum cap at the right end
local tok = { r = { name = "seed" } }
local idx = A.toneN(c, sm, sn, SEED, { tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.82 }, amb = 0.1, wrap = 0.22 })
local ca, sa = cos(SA), sin(SA)
local rim = X.rim(sn)
sm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - SX, y - SY
  local u = (dx * ca + dy * sa) / (SRX + .45)
  local v = (-dx * sa + dy * ca) / (SRY + .45)
  local q = (u - 0.92) ^ 2 / 0.2 + v * v / 0.6
  if q < 1 then
    local hi = max(1, min(4, (idx[k] or 3) - 1))
    if X.hash(x, y, 4) < 0.25 then hi = max(1, hi - 1) end
    c:put(x, y, HIL[hi], tok)
  elseif q < 1.45 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 2)], tok)
  elseif rim[k] > 0.6 and (idx[k] or 3) <= 2 and u * u + v * v > 0.6 then c:put(x, y, "#5a3448", tok) end
end)
-- faint lengthwise grain on the shell
for _, q in ipairs{ { 18, 44 }, { 19, 44 }, { 20, 45 }, { 23, 46 }, { 24, 46 } } do
  local h = c:get(q[1], q[2]) if h and sm:has(q[1], q[2]) then c:put(q[1], q[2], SEED[3], tok) end end
local gx, gy = A.specAt(sm, sn, 40)
c:put(gx, gy, A.CREAM, tok) c:put(gx + 1, gy, A.CREAM, tok) c:put(gx + 2, gy, SEED[6], tok) c:put(gx, gy + 1, SEED[6], tok)
c:put(gx + 6, gy + 1, SEED[6], tok)

-- quirk: shell shard, convex red outside lower right, pale pith visible in the upper-left hollow
local qtok = { r = { name = "shard" } }
local sidx = A.toneN(c, shm, shn, RED, { tok = qtok, cuts = { 0.16, 0.3, 0.45, 0.6, 0.78 }, amb = 0.1, wrap = 0.28 })
local cs, ss = cos(0.35), sin(0.35)
shm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - 47, y - 42
  local u = (dx * cs + dy * ss) / 4.6
  local v = (-dx * ss + dy * cs) / 3.2
  if v < 0.05 and u * u + (v + 0.1) ^ 2 < 0.62 then
    c:put(x, y, PITH[(v < -0.4) and 1 or ((u < 0) and 3 or 2)], qtok)
  elseif ((x + y * 2) % 4 == 0) then c:put(x, y, RED[max(1, (sidx[k] or 3) - 1)], qtok)
  elseif ((x * 2 + y) % 5 == 0) and (sidx[k] or 1) >= 4 then c:put(x, y, RED[6], qtok) end
end)

A.save2(c, NAME)

-- lily-of-the-valley-seed (final, Opus single pass). Two glossy red-orange lily-of-the-valley berries and one pale round
-- seed on a torn, broad elliptic leaf scrap with parallel (monocot) veins converging at the tip. The pale seed has
-- sprouted: a purple-flushed rolled sheath (the "pip") opening into two tall upright lanceolate leaves.
-- quirk: a single tiny white nodding bell already hangs from a thread-thin arching stalk.
local NAME = "lily-of-the-valley-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#16393a", "#1f5544", "#2b704c", "#3f8f53", "#62ad5c", "#98cc72" }
local VEIN, COOL = "#bfe08e", "#3a6c72"
local BERRY = { "#5a1630", "#8e1f2c", "#c4302a", "#e6502e", "#fa7e48", "#ffb27a" }
local PALE = { "#5e4a3e", "#8a7258", "#b29a78", "#d2bf98", "#ebdcb8", "#fbefd0" }
local SHEATH = { "#3b2a4e", "#5e4270", "#86688e", "#a99aa0", "#cdd0a8", "#e6edbe" }
local BELL = { "#7a8a8e", "#a9b8b4", "#d2ddd2", "#eef3e2", "#fff4d6" }

local berries = { { 21, 45, 4.4 }, { 30, 48, 3.9 } }
local seed = { 39, 46, 2.6 }
for _, b in ipairs(berries) do b.m = c:ellipse(b[1], b[2], b[3], b[3]) b.n = X.sphere(b[1] - .3, b[2] - .3, b[3], b.m) end
seed.m = c:ellipse(seed[1], seed[2], seed[3], seed[3] - 0.4)
seed.n = X.sphere(seed[1], seed[2], seed[3], seed.m)

-- leaf scrap: broad elliptic leaf, torn base at left, tip at right
local lm, ln, LT, LS, len = A.blade(5, 50, 30, 54, 59, 45, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 7.4 * sin(pi * min(1, 0.08 + t * 0.92)) ^ 0.55)
end, { fold = 0.3 })
local tornE = A.tear(lm, LT, LS, len, 7, "start", 3)
local bias = {}
for _, b in ipairs(berries) do X.ao(bias, lm, b.m, 1, -1) A.cast(bias, lm, b.m, 1, 2, -1) end
X.ao(bias, lm, seed.m, 1, -1) A.cast(bias, lm, seed.m, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  local a = abs(s)
  if a < 0.1 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- parallel veins (fixed fraction of the half width, so they converge at the tip)
  if t < 0.93 and (abs(a - 0.42) < 0.07 or abs(a - 0.74) < 0.06) then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and not tornE:has(x, y) then c:put(x, y, COOL, ltok) end end)
tornE:each(function(x, y) c:put(x, y, (x * 3 + y) % 4 == 0 and LEAF[4] or "#cfe6a0", ltok) end)

-- sprout: tall leaves first, then the rolled sheath over their bases
local function lance(bx, by, cx, cy, tx, ty, W, ramp)
  local m, n, T, S = A.blade(bx, by, cx, cy, tx, ty, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, W * sin(pi * min(1, 0.12 + 0.88 * t)) ^ 0.7)
  end, { fold = 0.45 })
  A.shade(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  m:each(function(x, y) local k = K(x, y) local a = abs(S[k])
    if T[k] > 0.1 and T[k] < 0.9 and (a < 0.12 or abs(a - 0.6) < 0.08) then
      c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[2], ltok) end end)
  return m
end
local L1 = lance(38, 38, 35, 22, 31, 8, 3.3)
local L2 = lance(41, 38, 45, 26, 50, 14, 2.9)
-- shadow of the front leaf on the back leaf where they cross is the AO row below their bases
local shm, shn, ST, SS = A.tube({ { 39, 44 }, { 39, 41 }, { 39.5, 38 }, { 40, 34 } }, function(t) return 1.6 - t * 0.5 end)
shm:cut(seed.m)
local stok = { r = { name = "sheath" } }
local sidx = X.tone(c, shm, X.light(shn, { amb = 0.12, wrap = 0.3 }), SHEATH, { cuts = A.CUTS, tok = stok })
shm:each(function(x, y) local k = K(x, y) if (y % 3 == 0) and SS[k] > -0.3 then A.rp(c, x, y, SHEATH, sidx[k] - 1, stok) end end)

-- quirk: thread stalk arching left with one nodding bell
local btok = { r = { name = "bell" } }
local arc = { { 37, 36 }, { 33, 31 }, { 27, 28 }, { 24, 31 } }
for i = 0, 40 do local x, y = A.bez(arc, i / 40) c:put(floor(x + .5), floor(y + .5), i < 30 and A.STEM[2] or A.STEM[3], { r = { name = "stalk" } }) end
local bm = HP.mask()
for _, r in ipairs{ { 32, 23, 25 }, { 33, 22, 26 }, { 34, 22, 26 }, { 35, 21, 27 }, { 36, 21, 27 } } do
  for x = r[2], r[3] do bm:set(x, r[1]) end end
local bn = X.sphere(23.5, 34, 3, bm)
local bidx = X.tone(c, bm, X.light(bn, { amb = 0.2, wrap = 0.4 }), BELL, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = btok })
-- flared scalloped lip
c:put(21, 37, BELL[3], btok) c:put(23, 37, BELL[3], btok) c:put(25, 37, BELL[2], btok) c:put(27, 37, BELL[2], btok)
c:put(22, 36, BELL[2], btok) c:put(26, 36, BELL[1], btok)
c:put(24, 37, "#c9a640", btok)  -- stamen tip peeking out

-- berries: glossy, cool bounce, style dot, specular
for i, b in ipairs(berries) do
  local vis = b.m:copy()
  local bb = {}
  for j = i + 1, #berries do vis:cut(berries[j].m) X.ao(bb, b.m, berries[j].m, 1, -1) end
  local tok = { r = { name = "berry" .. i } }
  local idx = X.tone(c, vis, X.light(b.n, { amb = 0.06, wrap = 0.22 }), BERRY, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 }, bias = bb, tok = tok })
  local rim = X.rim(b.n)
  vis:each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and (idx[k] or 9) <= 2 and not bb[k] then c:put(x, y, "#a8486a", tok) end end)
  local sx, sy = A.specAt(vis, b.n, 30)
  c:put(sx, sy, A.CREAM, tok) c:put(sx + 1, sy, BERRY[6], tok)
  c:put(b[1] + 1, b[2] - floor(b[3]) + 1, BERRY[1], tok)   -- style dot
end
-- pale seed (sheath grows out of it)
local tok = { r = { name = "seed" } }
X.tone(c, seed.m, X.light(seed.n, { amb = 0.1, wrap = 0.3 }), PALE, { cuts = A.CUTS, tok = tok })
c:put(38, 45, PALE[6], tok)
c:put(40, 47, PALE[2], tok)

A.save(c, NAME)

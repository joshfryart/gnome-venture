-- kohlrabi-seed (final pass, Opus single pass). Four round brassica seeds (red-brown spheres, fine dark netting,
-- one glint each) lined up along the purple midrib of a torn glaucous kohlrabi leaf scrap lying on the diagonal
-- (wavy blue-green margin, pinnate veins, V-fold light, pale torn end, cool reflected edge, AO + contact shadows).
-- The top seed has sprouted: a purple stem with two broad kidney cotyledons notched at the tip (the brassica tell)
-- and a first toothed blue-green true leaf.
-- quirk: a round dew drop sits on the leaf, bright rim and pale core, catching the light.
local NAME = "kohlrabi-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1a3440", "#264f52", "#376c62", "#4f8c70", "#76ac84", "#a8cea6" }
local MID, MIDHI = "#7a4ca8", "#b892d8"
local COOL, TORN = "#4a6a96", "#d2e6b8"
local SEED = { "#2a1414", "#46201c", "#662e22", "#8a442c", "#b06640", "#d89466" }
local STEM = { "#3a2058", "#5a3482", "#7a4ca8", "#a07ccc", "#cbb0e6" }
local DROP = { "#3a6e8a", "#6aa6c0", "#b6e2ea", "#e8f8f4" }
local CUTS = A.CUTS

-- leaf scrap: from lower-left (petiole) up to the torn upper-right
local lm, ln, LT, LS, len = A.blade(10, 56, 26, 46, 52, 30, function(t)
  if t > 0.985 then return -1 end
  local w = 10 * sin(pi * min(1, t * 0.78 + 0.08)) ^ 0.7
  return max(0.6, w * (1 + 0.09 * sin(t * 30)))
end, { fold = 0.4 })
local torn = A.tear(lm, 46, 34, 0.8, -0.6, 1.5, 9)
local bias = {}

-- seeds along the midrib
local seeds = { { 19, 50, 2.6 }, { 25, 46, 2.6 }, { 31, 43, 2.6 }, { 37, 39, 2.7 } }
for _, s in ipairs(seeds) do
  s.m = HP.ellipse(s[1], s[2], s[3] - 0.4, s[3] - 0.5)
  s.n = X.sphere(s[1] - 0.2, s[2] - 0.2, s[3], s.m)
  X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1)
end
-- dew drop geometry
local DX, DY = 27, 53
local dm = HP.ellipse(DX, DY, 2.2, 1.9)
A.cast(bias, lm, dm, 1, 1, -1)

local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.0 and t < 0.86 then c:put(x, y, s <= 0 and MIDHI or MID, ltok) return end
  local ph = (t * len - abs(s) * 6) / 5.2 + (s > 0 and 0.45 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.8 and t > 0.08 and t < 0.84 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 and LT[k] < 0.82 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
local ptok = { r = { name = "petiole" } }
for _, q in ipairs{ { 9, 57, 3 }, { 8, 57, 4 }, { 8, 58, 2 }, { 7, 58, 3 }, { 6, 59, 2 } } do c:put(q[1], q[2], STEM[q[3]], ptok) end

-- sprout from the top seed (37,39)
local stok = { r = { name = "stem" } }
local sp = { { 37, 37 }, { 37, 31 }, { 34, 27 }, { 35, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[4].m)
X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
-- kidney cotyledons: heart shape turned so the notch faces outward
local cotok = { r = { name = "cot" } }
local function cot(cx, cy, S, ang)
  local m, U, V = A.heart(cx, cy, S, ang, 1.15, 0.85)
  m:cut(sm)
  local n0 = X.pillow(m, 2.2)
  local n = {}
  m:each(function(x, y) local k = K(x, y) local a = n0[k] n[k] = { A.norm(a[1] - 0.15, a[2] - 0.25 + U[k] * 0.3, a[3]) } end)
  A.toneN(c, m, n, LEAF, { tok = cotok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(V[k]) < 0.09 and U[k] > 0.3 and U[k] < 0.92 then c:put(x, y, LEAF[5], cotok) end end)
  return m
end
local cl = cot(28, 22, 4.3, -1.75)   -- notch to the left
local cr = cot(42, 22, 4.3, 1.75)    -- notch to the right
-- first true leaf: small toothed oval standing up between them
local tm, tn, TT, TS = A.blade(35, 21, 34, 15, 36, 9, function(t)
  if t > 0.985 then return -1 end
  local w = 2.8 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.7
  return max(0.4, w + ((floor(t * 9) % 2 == 0) and 0.35 or -0.1))
end, { fold = 0.35 })
tm:cut(cl):cut(cr)
A.toneN(c, tm, tn, LEAF, { tok = cotok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.14 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and LEAF[6] or LEAF[3], cotok) end end)
for _, q in ipairs{ { 35, 22 }, { 35, 21 } } do c:put(q[1], q[2], STEM[3], stok) end

-- seeds: lit spheres with a faint net, AO between neighbours, one glint
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, amb = 0.05, wrap = 0.2, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 } })
  s.m:each(function(x, y) local k = K(x, y) if (idx[k] or 1) >= 3 and (x + 2 * y + i) % 5 == 0 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok) end end)
  c:put(s[1] - 1, s[2] - 1, "#fff4d6", tok)
end

-- quirk: dew drop
local dtok = { r = { name = "drop" } }
dm:each(function(x, y) local dx, dy = x - DX, y - DY
  local col = DROP[3]
  if dx + dy > 1.5 then col = DROP[2] end
  if dy > 1 then col = DROP[1] end
  if dx + dy < -1.5 then col = DROP[4] end
  c:put(x, y, col, dtok) end)
c:put(DX - 1, DY - 1, "#fff4d6", dtok) c:put(DX + 1, DY + 1, DROP[4], dtok)

A.save(c, NAME)

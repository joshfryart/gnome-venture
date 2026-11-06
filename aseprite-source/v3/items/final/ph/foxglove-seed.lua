-- foxglove-seed (B32, Opus single pass). Three tiny oblong foxglove seeds (rust-brown, pitted honeycomb coat) on a
-- broad, downy grey-green foxglove leaf scrap: crenate (round-toothed) margin, pale midrib, swept laterals with a
-- quilted puckering between them, soft bloom flecks, torn ragged at the left. The right seed has sprouted: pale stem,
-- two round cotyledons and a first ovate, scalloped true leaf with veins.
-- quirk: a single fallen pink foxglove bell, freckled inside its mouth, lies at the leaf tip.
local NAME = "foxglove-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local LEAF = { "#1e3a3c", "#2c5246", "#3e6c50", "#58885a", "#7ea670", "#acc890" }
local VEIN, COOL, BLOOM = "#c6dcaa", "#40687a", "#b8d0a4"
local SEED = { "#331c1e", "#562e24", "#7a442a", "#9e6034", "#c28248", "#e2ac6c" }
local STEM = { "#4a8058", "#80b070", "#b4d698", "#e0f0c4" }
local PINK = { "#4e1e44", "#7d2c5e", "#b0447e", "#d9679c", "#f08fb8", "#ffc4d8" }

-- broad leaf scrap, slight arch, tip at the right
local lm, ln, LT, LS, len = G.blade(7, 47, 30, 58, 56, 41, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 10.0 * sin(pi * min(1, t * 0.86 + 0.1)) ^ 0.62)
end, { fold = 0.32 })
-- crenate margin + torn base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / 4.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if abs(s) > 0.9 - (1 - f) ^ 3 * 0.25 and t > 0.12 then cut[#cut + 1] = k end
  if t < 0.1 + 0.06 * sin(s * 11) + 0.04 * X.hash(x, y, 2) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 19, 49, 2.7, 1.6, 0.35 }, { 27, 52, 2.7, 1.6, -0.25 }, { 40, 46, 2.7, 1.7, 0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- the bell (quirk) lies over the leaf tip
local BP = { { 44, 53 }, { 47, 54 }, { 50, 55 }, { 54, 55 } }
local bm, bn, BT, BS = G.tube(BP, function(t) return 1.1 + 1.8 * t ^ 1.3 end, 80)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -2) G.cast(bias, lm, s.m, 1, 1, -1) end
X.ao(bias, lm, bm, 1, -1) G.cast(bias, lm, bm, 1, 1, -1)
-- quilting: lighter puckers between laterals
local VP = 6.0
lm:each(function(x, y) local k = K(x, y)
  local ph = (LT[k] * len - abs(LS[k]) * 6.0) / VP
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.82 then bias[k] = (bias[k] or 0) - 1 elseif f < 0.3 and abs(LS[k]) < 0.8 then bias[k] = (bias[k] or 0) + 1 end
end)
local lidx = G.shade(c, lm, ln, LEAF, { bias = bias, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.2, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bm:has(x, y) then return end
  for _, sd in ipairs(seeds) do if sd.m:grow(1):has(x, y) then return end end
  if abs(s) < 0.12 and t > 0.08 then c:put(x, y, s <= 0 and VEIN or LEAF[3]) return end
  local ph = (t * len - abs(s) * 6.0) / VP
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.14 and abs(s) < 0.78 and t > 0.12 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2]) return end
  if X.hash(x, y, 9) > 0.94 and (lidx[k] or 1) >= 3 then c:put(x, y, BLOOM) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.8 and not bm:has(x, y) then c:put(x, y, COOL) end end)
-- torn base: pale fibre pixels
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 and abs(LS[k]) < 0.8 then c:put(x, y, LEAF[5]) end end)

-- sprout from the right seed
local sp = { { 40, 45 }, { 39, 39 }, { 41, 33 }, { 40, 27 } }
local sm, sn = G.tube(sp, function() return 1.0 end)
sm:cut(seeds[3].m)
G.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local function coty(cx, cy, a)
  local m, n = G.oval(cx, cy, 3.4, 2.4, a, 0.7)
  m:cut(sm)
  local cb = {}
  X.ao(cb, m, sm, 1, -1)
  G.shade(c, m, n, LEAF, { bias = cb, amb = 0.16, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  return m
end
local cl = coty(35.5, 29.5, 0.45)
local cr = coty(45.5, 29.5, -0.45)
-- true leaf: ovate, scalloped, midrib + two pairs of veins
local tl, tln, TLT, TLS, tlen = G.blade(40, 27, 39, 20, 42, 12, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 3.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
end, { fold = 0.35 })
local tc = {}
tl:each(function(x, y) local k = K(x, y)
  local ph = TLT[k] * tlen / 3.2 + (TLS[k] > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if abs(TLS[k]) > 0.92 - (1 - f) ^ 3 * 0.3 and TLT[k] > 0.15 then tc[#tc + 1] = k end
end)
for _, k in ipairs(tc) do tl.s[k] = nil end
tl:cut(cl):cut(cr)
local tb = {}
X.ao(tb, tl, cl, 1, -1) X.ao(tb, tl, cr, 1, -1)
G.shade(c, tl, tln, LEAF, { bias = tb, amb = 0.16, wrap = 0.3, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
tl:each(function(x, y) local k = K(x, y) local s, t = TLS[k], TLT[k]
  if tb[k] then return end
  if abs(s) < 0.16 and t > 0.05 and t < 0.85 then c:put(x, y, s <= 0 and VEIN or LEAF[3]) return end
  local ph = (t * tlen - abs(s) * 3.0) / 3.6
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.15 and t < 0.75 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2]) end
end)

-- seeds: pitted coat
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  if i == 3 then vis:cut(sm) end
  local v = X.light(s.n, { amb = 0.1, wrap = 0.3 })
  vis:each(function(x, y) local k = K(x, y)
    local idx = 1
    for jj, t in ipairs{ 0.16, 0.32, 0.48, 0.64, 0.82 } do if v[k] >= t then idx = jj + 1 end end
    if (x + 2 * y + i) % 4 == 0 then idx = idx - 1 end
    c:put(x, y, SEED[max(1, min(6, idx))])
  end)
  local gx, gy = G.specAt(s.m, s.n, 30)
  if gx and i == 1 then c:put(gx, gy, "#fff4d6") end
end

-- the fallen bell: tube with open freckled mouth at the right
local bv = X.light(bn, { amb = 0.12, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y)
  local i = 1 for j, t in ipairs{ 0.14, 0.3, 0.46, 0.62, 0.8 } do if bv[k] >= t then i = j + 1 end end
  if BT[k] < 0.15 then i = max(1, i - 1) end
  c:put(x, y, PINK[i])
end)
-- mouth: dark throat with cream lip and two freckles
for _, q in ipairs{ { 55, 54, "#5a2048" }, { 55, 55, "#3e1834" }, { 55, 56, "#5a2048" }, { 56, 55, "#f8efe0" }, { 56, 54, PINK[6] }, { 56, 56, PINK[4] },
  { 54, 53, "#f8efe0" }, { 54, 57, PINK[3] }, { 54, 55, "#7d2c5e" } } do c:put(q[1], q[2], q[3]) end
-- tiny green calyx at the bell's base
c:put(43, 53, LEAF[4]) c:put(44, 52, LEAF[5]) c:put(43, 54, LEAF[2])

G.save(c, NAME)

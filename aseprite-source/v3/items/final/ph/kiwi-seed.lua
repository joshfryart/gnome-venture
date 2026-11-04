-- kiwi-seed (final pass, Opus single pass). A small heap of glossy black-brown kiwi seeds (tiny teardrop ovals,
-- 1 px glint each) on a torn, round kiwi-vine leaf scrap (heart notch at the petiole end, midrib + curved side veins,
-- V-fold light, pale torn edge, cool reflected rim, AO + contact shadow under the seeds). One seed has germinated:
-- a rusty, hairy twining stem with two round cotyledons, a first true leaf (round heart, short point) and the vine's
-- tip already curling into a twining hook.
-- quirk: a little wedge of kiwi fruit (emerald flesh, seed ring, cream core, fuzzy brown skin) leans on the leaf.
local NAME = "kiwi-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local LEAF = { "#1b3a2e", "#25503a", "#346b40", "#4c8a45", "#72aa52", "#a6cc72" }
local VEIN, COOL, TORN = "#bcd98c", "#3b6a6c", "#d6e6a0"
local SEED = { "#1e1218", "#33202a", "#4a2e32", "#66403c", "#8a5a4a", "#b88a70" }
local STEM = { "#4a2a24", "#6e3e2c", "#94583a", "#b8764c", "#d89a68" }
local FL = { "#24602e", "#3a8a34", "#5cae3a", "#8acc4a", "#bce27a" }
local SKIN = { "#4a3222", "#6e4c30", "#8e6a42", "#b08c5c" }
local CUTS = A.CUTS

-- leaf scrap: broad round kiwi leaf lying left->right, heart notch at the left (petiole), torn on the right
local lm, ln, LT, LS, len = A.blade(11, 47, 30, 44, 54, 45, function(t)
  if t > 0.985 then return -1 end
  local u = 2 * t - 1.0
  local w = 10.2 * sqrt(max(0, 1 - (u * 0.98) ^ 2)) ^ 0.8
  return max(0.6, w)
end, { fold = 0.34 })
-- heart notch at the base
lm:each(function(x, y) local k = K(x, y) if LT[k] < 0.07 and abs(LS[k]) < 0.33 then lm.s[k] = nil end end)
local torn = A.tear(lm, 47, 44, 1, -0.25, 1.6, 5)
local bias = {}

-- seeds: cx, cy, rx, ry, ang (a small heap, front row lowest)
local seeds = {
  { 21, 45, 2.4, 1.5, 0.5 }, { 26, 43, 2.4, 1.5, -0.3 }, { 25, 48, 2.5, 1.6, 0.15 },
  { 30, 46, 2.4, 1.5, 0.9 }, { 20, 50, 2.3, 1.5, -0.4 }, { 35, 44, 2.6, 1.6, -1.2 },
}
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7)
  X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1)
end

-- quirk wedge geometry (needed for the leaf's contact shadow)
local WC = { 41, 48 }
local wm, WR, WA = HP.mask(), {}, {}
for y = WC[2] - 11, WC[2] + 11 do for x = WC[1] - 11, WC[1] + 11 do
  local dx, dy = x - WC[1] + 0.0, y - WC[2] + 0.0
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)               -- radians, -pi..pi ; wedge opens up-left
  if r <= 9.2 and a > 0.02 and a < 1.12 then wm:set(x, y) WR[K(x, y)] = r WA[K(x, y)] = a end
end end
wm:set(WC[1], WC[2]) WR[K(WC[1], WC[2])] = 0 WA[K(WC[1], WC[2])] = 0.6
X.ao(bias, lm, wm, 1, -1) A.cast(bias, lm, wm, 1, 1, -1)

local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.07 and t < 0.86 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- curved side veins sweeping toward the tip
  local ph = (t * len - abs(s) ^ 1.4 * 9) / 6.5 + (s > 0 and 0.4 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.82 and t > 0.12 and t < 0.84 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
-- petiole stub into the notch
local ptok = { r = { name = "petiole" } }
for _, q in ipairs{ { 12, 47, 4 }, { 11, 48, 3 }, { 10, 48, 4 }, { 9, 49, 3 }, { 8, 49, 2 }, { 7, 50, 2 } } do c:put(q[1], q[2], STEM[q[3]], ptok) end

-- sprout from the seed at (35,44): hairy rusty stem, cotyledons, first true leaf, twining tip
local sp = { { 35, 43 }, { 34, 35 }, { 38, 30 }, { 36, 22 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.15 - t * 0.2 end)
sm:cut(seeds[6].m)
local stok = { r = { name = "stem" } }
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
-- hairs: short pale ticks along the lit side
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.3 and (x * 3 + y) % 4 == 0 then c:put(x, y, STEM[5], stok) end end)
local lfok = { r = { name = "sproutleaf" } }
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.55)
  end, { fold = 0.25 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = lfok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.15 and T[k] < 0.75 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], lfok) end end)
  return m
end
local cl = cot(34, 33, 30, 31, 25, 31, 2.4)
local cr = cot(36, 31, 40, 30, 44, 31, 2.3)
-- first true leaf: round heart with a short point (kiwi), on a short petiole to the right
local hm, HU, HV = A.heart(44, 21, 5.6, -1.75, 1.0, 1.05)
hm:cut(sm)
local hn = X.pillow(hm, 2.4)
local hn2 = {}
hm:each(function(x, y) local k = K(x, y) local v = HV[k] local f = (v < 0 and -0.35 or 0.35) + v * 0.3
  local a = hn[k] hn2[k] = { A.norm(a[1] + f * 0.15, a[2] + f * 0.95, a[3]) } end)
A.toneN(c, hm, hn2, LEAF, { tok = lfok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  if abs(HV[k]) < 0.1 and HU[k] > 0.12 and HU[k] < 0.85 then c:put(x, y, HV[k] < 0 and LEAF[6] or LEAF[3], lfok) end
  if abs(HV[k]) > 0.25 and abs(HV[k]) < 0.7 and abs((HU[k] * 3 + abs(HV[k]) * 1.4) % 1 - 0.5) < 0.09 and HU[k] > 0.2 and HU[k] < 0.8 then
    c:put(x, y, HV[k] < 0 and LEAF[5] or LEAF[2], lfok) end end)
for _, q in ipairs{ { 37, 23 }, { 38, 22 }, { 39, 22 } } do c:put(q[1], q[2], STEM[3], stok) end
-- twining tip: the stem keeps going up-left and hooks into a curl
local tp = { { 36, 22 }, { 35, 17 }, { 31, 14 }, { 29, 17 } }
local tm, tn = A.tube(tp, function(t) return 0.75 end)
tm:cut(hm)
X.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = stok })
c:put(30, 18, STEM[4], stok) c:put(31, 18, STEM[3], stok)

-- seeds last: glossy teardrops, AO between neighbours, one glint each
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local v = X.light(s.n, { amb = 0.05, wrap = 0.15 })
  local idx = X.tone(c, s.m, v, SEED, { cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 }, bias = sb, tok = tok })
  local gx, gy = A.specAt(s.m, s.n, 30)
  if gx then c:put(gx, gy, i % 2 == 0 and "#e8d2c0" or "#fff4d6", tok) end
  for j = i + 1, #seeds do seeds[j].m:each(function(x, y) end) end
end
-- re-cover: later seeds sit over earlier (already in order)

-- quirk: kiwi wedge
local wtok = { r = { name = "wedge" } }
wm:each(function(x, y) local k = K(x, y) local r, a = WR[k], WA[k]
  local col
  if r > 8.1 then col = SKIN[(x + y) % 3 == 0 and 4 or (a > 0.6 and 2 or 3)]
  elseif r > 7.2 then col = FL[2]
  elseif r < 1.6 then col = r < 0.8 and "#fff4d6" or "#f0e6b0"
  elseif r < 2.6 then col = "#e2eca0"
  else
    local i = (a < 0.37) and 4 or (a < 0.75 and 3 or 2)
    if r < 3.6 then i = i + 1 end
    -- radial pale rays
    if abs(((a - 0.02) / 0.2) % 1 - 0.5) < 0.12 and r > 3 then i = i + 1 end
    col = FL[min(5, i)]
  end
  c:put(x, y, col, wtok) end)
-- seed ring in the flesh
for _, a in ipairs{ 0.25, 0.57, 0.89 } do c:put(floor(WC[1] + cos(a) * 3.3 + .5), floor(WC[2] + sin(a) * 3.3 + .5), SEED[2], wtok) end
-- fuzz on the skin edge
for _, q in ipairs{ { 39, 51 }, { 41, 48 }, { 44, 46 } } do if not wm:has(q[1], q[2]) then end end
c:put(floor(WC[1] + cos(0.4) * 6) , floor(WC[2] + sin(0.4) * 6), FL[5], wtok)

A.save(c, NAME)

-- okra-seed (final, Opus C3 single pass). Four round blue-grey okra seeds (hard coat, small pale hilum eye, glossy
-- glint, AO between neighbours, contact shadow) on a torn scrap of palmate okra leaf (five pointed lobes, a midrib
-- into each lobe from the petiole point, side veins, V-fold light, cool reflected edge, one lobe ripped off).
-- The right seed has sprouted: reddish hypocotyl, two broad kidney cotyledons, and a first three-lobed okra leaf.
-- quirk: a thin cross-section slice of okra pod lies on the leaf, a five-point green star with seeds in its chambers.
local NAME = "okra-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#163a33", "#1f5238", "#2d6e3e", "#448c45", "#69ad52", "#9dcf72" }
local VEIN, COOL = "#b6dc8a", "#386a6c"
local SEED = { "#1f2230", "#2e3444", "#425062", "#5d6e7c", "#8296a0", "#bccad0" }
local HYPO = { "#5e2a36", "#8a3c40", "#b0584c", "#cf7e64", "#e8a888", "#f6d0b4" }
local SL = { "#2a6a40", "#4f9a4a", "#86c462", "#c4e494", "#eef6c8" }

-- palmate leaf: lobes from the petiole point
local P0 = { 31, 55 }
local lobes = { { -90, 25, 6.4 }, { -134, 22, 6.0 }, { -46, 22, 6.0 }, { -172, 15, 4.8 }, { -8, 15, 4.8 } }
local lm, ln, LT, LS = HP.mask(), {}, {}, {}
for li, L in ipairs(lobes) do
  local a = math.rad(L[1])
  local bx, by = P0[1] + cos(a) * L[2], P0[2] + sin(a) * L[2]
  local cx, cy = P0[1] + cos(a) * L[2] * 0.5 + cos(a + 0.5) * 1.5, P0[2] + sin(a) * L[2] * 0.5 + sin(a + 0.5) * 1.5
  local m, n, T, S = A.blade(P0[1], P0[2], cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, L[3] * sin(pi * min(1, t * 0.82 + 0.16)) ^ 0.9)
  end, { fold = 0.35 })
  m:each(function(x, y) local k = K(x, y)
    if not lm:has(x, y) or abs(S[k]) < abs(LS[k]) then lm:set(x, y) ln[k], LT[k], LS[k] = n[k], T[k] + li * 10, S[k] end end)
end
-- rip off the upper-left lobe tip (torn edge)
A.tear(lm, 14, 37, -0.8, -0.6, 1.3, 9)

-- seeds: cx, cy, r
local seeds = { { 21, 47, 3.3 }, { 29, 44, 3.4 }, { 26, 51, 3.2 }, { 38, 45, 3.4 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3] - 0.3, 0.4, 0.85) end
-- pod slice (quirk)
local PX, PY = 41, 53
local pm = HP.mask()
for y = PY - 7, PY + 7 do for x = PX - 7, PX + 7 do
  local dx, dy = x - PX, y - PY
  local r, a = sqrt(dx * dx + dy * dy), atan(dy, dx)
  local R = 4.4 + 0.9 * cos(5 * (a + pi / 2))
  if r <= R then pm:set(x, y) end
end end
-- sprout from seed 4
local hp = { { 39, 43 }, { 40, 36 }, { 38, 30 }, { 39, 25 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 1.1 end)

local ltok = A.tok("leaf")
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 1, -1)
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- veins: midrib per lobe + side veins angled toward the tips
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k] % 10
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  local along = t * 18 - abs(s) * 3.5
  if t > 0.25 and t < 0.85 and abs(s) > 0.22 and abs(s) < 0.75 and abs(along - floor(along / 4.2 + 0.5) * 4.2) < 0.45 then
    A.step(c, lidx, LEAF, x, y, s < 0 and 1 or -1, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and (LT[k] % 10) > 0.15 then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 31, 56, 3 }, { 32, 57, 3 }, { 33, 58, 2 }, { 32, 56, 4 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- pod slice: green skin ring, pale flesh, five chambers with seeds
local ptok = A.tok("slice")
local pn = X.pillow(pm, 1.5)
local pidx = A.shade(c, pm, pn, { "#1d4a34", SL[1], SL[2], SL[3], SL[3], SL[4] }, { tok = ptok })
pm:shrink(1):each(function(x, y) c:put(x, y, (x + y) % 5 == 0 and SL[4] or SL[5], ptok) end)
for i = 0, 4 do local a = -pi / 2 + i * 2 * pi / 5
  local sx, sy = floor(PX + cos(a) * 2.4 + 0.5), floor(PY + sin(a) * 2.4 + 0.5)
  c:put(sx, sy, SL[1], ptok) end
c:put(PX, PY, SL[3], ptok)

-- hypocotyl (drawn before seeds so seed 4 sits over its foot)
local stok = A.tok("sprout")
hm:cut(seeds[4].m)
A.shade(c, hm, hn, HYPO, { tok = stok })
-- cotyledons: broad kidney shapes
local function coty(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.5)
  end, { fold = 0.2 })
  m:cut(hm)
  local idx = A.toneN(c, m, n, LEAF, { tok = stok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.15 and T[k] < 0.8 then A.step(c, idx, LEAF, x, y, S[k] <= 0 and 2 or -1, stok) end end)
  return m
end
local c1 = coty(38, 25, 33, 20, 28, 20, 3.4)
local c2 = coty(40, 25, 45, 20, 50, 20, 3.4)
-- first true leaf: three pointed lobes on a short petiole
local tl, tn = HP.mask(), {}
for _, a in ipairs{ -90, -135, -45 } do local r = math.rad(a)
  local L = (a == -90) and 7.5 or 5.5
  local m, n = A.blade(39, 22, 39 + cos(r) * L * 0.5, 22 + sin(r) * L * 0.5, 39 + cos(r) * L, 22 + sin(r) * L, function(t)
    if t > 0.98 then return -1 end return max(0.4, 2.1 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.8) end, { fold = 0.4 })
  m:each(function(x, y) tl:set(x, y) tn[K(x, y)] = n[K(x, y)] end)
end
tl:cut(c1):cut(c2)
local tidx = A.toneN(c, tl, tn, LEAF, { tok = stok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
for _, q in ipairs{ { 39, 21 }, { 39, 20 }, { 39, 19 }, { 39, 18 }, { 38, 20 }, { 40, 20 } } do A.step(c, tidx, LEAF, q[1], q[2], 1, stok) end

-- seeds last, back to front
table.sort(seeds, function(a, b) return a[2] < b[2] end)
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = A.tok("seed" .. i)
  A.toneN(c, vis, s.n, SEED, { bias = sb, tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.1, wrap = 0.3 })
  -- hilum eye (lower right, pale ring with dark dot) and glint upper left
  local hx, hy = floor(s[1] + 1.5), floor(s[2] + 1.2)
  if vis:has(hx, hy) then c:put(hx, hy, "#c9c2a8", tok) end
  if vis:has(hx + 1, hy) then c:put(hx + 1, hy, SEED[1], tok) end
  local gx, gy = floor(s[1] - 1.3), floor(s[2] - 1.4)
  if vis:has(gx, gy) then c:put(gx, gy, "#eef4f4", tok) end
end

A.save(c, NAME)

-- kapok-blossom-seed (final pass, Opus single pass). A puff of silky kapok floss (cream to cool lilac, combed fibre
-- streaks, stray strands on the rim) holding three round, glossy, near-black kapok seeds, resting on a scrap of the
-- palmate kapok leaf: two lance leaflets on a petiole stub, one torn short (midribs, veins, cool rim, AO + contact
-- shadow under the puff). The right seed has sprouted: a slim stem and a little palm of five leaflets, the tree's
-- leaf shape in miniature.
-- quirk: one seed has escaped on its own tuft of floss and drifts off to the upper left.
local NAME = "kapok-blossom-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#16343a", "#1f4e44", "#2c6a4a", "#438a50", "#68a85c", "#9cc876" }
local VEIN, COOL, TISSUE = "#c2e290", "#3c6a7e", "#d8ecb0"
local FLOSS = { "#6a6086", "#958cae", "#bfb7d0", "#ded7e4", "#f2ece6", "#fffaf0" }
local SEED = { "#140e12", "#241a1e", "#3a2a2a", "#56403a", "#7c6050", "#a88c74" }
local STEM = { "#3e4a36", "#5e7044", "#86985a", "#b4c47e" }
local SPR = { "#1c4636", "#2a6642", "#408a4a", "#62ac56", "#94cc6a", "#ccec9c" }

local function line(pts, f)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      f(floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5)) end
  end
end

-- leaf scrap: petiole stub at the left, two lance leaflets fanning right; the lower one torn short
local ltok = { r = { name = "leaf" } }
local l1m, l1n, L1T, L1S, len1 = A.blade(12, 52, 34, 45, 57, 48, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 5.2 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.7)
end, { fold = 0.42 })
local l2m, l2n, L2T, L2S, len2 = A.blade(12, 53, 26, 58, 46, 58, function(t)
  return max(0.5, 4.2 * sin(pi * min(1, t * 0.6 + 0.06)) ^ 0.7)
end, { fold = 0.42 })
local torn2 = A.tear(l2m, L2T, L2S, 0.86, { 0.03, -0.04, 0.02, -0.02, 0.05, -0.03, 0.01, 0 })
l2m:cut(l1m)

-- floss puff
local fm = HP.mask()
for _, e in ipairs{ { 21, 45, 6, 4.5 }, { 29, 41.5, 6.5, 5 }, { 37, 44.5, 5, 4 }, { 27, 48, 8, 3 }, { 17, 48, 4, 2.5 } } do
  fm:add(c:ellipse(e[1], e[2], e[3], e[4])) end
-- seeds: cx, cy, r
local seeds = { { 22, 44, 2.2 }, { 30, 47, 2.0 }, { 33, 41, 2.1 } }
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3]) s.n = X.sphere(s[1], s[2], s[3], s.m) end
-- drifting seed + tuft (quirk)
local tm = HP.mask()
for _, e in ipairs{ { 11, 26, 3.5, 2.2 }, { 14, 24.5, 2.5, 2 }, { 9, 24.5, 2, 1.5 } } do tm:add(c:ellipse(e[1], e[2], e[3], e[4])) end
local dsm = c:ellipse(11, 29, 1.5, 1.5)

local b1, b2 = {}, {}
X.ao(b1, l1m, fm, 1, -1) A.cast(b1, l1m, fm, 1, 2, -1)
X.ao(b2, l2m, l1m, 1, -1) A.cast(b2, l2m, l1m, 0, 1, -1) A.cast(b2, l2m, fm, 1, 2, -1)
A.leaf(c, l2m, l2n, L2T, L2S, { ramp = LEAF, vein = VEIN, cool = COOL, len = len2, torn = torn2, tissue = TISSUE, tok = ltok, bias = b2, per = 4.5, amb = 0.18 })
A.leaf(c, l1m, l1n, L1T, L1S, { ramp = LEAF, vein = VEIN, cool = COOL, len = len1, tok = ltok, bias = b1, per = 4.5, amb = 0.18 })
-- petiole stub
local ptok = { r = { name = "petiole" } }
local pm, pn = A.tube({ { 6, 56 }, { 8, 55 }, { 10, 54 }, { 13, 52 } }, function(t) return 1.0 end)
pm:cut(l1m):cut(l2m)
A.shade(c, pm, pn, STEM, { tok = ptok, cuts = { 0.3, 0.55, 0.8 } })
c:put(5, 57, STEM[3], ptok) c:put(6, 57, STEM[2], ptok)

-- sprout stem from seed 3, then the palm of leaflets
local stok = { r = { name = "sprout" } }
local sm, sn, ST, SS = A.tube({ { 34, 39 }, { 37, 33 }, { 36, 28 }, { 38, 22 } }, function(t) return 1.0 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local hub = { 38, 21 }
local leaflets = { { -90, 11 }, { -52, 10 }, { -128, 10 }, { -14, 8 }, { -166, 8 } }
local pal = HP.mask()
for i = #leaflets, 1, -1 do local L = leaflets[i]
  local a = L[1] * pi / 180
  local ux, uy = cos(a), sin(a)
  local ax, ay = hub[1] + ux * 1.2, hub[2] + uy * 1.2
  local bx, by = hub[1] + ux * L[2], hub[2] + uy * L[2]
  local cx, cy = (ax + bx) / 2 - uy * 0.6, (ay + by) / 2 + ux * 0.6
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.3, 1.9 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.8)
  end, { fold = 0.35 })
  m:cut(pal)
  local bb = {}
  X.ao(bb, m, pal, 1, -1)
  local idx = A.shade(c, m, n, SPR, { tok = stok, bias = bb, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.15 and T[k] < 0.85 and not bb[k] then c:put(x, y, S[k] <= 0 and SPR[6] or SPR[3], stok) end end)
  pal:add(m)
end
c:put(38, 21, STEM[2], stok) c:put(38, 22, STEM[2], stok)

-- floss: pillow tones + combed fibre streaks + stray strands
local ftok = { r = { name = "floss" } }
local fb = {}
local fn = X.pillow(fm, 4)
local fidx = A.shade(c, fm, fn, FLOSS, { tok = ftok, bias = fb, amb = 0.16, wrap = 0.35, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
fm:each(function(x, y) local k = K(x, y)
  local ph = (y * 1.0 + sin(x * 0.45) * 1.6 + x * 0.25) % 3.2
  if ph < 0.8 and not fm:edge():has(x, y) then c:put(x, y, FLOSS[max(1, (fidx[k] or 4) - 1)], ftok)
  elseif ph > 2.3 and ph < 2.9 and (fidx[k] or 1) >= 4 and X.hash(x, y, 2) > 0.4 then c:put(x, y, FLOSS[6], ftok) end
end)
for _, p in ipairs{ { 14, 46, 4 }, { 13, 45, 5 }, { 25, 36, 5 }, { 24, 35, 6 }, { 42, 45, 3 }, { 43, 46, 3 }, { 36, 50, 3 } } do
  c:put(p[1], p[2], FLOSS[p[3]], ftok) end

-- seeds: glossy round, AO ring on the floss, cream glint
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  s.m:grow(1):cut(s.m):each(function(x, y) if fm:has(x, y) and not seeds[3].m:has(x, y) then
    local k = K(x, y) local j = max(1, (fidx[k] or 3) - 2) c:put(x, y, FLOSS[j], ftok) end end)
  local vis = s.m:copy()
  A.seed(c, vis, s.n, SEED, { tok = tok, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, rim = "#4a4a66" })
  local gx, gy = A.specAt(vis, s.n, 40) if gx then c:put(gx, gy, "#fff4d6", tok) end
end
-- a strand of floss draped over seed 1
c:put(23, 45, FLOSS[4], ftok) c:put(24, 44, FLOSS[5], ftok)
-- sprout foot over seed 3
c:put(34, 39, STEM[3], stok) c:put(35, 38, STEM[2], stok)

-- quirk: drifting seed on its tuft
do local tok = { r = { name = "tuft" } }
  local tn = X.pillow(tm, 2)
  local ti = A.shade(c, tm, tn, FLOSS, { tok = tok, amb = 0.2, wrap = 0.35, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
  tm:each(function(x, y) if (x + y * 2) % 4 == 0 and not tm:edge():has(x, y) then c:put(x, y, FLOSS[max(1, ti[K(x, y)] - 1)], tok) end end)
  -- fibres hanging to the seed
  c:put(10, 28, FLOSS[3], tok) c:put(12, 28, FLOSS[4], tok)
  local sn2 = X.sphere(11, 29, 1.5, dsm)
  A.seed(c, dsm, sn2, SEED, { tok = { r = { name = "dseed" } }, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
  c:put(10, 29, SEED[6], tok)
  c:put(10, 22, FLOSS[6], tok)
end

A.save(c, NAME)

-- california-poppy-seed (final pass, Opus aB13_4). Tiny round slate-grey poppy seeds with a netted, pitted coat spill
-- from the open end of a slender, ribbed straw-tan seed pod lying on a torn scrap of the poppy's finely divided,
-- glaucous blue-green leaf (narrow finger lobes, pale midribs, ragged torn base, cool rim, AO + contact shadows).
-- One seed has germinated: thin stem, two long linear seed-leaves and a first three-fingered true leaf.
-- quirk: the pod's other half has sprung into a tight coil, the way poppy pods burst.
local NAME = "california-poppy-seed"
local M = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_4.lua")
local HP, X, K = M.HP, M.X, M.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = M.new(NAME)

local GLAU = { "#1c3640", "#264e50", "#386a60", "#538672", "#78a68a", "#a8c8a8" }
local VEIN, TORN, COOL = "#c4dcc0", "#dcecc8", "#3c5e7c"
local POD = { "#4a3a2a", "#6e5636", "#957844", "#b89c5a", "#d6be7c", "#efdca6" }
local SEED = { "#1e1b26", "#2e2b38", "#44404e", "#5e5968", "#7f798a", "#aaa3b2" }
local COT = { "#22504a", "#346c58", "#4c8a68", "#6aa87c", "#90c494", "#bcdcb4" }
local STEM = { "#4e7e5c", "#7aa47a", "#a8c8a0", "#d6e8c8" }

-- seeds (cx, cy, r); first one sprouts
local seeds = { { 17, 45, 1.9 }, { 21, 49.5, 1.8 }, { 26, 51.5, 1.8 }, { 15.5, 50.5, 1.7 }, { 25.5, 46.6, 1.5 } }
local allS = HP.mask()
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3]) allS:add(s.m) end

-- pod valve lying on the leaf
local pm, pn, PT, PS = M.tube({ { 24, 46.8 }, { 31, 46 }, { 39, 45 }, { 46, 43.5 } }, function(t) return 2.2 - 0.6 * t end)
-- coiled valve springing up from the pod's right end
local cpts = {}
local cx0, cy0 = 50, 39.5
for i = 0, 90 do local u = i / 90
  local th = 2.4 - u * 2.35 * pi
  local r = 5.6 - 3.4 * u
  cpts[#cpts + 1] = { cx0 + r * cos(th), cy0 + r * sin(th) } end
local km, kn, KT, KS = M.ptube(cpts, function(t) return 1.15 - 0.35 * t end)

-- leaf scrap: rachis + narrow finger lobes
local leaf, lnrm, LS = HP.mask(), {}, {}
local function lobe(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = M.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * sin(pi * min(1, t * 0.75 + 0.25)) ^ 0.6)
  end, { fold = 0.35 })
  m:each(function(x, y) local k = K(x, y) if not leaf:has(x, y) or abs(S[k]) < abs(LS[k]) then lnrm[k], LS[k] = n[k], S[k] end end)
  leaf:add(m)
end
lobe(57, 55, 38, 52, 10, 50, 5.8)
lobe(44, 52, 42, 45, 38, 38, 3.2)
lobe(34, 53, 29, 57, 24, 60, 2.6)
lobe(30, 50, 22, 45, 10, 41, 3.0)
lobe(48, 55, 52, 58, 55, 60, 2.0)
local torn = M.tear(leaf, 53, 55, 1, -0.25, 1.4, 9)
local over = HP.mask():add(allS):add(pm):add(km)
local bias = {}
X.ao(bias, leaf, over, 1, -1) M.cast(bias, leaf, over, 1, 1, -1) M.cast(bias, leaf, over, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = M.toneN(c, leaf, lnrm, GLAU, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.28, cuts = { 0.24, 0.4, 0.56, 0.72, 0.87 } })
leaf:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if abs(LS[k]) < 0.14 then c:put(x, y, VEIN, ltok) elseif LS[k] > 0.14 and LS[k] < 0.32 then c:put(x, y, GLAU[max(1, lidx[k] - 1)], ltok) end
end)
local rim = X.rim(lnrm)
leaf:edge():each(function(x, y) local k = K(x, y) if not bias[k] and rim[k] > 0.3 and not torn:has(x, y) then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) c:put(x, y, TORN, ltok) end)

-- pod: ribbed straw valve, hollow inside showing a pale lining toward the open end
do
  local tok = { r = { name = "pod" } }
  local b = {} X.ao(b, pm, km, 1, -1)
  local id = M.toneN(c, pm, pn, POD, { tok = tok, bias = b, amb = 0.12, wrap = 0.3 })
  pm:each(function(x, y) local k = K(x, y)
    if abs(PS[k] - 0.1) < 0.18 and PT[k] < 0.92 then c:put(x, y, POD[max(1, id[k] - 2)], tok) end   -- rib groove
    if PS[k] < -0.35 and PS[k] > -0.7 and PT[k] > 0.15 and PT[k] < 0.8 and floor(PT[k] * 14) % 3 ~= 0 then c:put(x, y, POD[6], tok) end
  end)
  -- open end: dark mouth
  c:put(24, 46, POD[1], tok) c:put(24, 47, POD[1], tok) c:put(25, 47, POD[2], tok)
  local bx, by = M.specAt(pm, pn, 40) c:put(bx, by, "#fff2cc", tok)
end
-- coil
do
  local tok = { r = { name = "coil" } }
  local b = {}
  local id = M.toneN(c, km, kn, POD, { tok = tok, amb = 0.12, wrap = 0.3 })
  -- where the coil crosses itself, later turns sit over earlier: darken the turn beneath with a 1px edge
  km:each(function(x, y) local k = K(x, y)
    if KS[k] > 0.5 then c:put(x, y, POD[max(1, id[k] - 1)], tok) end
    if KS[k] < -0.3 and KS[k] > -0.7 and floor(KT[k] * 30) % 3 == 0 then c:put(x, y, POD[6], tok) end
  end)
end

-- sprout
local stok = { r = { name = "stem" } }
local sm, sn = M.tube({ { 17, 43 }, { 15, 36 }, { 21, 30 }, { 20, 23 } }, function(t) return 0.95 end)
sm:cut(seeds[1].m)
M.toneN(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local function linear(ax, ay, cx, cy, bx, by, w, tok)
  local m, n, T, S = M.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.8 + 0.12)) ^ 0.4)
  end, { fold = 0.3 })
  m:cut(sm)
  local id = M.toneN(c, m, n, COT, { tok = tok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.2 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, COT[min(6, id[k] + 1)], tok) end end)
  return m
end
local ctok = { r = { name = "cot" } }
local c1 = linear(20, 24, 15, 21, 9, 21, 1.5, ctok)
local c2 = linear(20, 24, 25, 21, 31, 20, 1.5, ctok)
-- forked cotyledon tips
c:put(9, 20, COT[4], ctok) c:put(31, 19, COT[4], ctok)
-- first true leaf: petiole + three narrow fingers
local ttok = { r = { name = "true" } }
for y = 17, 23 do c:put(20 + ((y < 20) and 1 or 0), y, STEM[3], stok) end
linear(21, 17, 18, 14, 15, 12, 1.2, ttok)
linear(21, 17, 21, 13, 22, 9, 1.3, ttok)
linear(21, 17, 24, 15, 27, 13, 1.2, ttok)

-- seeds: pitted netted coat
for i = #seeds, 1, -1 do local s = seeds[i]
  local tok = { r = { name = "seed" .. i } }
  local cutm = (i == 5) and pm or nil
  local m, id = M.ball(c, s[1], s[2], s[3], s[3], 0, SEED, { tok = tok, cut = cutm, glint = "#e6e2f0" })
  m:shrink(1):each(function(x, y) if X.hash(x, y, i) < 0.3 and id[K(x, y)] and id[K(x, y)] < 6 then c:put(x, y, SEED[max(1, id[K(x, y)] - 1)], tok) end end)
end
-- the sprouting seed: split coat, pale root
c:put(17, 44, "#e4e6c8", { r = { name = "seed1" } })
for _, p in ipairs{ { 18, 47 }, { 18, 48 }, { 19, 49 } } do c:put(p[1], p[2], "#e8e2c8", { r = { name = "root" } }) end

M.save(c, NAME)

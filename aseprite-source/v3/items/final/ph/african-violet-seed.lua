-- african-violet-seed (final pass, Opus). Saintpaulia seed is dust-fine, so the seed here is the real thing as it is
-- found: a dry, round seed capsule (6-tone tan, papery ridges, dark split, dried style, specular) lying on a torn
-- piece of thick velvety violet leaf, with a fan of dust seeds spilling out of the split onto the leaf. The leaf scrap
-- is round-ovate with a scalloped (crenate) margin, sunken arched veins and a pale midrib, velvet fuzz specks and
-- bright hairs on the lit rim; its front edge curls up to show the wine-red underside violets have. A seedling has
-- come up out of the spill: three round, scalloped, fuzzy little leaves on short petioles, the rosette in miniature.
-- quirk: one shrivelled purple petal is still stuck to the capsule.
local NAME = "african-violet-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#16333a", "#1f4c3e", "#2a6844", "#3b844c", "#56a056", "#80bc66" }
local FUZZ, HAIR, VEIN = "#94c47a", "#b4dc94", "#8cb874"
local UNDER = { "#3c1636", "#5c2246", "#7e3258", "#a04a6c", "#c06c86", "#da96a6" }
local CAP   = { "#3a2822", "#5a402e", "#7c5c3e", "#9e7a52", "#bf9b6a", "#ddc08e" }
local DUST  = { "#3a2418", "#6a4428", "#a27a4a" }
local PET   = { "#3c2462", "#5a3a8e", "#7c5cba", "#a488dc" }
local PETI  = { "#3f6e4a", "#679a5a", "#98c47c", "#c6e2a4" }
local SL    = { "#1f4a34", "#2f6a3a", "#468e40", "#66ad48", "#8fca58", "#c0e27a" }

-- leaf scrap: broad round-ovate blade, scalloped, torn across the base (left)
local SC = 5.8
local lm, ln, LT, LS, len = A.blade(6, 50, 31, 47, 58, 35, function(t)
  if t > 0.99 then return -1 end
  local e = sqrt(max(0, 1 - (1.9 * t - 0.95) ^ 2))
  local w = 8.0 * e ^ 0.95
  return max(0.5, w - 0.45 * (1 - abs(sin(t * 49 / SC * pi))))
end, { fold = 0.32 })
A.tear(lm, LT, 0.04, 0.1, 5)
-- curled-up front edge (underside showing)
local curl = HP.mask()
lm:each(function(x, y) local k = K(x, y) if LS[k] > 0.66 and LT[k] > 0.35 and LT[k] < 0.86 then curl:set(x, y) end end)

-- capsule + petal + style
local ccx, ccy = 44, 41
local cm, cn = A.ovalM(ccx, ccy, 5.0, 4.3, -0.4, 0.9)
local pm = c:poly{ { 44, 37 }, { 46, 35 }, { 49, 35 }, { 50, 37 }, { 47, 39 } }

-- dust seeds spilling to the lower left out of the split
local dust = {}
for i = 1, 26 do
  local a = 2.0 + X.hash(i, 1, 31) * 1.5
  local r = 4.8 + X.hash(i, 2, 31) ^ 1.6 * 7
  local x, y = floor(ccx - 2 + cos(a) * r * 1.05 + .5), floor(ccy + 2 + sin(a) * r * 0.75 + .5)
  dust[#dust + 1] = { x, y, 1 + floor(X.hash(i, 3, 31) * 3) }
end

-- leaf tone
local bias = {}
X.ao(bias, lm, cm, 1, -1) A.cast(bias, lm, cm, 1, 2, -1) A.cast(bias, lm, cm, 2, 2, -1)
local ltok = A.tok("leaf")
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.12, wrap = 0.3 })
A.veins(c, lm, LT, LS, len, LEAF, VEIN, { tok = ltok, skip = bias, per = 8.5, sweep = 6.5, t0 = 0.06, t1 = 0.9, hiV = 3, reach = 0.6, rib = 0.1 })
-- velvet fuzz specks + bright hairs on the lit rim
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and (lidx[k] or 1) >= 4 and X.hash(x, y, 17) > 0.9 then c:put(x, y, FUZZ, ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] < -0.5 and LT[k] > 0.15 and X.hash(x, y, 3) > 0.35 then c:put(x, y, HAIR, ltok) end
  if LT[k] < 0.1 then c:put(x, y, LEAF[5], ltok) end end)
-- curled underside: wine red, lit fold line, darker toward the rim
local utok = A.tok("under")
curl:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local i = s < 0.72 and 6 or (s < 0.8 and 4 or 3)
  if X.hash(x, y, 9) > 0.8 then i = i - 1 end
  c:put(x, y, UNDER[i], utok)
end)
curl:grow(1):cut(curl):clip(lm):each(function(x, y) c:put(x, y, LEAF[2], ltok) end)   -- AO line above the curl

-- dust on the leaf (cast a 1 px shadow to the lower right)
for _, d in ipairs(dust) do
  if lm:has(d[1], d[2]) and not cm:has(d[1], d[2]) and not curl:has(d[1], d[2]) then
    c:put(d[1], d[2], DUST[d[3]], ltok)
    if d[3] == 3 and lm:has(d[1] + 1, d[2]) then c:put(d[1] + 1, d[2], DUST[1], ltok) end
  end
end

-- capsule: papery ridges, dark split toward the spill, dried style
local ctok = A.tok("capsule")
local cb = {}
cm:each(function(x, y) local k = K(x, y)
  local a = math.atan(y - ccy, x - ccx)
  if (a / pi * 3 + 0.5) % 1 < 0.2 then cb[k] = -1 end
end)
A.shade(c, cm, cn, CAP, { tok = ctok, bias = cb, amb = 0.06, wrap = 0.2 })
A.bounce(c, cm, cn, "#7a7290", 0.66, ctok)
for _, p in ipairs{ { 40, 41 }, { 41, 42 }, { 40, 42 }, { 41, 43 }, { 42, 44 }, { 43, 44 } } do c:put(p[1], p[2], CAP[1], ctok) end
c:put(39, 42, CAP[2], ctok) c:put(42, 43, CAP[2], ctok)
local sx, sy = A.specAt(cm, cn, 30)
c:put(sx, sy, "#fff0d0", ctok) c:put(sx + 1, sy, CAP[6], ctok)
-- dried style: thin wiry tail off the top-right of the capsule
for _, p in ipairs{ { 50, 41, 3 }, { 51, 40, 2 }, { 52, 40, 3 }, { 53, 39, 2 } } do c:put(p[1], p[2], CAP[p[3]], ctok) end

-- quirk: shrivelled petal
local ptok = A.tok("petal")
pm:each(function(x, y) c:put(x, y, (x + y < 83) and PET[3] or PET[2], ptok) end)
c:put(46, 36, PET[4], ptok) c:put(47, 36, PET[4], ptok) c:put(48, 38, PET[1], ptok) c:put(49, 37, PET[2], ptok)

-- seedling: a tiny rosette of three spoon-shaped, scalloped, velvety leaves on short petioles
local rose = {
  { 25, 44, 20, 37, 11, 31, 5.0 },
  { 27, 44, 26, 35, 28, 21, 4.3 },
  { 28, 44, 34, 38, 41, 30, 5.0 },
}
local bl = {}
for i, q in ipairs(rose) do
  local L0 = sqrt((q[5] - q[1]) ^ 2 + (q[6] - q[2]) ^ 2)
  local m, n, T, S, L = A.blade(q[1], q[2], q[3], q[4], q[5], q[6], function(t)
    if t > 0.985 then return -1 end
    if t < 0.36 then return 0.8 end                                 -- petiole
    local u = (t - 0.36) / 0.64
    local w = q[7] * sqrt(max(0, 1 - ((u - 0.56) / 0.56) ^ 2)) ^ 0.8  -- round spoon blade
    return max(0.8, w - 0.45 * (1 - abs(sin(u * L0 * 0.64 * pi / 2.8))))
  end, { fold = 0.25 })
  bl[i] = { m = m, n = n, T = T, S = S }
end
local roseAll = HP.mask() for _, f in ipairs(bl) do roseAll:add(f.m) end
roseAll:grow(1):cut(roseAll):clip(lm):each(function(x, y) if not cm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
roseAll:shift(1, 2):cut(roseAll):clip(lm):each(function(x, y) if not cm:has(x, y) and not curl:has(x, y) then c:put(x, y, LEAF[2], ltok) end end)
-- paint 2 (back, centre) first, then 1 and 3 over it
for _, i in ipairs{ 2, 1, 3 } do
  local f = bl[i]
  local m = f.m:copy()
  local tk = A.tok("sleaf" .. i)
  local sb = {}
  if i ~= 2 then X.ao(sb, bl[2].m, m, 1, -1) end
  -- petiole part in stem colours, blade part in leaf ramp
  local pm, bm = HP.mask(), HP.mask()
  m:each(function(x, y) if f.T[K(x, y)] < 0.38 then pm:set(x, y) else bm:set(x, y) end end)
  A.shade(c, pm, f.n, PETI, { tok = tk, cuts = { 0.28, 0.52, 0.76 }, amb = 0.15, wrap = 0.3 })
  local idx = A.toneN(c, bm, f.n, SL, { tok = tk, cuts = A.CUTS, amb = 0.1, wrap = 0.28 })
  bm:each(function(x, y) local k = K(x, y)
    if abs(f.S[k]) < 0.16 and f.T[k] < 0.9 then c:put(x, y, f.S[k] <= 0 and SL[6] or SL[3], tk)
    elseif (idx[k] or 1) >= 4 and X.hash(x, y, 23) > 0.84 then c:put(x, y, FUZZ, tk) end
  end)
  bm:edge():each(function(x, y) local k = K(x, y) if f.S[k] < -0.5 and X.hash(x, y, 5) > 0.4 then c:put(x, y, HAIR, tk) end end)
end
A.save(c, NAME)

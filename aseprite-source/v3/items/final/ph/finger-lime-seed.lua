-- finger-lime-seed (B3, Opus single pass). Three pale, pointed finger-lime seeds on a torn glossy citrus-leaf scrap
-- (elliptic blade, jagged torn base, pale midrib + swept laterals, translucent oil-gland dots, one waxy gloss streak,
-- AO + contact shadow under each seed). The right seed has germinated: green stem with one sharp citrus thorn, two
-- thick rounded cotyledons and a first elliptic citrus leaf on a short petiole.
-- quirk: one glossy pink lime "caviar" pearl has rolled onto the leaf beside the seeds.
local NAME = "finger-lime-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#143a30", "#1d5238", "#2a6d40", "#3f8c45", "#63ad50", "#a0d26c" }
local GLAND, GLOSS = "#c8e890", "#e6f6b8"
local SEED = { "#5c4130", "#8a6a4a", "#b6956a", "#d6ba8c", "#eedab0", "#fbf0d6" }
local STEM = { "#2a5a3a", "#3f7c44", "#64a052", "#94c46a" }
local PEARL = { "#7d2c5e", "#b8466e", "#e0708a", "#f6a0ae", "#ffd4d8" }
local THORN = { "#5a4a2c", "#9a8a52", "#d6cc90" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 18, 47, 3.5, 2.1, -0.55 }, { 27, 46, 3.7, 2.2, 0.3 }, { 37, 43, 3.4, 2.1, -0.15 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end
local pearl = HP.mask() do local pm = A.oval(47.5, 45.5, 2.2, 2.2, 0, 1) pearl = pm end

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 45, 57, 39, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, 0.14 + t * 0.86)) ^ 0.75)
end, { fold = 0.32 })
-- torn base: jagged edge across the blade
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local jag = 2.2 + 3.2 * X.hash(floor(LS[k] * 5 + 9), 3, 7)
  if LT[k] * len < jag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
local stemFoot = c:rect(36, 39, 38, 41)
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, pearl, 1, -1) A.cast(bias, lm, pearl, 1, 1, -1)
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[4], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 5.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.15 and abs(s) < 0.72 and t > 0.08 and t < 0.88 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) return end
  -- waxy gloss streak on the lit half
  if s > -0.62 and s < -0.42 and t > 0.32 and t < 0.52 then c:put(x, y, GLOSS, ltok) return end
  -- oil glands: sparse pale dots
  if abs(s) > 0.25 and abs(s) < 0.8 and X.hash(x, y, 11) > 0.955 then c:put(x, y, s < 0 and GLAND or LEAF[5], ltok) end
end)
-- dark torn fibre along the torn base
for _, k in ipairs(cut) do end
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] * len < 6.5 and not bias[k] then c:put(x, y, LEAF[2], ltok) end end)
-- cool reflected edge on the lower-right margin
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.85 then c:put(x, y, "#2f6a6e", ltok) end end)

-- sprout: stem, thorn, cotyledons, first leaf
local stok = A.tok("stem")
local sm, sn = A.tube({ { 37, 41 }, { 36, 34 }, { 38, 28 }, { 38, 21 } }, function(t) return 1.05 end)
A.tone(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- thorn on the right of the stem
A.map(c, { "ab", ".bc" }, 39, 30, { a = THORN[1], b = THORN[2], c = THORN[3] }, stok)
local function cotyledon(cx, cy, ang)
  local m, n = A.oval(cx, cy, 3.6, 2.0, ang, 0.7)
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.15, wrap = 0.3 })
  return m
end
local cl = cotyledon(33, 25, 0.35)
local cr = cotyledon(42.5, 25, -0.35)
-- first citrus leaf on a short winged petiole
local tm, tn, TT, TS = A.blade(38, 22, 37, 15, 44, 8, function(t)
  if t > 0.985 then return -1 end
  if t < 0.2 then return 0.7 + t * 2 end
  return max(0.5, 3.8 * sin(pi * min(1, (t - 0.2) / 0.8 * 0.88 + 0.1)) ^ 0.7)
end, { fold = 0.35 })
tm:cut(cl):cut(cr)
A.toneN(c, tm, tn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.16 and TT[k] > 0.15 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
-- AO where cotyledons meet the stem top
for _, p in ipairs{ { 36, 24 }, { 40, 24 } } do c:put(p[1], p[2], LEAF[1], ltok) end

-- seeds: pointed ovoids, raphe line, AO between neighbours, one glint each
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = A.tok("seed" .. i)
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  -- raphe: a darker line along the shade half
  for u = -0.55, 0.55, 0.1 do
    local px = s[1] + u * s[3] * ca - 0.45 * s[4] * sa
    local py = s[2] + u * s[3] * sa + 0.45 * s[4] * ca
    local xi, yi = floor(px + .5), floor(py + .5)
    if vis:has(xi, yi) then A.step(c, idx, SEED, xi, yi, -1, tok) end
  end
  -- pointed end
  local tx, ty = floor(s[1] + (s[3] + 1.3) * ca + .5), floor(s[2] + (s[3] + 1.3) * sa + .5)
  if not vis:has(tx, ty) then c:put(tx, ty, SEED[3], tok) end
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) end
end

-- quirk: pink citrus pearl, glossy
local ptok = A.tok("pearl")
local pm, pn = A.oval(47.5, 45.5, 2.2, 2.2, 0, 1)
A.toneN(c, pm, pn, PEARL, { tok = ptok, cuts = { 0.22, 0.45, 0.66, 0.85 }, amb = 0.15, wrap = 0.3 })
c:put(46, 44, "#fff4e8", ptok)
c:put(49, 47, "#c47ab0", ptok)

A.save(c, NAME)

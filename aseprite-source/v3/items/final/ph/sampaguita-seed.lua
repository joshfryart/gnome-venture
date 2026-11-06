-- sampaguita-seed (final, single pass). Three tiny glossy plum-black jasmine seeds, each with a pale pitted hilum, lying
-- on a torn scrap of Arabian jasmine leaf (ovate, acuminate tip, glossy, midrib + arching side veins, ragged torn
-- base and a bite out of the margin). The right seed has germinated: a pale twining stem, an opposite pair of ovate
-- leaves with the same arching veins, and a bud on top.
-- Material: ellipsoid light on 6-tone seed and leaf ramps, V-fold leaf, cool reflected edge, AO + contact shadow
-- under each seed, split seed coat at the sprout foot, specular glints on the gloss.
-- quirk: the seedling already carries a tiny white star blossom.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("sampaguita-seed")
local hash = A.hash

local LEAF = { "#112f2d", "#1a4a36", "#276a40", "#3c8c4a", "#5fae56", "#92cf6c" }
local VEIN, COOL = "#b9e286", "#2f6a70"
local SEED = { "#1c1224", "#2f1d38", "#47294f", "#64406e", "#86628f", "#b394bb" }
local STEM = { "#4d8a52", "#82b868", "#b4dc92", "#e0f2bc" }
local PET  = { "#8f86b4", "#bdb6d6", "#e0dcec", "#f6f3f1", "#fffaf0" }
local ltok = { r = { name = "leaf" } }

-- leaf scrap on the diagonal, ovate with a drawn-out tip (widest about a third along)
local ax, ay, cx, cy, bx, by = 8, 55, 32, 51, 57, 44
local lm, ln, LT, LS, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.6 * sin(pi * min(1, t ^ 0.72 * 0.99 + 0.005)) ^ 0.95 * (t > 0.7 and (1 - (t - 0.7) * 0.5) or 1))
end, { fold = 0.4 })
-- torn base and a bite out of the lower margin
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local u, s = LT[k] * len, LS[k]
  local umin = 1.5 + hash(floor((s + 1) * 4), 5, 2) * 3.5 + abs(s) * 2
  if u < umin then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bite = c:ellipse(46, 41, 3.2, 2.4)
lm:cut(bite)
-- seeds
local seeds = { { 17, 53, 4.4, 2.9, 0.12 }, { 28, 50.5, 4.2, 2.8, -0.2 }, { 40, 47.5, 4.3, 2.8, -1.45 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- arching side veins, swept toward the tip
  local d = (t * len - abs(s) * 8.6 * 1.25) % 5.2
  if t > 0.1 and t < 0.9 and abs(s) > 0.2 and abs(s) < 0.78 and d < 0.85 then
    c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- cool reflected light on the lower-right margin; pale torn fibre along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end
  if LT[k] * len < 5 then c:put(x, y, LEAF[2], ltok) end
end)
bite:grow(1):cut(bite):each(function(x, y) if lm:has(x, y) then c:put(x, y, LEAF[2], ltok) end end)

-- sprout: stem from the right seed, up and slightly twining
local stok = { r = { name = "stem" } }
local sp = { { 40, 46 }, { 36, 39 }, { 44, 32 }, { 41, 24 } }
local sm, sn = G.tube(sp, function(t) return 1.15 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
-- opposite ovate leaves at the node (y~27), with arching veins
local function sleaf(x0, y0, mx, my, x1, y1, w)
  local m, n, T, S, L = G.blade(x0, y0, mx, my, x1, y1, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t ^ 0.7 * 0.99 + 0.01)) ^ 0.9)
  end, { fold = 0.38 })
  m:cut(sm)
  local ix = G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.16 and t > 0.05 and t < 0.9 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
    local d = (t * L - abs(s) * w * 1.2) % 3.6
    if t > 0.2 and t < 0.85 and abs(s) > 0.3 and abs(s) < 0.8 and d < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end)
  return m
end
sleaf(43, 32, 50, 28, 58, 29, 3.4)
sleaf(40, 32, 33, 29, 24, 25, 3.6)
-- bud + the quirk blossom on top: six lit petals round a gold eye
local fx, fy = 41, 18
local fl = HP.mask()
local ptok = { r = { name = "petal" } }
for i = 0, 5 do
  local a = -pi / 2 + i * pi / 3 + 0.18
  local ux, uy = cos(a), sin(a)
  local pm = G.rell(fx + ux * 2.9, fy + uy * 2.9, ux, uy, 3.0, 1.55)
  pm:each(function(x, y)
    local k = K(x, y)
    local lit = -(ux * 0.55 + uy * 0.7)
    local dxp, dyp = x - fx, y - fy
    local r = sqrt(dxp * dxp + dyp * dyp)
    local v = 0.5 + 0.35 * lit + (r < 3 and -0.18 or 0.08)
    local ii = max(1, min(5, floor(v * 5.4) + 1))
    c:put(x, y, PET[ii], ptok)
  end)
  fl:add(pm)
end
for _, q in ipairs{ { fx, fy, "#f5b82e" }, { fx - 1, fy, "#ffe38a" }, { fx, fy - 1, "#d98322" } } do c:put(q[1], q[2], q[3], ptok) end
-- sprout stem meets the flower: a small green calyx
c:put(41, 24, LEAF[5], ptok) c:put(42, 24, LEAF[3], ptok) c:put(40, 24, LEAF[4], ptok)

-- seeds last: glossy plum-black, pale pitted hilum at one end, split coat where the sprout leaves
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = G.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.1, wrap = 0.2 })
  -- cool reflected rim on the shade side
  local rim = X.rim(s.n)
  vis:edge():each(function(x, y) local k = K(x, y) if (rim[k] or 0) > 0.8 and not sb[k] then c:put(x, y, "#6a5a9a", tok) end end)
  -- hilum: pale pit at the lower-left end
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] - ca * (s[3] - 1.2) + 0.5), floor(s[2] - sa * (s[3] - 1.2) + 0.5)
  if i < 3 then
    c:put(hx, hy, "#e8d9b8", tok) c:put(hx, hy + 1, "#a88e6a", tok)
  end
  -- specular
  local sx, sy = G.specAt(s.m, s.n, 30)
  if sx then c:put(sx, sy, "#fff4e0", tok) c:put(sx + 1, sy, SEED[6], tok) end
end
-- the sprouting seed: coat split, pale green shoot showing
local s3 = seeds[3]
for _, q in ipairs{ { 40, 46 }, { 40, 47 }, { 40, 48 } } do c:put(q[1], q[2], "#e8d9b8", { r = { name = "crack" } }) end
c:put(40, 45, STEM[3], stok) c:put(41, 45, STEM[2], stok) c:put(39, 45, STEM[2], stok)
A.save(c, "sampaguita-seed")

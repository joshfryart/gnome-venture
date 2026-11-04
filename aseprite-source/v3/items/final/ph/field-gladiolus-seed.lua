-- field-gladiolus-seed (final, Opus aB31_2). Two flat winged gladiolus seeds (glossy chestnut body inside a broad
-- papery tan wing with radial veins) on a torn strip of gladiolus leaf (sword leaf: strong midrib, parallel veins,
-- ragged torn ends, cool reflected lower edge, AO + contact shadow under each seed). A third seed has sprouted:
-- pale hypocotyl and a fan of two sword-shaped blades (folded midrib, parallel veins) showing the gladiolus leaf.
-- quirk: a single fallen magenta floret petal has landed on the leaf scrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt, atan = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt, math.atan
local NAME = "field-gladiolus-seed"
local c = A.new(NAME)
local LEAF = { "#183c34", "#235a40", "#317848", "#4a9750", "#72b65a", "#a6d474" }
local BLADE = { "#1f4a38", "#2c6a44", "#3f8a4a", "#5eaa52", "#8cc862", "#c0e488" }
local WING = { "#6a4a30", "#94703f", "#bd9858", "#dcbc7c", "#f0dcaa" }
local SEED = { "#2e1a1c", "#4e2a22", "#74402a", "#9a5a34", "#c27e4a", "#e8b07a" }
local PET = { "#7d2c5e", "#c94f84", "#ec6fa0", "#ffa8c8" }
local COOL, VEIN = "#3a6c72", "#c2e48c"

-- torn sword-leaf strip on the diagonal
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 49, 57, 39, function(t) return 5.6 - 0.8 * t end, { fold = 0.3 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local j0 = 0.02 + 0.055 * abs(sin(s * 6.5 + 1)) + 0.03 * X.hash(floor(s * 4), 1, 3)
  local j1 = 0.985 - 0.06 * abs(sin(s * 5.2 + 0.4)) - 0.03 * X.hash(floor(s * 4), 2, 5)
  if t < j0 or t > j1 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: cx, cy, wing rx, ry, angle
local seeds = { { 17, 49, 5.2, 4.0, 0.25 }, { 30, 45, 5.0, 3.9, -0.35 }, { 44, 42, 4.4, 3.4, 0.1 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.35)
  s.bm, s.bn = A.oval(s[1] - 0.6, s[2] - 0.3, s[3] * 0.48, s[4] * 0.52, s[5], 0.9)
end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
-- petal (quirk) on the lower part of the strip
local pm, pn = A.oval(39, 47.5, 2.8, 1.5, -0.5, 0.6)
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 1, -1)

local ltok = A.tok("leaf")
local lidx = X.tone(c, lm, X.light(ln, { amb = 0.15, wrap = 0.3 }), LEAF, { cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, bias = bias, tok = ltok })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- parallel veins along the strip
  for _, v in ipairs{ -0.52, 0.42 } do
    if abs(s - v) < 0.1 then c:put(x, y, LEAF[min(6, max(1, lidx[k] + (v < 0 and 1 or -1)))], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 then c:put(x, y, COOL, ltok) end end)
-- torn ends: pale ragged fibres
lm:each(function(x, y) local k = K(x, y)
  if (LT[k] < 0.1 or LT[k] > 0.9) and not lm:has(x + (LT[k] < 0.5 and -1 or 1), y) and not bias[k] then c:put(x, y, "#b6d888", ltok) end end)

-- sprout from seed 3: pale hypocotyl, two sword blades in a fan
local stok = A.tok("sprout")
local hm, hn = A.tube({ {45, 41}, {45, 38}, {44, 36}, {44, 34} }, function(t) return 1.0 end)
hm:cut(seeds[3].m)
X.tone(c, hm, X.light(hn, { amb = 0.2, wrap = 0.3 }), { "#5a8a52", "#8ab86e", "#bcdc98", "#e2f2bc" }, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function sword(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    if t < 0.72 then return W * (0.75 + 0.25 * min(1, t * 4)) end
    return W * (1 - (t - 0.72) / 0.28) ^ 0.8
  end, { fold = 0.5 })
  return m, n, T, S
end
local b1, b1n, B1T, B1S = sword(44, 35, 42, 24, 39, 11, 1.7)
local b2, b2n, B2T, B2S = sword(45, 35, 49, 27, 53, 18, 1.5)
b2:cut(b1)
local bb = {}
X.ao(bb, b2, b1, 1, -1)
for _, bl in ipairs{ { b2, b2n, B2T, B2S }, { b1, b1n, B1T, B1S } } do
  local idx = X.tone(c, bl[1], X.light(bl[2], { amb = 0.12, wrap = 0.3 }), BLADE, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.84 }, bias = bb, tok = stok })
  bl[1]:each(function(x, y) local k = K(x, y) local s, t = bl[4][k], bl[3][k]
    if abs(s) < 0.16 and t > 0.06 and t < 0.86 and not bb[k] then c:put(x, y, s <= 0 and BLADE[6] or BLADE[2], stok) end
    if s > 0.72 and t > 0.1 and t < 0.8 and idx[k] <= 3 then c:put(x, y, COOL, stok) end
  end)
end
-- ambient where blades emerge
c:put(44, 34, BLADE[1], stok) c:put(45, 34, BLADE[2], stok)

-- seeds: papery wing, then glossy body
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  local vis = s.m:copy()
  if i == 3 then vis:cut(hm) end
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  X.ao(sb, s.m, s.bm, 1, -1)
  local widx = X.tone(c, vis, X.light(s.n, { amb = 0.25, wrap = 0.4 }), WING, { cuts = { 0.25, 0.45, 0.65, 0.82 }, bias = sb, tok = tok })
  -- radial veins in the wing + thin pale rim on the lit side
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local a = atan(dy, dx)
    local f = (a / (2 * pi) * 9) % 1
    if f < 0.13 and not s.bm:has(x, y) and (dx*dx + dy*dy) > 5 then c:put(x, y, WING[max(1, widx[k] - 1)], tok) end
  end)
  vis:edge():each(function(x, y) if x + y < s[1] + s[2] - 2 then c:put(x, y, WING[5], tok) end end)
  -- body
  local bvis = s.bm:copy() bvis:clip(vis)
  local bidx = X.tone(c, bvis, X.light(s.bn, { amb = 0.06, wrap = 0.2 }), SEED, { cuts = { 0.18, 0.36, 0.54, 0.7, 0.86 }, tok = tok })
  -- hilum notch + spec glint
  local hx, hy = floor(s[1] + s[3] * 0.48 * ca + 0.5) - 1, floor(s[2] + s[3] * 0.48 * sa + 0.5)
  if bvis:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  local gx, gy = A.specAt(bvis, s.bn, 30)
  if gx then c:put(gx, gy, i == 2 and "#fff4d6" or SEED[6], tok) end
end

-- quirk petal, drawn last
local ptok = A.tok("petal")
local pidx = X.tone(c, pm, X.light(pn, { amb = 0.2, wrap = 0.3 }), PET, { cuts = { 0.3, 0.55, 0.8 }, tok = ptok })
c:put(38, 47, PET[1], ptok) c:put(39, 48, PET[2], ptok)

A.save(c, NAME)

-- mexican-sage-seed (final, Opus single pass). Three glossy dark-brown ovoid sage nutlets (pale hilum scar, mottled
-- coat) on a torn scrap of grey-green Salvia leucantha leaf (lance shape, quilted rugose surface from a vein grid,
-- felted pale margin, jagged torn base, V-fold light, AO + contact shadow under each seed). The front nutlet has
-- sprouted: pale stem, two round cotyledons, then a pair of narrow felted lance leaves showing the sage.
-- quirk: the seedling already wears a tiny purple velvet flower spike with one white petal poking out.
local NAME = "mexican-sage-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sqrt, max, min, cos, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.cos, math.sin, math.pi
local c = A.new(NAME)
local LEAF = { "#263c3c", "#36544d", "#4b6e5e", "#678b72", "#8aab8c", "#b8d0ae" }
local FELT = "#d4e2c8"
local SEED = { "#2c1a1e", "#45282a", "#633a30", "#86523a", "#a9714e", "#d6a476" }
local STEM = { "#4b7a5a", "#7fa883", "#b2cfa8", "#dfeccf" }
local PURP = { "#3a2058", "#5a3488", "#7d4fb8", "#a57ad8", "#cfb2f0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- leaf scrap: lance leaf on a diagonal, torn at the base
local lm, ln, LT, LS, len = G.blade(9, 54, 30, 50, 57, 36, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.4 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.8)
end, { fold = 0.4 })
-- torn base: jagged line across near t ~ 0.1, plus a small tear notch in the lower edge
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local jag = 0.06 + 0.05 * abs(((s * 7.3) % 2) - 1) + 0.03 * X.hash(floor(s * 9), 0, 3)
  if t < jag then cut[#cut + 1] = k end
  if t > 0.42 and t < 0.5 and s > 0.62 + (t - 0.42) * 3 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 22, 46, 3.6, 2.4, -0.5 }, { 31, 48, 3.4, 2.3, 0.3 }, { 37, 40, 3.6, 2.5, -0.9 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- rugose quilting: vein grid (side veins swept to tip + cross veinlets), puffed cells lit upper-left
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  local i = lidx[k]
  if abs(s) < 0.13 and t > 0.08 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local a = (t * len - abs(s) * 5.5) / 4.2
  local b = abs(s) * 7.4 / 2.2
  local fa, fb = a - floor(a), b - floor(b)
  if t > 0.1 and t < 0.92 and abs(s) < 0.86 then
    if fa < 0.2 then c:put(x, y, LEAF[max(1, i - 1)], ltok)
    elseif fb < 0.22 and abs(s) > 0.25 then c:put(x, y, LEAF[max(1, i - 1)], ltok)
    elseif fa > 0.25 and fa < 0.5 and fb > 0.3 and fb < 0.6 and s < 0 then c:put(x, y, LEAF[min(6, i + 1)], ltok) end
  end
end)
-- felted pale margin on the lit side, cool reflected edge on the shaded side; dark torn fibres at the base
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] < -0.6 and LT[k] > 0.12 then c:put(x, y, FELT, ltok)
  elseif LS[k] > 0.6 and LT[k] > 0.12 then c:put(x, y, "#3e6170", ltok)
  elseif LT[k] < 0.2 then c:put(x, y, (x + y) % 2 == 0 and LEAF[2] or LEAF[5], ltok) end
end)

-- sprout from the front-right seed (seed 3)
local stok = { r = { name = "stem" } }
local sp = { { 37, 38 }, { 36, 31 }, { 39, 24 }, { 37, 16 } }
local sm = A.stem(c, sp, function(t) return 1.0 - 0.2 * t end, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
sm:cut(seeds[3].m)
-- cotyledons: round paddles low on the stem
local ctok = { r = { name = "coty" } }
for _, q in ipairs{ { 32, 29, 2.8, 1.8, -0.35 }, { 42, 28, 2.8, 1.8, 0.35 } } do
  local m, n = G.oval(q[1], q[2], q[3], q[4], q[5], 0.7)
  m:cut(sm)
  G.toneN(c, m, n, { "#3f7a46", "#5c9a52", "#7fb85e", "#a7d27a", "#cfe7a0" }, { tok = ctok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
end
-- true leaves: narrow felted lances
local tl1 = A.leaf(c, 38, 21, 32, 16, 25, 15, 1.8, LEAF, { cut = sm, vs = 2.4 })
local tl2 = A.leaf(c, 38, 21, 44, 16, 51, 15, 1.8, LEAF, { cut = sm, vs = 2.4 })
for _, m in ipairs{ tl1, tl2 } do
  m:edge():each(function(x, y) if y <= 15 and X.hash(x, y, 8) < 0.5 then c:put(x, y, FELT, ltok) end end)
end

-- quirk: velvet flower spike (stacked purple calyx beads) with one white petal
local ptok = { r = { name = "spike" } }
local beads = { { 37, 14, 1.4 }, { 37, 11, 1.3 }, { 38, 9, 1.0 } }
for _, b in ipairs(beads) do
  local m = HP.ellipse(b[1], b[2], b[3], b[3])
  local n = X.sphere(b[1], b[2], b[3] + 0.3, m)
  X.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.3 }), PURP, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = ptok })
end
c:put(39, 11, "#f4eef8", ptok) c:put(40, 11, "#d8d0e8", ptok)
c:put(36, 10, PURP[5], ptok)

-- seeds last: glossy coat, mottling, pale hilum scar, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.08, wrap = 0.25 }), SEED, { cuts = CUTS, bias = sb, tok = tok })
  vis:each(function(x, y) local k = K(x, y) if X.hash(x, y, 20 + i) < 0.18 and idx[k] > 2 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  -- hilum: pale dash at the lower-right end
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  if vis:has(hx, hy) then c:put(hx, hy, "#c9a688", tok) end
  -- glossy specular
  local bx, by = G.specAt(vis, s.n, 30)
  if bx then c:put(bx, by, "#f3d9b4", tok) end
end

A.save(c, NAME)

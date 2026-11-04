-- guava-seed (final, Opus single pass). Four small hard guava seeds (cream-tan kidneys with a dark hilum notch)
-- on a torn scrap of guava leaf (oblong, sunken parallel veins, ragged tear on the right, V-fold light, cool edge,
-- AO + contact shadow under each seed). The right seed has sprouted: pale stem, two round cotyledons and a first
-- opposite pair of oblong, veined guava leaves.
-- quirk: one seed still wears a blob of coral-pink guava pulp.
local NAME = "guava-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SEED  = { "#4a3224", "#6e4a30", "#987048", "#c09a64", "#e2c48e", "#f8e8c0" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local PULP  = { "#8e2444", "#c23a52", "#e05a62", "#f4867a", "#ffc0a8" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 15, 47, 3.0, 2.2, 0.4 }, { 22, 50, 3.0, 2.1, -0.3 }, { 25, 44, 2.9, 2.2, 0.9 }, { 37, 46, 3.1, 2.3, -0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: oblong guava blade, base on the left, torn across on the right
local lm, ln, LT, LS, len = G.blade(6, 50, 28, 44, 56, 48, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 9.0 * sin(pi * min(1, t * 0.8 + 0.08)) ^ 0.55)
end, { fold = 0.36 })
-- ragged tear: remove beyond a jagged line around t = 0.8
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local j = 0.78 + 0.05 * sin(LS[k] * 9.0) + 0.03 * X.hash(floor(LS[k] * 6), 1, 5)
  if LT[k] > j then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- one small bite-like tear notch in the lower edge
lm:cut(c:ellipse(18, 57, 2.5, 2))
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
local PER = 3.4
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- straight parallel side veins, sunken (dark line + lit lip), swept toward the tip
  local ph = (t * len - abs(s) * 5.0) / PER
  local f = ph - floor(ph)
  if abs(s) > 0.18 and abs(s) < 0.82 and t > 0.05 then
    if f < 0.2 then c:put(x, y, s < 0 and LEAF[3] or LEAF[2], ltok)
    elseif f < 0.38 and s < 0 then c:put(x, y, LEAF[6], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 and LT[k] < 0.74 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken tissue line
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] > 0.72 and abs(LS[k]) < 0.8 then c:put(x, y, "#b8dc92", ltok) end end)
-- petiole stub
for _, q in ipairs{ { 5, 51, 3 }, { 4, 51, 2 }, { 3, 52, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the right seed
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 37, 45 }, { 36, 38 }, { 37, 32 }, { 37, 22 } }, function(t) return 1.05 end, STEM, { tok = stok, cut = seeds[4].m })
-- cotyledons: two small round paddles
local cot = HP.mask()
local cl = G.rell(31.5, 31.5, 1, 0.35, 3.3, 2.1)
local cr = G.rell(42.5, 31.5, 1, -0.35, 3.3, 2.1)
cot:add(cl):add(cr):cut(sm)
A.shade(c, cot, X.pillow(cot, 1.8), LEAF, { tok = ltok, amb = 0.14, wrap = 0.3 })
-- first true leaves: opposite pair, oblong, midrib + side veins
local tl1 = A.leaf(c, 36, 23, 30, 17, 23, 16, 2.6, LEAF, { tok = ltok, vs = 2.2, fold = 0.4 })
local tl2 = A.leaf(c, 38, 23, 44, 17, 51, 15, 2.6, LEAF, { tok = ltok, vs = 2.2, fold = 0.4 })
-- bud tip
c:put(37, 21, STEM[3], stok) c:put(37, 20, STEM[4], stok) c:put(36, 21, STEM[2], stok)
-- AO where the cotyledons meet the stem
c:put(36, 32, STEM[1], stok) c:put(38, 32, STEM[1], stok)

-- seeds last: kidney shape (hilum notch), ridge highlight, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.1, wrap = 0.3 })
  -- hilum notch on the lower edge (kidney dent)
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] - sa * (s[4] + 0.2) + .5), floor(s[2] + ca * (s[4] + 0.2) + .5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  -- pitted hard coat: a couple of darker pits
  vis:shrink(1):each(function(x, y) if X.hash(x, y, 20 + i) > 0.82 then c:put(x, y, SEED[max(1, (idx[K(x, y)] or 3) - 1)], tok) end end)
  local sx, sy = G.specAt(vis, s.n, 30)
  c:put(sx, sy, SEED[6], tok)
end
-- quirk: pulp blob clinging to the middle seed
local pm = c:ellipse(24, 42.5, 1.6, 1.2):add(c:ellipse(26, 43, 1, 1))
local ptok = { r = { name = "pulp" } }
A.shade(c, pm, X.sphere(24.5, 42.5, 2, pm), PULP, { tok = ptok, cuts = { 0.2, 0.4, 0.6, 0.8 } })
c:put(23, 42, "#fff4d6", ptok)

A.save(c, NAME)

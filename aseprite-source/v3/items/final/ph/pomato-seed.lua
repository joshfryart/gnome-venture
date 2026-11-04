-- pomato-seed (final pass, Sonnet). Tomato-potato graft seeds: four flat, pale buff teardrop seeds with a fuzz of fine
-- hairs, lying on a torn diagonal scrap of a sawtooth-edged potato-tomato leaflet (deeply impressed veins with lit
-- lips, V fold, cool reflected lower edge, AO + contact shadow under every seed). The left seed has germinated: a
-- pale stem, two long strap-shaped cotyledons arching out, and the first true leaf, pinnate with a terminal
-- leaflet and two pairs of serrated side leaflets (tomato foliage), so the plant reads at a glance.
-- Material: seeds per-pixel flat-dome light on a 6-tone ramp, hash fuzz and rim hairs, dark hilum notch; leaf 6 tones.
-- History: Sonnet draft replaced.
-- quirk: the right-hand seed carries a potato eye dimple that has already pushed out one tiny pink root hair.
local NAME = "pomato-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD1t0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#1a3f34", "#27593a", "#37763f", "#52964a", "#79b85a", "#aedc7c" }
local YLEAF = { "#245238", "#36733f", "#4f9448", "#70b557", "#9ad06a", "#cdea92" }
local VEIN, COOL = "#c4e48c", "#3a6c72"
local SEED  = { "#7a5a38", "#a07e4e", "#c29e66", "#dcb97e", "#efd49a", "#fdeebf" }
local STEM  = { "#5a8c52", "#8cbc6c", "#b8dc90", "#e0f2b6" }
local PINK  = { "#8a2c52", "#c0507a", "#e87ea2", "#fbb4c8" }

-- ---------------------------------------------------------------- leaflet scrap (serrated, torn)
local lm, ln, LT, LS, len = A.blade(8, 55, 30, 54, 54, 39, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.97 + 0.04)) ^ 0.72)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local saw = ((t * len / 3.3) + (s > 0 and 0.5 or 0)) % 1
  if t > 0.1 and t < 0.94 and abs(s) > 0.97 - 0.22 * (1 - saw) ^ 1.3 then cut[#cut + 1] = k end
  local rag = 0.95 + 0.03 * X.hash(floor(s * 6), 5, 2)
  if t > rag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

local seeds = { { 18, 50, 3.9, 2.7, 0.3 }, { 29, 52, 3.7, 2.6, -0.25 }, { 40, 49, 3.8, 2.6, 0.15 }, { 49, 44, 3.7, 2.6, -0.5 } }
for _, s in ipairs(seeds) do s.m = A.oval(s[1], s[2], s[3], s[4], s[5], 0.55) end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
-- midrib + deep lateral veins (dark groove, lit lip above it)
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t > 0.02 and t < 0.94 then
    c:put(x, y, s <= 0 and VEIN or LEAF[2], ltok)
  elseif t > 0.1 and t < 0.9 and abs(s) > 0.17 and abs(s) < 0.8 then
    local ph = (t * len - abs(s) * 6.0) % 6.6
    if ph < 0.8 then c:put(x, y, LEAF[1], ltok)
    elseif ph > 5.8 and s < 0 then c:put(x, y, LEAF[5], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.08 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- stalk stub
for _, q in ipairs{ { 8, 55, 4 }, { 7, 56, 3 }, { 6, 56, 3 }, { 9, 56, 2 }, { 7, 57, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- ---------------------------------------------------------------- sprout from the left seed
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 18, 48 }, { 16, 40 }, { 20, 33 }, { 19, 27 } }, function(t) return 1.05 end)
sm:cut(seeds[1].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- two long strap cotyledons arching out of the stem
local function strap(ax, ay, cx, cy, bx, by)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, 1.8, YLEAF, { tok = ltok, vs = 9, vein = YLEAF[6], pw = 0.45, fold = 0.3 })
  return m
end
strap(17, 37, 10, 32, 7, 39)
strap(18, 36, 27, 31, 35, 36)
-- first true leaf: pinnate, serrated leaflets (terminal + two pairs)
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m = A.leaf(c, ax, ay, cx, cy, bx, by, w, YLEAF, { tok = ltok, vs = 2.8, vein = YLEAF[6], pw = 0.7, fold = 0.4 })
  m:edge():each(function(x, y) if (x * 2 + y * 3) % 5 == 0 then c:put(x, y, YLEAF[1], ltok) end end)
  return m
end
leaflet(19, 22, 21, 17, 18, 10, 2.9)          -- terminal
leaflet(19, 26, 13, 23, 9, 26, 2.3)          -- lower pair
leaflet(19, 26, 25, 23, 31, 25, 2.3)
leaflet(19, 22.5, 15, 19.5, 11, 19, 1.8)     -- upper pair
leaflet(19, 22.5, 23, 19.5, 27, 19, 1.8)
-- rachis over the leaflet bases
for _, q in ipairs{ { 19, 27, 2 }, { 19, 26, 3 }, { 19, 25, 3 }, { 19, 24, 3 }, { 19, 23, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end

-- ---------------------------------------------------------------- seeds last (fuzz, hilum, glint, quirk)
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local n = A.dome(s.m, s[1] - 0.5, s[2] - 0.6, s[3] + 0.3, 1.5, 0.55)
  local idx = A.shade(c, vis, n, SEED, { tok = tok, bias = sb, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  vis:each(function(x, y)                                     -- fuzz: sparse pale / dark hairs on the body
    local h = X.hash(x, y, 60 + i)
    if h > 0.84 and (idx[K(x, y)] or 1) >= 2 then A.step(c, idx, SEED, x, y, 1, tok)
    elseif h < 0.06 then A.step(c, idx, SEED, x, y, -1, tok) end
  end)
  -- rim hairs: pale pixels just outside the seed, onto the leaf
  local ring = s.m:grow(1):cut(s.m)
  ring:each(function(x, y)
    if lm:has(x, y) and not sm:has(x, y) and X.hash(x, y, 70 + i) > 0.62 then
      local ok = true
      for j = 1, #seeds do if j ~= i and seeds[j].m:has(x, y) then ok = false end end
      if ok then c:put(x, y, SEED[(x < s[1] and y < s[2]) and 5 or 3], tok) end
    end
  end)
  -- hilum notch at the narrow end
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] - 0.8) + 0.5), floor(s[2] + sa * (s[3] - 0.8) + 0.5)
  if vis:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  local gx, gy = floor(s[1] - 1.5 + 0.5), floor(s[2] - 1.0 + 0.5)
  if vis:has(gx, gy) then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[6], tok) end
end
-- quirk: potato eye dimple on the right seed + pink root hair curling off the leaf
c:put(50, 44, SEED[1]) c:put(51, 44, SEED[1]) c:put(50, 45, SEED[3])
local pk = { r = { name = "root" } }
for _, q in ipairs{ { 52, 44, 2 }, { 53, 44, 3 }, { 54, 43, 3 }, { 55, 42, 4 }, { 55, 41, 3 }, { 54, 40, 2 } } do c:put(q[1], q[2], PINK[q[3]], pk) end
-- germination split on the sprouting seed
c:put(17, 48, SEED[1]) c:put(18, 48, STEM[2], stok)

A.save(c, NAME)

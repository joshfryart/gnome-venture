-- oleander-seed (final, Opus single pass, aC31_0). Two oleander seeds (slim, rusty-brown, finely hairy) each with
-- a fan-shaped tuft of silky golden pappus, lying on a long torn scrap of oleander leaf (leathery dark green, pale
-- raised midrib, the fine near-parallel side veins of Nerium, cool reflected edge, a ragged torn base). A third
-- seed has split and sprouted: thin stem, two round cotyledons, and a first whorl of three narrow lance leaves.
-- AO + contact shadow under every seed and the sprout foot.
-- quirk: a single fallen pink oleander petal, twisted like a pinwheel blade, rests near the leaf tip.
local NAME = "oleander-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#142c2a", "#1d4232", "#2a5e3a", "#3f7d43", "#5f9c4f", "#8dbb66" }
local VEIN, COOL = "#b6d68a", "#36606a"
local SEED  = { "#3a221f", "#573226", "#78452d", "#9a5d38", "#bd7c4a", "#dca36c" }
local TUFT  = { "#8e6a3e", "#b88f56", "#dcbb7e", "#f4e2b2" }
local STEM  = { "#5a3d3e", "#80585a", "#a87f78", "#d0aa9a" }      -- oleander shoots are reddish
local PETAL = { "#7d2c5e", "#b04478", "#d8649a", "#f08cb6", "#ffb6d0", "#ffe2ee" }
local CUTS = A.CUTS

-- leaf scrap: long lance blade, torn (wide, ragged) at the left end
local W = 6.0
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 57, 56, 43, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, W * min(1, (1 - t) * 1.6) ^ 0.8 * (0.86 + 0.14 * min(1, t * 4)))
end, { fold = 0.42 })
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local s, d = LS[k], LT[k] * len
  local depth = 1.2 + 1.8 * abs(sin(s * 7.3 + 0.6)) + (s > 0.3 and 1.5 or 0)
  if d < depth then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end
-- a little bite torn out of the upper edge
lm:cut(A.rell(24, 46.6, 1, 0.2, 2.2, 1.3))

-- seeds: cx, cy, rx, ry, angle ; tuft direction (unit), tuft length
local seeds = {
  { 20, 50, 3.6, 1.6, -0.25, -0.7, -0.72, 9 },
  { 31, 51, 3.4, 1.5, 0.3, 0.45, -0.89, 8 },
}
local sprout = { 43, 47, 3.0, 1.7, -0.5 }
local allSeed = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) allSeed:add(s.m) end
sprout.m, sprout.n = A.oval(sprout[1], sprout[2], sprout[3], sprout[4], sprout[5], 0.8)
allSeed:add(sprout.m)

-- tufts: fan of silky hairs from the seed end
local tufts = {}
for i, s in ipairs(seeds) do
  local ca, sa = cos(s[5]), sin(s[5])
  local dir = (ca * s[6] + sa * s[7]) > 0 and 1 or -1
  local ex, ey = s[1] + ca * s[3] * dir, s[2] + sa * s[3] * dir
  local tx, ty = s[6], s[7]
  local m, H = HP.mask(), {}
  for y = floor(ey) - 10, floor(ey) + 10 do for x = floor(ex) - 10, floor(ex) + 10 do
    local dx, dy = x - ex, y - ey
    local r = sqrt(dx * dx + dy * dy)
    if r > 0.3 then
      local cosA = (dx * tx + dy * ty) / r
      local ang = math.acos(max(-1, min(1, cosA)))
      local side = dx * (-ty) + dy * tx
      local lim = s[8] * (1 - (ang / 0.75) ^ 2) + 0.6 * sin(side * 2.1 + i)
      if ang < 0.75 and r <= lim then m:set(x, y) H[K(x, y)] = { side / r, r / s[8] } end
    end
  end end
  m:cut(s.m)
  tufts[i] = { m = m, H = H }
end

-- leaf shading with AO from seeds + tufts and contact shadows
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
X.ao(bias, lm, sprout.m, 1, -1) A.cast(bias, lm, sprout.m, 1, 2, -1)
for _, t in ipairs(tufts) do A.cast(bias, lm, t.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  -- fine near-parallel side veins (Nerium), angled toward the tip
  local d = (t * len - abs(s) * 2.2) % 2.6
  if d < 0.7 and abs(s) > 0.2 and abs(s) < 0.82 and t < 0.9 then
    c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)

-- quirk: fallen petal near the tip (twisted: lit half + shaded half)
local pm = A.rell(50.5, 44.5, 0.94, -0.34, 3.6, 1.9)
local pn = X.pillow(pm, 1.6)
local ptok = { r = { name = "petal" } }
local psh = pm:shift(1, 1)
lm:each(function(x, y) if not pm:has(x, y) and psh:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local pidx = A.shade(c, pm, pn, PETAL, { amb = 0.2, wrap = 0.3, tok = ptok })
pm:each(function(x, y) local along = (x - 50.5) * 0.94 + (y - 44.5) * -0.34
  local across = -(x - 50.5) * -0.34 + (y - 44.5) * 0.94
  if along > 0.8 and across > -0.2 then c:put(x, y, PETAL[max(2, pidx[K(x, y)] - 1)], ptok) end   -- the twist
  if abs(across) < 0.5 and along < -0.5 then c:put(x, y, PETAL[min(6, pidx[K(x, y)] + 1)], ptok) end
end)

-- sprout stem (behind the split seed coat)
local stok = { r = { name = "stem" } }
local sp = { { 43, 46 }, { 41, 38 }, { 44, 29 }, { 42, 19 } }
local sm, sn, ST, SS, sidx = A.stem(c, sp, function(t) return 0.95 end, STEM, { tok = stok, cut = sprout.m })
-- cotyledons: two small rounded paddles
local cotl = A.leaf(c, 42, 30, 38, 30, 34, 27, 1.9, LEAF, { tok = ltok, cut = sm, pw = 0.5, fold = 0.3, vs = 9 })
local cotr = A.leaf(c, 44, 30, 48, 31, 51, 28, 1.9, LEAF, { tok = ltok, cut = sm, pw = 0.5, fold = 0.3, vs = 9 })
-- whorl of three narrow lance true leaves
local wcut = sm:copy():add(cotl):add(cotr)
local w1 = A.leaf(c, 42, 20, 36, 14, 29, 13, 1.7, LEAF, { tok = ltok, cut = wcut, vs = 2.6, fold = 0.5 })
local w2 = A.leaf(c, 43, 20, 49, 15, 55, 15, 1.7, LEAF, { tok = ltok, cut = wcut, vs = 2.6, fold = 0.5 })
local w3 = A.leaf(c, 42, 19, 42, 15, 44, 9, 1.6, LEAF, { tok = ltok, cut = wcut:copy():add(w1):add(w2), vs = 2.6, fold = 0.5 })
-- reddish leaf-stalk node + AO
for _, p in ipairs{ { 42, 20, 1 }, { 43, 20, 2 }, { 42, 21, 2 } } do c:put(p[1], p[2], STEM[p[3]], stok) end

-- seeds: hairy brown coats with ridge, AO from tufts
local function seedPaint(s, tok, split)
  local sb = {}
  local idx = A.shade(c, s.m, s.n, SEED, { amb = 0.08, wrap = 0.25, tok = tok, bias = sb, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y)
    local u = ((x - s[1]) * ca + (y - s[2]) * sa) / (s[3] + .45)
    local v = (-(x - s[1]) * sa + (y - s[2]) * ca) / (s[4] + .45)
    if abs(v) < 0.25 and abs(u) < 0.7 then c:put(x, y, SEED[max(1, idx[k] - 1)], tok) end           -- groove
    if X.hash(x, y, 5) > 0.82 and idx[k] > 2 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end    -- fine hairs
  end)
  local hx, hy = A.specAt(s.m, s.n, 30)
  c:put(hx, hy, SEED[6], tok)
  if split then
    -- seed coat split open where the stem leaves: dark slit + pale inner lip
    c:put(43, 46, SEED[1], tok) c:put(42, 46, SEED[1], tok) c:put(44, 46, SEED[2], tok) c:put(42, 45, SEED[5], tok)
  end
end
for i, s in ipairs(seeds) do
  -- tuft first (hairs streaked along the radius)
  local t = tufts[i]
  local ttok = { r = { name = "tuft" .. i } }
  t.m:each(function(x, y) local h = t.H[K(x, y)]
    local stripe = floor((h[1] + 1) * 4.2 + i) % 2
    local tone = (h[1] < -0.05) and 3 or 2
    if stripe == 0 then tone = tone + 1 end
    if h[2] < 0.3 then tone = tone - 1 end
    c:put(x, y, TUFT[max(1, min(4, tone))], ttok)
  end)
  seedPaint(s, { r = { name = "seed" .. i } }, false)
end
seedPaint(sprout, { r = { name = "seedS" } }, true)
-- radicle: tiny pale root tip poking out the other side
for _, p in ipairs{ { 46, 49, 4 }, { 47, 50, 3 } } do c:put(p[1], p[2], STEM[p[3]], stok) end

A.save(c, NAME)

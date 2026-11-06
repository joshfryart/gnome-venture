-- napa-cabbage-seed (final, Opus single pass). Four tiny round brassica seeds (glossy red-brown spheres) on a torn
-- scrap of crinkled napa leaf (broad white rib, crinkle, veins, ragged torn ends, cool edge, AO + contact shadow under
-- each seed). One seed has split and sprouted: a pale stem with a white fuzzy root, two notched kidney-shaped
-- cotyledons (the brassica tell) and a first true leaf, oval, crinkled, with the white napa rib.
-- quirk: the empty seed coat is still stuck on the tip of the left cotyledon like a little cap.
local NAME = "napa-cabbage-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GR   = { "#21462f", "#346a3c", "#55924a", "#7fb85a", "#aed474", "#dcee9e" }
local COT  = { "#2a5a34", "#3f7a3c", "#62a048", "#8cc65a", "#b8e07a", "#e2f4a8" }
local WH   = { "#6a7656", "#949f72", "#bcc492", "#dcdfb2", "#efefd0", "#fbf8e6" }
local SEED = { "#2a1620", "#4a2226", "#6e3226", "#94482e", "#b8683e", "#dc9a62" }
local STEM = { "#6e8a5a", "#a2c07e", "#d2e4ae", "#eef6d6" }
local COOL = "#3a6c72"

-- seeds (cx, cy, r); #4 is the sprouting one
local seeds = { { 15, 47, 2.6 }, { 21, 50, 2.6 }, { 22, 44, 2.5 }, { 35, 46, 2.7 } }
for _, s in ipairs(seeds) do s.m = HP.ellipse(s[1], s[2], s[3], s[3]) end
local smask = HP.mask() for _, s in ipairs(seeds) do smask:add(s.m) end

-- leaf scrap: crinkled napa piece across the bottom, torn at both ends
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 40, 56, 49, function(t)
  local w = 7.6 * sin(pi * min(1, t * 0.8 + 0.1)) ^ 0.5
  return max(3, w)
end, { fold = 0.25 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  -- ragged torn ends + frilled long edges
  if t < 0.07 + 0.05 * X.hash(floor(y / 2), 1, 5) then cut[#cut + 1] = k end
  if t > 0.93 - 0.06 * X.hash(floor(y / 2), 2, 9) then cut[#cut + 1] = k end
  if abs(s) > 0.82 and (floor(x / 2) + floor(y / 2)) % 2 == 0 and X.hash(x, y, 4) > 0.3 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
lm:cut(smask)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local v = X.light(ln, { amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local i = 1 for j, ct in ipairs(A.CUTS) do if v[k] >= ct then i = j + 1 end end
  i = i + (bias[k] or 0)
  local col
  if abs(s) < 0.22 then
    local j = i + 1
    if abs(s) > 0.13 then j = j - 2 end
    col = WH[max(1, min(6, j))]
  else
    local hh = X.hash(floor(x / 2), floor(y / 2), 21)
    if hh > 0.8 then i = i - 1 elseif hh < 0.15 then i = i + 1 end
    local ph = (t * len - abs(s) * 6) / 4.2
    if ph - floor(ph) < 0.18 and abs(s) < 0.8 then i = (s < 0) and i + 1 or i - 1 end
    col = GR[max(1, min(6, i))]
  end
  c:put(x, y, col, ltok)
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

-- sprout from seed 4: stem, root, cotyledons, true leaf
local SX, SY = 35, 44
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { SX, SY }, { SX - 1, 36 }, { SX + 1, 29 }, { SX, 23 } }, function(t) return 1.05 end)
sm:cut(seeds[4].m)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
-- root: thin white radicle with fuzz hairs, curling off the right of the seed over the leaf
local rpts = { { 37, 48 }, { 39, 50 }, { 41, 51 }, { 43, 51 }, { 45, 52 } }
local rtok = { r = { name = "root" } }
for i, p in ipairs(rpts) do c:put(p[1], p[2], i < 3 and STEM[3] or STEM[4], rtok) c:put(p[1], p[2] + 1, GR[1], ltok) end
for _, p in ipairs{ { 40, 49 }, { 42, 50 }, { 44, 50 }, { 42, 52 } } do c:put(p[1], p[2], STEM[4], rtok) end

-- cotyledons: kidney shapes with a notch at the outer end
local ctok = { r = { name = "cot" } }
local function cotyledon(px, py, ox, oy, dir)
  local m = A.rell(ox, oy, 1, -0.18 * dir, 4.6, 3.1)
  -- notch at the outer tip
  local nx = ox + dir * 4.4
  m:cut(HP.ellipse(nx, oy - 0.6, 1.1, 1.1))
  local n = X.pillow(m, 2.2)
  local idx = A.shade(c, m, n, COT, { tok = ctok, amb = 0.14, wrap = 0.3 })
  -- midrib + petiole
  for xx = 0, 3 do local x = floor(ox - dir * 2 + dir * xx + .5) if m:has(x, oy) then A.at(c, x, oy, COT, (idx[K(x, oy)] or 3) + 1, ctok) end end
  c:fillMask(c:line({ { px, py }, { ox - dir * 3.6, oy } }, 1), STEM[2])
  return m
end
local cl = cotyledon(SX - 1, 24, SX - 7, 21, -1)
local cr = cotyledon(SX + 1, 24, SX + 7, 20, 1)

-- first true leaf: oval, crinkled, white napa rib, rising from the stem top
local tl, tn, TT, TS = A.blade(SX, 22, SX + 1, 14, SX, 6, function(t)
  if t > 0.97 then return -1 end
  return max(0.6, 4.2 * sin(pi * min(1, t * 0.95 + 0.04)) ^ 0.75)
end, { fold = 0.3 })
local tb = {}
X.ao(tb, cl, tl, 1, -1) X.ao(tb, cr, tl, 1, -1)
-- AO on cotyledons where the true leaf sits on them
for _, cm in ipairs{ cl, cr } do cm:each(function(x, y) local k = K(x, y) if tb[k] and not tl:has(x, y) then c:put(x, y, COT[2], ctok) end end) end
local ti = A.shade(c, tl, tn, GR, { tok = ltok, amb = 0.14, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  if abs(s) < 0.2 and t < 0.85 then c:put(x, y, s <= 0 and WH[6] or WH[4], ltok)
  else
    local ph = (t * 15 - abs(s) * 3) / 3
    if ph - floor(ph) < 0.25 and t > 0.15 and t < 0.85 then A.at(c, x, y, GR, (ti[k] or 3) + (s < 0 and 1 or -1), ltok) end
  end
end)
-- crinkled edge notches on the true leaf
for _, q in ipairs{ { SX - 4, 13 }, { SX + 4, 11 }, { SX - 3, 9 } } do if tl:has(q[1], q[2]) then c.pix[q[2] * 64 + q[1]] = nil c.own[q[2] * 64 + q[1]] = nil end end

-- seeds last: glossy spheres, split coat on the sprouting seed
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tk = { r = { name = "seed" .. i } }
  local n = X.sphere(s[1] - 0.3, s[2] - 0.3, s[3], vis)
  A.shade(c, vis, n, SEED, { tok = tk, bias = sb, amb = 0.05, wrap = 0.15, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
  local gx, gy = floor(s[1] - 1 + .5), floor(s[2] - 1 + .5)
  c:put(gx, gy, (i == 2) and A.CREAM or SEED[6], tk)
end
-- the sprouting seed: pale split line where the stem comes out
c:put(SX, SY - 2, STEM[3], stok) c:put(SX, SY - 1, STEM[2], stok) c:put(SX + 1, SY - 1, SEED[1], stok)

-- quirk: seed coat cap on the left cotyledon tip
local capx, capy = SX - 12, 19
for _, q in ipairs{ { 0, 0, 4 }, { 1, 0, 5 }, { -1, 1, 3 }, { 0, 1, 3 }, { 1, 1, 2 }, { 0, -1, 6 } } do
  c:put(capx + q[1], capy + q[2], SEED[q[3]], { r = { name = "cap" } })
end

A.save(c, NAME)

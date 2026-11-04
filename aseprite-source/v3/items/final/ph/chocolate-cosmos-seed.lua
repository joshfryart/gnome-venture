-- chocolate-cosmos-seed (final, Opus single pass). Three slim needle-like cosmos achenes (near-black chocolate, two
-- dark ribs, paler lit ridge, a pale forked awn at the tip) fanned on a torn strip of a pinnate chocolate-cosmos leaf
-- (rounded lobes, midrib, swept veins, cool lower-right rim, pale torn edge, AO + contact shadow under each seed).
-- The right seed has germinated: pale stem, two long strap cotyledons and a first pinnate true leaf.
-- quirk: the sprout already wears a tiny maroon-chocolate flower bud on its tip.
local NAME = "chocolate-cosmos-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#163a33", "#1f5440", "#2c7046", "#428e4b", "#66ad54", "#97cb6a" }
local VEIN, COOL, TORN = "#bfe28a", "#3a6a72", "#d6eaa0"
local SEED = { "#1a0d12", "#2c171a", "#43241f", "#5e3627", "#7f4f33", "#b88a5c" }
local AWN = { "#8a6a4a", "#d8bc8a" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local BUD = { "#2a0e18", "#4a1424", "#6e1e30", "#93283a", "#b8424a", "#e07a6a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds (bezier control points), drawn last
local seeds = {
  { { 9, 47 }, { 15, 45 }, { 21, 42 }, { 28, 39 } },
  { { 15, 53 }, { 21, 52 }, { 28, 50 }, { 34, 48 } },
  { { 39, 52 }, { 39, 48 }, { 40, 44 }, { 40, 39 } },
}
local sw = function(t) return max(0.4, 2.15 * sin(pi * min(1, 0.12 + t * 0.95)) ^ 0.6) end
local smask = {}
for i, p in ipairs(seeds) do smask[i] = A.tube(p, sw) end

-- leaf strip: pinnate cosmos leaflet scrap, lobed, torn off at the right end
local PER = 8.2
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 56, 58, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.6 * sin(pi * min(1, t * 0.8 + 0.08)) ^ 0.55)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.3
  local f = abs((ph - floor(ph)) - 0.5) * 2
  local lim = 0.98 - (1 - f) ^ 1.3 * 0.72
  if t > 0.06 and abs(s) > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local torn = A.tear(lm, LT, LS, 0.84, 0.035, 11, 0.04)
local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 4.5) / PER + (s > 0 and 0.5 or 0) + 0.3
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.05 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
for _, q in ipairs{ { 5, 53, 4 }, { 4, 54, 3 }, { 3, 55, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: stem out of the upright seed, two strap cotyledons, a pinnate true leaf, the bud
local stok = { r = { name = "stem" } }
local sp = { { 40, 41 }, { 41, 34 }, { 39, 27 }, { 40, 19 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = strap(39, 30, 32, 29, 25, 24, 1.6)
local cr = strap(41, 30, 48, 30, 54, 26, 1.6)
-- pinnate true leaf: rachis up-left from the stem, narrow leaflets on both sides
local rach = { { 40, 23 }, { 38, 20 }, { 35, 17 }, { 32, 14 } }
local tl = HP.mask()
for _, q in ipairs{ { 0.25, 1 }, { 0.3, -1 }, { 0.55, 1 }, { 0.6, -1 }, { 0.85, 1 }, { 0.88, -1 } } do
  local x, y = A.bez(rach, q[1])
  local ux, uy = A.rot(-0.7, -0.7, q[2] * 1.15)
  local L = 3.6 - q[1] * 1.2
  tl:add(A.rell(x + ux * L * 0.6, y + uy * L * 0.6, ux, uy, L * 0.62, 0.95))
end
do local x, y = A.bez(rach, 1) tl:add(A.rell(x - 0.8, y - 0.8, -0.7, -0.7, 2.0, 1.0)) end
tl:cut(cl):cut(cr):cut(sm)
A.toneN(c, tl, X.pillow(tl, 1.4), LEAF, { tok = ltok, cuts = CUTS, amb = 0.12, wrap = 0.25 })
A.bline(c, rach, LEAF[3], ltok, 0.05, 0.95)
-- quirk: the bud on the stem tip
local bm = A.rell(40.5, 17, 0, 1, 2.3, 2.0)
local bn = X.sphere(40.1, 16.6, 2.3, bm)
X.tone(c, bm, X.light(bn, { amb = 0.08, wrap = 0.2 }), BUD, { cuts = CUTS, tok = { r = { name = "bud" } } })
c:put(39, 16, BUD[6]) c:put(38, 18, LEAF[4]) c:put(42, 18, LEAF[3]) c:put(40, 19, LEAF[3])
for i = 0, 20 do local x, y = A.bez(sp, i / 20) if i < 18 then c:put(floor(x + .5), floor(y + .5), i < 3 and STEM[2] or STEM[3], stok) end end

-- seeds last, AO between neighbours
for i, p in ipairs(seeds) do
  local b = {}
  for j = i + 1, #seeds do X.ao(b, smask[i], smask[j], 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local m, n, T, S = A.needle(c, p, sw, SEED, tok, { -0.05, 0.5 }, b)
  -- lit ridge
  m:each(function(x, y) local k = K(x, y) if S[k] < -0.35 and S[k] > -0.75 and T[k] > 0.25 and T[k] < 0.6 then c:put(x, y, SEED[6], tok) end end)
  -- forked awn at the tip (except the sprouting seed, whose tip became the stem)
  if i < 3 then
    local x, y = p[4][1], p[4][2]
    local dx, dy = p[4][1] - p[3][1], p[4][2] - p[3][2]
    local l = math.sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
    for s = 1, 2 do
      local a1x, a1y = A.rot(dx, dy, -0.6) local a2x, a2y = A.rot(dx, dy, 0.6)
      c:put(floor(x + a1x * (s + 0.6) + .5), floor(y + a1y * (s + 0.6) + .5), s == 2 and AWN[2] or AWN[1], tok)
      c:put(floor(x + a2x * (s + 0.6) + .5), floor(y + a2y * (s + 0.6) + .5), AWN[1], tok)
    end
  end
end
c:put(13, 45, A.CREAM)
A.save(c, NAME)

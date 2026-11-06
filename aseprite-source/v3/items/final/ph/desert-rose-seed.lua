-- desert-rose-seed (final, Opus single pass). Two slim tan desert-rose (adenium) seeds, ribbed along the back, with a
-- silky cream hair tuft fanned out at each end, lying on a torn scrap of glossy obovate adenium leaf (V-fold light,
-- pale midrib, side veins, torn ragged base, AO + contact shadow under each seed). Behind them a seedling has already
-- swollen into a tiny olive caudex (the plant's bottle trunk) with a slim stem, two round cotyledons and a pair of
-- glossy obovate true leaves.
-- quirk: the seedling is showing off, a single pink trumpet flower already open on its tip.
local NAME = "desert-rose-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, cos, sin, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.cos, math.sin, math.pi
local c = A.new(NAME)
local LEAF = { "#14352e", "#1f5236", "#2f7040", "#4a9248", "#78b65a", "#b2da7c" }
local VEIN, COOL = "#cfe39a", "#3a6c72"
local CAU = { "#3f3326", "#6b5a3c", "#94804f", "#b8a465", "#d7c88a", "#f0e7b6" }
local SEED = { "#3a2420", "#5e3a2a", "#865a35", "#ad7f4a", "#cfa66c", "#ecd09a" }
local HAIR = { "#b9ab90", "#e2d7bb", "#f7f0dc" }
local PINK = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local seeds = { { 19, 47, 4.6, 1.5, -0.22 }, { 30, 44, 4.4, 1.5, 0.12 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
local cau = { m = nil }
cau.m, cau.n = A.oval(42, 41, 3.6, 4.2, 0, 1)

-- leaf scrap: obovate (broad toward the tip), torn ragged at the base
local lm, ln, LT, LS, len = A.blade(9, 53, 30, 52, 55, 38, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.2 * sin(pi * min(1, t * 0.78 + 0.22)) ^ 0.6)
end, { fold = 0.4 })
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.07 * sin(LS[k] * 9.0) + 0.04 * X.hash(x, y, 3)
  if LT[k] < lim then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, cau.m, 1, -1) A.cast(bias, lm, cau.m, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.12 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  -- side veins swept toward the tip
  local ph = (t * len - abs(s) * 5.0) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.15 and abs(s) < 0.78 and t > 0.16 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
-- glossy leaf: one 2x1 sheen
c:put(44, 41, LEAF[6], ltok)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.15 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale broken tissue on the ragged base
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.17 and not bias[k] then c:put(x, y, LEAF[5], ltok) end end)

-- seedling: stem, cotyledons, true leaves, flower
local stok = { r = { name = "stem" } }
local sp = { { 42, 38 }, { 41, 31 }, { 40, 24 }, { 40, 17 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(cau.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by, w, pw)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.8 + 0.2)) ^ (pw or 0.6))
  end, { fold = 0.35 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) end end)
  return m
end
-- round cotyledons low on the stem
local c1 = blade(40, 29, 36, 29, 33, 27, 1.8, 0.4)
local c2 = blade(42, 29, 46, 29, 49, 27, 1.8, 0.4)
-- glossy obovate true leaves
local t1 = blade(40, 19, 34, 17, 28, 11, 3.0)
local t2 = blade(41, 19, 47, 17, 53, 13, 3.0)
-- caudex: swollen bottle trunk with fine horizontal wrinkles and a root foot
local ctok = { r = { name = "caudex" } }
local cb = {}
A.cast(cb, cau.m, sm, 0, 0, 0)
local cidx = A.toneN(c, cau.m, cau.n, CAU, { tok = ctok, cuts = CUTS, amb = 0.12, wrap = 0.25 })
cau.m:each(function(x, y) local k = K(x, y) if (y == 40 or y == 43) and x > 39 and x < 45 then c:put(x, y, CAU[max(1, cidx[k] - 1)], ctok) end end)
c:put(40, 39, CAU[6], ctok) c:put(40, 38, CAU[5], ctok)
for _, q in ipairs{ {44, 46, 2}, {45, 47, 1}, {41, 46, 2} } do c:put(q[1], q[2], CAU[q[3]], ctok) end
-- quirk: open pink trumpet flower on the tip (five-lobed star with pale throat)
local ftok = { r = { name = "flower" } }
c:paint({
  ".aba.",
  "abcba",
  "bcdcb",
  ".bcb.",
  "..e..",
}, 38, 11, { a = PINK[3], b = PINK[2], c = PINK[4], d = "#fff0d8", e = PINK[1] })
c:put(39, 12, PINK[4], ftok)

-- seeds last: ribbed backs, hair tufts at both ends
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local ii
    if v < -0.35 then ii = 5 elseif v < 0.25 then ii = 4 else ii = 2 end
    if v >= -0.35 and v < 0.25 and u > -0.5 and u < 0.4 and (x % 3 == 0) then ii = 3 end
    if abs(u) > 0.8 then ii = ii - 1 end
    if v < -0.35 and u > -0.55 and u < -0.15 then ii = 6 end
    c:put(x, y, SEED[max(1, min(6, ii))], tok)
  end)
  -- tufts: three fanned 1 px hairs at each end
  for _, side in ipairs{ -1, 1 } do
    for j, a in ipairs{ -0.45, 0, 0.45 } do
      local ux, uy = A.rot(ca * side, sa * side, a)
      for r = 1, 4 do
        local px = s[1] + side * ca * (s[3] + 0.3) + ux * r
        local py = s[2] + side * sa * (s[3] + 0.3) + uy * r
        local xi, yi = floor(px + .5), floor(py + .5)
        if not s.m:has(xi, yi) then c:put(xi, yi, HAIR[(j == 1 and 3) or (r > 2 and 1 or 2)], tok) end
      end
    end
  end
end
A.save(c, A.here(), NAME)

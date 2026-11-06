-- chrysanthemum-seed (final, Opus single pass). Four tiny ribbed wedge achenes (grey-tan, three dark ribs, pale lit
-- edge, blunt dark crown) clustered on a torn scrap of a deeply lobed grey-green chrysanthemum leaf laid on the diagonal
-- (rounded lobes, midrib, a vein into each lobe, pale felted underside showing along the lower-right margin, ragged
-- torn base, AO + contact shadows). One seed has sprouted: pale stem, two round spoon cotyledons, a first lobed leaf.
-- quirk: a single yellow ray petal has drifted onto the leaf.
local NAME = "chrysanthemum-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1c3638", "#294e46", "#3a6850", "#53845c", "#77a26e", "#a7c58e" }
local VEIN, UNDER, TORN = "#c6dca6", "#a3b8a8", "#dfe9b6"
local SEED = { "#24160f", "#3e2a1c", "#5c4028", "#7e5a38", "#a47c50", "#d6b884" }
local STEM = { "#5a8556", "#93ba72", "#c4dc9a", "#e8f2c4" }
local PET = { "#8f4a1f", "#c8701e", "#e8a020", "#f5c02e", "#ffdc5a", "#fff0a0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: wedge achenes (base -> crown), drawn last
local seeds = {
  { { 14, 48 }, { 17, 46.5 }, { 20, 45 }, { 23, 43.5 } },
  { { 20, 53 }, { 23, 52.5 }, { 26, 52 }, { 29, 51.5 } },
  { { 41, 40 }, { 38, 41 }, { 35, 42 }, { 32, 43 } },
  { { 34, 52 }, { 34, 49.5 }, { 34, 47.5 }, { 34.5, 45 } },    -- sprouting, upright
}
local sw = function(t) if t > 0.97 then return 0.9 end return 0.75 + 1.75 * t ^ 0.7 end
local smask = {}
for i, p in ipairs(seeds) do smask[i] = A.tube(p, sw) end

-- leaf: tip upper-right, torn base lower-left, deeply lobed with round lobes
local PER = 9.5
local lm, ln, LT, LS, len = A.blade(56, 30, 34, 50, 6, 56, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 10.5 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.6)
end, { fold = 0.42 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.15
  local f = abs((ph - floor(ph)) - 0.5) * 2
  local lim = 0.96 - (1 - f) ^ 3.2 * 0.78
  if t > 0.04 and t < 0.9 and abs(s) > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local torn = A.tear(lm, LT, LS, 0.86, 0.04, 5, 0.03)
local pm, pn, PT, PS = A.blade(41, 36, 45, 33, 50, 33, function(t)
  if t > 0.97 then return -1 end return 1.25 end, { fold = 0.2 })
local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
A.cast(bias, lm, pm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len + abs(s) * 4.0) / PER + (s > 0 and 0.5 or 0) + 0.15
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.15 and abs(s) < 0.7 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.55 then c:put(x, y, UNDER, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
c:put(57, 29, LEAF[4], ltok) c:put(58, 28, LEAF[3], ltok)

-- quirk: yellow ray petal with a notched tip
local ptok = { r = { name = "petal" } }
A.toneN(c, pm, pn, PET, { tok = ptok, cuts = CUTS, amb = 0.2, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y) if abs(PS[k]) < 0.2 and PT[k] > 0.2 and PT[k] < 0.8 then c:put(x, y, PET[4], ptok) end end)

-- sprout
local stok = { r = { name = "stem" } }
local sp = { { 34.5, 45 }, { 35, 37 }, { 31, 30 }, { 32, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function spoon(ax, ay, bx, by)
  local m, n, T, S = A.blade(ax, ay, (ax + bx) / 2, (ay + by) / 2 - 1, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.9 * sin(pi * min(1, t * 0.75 + 0.05)) ^ 1.1)
  end, { fold = 0.25 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.7 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = spoon(31, 30, 21, 27)
local cr = spoon(33, 30, 43, 25)
-- first true leaf: small lobed ovate, five round lobes
local tl = HP.mask()
tl:add(A.rell(32, 17.5, 0, 1, 3.6, 2.2))
for _, q in ipairs{ { -2.6, 19.5 }, { 2.6, 19.5 }, { -2.4, 16 }, { 2.4, 16 }, { 0, 13.8 } } do tl:add(A.rell(32 + q[1], q[2], 0, 1, 1.5, 1.5)) end
tl:cut(cl):cut(cr)
A.toneN(c, tl, X.pillow(tl, 1.8), LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.25 })
for y = 15, 20 do c:put(32, y, y < 18 and LEAF[6] or LEAF[3], ltok) end
for i = 0, 20 do local x, y = A.bez(sp, i / 20) if i < 19 then c:put(floor(x + .5), floor(y + .5), i < 3 and STEM[2] or STEM[3], stok) end end

-- seeds last
for i, p in ipairs(seeds) do
  local b = {}
  for j = i + 1, #seeds do X.ao(b, smask[i], smask[j], 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local m, n, T, S = A.needle(c, p, sw, SEED, tok, { -0.25, 0.25, 0.7 }, b)
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.55 and T[k] > 0.3 and T[k] < 0.8 and not b[k] then c:put(x, y, SEED[6], tok) end
    if T[k] > 0.92 then c:put(x, y, SEED[2], tok) end end)
end
c:put(16, 46, A.CREAM)
A.save(c, NAME)

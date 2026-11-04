-- camellia-seed (final pass, Opus). Two glossy chestnut-brown camellia seeds (rounded, one pressed facet line, pale hilum
-- scar) on a torn scrap of glossy dark camellia leaf (elliptic, torn jagged base, midrib + swept veins, wax streak,
-- cool reflected edge, AO + contact shadow under each seed). A third seed has sprouted: slim stem and two elliptic,
-- pointed, glossy camellia leaves with midribs.
-- quirk: the sprout already carries a tiny pink camellia bud at its tip, sepals cupped round it.
local NAME = "camellia-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min = math.floor, math.abs, math.sin, math.pi, math.max, math.min
local c = A.new(NAME)

local LEAF = { "#132f2a", "#1b4535", "#275f40", "#387b48", "#56a052", "#8cc86a" }
local WAX, VEIN, COOL = "#b8e08c", "#6fae5c", "#356a70"
local SEED = { "#2c171c", "#4a2722", "#6e3b29", "#965533", "#bf7a44", "#e6aa6c" }
local HIL = "#d9b88a"
local STEM = { "#3a6e48", "#5c9654", "#8ebe6c", "#c6e09a" }
local BUD = { "#6e2450", "#a8366a", "#d85a8a", "#f08aac", "#ffc4d8" }

-- leaf scrap: elliptic camellia leaf, base end torn off (left), tip to the right
local lm, ln, LT, LS, len = A.blade(8, 53, 30, 56, 56, 40, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.8 * sin(pi * min(1, t * 0.82 + 0.16)) ^ 0.75)
end, { fold = 0.32 })
-- jagged tear across the base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local along, s = LT[k] * len, LS[k]
  local z = abs(((s * 3.2 + 10) % 2) - 1)            -- zigzag 0..1
  local tear = 3.5 + 3.5 * z + (s > 0.3 and 2 or 0)
  if along < tear then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 19, 46, 4.4, 3.7, -0.35 }, { 29, 49, 4.0, 3.4, 0.45 }, { 41, 43, 4.0, 3.5, -0.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[2], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.0
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.08 and t < 0.88 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
  -- waxy streak on the lit half
  if s < -0.3 and s > -0.5 and t > 0.45 and t < 0.68 then c:put(x, y, WAX, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- pale torn fibre along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] * len < 11 and abs(LS[k]) < 0.85 and not bias[k] then c:put(x, y, "#a8d27a", ltok) end end)

-- sprout stem from the third seed
local stok = { r = { name = "stem" } }
local sp = { { 41, 41 }, { 39, 34 }, { 37, 27 }, { 38, 17 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- two camellia leaves: elliptic, pointed, glossy
local function cleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.06 then return 0.6 end
    return max(0.5, w * sin(pi * min(1, (t - 0.04) * 1.0)) ^ 0.8)
  end, { fold = 0.36 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) end
    if S[k] < -0.35 and S[k] > -0.6 and T[k] > 0.3 and T[k] < 0.5 then c:put(x, y, WAX, ltok) end
  end)
  return m
end
cleaf(37, 28, 31, 22, 21, 22, 3.4)
cleaf(38, 23, 44, 17, 53, 17, 3.2)

-- quirk: pink camellia bud at the tip, cupped by two sepals
local bm = HP.ellipse(38.5, 13.5, 2, 2.6)
local bn = A.body(bm, 38, 13, 2.6, 2, 0.7)
A.shade(c, bm, bn, BUD, { cuts = { 0.2, 0.42, 0.62, 0.82 }, tok = { r = { name = "bud" } } })
c:put(37, 12, BUD[5])
for _, q in ipairs{ { 36, 15, 3 }, { 37, 16, 4 }, { 40, 15, 2 }, { 39, 16, 3 }, { 38, 16, 3 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end
c:put(38, 17, STEM[2], stok)

-- seeds: glossy, one facet line, hilum scar
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local n = s.n
  local idx = A.toneN(c, s.m, n, SEED, { tok = tok, bias = sb, cuts = { 0.14, 0.3, 0.47, 0.64, 0.82 }, amb = 0.1, wrap = 0.2 })
  -- facet: a deep line from the centre toward lower-right
  for j = 0, 2 do local x, y = s[1] + 1 + j, s[2] + floor(j * 0.6 + 0.5)
    if s.m:has(x, y) then c:put(x, y, SEED[2], tok) end end
  -- pale hilum scar near the lower-left
  local hx, hy = s[1] - 2, s[2] + 2
  if s.m:has(hx, hy) then c:put(hx, hy, HIL, tok) if s.m:has(hx + 1, hy) then c:put(hx + 1, hy, SEED[5], tok) end end
  A.glint(c, s.m, n, SEED[6], 30, tok)
end
-- radicle stub out of the sprouting seed's tip (below)
c:put(44, 46, STEM[3], stok) c:put(45, 47, STEM[4], stok)

A.done(c, NAME)

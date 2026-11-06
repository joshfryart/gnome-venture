-- fuchsia-seed (aB33_0, Opus single pass). Three small flattened fuchsia seeds (tan, a dark keel, a pale hilum notch)
-- on a torn fuchsia-leaf scrap (bronze-green, finely toothed margin, red-pink midrib and veins, ragged pale tear at
-- the tip, V-fold light, AO + contact shadow under the seeds). The right seed has sprouted: a red fuchsia stem,
-- two round cotyledons and a first pair of pointed, red-veined true leaves.
-- quirk: the seedling already dangles a tiny fuchsia bud (pink sepals, purple skirt) on an arching thread-thin stalk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB33_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "fuchsia-seed"
local c = A.new(NAME)
local LEAF  = { "#1b2c32", "#25443c", "#305f42", "#467c47", "#6c9d55", "#a3c472" }
local RIB, RIBD = "#e8829c", "#a83a5c"
local TEAR  = "#d6e9a8"
local SEED  = { "#3e2422", "#5e3a2a", "#84552f", "#a87843", "#ca9d62", "#ebc991" }
local STEM  = { "#5c1f3a", "#8a2e4a", "#b84a62", "#de7e8e" }
local SEPAL = { "#6e1f3e", "#a12a4e", "#d33f5e", "#f06a7e", "#ff9aa6", "#ffc8cc" }
local COR   = { "#35295f", "#5a3c9e", "#8a62d2", "#b893f2" }
local CUTS  = { 0.18, 0.34, 0.5, 0.66, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 47, 3.4, 2.2, -0.25 }, { 26.5, 44.5, 3.3, 2.1, 0.35 }, { 36, 43, 3.2, 2.1, -0.15 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf scrap: ovate fuchsia leaf on the diagonal, base lower-left, tip torn away upper-right
local lm, ln, LT, LS, len = A.blade(8, 52, 30, 52, 56, 37, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.2 * sin(pi * min(1, t * 0.86 + 0.07)) ^ 0.62)
end, { fold = 0.4 })
local cut, tear = {}, HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  -- fine teeth: a notch every 3 px along both margins
  local ph = t * len / 3.1 + (s > 0 and 0.5 or 0)
  if abs(s) > 0.84 and (ph - floor(ph)) < 0.34 and t > 0.06 then cut[#cut + 1] = k end
  -- ragged tear across the tip
  local lim = 0.8 + 0.07 * sin(s * 9.0) + 0.04 * X.hash(floor(s * 6 + 9), 2, 4)
  if t > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
lm:each(function(x, y) if not lm:has(x + 1, y) or not lm:has(x, y - 1) then if LT[K(x, y)] > 0.7 then tear:set(x, y) end end end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- midrib + paired veins (red-pink, darker on the shade half)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.8 then c:put(x, y, s <= 0 and RIB or RIBD, ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 6.5 + 0.3
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.72 and t > 0.08 and t < 0.76 then c:put(x, y, s < 0 and LEAF[6] or RIBD, ltok) end
end)
-- pale torn edge
tear:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TEAR, ltok) end end)
-- petiole stub (red)
for _, q in ipairs{ { 7, 53, 3 }, { 6, 54, 2 }, { 5, 55, 2 } } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- sprout: red stem out of the right seed
local stok = { r = { name = "stem" } }
local sp = { { 36, 42 }, { 35, 36 }, { 37, 30 }, { 37, 21 } }
local sm, sn = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
A.tone(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15 })
-- cotyledons: two round seed leaves
local function blade(ax, ay, cx, cy, bx, by, w, rib)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.55)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.82 then
    c:put(x, y, S[k] <= 0 and (rib and RIB or LEAF[6]) or (rib and RIBD or LEAF[3]), ltok) end end)
  return m
end
local c1 = blade(36, 31, 31, 30, 27, 32, 2.2, false)
local c2 = blade(38, 31, 42, 30, 46, 32, 2.2, false)
-- first true leaves: pointed ovate, red midrib, angled up
local t1 = blade(36, 22, 30, 20, 24, 15, 2.9, true)
local t2 = blade(38, 22, 43, 19, 48, 14, 2.9, true)
-- AO on the stem where leaves join
for _, q in ipairs{ { 37, 23 }, { 36, 32 }, { 37, 32 } } do if sm:has(q[1], q[2]) then c:put(q[1], q[2], STEM[1], stok) end end
-- growing tip
c:put(37, 20, STEM[3], stok) c:put(37, 19, STEM[4], stok)

-- quirk: arching pedicel + dangling fuchsia bud
local pp = { { 38, 18 }, { 42, 11 }, { 50, 11 }, { 51, 18 } }
for i = 0, 40 do local x, y = A.bez(pp, i / 40) c:put(floor(x + .5), floor(y + .5), i < 20 and STEM[3] or STEM[2], stok) end
local btok = { r = { name = "bud" } }
local bm, bn = A.oval(51, 22, 3.6, 2.0, pi / 2 + 0.08, 0.8)
local bb = {}
bm:each(function(x, y) if y <= 19 then bb[K(x, y)] = -1 end end)
A.tone(c, bm, bn, SEPAL, { bias = bb, tok = btok, cuts = CUTS, amb = 0.12 })
-- sepal seams + spec
c:put(51, 21, SEPAL[2], btok) c:put(51, 22, SEPAL[2], btok) c:put(50, 20, SEPAL[6], btok) c:put(50, 21, "#fff4d6", btok)
-- purple skirt peeping below, with tiny stamen
local ctok = { r = { name = "corolla" } }
for _, q in ipairs{ { 50, 26, 3 }, { 51, 26, 2 }, { 52, 26, 2 }, { 50, 27, 4 }, { 51, 27, 3 }, { 52, 27, 1 }, { 51, 28, 2 } } do
  c:put(q[1], q[2], COR[q[3]], ctok) end
c:put(51, 29, SEPAL[5], ctok)

-- seeds last: keeled, hilum notch, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local idx = A.tone(c, vis, s.n, SEED, { bias = sb, tok = tok, cuts = CUTS, amb = 0.1 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(v) < 0.2 and abs(u) < 0.62 then c:put(x, y, SEED[max(1, (idx[k] or 3) - 2)], tok) end  -- keel line
    if u > 0.72 and abs(v) < 0.35 then c:put(x, y, SEED[6], tok) end                             -- hilum
  end)
end
-- one glint on the front seed
c:put(15, 46, "#fff4d6", { r = { name = "seed1" } })

A.save(c, NAME)

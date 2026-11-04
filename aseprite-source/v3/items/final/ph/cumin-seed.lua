-- cumin-seed (final, Opus single pass). Four slim cumin seeds (long, boat-shaped, khaki-brown with pale lengthwise
-- ridges and a tiny dark tail) scattered on a flat torn scrap of sage-green leaf (ragged tear on both short ends, one
-- corner curled up to show the paler underside, midrib + veins). The middle seed has germinated: a slim stem, two
-- needle-thin cotyledons and a first true leaf split into fine thread segments, the feathery cumin foliage.
-- quirk: a single dew drop hangs on the tip of one thread leaf.
local NAME = "cumin-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#23402f", "#335a3b", "#467446", "#5f8f50", "#83ad66", "#b2cd8a" }
local UNDER = { "#5a7a52", "#7c9a68", "#a3bb86", "#cadcaa" }
local VEIN, COOL = "#cfe0a4", "#41686a"
local SEED = { "#3b2a1c", "#5c4128", "#7d5c34", "#a07d48", "#c4a466", "#e6cf94" }
local STEM = { "#5a7a3c", "#8aab58", "#bcd68a", "#e4f0bc" }
local DEEP = { "#1d3a2c", "#2d5638", "#3f7444", "#5a9450", "#80b462", "#b4d68a" }
local ltok, utok = A.tok("leaf"), A.tok("under")

-- scrap: wide flat band across the lower half, torn at both ends
local lm, ln, LT, LS, len = A.blade(5, 50, 30, 40, 59, 45, function(t)
  return 8.6 * sin(pi * (0.12 + 0.76 * t)) ^ 0.45 + 0.8 * sin(t * pi * 5)
end, { fold = 0.4 })
A.tear(lm, 12, 34, 8, 60, 1.8, 11)  -- left tear (keeps the right side)
A.tear(lm, 53, 60, 55, 34, 1.8, 12) -- right tear
-- curled corner: upper-right corner folds toward the viewer (paler underside showing)
local curl = HP.poly{ { 43, 35 }, { 52, 36 }, { 47, 41 } }
curl:clip(lm:copy():grow(2))
local seeds = { { 17, 47, 4.6, 1.5, -0.25 }, { 27, 51, 4.4, 1.5, 0.35 }, { 33, 41, 4.4, 1.5, -1.25 }, { 43, 48, 4.6, 1.5, -0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, curl, 1, -1) A.cast(bias, lm, curl, -1, 2, -1)
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.28, 0.44, 0.6, 0.74, 0.88 }, amb = 0.08, wrap = 0.22 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.09 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6) / 7
  if abs(ph - floor(ph + .5)) < 0.07 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.72 then c:put(x, y, COOL, ltok) end end)
-- underside of the curl: pale, lit on its upper ridge
curl:each(function(x, y)
  local d = (x - 43) * 0.3 + (y - 35) * 0.95
  local i = d < 2 and 4 or d < 4 and 3 or d < 6 and 2 or 1
  c:put(x, y, UNDER[i], utok)
end)
HP.line({ { 45, 36 }, { 49, 39 } }, 1):each(function(x, y) if curl:has(x, y) then c:put(x, y, UNDER[1], utok) end end)

-- sprout from seed 3 (stem drawn before seeds so the coat sits over its foot)
local stok = A.tok("stem")
local sp = { { 34, 38 }, { 33, 34 }, { 35, 31 }, { 34, 28 } }
local sm, sn = A.tube(sp, function(t) return 0.9 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function needle(pts, col1, col2)
  for _, q in ipairs(A.curve(pts, 30)) do if not sm:has(q[1], q[2]) then c:put(q[1], q[2], q[3] < 0.5 and col1 or col2, ltok) end end
end
-- cotyledons: two long needles
needle({ { 34, 29 }, { 30, 27 }, { 26, 27 }, { 22, 29 } }, DEEP[5], DEEP[6])
needle({ { 34, 30 }, { 38, 28 }, { 43, 28 }, { 47, 30 } }, DEEP[4], DEEP[3])
-- second needle row under each cotyledon gives 2 px body with a lit top and a shaded belly
needle({ { 33, 30 }, { 30, 28 }, { 27, 28 }, { 24, 30 } }, DEEP[3], DEEP[4])
needle({ { 35, 31 }, { 38, 29 }, { 42, 29 }, { 45, 31 } }, DEEP[2], DEEP[2])
-- true leaf: thread segments fanning from the top of the stem
local tip = { 34, 28 }
local threads = { { 23, 19, 28, 21 }, { 28, 13, 31, 19 }, { 35, 10, 34, 18 }, { 41, 13, 38, 19 }, { 46, 18, 41, 22 } }
for i, th in ipairs(threads) do
  needle({ tip, { (tip[1] + th[3]) / 2, tip[2] - 2 }, { th[3], th[4] }, { th[1], th[2] } }, DEEP[i <= 2 and 5 or 4], DEEP[i <= 2 and 6 or 3])
end
-- short forks on the outer threads
needle({ { 30, 18 }, { 28, 18 }, { 26, 16 }, { 25, 14 } }, DEEP[5], DEEP[6])
needle({ { 39, 18 }, { 41, 18 }, { 43, 16 }, { 44, 14 } }, DEEP[4], DEEP[3])
-- quirk: dew drop on the tip of the tallest thread
local dtok = A.tok("dew")
for _, q in ipairs{ { 35, 8, "#7fc4d0" }, { 36, 8, "#5aa0b8" }, { 35, 7, "#d9f4f4" }, { 36, 7, "#a6dde4" }, { 35, 9, "#4b88a4" }, { 36, 9, "#3c7092" } } do c:put(q[1], q[2], q[3], dtok) end

-- seeds: long boats with lengthwise ridges, a tail at the far end
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = A.tok("seed" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.12, wrap = 0.3, bias = sb })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i2 = idx[k] or 3
    if abs(v) < 0.3 and abs(u) < 0.7 then i2 = i2 + 1 end           -- pale ridge along the spine
    if v < -0.3 and u < 0 and u > -0.6 then i2 = 6 end               -- lit ridge
    if abs(u) > 0.78 then i2 = i2 - 1 end
    c:put(x, y, SEED[max(1, min(6, i2))], tok)
  end)
  -- tail (stylopodium) out of the right tip
  local tx, ty = floor(s[1] + (s[3] + 1.3) * ca + .5), floor(s[2] + (s[3] + 1.3) * sa + .5)
  if not s.m:has(tx, ty) then c:put(tx, ty, SEED[2], tok) end
end
c:put(15, 46, A.CREAM, A.tok("seed1"))
A.save(c, NAME)

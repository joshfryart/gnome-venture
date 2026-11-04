-- pua-kenikeni-seed (D10 final, Sonnet high). Two amber ridged seeds on a torn scrap of glossy pua kenikeni leaf
-- (pale torn rim, midrib + curved veins, contact shadow under the seeds). The left-hand seed has sprouted: a slim pale stem
-- with two opposite pairs of glossy pointed-elliptic leaves (drip tips, veins) -- the plant's leaf shape.
-- quirk: the sprout is already crowned by one tiny blossom, cream fading to orange like the real flower as it ages.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pua-kenikeni-seed")

local LEAF = { "#12393a", "#1d5a45", "#2a7a4a", "#42994f", "#6cb958", "#a2d874" }
local SEED = { "#4a2a22", "#6e3f2a", "#935a32", "#b87b42", "#d9a15c", "#f4d596" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local FL   = { "#a8501c", "#d97a22", "#f5a83a", "#ffc95a", "#ffe28c", "#fff6da" }
local TORN = "#cde08c"

-- leaf scrap (drawn first): a ribbon cut from a leaf, torn ends
local function wf(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.04)
  return max(0.5, 7.4 * sin(pi * u) ^ 0.62)
end
local lm, ln, LT, LS, len = A.blade(8, 52, 27, 57, 54, 47, wf, { fold = 0.38 })
local bites = HP.mask()
bites:add(c:poly{ { 50, 40 }, { 55, 44 }, { 52, 46 }, { 57, 49 }, { 52, 52 }, { 62, 52 }, { 62, 38 } })
bites:add(c:poly{ { 4, 49 }, { 9, 51 }, { 7, 53 }, { 12, 55 }, { 0, 58 }, { 0, 47 } })
bites:add(c:poly{ { 33, 62 }, { 36, 58 }, { 38, 62 } })
lm:cut(bites)
local torn = bites:grow(1):clip(lm)
-- seeds (positions) -- needed first for shadow casting
local seeds = { { 16, 51, 5.0, 3.2, -0.25 }, { 29, 49, 5.0, 3.2, 0.12 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) A.cast(bias, lm, s.m, 2, 2, -1) end
local ltok = { r = { name = "scrap" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.16, wrap = 0.3, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  for _, vt in ipairs{ 8, 13, 18, 23, 28, 33, 38, 43 } do
    local d = t * len - (vt + abs(s) * 3.0)
    if d > -0.55 and d < 0.55 and abs(s) > 0.2 and abs(s) < 0.82 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end
end)
torn:each(function(x, y) c:put(x, y, TORN, ltok) end)
lm:edge():each(function(x, y) local k = K(x, y) if not torn:has(x, y) and LS[k] > 0.68 and LT[k] > 0.1 and LT[k] < 0.9 then c:put(x, y, "#3a6c72", ltok) end end)

-- sprout: stem
local stok = { r = { name = "stem" } }
local sp = { { 17, 48 }, { 15, 40 }, { 20, 30 }, { 21, 20 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - 0.2 * t end)
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- opposite leaf pairs: lower pair (large), upper pair (smaller). Pointed ellipses with drip tips.
local function lf(w)
  return function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.97 + 0.05)
    local prof = w * sin(pi * u ^ 0.85) ^ 0.62
    if t > 0.84 then prof = min(prof, w * 0.5 * (1 - t) / 0.16 + 0.45) end   -- drip tip
    return max(0.45, prof)
  end
end
local vs = { 4, 7.5, 11, 14.5 }
local ok = HP.mask()
local function put(ax, ay, cx, cy, bx, by, w, veins)
  local m = A.vleaf(c, ax, ay, cx, cy, bx, by, lf(w), LEAF, { veins = veins or vs, slant = 2.0, fold = 0.42, tok = { r = { name = "lf" .. ax .. by } }, cut = nil })
  return m
end
-- upper pair first (behind), lower pair in front
put(21, 24, 27, 20, 35, 17, 2.7, { 4, 7, 10 })
put(20, 25, 14, 22, 6, 18, 2.8, { 4, 7, 10 })
put(16, 38, 24, 35, 38, 32, 3.8)
put(16, 40, 9, 37, 2, 31, 3.8)

-- quirk: one little blossom on top (5 lobes, cream to orange)
local fx, fy = 21, 17
local fm = HP.mask()
local lobes = {}
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5 + 0.3
  local ux, uy = cos(a), sin(a)
  local lm2 = A.rell(fx + ux * 2.5, fy + uy * 2.5, ux, uy, 3.0, 1.9)
  lobes[#lobes + 1] = { m = lm2, a = a }
  fm:add(lm2)
end
local fn = X.pillow(fm, 2.2)
local ftok = { r = { name = "flower" } }
local fbias = {}
fm:each(function(x, y) local k = K(x, y) if (x - fx) + (y - fy) > 1.5 then fbias[k] = -0 end end)
A.shade(c, fm, fn, FL, { amb = 0.1, wrap = 0.3, tok = ftok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
-- lobe creases
for _, L in ipairs(lobes) do
  local ux, uy = cos(L.a), sin(L.a)
  for r = 1.6, 4.6, 1 do local x, y = floor(fx + ux * r + 0.5), floor(fy + uy * r + 0.5)
    if fm:has(x, y) and r > 2 then c:put(x, y, FL[2], ftok) end end
end
c:fillMask(c:rect(fx - 1, fy - 1, fx, fy), FL[1])
c:px(fx - 1, fy - 1, FL[2])

-- seeds on top: amber, ridged, pale hilum, glossy
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  local vis = s.m:copy()
  A.toneN(c, s.m, s.n, SEED, { tok = tok, amb = 0.06, wrap = 0.18, cuts = { 0.24, 0.42, 0.58, 0.72, 0.86 } })
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  s.m:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + 0.45), flip * (-dx * sa + dy * ca) / (s[4] + 0.45)
    if abs(v - 0.15) < 0.17 and abs(u) < 0.78 then c:put(x, y, SEED[2], tok) end          -- long ridge groove
    if abs(v + 0.4) < 0.15 and abs(u) < 0.6 and u > -0.5 then c:put(x, y, SEED[5], tok) end -- lit ridge
    if u < -0.78 and abs(v) < 0.4 then c:put(x, y, SEED[6], tok) end                       -- pale hilum end
    if u > 0.62 and v > 0.2 then c:put(x, y, SEED[2], tok) end                              -- shade tip
  end)
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:put(x, y, "#b08a6a", tok) end end)
  local bx, by = A.specAt(s.m, s.n, 40)
  c:put(bx, by, "#fffbe8", tok) c:put(bx + 1, by, SEED[6], tok)
end
A.save(c, "pua-kenikeni-seed")

-- busy-lizzie-seed (final, Opus aB13_3 single pass). Tiny round mottled-brown Impatiens seeds on a torn, broad ovate
-- busy-lizzie leaf (serrated margin, pale midrib + curved side veins, cool reflected edge, AO + contact shadows).
-- One seed has sprouted: a juicy translucent pink-green stem, two round cotyledon paddles and a first serrated ovate
-- leaf with a pink-flushed edge.
-- quirk: the burst seed pod lies beside them, its valves sprung into two tight green coils, one seed still flying off.
local NAME = "busy-lizzie-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#18352f", "#22503a", "#2f6c3c", "#4b8e3e", "#7bb04a", "#b6d672" }
local VEIN, COOL = "#cfe69a", "#3c6870"
local SEED = { "#2e1a1c", "#4a2a24", "#6c3e2c", "#8f5836", "#b07a4a", "#d8aa70" }
local STEM = { "#7d3a52", "#b45a6c", "#d88a86", "#f2c0a8" }
local COT = { "#1f4a3a", "#2c6a42", "#459048", "#6eb452", "#a2d066", "#d4ec9a" }
local POD = { "#1c3c30", "#2b5a3a", "#3f7c42", "#62a04c", "#92c460", "#cce690" }
local PINK = "#e8708c"

-- leaf scrap: broad ovate leaf, torn at the base
local lm, ln, LT, LS, len = A.blade(6, 53, 28, 50, 58, 40, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 9.2 * sin(pi * (0.08 + 0.92 * t)) ^ 0.75)
end, { fold = 0.3 })
A.tear(lm, 11, 53, -0.95, 0.3, 3.2, 2.6, 7)
-- serrations: small notches along the margin, every 3 px
local cut = {}
lm:edge():each(function(x, y) local k = K(x, y)
  if abs(LS[k]) > 0.8 and LT[k] > 0.18 and LT[k] < 0.95 and floor(LT[k] * len / 3 + (LS[k] > 0 and 0.5 or 0)) % 2 == 0 and floor(LT[k] * len) % 3 == 0 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local seeds = { { 21, 45.5, 2.4, 2.1 }, { 28, 48, 2.2, 2.0 }, { 33, 45, 2.3, 2.0 }, { 25, 51, 2.1, 1.9 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], 0, 0.9) end
-- burst pod coils
local function coil(cx, cy, r0, r1, turns, a0)
  local pts = {}
  for i = 0, 60 do local t = i / 60
    local a = a0 + t * turns * 2 * pi
    local r = r0 + (r1 - r0) * t
    pts[#pts + 1] = { cx + cos(a) * r, cy + sin(a) * r * 0.85 }
  end
  return c:line(pts, 2), pts
end
local pm = HP.mask()
local c1 = coil(44, 39, 4.2, 0.6, 1.45, pi * 0.9)
local c2 = coil(51, 41, 3.4, 0.5, 1.3, pi * 1.6)
local tail = c:line({ { 40, 41 }, { 42, 43 }, { 45, 44 }, { 48, 45 } }, 2)
pm:add(tail):add(c1):add(c2)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.13, 0.28, 0.44, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.09 and t > 0.05 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- curved side veins swept to the tip
  local ph = (t * len - abs(s) ^ 1.5 * 9) / 6.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.12 and abs(s) < 0.78 and t > 0.08 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.1 then c:put(x, y, COOL, ltok) end end)

-- pod coils: tubular, pale ridge on top, dark under
local ptok = { r = { name = "pod" } }
local pn = X.pillow(pm, 1.2)
local pb = {}
X.ao(pb, tail, c1, 1, -1)
A.shade(c, pm, pn, POD, { tok = ptok, bias = pb, amb = 0.12, wrap = 0.3 })
for _, p in ipairs{ { 42, 36 }, { 49, 38 }, { 43, 36 } } do c:put(p[1], p[2], POD[6], ptok) end
c:put(39, 41, POD[3], ptok) c:put(39, 42, POD[2], ptok)

-- sprout: translucent stem, cotyledon paddles, first true leaf
local stok = { r = { name = "stem" } }
local sp = { { 21, 44 }, { 19, 36 }, { 23, 28 }, { 22, 19 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - 0.2 * t end)
local cl, cln = A.oval(14.5, 28.5, 4.2, 2.6, 0.22, 0.6)
local cr, crn = A.oval(29.5, 27.5, 4.2, 2.6, -0.25, 0.6)
local ctok = { r = { name = "cot" } }
cl:cut(sm) cr:cut(sm)
A.shade(c, cl, cln, COT, { tok = ctok, amb = 0.12, wrap = 0.3 })
A.shade(c, cr, crn, COT, { tok = ctok, amb = 0.12, wrap = 0.3 })
-- cotyledon midribs + attach lines
for x = 12, 18 do if cl:has(x, 29 - floor((x - 12) / 4)) then c:put(x, 29 - floor((x - 12) / 4), COT[3], ctok) end end
for x = 25, 32 do local y = 27 + floor((x - 25) / 5) if cr:has(x, y) then c:put(x, y, COT[3], ctok) end end
c:put(13, 27, COT[6], ctok) c:put(14, 27, COT[6], ctok) c:put(27, 26, COT[6], ctok)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.5, 0.75 }, amb = 0.15, wrap = 0.3 })
-- translucent stem: pale core line on the lit side
sm:each(function(x, y) if y > 20 and y < 42 and (x + y) % 4 ~= 1 and not sm:has(x - 1, y) then c:put(x, y, STEM[4], stok) end end)
-- true leaf: serrated ovate, pink-flushed edge
local tm, tn, TT, TS, tl = A.blade(22, 20, 25, 13, 31, 9, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 4.1 * sin(pi * (0.1 + 0.9 * t)) ^ 0.8)
end, { fold = 0.4 })
local tcut = {}
tm:edge():each(function(x, y) local k = K(x, y) if abs(TS[k]) > 0.75 and TT[k] > 0.2 and floor(TT[k] * tl) % 3 == 0 then tcut[#tcut + 1] = k end end)
for _, k in ipairs(tcut) do tm.s[k] = nil end
tm:cut(sm)
local tb = {}
X.ao(tb, tm, sm, 1, -1)
A.shade(c, tm, tn, LEAF, { tok = ctok, bias = tb, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.12 and TT[k] < 0.9 then c:put(x, y, TS[k] <= 0 and VEIN or LEAF[3], ctok) end end)
tm:edge():each(function(x, y) local k = K(x, y) if TS[k] > 0.55 and TT[k] > 0.25 then c:put(x, y, PINK, ctok) end end)

-- seeds: tiny round, mottled; flying seed near the pod
seeds[#seeds + 1] = { 55, 32, 1.7, 1.6 }
seeds[#seeds].m, seeds[#seeds].n = A.oval(55, 32, 1.7, 1.6, 0, 0.9)
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  if i == 1 then vis:cut(sm) end
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local sb = {}
  for j = 1, i - 1 do X.ao(sb, vis, seeds[j].m, 1, -1) end
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.06, wrap = 0.2, cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 } })
  vis:each(function(x, y) local k = K(x, y)
    if (idx[k] or 1) >= 2 and (idx[k] or 1) <= 4 and X.hash(x, y, i + 5) > 0.7 then c:put(x, y, SEED[idx[k] + 2], tok) end end)
  local bx, by = A.specAt(vis, s.n, 40)
  if bx then c:put(bx, by, "#f2d8a8", tok) end
end
-- sprouting seed coat split at the stem
c:put(21, 43, STEM[3], stok)

A.fin(c, NAME)

-- dahlia-seed (final, Opus single pass). Three slim, flat dahlia achenes (dark brown wedge with a pale buff
-- margin, a central rib and a squared-off crown) fanned out on a torn dahlia leaflet: broad ovate, sharply serrated
-- edge, pinnate veins off a pale midrib, V-fold light, cool reflected edge, AO + contact shadows. The right achene
-- has germinated: purple-flushed stem, two spoon-shaped cotyledons and a first true leaf of three serrated
-- leaflets (the dahlia's pinnate leaf in miniature), and a white root dangling over the leaf edge.
-- quirk: a single curled magenta ray petal from the parent flower has stayed stuck to the leaf.
local NAME = "dahlia-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1a3d30", "#24583c", "#327545", "#4d944c", "#76b45a", "#a8d27a" }
local VEIN, COOL, TORN = "#c6e292", "#3a6a6c", "#dcecaa"
local ACH = { "#1c1216", "#2e1e1e", "#463026", "#604430", "#806044", "#a8865c" }
local MARGIN = "#cdb48c"
local STEM = { "#4e3456", "#6c6a4c", "#8fb468", "#c6e29a" }
local PET = { "#561640", "#861f58", "#bb2f6e", "#de4b88", "#f37aa6", "#ffb6cc" }
local ROOT = { "#a89878", "#d8ccac", "#f4eedc" }

-- serrated ovate leaflet, tip to the right, torn base on the left
local lm, ln, LT, LS, len = A.blade(9, 47, 32, 39, 57, 45, function(t)
  if t > 0.99 then return -1 end
  return max(0.4, 9.2 * sin(pi * min(1, t ^ 0.78)) ^ 0.75)
end, { fold = 0.42 })
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local ph = (t * len + abs(s) * 2.2) / 3.4 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)               -- sawtooth: teeth lean toward the tip
  if t > 0.14 and abs(s) > 0.93 - 0.2 * f then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local torn = A.tear(lm, LT, LS, len, true, 3.0, 11)

local seeds = { { 20.5, 44.5, 4.6, 1.7, 2.75 }, { 29, 47.6, 4.8, 1.75, 0.12 }, { 38.2, 43.8, 4.6, 1.7, -0.95 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.5) end
-- quirk petal (on the leaf near the tip)
local pm, pn, PT, PS = A.blade(44, 47, 49, 42, 54, 44.5, function(t)
  if t > 0.98 then return -1 end return max(0.5, 1.9 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.6) end, { fold = 0.5 })
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, pm, 1, -1) A.cast(bias, lm, pm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.03 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / 6.0 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.72 and t > 0.08 and t < 0.86 then
    c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if lm:has(x, y) then local k = K(x, y) c:put(x, y, LS[k] < 0.4 and TORN or LEAF[4], ltok) end end)

-- quirk: curled magenta ray petal, groove down its middle, rolled lit edge
local ptok = { r = { name = "petal" } }
local pidx = A.toneN(c, pm, pn, PET, { tok = ptok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 }, amb = 0.16, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k]) < 0.16 and PT[k] > 0.12 and PT[k] < 0.88 then c:put(x, y, PET[max(1, pidx[k] - 1)], ptok) end end)
do local gx, gy = A.glint(c, pm, pn, PET[6], ptok, false) end

-- root out of the sprouting achene, hanging over the lower leaf edge
local rm, rn = A.tube({ { 35.5, 47.5 }, { 35.5, 50.5 }, { 36.5, 53 }, { 35.5, 57 } }, function(t) return 1.0 * (1 - t) + 0.35 end)
rm:cut(seeds[3].m)
local rb = {}
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.65 }, tok = { r = { name = "root" } } })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout: stem, cotyledons, first true leaf
local stok = { r = { name = "stem" } }
local sp = { { 40.5, 40.5 }, { 41.5, 35 }, { 40, 30 }, { 40, 24 } }
local sm, sn, ST = A.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
sm:each(function(x, y) local k = K(x, y) if ST[k] < 0.3 then c:put(x, y, STEM[max(1, sidx[k] - 1)], stok) end end) -- purple flush at the foot
local function bladeLeaf(ax, ay, cx, cy, bx, by, wmax, teeth, shape)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = max(0.35, wmax * sin(pi * min(1, t ^ (shape or 0.9))) ^ 0.6)
    if teeth then local ph = t * 9 / teeth w = w * (0.8 + 0.2 * (ph - floor(ph))) end
    return w
  end, { fold = 0.35 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  A.reflect(c, m, n, COOL, ltok, 0.55)
  return m
end
local cl = bladeLeaf(39.5, 27, 33, 24.5, 27, 27, 2.6, nil, 0.6)
local cr = bladeLeaf(41, 27, 48, 24.5, 54, 27.5, 2.6, nil, 0.6)
-- petiole and three serrated leaflets
for i = 0, 10 do local y = 24 - i c:put(i < 5 and 40 or 41, y, i < 3 and STEM[2] or STEM[3], stok) end
local tl = bladeLeaf(41, 15, 41.5, 10.5, 40, 6, 2.5, 0.42, 0.7)
local l1 = bladeLeaf(40, 19, 36.5, 17, 33.5, 14, 1.7, 0.5, 0.7)
local l2 = bladeLeaf(41, 18, 44.5, 16, 47.5, 13, 1.7, 0.5, 0.7)

-- achenes last: flat wedge, dark centre rib, pale buff margin on the lit rim, squared crown
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local idx = A.toneN(c, vis, s.n, ACH, { tok = tok, cuts = { 0.12, 0.28, 0.46, 0.64, 0.82 }, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(v) < 0.22 and abs(u) < 0.7 then c:put(x, y, ACH[max(1, idx[k] - 2)], tok) end   -- rib groove
    if v < -0.55 and abs(u) < 0.8 then c:put(x, y, MARGIN, tok) end                       -- pale wing margin
    if u > 0.86 then c:put(x, y, ACH[2], tok) end                                           -- squared crown
  end)
  local gx, gy = A.glint(c, vis, s.n, "#fff4d6", tok, false)
end
A.save2(c, NAME)

-- fenugreek-seed (B31, Opus single pass). Five small angular fenugreek seeds (golden amber, blocky rhomboid ovals
-- with the deep diagonal furrow that splits each seed into two lobes) on a torn scrap of a fenugreek leaflet
-- (obovate, toothed apex, midrib + pinnate veins, V-fold light, cool reflected edge, AO + contact shadows).
-- One seed has germinated: pale stem, two oblong cotyledons and the first trifoliate true leaf (three obovate,
-- tooth-tipped leaflets) that shows the fenugreek plant; a pale radicle with root hairs runs over the leaf edge.
-- quirk: the split seed coat still sits on the tip of one cotyledon like a little cap.
local NAME = "fenugreek-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = G.new(NAME)

local LEAF = { "#163a38", "#1f5644", "#2b744c", "#43944f", "#6cb45a", "#a2d274" }
local VEIN, COOL = "#c8e696", "#3c6e7a"
local SEED = { "#4a2a1c", "#7a4620", "#a8682a", "#cf9338", "#ebbe56", "#fae39a" }
local STEM = { "#4c7f58", "#80b26c", "#b6d892", "#e2f2bc" }
local ROOT = { "#9c8c80", "#cfc0a8", "#f2e8cc" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local ltok = { r = { name = "leaf" } }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 16, 50, 3.6, 2.4, 0.35 }, { 25, 47, 3.5, 2.3, -0.5 }, { 21, 41, 3.3, 2.2, 0.9 },
                { 31, 51, 3.4, 2.3, 0.1 }, { 42, 44, 3.6, 2.5, -0.25 } }
for _, s in ipairs(seeds) do
  s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.55)
  -- blocky: square off the ends a touch (fenugreek seeds are angular)
  s.m:add(G.oval(s[1], s[2], s[3] - 0.6, s[4] + 0.35, s[5], 0.55))
  local _, n2 = G.oval(s[1], s[2], s[3] - 0.6, s[4] + 0.35, s[5], 0.55)
  for k, v in pairs(n2) do if not s.n[k] then s.n[k] = v end end
end

-- leaf scrap: an obovate leaflet lying on the diagonal, broadest near the tip, torn off at the base
local lm, ln, LT, LS, len = G.blade(5, 50, 27, 57, 57, 38, function(t)
  if t > 0.975 then return -1 end
  local u = min(1, t * 0.92 + 0.08)
  return max(0.5, 8.6 * sin(pi * u ^ 1.4) ^ 0.75)
end, { fold = 0.4 })
-- torn base: a jagged cut across the blade
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local jag = 0.13 + 0.05 * sin(s * 9.0) + 0.03 * ((floor(s * 6) % 2 == 0) and 1 or -1)
  if LT[k] < jag then cut[#cut + 1] = k end
  -- toothed apex: notch every 3rd rim pixel near the tip
  if LT[k] > 0.66 and abs(s) > 0.84 and (x + y) % 3 == 0 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- a small tear bite out of the lower edge

-- sprouting seed stem/root first (seed coat drawn over the stem foot later)
local sprout = seeds[5]
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1)
  s.m:shift(1, 1):each(function(x, y) if lm:has(x, y) and not s.m:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
end
-- radicle: pale root over the leaf toward lower right, a few root hairs
local rm = G.sweep({ { 45, 46 }, { 48, 49 }, { 51, 50 }, { 54, 54 } }, function(t) return 1.25 - t * 0.8 end)
rm:cut(sprout.m)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)

G.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.12 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- pinnate veins, swept toward the apex
  local ph = (t * len - abs(s) * 7.0) / 6.0 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.78 and t > 0.16 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale broken edge pixels on the torn base
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] < 0.22 and abs(LS[k]) < 0.8 and (x + y) % 2 == 0 then c:put(x, y, LEAF[5], ltok) end end)

local rtok = { r = { name = "root" } }
rm:each(function(x, y) c:put(x, y, ROOT[2], rtok) end)
rm:edge():each(function(x, y) if rm:has(x + 1, y + 1) == false and (x + y) % 1 == 0 then c:put(x, y, ROOT[1], rtok) end end)
for _, q in ipairs{ { 47, 47 }, { 50, 49 } } do c:put(q[1], q[2], ROOT[3], rtok) end
for _, h in ipairs{ { 49, 52 }, { 53, 51 }, { 52, 54 } } do c:put(h[1], h[2], ROOT[3], rtok) end

-- stem
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 42, 43 }, { 41, 38 }, { 41, 32 }, { 41, 27 } }, function() return 1.05 end)
sm:cut(sprout.m)
G.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })

-- cotyledons: oblong, slightly upturned
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.4, 2.0 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  G.shade(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.12 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cot(40, 28, 34, 27, 28, 23)
local cr = cot(42, 28, 48, 27, 53, 24)

-- first true leaf: petiole + three obovate leaflets with a toothed tip
local pet = { { 41, 27 }, { 41, 23 }, { 42, 20 }, { 42, 18 } }
for i = 0, 24 do local x, y = G.bez(pet, i / 24) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end
local tl, parts = HP.mask(), {}
for _, a in ipairs{ -pi / 2, -pi + 0.6, -0.6 } do
  local ux, uy = cos(a), sin(a)
  local m, n = G.oval(42 + ux * 4.7, 17 + uy * 4.7, 3.7, 2.3, a, 1.4)
  m:cut(cl):cut(cr)
  local tok = { r = { name = "tl" .. #parts } }
  G.shade(c, m, n, LEAF, { tok = tok, cuts = CUTS, amb = 0.3, wrap = 0.35 })
  -- midrib
  for d = 2, 6 do local x, y = floor(42 + ux * d + .5), floor(17 + uy * d + .5) if m:has(x, y) then c:put(x, y, LEAF[3], tok) end end
  -- ambient line where it meets an earlier leaflet
  for _, o in ipairs(parts) do G.touch(m, o):each(function(x, y) c:put(x, y, LEAF[1], tok) end) end
  -- toothed tip: notch the apex pixel
  local tx, ty = floor(42 + ux * 8.6 + .5), floor(17 + uy * 8.6 + .5)
  if m:has(tx, ty) then m.s[K(tx, ty)] = nil c.pix[ty * 64 + tx] = nil c.own[ty * 64 + tx] = nil end
  parts[#parts + 1] = m tl:add(m)
end
c:put(42, 17, STEM[2], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = G.shade(c, vis, s.n, SEED, { bias = sb, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.3 })
  -- furrow: a diagonal groove across the seed, dark with a lit lip above it
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    local d = v - (u * 0.75 - 0.15)
    if abs(d) < 0.22 and abs(u) < 0.75 then c:put(x, y, SEED[2], tok)
    elseif d > -0.55 and d <= -0.22 and abs(u) < 0.6 and (idx[K(x, y)] or 1) >= 3 then c:put(x, y, SEED[min(6, (idx[K(x, y)] or 3) + 1)], tok) end
  end)
  -- one glossy speck
  local bx, by = G.specAt(vis, s.n, 30)
  if bx and i ~= 5 then c:put(bx, by, SEED[6], tok) end
end
-- the sprouting seed's split: the stem emerges from a crack (dark notch at the top)
c:put(42, 42, SEED[1]) c:put(43, 42, SEED[2])

-- quirk: split seed coat cap on the tip of the left cotyledon
local capm, capn = G.oval(29, 23, 2.6, 1.7, -0.6, 0.55)
local ctok = { r = { name = "cap" } }
G.shade(c, capm, capn, SEED, { tok = ctok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.3 })
c:put(28, 24, SEED[2], ctok) c:put(29, 24, SEED[2], ctok)
c:put(28, 22, SEED[6], ctok)

G.save(c, NAME)

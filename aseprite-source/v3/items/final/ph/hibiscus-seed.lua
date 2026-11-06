-- hibiscus-seed (final, Opus single pass). Three kidney-shaped hibiscus seeds (dark cocoa brown, rows of pale warty
-- dots, a notch at the hilum) on a torn hibiscus-leaf scrap (ovate, saw-toothed margin, midrib + palmate-ish veins,
-- V-fold light, cool reflected edge, AO + contact shadow under each seed). The front-right seed has germinated: pale
-- stem, two round cotyledons and a first serrated true leaf that shows the hibiscus leaf shape.
-- quirk: the seedling is already showing off a tiny red hibiscus flower with its long gold stamen column.
local NAME = "hibiscus-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#15392f", "#1f5440", "#2b7245", "#3f924a", "#64b252", "#98d06a" }
local VEIN, COOL = "#bfe48a", "#3b6d76"
local SEED = { "#24161b", "#3d2426", "#5a352d", "#7c4e38", "#a06c4a", "#c9996c" }
local STEM = { "#4b8551", "#80b866", "#b4dc8c", "#e0f2b8" }
local RED = { "#5a1530", "#8c1d3a", "#bf2a45", "#e64859", "#ff7b7c", "#ffb6a6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local ltok = { r = { name = "leaf" } }

-- seeds (cx, cy, rx, ry, angle)
local seeds = { { 17, 49, 3.4, 2.6, -0.25 }, { 26.5, 47, 3.3, 2.5, 0.35 }, { 38, 44, 3.4, 2.6, -0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: ovate hibiscus blade, torn across at the base, saw-toothed margin
local lm, ln, LT, LS, len = A.blade(7, 55, 28, 55, 55, 39, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.2 * sin(pi * (0.24 + 0.76 * t)) ^ 0.75)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / 3.1 + (s > 0 and 0.45 or 0)
  local f = ph - floor(ph)                       -- sawtooth: teeth lean toward the tip
  if t > 0.1 and t < 0.95 and abs(s) > 0.95 - 0.2 * f then cut[#cut + 1] = k end
  -- torn base: ragged line across the blade
  if t * len < 1.6 + 2.6 * X.hash(floor(s * 6), 3, 7) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.05 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- secondary veins, swept toward the tip, every ~5 px
  local d = (t * len - abs(s) * 6.5) % 5.2
  if d < 0.85 and abs(s) > 0.16 and abs(s) < 0.78 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- torn edge: pale fibrous rim where it ripped
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] * len < 5 and not bias[k] then c:put(x, y, LS[k] < 0 and "#c8e49a" or LEAF[4], ltok) end
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end
end)

-- sprout: stem
local stok = { r = { name = "stem" } }
local sp = { { 38, 42 }, { 37, 38 }, { 36, 33 }, { 37, 28 } }
local sm = A.stem(c, sp, function(t) return 1.05 end, STEM, { cut = seeds[3].m, tok = stok })
-- cotyledons: round, slightly heart-notched
local function coty(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.45)
  end, { fold = 0.25 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = coty(36, 33, 31, 32, 27, 29, 2.5)
local cr = coty(38, 33, 43, 33, 47, 30, 2.4)
-- first true leaf: ovate, toothed, up-right
local tm, tn, TT, TS, tlen = A.blade(37, 28, 40, 22, 47, 18, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 3.6 * sin(pi * (0.12 + 0.88 * t)) ^ 0.7)
end, { fold = 0.38 })
tm:cut(sm)
do local tc = {}
  tm:each(function(x, y) local k = K(x, y)
    local ph = TT[k] * tlen / 2.4 + (TS[k] > 0 and 0.5 or 0) local f = ph - floor(ph)
    if TT[k] > 0.2 and TT[k] < 0.92 and abs(TS[k]) > 0.9 - 0.25 * f then tc[#tc + 1] = k end end)
  for _, k in ipairs(tc) do tm.s[k] = nil end end
A.toneN(c, tm, tn, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.12, wrap = 0.28 })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.14 and TT[k] > 0.05 and TT[k] < 0.88 then c:put(x, y, TS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)

-- quirk: tiny hibiscus flower on a short pedicel, up-left
local ped = { { 37, 29 }, { 36, 26 }, { 35, 24 }, { 33, 22 } }
local pm = A.stem(c, ped, function(t) return 0.7 end, STEM, { tok = stok })
local fx, fy = 31, 18
local fm = HP.mask()
for i = 0, 4 do local a = -pi / 2 + i * 2 * pi / 5 + 0.3
  fm:add(A.rell(fx + cos(a) * 2.7, fy + sin(a) * 2.7, cos(a), sin(a), 2.5, 2.0)) end
fm:add(c:ellipse(fx, fy, 1, 1))
local ftok = { r = { name = "flower" } }
local fidx = A.shade(c, fm, A.body(fm, fx - 0.5, fy - 0.5, 5, 2.5, 0.5), RED, { tok = ftok, amb = 0.1, wrap = 0.3 })
-- petal seams (darker spokes) and the dark throat
for i = 0, 4 do local a = -pi / 2 + i * 2 * pi / 5 + 0.3 + pi / 5
  for r = 2, 4 do local x, y = floor(fx + cos(a) * r + 0.5), floor(fy + sin(a) * r + 0.5)
    if fm:has(x, y) then A.step(c, fidx, RED, x, y, -2, ftok) end end end
c:put(fx, fy, RED[1], ftok) c:put(fx + 1, fy, RED[2], ftok) c:put(fx, fy + 1, RED[2], ftok)
-- stamen column: pale stalk out of the throat, gold pollen tip
A.line(c, { { fx + 1, fy - 1 }, { fx + 3, fy - 3 } }, "#ffd9b8", ftok)
c:put(fx + 4, fy - 4, GOLD[3], ftok) c:put(fx + 4, fy - 5, GOLD[4], ftok) c:put(fx + 5, fy - 4, GOLD[2], ftok)
c:put(fx - 2, fy - 2, RED[6], ftok) -- petal sheen

-- seeds last: kidney shape, warty dot rows, hilum notch
for i, s in ipairs(seeds) do
  local ca, sa = cos(s[5]), sin(s[5])
  -- hilum notch on the lower long side
  local nx, ny = s[1] - sa * (s[4] + 0.3), s[2] + ca * (s[4] + 0.3)
  local hx, hy = floor(nx + 0.5), floor(ny + 0.5)
  s.m.s[K(hx, hy)] = nil
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.06, wrap = 0.2 }), SEED, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = sb, tok = tok })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local r = sqrt(u * u + v * v)
    -- concentric rows of pale warts
    if r > 0.38 and r < 0.62 and X.hash(x, y, 5 + i) > 0.45 then c:put(x, y, SEED[min(6, idx[k] + 2)], tok) end
  end)
  -- hilum: pale scar pixel beside the notch
  local ix, iy = floor(s[1] - sa * (s[4] - 0.6) + 0.5), floor(s[2] + ca * (s[4] - 0.6) + 0.5)
  if vis:has(ix, iy) then c:put(ix, iy, "#d8b48a", tok) end
  -- glint
  local gx, gy = A.specAt(vis, s.n, 40)
  if gx then c:put(gx, gy, "#f3dcc0", tok) end
end
A.save(c, NAME)

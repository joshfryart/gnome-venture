-- green-bean-seed (aC10_1, Opus single pass). Three kidney-shaped snap-bean seeds (cream-tan coats with maroon
-- mottling, a pale hilum eye in the concave notch) on a torn, pointed bean leaflet (jagged torn base, a ripped bite
-- out of the upper edge, midrib + curved lateral veins, V-fold light, cool reflected edge, AO and contact shadows).
-- The right seed has germinated: pale stem, two fat fleshy cotyledons, and a pair of heart-shaped true leaves with
-- pointed tips (the bean leaf shape); a pale radicle curls out over the leaf.
-- quirk: a flake of the mottled seed coat rides on the shoot tip like a little cap.
local NAME = "green-bean-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#173d30", "#215c3b", "#2e7b42", "#47a048", "#6fbd52", "#a6d870" }
local VEIN, COOL = "#c6e88e", "#3a6e74"
local SEED = { "#4a2a2e", "#6e4036", "#9a6648", "#c4955e", "#e2c08a", "#f6e4b8" }
local MOT  = { "#2e1424", "#46202e", "#62283a", "#7e3446", "#9a4652", "#b45c62" }
local HILUM, HIL_D = "#fff4d6", "#5a3034"
local STEM = { "#4c8452", "#82b46a", "#b4d88e", "#def0b8" }
local COT  = { "#4a5a22", "#6c7e2e", "#93a43c", "#bcc756", "#dce27e", "#f2f4b2" }
local ROOT = { "#857a6a", "#b4aa90", "#dad0b0", "#f4eed4" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 18, 47, 4.6, 2.6, -0.32 }, { 29, 49, 4.4, 2.6, 0.28 }, { 41, 41, 4.2, 2.5, -0.62 } }
for _, s in ipairs(seeds) do
  local m, n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85)
  -- kidney notch on the upper (lit) long side
  local ca, sa = cos(s[5]), sin(s[5])
  local nx, ny = s[1] + (s[4] + 0.9) * sa, s[2] - (s[4] + 0.9) * ca
  m:cut(G.rell(nx, ny, ca, sa, 1.9, 1.3))
  s.m, s.n, s.nx, s.ny = m, n, nx, ny
end

-- leaf scrap: pointed bean leaflet on the diagonal, base torn off
local lm, ln, LT, LS, len = G.blade(8, 54, 28, 51, 55, 33, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 10.2 * sin(pi * (0.22 + 0.78 * t)) ^ 0.85)
end, { fold = 0.36 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d = LT[k] * len
  if d < 4.5 and d < 0.8 + 3.6 * X.hash(floor((LS[k] + 1) * 4.5), 3, 7) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- ripped bite out of the upper edge
do local bx, by = G.bez({ { 8, 54 }, { 21, 52 }, { 35, 48 }, { 55, 33 } }, 0.38)
  lm:cut(G.rell(bx - 4.6, by - 8.2, 1, 0.3, 3.2, 2.2)) end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end

-- radicle (drawn into the bias before the leaf is toned so it casts)
local rm, rn, RT, RS = G.tube({ { 44, 43 }, { 47, 45 }, { 48, 49 }, { 51, 51 } }, function(t) return 1.25 * (1 - t) ^ 0.8 + 0.35 end)
rm:cut(seeds[3].m)
G.cast(bias, lm, rm, 1, 1, -1)

local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 and t < 0.93 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- curved lateral veins sweeping toward the tip
  for _, vt in ipairs{ 0.2, 0.38, 0.56, 0.72 } do
    local dd = (t - vt) * len - abs(s) ^ 1.3 * 6.5
    if dd > -0.5 and dd < 0.5 and abs(s) > 0.16 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn base: pale broken fibres along the torn edge
lm:each(function(x, y) local k = K(x, y)
  if LT[k] * len < 5 and not lm:has(x - 1, y) and not bias[k] then c:put(x, y, LS[k] < 0.2 and LEAF[5] or LEAF[3], ltok) end end)

-- radicle
local rtok = { r = { name = "radicle" } }
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
c:put(52, 52, ROOT[2], rtok)

-- shoot: stem, cotyledons, heart-shaped true leaves
local stok = { r = { name = "stem" } }
local sp = { { 40, 39 }, { 42, 32 }, { 37, 27 }, { 38, 18 } }
local sm, sn = G.tube(sp, function(t) return 1.15 - 0.15 * t end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

local ctok = { r = { name = "cotyledon" } }
local cots = {}
for _, q in ipairs{ { 34.6, 27.6, -0.35 }, { 43.4, 27.2, 0.4 } } do
  local m, n = G.oval(q[1], q[2], 3.1, 2.0, q[3], 0.8)
  m:cut(sm)
  cots[#cots + 1] = m
  G.toneN(c, m, n, COT, { tok = ctok, cuts = CUTS, amb = 0.12, wrap = 0.25 })
end
-- AO where the cotyledons meet the stem
for _, m in ipairs(cots) do sm:grow(1):each(function(x, y) if m:has(x, y) then c:put(x, y, COT[2], ctok) end end) end

local function heart(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.84 + 0.16)) ^ 0.55)
  end, { fold = 0.32 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.13 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
    for _, vt in ipairs{ 0.3, 0.58 } do
      local dd = (T[k] - vt) * L - abs(S[k]) * 3.2
      if dd > -0.5 and dd < 0.5 and abs(S[k]) > 0.25 and abs(S[k]) < 0.75 then c:put(x, y, S[k] < 0 and LEAF[5] or LEAF[2], ltok) end
    end
  end)
  return m
end
local hl = heart(37, 19, 31, 19, 24, 12, 4.1)
local hr = heart(39, 19, 45, 18, 52, 11, 4.0)
-- node bud
c:put(38, 18, STEM[2], stok) c:put(38, 17, STEM[3], stok)

-- seeds last: mottled coats, hilum eye, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.1, wrap = 0.28 })
  vis:each(function(x, y) local k = K(x, y)
    local val = v[k] or 0
    local ti = 1
    for j, cu in ipairs({ 0.18, 0.34, 0.5, 0.66, 0.82 }) do if val >= cu then ti = j + 1 end end
    if sb[k] then ti = ti - 1 end
    ti = max(1, min(6, ti))
    -- low-frequency mottle: 2x2 cells, skipped on the brightest tone so the coat still reads pale
    local mot = X.hash(floor((x + i) / 2), floor((y + 2 * i) / 2), 13) > 0.62
    if mot and ti < 6 then c:put(x, y, MOT[ti], tok) else c:put(x, y, SEED[ti], tok) end
  end)
  -- hilum: pale eye with a dark seam, inside the notch
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + (s[4] - 0.9) * sa + 0.5), floor(s[2] - (s[4] - 0.9) * ca + 0.5)
  if vis:has(hx, hy) then c:put(hx, hy, HILUM, tok) end
  if vis:has(hx + 1, hy) then c:put(hx + 1, hy, HIL_D, tok) end
  if vis:has(hx - 1, hy) then c:put(hx - 1, hy, SEED[5], tok) end
end
-- glossy specular on the front seed
c:put(27, 48, "#fffaf0", { r = { name = "seed2" } })

-- quirk: seed-coat flake cap on the shoot tip
local cap = { { 37, 16, MOT[3] }, { 38, 16, SEED[5] }, { 39, 16, MOT[2] }, { 37, 15, SEED[4] }, { 38, 15, SEED[6] }, { 39, 15, SEED[3] }, { 38, 14, MOT[4] } }
local ktok = { r = { name = "cap" } }
for _, p in ipairs(cap) do c:put(p[1], p[2], p[3], ktok) end
c:put(38, 17, STEM[1], stok)

G.save2(c, NAME)

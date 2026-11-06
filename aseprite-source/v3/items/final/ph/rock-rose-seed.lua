-- rock-rose-seed (Sonnet high, single pass). Rock rose (Cistus): four tiny angular red-brown seeds (faceted, with a pale
-- hilum dot) on a torn scrap of grey-green rugose leaf (sunken net veins, pale fibres on the tear). One seed has split:
-- a blush-red hypocotyl rises from the husk with two smooth oval cotyledons and, above them, the first pair of true
-- leaves: oval, puckered, with fuzzy pale hairs on the margin. quirk: a drop of amber labdanum resin on the leaf,
-- with one seed stuck in it.
local NAME = "rock-rose-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }

local SAGE = { "#1c3735", "#2b5545", "#406f50", "#5f8d5d", "#86ac6e", "#b3cc88" }
local FRESH = { "#22463a", "#35694a", "#4e9254", "#78b663", "#a4d27c", "#d4ee9e" }
local SEEDC = { "#2c1820", "#4a2628", "#6e3a2c", "#93573a", "#b9794a", "#dba06c" }
local STEM = { "#6c3346", "#9c4f58", "#c97a68", "#eeb08a" }
local RESIN = { "#5a2418", "#8f3a1a", "#c4621c", "#ea8f26", "#fdbe48", "#ffe6a0" }
local HUSK = { "#3b2228", "#5f3a30", "#86593e", "#d9c79a", "#f3e7c4" }
local ltok, stok, ktok, rtok, ctok = {r={name="scrap"}}, {r={name="stem"}}, {r={name="seedc"}}, {r={name="resin"}}, {r={name="cot"}}

-- leaf scrap (horizontal, torn on the right)
local TORN = "#dbe7b6"
local lm, ln, LT, LS, len = G.blade(9, 47, 28, 54, 54, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, t * 0.97 + 0.03)) ^ 0.62)
end, { fold = 0.4 })
local cutk = {}
lm:each(function(x, y) local k = K(x, y)
  local j = 0.84 + 0.05 * sin(LS[k] * 6.5 + 0.8) + 0.035 * ((floor((LS[k] + 1) * 5) % 2 == 0) and 1 or -1)
  if LT[k] > j then cutk[#cutk + 1] = k end
end)
for _, k in ipairs(cutk) do lm.s[k] = nil end

-- seeds
local SHAPE = { { -3.6, -0.6 }, { -1.6, -2.7 }, { 1.8, -2.5 }, { 3.7, -0.2 }, { 2.4, 2.3 }, { -1.2, 2.7 } }
local function mkseed(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang), sin(ang)
  local pts = {}
  for i, p in ipairs(SHAPE) do local u, v = p[1] * rx / 3.4, p[2] * ry / 2.7
    pts[i] = { cx + u * ca - v * sa, cy + u * sa + v * ca } end
  local m = c:poly(pts)
  local n = X.pillow(m, 2.0)
  return { m = m, n = n, cx = cx, cy = cy, ang = ang, pts = pts }
end
local seeds = { mkseed(15, 46, 3.6, 2.8, 0.4), mkseed(22, 50, 3.6, 2.9, -0.5), mkseed(27, 45, 3.4, 2.7, 0.9), mkseed(30, 50, 3.2, 2.6, -0.2) }
local resin = G.oval(35.0, 51.4, 3.4, 2.9, 0.2, 1.1)
local germ = HP.mask() -- husk area
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, resin, 1, -1) G.cast(bias, lm, resin, 1, 2, -1)
local hx, hy = 43, 46
X.ao(bias, lm, G.oval(hx, hy, 4.2, 2.6, 0, 1), 1, -1)
G.toneN(c, lm, ln, SAGE, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- midrib, net veins pressed in (rugose), pale tear fibres, cool bounce edge
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.1 and t > 0.03 and t < 0.84 then c:put(x, y, s <= 0 and SAGE[6] or SAGE[3], ltok) return end
  -- lateral veins sweeping to the tip, then cross links = net
  local ph = (t * len - abs(s) * 3.6) / 7.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.12 and abs(s) < 0.82 then c:put(x, y, s < 0 and SAGE[5] or SAGE[2], ltok) return end
  -- rugose pits: dark dimples with a pale lip on the lit side
  local hsh = X.hash(x, y, 5)
  if hsh > 0.9 and abs(s) > 0.18 then c:put(x, y, s < 0 and SAGE[3] or SAGE[1], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.08 and LT[k] < 0.8 then c:put(x, y, "#3a7468", ltok) end end)
-- torn edge: pale fibre line + a few frays
lm:each(function(x, y) local k = K(x, y)
  local j = 0.84 + 0.05 * sin(LS[k] * 6.5 + 0.8) + 0.035 * ((floor((LS[k] + 1) * 5) % 2 == 0) and 1 or -1)
  if LT[k] > j - 0.028 and not bias[k] then c:put(x, y, (x + y) % 3 == 0 and SAGE[6] or TORN, ltok) end
end)

-- seed painter: faceted angular seed, pale hilum, ambient dark where seeds touch
local function drawSeed(s, vis, sb)
  local ca, sa = cos(s.ang), sin(s.ang)
  local sk = {}
  G.toneN(c, vis, s.n, SEEDC, { bias = sb, tok = ktok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, amb = 0.12, wrap = 0.3 })
  vis:each(function(x, y)
    local dx, dy = x - s.cx, y - s.cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    -- two facet edges: a dark crease across the body and a lit facet on the upper left
    if u < -0.2 and v < -0.2 and v > -2.0 and u > -3.0 then c:put(x, y, SEEDC[5], ktok) end
  end)
  -- facet creases between vertices
  G.bres(c, s.pts[2][1], s.pts[2][2], s.pts[5][1], s.pts[5][2], function(x, y) if vis:has(x, y) then return SEEDC[2] end end, ktok)
  G.bres(c, s.pts[3][1], s.pts[3][2], s.pts[5][1], s.pts[5][2], function(x, y) if vis:has(x, y) then return SEEDC[3] end end, ktok)
  c:put(floor(s.cx - ca * 2.6 + 0.5), floor(s.cy - sa * 2.6 + 0.5), SEEDC[6], ktok)      -- hilum glint at one tip
end
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i < 4 then vis:cut(resin) end
  if i == 4 then X.ao(sb, s.m, resin, 1, -1) end
  drawSeed(s, vis, sb)
end

-- resin drop over the 4th seed (quirk): amber, glossy, one bright spec, bounce
G.toneN(c, resin, resin and (function() local m, n = G.oval(35.0, 51.4, 3.4, 2.9, 0.2, 1.1) return n end)(), RESIN, { tok = rtok, cuts = { 0.18, 0.36, 0.54, 0.72, 0.88 }, amb = 0.1, wrap = 0.35 })
c:put(33, 49, RESIN[6], rtok) c:put(34, 49, RESIN[6], rtok) c:put(33, 50, RESIN[5], rtok)
c:put(37, 53, RESIN[4], rtok) c:put(36, 53, RESIN[4], rtok)
-- thin resin thread toward the seed
c:put(32, 51, RESIN[3], rtok) c:put(31, 52, RESIN[2], rtok)

-- germinating seed: two husk halves split apart, pale inner face, curled radicle on the leaf
local hl = G.oval(hx - 2.6, hy + 0.2, 3.0, 2.6, -0.5, 0.9)
local hr = G.oval(hx + 3.0, hy + 0.2, 3.0, 2.6, 0.5, 0.9)
for _, h in ipairs{ hl, hr } do
  local m, n = h[1] and h[1] or nil, nil
end
local function husk(cx, cy, ang, left)
  local m, n = G.oval(cx, cy, 3.1, 2.6, ang, 0.9)
  G.toneN(c, m, n, SEEDC, { tok = ktok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, amb = 0.1, wrap = 0.3 })
  -- pale inner face on the cut side
  m:each(function(x, y)
    local inner = left and (x >= cx + 1.2) or (x <= cx - 1.2)
    if inner and abs(y - cy) < 2 then c:put(x, y, abs(y - cy) < 1 and HUSK[5] or HUSK[4], ktok) end
  end)
  return m
end
-- radicle first (under husks)
local rm, rn = G.tube({ { hx + 1, 47 }, { hx + 4, 49 }, { hx + 7, 49 }, { hx + 9, 46 } }, function(t) return 0.95 * (1 - t) + 0.35 end)
G.toneN(c, rm, rn, { "#9a8c78", "#cdbf9e", "#efe3c0", "#fff6da" }, { tok = stok, cuts = { 0.3, 0.6, 0.85 }, amb = 0.2, wrap = 0.3 })
local mL = husk(hx - 3.1, hy + 0.4, -0.45, true)
local mR = husk(hx + 3.2, hy + 0.4, 0.45, false)

-- sprout stem (blush hypocotyl)
local sp = { { hx, hy - 1 }, { hx - 1, 38 }, { hx + 1, 30 }, { hx, 22 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.15 - 0.3 * t end)
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.28, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
sm:each(function(x, y) local k = K(x, y) if ST[k] < 0.08 then c:put(x, y, STEM[1], stok) end end)

-- cotyledons: smooth oval pair
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.5, 3.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7)
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, FRESH, { tok = ctok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.86 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and FRESH[6] or FRESH[3], ctok) end end)
  return m
end
local cl = cot(hx, 31, hx - 6, 28, hx - 13, 30)
local cr = cot(hx, 29, hx + 7, 26, hx + 13, 29)

-- true leaf pair: oval, puckered, hairy
local function tleaf(ax, ay, cx, cy, bx, by, side)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 3.9 * sin(pi * min(1, t * 0.94 + 0.06)) ^ 0.62)
  end, { fold = 0.45 })
  m:cut(sm):cut(cl):cut(cr)
  G.toneN(c, m, n, SAGE, { tok = ltok, cuts = { 0.12, 0.28, 0.44, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
  -- lighter fresh tone on the first leaves
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.15 and t > 0.05 and t < 0.85 then c:put(x, y, s <= 0 and SAGE[6] or SAGE[4], ltok) return end
    local ph = (t * L - abs(s) * 2.2) / 3.4
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.85 and abs(s) > 0.2 and abs(s) < 0.8 and t > 0.1 then c:put(x, y, s < 0 and SAGE[5] or SAGE[2], ltok) end
  end)
  -- hairs along the margin: pale pixels just outside the blade
  m:edge():each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 9) > 0.62 and not cl:has(x, y) and not cr:has(x, y) and not sm:has(x, y) then c:put(x, y, "#d9e8b8", ltok) end end)
  return m
end
local tl = tleaf(hx, 24, hx - 5, 21, hx - 11, 10, -1)
local tr = tleaf(hx, 24, hx + 7, 20, hx + 12, 11, 1)
-- terminal bud
c:put(hx, 20, STEM[3], stok) c:put(hx, 21, STEM[2], stok) c:put(hx - 1, 20, FRESH[4], ctok) c:put(hx + 1, 20, FRESH[3], ctok) c:put(hx, 19, FRESH[5], ctok)
-- contact shadow under cotyledons on the stem
for _, p in ipairs{ {hx - 1, 29}, {hx + 1, 30} } do c:put(p[1], p[2], STEM[1], stok) end

G.save(c, NAME)

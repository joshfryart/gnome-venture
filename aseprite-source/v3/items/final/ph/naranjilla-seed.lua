-- naranjilla-seed (final, Opus single pass). Small flat buff seeds (lens-shaped, a ringed rim and a dark hilum notch)
-- lying on a torn strip of naranjilla leaf (dark green, hairy, shallow-lobed, PURPLE midrib and veins, ragged torn end
-- on the left, natural tip on the right). One seed has sprouted: a purple fuzzy stem, two oval seed leaves and a first
-- true leaf, broad and shallow-lobed with purple veins (the naranjilla look).
-- quirk: one seed is still stuck in a glossy blob of the fruit's green jelly pulp.
local NAME = "naranjilla-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

local LEAF = { "#1b3833", "#26503e", "#336c46", "#478b4d", "#69a955", "#9cc96c" }
local PV = { "#4a2c6a", "#6f4598", "#9a6cc4", "#c7a2ea" }          -- purple vein ramp
local STEM = { "#3a2650", "#563a78", "#77569c", "#9a7abd", "#c2a6dc", "#e4d2f2" }
local SEED = { "#664428", "#946c3e", "#bd955a", "#d8b878", "#ecd49c", "#fff0c8" }
local JEL = { "#2c6438", "#3f8a44", "#62ac4e", "#8ccc66", "#bde58e", "#e8fbc4" }
local COOL = "#3d6f78"

---------------------------------------------------------------- leaf scrap (diagonal, torn left end)
local lm, ln, LT, LS, len = A.blade(9, 50, 31, 57, 56, 39, function(t)
  if t > 0.985 then return -1 end
  local w = 9.6 * sin(pi * (0.22 + 0.78 * t)) ^ 0.6
  w = w * (1 - 0.13 * abs(sin(t * pi * 3.2)))     -- shallow lobes
  return max(0.4, w)
end, { fold = 0.34 })
-- ragged tear across the left end
do local cut = {}
  lm:each(function(x, y) local k = K(x, y)
    local saw = abs(((LS[k] * 2.6 + 0.3) % 1) - 0.5) * 4.2 + X.hash(x, y, 7) * 1.2
    if LT[k] * len < 1.2 + saw then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do lm.s[k] = nil end
  -- a small torn bite out of the upper edge
  lm:cut(HP.ellipse(22, 44, 2, 1))
  A.clean(lm)
end

-- seeds (cx, cy, rx, ry, angle)
local seeds = { { 15, 50, 3.1, 2.3, 0.5 }, { 23, 53, 3.2, 2.3, -0.3 }, { 30, 50, 3.0, 2.3, 0.9 }, { 39, 47, 3.1, 2.3, -1.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.5) end
local SPR = seeds[4]
-- pulp blob (quirk)
local jm = HP.ellipse(48, 42, 4, 3)
local jn = X.sphere(48, 42, 4, jm)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
X.ao(bias, lm, jm, 1, -1) A.cast(bias, lm, jm, 1, 2, -1)
local ltok = A.tok("leaf")
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
-- purple midrib + veins sweeping to the tip
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.04 and t < 0.93 then c:put(x, y, s <= 0 and PV[3] or PV[2], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.5 + (s > 0 and 0.45 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.8 and abs(s) > 0.15 and abs(s) < 0.66 and t > 0.06 and t < 0.86 then c:put(x, y, s < 0 and PV[2] or PV[1], ltok) return end
  -- hairy surface: sparse pale hair glints on the lit half
  if s < -0.2 and X.hash(x, y, 3) > 0.9 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + 2)], ltok) end
end)
-- cool reflected light on the lower (shade) rim
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

---------------------------------------------------------------- sprout
local stok = A.tok("stem")
local sp = { { 39, 46 }, { 40, 39 }, { 33, 33 }, { 34, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.05 - 0.15 * t end)
sm:cut(SPR.m)
local sidx = A.shade(c, sm, sn, STEM, { amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.34, 0.5, 0.66, 0.82 }, tok = stok })
-- fuzzy stem: pale hair flecks along the lit edge
sm:each(function(x, y) if X.hash(x, y, 11) > 0.72 and (sidx[K(x, y)] or 1) >= 4 then c:put(x, y, STEM[6], stok) end end)

local function blade(ax, ay, cx, cy, bx, by, W, lobes, tok, veins)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = W * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.6
    if lobes then w = w * (1 - 0.16 * abs(sin(t * pi * lobes))) end
    return max(0.4, w)
  end, { fold = 0.32 })
  m:cut(sm)
  A.clean(m)
  local b = {}
  X.ao(b, m, sm, 1, -1)
  local idx = A.toneN(c, m, n, LEAF, { tok = tok, bias = b, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.06 and t < 0.86 then c:put(x, y, veins and (s <= 0 and PV[4] or PV[2]) or (s <= 0 and LEAF[6] or LEAF[3]), tok) return end
    if veins then
      local ph = (t * L - abs(s) * 3.2) / 4.2 + (s > 0 and 0.5 or 0)
      local f = abs((ph - floor(ph)) - 0.5) * 2
      if f > 0.84 and abs(s) > 0.16 and abs(s) < 0.74 and t > 0.08 and t < 0.84 then c:put(x, y, s < 0 and PV[3] or PV[2], tok) end
    end
  end)
  -- hair rim on the lit edge
  m:edge():each(function(x, y) local k = K(x, y) if S[k] < -0.5 and X.hash(x, y, 5) > 0.55 then c:put(x, y, LEAF[6], tok) end end)
  return m, S
end
local ctok = A.tok("cotyledon")
local cl = blade(34, 33, 30, 35, 25, 32, 2.3, nil, ctok, false)
local cr = blade(35, 32, 39, 33, 44, 30, 2.2, nil, ctok, false)
local ttok = A.tok("trueleaf")
local tl = blade(34, 25, 29, 19, 20, 13, 6.4, 3.4, ttok, true)
-- petiole ink-dark contact under true leaf
-- (ambient shading where cotyledons meet the stem)
for _, m in ipairs{ cl, cr } do sm:grow(1):clip(m):each(function(x, y) c:put(x, y, LEAF[2], ctok) end) end

---------------------------------------------------------------- seeds
local function drawSeed(s, i, ramp, sb)
  local tok = A.tok("seed" .. i)
  local vis = s.m:copy()
  local v = X.light(s.n, { amb = 0.18, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local r = u * u + w * w
    local i = floor(v[k] * 6) + 1
    if r > 0.42 and r < 0.62 then i = i - 1 end            -- ringed rim (flat lens seed)
    if sb and sb[k] then i = i + sb[k] end
    c:put(x, y, ramp[max(1, min(6, i))], tok)
  end)
  -- hilum notch at one end
  local hx, hy = floor(s[1] + ca * s[3] + .5), floor(s[2] + sa * s[3] + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, ramp[1], tok) end
  return tok
end
for i = 1, 3 do drawSeed(seeds[i], i, SEED) end
-- sprouting seed: coat split where the stem leaves it
drawSeed(SPR, 4, SEED)
for _, p in ipairs{ { 39, 45 }, { 40, 46 } } do c:put(p[1], p[2], SEED[2]) end
c:put(39, 44, STEM[4], stok) c:put(40, 45, STEM[3], stok)
-- pale radicle peeping out of the bottom of the sprouting seed
for _, p in ipairs{ { 40, 49, "#efe2c4" }, { 41, 50, "#d6c49a" } } do c:put(p[1], p[2], p[3], A.tok("root")) end
-- glints
c:put(14, 48, SEED[6]) c:put(28, 49, SEED[6])

---------------------------------------------------------------- quirk: seed in green jelly pulp
local jtok = A.tok("jelly")
local jidx = A.shade(c, jm, jn, JEL, { amb = 0.2, wrap = 0.35, cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 }, tok = jtok })
-- seed seen through the jelly (tinted), with the jelly's pale core around it
local inS = { 49, 43, 2.0, 1.5, 0.4 }
local im = A.oval(inS[1], inS[2], inS[3], inS[4], inS[5], 0.5)
im:clip(jm)
local TS = { "#6a7a3a", "#8e9a50", "#b2b86a", "#d0d488" }
im:each(function(x, y) local i = 3 if x + y > 92 then i = 2 end if x + y > 93 then i = 1 end if x + y < 91 then i = 4 end c:put(x, y, TS[i], jtok) end)
-- glassy rim: bright on the shade-side edge (light passing through), deep on the very bottom
jm:edge():each(function(x, y)
  if x >= 49 and y >= 43 then c:put(x, y, JEL[5], jtok) end
end)
c:put(46, 40, A.CREAM, jtok) c:put(47, 40, A.CREAM, jtok) c:put(45, 41, JEL[6], jtok)

A.save(c, NAME)

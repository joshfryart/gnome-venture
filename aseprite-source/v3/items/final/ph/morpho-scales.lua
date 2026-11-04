-- morpho-scales (final pass, Opus). Three long morpho wing scales laid like shingles: slim stalked paddles with a
-- toothed tip, fine lengthwise ridges, iridescent banding (violet at the root, electric blue to ice cyan at the tip),
-- AO and a contact shadow where they overlap, one hard glint on the front scale.
-- quirk: a tiny fourth scale has come loose and drifts off top-right, catching a cream sparkle.
local NAME = "morpho-scales"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local BLUE = { "#1a1d5c", "#1d3696", "#1f5bd0", "#2e8ff2", "#62c9ff", "#cdf6ff" }
local VIO  = { "#24164f", "#3b228a", "#5a34c0", "#7c5ae6", "#a98cff", "#dcd0ff" }
local STALK = { "#2a1d3e", "#4a3466", "#7a64a0" }

local function smooth(a, b, t) t = max(0, min(1, (t - a) / (b - a))) return t * t * (3 - 2 * t) end

-- one scale: base (ax,ay) -> tip (bx,by), bow control (cx,cy), max half width W
local function scale(ax, ay, cx, cy, bx, by, W, seed)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    return 0.55 + (W - 0.55) * smooth(0.06, 0.5, t) - 0.6 * smooth(0.8, 1, t)
  end, { fold = 0.12 })
  -- toothed tip: three rounded teeth
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    local tooth = abs(cos(S[k] * pi * 1.5))
    if T[k] > 0.86 + 0.14 * tooth ^ 0.7 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return { m = m, n = n, T = T, S = S, len = len, W = W, seed = seed }
end

local function paint(sc, bias, tok)
  local v = X.light(sc.n, { amb = 0.04, wrap = 0.2 })
  sc.m:each(function(x, y) local k = K(x, y)
    local t, s = sc.T[k], sc.S[k]
    local i = 1
    for j, cu in ipairs(A.CUTS) do if v[k] >= cu then i = j + 1 end end
    -- lengthwise ridges: a groove every 3 px across
    local sp = s * (sc.W + 0.6)
    if t > 0.14 and t < 0.92 and floor(sp + 0.5 + sc.seed) % 3 == 0 then i = i - 1 end
    -- brighter toward the tip (thin film catches more light)
    if t > 0.75 and s < 0.3 then i = i + 1 end
    if t < 0.12 then i = i - 1 end
    if bias[k] then i = i + bias[k] end
    i = max(1, min(6, i))
    -- iridescent band: violet near the root and on the shade rim, blue elsewhere (hard switch line)
    local useV = (t + 0.22 * s) < 0.36 or (s > 0.82 and t < 0.7)
    c:put(x, y, (useV and VIO or BLUE)[i], tok)
  end)
end

-- three scales, back to front
local s1 = scale(21, 50, 15, 34, 23, 15, 4.4, 0)
local s3 = scale(28, 52, 41, 46, 51, 35, 4.2, 1)
local s2 = scale(24, 52, 30, 36, 39, 17, 4.8, 2)

local function stalk(sc, ax, ay)
  -- short pedicel socket: dark knob at the root
  c:put(ax, ay, STALK[1]) c:put(ax, ay - 1, STALK[2]) c:put(ax - 1, ay, STALK[2])
end

local b1, b3, b2 = {}, {}, {}
X.ao(b1, s1.m, s2.m, 1, -1) A.cast(b1, s1.m, s2.m, 1, 1, -1)
X.ao(b3, s3.m, s2.m, 1, -1) A.cast(b3, s3.m, s2.m, 1, 1, -1)
local t1, t2, t3 = { r = { name = "s1" } }, { r = { name = "s2" } }, { r = { name = "s3" } }
paint(s1, b1, t1)
paint(s3, b3, t3)
paint(s2, b2, t2)
-- deep separation line on the back scales where they touch the front one
for _, p in ipairs{ { s1, t1 }, { s3, t3 } } do
  s2.m:grow(1):cut(s2.m):each(function(x, y) if p[1].m:has(x, y) then c:put(x, y, VIO[1], p[2]) end end)
end
stalk(s1, 21, 50) stalk(s3, 28, 52) stalk(s2, 24, 52)

-- hard glint on the front scale (2x1 + 1) along the lit ridge
local gx, gy = A.specAt(s2.m, s2.n, 30)
c:put(gx, gy, BLUE[6], t2) c:put(gx + 1, gy - 1, BLUE[6], t2)
-- tooth tips on the front scale catch light
s2.m:each(function(x, y) local k = K(x, y) if s2.T[k] > 0.93 and s2.S[k] < 0.2 and not s2.m:has(x, y - 1) then c:put(x, y, BLUE[5], t2) end end)

-- quirk: tiny loose scale drifting top-right
local q = scale(46, 22, 50, 18, 52, 13, 1.9, 0)
local tq = { r = { name = "q" } }
paint(q, {}, tq)
c:sparkle(54, 10)

A.save(c, NAME)

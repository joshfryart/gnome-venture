-- noni-seed (C3, Opus single pass): three reddish-brown noni seeds (oblong, a dark groove along the back, each with the
-- pale papery air chamber that lets noni seeds float) resting on a torn scrap of glossy noni leaf (deep green, pale
-- curved pinnate veins, wet specular glints, ripped pale-edged base). The front-right seed has germinated: a thin pale
-- stem lifts a pair of opposite, broad elliptic noni leaves with yellow-green veins and a tiny terminal bud.
-- quirk: a caterpillar has nibbled a neat round hole through the leaf scrap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_3.lua")
local HP, X, K, B = A.HP, A.X, A.K, A.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("noni-seed")
local LEAF = { "#123430", "#1b4a3c", "#256346", "#347f4c", "#55a052", "#8cc866" }
local VEIN, VEIND, TORN = "#c8e08a", "#2e6a48", "#a8d080"
local SEED = { "#2e1414", "#4e2018", "#723222", "#984a30", "#bc6a44", "#e09868" }
local SAC = { "#6a5040", "#957a5c", "#bea47e", "#dcc8a0", "#f0e2c0", "#fff4d6" }
local STEM = { "#3f7a4c", "#6aa45c", "#9ccc78", "#cde8a8" }

-- leaf scrap
local LP = { { 7, 53 }, { 20, 48 }, { 38, 47 }, { 56, 40 } }
local lm, ln, LT, LS = A.tube(LP, function(t)
  if t > 0.98 then return -1 end
  return max(0.5, 6.6 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.6)
end, { flat = 0.5, bend = 0.2 })
-- ripped base: jagged cut on the left end
local rip = HP.mask()
lm:each(function(x, y) if x < 10 + floor(X.hash(0, y, 4) * 3) + floor((y % 3) / 2) then rip:set(x, y) end end)
lm:cut(rip)
-- quirk: nibbled hole
local hole = A.ell(22, 52, 1.6, 1.4, 0)
lm:cut(hole)
-- seeds
local seeds = { { 17, 47.5, 4.3, 2.6, -0.25 }, { 28, 49, 4.3, 2.6, 0.12 }, { 39, 44, 4.0, 2.5, -0.65 } }
local bias = {}
for _, s in ipairs(seeds) do s.m = A.ell(s[1], s[2], s[3], s[4], s[5]) X.ao(bias, lm, s.m, 1, -1) end
local ltok = A.tok("leaf")
local lidx = A.toneN(c, lm, ln, LEAF, { tok = ltok, bias = bias, amb = 0.14, wrap = 0.3, cuts = { 0.14, 0.3, 0.47, 0.64, 0.82 } })
local len = 52
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) ^ 0.7 * 5.5) / 6.2
  if abs(ph - floor(ph + .5)) < 0.09 and abs(s) > 0.18 and abs(s) < 0.8 and t > 0.05 and t < 0.9 then c:put(x, y, s < 0 and VEIN or LEAF[2], ltok) end
end)
-- torn edge pale, nibbled-hole rim browned
lm:edge():each(function(x, y)
  if rip:has(x - 1, y) or rip:has(x, y - 1) or rip:has(x, y + 1) then c:put(x, y, TORN, ltok) end
  if hole:grow(1):has(x, y) then c:put(x, y, "#8a7a3a", ltok) end
end)
hole:each(function(x, y) c:put(x, y, A.INK, ltok) end)
-- glossy glints on the lit half
for _, q in ipairs{ { 33, 41 }, { 34, 41 }, { 47, 38 } } do if lm:has(q[1], q[2]) then c:put(q[1], q[2], A.CREAM, ltok) end end
-- cool reflected light on the lower rim
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] and LS[k] > 0.7 and LT[k] > 0.25 and LT[k] < 0.9 and not bias[k] then c:put(x, y, "#3a6c72", ltok) end end)

-- sprout (drawn before the seeds so the coat sits over the stem foot)
local stok = A.tok("stem")
local sm, sn = A.tube({ { 39, 42 }, { 38, 36 }, { 40, 30 }, { 40, 24 } }, function() return 0.9 end, { N = 40 })
A.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
local function nleaf(p, w)
  local m, n, T, S = A.tube(p, function(t) if t > 0.97 then return -1 end return max(0.5, w * sin(pi * min(1, t * 0.95 + 0.06)) ^ 0.7) end, { flat = 0.55, N = 60 })
  m:cut(sm)
  local tk = A.tok("sl" .. p[4][1])
  A.toneN(c, m, n, LEAF, { tok = tk, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.2 and t > 0.08 and t < 0.86 then c:put(x, y, s <= 0 and VEIN or LEAF[3], tk) end
    local ph = (t * 15 - abs(s) * 2.6) / 3.6
    if abs(ph - floor(ph + .5)) < 0.12 and abs(s) > 0.35 and abs(s) < 0.8 and t > 0.15 and t < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], tk) end
  end)
  return m
end
local L1 = nleaf({ { 39, 25 }, { 35, 18 }, { 29, 17 }, { 24, 18 } }, 4.0)
local L2 = nleaf({ { 41, 25 }, { 44, 18 }, { 50, 15 }, { 55, 16 } }, 4.0)
-- terminal bud between the leaves
c:put(40, 23, STEM[4], stok) c:put(40, 22, STEM[3], stok) c:put(41, 23, STEM[2], stok)
c:put(30, 15, A.CREAM, A.tok("sl24"))

-- seeds last
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  local m, n, idx = A.seed(c, s[1], s[2], s[3], s[4], s[5], SEED, { shadow = LEAF[1], clip = lm, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .5), (-dx * sa + dy * ca) / (s[4] + .5)
    if u > 0.5 then c:put(x, y, SAC[max(1, min(6, idx[k] + 1))], tok)
    elseif abs(v) < 0.18 and u > -0.75 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok) end
    if u > 0.42 and u <= 0.5 then c:put(x, y, SEED[2], tok) end
  end)
  c:put(floor(s[1] - s[3] * 0.4), floor(s[2] - s[4] * 0.5), A.CREAM, tok)
end
-- split seed coat at the sprout foot
c:put(39, 42, STEM[3], stok) c:put(38, 42, SEED[1], A.tok("seed3"))
A.fin()

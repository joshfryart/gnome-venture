-- ceibo-seed (final, Opus aB1r1_1). Three glossy kidney-shaped ceibo (Erythrina crista-galli) seeds, mottled
-- oxblood-brown with darker blotches, a pale hilum in the notch and a bright specular, lying on a torn scrap of a
-- rhombic-ovate ceibo leaflet (6-tone, midrib with one hooked prickle, pinnate veins, cool reflected edge, pale
-- torn rim, AO + contact shadows). The left seed has sprouted: a reddish stem with a tiny prickle and the first
-- trifoliate leaf (three pointed leaflets with midribs) that shows the coral tree.
-- quirk: a fallen crimson ceibo petal, curled like a little boat, has drifted onto the leaf.
local NAME = "ceibo-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1a3424", "#26502c", "#386e32", "#548e3a", "#7cae48", "#b0d070" }
local VEIN, COOL, TORN = "#d6eca0", "#3c6070", "#e2eebc"
local SEED = { "#1c0e16", "#34161c", "#521f22", "#743028", "#9a4634", "#c46c4c" }
local STEM = { "#4e2e2a", "#7a4a36", "#a2704a", "#c8a070" }
local SL = { "#1c3a26", "#2a5a30", "#3e7a36", "#5c9a40", "#86ba50", "#b8da78" }
local RED = { "#4a0c22", "#7a1230", "#aa1c38", "#d4303e", "#f05a4c", "#ff9a7a" }
local ltok = { r = { name = "leaf" } }

-- leaf scrap: torn at the lower right, acuminate tip at the left
local lm, ln, LT, LS, len = A.blade(56, 53, 36, 54, 9, 42, function(t)
  if t > 0.985 then return -1 end
  local w = 10.2 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.75 * (1 - 0.3 * t)
  if t > 0.8 then w = w * (1 - (t - 0.8) * 2.2) end
  return max(0.5, w)
end, { fold = 0.4 })
local rim = A.tear(lm, LT, LS, len, 2.5, 7)

-- seeds: kidney = oval minus a notch on the lower side
local seeds = { { 20, 44, 4.4, 2.8, 0.45 }, { 30, 49, 4.6, 2.9, -0.25 }, { 41, 46, 4.4, 2.8, 0.2 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9)
  local ca, sa = cos(s[5]), sin(s[5])
  s.nx, s.ny = s[1] - sa * (s[4] + 1.2), s[2] + ca * (s[4] + 1.2)
  s.m:cut(HP.ellipse(s.nx, s.ny, 1.6, 1.6))
end
-- quirk petal mask (needed for the shadow)
local pm, pn, PT, PS = A.blade(45, 48, 51, 50, 57, 47, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 3.0 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7)
end, { fold = 0.7 })
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.cast(bias, lm, pm, 1, 2, -1)
local stemPts = { { 19, 42 }, { 17, 35 }, { 21, 30 }, { 21, 24 } }
local sm, sn = A.tube(stemPts, function(t) return 1.1 - 0.2 * t end)
A.cast(bias, lm, sm, 1, 1, -1)
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, per = 5.5, sweep = 3, vein = VEIN, cool = COOL, rim = rim, rimCol = TORN })
-- hooked prickle on the leaf midrib (ceibo leaflets carry them)
c:put(38, 53, LEAF[2], ltok) c:put(38, 52, STEM[3], ltok) c:put(37, 51, STEM[4], ltok)

-- sprout stem (reddish, woody) with one prickle
local stok = { r = { name = "stem" } }
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
c:put(16, 33, STEM[2], stok) c:put(15, 32, STEM[3], stok)

-- trifoliate leaf: terminal leaflet up, two laterals
local stk = { r = { name = "sleaf" } }
local function leaflet(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local w = W * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.8
    if t > 0.55 then w = w * (1 - (t - 0.55) * 1.5) end
    if t < 0.12 then w = 0.6 end
    return max(0.5, w)
  end, { fold = 0.45 })
  A.toneN(c, m, n, SL, { tok = stk, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and SL[6] or SL[3], stk) end end)
  return m
end
leaflet(21, 22, 13, 22, 8, 17, 3.4)
leaflet(21, 22, 30, 22, 34, 16, 3.4)
leaflet(21, 23, 22, 17, 21, 9, 4.0)

-- seeds: glossy, mottled, pale hilum
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  for j = i + 1, #seeds do vis:cut(seeds[j].m) end
  local v = X.light(s.n, { amb = 0.05, wrap = 0.25 })
  local mb = {}
  vis:each(function(x, y) local k = K(x, y)
    local h = X.hash(floor(x / 2), floor(y / 2), i * 13)
    if h < 0.3 then mb[k] = -1 end
  end)
  X.tone(c, vis, v, SEED, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, bias = mb, tok = tok })
  -- hilum: pale dash on the notch rim
  local ca, sa = cos(s[5]), sin(s[5])
  for d = -1, 1 do
    local x, y = floor(s.nx + sa * 1.8 + ca * d * 0.9 + .5), floor(s.ny - ca * 1.8 + sa * d * 0.9 + .5)
    if vis:has(x, y) then c:put(x, y, d == 0 and "#e8c89a" or "#b88a62", tok) end
  end
  local sx, sy = A.specAt(vis, s.n, 24)
  c:put(sx, sy, "#ffe8d4", tok) c:put(sx + 1, sy, SEED[6], tok)
end

-- quirk: fallen crimson petal, curled boat
local ptok = { r = { name = "petal" } }
A.toneN(c, pm, pn, RED, { tok = ptok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  if PS[k] > 0.55 and PT[k] > 0.15 and PT[k] < 0.85 then c:put(x, y, RED[2], ptok) end
  if abs(PS[k] + 0.2) < 0.12 and PT[k] > 0.2 and PT[k] < 0.8 then c:put(x, y, RED[6], ptok) end end)
A.save(c, NAME)

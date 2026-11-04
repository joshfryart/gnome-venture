-- basil-seed (ph, Opus single pass, aR3_5). Four tiny glossy black basil seeds (teardrop ovals, violet bounce, a pale
-- hilum dot at the narrow end, one glint each) lying on a torn scrap of a basil leaf (broad, cupped ovate blade with a
-- finely toothed margin, quilted puckers between swept veins, waxy specular, pale fibrous tear on the right, petiole
-- stub on the left, AO + contact shadow under the seeds). The left seed has sprouted: a slim square-ish stem with two
-- broad notched cotyledons and the first pair of pointed, cupped true basil leaves.
-- quirk: one seed has been soaked and wears its pale frog-spawn gel halo.
local NAME = "basil-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF  = { "#17432f", "#1f5e38", "#2d7d3e", "#46a046", "#6fc256", "#a6e07a" }
local VEINL, VEIND, COOL, TORN = "#c6ec96", "#24603a", "#3a6e70", "#d6efa4"
local SEED  = { "#1a1220", "#271a2e", "#38263e", "#4e3850", "#6c5470", "#9c86a4" }
local GEL   = { "#5d8288", "#86aaa8", "#a8c8bc", "#cfe4d2" }
local STEM  = { "#2b5c36", "#457f44", "#68a452", "#98c870" }
local CUTS  = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
-- leaf spine (quadratic bezier) so seeds sit along the cupped centre
local A, C, B = { 5, 41 }, { 30, 33 }, { 59, 50 }
local function spine(t, off)
  local u = 1 - t
  local x, y = u*u*A[1] + 2*u*t*C[1] + t*t*B[1], u*u*A[2] + 2*u*t*C[2] + t*t*B[2]
  local dx, dy = 2*u*(C[1]-A[1]) + 2*t*(B[1]-C[1]), 2*u*(C[2]-A[2]) + 2*t*(B[2]-C[2])
  local l = sqrt(dx*dx + dy*dy)
  return x - dy / l * off, y + dx / l * off, math.atan(dy, dx)
end
local seeds = {}
for _, q in ipairs{ { 0.3, 1.5, 0.4 }, { 0.46, -2.2, -0.35 }, { 0.6, 2.4, 0.2 }, { 0.75, -0.6, 0.7 } } do
  local x, y, a = spine(q[1], q[2]) seeds[#seeds + 1] = { x, y, 2.6, 1.7, a + q[3] }
end
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local GELI = 3
local gel = seeds[GELI].m:grow(2)
gel:add(c:ellipse(seeds[GELI][1] + 0.5, seeds[GELI][2] - 0.3, 4.4, 3.4))

-- leaf scrap: broad cupped basil blade, base on the left, torn across the right ------------------------------------
local lm, ln, LT, LS, len = G.blade(A[1], A[2], C[1], C[2], B[1], B[2], function(t)
  if t > 0.99 then return -1 end
  return max(0.4, 8.6 * sin(pi * min(1, t * 0.78 + 0.22) ^ 1.25) ^ 0.75)
end, { fold = 0.42 })
G.tear(lm, 11, 0, -1, 0.15, 1.8, 5)
-- fine teeth on the margin (basil is shallowly serrate)
local cut = {}
lm:edge():each(function(x, y) local k = K(x, y)
  if abs(LS[k]) > 0.8 and LT[k] > 0.2 and LT[k] < 0.93 then
    local ph = (LT[k] * len) / 3.2 + (LS[k] > 0 and 0.5 or 0)
    if ph - floor(ph) < 0.3 then cut[#cut + 1] = k end
  end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
lm:cut(gel:copy():cut(gel)) -- (no-op, keeps leaf whole under the gel)

local bias, aob = {}, {}
-- quilting: intervein bulges a tone up on the lit half, a tone down on the shade half
local PER = 6.2
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local ph = (t * len - abs(s) * 5.5) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f < 0.35 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 then bias[k] = (s < 0) and 1 or 0 end
  if f > 0.65 and abs(s) > 0.2 and t > 0.1 and s > 0 then bias[k] = -1 end
end)
for i, s in ipairs(seeds) do
  local m = (i == GELI) and gel or s.m
  X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 2, -1)
  X.ao(aob, lm, m, 1, -1) G.cast(aob, lm, m, 1, 2, -1)
end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.28, 0.46, 0.62, 0.8, 0.93 }, amb = 0.12, wrap = 0.3 })
-- midrib + swept lateral veins
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if aob[k] then return end
  if abs(s) < 0.1 and t > 0.02 and t < 0.95 then c:put(x, y, s <= 0 and VEINL or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / PER + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.12 and abs(s) < 0.8 and t > 0.08 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or VEIND, ltok) end
end)
-- cool reflected light on the shade rim, pale fibres along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if not aob[k] and LS[k] > 0.7 and LT[k] > 0.2 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.2 and not lm:has(x - 1, y) then c:put(x, y, TORN, ltok) end end)
-- waxy specular on the cupped lit shoulder
do local inn = lm:shrink(2) inn:each(function(x, y) if x < 30 or x > 50 or aob[K(x, y)] then inn.s[K(x, y)] = nil end end)
  local bx, by = G.specAt(inn, ln, 30)
  c:put(bx, by, "#e4f8b4", ltok) c:put(bx + 1, by, "#e4f8b4", ltok) c:put(bx + 2, by, LEAF[6], ltok) end
-- petiole stub
local ptok = { r = { name = "petiole" } }


-- quirk: soaked seed in a gel halo -----------------------------------------------------------------------------------
local gtok = { r = { name = "gel" } }
local gs = seeds[GELI]
local gn = X.sphere(gs[1] - 0.4, gs[2] - 0.4, 4.2, gel)
local gv = X.light(gn, { amb = 0.2, wrap = 0.4 })
gel:each(function(x, y) local k = K(x, y)
  local v = gv[k] local i = v < 0.5 and 2 or (v < 0.86 and 3 or 4)
  c:put(x, y, GEL[i], gtok) end)
gel:edge():each(function(x, y) local k = K(x, y) if gv[k] < 0.75 then c:put(x, y, GEL[1], gtok) end end)
c:put(gs[1] - 3, gs[2] - 2, "#fff4d6", gtok) c:put(gs[1] - 2, gs[2] - 3, "#fff4d6", gtok)

-- sprout from seed 1: stem, cotyledons, first true leaves ---------------------------------------------------------
local stok = { r = { name = "stem" } }
local SX, SY = floor(seeds[1][1] + 0.5), floor(seeds[1][2] + 0.5)
local sp = { { SX, SY }, { SX - 1, SY - 8 }, { SX + 1, SY - 16 }, { SX, 13 } }
local sm, sn = G.tube(sp, function(t) return 1.05 - 0.15 * t end)
sm:cut(seeds[1].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local ctok = { r = { name = "coty" } }
-- cotyledon: broad kidney blade with a notched tip
local function coty(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.5 * sin(pi * min(1, t * 0.7 + 0.18)) ^ 0.4)
  end, { fold = 0.25 })
  -- notch at the tip
  local cutn = {}
  m:each(function(x, y) local k = K(x, y) if T[k] > 0.86 and abs(S[k]) < 0.25 then cutn[#cutn + 1] = k end end)
  for _, k in ipairs(cutn) do m.s[k] = nil end
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = ctok, cuts = CUTS, amb = 0.14, wrap = 0.3, bias = b })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.12 and T[k] > 0.12 and T[k] < 0.7 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ctok) end end)
  return m
end
local CY = 26
local cl = coty(SX - 1, CY, SX - 5, CY - 2, SX - 8, CY + 2)
local cr = coty(SX + 1, CY, SX + 5, CY - 2, SX + 9, CY + 2)
-- true leaves: ovate, pointed, cupped, midrib, one pair of veins
local tlt = { r = { name = "trueleaf" } }
local function tleaf(ax, ay, cx, cy, bx, by, mirror)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, 3.3 * sin(pi * (t * 0.92 + 0.06) ^ 0.75) ^ 0.8)
  end, { fold = 0.45 })
  m:cut(sm)
  local b = {} X.ao(b, m, sm, 1, -1)
  G.toneN(c, m, n, LEAF, { tok = tlt, cuts = CUTS, amb = 0.12, wrap = 0.25, bias = b })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.13 and T[k] > 0.08 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and VEINL or LEAF[2], tlt) end
    local d = T[k] * L - (3.2 + abs(S[k]) * 2.6)
    if d > -0.5 and d < 0.5 and abs(S[k]) > 0.3 and abs(S[k]) < 0.75 then c:put(x, y, S[k] < 0 and LEAF[6] or LEAF[3], tlt) end
  end)
  return m
end
local tl1 = tleaf(SX - 1, 17, SX - 7, 15, SX - 11, 8)
local tl2 = tleaf(SX + 1, 17, SX + 7, 15, SX + 12, 9)
-- terminal bud between them
for _, q in ipairs{ { 0, 12, 5 }, { 0, 11, 6 }, { 1, 12, 4 }, { 1, 11, 4 }, { 0, 10, 5 }, { -1, 12, 5 } } do c:put(SX + q[1], q[2], LEAF[q[3]], tlt) end

-- seeds last ---------------------------------------------------------------------------------------------------------
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.05, wrap = 0.15 })
  local idx = X.tone(c, s.m, v, SEED, { cuts = { 0.15, 0.32, 0.5, 0.7, 0.9 }, tok = tok })
  -- violet bounce on the lower-right rim
  local r = X.rim(s.n)
  s.m:each(function(x, y) local k = K(x, y) if r[k] > 0.5 and idx[k] <= 2 then c:put(x, y, SEED[4], tok) end end)
  local bx, by = G.specAt(s.m, s.n, 30)
  c:put(bx, by, "#fff4d6", tok)
  -- hilum: pale dot at the narrow (right-down) end
  local hx = floor(s[1] + cos(s[5]) * (s[3] - 0.2) + 0.5)
  local hy = floor(s[2] + sin(s[5]) * (s[3] - 0.2) + 0.5)
  if s.m:has(hx, hy) then c:put(hx, hy, "#d8ccd6", tok) end
end

G.save2(c, NAME)

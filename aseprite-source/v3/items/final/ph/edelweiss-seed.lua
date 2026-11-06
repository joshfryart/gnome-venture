-- edelweiss-seed (Opus single pass). Two slim brown achenes, each with a cream pappus tuft of bristles, lying on a
-- torn scrap of edelweiss leaf: lance-shaped, grey-sage, felted (silvery woolly rim + fuzz hairs past the edge),
-- midrib, V-fold light, ragged torn base, AO + contact shadow under each seed. The third seed has sprouted: pale
-- stem, two round cotyledons and a pair of narrow woolly lance leaves with silver tips showing the alpine rosette.
-- quirk: a fourth seed drifts away above the scrap on its open pappus parachute.
local NAME = "edelweiss-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#253d3a", "#36564b", "#4e7260", "#6e917a", "#93b29a", "#c0d6bc" }
local WOOL, WOOL2 = "#e4ecdc", "#cbd8c6"
local SEED = { "#3a2220", "#5a3626", "#7e5230", "#a3713e", "#c99a5c", "#e8c68a" }
local PAP = { "#9a988c", "#c9c4b2", "#ece6d2", "#fbf6e4" }
local STEM = { "#4a7a58", "#7ea676", "#b6d0a0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- leaf scrap: lance blade on a shallow diagonal, base torn off (left)
local lm, ln, LT, LS, len = G.blade(7, 50, 30, 54, 56, 40, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 7.6 * sin(pi * min(1, 0.35 + t * 0.66)) ^ 0.75)
end, { fold = 0.4 })
-- torn edge: ragged notches at the base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k]
  local lim = 0.06 + 0.07 * X.hash(0, floor((LS[k] + 1) * 5), 3)
  if t < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- seeds: cx, cy, rx, ry, ang  (pappus at the -u end)
local seeds = { { 21, 48, 3.6, 1.6, -0.25 }, { 33, 47, 3.6, 1.6, 0.35 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
-- sprouting seed (upright-ish)
local sp = { 44, 44, 3.2, 1.5, -0.1 }
sp.m, sp.n = G.oval(sp[1], sp[2], sp[3], sp[4], sp[5], 0.8)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, sp.m, 1, -1) G.cast(bias, lm, sp.m, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.15, wrap = 0.3 })
-- midrib + faint side veins
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.08 and t < 0.94 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5) / 6
  if abs(ph - floor(ph + 0.5)) < 0.08 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- felted woolly rim, fuzz hairs outside the edge, torn base darker raw edge
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] < 0.15 then c:put(x, y, LEAF[2], ltok)
  elseif not bias[k] then c:put(x, y, LS[k] < 0 and WOOL or WOOL2, ltok) end
end)
lm:grow(1):cut(lm):each(function(x, y)
  if X.hash(x, y, 8) > 0.8 then
    local inside = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do local k = K(x + d[1], y + d[2])
      if lm:has(x + d[1], y + d[2]) and LT[k] > 0.15 then inside = true end end
    if inside then c:put(x, y, WOOL2, ltok) end
  end
end)

-- sprout (before its seed so the coat covers the stem foot)
local stok = { r = { name = "stem" } }
local spp = { { 44, 43 }, { 43, 37 }, { 45, 31 }, { 44, 26 } }
local sm, sn = G.tube(spp, function() return 1.0 end)
sm:cut(sp.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.4, 0.7 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by, wmax, wool)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, wmax * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end
    if wool and T[k] > 0.72 then c:put(x, y, S[k] < 0.3 and WOOL or WOOL2, ltok) end
  end)
  if wool then m:edge():each(function(x, y) local k = K(x, y) if S[k] < -0.5 and T[k] > 0.2 then c:put(x, y, WOOL, ltok) end end) end
  return m
end
-- cotyledons: short round
blade(43, 31, 39, 30, 36, 32, 1.8, false)
blade(45, 31, 49, 30, 52, 32, 1.8, false)
-- true leaves: narrow woolly lances
blade(44, 26, 40, 20, 35, 15, 1.9, true)
blade(44, 26, 48, 19, 53, 15, 1.9, true)
c:put(44, 25, STEM[3], stok) c:put(44, 24, WOOL, ltok)

-- seeds with pappus tufts
local function seed(s, tok, sb)
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), (-dx * sa + dy * ca) / (s[4] + .45)
    local i = v < -0.35 and 5 or (v < 0.3 and 4 or 2)
    if abs(u) > 0.7 then i = i - 1 end
    if v < -0.35 and u > -0.4 and u < 0.1 then i = 6 end
    if abs(v) < 0.15 and u > 0.1 and u < 0.7 then i = 3 end   -- rib groove
    if sb and sb[k] then i = i - 1 end
    c:put(x, y, SEED[max(1, min(6, i))], tok)
  end)
end
local function pappus(x0, y0, ux, uy, L, tok)
  -- fan of bristles spreading from the seed tip
  local px, py = -uy, ux
  for _, a in ipairs{ -0.9, -0.45, 0, 0.45, 0.9 } do
    for i = 1, L do
      local f = i / L
      local x = floor(x0 + ux * i + px * a * i * 0.8 + .5)
      local y = floor(y0 + uy * i + py * a * i * 0.8 + .5)
      c:put(x, y, (a <= 0 and f < 0.8) and PAP[4] or (f < 0.5 and PAP[3] or PAP[2]), tok)
    end
  end
  c:put(floor(x0 + .5), floor(y0 + .5), PAP[1], tok)
end
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  pappus(s[1] - ca * (s[3] + 1), s[2] - sa * (s[3] + 1), -ca, -sa, 4, tok)
  seed(s, tok)
end
do local tok = { r = { name = "seedS" } }
  seed(sp, tok)
  -- split coat at the top where the sprout came out
  c:put(44, 43, SEED[1], tok) c:put(43, 43, SEED[2], tok)
  pappus(sp[1] + 4.2, sp[2] + 0.5, 1, 0.2, 3, tok)
end

-- quirk: a seed drifting off on its parachute (upper-left)
local qtok = { r = { name = "drift" } }
local qx, qy = 18, 21
-- open pappus: star of bristles above the seed
for _, a in ipairs{ -2.6, -2.1, -1.57, -1.05, -0.55 } do
  for i = 1, 5 do
    local x, y = floor(qx + cos(a) * i + .5), floor(qy - 1 + sin(a) * i + .5)
    c:put(x, y, i >= 4 and PAP[3] or PAP[4], qtok)
  end
end
for _, a in ipairs{ -2.6, -1.57, -0.55 } do c:put(floor(qx + cos(a) * 6 + .5), floor(qy - 1 + sin(a) * 6 + .5), PAP[2], qtok) end
c:put(qx, qy, PAP[2], qtok) c:put(qx, qy + 1, PAP[1], qtok)
for _, q in ipairs{ { 0, 2, 5 }, { 0, 3, 4 }, { 1, 3, 3 }, { 0, 4, 3 }, { 1, 4, 2 }, { 0, 5, 2 } } do
  c:put(qx + q[1], qy + q[2], SEED[q[3]], qtok) end
G.save2(c, NAME)

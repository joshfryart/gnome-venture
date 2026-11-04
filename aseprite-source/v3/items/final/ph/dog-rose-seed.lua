-- dog-rose-seed (final pass, Opus). Three dog-rose achenes (angular, faceted, ochre-tan, with pale bristle hairs at the
-- tip) on a torn rose leaflet scrap lying from lower left (torn end) to upper right (serrated tip). Leaf: 6-tone,
-- V-fold light, midrib with paired veins, saw-tooth margin, cool reflected edge, AO + contact shadow under each seed.
-- One achene has germinated: a slim reddish rose stem with a tiny hooked thorn, two oval cotyledons and a first
-- true leaf of three serrated leaflets (the rose leaf shape).
-- quirk: one pale pink dog-rose petal (heart-notched) has drifted onto the leaf tip.
local NAME = "dog-rose-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_2.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = D.new(NAME)
local LEAF = { "#163a34", "#1f553e", "#2b7044", "#428f48", "#66ae52", "#98cc68" }
local SEED = { "#4a2a20", "#73422a", "#9c6232", "#c48a44", "#e0b462", "#f6dc96" }
local STEM = { "#5a2a2e", "#8a3a36", "#b65a46", "#d88a62" }
local PET = { "#b0507e", "#e07ea4", "#f8b0c8", "#ffd8e4" }
local CUTS = D.CUTS

-- leaf scrap: rose leaflet (ovate), torn at the lower-left base, serrated margin
local lm, ln, LT, LS, len = G.blade(10, 52, 30, 50, 54, 36, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.0 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.8)
end, { fold = 0.4 })
-- saw teeth along the margin (pointing toward the tip), torn ragged base
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = (t * len) / 3.2
  local f = ph - floor(ph)                       -- sawtooth 0..1
  if t > 0.12 and abs(s) > 0.93 - f * 0.22 then cut[#cut + 1] = k end
  if t < 0.1 and X.hash(x, y, 5) > 0.55 and t < 0.04 + X.hash(floor(s * 6), 0, 9) * 0.07 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: angular achenes (cx, cy, rx, ry, angle)
local seeds = { { 21, 47, 3.6, 2.4, -0.5 }, { 29, 46, 3.3, 2.2, 0.6 }, { 25, 52, 3.2, 2.2, -1.2 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end

-- sprout stem (from the second seed) + its contact shadow
local sp = { { 31, 45 }, { 33, 38 }, { 30, 31 }, { 32, 22 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.0 end)
G.cast(bias, lm, sm, 1, 1, -1)

local ltok = D.tok("leaf")
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.06 and t < 0.95 then c:put(x, y, s <= 0 and D.VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 5.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.16 and abs(s) < 0.75 and t > 0.12 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, D.COOL, ltok) end end)
-- torn base: pale fibres on the ragged end
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.06 and abs(LS[k]) < 0.7 then c:put(x, y, LEAF[5], ltok) end end)

-- quirk: a heart-notched petal on the leaf tip
local pm = HP.ellipse(48, 40, 3, 2.6)
pm:set(46, 37) pm:set(50, 37) pm.s[K(48, 37)] = nil pm.s[K(48, 38)] = nil
local pn = X.pillow(pm, 2)
G.cast({}, lm, pm, 1, 1, -1)
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local pidx = D.toneV(c, pm, pn, PET, { cuts = { 0.3, 0.55, 0.8 }, tok = D.tok("petal"), amb = 0.2 })
c:put(48, 42, PET[1], D.tok("petal"))      -- petal claw (base)
c:put(48, 41, PET[2], D.tok("petal"))
c:put(47, 39, PET[4], D.tok("petal"))

-- sprout: stem, thorn, cotyledons, trifoliate first leaf
local stok = D.tok("stem")
local smv = sm:copy()
for _, s in ipairs(seeds) do smv:cut(s.m) end
X.tone(c, smv, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- hooked thorn on the right side of the stem
c:put(33, 34, STEM[2], stok) c:put(34, 33, STEM[1], stok)
local function cotyledon(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = D.tok("cot"), cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], D.tok("cot")) end end)
  return m
end
local cl = cotyledon(31, 30, 26, 29, 21, 31, 2.1)
local cr = cotyledon(32, 30, 36, 30, 40, 33, 2.0)
-- trifoliate: three serrated oval leaflets on a short petiole, the top one largest
local function leaflet(ax, ay, bx, by, w, seed)
  local m, n, T, S, L = G.blade(ax, ay, (ax + bx) / 2, (ay + by) / 2, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.7)
  end, { fold = 0.35 })
  local cutl = {}
  m:each(function(x, y) local k = K(x, y)
    local f = (T[k] * L / 2.0) % 1
    if T[k] > 0.25 and abs(S[k]) > 0.8 and f < 0.5 then cutl[#cutl + 1] = k end end)
  for _, k in ipairs(cutl) do m.s[k] = nil end
  return m, n, T, S
end
local leaves = {}
leaves[1] = { leaflet(31, 21, 24, 15, 2.6) }
leaves[2] = { leaflet(33, 21, 40, 15, 2.6) }
leaves[3] = { leaflet(32, 20, 33, 10, 3.0) }
for i, l in ipairs(leaves) do
  local m, n, T, S = l[1], l[2], l[3], l[4]
  if i < 3 then m:cut(leaves[3][1]) end
  local tok = D.tok("tl" .. i)
  local bb = {}
  if i < 3 then X.ao(bb, m, leaves[3][1], 1, -1) end
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = CUTS, bias = bb, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.13 and T[k] > 0.08 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and D.VEIN or LEAF[3], tok) end end)
end

-- achenes last: faceted (a lit facet and a shade facet split along the long axis), bristly tip
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = D.tok("seed" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i2
    if v < -0.55 then i2 = 5 elseif v < 0 then i2 = 4 elseif v < 0.5 then i2 = 3 else i2 = 2 end
    if abs(u) > 0.8 then i2 = i2 - 1 end
    if v > -0.15 and v < 0.15 and abs(u) < 0.6 then i2 = 6 end  -- ridge (keel) catches the light
    if sb[k] then i2 = i2 - 1 end
    c:put(x, y, SEED[max(1, min(6, i2))], tok)
  end)
  -- bristle tuft at one end
  local tx, ty = s[1] + ca * (s[3] + 1.2), s[2] + sa * (s[3] + 1.2)
  local xi, yi = floor(tx + .5), floor(ty + .5)
  if not s.m:has(xi, yi) then c:put(xi, yi, SEED[6], tok) end
end
-- glint on the front achene
c:put(24, 51, D.CREAM)

D.save(c, NAME)

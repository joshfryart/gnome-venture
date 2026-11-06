-- carrot-seed (batch2, Opus single pass). Three carrot seeds (small flat ovals, tan-brown, two dark ribs along the
-- back, pale bristles on the rims) on a lobed carrot-leaf scrap (pinnatifid margin, midrib + a vein into each lobe,
-- V-fold light, cool reflected edge, AO + contact shadow under each seed). The right seed has germinated: pale stem,
-- two long grassy cotyledons and a first feathery true leaf (three lobed leaflets) that shows the carrot top.
-- quirk: the sprouting seed's root is already a tiny orange carrot, ringed and pointed.
local NAME = "carrot-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SEED = { "#3e2422", "#5e3a2a", "#84552f", "#a87240", "#cc9c5e", "#ecc98e" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local OR = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 49, 4.7, 2.5, 0 }, { 28, 45, 4.6, 2.5, -0.18 }, { 39, 41, 4.4, 2.4, -1.5708 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: a carrot pinna on the diagonal, scalloped into rounded lobes (clean silhouette that reads at 16 px)
local PER = 7.4
local lm, ln, LT, LS, len = G.blade(8, 54, 30, 52, 55, 39, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.5, 8.6 * sin(pi * u ^ 1.1) ^ 0.7)
end, { fold = 0.38 })
-- scallops: notch each side every PER px (offset between sides), notch depth grows toward the tip
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.25
  local f = abs((ph - floor(ph)) - 0.5) * 2      -- 0 at notch centre, 1 at lobe centre
  local lim = 0.97 - (1 - f) ^ 2.4 * (0.62 + 0.15 * t)
  if t > 0.08 and t < 0.94 and abs(s) > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.15 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- one vein into each lobe, swept toward the tip
  local ph = (t * len - abs(s) * 4.0) / PER + (s > 0 and 0.5 or 0) + 0.25
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.16 and abs(s) < 0.7 and t > 0.06 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.1 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end end)
-- petiole stub at the base
for _, q in ipairs{ {7, 55, 4}, {6, 56, 3}, {5, 57, 3} } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: baby-carrot radicle out of the sprouting seed, hanging over the lower leaf edge
local rp = { { 41, 45 }, { 44, 49 }, { 47, 52 }, { 50, 57 } }
local rm, rn, RT, RS = G.tube(rp, function(t) return 1.9 * (1 - t) ^ 0.85 + 0.25 end)
rm:cut(seeds[3].m)
X.ao(bias, lm, rm, 1, -1)
local rtok = { r = { name = "radicle" } }
local ridx = X.tone(c, rm, X.light(rn, { amb = 0.08, wrap = 0.25 }), OR, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.9 }, tok = rtok })
rm:each(function(x, y) local k = K(x, y)
  if (RT[k] > 0.4 and RT[k] < 0.45 or RT[k] > 0.62 and RT[k] < 0.66) and RS[k] > -0.5 then c:put(x, y, OR[max(1, (ridx[k] or 3) - 2)], rtok) end end)
-- re-shade leaf under the radicle (contact shadow)
G.cast({}, lm, rm, 1, 1, -1)
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout: stem, cotyledons, first true leaf (drawn before seeds so the seed coat sits over the stem foot)
local stok = { r = { name = "stem" } }
local sp = { { 39, 40 }, { 38, 34 }, { 39, 29 }, { 39, 24 } }
local sm, sn = G.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function cotyledon(ax, ay, cx, cy, bx, by)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 1.7 * sin(pi * min(1, t * 0.9 + 0.12)) ^ 0.5)
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cotyledon(38, 24, 31, 21, 22, 16)
local cr = cotyledon(40, 24, 47, 22, 55, 18)
-- true leaf: petiole + three lobed leaflets (carrot frond in miniature)
local function leaflet(x, y, ux, uy, L)
  local m = HP.mask()
  local nl = max(1, floor(L / 2.2 + 0.5))
  for i = 1, nl do local f = i / nl local r = 1.7 - f * 0.4
    m:add(G.rell(x + ux * (L * f - 0.6), y + uy * (L * f - 0.6), ux, uy, r + 0.35, r - 0.2)) end
  return m
end
local pet = { { 39, 24 }, { 39, 20 }, { 40, 16 }, { 40, 13 } }
local tl = HP.mask()
for _, q in ipairs{ { 0.45, -1, 3.2 }, { 0.5, 1, 3.4 }, { 0.78, -1, 2.6 }, { 0.82, 1, 2.6 } } do
  local x, y = G.bez(pet, q[1]) local ux, uy = G.rot(0, -1, q[2] * 1.0)
  tl:add(leaflet(x, y, ux, uy, q[3]))
end
do local x, y = G.bez(pet, 1) tl:add(G.rell(x, y - 1.2, 0, -1, 2.6, 1.4)) end
tl:cut(cl):cut(cr)
G.toneN(c, tl, X.pillow(tl, 1.6), LEAF, { tok = ltok, cuts = CUTS, amb = 0.12, wrap = 0.25 })
for i = 0, 30 do local x, y = G.bez(pet, i / 30) c:put(floor(x + .5), floor(y + .5), i < 4 and STEM[2] or STEM[3], stok) end

-- seeds last: ribbed backs, bristly rims, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  -- across axis sign: v<0 must be the lit (upper-left) side
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local i
    -- ridged back: lit rim, pale ridge, dark groove, ridge, shade rim (rows along the seed)
    if v < -0.62 then i = 4 elseif v < -0.2 then i = 5 elseif v < 0.2 then i = 2 elseif v < 0.62 then i = 4 else i = 2 end
    if v >= -0.2 and v < 0.2 and abs(u) > 0.75 then i = 3 end
    if v >= 0.2 and v < 0.62 then i = 3 + ((u < -0.1) and 1 or 0) end
    if abs(u) > 0.86 then i = i - 1 end
    if v < -0.2 and v > -0.62 and u > -0.6 and u < -0.1 then i = 6 end  -- lit ridge
    if sb[k] then i = i - 1 end
    c:put(x, y, SEED[max(1, min(6, i))], tok)
  end)
  -- bristles: pale 1 px spines on the rim, on the long sides
  for _, b in ipairs{ { -0.45, 1 }, { 0.15, 1 }, { 0.6, -1 }, { -0.2, -1 } } do
    local u, side = b[1], b[2]
    local px = s[1] + (u * s[3]) * ca - (side * (s[4] + 1.1)) * sa
    local py = s[2] + (u * s[3]) * sa + (side * (s[4] + 1.1)) * ca
    local xi, yi = floor(px + .5), floor(py + .5)
    if not s.m:has(xi, yi) then c:put(xi, yi, side < 0 and SEED[5] or SEED[3], tok) end
  end
end
-- one glint on the front seed

G.save2(c, NAME)

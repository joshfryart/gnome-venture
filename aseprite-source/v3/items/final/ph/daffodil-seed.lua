-- daffodil-seed (final, Opus single pass). Three glossy jet-black daffodil seeds lying along a torn scrap of
-- daffodil leaf: a flat glaucous blue-green strap with a blunt rounded tip, parallel veins, a faint keel, a powdery
-- waxy bloom on the lit side and a pale fibrous torn end. The front seed has germinated: a single grassy
-- strap-leaf (the daffodil's own leaf shape) arching up-left, plus a hair-thin scape.
-- quirk: the scape already carries a tiny open daffodil, six cream tepals and an orange trumpet, far too early.
local NAME = "daffodil-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163538", "#1f5048", "#2b6c55", "#438a62", "#6aa872", "#9fca8e" }
local BLOOM, TORN, COOL = "#c4dcc8", "#d6e8a8", "#3d6f80"
local SEED = { "#140e1a", "#22172a", "#33233a", "#4a3650", "#6e5878", "#a896b4" }
local STEM = { "#3f7a52", "#6ea66a", "#a2cc8a", "#d6ecb4" }
local YEL = { "#9a6420", "#cf9426", "#ecbc3c", "#f9db62", "#ffee9a", "#fff8d0" }
local ORG = { "#6e2a22", "#a8441f", "#d8661f", "#f08a2a", "#fbad48", "#ffd27a" }

-- leaf scrap: flat strap, blunt round tip at the upper right, torn at the lower left
local W = 4.7
local lm, ln, LT, LS, len = A.blade(7, 55, 30, 48, 57, 33, function(t)
  if t > 0.995 then return -1 end
  if t > 0.88 then local u = (t - 0.88) / 0.12 return W * sqrt(max(0, 1 - u * u)) end
  return W
end, { fold = 0.22 })
local torn = A.tear(lm, LT, LS, len, true, 3.2, 4)

local seeds = { { 19, 48.6, 3.1, 2.6, -0.5 }, { 29.5, 44.2, 3.2, 2.7, 0.3 }, { 40.5, 39.6, 3.3, 2.8, -0.2 } }
for _, s in ipairs(seeds) do s.m = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- parallel veins + keel, waxy bloom, cool reflected edge, torn fibres
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  local i = lidx[k]
  if abs(s) < 0.07 and t < 0.86 then c:put(x, y, LEAF[max(1, i - 1)], ltok) return end
  if (abs(s - 0.47) < 0.08 or abs(s + 0.47) < 0.08) and t < 0.84 and t > 0.08 then
    c:put(x, y, s < 0 and LEAF[min(6, i + 1)] or LEAF[max(1, i - 1)], ltok) return end
  if s < -0.1 and i >= 4 and X.hash(x, y, 3) > 0.84 then c:put(x, y, BLOOM, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if lm:has(x, y) then local k = K(x, y)
  c:put(x, y, (LS[k] < 0.3) and TORN or LEAF[4], ltok) end end)
-- lit tip highlight
for _, q in ipairs{ { 53, 33 }, { 54, 33 } } do if lm:has(q[1], q[2]) then c:put(q[1], q[2], LEAF[6], ltok) end end

-- sprout: grassy strap leaf (daffodil leaf in miniature) arching up-left
local stok = { r = { name = "sprout" } }
local bm, bn, BT, BS = A.blade(40, 37, 37, 19, 26, 10, function(t)
  if t > 0.99 then return -1 end
  if t > 0.86 then local u = (t - 0.86) / 0.14 return 1.6 * sqrt(max(0, 1 - u * u)) end
  return 1.25 + 0.35 * t
end, { fold = 0.25 })
local bidx = A.toneN(c, bm, bn, LEAF, { tok = stok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y)
  if abs(BS[k]) < 0.18 and BT[k] > 0.1 and BT[k] < 0.82 then c:put(x, y, BS[k] <= 0 and LEAF[6] or LEAF[3], stok) end
  if BS[k] < -0.3 and BT[k] > 0.3 and X.hash(x, y, 5) > 0.8 then c:put(x, y, BLOOM, stok) end
end)
-- scape: hair-thin stem up-right to the flower
local scape = { { 42, 37 }, { 44, 28 }, { 48, 22 }, { 50, 17 } }
local sm, sn = A.tube(scape, function(t) return 0.75 end)
sm:cut(bm)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- papery spathe where the flower joins
for _, q in ipairs{ { 49, 18, "#c9b98a" }, { 48, 17, "#e2d6a6" } } do c:put(q[1], q[2], q[3], stok) end

-- quirk: tiny open daffodil, face-on, six tepals + orange trumpet
local fx, fy = 51.5, 11.5
local fm = HP.mask()
for i = 0, 5 do local a = -pi / 2 + i * pi / 3 + 0.2
  local ux, uy = math.cos(a), sin(a)
  fm:add(A.rell(fx + ux * 2.9, fy + uy * 2.9, ux, uy, 2.4, 1.35)) end
fm:add(A.rell(fx, fy, 1, 0, 2.2, 2.2))
local ftok = { r = { name = "flower" } }
local fn = {}
fm:each(function(x, y) local dx, dy = x - fx, y - fy local r = sqrt(dx * dx + dy * dy)
  -- tepals cup gently upward toward the trumpet
  local z = 1 local nx, ny = dx / (r + 0.01) * min(r / 5, 0.6), dy / (r + 0.01) * min(r / 5, 0.6)
  fn[K(x, y)] = { A.norm(nx, ny, z) } end)
local fidx = A.toneN(c, fm, fn, YEL, { tok = ftok, cuts = { 0.12, 0.3, 0.5, 0.7, 0.86 }, amb = 0.3, wrap = 0.4 })
-- separation lines between tepals (darker neighbour tone)
fm:each(function(x, y) local dx, dy = x - fx, y - fy local r = sqrt(dx * dx + dy * dy)
  local a = math.atan(dy, dx) - (-pi / 2 + 0.2) + pi / 6
  local f = (a / (pi / 3)) % 1
  if r > 2.6 and (f < 0.12 or f > 0.88) then c:put(x, y, YEL[max(1, fidx[K(x, y)] - 2)], ftok) end
end)
local tm, tn = A.oval(fx, fy, 1.9, 1.9, 0, 0.7)
local tidx = A.toneN(c, tm, tn, ORG, { tok = ftok, cuts = { 0.2, 0.4, 0.58, 0.74, 0.88 }, amb = 0.12, wrap = 0.3 })
c:put(floor(fx + 0.5), floor(fy + 0.5), ORG[1], ftok)           -- throat
c:put(floor(fx - 1.5 + 0.5), floor(fy - 1.5 + 0.5), ORG[6], ftok) -- frilled rim catch-light

-- seeds last: jet, glossy, faintly angular; AO where neighbours touch; one cream glint each, cool reflected rim
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local m, n = A.seed(c, s[1], s[2], s[3], s[4], s[5], SEED, { tok = tok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, flat = 0.75 })
  A.reflect(c, m, n, "#4c4a6e", tok, 0.5)
  -- faint facet line across the seed (angular coat)
  local fx2, fy2 = floor(s[1] + 0.5), floor(s[2] + 0.5)
  if m:has(fx2 + 1, fy2) then c:put(fx2 + 1, fy2, SEED[2], tok) end
  if m:has(fx2 + 1, fy2 + 1) then c:put(fx2 + 1, fy2 + 1, SEED[2], tok) end
  local gx, gy = A.glint(c, m, n, "#fff4d6", tok, false)
  if gx and m:has(gx + 1, gy) then c:put(gx + 1, gy, SEED[6], tok) end
end
-- radicle: one white root nub out of the sprouting seed, dipping over the leaf
for _, q in ipairs{ { 43, 42, "#f1ead2" }, { 44, 43, "#d9cfb0" }, { 44, 44, "#f1ead2" } } do c:put(q[1], q[2], q[3], stok) end
A.save2(c, NAME)

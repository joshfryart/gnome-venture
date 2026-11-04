-- grapefruit-seed (aC10_0, Opus single pass). Three pale cream grapefruit pips (teardrops: round heel, pointed
-- beak, a raphe ridge and two wrinkle grooves) on a torn scrap of glossy citrus leaf (ragged torn base, ovate pointed
-- tip, pale midrib with fine swept veins, gloss specular, cool reflected edge, AO + contact shadow under each pip).
-- The right pip has germinated: white root curling onto the leaf, a pale stem and two glossy elliptic citrus leaves
-- on a winged petiole (the grapefruit's tell), plus a folded bud between them.
-- quirk: a single pink juice vesicle is still stuck to the front pip.
local NAME = "grapefruit-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#122f2c", "#1b4637", "#276340", "#3a8447", "#5ea653", "#93c968" }
local VEIN, COOL, GLOSS = "#b5dc86", "#356a6e", "#e2f4b4"
local SEED = { "#6e5c40", "#97835c", "#bfab7d", "#dccd9f", "#f1e6c0", "#fff8e2" }
local STEM = { "#4a7f4c", "#7fb46a", "#b5d996", "#e4f3c4" }
local ROOT = { "#a99a86", "#d8cdb8", "#f6efdf" }
local PULP = { "#9c2f4e", "#e0607e", "#ffaabb", "#ffe0e6" }

-- teardrop pip: centre, half length, half width, angle (beak points along +u)
local function pip(cx, cy, a, b, ang)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local U, V = {}, {}
  local R = a + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (a + 0.4)
    local v = (-dx * sa + dy * ca)
    if u >= -1 and u <= 1 then
      local hw = (b + 0.4) * sqrt(max(0, 1 - u * u)) * (1 - 0.42 * u) / 1.0
      if u > 0.55 then hw = hw * (1 - (u - 0.55) * 0.6) end
      if abs(v) <= hw then m:set(x, y) U[K(x, y)] = u V[K(x, y)] = hw > 0 and v / hw or 0 end
    end
  end end
  return { m = m, U = U, V = V, cx = cx, cy = cy, ang = ang }
end
local seeds = { pip(16, 48, 4.3, 2.6, -0.35), pip(27, 45, 4.4, 2.7, 0.25), pip(38, 41, 4.2, 2.6, -1.25) }

-- leaf scrap: ovate citrus blade on the diagonal, base torn off
local lm, ln, LT, LS, len = G.blade(8, 53, 30, 52, 56, 34, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.4 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.75)
end, { fold = 0.32 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local along = LT[k] * len
  local lim = 2.2 + 2.6 * abs(sin(LS[k] * 7.3 + 0.6)) + 1.2 * X.hash(floor(LS[k] * 9), 1, 3)
  if along < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- a small torn bite out of the lower edge
lm:cut(c:ellipse(30, 59, 3, 2.5))

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 5.2
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.16 and abs(s) < 0.78 and t < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.15 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- glossy leaf: two specular glints on the lit half
do
  local sp = X.spec(ln, 24)
  local n = 0
  for _, q in ipairs{ { 0.45, 0.6 }, { 0.68, 0.82 } } do
    local best, bx, by
    lm:each(function(x, y) local k = K(x, y)
      if not bias[k] and LT[k] > q[1] and LT[k] < q[2] and LS[k] < -0.3 and LS[k] > -0.7 and (not best or sp[k] > best) then best, bx, by = sp[k], x, y end end)
    if bx then c:put(bx, by, GLOSS, ltok) c:put(bx + 1, by, GLOSS, ltok) end
  end
end

-- root of the sprouting pip, curling down onto the leaf
local s3 = seeds[3]
local rtok = { r = { name = "root" } }
local rp = { { 40, 45 }, { 42, 49 }, { 45, 50 }, { 47, 48 } }
local rm, rn = G.tube(rp, function(t) return 1.0 * (1 - t) + 0.35 end, 60)
rm:cut(s3.m)
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.7 }, tok = rtok })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not s3.m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout stem
local stok = { r = { name = "stem" } }
local sp = { { 37, 38 }, { 36, 31 }, { 38, 26 }, { 37, 20 } }
local stm, stn = G.tube(sp, function(t) return 1.0 end, 80)
stm:cut(s3.m)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.85 }, tok = stok })
-- winged petiole + elliptic glossy leaflet
local function citrusLeaf(ax, ay, cx_, cy_, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx_, cy_, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.24 then return 0.5 + 1.1 * sin(pi * t / 0.24) end            -- the wing on the petiole
    return max(0.45, 3.5 * sin(pi * min(1, (t - 0.24) / 0.76 * 0.92 + 0.08)) ^ 0.7)
  end, { fold = 0.35 })
  m:cut(stm)
  local idx = G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if T[k] > 0.2 and T[k] < 0.27 then c:put(x, y, LEAF[max(1, idx[k] - 2)], ltok) end   -- joint between wing and blade
    if abs(S[k]) < 0.16 and T[k] > 0.3 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) end
  end)
  local bx_, by_ = G.specAt(m, n, 30)
  c:put(bx_, by_, GLOSS, ltok)
  return m
end
local L1 = citrusLeaf(37, 22, 30, 17, 21, 15)
local L2 = citrusLeaf(38, 21, 45, 15, 54, 14)
-- folded bud at the stem top
local btok = { r = { name = "bud" } }
for _, q in ipairs{ { 37, 19, 5 }, { 38, 19, 3 }, { 37, 18, 4 }, { 38, 18, 3 }, { 37, 17, 5 }, { 37, 16, 4 } } do c:put(q[1], q[2], STEM[q[3] - 2] or LEAF[q[3]], btok) end
c:put(37, 16, LEAF[5], btok) c:put(37, 17, STEM[3], btok) c:put(38, 18, LEAF[4], btok) c:put(38, 19, LEAF[3], btok)

-- pips last: raphe ridge, wrinkle grooves, darker beak, AO where they overlap
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local n = X.pillow(s.m, 2.2)
  local v = X.light(n, { amb = 0.12, wrap = 0.3 })
  local tok = { r = { name = "pip" .. i } }
  vis:each(function(x, y) local k = K(x, y)
    local idx = 1
    for j, t in ipairs{ 0.25, 0.42, 0.58, 0.74, 0.88 } do if v[k] >= t then idx = j + 1 end end
    local u, vv = s.U[k], s.V[k]
    if abs(vv + 0.15) < 0.17 and u > -0.75 and u < 0.7 then idx = idx + 1 end            -- raphe ridge
    if (abs(vv - 0.45) < 0.12 or abs(vv + 0.7) < 0.1) and u > -0.6 and u < 0.5 then idx = idx - 1 end  -- wrinkles
    if u > 0.72 then idx = idx - 1 end                                                    -- beak
    if sb[k] then idx = idx - 1 end
    c:put(x, y, SEED[max(1, min(6, idx))], tok)
  end)
end
-- seed coat glint on the middle pip
do local s = seeds[2] local bx, by = G.specAt(s.m, X.pillow(s.m, 2.2), 40) c:put(bx, by, SEED[6], { r = { name = "pip2" } }) end

-- quirk: pink juice vesicle stuck to the front pip (spindle shape)
local qtok = { r = { name = "pulp" } }
local vm = { { 13, 45, 3 }, { 14, 45, 4 }, { 14, 44, 3 }, { 15, 44, 2 }, { 13, 46, 2 }, { 12, 46, 2 }, { 15, 45, 2 } }
for _, q in ipairs(vm) do c:put(q[1], q[2], PULP[q[3]], qtok) end
c:put(13, 44, PULP[3], qtok) c:put(12, 45, PULP[3], qtok)

G.save2(c, NAME)

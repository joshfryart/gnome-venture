-- poinsettia-seed (D10 final, Sonnet high). Four small mottled grey-brown poinsettia seeds (each with a pale caruncle knob)
-- on a torn, pointed-lobed poinsettia leaf scrap (midrib, swept veins, V-fold light, cool reflected edge, AO + contact
-- shadow under each seed). A seedling stands from the scrap: pale-green stem with a red node, two round cotyledons, a big
-- lobed true leaf and a small second leaf that show the real poinsettia leaf shape (ovate, pointed, notched lobes).
-- quirk: the seedling is already crowned with a tiny three-petal red bract rosette and a yellow cyathium dot.
local NAME = "poinsettia-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aD10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#12362f", "#1c5139", "#29703f", "#3f9048", "#62b052", "#94cc68" }
local VEIN, COOL = "#c6e68e", "#3a6c72"
local SEED = { "#2a1b1f", "#43312c", "#654a3a", "#8b6b4e", "#b08d68", "#d6b88e" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local RED = { "#5a1020", "#8c1a2c", "#c02a34", "#e04a3c", "#f47a4a", "#ffb070" }
local ltok = { r = { name = "leaf" } }
local stok = { r = { name = "stem" } }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 14, 50, 3.6, 2.8, 0.15 }, { 22, 46.5, 3.5, 2.7, -0.3 }, { 22.5, 54, 3.5, 2.7, 0.2 }, { 30.5, 51, 3.4, 2.7, -0.15 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- lobed leaf with notches (list of {t0, side, width, depth}), veins; returns mask, T, S, len
local function lobed(ax, ay, cx, cy, bx, by, wmax, notches, per, o)
  o = o or {}
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.95 + 0.05)
    return max(0.5, wmax * sin(pi * u ^ 1.1) ^ 0.7)
  end, { fold = o.fold or 0.38 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    for _, nt in ipairs(notches) do
      if (s > 0 and 1 or -1) == nt[2] then
        local f = max(0, 1 - abs(t - nt[1]) / nt[3])
        if f > 0 and abs(s) > 1 - nt[4] * f then cut[#cut + 1] = k end
      end
    end
    if o.torn and t < 0.04 + 0.1 * X.hash(x, y, 5) then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S, len
end
local function paintLeaf(m, n, T, S, len, per, bias, o)
  o = o or {}
  X.tone(c, m, X.light(n, { amb = 0.18, wrap = 0.3 }), LEAF, { cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, bias = bias, tok = ltok })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias and bias[k] then return end
    if abs(s) < (o.rib or 0.15) and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
    local ph = (t * len - abs(s) * 3.4) / per
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.86 and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.06 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end)
end

-- scrap
local lm, ln, LT, LS, len = lobed(7, 49, 30, 53, 55, 41, 8.2,
  { { 0.38, -1, 0.07, 0.62 }, { 0.54, 1, 0.07, 0.62 }, { 0.72, -1, 0.06, 0.6 } }, 5.5, { torn = true })
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local foot = c:ellipse(38, 48, 2, 1)
X.ao(bias, lm, foot, 1, -1)
paintLeaf(lm, ln, LT, LS, len, 5.5, bias)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- sprout: stem
local sm, sn, ST, SS = A.tube({ { 38, 49 }, { 38, 42 }, { 39, 33 }, { 38, 24 } }, function(t) return 1.3 - 0.3 * t end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- reddish node where the cotyledons leave
for _, p in ipairs{ { 37, 39 }, { 38, 39 }, { 39, 39 }, { 38, 40 } } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], p[1] == 37 and RED[4] or RED[3], stok) end end
-- cotyledons: two round, plump
local function cotyl(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.5 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.55)
  end, { fold = 0.3 })
  m:cut(sm)
  X.tone(c, m, X.light(n, { amb = 0.14, wrap = 0.3 }), LEAF, { cuts = A.CUTS6, tok = ltok })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = cotyl(37, 41, 31, 42, 28, 37)
local cr = cotyl(39, 41, 45, 42, 49, 37)
-- true leaves
local bm, bn, BT, BS, blen = lobed(38, 30, 28, 29, 22, 17, 4.6, { { 0.45, -1, 0.1, 0.55 }, { 0.62, 1, 0.1, 0.55 } }, 4.2, { fold = 0.32 })
bm:cut(sm)
paintLeaf(bm, bn, BT, BS, blen, 4.2, nil, { rib = 0.2 })
local rm, rn, RT, RS, rlen = lobed(39, 29, 46, 28, 52, 20, 3.2, { { 0.5, 1, 0.12, 0.5 } }, 4, { fold = 0.3 })
rm:cut(sm):cut(bm)
paintLeaf(rm, rn, RT, RS, rlen, 4, nil, { rib = 0.22 })
-- contact shadow where leaves cross the stem
for _, p in ipairs{ { 37, 30 }, { 37, 31 }, { 40, 30 } } do if sm:has(p[1], p[2]) then c:put(p[1], p[2], STEM[1], stok) end end
-- bract rosette (quirk): three tapered red petals over a yellow cyathium dot
local function petal(x1, y1, x2, y2, x3, y3, x4, y4)
  local m, n, T = A.tube({ { x1, y1 }, { x2, y2 }, { x3, y3 }, { x4, y4 } }, function(t) return 1.6 * (1 - t) ^ 0.6 + 0.35 end)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), RED, { cuts = A.CUTS6, tok = { r = { name = "bract" } } })
  return m
end
petal(38, 25, 33, 23, 31, 20, 30, 17)
petal(38, 25, 43, 23, 45, 20, 46, 17)
petal(38, 25, 38, 21, 38, 18, 38, 14)
c:fillMask(c:rect(37, 25, 39, 25), "#f7d84a")
c:put(37, 24, "#c9a21e", stok) c:put(39, 24, "#fff2a0", stok)

-- seeds last: mottled coat, raphe line, pale caruncle
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v = X.light(s.n, { amb = 0.08, wrap = 0.28 })
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local id = floor(v[k] * 6) + 1
    id = max(1, min(6, id))
    local h = X.hash(x, y, 11)
    if h < 0.2 then id = id - 2 elseif h > 0.9 then id = id + 1 end
    if abs(w) < 0.3 and abs(u) < 0.75 then id = id - 1 end    -- raphe groove
    if u > -0.2 and u < 0.1 and w < -0.35 and w > -0.8 then id = 6 end   -- lit streak
    if sb[k] then id = id - 1 end
    c:put(x, y, SEED[max(1, min(6, id))], tok)
  end)
  -- caruncle on the left end
  local kx, ky = s[1] - ca * (s[3] + 0.9), s[2] - sa * (s[3] + 0.9)
  local xi, yi = floor(kx + .5), floor(ky + .5)
  if not s.m:has(xi, yi) then
    c:put(xi, yi, "#f2e2bc", tok) c:put(xi, yi + 1, "#b9a07a", tok)
    if not s.m:has(xi - 1, yi) then c:put(xi - 1, yi, "#d8c598", tok) end
  end
end
c:put(12, 49, SEED[6], { r = { name = "seed1" } })
c:sparkle(47, 50)

A.save(c, NAME)

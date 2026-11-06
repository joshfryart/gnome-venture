-- frangipani-seed (aB32_5, Opus single pass). Two winged frangipani seeds (dark ribbed body + long papery wing with
-- fine lengthwise veins and a translucent pale rim) lying on a torn, glossy frangipani leaf scrap (midrib, ladder of
-- straight lateral veins meeting a pale marginal vein, ragged torn base with pale fibres, contact shadows).
-- The right seed has sprouted: a thick succulent stem and two long oblanceolate frangipani leaves with ladder veins,
-- plus a folded new leaf pair at the top.
-- quirk: a tiny cream-and-yolk frangipani blossom has dropped onto the leaf tip.
local NAME = "frangipani-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, pi = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.pi
local c = A.new(NAME)
local LEAF = { "#15392f", "#1f553c", "#2c7042", "#428e48", "#64ae52", "#9bcf68" }
local VEIN, COOL = "#c4e08c", "#3a6a70"
local SEED = { "#3a2220", "#5a3626", "#80502e", "#a8723e", "#cc9a5c", "#ecc68c" }
local WING = { "#7a5634", "#a77e4e", "#c9a46a", "#e2c890", "#f2e2b4", "#fff4d6" }
local STEM = { "#3f6a3e", "#6a9a4e", "#9cc06a", "#cce39a" }
local PET = { "#b98a86", "#e6c2b0", "#f8e6cc", "#fff4d6" }
local YOLK = { "#d98322", "#f5b82e", "#ffe38a" }

-- seeds: body (cx, cy, rx, ry, ang), wing end point
local seeds = {
  { body = { 14, 48, 2.9, 1.9, -0.25 }, wing = { 27, 44.5 } },
  { body = { 37, 46, 2.9, 1.9, 0.3 }, wing = { 49, 41 } },
}
for _, s in ipairs(seeds) do
  local b = s.body
  s.m, s.n = A.oval(b[1], b[2], b[3], b[4], b[5], 0.7)
  local ax, ay = b[1] + 2 * cos(b[5]), b[2] + 2 * sin(b[5])
  local mx, my = (ax + s.wing[1]) / 2, (ay + s.wing[2]) / 2 - 1
  s.wm, s.wn, s.WT, s.WS = A.blade(ax, ay, mx, my, s.wing[1], s.wing[2], function(t)
    if t > 0.98 then return -1 end
    return max(0.5, 2.5 * sin(pi * min(1, 0.25 + t * 0.78)) ^ 0.6)
  end, { fold = 0.15 })
  s.wm:cut(s.m)
end

-- sprout masks (needed for leaf-scrap contact shadow)
local stemP = { { 36, 45 }, { 35, 38 }, { 31, 30 }, { 32, 21 } }
local sm, sn = A.tube(stemP, function(t) return 1.5 - t * 0.35 end)

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(6, 50, 30, 57, 55, 46, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 7.2 * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.65)
end, { fold = 0.32 })
-- torn base: ragged edge
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.1 + 0.05 * (floor((LS[k] + 1) * 4) % 2) + 0.025 * X.hash(x, y, 2)
  if LT[k] < lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do
  X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) A.cast(bias, lm, s.wm, 1, 1, -1)
end
A.cast(bias, lm, sm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t > 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  if abs(s) > 0.74 and abs(s) < 0.86 and t > 0.16 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 1.6) / 3.4
  local f = ph - floor(ph)
  if f < 0.22 and abs(s) > 0.14 and abs(s) < 0.75 and t > 0.15 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
-- cool reflected light on the shade edge; pale torn fibres on the ragged base
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.2 and not lm:has(x - 1, y) then c:put(x, y, (y % 2 == 0) and VEIN or LEAF[5], ltok) end
end)

-- sprout: stem, two oblanceolate leaves with ladder veins, folded new pair
local stok = { r = { name = "stem" } }
sm:cut(seeds[2].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function sleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.45, w * sin(pi * min(1, 0.06 + t * 0.9)) ^ 0.45 * (0.55 + 0.45 * t ^ 0.5))
  end, { fold = 0.4 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.06 and t < 0.88 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok)
    else
      local ph = (t * L - abs(s) * 1.2) / 3.0
      local f = ph - floor(ph)
      if f < 0.25 and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.12 and t < 0.86 then c:put(x, y, LEAF[max(1, min(6, (idx[k] or 3) + (s < 0 and 1 or -1)))], ltok) end
    end
  end)
  return m
end
local L1 = sleaf(31, 25, 22, 24, 12, 15, 3.4)
local L2 = sleaf(32, 23, 40, 17, 49, 13, 3.2)
-- folded new leaf pair at the top
local bud = A.blade(32, 22, 31, 17, 33, 12, function(t) if t > 0.97 then return -1 end return max(0.4, 1.6 * sin(pi * min(1, 0.1 + t))) end, { fold = 0.3 })
bud:cut(L1):cut(L2)
bud:each(function(x, y) c:put(x, y, (x < 32) and LEAF[6] or LEAF[4], ltok) end)
c:put(32, 16, LEAF[2], ltok)

-- seeds + wings
for i, s in ipairs(seeds) do
  local wtok = { r = { name = "wing" .. i } }
  local widx = A.toneN(c, s.wm, s.wn, WING, { tok = wtok, cuts = { 0.18, 0.34, 0.52, 0.68, 0.84 }, amb = 0.2, wrap = 0.35 })
  s.wm:each(function(x, y) local k = K(x, y)
    local sv, t = s.WS[k], s.WT[k]
    if (abs(sv - 0.3) < 0.12 or abs(sv + 0.35) < 0.1) and t > 0.08 and t < 0.86 then c:put(x, y, WING[max(1, (widx[k] or 3) - 1)], wtok) end
  end)
  s.wm:edge():each(function(x, y) local k = K(x, y) if s.WS[k] < -0.4 then c:put(x, y, WING[6], wtok) end end)
  -- ambient where the wing meets the seed body
  X.ao({}, s.wm, s.m, 1, -1)
  s.m:grow(1):clip(s.wm):cut(s.m):each(function(x, y) c:put(x, y, WING[2], wtok) end)
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.1, wrap = 0.3 })
  -- lengthwise rib
  local b = s.body
  for d = -2, 1 do
    local x, y = floor(b[1] + d * cos(b[5]) + 0.5), floor(b[2] + d * sin(b[5]) + 0.5)
    if s.m:has(x, y) then c:put(x, y, SEED[max(1, (idx[K(x, y)] or 3) - 2)], tok) end
  end
  local gx, gy = floor(b[1] - 1.5 + 0.5), floor(b[2] - 1 + 0.5)
  if s.m:has(gx, gy) then c:put(gx, gy, SEED[6], tok) end
end
-- stem foot over the sprouting seed's split coat
c:put(36, 44, STEM[3], stok) c:put(37, 44, STEM[2], stok)

-- quirk: frangipani blossom on the leaf tip (pinwheel of five petals, yolk centre)
local bx, by = 51, 49
local btok = { r = { name = "bloom" } }
local petals = HP.mask()
for i = 0, 4 do
  local a = i * 2 * pi / 5 - 0.4
  local ux, uy = cos(a), sin(a)
  local p = A.rell(bx + ux * 2.0 - uy * 0.7, by + uy * 2.0 + ux * 0.7, ux, uy, 2.4, 1.35)
  petals:add(p)
end
petals:each(function(x, y)
  local dx, dy = x - bx, y - by
  local r = (dx * dx + dy * dy) ^ 0.5
  local i = 3
  if dx + dy > 2.5 then i = 2 end
  if dx + dy < -2 then i = 4 end
  if r > 3.6 and dx + dy > 0 then i = 1 end
  c:put(x, y, PET[i], btok)
end)
c:put(bx, by, YOLK[2], btok) c:put(bx - 1, by, YOLK[3], btok) c:put(bx, by - 1, YOLK[3], btok) c:put(bx + 1, by, YOLK[1], btok) c:put(bx, by + 1, YOLK[1], btok)

A.save(c, NAME)

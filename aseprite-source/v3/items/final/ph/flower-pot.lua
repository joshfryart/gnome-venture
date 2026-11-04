-- flower-pot (final, Opus single pass). A slim tapered terracotta pot: rolled rim band with a lit top ellipse, inner
-- back wall and crumbly dark soil, a cylinder-lit body (6 tones, cool deep on the right), AO row under the rim
-- overhang, clay speckle, a pale salt bloom creeping up from the foot, and a 2-tone ground shadow. A young seedling
-- (thin stem, two veined heart leaves) grows from the soil.
-- quirk: a pink earthworm loops out of the soil and over the rim.
local NAME = "flower-pot"
local B = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_1.lua")
local HP, X, K = B.HP, B.X, B.K
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin
local c = B.new(NAME)
local TC = { "#5a2030", "#8c372e", "#b6512f", "#d8713a", "#ee9757", "#fbc488" }
local SALT = { "#76484a", "#a2685c", "#c28c78", "#dbad96", "#ecc8b1", "#f8e2cd" }
local SOIL = { "#24161a", "#3a2422", "#563626", "#764e32" }
local LEAF = { "#1d4a3c", "#2a6646", "#3d8a4c", "#5aa852", "#86c766", "#bfe38e" }
local STEM = { "#3d7a4a", "#64a45a", "#9ccc78", "#d2eca6" }
local WORM = { "#6e2a4a", "#a8456a", "#d06a84", "#ec96a6", "#ffc4cc" }
local CX = 32

c:groundShadow(32, 56, 12, 1)
-- body: tapered cylinder
local body = HP.mask()
local hw = {}
for y = 29, 55 do local w = floor(11.5 - (y - 29) * (3.6 / 26) + 0.5) hw[y] = w
  for x = CX - w, CX + w - 1 do body:set(x, y) end end
-- rim band (front) and top ellipse
local rim = c:rect(18, 23, 45, 29)
local top = c:ellipse(31.5, 22, 13.5, 2.5)
local inner = c:ellipse(31.5, 22, 11.5, 1.6)
top:cut(inner)
rim:cut(top):cut(inner)
local function cyl(m, ny, half)
  local n = {}
  m:each(function(x, y) local w = half(y)
    local nx = max(-0.97, min(0.97, (x + 0.5 - CX) / (w + 0.4)))
    n[K(x, y)] = { B.norm(nx, ny, sqrt(1 - nx * nx)) }
  end)
  return n
end
local tok = { r = { name = "clay" } }
local bias = {}
for x = CX - 12, CX + 12 do bias[K(x, 30)] = -2 bias[K(x, 31)] = -1 end
for y = 53, 55 do for x = CX - 9, CX + 9 do bias[K(x, y)] = (bias[K(x, y)] or 0) - (y == 55 and 1 or 0) end end
body:each(function(x, y) if X.hash(x, y, 3) > 0.94 then bias[K(x, y)] = (bias[K(x, y)] or 0) - 1 end end)
local bidx = X.tone(c, body, X.light(cyl(body, -0.12, function(y) return hw[y] end), { amb = 0.06, wrap = 0.2 }), TC,
  { cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, bias = bias, tok = tok })
-- salt bloom: pale patchy band at the foot (same tone index, desaturated ramp)
body:each(function(x, y)
  local edge = 49 + floor(1.6 * sin(x * 0.8) + 1.2 * sin(x * 0.37 + 1) + 0.5)
  if y >= edge and X.hash(x, y, 9) > 0.12 then c:put(x, y, SALT[bidx[K(x, y)]], tok) end
end)
-- rim: band lit as a cylinder, lower lip row darker, top ellipse faces up
local rb = {}
for x = 18, 45 do rb[K(x, 29)] = -1 end
X.tone(c, rim, X.light(cyl(rim, 0, function() return 14 end), { amb = 0.08, wrap = 0.22 }), TC,
  { cuts = { 0.16, 0.3, 0.46, 0.62, 0.8 }, bias = rb, tok = tok })
-- bright lip row at top of the rim band
for x = 19, 44 do if rim:has(x, 23) then c:put(x, 23, (x < 36) and TC[6] or TC[4], tok) end end
top:each(function(x, y)
  local i = (y >= 23) and 5 or 6
  if x > 40 then i = i - 1 end
  if y < 21 and x > 26 and x < 38 then i = 4 end            -- far rim, seen across the opening
  c:put(x, y, TC[i], tok)
end)
-- inner back wall + soil
inner:each(function(x, y) c:put(x, y, TC[1], tok) end)
local soil = c:ellipse(31.5, 22.6, 10.5, 1.2):clip(inner)
local stok = { r = { name = "soil" } }
soil:each(function(x, y) local h = X.hash(x, y, 5)
  c:put(x, y, SOIL[h > 0.8 and 4 or h > 0.45 and 3 or 2], stok) end)

-- seedling
local sm = B.stem(c, { { 32, 22 }, { 31, 19 }, { 33, 16 }, { 32, 13 } }, function() return 0.75 end, STEM, { tok = { r = { name = "stem" } } })
local ltok = { r = { name = "leaf" } }
B.leaf(c, 32, 14, 27, 9, 22, 12, 2.6, LEAF, { cut = sm, tok = ltok, vs = 2.6, pw = 0.6 })
B.leaf(c, 33, 14, 38, 8, 43, 11, 2.8, LEAF, { cut = sm, tok = ltok, vs = 2.6, pw = 0.6 })

-- quirk: earthworm out of the soil, arching over the left rim and down the outside
local wm, wn, WT = B.tube({ { 23, 22 }, { 20, 18 }, { 15, 20 }, { 15, 27 } }, function(t) return t > 0.93 and 0.6 or 0.95 end)
local wtok = { r = { name = "worm" } }
local widx = X.tone(c, wm, X.light(wn, { amb = 0.15, wrap = 0.3 }), WORM, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = wtok })
wm:each(function(x, y) local k = K(x, y)
  if WT[k] and (WT[k] * 22) % 3 < 0.8 then c:put(x, y, WORM[max(1, widx[k] - 1)], wtok) end end)
-- saddle band (clitellum)
wm:each(function(x, y) local k = K(x, y) if WT[k] and WT[k] > 0.36 and WT[k] < 0.46 then c:put(x, y, WORM[max(2, widx[k])] == WORM[5] and WORM[4] or "#e07a7a", wtok) end end)
-- contact shadow of the worm on the rim
wm:shift(1, 1):each(function(x, y) if (rim:has(x, y) or top:has(x, y)) and not wm:has(x, y) then c:put(x, y, TC[2], tok) end end)
B.save(c, NAME)

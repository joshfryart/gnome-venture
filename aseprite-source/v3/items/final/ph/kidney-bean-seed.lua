-- kidney-bean-seed (final, Opus single pass). Two glossy maroon kidney beans on a torn bean-leaflet scrap (ovate,
-- pointed tip, ragged torn base, midrib + paired curving veins, V-fold light, cool reflected edge, AO + contact
-- shadow under each bean). The right bean has germinated: its coat has split (pale cotyledon in the crack), a white
-- radicle with root hairs runs off the leaf, and a pale hooked stem lifts the first pair of heart-shaped bean leaves.
-- quirk: the shed seed coat still clings to the tip of the right leaf like a tiny maroon cap.
local NAME = "kidney-bean-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SPRL  = { "#1d4a3a", "#2b6a42", "#3f8a48", "#5eaa52", "#88c662", "#b8e080" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local BEAN  = { "#33111f", "#561a2c", "#7e2331", "#a8323a", "#cf5548", "#f08f72" }
local COT   = { "#c9b27a", "#e6d49c", "#f6ecc4" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ROOT  = { "#a99a8a", "#d8ccb8", "#f2ead8" }
local SPEC, BCOOL, HILUM = "#fff0e6", "#6a5a8e", "#f4ecd8"

-- ---------------------------------------------------------------- torn leaflet scrap
local lm, ln, LT, LS, len = A.blade(7, 55, 30, 50, 57, 37, function(t)
  if t > 0.985 then return -1 end
  local u = t * 0.94 + 0.06
  return max(0.5, 9.4 * sin(pi * u ^ 1.25) ^ 0.75)
end, { fold = 0.4 })
-- torn base: ragged bite out of the lower-left end
local cut = {}
lm:each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  local tear = 0.1 + 0.07 * X.hash(floor(s * 6), 3, 7) + 0.03 * sin(s * 9)
  if t < tear then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- beans: (cx, cy, rx, ry, ang, dent side)
local function bean(cx, cy, rx, ry, ang, side)
  local m, n = A.oval(cx, cy, rx, ry, ang, 0.85)
  local ca, sa = cos(ang), sin(ang)
  local dx, dy = -sa * side, ca * side
  local ex, ey = cx + dx * ry * 1.5, cy + dy * ry * 1.5
  local r = ry * 0.95
  m:each(function(x, y) if (x - ex)^2 + (y - ey)^2 <= r * r then m.s[K(x, y)] = nil end end)
  return { m = m, n = n, ex = ex, ey = ey, ca = ca, sa = sa }
end
local b1 = bean(21, 47, 5.4, 3.3, -0.28, -1)
local b2 = bean(37, 42, 5.0, 3.1, -0.5, -1)

-- radicle (drawn into leaf AO first)
local rm, rn, RT = A.tube({ { 40, 45 }, { 44, 49 }, { 46, 53 }, { 51, 56 } }, function(t) return 1.3 * (1 - t) ^ 0.7 + 0.35 end)
rm:cut(b2.m)
local bias = {}
for _, b in ipairs{ b1, b2 } do X.ao(bias, lm, b.m, 1, -1) A.cast(bias, lm, b.m, 1, 2, -1) end
X.ao(bias, lm, rm, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- paired pinnate veins curving toward the tip
  local d = (t * len - abs(s) ^ 0.8 * 7.5)
  local f = (d / 6.2) % 1
  if f < 0.13 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.14 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.2 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: pale fibrous rim
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.2 then c:put(x, y, LEAF[5], ltok) end end)

-- radicle paint + root hairs
local rtok = { r = { name = "root" } }
A.shade(c, rm, rn, ROOT, { cuts = { 0.35, 0.7 }, amb = 0.15, wrap = 0.3, tok = rtok })
for _, p in ipairs{ { 45, 51 }, { 48, 56 }, { 47, 52 } } do c:put(p[1], p[2], ROOT[2], rtok) end
c:put(52, 56, ROOT[1], rtok)

-- ---------------------------------------------------------------- sprout
local stok = { r = { name = "stem" } }
local sp = { { 38, 39 }, { 39, 32 }, { 35, 26 }, { 33, 19 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - t * 0.15 end)
sm:cut(b2.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- heart-shaped primary leaves: broad lobed base, pointed tip
local function heart(ax, ay, cx, cy, bx, by)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.08 then return 0.6 end
    return max(0.5, 5.4 * sin(pi * min(1, (t - 0.08) * 0.92 + 0.22)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  local tok = { r = { name = "sprout-leaf" } }
  A.toneN(c, m, n, SPRL, { tok = tok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.12 and t > 0.1 and t < 0.88 then c:put(x, y, s <= 0 and SPRL[6] or SPRL[3], tok) end
    local d = t * L - abs(s) * 4.2
    if (d / 4.4) % 1 < 0.16 and abs(s) > 0.22 and abs(s) < 0.75 and t > 0.25 and t < 0.82 then c:put(x, y, s < 0 and SPRL[5] or SPRL[2], tok) end
  end)
  -- base notch (heart): carve the pixel at the petiole join
  return m, T, S
end
local hl = heart(32, 19, 26, 14, 14, 13)
local hr, HT = heart(34, 19, 41, 13, 52, 9)
-- tiny trifoliate bud between them
for _, q in ipairs{ { 33, 17, 4 }, { 33, 16, 5 }, { 32, 16, 3 }, { 34, 16, 4 } } do c:put(q[1], q[2], SPRL[q[3]], stok) end
-- quirk: seed-coat cap on the right leaf tip
for _, q in ipairs{ { 51, 8, 4 }, { 52, 8, 3 }, { 53, 9, 2 }, { 50, 9, 5 }, { 51, 9, 4 }, { 52, 9, 3 }, { 53, 10, 2 }, { 52, 10, 1 } } do
  c:put(q[1], q[2], BEAN[q[3]], { r = { name = "cap" } }) end
c:put(50, 8, SPEC, { r = { name = "cap" } })

-- ---------------------------------------------------------------- beans last
local function paintBean(b, tok, bb, split)
  local idx = A.shade(c, b.m, b.n, BEAN, { amb = 0.0, wrap = 0.1, bias = bb, tok = tok, cuts = { 0.3, 0.5, 0.66, 0.8, 0.93 } })
  local rim = X.rim(b.n)
  b.m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.62 and (idx[k] or 1) <= 3 then c:put(x, y, BCOOL, tok) end end)
  local best, hx, hy
  b.m:each(function(x, y) local q = (x - b.ex)^2 + (y - b.ey)^2 if not best or q < best then best, hx, hy = q, x, y end end)
  c:put(hx, hy, HILUM, tok)
  b.m:copy():shrink(1):each(function(x, y) local k = K(x, y) if idx[k] == 5 and X.hash(x, y, 9) > 0.85 then c:put(x, y, BEAN[6], tok) end end)
  if split then
    -- split coat: a pale cotyledon crack along the top edge
    for _, q in ipairs(split) do c:put(q[1], q[2], COT[q[3]], tok) end
  else
    local sx, sy = A.specAt(b.m:copy():shrink(1), b.n, 30)
    c:put(sx, sy, SPEC, tok) if b.m:has(sx + 1, sy) then c:put(sx + 1, sy, BEAN[6], tok) end
  end
end
local bb2 = {}
paintBean(b2, { r = { name = "bean2" } }, bb2, { { 34, 40, 2 }, { 35, 40, 3 }, { 36, 39, 3 }, { 37, 39, 2 }, { 38, 38, 1 }, { 33, 41, 1 } })
local bb1 = {}
X.ao(bb1, b1.m, b2.m, 1, -1)
paintBean(b1, { r = { name = "bean1" } }, bb1)

A.save(c, NAME)

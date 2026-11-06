-- meyer-lemon (aC23_2, Opus single pass). A rounder-than-lemon Meyer lemon lying on a slant (stem end upper-left,
-- small blunt nub lower-right), deep egg-yolk yellow with an orange blush on the shade side. Per-pixel ellipsoid light,
-- 6 tones, cool-violet shade, pitted oil-gland pores, waxy bloom band, one cream specular + a 2-px streak, cool reflected
-- light lower-right, sunken stem dimple with a green star calyx. A slim woody twig rises from the calyx carrying one glossy
-- citrus leaf (midrib, arched veins, winged petiole); leaf casts a contact shadow on the shoulder.
-- quirk: a purple-flushed Meyer blossom bud on the twig, about to open.
local NAME = "meyer-lemon"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEM  = { "#6e3540", "#b0583a", "#e08a26", "#f6b623", "#ffd84a", "#fff09a" }
local LEAF = { "#123a2e", "#1c5236", "#28703e", "#3c8e44", "#62ae4e", "#a4d670" }
local WOOD = { "#4a2c2a", "#7a4a32", "#a8724a", "#d0a070" }
local BUD  = { "#5a2c5e", "#9a5aa0", "#d8a6d8", "#fbe6f2" }
local SPEC, BOUNCE = "#fffbe6", "#b7887a"

-- body
local CX, CY, RX, RY, ANG = 32, 40, 15.5, 12.6, 0.36
local ca, sa = cos(ANG), sin(ANG)
local bm, bn = A.oval(CX, CY, RX, RY, ANG, 0.9)
-- blossom-end nub (lower right), stem end point (upper left)
local NX, NY = CX + (RX + 1.2) * ca, CY + (RX + 1.2) * sa
local nm, nn = A.oval(NX, NY, 2.2, 2.0, ANG, 0.7)
for k, v in pairs(nn) do if not bm.s[k] then bn[k] = v end end
bm:add(nm)
local SX, SY = CX - (RX - 0.6) * ca, CY - (RX - 0.6) * sa
local btok = { r = { name = "lemon" } }
local bias = {}
-- stem dimple AO
bm:each(function(x, y) local d = sqrt((x - SX) ^ 2 + (y - SY) ^ 2) if d < 2.6 then bias[K(x, y)] = -1 end end)

-- twig + leaf first so their masks exist for the cast shadow
local tp = { { SX, SY - 0.5 }, { SX - 1, SY - 5 }, { SX + 1, SY - 9 }, { SX + 3, SY - 13 } }
local tm, tn = A.tube(tp, function(t) return 1.25 - 0.35 * t end)
local lm, ln, LT, LS, len = A.blade(SX + 2, SY - 9, 36, 14, 52, 15, function(t)
  if t > 0.985 then return -1 end
  if t < 0.1 then return 0.6 + t * 6 end
  return max(0.5, 6.4 * sin(pi * min(1, (t - 0.05) * 1.02)) ^ 0.75)
end, { fold = 0.42 })
A.cast(bias, bm, lm, 1, 2, -1)
A.cast(bias, bm, tm, 1, 1, -1)

local idx = A.toneN(c, bm, bn, LEM, { bias = bias, tok = btok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.06, wrap = 0.24 })
-- pores: pitted oil glands (one step darker), sparse, avoid rim and dimple
bm:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i and i >= 3 and not bias[k] and X.hash(x, y, 7) > 0.86 and (x + y) % 2 == 0 then c:put(x, y, LEM[i - 1], btok) end
end)
-- waxy bloom: a lighter band just inside the lit rim
bm:edge():grow(1):each(function(x, y) local k = K(x, y)
  if bm:has(x, y) and not bm:edge():has(x, y) and idx[k] and idx[k] >= 4 and idx[k] <= 5 and not bias[k] then
    local nx = bn[k] if nx and nx[1] + nx[2] < -0.9 then c:put(x, y, LEM[idx[k] + 1], btok) end
  end end)
A.bounce(c, bm, bn, BOUNCE, btok, 0.7, function(x, y, k) return not bias[k] end)
-- specular: one cream pixel + a short streak along the curve
local gx, gy = A.specAt(bm, bn, 60)
c:put(gx, gy, SPEC, btok) c:put(gx + 1, gy, LEM[6], btok) c:put(gx - 1, gy + 1, LEM[6], btok) c:put(gx - 2, gy + 2, LEM[6], btok)
-- nub tip: a darker stub point
c:put(floor(NX + 1.6 * ca + .5), floor(NY + 1.6 * sa + .5), LEM[2], btok)

-- twig (wood, bark ridge)
local ttok = { r = { name = "twig" } }
X.tone(c, tm, X.light(tn, { amb = 0.1, wrap = 0.3 }), WOOD, { cuts = { 0.3, 0.55, 0.8 }, tok = ttok })
-- calyx star in the dimple
local CAL = { { 0, 0, 2 }, { -1, 0, 3 }, { 1, 0, 2 }, { 0, 1, 1 }, { -1, -1, 4 }, { 1, 1, 1 }, { -2, 1, 2 }, { 2, -1, 3 } }
for _, q in ipairs(CAL) do c:put(floor(SX + q[1] + .5), floor(SY + q[2] + .5), LEAF[q[3] + 1], ttok) end

-- leaf: glossy citrus blade, midrib, arched veins, specular streak on the lit half
local ltok = { r = { name = "leaf" } }
local lb = {}
A.cast(lb, lm, tm, 1, 1, -1)
local li = A.toneN(c, lm, ln, LEAF, { tok = ltok, bias = lb, cuts = { 0.16, 0.3, 0.46, 0.64, 0.84 }, amb = 0.14, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.14 and t > 0.06 and t < 0.92 then c:put(x, y, s <= 0 and LEAF[5] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 5.2
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  if s < -0.35 and s > -0.62 and t > 0.3 and t < 0.55 then c:put(x, y, "#d4f09a", ltok) end
end)
A.bounce(c, lm, ln, "#3e7a7a", ltok, 0.55, function(x, y, k) return LS[k] > 0.5 and LT[k] > 0.15 end)

-- quirk: purple-flushed blossom bud on a tiny pedicel, upper-left of the twig
local bx, by = SX - 3, SY - 14
for _, q in ipairs{ { SX, SY - 10 }, { SX - 1, SY - 11 }, { SX - 2, SY - 12 } } do c:put(floor(q[1] + .5), floor(q[2] + .5), LEAF[3], ttok) end
local bud = {
  ".hl.",
  "hhlm",
  "lmmd",
  ".md.",
  ".gg.",
}
local BC = { h = BUD[4], l = BUD[3], m = BUD[2], d = BUD[1], g = LEAF[3] }
for yy, row in ipairs(bud) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BC[ch] then c:put(floor(bx + .5) + xx - 3, floor(by + .5) + yy - 5, BC[ch], ttok) end end end

A.save2(c, NAME)

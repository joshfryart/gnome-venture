-- mango-seed (ph, Opus final pass, replaces the Sonnet draft). One big flat mango stone in its hairy husk (buff ramp,
-- long fibres along the length, a pale ridge on the upper rim, AO + contact shadow) lying across a long lanceolate
-- mango-leaf scrap torn off at the base (ragged pale tear, pale yellow midrib, close parallel side veins, cool rim).
-- The stone has sprouted from its back: a stout arching stem topped by the limp, bronze-red young leaves a mango
-- flush hangs down, and a pale root out of the end. quirk: a curly cowlick of fibre sticks up from the husk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("mango-seed")

local LEAF = { "#11302a", "#1a4732", "#255f38", "#357c40", "#4f9846", "#7cb858" }
local HUSK = { "#5a3a22", "#86603a", "#ae8a54", "#ccac70", "#e4cc92", "#f6e6b8" }
local BR = { "#3e1630", "#6a2236", "#983a3a", "#c25a3e", "#e2844e", "#f6b67a" }
local STEM = { "#4a2a2a", "#7a4636", "#a8704a", "#d0a470" }
local ROOT = { "#b49a72", "#d6c09a", "#efe2c2", "#fff6e0" }
local MID, COOL, TORN = "#d6d88a", "#36646c", "#c8e0a0"

-- husk: flat oval, slightly kidney (upper edge flattened)
local HX, HY, RX, RY, ANG = 33, 46, 12.5, 6.6, -0.22
local hm, hn = A.oval(HX, HY, RX, RY, ANG, 0.6)
local ca, sa = cos(ANG), sin(ANG)
local HU, HV = {}, {}
hm:each(function(x, y) local k = K(x, y) local dx, dy = x - HX, y - HY
  HU[k], HV[k] = (dx * ca + dy * sa) / RX, (-dx * sa + dy * ca) / RY end)
-- flatten the top: trim the upper middle a touch for the kidney dent
local trim = {}
hm:each(function(x, y) local k = K(x, y) if HV[k] < -0.86 + 0.5 * HU[k] ^ 2 and abs(HU[k]) < 0.35 then trim[#trim + 1] = k end end)
for _, k in ipairs(trim) do hm.s[k] = nil end

-- leaf scrap: long lanceolate blade, sagging, base torn off on the left
local lm, ln, LT, LS, len = A.blade(3, 47, 28, 61, 59, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 7.6 * sin(pi * min(1, t * 0.96 + 0.02)) ^ 0.75)
end, { fold = 0.5 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.16 + LS[k] * 0.05 + (X.hash(floor((x + y) / 2), 1, 4) - 0.5) * 0.06 then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local torn = HP.mask()
lm:edge():each(function(x, y) if LT[K(x, y)] < 0.24 and not lm:has(x - 1, y) then torn:set(x, y) end end)

-- sprout geometry (masks first, for shadows)
local sx0, sy0 = 27, 41
local stemPts = { { sx0, sy0 }, { 25, 35 }, { 26, 29 }, { 30, 25 } }
local rootPts = { { 21, 49 }, { 17, 51 }, { 15, 54 }, { 12, 55 } }
local rm, rn = A.tube(rootPts, function(t) return 1.1 * (1 - t) ^ 0.8 + 0.3 end)
rm:cut(hm)
local bias = {}
X.ao(bias, lm, hm, 1, -1) A.cast(bias, lm, hm, 1, 2, -1) A.cast(bias, lm, hm, 2, 2, -1)
X.ao(bias, lm, rm, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.15, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t < 0.97 then c:put(x, y, s <= 0 and MID or "#a8aa5e", ltok) return end
  local d = (t * len - abs(s) * 7.6 * 1.3) % 2.9
  if d < 0.7 and abs(s) > 0.2 and abs(s) < 0.85 then c:put(x, y, s < 0 and LEAF[min(6, lidx[k] + 1)] or LEAF[max(1, lidx[k] - 1)], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.3 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) c:put(x, y, TORN, ltok) end)

-- root over the leaf
local rtok = { r = { name = "root" } }
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not hm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })

-- husk: lit oval, longitudinal fibres, pale ridge on the upper rim, AO where the stem leaves
local htok = { r = { name = "husk" } }
local smask = A.tube(stemPts, function(t) return 1.6 - 0.5 * t end)
local hb = {}
X.ao(hb, hm, smask, 1, -1)
local hidx = A.shade(c, hm, hn, HUSK, { amb = 0.08, wrap = 0.28, bias = hb, tok = htok })
hm:each(function(x, y) local k = K(x, y) local u, vv = HU[k], HV[k]
  local f = (vv * RY + 0.5 * sin(u * 4.2)) / 1.6
  local fr = f - floor(f)
  local i = hidx[k]
  if fr < 0.3 and i > 1 then c:put(x, y, HUSK[i - 1], htok)
  elseif fr > 0.82 and i < 6 and i >= 3 then c:put(x, y, HUSK[i + 1], htok) end
end)
local e1 = hm:edge()
e1:each(function(x, y) local k = K(x, y) if HV[k] < -0.3 and HU[k] > -0.6 and HU[k] < 0.8 then c:put(x, y, HUSK[6], htok) end end)
local rimL = X.rim(hn)
e1:each(function(x, y) local k = K(x, y) if rimL[k] > 0.5 and HV[k] > 0.2 then c:put(x, y, "#7a6a7e", htok) end end)
local gx, gy = A.specAt(hm:shrink(2), hn, 30)
c:put(gx, gy, "#fff8e2", htok)

-- stem: stout, arching, reddish
local stok = { r = { name = "stem" } }
A.stem(c, stemPts, function(t) return 1.6 - 0.5 * t end, STEM, { cut = hm, tok = stok, cuts = { 0.3, 0.55, 0.8 } })
-- limp young leaves hanging from the top, bronze-red
local ytok = { r = { name = "young" } }
local function young(ax, ay, cx, cy, bx, by, w)
  local m, T, S = A.leaf(c, ax, ay, cx, cy, bx, by, w, BR, { vs = 2.2, fold = 0.55, tok = ytok, pw = 0.6 })
  return m
end
young(31, 25, 37, 24, 41, 37, 3.2)
young(29, 25, 21, 18, 13, 22, 3.2)
-- upright bud, lighter
local BUD = { "#6a2236", "#c25a3e", "#f6b67a", "#ffd8a4" }
for _, p in ipairs{ { 31, 24, 2 }, { 32, 23, 2 }, { 32, 22, 3 }, { 33, 21, 3 }, { 33, 20, 4 }, { 31, 23, 1 } } do c:put(p[1], p[2], BUD[p[3]], ytok) end

-- quirk: curly fibre cowlick on the husk's left shoulder
local cx0, cy0 = 23, 41
for _, p in ipairs{ { 0, 0, 4 }, { 0, -1, 5 }, { -1, -2, 4 }, { -1, -3, 5 }, { 0, -4, 6 }, { 1, -4, 4 }, { 1, -3, 3 } } do
  c:put(cx0 + p[1], cy0 + p[2], HUSK[p[3]], htok) end

A.save(c, "mango-seed")

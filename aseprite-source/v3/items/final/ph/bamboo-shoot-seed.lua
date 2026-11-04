-- bamboo-shoot-seed (final, aR3_2 single pass). Three bamboo grains (slim pointed caryopses in a straw husk with a lit
-- ridge, a dark groove and a pale tip) on a torn strip of bamboo leaf (long lanceolate, parallel veins with faint cross
-- tessellation, V-fold light, ragged tear, cool reflected edge, AO + contact shadow under each grain). The middle grain
-- has sprouted a miniature bamboo: a slim segmented culm with a swollen lit node ring and a papery sheath, carrying
-- three narrow lanceolate leaves with parallel veins.
-- quirk: one grain still wears its husk bristle, a long fine awn that curls at the end.
local NAME = "bamboo-shoot-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#15373a", "#1e5244", "#2b6d4c", "#3e8b52", "#61aa5c", "#96ca74" }
local YL = { "#22483a", "#326a44", "#4a8c4c", "#6dae56", "#9ccc6a", "#cfe692" }
local COOL = "#3a6676"
local GRAIN = { "#4a3426", "#76532f", "#a07844", "#c69f5e", "#e2c482", "#f6e4b2" }
local CULM = { "#2c5a3e", "#44804a", "#64a254", "#8cc062", "#bcdc84", "#e6f2b4" }
local SHEATH = { "#7a6440", "#a88c5a", "#d0b682", "#eedcac" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- grains: cx, cy, rx, ry, angle
local grains = { { 18, 44, 4.6, 1.9, 0.35 }, { 31, 47, 4.4, 1.9, -0.25 }, { 43, 49, 4.4, 1.8, 0.15 } }
for _, s in ipairs(grains) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf strip: bamboo leaf, long and narrow, sloping down to the right, torn across at the left
local lm, ln, LT, LS, len = G.blade(8, 40, 31, 52, 56, 51, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 5.6 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.55)
end, { fold = 0.35 })
G.tear(lm, 12, 41, -0.75, -0.66, 1.3, 9)
local bias = {}
for _, s in ipairs(grains) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 and t < 0.96 then c:put(x, y, s <= 0 and "#bfe08a" or LEAF[3], ltok) return end
  -- parallel veins
  local f = (abs(s) * 3.2) % 1
  if f < 0.2 and abs(s) > 0.25 and abs(s) < 0.85 and t < 0.94 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) return end
  -- faint cross tessellation every few px on the lit half
  local q = (t * len / 4.5) % 1
  if s < -0.2 and q < 0.12 and abs(s) < 0.8 then c:put(x, y, LEAF[4], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.12 and not bias[k] then c:put(x, y, LEAF[5], ltok) end end)

-- miniature bamboo sprout out of the middle grain
local stok = { r = { name = "culm" } }
local base = { 30, 45 }
local cp = { { 30, 45 }, { 30.5, 36 }, { 31.5, 22 }, { 31.5, 12 } }
local cm, cn, CT, CS = G.tube(cp, function(t) return 1.45 - 0.55 * t end)
cm:cut(grains[2].m)
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.12, wrap = 0.3 }), CULM, { cuts = CUTS, tok = stok })
-- nodes: swollen ring (lit lip above a dark seat)
local nodes = { 0.34, 0.6 }
cm:each(function(x, y) local k = K(x, y) local t = CT[k]
  for _, nt in ipairs(nodes) do
    local d = (t - nt) * 33
    if d > -0.6 and d < 0.5 then c:put(x, y, CULM[CS[k] < 0 and 6 or 3], stok) end
    if d >= 0.5 and d < 1.5 then c:put(x, y, CULM[CS[k] < 0 and 3 or 1], stok) end
  end
end)
-- papery sheath at the lower node (wraps the culm, pointed tab on the right)
local shm = HP.mask()
do local x, y = G.bez(cp, 0.36)
  for _, q in ipairs{ { 1, 1 }, { 2, 1 }, { 1, 2 }, { 2, 2 }, { 3, 0 }, { 2, 3 }, { 1, 3 }, { 4, -1 } } do shm:set(floor(x + .5) + q[1], floor(y + .5) + q[2]) end
end
local shtok = { r = { name = "sheath" } }
-- (sheath tab dropped: read as clutter at 16 px)

-- lanceolate leaves with parallel veins
local function lance(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.975 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.6 * (t < 0.08 and 0.6 or 1))
  end, { fold = 0.3 })
  m:cut(cm)
  G.toneN(c, m, n, YL, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.15 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and YL[6] or YL[3], ltok)
    elseif abs(S[k]) > 0.5 and abs(S[k]) < 0.66 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] < 0 and YL[5] or YL[2], ltok) end end)
  return m
end
local L1 = lance(32, 13, 37, 8, 46, 9, 1.9)       -- top leaf, out to the right
local L2 = lance(30, 24, 25, 20, 17, 19, 1.9)     -- left from the upper node
local L3 = lance(32, 25, 39, 25, 46, 30, 1.8)     -- right, drooping
-- AO where leaves join the culm
for _, q in ipairs{ { 31, 24 }, { 32, 23 }, { 31, 14 } } do if cm:has(q[1], q[2]) then c:put(q[1], q[2], CULM[1], stok) end end

-- grains last: husk with lit ridge, dark groove, pale tip
for i, s in ipairs(grains) do
  local tok = { r = { name = "grain" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local idx
    if v < -0.45 then idx = 5 elseif v < 0.05 then idx = 4 elseif v < 0.4 then idx = 2 else idx = 3 end
    if v < -0.45 and u > -0.5 and u < 0.2 then idx = 6 end
    if abs(u) > 0.78 then idx = idx - 1 end
    if u > 0.78 and v < 0.2 then idx = 5 end     -- pale beak tip
    c:put(x, y, GRAIN[max(1, min(6, idx))], tok)
  end)
end
-- the sprouting grain: split husk where the culm comes out
c:put(29, 46, GRAIN[6], { r = { name = "split" } }) c:put(31, 46, GRAIN[1], { r = { name = "split" } })

-- quirk: awn from the left grain's tip, curling at the end
do local s = grains[1] local ca, sa = cos(s[5]), sin(s[5])
  local tx, ty = s[1] - ca * (s[3] + 0.5), s[2] - sa * (s[3] + 0.5)
  local ap = { { tx, ty }, { tx - 3, ty - 1.5 }, { tx - 5, ty - 5 }, { tx - 3.5, ty - 7 } }
  G.path(c, ap, function(t) return t < 0.5 and GRAIN[4] or GRAIN[5] end, { r = { name = "awn" } }, 30)
  local ex, ey = G.bez(ap, 1) c:put(floor(ex + .5) + 1, floor(ey + .5), GRAIN[5], { r = { name = "awn" } })
end

G.save2(c, NAME)

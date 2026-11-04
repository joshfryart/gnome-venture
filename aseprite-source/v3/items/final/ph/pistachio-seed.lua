-- pistachio-seed (aC35_1, Opus single pass). Two in-shell pistachio nuts (ivory shell, rosy tip, dark seam) lying
-- on a torn scrap of a leathery pistachio leaflet (ovate, glossy, midrib + paired side veins, V-fold light, cool
-- reflected edge, a ragged torn end with a pale fibrous rim, AO + contact shadow under each nut). The right nut has
-- split at the tip and sprouted: pale stem, two fleshy kernel-green cotyledons, and a first true leaf of three ovate
-- leaflets (pistachio's pinnate leaf in miniature) with midribs.
-- quirk: the cotyledons still wear a thin red-violet rim of the kernel's papery skin.
local NAME = "pistachio-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#163a30", "#1f5238", "#2c6c3e", "#3f8a44", "#62a84e", "#94c866" }
local VEIN, COOL, TORN = "#bfe08a", "#3a6670", "#c8d89a"
local SHELL = { "#5c4038", "#8a684e", "#b8946a", "#d9bb8c", "#efd9ae", "#fff1d2" }
local BLUSH = { "#6a3440", "#9a5258", "#c47a72", "#dea088", "#f0c0a4", "#ffdcc4" }
local KER = { "#1f4a2a", "#2f6a34", "#4a8c3c", "#72b048", "#a0d05e", "#d0ec96" }
local SKIN = "#a8445e"
local STEM = { "#5a7a4a", "#8eb070", "#bcd896", "#e2f0c0" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- nuts: cx, cy, rx(long), ry, angle (long axis), split?
local nuts = { { 19, 47, 6.2, 4.0, -0.25 }, { 33, 44, 6.0, 3.9, -0.95 } }
for _, s in ipairs(nuts) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end

-- leaf scrap: ovate leaflet on the diagonal, torn off ragged at the right end
local lm, ln, LT, LS, len = G.blade(6, 55, 28, 54, 56, 40, function(t)
  if t > 0.86 then return -1 end
  return max(0.5, 7.8 * sin(pi * min(1, t * 0.78 + 0.06)) ^ 0.75)
end, { fold = 0.35 })
-- ragged tear across the end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.05 * sin(LS[k] * 9) + 0.03 * sin(LS[k] * 23 + 1)
  if LT[k] > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(nuts) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- paired side veins swept toward the tip
  local ph = (t * len - abs(s) * 5.0) / 6.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.18 and abs(s) < 0.8 and t > 0.05 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- glossy leathery highlight streak on the lit half
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] < -0.3 and LS[k] > -0.5 and LT[k] > 0.25 and LT[k] < 0.45 then c:put(x, y, "#c6e690", ltok) end end)
-- edges: cool reflected light on the shade edge, pale fibre along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local lim = 0.8 + 0.05 * sin(LS[k] * 9) + 0.03 * sin(LS[k] * 23 + 1)
  if LT[k] > lim - 0.035 then c:put(x, y, TORN, ltok)
  elseif LS[k] > 0.66 and LT[k] > 0.1 then c:put(x, y, COOL, ltok) end
end)
for _, q in ipairs{ {5, 56, 3}, {4, 57, 2}, {3, 57, 2} } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the right nut's tip
local s2 = nuts[2]
local tipx, tipy = s2[1] + cos(s2[5]) * s2[3], s2[2] + sin(s2[5]) * s2[3]   -- upper-right tip
local stok = { r = { name = "stem" } }
local sp = { { tipx - 0.5, tipy }, { tipx - 1, tipy - 6 }, { tipx + 1.5, tipy - 9 }, { tipx + 1, tipy - 13 } }
local stm, stn = G.tube(sp, function(t) return 1.0 end)
for _, s in ipairs(nuts) do stm:cut(s.m) end
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local ex, ey = G.bez(sp, 1)
-- fleshy cotyledons: thick ovals either side of the stem top, rimmed with skin (quirk)
local cot = {}
local ctok = { r = { name = "cotyledon" } }
for _, d in ipairs{ { -1, -0.35 }, { 1, 0.3 } } do
  local cx, cy = ex + d[1] * 5.2, ey + 1.6 + d[1] * 0.6
  local m, n = G.oval(cx, cy, 4.6, 2.6, d[2], 1.0)
  m:cut(stm)
  local idx = X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), KER, { cuts = CUTS, tok = ctok })
  m:edge():each(function(x, y)
    local ux, uy = x - cx, y - cy
    if uy * 1 + ux * 0.2 > 0.4 then c:put(x, y, SKIN, ctok) end end)
  cot[#cot + 1] = m
end
-- first true leaf: petiole up, three ovate leaflets with midribs
local pet = { { ex, ey }, { ex, ey - 3 }, { ex + 0.5, ey - 6 }, { ex + 0.5, ey - 8 } }
local tok2 = { r = { name = "trueleaf" } }
local function leaflet(ax, ay, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, (ax + bx) / 2 + 0.6, (ay + by) / 2 - 0.6, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.3, w * sin(pi * min(1, t * 0.85 + 0.1)) ^ 0.8)
  end, { fold = 0.3 })
  for _, cm in ipairs(cot) do m:cut(cm) end
  G.toneN(c, m, n, LEAF, { tok = tok2, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.16 and T[k] > 0.1 and T[k] < 0.82 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], tok2) end end)
  return m
end
local px, py = G.bez(pet, 1)
leaflet(px, py, px - 8, py - 4, 2.4)
leaflet(px, py, px + 8, py - 3, 2.4)
leaflet(px, py, px + 0.5, py - 8, 2.6)
for i = 0, 20 do local x, y = G.bez(pet, i / 20) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end

-- nuts last: shell lighting, blush tip, seam, AO between them
for i, s in ipairs(nuts) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #nuts do vis:cut(nuts[j].m) X.ao(sb, s.m, nuts[j].m, 1, -1) end
  local ca, sa = cos(s[5]), sin(s[5])
  -- seam along the long axis
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(v) < 0.14 and i == 2 then sb[K(x, y)] = (sb[K(x, y)] or 0) - 2 end
    if abs(v - 0.15) < 0.12 and i == 1 then sb[K(x, y)] = (sb[K(x, y)] or 0) - 2 end
  end)
  local tok = { r = { name = "nut" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.1, wrap = 0.3 }), SHELL, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = sb, tok = tok })
  vis:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    if u > 0.45 then c:put(x, y, BLUSH[idx[K(x, y)]], tok) end
  end)
  local bx, by = G.specAt(vis, s.n, 30)
  c:put(bx, by, SHELL[6], tok) c:put(bx + 1, by, "#fff4d6", tok)
end
-- split tip of nut 2: green kernel peeking where the stem comes out
c:put(floor(tipx - 1.5 + .5), floor(tipy + 1 + .5), KER[5], ctok)
c:put(floor(tipx - 0.5 + .5), floor(tipy + 1.5 + .5), KER[3], ctok)

G.save2(c, NAME)

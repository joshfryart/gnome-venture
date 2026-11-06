-- ginger-seed (Opus single pass). A ginger seed piece (a knobbly rhizome with ringed nodes, a pale cut end showing
-- yellow fibrous flesh, a pink waking bud) on a torn scrap of long lance-shaped ginger leaf (midrib, parallel swept
-- veins, ragged torn ends, cool reflected edge, AO + contact shadow under the rhizome). From the bud rises a pink-footed
-- pseudostem with two narrow alternate ginger leaves and a rolled tip leaf.
-- quirk: a round dew drop sits on the leaf scrap, with a cream glint and its own tiny shadow.
local NAME = "ginger-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi
local c = G.new2(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local YLEAF = { "#1d4a34", "#2b6a3e", "#3f8a44", "#5eaa4c", "#86c85a", "#bfe486" }
local COOL = "#3a6c72"
local SKIN = { "#4a2c26", "#74452f", "#9e683e", "#c38e55", "#ddb478", "#f2d6a0" }
local FLESH = { "#b88a34", "#e0b84a", "#f4d873", "#fff0b0" }
local PINK = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local DEW = { "#2a4a7a", "#3a86b0", "#7fd0d4", "#c8f2ea" }

-- torn leaf scrap: a section of a long lanceolate ginger leaf, ragged at both ends
local lm, ln, LT, LS, len = G.blade(9, 53, 30, 50.5, 56, 40, function(t) return 6.6 * (0.8 + 0.2 * sin(pi * t)) end, { fold = 0.32 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local j1 = 0.035 + 0.05 * X.hash(floor(s * 6 + 9), 1, 3) + 0.02 * (s > 0 and 1 or 0)
  local j2 = 0.93 - 0.06 * X.hash(floor(s * 5 + 9), 2, 5) - 0.04 * (s < 0 and 1 or 0)
  if t < j1 or t > j2 then cut[#cut + 1] = k end
  -- a small tear notch on the lower edge
  if s > 0.7 and t > 0.62 and t < 0.67 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- rhizome: three lobes merged and lit as one pillowy body
local rz = HP.mask()
local lobes = { { 27, 44, 7.2, 3.6, -0.15 }, { 36.5, 40.5, 3.8, 3.1, -0.7 }, { 19, 46.5, 3.2, 2.7, 0.15 } }
for _, o in ipairs(lobes) do local m = G.oval(o[1], o[2], o[3], o[4], o[5], 1) rz:add(m) end
local bias = {}
X.ao(bias, lm, rz, 1, -1) G.cast(bias, lm, rz, 1, 2, -1) G.cast(bias, lm, rz, 2, 3, -1)
-- dew drop (quirk) shadow on the leaf
local DX, DY = 46, 47
G.cast(bias, lm, G.rell(DX, DY, 1, 0, 1.8, 1.8), 1, 1, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 then c:put(x, y, s <= 0 and "#c2e48c" or LEAF[3], ltok) return end
  -- parallel ginger veins sweeping out from the midrib toward the tip
  local ph = (t * len - abs(s) * 7.0) / 4.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.8 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 then c:put(x, y, COOL, ltok) end
  -- torn ends show a paler fibrous edge
  if LT[k] < 0.11 or LT[k] > 0.86 then if LS[k] < 0.5 and not bias[k] then c:put(x, y, LEAF[6], ltok) end end
end)

-- sprout (drawn before the rhizome so the bud sits over the shoot foot)
local stok = { r = { name = "shoot" } }
local sp = { { 37, 38 }, { 37.5, 31 }, { 38, 24 }, { 38.5, 16 } }
local sm, sn, ST = G.tube(sp, function(t) return 1.25 - 0.35 * t end)
local sidx = G.toneN(c, sm, sn, YLEAF, { tok = stok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.15, wrap = 0.3 })
-- pink-flushed foot and leaf-sheath rings on the pseudostem
sm:each(function(x, y) local k = K(x, y)
  if ST[k] < 0.22 then c:put(x, y, PINK[max(1, min(4, (sidx[k] or 3) - 1))], stok) end
  if (ST[k] > 0.45 and ST[k] < 0.49) or (ST[k] > 0.7 and ST[k] < 0.73) then c:put(x, y, YLEAF[max(1, (sidx[k] or 3) - 2)], stok) end
end)
local l1 = G.lance(c, 38, 27, 47, 21, 55, 13, 2.7, YLEAF, ltok, { cut = sm, veins = 3.6, cool = COOL, pow = 0.75 })
local l2 = G.lance(c, 38, 21, 29, 16, 21, 13, 2.5, YLEAF, ltok, { cut = sm:copy():add(l1), veins = 3.6, cool = COOL, pow = 0.75 })
-- rolled tip leaf (a tight scroll, lit on the left)
local tm, tn = G.tube({ { 38.5, 17 }, { 38.8, 13 }, { 39.4, 12 }, { 40.5, 9.5 } }, function(t) return 1.3 * (1 - t) + 0.45 end)
tm:cut(l1):cut(l2)
G.toneN(c, tm, tn, YLEAF, { tok = ltok, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.15, wrap = 0.3 })
-- AO where the leaves leave the stem
for _, p in ipairs{ { 39, 26 }, { 40, 26 }, { 37, 20 }, { 36, 20 } } do if not sm:has(p[1], p[2]) then c:put(p[1], p[2], YLEAF[2], ltok) end end

-- rhizome body
local rtok = { r = { name = "rhizome" } }
local rn = X.pillow(rz, 3.2)
local rb = {}
local ridx = G.toneN(c, rz, rn, SKIN, { tok = rtok, bias = rb, cuts = { 0.15, 0.3, 0.46, 0.63, 0.8 }, amb = 0.1, wrap = 0.3 })
-- node rings: thin curved dark bands across the lobes, with a pale lip above each
rz:each(function(x, y) local k = K(x, y)
  local i = ridx[k] or 3
  for _, rx in ipairs{ 22.5, 29.5, 34 } do
    local d = x - rx - (y - 44) * 0.35
    if d >= 0 and d < 1 then c:put(x, y, SKIN[max(1, i - 2)], rtok) end
    if d >= -1 and d < 0 and i < 6 then c:put(x, y, SKIN[min(6, i + 1)], rtok) end
  end
  -- papery skin speckle
  if X.hash(x, y, 11) > 0.9 and i >= 3 and i <= 5 then c:put(x, y, SKIN[i - 1], rtok) end
end)
-- cut end on the left lobe: yellow fibrous flesh face
local cf = G.rell(16.6, 46.6, 0.3, 1, 2.4, 1.5)
cf:clip(rz)
cf:each(function(x, y)
  local col = FLESH[3]
  if y >= 47 or x >= 18 then col = FLESH[2] end
  if X.hash(x, y, 5) > 0.7 then col = FLESH[1] end
  if x <= 15 and y <= 46 then col = FLESH[4] end
  c:put(x, y, col, rtok)
end)
-- the waking bud: a pink cone on top of the right knob, foot of the shoot
for _, p in ipairs{ { 36, 37, 2 }, { 37, 37, 2 }, { 38, 37, 1 }, { 36, 36, 3 }, { 37, 36, 2 }, { 36, 35, 4 } } do c:put(p[1], p[2], PINK[p[3]], rtok) end
-- skin specular
c:put(25, 41, SKIN[6], rtok) c:put(26, 41, "#fff4d6", rtok)

-- quirk: dew drop on the leaf scrap
local dm, dn = G.ball(c, DX + 0.5, DY + 0.5, 1.8, DEW, { r = { name = "dew" } }, { cuts = { 0.2, 0.45, 0.7 } })
c:put(DX - 1, DY - 1, "#fff4d6")
c:put(DX + 1, DY + 1, DEW[4])

G.save2(c, NAME)

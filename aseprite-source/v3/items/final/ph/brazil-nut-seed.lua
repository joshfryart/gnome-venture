-- brazil-nut-seed (final, Opus aB10_2). Two small Brazil nuts in shell (three-faced woody wedges, ridged and fibre
-- grooved, pale scar at the blunt end) lying on a torn scrap of a Brazil-nut-tree leaf: a broad oblong leaf with a
-- wavy margin, strong midrib and close parallel side veins, V-fold light, cool reflected edge, the near end ripped
-- off in a jagged tear. The front nut has germinated: a bronze-red stem rises from its blunt end carrying one young
-- oblong leaf (wavy edge, midrib + parallel veins, the tree's leaf in miniature) and a furled second leaf.
-- quirk: a single dewdrop sits on the young leaf.
local NAME = "brazil-nut-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SHELL = { "#2a1820", "#4a2a26", "#6e3f2c", "#955a36", "#bb7c48", "#dea468" }
local STEM = { "#5a2a2a", "#8a3e30", "#b8603e", "#e09060" }
local YL = { "#5a2c34", "#8a3e3a", "#b45a40", "#d67e4c", "#f0a866", "#ffd08a" }  -- young bronze leaf
local CUTS = { 0.12, 0.27, 0.43, 0.6, 0.78 }

-- leaf scrap on the diagonal (lower-left -> upper-right), wavy margin, torn near end
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 50, 58, 34, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.9 + 0.1)
  return max(0.6, 7.6 * sin(pi * u ^ 1.05) ^ 0.6 + 0.6 * sin(t * 17))
end, { fold = 0.35 })
-- jagged tear across the lower-left end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local jag = 0.2 + 0.07 * ((floor((s + 1) * 4) % 2 == 0) and 1 or -1) + 0.04 * X.hash(floor((s + 1) * 6), 0, 3)
  if t < jag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- nuts: back nut lies flat, front nut sprouts
local function nutPts(x, y, dx, dy) return { { x, y }, { x + dx * 0.3 - dy * 0.15, y + dy * 0.3 + dx * 0.15 }, { x + dx * 0.7 - dy * 0.12, y + dy * 0.7 + dx * 0.12 }, { x + dx, y + dy } } end
local nw = function(t) if t > 0.99 then return 0.3 end return max(0.5, 4.2 * sin(pi * (0.14 + t * 0.86)) ^ 0.7) end
local backP = nutPts(36, 36, 13, -5)
local frontP = nutPts(20, 45, 15, 1)
local bm = A.tube(backP, nw)
local fm = A.tube(frontP, nw)

-- leaf paint with AO + contact shadows under the nuts
local bias = {}
for _, m in ipairs{ bm, fm } do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = CUTS, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- close parallel side veins swept toward the tip
  local ph = (t * len - abs(s) * 5.5) / 4.2
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.16 and abs(s) < 0.82 and t < 0.92 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.25 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn fibres: pale vein ends sticking out of the tear
for _, q in ipairs{ { 0.0 }, { -0.5 }, { 0.5 } } do
  local best
  lm:each(function(x, y) local k = K(x, y) if abs(LS[k] - q[1]) < 0.12 and (not best or LT[k] < best[3]) then best = { x, y, LT[k] } end end)
  if best then c:put(best[1] - 1, best[2] + (q[1] < 0 and 0 or 1), VEIN, ltok) end
end

-- back nut, then the front one over it
local _, BT, BS, _, btok = A.shell(c, backP, nw, SHELL, { seed = 11, cut = fm, tok = { r = { name = "nutB" } } })
bm:cut(fm)
local fmm, FT, FS, _, ftok = A.shell(c, frontP, nw, SHELL, { seed = 5, tok = { r = { name = "nutF" } } })
-- AO on the back nut where the front nut meets it
fm:grow(1):each(function(x, y) if bm:has(x, y) and not fm:has(x, y) then A.shift(c, x, y, SHELL, -1, btok) end end)
-- scars at the blunt ends
for _, P in ipairs{ { fmm, FT, FS, ftok }, } do
  P[1]:each(function(x, y) local k = K(x, y)
    if P[2][k] < 0.07 and abs(P[3][k]) < 0.6 then c:put(x, y, P[3][k] < 0 and SHELL[6] or SHELL[5], P[4]) end end)
end
c:put(25, 42, "#f4d49a", ftok) c:put(26, 42, "#f4d49a", ftok)

-- sprout from the front nut's blunt end: stem, young leaf, furled leaf
local stok = { r = { name = "stem" } }
local sp = { { 21, 42 }, { 20, 34 }, { 23, 27 }, { 22, 20 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(fmm)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- young oblong leaf off to the left
local ytok = { r = { name = "young" } }
local ym, yn, YT, YS, ylen = A.blade(22, 21, 14, 14, 7, 10, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 3.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6 + 0.35 * sin(t * 14))
end, { fold = 0.4 })
ym:cut(sm)
A.toneN(c, ym, yn, YL, { tok = ytok, cuts = CUTS, amb = 0.15, wrap = 0.3 })
ym:each(function(x, y) local k = K(x, y) local s, t = YS[k], YT[k]
  if abs(s) < 0.14 and t > 0.06 and t < 0.9 then c:put(x, y, s <= 0 and YL[6] or YL[3], ytok) return end
  local ph = (t * ylen - abs(s) * 3) / 2.6
  if ph - floor(ph) < 0.2 and abs(s) > 0.2 and abs(s) < 0.75 and t < 0.85 then c:put(x, y, s < 0 and YL[5] or YL[2], ytok) end
end)
-- furled second leaf: a slim rolled spear at the top
local fum, fun = A.tube({ { 22, 21 }, { 23, 17 }, { 25, 13 }, { 27, 10 } }, function(t) return 1.5 * (1 - t) + 0.3 end)
fum:cut(ym)
X.tone(c, fum, X.light(fun, { amb = 0.15, wrap = 0.3 }), YL, { cuts = CUTS, tok = ytok })
-- quirk: dewdrop on the young leaf
local dtok = { r = { name = "dew" } }
A.map(c, 12, 14, {
  ".ab.",
  "awbs",
  "abbs",
  ".ss.",
}, { a = "#b6f0e0", b = "#7fd4dc", s = "#3a86b0", w = "#fff4d6" }, dtok)

A.save(c, NAME)

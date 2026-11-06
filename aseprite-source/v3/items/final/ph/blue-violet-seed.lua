-- blue-violet-seed (final, Opus single pass). Viola: three glossy tan seeds, each with a cream elaiosome nub, on a
-- foreshortened heart-shaped violet leaf (crenate margin, palmate veins from the sinus, pillow light, cool edge,
-- AO + contact shadows) whose tip is torn off. One seed has sprouted: stem, two round cotyledons and a first
-- heart-shaped, scalloped true leaf on its petiole.
-- quirk: an ant is marching off with a fourth seed, gripping it by the cream elaiosome.
local NAME = "blue-violet-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local norm = A.norm
local LEAF = { "#163c2e", "#1f5a38", "#2b7a40", "#44994a", "#6cb856", "#a2d472" }
local VEIN, COOL, TORN = "#c6e692", "#356a70", "#d8eeb0"
local SPR = { "#1c4a32", "#29683c", "#3b8a46", "#5aaa52", "#84c862", "#b8e28a" }
local STEM = { "#3f7c4c", "#6aac62", "#a2d488", "#d8f0b8" }
local VS = { "#45281a", "#6c4426", "#946233", "#b98646", "#d9ab66", "#f4d79a" }
local EL = { "#b9a676", "#e7d9a6", "#fff4d6" }
local ANT = { "#2e1418", "#5e2628", "#933e34" }

-- heart leaf builder: sinus (sx,sy), toward tip (tx,ty), half-width W (px). returns mask, normals, U, V
local function heart(sx, sy, tx, ty, W, crenN, tearU)
  local dx, dy = tx - sx, ty - sy
  local L = sqrt(dx*dx + dy*dy)
  local ux, uy = dx / L, dy / L
  local px, py = -uy, ux
  if px + py < 0 then px, py = -px, -py end
  local m, U, V = HP.mask(), {}, {}
  local inside = function(u, v)
    local av = abs(v)
    local lobe = ((u - 0.3) / 0.32)^2 + ((av - 0.42) / 0.58)^2 <= 1
    local taper = u >= 0.3 and u <= 1 and av <= 0.98 * (1 - ((u - 0.3) / 0.7) ^ 1.7) ^ 0.9
    return lobe or taper
  end
  local R = floor(max(L, W) + 3)
  for y = floor(sy) - R, floor(sy) + R do for x = floor(sx) - R, floor(sx) + R do
    local rx, ry = x - sx, y - sy
    local u, v = (rx*ux + ry*uy) / L, (rx*px + ry*py) / W
    if inside(u, v) then m:set(x, y) local k = K(x, y) U[k], V[k] = u, v end
  end end
  -- crenate margin: notch the border pixels on a scallop rhythm (angle about the leaf centre)
  local d = X.dist(m)
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    if d[k] < 1.0 then
      local a = atan(V[k] * W, (U[k] - 0.42) * L)
      if sin(a * crenN) > 0.5 then cut[#cut + 1] = k end
    end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  if tearU then A.tear(m, function(x, y) return U[K(x, y)] end, tearU, true, 0.07, 5) end
  -- normals: pillow + V fold along the midrib
  local pn = X.pillow(m, 4)
  local n = {}
  m:each(function(x, y) local k = K(x, y) local p = pn[k]
    local v = V[k] local f = (v < 0 and -1 or 1) * 0.34 + v * 0.2
    n[k] = { norm(p[1] + px * f, p[2] + py * f, p[3]) } end)
  return m, n, U, V, L
end

-- seeds on the leaf: cx, cy, angle (elaiosome at the +u end)
local seeds = { { 21, 45, 0.5 }, { 27, 50, -0.25 }, { 31, 42, 0.9 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], 3.3, 2.2, s[3], 0.8)
  s.e = A.rell(s[1] + 4.0 * cos(s[3]), s[2] + 4.0 * sin(s[3]), cos(s[3]), sin(s[3]), 1.4, 1.5)
  s.e:cut(s.m)
end
local allS = HP.mask() for _, s in ipairs(seeds) do allS:add(s.m):add(s.e) end

-- ant (facing left) glyph, top-left at (AX,AY); held seed in front of its jaws
local AX, AY = 40, 47
local ANTG = {
  "..a..........",
  "...a...l..l..",
  ".hHh.tTl.gGg.",
  "hhhhltttlgggg",
  ".hhd.ttd.gggd",
  "..l.l..l.dgd.",
  ".l...l...l...",
}
local antm = HP.mask()
for j, row in ipairs(ANTG) do for i = 1, #row do if row:sub(i, i) ~= "." then antm:set(AX + i - 1, AY + j - 1) end end end
local held = { 35.5, 50.5, -0.3 }
held.m, held.n = A.oval(held[1], held[2], 3.0, 2.0, held[3], 0.8)
held.e = A.rell(38.6, 51.2, 1, 0, 1.2, 1.3) held.e:cut(held.m)

-- leaf scrap
local lm, ln, LU, LV, L = heart(5, 44, 60, 52, 12, 25, 0.875)
local bias = {}
X.ao(bias, lm, allS, 1, -1) A.cast(bias, lm, allS, 1, 2, -1) A.cast(bias, lm, allS, 2, 2, -1)
A.cast(bias, lm, antm, 1, 1, -1)
local hm = held.m:copy():add(held.e) A.cast(bias, lm, hm, 1, 2, -1) A.cast(bias, lm, hm, 2, 3, -1)
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- palmate veins from the sinus: midrib + two pairs
local VA = { 0.0, 0.42, -0.42, 0.95, -0.95 }
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local u, v = LU[k], LV[k]
  local r = sqrt((u * L)^2 + (v * 12)^2)
  if r < 2 then return end
  local a = atan(v * 12, u * L)
  for i, va in ipairs(VA) do
    local want = va * (1 + 0.35 * min(1, r / 30))           -- veins sweep outward
    local w = i == 1 and 0.75 or 0.55
    if abs((a - want) * r) < w and (i == 1 or r < 26) then
      c:put(x, y, v <= 0.02 and VEIN or LEAF[2], ltok) return
    end
  end
end)
local lb = A.border(lm)
for _, p in ipairs(lb) do local k = K(p[1], p[2])
  if LU[k] > 0.82 and p[3] >= 0 then c:put(p[1], p[2], TORN, ltok)
  elseif not bias[k] and LV[k] > 0.55 then c:put(p[1], p[2], COOL, ltok) end end

-- sprout
local stok = { r = { name = "stem" } }
local sp = { { 21, 44 }, { 23, 37 }, { 19, 31 }, { 20, 24 } }
local stm, stn = A.tube(sp, function() return 1.05 end)
stm:cut(seeds[1].m)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local sptok = { r = { name = "sprout" } }
-- round cotyledons on short stalks
for _, q in ipairs{ { 15.5, 32, -0.35 }, { 27, 33.5, 0.3 } } do
  local m, n = A.oval(q[1], q[2], 3.6, 2.4, q[3], 0.7)
  m:cut(stm)
  local idx = A.shade(c, m, n, SPR, { tok = sptok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) if abs((y - q[2]) - (x - q[1]) * math.tan(q[3])) < 0.5 and abs(x - q[1]) < 2.5 then A.step(c, idx, SPR, x, y, -1, sptok) end end)
end
-- first true leaf: heart on the petiole
local tm, tn, TU, TV, TL = heart(20, 24, 31, 9, 6.6, 15, nil)
tm:cut(stm)
A.shade(c, tm, tn, SPR, { tok = sptok, amb = 0.14, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y) local u, v = TU[k], TV[k]
  local r = sqrt((u * TL)^2 + (v * 6.6)^2) if r < 1.5 then return end
  local a = atan(v * 6.6, u * TL)
  if abs(a * r) < 0.6 and u < 0.9 then c:put(x, y, v <= 0 and SPR[6] or SPR[3], sptok)
  elseif abs((abs(a) - 0.75) * r) < 0.5 and r < 9 then c:put(x, y, v < 0 and SPR[5] or SPR[2], sptok) end
end)
for _, p in ipairs(A.border(tm)) do local k = K(p[1], p[2]) if TV[k] > 0.55 then c:put(p[1], p[2], COOL, sptok) end end
c:put(20, 24, STEM[2], stok)

-- seeds: glossy tan obovoids + elaiosome
local function seed(s, i)
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, VS, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.05, wrap = 0.22 })
  -- faint seam along the long axis
  local ca, sa = cos(s[3]), sin(s[3])
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local v = -dx * sa + dy * ca local u = dx * ca + dy * sa
    if abs(v - 0.6) < 0.5 and abs(u) < 2.2 then A.step(c, idx, VS, x, y, -1, tok) end end)
  local bx, by = A.specAt(s.m, s.n, 30)
  if bx then c:put(bx, by, VS[6], tok) end
  s.e:each(function(x, y) local lit = not s.e:has(x - 1, y) or not s.e:has(x, y - 1)
    local dark = not s.e:has(x + 1, y) and not s.e:has(x, y + 1)
    c:put(x, y, dark and EL[1] or (lit and EL[3] or EL[2]), tok) end)
end
for i, s in ipairs(seeds) do seed(s, i) end

-- ant + its seed
local atok = { r = { name = "ant" } }
local AM = { a = ANT[1], l = ANT[1], d = ANT[1], h = ANT[2], t = ANT[2], g = ANT[2], H = ANT[3], T = ANT[3], G = ANT[3] }
for j, row in ipairs(ANTG) do for i = 1, #row do local ch = row:sub(i, i)
  if AM[ch] then c:put(AX + i - 1, AY + j - 1, AM[ch], atok) end end end
c:put(AX + 10, AY + 2, "#d07a5a", atok)  -- gaster glint
seed(held, 4)

A.save(c, NAME)

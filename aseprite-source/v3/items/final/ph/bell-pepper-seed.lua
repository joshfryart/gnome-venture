-- bell-pepper-seed (final pass, Opus). Three flat, kidney-shaped ivory pepper seeds (thick pale rim, slightly dished
-- centre, dark hilum notch) on a torn scrap of glossy pepper leaf (ovate, entire margin, pointed tip, ragged torn
-- end, midrib + pinnate veins curving to the tip, V-fold light, cool reflected edge, AO + contact shadow under each
-- seed). The right seed has germinated: pale hooked stem, two long narrow cotyledons and the first true leaf, a
-- small pointed ovate leaf with a midrib (the bell-pepper leaf shape).
-- quirk: a little curled sliver of glossy purple pepper skin lies beside the seeds.
local NAME = "bell-pepper-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local SEED = { "#6a4a2e", "#9c7646", "#c49e62", "#e2c486", "#f4deaa", "#fff0c8" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local PUR = { "#2a1236", "#461e5c", "#672a82", "#8c3aa8", "#b25ec8", "#da9ae8" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle, notch side (1-2 px of air between them)
local seeds = { { 20, 45, 4.1, 3.2, -0.4, 1 }, { 30.5, 46, 4.2, 3.3, 0.3, -1 }, { 41, 44, 3.9, 3.1, -0.2, -1 } }
for _, s in ipairs(seeds) do s.m, s.hx, s.hy = A.kidney(s[1], s[2], s[3], s[4], s[5], s[6]) end

-- leaf scrap: blunt torn end at A (right), long pointed tip at B (left)
local AX, AY, CX, CY, BX, BY = 57, 45, 34, 38, 8, 50
local lm, ln, LT, LS, len = A.blade(AX, AY, CX, CY, BX, BY, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.2 * sin(pi * (0.32 + 0.68 * t)) ^ 0.85)
end, { fold = 0.45 })
-- ragged tear across the blunt end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local d = LT[k] * len
  local s = LS[k]
  local jag = 0.8 + 2.8 * X.hash(floor((s + 1) * 3.5), 7, 11) + (s > 0.4 and 1.2 or 0)
  if d < jag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- a small torn notch on the lower margin
lm:cut(HP.ellipse(47, 52, 1.6, 1.6))

-- quirk: curled sliver of purple pepper skin lying on the leaf near the torn end
local qm, qn, QT, QS = A.tube({ { 47, 49 }, { 49, 46 }, { 53, 46 }, { 54, 49 } }, function(t) return 1.2 + sin(pi * t) * 0.6 end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, qm, 1, -1) A.cast(bias, lm, qm, 1, 1, -1)

local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.22, 0.4, 0.58, 0.76, 0.92 }, amb = 0.08, wrap = 0.3 })
-- midline / perpendicular of the blade (for explicit veins)
local function Q(t) local u = 1 - t return u*u*AX + 2*u*t*CX + t*t*BX, u*u*AY + 2*u*t*CY + t*t*BY end
local function W(t) return 7.2 * sin(pi * (0.32 + 0.68 * t)) ^ 0.85 end
local function vput(x, y, lit)
  x, y = floor(x + 0.5), floor(y + 0.5)
  local k = K(x, y)
  if lm:has(x, y) and not bias[k] then c:put(x, y, lit and LEAF[4] or LEAF[2], ltok) end
end
-- pinnate laterals: from the midrib, sweeping out toward the tip
for _, t0 in ipairs{ 0.16, 0.32, 0.48, 0.64, 0.78 } do
  for _, side in ipairs{ -1, 1 } do
    for j = 1, 14 do
      local f = j / 14
      local t = t0 + f * 0.11
      local x, y = Q(t)
      local x2, y2 = Q(t + 0.01)
      local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
      local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
      local off = side * f * W(t) * 0.8
      vput(x + px * off, y + py * off, side < 0)
    end
  end
end
-- midrib
for i = 4, 92 do local x, y = Q(i / 100) local xi, yi = floor(x + .5), floor(y + .5)
  if lm:has(xi, yi) and not bias[K(xi, yi)] then c:put(xi, yi, VEIN, ltok) end
  if lm:has(xi, yi + 1) and not bias[K(xi, yi + 1)] and not lm:edge():has(xi, yi + 1) then c:put(xi, yi + 1, LEAF[3], ltok) end
end
-- cool reflected light on the lower-right margin, paler torn edge
local le = lm:edge()
le:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.66 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, COOL, ltok)
  elseif LT[k] * len < 5 then c:put(x, y, LEAF[5], ltok)
  elseif LS[k] < -0.6 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, LEAF[6], ltok) end
end)

-- pepper skin curl: glossy purple outside, pale flesh on the cut inner edge
local qtok = { r = { name = "skin" } }
local qidx = A.shade(c, qm, qn, PUR, { amb = 0.1, wrap = 0.3, cuts = CUTS, tok = qtok })
qm:each(function(x, y) local k = K(x, y) if QS[k] > 0.55 then c:put(x, y, "#e8d8c8", qtok) end end)
c:put(49, 46, "#fbeeff", qtok) c:put(50, 45, PUR[6], qtok)

-- sprout: stem from the right seed, hooked slightly, then cotyledons + first true leaf
local stok = { r = { name = "stem" } }
local sp = { { 41, 44 }, { 43, 36 }, { 40, 29 }, { 41, 22 } }
local sm, sn = A.tube(sp, function(t) return 1.1 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by, wmax, pw)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, wmax * sin(pi * min(1, t * 0.92 + 0.08)) ^ pw)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m, n, T, S
end
local cl = blade(40, 22, 33, 17, 26, 19, 2.3, 0.7)
local cr = blade(42, 22, 49, 17, 56, 18, 2.3, 0.7)
-- first true leaf: ovate, pointed, petiole up from the node (pepper leaf shape)
for y = 18, 21 do c:put(41, y, STEM[3], stok) end
local tm, tn, TT, TS = A.blade(41, 18, 38, 13, 42, 7, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 3.6 * sin(pi * min(1, t ^ 0.8 * 0.95 + 0.05)) ^ 0.9)
end, { fold = 0.35 })
tm:cut(cl):cut(cr)
A.toneN(c, tm, tn, LEAF, { tok = ltok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.13 and TT[k] > 0.05 and TT[k] < 0.88 then c:put(x, y, TS[k] <= 0 and VEIN or LEAF[3], ltok)
  elseif abs(TS[k]) > 0.3 and abs(TS[k]) < 0.6 and (floor(TT[k] * 5 + abs(TS[k]) * 2) % 2 == 0) and TT[k] > 0.15 and TT[k] < 0.75 and TS[k] > 0 then
    c:put(x, y, LEAF[2], ltok) end
end)

-- seeds last: flat discs with a thick rim, dished centre, hilum notch, contact AO between neighbours
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local n, d = X.pillow(s.m, 1.6)
  local sb = {}
  s.m:each(function(x, y) local k = K(x, y) if d[k] and d[k] >= 1.4 then sb[k] = -1 end end)
  local idx = A.shade(c, s.m, n, SEED, { amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = sb, tok = tok })
  -- shade crescent on the lower-right rim (seed thickness)
  s.m:edge():each(function(x, y) local nn = n[K(x, y)] if nn[1] + nn[2] > 0.7 then c:put(x, y, SEED[2], tok) end end)
  -- hilum: dark notch pixel + tiny pale beak
  local hx, hy = floor(s.hx + 0.5), floor(s.hy + 0.5)
  if s.m:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
    if s.m:has(hx + d[1], hy + d[2]) and idx[K(hx + d[1], hy + d[2])] and idx[K(hx + d[1], hy + d[2])] > 3 then c:put(hx + d[1], hy + d[2], SEED[3], tok) end end
  -- rim highlight on the upper-left
  s.m:edge():each(function(x, y) local k = K(x, y) local nn = n[k]
    if nn[1] + nn[2] < -0.75 then c:put(x, y, SEED[6], tok) end end)
end

A.save(c, NAME)

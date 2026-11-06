-- naupaka-seed (final, Opus single pass). Three corky, ribbed cream-tan naupaka seeds on a torn scrap of fleshy,
-- waxy naupaka leaf (obovate blade, pale midrib, faint pinnate veins, pale torn flesh, cool reflected edge, AO and
-- contact shadow under each seed). The right seed has sprouted: pale stem, two oval cotyledons and a first
-- spoon-shaped true leaf, the naupaka beach-leaf shape.
-- quirk: a tiny naupaka half-flower already blooms by the sprout, all five petals fanned to one side.
local NAME = "naupaka-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC25_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1b4734", "#28663f", "#3d8945", "#5fab4c", "#8ccb5c", "#c3e786" }
local VEIN, COOL, WAX, FLESH = "#d4efa0", "#3c7276", "#e2f5b8", "#e6f2bd"
local SEED = { "#3e2b26", "#6a4b36", "#98734e", "#c09c6c", "#ddc391", "#f3e5ba" }
local STEM = { "#3f6e44", "#5f9a58", "#8cc06c", "#bcdc94", "#e2f2bc" }
local PET = { "#a891cf", "#d9cdef", "#f6f1fb" }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 17, 47, 4.3, 2.9, -0.25 }, { 27, 44, 4.1, 2.8, 0.3 }, { 40, 41, 3.7, 2.8, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- leaf scrap: obovate fleshy blade on the diagonal, torn across its wide end
local lm, ln, LT, LS, len = A.blade(6, 54, 30, 52, 57, 37, function(t)
  if t > 0.99 then return -1 end
  if t < 0.6 then return max(0.6, 8.8 * (t / 0.6) ^ 0.75) end
  return 8.8
end, { fold = 0.3 })
local torn = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.06 * X.hash(floor(LS[k] * 6), 1, 5) + 0.03 * LS[k]
  if LT[k] > lim then torn:set(x, y) end
  -- small bite-shaped tear on the upper margin
  if LS[k] < -0.72 and LT[k] > 0.46 and LT[k] < 0.53 then torn:set(x, y) end
end)
lm:cut(torn)
local tear = lm:copy():cut(lm:copy():shift(-1, 0)):add(lm:copy():cut(lm:copy():shift(-1, 1)))
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / 6
  local f = ph - floor(ph)
  if f < 0.16 and abs(s) > 0.18 and abs(s) < 0.75 and t > 0.12 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) return end
  -- waxy bloom: short pale sheen strokes on the lit half
  if s < -0.3 and s > -0.6 and t > 0.25 and t < 0.7 and (floor(t * len) % 7 == 2) then c:put(x, y, WAX, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.12 and LT[k] < 0.78 then c:put(x, y, COOL, ltok) end end)
-- pale torn flesh along the rip
lm:each(function(x, y) if torn:grow(1):has(x, y) and not bias[K(x, y)] then c:put(x, y, FLESH, ltok) end end)
for _, q in ipairs{ { 6, 55, 3 }, { 5, 56, 2 }, { 4, 57, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout stem
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 40, 39 }, { 41, 32 }, { 38, 25 }, { 39, 18 } }, function(t) return 1.1 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3 })
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function blade(ax, ay, cx, cy, bx, by, wfn, mid)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, wfn, { fold = 0.3 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  if mid then m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end) end
  return m, idx
end
-- oval cotyledons
local cot = function(t) if t > 0.98 then return -1 end return max(0.5, 2.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6) end
local cl = blade(39, 30, 33, 27, 27, 28, cot, false)
local cr = blade(40, 28, 46, 25, 52, 26, cot, false)
-- spoon-shaped (obovate) true leaf
local tl = blade(39, 19, 41, 13, 46, 6, function(t)
  if t > 0.99 then return -1 end
  if t < 0.66 then return max(0.6, 4.3 * (t / 0.66) ^ 0.9) end
  local u = (t - 0.66) / 0.34
  return max(0.6, 4.3 * sqrt(max(0, 1 - u * u)) ^ 0.7)
end, true)

-- quirk: naupaka half-flower on a thread of pedicel, petals all to the left
local ftok = { r = { name = "flower" } }
A.poly1(c, { { 38, 22 }, { 36, 20 }, { 34, 18 } }, STEM[3], stok)
local fx, fy = 32, 16
for i, a in ipairs{ -90, -135, 180, 135, 90 } do
  local r = a * pi / 180
  local ux, uy = cos(r), sin(r)
  local pm = A.rell(fx + ux * 2.6, fy + uy * 2.6, ux, uy, 2.1, 0.9)
  pm:each(function(x, y)
    local lit = (x - fx) * -0.6 + (y - fy) * -0.8
    c:put(x, y, lit > 0.5 and PET[3] or lit > -1.2 and PET[2] or PET[1], ftok)
  end)
  c:put(floor(fx + ux * 2.4 + .5), floor(fy + uy * 2.4 + .5), "#9b6cc6", ftok)
end
c:put(fx, fy, "#f5b82e", ftok) c:put(fx + 1, fy, "#d98322", ftok)

-- seeds last: corky body with three ribs along the length, AO where they touch
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, 0) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = flip * (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(u) < 0.8 and (abs(v - 0.05) < 0.14 or abs(abs(v) - 0.55) < 0.12) then
      c:put(x, y, SEED[max(1, (idx[k] or 3) - 2)], tok)
    elseif abs(u) < 0.6 and v > -0.45 and v < -0.2 then
      c:put(x, y, SEED[min(6, (idx[k] or 3) + 1)], tok)
    end
  end)
end
-- cork pore pits and one glint
c:put(15, 46, SEED[6], { r = { name = "seed1" } })
-- radicle: a little cream root tip poking out under the sprouting seed
A.poly1(c, { { 42, 44 }, { 44, 46 }, { 45, 47 } }, function(x, y, i, f) return f < 0.5 and "#f0e6c8" or "#cdbf9c" end, { r = { name = "root" } })

A.save(c, NAME)

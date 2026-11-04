-- melon-seed (final pass, Opus, replaces Sonnet draft). Three flat ivory melon seeds (teardrop ovals, lit per pixel,
-- pale lit rim, lengthwise keel, darker pointed end) on a torn scrap of rough melon leaf: three rounded palmate
-- lobes, veins fanning from the petiole stub, hairy pale specks, a fibrous torn edge, AO + contact shadow under each
-- seed. The right seed has germinated: pale stem, two oblong smooth cotyledons and a first true leaf with five
-- rounded lobes (the melon leaf in small), plus a tiny white root.
-- quirk: a fleck of orange melon flesh is still stuck to the left seed.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "melon-seed"
local c = A.new(NAME)

local LEAF = { "#1b3a33", "#28583c", "#3a7844", "#57984c", "#7fb65a", "#acd27a" }
local SEED = { "#5a4636", "#866c52", "#b09a78", "#d6c49c", "#eee1bc", "#fdf6e0" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local TORN, HAIR, ROOT = "#cfc58e", "#c4dc94", "#f4eedc"
local FLESH = { "#dc7630", "#fbb866" }
local ltok, stok = { r = { name = "leaf" } }, { r = { name = "stem" } }

-- seeds: cx, cy, angle (tip end along +u)
local seeds = { { 21, 46, 0.35 }, { 30, 50, -0.12 }, { 38, 44, -0.45 } }
local RX, RY = 4.8, 2.2
for _, s in ipairs(seeds) do
  local om, on = A.oval(s[1], s[2], RX, RY, s[3], 0.7)
  local ca, sa = cos(s[3]), sin(s[3])
  local m = HP.mask()
  om:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (RX + 0.45), (-dx * sa + dy * ca) / (RY + 0.45)
    local w = sqrt(max(0, 1 - u * u)) * (1 - 0.32 * max(0, u))
    if abs(v) <= w + 0.05 then m:set(x, y) end
  end)
  s.m, s.n = m, on
end

-- leaf scrap: three rounded lobes, torn across the top
local lm = A.ell(20, 47, 10, 6.5):add(A.ell(32, 50, 11, 5.5)):add(A.ell(44, 45, 8, 6.5))
local function tear(x) return 39.5 - (x - 10) * 0.12 + ((x * 7) % 5 - 2) * 0.55 + (X.hash(x, 1, 4) - 0.5) * 1.2 end
local rm = {}
lm:each(function(x, y) if y < tear(x) then rm[#rm + 1] = K(x, y) end end)
for _, k in ipairs(rm) do lm.s[k] = nil end
local ln = X.pillow(lm, 3.2)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.shade(c, lm, ln, LEAF, { tok = ltok, bias = bias, cuts = { 0.12, 0.28, 0.45, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
-- palmate veins fanning from the petiole stub at the lower left
local ox, oy = 11, 53
for _, ang in ipairs{ -0.15, -0.42, -0.7, 0.12 } do
  local ux, uy = cos(ang), sin(ang)
  for i = 2, 40 do
    local x, y = floor(ox + ux * i + 0.5), floor(oy + uy * i * 0.75 + 0.5 - (ang < 0 and i * 0.05 or 0))
    local k = K(x, y)
    if lm:has(x, y) and not bias[k] then
      c:put(x, y, (lidx[k] or 3) >= 4 and LEAF[6] or LEAF[4], ltok)
      if i % 6 == 3 then -- side veinlets
        local qx, qy = x + 1, y + (ang < 0 and 1 or -1)
        if lm:has(qx, qy) and not bias[K(qx, qy)] then c:put(qx, qy, LEAF[min(6, max(2, (lidx[K(qx, qy)] or 3) + 1))], ltok) end
      end
    end
  end
end
-- rough hairs: sparse pale specks on lit areas
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and (lidx[k] or 0) >= 4 and X.hash(x, y, 21) > 0.93 then c:put(x, y, HAIR, ltok) end end)
-- fibrous torn edge
lm:edge():each(function(x, y) if not lm:has(x, y - 1) and y < tear(x) + 2.5 then c:put(x, y, TORN, ltok) end end)
-- petiole stub
for _, p in ipairs{ { 10, 54, 3 }, { 9, 55, 2 }, { 11, 54, 4 } } do c:put(p[1], p[2], LEAF[p[3]], ltok) end

-- sprout (from the tip of the right seed)
local sp = { { 41, 42 }, { 42, 37 }, { 40, 32 }, { 40, 25 } }
local sm, sn = A.tube(sp, function() return 1.1 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3 })
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, 2.4 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.45)
  end, { fold = 0.25 })
  m:cut(sm)
  A.shade(c, m, n, LEAF, { tok = ltok, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.13 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local c1 = cot(39, 27, 34, 27, 29, 24)
local c2 = cot(41, 27, 46, 27, 51, 24)
-- first true leaf: five rounded lobes
local tl = A.ell(40, 18.5, 3.6, 3.2):add(A.ell(36.5, 17.5, 2.1, 1.9)):add(A.ell(43.5, 17.5, 2.1, 1.9))
  :add(A.ell(38, 15, 1.9, 1.9)):add(A.ell(42, 15, 1.9, 1.9))
tl:cut(sm)
local tidx = A.shade(c, tl, X.pillow(tl, 1.8), LEAF, { tok = ltok, amb = 0.14, wrap = 0.3 })
for _, v in ipairs{ { { 40, 22 }, { 40, 15 } }, { { 40, 21 }, { 37, 18 } }, { { 40, 21 }, { 43, 18 } } } do
  A.stroke(c, v, LEAF[5], ltok)
end
c:put(40, 22, STEM[2], stok) c:put(40, 23, STEM[2], stok) c:put(40, 24, STEM[3], stok)
-- tiny root out of the seed's tip, down-right
for _, p in ipairs{ { 43, 44 }, { 44, 45 }, { 44, 46 }, { 45, 47 } } do c:put(p[1], p[2], ROOT, stok) end

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  for j = i + 1, #seeds do X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local ca, sa = cos(s[3]), sin(s[3])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.2, wrap = 0.35, cuts = { 0.2, 0.36, 0.52, 0.68, 0.82 } })
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (RX + 0.45), flip * (-dx * sa + dy * ca) / (RY + 0.45)
    local id = idx[k] or 3
    if abs(v) < 0.18 and abs(u) < 0.6 then c:put(x, y, SEED[max(1, id - 1)], tok) end   -- keel groove
    if u > 0.62 then c:put(x, y, SEED[max(1, id - 1)], tok) end                         -- darker pointed tip
    if v < -0.55 and u > -0.7 and u < 0.4 then c:put(x, y, SEED[min(6, id + 1)], tok) end -- lit rim
  end)
end
-- glint on the front seed
c:put(28, 49, SEED[6], { r = { name = "seed2" } })
-- quirk: flesh fleck on the left seed
c:put(19, 45, FLESH[1], { r = { name = "seed1" } }) c:put(20, 45, FLESH[2], { r = { name = "seed1" } })
c:put(19, 46, FLESH[1], { r = { name = "seed1" } })

A.save(c, NAME)

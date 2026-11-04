-- lingonberry-seed (final, Opus single pass). Three tiny crescent lingonberry seeds (red-brown, pitted coat, one
-- glint) on a torn scrap of lingonberry leaf: leathery, glossy, rolled pale rim, midrib + faint veins, dark gland
-- dots, ragged tear on the right end. The front seed has sprouted: a reddish wiry stem, two round cotyledons and
-- alternate small elliptic glossy leaves (the lingonberry leaf shape), plus a pale root over the leaf edge.
-- quirk: a fleck of red berry pulp is still stuck to the left seed.
local NAME = "lingonberry-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local abs, max, min, sqrt, floor, sin, cos, pi = math.abs, math.max, math.min, math.sqrt, math.floor, math.sin, math.cos, math.pi
local c = A.new(NAME)

local LEAF = { "#14352e", "#1d4f3a", "#2a6b42", "#3f8a48", "#62a852", "#93c868" }
local RIM, COOL, GLAND = "#b7d98a", "#2f5f66", "#16402f"
local SEED = { "#3a1c1e", "#5e2a24", "#86402c", "#ac5e38", "#cf8650", "#efb87a" }
local STEM = { "#4a1c2c", "#6e2a34", "#94403e", "#b85a4a" }
local SPR  = { "#1d4a36", "#2f6a40", "#4c8e48", "#74b156", "#a6d474", "#d6f0a0" }
local RUBY = { "#5e132f", "#b5283b", "#ff8466" }
local ROOT = { "#b8a07a", "#e2d2a8" }

-- leaf scrap: broad elliptic lingonberry leaf on the diagonal, torn off on the right end
local lm, ln, LT, LS, len = A.blade(8, 53, 28, 52, 52, 41, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 9.2 * sin(pi * min(1, t * 0.82 + 0.06)) ^ 0.6)
end, { fold = 0.3 })
-- ragged tear: remove the end past a zigzag line
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local z = 0.74 + 0.05 * ((floor((s + 1) * 4.5) % 2 == 0) and 1 or -1) + 0.03 * s
  if LT[k] > z then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
-- small tear nick in the upper edge
for _, p in ipairs{ { 22, 45 }, { 23, 45 }, { 23, 46 } } do lm.s[K(p[1], p[2])] = nil end

-- seeds: cx, cy, rx, ry, angle (crescents: an oval with a bite on one side)
local seeds = { { 19, 50, 3.0, 1.8, -0.35 }, { 27, 48, 3.0, 1.8, 0.5 }, { 36, 45, 3.1, 1.9, -0.2 } }
for i, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8)
  local ca, sa = cos(s[5]), sin(s[5])
  -- crescent bite on the lower side, toward one end
  local bx, by = s[1] + 1.6 * ca - 2.2 * sa, s[2] + 1.6 * sa + 2.2 * ca
  s.m:cut(c:ellipse(bx, by, 1.4, 1.2))
end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
-- midrib, faint veins, gland dots, rolled pale rim on the lit edge, cool reflected rim on the shade edge
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and RIM or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5) / 6.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.08 and t < 0.7 then c:put(x, y, A.step(LEAF, lidx[k], s < 0 and 1 or -1), ltok) end
  if X.hash(x, y, 7) > 0.93 and abs(s) > 0.25 and abs(s) < 0.8 then c:put(x, y, GLAND, ltok) end
end)
local ledge = lm:edge()
ledge:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] < -0.6 and LT[k] < 0.72 then c:put(x, y, LEAF[6], ltok)
  elseif LS[k] > 0.6 and LT[k] < 0.72 then c:put(x, y, COOL, ltok) end
end)
-- torn edge: pale exposed fibre pixels along the tear
ledge:each(function(x, y) local k = K(x, y) if LT[k] > 0.66 and abs(LS[k]) < 0.85 and (x + y) % 2 == 0 then c:put(x, y, "#a8c88a", ltok) end end)
-- glossy spec on the leaf
c:put(14, 48, "#e4f4b0", ltok) c:put(15, 48, "#e4f4b0", ltok)
-- petiole stub
for _, q in ipairs{ { 7, 54, 2 }, { 6, 55, 2 }, { 5, 56, 1 } } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- root from the sprouting seed, over the lower leaf edge
local rtok = { r = { name = "root" } }
local root = A.seg(nil, 38, 47, 40, 51) A.seg(root, 40, 51, 41, 55)
root:each(function(x, y) c:put(x, y, ROOT[(y < 51) and 2 or 1], rtok) end)
c:put(42, 55, ROOT[1], rtok)
root:shift(1, 0):each(function(x, y) if lm:has(x, y) and not root:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- sprout stem (reddish, wiry), slight S curve
local stok = { r = { name = "stem" } }
local sp = { { 36, 44 }, { 35, 36 }, { 37, 28 }, { 35, 18 } }
local sm, sn = A.tube(sp, function(t) return 0.6 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- leaves: elliptic, rounded tip, glossy, midrib; (base x,y, direction angle, length, half width)
local ptok = { r = { name = "sprout" } }
local function leaf(x, y, ang, L, W, fold)
  local ux, uy = cos(ang), sin(ang)
  local bx, by = x + ux * L, y + uy * L
  local m, n, T, S = A.blade(x, y, (x + bx) / 2, (y + by) / 2, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.3, W * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.55)
  end, { fold = fold or 0.35 })
  m:cut(sm)
  local idx = A.shade(c, m, n, SPR, { tok = ptok, amb = 0.14, wrap = 0.3 })
  m:each(function(px, py) local k = K(px, py)
    if abs(S[k]) < 0.15 and T[k] > 0.12 and T[k] < 0.85 then c:put(px, py, S[k] <= 0 and SPR[5] or SPR[2], ptok) end end)
  -- gloss: one bright pixel on the lit half
  local best, gx, gy
  m:each(function(px, py) local k = K(px, py) if S[k] < -0.2 and idx[k] and (not best or idx[k] > best or (idx[k] == best and T[k] > 0.3 and T[k] < 0.6)) then best, gx, gy = idx[k], px, py end end)
  if gx then c:put(gx, gy, SPR[6], ptok) end
  return m
end
-- cotyledons (round, low)
leaf(35, 37, pi + 0.35, 5.5, 2.2, 0.25)
leaf(36, 37, -0.3, 5.5, 2.2, 0.25)
-- alternate true leaves
leaf(35, 31, pi + 0.45, 10, 2.9)
leaf(36, 25, -0.4, 10, 2.9)
leaf(35, 20, pi + 0.8, 7, 2.4)
-- terminal bud
local bud = c:ellipse(35, 16, 1, 1.6)
bud:each(function(x, y) c:put(x, y, (y <= 15) and SPR[5] or SPR[3], ptok) end)

-- seeds last: pitted red-brown coat, AO between neighbours, one glint on the front seed
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, amb = 0.1, wrap = 0.2, cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 } })
  vis:each(function(x, y) local k = K(x, y)
    if X.hash(x, y, 3 + i) > 0.78 and idx[k] > 2 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
end
c:put(35, 44, SEED[6], { r = { name = "seed3" } })
-- quirk: berry pulp fleck stuck on the left seed
local qt = { r = { name = "pulp" } }
c:put(19, 48, RUBY[2], qt) c:put(20, 48, RUBY[2], qt) c:put(20, 49, RUBY[1], qt) c:put(19, 48, RUBY[3], qt)

A.save(c, NAME)

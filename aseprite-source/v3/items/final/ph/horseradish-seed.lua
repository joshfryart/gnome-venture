-- horseradish-seed (final, Opus single pass). Three small round red-brown brassica seeds on a torn scrap of wavy
-- horseradish leaf (crinkled margin, midrib + side veins, ragged torn end, cool shade edge, AO + contact shadow under
-- each seed). The right seed has germinated: a white root tip, pale stem, two notched heart-shaped brassica cotyledons
-- and a first true leaf that is the long, wavy-edged horseradish leaf in miniature.
-- quirk: a single dewdrop is balanced on the new true leaf.
local NAME = "horseradish-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local L = A.LEAF
local SEED = { "#3a1f22", "#5c2e2a", "#84452f", "#a8643c", "#c98a52", "#ecc08a" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local DEW = { "#3a86b0", "#5fc4c8", "#b6f0e0", "#fff4d6" }

local seeds = { { 17, 48, 2.7, 2.3, 0.3 }, { 25, 46, 2.6, 2.3, -0.4 }, { 37, 44, 2.7, 2.4, 0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
local allSeeds = HP.mask() for _, s in ipairs(seeds) do allSeeds:add(s.m) end

-- leaf scrap with crinkled margin and a ragged torn right end
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 41, 56, 47, function(t)
  if t > 0.985 then return -1 end
  local w = 8.4 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.55
  return max(0.6, w * (0.9 + 0.1 * abs(sin(t * 22))))
end, { fold = 0.36 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.8 + 0.07 * sin(LS[k] * 11) + 0.03 * X.hash(x, y, 3) then cut[#cut + 1] = k end end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(lm and c, lm, ln, L, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and "#c2e48c" or L[3], ltok) return end
  local ph = (t * len - abs(s) * 4.0) / 5.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.75 then c:put(x, y, s < 0 and L[6] or L[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.1 and LT[k] < 0.78 then c:put(x, y, "#3a6c72", ltok) end
  -- torn end: pale fibrous edge
  if LT[k] > 0.74 and not lm:has(x + 1, y) then c:put(x, y, L[6], ltok) end
end)
for _, q in ipairs{ { 6, 53, 3 }, { 5, 54, 3 }, { 4, 55, 2 } } do c:put(q[1], q[2], L[q[3]], ltok) end

-- white root tip from the sprouting seed, down-right over the leaf
local rp = { { 39, 46 }, { 41, 48 }, { 43, 49 }, { 46, 50 } }
local rm, rn = A.tube(rp, function(t) return 1.1 * (1 - t) + 0.3 end)
rm:cut(seeds[3].m)
local rtok = { r = { name = "radicle" } }
A.shade(c, rm, rn, { "#9a8c7a", "#c8bca4", "#ece4cc", "#fff4d6" }, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok, amb = 0.2 })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not allSeeds:has(x, y) then c:put(x, y, L[1], ltok) end end)

-- sprout
local stok = { r = { name = "stem" } }
local sp = { { 37, 42 }, { 35, 36 }, { 35, 30 }, { 35, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15, wrap = 0.3 })
-- true leaf (behind cotyledons): long, wavy horseradish leaf
local tl, TT, TS = A.wavyLeaf(c, { 35, 24 }, { 34, 16 }, { 39, 7 }, 3.0, { pet = 0.18, freq = 40, wave = 0.55, per = 3.4, tok = ltok })
-- cotyledons: notched heart / kidney shapes on short petioles
local function coty(cx, cy, dir)
  local m = A.rell(cx, cy, 1, -0.25 * dir, 3.8, 2.5)
  m:set(floor(cx + dir * 4.2 + .5), floor(cy + .5))
  m:cut(A.rell(cx + dir * 4.0, cy - 0.3, 1, 0, 1.0, 0.6))          -- notch at the tip
  local n = X.pillow(m, 1.8)
  local idx = A.shade(c, m, n, L, { tok = ltok, amb = 0.14, wrap = 0.3, cuts = A.CUTS })
  for i = 1, 3 do c:put(floor(cx - dir * 3 + dir * i * 1.4 + .5), floor(cy + .5), dir < 0 and L[6] or L[5], ltok) end
  return m
end
A.line(c, { { 34, 25 }, { 32, 24 } }, STEM[2], stok) A.line(c, { { 36, 25 }, { 38, 24 } }, STEM[2], stok)
local cl = coty(28.5, 23.5, -1)
local cr = coty(42.5, 22.5, 1)
A.sep(c, cl, tl, L[2], ltok) A.sep(c, cr, tl, L[2], ltok)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, amb = 0.1, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
  local bx, by = A.specAt(s.m, s.n, 30)
  c:put(bx, by, A.CREAM, tok)
  -- hilum: small dark notch lower-right
  local hx, hy = floor(s[1] + 1.6 + .5), floor(s[2] + 1.4 + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, SEED[1], tok) end
  -- fine net texture on the coat
  s.m:each(function(x, y) if X.hash(x, y, i) < 0.12 and (idx[K(x, y)] or 1) >= 3 and not (x == bx and y == by) then c:put(x, y, SEED[idx[K(x, y)] - 1], tok) end end)
end
-- seed-coat husk still clinging to the sprout's stem base: two dark pixels
c:put(36, 41, SEED[2]) c:put(37, 41, SEED[3])

-- quirk: dewdrop on the true leaf
local dx, dy = 37, 13
local dm = HP.mask():set(dx, dy):set(dx + 1, dy):set(dx - 1, dy + 1):set(dx, dy + 1):set(dx + 1, dy + 1):set(dx + 2, dy + 1)
  :set(dx - 1, dy + 2):set(dx, dy + 2):set(dx + 1, dy + 2):set(dx + 2, dy + 2):set(dx, dy + 3):set(dx + 1, dy + 3)
dm:each(function(x, y) c:put(x, y, (y >= dy + 2 and x >= dx + 1) and DEW[1] or DEW[2]) end)
c:put(dx, dy, DEW[3]) c:put(dx - 1, dy + 1, DEW[3]) c:put(dx, dy + 1, DEW[4]) c:put(dx + 2, dy + 2, DEW[3])
c:put(dx, dy + 4, L[1]) c:put(dx + 1, dy + 4, L[1])

A.save(c, NAME)

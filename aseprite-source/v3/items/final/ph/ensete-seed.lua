-- ensete-seed (final, Opus single pass). Three big, hard, glossy near-black enset seeds (irregular rounded, each with a
-- pale ring-shaped hilum) on a torn strip of enset leaf: parallel slanted veins, a red midrib along the lower edge, both
-- ends shredded along the veins the way banana-family leaves tear. AO + contact shadow under each seed. The middle seed
-- has germinated: a pale root on the leaf, a reddish swollen base and a slim stem carrying a rolled leaf and a first
-- little paddle leaf with a red midrib and side veins (the plant's own leaf shape).
-- quirk: a single dewdrop sits on the paddle leaf.
local NAME = "ensete-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173a3a", "#1f5446", "#2c714d", "#459052", "#6eb05c", "#a3cf78" }
local RED  = { "#3a1828", "#5a1f33", "#80283c", "#a83a45", "#cb5f55", "#e8907a" }
local SEED = { "#120a12", "#22131c", "#36202a", "#50323a", "#74504e", "#a0807a" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local HIL, HILD, ROOT = "#d6b88a", "#8a6a4a", "#efe6c6"
local SEA = { "#3a86b0", "#8fd8e0", "#e4fbf6" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, ang
local seeds = { { 18, 47, 4.0, 3.3, 0.4 }, { 30, 45, 4.3, 3.5, -0.2 }, { 42, 42, 3.8, 3.2, 0.9 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf strip (diagonal), shredded ends
local lm, ln, LT, LS, len = A.blade(6, 52, 30, 50, 57, 41, function(t) return t > 0.995 and -1 or 6.4 end, { fold = 0.22 })
local VP = 2.4
local function strand(k) return floor((LT[k] * len + LS[k] * 6.4 * 0.9) / VP) end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local st = strand(k)
  local d0 = LT[k] * len
  local lo = 1.5 + 6 * X.hash(st, 1, 21)
  local hi = len - 1.5 - 6 * X.hash(st, 2, 22)
  if d0 < lo or d0 > hi then cut[#cut + 1] = k end
  -- one split along a vein on the upper edge
  if LS[k] < -0.35 and abs(LT[k] * len + LS[k] * 6.4 * 0.9 - 15.5) < 0.5 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  if s > 0.62 and s < 0.86 then c:put(x, y, (s < 0.74) and RED[5] or RED[3], ltok) return end
  if s >= 0.86 then c:put(x, y, LEAF[2], ltok) return end
  local ph = (LT[k] * len + s * 6.4 * 0.9) / VP
  if ph - floor(ph) < 0.3 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)

-- root of the sprouting seed, lying on the leaf
local rtok = A.tok("root")
local rpts = { { 32, 48 }, { 34, 50 }, { 37, 51 }, { 40, 51 } }
for i = 0, 20 do local x, y = A.bez(rpts, i / 20) c:put(floor(x + .5), floor(y + .5), i < 14 and ROOT or HIL, rtok) end
for _, p in ipairs{ { 33, 50 }, { 36, 52 }, { 39, 52 } } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

-- sprout: swollen reddish base, stem, rolled leaf, paddle leaf
local stok = A.tok("stem")
local sp = { { 30, 42 }, { 30, 35 }, { 28, 29 }, { 29, 23 } }
local sm, sn = A.tube(sp, function(t) return t < 0.18 and 1.9 - t * 4 or 1.1 end)
sm:cut(seeds[2].m)
local si = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
sm:each(function(x, y) if y > 37 then c:put(x, y, ((si[K(x, y)] or 1) >= 3) and RED[5] or RED[3], stok) end end)
local roll = A.tok("roll")
local rm, rn = A.tube({ { 29, 24 }, { 28, 20 }, { 26, 17 }, { 24, 14 } }, function(t) return 1.2 * (1 - t) + 0.5 end)
rm:cut(sm)
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = roll })
local ptok = A.tok("paddle")
local pm, pn, PT, PS, plen = A.blade(30, 24, 36, 12, 49, 10, function(t)
  if t < 0.12 then return 0.8 end
  local u = (t - 0.12) / 0.88
  local w = 4.0 * min(1, u / 0.25) ^ 0.6
  if u > 0.82 then w = w * sqrt(max(0, (1 - u) / 0.18)) end
  return u > 0.995 and -1 or max(0.8, w)
end, { fold = 0.3 })
pm:cut(sm):cut(rm)
local pb = {} X.ao(pb, pm, rm, 1, -1)
A.toneN(c, pm, pn, LEAF, { tok = ptok, cuts = CUTS, amb = 0.14, wrap = 0.3, bias = pb })
pm:each(function(x, y) local k = K(x, y) local t, s = PT[k], PS[k]
  if pb[k] then return end
  if t < 0.13 then c:put(x, y, s <= 0 and STEM[3] or STEM[2], ptok) return end
  if abs(s) < 0.15 then c:put(x, y, s <= 0 and RED[5] or RED[3], ptok) return end
  local d = (t * plen - abs(s) * 2.4) / 2.2
  if d - floor(d) < 0.3 and abs(s) < 0.85 and t < 0.93 then c:put(x, y, s < 0 and LEAF[4] or LEAF[2], ptok) end
end)
-- quirk: dewdrop on the paddle (2x2 bead + glint)
local dx, dy = 41, 13
c:put(dx, dy, SEA[2], ptok) c:put(dx + 1, dy, SEA[2], ptok) c:put(dx, dy + 1, SEA[1], ptok) c:put(dx + 1, dy + 1, SEA[2], ptok)
c:put(dx, dy - 0, SEA[3], ptok) c:put(dx + 1, dy + 2, LEAF[1], ptok) c:put(dx + 2, dy + 1, LEAF[1], ptok)

-- seeds last: glossy black, hilum ring, AO between neighbours
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  local sb = {}
  A.cast(sb, s.m, sm, 1, 1, -1)
  local idx = X.tone(c, s.m, X.light(s.n, { amb = 0.05, wrap = 0.15 }), SEED, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.86 }, bias = sb, tok = tok })
  -- cool reflected light on the lower-right rim
  s.m:edge():each(function(x, y) if (x - s[1]) + (y - s[2]) > 3.2 then c:put(x, y, "#3e3a5e", tok) end end)
  -- hilum: pale ring on the lower-left face
  local hx, hy = floor(s[1] - 1.5 + .5), floor(s[2] + 1 + .5)
  if i == 2 then hx, hy = 30, 41 end
  c:put(hx, hy, HIL, tok) c:put(hx + 1, hy, HIL, tok) c:put(hx, hy + 1, HILD, tok) c:put(hx + 1, hy + 1, HIL, tok)
  -- glossy specular: 2x1 + 1 px
  local bx, by = A.specAt(s.m, s.n, 30)
  c:put(bx, by, "#efe0dc", tok) c:put(bx + 1, by, "#efe0dc", tok) c:put(bx, by + 1, SEED[6], tok)
end
A.save(c, NAME)

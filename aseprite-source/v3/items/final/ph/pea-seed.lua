-- pea-seed (aC32_2 final, Opus single pass). Three dried pea seeds (matte sage-khaki spheres, 6 tones, one small
-- glint each, a dark hilum scar with a pale rim) heaped on a torn pea leaflet (ovate, bluish green with waxy bloom
-- flecks, midrib + swept veins, cool reflected edge, AO + contact shadow under the heap). The top seed has sprouted:
-- a pale stem with a pair of leafy stipules at the node, a first true leaf of two oval leaflets and a curling tendril
-- (the pea leaf shape).
-- quirk: the front-right seed is wrinkled, the odd one out (a nod to Mendel's wrinkled peas).
local NAME = "pea-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local full = c:rect(0, 0, 63, 63)
local LEAF = { "#18392f", "#24553e", "#367448", "#539355", "#80b56a", "#b8d88e" }
local DRY  = { "#43432a", "#626234", "#838444", "#a3a45a", "#c4c27c", "#e4dfa8" }
local STEM = { "#3c744a", "#68a65a", "#9ccf78", "#d4eeaa" }
local BLOOM, COOL = "#a9cdb8", "#3a6c72"

-- seeds (spheres): C sits on top/behind A and B
local SA = { 22, 47, 3.7 }
local SB = { 31, 48, 3.7 }
local SC = { 27, 41, 3.5 }
local function ball(S) return c:ellipse(S[1], S[2], S[3], S[3]) end
local mA, mB, mC = ball(SA), ball(SB), ball(SC)
local heap = mA:copy():add(mB):add(mC)

-- leaf scrap: a pea leaflet, base torn off on the left
local bias = {}
X.ao(bias, full, heap, 1, -1)
A.cast(bias, full, heap, 1, 2, -1)
local tearM = A.tear(full:copy(), 13, 45, -0.98, 0.2, 1.8, 17)
local ltok = { r = { name = "leaf" } }
local lm, LT, LS, lidx = A.leaf(c, 6, 43, 30, 42, 57, 53, 8.8, LEAF, { cut = tearM, bias = bias, tok = ltok, vs = 4.6, fold = 0.4,
  wfn = function(t) if t > 0.99 then return -1 end return max(0.5, 8.8 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.7) end })
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and (lidx[k] or 0) >= 4 and abs(LS[k]) > 0.25 and X.hash(x, y, 8) < 0.07 then c:put(x, y, BLOOM, ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end
  if tearM:has(x - 1, y) then c:put(x, y, (y % 2 == 0) and LEAF[5] or LEAF[4], ltok) end end)

-- sprout from seed C
local stok = { r = { name = "stem" } }
A.stem(c, { { 27, 38 }, { 26, 32 }, { 28, 26 }, { 27, 19 } }, function(t) return 1.1 - t * 0.15 end, STEM, { tok = stok })
local ctok = { r = { name = "sprout-leaf" } }
-- stipules: two leafy ears clasping the node
A.leaf(c, 26, 29, 23, 28, 20, 30, 1.9, LEAF, { tok = ctok, vs = 9, fold = 0.3, pw = 0.5 })
A.leaf(c, 28, 29, 31, 27, 34, 29, 1.9, LEAF, { tok = ctok, vs = 9, fold = 0.3, pw = 0.5 })
-- first true leaf: a pair of oval leaflets
A.leaf(c, 26, 21, 21, 17, 16, 19, 3.0, LEAF, { tok = ctok, vs = 3.2, fold = 0.4, pw = 0.6 })
A.leaf(c, 28, 21, 33, 17, 38, 19, 3.0, LEAF, { tok = ctok, vs = 3.2, fold = 0.4, pw = 0.6 })
c:put(26, 22, STEM[1], stok) c:put(28, 22, STEM[1], stok)
-- tendril from the tip, curling right
for _, p in ipairs{ { 27, 18 }, { 27, 17 }, { 28, 16 }, { 28, 15 }, { 29, 14 } } do c:put(p[1], p[2], STEM[3], stok) end
for _, p in ipairs(A.spiral(32, 12, pi * 0.9, 2.8, -0.1, 22, 1)) do c:put(p[1], p[2], p[2] > 12 and STEM[2] or STEM[3], stok) end

-- seeds: C first (behind), then A and B over it
local function pea(S, m, tok, o)
  o = o or {}
  local b = {}
  for _, other in ipairs(o.over or {}) do X.ao(b, m, other, 1, -1) end
  local vis = m:copy()
  for _, other in ipairs(o.under or {}) do vis:cut(other) end
  local n = X.sphere(S[1] - 0.5, S[2] - 0.6, S[3] + 0.4, m)
  local idx = A.shade(c, vis, n, DRY, { amb = 0.08, wrap = 0.24, tok = tok, bias = b })
  local rr = X.rim(n)
  vis:edge():each(function(x, y) local k = K(x, y) if rr[k] and rr[k] > 0.55 and not b[k] then c:put(x, y, "#6f8a6a", tok) end end)
  return vis, n, idx
end
local tC = { r = { name = "seedC" } }
local visC, nC = pea(SC, mC, tC, { over = { mA, mB }, under = { mA, mB } })
local gx, gy = A.specAt(visC:shrink(1), nC, 40) if gx then c:put(gx, gy, DRY[6], tC) end
-- split coat where the stem leaves seed C
for _, p in ipairs{ { 27, 38 }, { 27, 39 }, { 26, 38 } } do c:put(p[1], p[2], STEM[2], stok) end
c:put(28, 38, DRY[2], tC)

local tA = { r = { name = "seedA" } }
local visA, nA = pea(SA, mA, tA, { over = { mB }, under = { mB } })
local gx2, gy2 = A.specAt(visA:shrink(1), nA, 40) c:put(gx2, gy2, A.CREAM, tA)
-- hilum: dark scar with a pale rim, facing the viewer low on seed A
c:put(23, 49, "#3a2a22", tA) c:put(24, 49, "#3a2a22", tA)
c:put(22, 49, DRY[6], tA) c:put(23, 48, DRY[6], tA) c:put(24, 48, DRY[5], tA) c:put(25, 49, DRY[4], tA)

-- seed B: wrinkled
local tB = { r = { name = "seedB" } }
local visB, nB, idxB = pea(SB, mB, tB, {})
visB:shrink(1):each(function(x, y)
  local dx, dy = x - SB[1], y - SB[2]
  local w = sin(dx * 1.5 + dy * 0.7 + 0.4) * cos(dy * 1.4 - dx * 0.5)
  if w > 0.5 then A.step(c, idxB, DRY, x, y, -2, tB)
  elseif w < -0.62 then A.step(c, idxB, DRY, x, y, 1, tB) end
end)
local gx3, gy3 = A.specAt(visB:shrink(1), nB, 40) c:put(gx3, gy3, DRY[6], tB)

A.save(c, NAME)

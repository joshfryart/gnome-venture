-- petunia-seed (Opus artist pass, single). A dry, split petunia seed capsule (tan, two gaping valves, a star of five
-- papery sepals) lying on a torn scrap of soft petunia leaf (ovate, pointed tip on the left, torn base on the right,
-- midrib and soft veins, downy edge hairs, cool reflected edge, contact shadows). Tiny round dark-brown seeds have
-- spilled out of the capsule in a little trail; one of them has sprouted on the right: thin stem, two round
-- cotyledons and two downy ovate true leaves (the petunia leaf shape, with fine edge hairs).
-- quirk: the seedling is far too eager: it already carries one tiny striped violet trumpet bud.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_3.lua")
local HP, X, K, G = D.HP, D.X, D.K, D.G
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "petunia-seed"
local c = D.new(NAME)

local LEAF = { "#1e4a3c", "#2c6646", "#3f8650", "#5aa45a", "#7fc066", "#aedb84" }
local VEIN, HAIR, COOL = "#cdeaa0", "#d8efb4", "#3e7480"
local POD  = { "#5a3a26", "#80562e", "#a8783c", "#cc9c52", "#e8c47a", "#f8e2a8" }
local SEP  = { "#4a4a2a", "#76703c", "#a49a5a", "#cfc584" }
local SEED = { "#2a1618", "#4e2c22", "#7c4a2a", "#b0763a" }
local STEM = { "#4e7e4a", "#80ac64", "#b4d48c", "#e0f0bc" }
local VIO  = { "#3a2060", "#5a3290", "#8250c0", "#a978e0", "#d0aaf4" }
local ltok, stok, ptok = D.tok("leaf"), D.tok("stem"), D.tok("pod")

-- leaf scrap: tip on the left, base torn off on the right
local lm, ln, LT, LS, len = G.blade(10, 46, 32, 58, 55, 51, function(t)
  if t > 0.985 then return -1 end
  local u = 1 - t                               -- u: 0 at the tip (left)
  return max(0.5, 7.4 * sin(pi * min(1, u * 0.78 + 0.02)) ^ 0.75)
end, { fold = 0.3 })
-- torn base: ragged diagonal cut near the right end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.0 then return end
  if (1 - LT[k]) < 0.0 then return end
  local lim = 0.84 - 0.06 * LS[k] + 0.025 * sin(LS[k] * 11)
  if LT[k] > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- capsule + sepals + seeds (masks first, for AO)
local pod, podn = G.oval(19, 45, 5.0, 3.0, -0.5, 0.8)
local seeds = { { 26, 47 }, { 30, 49 }, { 33, 46 }, { 28, 52 }, { 36, 51 }, { 24, 50 } }
local seedm = HP.mask()
for _, p in ipairs(seeds) do seedm:add(c:rect(p[1], p[2], p[1] + 2, p[2] + 2)) end
local sprSeed = { 41, 49 }
seedm:add(c:rect(sprSeed[1], sprSeed[2], sprSeed[1] + 2, sprSeed[2] + 2))
local bias = {}
X.ao(bias, lm, pod, 1, -1) G.cast(bias, lm, pod, 1, 2, -1)
G.cast(bias, lm, seedm, 1, 1, -1)
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.18, wrap = 0.32 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.04 and t < 0.86 then c:put(x, y, s <= 0 and VEIN or LEAF[4], ltok) return end
  local ph = ((1 - t) * len - abs(s) * 4.2) / 7.5 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.08 and t < 0.84 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] > 0.78 then c:put(x, y, LEAF[5], ltok) return end          -- torn tissue
  if not bias[k] and LS[k] > 0.7 then c:put(x, y, COOL, ltok) end
end)
-- downy hairs: pale ticks just outside the upper (lit) edge
lm:grow(1):cut(lm):each(function(x, y)
  if y < 50 and x > 11 and x < 50 and (x % 3 == 0) and not pod:has(x, y) and not lm:has(x, y - 1) then c:put(x, y, HAIR, ltok) end
end)

-- sepals: five papery points from the capsule base (lower left)
local sep = HP.mask()
for _, a in ipairs{ 2.0, 2.6, 3.3, 3.9, 1.4 } do
  local ux, uy = cos(a), sin(a)
  sep:add(D.stroke({ { 15.5, 47 }, { 15.5 + ux * 5.0, 47 + uy * 3.6 } }, 0.5))
end
sep:cut(pod)
sep:each(function(x, y) local d = sqrt((x - 15.5) ^ 2 + (y - 47) ^ 2)
  c:put(x, y, SEP[(y < 46) and (d < 3 and 4 or 3) or (d < 3 and 2 or 1)], ptok) end)
-- capsule: ovoid, lit, with a ridge seam and the two split valves at the tip (upper right)
local pidx = G.toneN(c, pod, podn, POD, { tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.1, wrap = 0.25 })
pod:each(function(x, y)
  local dx, dy = x - 19, y - 45
  local u = dx * cos(-0.5) + dy * sin(-0.5)
  local v = -dx * sin(-0.5) + dy * cos(-0.5)
  if abs(v) < 0.5 and u < 3 and u > -4 then c:put(x, y, POD[max(1, (pidx[K(x, y)] or 3) - 2)], ptok) end
end)
-- open valves: dark mouth + two curled valve lips
c:put(23, 42, SEED[1], ptok) c:put(24, 43, SEED[1], ptok) c:put(23, 43, SEED[2], ptok)
c:put(22, 41, POD[6], ptok) c:put(23, 40, POD[5], ptok) c:put(25, 42, POD[4], ptok) c:put(26, 43, POD[3], ptok)
c:put(24, 44, SEED[2], ptok)
-- spilled seeds: round 3x3, dark corners, lit top-left
local function seed(px, py, tok)
  c:paint({ ".b.", "bcd", ".d." }, px, py, { b = SEED[4], c = SEED[3], d = SEED[2] })
  c:put(px + 2, py + 2, LEAF[2], ltok) c:put(px + 1, py + 2, SEED[1], tok)
end
for _, p in ipairs(seeds) do seed(p[1], p[2], D.tok("seed")) end
seed(sprSeed[1], sprSeed[2], D.tok("seed"))

-- seedling from the right-hand seed
local sp = { { 42, 49 }, { 44, 42 }, { 40, 33 }, { 42, 26 } }
local sm, sn = G.tube(sp, function(t) return 0.95 end)
sm:cut(seedm)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function blade(ax, ay, cx, cy, bx, by, w, hairy)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.55)
  end, { fold = 0.3 })
  m:cut(sm)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) end end)
  if hairy then
    m:grow(1):cut(m):each(function(x, y)
      if (x + y) % 3 == 0 and not sm:has(x, y) and c:get(x, y) == nil then c:put(x, y, HAIR, ltok) end end)
  end
  return m
end
-- round cotyledons (low), downy ovate true leaves (higher)
blade(41, 35, 37, 34, 33, 31, 2.0)
blade(43, 36, 47, 36, 51, 33, 2.0)
blade(41, 28, 36, 27, 29, 22, 3.0, true)
blade(42, 28, 48, 26, 53, 20, 3.0, true)
-- AO knot where leaves meet the stem
c:put(41, 29, STEM[1], stok) c:put(42, 36, STEM[1], stok)

-- quirk: a tiny violet trumpet bud, striped, on a short neck
local btok = D.tok("bud")
D.line(c, { { 42, 26 }, { 42, 22 } }, STEM[2], stok)
c:paint({
  "aabbcc.",
  ".bdbec.",
  ".cbdc..",
  "..cdc..",
  "..cc...",
  "...g...",
}, 39, 15, { a = VIO[5], b = VIO[4], c = VIO[3], d = VIO[2], e = VIO[1], g = STEM[1] })
c:put(41, 15, D.CREAM, btok)

D.save(c, NAME)

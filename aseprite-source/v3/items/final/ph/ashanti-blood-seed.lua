-- ashanti-blood-seed (final pass, Opus). Ashanti blood (Mussaenda erythrophylla): the "leaf scrap" is a torn piece
-- of its crimson velvet bract, lying flat: pinnate veins pressed in deeper red, velvet nap as pale specks on the lit
-- side, cool violet edge on the shade side, a ragged torn right end. Two small dark seeds with pitted coats rest on it
-- (AO + contact shadow); a third has sprouted: thin red-flushed stem, one opposite pair of elliptic, pointed, pinnately
-- veined leaves (the parent's leaf shape) and a tiny closed bud above.
-- quirk: one fallen little yellow star flower lies on the bract, orange eye.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "ashanti-blood-seed"
local c = A.new(NAME)

local BR   = { "#3e0f22", "#621a2a", "#8e2430", "#b8323a", "#dc5448", "#f48a6c" }
local NAP, BCOOL, TORN = "#e8705a", "#5a2a5c", "#f0b49a"
local LEAF = { "#173a30", "#235638", "#33743e", "#4d9446", "#74b452", "#a6d270" }
local STEM = { "#5a3a2e", "#7a6a3c", "#a49a56", "#d0cc84" }
local SEED = { "#24161a", "#3a2224", "#56342c", "#764a36", "#9a6a48", "#c49468" }
local STAR = { "#d0801a", "#f6b82c", "#ffe05a", "#fff4b0" }
local EYE = "#e0602a"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local seeds = { { 30, 48.5, 2.9, 2.2, 0.3 }, { 38, 47, 2.7, 2.1, -0.4 }, { 22, 45.5, 2.8, 2.1, -1.2 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- bract scrap: broad ovate, base at left, torn off at the right
local btok = { r = { name = "bract" } }
local bm, bn, BT, BS, blen = A.blade(9, 50, 30, 54, 55, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.6 * sin(pi * min(1, t * 0.62 + 0.06)) ^ 0.7)
end, { fold = 0.28 })
local torn = {}
bm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.04 * sin(BS[k] * 7) + 0.04 * X.hash(floor(BS[k] * 4 + 9), 1, 3)
  if BT[k] > lim or x > 52 then torn[#torn + 1] = k end end)
for _, k in ipairs(torn) do bm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, bm, s.m, 1, -1) A.cast(bias, bm, s.m, 1, 2, -1) end
local STARM = HP.mask()
local SX, SY = 43, 51
for _, p in ipairs{ {0,-2},{0,-1},{-2,0},{-1,0},{0,0},{1,0},{2,0},{-1,1},{1,1},{-2,2},{2,2},{0,1} } do STARM:set(SX + p[1], SY + p[2]) end
X.ao(bias, bm, STARM, 1, -1)
local bidx = A.toneN(c, bm, bn, BR, { bias = bias, tok = btok, cuts = { 0.2, 0.4, 0.58, 0.76, 0.92 }, amb = 0.06, wrap = 0.25 })
bm:each(function(x, y) local k = K(x, y) local s, t = BS[k], BT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, BR[max(1, (bidx[k] or 3) - 2)], btok) return end    -- pressed midrib
  local ph = (t * blen - abs(s) * 6.5) / 6.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.15 and abs(s) < 0.8 and t > 0.06 then c:put(x, y, BR[max(1, (bidx[k] or 3) - 1)], btok)
  elseif (bidx[k] or 0) >= 4 and X.hash(x, y, 21) > 0.9 then c:put(x, y, NAP, btok) end           -- velvet nap
end)
bm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if BT[k] > 0.74 then c:put(x, y, (x + y) % 2 == 0 and TORN or BR[5], btok)
  elseif BS[k] > 0.6 then c:put(x, y, BCOOL, btok) end end)
-- petiole stub at the base
for _, q in ipairs{ { 8, 50, 3 }, { 7, 50, 2 }, { 6, 51, 2 } } do c:put(q[1], q[2], BR[q[3]], btok) end

-- sprout from the left seed
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 22, 44 }, { 23, 37 }, { 21, 31 }, { 22, 21 } }, function(t) return 1.0 end, STEM, { tok = stok, cut = seeds[3].m, cuts = { 0.3, 0.55, 0.8 } })
local ltok = { r = { name = "leaf" } }
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.08 then return 0.5 end
    return max(0.4, w * sin(pi * min(1, (t - 0.04) * 1.0)) ^ 0.75 * (1 - 0.25 * t))
  end, { fold = 0.4 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.06 and t < 0.9 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
    elseif t > 0.15 and t < 0.85 and abs(s) > 0.25 and abs(s) < 0.75 then
      local d = (t * L - abs(s) * w * 1.3) % 3.2
      if d < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, idx[k] + 1)] or LEAF[max(1, idx[k] - 1)], ltok) end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.2 and T[k] < 0.85 then c:put(x, y, "#2c5a5a", ltok) end end)
  return m
end
local L1 = leaf(21, 30, 15, 28, 8, 22, 3.6)
local L2 = leaf(23, 30, 30, 27, 37, 20, 3.6)
-- node: AO where the leaf stalks meet the stem
c:put(21, 30, STEM[1], stok) c:put(22, 30, STEM[1], stok) c:put(22, 31, STEM[2], stok)
-- tiny closed bud at the stem tip: two folded leaflets
local bud = leaf(22, 22, 20, 18, 21, 14, 1.6)
local bud2 = leaf(23, 22, 25, 19, 26, 16, 1.2)

-- seeds: pitted coats, collar ring, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, amb = 0.1, wrap = 0.25 })
  vis:each(function(x, y) local k = K(x, y) if (x * 2 + y * 3 + i) % 5 == 0 and (idx[k] or 1) >= 3 then c:put(x, y, SEED[(idx[k] or 3) - 1], tok) end end)
  local gx, gy = A.specAt(vis, s.n, 30) if gx then c:put(gx, gy, SEED[6], tok) end
end

-- quirk: fallen yellow star flower
local ftok = { r = { name = "star" } }
STARM:each(function(x, y) local dx, dy = x - SX, y - SY
  local i = (dx + dy < 0) and 3 or 2
  if abs(dx) == 2 then i = i - 1 end
  c:put(x, y, STAR[max(1, i)], ftok) end)
c:put(SX, SY - 2, STAR[4], ftok) c:put(SX - 1, SY, STAR[4], ftok)
c:put(SX, SY, EYE, ftok)

A.save(c, NAME)

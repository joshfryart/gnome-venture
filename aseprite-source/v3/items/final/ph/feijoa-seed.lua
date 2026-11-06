-- feijoa-seed (B31, Opus single pass). Tiny cream feijoa seeds held in a dab of pale glassy pulp (rim highlight,
-- pale core, darker seeds showing through) on a glossy dark-olive feijoa leaf scrap: torn off at the left, its lower
-- edge curled to show the silvery felted underside, midrib and looping veins, one leaf specular. From the right seed
-- a sprout rises with two opposite pairs of oval grey-green leaves (silver backs) and a terminal bud.
-- quirk: a fallen tuft of crimson feijoa stamens with gold tips lies by the pulp.
local NAME = "feijoa-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new(NAME)

local LEAF = { "#132e2a", "#1d4636", "#2c6240", "#467e48", "#72a45a", "#b0cc7c" }
local SILV = { "#6c8478", "#9cb0a2", "#c8d4c2", "#e4eadc" }
local SPR = { "#24493c", "#3c6c4c", "#5c905c", "#88b276", "#b8d49e", "#dcebc6" }
local PULP = { "#9c8a52", "#c4b474", "#ddd298", "#efe8bc", "#fbf6dc" }
local SEED = { "#6a4a2c", "#9a7448", "#c6a26e", "#e6cc98" }
local RED = { "#7a1630", "#c42a3a", "#ee5248" }

-- leaf scrap: broad ellipse leaf, slight downward bow, torn at the left end
local lm, ln, LT, LS, len = G.blade(6, 47, 30, 52, 57, 43, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 8.6 * sin(pi * min(1, t * 0.8 + 0.12)) ^ 0.55)
end, { fold = 0.3 })
local tear = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.16 + 0.06 * sin(LS[k] * 7.0 + 1.0) + 0.04 * (X.hash(x, y, 7) - 0.5)
  if LT[k] < lim then tear[#tear + 1] = k end
end)
for _, k in ipairs(tear) do lm.s[k] = nil end
-- curl: the lower rim rolls over, showing the silvery underside
local curl = HP.mask()
lm:each(function(x, y) local k = K(x, y) if LS[k] > 0.72 and LT[k] > 0.3 and LT[k] < 0.86 then curl:set(x, y) end end)

-- pulp dab + seeds
local PM, PN = G.oval(25, 45, 8.2, 3.6, 0.05, 0.6)
local seeds = { { 20, 45 }, { 24, 43 }, { 28, 46 }, { 31, 44 }, { 23, 47 } }
local bias = {}
X.ao(bias, lm, PM, 1, -1) G.cast(bias, lm, PM, 1, 2, -1)
local sprSeed = { 40, 42 }
local sdm = G.oval(sprSeed[1], sprSeed[2], 2.2, 1.4, -0.3)
X.ao(bias, lm, sdm, 1, -2)

local lidx = G.shade(c, lm, ln, LEAF, { bias = bias, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
-- midrib + looping veins
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] or curl:has(x, y) then return end
  if abs(s) < 0.1 and t > 0.12 then c:put(x, y, s <= 0 and LEAF[5] or LEAF[2]) return end
  local ph = (t * len - abs(s) * 3.0) / 6.0
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.12 and abs(s) < 0.62 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3]) end
end)
-- silver underside on the curl, with its own dark fold line on top
curl:each(function(x, y) local k = K(x, y)
  local i = (LS[k] > 0.86) and 2 or 3
  if X.hash(x, y, 2) > 0.8 then i = i + 1 end
  c:put(x, y, SILV[min(4, i)])
end)
curl:each(function(x, y) if lm:has(x, y - 1) and not curl:has(x, y - 1) then c:put(x, y - 1, LEAF[1]) end end)
-- torn left end: pale fibrous edge
lm:edge():each(function(x, y) local k = K(x, y) if LT[k] < 0.26 and not curl:has(x, y) and not bias[k] then c:put(x, y, LEAF[5]) end end)
-- glossy leaf specular
c:put(46, 41, "#e8f4c0") c:put(47, 41, "#e8f4c0")

-- pulp: glassy, darker seeds showing through, bright rim + pale core
local pv = X.light(PN, { amb = 0.2, wrap = 0.4 })
local pidx = X.tone(c, PM, pv, PULP, { cuts = { 0.2, 0.4, 0.6, 0.8 } })
for _, s in ipairs(seeds) do
  local m = G.oval(s[1], s[2], 1.3, 0.8, 0.3)
  m:clip(PM)
  m:each(function(x, y) local i = (x <= s[1] and y <= s[2]) and 4 or ((x > s[1] and y > s[2]) and 2 or 3) c:put(x, y, SEED[i]) end)
  if PM:has(s[1] + 1, s[2] + 1) and not m:has(s[1] + 1, s[2] + 1) then c:put(s[1] + 1, s[2] + 1, PULP[2]) end
end
PM:edge():each(function(x, y) if x + y < 25 + 45 - 2 then c:put(x, y, PULP[5]) end end)
c:put(21, 43, "#fff4d6") c:put(22, 43, "#fff4d6")

-- sprout: stem, two opposite leaf pairs, terminal bud
local sp = { { 40, 41 }, { 41, 34 }, { 39, 26 }, { 40, 15 } }
local sm, sn = G.tube(sp, function(t) return 1.0 end)
G.shade(c, sm, sn, SPR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.15, wrap = 0.3 })
local function pair(t, L, W, lift)
  local x, y = G.bez(sp, t)
  for _, side in ipairs{ -1, 1 } do
    local ux, uy = G.rot(side, 0, -side * lift)
    local bx, by = x + ux * L, y + uy * L
    local m, n, T, S = G.blade(x + ux, y + uy, (x + bx) / 2, (y + by) / 2 - 1.2, bx, by, function(tt)
      if tt > 0.98 then return -1 end
      return max(0.4, W * sin(pi * min(1, tt * 0.92 + 0.06)) ^ 0.6)
    end, { fold = 0.35 })
    m:cut(sm)
    local idx = G.shade(c, m, n, SPR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
    m:each(function(xx, yy) local k = K(xx, yy)
      if abs(S[k]) < 0.15 and T[k] > 0.1 and T[k] < 0.82 then c:put(xx, yy, S[k] <= 0 and SPR[6] or SPR[3]) end
      if S[k] > 0.72 then c:put(xx, yy, SILV[2]) end   -- silver back peeks along the lower rim
    end)
    G.touch(sm, m):each(function(xx, yy) c:put(xx, yy, SPR[1]) end)
  end
end
pair(0.42, 8.5, 2.6, 0.35)
pair(0.8, 6.5, 2.1, 0.5)
local bx, by = G.bez(sp, 1)
local bud = G.oval(bx, by - 1, 1.3, 2.0, 0)
bud:each(function(x, y) c:put(x, y, (x <= bx and y < by) and SPR[5] or SPR[3]) end)
-- sprouting seed coat
sdm:each(function(x, y) local i = (x < sprSeed[1] and y <= sprSeed[2]) and 4 or ((x > sprSeed[1] or y > sprSeed[2]) and 2 or 3) c:put(x, y, SEED[i]) end)
c:put(41, 43, SEED[1])

-- quirk: fallen stamen tuft (crimson filaments, gold anthers) right of the pulp
local fil = { { { 33, 50 }, { 36, 47 } }, { { 33, 50 }, { 37, 49 } }, { { 33, 50 }, { 35, 46 } }, { { 33, 50 }, { 37, 51 } } }
for i, f in ipairs(fil) do G.pline(c, f, i % 2 == 0 and RED[2] or RED[3]) end
c:put(33, 50, RED[1]) c:put(32, 51, RED[1])
for _, q in ipairs{ { 36, 46 }, { 35, 45 }, { 38, 49 }, { 38, 51 }, { 37, 47 } } do c:put(q[1], q[2], "#ffd84a") end

G.save(c, NAME)

-- kola-seed (run3, Opus single pass). Two kola seeds (rosy, angular, with the deep cleft between the cotyledons) on a
-- torn scrap of glossy kola leaf (midrib, pinnate veins, ragged torn right end, cool reflected edge). The big seed
-- has germinated: a woody-green stem rises and opens two leathery obovate kola leaves with drip-tip points, a pale
-- midrib and side veins. AO under the seeds, contact shadow on the scrap.
-- quirk: a single dewdrop sits on the big leaf, catching the light.
local NAME = "kola-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new5(NAME)
local LEAF = { "#163a33", "#1f5640", "#2c7349", "#43924f", "#69b25a", "#a2d276" }
local TORN = "#d4e6a4"
local SEED = { "#4c1630", "#7c2238", "#a8363f", "#cf5a50", "#eb8670", "#fbb79c" }
local STEM = { "#3e4a2e", "#5f7a3c", "#8aa858", "#c0d88a" }
local COOL = "#3b6a78"
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }

-- leaf scrap: broad blade, base at left, ragged torn edge at right
local lm, ln, LT, LS, len = G.blade(7, 50, 30, 41, 57, 45, function(t)
  local u = 0.1 + t * 0.9
  return max(0.6, 7.4 * sin(pi * min(1, u)) ^ 0.45)
end, { fold = 0.3 })
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.86 and X.hash(x, y, 3) > 0.5 then lm.s[k] = nil end end)
G.tear(lm, function(x, y) return LT[K(x, y)] > 0.8 end, 11, 2)
-- seeds
local S1m, S1n = G.oval(24, 44, 6.6, 4.4, -0.12, 0.8)
local S2m, S2n = G.oval(37.5, 47, 4.0, 3.0, 0.5, 0.8)
local bias = {}
for _, m in ipairs{ S1m, S2m } do X.ao(bias, lm, m, 1, -1) G.cast(bias, lm, m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 then c:put(x, y, s <= 0 and "#bfe28e" or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.5
  local f = ph - floor(ph)
  if f < 0.13 and abs(s) > 0.16 and abs(s) < 0.8 and t > 0.05 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] > 0.84 then c:put(x, y, TORN, ltok)
  elseif LS[k] > 0.6 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 6, 51, 3 }, { 5, 52, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout stem (behind the big seed)
local stok = { r = { name = "stem" } }
local sp = { { 25, 42 }, { 24, 34 }, { 27, 28 }, { 27, 19 } }
local sm, sn = G.tube(sp, function(t) return 1.15 - 0.2 * t end)
sm:cut(S1m)
G.toneN(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
local function kleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    if t > 0.86 then return max(0.3, w * 0.55 * (1 - (t - 0.86) / 0.13)) end   -- drip tip
    return max(0.6, w * sin(pi * (0.1 + t * 0.62)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  local tok = { r = { name = "kleaf" } }
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t < 0.9 then c:put(x, y, s <= 0 and "#cdeaa0" or LEAF[3], tok) return end
    local ph = (t * L - abs(s) * 3.4) / 4.2
    local f = ph - floor(ph)
    if f < 0.16 and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 and t < 0.82 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], tok) end
  end)
  return m, n
end
local smallL = kleaf(26, 30, 19, 29, 10, 22, 3.4)
local bigL, bigN = kleaf(27, 21, 35, 14, 50, 13, 4.6)
-- glossy spec on the big leaf
local gx, gy = G.specAt(bigL, bigN, 60) if gx then c:px(gx, gy, "#e4f6b8") end
-- bud at stem tip
c:put(27, 18, STEM[3], stok) c:put(26, 18, STEM[4], stok) c:put(27, 17, STEM[2], stok)

-- seeds
local function seed(m, n, cx, cy, ang, rx, cleft, tok)
  local idx = G.toneN(c, m, n, SEED, { tok = tok, cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, amb = 0.1, wrap = 0.3 })
  -- cotyledon cleft: a dark groove across the seed, lit lip on its upper-left side
  local ca, sa = cos(ang + cleft), sin(ang + cleft)
  for d = -rx, rx do
    local x, y = floor(cx + d * ca * 0.75 + .5), floor(cy + d * sa * 0.75 + .5)
    if m:has(x, y) and m:has(x - 1, y - 1) then c:put(x, y, SEED[1], tok) c:put(x - 1, y - 1, SEED[5], tok) end
  end
  -- hilum notch on the lower edge
  local sx, sy = G.specAt(m, n, 40) if sx then c:px(sx, sy, "#fff4d6") end
  return idx
end
local t2 = { r = { name = "seed2" } }
seed(S2m, S2n, 37.5, 47, 0.5, 3, 1.6, t2)
local t1 = { r = { name = "seed1" } }
-- big seed sits over the small one's edge: AO on the small one already handled by draw order; rim on S1
seed(S1m, S1n, 24, 44, -0.12, 5, 1.35, t1)
-- stem foot over the seed cleft (sprout emerges from the cleft)
c:put(25, 40, STEM[2], stok) c:put(25, 41, STEM[1], stok)
-- cool reflected light on the big seed's lower-right rim
local rim = X.rim(S1n)
S1m:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.6 then c:put(x, y, "#8a5a86", t1) end end)

-- quirk: dewdrop on the big leaf
local DX, DY = 40, 15
c:px(DX, DY, "#9fe0d6") c:px(DX + 1, DY, "#6cbfc0") c:px(DX, DY + 1, "#6cbfc0") c:px(DX + 1, DY + 1, "#3e8f98")
c:px(DX, DY, "#f2fff6")
c:px(DX + 1, DY + 2, LEAF[1])
G.save2(c, NAME)

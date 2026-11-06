-- pickled-bamboo-shoots (C34, Opus single pass). Opaque stoneware crock: celadon glaze (per-pixel lit, glossy
-- specular streak) that stops in a wavy pooled edge with two runs over bare speckled clay at the foot; rolled rim seen
-- from slightly above with a dark brine mouth; two lug ears. Three slim pickled shoot halves stand up out of it, each a
-- tapering cone with layered sheath chevrons (groove + lit lip) and a tawny tip; AO where they enter the brine.
-- quirk: the tallest shoot is still growing - a fresh green bamboo leaf unfurls from its tip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC34_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, sin, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.abs
local c = A.new("pickled-bamboo-shoots")
local CX = 32
local GLAZE = { "#1c3a3a", "#2a5a4a", "#3f7f58", "#5ea268", "#8cc47c", "#c4e6a4" }
local CLAY = { "#4a2c26", "#74452e", "#9c6a44", "#c09060", "#dcb482", "#f0d4a8" }
local SHOOT = { "#6a5638", "#9a8460", "#c4b088", "#e2d2a6", "#f4eacc", "#fffaea" }
local TIP = { "#4a3a20", "#7a6230", "#a8883e", "#c8aa56", "#e0c87a", "#f2e2a8" }
local MOUTH = { "#2a2420", "#4a3c2c", "#6a5a3a" }

c:groundShadow(CX - .5, 55, 14, 1)
-- crock body
local function hw(y)
  if y < 26 or y > 54 then return nil end
  if y == 54 then return 10.5 elseif y == 53 then return 11.5 end
  return 9.6 + 3 * sin(math.pi * (y - 25) / 30)
end
local body, bn, NX = A.lathe(CX, 26, 54, hw)
-- glaze line: wavy, with two runs
local function glazeEnd(x)
  local e = 46 + floor(sin(x * .9) * 1.2 + .5)
  if x == CX - 5 or x == CX - 4 then e = 50 end
  if x == CX + 4 then e = 49 end
  return e
end
local glaze, clay = HP.mask(), HP.mask()
body:each(function(x, y) if y <= glazeEnd(x) then glaze:set(x, y) else clay:set(x, y) end end)
local function sub(m) local t = {} m:each(function(x, y) t[K(x, y)] = bn[K(x, y)] end) return t end
local gb = {}
glaze:each(function(x, y) if y == glazeEnd(x) then gb[K(x, y)] = -1 end end) -- pooled glaze rim
local gidx, gtok = A.tone(c, glaze, sub(glaze), GLAZE, { amb = .08, wrap = .25, bias = gb })
local cidx = A.tone(c, clay, sub(clay), CLAY, { amb = .08, wrap = .25 })
clay:each(function(x, y) if X.hash(x, y, 4) > .78 then c:put(x, y, CLAY[max(1, (cidx[K(x, y)] or 3) - 1)]) end end)
-- glossy specular streak
local spec = X.spec(sub(glaze), 30)
glaze:each(function(x, y) local s = spec[K(x, y)] if s and s > .55 then c:put(x, y, s > .8 and A.SPEC or GLAZE[6], gtok) end end)
-- crackle hint (a few deep glaze lines on the shade side)
for _, p in ipairs{ { 38, 34 }, { 39, 35 }, { 39, 36 }, { 40, 40 }, { 41, 41 } } do if glaze:has(p[1], p[2]) then c:put(p[1], p[2], GLAZE[2], gtok) end end

-- lug ears
for _, s in ipairs{ -1, 1 } do
  local ex = s < 0 and CX - 13 or CX + 12
  local m = HP.rect(ex - (s < 0 and 1 or 0), 29, ex + (s < 0 and 0 or 1), 31)
  m:each(function(x, y) c:put(x, y, s < 0 and (y == 29 and GLAZE[5] or GLAZE[4]) or (y == 29 and GLAZE[3] or GLAZE[2]), gtok) end)
  c:put(ex + (s < 0 and 0 or 0), 30, GLAZE[1], gtok)
end

-- rim (ellipse ring seen from above) and brine mouth
local rimO = A.rell(CX, 26, 1, 0, 10.4, 2.6)
local mouth = A.rell(CX, 25.6, 1, 0, 8.2, 1.6)
local ring = rimO:copy():cut(mouth)
local rn = X.pillow(ring, 1.5)
A.tone(c, ring, rn, GLAZE, { amb = .25, wrap = .4, tok = gtok })
ring:each(function(x, y) if y >= 27 then c:put(x, y, GLAZE[3], gtok) end end)
mouth:each(function(x, y) c:put(x, y, y <= 24 and MOUTH[1] or (x < CX and MOUTH[2] or MOUTH[3]), gtok) end)

-- shoots (cones). allowed area: above the mouth's front edge
local front = body:copy():add(ring):cut(mouth)
local function shoot(bx, by, tx, ty, w0, seed)
  local m, n, T, S = X.cyl(bx, by, tx, ty, function(t) return max(.3, w0 * (1 - t) ^ .8) end)
  m:cut(front)
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if mouth:has(x, y) or mouth:has(x, y + 1) then bias[k] = -2 elseif mouth:has(x, y + 2) then bias[k] = -1 end end)
  local v = X.light(n, { amb = .1, wrap = .3 })
  local len = sqrt((tx - bx)^2 + (ty - by)^2)
  local tok = { r = { name = "shoot" .. seed } }
  m:each(function(x, y)
    local k = K(x, y)
    local t, s = T[k], S[k]
    local ramp = t > .72 and TIP or SHOOT
    local i = 1 for j, cut in ipairs(A.CUT6) do if v[k] >= cut then i = j + 1 end end
    i = max(1, min(6, i + (bias[k] or 0)))
    -- sheath chevrons: layers rising toward the edges
    local d = (t * len - abs(s) * 2.2 + seed) % 5
    if t < .9 and d < .9 then i = max(1, i - 2) elseif t < .9 and d < 1.9 and i >= 3 then i = min(6, i + 1) end
    c:put(x, y, ramp[i], tok)
  end)
  return m
end
shoot(CX - 4.5, 26, CX - 8, 14, 3.6, 1)
shoot(CX + 5, 26, CX + 8.5, 16, 3.2, 3)
local mid = shoot(CX + .5, 27, CX + 1, 11, 4.2, 0)

-- quirk: a fresh bamboo leaf unfurling from the tallest tip
local ltok = { r = { name = "leaf" } }
c:put(CX + 1, 10, "#5b9a52", ltok) c:put(CX + 2, 9, "#5b9a52", ltok)
A.leaf(c, CX + 2.5, 9, 1, -.35, 7, 1.5, A.LEAF, { tok = ltok, R = 1.3 })
A.fin(c, "pickled-bamboo-shoots")

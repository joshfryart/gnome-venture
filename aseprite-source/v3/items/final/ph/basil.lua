-- basil (ph, round 3, artist 4). A slim sprig: square stem (flat lit face, node rings) with three opposite
-- pairs of broad, cupped, glossy ovate leaves that shrink toward a soft pale tip. Leaves: 6-tone ramp from a
-- tented normal field, sunken midrib + curved side veins, one wet specular streak each, cool reflected light
-- on the shade rim, AO where the petioles meet the stem. quirk: a caterpillar nibble bitten out of the lower
-- right leaf (pale chewed rim).
local NAME = "basil"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local LEAF = { "#123a2c", "#1b5534", "#28743a", "#3f963c", "#66b844", "#9edb64" }
local YOUNG = { "#1b5534", "#28743a", "#3f963c", "#66b844", "#9edb64", "#cdf08e" }
local STEM = { "#24462c", "#3a6a36", "#5a8e40", "#7eae52", "#a8cc6e", "#d2e8a0" }
local GLOSS, COOL, CHEW = "#e8f8b8", "#3a6f74", "#d6ec98"

-- stem
local sTok = G.tok("stem")
local sp = { { 32, 58 }, { 31, 46 }, { 32, 30 }, { 31, 14 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.2 - t * 0.25 end)
-- square stem: flat faces -> left face lit, centre ridge, right face shade
sm:each(function(x, y) local k = K(x, y) local s = SS[k]
  local i = (s < -0.35) and 5 or ((s < 0.3) and 4 or 2)
  c:put(x, y, STEM[i], sTok) end)

local function leaf(ax, ay, cx, cy, bx, by, W, ramp, o)
  o = o or {}
  local tok = G.tok(o.name or "leaf")
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, W * sin(pi * min(1, t ^ 0.82 * 0.97 + 0.03)) ^ 0.8)
  end, { fold = o.fold or 0.42 })
  if o.cut then m:cut(o.cut) end
  local bias = {}
  X.ao(bias, m, sm, 1, -1)
  if o.ao then X.ao(bias, m, o.ao, 1, -1) end
  local idx = G.toneN(c, m, n, ramp, { bias = bias, tok = tok, cuts = { 0.14, 0.3, 0.47, 0.64, 0.82 }, amb = 0.14, wrap = 0.3 })
  local PER = len / (o.veins or 5)
  m:each(function(x, y) local k = K(x, y)
    if bias[k] then return end
    local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.05 and t < 0.86 then c:put(x, y, s <= 0 and ramp[min(6, idx[k] + 1)] or ramp[max(1, idx[k] - 1)], tok) return end
    local ph = (t * len - abs(s) * W * 1.3) / PER
    local f = ph - floor(ph)
    if (f < 0.2) and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.08 and t < 0.82 then
      c:put(x, y, ramp[max(1, idx[k] - 1)], tok)
    end
  end)
  -- cool reflected light on the shade rim
  m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.9 and idx[k] <= 3 then c:put(x, y, COOL, tok) end end)
  -- wet specular streak: 2 px on the lit half near the widest point
  local sp2 = X.spec(n, 24)
  local best, bx2, by2
  m:each(function(x, y) local k = K(x, y)
    if S[k] < -0.25 and T[k] > 0.2 and T[k] < 0.6 and (not best or sp2[k] > best) then best, bx2, by2 = sp2[k], x, y end end)
  if bx2 then c:put(bx2, by2, o.gloss or GLOSS, tok)
    if m:has(bx2 + 1, by2) and S[K(bx2 + 1, by2)] < -0.15 then c:put(bx2 + 1, by2, ramp[6], tok) end end
  return m, T, S, idx, tok
end

-- petioles (short stalks) from nodes to leaf bases
local function petiole(x0, y0, x1, y1)
  local m = G.lineMask(x0, y0, x1, y1)
  m:each(function(x, y) c:put(x, y, STEM[3], sTok) end)
  return m
end

-- lower pair (largest, drooping)
petiole(30, 45, 27, 44) petiole(33, 44, 36, 43)
-- quirk bite: two overlapping circles out of the upper edge of the right lower leaf
local bite = HP.mask():add(c:ellipse(46, 37, 1.9, 1.9)):add(c:ellipse(48.5, 37.6, 1.3, 1.3))
local L1 = leaf(27, 44, 17, 39, 8, 49, 5.6, LEAF, { name = "l1" })
local R1, R1T, R1S, R1i, R1tok = leaf(36, 43, 46, 38, 56, 46, 5.6, LEAF, { name = "r1", cut = bite })
-- chewed rim
bite:grow(1):cut(bite):each(function(x, y) if R1:has(x, y) then c:put(x, y, CHEW, R1tok) end end)
-- middle pair (angled up)
petiole(30, 31, 28, 30) petiole(33, 30, 35, 29)
local L2 = leaf(28, 30, 21, 26, 14, 22, 4.4, LEAF, { name = "l2", veins = 4 })
local R2 = leaf(35, 29, 42, 25, 49, 21, 4.4, LEAF, { name = "r2", veins = 4 })
-- top: pale young pair + folded tip bud
local L3 = leaf(30, 20, 27, 15, 24, 10, 2.7, YOUNG, { name = "l3", veins = 3, fold = 0.5 })
local R3 = leaf(33, 19, 37, 14, 40, 10, 2.7, YOUNG, { name = "r3", veins = 3, fold = 0.5 })
local B = leaf(31, 16, 31, 12, 32, 7, 1.7, YOUNG, { name = "bud", veins = 2, fold = 0.6, ao = HP.mask():add(L3):add(R3) })

-- node rings on the stem (dark row just under each pair) = AO where parts meet
for _, y in ipairs{ 46, 32, 21 } do sm:each(function(x, yy) if yy == y and not L1:has(x, yy) then c:put(x, yy, STEM[1], sTok) end end) end
-- stem cut end at the bottom: pale end
c:put(32, 58, STEM[6], sTok) c:put(31, 58, STEM[5], sTok) c:put(33, 58, STEM[4], sTok)

-- one cream sparkle on the biggest leaf
c:put(19, 42, "#fff4d6", G.tok("l1"))

G.done(c, NAME)

-- broken-fine-foraging-knife (aB11_1, Opus single pass). Slim mushroom-forager's knife on the diagonal: a boar
-- bristle cleaning brush at the butt, brass ferrule, olive-wood handle with grain, brass bolster, a gently curved
-- steel blade (lit spine, flat with a specular streak, darker grind bevel, bright edge). broken: the blade tip is
-- snapped off on a jagged line and flies away, plus a chip bitten out of the edge; fracture faces pale crystalline
-- steel. AO where the blade enters the bolster and the handle meets the ferrule.
-- quirk: a tiny green inchworm is looping its way along the handle.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_1.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.start(debug.getinfo(1, "S").source)
local S = D.STEEL
local FRAC = "#d2d6e4"
local OLIVE = { "#3c2a1e", "#5e4028", "#86603a", "#a8824e", "#c8a268", "#e6c890" }

-- brush tuft: wedge fanning back from the ferrule, strand-streaked, tips lighter
local ax, ay = 18, 47
local bm = HP.mask()
local strand = {}
for y = ay - 2, ay + 12 do for x = ax - 12, ax + 2 do
  local dx, dy = x - ax, y - ay
  local a = dx * -0.7071 + dy * 0.7071       -- along (toward lower-left)
  local b = dx * 0.7071 + dy * 0.7071        -- across (+ = lower-right)
  local half = 1.9 + a * 0.32
  if a >= 0 and a <= 8.2 - abs(b) * 0.18 and abs(b) <= half then
    bm:set(x, y) strand[K(x, y)] = { a, b }
  end
end end
D.paintMask(c, bm, function(x, y)
  local q = strand[K(x, y)]
  local a, b = q[1], q[2]
  local ln = floor((b + 6) * 1.2)
  local i = 3 + (ln % 2) - (b > 1.2 and 1 or 0) + (b < -1.2 and 1 or 0)
  if a > 6.6 then i = i + 1 end
  if a < 1.4 then i = i - 1 end
  return D.BRISTLE[max(1, min(6, i))]
end)
-- ferrule (brass) with a lit crimp ridge
local fm, fT, fS = D.cyl(c, 18, 47, 21, 44, function() return 2.1 end, D.BRASS)
fm:each(function(x, y) if abs(fT[K(x, y)] - 0.5) < 0.17 and fS[K(x, y)] < 0.5 then c:px(x, y, D.BRASS[6]) end end)
-- handle (olive wood) with figured grain
local hm, hT, hS = D.cyl(c, 21, 44, 32, 33, function(t) return 1.7 + 0.3 * sin(pi * t) end, OLIVE)
local hl = sqrt(242)
hm:each(function(x, y) local k = K(x, y)
  local s, t = hS[k], hT[k]
  local wave = sin(t * hl * 0.55 + 1.3) * 0.35
  if abs(s - wave) < 0.13 and s > -0.75 then c:px(x, y, OLIVE[2]) end
  if abs(s - wave + 0.55) < 0.1 and t > 0.2 and t < 0.8 then c:px(x, y, OLIVE[3]) end
  if t < 0.09 then c:px(x, y, OLIVE[1]) end           -- AO into the ferrule
end)
c:px(24, 40, OLIVE[6]) c:px(25, 39, OLIVE[6])
-- bolster (brass)
D.cyl(c, 32, 33, 34, 31, function() return 2.4 end, D.BRASS)
c:px(31, 32, D.BRASS[6]) c:px(32, 31, D.BRASS[5])

-- blade in local frame: a along the axis (from bolster toward upper-right), b across (+ = edge side, lower-right)
local L = 27
local function spine(a) local u = max(0, (a - 17) / (L - 17)) return -1.8 + 2.6 * u * u end
local function edge(a)
  local u = a / L
  return 1.6 + 1.5 * sin(pi * min(1, u * 1.15)) ^ 0.8 - 2.4 * max(0, (u - 0.7) / 0.3) ^ 1.6
end
local function brk(b) return 19.2 + ((floor(b + 3) % 2 == 0) and 0.8 or -0.4) end   -- jagged fracture
local function inBlade(a, b) return a >= 0 and a <= L and b >= spine(a) and b <= edge(a) end
local function notch(a, b) return abs(a - 11) + (edge(a) - b) * 1.1 < 1.8 end
local ang = -pi / 4
local bmk, BA, BB = D.shape(34, 31, ang, -2, L + 2, -4, 4, function(a, b) return inBlade(a, b) and a < brk(b) and not notch(a, b) end)
local function bladeTone(a, b)
  local e = edge(a)
  local i = 4
  if b - spine(a) < 0.9 then i = 5 end
  if e - b < 2.0 then i = 3 end
  if e - b < 1.0 then i = 6 end
  if a > 14 and i == 4 then i = 3 end
  if abs(b + 0.2) < 0.55 and a > 3 and a < 13 and i == 4 then i = (a < 6) and 6 or 5 end
  if a < 1.2 then i = max(1, i - 2) end
  return S[i]
end
D.paintMask(c, bmk, function(x, y) local k = K(x, y)
  local a, b = BA[k], BB[k]
  if a > brk(b) - 1.0 then return FRAC end
  return bladeTone(a, b)
end)
-- maker's mark: a tiny etched leaf near the bolster
c:px(37, 29, S[3]) c:px(38, 28, S[3])

-- flying tip (rotated, offset up-right)
local tang = ang - 0.45
local tm, TA, TB = D.shape(55, 9, tang, -1, 9, -4, 4, function(a, b)
  local A = a + 19.2
  return inBlade(A, b) and A >= brk(b)
end)
D.paintMask(c, tm, function(x, y) local k = K(x, y)
  local A, b = TA[k] + 19.2, TB[k]
  if A < brk(b) + 0.9 then return FRAC end
  return bladeTone(A, b)
end)
-- a little steel fleck from the edge notch
c:px(48, 33, S[5]) c:px(49, 33, S[3])

-- quirk: inchworm arching on the top of the handle
c:px(24, 37, D.GREEN[3]) c:px(24, 36, D.GREEN[5]) c:px(25, 35, D.GREEN[6]) c:px(26, 35, D.GREEN[5])
c:px(27, 34, D.GREEN[4]) c:px(28, 34, D.GREEN[2])

D.fin(c)

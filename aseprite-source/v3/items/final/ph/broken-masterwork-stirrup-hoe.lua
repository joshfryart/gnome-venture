-- broken-masterwork-stirrup-hoe (final, Opus single pass). A long slim ash shaft (grain dashes, pale end grain at the
-- butt, a dark hang-hole) with a ribbed brass ferrule; a steel shank forks into a yoke that holds a trapezoid stirrup
-- on two brass pivot rivets; the stirrup's bottom bar is the blade (thicker, honed bright edge, specular streak).
-- broken: the shaft has snapped clean through above the middle, with splintered ends and a flying splinter.
-- quirk: an earthworm is draped over the blade bar.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, sin, cos = math.floor, math.sqrt, math.max, math.min, math.sin, math.cos
local c = A.new("broken-masterwork-stirrup-hoe")
local ST, BR, WD = A.STEEL, A.BRASS, A.WOOD

-- shaft axis, bottom -> top
local SB, STP = { 30, 37 }, { 49, 5 }
local dl = sqrt((STP[1] - SB[1])^2 + (STP[2] - SB[2])^2)
local ux, uy = (SB[1] - STP[1]) / dl, (SB[2] - STP[2]) / dl -- points down the shaft (toward the blade)
local vx, vy = -uy, ux
if vx + vy < 0 then vx, vy = -vx, -vy end
local function L(u, v) return { SB[1] + ux * u + vx * v, SB[2] + uy * u + vy * v } end
local function P(u, v) local p = L(u, v) return { p[1], p[2] } end

-- stirrup (local frame: u down from the shaft end, v across)
local outer = HP.poly{ P(2.5, -5.2), P(2.5, 5.2), P(12.2, 8.2), P(12.2, -8.2) }
local inner = HP.poly{ P(4.5, -3.6), P(4.5, 3.6), P(9.4, 5.6), P(9.4, -5.6) }
local stir = outer:copy():cut(inner)
-- yoke arms
local yokeA = A.geo({ L(0, 0), L(2.8, -4.6) }, function() return 0.75 end)
local yokeB = A.geo({ L(0, 0), L(2.8, 4.6) }, function() return 0.75 end)
local shank = A.geo({ L(-3, 0), L(0.6, 0) }, function() return 1.0 end)
-- shaft pieces
local lower = A.geo({ SB, { SB[1] + (STP[1] - SB[1]) * 0.47, SB[2] + (STP[2] - SB[2]) * 0.47 } }, function(t) return t < 0.2 and 1.55 or 1.25 end)
local ua = 0.07 -- the upper piece is knocked aside and turned slightly
local function up(t)
  local x, y = SB[1] + (STP[1] - SB[1]) * t, SB[2] + (STP[2] - SB[2]) * t
  local ox, oy = SB[1] + (STP[1] - SB[1]) * 0.56, SB[2] + (STP[2] - SB[2]) * 0.56
  local dx, dy = x - ox, y - oy
  return { ox + 3 + dx * cos(ua) - dy * sin(ua), oy - 1 + dx * sin(ua) + dy * cos(ua) }
end
local upper = A.geo({ up(0.56), up(1) }, function() return 1.25 end)

-- paint: stirrup + yoke behind, then shank, ferrule, shaft
local sg = A.slab(c, stir, 1.4, ST, { ao = { yokeA.m, yokeB.m }, name = "stirrup" })
-- honed blade edge (outer edge of the bottom bar) + specular streak on the bar
stir:each(function(x, y)
  local rx, ry = x - SB[1], y - SB[2]
  local u = rx * ux + ry * uy
  local v = rx * vx + ry * vy
  if u > 11.3 and not stir:has(x + floor(ux * 1.5 + .5), y + floor(uy * 1.5 + .5)) then c:put(x, y, ST[6], sg.tok)
  elseif u > 10.2 and u < 11.0 and v < 1 and v > -6 then c:put(x, y, ST[5], sg.tok) end
end)
A.paint(c, yokeA, ST, { name = "yoke" }) A.paint(c, yokeB, ST, { name = "yoke" })
-- brass pivot rivets
for _, q in ipairs{ L(3.2, -4.6), L(3.2, 4.6) } do
  local x, y = floor(q[1] + .5), floor(q[2] + .5)
  local tk = A.tok("rivet")
  c:put(x, y, BR[4], tk) c:put(x + 1, y, BR[2], tk) c:put(x, y + 1, BR[2], tk) c:put(x + 1, y + 1, BR[1], tk)
  c:put(x, y, BR[6], tk)
end
A.paint(c, shank, ST, { name = "shank" })
-- shaft lower piece: ferrule (brass, ribbed) + wood
local fer, lw = A.sub(lower, 0, 0.2), A.sub(lower, 0.2, 1)
A.paint(c, lw, WD, { ao = { fer.m }, name = "shaftL" })
A.grain(c, lw, 3)
A.paint(c, fer, BR, { name = "ferrule" })
A.band(c, lower, 0.07, BR, fer.tok, true) A.band(c, lower, 0.14, BR, fer.tok, true)
A.streak(c, fer, -0.7, -0.3, 0, 0.2, BR[6], 3)
A.paint(c, upper, WD, { name = "shaftU" })
A.grain(c, upper, 7)
A.streak(c, upper, -0.7, -0.4, 0.1, 0.8, WD[6], 4)
-- pale end grain at the butt + dark hang-hole
upper.m:each(function(x, y) local k = K(x, y) if upper.T[k] > 0.965 then c:put(x, y, (upper.S[k] < 0.3) and WD[6] or WD[5], upper.tok) end end)
do local x, y = A.at(upper, 0.86) c:put(floor(x + .5), floor(y + .5), WD[1], upper.tok) c:put(floor(x + .5), floor(y + 1.5), WD[2], upper.tok) end
-- splintered ends: pale fresh wood spikes poking across the break
local ex, ey = A.at(lower, 1)
local sx, sy = A.at(upper, 0)
local tk = A.tok("splinter")
local function sp(x, y, col) c:put(floor(x + .5), floor(y + .5), col, tk) end
sp(ex - ux * 1 - vx * 1, ey - uy * 1 - vy * 1, WD[6]) sp(ex - ux * 2 - vx * 1, ey - uy * 2 - vy * 1, WD[5])
sp(ex - ux * 1 + vx * 1, ey - uy * 1 + vy * 1, WD[5])
sp(sx + ux * 1 + vx * 1, sy + uy * 1 + vy * 1, WD[5]) sp(sx + ux * 2 + vx * 1, sy + uy * 2 + vy * 1, WD[4])
sp(sx + ux * 1, sy + uy * 1, WD[6])
-- flying splinter
A.chip(c, { { 31, 17 }, { 34.5, 15.5 }, { 33, 18 } }, WD)
-- quirk: earthworm draped over the blade bar
do
  local w = A.geo({ L(8.0, -2.6), L(10.6, -3.6), L(12.4, -1.8), L(14.4, -2.4) }, function(t) return t > 0.92 and 0.6 or 0.85 end)
  A.paint(c, w, A.PINK, { name = "worm", amb = 0.2 })
  for _, t in ipairs{ 0.3, 0.5, 0.7 } do A.band(c, w, t, A.PINK, w.tok, true) end
  local hx, hy = A.at(w, 0.0) c:put(floor(hx + .5), floor(hy + .5), A.PINK[6], w.tok)
end
A.save(c, "broken-masterwork-stirrup-hoe")

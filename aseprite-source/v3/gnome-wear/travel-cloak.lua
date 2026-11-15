-- travel-cloak: moss green wool cloak folded in layers, the pointed hood lying on top with its tip
-- flopped over the edge, a wooden toggle on a cord at the throat.
-- quirk: a little orange autumn leaf caught in the bottom fold.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "travel-cloak" }
local weave = function(x, y, i) if (x + y) % 4 == 0 and X.hash(x, y, 5) < 0.7 then return -1 end end

local function lay(m, bias, cuts)
  local b = {} m:each(function(x, y) b[K(x, y)] = bias end)
  local i = W.lit(c, m, R.cloak, { R = 3, bias = b, cuts = cuts })
  W.retone(c, m, i, R.cloak, weave)
  return i
end
-- folded layers, bottom first
local L1 = c:rrect(8, 41, 55, 52, 4)
local L2 = c:rrect(9, 33, 54, 44, 4)
local top = c:poly{ {14,17}, {50,17}, {55,35}, {9,35} }:add(c:rrect(9, 30, 55, 36, 3))
lay(L1, -1)
-- lining peeking out of the fold ends on the right
W.sep(c, L2, L1, R.cloak[1])
lay(L2, 0)
for y = 45, 49 do c:put(54, y, R.lining[3]) end
for y = 37, 41 do c:put(53, y, R.lining[3]) end
W.sep(c, top, L2, R.cloak[1])
lay(top, 1, { .22, .4, .58, .74, .9 })
-- front lips: lit roll along the bottom edge of each layer's top
for x = 10, 53 do if top:has(x, 35) then c:put(x, 34, R.cloak[3]) c:put(x, 35, R.cloak[2]) end end
for x = 11, 52 do c:put(x, 44, R.cloak[1]) end
-- hood folded flat on top as a triangle, its point flopped over the front edge; tan lining rim
local hood = c:poly{ {15,19}, {49,19}, {45,27}, {37,38}, {33,43}, {31,43}, {27,38}, {19,27} }
W.sep(c, hood, top:copy():add(L2), R.cloak[1])
local hb = {} hood:each(function(x, y) hb[K(x, y)] = (y > 35) and -1 or 0 end)
local hi = W.lit(c, hood, R.cloak, { R = 4, bias = hb, cuts = { .2, .36, .54, .7, .86 } })
W.retone(c, hood, hi, R.cloak, weave)
-- lining rim: lit on the upper left edges, shaded on the right
hood:edge():each(function(x, y) c:put(x, y, (x < 32) and R.lining[5] or R.lining[3]) end)
hood:shrink(1):edge():each(function(x, y) if x >= 32 and y > 20 then c:put(x, y, R.cloak[2]) end end)
-- centre seam down the hood
for y = 21, 40 do c:put(32, y, R.cloak[2]) c:put(31, y, R.cloak[y < 30 and 5 or 4]) end
-- contact shadow on the front below the flopped tip
W.put(c, { {30,44}, {31,44}, {32,44}, {33,44}, {34,44}, {35,43}, {36,42}, {29,43} }, R.cloak[1])
-- tiny bead on the hood point
local bead = c:ellipse(32, 45, 1.6, 1.6)
W.lit(c, bead, R.wood, { R = 1 }) c:put(31, 44, R.wood[6])
-- cord loop + wooden toggle at the throat (hood base)
local cord = c:line({ {36,22}, {40,21}, {43,23}, {40,25}, {36,24} }, 1)
cord:each(function(x, y) c:put(x, y, R.strap[2]) end)
local tog = c:rrect(23, 21, 33, 24, 1)
W.lit(c, tog, R.wood, { R = 1 })
W.hline(c, 24, 32, 21, R.wood[6]) W.hline(c, 24, 32, 24, R.wood[2])
W.vline(c, 28, 22, 23, R.wood[3]) c:put(29, 22, R.wood[4])
c:put(24, 22, W.cream)
W.hline(c, 24, 33, 25, R.cloak[1])
-- quirk: autumn leaf in the bottom fold
local leaf = c:poly{ {11,45}, {15,43}, {19,45}, {15,48} }
W.lit(c, leaf, R.autumn, { R = 1 })
c:put(12, 45, R.autumn[6]) c:put(14, 46, R.autumn[2]) c:put(15, 46, R.autumn[2]) c:put(20, 46, R.strap[3])
-- wool pop
c:put(13, 31, R.cloak[6]) c:put(14, 31, R.cloak[6])
W.save(c, "travel-cloak")

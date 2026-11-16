-- travel-cloak ICON redo (64x64): a hooded cloak standing on its own: pointed hood with a dark opening,
-- sloped shoulders flaring to a scalloped hem, fold shading down the wool, wooden toggle at the throat.
-- Was a boxy stack of folded rectangles. quirk: a little autumn leaf caught in the hem.
-- Run: aseprite -b --script-param out=<dir>/ --script travel-cloak.lua
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local OUT = app.params.out or (DIR .. "/")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local sin, sqrt, floor, pi, abs = math.sin, math.sqrt, math.floor, math.pi, math.abs
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "travel-cloak" }
local weave = function(x, y, i) if (x + y) % 4 == 0 and X.hash(x, y, 5) < 0.7 then return -1 end end

-- body: A-line from the shoulders, scalloped hem
local body = c:poly{ {21,24}, {43,24}, {49,31}, {54,44}, {58,56}, {6,56}, {10,44}, {15,31} }
local scal = HP.mask()
for x = 4, 60 do
  local u = (((x - 6) % 13) / 6.5) - 1
  local yb = 54 + floor(3.4 * sqrt(math.max(0, 1 - u * u)) + 0.5)
  for y = yb + 1, 60 do scal:add(c:rect(x, y, x, y)) end
end
body:cut(scal)

-- hood: pointed cowl, tip flopped slightly to the right
local hood = c:poly{ {31,2}, {35,4}, {40,9}, {43,16}, {43,24}, {40,29}, {24,29}, {21,24}, {21,16}, {24,9}, {28,4} }
hood:add(c:poly{ {34,3}, {40,2}, {46,6}, {43,10}, {38,8} })
local hole = c:ellipse(32, 19, 5.5, 7)
local rim = hole:grow(1):cut(hole):clip(hood)

-- body shading: cylinder + fold waves
local n = {}
body:each(function(x, y)
  local half = 6 + (y - 24) * 0.82
  local t = math.max(-0.97, math.min(0.97, (x - 32) / half))
  local fold = 0.42 * sin((x - 32) / 4.2 * pi * 0.55 + 0.6)
  local nx = t * 0.8 + fold
  local nz = sqrt(math.max(0.05, 1 - nx * nx))
  n[K(x, y)] = { nx, -0.2, nz }
end)
local bias = {}
local idx = W.toneN(c, body, n, R.cloak, { cuts = { .22, .4, .58, .74, .9 } })
W.retone(c, body, idx, R.cloak, weave)
-- fold creases (deep) with a lit lip beside them
local function crease(pts, col)
  c:line(pts, 1):clip(body):each(function(x, y) c:put(x, y, col) end)
end
crease({ {24,34}, {21,44}, {19,54} }, R.cloak[1])
crease({ {40,34}, {43,44}, {46,54} }, R.cloak[1])
crease({ {28,37}, {27,46}, {27,53} }, R.cloak[2])
crease({ {36,37}, {37,46}, {38,53} }, R.cloak[2])
for _, p in ipairs{ {25,36}, {24,40}, {22,44}, {21,49}, {29,40}, {28,45} } do if body:has(p[1], p[2]) then c:put(p[1], p[2], R.cloak[5]) end end
-- front opening: right panel laps over the left
for y = 32, 55 do if body:has(32, y) then c:put(32, y, R.cloak[1]) c:put(31, y, R.cloak[5]) end end
-- hem lip: the scallop edge reads as a rolled edge
body:edge():each(function(x, y) if y >= 52 then c:put(x, y, R.cloak[x < 32 and 3 or 2]) end end)
-- tan lining peeking at the hem on the lap (one small triangle)
W.put(c, { {33,53}, {34,53}, {35,53}, {34,52} }, R.lining[3])

-- hood on top of the body
W.sep(c, hood, body, R.cloak[1])
local hb = {}
hood:each(function(x, y) hb[K(x, y)] = (x > 40 and y < 10) and 1 or 0 end)
local hidx = W.lit(c, hood:copy():cut(hole), R.cloak, { R = 4, bias = hb, cuts = { .2, .36, .54, .7, .88 } })
W.retone(c, hood, hidx, R.cloak, weave)
-- dark opening with a tan lining rim (lit upper-left)
c:fillMask(hole, R.cloak[1])
hole:each(function(x, y) if y >= 22 and x > 30 then c:put(x, y, "#12201f") end end)
rim:each(function(x, y) c:put(x, y, (x <= 32 and y < 24) and R.lining[5] or R.lining[3]) end)
for x = 28, 31 do c:put(x, 14, R.lining[6]) end
-- hood seam to the tip and a fold in the flopped tip
for y = 4, 9 do c:put(31, y, R.cloak[2]) end
W.put(c, { {38,6}, {40,5}, {42,6} }, R.cloak[2])
c:put(36, 4, R.cloak[6]) c:put(37, 4, R.cloak[6])

-- cord + wooden toggle at the throat
local cord = c:line({ {23,31}, {27,33}, {32,32}, {37,33}, {41,31} }, 1)
cord:each(function(x, y) c:put(x, y, R.strap[3]) end)
local tog = c:rrect(29, 31, 35, 34, 1)
W.lit(c, tog, R.wood, { R = 1 })
W.hline(c, 30, 34, 31, R.wood[6]) W.hline(c, 30, 34, 34, R.wood[2])
c:put(32, 32, R.wood[2]) c:put(32, 33, R.wood[2]) c:put(30, 32, W.cream)

-- quirk: autumn leaf caught in the hem
local leaf = c:poly{ {44,50}, {48,48}, {52,50}, {48,54} }
W.lit(c, leaf, R.autumn, { R = 1 })
c:put(45, 50, R.autumn[6]) c:put(47, 51, R.autumn[2]) c:put(48, 51, R.autumn[2]) c:put(53, 51, R.strap[3])
-- wool pop
c:put(18, 33, R.cloak[6]) c:put(19, 33, R.cloak[6])

c:finish{ outline = true }
G.centre(c)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = OUT .. "travel-cloak.aseprite", png = OUT .. "travel-cloak.png", scale = 1 }

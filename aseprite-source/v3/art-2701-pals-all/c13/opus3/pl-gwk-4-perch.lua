-- Crown Points (pl-gwk-4), perch sprite 36x36. Opus second pass (c13/opus2), hand-built at this size.
-- A snapped-off segment of the king's crown: curved worn-gold band with jagged ends, four ball-tipped points,
-- a ruby and a sapphire, 2x3 pill eyes on the band.
-- quirk: it is old: the fourth point is bent over to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-4-perch", 36)

local GOLD = { "#5a2e14", "#91501e", "#c9802a", "#eeb240", "#fbd870", "#fff2b8" }
local RUBY = { "#5a1028", "#a8203a", "#e8485a", "#ff9a9a" }
local SAPH = { "#14285a", "#2a4ea8", "#4a8ae8", "#a8d0ff" }

c:groundShadow(17, 32, 14, 1)
local function ybot(x) local u = (x - 17) / 15 return 27 + math.floor(2.5 * math.sqrt(math.max(0, 1 - u * u)) + .5) end
local pts = { 7, 13, 20, 26 }
local tips = {}
for k, bx in ipairs(pts) do
  local yb = ybot(bx) - 11
  local m, tx, ty
  if k < 4 then
    tx, ty = bx, yb - 9
    m = c:poly{ { bx - 2.5, yb + 1 }, { bx + 2.5, yb + 1 }, { tx + .5, ty } }
  else
    tx, ty = bx + 6, yb - 5
    m = c:poly{ { bx - 2.5, yb + 1 }, { bx + 2.5, yb + 1 }, { bx + 2, yb - 2 }, { tx + 1, ty + 1 }, { tx, ty - 1 }, { bx - 1.5, yb - 4 } }
  end
  local I, T = O.shade(c, m, GOLD, { R = 1, amb = .3, wrap = .45, rim = true, sep = GOLD[1] })
  O.tex(c, I, T, GOLD, function(x, y, i) if k < 4 and x > bx then return -1 end end)
  tips[k] = { tx, ty }
end
local band = HP.mask()
for x = 3, 31 do local yb = ybot(x) for y = yb - 11, yb do band:set(x, y) end end
band:cut(c:poly{ { 2, 17 }, { 4, 17 }, { 3, 21 }, { 5, 24 }, { 3, 28 }, { 2, 30 } })
band:cut(c:poly{ { 33, 17 }, { 31, 17 }, { 32, 21 }, { 30, 24 }, { 32, 28 }, { 33, 30 } })
local bn = {}
band:each(function(x, y)
  local sx = math.max(-.95, math.min(.95, (x - 17) / 16))
  local yy = (y - (ybot(x) - 4.5)) / 7
  local l = math.sqrt(sx * sx + yy * yy + .6)
  bn[K(x, y)] = { sx / l, yy / l, math.sqrt(.6) / l }
end)
local bI, bT = O.shadeN(c, band, bn, GOLD, { amb = .28, wrap = .45, rim = true, bounce = "#8a6ab0", bmax = 3, sep = GOLD[1] })
O.tex(c, bI, bT, GOLD, function(x, y, i) local yb = ybot(x) if y == yb - 1 and x % 3 == 0 then return -2 end end)
for _, t in ipairs(tips) do
  O.shade(c, c:ellipse(t[1], t[2] - 1, 1.2, 1.2), GOLD, { sphere = { t[1] - 1, t[2] - 2, 2 }, amb = .4, wrap = .5, sep = GOLD[2] })
end
O.flat(c, c:rect(5, 22, 6, 23), RUBY[2], "ruby") O.dot(c, 5, 22, RUBY[4])
O.flat(c, c:rect(28, 22, 29, 23), SAPH[2], "saph") O.dot(c, 28, 22, SAPH[4])

c:eyeSmall(11, 20)
c:eyeSmall(21, 20)
O.dot(c, 9, 24, P.petal.base) O.dot(c, 24, 24, P.petal.base)
O.dots(c, { { 14, 25 }, { 15, 26 }, { 16, 26 }, { 17, 26 }, { 18, 25 } }, P.ink)

O.done(c, "pl-gwk-4-perch", function(c) c:sparkle(3, 6) end)

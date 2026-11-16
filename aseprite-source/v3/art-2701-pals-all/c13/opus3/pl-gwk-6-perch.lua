-- Grey Wolf Whistle (pl-gwk-6), perch sprite 36x36. Opus second pass (c13/opus2), hand-built at this size.
-- Old pewter pea whistle: round chamber with a pale wolf muzzle and black nose, 2x3 pill eyes, tapered mouthpiece
-- to the left, two pricked wolf ears, red cord and gold tassel on a ring.
-- quirk: the wolves still answer: blow marks on the left, two pale answering arcs on the right. Rare: a sparkle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-gwk-6-perch", 36)

local PEW  = { "#2a2c3c", "#464a5e", "#6a7084", "#959caf", "#c2c8d4", "#e6e9ef" }
local MUZ  = { "#8a8e9e", "#b8bcc8", "#dcdfe6" }
local CORD = { "#4e1620", "#86242e", "#c23e3a", "#ea7458" }
local GOLD = { "#6a3e1a", "#a8662a", "#e0a03a", "#f8d468", "#fff0b0" }

c:groundShadow(20, 33, 11, 1)
local cord, cn = O.tube({ { 29, 23 }, { 32, 25 }, { 32, 28 }, { 29, 29 } }, function() return .8 end)
O.shadeN(c, cord, cn, CORD, { amb = .35, wrap = .5, sep = CORD[1] })
O.shade(c, c:poly{ { 28, 29 }, { 30, 29 }, { 31, 33 }, { 27, 33 } }, GOLD, { R = 1, amb = .35, wrap = .5, cuts = { .25, .45, .65, .82 }, sep = GOLD[1] })
for _, e in ipairs({ { 16, 1 }, { 25, -1 } }) do
  local bx, s = e[1], e[2]
  O.shade(c, c:poly{ { bx - 3, 15 }, { bx + 3, 15 }, { bx + s, 4 } }, PEW, { R = 1, amb = .3, wrap = .45, rim = true, sep = PEW[1] })
  O.dots(c, { { bx, 13 }, { bx, 12 }, { bx + s, 10 } }, "#4a4452")
end
local ch = c:ellipse(21, 21, 8.5, 8)
O.shade(c, ch, PEW, { sphere = { 18, 17, 12 }, amb = .28, wrap = .45, rim = true, bounce = "#7a8ab8", bmax = 3, sep = PEW[1] })
local mp = c:poly{ { 3, 14 }, { 15, 13 }, { 15, 19 }, { 3, 18 } }
local mn = {}
mp:each(function(x, y) local sy = (y - 16) / 3.5 mn[K(x, y)] = { -.15, sy, math.sqrt(math.max(.05, 1 - sy * sy)) } end)
O.shadeN(c, mp, mn, PEW, { amb = .3, wrap = .45, rim = true, sep = PEW[1] })
O.flat(c, c:rect(3, 15, 3, 17), PEW[1], "bore")
O.flat(c, c:rect(11, 13, 14, 13), PEW[1], "slot")
local ring = c:ellipse(29.5, 22, 1.8, 1.8)
O.shade(c, ring, GOLD, { sphere = { 29, 21, 2.5 }, amb = .35, wrap = .5, cuts = { .25, .45, .65, .82 }, sep = GOLD[1] })

O.shade(c, c:ellipse(21, 25, 4, 2.5), MUZ, { R = 1, amb = .45, wrap = .5, cuts = { .35, .7 } })
O.dots(c, { { 20, 23 }, { 21, 23 }, { 22, 23 } }, P.ink)
O.dots(c, { { 19, 25 }, { 20, 26 }, { 21, 26 }, { 22, 26 }, { 23, 25 } }, P.ink)
c:eyeSmall(16, 18)
c:eyeSmall(24, 18)
O.dot(c, 15, 23, P.petal.base) O.dot(c, 27, 23, P.petal.base)

O.done(c, "pl-gwk-6-perch", function(c)
  for _, p in ipairs({ { 2, 11 }, { 1, 10 }, { 1, 16 }, { 2, 21 }, { 1, 22 } }) do c:put(p[1], p[2], P.ink) end
  for _, a in ipairs({ { 32, 9 }, { 33, 15 } }) do
    for _, q in ipairs({ { 0, 0 }, { 1, -1 }, { 1, 1 } }) do c:put(a[1] + q[1], a[2] + q[2], "#a8d8ec") end
  end
  c:sparkle(30, 3)
end)

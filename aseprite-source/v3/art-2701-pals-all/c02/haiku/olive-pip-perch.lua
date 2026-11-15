-- Olive Pip (ow-olive-pip), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: a little olive tree is planted beside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("olive-pip-perch", 36)

local OLIVE = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a" }

c:groundShadow(16, 32, 9, 2)

-- two leaf knobs on top
local function leaf(pts, w0, w1)
  local m, n = O.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  O.shadeN(c, m, n, OLIVE, { amb = .2, wrap = .35, sep = OLIVE[1] })
end
leaf({ { 15, 11 }, { 13, 7 }, { 11, 4 }, { 10, 2 } }, 1.4, .4)
leaf({ { 21, 11 }, { 23, 7 }, { 25, 4 }, { 26, 2 } }, 1.4, .4)

-- the fruit
local body = c:ellipse(18, 19, 10, 10)
O.shade(c, body, OLIVE, { sphere = { 15, 15, 9 }, sep = OLIVE[1] })
O.dot(c, 13, 14, OLIVE[4])

-- quirk: tiny olive tree planted beside it
O.flat(c, c:rect(29, 26, 30, 31), WOOD[2], "trunk")
O.shade(c, c:ellipse(30, 22, 3, 3), OLIVE, { R = 1, sep = OLIVE[1] })

c:eyeSmall(13, 17)
c:eyeSmall(22, 17)
c:cheek(9, 21)
c:cheek(25, 21)
O.dots(c, { { 17, 20 }, { 18, 20 } }, OLIVE[1])
O.dots(c, { { 15, 23 }, { 16, 24 }, { 17, 24 }, { 18, 24 }, { 19, 23 } }, P.ink)

O.done(c, "olive-pip-perch")

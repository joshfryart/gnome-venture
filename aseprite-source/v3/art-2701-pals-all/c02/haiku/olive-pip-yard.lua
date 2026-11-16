-- Olive Pip (ow-olive-pip), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Bloomcaller, common. A round olive-green fruit with two leaf knobs on top.
-- quirk: a little olive tree is planted beside it, and it thinks the tree is its own.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("olive-pip-yard", 64)

local OLIVE = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a" }

c:groundShadow(30, 58, 15, 3)

-- two leaf knobs on top (behind the fruit)
local function leaf(pts, w0, w1)
  local m, n = O.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  O.shadeN(c, m, n, OLIVE, { amb = .2, wrap = .35, sep = OLIVE[1] })
end
leaf({ { 28, 26 }, { 25, 19 }, { 22, 13 }, { 20, 9 } }, 2.2, .7)
leaf({ { 36, 26 }, { 39, 19 }, { 42, 13 }, { 44, 9 } }, 2.2, .7)

-- the olive fruit
local body = c:ellipse(30, 38, 15, 15)
O.shade(c, body, OLIVE, { sphere = { 26, 33, 14 }, sep = OLIVE[1] })
-- waxy bloom highlight
O.dots(c, { { 21, 30 }, { 22, 30 }, { 21, 31 } }, OLIVE[4])

-- face: locked eyes, cheeks, nose, smile (body centre x=30)
c:eyeLocked(22, 35)
c:eyeLocked(33, 35)
c:cheek(18, 41)
c:cheek(38, 41)
O.dots(c, { { 29, 41 }, { 30, 41 } }, OLIVE[1])
O.dots(c, { { 27, 44 }, { 28, 45 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 44 } }, P.ink)

-- quirk: a little olive tree planted beside it
O.flat(c, c:rect(50, 46, 52, 56), WOOD[2], "trunk")
O.dot(c, 51, 50, WOOD[3])
O.shade(c, c:ellipse(51, 42, 5, 5), OLIVE, { R = 2, sep = OLIVE[1] })
O.dots(c, { { 48, 40 }, { 53, 39 } }, OLIVE[4])

O.done(c, "olive-pip-yard")

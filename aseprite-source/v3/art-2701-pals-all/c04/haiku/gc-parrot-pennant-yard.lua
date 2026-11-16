-- gc-parrot-pennant-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-parrot-pennant-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 58, 12, 2)
c:part(c:ellipse(30, 38, 14, 15), "ember")
c:part(c:ellipse(26, 38, 8, 9), "moss")
c:part(c:poly{ {18,44},{4,46},{6,54},{18,52} }, "sea")
c:part(c:ellipse(34, 20, 10, 9), "ember")
c:part(c:poly{ {41,17},{50,21},{42,25} }, "gold")
c:part(c:line({ {34,10},{34,5},{39,4} }, 2), "gold")
c:eyeLocked(27, 17)
c:eyeLocked(34, 17)
c:sparkle(54, 12)
c:sparkle(57, 26)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

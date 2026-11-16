-- gc-yam-nub-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-yam-nub-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 58, 17, 3)
local body = c:ellipse(32, 38, 17, 14)
body:add(c:ellipse(20, 46, 6, 5))
body:add(c:ellipse(45, 46, 6, 6))
c:part(body, "wood")
c:part(c:rect(30, 20, 34, 25), "wood")
c:part(c:ellipse(28, 18, 3, 2), "moss")
c:part(c:ellipse(37, 18, 3, 2), "moss")
c:eyeLocked(24, 34)
c:eyeLocked(36, 34)
c:fillMask(c:ellipse(32, 43, 4, 2), P.ink)
c:px(32, 44, P.petal.base)
c:sparkle(50, 22)
c:sparkle(12, 24)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

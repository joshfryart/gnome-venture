-- gc-calabash-cup-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-calabash-cup-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 58, 15, 3)
local body = c:ellipse(32, 40, 17, 15)
body:add(c:ellipse(32, 23, 8, 8))
c:part(body, "gold")
c:part(c:ellipse(32, 13, 3, 3), "gold")
c:part(c:ellipse(53, 54, 2, 2), "sea")
c:eyeLocked(24, 36)
c:eyeLocked(35, 36)
for _, p in ipairs({ {29,43},{30,44},{31,44},{32,44},{33,43} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

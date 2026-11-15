-- gc-drum-tap-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-drum-tap-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:part(c:rect(14, 28, 50, 50), "ember")
c:part(c:rect(14, 47, 50, 49), "gold")
c:part(c:ellipse(32, 28, 18, 5), "sky")
c:part(c:ellipse(20, 24, 2, 2), "gold")
c:part(c:ellipse(44, 24, 2, 2), "gold")
c:part(c:ellipse(9, 9, 1, 2), "sea")
c:part(c:ellipse(56, 10, 1, 2), "sea")
c:part(c:ellipse(58, 20, 1, 2), "sea")
c:eyeLocked(23, 37)
c:eyeLocked(36, 37)
for _, p in ipairs({ {27,44},{28,45},{29,45},{30,45},{31,45},{32,45},{33,45},{34,45},{35,45},{36,44} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

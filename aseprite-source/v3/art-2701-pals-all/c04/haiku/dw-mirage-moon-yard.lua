-- dw-mirage-moon-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "dw-mirage-moon-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local moon = c:ellipse(30, 34, 18, 18)
moon:cut(c:ellipse(40, 28, 15, 15))
c:part(moon, "dusk")
c:part(c:ellipse(10, 7, 2, 2), "gold")
c:px(10, 7, P.ink)
c:eyeLocked(14, 31)
c:eyeLocked(20, 31)
for _, p in ipairs({ {17,40},{18,41},{19,41},{20,41},{21,40} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(50, 14)
c:sparkle(44, 48)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

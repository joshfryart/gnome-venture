-- progress-house FIRST DRAFT. 18x18 icon: cottage with a round door. quirk: one wonky chimney.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "progress-house"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:part(c:rect(12, 1, 14, 6), "stone", { band = 1, nopop = true })
c:part(c:rect(3, 8, 14, 16), { hi = P.cream, base = P.cream, shade = "#ead7b4", deep = P.wood.base }, { band = 1, nopop = true })
c:part(c:poly{ {0,8},{8,1},{16,8} }, "ember", { band = 2, pop = { x = 5, y = 5 } })
c:part(c:ellipse(8.5, 13.5, 2.5, 3), "wood", { band = 1, nopop = true })
c:px(9, 14, P.gold.hi)
c:part(c:rect(12, 10, 13, 11), "sea", { band = 1, nopop = true, inner = false })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

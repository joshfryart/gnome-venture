-- progress-sprout FIRST DRAFT. 18x18 icon: sprout in soil. quirk: a droplet on the left leaf.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "progress-sprout"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:part(c:ellipse(9, 14, 7, 3):clip(c:rect(0, 11, 17, 17)), "wood", { band = 1, pop = { x = 5, y = 13 } })
c:part(c:rect(8, 6, 9, 12), "moss", { band = 1, nopop = true })
c:part(c:poly{ {8,8},{1,3},{4,1},{8,4} }, "moss", { band = 1, pop = { x = 3, y = 3 } })
c:part(c:poly{ {9,6},{12,0},{17,2},{15,6} }, "moss", { band = 1, pop = { x = 13, y = 2 } })
c:px(3, 6, P.sea.hi)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

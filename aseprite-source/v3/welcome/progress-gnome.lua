-- progress-gnome FIRST DRAFT. 18x18 icon: gnome head with a red hat. quirk: hat tip flops to one side.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "progress-gnome"
local c = HP.canvas{ w = 18, h = 18, scale = 1, name = NAME }
c:part(c:poly{ {2,9},{8,1},{14,0},{16,3},{13,4},{15,9} }, "ember", { band = 1, pop = { x = 7, y = 4 } })
c:part(c:ellipse(9, 11, 6, 5), "skinA", { band = 1, nopop = true })
c:part(c:poly{ {3,12},{15,12},{13,17},{9,17},{5,17} }, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
c:part(c:rect(2, 8, 15, 9), "ember", { band = 1, nopop = true, inner = false })
c:px(6, 10, P.ink) c:px(6, 11, P.ink) c:px(11, 10, P.ink) c:px(11, 11, P.ink)
c:px(8, 12, P.petal.base) c:px(9, 12, P.petal.base)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

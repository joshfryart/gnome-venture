-- pack-kit FIRST DRAFT. 32x32 icon: leather satchel with a trowel and a watering-can spout. quirk: a daisy tucked in the buckle strap.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "pack-kit"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
c:groundShadow(15, 30, 11, 1)
-- trowel poking out of the top-left
c:part(c:line({ {8,13},{5,7} }, 3), "wood", { band = 1, nopop = true })
c:part(c:poly{ {1,1},{7,0},{9,5},{4,7} }, "stone", { band = 1, pop = { x = 3, y = 2 } })
-- watering-can spout on the right
c:part(c:line({ {22,22},{26,17},{29,11} }, 3), "stone", { band = 1, nopop = true })
c:part(c:ellipse(29.5, 9.5, 2.5, 2.5), "sea", { band = 1, pop = { x = 28, y = 8 } })
c:px(29, 10, P.sea.deep)
-- satchel
local bag = c:rrect(4, 14, 24, 29, 3)
c:part(bag, "wood", { band = 3, pop = { x = 6, y = 17 } })
local flap = c:rrect(4, 14, 24, 21, 3)
c:part(flap, { hi = "#c98a56", base = "#9a5a38", shade = P.wood.shade, deep = P.wood.deep }, { band = 1, nopop = true })
c:fillMask(c:rect(6, 21, 22, 21), P.wood.deep)
-- strap + buckle
c:part(c:rect(12, 19, 15, 26), "wood", { band = 1, nopop = true, inner = false })
c:part(c:rect(11, 22, 16, 25), "gold", { band = 1, nopop = true })
c:px(13, 23, P.wood.deep) c:px(14, 23, P.wood.deep)
-- quirk daisy
c:px(8, 18, P.cream) c:px(7, 18, P.cream) c:px(9, 18, P.cream) c:px(8, 17, P.cream) c:px(8, 19, P.cream) c:px(8, 18, P.gold.base)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }

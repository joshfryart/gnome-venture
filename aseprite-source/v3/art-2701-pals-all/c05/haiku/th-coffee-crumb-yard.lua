-- Coffee Crumb (th-coffee-crumb), yard 64x64. Haiku first pass. Common, brewroot.
-- Roasts the beans with great care and a very large hat.
-- quirk: a thin curl of steam rises from the top of the hat.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "th-coffee-crumb-yard" }
c:groundShadow(32, 59, 16, 3)
c:part(c:rect(23, 50, 27, 57), "wood", { band = 1 })
c:part(c:rect(37, 50, 41, 57), "wood", { band = 1 })
c:part(c:ellipse(32, 40, 17, 12), "wood")
c:part(c:ellipse(32, 24, 26, 4), "dusk")
c:part(c:rrect(19, 6, 45, 24, 4), "dusk")
c:stitch({ { 20, 20 }, { 44, 20 } })
c:px(40, 4, P.sky.hi) c:px(41, 3, P.sky.hi) c:px(40, 2, P.sky.base) c:px(41, 1, P.sky.hi)
c:sparkle(24, 31)
c:eyeLocked(25, 36) c:eyeLocked(35, 36)
c:cheek(21, 43) c:cheek(40, 43)
c:px(32, 42, P.wood.deep) c:px(33, 42, P.wood.deep)
c:px(29, 46, P.ink) c:px(30, 47, P.ink) c:px(31, 47, P.ink) c:px(32, 47, P.ink) c:px(33, 47, P.ink) c:px(34, 46, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-coffee-crumb-yard.aseprite", png = out .. "th-coffee-crumb-yard.png", scale = 1 }

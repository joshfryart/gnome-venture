-- Coffee Crumb (th-coffee-crumb), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: the huge hat (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "th-coffee-crumb-perch" }
c:groundShadow(18, 33, 9, 2)
c:part(c:rect(13, 29, 14, 32), "wood", { band = 1 })
c:part(c:rect(21, 29, 22, 32), "wood", { band = 1 })
c:part(c:ellipse(18, 22, 9, 7), "wood")
c:part(c:ellipse(18, 12, 13, 2), "dusk")
c:part(c:rrect(9, 3, 27, 12, 2), "dusk")
c:stitch({ { 10, 9 }, { 26, 9 } })
c:eyeSmall(14, 20) c:eyeSmall(21, 20)
c:cheek(11, 24) c:cheek(24, 24)
c:px(18, 23, P.wood.deep) c:px(19, 23, P.wood.deep)
c:px(16, 26, P.ink) c:px(17, 27, P.ink) c:px(18, 27, P.ink) c:px(19, 27, P.ink) c:px(20, 26, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-coffee-crumb-perch.aseprite", png = out .. "th-coffee-crumb-perch.png", scale = 1 }

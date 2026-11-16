-- Tall Tiptoe (th-tall-tiptoe), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: the leaf on its head (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "th-tall-tiptoe-perch" }
c:groundShadow(14, 33, 8, 2)
c:part(c:rect(10, 27, 11, 31), "gold", { band = 1 })
c:part(c:rect(17, 27, 18, 31), "gold", { band = 1 })
c:part(c:ellipse(14, 22, 7, 5), "gold")
c:part(c:line({ { 18, 19 }, { 21, 11 }, { 23, 6 } }, 3), "gold")
c:part(c:ellipse(23, 5, 3, 3), "gold")
c:part(c:rect(22, 1, 23, 2), "wood", { band = 1 })
c:part(c:poly({ { 24, 1 }, { 29, 0 }, { 27, 3 } }), "moss")
c:fillMask(c:ellipse(11, 21, 1, 1), P.wood.shade)
c:eyeSmall(21, 4)
c:px(25, 6, P.ink)
c:sparkle(31, 20)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-tall-tiptoe-perch.aseprite", png = out .. "th-tall-tiptoe-perch.png", scale = 1 }

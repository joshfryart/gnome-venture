-- Tall Tiptoe (th-tall-tiptoe), yard 64x64. Haiku first pass. Rare, wayfinder.
-- Reaches the top leaves before anybody else is out of bed.
-- quirk: a fresh leaf sprouts from the top of its head, reaching for the sun.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "th-tall-tiptoe-yard" }
c:groundShadow(30, 61, 14, 2)
c:part(c:rect(20, 48, 23, 59), "gold", { band = 1 })
c:part(c:rect(31, 48, 34, 59), "gold", { band = 1 })
c:part(c:ellipse(30, 42, 14, 8), "gold")
c:part(c:line({ { 36, 38 }, { 42, 24 }, { 44, 12 } }, 6), "gold")
c:part(c:ellipse(46, 10, 5, 4), "gold")
c:part(c:rect(44, 2, 45, 4), "wood", { band = 1 })
c:part(c:poly({ { 46, 2 }, { 52, 0 }, { 50, 5 } }), "moss")
c:fillMask(c:ellipse(24, 40, 2, 2), P.wood.shade)
c:fillMask(c:ellipse(40, 28, 1.5, 1.5), P.wood.shade)
c:part(c:ellipse(51, 12, 2, 2), "petal")
c:eyeLocked(43, 8)
c:cheek(42, 15)
c:px(52, 11, P.ink)
c:sparkle(56, 22)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-tall-tiptoe-yard.aseprite", png = out .. "th-tall-tiptoe-yard.png", scale = 1 }

-- Flamingo Flick (th-flamingo-flick), yard 64x64. Haiku first pass. Common, bloomcaller.
-- Stands on one leg in the waterhole and dares you to try.
-- quirk: one wing is raised high, like a dare.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "th-flamingo-flick-yard" }
c:part(c:rect(3, 55, 60, 60), "sea", { band = 1 })
c:px(20, 57, P.sea.hi) c:px(21, 57, P.sea.hi) c:px(44, 58, P.sea.hi)
c:part(c:line({ { 30, 42 }, { 31, 55 } }, 2), "ember")
c:part(c:ellipse(30, 34, 15, 9), "petal")
c:part(c:line({ { 38, 30 }, { 43, 20 }, { 44, 14 } }, 5), "petal")
c:part(c:ellipse(46, 12, 6, 5), "petal")
c:part(c:poly({ { 50, 10 }, { 59, 13 }, { 50, 15 } }), "gold")
c:part(c:poly({ { 20, 34 }, { 17, 21 }, { 28, 25 }, { 34, 32 } }), "ember")
c:eyeLocked(43, 9)
c:px(50, 12, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-flamingo-flick-yard.aseprite", png = out .. "th-flamingo-flick-yard.png", scale = 1 }

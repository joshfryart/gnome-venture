-- Kopje Keeper (th-kopje-keeper), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: a moss tuft on the top (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "th-kopje-keeper-perch" }
c:groundShadow(18, 33, 11, 2)
c:part(c:ellipse(18, 20, 11, 9), "stone")
c:part(c:ellipse(22, 12, 2, 2), "moss", { band = 1 })
c:px(21, 10, P.moss.hi) c:px(22, 9, P.moss.hi)
c:eyeSmall(13, 18) c:eyeSmall(20, 18)
c:px(17, 23, P.stone.deep) c:px(18, 23, P.stone.deep)
c:fillMask(c:line({ { 14, 26 }, { 21, 26 } }, 1), P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-kopje-keeper-perch.aseprite", png = out .. "th-kopje-keeper-perch.png", scale = 1 }

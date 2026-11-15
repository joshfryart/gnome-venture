-- lull (tag "lull": the creature plays one tile fewer / skips its next turn). Haiku first pass.
-- A dusk-violet crescent moon with a sleepy closed eye and two cream "z" letters drifting off.
-- quirk: the closed eye, the moon is asleep too.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "lull" }

local moon = HP.ellipse(30, 34, 16, 16):cut(HP.ellipse(40, 26, 14, 14))
c:part(moon, "dusk", { band = 2 })

for _, p in ipairs({ {20, 33}, {21, 34}, {22, 34}, {23, 33} }) do c:put(p[1], p[2], P.dusk.deep) end

HP.line({ {43, 18}, {48, 18}, {43, 23}, {48, 23} }, 2):each(function(x, y) c:put(x, y, P.cream) end)
HP.line({ {51, 30}, {54, 30}, {51, 33}, {54, 33} }, 2):each(function(x, y) c:put(x, y, P.cream) end)

c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "lull.aseprite", png = OUT .. "lull.png", scale = 1 }

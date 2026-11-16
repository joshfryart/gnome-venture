-- bond (tag "bond": the creature warms to Charm for the rest of the fight). Haiku first pass.
-- Two interlocking rings, gold behind and ember in front, with a small petal-pink heart in the top corner.
-- quirk: the heart floats off by itself.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "bond" }

local ringB = HP.ellipse(38, 36, 14, 14):cut(HP.ellipse(38, 36, 8, 8))
local ringA = HP.ellipse(22, 28, 14, 14):cut(HP.ellipse(22, 28, 8, 8))
c:part(ringB, "gold", { band = 2 })
c:part(ringA, "ember", { band = 2 })

c:paint({ ".x.x.", "xxxxx", ".xxx.", "..x.." }, 47, 9, { x = P.petal.base })

c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "bond.aseprite", png = OUT .. "bond.png", scale = 1 }

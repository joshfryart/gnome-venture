-- mend (tag "mend": heals you 2 as well). Haiku first pass.
-- A tan fabric plaster on the diagonal with a grey gauze pad and two ember spots, plus a moss sprout at one end.
-- quirk: the sprout pushing up through the plaster.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local OUT = app.params.out or (DIR .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "mend" }

local strip = HP.poly({ {52, 21}, {43, 12}, {12, 43}, {21, 52} })
c:part(strip, "wood", { band = 2 })

local pad = HP.poly({ {41, 30}, {34, 23}, {23, 34}, {30, 41} })
c:part(pad, "stone", { band = 1 })
c:put(29, 31, P.ember.base)
c:put(33, 33, P.ember.base)

local sprout = HP.poly({ {46, 8}, {50, 4}, {54, 7}, {50, 11} })
c:part(sprout, "moss", { band = 1 })

c:finish{ outline = true }
HP.assertClean(c)
c:save{ aseprite = OUT .. "mend.aseprite", png = OUT .. "mend.png", scale = 1 }

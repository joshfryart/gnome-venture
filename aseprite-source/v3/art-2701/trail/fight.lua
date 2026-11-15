-- trail-fight (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "fight"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: one of the crossed weapons is a wooden spoon
c:part(c:line({{5,4},{22,21}},4), "stone")
c:part(c:poly{{22,18},{28,24},{26,26},{20,20}}, "gold")
c:part(c:line({{24,23},{28,27}},3), "wood")
c:part(c:line({{27,4},{12,19}},3), "wood")
c:part(c:ellipse(6,6,3,3), "wood")
c:part(c:poly{{13,21},{19,17},{21,19},{15,23}}, "wood", {noshade=true, nopop=true})
c:sparkle(16,12)
c:part(c:line({{4,26},{9,21}},3), "wood", {noshade=true, nopop=true})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


-- trail-camp (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "camp"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: a tiny pennant on the tent peak
c:groundShadow(16, 27, 12, 2)
c:part(c:poly{{12,26},{12,12},{8,26}}:add(c:poly{{12,7},{4,26},{21,26}}), "ember")
c:part(c:poly{{12,15},{8,26},{16,26}}, "wood", {band=1, nopop=true})
c:part(c:poly{{12,12},{10,22},{14,22}}, "wood", {noshade=true, nopop=true})
c:part(c:line({{12,5},{12,9}},1), "wood", {noshade=true, nopop=true})
c:part(c:poly{{13,4},{18,5},{13,7}}, "gold", {noshade=true, nopop=true})
c:part(c:rect(21,25,28,26), "wood", {noshade=true, nopop=true})
c:part(c:poly{{24,24},{21,19},{23,17},{24,20},{25,15},{27,20},{28,24}}, "gold")
c:part(c:poly{{24,24},{23,21},{26,21},{26,24}}, "ember", {noshade=true, nopop=true})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


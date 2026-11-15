-- trail-toll (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "toll"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: the barrier arm is striped like a candy stick
c:groundShadow(16,28,12,1)
c:part(c:rect(4,10,8,27), "wood")
c:part(c:rect(24,17,28,27), "stone")
c:part(c:poly{{8,12},{26,6},{26,10},{8,16}}, "cream" and "stone", {nopop=true})
for i=0,2 do c:part(c:poly{{10+i*6,12-i*2},{13+i*6,11-i*2},{13+i*6,15-i*2},{10+i*6,16-i*2}}:clip(c:poly{{8,12},{26,6},{26,10},{8,16}}), "ember", {noshade=true, nopop=true}) end
c:part(c:ellipse(16,22,5,5), "gold")
c:part(c:rect(15,19,16,25), "gold", {noshade=true, nopop=true})
c:px(16,22,"#8f4a1f") c:px(16,23,"#8f4a1f")
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


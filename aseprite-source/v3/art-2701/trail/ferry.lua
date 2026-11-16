-- trail-ferry (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "ferry"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: a duck rides the bow
c:bands(24,30,"sea",3)
c:part(c:poly{{4,19},{27,19},{23,25},{8,25}}, "wood")
c:part(c:rect(15,5,16,19), "wood", {noshade=true, nopop=true})
c:part(c:poly{{17,6},{25,17},{17,17}}, "stone", {band=1})
c:part(c:poly{{14,8},{14,17},{8,17}}, "gold", {band=1})
c:part(c:ellipse(6,16,2,2), "gold", {noshade=true, nopop=true})
c:part(c:rect(7,14,8,14), "ember", {noshade=true, nopop=true})
c:part(c:rect(5,28,9,28), "sea", {noshade=true, nopop=true})
c:part(c:rect(18,29,23,29), "sea", {noshade=true, nopop=true})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


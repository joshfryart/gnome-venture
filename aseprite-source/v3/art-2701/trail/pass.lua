-- trail-pass (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "pass"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: a gold flag marks the saddle between the peaks
c:groundShadow(16,28,12,1)
c:part(c:poly{{2,27},{11,8},{20,27}}, "stone")
c:part(c:poly{{11,8},{8,14},{10,13},{11,15},{13,13},{14,14}}, "sky", {noshade=true, nopop=true})
c:part(c:poly{{12,27},{22,11},{30,27}}, "dusk")
c:part(c:poly{{22,11},{19,17},{21,16},{22,18},{24,16},{25,17}}, "sky", {noshade=true, nopop=true})
c:part(c:line({{16,15},{16,22}},1), "wood", {noshade=true, nopop=true})
c:part(c:poly{{17,15},{21,17},{17,19}}, "gold", {noshade=true, nopop=true})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


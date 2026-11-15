-- trail-tunnel (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "tunnel"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: a lantern glows deep inside the dark
c:part(c:ellipse(16,24,14,16):clip(c:rect(0,0,31,28)), "moss")
c:part(c:rect(3,25,28,28), "moss", {noshade=true, nopop=true})
c:part(c:rrect(8,13,23,28,6):clip(c:rect(0,0,31,28)), "stone")
c:part(c:rrect(11,16,20,28,4):clip(c:rect(0,0,31,28)), "dusk", {noshade=true, nopop=true})
c:part(c:rect(11,24,20,28), "dusk", {noshade=true, nopop=true})
c:part(c:rect(15,22,16,24), "gold", {noshade=true, nopop=true})
c:px(15,21,"#ffe38a") c:px(16,21,"#ffe38a")
c:part(c:poly{{3,28},{8,27},{8,28}}, "wood", {noshade=true, nopop=true})
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


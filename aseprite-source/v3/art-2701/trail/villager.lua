-- trail-villager (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "villager"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: a leaf pokes out of the hat
c:part(c:poly{{16,2},{8,15},{24,15}}, "ember")
c:part(c:poly{{22,5},{27,4},{24,8}}, "moss", {noshade=true, nopop=true})
c:part(c:rrect(8,13,24,17,1), "ember", {noshade=true, nopop=true})
c:part(c:rrect(9,15,23,27,5), "skinA")
c:part(c:poly{{9,21},{23,21},{20,29},{16,30},{12,29}}, "stone", {band=2, nopop=true})
c:eyeSmall(12,17) c:eyeSmall(19,17)
c:part(c:rect(15,19,16,20), "skinB", {noshade=true, nopop=true})
c:cheek(10,20) c:cheek(20,20)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


-- trail-sight (32x32 map marker, Hearth Pop)
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../lib/hp.lua")
local out = app.params.out or "./"

local NAME = "sight"
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = NAME }
-- quirk: a ladybird sits on the lens cap
c:part(c:line({{6,26},{17,15}},5), "wood")
c:part(c:line({{16,16},{25,7}},7), "gold")
c:part(c:line({{24,8},{27,5}},9), "stone")
c:part(c:ellipse(27,5,3,3), "sea", {noshade=true})
c:part(c:ellipse(5,27,2,2), "gold", {noshade=true, nopop=true})
c:part(c:ellipse(11,9,2,2), "ember", {noshade=true, nopop=true})
c:px(11,8,"#2b1c26") c:px(12,10,"#2b1c26")
c:sparkle(24,6)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }


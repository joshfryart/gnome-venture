-- wayfarers-hat-fine: Wayfarer's Hat, fine rank (Opus second pass, full redraw). 64x64 Hearth Pop.
-- Drawing shared with the other hat ranks in _hat.lua so the three stay siblings.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local c = dofile(DIR .. "/_hat.lua")("fine")
W.save(c, "wayfarers-hat-fine")

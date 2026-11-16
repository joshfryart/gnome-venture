-- wayfarers-hat-lined: Wayfarer's Hat, lined rank (Opus second pass, full redraw). 64x64 Hearth Pop.
-- Drawing shared with the other hat ranks in _hat.lua so the three stay siblings.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local c = dofile(DIR .. "/_hat.lua")("lined")
W.save(c, "wayfarers-hat-lined")

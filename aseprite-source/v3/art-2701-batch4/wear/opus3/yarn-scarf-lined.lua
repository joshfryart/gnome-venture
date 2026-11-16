-- yarn-scarf-lined: Yarn Scarf, lined rank (Opus second pass, full redraw). 64x64 Hearth Pop.
-- Drawing shared with the other scarf rank in _scarf.lua so the two stay siblings.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_w.lua")
local c = dofile(DIR .. "/_scarf.lua")("lined")
W.save(c, "yarn-scarf-lined")

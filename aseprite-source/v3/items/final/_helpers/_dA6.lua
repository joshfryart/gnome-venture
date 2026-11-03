-- _dA6: helper for chunk dA6 first drafts (ico-info .. ico-medal-silver). Layer over _dA5 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA5.lua")
function D.rp(n) return D.H.ramp(n) end
function D.cyl(m, ramp, x0, x1, o) return D.H.vcyl(D.c, m, ramp, x0, x1, o) end
-- 2-3px thick segment list as mask
function D.seg(pts, w) return D.c:line(pts, w) end
D.SAND = { "#8a5a3a", "#b88050", "#d9a868", "#ecc888", "#f6dca6", "#fff0c4" }
D.BARK = { "#2e1a22", "#46281f", "#63382a", "#7e4a32", "#9a6240", "#bb8052" }
D.SILV = { "#3d4160", "#5d6285", "#8388a8", "#aeb2cc", "#d4d7e8", "#f4f5fc" }
D.BRZ  = { "#4a2418", "#7a3c20", "#a8582a", "#cc7a3a", "#e69a52", "#f8c27c" }
return D

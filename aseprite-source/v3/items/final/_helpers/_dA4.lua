-- _dA4: helper for chunk dA4 first drafts (ico-egg .. ico-gift). Reuses _dA3 (not edited), adds ramps.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA3.lua")
D.leaf = D.H.leaf
D.SKIN = { "#7a3a3a", "#b0605a", "#d98a6a", "#f0a880", "#ffc8a0", "#ffe0c0" }
D.YEL  = { "#8a5a14", "#c08a1c", "#e8b028", "#ffd23c", "#ffe670", "#fff6b0" }
D.FOG  = { "#5a6a8c", "#7c8cae", "#9eaeca", "#bccadf", "#d6e2f0", "#eef4fa" }
D.STONE = { "#4a4658", "#6a667a", "#8a869a", "#aaa6b8", "#c8c4d2", "#e4e0ea" }
D.FOX  = { "#6a2a1c", "#a8441e", "#d86a28", "#f28a34", "#ffa850", "#ffc880" }
D.GHOST = { "#7a86b8", "#9ea8d2", "#bcc6e6", "#d6def2", "#ecf0fa", "#fbfdff" }
-- flat polygon fill clipped to nothing; returns mask
function D.polym(pts) return D.c:poly(pts) end
return D

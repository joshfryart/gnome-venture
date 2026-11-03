-- _dA7: helper for chunk dA7 first drafts (ico-melon .. ico-paw). Thin layer over _dA5 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA5.lua")
function D.rp(n) return D.H.ramp(n) end
function D.mirror(m) local n = D.HP.mask() m:each(function(x, y) n:set(63 - x, y) end) return n end
-- px list: {{x,y},..} painted one colour
function D.pts(list, hex) for _, p in ipairs(list) do D.c:px(p[1], p[2], hex) end end
-- paint a bitmap (rows of strings) at x,y with char->hex map
function D.bmp(rows, x, y, map) D.c:paint(rows, x, y, map) end
D.WHITEISH = { "#8f9cc4", "#b8c4e4", "#dce4f4", "#eef2fb", "#f6f8ff", "#fbfcff" }
D.OLIVE = { "#2c3a22", "#46592b", "#657a34", "#86993f", "#a6b658", "#cad47e" }
D.PLUM = { "#2e1a45", "#4a2463", "#7a3a8a", "#a14e9c", "#c277b0", "#e2a8cc" }
return D

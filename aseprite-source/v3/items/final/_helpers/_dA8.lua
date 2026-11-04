-- _dA8: helper for chunk dA8 first drafts (ico-peach .. ico-ribbon). Layer over _dA0 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA0.lua")
-- 6-tone ramps, dark -> light
D.PEACH = { "#7a2638", "#b5384a", "#e0584e", "#f58a5c", "#ffb27a", "#ffd9a8" }
D.TAN   = { "#5a3a28", "#8a5a38", "#b58650", "#d4a468", "#e8c488", "#f8e2b4" }
D.YEL   = { "#8f4a1f", "#c98a1c", "#eeb52a", "#fcd04a", "#ffe57a", "#fff5b8" }
D.PINK  = { "#6e2150", "#a33468", "#d4527e", "#f27a9a", "#ffa4bc", "#ffd0dc" }
D.BLU   = { "#1c2e5a", "#2a4a7a", "#3a6aa6", "#4a8acc", "#78b4ea", "#b6dcf6" }
D.GRN   = { "#14382f", "#1f5a44", "#2f8450", "#3fa862", "#6cc880", "#aeeaa0" }
D.ORG   = { "#6e2a18", "#a8441c", "#d9661f", "#f58a2c", "#ffaa50", "#ffd080" }
D.GRY   = { "#3a3d56", "#5a5e7c", "#7e829e", "#a4a8c0", "#cdd0e2", "#eef0fa" }
D.SKIN  = { "#7a4036", "#c98462", "#e8a47c", "#f0b98d", "#ffd0a8", "#ffe8cc" }
D.RED   = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.PURP  = { "#2e1a45", "#4a2463", "#6b3485", "#8e4fa6", "#b27cc4", "#d6aee0" }
D.CRM   = { "#a88a6a", "#d4b48a", "#ecd4a8", "#f8e8c0", "#fff2d4", "#fffbec" }
D.BRN   = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
function D.pts(c, list, hex) for _, p in ipairs(list) do c:px(p[1], p[2], hex) end end
function D.rect(c, x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
return D

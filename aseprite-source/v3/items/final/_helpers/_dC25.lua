-- _dC25: helper for chunk dC25 (natto, naupaka-seed, nav-*). Wraps _dC23 (which wraps batch2/_b2.lua), unchanged.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dC23.lua")
local B, c0 = D.B, nil
D.R.blue  = { "#1a2748", "#26407a", "#3a62a8", "#5a8cd0", "#86b4ea", "#bddcff" }
D.R.red   = { "#4a1424", "#7e1f34", "#b0303c", "#d44c46", "#ee7258", "#ffa282" }
D.R.sun   = { "#a8501c", "#d6781e", "#f29a24", "#ffbc30", "#ffd85a", "#fff0a0" }
D.R.paper = { "#8a7a78", "#b8a898", "#dccdb4", "#eee0c4", "#f8eed4", "#fffaea" }
D.R.sprout= { "#1b4a3a", "#2a6c42", "#42924c", "#68b658", "#96d46c", "#c8ee90" }
D.R.skin  = { "#8a4a3a", "#b87052", "#dc9a70", "#f0b88c", "#ffd0a8", "#ffe6c8" }
D.R.beard = { "#8a8498", "#b4aec0", "#d4d0dc", "#eae6ee", "#f8f6fa", "#fcf8ff" }
D.R.dusk  = { "#241a48", "#3a2c70", "#5a459e", "#7a62c0", "#a088e0", "#cbb8f6" }
D.R.petal = { "#5a1c48", "#8a2c62", "#c0487c", "#e86c96", "#f89ab6", "#ffc8d8" }
D.R.sky   = { "#3a6aa8", "#5a90cc", "#8cbcea", "#b6dcf6", "#d8f0ff", "#f4fcff" }
D.R.hay   = D.R.straw
-- lit ink-friendly mask shapes
function D.rect(c, x0, y0, x1, y1, ramp, R) local m = c:rect(x0, y0, x1, y1) B.lit(c, m, ramp, R or 2) return m end
function D.shadow(c, cx, cy, rx, ry) c:groundShadow(cx, cy, rx, ry) end
-- thick line of colour hex width w
function D.line(c, pts, w, hex) c:fillMask(c:line(pts, w), hex) end
-- lit line (wood handle etc): mask from line then pillow-lit
function D.rod(c, pts, w, ramp, R) local m = c:line(pts, w) B.lit(c, m, ramp, R or w / 2 + .5) return m end
return D

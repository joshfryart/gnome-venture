-- _dA1: helper for the chunk dA1 first drafts (ico-b*). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, P = B.H, B.HP, B.X, dofile(DIR .. "/../../../lib/palette.lua")
local D = { B = B, H = H, HP = HP, X = X, P = P }
local floor = math.floor
function D.new(name) D.c = B.new(name) return D.c end
function D.lit(m, ramp, R, o) o = o or {} o.R = R or 2.5 return H.lit(D.c, m, ramp, o) end
function D.cyl(m, ramp, x0, x1, o) return H.vcyl(D.c, m, ramp, x0, x1, o) end
D.ell, D.ln, D.poly, D.seam = B.ell, B.ln, B.polyline, B.seam
function D.mirror(m) local n = HP.mask() m:each(function(x, y) n:set(63 - x, y) end) return n end
function D.sub(a, b) return a:copy():cut(b) end
function D.isect(a, b) return a:copy():clip(b) end
function D.px(x, y, h) D.c:px(x, y, h) end
function D.fill(m, h) D.c:fillMask(m, h) end
function D.rp(n) return H.ramp(n) end
-- custom 6-tone ramps (dark -> light)
D.CREAM = { "#8a6a5a", "#c9a98a", "#e6cfa8", "#f6e6bf", "#fff0cc", "#fffbe8" }
D.WICK  = { "#6e4630", "#9c6a3e", "#c48d52", "#dca865", "#efc582", "#fbe0a6" }
D.GREEN = { "#14382f", "#1f5a44", "#2f8450", "#3fa862", "#6cc880", "#aeeaa0" }
D.BLUE  = { "#1c2e5a", "#2a4a7a", "#3a6aa6", "#4a8acc", "#78b4ea", "#b6dcf6" }
D.RED   = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.TEAL  = { "#1d3a4e", "#2a5a6c", "#2f8a86", "#3fb0a0", "#6fd6b8", "#b6f0e0" }
D.DKP   = { "#150f22", "#251a3c", "#35295f", "#4a3a80", "#5e4b9a", "#7d69b8" }
D.MEM   = { "#2e2250", "#3f3270", "#5a459e", "#7358b8", "#8f77d0", "#b09ae6" }
D.ORG   = { "#8f4a1f", "#c26a24", "#e8872e", "#ff9f3c", "#ffbf5c", "#ffe08a" }
D.CRUST = { "#5a2e1e", "#8a4a26", "#b8702f", "#d6903f", "#eeae58", "#ffd98a" }
D.DBRN  = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#b97a4a" }
D.INK, D.CR = "#2b1c26", "#fff4d6"
function D.fin() B.fin() end
return D

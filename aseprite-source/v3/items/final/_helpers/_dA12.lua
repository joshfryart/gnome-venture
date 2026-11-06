-- _dA12: helper for chunk dA12 (ico-world-map .. amber-lamppost). Layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local D = { B = B, H = H, HP = HP, X = X, INK = "#2b1c26", CR = "#fff4d6" }
function D.new(name) D.c = B.new(name) return D.c end
function D.lit(m, ramp, R, o) o = o or {} o.R = R or 2.5 return H.lit(D.c, m, ramp, o) end
D.ell, D.seam = B.ell, B.seam
function D.ln(x0, y0, x1, y1, hex, clip) B.ln(D.c, x0, y0, x1, y1, hex, clip) end
function D.px(x, y, h) D.c:px(x, y, h) end
function D.sub(a, b) return a:copy():cut(b) end
function D.fin() B.fin() end
-- ramps dark -> light
D.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.LEAF2 = { "#1c4a3a", "#2b6b45", "#3f8a4e", "#5aaa58", "#86c868", "#bfe688" }
D.RED  = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.BRN  = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
D.TAN  = { "#6a4a38", "#8f6a46", "#b88c5c", "#d9b37c", "#ecd09c", "#fae8c0" }
D.PURP = { "#2a1640", "#44235f", "#62348a", "#8650ae", "#a97ccc", "#d0aee8" }
D.ORG  = { "#8f3a1f", "#c25a24", "#e8782e", "#ff9a3c", "#ffbc5c", "#ffe08a" }
D.YEL  = { "#8f5a1f", "#c88a22", "#eab32e", "#f8d048", "#ffe46e", "#fff2a8" }
D.PINK = { "#7d2c5e", "#a83e6e", "#d4587e", "#f07a98", "#ff9ab4", "#ffc9d8" }
D.CRM  = { "#8a6a5a", "#c9a98a", "#e6cfa8", "#f6e6bf", "#fff0cc", "#fffbe8" }
D.STEEL= { "#2f3350", "#4d5275", "#74789a", "#9ea2bf", "#c9ccdf", "#f0f1fa" }
D.SEA  = { "#1c2e5a", "#2a4a7a", "#3a6aa6", "#4a8acc", "#78b4ea", "#b6dcf6" }
-- leaf scrap blade (ramp) from a to b, half width w
function D.scrap(ax, ay, bx, by, w, ramp, o) o = o or {} o.veins = o.veins or {5,9,13,17,21,25,29,33} return B.blade(D.c, ax, ay, bx, by, w, ramp or D.LEAF, o) end
-- seed (rotated lit ellipse + contact shadow + glint)
function D.seed(cx, cy, rx, ry, ang, ramp, glint) return B.seed(D.c, cx, cy, rx, ry, ang, ramp, "#1f4a3a", glint) end
-- leaflet blob lit
function D.lf(cx, cy, rx, ry, ang, ramp) local m = B.ell(cx, cy, rx, ry, ang) B.lit(D.c, m, ramp or D.LEAF, min(rx, ry) + .4) return m end
-- stem line 1px
function D.stem(x0, y0, x1, y1, hex) B.ln(D.c, x0, y0, x1, y1, hex or "#86b86c") end
return D

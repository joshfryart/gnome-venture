-- _dB35: helper for the chunk dB35 first drafts (goat..grapefruit). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local D = { B = B, H = H, HP = HP, X = X, K = B.K, INK = "#2b1c26", CR = "#fff4d6" }
D.ell, D.ln, D.poly, D.seam = B.ell, B.ln, B.polyline, B.seam
function D.new(name) D.c = B.new(name) return D.c end
function D.lit(m, ramp, R, o) o = o or {} o.R = R or 2.5 return H.lit(D.c, m, ramp, o) end
function D.cyl(m, ramp, x0, x1, o) return H.vcyl(D.c, m, ramp, x0, x1, o) end
function D.sub(a, b) return a:copy():cut(b) end
function D.isect(a, b) return a:copy():clip(b) end
function D.px(x, y, h) D.c:px(x, y, h) end
function D.fill(m, h) D.c:fillMask(m, h) end
function D.fin() B.fin() end
-- 6-tone ramps, dark -> light
D.LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.LEAF2 = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" }
D.GOLD  = { "#6e3a1c", "#a8601f", "#d98322", "#f5b82e", "#ffd45a", "#fff0a0" }
D.CREAM = { "#8a6a5a", "#c9a98a", "#e6cfa8", "#f6e6bf", "#fff0cc", "#fffbe8" }
D.WOOD  = { "#51302b", "#6f4033", "#864c33", "#a35f3c", "#b97a4a", "#e8b982" }
D.STONE = { "#3a3c58", "#575a78", "#74758c", "#8f90a4", "#aaa9b8", "#d6d4de" }
D.RED   = { "#4a1630", "#7a2036", "#a82c3c", "#d4403a", "#ee6a50", "#ff9a78" }
D.PURP  = { "#251a3c", "#35295f", "#5a459e", "#7a5cc0", "#9a7ee0", "#c9b2f0" }
D.SEEDB = { "#3a1a1e", "#5e3226", "#84503a", "#a8704a", "#cc9a68", "#ecc892" }
D.CHINA = { "#8f9ab8", "#b4bcd6", "#d0d6ea", "#e8ecf8", "#f6f8ff", "#fffbe8" }
D.VEIN, D.COOL = "#c8e69a", "#3a6c72"
function D.mirror(m) local n = HP.mask() m:each(function(x, y) n:set(63 - x, y) end) return n end
-- leaf scrap (straight blade, veins) painted straight onto the canvas
function D.blade(ax, ay, bx, by, w, ramp, o) return B.blade(D.c, ax, ay, bx, by, w, ramp, o) end
-- tiny leaf-scrap contact shadow under a seed
function D.seedShadow(cx, cy, rx, ry, ang, hex)
  D.c:fillMask(B.ell(cx + 1, cy + 1.2, rx + .3, ry + .3, ang), hex or "#163a35")
end
-- two-pixel wide stem from a to b, left px lit, right px shade
function D.stem(x0, y0, x1, y1, lit, shade)
  B.ln(D.c, x0, y0, x1, y1, shade) B.ln(D.c, x0 - 1, y0, x1 - 1, y1, lit)
end
return D

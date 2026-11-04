-- _dA13: helper for chunk dA13 (ant-chitin .. balloon-flower-seed). Layer over _dA12 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA12.lua")
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
D.CHIT = { "#120c16", "#251a26", "#3d2a2c", "#5c3a30", "#835139", "#b0784c" }
D.BONE = { "#5a4638", "#8a6c52", "#b8966c", "#d8bc8c", "#ecd8aa", "#fbf0d0" }
D.GLASS = { "#5a8aa0", "#86b8c8", "#b2dce4", "#d4f0f0", "#eafaf6", "#fcfffa" }
D.FUR = { "#2a2630", "#443f4c", "#625c68", "#847e8a", "#a8a2ac", "#d0ccd2" }
D.SEED = { "#1c1218", "#33201f", "#4e3024", "#6b4430", "#8c5e3e", "#b08454" }
D.STM = "#86b86c"
-- 2px stem, lit left
function D.stem2(x0, y0, x1, y1) D.ln(x0, y0, x1, y1, "#a6d07c") D.ln(x0 + 1, y0, x1 + 1, y1, "#4e9050") end
-- cotyledon pair at (x,y)
function D.cots(x, y, rx, ry, ramp)
  D.lf(x - rx, y, rx, ry, -0.25, ramp or D.LEAF2) D.lf(x + rx + 1, y, rx, ry, 0.25, ramp or D.LEAF2)
end
function D.shadow(cx, cy, rx, ry) D.c:groundShadow(cx, cy, rx, ry) end
-- ellipse mask lit
function D.E(cx, cy, rx, ry, ang, ramp, R, o) local m = D.B.ell(cx, cy, rx, ry, ang) D.lit(m, ramp, R or min(rx, ry) + .5, o) return m end
function D.P(pts, ramp, R, o) local m = D.c:poly(pts) D.lit(m, ramp, R or 2, o) return m end
function D.steam(x, y, h)
  for i = 0, h do D.px(x + floor(sin(i * 0.9) * 1.6 + .5), y - i, i % 3 == 2 and "#e8e6ee" or "#fbf8ff") end
end
return D

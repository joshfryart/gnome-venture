-- _dB24: helper for the d-B24 chunk (thin layer over batch2/_b2.lua, not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P }
local floor, sin, cos, pi, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.sqrt
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
function D.new(name) return B.new(name) end
function D.ramp(r) return H.ramp(r) end
function D.mix(a, b, t) return H.mix(a, b, t) end
function D.lit(c, m, ramp, R, o) o = o or {} o.R = R or 3 return H.lit(c, m, ramp, o) end
function D.rr(c, x0, y0, x1, y1, r, ramp, R) local m = c:rrect(x0, y0, x1, y1, r) H.lit(c, m, ramp, { R = R or 3 }) return m end
function D.el(c, cx, cy, rx, ry, ramp, ang, R) local m = B.ell(cx, cy, rx, ry, ang or 0) H.lit(c, m, ramp, { R = R or min(rx, ry) + .6 }) return m end
function D.poly(c, pts, ramp, R) local m = c:poly(pts) H.lit(c, m, ramp, { R = R or 2.5 }) return m end
function D.cylx(c, m, ramp, x0, x1, o) return H.vcyl(c, m, ramp, x0, x1, o) end
function D.sweep(c, pts, wfn, ramp, R) local m, T = H.sweep(pts, wfn) H.lit(c, m, ramp, { R = R or 2.5 }) return m, T end
function D.shadow(c, cx, cy, rx, ry) c:groundShadow(cx, cy, rx, ry) end
function D.ln(c, x0, y0, x1, y1, hex, clip) B.ln(c, x0, y0, x1, y1, hex, clip) end
function D.pl(c, pts, hex, clip) B.polyline(c, pts, hex, clip) end
function D.px(c, x, y, hex) c:px(x, y, hex) end
function D.spec(c, x, y, big) c:px(x, y, D.CREAM) if big then c:px(x + 1, y, D.CREAM) end end
function D.noise(x, y, s) return X.hash(x, y, s or 1) end
function D.bez(p, t) local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1], u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2] end
-- 6-tone ramps
D.R = {
  paste = { "#2a1410", "#4a2418", "#6e3a22", "#8e5430", "#b27640", "#d29a5c" },
  green = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  pink  = { "#5a1450", "#8c2468", "#c03a80", "#e45a98", "#f58cb4", "#ffc0d8" },
  orange = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" },
  cream = { "#6a5a5c", "#a08c80", "#cbb89a", "#e8d8b4", "#f6ead0", "#fffaea" },
  tan   = { "#51302b", "#7a4a34", "#a87048", "#caa06a", "#e2c088", "#f6dcaa" },
  kraft = { "#5a3a30", "#8a5c3e", "#b98456", "#d6a670", "#ecc896", "#fae2b4" },
  glass = { "#3a7a86", "#5aa4ae", "#86c8c4", "#acdcd4", "#cdeee4", "#eefaf0" },
  grey  = { "#4a4658", "#6e6a7c", "#948f9e", "#bdb2a2", "#d8ceba", "#efe8d6" },
  red   = { "#4a1230", "#7a1c3a", "#a8283e", "#cc3844", "#e8605a", "#ff9a84" },
  purple = { "#2c1a3a", "#4a2a4e", "#6c3e62", "#8c5876", "#ac7890", "#cc9cb0" },
  white = { "#7a6e86", "#aaa0b4", "#cfc8d0", "#e8e2de", "#f8f2e6", "#fffcf0" },
  yolk  = { "#8f4a1f", "#c27a20", "#e8a428", "#f5c13a", "#ffd95c", "#fff0a0" },
  night = { "#141428", "#1e2a46", "#2a4666", "#3a6a82", "#5a98a0", "#9ad0c4" },
}
function D.fin() B.fin() end
return D

-- _dB34: first-draft helper for chunk B34 (ph/g*). Thin layer over batch2/_b2.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local G7 = dofile(DIR .. "/../../batch2/_b2g7.lua")
local H, HP, X, K = B.H, B.HP, B.X, B.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local D = { B = B, H = H, HP = HP, X = X, K = K }
local INK, CREAM = "#2b1c26", "#fff4d6"
D.INK, D.CREAM = INK, CREAM
-- 6-tone ramp from one base colour: cool-violet shade, warm-yellow light
function D.R(base, lightTo, shadeTo)
  local mx = H.mix
  local deep = mx(mx(base, "#2a1a3a", .72), "#000000", 0)
  local shade = mx(base, shadeTo or "#3a2a6e", .38)
  local hi = mx(base, lightTo or "#fff0b0", .62)
  return { deep, shade, mx(shade, base, .5), base, mx(base, hi, .5), hi }
end
function D.new(name) return B.new(name) end
D.E = B.ell
function D.P(c, pts) return c:poly(pts) end
function D.lit(c, m, ramp, R, o) o = o or {} o.R = R or 3 return H.lit(c, m, ramp, o) end
D.ln = B.ln
function D.shadow(c, cx, cy, rx, ry) c:groundShadow(cx, cy, rx, ry) end
-- flat pixel list: pts = {{x,y},..} hex
function D.dots(c, pts, hex) for _, p in ipairs(pts) do c:px(p[1], p[2], p[3] or hex) end end
function D.glint(c, x, y) c:px(x, y, CREAM) end
-- vertical cylinder body (jar/bottle): x0..x1, y0..y1 with rounded bottom
function D.vcyl(c, m, ramp, x0, x1) return H.vcyl(c, m, ramp, x0, x1) end
-- leaf scrap (tilted blade) for seed items: base lower-left tip upper-right
function D.scrap(c, ramp, ax, ay, bx, by, w, o) return B.blade(c, ax, ay, bx, by, w, ramp, o or { veins = { 4, 8, 12, 16 } }) end
function D.centre(c) G7.centre(c) end
function D.fin(c) D.centre(c) B.fin() end
return D

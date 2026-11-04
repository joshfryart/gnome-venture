-- _dC30 helper (chunk C3): thin layer over batch2/_b2.lua (shared files not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local D = { B = B, H = H, HP = HP, X = X, K = B.K, ell = B.ell, ln = B.ln, lit = B.lit, blade = B.blade, seam = B.seam }
D.CREAM, D.INK = "#fff4d6", "#2b1c26"
D.LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.WOOD = { "#3a2420", "#51302b", "#864c33", "#b97a4a", "#d79e66", "#e8c08c" }
D.STONE = { "#32344f", "#444663", "#5f6079", "#85869b", "#aaa9b8", "#d6d4de" }
D.GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#8ee0dc", "#b6f0e0", "#e4fbf4" }
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
-- polygon lit as a pillow
function D.poly(c, pts, ramp, R, o) local m = c:poly(pts) B.lit(c, m, ramp, R or 2.5, o) return m end
-- hash noise
function D.hash(x, y, s) return X.hash(x, y, s or 1) end
-- seed scrap: torn leaf scrap with midrib; returns mask
function D.scrap(c, ax, ay, bx, by, w, ramp, o)
  o = o or {}
  o.veins = o.veins or { 5, 9, 13, 17, 21, 25, 29, 33 }
  return B.blade(c, ax, ay, bx, by, w, ramp or D.LEAF, o)
end
-- seed with contact shadow; ramp 6 tones
function D.seed(c, cx, cy, rx, ry, ang, ramp, shadow)
  return B.seed(c, cx, cy, rx, ry, ang, ramp, shadow or "#1f3f33")
end
function D.drop(c, x, y)
  c:px(x, y, "#3a86b0") c:px(x, y + 1, "#5fc4c8") c:px(x + 1, y + 1, "#3a86b0") c:px(x, y + 2, "#3a86b0")
  c:px(x, y + 1, "#8ee0dc") c:px(x - 1, y + 1, "#b6f0e0")
end
-- tapered stem tube with 3 tone
function D.stem(c, pts, ramp, w)
  for i = 1, #pts - 1 do B.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], ramp[4]) end
end
return D

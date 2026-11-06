-- dD10 helper (chunk D10): thin layer over batch2/_b2.lua; shared files untouched.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = B.K, INK = "#2b1c26", CREAM = "#fff4d6", SPEC = "#fffbe8" }
D.new, D.ell, D.lit, D.ln, D.polyline, D.fin, D.seam = B.new, B.ell, B.lit, B.ln, B.polyline, B.fin, B.seam
D.hash = X.hash
-- leaf scrap blade with side veins
function D.scrap(c, ax, ay, bx, by, w, ramp, veins, o)
  o = o or {} o.veins = veins or { 5, 9, 13, 17, 21, 25 } o.slant = o.slant or 2.2
  return B.blade(c, ax, ay, bx, by, w, ramp, o)
end
-- bezier tube (4 pts), half width wfn(t), lit
function D.tube(c, pts, wfn, ramp, R, o)
  local m, T = H.sweep(pts, wfn, 70)
  B.lit(c, m, ramp, R or 1.6, o)
  return m, T
end
-- small blob leaf from a to b (pointed ellipse-ish) lit
function D.leafy(c, ax, ay, bx, by, w, ramp, rib)
  local m = B.blade(c, ax, ay, bx, by, w, ramp, { norib = not rib, veins = nil })
  return m
end
-- spots of colour inside a mask by hash
function D.speck(c, m, hex, dens, seed)
  m:each(function(x, y) if X.hash(x, y, seed or 7) < dens then c:px(x, y, hex) end end)
end
-- tapered rrect-free quick poly lit
function D.polylit(c, pts, ramp, R, o)
  local m = c:poly(pts) B.lit(c, m, ramp, R or 2, o) return m
end
-- centre the drawing then finish/save (bbox incl. future outline)
function D.fin(c)
  local x0, y0, x1, y1 = 99, 99, -1, -1
  for i in pairs(c.pix) do local x, y = i % 64, i // 64 x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  x0, y0, x1, y1 = x0 - 1, y0 - 1, x1 + 1, y1 + 1
  local dx, dy = floor((64 - (x1 - x0 + 1)) / 2) - x0, floor((64 - (y1 - y0 + 1)) / 2) - y0
  local np, no = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % 64 + dx, i // 64 + dy
    if x >= 0 and y >= 0 and x < 64 and y < 64 then np[y * 64 + x] = v no[y * 64 + x] = c.own[i] end end
  c.pix, c.own = np, no
  B.fin()
end
return D

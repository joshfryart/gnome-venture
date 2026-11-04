-- _dC22: first-draft helper for chunk dC22 (thin layer over batch2/_b2.lua, which is not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local D = { B = B, H = H, HP = HP, X = X, P = H.P }
function D.new(name) local c = B.new(name) D.c = c return c end
function D.fin() B.fin() end
function D.R(hi, base, shade, deep) return H.ramp({ hi = hi, base = base, shade = shade, deep = deep }) end
-- 6-tone ramp from two end colours
function D.span(dark, light) local r = {} for i = 0, 5 do r[#r+1] = H.mix(dark, light, i / 5) end return r end
function D.ell(c, cx, cy, rx, ry, ang, ramp, R, o) local m = B.ell(cx, cy, rx, ry, ang) B.lit(c, m, ramp, R or min(rx, ry), o) return m end
function D.rect(c, x0, y0, x1, y1, ramp, R, r) local m = c:rrect(x0, y0, x1, y1, r or 1) B.lit(c, m, ramp, R or 2) return m end
function D.rod(c, ax, ay, bx, by, w, ramp, o) local m = H.cyl(c, ax, ay, bx, by, function() return w end, ramp, o) return m end
function D.taper(c, ax, ay, bx, by, w0, w1, ramp) local m = H.cyl(c, ax, ay, bx, by, function(t) return w0 + (w1 - w0) * t end, ramp) return m end
function D.spec(c, x, y, big) H.spec(c, x, y, "#fff4d6", big) end
function D.ring(c, cx, cy, ro, ri, ramp)
  local m = c:ellipse(cx, cy, ro, ro) m:cut(c:ellipse(cx, cy, ri, ri)) B.lit(c, m, ramp, (ro - ri) + .5, { amb = .1 }) return m
end
function D.wheel(c, cx, cy, ro, ri, tire, hubr, spokes, spokeHex)
  D.ring(c, cx, cy, ro, ri, tire)
  for i = 0, spokes - 1 do local a = i / spokes * pi * 2 + .3
    B.ln(c, cx, cy, floor(cx + cos(a) * (ri - .3) + .5), floor(cy + sin(a) * (ri - .3) + .5), spokeHex) end
  D.ell(c, cx, cy, hubr, hubr, 0, "stone", hubr)
end
-- leaf scrap for seed items: lanceolate blade (ax,ay)->(bx,by), half width w
function D.scrap(c, ax, ay, bx, by, w, ramp, o)
  o = o or {} o.veins = o.veins or { 5, 10, 15, 20, 25, 30 }
  return B.blade(c, ax, ay, bx, by, w, ramp, o)
end
function D.shadowSeeds(c, list, ramp) for _, s in ipairs(list) do B.seed(c, s[1], s[2], s[3], s[4], s[5] or 0, s[6] or ramp, s[7]) end end
function D.sprout(c, x, y, tx, ty, leaves, ramp, stem) B.sprout(c, x, y, tx, ty, stem or "#3f9150", leaves, ramp) end
function D.jar(c, x0, y0, x1, y1, glass, fill, fy)
  local m = c:rrect(x0, y0, x1, y1, 3)
  H.vcyl(c, m, glass, x0, x1)
  local f = c:rrect(x0 + 2, fy, x1 - 2, y1 - 1, 2) H.vcyl(c, f, fill, x0 + 2, x1 - 2)
  c:px(x0 + 1, y0 + 4, "#fff4d6") c:px(x0 + 1, y0 + 5, "#fff4d6")
  return m, f
end
return D

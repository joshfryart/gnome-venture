-- _dC11 helper (chunk dC11, first drafts). Thin layer over batch2/_b2.lua (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X, K = B.H, B.HP, B.X, B.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X, K = K, P = H.P, ell = B.ell, lit = B.lit, ln = B.ln, blade = B.blade, seed = B.seed, seam = B.seam }
function D.new(n) return B.new(n) end
function D.fin() B.fin() end
function D.r4(hi, base, shade, deep) return H.ramp({ hi = hi, base = base, shade = shade, deep = deep }) end
function D.ramp(r) return H.ramp(r) end
-- fill mask with lit ramp; returns mask
function D.part(c, m, ramp, R, o) B.lit(c, m, ramp, R or 3, o) return m end
-- horizontal-banded recolour of mask pixels in a y range
function D.bandrows(c, m, y0, y1, hex) m:each(function(x, y) if y >= y0 and y <= y1 then c:px(x, y, hex) end end) end
-- bezier point
function D.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1], u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- stalk along a bezier with width fn, lit
function D.tube(c, pts, wfn, ramp, R)
  local m, T = H.sweep(pts, wfn, 70)
  B.lit(c, m, ramp, R or 2)
  return m, T
end
-- leaf scrap with 1 diagonal blade + veins; returns mask
function D.scrap(c, ramp, o)
  o = o or {}
  local m = B.blade(c, o.ax or 5, o.ay or 57, o.bx or 58, o.by or 50, o.w or 8.5, ramp or "moss", { veins = o.veins or { 8, 14, 20, 26, 32, 38, 44 } })
  return m
end
-- seed on scrap (lit oval + glint). shadow colour dark leaf
function D.sd(c, cx, cy, rx, ry, ang, ramp, glint)
  return B.seed(c, cx, cy, rx, ry, ang, ramp, "#1f3f35", glint)
end
-- conical wizard hat. o: ramp, brim ramp, tip bezier {4 pts}, w0 half base width, brim {cx,cy,rx,ry}, 
function D.hat(c, o)
  local br = o.brim or { 32, 49, 22, 6 }
  local bm = D.ell(br[1], br[2], br[3], br[4])
  B.lit(c, bm, o.bramp or o.ramp, 3)
  -- brim underside rim darker row
  bm:each(function(x, y) if not bm:has(x, y + 1) and y > br[2] then c:px(x, y, D.ramp(o.bramp or o.ramp)[1]) end end)
  local w0 = o.w0 or 13
  local m, T = H.sweep(o.tip, function(t) return w0 * (1 - t) ^ (o.pw or 0.85) + 0.7 end, 90)
  B.lit(c, m, o.ramp, 4)
  -- ambient dark where cone meets brim
  m:each(function(x, y) if y >= br[2] - 2 and y <= br[2] - 1 and not bm:has(x, y + 3) then end end)
  return m, T, bm
end
return D

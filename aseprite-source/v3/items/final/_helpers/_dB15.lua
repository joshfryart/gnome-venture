-- _dB15: helper for ph/ch* first drafts. Thin layer over batch2/_b2.lua (read-only).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local D = setmetatable({}, { __index = B })
local max, min, sin, pi, floor = math.max, math.min, math.sin, math.pi, math.floor
function D.new(name) return B.new(name) end
function D.fin() B.fin() end
function D.ramp(r) return H.ramp(r) end
-- leaf scrap along the bottom: seeds sit on it
function D.scrap(c, ramp, o)
  o = o or {}
  local x0, y0, x1, y1 = o.x0 or 6, o.y0 or 55, o.x1 or 56, o.y1 or 52
  return B.blade(c, x0, y0, x1, y1, o.w or 8, ramp or "moss", { veins = o.veins or { 8, 14, 20, 26, 32, 38 }, slant = 2.4 })
end
-- seed with contact shadow; returns mask
function D.seed(c, cx, cy, rx, ry, ang, ramp, glint) return B.seed(c, cx, cy, rx, ry, ang, ramp, "#1f553f", glint) end
-- curved stem via bezier sweep
function D.stem(c, pts, w0, w1, ramp)
  local m, T = H.sweep(pts, function(t) return w0 + (w1 - w0) * t end)
  H.lit(c, m, ramp, { R = 1.5 })
  return m
end
-- ground shadow
function D.shadow(c, cx, cy, rx, ry) c:groundShadow(cx, cy, rx, ry) end
-- small sprout: stem pts (bezier) and leaf list {ax,ay,bx,by,w}
function D.sprout(c, pts, leaves, stemRamp, leafRamp, veins)
  D.stem(c, pts, 0.9, 0.8, stemRamp or "moss")
  for _, L in ipairs(leaves) do H.leaf(c, L[1], L[2], L[3], L[4], L[5], leafRamp or "moss", veins or { 2 }) end
end
function D.bez(p, t) local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1], u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2] end
-- polyline along bezier in hex, optionally clipped, offset ox,oy
function D.bline(c, p, hex, clip, ox, oy, t0, t1)
  local pxp, pyp
  for i = floor((t0 or 0) * 30), floor((t1 or 1) * 30) do
    local x, y = D.bez(p, i / 30) x, y = floor(x + (ox or 0) + .5), floor(y + (oy or 0) + .5)
    if pxp then B.ln(c, pxp, pyp, x, y, hex, clip) end
    pxp, pyp = x, y
  end
end
return D

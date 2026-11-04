-- _aD13_3.lua: private helpers for ph/rose-of-sharon-seed, rosemary, rosemary-seed, rubber-sap (Sonnet, final pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local A = { G = G, HP = G.HP, X = G.X, K = G.K }
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- 1px Bresenham line
function A.line(c, x0, y0, x1, y1, hex, tok)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    c:put(x0, y0, hex, tok)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end

-- distance / side / t of a pixel to a segment. side > 0 = above the line for a line running down-right
function A.dseg(px, py, x0, y0, x1, y1)
  local vx, vy = x1 - x0, y1 - y0
  local l2 = vx * vx + vy * vy
  local t = max(0, min(1, ((px - x0) * vx + (py - y0) * vy) / l2))
  local qx, qy = x0 + vx * t, y0 + vy * t
  local d = sqrt((px - qx) ^ 2 + (py - qy) ^ 2)
  local side = ((px - x0) * vy - (py - y0) * vx) / sqrt(l2)
  return d, side, t
end

-- slim lit needle from base (cx,cy) along angle ang. ramp = 6 tones dark..light. o.silver = pale underside colour
function A.needle(c, cx, cy, ang, len, hw, ramp, tok, o)
  o = o or {}
  local ux, uy = cos(ang), sin(ang)
  local mx, my = cx + ux * len / 2, cy + uy * len / 2
  local m = G.rell(mx, my, ux, uy, len / 2 + 0.35, hw)
  local nx, ny = -uy, ux
  if nx * -0.55 + ny * -0.7 < 0 then nx, ny = -nx, -ny end
  m:each(function(x, y)
    local s = (x - mx) * nx + (y - my) * ny
    local u = ((x - cx) * ux + (y - cy) * uy) / len
    local i = s > 0.3 and 5 or (s > -0.3 and 4 or 3)
    if u < 0.2 then i = i - 1 end
    if u > 0.85 then i = i + 1 end
    i = o.bias and (i + o.bias) or i
    if o.silver and s < -0.3 and u > 0.12 then c:put(x, y, o.silver, tok)
    else c:put(x, y, ramp[max(1, min(#ramp, i))], tok) end
  end)
  return m
end
return A

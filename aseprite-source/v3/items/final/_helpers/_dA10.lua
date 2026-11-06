-- _dA10: helper for chunk dA10 first drafts (ico-spade .. ico-test-tube). Layer over _dA8 (not edited).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dA8.lua")
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
-- star polygon points (n points, outer ro, inner ri), rot in radians (-pi/2 = point up)
function D.starPts(cx, cy, ro, ri, n, rot)
  local p = {}
  for i = 0, 2 * n - 1 do
    local r = (i % 2 == 0) and ro or ri
    local a = (rot or -pi / 2) + i * pi / n
    p[#p + 1] = { floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5) }
  end
  return p
end
function D.poly(c, pts, ramp, R, o) local m = c:poly(pts) D.lit(c, m, ramp, R or 4, o) return m end
function D.ladybug(c, x, y)
  D.rect(c, x, y, x + 4, y + 3, D.RED[4]) D.rect(c, x + 1, y - 1, x + 3, y - 1, D.RED[4])
  D.rect(c, x + 2, y - 1, x + 2, y + 3, D.INK) c:px(x, y + 1, D.INK) c:px(x + 4, y + 2, D.INK)
  c:px(x + 1, y, D.RED[6]) D.rect(c, x, y + 3, x + 4, y + 3, D.RED[2])
end
function D.bubble(c, x, y, r)
  local m = c:ellipse(x, y, r, r) D.lit(c, m, D.BLU, r, { amb = 0.3 })
  c:px(x - 1, y - 1, D.CREAM)
end
return D

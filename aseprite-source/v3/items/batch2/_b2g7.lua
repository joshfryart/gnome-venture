-- _b2g7.lua: private helpers for cacao + cacao-seed (batch2, single pass). Wraps batch1/_g1.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G0 = dofile(DIR .. "/../batch1/_g1.lua")
local G = setmetatable({}, { __index = G0 })
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min

-- quadratic bezier point + unit tangent at t
function G.qb(ax, ay, cx, cy, bx, by, t)
  local u = 1 - t
  local x, y = u*u*ax + 2*u*t*cx + t*t*bx, u*u*ay + 2*u*t*cy + t*t*by
  local dx, dy = 2*u*(cx - ax) + 2*t*(bx - cx), 2*u*(cy - ay) + 2*t*(by - cy)
  local l = sqrt(dx*dx + dy*dy)
  return x, y, dx / l, dy / l
end

-- shift the finished drawing so its bbox is centred on the canvas (call before finish)
function G.centre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1, -1
  for k in pairs(c.pix) do local x, y = k % c.w, k // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local dx = floor((c.w - 1 - x1 - x0) / 2 + 0.5)
  local dy = floor((c.h - 1 - y1 - y0) / 2 + 0.5)
  local np, no = {}, {}
  for k, v in pairs(c.pix) do local x, y = k % c.w + dx, k // c.w + dy
    if x >= 0 and y >= 0 and x < c.w and y < c.h then np[y * c.w + x] = v no[y * c.w + x] = c.own[k] end end
  c.pix, c.own = np, no
  return dx, dy
end
return G

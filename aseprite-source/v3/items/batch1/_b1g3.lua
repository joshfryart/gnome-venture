-- _b1g3.lua: private helpers for bug-net / fine-foraging-knife / broken-wheelbarrow (batch1 group 3).
-- Wraps _h.lua (unchanged). NAME comes from the calling script's file name, so x.pA.lua writes x.pA.png.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/_h.lua")
local G = setmetatable({}, { __index = H })
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local K = H.K
function G.start(src)
  local name = src:match("([^/\\]+)%.lua$")
  local HP, X, c, P = H.new(name)
  return HP, X, c, P, name
end
-- paint with per-pixel tone index from value v[k] (0..1) + bias, into ramp (dark..light)
function G.paint(c, m, v, ramp, cuts, bias, tok)
  cuts = cuts or { 0.22, 0.4, 0.56, 0.72, 0.86 }
  local idx = {}
  m:each(function(x, y)
    local k = K(x, y)
    local i = 1
    for j, t in ipairs(cuts) do if (v[k] or 0) >= t then i = j + 1 end end
    i = i + ((bias and bias[k]) or 0)
    i = max(1, min(#ramp, i))
    idx[k] = i
    c:put(x, y, ramp[i], tok)
  end)
  return idx
end
-- tube normal for an elliptical ring (wire hoop): outward on outer half, inward on inner half
function G.ringNormals(m, cx, cy, rx, ry, mid)
  local n = {}
  m:each(function(x, y)
    local dx, dy = (x - cx) / rx, (y - cy) / ry
    local e = sqrt(dx * dx + dy * dy)
    local gx, gy = (x - cx) / (rx * rx), (y - cy) / (ry * ry)
    local gl = sqrt(gx * gx + gy * gy) + 1e-6
    gx, gy = gx / gl, gy / gl
    local s = max(-0.95, min(0.95, (e - mid) * 9))
    local z = sqrt(1 - s * s)
    n[K(x, y)] = { gx * s, gy * s, z }
  end)
  return n
end
function G.move(c, dx, dy)
  local np, no = {}, {}
  for k, v in pairs(c.pix) do
    local x, y = k % c.w, k // c.w
    local nx, ny = x + dx, y + dy
    if nx >= 0 and ny >= 0 and nx < c.w and ny < c.h then np[ny * c.w + nx] = v no[ny * c.w + nx] = c.own[k] end
  end
  c.pix, c.own = np, no
end
return G

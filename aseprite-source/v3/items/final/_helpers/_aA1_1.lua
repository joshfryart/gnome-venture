-- _aA1_1: helper for ico-bed / ico-bee / ico-beetle / ico-bell (Opus single pass).
-- Thin read-only layer over batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua). Shared files untouched.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs, sin, cos = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos
local A = setmetatable({ HP = HP, X = X, K = K }, { __index = G })
A.INK, A.CR = "#2b1c26", "#fff4d6"
function A.new(name) A.c = HP.canvas{ w = 64, h = 64, scale = 1, name = name } return A.c end
-- paint mask m with ramp from normals n; returns idx table (k -> tone index)
function A.shade(m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(A.c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias })
  return idx, v
end
-- set / shift tone of one pixel inside a part painted with A.shade
function A.set(idx, ramp, x, y, i)
  local k = K(x, y) if not idx[k] then return end
  i = max(1, min(#ramp, i)) idx[k] = i A.c:px(x, y, ramp[i])
end
function A.sh(idx, ramp, x, y, d) local k = K(x, y) if idx[k] then A.set(idx, ramp, x, y, idx[k] + d) end end
-- ambient occlusion: darken pixels of part (idx) within r px of mask `other`
function A.ao(idx, ramp, m, other, r, amt)
  local ring = other:copy()
  for i = 1, r do
    local g = ring:grow(1)
    g:copy():cut(ring):each(function(x, y) if m:has(x, y) and not other:has(x, y) then A.sh(idx, ramp, x, y, amt or -1) end end)
    ring = g
  end
end
function A.ln(x0, y0, x1, y1, hex, clip)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do
    local t = n == 0 and 0 or i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    if not clip or clip:has(x, y) then A.c:px(x, y, hex) end
  end
end
-- thick polyline mask (disc stamps of radius r along segments)
function A.limb(pts, r)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(1, floor(sqrt((b[1]-a[1])^2 + (b[2]-a[2])^2) * 3))
    for s = 0, n do
      local x, y = a[1] + (b[1]-a[1]) * s / n, a[2] + (b[2]-a[2]) * s / n
      for yy = floor(y - r - 1), floor(y + r + 1) do for xx = floor(x - r - 1), floor(x + r + 1) do
        if (xx - x)^2 + (yy - y)^2 <= r * r then m:set(xx, yy) end end end
    end
  end
  return m
end
-- rotated ellipse mask + ellipsoid normals (flat<1 flattens the dome)
function A.egg(cx, cy, rx, ry, ang, flat)
  local m, n = G.oval(cx, cy, rx, ry, ang or 0, flat)
  return m, n
end
function A.save(name) G.save2(A.c, name) end
return A

-- _aB30_4.lua: private helpers for the four feast items (mistmoor supper, olivewhistle supper, orchard crumble,
-- riverside bake). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local A = setmetatable({}, { __index = G })
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- lit mask with a normal table (ellipsoid etc.)
function A.shadeN(c, m, n, ramp, o)
  o = o or {}
  return G.toneN(c, m, n, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, amb = o.amb, wrap = o.wrap, tok = o.tok })
end
-- pillow-lit mask
function A.pil(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R or 2, o.hs)
  local idx = A.shadeN(c, m, n, ramp, o)
  return idx, n
end
-- ellipse mask (float centre)
function A.ell(cx, cy, rx, ry) return G.rell(cx, cy, 1, 0, rx, ry) end
-- vertical-axis cylinder normals over x0..x1 (+ ny tilt)
function A.vn(m, x0, x1, ny)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    local nz = sqrt(1 - t * t)
    local l = sqrt(t*t + (ny or 0)^2 + nz*nz)
    n[K(x, y)] = { t / l, (ny or 0) / l, nz / l }
  end)
  return n
end
-- paint pixels of m (only where already painted / within clip) with hex
function A.fill(c, m, hex, clip)
  m:each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, hex) end end)
end
-- 1px polyline points
function A.dots(c, pts, hex) for _, p in ipairs(pts) do c:put(p[1], p[2], hex) end end
-- pixel map
function A.map(c, x0, y0, rows, pal)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch]) end end end
end
A.hash = X.hash
return A

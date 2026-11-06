-- _aD10_1.lua: private helpers for pomegranate-molasses / pomegranate-seed / potato / potato-leek-soup (D10, artist 1).
-- Wraps batch2/_b2g1.lua (read-only) and adds a few small utilities.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
function G.smooth(t) t = max(0, min(1, t)) return t * t * (3 - 2 * t) end
-- smooth value noise 0..1
function G.vnoise(x, y, sc, s)
  local fx, fy = x / sc, y / sc
  local ix, iy = floor(fx), floor(fy)
  local tx, ty = G.smooth(fx - ix), G.smooth(fy - iy)
  local a, b = X.hash(ix, iy, s), X.hash(ix + 1, iy, s)
  local c, d = X.hash(ix, iy + 1, s), X.hash(ix + 1, iy + 1, s)
  return (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
end
function G.nrm(x, y, z) local l = sqrt(x * x + y * y + z * z) return x / l, y / l, z / l end
-- vertical-axis cylinder normals for mask m; wf(y) half width, cx centre (continuous)
function G.cylN(m, wf, cx)
  local n = {}
  m:each(function(x, y)
    local sn = max(-0.97, min(0.97, (x + 0.5 - cx) / (wf(y) + 0.5)))
    n[K(x, y)] = { sn, 0, sqrt(1 - sn * sn) }
  end)
  return n
end
return G

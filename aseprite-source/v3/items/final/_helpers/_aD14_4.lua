-- _aD14_4.lua: private helpers for scotch-quail-eggs, scrambled-eggs, sea-buckthorn, sea-buckthorn-juice (Sonnet high).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
G.out = app.params.out or (DIR .. "/")
G.H = X.hash
-- analytic ellipsoid normals over any mask
function G.ellN(m, cx, cy, rx, ry, flat)
  local n = {}
  m:each(function(x, y)
    local nx, ny = (x - cx) / (rx + 0.6), (y - cy) / (ry + 0.6)
    local q = 1 - nx * nx - ny * ny
    n[K(x, y)] = { G.norm(nx, ny, sqrt(max(q, 0.05)) * (flat or 1)) }
  end)
  return n
end
-- egg shaped mask (broad end down)
function G.eggM(cx, cy, rx, ry, k)
  local m = HP.mask()
  for y = floor(cy - ry), math.ceil(cy + ry) do
    local t = (y - cy) / ry
    local w = rx * sqrt(max(0, 1 - t * t)) * (1 + (k or .14) * t)
    for x = floor(cx - w + .5), floor(cx + w - .5) do m:set(x, y) end
  end
  return m
end
-- paint hex on pixels of `prev` that touch mask m (contact line)
function G.touch(c, m, prev, hex)
  m:grow(1):each(function(x, y) if not m:has(x, y) and prev:has(x, y) then c:px(x, y, hex) end end)
end
function G.clamp(v, a, b) return max(a, min(b, v)) end
return G

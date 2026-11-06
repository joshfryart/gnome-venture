-- _aB23_1.lua: private helpers for ph/cured-olives, curry-paste, custard-tart, cyclamen-seed (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS = CUTS
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- ellipsoid normals for a mask (centre cx,cy radii rx,ry); flat < 1 flattens the dome
function A.ellN(m, cx, cy, rx, ry, flat)
  local n = {}
  m:each(function(x, y)
    local a, b = (x - cx) / (rx + .5), (y - cy) / (ry + .5)
    local q = 1 - a*a - b*b
    n[K(x, y)] = { norm(a, b, sqrt(max(q, 0.02)) / (flat or 1)) }
  end)
  return n
end

-- blend two normal fields (w = weight of b)
function A.mix(na, nb, w)
  local n = {}
  for k, a in pairs(na) do local b = nb[k] or a
    n[k] = { norm(a[1] * (1 - w) + b[1] * w, a[2] * (1 - w) + b[2] * w, a[3] * (1 - w) + b[3] * w) } end
  return n
end

-- vertical cylinder normals: per row the half width is measured from the mask itself
function A.cylV(m, cx, rx)
  local n = {}
  m:each(function(x, y)
    local a = max(-0.97, min(0.97, (x - cx) / (rx + .5)))
    n[K(x, y)] = { a, 0, sqrt(1 - a*a) }
  end)
  return n
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

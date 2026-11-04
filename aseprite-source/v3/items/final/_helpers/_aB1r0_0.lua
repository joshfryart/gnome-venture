-- _aB1r0_0.lua: private helpers for ph/camellia-seed, camp-kit, candied-chestnuts, candied-citrus-peel (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok }), v
end

-- blend sphere + pillow normals (round body with a soft silhouette)
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 4)
  local ns = X.sphere(cx, cy, r, m)
  wS = wS or 0.65
  local n = {}
  for k, a in pairs(ns) do
    local b = np[k] or a
    n[k] = { norm(a[1] * wS + b[1] * (1 - wS), a[2] * wS + b[2] * (1 - wS), a[3] * wS + b[3] * (1 - wS)) }
  end
  return n
end

-- strongest specular pixel; puts cream there and a hi neighbour left of it
function A.glint(c, m, n, hi, power, tok)
  local x, y = G.specAt(m, n, power or 40)
  if x then c:put(x, y, A.CREAM, tok) if hi and m:has(x - 1, y) then c:put(x - 1, y, hi, tok) end end
  return x, y
end

function A.done(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

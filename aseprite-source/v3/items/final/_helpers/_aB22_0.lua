-- _aB22_0.lua: private helpers for ph/cornbread, ph/cornflower-seed, ph/cosmos-seed, ph/cottongrass (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua). Saves into final/<folder>/.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G0 = dofile(DIR .. "/../../batch2/_b2g1.lua")
local G = setmetatable({}, { __index = G0 })
local HP, X, K = G0.HP, G0.X, G0.K
G.HP, G.X, G.K = HP, X, K
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
G.norm = norm

function G.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- flat face with a bevelled rim: face normal f tilted by pillow normals (bevel radius R)
function G.face(m, f, R, k)
  local pn = X.pillow(m, R or 2)
  local n = {}
  k = k or 1
  for key, p in pairs(pn) do n[key] = { norm(f[1] + p[1] * k, f[2] + p[2] * k, f[3] * p[3]) } end
  return n
end

-- line of pixels along points (1px), returns mask
function G.poly1(pts)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local n = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1)
    for t = 0, n do m:set(floor(a[1] + (b[1] - a[1]) * t / n + .5), floor(a[2] + (b[2] - a[2]) * t / n + .5)) end
  end
  return m
end

function G.saveTo(c, folder, name)
  G0.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  local out = DIR .. "/../" .. folder .. "/"
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return G

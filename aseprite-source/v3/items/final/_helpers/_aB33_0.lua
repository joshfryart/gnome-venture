-- _aB33_0.lua: private helpers for fuchsia-seed, garam-masala, garden-bench, garden-fork (aB33_0, Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G0 = dofile(DIR .. "/../../batch2/_b2g1.lua")
local A = setmetatable({}, { __index = G0 })
local HP, X, K = G0.HP, G0.X, G0.K
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
A.HP, A.X, A.K = HP, X, K
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) A.name = name return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- rotated local frame: fn(u, v, x, y) -> nil | tag, nu, nv, nz (local normal). ang radians (positive = clockwise on screen)
-- returns parts[tag] = { m = mask, n = normals (world), U = {}, V = {} }
function A.field(cx, cy, ang, R, fn)
  local ca, sa = cos(ang), sin(ang)
  local parts = {}
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa
    local v = -dx * sa + dy * ca
    local tag, nu, nv, nz = fn(u, v, x, y)
    if tag then
      local p = parts[tag]
      if not p then p = { m = HP.mask(), n = {}, U = {}, V = {} } parts[tag] = p end
      p.m:set(x, y)
      local k = K(x, y)
      local wx, wy = nu * ca - nv * sa, nu * sa + nv * ca
      p.n[k] = { norm(wx, wy, nz) }
      p.U[k], p.V[k] = u, v
    end
  end end
  return parts
end

function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.28 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or { r = { name = o.name or "p" } } })
end

function A.save(c, name)
  G0.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  local out = app.params.out or (DIR .. "/../ph/")
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
  return r
end
return A

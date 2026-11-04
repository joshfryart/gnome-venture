-- _aC14_1.lua: private helpers for ph/kidney-bean, ph/kidney-bean-seed, ph/kiln-key, ph/kimchi (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) if l == 0 then return 0, 0, 1 end return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- local frame: origin (ox,oy), axis angle ang (u along, v across). f(u,v) -> true to include
function A.frame(ox, oy, ang)
  local ca, sa = cos(ang), sin(ang)
  local F = {}
  function F.uv(x, y) local dx, dy = x - ox, y - oy return dx * ca + dy * sa, -dx * sa + dy * ca end
  function F.xy(u, v) return ox + u * ca - v * sa, oy + u * sa + v * ca end
  function F.mask(f, R)
    local m = HP.mask()
    for y = 0, 63 do for x = 0, 63 do local u, v = F.uv(x, y) if f(u, v) then m:set(x, y) end end end
    return m
  end
  -- local-normal (nu,nv,nz) -> image normal
  function F.n(nu, nv, nz) return { norm(nu * ca - nv * sa, nu * sa + nv * ca, nz) } end
  return F
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

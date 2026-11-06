-- _aB24_4.lua: private helpers for ph/dried-dates, dried-figs, dried-mango, dried-mushrooms (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua, hp.lua, hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- rotated ellipsoid: mask, normals, U (along major -1..1), V (across -1..1). flat <1 flattens the dome
function A.oval(cx, cy, rx, ry, ang, flat)
  local ca, sa = cos(ang), sin(ang)
  local m, n, U, V = HP.mask(), {}, {}, {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local k = K(x, y)
      local a, b = u / (rx + .45), v / (ry + .45)
      local wx, wy = a * ca - b * sa, a * sa + b * ca
      local nz = sqrt(max(1 - q, 0.02)) / ((rx + ry) / 2) / (flat or 1)
      n[k] = { norm(wx, wy, nz) }
      U[k], V[k] = u, v
    end
  end end
  return m, n, U, V
end

function A.tone(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = o.bias, tok = o.tok }), v
end

-- cool reflected light on lower-right edge pixels of mask
function A.bounce(c, m, n, hex, thr, tok)
  local r = X.rim(n)
  m:edge():each(function(x, y) local k = K(x, y) if r[k] and r[k] > (thr or 0.62) then c:put(x, y, hex, tok) end end)
end

-- specular: cream pixel at brightest Blinn spot plus a hi neighbour
function A.glint(c, m, n, spec, hi, tok, power)
  local x, y = G.specAt(m, n, power or 40)
  if x then c:put(x, y, spec, tok) if hi and m:has(x + 1, y) then c:put(x + 1, y, hi, tok) end end
  return x, y
end

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.done(c, name) G.save2(c, name) end
return A

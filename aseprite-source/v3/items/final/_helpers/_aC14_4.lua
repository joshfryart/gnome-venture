-- _aC14_4.lua: private helpers for ph/kiwi-seed, ph/kohlrabi, ph/kohlrabi-seed, ph/koi-pond (final pass, Opus).
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

-- weighted blend of normal fields (missing entries skipped)
function A.blend(m, list)
  local n = {}
  m:each(function(x, y) local k = K(x, y) local a, b, cc = 0, 0, 0
    for _, e in ipairs(list) do local v = e[1][k] if v then a, b, cc = a + v[1]*e[2], b + v[2]*e[2], cc + v[3]*e[2] end end
    n[k] = { norm(a, b, cc) } end)
  return n
end

-- heart-shaped leaf (implicit heart), notch at the top in local frame; ang rotates (radians, + = clockwise)
-- returns mask, local coords U (along, 0 at notch .. 1 at tip), V (across, -1..1), notch point
function A.heart(cx, cy, S, ang, sx, sy)
  sx, sy = sx or 1, sy or 1
  local ca, sa = cos(ang), sin(ang)
  local m, U, V = HP.mask(), {}, {}
  local R = floor(S * 1.6) + 2
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local lx = dx * ca + dy * sa
    local ly = -dx * sa + dy * ca
    local hx, hy = lx / (S * sx), -ly / (S * sy)
    local q = hx*hx + hy*hy - 1
    if q*q*q - hx*hx*hy*hy*hy <= 0 then
      m:set(x, y) local k = K(x, y)
      U[k] = (1 - hy) / 2   -- notch (hy=1) -> 0, tip (hy=-1) -> 1
      V[k] = hx / 1.15
    end
  end end
  local nx, ny = cx + (-(-S * sy)) * (-sa), cy + (-S * sy) * ca
  return m, U, V, { cx + S * sy * sa, cy - S * sy * ca }
end

-- deterministic jagged tear: removes pixels of m beyond the line through (px,py) with outward normal (nx,ny)
function A.tear(m, px, py, nx, ny, amp, seed)
  local torn = HP.mask()
  local l = sqrt(nx*nx + ny*ny) nx, ny = nx / l, ny / l
  local cut = {}
  m:each(function(x, y)
    local d = (x - px) * nx + (y - py) * ny
    local along = (x - px) * -ny + (y - py) * nx
    local j = (X.hash(floor(along / 2), 7, seed or 1) - 0.5) * 2 * amp + sin(along * 0.9) * amp * 0.5
    if d > j then cut[#cut + 1] = K(x, y) end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  -- torn edge pixels: border pixels whose removed neighbour came from the cut
  local cs = {} for _, k in ipairs(cut) do cs[k] = true end
  m:edge():each(function(x, y)
    if cs[K(x+1, y)] or cs[K(x-1, y)] or cs[K(x, y+1)] or cs[K(x, y-1)] then torn:set(x, y) end end)
  return torn
end

-- recentre, outline, check, save into OUT
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

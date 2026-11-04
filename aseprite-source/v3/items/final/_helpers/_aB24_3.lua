-- _aB24_3.lua: private helpers for ph/dragonfly-wing, dried-apple-rings, dried-apricots, dried-cranberries (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- sphere + pillow blend
function A.body(m, cx, cy, r, R, wS)
  local np = X.pillow(m, R or 5)
  local ns = X.sphere(cx, cy, r, m)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

-- perturb normals with a function f(x,y) -> dx,dy (wrinkles)
function A.bump(n, f)
  for k, a in pairs(n) do local x, y = k % 1024 - 256, k // 1024 - 256
    local dx, dy = f(x, y)
    if dx then n[k] = { norm(a[1] + dx, a[2] + dy, a[3]) } end
  end
  return n
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- 1px pixel line (Bresenham) through fn(x,y)
function A.ln(x0, y0, x1, y1, f)
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    f(x0, y0)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

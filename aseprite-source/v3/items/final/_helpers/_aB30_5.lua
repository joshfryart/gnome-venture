-- _aB30_5.lua: private helpers for feast-spicepeak-thali, feast-steppe-table, feast-summer-table, feijoa (B30, Opus).
-- Read-only use of v3/lib/hp.lua + hpx.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local G = { HP = HP, X = X, K = K, P = HP.P }
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
G.norm = norm
G.CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }

function G.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light normals n over mask m, quantise into ramp (dark..light). returns idx, v
function G.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or G.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
function G.pillow(c, m, ramp, R, o)
  local n = X.pillow(m, R or 2)
  local idx, v = G.shade(c, m, n, ramp, o)
  return idx, n, v
end
-- rotated ellipsoid mask + normals
function G.oval(cx, cy, rx, ry, ang, flat)
  local ca, sa = cos(ang or 0), sin(ang or 0)
  local m, n = HP.mask(), {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local a, b = u, v
      local wx, wy = a * ca - b * sa, a * sa + b * ca
      n[K(x, y)] = { norm(wx, wy, sqrt(max(1 - q, 0.03)) * (flat or 1)) }
    end
  end end
  return m, n
end
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- swept disc along a cubic bezier, radius wfn(t). returns mask, T
function G.sweep(p, wfn, steps)
  steps = steps or 80
  local m, T = HP.mask(), {}
  for i = 0, steps do
    local t = i / steps
    local x, y = G.bez(p, t)
    local r = wfn(t)
    local R = math.ceil(r) + 1
    for dy = -R, R do for dx = -R, R do
      local px, py = floor(x + dx + .5), floor(y + dy + .5)
      if (px - x)^2 + (py - y)^2 <= r * r + 0.2 then
        if not m:has(px, py) then T[K(px, py)] = t end
        m:set(px, py)
      end
    end end
  end
  return m, T
end
-- vertical-axis cylinder normals (x0..x1 span)
function G.vcylN(m, x0, x1, ny)
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x + .5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { norm(t, ny or 0, sqrt(1 - t*t)) }
  end)
  return n
end
-- paint hex onto pixels of `under` that touch `over` (4-neighbour) but are not in it: ambient / contact line
function G.ao(c, under, over, hex, dx, dy)
  local ring = over:shift(dx or 0, dy or 0):grow(1)
  ring:each(function(x, y) if under:has(x, y) and not over:has(x, y) then c:put(x, y, hex, c.own[y * c.w + x]) end end)
end
-- recolour pixels of mask that are inside `clip` (or everywhere)
function G.fill(c, m, hex, clip)
  m:each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, hex) end end)
end
G.hash = X.hash
-- shift all drawn pixels so the final (outlined) bbox sits centred on the 64 canvas
function G.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function G.save(c, name)
  local out = app.params.out or "./"
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
return G

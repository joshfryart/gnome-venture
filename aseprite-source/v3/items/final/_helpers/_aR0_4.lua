-- _aR0_4.lua: private helpers for ico-tools, ico-tower, ico-tree, ico-trophy (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local R = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
R.HP, R.X, R.K = HP, X, K
R.OUT = app.params.out or (DIR .. "/../ico/")
R.INK, R.CREAM = "#2b1c26", "#fff4d6"
R.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
R.norm = norm

function R.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + quantise a normal field onto a 6-tone ramp (dark..light); returns idx, v
function R.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.24 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or R.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- step one pixel's tone by d using idx
function R.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- polygon in a local frame: origin (ox,oy), axis a (ax,ay) and axis b (bx,by); pts = {{a,b},..}
function R.lpoly(c, ox, oy, ax, ay, bx, by, pts)
  local w = {}
  for i, p in ipairs(pts) do w[i] = { ox + ax * p[1] + bx * p[2], oy + ay * p[1] + by * p[2] } end
  return c:poly(w)
end
-- local-frame mask by predicate f(a,b) over a world box
function R.lmask(ox, oy, ax, ay, bx, by, f, rad)
  local m = HP.mask()
  rad = rad or 30
  for y = floor(oy - rad), floor(oy + rad) do for x = floor(ox - rad), floor(ox + rad) do
    local dx, dy = x - ox, y - oy
    local a, b = dx * ax + dy * ay, dx * bx + dy * by
    if f(a, b) then m:set(x, y) end
  end end
  return m
end

-- vertical-axis cylinder normals between x0..x1 (bulge optional), tilt lean toward viewer
function R.vcylN(m, x0, x1, tiltY)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { norm(t, tiltY or 0, sqrt(1 - t * t)) }
  end)
  return n
end

function R.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- interior separation: 1px line in `hex` on pixels of mask `m` that 4-touch mask `other`
function R.sepLine(c, m, other, hex, tok)
  m:each(function(x, y)
    if other:has(x + 1, y) or other:has(x - 1, y) or other:has(x, y + 1) or other:has(x, y - 1) then c:put(x, y, hex, tok) end
  end)
end

function R.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = R.OUT .. name .. ".aseprite", png = R.OUT .. name .. ".png", scale = 1 }
end
return R

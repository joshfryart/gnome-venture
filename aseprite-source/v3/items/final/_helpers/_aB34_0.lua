-- _aB34_0.lua: private helpers for ph/geode, ph/gerbera-seed, ph/giant-allium-seed, ph/giant-seed-pod (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local B = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
B.HP, B.X, B.K = HP, X, K
B.OUT = app.params.out or (DIR .. "/../ph/")
B.INK, B.CREAM = "#2b1c26", "#fff4d6"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
B.CUTS = CUTS
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
B.norm = norm

function B.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function B.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or CUTS), bias = o.bias, tok = o.tok })
  return idx, v
end

function B.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- tube along cubic bezier with lighting
function B.stem(c, pts, wfn, ramp, o)
  o = o or {}
  local m, n, T, S, samp = G.tube(pts, wfn)
  if o.cut then m:cut(o.cut) end
  local idx = B.shade(c, m, n, ramp, { amb = o.amb or 0.14, wrap = o.wrap or 0.3, cuts = o.cuts, tok = o.tok, bias = o.bias })
  return m, n, T, S, idx, samp
end

-- ragged torn edge: removes pixels of m near the line through (x0,y0) with normal (nx,ny) on the + side, jittered
function B.tear(m, x0, y0, nx, ny, amp, seed)
  local rm = {}
  m:each(function(x, y)
    local d = (x - x0) * nx + (y - y0) * ny
    local along = -(x - x0) * ny + (y - y0) * nx
    local j = (X.hash(floor(along / 2), 3, seed or 1) - 0.5) * 2 * amp
    if d > j then rm[#rm + 1] = K(x, y) end
  end)
  for _, k in ipairs(rm) do m.s[k] = nil end
  return m
end

function B.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function B.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = B.OUT .. name .. ".aseprite", png = B.OUT .. name .. ".png", scale = 1 }
end
return B

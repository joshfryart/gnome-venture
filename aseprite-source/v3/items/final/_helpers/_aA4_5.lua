-- _aA4_5.lua: private helpers for ico-frog, ico-gem, ico-ghost, ico-gift (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = v[k] + a end end end
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- sphere + pillow blend
function A.body(m, cx, cy, r, R, wS, ry)
  local np = X.pillow(m, R or 5)
  local ns = {}
  ry = ry or r
  m:each(function(x, y)
    local nx, ny = (x - cx) / (r + 0.5), (y - cy) / (ry + 0.5)
    local q = 1 - nx*nx - ny*ny
    ns[K(x, y)] = { norm(nx, ny, sqrt(max(q, 0.02))) }
  end)
  local n = {}
  wS = wS or 0.6
  for k, a in pairs(np) do local b = ns[k]
    n[k] = { norm(a[1] * (1 - wS) + b[1] * wS, a[2] * (1 - wS) + b[2] * wS, a[3] * (1 - wS) + b[3] * wS) } end
  return n
end

-- re-tone one pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- darken pixels of m (by d steps) that 4-touch mask other (ambient row where parts meet)
function A.sep(c, m, idx, ramp, other, d, tok, rings)
  local cur = other:copy()
  for r = 1, rings or 1 do
    local g = cur:grow(1)
    local ring = g:copy():cut(cur)
    ring:each(function(x, y) if m:has(x, y) and not other:has(x, y) then A.step(c, idx, ramp, x, y, d or -1, tok) end end)
    cur = g
  end
end

-- flat facet: constant normal + linear gradient (gx,gy per px) -> idx
function A.facet(c, m, nrm, ramp, o)
  o = o or {}
  local nx, ny, nz = norm(nrm[1], nrm[2], nrm[3])
  local L = X.L
  local base = max(0, nx*L[1] + ny*L[2] + nz*L[3])
  base = (o.amb or 0.08) + (1 - (o.amb or 0.08)) * base + (o.lift or 0)
  local x0, y0 = m:bbox()
  local v = {}
  m:each(function(x, y)
    v[K(x, y)] = base + (o.gx or 0) * (x - x0) + (o.gy or 0) * (y - y0)
  end)
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
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

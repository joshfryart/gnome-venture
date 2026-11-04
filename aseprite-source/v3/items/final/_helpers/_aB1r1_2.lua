-- _aB1r1_2.lua: private helpers for ph/cellar-key, ph/centipede-plate, ph/chaconia-seed, ph/chai-blend (final, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min = math.sqrt, math.floor, math.max, math.min
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or A.tok(o.name or "part") })
  return idx, v
end

-- mix two normal fields (weights)
function A.mixN(a, b, wb)
  local n = {}
  for k, p in pairs(a) do
    local q = b[k] or p
    n[k] = { norm(p[1] * (1 - wb) + q[1] * wb, p[2] * (1 - wb) + q[2] * wb, p[3] * (1 - wb) + q[3] * wb) }
  end
  return n
end

-- vertical cylinder normals between x0..x1 (blended with optional pillow for rounded ends)
function A.vcylN(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x + 0.5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end

-- step a painted pixel's tone by d within ramp using idx table
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  if idx[k] then c:put(x, y, ramp[max(1, min(#ramp, idx[k] + d))], tok) end
end

-- 1px polyline (Bresenham) in a colour
function A.pline(c, pts, hex, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
      c:put(x0, y0, hex, tok)
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * err
      if e2 >= dy then err = err + dy x0 = x0 + sx end
      if e2 <= dx then err = err + dx y0 = y0 + sy end
    end
  end
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

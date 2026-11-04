-- _aC11_3.lua: private helpers for ph/hazelnut-seed, hazelnut-spread, healing-potion, heartwood (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ph/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- light + tone a normal field
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.06, wrap = o.wrap or 0.22 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end

-- vertical cylinder normals across x0..x1 (jars, sacks); optional dome on top rows
function A.vcylN(m, x0, x1)
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x + .5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  return n
end

-- blend two normal fields (w = weight of b)
function A.blend(a, b, w)
  local n = {}
  for k, p in pairs(a) do
    local q = b[k] or p
    n[k] = { norm(p[1] * (1 - w) + q[1] * w, p[2] * (1 - w) + q[2] * w, p[3] * (1 - w) + q[3] * w) }
  end
  return n
end

-- paint char map; (x0,y0) top-left; map char -> hex
function A.map(c, rows, x0, y0, cmap, tok)
  for j, row in ipairs(rows) do for i = 1, #row do
    local ch = row:sub(i, i)
    if cmap[ch] then c:put(x0 + i - 1, y0 + j - 1, cmap[ch], tok) end
  end end
end

-- put only where mask has the pixel
function A.putIn(c, m, x, y, hex, tok) if m:has(x, y) then c:put(x, y, hex, tok) end end

-- darken one step in a ramp (finds the colour index)
function A.step(ramp, hex, d)
  for i, h in ipairs(ramp) do if h == hex then return ramp[max(1, min(#ramp, i + d))] end end
  return hex
end

function A.save(c, name, noRecentre)
  if not noRecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

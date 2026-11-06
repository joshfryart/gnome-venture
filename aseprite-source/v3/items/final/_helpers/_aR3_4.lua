-- _aR3_4.lua: private helpers for ph/bark-path, ph/barley, ph/barley-seed, ph/basil (round 3, artist 4).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). Shared files unchanged.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G0 = dofile(DIR .. "/../../batch2/_b2g1.lua")
local G = setmetatable({}, { __index = G0 })
local HP, X, K = G0.HP, G0.X, G0.K
G.HP, G.X, G.K = HP, X, K
local floor, sqrt, max, min, abs, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin
G.OUT = app.params.out or (DIR .. "/../ph/")

function G.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- 1px line (Bresenham) as a mask
function G.lineMask(x0, y0, x1, y1)
  local m = HP.mask()
  x0, y0, x1, y1 = floor(x0 + .5), floor(y0 + .5), floor(x1 + .5), floor(y1 + .5)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    m:set(x0, y0)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
  return m
end
-- 1px polyline along a cubic bezier, returns ordered list of unique pixels
function G.bezPix(p, n)
  n = n or 80
  local out, seen = {}, {}
  for i = 0, n do
    local x, y = G0.bez(p, i / n)
    local xi, yi = floor(x + .5), floor(y + .5)
    local k = K(xi, yi)
    if not seen[k] then seen[k] = true out[#out + 1] = { xi, yi, i / n } end
  end
  return out
end

-- jittered Voronoi cells (bark chips). returns cell id map, edge flag map, cell list
function G.voronoi(m, step, seed)
  local cells = {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  m:each(function(x, y) x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end)
  local id = 0
  for gy = y0 - step, y1 + step, step do for gx = x0 - step, x1 + step, step do
    id = id + 1
    cells[id] = { x = gx + X.hash(gx, gy, seed) * step, y = gy + X.hash(gy, gx, seed + 7) * step * 0.8,
      tone = X.hash(gx, gy, seed + 13), tilt = X.hash(gx, gy, seed + 21) }
  end end
  local C, E = {}, {}
  m:each(function(x, y)
    local b1, b2, bi = 1e9, 1e9, 0
    for i, cc in ipairs(cells) do
      local dx, dy = (x - cc.x), (y - cc.y) * 1.5
      local q = dx * dx + dy * dy
      if q < b1 then b2 = b1 b1, bi = q, i elseif q < b2 then b2 = q end
    end
    local k = K(x, y)
    C[k] = bi
    E[k] = (sqrt(b2) - sqrt(b1)) < 0.9
  end)
  return C, E, cells
end

-- paint a list of pixels/mask with a fixed hex under a token
function G.fill(c, m, hex, tok) m:each(function(x, y) c:put(x, y, hex, tok) end) end
function G.tok(name) return { r = { name = name } } end

function G.done(c, name)
  G0.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = G.OUT .. name .. ".aseprite", png = G.OUT .. name .. ".png", scale = 1 }
end
return G

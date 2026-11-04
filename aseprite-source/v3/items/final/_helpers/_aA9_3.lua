-- _aA9_3.lua: private helpers for ico-shears, ico-shell, ico-shield, ico-shop (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- per-pixel light -> ramp (dark..light). returns idx table
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = o.bias, tok = o.tok })
  return idx
end

-- ellipse mask with centre on any subpixel
function A.ellM(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

-- shift tone of an already painted pixel by d steps
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- straight 1px line (Bresenham)
function A.line(c, x0, y0, x1, y1, hex, tok, clip)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    if not clip or clip:has(x0, y0) then c:put(x0, y0, hex, tok) end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end

-- add a broad dome curvature to a normal field (so flat interiors still turn from the light)
function A.bulge(n, cx, cy, rx, ry, amt)
  for k, v in pairs(n) do
    local x, y = k % 1024 - 256, k // 1024 - 256
    local nx, ny, nz = v[1] + amt * (x - cx) / rx, v[2] + amt * (y - cy) / ry, v[3]
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    n[k] = { nx / l, ny / l, nz / l }
  end
  return n
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

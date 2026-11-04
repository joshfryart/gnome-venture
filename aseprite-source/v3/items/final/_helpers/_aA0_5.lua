-- _aA0_5.lua: private helpers for ico-axe, ico-badger, ico-ballot, ico-banana (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
A.CUTS5 = { 0.22, 0.42, 0.62, 0.82 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + tone a normal field; returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts or (#ramp == 5 and A.CUTS5 or A.CUTS6)
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
  return idx, v
end

-- flat-ish slab: pillow normals with bevel R, optional tilt of the flat face {tx,ty}
function A.slab(m, R, tilt)
  local n = X.pillow(m, R)
  if tilt then
    for k, v in pairs(n) do n[k] = { norm(v[1] + tilt[1], v[2] + tilt[2], v[3]) } end
  end
  return n
end

-- re-tone one pixel by delta steps using idx
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- pixels of m that 4-touch mask o (contact / separation row)
function A.touch(m, o)
  local r = HP.mask()
  m:each(function(x, y)
    if o:has(x + 1, y) or o:has(x - 1, y) or o:has(x, y + 1) or o:has(x, y - 1) then r:set(x, y) end
  end)
  return r
end

-- Bresenham polyline of single pixels
function A.pline(c, pts, hex, tok)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local dx, dy = abs(x1 - x0), -abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local e = dx + dy
    while true do
      c:put(x0, y0, hex, tok)
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * e
      if e2 >= dy then e = e + dy x0 = x0 + sx end
      if e2 <= dx then e = e + dx y0 = y0 + sy end
    end
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

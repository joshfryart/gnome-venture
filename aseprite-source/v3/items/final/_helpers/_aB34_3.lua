-- _aB34_3.lua: private helpers for ph/glazed-garden-pot, ph/gloriosa-lily-seed, ph/glory-bower-seed, ph/glow-silk
-- (final pass, Opus). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local B = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
B.HP, B.X, B.K = HP, X, K
B.INK, B.CREAM = "#2b1c26", "#fff4d6"
B.CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
function B.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
function B.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light a normal field and paint it with a ramp (dark..light)
function B.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or (#ramp == 4 and { 0.3, 0.55, 0.8 } or B.CUTS), bias = o.bias, tok = o.tok })
  return idx, v
end

-- move one painted pixel d steps along its ramp
function B.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- ragged torn edge: drop pixels of m beyond the line (x0,y0) normal (nx,ny), jittered by amp
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

-- polyline of single pixels (Bresenham)
function B.ln(c, x0, y0, x1, y1, hex, tok, only)
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    if not only or only:has(x0, y0) then c:put(x0, y0, hex, tok) end
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy x0 = x0 + sx end
    if e2 <= dx then err = err + dx y0 = y0 + sy end
  end
end

function B.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

function B.save(c, name) G.recentre(c) G.save(c, name) end
return B

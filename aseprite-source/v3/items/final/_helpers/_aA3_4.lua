-- _aA3_4.lua: private helpers for ico-dice, ico-dna, ico-door, ico-dove (final pass, Opus). Copy of _aA3_0.lua helpers.
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.atan
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- light value per pixel from normals, plus optional additive tweaks
function A.val(n, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  if o.tilt then -- global upper-left -> lower-right falloff: tilt = {cx, cy, R, amount}
    local t = o.tilt
    for k, a in pairs(v) do
      local x, y = k % 1024 - 256, k // 1024 - 256
      v[k] = max(0, min(1, a + t[4] * (-(x - t[1]) - (y - t[2])) / (1.414 * t[3])))
    end
  end
  return v
end
-- per-pixel light snapped to a ramp (dark..light); returns idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = A.val(n, o)
  if o.vout then o.vout(v) end
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias, tok = o.tok })
end

-- normals from a height function h(x,y) (pixel units) over mask m
function A.hnorm(m, h, s)
  s = s or 1
  local n = {}
  m:each(function(x, y)
    local gx = (h(x + 1, y) - h(x - 1, y)) / 2 * s
    local gy = (h(x, y + 1) - h(x, y - 1)) / 2 * s
    n[K(x, y)] = { G.norm(-gx, -gy, 1) }
  end)
  return n
end

function A.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end
-- annulus between r0 and r1 (pixel-centre distance)
function A.ring(cx, cy, r0, r1)
  local m = HP.mask()
  for y = floor(cy - r1) - 1, floor(cy + r1) + 1 do for x = floor(cx - r1) - 1, floor(cx + r1) + 1 do
    local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    if d >= r0 and d <= r1 + 0.45 then m:set(x, y) end
  end end
  return m
end
function A.polar(x, y, cx, cy) local dx, dy = x - cx, y - cy return sqrt(dx * dx + dy * dy), atan(dy, dx) end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end
function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end
-- pixels of m that touch (4-conn) mask o
function A.touch(m, o)
  local r = HP.mask()
  m:each(function(x, y)
    if o:has(x + 1, y) or o:has(x - 1, y) or o:has(x, y + 1) or o:has(x, y - 1) then r:set(x, y) end
  end)
  return r
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

-- _aA3_3.lua: private helpers for ico-curry, ico-daisy, ico-deer, ico-desert (final pass, Opus).
-- Private copy of _aA3_2.lua (unchanged API). Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
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

-- straight tapered segment A->B (half widths w0 -> w1) as a tube; returns m, n, T, S
function A.seg(ax, ay, bx, by, w0, w1)
  local p = { { ax, ay }, { ax + (bx - ax) / 3, ay + (by - ay) / 3 }, { ax + 2 * (bx - ax) / 3, ay + 2 * (by - ay) / 3 }, { bx, by } }
  return G.tube(p, function(t) return w0 + (w1 - w0) * t end, 60)
end
-- merge normal tables (later wins)
function A.merge(dst, src) for k, v in pairs(src) do dst[k] = v end return dst end
-- mask from list of masks
function A.union(list) local m = HP.mask() for _, q in ipairs(list) do m:add(q) end return m end

-- capsule mask: pixels within w of segment A->B; also returns t (0..1 along) and s (signed across, + = lower-right)
function A.capsule(ax, ay, bx, by, w)
  local m, T, S = HP.mask(), {}, {}
  local vx, vy = bx - ax, by - ay
  local L2 = vx * vx + vy * vy
  local L = sqrt(L2)
  local px, py = -vy / L, vx / L
  if px + py < 0 then px, py = -px, -py end
  for y = floor(min(ay, by) - w) - 1, floor(max(ay, by) + w) + 1 do for x = floor(min(ax, bx) - w) - 1, floor(max(ax, bx) + w) + 1 do
    local t = ((x - ax) * vx + (y - ay) * vy) / L2
    local tc = max(0, min(1, t))
    local qx, qy = ax + vx * tc, ay + vy * tc
    if (x - qx) ^ 2 + (y - qy) ^ 2 <= (w + 0.2) ^ 2 then
      m:set(x, y) T[K(x, y)] = t S[K(x, y)] = (x - ax) * px + (y - ay) * py
    end
  end end
  return m, T, S, L
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
-- ellipsoid normals over mask m (centre cx,cy radii rx,ry); fz < 1 flattens the bulge
function A.ellN(m, cx, cy, rx, ry, fz)
  local n = {}
  m:each(function(x, y)
    local u, v = (x - cx) / (rx + 0.5), (y - cy) / (ry + 0.5)
    local q = 1 - u * u - v * v
    n[K(x, y)] = { G.norm(u, v, sqrt(max(q, 0.03)) / (fz or 1)) }
  end)
  return n
end
-- pixels of m whose 4-neighbour lies in o: step them d tones (separation / AO line)
function A.sepline(c, idx, ramp, m, o, d, tok)
  A.touch(m, o):each(function(x, y) A.step(c, idx, ramp, x, y, d or -1, tok) end)
end
return A

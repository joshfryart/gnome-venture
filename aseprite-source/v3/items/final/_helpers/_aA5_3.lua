-- _aA5_3.lua: private helpers for ico-handbag, ico-heart-green, ico-heart-red, ico-heart-yellow (final pass, Opus). Copy of _aA5_2.lua + heart mask.
-- Copy of _aA5_0.lua plus capsule / rotated-frame helpers; read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
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
-- pillow-shade a mask: rounded bevel R, returns idx, n
function A.pill(c, m, R, ramp, o)
  o = o or {}
  local n = X.pillow(m, R, o.hs)
  local idx = A.shade(c, m, n, ramp, o)
  return idx, n
end
-- 1px line (Bresenham) as mask
function A.seg(x0, y0, x1, y1)
  local m = HP.mask()
  local dx, dy = abs(x1 - x0), -abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local e = dx + dy
  while true do
    m:set(x0, y0)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * e
    if e2 >= dy then e = e + dy x0 = x0 + sx end
    if e2 <= dx then e = e + dx y0 = y0 + sy end
  end
  return m
end
-- darken (d<0) or lighten idx-tracked pixels of mask m by d steps
function A.stepM(c, idx, ramp, m, d, tok) m:each(function(x, y) A.step(c, idx, ramp, x, y, d, tok) end) end
-- capsule (segment with round caps) of radius r, pixel-centre test
function A.caps(ax, ay, bx, by, r)
  local m = HP.mask()
  local vx, vy = bx - ax, by - ay
  local L2 = vx * vx + vy * vy
  for y = floor(min(ay, by) - r) - 1, floor(max(ay, by) + r) + 1 do
    for x = floor(min(ax, bx) - r) - 1, floor(max(ax, bx) + r) + 1 do
      local t = L2 > 0 and max(0, min(1, ((x - ax) * vx + (y - ay) * vy) / L2)) or 0
      local dx, dy = x - (ax + vx * t), y - (ay + vy * t)
      if dx * dx + dy * dy <= (r + 0.3) ^ 2 then m:set(x, y) end
    end
  end
  return m
end
-- local frame: origin (ox,oy), unit axis (ux,uy); returns function(x,y)->u,v  (v = across, +v to the right of axis)
function A.frame(ox, oy, ux, uy)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  return function(x, y) local dx, dy = x - ox, y - oy return dx * ux + dy * uy, -dx * uy + dy * ux end, ux, uy
end
-- mask from predicate over a box
function A.pred(x0, y0, x1, y1, f)
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end
  return m
end
function A.unpaint(c, x, y) c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end
-- heart mask: centre (cx,cy) ~ middle of the shape, s = scale (width ~2.28s), ky stretches height, tilt radians
function A.heart(cx, cy, s, ky, tilt)
  ky = ky or 1 tilt = tilt or 0
  local ca, sa = math.cos(tilt), math.sin(tilt)
  local m = HP.mask()
  for y = floor(cy - 2 * s * ky) , floor(cy + 2 * s * ky) do for x = floor(cx - 2 * s), floor(cx + 2 * s) do
    local dx, dy = x - cx, y - cy
    local rx, ry = dx * ca + dy * sa, -dx * sa + dy * ca
    local u, v = rx / s, -(ry / ky) / s + 0.1
    local q = u * u + v * v - 1
    if q * q * q - u * u * v * v * v <= 0 then m:set(x, y) end
  end end
  return m
end
-- smooth dome normals: height from the distance field (rounded over R px), box-blurred `blur` times
function A.dome(m, R, hs, blur)
  local d = X.dist(m)
  local H = {}
  m:each(function(x, y) local t = min(d[K(x, y)] + 0.5, R) / R H[K(x, y)] = R * sqrt(1 - (1 - t) ^ 2) * (hs or 1) end)
  for _ = 1, blur or 0 do
    local H2 = {}
    m:each(function(x, y)
      local s, n = 0, 0
      for dy = -1, 1 do for dx = -1, 1 do local v = H[K(x + dx, y + dy)] s = s + (v or 0) n = n + 1 end end
      H2[K(x, y)] = s / n
    end)
    H = H2
  end
  local function h(x, y) return H[K(x, y)] or -0.5 end
  local n = {}
  m:each(function(x, y)
    local gx = (h(x + 1, y) - h(x - 1, y)) / 2
    local gy = (h(x, y + 1) - h(x, y - 1)) / 2
    n[K(x, y)] = { G.norm(-gx, -gy, 1) }
  end)
  return n, d
end
return A

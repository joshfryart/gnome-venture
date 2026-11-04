-- _aA4_3.lua: private helpers for ico-flatbread, ico-floppy, ico-fly, ico-fog (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, atan, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.atan, math.cos, math.sin
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

function A.val(n, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  if o.tilt then -- global upper-left -> lower-right falloff: {cx, cy, R, amount}
    local t = o.tilt
    for k, a in pairs(v) do
      local x, y = k % 1024 - 256, k // 1024 - 256
      v[k] = max(0, min(1, a + t[4] * (-(x - t[1]) - (y - t[2])) / (1.414 * t[3])))
    end
  end
  return v
end
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = A.val(n, o)
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.22, 0.4, 0.56, 0.72, 0.87 }, bias = o.bias, tok = o.tok })
end
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
-- rotated ellipse mask (angle radians)
function A.rot(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang or 0), sin(ang or 0)
  local m = HP.mask()
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) / (rx + 0.45), (-dx * sa + dy * ca) / (ry + 0.45)
    if u * u + v * v <= 1 then m:set(x, y) end
  end end
  return m
end
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
function A.touch(m, o)
  local r = HP.mask()
  m:each(function(x, y)
    if o:has(x + 1, y) or o:has(x - 1, y) or o:has(x, y + 1) or o:has(x, y - 1) then r:set(x, y) end
  end)
  return r
end
-- tube along a polyline (Catmull-Rom smoothed). wfn(t) half width. returns mask, normals, T, S, samples
function A.ptube(pts, wfn, per)
  per = per or 12
  local sm = {}
  local n = #pts
  local function P(i) return pts[max(1, min(n, i))] end
  for i = 1, n - 1 do
    local p0, p1, p2, p3 = P(i - 1), P(i), P(i + 1), P(i + 2)
    for j = 0, per - 1 do
      local t = j / per
      local t2, t3 = t * t, t * t * t
      local function cr(a, b, c2, d) return 0.5 * (2 * b + (-a + c2) * t + (2 * a - 5 * b + 4 * c2 - d) * t2 + (-a + 3 * b - 3 * c2 + d) * t3) end
      sm[#sm + 1] = { x = cr(p0[1], p1[1], p2[1], p3[1]), y = cr(p0[2], p1[2], p2[2], p3[2]) }
    end
  end
  sm[#sm + 1] = { x = pts[n][1], y = pts[n][2] }
  local N = #sm
  for i, s in ipairs(sm) do
    local a, b = sm[max(1, i - 1)], sm[min(N, i + 1)]
    local tx, ty = b.x - a.x, b.y - a.y
    local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    s.t, s.px, s.py, s.tx, s.ty = (i - 1) / (N - 1), px, py, tx, ty
    s.w = wfn(s.t)
  end
  local m, nn, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 9, floor(by1) + 9 do for x = floor(bx0) - 9, floor(bx1) + 9 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x - s.x) ^ 2 + (y - s.y) ^ 2
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      nn[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn * sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, nn, T, S, sm
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

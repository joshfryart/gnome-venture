-- _aA9_5.lua: private helpers for ico-snail, ico-snake, ico-snowflake, ico-soup-bowl (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs = math.sqrt, math.floor, math.max, math.min, math.abs
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.CREAM, A.INK = "#fff4d6", "#2b1c26"

function A.norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts or (#ramp == 6 and { 0.2, 0.38, 0.55, 0.71, 0.86 } or { 0.24, 0.45, 0.65, 0.83 })
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok }), v
end

function A.pil(c, m, R, ramp, o)
  o = o or {}
  local n = X.pillow(m, R, o.hs)
  local idx = A.shade(c, m, n, ramp, o)
  return idx, n
end

function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y)
  local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d))
  idx[k] = i
  c:put(x, y, ramp[i], tok)
end

function A.ellM(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local dx, dy = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
    if dx * dx + dy * dy <= 1 then m:set(x, y) end
  end end
  return m
end

function A.fn(x0, y0, x1, y1, f)
  local m = HP.mask()
  for y = y0, y1 do for x = x0, x1 do if f(x, y) then m:set(x, y) end end end
  return m
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- Catmull-Rom path through pts, returns sample list {x,y,t,px,py,w}
function A.crSamples(pts, wfn, N)
  N = N or 240
  local P = { pts[1] }
  for i = 1, #pts do P[#P + 1] = pts[i] end
  P[#P + 1] = pts[#pts]
  local segs = #pts - 1
  local raw = {}
  for i = 0, N do
    local u = i / N * segs
    local s = min(segs - 1, floor(u))
    local f = u - s
    local p0, p1, p2, p3 = P[s + 1], P[s + 2], P[s + 3], P[s + 4]
    local function cr(a, b, cc, d) return 0.5 * ((2 * b) + (-a + cc) * f + (2 * a - 5 * b + 4 * cc - d) * f * f + (-a + 3 * b - 3 * cc + d) * f * f * f) end
    raw[#raw + 1] = { cr(p0[1], p1[1], p2[1], p3[1]), cr(p0[2], p1[2], p2[2], p3[2]) }
  end
  local sm = {}
  for i, q in ipairs(raw) do
    local a, b = raw[max(1, i - 1)], raw[min(#raw, i + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]
    local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    local t = (i - 1) / N
    sm[#sm + 1] = { x = q[1], y = q[2], t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  return sm
end

-- tube along a sample list (nearest-sample), returns mask, normals, T, S (S<0 lit side), samples
function A.ctube(pts, wfn, N)
  local sm = A.crSamples(pts, wfn, N)
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 9, floor(by1) + 9 do for x = floor(bx0) - 9, floor(bx1) + 9 do
    local best, bs
    for _, s in ipairs(sm) do
      local q = (x - s.x)^2 + (y - s.y)^2
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w then
      local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
      local sn = max(-0.97, min(0.97, sd / (bs.w + 0.5)))
      m:set(x, y)
      local k = K(x, y)
      n[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn*sn) }
      T[k], S[k] = bs.t, sn
    end
  end end
  return m, n, T, S, sm
end

-- distance from point to segment, plus signed perpendicular offset and t
function A.seg(px, py, ax, ay, bx, by)
  local vx, vy = bx - ax, by - ay
  local l2 = vx * vx + vy * vy
  local t = max(0, min(1, ((px - ax) * vx + (py - ay) * vy) / l2))
  local qx, qy = ax + vx * t, ay + vy * t
  local l = sqrt(l2)
  local s = ((px - ax) * -vy + (py - ay) * vx) / l
  return sqrt((px - qx)^2 + (py - qy)^2), s, t
end

function A.save(c, name, norecentre)
  if not norecentre then G.recentre(c) end
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end
return A

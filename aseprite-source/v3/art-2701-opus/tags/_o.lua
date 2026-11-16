-- _o.lua: private helpers for the Opus tag-icon pass (art-2701-opus/tags). Loads lib/hp.lua + lib/hpx.lua read-only.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
local O = { HP = HP, X = X, K = K, INK = "#2b1c26", CREAM = "#fff4d6" }
O.OUT = app.params.out or (DIR .. "/")
O.CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
O.norm = norm

function O.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function O.tok(name) return { r = { name = name } } end

-- light a normal field and paint a dark->light ramp; returns idx (ramp index per key)
function O.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local nR = #ramp
  local cuts = o.cuts or (nR == 6 and O.CUTS) or (nR == 5 and { 0.24, 0.44, 0.64, 0.84 }) or { 0.3, 0.55, 0.8 }
  return X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok or O.tok(tostring(m)) }), v
end
function O.pill(c, m, R, ramp, o)
  o = o or {}
  local n = X.pillow(m, R, o.hs)
  if o.tilt then n = O.tilt(n, o.tilt[1], o.tilt[2], o.tilt[3], o.tilt[4]) end
  local idx = O.shade(c, m, n, ramp, o)
  return idx, n
end
function O.tilt(n, tx, ty, tz, w)
  tx, ty, tz = norm(tx, ty, tz)
  local r = {}
  for k, a in pairs(n) do r[k] = { norm(a[1] * (1 - w) + tx * w, a[2] * (1 - w) + ty * w, a[3] * (1 - w) + tz * w) } end
  return r
end
function O.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end
function O.set(c, idx, ramp, x, y, i, tok)
  local k = K(x, y) if not idx[k] then return end
  idx[k] = i c:put(x, y, ramp[i], tok)
end
function O.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier; half width wfn(t) (<=0 = gap). returns mask, normals, T, S (S<0 = lit upper-left side)
function O.tube(p, wfn, steps)
  local N = steps or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = O.bez(p, t)
    local x2, y2 = O.bez(p, min(1, t + 0.002))
    local x1, y1 = O.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 10, floor(by1) + 10 do for x = floor(bx0) - 10, floor(bx1) + 10 do
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
  return m, n, T, S
end
-- rotated ellipsoid mask + normals
function O.oval(cx, cy, rx, ry, ang, flat)
  ang = ang or 0
  local ca, sa = cos(ang), sin(ang)
  local m, n = HP.mask(), {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x + 0.0 - cx, y + 0.0 - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local wx, wy = u * ca - v * sa, u * sa + v * ca
      n[K(x, y)] = { norm(wx, wy, sqrt(max(1 - q, 0.02)) * (flat or 1)) }
    end
  end end
  return m, n
end
-- local-frame mask: origin, angle; f(u,v) true inside. returns m, U, V
function O.lmask(ox, oy, a, R, f)
  local ux, uy = cos(a), sin(a)
  local vx, vy = -uy, ux
  local m, U, V = HP.mask(), {}, {}
  for y = floor(oy - R), floor(oy + R) do for x = floor(ox - R), floor(ox + R) do
    local dx, dy = x - ox, y - oy
    local u, v = dx * ux + dy * uy, dx * vx + dy * vy
    if f(u, v) then m:set(x, y) U[K(x, y)], V[K(x, y)] = u, v end
  end end
  return m, U, V
end
function O.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end
-- bias pixels of target covered by caster shifted (dx,dy)
function O.cast(bias, target, caster, dx, dy, amt)
  caster:shift(dx, dy):each(function(x, y)
    if target:has(x, y) and not caster:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end
  end)
  return bias
end
function O.hash(x, y, s) return X.hash(x, y, s) end
-- erase pixels (make transparent again)
function O.erase(c, m) m:each(function(x, y) if x >= 0 and y >= 0 and x < c.w and y < c.h then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end end) end
function O.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined %dx%d)", dx, dy, W, Hh))
end
-- post-outline pass: f(c) may add pixels drawn ON TOP of the ink (e.g. sparkles), still hard pixels
function O.save(c, name, o)
  o = o or {}
  if o.recentre ~= false then O.recentre(c) end
  c:finish{ outline = true }
  if o.after then o.after(c) end
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = O.OUT .. name .. ".aseprite", png = O.OUT .. name .. ".png", scale = 1 }
end
return O

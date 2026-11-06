-- _aB32_4.lua: private helpers for fox-fang, fox-pelt, foxglove-seed, foxtail-lily-seed (B32, Opus). Copied from _aB31_0.lua.
-- Based on _aB30_5.lua (copied). Read-only use of v3/lib/hp.lua + hpx.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local G = { HP = HP, X = X, K = K, P = HP.P }
local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
G.norm = norm
G.CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }

function G.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light normals n over mask m, quantise into ramp (dark..light). returns idx, v
function G.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or G.CUTS, bias = o.bias, tok = o.tok })
  return idx, v
end
function G.pillow(c, m, ramp, R, o)
  local n = X.pillow(m, R or 2)
  local idx, v = G.shade(c, m, n, ramp, o)
  return idx, n, v
end
-- rotated ellipsoid mask + normals
function G.oval(cx, cy, rx, ry, ang, flat)
  local ca, sa = cos(ang or 0), sin(ang or 0)
  local m, n = HP.mask(), {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local a, b = u, v
      local wx, wy = a * ca - b * sa, a * sa + b * ca
      n[K(x, y)] = { norm(wx, wy, sqrt(max(1 - q, 0.03)) * (flat or 1)) }
    end
  end end
  return m, n
end
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- swept disc along a cubic bezier, radius wfn(t). returns mask, T
function G.sweep(p, wfn, steps)
  steps = steps or 80
  local m, T = HP.mask(), {}
  for i = 0, steps do
    local t = i / steps
    local x, y = G.bez(p, t)
    local r = wfn(t)
    local R = math.ceil(r) + 1
    for dy = -R, R do for dx = -R, R do
      local px, py = floor(x + dx + .5), floor(y + dy + .5)
      if (px - x)^2 + (py - y)^2 <= r * r + 0.2 then
        if not m:has(px, py) then T[K(px, py)] = t end
        m:set(px, py)
      end
    end end
  end
  return m, T
end
-- vertical-axis cylinder normals (x0..x1 span)
function G.vcylN(m, x0, x1, ny)
  local n = {}
  m:each(function(x, y)
    local t = max(-.96, min(.96, ((x + .5 - x0) / (x1 + 1 - x0)) * 2 - 1))
    n[K(x, y)] = { norm(t, ny or 0, sqrt(1 - t*t)) }
  end)
  return n
end
-- paint hex onto pixels of `under` that touch `over` (4-neighbour) but are not in it: ambient / contact line
function G.ao(c, under, over, hex, dx, dy)
  local ring = over:shift(dx or 0, dy or 0):grow(1)
  ring:each(function(x, y) if under:has(x, y) and not over:has(x, y) then c:put(x, y, hex, c.own[y * c.w + x]) end end)
end
-- recolour pixels of mask that are inside `clip` (or everywhere)
function G.fill(c, m, hex, clip)
  m:each(function(x, y) if not clip or clip:has(x, y) then c:put(x, y, hex) end end)
end
G.hash = X.hash
-- shift all drawn pixels so the final (outlined) bbox sits centred on the 64 canvas
function G.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined size %dx%d)", dx, dy, W, Hh))
end
function G.save(c, name)
  local out = app.params.out or "./"
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
function G.tube(p, wfn, steps)
  steps = steps or 120
  local P = {}
  for i = 0, steps do local x, y = G.bez(p, i / steps) P[i] = { x, y, wfn(i / steps) } end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i = 0, steps do x0, y0, x1, y1 = min(x0, P[i][1]), min(y0, P[i][2]), max(x1, P[i][1]), max(y1, P[i][2]) end
  for y = floor(y0) - 6, floor(y1) + 6 do for x = floor(x0) - 6, floor(x1) + 6 do
    local best, bi = 1e9, nil
    for i = 0, steps do local r = P[i][3]
      local q = sqrt((P[i][1] - x) ^ 2 + (P[i][2] - y) ^ 2) - r
      if q < best then best, bi = q, i end end
    if best <= 0.05 then
      local r = P[bi][3]
      local dx, dy = (x - P[bi][1]) / (r + .5), (y - P[bi][2]) / (r + .5)
      local q = dx*dx + dy*dy
      local k = K(x, y)
      m:set(x, y) n[k] = { norm(dx, dy, sqrt(max(1 - q, 0.05))) } T[k] = bi / steps
      S[k] = max(-1, min(1, dx * 0.7071 + dy * 0.7071))
    end
  end end
  return m, n, T, S
end
-- Bresenham polyline
function G.pline(c, pts, hex, tok)
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
-- pixels of m 4-touching o
function G.touch(m, o)
  local r = HP.mask()
  m:each(function(x, y) if o:has(x+1,y) or o:has(x-1,y) or o:has(x,y+1) or o:has(x,y-1) then r:set(x, y) end end)
  return r
end
-- brightest specular pixel in mask
function G.specAt(m, n, power)
  local sp = X.spec(n, power or 40)
  local best, bx, by
  m:each(function(x, y) local s = sp[K(x, y)] if s and (not best or s > best or (s == best and x + y < bx + by)) then best, bx, by = s, x, y end end)
  return bx, by
end
-- curved blade along a quadratic bezier A-C-B. wfn(t) half width (<0 = none). returns m, n, T, S, len
-- side bias sk: >0 tilts the blade so the +s half faces the viewer more (asymmetric fold)
function G.blade(ax, ay, cx, cy, bx, by, wfn, o)
  o = o or {}
  local N = 120
  local P, Tg = {}, {}
  local len = 0
  for i = 0, N do
    local t = i / N local u = 1 - t
    local x = u*u*ax + 2*u*t*cx + t*t*bx
    local y = u*u*ay + 2*u*t*cy + t*t*by
    local dx = 2*u*(cx - ax) + 2*t*(bx - cx)
    local dy = 2*u*(cy - ay) + 2*t*(by - cy)
    local l = sqrt(dx*dx + dy*dy)
    P[i] = { x, y } Tg[i] = { dx / l, dy / l }
    if i > 0 then len = len + sqrt((x - P[i-1][1])^2 + (y - P[i-1][2])^2) end
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local x0, x1 = floor(min(ax, bx, cx)) - 12, floor(max(ax, bx, cx)) + 12
  local y0, y1 = floor(min(ay, by, cy)) - 12, floor(max(ay, by, cy)) + 12
  for y = y0, y1 do for x = x0, x1 do
    local best, bi = 1e9, 0
    for i = 0, N do local q = (P[i][1] - x)^2 + (P[i][2] - y)^2 if q < best then best, bi = q, i end end
    local t = bi / N
    local w = wfn(t)
    if w >= 0 then
      local tx, ty = Tg[bi][1], Tg[bi][2]
      local px, py = -ty, tx
      if px + py < 0 then px, py = -px, -py end
      local rx, ry = x - P[bi][1], y - P[bi][2]
      local along = rx*tx + ry*ty
      local s = rx*px + ry*py
      local ok = abs(s) <= w + 0.15
      if (bi == 0 and along < -0.5) or (bi == N and along > 0.5) then ok = false end
      if ok then
        m:set(x, y)
        local sn = max(-0.95, min(0.95, s / (w + 0.6)))
        local k = K(x, y)
        local fold = o.fold or 0.55                      -- V fold across the midrib
        local nzv = 1
        local sx = (sn < 0 and -fold or fold) * 0.9 + sn * 0.35
        n[k] = { norm(px * sx, py * sx, nzv) }
        T[k], S[k] = t, sn
      end
    end
  end end
  return m, n, T, S, len
end
function G.rot(ux, uy, a) local c, s = cos(a), sin(a) return ux*c - uy*s, ux*s + uy*c end
-- bias pixels of target covered by caster shifted (dx,dy)
function G.cast(bias, target, caster, dx, dy, amt)
  caster:shift(dx, dy):each(function(x, y)
    if target:has(x, y) and not caster:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end
  end)
  return bias
end
return G

-- _aC10_1.lua: private helper copy for aC10_1 (green-bean-seed, green-pea-soup, green-tomato-relish, greenhouse-1).
-- Concatenated copy of batch1/_h.lua + batch1/_g1.lua + batch2/_b2g1.lua (originals unchanged).
-- batch1 shared helpers (first-draft items). Wraps hp.lua + hpx.lua lighting.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local LIB = DIR .. "/../../../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local P = dofile(LIB .. "palette.lua")
local K = X.K
local H = { HP = HP, X = X, P = P, K = K, out = app.params.out or "./" }
local floor, sqrt, sin, cos, pi, max, min = math.floor, math.sqrt, math.sin, math.cos, math.pi, math.max, math.min

local function rgb(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
function H.mix(a, b, t)
  local r1,g1,b1 = rgb(a) local r2,g2,b2 = rgb(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5))
end
function H.ramp(r)
  if type(r) == "string" then r = P[r] end
  if #r == 6 then return r end
  return { r.deep, r.shade, H.mix(r.shade, r.base, .5), r.base, H.mix(r.base, r.hi, .55), r.hi }
end
function H.new(name)
  H.name = name
  return HP, X, HP.canvas{ w = 64, h = 64, scale = 1, name = name }, P
end
local CUTS = { 0.26, 0.44, 0.6, 0.75, 0.88 }
-- pillow-lit part. o: R bevel, amb, wrap, bias, cuts, nospec
function H.lit(c, m, ramp, o)
  o = o or {}
  ramp = H.ramp(ramp)
  local n = X.pillow(m, o.R or 3, o.hs)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local idx = X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return idx, n, v
end
-- vertical-axis cylinder shade (jars, pails): normal varies with x only between x0..x1
function H.vcyl(c, m, ramp, x0, x1, o)
  o = o or {}
  ramp = H.ramp(ramp)
  local n = {}
  m:each(function(x, y)
    local t = max(-.97, min(.97, ((x - x0) / (x1 - x0)) * 2 - 1))
    n[K(x, y)] = { t, 0, sqrt(1 - t * t) }
  end)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.3 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return n
end
function H.disc(c, cx, cy, r, ramp, o)
  local m = c:ellipse(cx, cy, r, r)
  local n = X.sphere(cx - .4, cy - .4, r, m)
  local v = X.light(n, { amb = 0.06, wrap = 0.2 })
  X.tone(c, m, v, H.ramp(ramp), { cuts = (o and o.cuts) or CUTS })
  return m, n
end
function H.spec(c, x, y, hex, big)
  c:px(x, y, hex or P.cream)
  if big then c:px(x + 1, y, hex or P.cream) end
end
-- tapered cylinder A->B with lighting; wfn(t) half width
function H.cyl(c, ax, ay, bx, by, wfn, ramp, o)
  o = o or {}
  local m, n, T, S = X.cyl(ax, ay, bx, by, wfn)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, H.ramp(ramp), { cuts = o.cuts or CUTS, bias = o.bias })
  return m, T, S
end
function H.leaf(c, ax, ay, bx, by, w, ramp, veins)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 1.02 + 0.06)) ^ 0.7)
  end)
  local r = H.ramp(ramp)
  X.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), r, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  m:each(function(x, y)
    local s, t = S[K(x, y)], T[K(x, y)]
    if math.abs(s) < 0.2 and t > 0.06 and t < 0.86 then c:px(x, y, s <= 0 and r[6] or r[3]) end
    for _, vt in ipairs(veins or {}) do
      local d = t * len - (vt + math.abs(s) * 2.4)
      if d > -0.5 and d < 0.5 and math.abs(s) > 0.3 and math.abs(s) < 0.8 then c:px(x, y, s < 0 and r[5] or r[2]) end
    end
  end)
  return m
end
-- bezier (4 pts) swept disc mask; returns mask, T (t per pixel)
function H.sweep(pts, wfn, steps)
  steps = steps or 60
  local m, T = HP.mask(), {}
  for i = 0, steps do
    local t = i / steps
    local u = 1 - t
    local x = u^3*pts[1][1] + 3*u*u*t*pts[2][1] + 3*u*t*t*pts[3][1] + t^3*pts[4][1]
    local y = u^3*pts[1][2] + 3*u*u*t*pts[2][2] + 3*u*t*t*pts[3][2] + t^3*pts[4][2]
    local r = wfn(t)
    for dy = -math.ceil(r), math.ceil(r) do
      for dx = -math.ceil(r), math.ceil(r) do
        if dx*dx + dy*dy <= r*r + 0.25 then
          local px, py = floor(x + dx + .5), floor(y + dy + .5)
          if not m:has(px, py) then T[K(px, py)] = t end
          m:set(px, py)
        end
      end
    end
  end
  return m, T
end
function H.fin(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = H.out .. H.name .. ".aseprite", png = H.out .. H.name .. ".png", scale = 1 }
end
function H.each(m, f) m:each(f) end

local HP, X, K = H.HP, H.X, H.K
local G = setmetatable({}, { __index = H })
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
G.norm = norm

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

-- rotated ellipsoid mask + normals; ang radians
function G.oval(cx, cy, rx, ry, ang, flat)
  local ca, sa = math.cos(ang), math.sin(ang)
  local m, n = HP.mask(), {}
  local R = max(rx, ry) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u*u + v*v
    if q <= 1 then
      m:set(x, y)
      local rz = (rx + ry) / 2 * (flat or 1)
      local a, b = u / (rx + .45), v / (ry + .45)
      local wx, wy = a * ca - b * sa, a * sa + b * ca
      n[K(x, y)] = { norm(wx, wy, sqrt(max(1 - q, 0.02)) / rz) }
    end
  end end
  return m, n
end

-- bias pixels of target mask covered by caster shifted (dx,dy)
function G.cast(bias, target, caster, dx, dy, amt)
  caster:shift(dx, dy):each(function(x, y)
    if target:has(x, y) and not caster:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end
  end)
  return bias
end

function G.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = o.bias, tok = o.tok })
end

-- brightest spec pixel within mask
function G.specAt(m, n, power)
  local sp = X.spec(n, power or 40)
  local best, bx, by
  m:each(function(x, y) local s = sp[K(x, y)] if s and (not best or s > best or (s == best and x + y < bx + by)) then best, bx, by = s, x, y end end)
  return bx, by
end

function G.save(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = H.out .. name .. ".aseprite", png = H.out .. name .. ".png", scale = 1 }
end

local sqrt, floor, max, min, abs, cos, sin = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin
G.out = app.params.out or (DIR .. "/../ph/")
G.H = G
function G.new2(name) G.out = app.params.out or (DIR .. "/../ph/") local c = HP.canvas{ w = 64, h = 64, scale = 1, name = name } return c end
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along cubic bezier, half width wfn(t). returns mask, normals, T, S (S<0 lit side), samples
function G.tube(p, wfn, steps)
  local N = steps or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002))
    local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
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
function G.rell(cx, cy, ux, uy, ra, rb)
  local m = HP.mask()
  local R = math.ceil(max(ra, rb)) + 1
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local a = dx*ux + dy*uy
    local b = -dx*uy + dy*ux
    if (a/ra)^2 + (b/rb)^2 <= 1.0 then m:set(x, y) end
  end end
  return m
end
function G.rot(ux, uy, a) local c, s = cos(a), sin(a) return ux*c - uy*s, ux*s + uy*c end
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
function G.save2(c, name) G.recentre(c) G.save(c, name) end
return G

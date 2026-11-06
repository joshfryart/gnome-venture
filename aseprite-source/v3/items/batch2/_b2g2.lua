-- _b2g2.lua: private helpers for pumpkin + pumpkin-seed (batch2, Opus single pass). Read-only use of batch1/_g1.lua (-> _h.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../batch1/_g1.lua")
local HP, X, K = G.HP, G.X, G.K
local sqrt, floor, max, min, abs, cos, sin, atan, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.atan, math.pi
local norm = G.norm
function G.new2(name) G.out = app.params.out or (DIR .. "/") return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- round tube along a cubic bezier; half width wfn(t). returns m, n, T, S (S<0 = lit/upper-left side)
function G.tube(p, wfn, N)
  N = N or 120
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.003)) local x1, y1 = G.bez(p, max(0, t - 0.003))
    local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, tx = tx, ty = ty, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do x0, y0, x1, y1 = min(x0, s.x), min(y0, s.y), max(x1, s.x), max(y1, s.y) end
  for y = floor(y0) - 5, floor(y1) + 5 do for x = floor(x0) - 5, floor(x1) + 5 do
    local best, bs = 1e9
    for _, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 if q < best then best, bs = q, s end end
    local rx, ry = x - bs.x, y - bs.y
    local along = rx * bs.tx + ry * bs.ty
    local sd = rx * bs.px + ry * bs.py
    local endcap = (bs.t == 0 and along < -0.3) or (bs.t == 1 and along > 0.3)
    if not endcap and abs(sd) <= bs.w + 0.05 then
      m:set(x, y)
      local sn = max(-0.95, min(0.95, sd / (bs.w + 0.5)))
      n[K(x, y)] = { norm(bs.px * sn, bs.py * sn, sqrt(1 - sn * sn)) }
      T[K(x, y)], S[K(x, y)] = bs.t, sn
    end
  end end
  return m, n, T, S
end

-- palmate leaf (pumpkin/squash type). base (bx,by); lobes = { {angle, length}, ... } (angle radians, 0 = right, -pi/2 = up)
-- sharp = lobe pointiness, serr = margin teeth. returns m, n, info {A = angle per px, R = radius, nearest lobe}
function G.palm(bx, by, lobes, o)
  o = o or {}
  local sharp, floorR = o.sharp or 5, o.floor or 0.42
  local m, n, info = HP.mask(), {}, {}
  local Rmax = 0 for _, l in ipairs(lobes) do Rmax = max(Rmax, l[2]) end
  local function radius(a)
    local best, bi = 0, 1
    for i, l in ipairs(lobes) do
      local d = math.atan(sin(a - l[1]), cos(a - l[1]))
      local dd = abs(d) * (o.spread or 1.6) local c = dd < pi / 2 and cos(dd) or 0
      local r = l[2] * (floorR * min(1, c * 2.5) + (1 - floorR) * c ^ sharp)
      if r > best then best, bi = r, i end
    end
    return best, bi
  end
  for y = floor(by - Rmax) - 2, floor(by + Rmax) + 2 do for x = floor(bx - Rmax) - 2, floor(bx + Rmax) + 2 do
    local dx, dy = x - bx, y - by
    local r = sqrt(dx*dx + dy*dy)
    local a = atan(dy, dx)
    local R, li = radius(a)
    local teeth = o.serr and (0.6 * max(0, sin(r * 1.9 + a * 3))) or 0
    if r <= R - teeth and r > (o.hole or -1) then
      m:set(x, y)
      local la = lobes[li][1]
      local da = math.atan(sin(a - la), cos(a - la))
      local u = r / max(1, R)
      -- dome across each lobe (fold along its midrib), slight cup toward the base
      local fx = -sin(la) * da * 1.4
      local fy = cos(la) * da * 1.4
      local tx, ty = cos(la) * (u - 0.5) * 0.5, sin(la) * (u - 0.5) * 0.5
      n[K(x, y)] = { norm((o.fold or 1) * (da > 0 and 1 or -1) * -sin(la) * 0.35 + fx * 0.2 + tx, (o.fold or 1) * (da > 0 and 1 or -1) * cos(la) * 0.35 + fy * 0.2 + ty, 1) }
      info[K(x, y)] = { a = a, r = r, R = R, li = li, da = da }
    end
  end end
  return m, n, info
end

-- teardrop seed mask + normals: centre, half length L, half width W, angle (pointing to the narrow tip), flat 0..1
function G.drop(cx, cy, L, W, ang, flat)
  local ca, sa = cos(ang), sin(ang)
  local m, n, U = HP.mask(), {}, {}
  local R = max(L, W) + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (L + 0.4)            -- +1 = tip
    local v = (-dx * sa + dy * ca)
    if abs(u) <= 1 then
      local hw = (W + 0.4) * sqrt(max(0, 1 - u * u)) * (1 - 0.32 * max(0, u))
      if abs(v) <= hw then
        m:set(x, y)
        local q = (v / max(0.6, hw))
        local nu = u * 0.9
        local nx, ny = nu * ca - q * sa, nu * sa + q * ca
        n[K(x, y)] = { norm(nx * 0.9, ny * 0.9, (flat or 1) * 0.6 + 0.2) }
        U[K(x, y)] = { u = u, v = q }
      end
    end
  end end
  return m, n, U
end
-- translate every painted pixel (to centre the finished drawing before the outline pass)
function G.shift(c, dx, dy)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w, i // c.w pix[(y + dy) * c.w + x + dx] = v own[(y + dy) * c.w + x + dx] = c.own[i] end
  c.pix, c.own = pix, own
end
-- 1px connected polyline as a mask
function G.path(pts)
  local m = HP.mask()
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local nn = max(abs(b[1] - a[1]), abs(b[2] - a[2]), 1) * 2
    for s = 0, nn do m:set(floor(a[1] + (b[1] - a[1]) * s / nn + .5), floor(a[2] + (b[2] - a[2]) * s / nn + .5)) end
  end
  return m
end
return G

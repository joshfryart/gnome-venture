-- _bbg.lua: private helpers for blueberry + blueberry-seed (batch2, Opus single pass).
-- Read-only use of batch1/_h.lua; tube/rell/oval/blade copied from batch1/_g0.lua and _g1.lua.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/../batch1/_h.lua")
local HP, X, K = H.HP, H.X, H.K
local G = setmetatable({}, { __index = H })
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
G.norm = norm
G.out = app.params.out or (DIR .. "/")

function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along a cubic bezier: half width wfn(t). Returns mask, normals, T, S (S<0 = lit/upper-left side)
function G.tube(p, wfn, o)
  o = o or {}
  local N = o.steps or 160
  local sm = {}
  for i = 0, N do
    local t = i / N
    local x, y = G.bez(p, t)
    local x2, y2 = G.bez(p, min(1, t + 0.002))
    local x1, y1 = G.bez(p, max(0, t - 0.002))
    local tx, ty = x2 - x1, y2 - y1
    local l = sqrt(tx*tx + ty*ty)
    tx, ty = tx / l, ty / l
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    sm[#sm + 1] = { x = x, y = y, t = t, px = px, py = py, w = wfn(t) }
  end
  local m, n, T, S = HP.mask(), {}, {}, {}
  local bx0, by0, bx1, by1 = 1e9, 1e9, -1e9, -1e9
  for _, s in ipairs(sm) do bx0 = min(bx0, s.x) by0 = min(by0, s.y) bx1 = max(bx1, s.x) by1 = max(by1, s.y) end
  for y = floor(by0) - 6, floor(by1) + 6 do for x = floor(bx0) - 6, floor(bx1) + 6 do
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

-- curved blade along a quadratic bezier A-C-B (from _g1). wfn(t) half width (<0 = none). m, n, T, S, len
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
        local fold = o.fold or 0.55
        local sx = (sn < 0 and -fold or fold) * 0.9 + sn * 0.35
        n[k] = { norm(px * sx, py * sx, 1) }
        T[k], S[k] = t, sn
      end
    end
  end end
  return m, n, T, S, len
end

-- rotated ellipsoid mask + normals (from _g1); ang radians
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

function G.cast(bias, target, caster, dx, dy, amt)
  caster:shift(dx, dy):each(function(x, y)
    if target:has(x, y) and not caster:has(x, y) then local k = K(x, y) bias[k] = (bias[k] or 0) + (amt or -1) end
  end)
  return bias
end
function G.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.26, 0.44, 0.6, 0.75, 0.88 }, bias = o.bias, tok = o.tok }), v
end
function G.specAt(m, n, power)
  local sp = X.spec(n, power or 40)
  local best, bx, by
  m:each(function(x, y) local s = sp[K(x, y)] if s and (not best or s > best or (s == best and x + y < bx + by)) then best, bx, by = s, x, y end end)
  return bx, by
end

-- move every painted pixel so the bbox sits centred (call after finish so the outline is included)
function G.centre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1, -1
  for i, _ in pairs(c.pix) do
    local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y)
  end
  local dx = floor((c.w - 1 - x1 + x0) / 2) - x0
  local dy = floor((c.h - 1 - y1 + y0) / 2) - y0
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w, i // c.w pix[(y + dy) * c.w + x + dx] = v own[(y + dy) * c.w + x + dx] = c.own[i] end
  c.pix, c.own = pix, own
end
function G.save(c, name)
  c:finish{ outline = true }
  G.centre(c)
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = G.out .. name .. ".aseprite", png = G.out .. name .. ".png", scale = 1 }
end
return G

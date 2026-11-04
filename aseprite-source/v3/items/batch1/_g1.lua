-- _g1.lua: private helpers for the seed trio (chili-pepper-seed, ginseng-seed, banana-seed). Wraps _h.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/_h.lua")
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
return G

-- _mint.lua: private helpers for mint + mint-seed (batch2). Copy of batch1/_g1.lua (blade, oval, cast, toneN, specAt)
-- plus a serrated, rugose mint-leaf painter. Wraps batch1/_h.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/../batch1/_h.lua")
local HP, X, K = H.HP, H.X, H.K
local G = setmetatable({}, { __index = H })
G.HP, G.X, G.K = HP, X, K
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

-- move the whole drawing by (dx,dy) before save (centring)
function G.shift(c, dx, dy)
  local pix, own = {}, {}
  for y = 0, c.h - 1 do for x = 0, c.w - 1 do
    local sx, sy = x - dx, y - dy
    if sx >= 0 and sy >= 0 and sx < c.w and sy < c.h then pix[y * c.w + x] = c.pix[sy * c.w + sx] own[y * c.w + x] = c.own[sy * c.w + sx] end
  end end
  c.pix, c.own = pix, own
end
-- (bez + tube copied from batch1/_g0.lua)
function G.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- tube along a cubic bezier: half width wfn(t). Returns mask, normals, T, S (S<0 = lit/upper-left side)
function G.tube(p, wfn, o)
  o = o or {}
  local N = o.steps or 200
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
  for y = floor(by0) - 8, floor(by1) + 8 do for x = floor(bx0) - 8, floor(bx1) + 8 do
    local best, bs
    for _, s in ipairs(sm) do
      local dx, dy = x - s.x, y - s.y
      local q = dx*dx + dy*dy
      if not best or q < best then best, bs = q, s end
    end
    if bs.w > 0 and sqrt(best) <= bs.w + (o.pad or 0) then
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
-- mint leaf geometry: ovate blade (widest ~35%), pointed tip, serrated margin. o: fold, tooth (px period), notch {x,y,r}
function G.mintGeom(ax, ay, cx, cy, bx, by, w, o)
  o = o or {}
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.97 + 0.03)
    return max(0.45, w * math.sin(math.pi * u ^ (o.exp or 0.7)) ^ (o.pw or 0.5))
  end, { fold = o.fold or 0.38 })
  local tooth = o.tooth or 3.4
  m:edge():each(function(x, y) local k = K(x, y)
    local t = T[k]
    if t > 0.1 and t < 0.93 and abs(S[k]) > 0.45 then
      local ph = (t * len + (S[k] > 0 and tooth * 0.5 or 0)) / tooth
      if ph - floor(ph) < (o.tcut or 0.3) then m.s[k] = nil end
    end
  end)
  if o.notch then local nx, ny, r = o.notch[1], o.notch[2], o.notch[3]
    local cut = {}
    m:each(function(x, y) if (x - nx)^2 + (y - ny)^2 <= r * r then cut[#cut + 1] = K(x, y) end end)
    for _, k in ipairs(cut) do m.s[k] = nil end
  end
  return { m = m, n = n, T = T, S = S, len = len, o = o }
end
-- paint a mint leaf: per-pixel light, impressed (grooved) side veins with lit ridges = rugose look, pale midrib,
-- cool bounce on the lower-right edge. ramp 6 tones dark->light. bias: extra AO map
function G.mintPaint(c, L, ramp, bias, o)
  o = o or {}
  local m, n, T, S, len = L.m, L.n, L.T, L.S, L.len
  local tok = { r = { name = o.name or "mleaf" } }
  local b = {}
  for k, v in pairs(bias or {}) do b[k] = v end
  local vs = o.veins or { 0.2, 0.36, 0.52, 0.68, 0.82 }
  local slant = o.slant or 3.2
  local vein = {}
  m:each(function(x, y) local k = K(x, y)
    local s, t = S[k], T[k]
    if abs(s) > 0.16 and abs(s) < 0.8 then
      for _, vt in ipairs(vs) do
        local d = t * len - (vt * len + abs(s) * slant)
        if d > -0.5 and d < 0.5 then vein[k] = true b[k] = (b[k] or 0) - 1 break
        elseif d >= 0.5 and d < 1.5 and s < 0 and abs(s) < 0.7 then b[k] = (b[k] or 0) + 1 break end
      end
    end
  end)
  G.toneN(c, m, n, ramp, { bias = b, tok = tok, cuts = o.cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if (bias or {})[k] then return end
    if abs(s) < 0.13 and t > 0.03 and t < 0.9 then c:put(x, y, s <= 0 and (o.rib or ramp[6]) or ramp[3], tok) end
  end)
  if o.cool then
    local rim = X.rim(n)
    m:edge():each(function(x, y) local k = K(x, y)
      if not (bias or {})[k] and S[k] > 0.55 and T[k] > 0.12 and T[k] < 0.88 then c:put(x, y, o.cool, tok) end end)
  end
  return tok
end
return G

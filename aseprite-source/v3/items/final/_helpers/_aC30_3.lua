-- _aC30_3 helper (chunk C3, Opus single pass): thin layer over batch2/_b2.lua (shared files not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local K = B.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local A = { B = B, H = H, HP = HP, X = X, K = K, ell = B.ell, ln = B.ln }
A.CREAM, A.INK = "#fff4d6", "#2b1c26"
A.CUTS = { 0.2, 0.37, 0.53, 0.69, 0.85 }
local function tok(name) return { r = { name = name } } end
A.tok = tok
function A.new(name) return B.new(name) end
function A.fin() B.fin() end
-- tone a normal field (with optional bias) onto mask
function A.toneN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.28 })
  return X.tone(c, m, v, ramp, { cuts = o.cuts or A.CUTS, bias = o.bias, tok = o.tok or tok(tostring(m)) })
end
-- pillow-lit mask
function A.pil(c, m, ramp, R, o)
  local n = X.pillow(m, R or 2.5)
  local idx = A.toneN(c, m, n, ramp, o)
  return idx, n
end
-- sphere-lit mask (optional bulge squash)
function A.sph(c, cx, cy, rx, ry, m, ramp, o)
  local n = {}
  m:each(function(x, y)
    local nx, ny = (x - cx) / (rx + .5), (y - cy) / (ry + .5)
    local q = max(0.03, 1 - nx * nx - ny * ny)
    local l = sqrt(nx * nx + ny * ny + q)
    n[K(x, y)] = { nx / l, ny / l, sqrt(q) / l }
  end)
  return A.toneN(c, m, n, ramp, o), n
end
-- cubic bezier point
function A.bez(p, t)
  local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1],
         u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2]
end
-- swept tube along a cubic bezier; wfn(t) half width. returns mask, normals, T, S (S signed -1..1, <0 lit side)
-- o.flat scales the across-normal (0.4 = flattish leaf)
function A.tube(p, wfn, o)
  o = o or {}
  local N = o.N or 90
  local P = {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i = 0, N do local x, y = A.bez(p, i / N) P[#P + 1] = { x, y, i / N }
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W = 0 for i = 0, 20 do W = max(W, wfn(i / 20)) end
  local m, n, T, S = HP.mask(), {}, {}, {}
  for y = floor(y0 - W - 2), floor(y1 + W + 2) do for x = floor(x0 - W - 2), floor(x1 + W + 2) do
    local best, bi = 1e9, 1
    for i, q in ipairs(P) do local dx, dy = x - q[1], y - q[2] local d = dx * dx + dy * dy if d < best then best, bi = d, i end end
    local a, b = P[max(1, bi - 1)], P[min(#P, bi + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]
    local tl = sqrt(tx * tx + ty * ty) tx, ty = tx / tl, ty / tl
    local px, py = -ty, tx
    if px + py < 0 then px, py = -px, -py end
    local dx, dy = x - P[bi][1], y - P[bi][2]
    local s = dx * px + dy * py
    local w = wfn(P[bi][3])
    if w > 0 and sqrt(best) <= w + 0.02 then
      local k = K(x, y)
      m:set(x, y)
      local sn = max(-0.97, min(0.97, s / (w + 0.5)))
      local f = o.flat or 1
      local nx, ny, nz = px * sn * f, py * sn * f, sqrt(max(0.05, 1 - (sn * f) ^ 2))
      if o.bend then nx, ny = nx + tx * o.bend * (P[bi][3] - 0.5), ny + ty * o.bend * (P[bi][3] - 0.5) end
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      n[k] = { nx / l, ny / l, nz / l }
      T[k], S[k] = P[bi][3], sn
    end
  end end
  return m, n, T, S
end
-- torn edge: remove pixels of m within depth of the boundary on a side defined by sel(x,y) using hash noise
function A.tear(m, sel, depth, seed)
  local e = m:edge()
  local cut = HP.mask()
  local core = m:shrink(depth + 1)
  e:each(function(x, y)
    if sel(x, y) then
      local h = X.hash(floor(x / 2), floor(y / 2), seed or 3)
      local d = floor(h * (depth + 1))
      for i = 0, d - 1 do
        for _, q in ipairs{ { 0, 0 }, { i, 0 }, { -i, 0 }, { 0, i }, { 0, -i } } do
          if m:has(x + q[1], y + q[2]) and not core:has(x + q[1], y + q[2]) then cut:set(x + q[1], y + q[2]) end
        end
      end
    end
  end)
  m:cut(cut)
  return m
end
-- lentil/oval seed with contact shadow, returns mask & normals; o.dent = depression radius factor
function A.seed(c, cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  if o.shadow then
    local sh = B.ell(cx + 1, cy + 1.2, rx + .2, ry + .2, ang)
    if o.clip then sh:clip(o.clip) end
    c:fillMask(sh, o.shadow)
  end
  local m = B.ell(cx, cy, rx, ry, ang)
  local ca, sa = cos(ang), sin(ang)
  local n = {}
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = (dx * ca + dy * sa) / (rx + .5), (-dx * sa + dy * ca) / (ry + .5)
    local r2 = u * u + v * v
    local gx, gy = dx / (rx + .5), dy / (ry + .5)
    local nz = sqrt(max(0.04, 1 - r2))
    if o.dent and r2 < o.dent * o.dent then gx, gy = -gx * 0.8, -gy * 0.8 nz = 1 end
    local l = sqrt(gx * gx + gy * gy + nz * nz)
    n[K(x, y)] = { gx / l, gy / l, nz / l }
  end)
  local idx = A.toneN(c, m, n, ramp, { tok = o.tok or tok("seed" .. cx .. cy), cuts = o.cuts, amb = 0.08, wrap = 0.22 })
  return m, n, idx
end
-- shift every painted pixel (recentre before finishing)
function A.shift(c, dx, dy)
  local pix, own = {}, {}
  for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
    if c.pix[i] then local nx, ny = x + dx, y + dy
      if nx >= 0 and ny >= 0 and nx < c.w and ny < c.h then pix[ny * c.w + nx] = c.pix[i] own[ny * c.w + nx] = c.own[i] end end end end
  c.pix, c.own = pix, own
end
return A

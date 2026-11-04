-- _aA6_4.lua: private helpers for ico/ico-lock, ico-log, ico-magnifier, ico-mailbox (final pass, Opus).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = setmetatable({}, { __index = G })
local sqrt, floor, max, min, abs, sin, cos = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos
A.HP, A.X, A.K = HP, X, K
A.OUT = app.params.out or (DIR .. "/../ico/")
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.CUTS6 = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end

-- light + tone a normal field (6-tone default cuts); returns idx, v
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  local cuts = o.cuts or (#ramp == 6 and A.CUTS6) or (#ramp == 5 and { 0.22, 0.42, 0.62, 0.82 }) or { 0.3, 0.55, 0.8 }
  local idx = X.tone(c, m, v, ramp, { cuts = cuts, bias = o.bias, tok = o.tok })
  return idx, v
end

-- pillow-lit part; returns idx, n, d (distance field)
function A.pill(c, m, R, ramp, o)
  o = o or {}
  local n, d = X.pillow(m, R, o.hs)
  if o.tilt then n = A.tilt(n, o.tilt[1], o.tilt[2], o.tilt[3], o.tilt[4]) end
  local idx = A.shade(c, m, n, ramp, o)
  return idx, n, d
end

function A.tilt(n, tx, ty, tz, w)
  tx, ty, tz = norm(tx, ty, tz)
  local o = {}
  for k, a in pairs(n) do o[k] = { norm(a[1] * (1 - w) + tx * w, a[2] * (1 - w) + ty * w, a[3] * (1 - w) + tz * w) } end
  return o
end

-- re-tone a pixel by d steps (keeps idx in sync)
function A.step(c, idx, ramp, x, y, d, tok)
  local k = K(x, y) local i = idx[k]
  if not i then return end
  i = max(1, min(#ramp, i + d)) idx[k] = i
  c:put(x, y, ramp[i], tok)
end

-- mask from a local-frame predicate: origin (ox,oy), axis angle a (radians, u along axis, v across: +v = rotate u by +90deg)
-- f(u, v) -> true if inside. bbox radius R around origin. Also returns U, V per pixel.
function A.local_mask(ox, oy, a, R, f)
  local ux, uy = cos(a), sin(a)
  local vx, vy = -uy, ux
  local m, U, V = HP.mask(), {}, {}
  for y = floor(oy - R), floor(oy + R) do for x = floor(ox - R), floor(ox + R) do
    local dx, dy = x - ox, y - oy
    local u, v = dx * ux + dy * uy, dx * vx + dy * vy
    if f(u, v) then m:set(x, y) U[K(x, y)], V[K(x, y)] = u, v end
  end end
  return m, U, V, { ux = ux, uy = uy, vx = vx, vy = vy }
end

-- distance-field ellipse mask
function A.ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x - cx) / (rx + 0.45))^2 + ((y - cy) / (ry + 0.45))^2 <= 1 then m:set(x, y) end
  end end
  return m
end

function A.map(c, rows, x0, y0, pal, tok)
  for yy, row in ipairs(rows) do for xx = 1, #row do
    local ch = row:sub(xx, xx)
    if pal[ch] then c:put(x0 + xx - 1, y0 + yy - 1, pal[ch], tok) end
  end end
end

-- darken pixels of mask m that touch mask other (ambient where parts meet)
function A.ao(c, idx, ramp, m, other, d, tok)
  local g = other:grow(1)
  m:each(function(x, y) if g:has(x, y) and not other:has(x, y) then A.step(c, idx, ramp, x, y, d or -2, tok) end end)
end

function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
end

-- round tube along a dense centre polyline pts={{x,y},..}, half width w (number or fn(i/#pts)).
-- returns mask, normals, T (0..1 along), S (signed across, + = lower-right)
function A.ptube(pts, w)
  local m, n, T, S = HP.mask(), {}, {}, {}
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for _, p in ipairs(pts) do x0, y0, x1, y1 = min(x0, p[1]), min(y0, p[2]), max(x1, p[1]), max(y1, p[2]) end
  local N = #pts
  for y = floor(y0) - 8, floor(y1) + 8 do for x = floor(x0) - 8, floor(x1) + 8 do
    local best, bi
    for i, p in ipairs(pts) do local q = (x + .5 - p[1])^2 + (y + .5 - p[2])^2 if not best or q < best then best, bi = q, i end end
    local ww = type(w) == "function" and w((bi - 1) / (N - 1)) or w
    local d = sqrt(best)
    if d <= ww then
      local p = pts[bi]
      local dx, dy = x + .5 - p[1], y + .5 - p[2]
      local sn = min(0.97, d / (ww + 0.35))
      local ux, uy = 0, 0
      if d > 1e-6 then ux, uy = dx / d, dy / d end
      m:set(x, y)
      local k = K(x, y)
      n[k] = { ux * sn, uy * sn, sqrt(1 - sn * sn) }
      T[k] = (bi - 1) / (N - 1)
      S[k] = (ux + uy >= 0 and 1 or -1) * sn
    end
  end end
  return m, n, T, S
end

-- brightest pixel(s) of a specular term within mask
function A.glint(m, n, power, count)
  local sp = X.spec(n, power or 40)
  local list = {}
  m:each(function(x, y) list[#list + 1] = { x, y, sp[K(x, y)] or 0 } end)
  table.sort(list, function(a, b) if a[3] ~= b[3] then return a[3] > b[3] end if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
  local out = {}
  for i = 1, min(count or 1, #list) do out[i] = list[i] end
  return out
end
return A

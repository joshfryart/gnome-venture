-- _aA6_5.lua: private helpers for ico-map-pin, ico-medal-bronze/-gold/-silver (Opus single pass).
-- Read-only use of batch2/_b2g1.lua (-> batch1/_g1.lua -> _h.lua -> lib/hp.lua + hpx.lua).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../../batch2/_b2g1.lua")
local HP, X, K = G.HP, G.X, G.K
local A = { HP = HP, X = X, K = K, G = G }
local sqrt, floor, max, min, abs, cos, sin, pi, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.pi, math.atan
local function norm(x, y, z) local l = sqrt(x*x + y*y + z*z) return x/l, y/l, z/l end
A.norm = norm
A.INK, A.CREAM = "#2b1c26", "#fff4d6"
A.OUT = app.params.out or (DIR .. "/../ico/")

A.RED  = { "#5a1834", "#8e2638", "#c23a3a", "#e8553e", "#ff8158", "#ffbb8c" }
A.GOLD = { "#723418", "#ad5a1c", "#da8a20", "#f4b52c", "#ffd95c", "#fff1a6" }
A.SILV = { "#363a5c", "#585e84", "#8088aa", "#aab0cc", "#d2d6e8", "#eff1fa" }
A.BRZ  = { "#45201a", "#743620", "#a0522a", "#c4723a", "#e09452", "#f6bf7c" }

function A.new(name) return HP.canvas{ w = 64, h = 64, scale = 1, name = name } end
function A.tok(name) return { r = { name = name } } end

-- paint normals n over mask m with ramp; returns idx
function A.shade(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  if o.add then for k, a in pairs(o.add) do if v[k] then v[k] = max(0, min(1, v[k] + a)) end end end
  return X.tone(c, m, v, ramp, { cuts = o.cuts or { 0.24, 0.42, 0.58, 0.74, 0.88 }, bias = o.bias, tok = o.tok or A.tok(o.name or "part") })
end

function A.fill(c, m, hex, tok) m:each(function(x, y) c:put(x, y, hex, tok) end) end

-- recessed field: flat plane tilted toward the light + inner wall (dark upper-left, lit lower-right)
function A.field(c, m, ramp, tok, o)
  o = o or {}
  local x0, y0, x1, y1 = m:bbox()
  local cx, cy = (x0 + x1) / 2, (y0 + y1) / 2
  local R = max(x1 - x0, y1 - y0) / 2 + 0.5
  local idx = {}
  m:each(function(x, y)
    local g = -((x - cx) + (y - cy)) / (2 * R)          -- -1..1, lit upper-left
    local i = (o.mid or 4) + (g > 0.42 and 1 or (g < -0.45 and -1 or 0))
    idx[K(x, y)] = i
  end)
  m:each(function(x, y)
    local k = K(x, y)
    if not m:has(x - 1, y) or not m:has(x, y - 1) then idx[k] = (o.wallDark or 2)
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then idx[k] = (o.wallLit or 5) end
    c:put(x, y, ramp[idx[k]], tok)
  end)
  return idx
end

-- raised emblem on a field: pillow lit + 1px drop shadow on the field lower-right
function A.emboss(c, m, ramp, tok, field, o)
  o = o or {}
  local sh = m:shift(1, 1):cut(m)
  sh:each(function(x, y) if field:has(x, y) then c:put(x, y, ramp[o.shadow or 2], tok) end end)
  local n = X.pillow(m, o.R or 1.4)
  return A.shade(c, m, n, ramp, { tok = tok, cuts = o.cuts or { 0.12, 0.24, 0.36, 0.5, 0.66 }, amb = 0.1 })
end

-- polygon strip of cloth along axis A->B: gentle cross curvature, edge hem tone, twill weave lines
function A.strap(c, m, ax, ay, bx, by, hw, ramp, tok, o)
  o = o or {}
  local vx, vy = bx - ax, by - ay
  local l = sqrt(vx*vx + vy*vy) vx, vy = vx / l, vy / l
  local px, py = -vy, vx
  if px + py < 0 then px, py = -px, -py end
  local n, S, T = {}, {}, {}
  m:each(function(x, y)
    local rx, ry = x - ax, y - ay
    local s = max(-0.95, min(0.95, (rx*px + ry*py) / (hw + 0.5)))
    local k = K(x, y)
    S[k], T[k] = s, (rx*vx + ry*vy) / l
    local tilt = o.tilt or 0
    n[k] = { norm(px * s * 0.55 + tilt, py * s * 0.55, 1) }
  end)
  local idx = A.shade(c, m, n, ramp, { tok = tok, cuts = o.cuts or { 0.3, 0.5, 0.66, 0.8, 0.92 }, amb = 0.1, bias = o.bias })
  -- twill: diagonal 1px lines one step darker on mid tones
  m:each(function(x, y) local k = K(x, y)
    local i = idx[k]
    if i and i >= 3 and i <= 5 and (x + y * (o.tw or 1)) % (o.tp or 5) == 0 then c:put(x, y, ramp[i - 1], tok) end
  end)
  return idx, S, T
end

-- cylinder bar between two points (metal clasp)
function A.bar(c, ax, ay, bx, by, w, ramp, tok)
  local m, n = X.cyl(ax, ay, bx, by, function() return w end)
  return m, A.shade(c, m, n, ramp, { tok = tok, cuts = { 0.2, 0.38, 0.56, 0.72, 0.86 } })
end

-- faceted n-point star (ridges from centre to tips): mask + normals
function A.star(cx, cy, ro, ri, np, rot, lift)
  local pts = {}
  for i = 0, 2 * np - 1 do
    local a = rot + i * pi / np
    local r = (i % 2 == 0) and ro or ri
    pts[#pts + 1] = { cx + cos(a) * r, cy + sin(a) * r }
  end
  local m = HP.poly(pts)
  local n = {}
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local a = atan(dy, dx) - rot
    local seg = 2 * pi / np
    local j = floor(a / seg + 0.5)
    local aa = rot + j * seg                      -- nearest arm direction
    local side = ((a - j * seg) >= 0) and 1 or -1
    local ux, uy = cos(aa), sin(aa)
    local tx, ty = -uy * side, ux * side         -- away from the ridge
    n[K(x, y)] = { norm(tx * 0.75 + ux * (lift or 0.2), ty * 0.75 + uy * (lift or 0.2), 1) }
  end)
  return m, n, pts
end

-- 9x13 digits, 3px strokes (mask at x,y top-left)
function A.digit(d, x, y)
  local m = HP.mask()
  local function r(a, b, c2, e) m:add(HP.rect(x + a, y + b, x + c2, y + e)) end
  if d == 3 then
    r(0, 0, 7, 2) r(6, 1, 8, 11) r(2, 5, 8, 7) r(0, 10, 7, 12)
    m.s[K(x + 8, y + 1)] = nil m.s[K(x + 8, y + 11)] = nil m.s[K(x + 8, y + 5)] = nil m.s[K(x + 8, y + 7)] = nil
  elseif d == 2 then
    r(0, 0, 7, 2) r(6, 1, 8, 6) r(1, 5, 7, 7) r(0, 6, 2, 11) r(0, 10, 8, 12)
    m.s[K(x + 8, y + 1)] = nil m.s[K(x + 8, y + 6)] = nil m.s[K(x, y + 6)] = nil
  end
  return m
end

-- centre the outlined bbox, outline, check, save next to the drafts
function A.save(c, name)
  G.recentre(c)
  c:finish{ outline = true }
  local r = HP.report(c) HP.assertClean(c)
  c:save{ aseprite = A.OUT .. name .. ".aseprite", png = A.OUT .. name .. ".png", scale = 1 }
  return r
end
return A

-- ico-medal-gold (Opus single pass, replaces the Sonnet draft). First place as a sunburst: a 16-ray gold burst
-- (each ray faceted along its ridge, so the edge flickers light/dark like cut metal) around a recessed field with a
-- raised, faceted five-point star, hung from a pleated ember rosette (radial pleats, a covered centre button) with
-- two swallow-tailed tails flaring out behind. Dark ambient rows where the rosette and tails tuck behind the medal.
-- quirk: somebody tested it the old way: a tooth-mark bite in the right edge.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_5.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, floor, max, min, abs, cos, sin, pi, atan = math.sqrt, math.floor, math.max, math.min, math.abs, math.cos, math.sin, math.pi, math.atan
local c = A.new("ico-medal-gold")
local Gd = A.GOLD
local RED = A.RED
local tt, tro, tm = A.tok("tails"), A.tok("rosette"), A.tok("gold")

local MX, MY = 32, 41
-- tails (behind everything)
local function tail(pts, ax, ay, bx, by)
  local m = c:poly(pts)
  A.strap(c, m, ax, ay, bx, by, 3.2, RED, tt, { tp = 4 })
  return m
end
local tL = tail({ { 28, 16 }, { 33, 19 }, { 20, 40 }, { 17, 35 }, { 12, 38 } }, 30, 17, 16, 37)
local tR = tail({ { 36, 16 }, { 31, 19 }, { 44, 40 }, { 47, 35 }, { 52, 38 } }, 34, 17, 48, 37)

-- medal mask: burst of 16 rays
local NR, RI, RO = 12, 12.6, 16.6
local med, mn = HP.mask(), {}
for y = MY - 18, MY + 18 do for x = MX - 18, MX + 18 do
  local dx, dy = x - MX, y - MY
  local r = sqrt(dx*dx + dy*dy)
  local a = atan(dy, dx) + pi / NR * 0.5
  local seg = 2 * pi / NR
  local f = (a / seg) % 1                          -- 0..1 across a ray, 0.5 = ridge
  local edge = RI + (RO - RI) * (1 - abs(f - 0.5) * 2)
  if r <= edge + 0.2 then
    med:set(x, y)
    local ux, uy = dx / max(r, 0.1), dy / max(r, 0.1)
    local side = f < 0.5 and -1 or 1
    local tx, ty = -uy * side, ux * side
    local k = K(x, y)
    if r > RI - 3 then
      mn[k] = { A.norm(-tx * 0.65 + ux * 0.45, -ty * 0.65 + uy * 0.45, 1) }   -- faceted ray
    else
      mn[k] = { A.norm(ux * 0.15, uy * 0.15, 1) }
    end
  end
end end
-- quirk: bite (two overlapping tooth arcs) in the right edge
local bite = c:ellipse(MX + 15, MY + 3, 4, 4.5):add(c:ellipse(MX + 13, MY + 3, 2, 3))
med:cut(bite)
for k, _ in pairs(mn) do local x, y = k % 1024 - 256, k // 1024 - 256 if not med:has(x, y) then mn[k] = nil end end
-- ambient: tails darken where they go behind the medal
med:grow(1):each(function(x, y) if (tL:has(x, y) or tR:has(x, y)) and not med:has(x, y) then c:put(x, y, RED[1], tt) end end)
A.shade(c, med, mn, Gd, { tok = tm, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.06 })
-- bite wall: freshly exposed metal, lit lower-right inner edge
bite:grow(1):each(function(x, y) if med:has(x, y) then c:put(x, y, (y < MY + 1) and Gd[2] or Gd[6], tm) end end)
-- tooth dents: two small nicks on the bite wall
c:put(MX + 10, MY + 1, Gd[1], tm) c:put(MX + 10, MY + 5, Gd[1], tm)
-- ring groove between the rays and the field
local field = c:ellipse(MX, MY, 9.5, 9.5)
c:ellipse(MX, MY, 10.5, 10.5):cut(field):each(function(x, y)
  if med:has(x, y) then c:put(x, y, ((x - MX) + (y - MY) < 0) and Gd[1] or Gd[6], tm) end end)
A.field(c, field, Gd, tm, { mid = 2, wallDark = 1, wallLit = 4 })
-- raised faceted star
local st, sn = A.star(MX, MY + 0.5, 8.2, 3.6, 5, -pi / 2, 0.15)
st:shift(1, 1):cut(st):each(function(x, y) if field:has(x, y) then c:put(x, y, Gd[2], tm) end end)
A.shade(c, st, sn, Gd, { tok = tm, cuts = { 0.1, 0.22, 0.36, 0.52, 0.7 }, amb = 0.1 })
c:put(MX, MY + 1, Gd[6], tm)

-- rosette (in front of the medal top)
local RX, RY, RR = 32, 18, 7.5
local ros = c:ellipse(RX, RY, RR, RR)
local rn, NP = {}, 14
ros:each(function(x, y)
  local dx, dy = x - RX, y - RY
  local r = sqrt(dx*dx + dy*dy)
  local a = atan(dy, dx)
  local f = (a / (2 * pi / NP)) % 1
  local side = f < 0.5 and -1 or 1
  local ux, uy = dx / max(r, .1), dy / max(r, .1)
  local tx, ty = -uy * side, ux * side
  local w = min(1, r / RR)
  rn[K(x, y)] = { A.norm(tx * 0.55 * w + ux * 0.35 * w, ty * 0.55 * w + uy * 0.35 * w, 1) }
end)
-- contact shadow on the medal under the rosette
ros:shift(1, 2):cut(ros):each(function(x, y) if med:has(x, y) then c:put(x, y, Gd[1], tm) end end)
A.shade(c, ros, rn, RED, { tok = tro, cuts = { 0.26, 0.44, 0.6, 0.74, 0.88 } })
-- pinked (zig-zag) outer edge: every other edge pixel one tone darker
ros:edge():each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, RED[2], tro) end end)
-- covered centre button
local btn = c:ellipse(RX, RY, 2.5, 2.5)
btn:grow(1):cut(btn):each(function(x, y) c:put(x, y, RED[1], tro) end)
A.shade(c, btn, X.sphere(RX - .5, RY - .5, 3, btn), RED, { tok = tro })
c:put(RX - 1, RY - 1, RED[6], tro)

-- specular on the upper-left rays + one sparkle
for _, p in ipairs{ { -12, -6 }, { -11, -7 }, { -12, -7 } } do c:put(MX + p[1], MY + p[2], Gd[6], tm) end
c:put(MX - 12, MY - 6, A.CREAM, tm)
A.save(c, "ico-medal-gold")

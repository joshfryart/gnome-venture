-- ico-tools (final, Opus). Crossed claw hammer and open-end spanner, slim and bold for 16 px.
-- Material: per-pixel cylinder light on the ash handle (6-tone wood) with grain lines, a pale end-grain butt and a
-- twisted twine grip wrap; forged hammer head with a bevelled edge, a bright polished striking face and a dark eye
-- where the handle enters; chrome spanner with a lit bevel, specular streak, dark jaw throat and box-end hole.
-- Ambient shade where the handle crosses the spanner + a contact shadow under it.
-- quirk: a bent nail is still caught in the hammer's claw.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_4.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = R.new("ico-tools")
local WOOD  = { "#4a2a26", "#70402c", "#995a34", "#c07e46", "#dca263", "#f2c98c" }
local CHR   = { "#2a2c42", "#454a66", "#69708e", "#939bb6", "#c2cade", "#eef2f8" }
local IRON  = { "#24223a", "#383651", "#52536f", "#727894", "#9aa3bf", "#d6deec" }
local TWINE = { "#5a3a2c", "#82603e", "#ab8a58", "#cfb276", "#e8d29a", "#f8ecc4" }
local wt, st, ht, tt = { r = { name = "wood" } }, { r = { name = "chrome" } }, { r = { name = "iron" } }, { r = { name = "twine" } }

---------------------------------------------------------------- spanner (under)
local Cx, Cy, Dx, Dy = 14, 53, 45, 19
local sm, sn, ST, SS = X.cyl(Cx, Cy, Dx, Dy, function(t) return 1.9 + 0.3 * abs(t - 0.5) end)
local wx, wy = (Dx - Cx), (Dy - Cy) local wl = sqrt(wx*wx + wy*wy) wx, wy = wx / wl, wy / wl
local qx, qy = -wy, wx                       -- across the spanner
-- jaw head: rounded head, slot opening along the axis (tilted 15 deg)
local jx, jy = R.rot(wx, wy, -0.26)
local jqx, jqy = -jy, jx
local head = R.lmask(Dx + wx * 1.5, Dy + wy * 1.5, jx, jy, jqx, jqy, function(a, b)
  return a * a + b * b <= 7.2 * 7.2 or (a > 0 and a < 7.6 and abs(b) < 6.2 - a * 0.3)
end, 14)
local slot = R.lmask(Dx + wx * 1.5, Dy + wy * 1.5, jx, jy, jqx, jqy, function(a, b)
  return (a > 0.5 and abs(b) <= 2.4) or (a * a + b * b <= 2.4 * 2.4 + 1 and a > -1.2)
end, 14)
head:cut(slot)
-- box end: ring with a hex-ish hole
local ring = c:ellipse(Cx - 1, Cy + 1, 4.5, 4.5)
local hole = c:ellipse(Cx - 1, Cy + 1, 1.5, 1.5)
local span = sm:copy():add(head):add(ring):cut(hole)
local spn = X.pillow(span, 2.2)
-- blend shaft cylinder normals in for the round bar
for k, v in pairs(sn) do if spn[k] then local p = spn[k]
  spn[k] = { R.norm(v[1] * 0.6 + p[1] * 0.4, v[2] * 0.6 + p[2] * 0.4, v[3] * 0.6 + p[3] * 0.4) } end end
local sidx = R.shade(c, span, spn, CHR, { amb = 0.1, wrap = 0.2, tok = st })
-- dark throat inside the jaw (pixels of head that touch the slot)
R.sepLine(c, head, slot, CHR[2], st)
-- specular streak along the lit side of the shaft
for i = 0, 7 do local t = 0.3 + i * 0.05
  local x, y = Cx + (Dx - Cx) * t + qx * -1.0, Cy + (Dy - Cy) * t + qy * -1.0
  local xi, yi = floor(x + .5), floor(y + .5)
  if span:has(xi, yi) then c:put(xi, yi, i == 3 and CHR[6] or CHR[5], st) end
end
-- inside rim of the box-end hole is dark
R.sepLine(c, ring, hole, CHR[2], st)

---------------------------------------------------------------- hammer handle (over)
local Ax, Ay, Bx, By = 50, 55, 21, 25
local hm, hn, HT, HS = X.cyl(Ax, Ay, Bx, By, function(t)
  if t < 0.04 then return 2.6 end               -- flared butt
  if t < 0.36 then return 2.5 end               -- grip under the wrap
  return 2.1 - (t - 0.36) * 0.5
end)
local ux, uy = Bx - Ax, By - Ay local ul = sqrt(ux*ux + uy*uy) ux, uy = ux / ul, uy / ul
local bias = {}
local hidx = R.shade(c, hm, hn, WOOD, { amb = 0.1, wrap = 0.25, tok = wt, bias = bias })
-- grain: two broken lines along the handle
hm:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
  if t > 0.36 and t < 0.95 then
    if (abs(s - 0.35) < 0.17 and X.hash(x, y, 3) > 0.25) or (abs(s + 0.3) < 0.15 and (floor(t * 40) % 3 ~= 0)) then
      c:put(x, y, WOOD[max(1, (hidx[k] or 3) - 1)], wt) end
  end
end)
-- pale end grain on the butt
hm:each(function(x, y) local k = K(x, y) if HT[k] < 0.03 then c:put(x, y, abs(HS[k]) < 0.5 and WOOD[6] or WOOD[5], wt) end end)
-- twine wrap: twisted diagonal turns on the grip
local tm = HP.mask()
hm:each(function(x, y) local k = K(x, y) if HT[k] > 0.08 and HT[k] < 0.33 then tm:set(x, y) end end)
local tn = {} for k, v in pairs(hn) do if tm.s[k] then tn[k] = v end end
local tidx = R.shade(c, tm, tn, TWINE, { amb = 0.12, wrap = 0.3, tok = tt })
tm:each(function(x, y) local k = K(x, y)
  local d = (HT[k] * ul + HS[k] * 2.2) % 2.6
  if d < 0.9 then R.step(c, tidx, TWINE, x, y, -2, tt) end
end)
-- the loose twine end, flicking off the grip
c:put(floor(Ax + ux * 8.5 + 3.2), floor(Ay + uy * 8.5 + 1.0), TWINE[4], tt)
c:put(floor(Ax + ux * 8.5 + 4.2), floor(Ay + uy * 8.5 + 1.8), TWINE[3], tt)
-- ambient shade on the spanner where the handle crosses + contact shadow
hm:shift(1, 1):each(function(x, y) if span:has(x, y) and not hm:has(x, y) then R.step(c, sidx, CHR, x, y, -2, st) end end)
hm:shift(2, 2):each(function(x, y) if span:has(x, y) and not hm:has(x, y) and not hm:has(x - 1, y - 1) then R.step(c, sidx, CHR, x, y, -1, st) end end)
-- separation: dark wood line where the handle lies over the steel
hm:each(function(x, y)
  if (span:has(x + 1, y) or span:has(x, y + 1)) and not hm:has(x + 1, y + 1) then c:put(x, y, WOOD[1], wt) end
end)

---------------------------------------------------------------- hammer head
local Hx, Hy = Bx + ux * 1.2, By + uy * 1.2
local px, py = -uy, ux
if px < 0 then px, py = -px, -py end           -- +a = up-right (claw), -a = down-left (face)
local hd = R.lmask(Hx, Hy, px, py, ux, uy, function(a, b)
  if a >= -12.5 and a < -10.5 then return abs(b) <= 4.6 end              -- striking face (slightly wider)
  if a >= -10.5 and a < -3 then return abs(b) <= 3.8 - (a + 10.5) * 0.06 end
  if a >= -3 and a <= 3.2 then return abs(b) <= 3.6 end                  -- eye block
  if a > 3.2 and a <= 13.5 then                                          -- claw curving back toward the handle
    local bc = 0.6 - 0.045 * (a - 3.2) ^ 2
    local hw = 3.7 - 0.16 * (a - 3.2)
    return abs(b - bc) <= hw
  end
  return false
end, 18)
-- claw V slot
local vslot = R.lmask(Hx, Hy, px, py, ux, uy, function(a, b)
  local bc = 0.6 - 0.045 * (a - 3.2) ^ 2
  return a > 7.4 and a < 14 and abs(b - bc) < 0.7
end, 18)
hd:cut(vslot)
local hdn = X.pillow(hd, 2.0)
local hb = {}
local hdx = R.shade(c, hd, hdn, IRON, { amb = 0.08, wrap = 0.2, tok = ht, bias = hb })
-- polished striking face: bright band with a dark lip behind it
local A2 = {}
hd:each(function(x, y) local dx, dy = x - Hx, y - Hy local a = dx * px + dy * py A2[K(x, y)] = a end)
hd:each(function(x, y) local a = A2[K(x, y)]
  if a < -10.9 then R.step(c, hdx, IRON, x, y, 2, ht)
  elseif a < -10.0 then R.step(c, hdx, IRON, x, y, -2, ht) end
end)
-- dark eye: handle end shows in the eye as a sunken wedge
local eye = R.lmask(Hx, Hy, px, py, ux, uy, function(a, b) return abs(a) <= 1.4 and b > -1.2 and b < 1.6 end, 6)
local ex0, ey0 = eye:bbox()
eye:each(function(x, y) if hd:has(x, y) then c:put(x, y, (x == ex0 or y == ey0) and WOOD[3] or WOOD[1], wt) end end)
-- ambient shade on the handle right under the head
hm:each(function(x, y) if not hd:has(x, y) and (hd:has(x - 1, y - 1) or hd:has(x, y - 1) or hd:has(x - 1, y)) then
  R.step(c, hidx, WOOD, x, y, -2, wt) end end)
-- specular on the head bevel + one cream glint
do local bx, by = R.specAt(hd, hdn, 30) c:put(bx, by, IRON[6], ht) c:put(bx + 1, by, IRON[6], ht) end

---------------------------------------------------------------- quirk: bent nail caught in the claw
do
  local a, bcen = 10.0, 0.6 - 0.045 * (10.0 - 3.2) ^ 2
  local nx, ny = Hx + px * a + ux * bcen, Hy + py * a + uy * bcen
  local NAIL = { "#3a3a52", "#6c7290", "#b4bcd2" }
  -- shank pokes out above the claw, then bends over
  local x0, y0 = floor(nx + .5), floor(ny + .5)
  -- find the top of the claw at this column, shank rises 3 px above it, then bends right
  local yt = y0 while hd:has(x0, yt - 1) or vslot:has(x0, yt - 1) do yt = yt - 1 end
  for d = 1, 3 do c:put(x0, yt - d, NAIL[2], ht) c:put(x0 - 1, yt - d, d == 3 and NAIL[2] or NAIL[3], ht) end
  for d = 1, 2 do c:put(x0 + d, yt - 3, NAIL[2], ht) c:put(x0 + d, yt - 4, NAIL[3], ht) end
  c:put(x0 - 1, yt - 4, NAIL[3], ht) c:put(x0, yt - 4, NAIL[3], ht)
  -- nail head: flat cap at the bent tip
  for d = -1, 1 do c:put(x0 + 3, yt - 4 + d, d < 0 and NAIL[3] or NAIL[1], ht) end
  for d = 1, 3 do if hd:has(x0 + 1, yt - d + 3) then R.step(c, hdx, IRON, x0 + 1, yt - d + 3, -1, ht) end end
end

-- one cream sparkle on the spanner jaw
do local x, y = floor(Dx + wx * 1.5 - jqx * 4.2 - jx * 2 + .5), floor(Dy + wy * 1.5 - jqy * 4.2 - jy * 2 + .5)
  if span:has(x, y) then c:put(x, y, R.CREAM, st) end end

R.save(c, "ico-tools")

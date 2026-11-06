-- ico-trowel-pot (final, Opus). Slim terracotta flower pot (rolled rim, tapered body) filled with dark soil, a
-- garden trowel plunged in at an angle (ash handle, brass ferrule, steel scoop) and a two-leaf seedling.
-- Material: per-pixel tapered-cylinder light on the fired clay (6-tone), a lit lip and dark under-rim AO row, a pale
-- worn throwing ring; crumbly soil with clods; steel blade with a bevelled edge, centre ridge and specular streak;
-- wood handle with grain + pale end grain; leaves with midribs. Contact shadow where the blade enters the soil.
-- quirk: a small snail is slowly climbing the pot.
local R = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR0_5.lua")
local HP, X, K = R.HP, R.X, R.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = R.new("ico-trowel-pot")
local TERRA = { "#4e1f22", "#7d2f28", "#ad4a2e", "#d06a3a", "#e8935a", "#f8c088" }
local SOIL  = { "#1f1418", "#33211f", "#4c3226", "#664632", "#80603f", "#9a7a52" }
local STEEL = { "#2a2c42", "#454a66", "#69708e", "#939bb6", "#c2cade", "#eef2f8" }
local WOOD  = { "#4a2a26", "#70402c", "#995a34", "#c07e46", "#dca263", "#f2c98c" }
local BRASS = { "#5a3418", "#8f5a1f", "#c08a2a", "#e6b23e", "#f8d672", "#fff0b8" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SNAIL = { "#2e2250", "#4a3a80", "#6a58b0", "#8e7ad0", "#b4a2ea", "#dcd0fa" }
local BODY  = { "#5e4a3a", "#8c7258", "#b89a78", "#dcc49c" }
local pt, st, wt, ht, lt, nt, gt = { r = { name = "pot" } }, { r = { name = "soil" } }, { r = { name = "wood" } },
  { r = { name = "steel" } }, { r = { name = "leaf" } }, { r = { name = "snail" } }, { r = { name = "brass" } }

c:groundShadow(29, 56, 15, 1)

---------------------------------------------------------------- pot body (tapered cone, vertical axis)
local Y0, Y1 = 34, 55               -- body under the rim
local function bodyHalf(y) local t = (y - Y0) / (Y1 - Y0) return 13.5 - 3.6 * t end
local CXp = 29
local body = HP.mask()
for y = Y0, Y1 do local h = bodyHalf(y) for x = floor(CXp - h + .5), floor(CXp + h - .5) do body:set(x, y) end end
-- round the bottom corners
body:cut(HP.rect(CXp - 10, Y1, CXp - 10, Y1)):cut(HP.rect(CXp + 9, Y1, CXp + 9, Y1))
local bn = {}
body:each(function(x, y)
  local h = bodyHalf(y)
  local t = max(-.97, min(.97, (x + .5 - CXp) / (h + .4)))
  bn[K(x, y)] = { R.norm(t, -0.12, sqrt(1 - t * t)) }
end)
local bb = {}
local bidx = R.shade(c, body, bn, TERRA, { amb = 0.1, wrap = 0.3, tok = pt, bias = bb })
-- worn throwing ring (one pale groove line + dark under it)
body:each(function(x, y) if y == 45 then R.step(c, bidx, TERRA, x, y, 1, pt) elseif y == 46 then R.step(c, bidx, TERRA, x, y, -1, pt) end end)
-- base darkens toward the ground
body:each(function(x, y) if y >= Y1 - 1 then R.step(c, bidx, TERRA, x, y, -1, pt) end end)

---------------------------------------------------------------- rim (rolled lip)
local rim = HP.rrect(CXp - 16, 28, CXp + 16, 33, 2)
local rn = {}
rim:each(function(x, y)
  local tx = max(-.97, min(.97, (x + .5 - CXp) / 17))
  local ty = max(-.9, min(.9, (y + .5 - 31) / 3.6))
  rn[K(x, y)] = { R.norm(tx * 0.8, ty, sqrt(max(0.05, 1 - tx * tx * 0.6 - ty * ty))) }
end)
local ridx = R.shade(c, rim, rn, TERRA, { amb = 0.12, wrap = 0.3, tok = pt })
-- AO row: body just under the rim
body:each(function(x, y) if y == Y0 then R.step(c, bidx, TERRA, x, y, -2, pt) elseif y == Y0 + 1 then R.step(c, bidx, TERRA, x, y, -1, pt) end end)
-- dark line where the rim overhangs the body
rim:each(function(x, y) if y == 33 then R.step(c, ridx, TERRA, x, y, -1, pt) end end)

---------------------------------------------------------------- soil top (seen just over the lip)
local soil = c:ellipse(CXp, 27.5, 14, 3)
soil:cut(rim)
local sidx = {}
soil:each(function(x, y)
  local i = (y <= 25) and 5 or (y == 26 and 4 or 3)
  if X.hash(x, y, 7) > 0.78 then i = i + 1 elseif X.hash(x, y, 9) > 0.8 then i = i - 1 end
  if x > CXp + 8 then i = i - 1 end
  sidx[K(x, y)] = i c:put(x, y, SOIL[i], st)
end)
-- inner back lip of the rim (thin lit band behind the soil)
for x = CXp - 13, CXp + 13 do if soil:has(x, 25) and not soil:has(x, 24) then c:put(x, 24, TERRA[5], pt) end end
-- rim top edge lit row (lip catching the light)
rim:each(function(x, y) if y == 28 and x < CXp + 10 then c:put(x, y, x < CXp - 6 and TERRA[6] or TERRA[5], pt) end end)
-- soil front edge in the shadow of the lip
soil:each(function(x, y) if rim:has(x, y + 1) then c:put(x, y, SOIL[2], st) end end)

---------------------------------------------------------------- seedling (left)
local stem = c:line({ { 20, 25 }, { 20, 19 }, { 21, 15 } }, 2)
stem:each(function(x, y) c:put(x, y, (x == 20) and LEAF[5] or LEAF[3], lt) end)
local function leaf(ax, ay, bx, by, w)
  local lm, ln, LT, LS = R.blade(ax, ay, (ax + bx) / 2 + (by - ay) * 0.18, (ay + by) / 2 - (bx - ax) * 0.18, bx, by,
    function(t) return w * math.sin(math.pi * min(1, t * 1.05)) ^ 0.8 end, { fold = 0.5 })
  local li = R.shade(c, lm, ln, LEAF, { amb = 0.14, wrap = 0.3, tok = lt })
  lm:each(function(x, y) local k = K(x, y) if abs(LS[k]) < 0.18 and LT[k] > 0.1 and LT[k] < 0.85 then R.step(c, li, LEAF, x, y, -2, lt) end end)
  return lm
end
leaf(20, 16, 10, 11, 3.4)
leaf(22, 15, 31, 8, 3.2)

---------------------------------------------------------------- trowel: blade (in soil), ferrule, handle
-- axis from handle top (A) to blade tip buried (B)
local Ax, Ay, Bx, By = 49, 7, 38, 35
local ux, uy = Bx - Ax, By - Ay local ul = sqrt(ux * ux + uy * uy) ux, uy = ux / ul, uy / ul
local px, py = -uy, ux if px + py < 0 then px, py = -px, -py end
local function at(t, s) return Ax + ux * ul * t + px * s, Ay + uy * ul * t + py * s end
-- blade: leaf/spade shape t 0.58..1.0, widest at 0.68, buried below soil line
local blade = R.lmask(Ax, Ay, ux, uy, px, py, function(a, b)
  local t = a / ul
  if t < 0.4 or t > 1.0 then return false end
  local w
  if t < 0.5 then w = 2.0 + (t - 0.4) / 0.1 * 2.6 else w = 4.6 * ((1.0 - t) / 0.5) ^ 0.6 end
  return abs(b) <= w
end, 40)
-- hide the buried part: anything at/under the front soil line (rim covers)
blade:cut(rim):cut(HP.rect(0, 29, 63, 63))
blade:each(function(x, y) if soil:has(x, y) and y >= 27 then blade.s[K(x, y)] = nil end end)
local bln = {}
blade:each(function(x, y) local dx, dy = x - Ax, y - Ay local b = dx * px + dy * py
  local s = max(-.95, min(.95, b / 5.0)) s = s < 0 and s * 0.6 - 0.35 or s * 0.9 + 0.2
  -- scoop: dished blade with a centre ridge (normal flips at the ridge)
  bln[K(x, y)] = { R.norm(px * s * 0.7, py * s * 0.7, 1) } end)
local hb = {}
local hidx = R.shade(c, blade, bln, STEEL, { amb = 0.04, wrap = 0.1, tok = ht, bias = hb, cuts = { 0.3, 0.48, 0.64, 0.8, 0.93 } })
-- centre ridge line + bevel edge
blade:each(function(x, y) local dx, dy = x - Ax, y - Ay local b = dx * px + dy * py
  if b > -0.5 and b < 0.6 then R.step(c, hidx, STEEL, x, y, 1, ht) end end)
blade:edge():each(function(x, y) local dx, dy = x - Ax, y - Ay local b = dx * px + dy * py
  if b < 0 then R.step(c, hidx, STEEL, x, y, 1, ht) else R.step(c, hidx, STEEL, x, y, -1, ht) end end)
-- contact shadow on soil where the blade goes in + soil heaped against it
blade:shift(1, 1):each(function(x, y) if soil:has(x, y) and not blade:has(x, y) then c:put(x, y, SOIL[1], st) end end)
-- specular streak on the lit half
for i = 0, 3 do local x, y = at(0.5 + i * 0.045, -2.4) local xi, yi = floor(x + .5), floor(y + .5)
  if blade:has(xi, yi) then c:put(xi, yi, i == 0 and STEEL[6] or STEEL[5], ht) end end

-- brass ferrule (neck) t 0.5..0.6
local fx0, fy0 = at(0.31, 0) local fx1, fy1 = at(0.41, 0)
local fm, fn = X.cyl(fx0, fy0, fx1, fy1, function(t) return 2.0 end)
local fidx = R.shade(c, fm, fn, BRASS, { amb = 0.1, wrap = 0.25, tok = gt })
-- handle t 0..0.48 (slim, slightly flared at the top)
local hx0, hy0 = at(0.0, 0) local hx1, hy1 = at(0.32, 0)
local hm, hn, HT, HS = X.cyl(hx0, hy0, hx1, hy1, function(t) return t < 0.12 and 2.3 or 2.0 - (t - 0.12) * 0.4 end)
hm:cut(fm)
local widx = R.shade(c, hm, hn, WOOD, { amb = 0.1, wrap = 0.25, tok = wt })
hm:each(function(x, y) local k = K(x, y) local t, s = HT[k], HS[k]
  if t > 0.08 and t < 0.92 and ((abs(s - 0.35) < 0.17 and X.hash(x, y, 3) > 0.3) or (abs(s + 0.25) < 0.13 and floor(t * 30) % 3 ~= 0)) then
    R.step(c, widx, WOOD, x, y, -1, wt) end
  if t < 0.05 then c:put(x, y, abs(s) < 0.5 and WOOD[6] or WOOD[5], wt) end
end)
-- hanging hole near the top of the handle
do local x, y = at(0.12, 0) c:put(floor(x + .5), floor(y + .5), WOOD[1], wt) end
-- dark ring where the ferrule meets the wood (both sides)
R.sepLine(c, fm, hm, BRASS[2], gt)
R.sepLine(c, fm, blade, BRASS[2], gt)
do local bx, by = R.specAt(fm, fn, 20) c:put(bx, by, BRASS[6], gt) end

---------------------------------------------------------------- quirk: snail climbing the pot's right flank
do
  -- foot hugs the pot edge, head up, eye stalks up-right
  local foot = HP.mask()
  for y = 36, 46 do local h = bodyHalf(y) local xe = floor(CXp + h - .5) foot:set(xe + 1, y) if y < 44 then foot:set(xe + 2, y) end end
  foot:each(function(x, y) c:put(x, y, (y > 43) and BODY[2] or BODY[3], nt) end)
  local hx = floor(CXp + bodyHalf(36) + .5)
  c:put(hx + 1, 35, BODY[4], nt) c:put(hx + 2, 35, BODY[3], nt)
  c:put(hx + 1, 34, BODY[3], nt) c:put(hx + 1, 33, BODY[1], nt) c:put(hx + 3, 34, BODY[3], nt) c:put(hx + 4, 33, BODY[1], nt)
  local sx, sy = floor(CXp + bodyHalf(41) + 3.5), 41
  local shell = c:ellipse(sx, sy, 3, 3)
  local sn = X.sphere(sx - .5, sy - .5, 3, shell)
  R.shade(c, shell, sn, SNAIL, { amb = 0.1, wrap = 0.3, tok = nt })
  for _, p in ipairs{ { 0, 0 }, { 1, 0 }, { 1, 1 }, { 0, 2 }, { -1, 2 }, { -2, 1 }, { -2, 0 }, { -2, -1 }, { -1, -2 }, { 0, -2 }, { 1, -2 } } do
    c:put(sx + p[1], sy + p[2], SNAIL[2], nt) end
  c:put(sx - 1, sy - 1, SNAIL[6], nt)
  -- glossy slime trail down the pot below the foot
  for _, y in ipairs{ 48, 49, 51 } do local xe = floor(CXp + bodyHalf(y) - .5) R.step(c, bidx, TERRA, xe - 1, y, 2, pt) end
end

-- one cream sparkle on the rim lip
c:put(CXp - 11, 28, R.CREAM, pt)
R.save(c, "ico-trowel-pot")

-- ico-stamp-cart (final, Opus). A little market handcart heaped with produce (the shopping-cart icon).
-- Tray: tapered plank box with a lit top lip, plank grooves, wood grain, paler end grain on the lip ends and iron
-- corner straps with rivets. Two spoked wheels with a dark iron tyre, a bright edge on the lit side, a hub with an
-- axle eye. A slim ash handle rises to the right with a leather-wrapped grip. Cargo: a veined green cabbage, a
-- glossy red apple with a leaf, and a ribbed orange squash; AO where the produce sinks into the tray, contact
-- shadow from the lip, 2-tone ground shadow under the wheels.
-- quirk: a paper price tag dangles from the front corner on a bit of string.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.atan
local c = A.new("ico-stamp-cart")
local WD = { "#40242a", "#64382e", "#8c5436", "#b47848", "#d69c62", "#f0c288" }
local FE = { "#1e1e30", "#2e2e46", "#44455f", "#62637e", "#8c8da4", "#d4d3de" }
local CB = { "#1d4a3c", "#2a6b45", "#3d8a4a", "#5aab4f", "#86c95c", "#bfe57e" }
local AP = { "#5e1a30", "#8e2236", "#c22f3a", "#e8493b", "#ff7a5a", "#ffb08a" }
local SQ = { "#7a3018", "#b0501e", "#d87424", "#f29a30", "#ffc04a", "#ffe08a" }
local LV = { "#2a6b45", "#5aab4f", "#86c95c" }
local wt, ft, pt = { r = { name = "wood" } }, { r = { name = "iron" } }, { r = { name = "produce" } }

c:groundShadow(27, 54, 17, 1.5)
-- handle (behind the tray): slim ash pole with a leather-wrapped grip at the top
local LT = { "#2e1c2a", "#4a2a34", "#6e3e3e", "#945a4a", "#b87c5e" }
local hm, hn, HT, HS = X.cyl(41, 32, 51.5, 14.5, function(t) return 1.6 end)
local hb = {}
hm:each(function(x, y) local k = K(x, y) if abs(HS[k] * 1.6 - floor(HS[k] * 1.6 + .5)) < 0.1 then hb[k] = -1 end end)
local gm = HP.mask() hm:each(function(x, y) if HT[K(x, y)] > 0.62 then gm:set(x, y) end end)
local _, gn2, GT2, GS2 = X.cyl(41, 32, 51.5, 14.5, function(t) return t > 0.62 and 2.1 or 1.6 end)
local gmb = X.cyl(47.6, 21, 51.7, 14, function() return 2.1 end)
gm:add(gmb)
local wood = hm:copy():cut(gm)
X.ao(hb, wood, gm, 1, -1)
A.shade(c, wood, hn, WD, { amb = 0.08, bias = hb, tok = wt })
local _, gn = X.cyl(47.6, 21, 51.7, 14, function() return 2.1 end)
local gidx = A.shade(c, gm, gn, LT, { cuts = { 0.24, 0.44, 0.64, 0.82 }, tok = wt })
gm:each(function(x, y) if (x * 2 + y) % 5 == 0 then A.step(c, gidx, LT, x, y, -1, wt) end end)
c:put(52, 13, WD[6], wt) c:put(51, 13, WD[5], wt)

-- produce (sits in the tray; tray front drawn over the lower part)
local function ball(cx, cy, r, ramp, ang, sq)
  local m, n = A.oval(cx, cy, r, r * (sq or 1), ang or 0, 1)
  local idx = A.shade(c, m, n, ramp, { amb = 0.08, wrap = 0.3, tok = pt })
  return m, n, idx
end
-- squash (back right), ribbed
local sm, sn, sidx = ball(36, 24, 5.4, SQ, 0, 0.85)
sm:each(function(x, y) local dx = x - 36
  for _, rx in ipairs{ -2.5, 0.5, 3.5 } do
    if abs(dx - rx * (1 - abs(y - 24) / 9)) < 0.5 then A.step(c, sidx, SQ, x, y, -1, pt) end end end)
c:put(36, 19, LV[1], pt) c:put(37, 18, LV[1], pt) c:put(37, 19, LV[2], pt) c:put(38, 18, LV[2], pt)
c:put(33, 21, SQ[6], pt)
-- cabbage (centre, largest): outer leaves with veins
local cm, cn, cidx = ball(26, 22, 7.2, CB, 0, 0.92)
cm:each(function(x, y) local k = K(x, y) local dx, dy = x - 26, y - 22
  local a = atan(dy, dx)
  local r = sqrt(dx * dx + dy * dy)
  -- leaf seams sweeping from the core
  local s = (a * 3 / pi + r * 0.12) % 2
  if s < 0.22 and r > 2 then A.step(c, cidx, CB, x, y, -1, pt) end
  -- pale midribs
  if abs(s - 1) < 0.14 and r > 1.5 and r < 6 then A.step(c, cidx, CB, x, y, 1, pt) end
end)
c:put(23, 18, CB[6], pt) c:put(24, 18, A.CREAM, pt)
-- apple (front left)
local am, an, aidx = ball(16, 24.5, 4.6, AP, 0, 1)
A.touch(am, cm):each(function(x, y) if not cm:has(x, y) then end end)
c:put(15, 22, AP[6], pt) c:put(14, 22, A.CREAM, pt) c:put(14, 23, AP[6], pt)
c:put(16, 20, WD[2], pt) c:put(16, 19, WD[2], pt) c:put(17, 18, WD[3], pt)
A.map(c, { ".lL", "lLL", "dl." }, 17, 17, { l = LV[2], L = LV[3], d = LV[1] }, pt)
-- cool bounce on the apple's lower right
c:put(19, 27, "#a04a6a", pt) c:put(18, 28, "#a04a6a", pt)
-- AO between produce
for _, pr in ipairs{ { cm, cidx, CB, sm }, { sm, sidx, SQ, cm } } do end
A.touch(sm:copy():cut(cm), cm):each(function(x, y) A.step(c, sidx, SQ, x, y, -2, pt) end)
A.touch(cm:copy():cut(am), am):each(function(x, y) A.step(c, cidx, CB, x, y, -2, pt) end)

-- tray: tapered box
local tray = c:poly{ { 8, 27 }, { 45, 27 }, { 42, 42 }, { 11, 42 } }
local tn = A.slab(tray, 2.2)
local tb = {}
tray:each(function(x, y) local k = K(x, y)
  if y == 32 or y == 37 then tb[k] = -2 end                                  -- plank grooves
  if (y == 31 or y == 36) then tb[k] = 1 end                                 -- lit lip of the plank below
  local g = (x + sin(y * 0.9) * 1.4) / 5.3
  if abs(g - floor(g + .5)) < 0.06 and y > 28 and y ~= 31 and y ~= 36 then tb[k] = (tb[k] or 0) - 1 end   -- grain
  if y >= 40 then tb[k] = (tb[k] or 0) - 1 end
end)
local tidx = A.shade(c, tray, tn, WD, { amb = 0.1, wrap = 0.3, bias = tb, tok = wt })
-- top lip board (lighter, thicker), with paler end grain at the ends
local lip = c:rect(7, 26, 46, 28)
local ln = A.slab(lip, 1.2)
local lidx = A.shade(c, lip, ln, WD, { amb = 0.2, wrap = 0.35, tok = wt })
for y = 26, 28 do c:put(7, y, WD[6], wt) c:put(46, y, WD[5], wt) end
c:put(7, 28, WD[5], wt) c:put(46, 28, WD[4], wt)
-- contact shadow from the lip onto the tray
for x = 9, 44 do A.step(c, tidx, WD, x, 29, -2, wt) end
-- AO on produce just above the lip
for _, pr in ipairs{ { cm, cidx, CB }, { sm, sidx, SQ }, { am, aidx, AP } } do
  pr[1]:each(function(x, y) if y == 25 then A.step(c, pr[2], pr[3], x, y, -2, pt) end end)
end
-- iron corner straps with rivets
for _, st in ipairs{ { 10, 1 }, { 40, -1 } } do
  local x0 = st[1]
  local sm2 = c:poly{ { x0, 29 }, { x0 + 3, 29 }, { x0 + 3 + st[2] * 0 + (st[2] > 0 and 1 or -1), 41 }, { x0 + (st[2] > 0 and 1 or -1), 41 } }
  sm2:clip(tray)
  local fidx = A.shade(c, sm2, A.slab(sm2, 1), FE, { amb = 0.1, tok = ft })
  for _, ry in ipairs{ 31, 38 } do
    local rx = x0 + 1 + (st[2] > 0 and (ry - 29) // 12 or -((ry - 29) // 12))
    c:put(rx, ry, FE[6], ft) c:put(rx + 1, ry + 1, FE[1], ft)
  end
end
-- wheels: wooden, spoked, iron tyre
local function wheel(cx, cy, R)
  local wm = c:ellipse(cx, cy, R, R)
  local wn = X.sphere(cx, cy, R + 4, wm)
  local inner = c:ellipse(cx, cy, R - 2, R - 2)
  local tyre = wm:copy():cut(inner)
  local yidx = A.shade(c, tyre, wn, FE, { amb = 0.1, tok = ft })
  -- bright edge on the lit top-left of the tyre
  tyre:each(function(x, y) local dx, dy = x - cx, y - cy
    if dx + dy < -R * 1.0 and not wm:has(x - 1, y - 1) then c:put(x, y, FE[6], ft) end end)
  -- wood felloe ring + spokes on a dark gap
  local fel = inner:copy():cut(c:ellipse(cx, cy, R - 3.3, R - 3.3))
  local hollow = c:ellipse(cx, cy, R - 3.3, R - 3.3)
  hollow:each(function(x, y) c:put(x, y, WD[1], wt) end)
  A.shade(c, fel, wn, WD, { amb = 0.15, tok = wt })
  for _, a in ipairs{ 0, pi / 2, pi / 4, -pi / 4 } do
    for t = -R + 3, R - 3, 0.25 do
      local x, y = floor(cx + cos(a) * t + .5), floor(cy + sin(a) * t + .5)
      if hollow:has(x, y) then c:put(x, y, t < 0 and WD[5] or WD[3], wt) end
    end
  end
  local hub = c:ellipse(cx, cy, 1.5, 1.5)
  A.shade(c, hub, X.sphere(cx - .4, cy - .4, 1.6, hub), FE, { amb = 0.2, tok = ft })
  c:put(floor(cx + .5), floor(cy + .5), FE[1], ft)
  return wm
end
local w1 = wheel(17.5, 47, 6.5)
local w2 = wheel(36.5, 47, 6.5)
-- AO on the tray bottom behind the wheel tops
for _, w in ipairs{ w1, w2 } do A.touch(tray:copy():cut(w), w):each(function(x, y) A.step(c, tidx, WD, x, y, -2, wt) end) end
-- quirk: paper price tag on a string from the front-left corner
A.pline(c, { { 7, 29 }, { 6, 31 }, { 6, 33 } }, "#d8c8a0", wt)
A.map(c, {
  ".pp.",
  "pPPp",
  "pPkp",
  "pPPs",
  ".ss.",
}, 4, 34, { p = "#f0dcae", P = "#fff4d6", k = "#c22f3a", s = "#c8b080" }, wt)
A.save(c, "ico-stamp-cart")

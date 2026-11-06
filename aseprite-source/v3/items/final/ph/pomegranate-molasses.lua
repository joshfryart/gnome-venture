-- pomegranate-molasses (D10, Opus-style single pass). A slim carafe: long neck flowing (S-curve) into a rounded body,
-- cork stopper with a twine tie, glass walls with bright left rim + cool right rim, dark ruby-brown syrup inside with a
-- meniscus, a paper label with a cut pomegranate. Per-pixel cylinder light, glass streaks, warm glow through the
-- syrup, AO under cork / twine / label, ground shadow.
-- quirk: a fat drop of molasses has crept out from under the twine, down the neck and onto the label corner.
local NAME = "pomegranate-molasses"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local CX = 32
local GL   = { "#1f3f5c", "#2f6486", "#4f93ac", "#7fc4cf", "#b8ecea", "#effcf6" }
local SY   = { "#1f0a18", "#3d1224", "#651a2e", "#8e2a38", "#b8453f", "#e07a58" }
local SY2  = { "#3d1224", "#651a2e", "#8e2a38", "#b8453f", "#e07a58", "#ffd0b0" }
local CORK = { "#4a2c26", "#6e4533", "#94643f", "#b98756", "#d8ab72", "#efcf9a" }
local TWN  = { "#6c3a1c", "#a8622a", "#d98a2c", "#f5b82e", "#ffd96a", "#fff0a8" }
local PAP  = { "#8a7656", "#b39d72", "#d9c796", "#eddcaf", "#fbefc8", "#fffaea" }
local POM  = { "#561830", "#8d2038", "#c3303e", "#e8493b", "#ff7a58", "#ffb08a" }
local CUT = { 0.2, 0.38, 0.55, 0.7, 0.86 }

local function W(y) -- outer glass half-width at pixel row y
  local yy = y + 0.5
  if yy < 14 then return 0 end
  if yy < 17 then return 5.1 end
  if yy < 27 then return 3.8 end
  if yy < 38.5 then return 3.8 + 7.0 * G.smooth((yy - 27) / 11.5) end
  if yy < 52 then return 10.8 end
  local t = (yy - 52) / 4.7
  if t >= 1 then return 0 end
  return 10.8 * (1 - t ^ 2.8) ^ 0.5
end
local function rowMask(y0, y1, wf)
  local m = HP.mask()
  for y = y0, y1 do local w = wf(y) for x = 0, 63 do if abs(x + 0.5 - CX) <= w then m:set(x, y) end end end
  return m
end

c:groundShadow(32, 57, 13, 2)
local glass = rowMask(14, 56, W)
local LEVEL = 30

-- glass: lit cylinder, then syrup region over it
local gn = G.cylN(glass, W, CX)
local gbias = {}
for x = 28, 35 do gbias[K(x, 20)] = -1 end       -- AO under the twine
for x = 28, 35 do gbias[K(x, 15)] = (gbias[K(x, 15)] or 0) - 0 end
X.tone(c, glass, X.light(gn, { amb = 0.3, wrap = 0.35 }), { GL[2], GL[3], GL[4], GL[5], GL[5], GL[6] }, { cuts = { 0.3, 0.5, 0.65, 0.8, 0.92 }, bias = gbias })
-- empty glass above the syrup: pale core, bright left rim, cool right rim
glass:each(function(x, y)
  local dx = x + 0.5 - CX local de = W(y) - abs(dx)
  if y >= LEVEL or y < 14 then return end
  local col
  if de < 1 then col = dx < 0 and GL[5] or GL[2]
  elseif de < 2 then col = dx < 0 and GL[6] or GL[3]
  else col = dx < -0.6 and GL[5] or (dx > 1.4 and GL[4] or "#d4f2ee") end
  if y >= 14 and y <= 16 then
    if de < 1 then col = dx < 0 and GL[5] or GL[2] else col = dx < 0 and GL[6] or (dx > 2.5 and GL[3] or GL[5]) end
    if y == 14 then col = (de < 1 and dx > 0) and GL[3] or GL[6] end
  end
  c:put(x, y, col)
end)
-- syrup body (inside the walls)
local WALL = 1.9
local sy = HP.mask()
glass:each(function(x, y) if y >= LEVEL and y <= 53 and W(y) - abs(x + 0.5 - CX) >= WALL then sy:set(x, y) end end)
local sn = {}
sy:each(function(x, y)
  local s = max(-0.97, min(0.97, (x + 0.5 - CX) / (W(y) - WALL + 0.5)))
  sn[K(x, y)] = { s, 0, sqrt(1 - s * s) }
end)
local sbias = {}
sy:each(function(x, y)
  local k = K(x, y)
  local de = W(y) - abs(x + 0.5 - CX) - WALL
  sbias[k] = -1
  if y >= 51 then sbias[k] = -2 end
  if y >= 53 then sbias[k] = -3 end
  if x + 0.5 > CX and de < 1 and y > 34 and y < 52 then sbias[k] = (sbias[k] or 0) + 2 end   -- warm glow through the syrup
end)
X.tone(c, sy, X.light(sn, { amb = 0.1, wrap = 0.3 }), SY, { cuts = { 0.22, 0.4, 0.58, 0.75, 0.9 }, bias = sbias })
-- meniscus row + syrup film on the inner walls above it
sy:each(function(x, y) if y == LEVEL then c:put(x, y, x + 0.5 < CX - 1 and SY[6] or SY[5]) end end)
for _, p in ipairs{ { 29, 27, 3 }, { 29, 28, 3 }, { 29, 29, 4 }, { 35, 24, 2 }, { 35, 25, 3 }, { 35, 26, 3 }, { 35, 27, 3 } } do
  if glass:has(p[1], p[2]) then c:put(p[1], p[2], SY[p[3]]) end
end
-- thick glass base: pale refracting row under the syrup
glass:each(function(x, y)
  local dx = x + 0.5 - CX
  if y == 54 then c:put(x, y, dx < -2 and GL[5] or (dx > 5 and GL[3] or GL[4]))
  elseif y >= 55 then c:put(x, y, dx < -3 and GL[4] or (dx > 3 and GL[2] or GL[3])) end
end)
-- glass streaks
for yy = 31, 36 do local x = floor(CX - W(yy) + 2.4) c:px(x, yy, GL[6]) end
for xx = 24, 27 do c:px(xx, 54, GL[6]) end
c:px(21, 46, GL[6]) c:px(21, 47, GL[6]) c:px(21, 52, GL[6]) c:px(21, 53, GL[6])

-- cork
local function CW(y) local w = 4.3 - 0.6 * (y + 0.5 - 7) / 7 if y == 7 then w = w - 1.0 end return w end
local cork = rowMask(7, 13, CW)
local cn = G.cylN(cork, CW, CX)
cork:each(function(x, y) if y <= 8 then local k = K(x, y) local n = cn[k] cn[k] = { G.nrm(n[1] * 0.8, y == 7 and -0.9 or -0.35, n[3] * 0.9) } end end)
local ci = X.tone(c, cork, X.light(cn, { amb = 0.12, wrap = 0.3 }), CORK, { cuts = CUT })
cork:each(function(x, y)
  local h = X.hash(x, y, 3)
  local i = ci[K(x, y)]
  if h < 0.17 then c:px(x, y, CORK[max(1, i - 2)]) if h < 0.07 and cork:has(x, y + 1) then c:px(x, y + 1, CORK[max(1, i - 1)]) end
  elseif h > 0.9 then c:px(x, y, CORK[min(6, i + 1)]) end
  if y == 13 then c:px(x, y, CORK[1]) end
end)
for x = 30, 32 do c:px(x, 7, CORK[6]) end
-- twine tie (diagonal twist) around the neck
local tw = HP.mask()
for y = 17, 19 do for x = 0, 63 do if abs(x + 0.5 - CX) <= 4.7 then tw:set(x, y) end end end
local tn = G.cylN(tw, function() return 4.7 end, CX)
local ti = X.tone(c, tw, X.light(tn, { amb = 0.15, wrap = 0.3 }), TWN, { cuts = CUT })
tw:each(function(x, y)
  local ph = (x + y * 2) % 4
  local i = ti[K(x, y)]
  if ph == 0 then c:px(x, y, TWN[min(6, i + 1)]) elseif ph == 2 then c:px(x, y, TWN[max(1, i - 1)]) end
  if y == 19 then c:px(x, y, TWN[max(1, (ti[K(x, y)] or 3) - 1)]) end
end)
-- knot + two tails on the left
for _, p in ipairs{ { 25, 18, 4 }, { 26, 18, 5 }, { 25, 19, 2 }, { 26, 19, 3 }, { 25, 20, 3 }, { 25, 21, 2 }, { 24, 22, 2 }, { 24, 23, 5 },
  { 26, 20, 3 }, { 26, 21, 2 }, { 27, 22, 2 }, { 27, 23, 4 } } do c:px(p[1], p[2], TWN[p[3]]) end

-- label wrapped on the body
local lab = HP.mask()
for y = 36, 52 do for x = 0, 63 do
  local dx = x + 0.5 - CX
  if abs(dx) <= 7.2 and W(y) >= 10 then
    local j = floor(1.4 * (dx / 7.5) ^ 2 + 0.5)
    if y >= 37 + j and y <= 51 + j - 0 and y <= 51 then lab:set(x, y) end
  end
end end
local lw = function() return 10.8 end
local ln = G.cylN(lab, lw, CX)
local li = X.tone(c, lab, X.light(ln, { amb = 0.5, wrap = 0.4 }), PAP, { cuts = { 0.3, 0.46, 0.6, 0.74, 0.88 } })
lab:each(function(x, y)
  local dx = x + 0.5 - CX
  local top = not lab:has(x, y - 1) local bot = not lab:has(x, y + 1)
  if top then c:px(x, y, dx < 0 and PAP[3] or PAP[2]) end
  if bot then c:px(x, y, PAP[2]) end
  if abs(abs(dx) - 6.4) < 0.6 then c:px(x, y, dx < 0 and PAP[4] or PAP[2]) end
  -- fine paper grain
  if X.hash(x, y, 9) > 0.93 then c:px(x, y, PAP[max(1, (li[K(x, y)] or 4) - 1)]) end
end)
-- printed bands
for x = 0, 63 do
  local dx = x + 0.5 - CX
  if abs(dx) <= 6.4 then
    for y = 38, 51 do if lab:has(x, y) and lab:has(x, y - 1) and lab:has(x, y + 1) and ((y == 39) or (y == 50 and false)) then c:px(x, y, POM[2]) end end
  end
end
-- cut pomegranate emblem
local ecx, ecy = 31.6, 43.6
for y = 38, 49 do for x = 24, 40 do
  local dx, dy = x + 0.5 - ecx, y + 0.5 - ecy
  local d = sqrt(dx * dx + dy * dy)
  if d <= 4.1 and lab:has(x, y) then
    local col
    if d > 3.2 then col = (dx + dy < 0) and POM[4] or POM[2]
    elseif d > 2.55 then col = "#ffe9c0"
    else col = ((x + y) % 2 == 0) and POM[5] or POM[3]
      if (x == 31 and y % 2 == 0) or (y == 43 and x % 2 == 1 and false) then col = POM[2] end
    end
    c:px(x, y, col)
  end
end end
c:px(30, 42, "#ffd8c0") c:px(31, 41, "#ffd8c0") c:px(32, 44, POM[2]) c:px(30, 44, POM[2])
c:px(35, 40, "#3a8a48") c:px(36, 39, "#58aa52") c:px(36, 40, "#24544a")
-- caption dashes
for _, r in ipairs{ { 26, 29 }, { 31, 34 }, { 36, 37 } } do for x = r[1], r[2] do if lab:has(x, 48) then c:px(x, 48, POM[1]) end end end
for x = 28, 36 do if lab:has(x, 49) and x % 2 == 0 then c:px(x, 49, PAP[2]) end end
-- shadow cast by the label's lower edge on the syrup
for x = 0, 63 do if lab:has(x, 51) and not lab:has(x, 52) and sy:has(x, 52) then c:px(x, 52, SY[1]) end end

-- the drip (quirk): from under the twine, down the neck, onto the label corner
local dm, dn, DT = G.tube({ { 34.6, 20.0 }, { 34.6, 27.5 }, { 37.2, 31 }, { 38.6, 40.5 } }, function(t) return 1.0 + 0.15 * t end)
local bulbM = c:ellipse(38.6, 42.6, 1.6, 2.3)
local bn = X.sphere(38.2, 42.4, 2.2, bulbM)
local all = dm:copy():add(bulbM)
local nn = {}
dm:each(function(x, y) nn[K(x, y)] = dn[K(x, y)] end)
bulbM:each(function(x, y) nn[K(x, y)] = bn[K(x, y)] end)
-- contact shadow of the drop on the label
bulbM:shift(1, 1):each(function(x, y) if lab:has(x, y) and not all:has(x, y) then c:px(x, y, PAP[1]) end end)
X.tone(c, all, X.light(nn, { amb = 0.1, wrap = 0.3 }), SY2, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 } })
c:px(34, 24, SY2[6]) c:px(34, 25, SY2[6]) c:px(38, 41, SY2[6]) c:px(37, 40, SY2[5])
bulbM:edge():each(function(x, y) if x > 38 and y > 43 then c:px(x, y, SY2[2]) end end)
G.save2(c, NAME)

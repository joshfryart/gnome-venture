-- pickled-beets (sonnet-medium test)
local LIB = "/home/user/gnome-venture/aseprite-source/v3/lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local OUT = app.params.out or "./"
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x + 0.5 - cx) / rx) ^ 2 + ((y + 0.5 - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
local function tn(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return n, v
end
local function tnN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return v
end
local function fin(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = OUT .. name .. ".aseprite", png = OUT .. name .. ".png", scale = 1 }
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pickled-beets" }
local GL = { "#4a5a80", "#7a8cb0", "#a8bcd4", "#cfe0e8", "#e8f4f0", "#f8fcf4" }
local LQ = { "#3a1038", "#5e1a4c", "#8a2560", "#b53c78", "#d86a96", "#f0a0b8" }
local BT = { "#2a0a2c", "#4a1240", "#6e1a50", "#962a62", "#bc4278", "#dc709a" }
local LID = { "#5a4026", "#8a6030", "#b88a3c", "#dcb050", "#f0d070", "#fff0a8" }
local DILL = { "#255644", "#32764b", "#4b9650", "#70b45a", "#a4d070" }
c:groundShadow(32, 56, 17, 2)
local jar = c:rrect(15, 23, 48, 56, 6)
jar:add(c:rect(19, 19, 44, 24))
-- glass: cylinder lit
local n = {}
jar:each(function(x, y)
  local nx = max(-0.95, min(0.95, (x - 31.5) / 17)) 
  n[K(x, y)] = { nx, 0, sqrt(1 - nx * nx) }
end)
tnN(c, jar, n, GL, { amb = 0.35, wrap = 0.1 })
-- liquid
local inner = c:rrect(17, 25, 46, 54, 5):shrink(0)
local liq = HP.mask()
inner:each(function(x, y) if y >= 29 then liq:set(x, y) end end)
local ln = {}
liq:each(function(x, y) local nx = max(-0.95, min(0.95, (x - 31.5) / 15)) ln[K(x, y)] = { nx, 0, sqrt(1 - nx * nx) } end)
tnN(c, liq, ln, LQ, { amb = 0.3, wrap = 0.25 })
for x = 18, 45 do if liq:has(x, 29) then c:px(x, 29, LQ[6]) end end
-- beets: three cut discs with growth rings
local function disc(cx, cy, rx, ry, seed)
  local m = ell(cx, cy, rx, ry):clip(liq)
  local nn = X.pillow(m, 3)
  local vv = X.light(nn, { amb = 0.15, wrap = 0.3 })
  local bias = {}
  m:each(function(x, y)
    local d = sqrt(((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2)
    if d < 0.92 and floor(d * 4.6 + seed) % 2 == 0 then bias[K(x, y)] = 1 end
    if d >= 0.8 then bias[K(x, y)] = -1 end
  end)
  X.tone(c, m, vv, BT, { cuts = { 0.2, 0.34, 0.5, 0.66, 0.82 }, bias = bias })
  return m
end
disc(26, 38, 7.5, 6, 0.3)
disc(38, 43, 7.5, 6.5, 0.8)
disc(27, 49, 6.5, 4.5, 0.1)
disc(39, 33, 5, 3.5, 0.5)
-- dill sprig floating (quirk)
for _, p in ipairs{ {20,31},{20,33},{21,35},{21,37},{21,39},{21,41},{20,43},{20,45} } do c:px(p[1], p[2], DILL[2]) end
for _, p in ipairs{ {19,32},{22,34},{19,36},{22,38},{22,42},{19,40},{19,44},{21,44},{20,30},{22,40} } do c:px(p[1], p[2], DILL[4]) end
c:px(20, 31, DILL[5])
-- bubbles
for _, p in ipairs{ {43,32},{44,36},{42,47},{33,31} } do c:px(p[1], p[2], LQ[6]) end
-- glass rim, highlight strip, dark lower right
for y = 25, 52 do c:px(18, y, GL[6]) if y % 7 ~= 0 then c:px(19, y, GL[5]) end end
c:px(18, 25, GL[5])
for y = 30, 53 do c:px(46, y, "#5a2a70") end
for x = 24, 42 do c:px(x, 54, "#4a1a58") end
c:px(45, 31, GL[4]) c:px(45, 32, GL[4])
-- neck threads
for x = 20, 43 do c:px(x, 23, GL[3]) c:px(x, 21, x < 30 and GL[5] or GL[3]) end
-- lid
local lid = c:rrect(18, 11, 45, 19, 2)
local lnn = {}
lid:each(function(x, y) local nx = max(-0.95, min(0.95, (x - 31.5) / 14)) lnn[K(x, y)] = { nx, 0.1, sqrt(1 - nx * nx) } end)
local lb = {}
lid:each(function(x, y) if x % 3 == 0 then lb[K(x, y)] = -1 end end)
tnN(c, lid, lnn, LID, { bias = lb })
for x = 19, 44 do c:px(x, 12, LID[5]) c:px(x, 19, LID[1]) end
c:px(21, 13, LID[6]) c:px(22, 13, LID[6])
fin(c, "pickled-beets")

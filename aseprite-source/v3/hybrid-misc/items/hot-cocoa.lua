-- hot-cocoa (sonnet-medium test)
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "hot-cocoa" }
local RD = { "#4a1c34", "#7a2640", "#a83448", "#cc4850", "#e8685c", "#f8987c" }
local CR = { "#8a7088", "#b8a0a8", "#dcc8c0", "#f2e4d6", "#fff4e4", "#fffaf0" }
local CO = { "#2a1410", "#4a281c", "#6e3c24", "#8e5430", "#b07440", "#d09858" }
local MM = { "#8a7488", "#b8a4a8", "#dccac4", "#f4e6d8", "#fff6e8", "#fffaf0" }
c:groundShadow(31, 56, 20, 2.5)
-- handle
local hnd = ell(45.5, 42, 9, 8.5):cut(ell(45.5, 42, 4.5, 4.2))
local mug = c:rrect(15, 29, 45, 55, 7)
hnd:cut(mug)
local hb = {}
hnd:each(function(x, y) if x + y > 90 then hb[K(x, y)] = -1 end end)
tn(c, hnd, RD, 2.5, { bias = hb })
-- body
local body = mug:copy():add(ell(30, 29, 15.5, 5))
local n = {}
body:each(function(x, y)
  local nx = max(-0.95, min(0.95, (x + 0.5 - 30) / 15.5))
  n[K(x, y)] = { nx, 0.05, sqrt(1 - nx * nx) }
end)
local bb = {}
body:each(function(x, y) if y > 50 then bb[K(x, y)] = -1 end end)
local v = tnN(c, body, n, RD, { amb = 0.08, wrap = 0.25, bias = bb })
-- cream band with scallops and dots
local band = HP.mask()
body:each(function(x, y)
  local lo = 41 + ((x % 4 == 1 or x % 4 == 2) and 1 or 0)
  if y >= 38 and y <= lo + 3 then band:set(x, y) end
end)
band:clip(mug)
tnN(c, band, n, CR, { amb = 0.2, wrap = 0.3 })
band:each(function(x, y) if (x + y * 2) % 5 == 0 and y > 38 and y < 43 then c:px(x, y, RD[v[K(x, y)] > 0.5 and 4 or 3]) end end)
-- ceramic spec and rim
for y = 33, 36 do c:px(20, y, RD[6]) end
c:px(21, 49, RD[6])
-- opening
local rimOuter = ell(30, 29, 15.5, 5)
local open = ell(30, 29, 13.4, 3.6)
local rimM = rimOuter:copy():cut(open)
local rn = {}
rimM:each(function(x, y) rn[K(x, y)] = { max(-0.9, min(0.9, (x - 30) / 16)), -0.3, 0.7 } end)
tnN(c, rimM, rn, RD, { amb = 0.35, wrap = 0.3 })
rimM:each(function(x, y) if x < 26 and y < 28 then c:px(x, y, RD[6]) end end)
local on = X.pillow(open, 3)
local ov = X.light(on, { amb = 0.2, wrap = 0.3 })
local ob = {}
open:each(function(x, y) if y > 30 then ob[K(x, y)] = -1 end end)
X.tone(c, open, ov, CO, { cuts = CUTS, bias = ob })
for x = 21, 26 do c:px(x, 30, CO[5]) end
-- marshmallows
local function marsh(x0, y0, x1, y1, ramp, tilt)
  local m = c:rrect(x0, y0, x1, y1, 2)
  local nn = X.pillow(m, 3)
  local vv = X.light(nn, { amb = 0.12, wrap = 0.3 })
  X.tone(c, m, vv, ramp, { cuts = CUTS })
  for x = x0 + 1, x1 - 1 do c:px(x, y1, ramp[1]) end
  c:px(x0 + 1, y0 + 1, ramp[6])
  return m
end
marsh(21, 24, 27, 30, MM)
marsh(29, 22, 35, 28, MM)
local m3 = marsh(36, 25, 41, 30, MM)
-- quirk: dribble of cocoa down the front
for y = 33, 38 do c:px(37, y, CO[3]) c:px(38, y, CO[2]) end
c:px(37, 39, CO[3]) c:px(37, 33, CO[4]) c:px(38, 33, CO[3])
c:px(37, 40, CO[2])
-- steam
local SM = { "#b8aed0", "#d8d0e6", "#f0eaf6" }
for i = 0, 13 do
  local y = 19 - i
  c:px(floor(26 + 2.2 * sin(i * 0.55)), y, SM[2])
  c:px(floor(26 + 2.2 * sin(i * 0.55)) + 1, y, SM[3])
  if i % 3 == 0 then c:px(floor(26 + 2.2 * sin(i * 0.55)) - 1, y, SM[1]) end
end
for i = 0, 10 do
  local y = 21 - i
  c:px(floor(37 + 2 * sin(i * 0.6 + 2)), y, SM[2])
  c:px(floor(37 + 2 * sin(i * 0.6 + 2)) + 1, y, SM[3])
end
fin(c, "hot-cocoa")

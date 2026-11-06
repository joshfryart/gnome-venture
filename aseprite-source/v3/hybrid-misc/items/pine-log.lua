-- pine-log (sonnet-medium test)
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
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pine-log" }
local BK = { "#2a1c22", "#4a2e2c", "#6e4430", "#92603a", "#b8844c", "#d8a860" }
local WDF = { "#7a5030", "#a8743c", "#cc9a54", "#e8bc70", "#f6d890", "#fff0b8" }
local NEED = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(34, 50, 22, 3)
local CY, RY = 37, 12
local bark = c:rect(20, CY - RY, 52, CY + RY - 1)
bark:add(ell(52, CY, 4, RY):clip(c:rect(52, 0, 60, 63)))
local n = {}
bark:each(function(x, y)
  local ny = max(-0.95, min(0.95, (y + 0.5 - CY) / RY))
  n[K(x, y)] = { 0.15, ny, sqrt(1 - ny * ny) }
end)
local bias = {}
bark:each(function(x, y)
  local k = K(x, y)
  if (y % 4 == 1 or y % 4 == 3 and X.hash(x, y, 3) > 0.6) and X.hash(floor(x / 5), y, 3) > 0.4 then bias[k] = -1 end
  if x % 6 == floor(y / 4) % 6 and y % 4 == 2 then bias[k] = -1 end
  if X.hash(floor(x / 3), floor(y / 2), 8) > 0.9 then bias[k] = 1 end
end)
local v = tnN(c, bark, n, BK, { amb = 0.1, wrap = 0.2, bias = bias })
-- twig stub with needles (quirk)
local sm, sn2, T, S = X.cyl(40, 26, 42, 19, function(t) return 1.8 - t * 0.5 end)
tnN(c, sm, sn2, BK, {})
local nd = { {42,19,37,14},{42,19,42,12},{42,19,47,14},{42,19,39,17},{42,19,46,18} }
for _, l in ipairs(nd) do c:line({{l[1], l[2]}, {l[3], l[4]}}, 1):each(function(x, y) c:px(x, y, NEED[3 + ((x + y) % 2)]) end) end
c:px(37, 14, NEED[6]) c:px(42, 12, NEED[6]) c:px(47, 14, NEED[5])
-- cut face with rings
local face = ell(20, CY, 6.4, RY)
local fn = X.pillow(face, 5)
local fv = X.light(fn, { amb = 0.35, wrap = 0.3 })
local fb = {}
face:each(function(x, y)
  local d = sqrt(((x + 0.5 - 19.5) / 6.2) ^ 2 + ((y + 0.5 - 38) / 11.6) ^ 2)
  local k = K(x, y)
  if d > 0.9 then fb[k] = -3
  elseif floor(d * 8.5) % 2 == 0 then fb[k] = -1 end
  if d < 0.08 then fb[k] = -2 end
end)
X.tone(c, face, fv, WDF, { cuts = { 0.2, 0.35, 0.5, 0.65, 0.8 }, bias = fb })
-- radial check crack
for i = 1, 6 do c:px(19 + i - 0, 38 - floor(i * 0.3), WDF[1]) end
-- bark rim shade on face right side
face:each(function(x, y) if not face:has(x, y + 1) then c:px(x, y, WDF[1]) end end)
-- resin bead + drip
c:px(17, 27, "#e8a030") c:px(18, 27, "#f8cc50") c:px(17, 28, "#b86a20") c:px(18, 28, "#e8a030") c:px(17, 29, "#b86a20")
c:px(18, 27, "#fff0a0")
-- AO where face meets bark
for y = CY - RY + 2, CY + RY - 3 do c:px(26, y, BK[2]) end
fin(c, "pine-log")

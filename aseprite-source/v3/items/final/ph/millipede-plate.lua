-- millipede-plate (lean E2_03)
local NAME = "millipede-plate"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local T = { r = { name = "d" } }
local function body(m, ramp, R, name, amb)
  local n = X.pillow(m, R)
  local idx = X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = { .22, .4, .56, .72, .86 }, tok = { r = { name = name } } })
  return n, idx
end
local function draw(lm, hex, within) lm:each(function(x, y) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end) end
local function dot(x, y, hex, within) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end
c:groundShadow(32, 56, 22, 2)
local LEG = { "#5a3a22", "#8a6238", "#bc8c52", "#e2b878" }
-- capsule rasteriser for legs
local function cap(x0, y0, x1, y1, w0, w1)
  local m = HP.mask()
  local dx, dy = x1 - x0, y1 - y0
  local L2 = dx * dx + dy * dy
  for y = 0, 63 do for x = 0, 63 do
    local t = max(0, min(1, ((x - x0) * dx + (y - y0) * dy) / L2))
    local px, py = x0 + dx * t, y0 + dy * t
    local w = w0 + (w1 - w0) * t
    if (x - px) ^ 2 + (y - py) ^ 2 <= w * w then m:set(x, y) end
  end end
  return m
end
-- legs: 5 pairs fanning from under the plate
for i = 0, 4 do
  local ox = 14 + i * 9
  local lg = cap(ox, 42, ox + (i - 2) * 1.5, 56, 1.8, 1.0)
  body(lg, LEG, 2, "leg" .. i, 0.15)
  dot(ox + floor((i - 2) * 1.5), 56, "#3a2a1c")
end
local m = HP.mask()
for y = 8, 46 do for x = 8, 56 do
  local dx, dy = (x - 32) / 24, (y - 44) / 36
  if dx * dx + dy * dy <= 1 and y <= 46 then m:set(x, y) end
end end
local R = { "#2e1a1c", "#5c2e28", "#8a4428", "#b4602e", "#da8c44", "#f4c06c" }
body(m, R, 22, "plate")
-- segment flange band along the bottom edge
m:each(function(x, y) if y >= 38 then c:put(x, y, (y >= 43) and R[1] or (x < 30 and R[3] or R[2]), T) end end)
for x = 12, 52 do dot(x, 38, R[5], m) end
-- dorsal groove + ribs
for y = 12, 37 do dot(32, y, R[2], m) dot(31, y, R[5], m) end
for k = 0, 3 do
  local y = 14 + k * 6
  for x = 14, 50 do local sag = ((x - 32) / 18) ^ 2 * 5 if abs(x - 32) > 2 then dot(x, floor(y + sag + 8 - k * 0), R[2], m) end end
end
-- quirk: pair of orange warning spots
for _, sx in ipairs{ 22, 42 } do
  dot(sx, 41, "#ff9a30", m) dot(sx + 1, 41, "#ff9a30", m) dot(sx, 40, "#ffd060", m)
end
dot(22, 22, "#fff0c0", m) dot(23, 22, "#fff0c0", m) dot(22, 23, "#fff0c0", m)
G.save(c, NAME)

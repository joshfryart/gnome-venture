-- nav-passport (lean E2_03)
local NAME = "nav-passport"
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
c:groundShadow(32, 58, 16, 2)
local NV = { "#0e1836", "#182a5a", "#26448a", "#3a62b2", "#5c8ad2", "#9cbcf0" }
local GD = { "#6a4a14", "#a06e1c", "#d09a2a", "#eebb44", "#f8d878", "#fff2b4" }
-- page block peeking at right
local pg = c:rect(16, 7, 48, 55)
body(pg, { "#9a8a88", "#c8baa8", "#e6dcc4", "#f4ecd6", "#faf4e2", "#fffaec" }, 40, "pages", 0.2)
for y = 9, 53, 3 do dot(47, y, "#bdae98", pg) end
local cv = c:rrect(14, 5, 44, 54, 2)
body(cv, NV, 36, "cover", 0.12)
-- spine band on left + embossed border
for y = 6, 53 do dot(15, y, NV[1], cv) dot(16, y, NV[2], cv) dot(17, y, NV[5], cv) end
for x = 20, 40 do dot(x, 9, GD[2], cv) dot(x, 50, GD[2], cv) end
for y = 9, 50 do dot(20, y, GD[2], cv) dot(40, y, GD[2], cv) end
-- gold compass emblem
local cx, cy = 30, 24
local ring = c:ellipse(cx, cy, 9, 9)
body(ring, GD, 9, "ring", 0.1)
local inner = c:ellipse(cx, cy, 6, 6)
body(inner, NV, 6, "disc", 0.12)
-- four-point star
for i = -7, 7 do
  local w = max(0, 2 - floor(abs(i) / 3.2))
  for j = -w, w do dot(cx + j, cy + i, GD[5]) dot(cx + i, cy + j, GD[4]) end
end
dot(cx, cy, GD[6]) dot(cx - 1, cy - 1, GD[6])
-- title bars and small lines
for x = 22, 38 do dot(x, 38, GD[4]) dot(x, 39, GD[2]) end
for x = 25, 35 do dot(x, 43, GD[3]) end
for x = 27, 33 do dot(x, 47, GD[2]) end
-- quirk: red ribbon bookmark trailing from the bottom
local rb = c:rect(36, 54, 39, 59)
body(rb, { "#5a0e1e", "#8c1a2e", "#c02a3c", "#dc4a52", "#f07872", "#ffb0a0" }, 3, "ribbon", 0.1)
dot(37, 59, "#2b1c26") dot(37, 58, "#2b1c26")
G.save(c, NAME)

-- loach-scale (lean E2_03)
local NAME = "loach-scale"
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
c:groundShadow(32, 54, 14, 2)
local cx, cy = 32, 32
local m = HP.mask()
for y = 8, 56 do for x = 8, 56 do
  local dx, dy = (x - cx) / 22, (y - cy) / 18
  local ang = math.atan(dy, dx)
  local r = sqrt(dx * dx + dy * dy)
  local scal = 1 + (ang < 0 and 0.05 * sin(ang * 14) or 0)   -- scalloped top rim
  if r <= scal and not (dy > 0.75 and abs(dx) < 0.25) then m:set(x, y) end
end end
-- flat narrow base notch (the embedded end)
local R = { "#34507a", "#5d79a4", "#8aa4c8", "#b2c6e0", "#d4e2f0", "#eef6fc" }
body(m, R, 18, "lscale")
-- growth rings: arcs around the focus lower in the scale
local fx, fy = 32, 42
m:each(function(x, y)
  local d = sqrt(((x - fx) / 1.25) ^ 2 + (y - fy) ^ 2)
  local k = d % 5
  if k < 1.0 and d > 4 then c:put(x, y, (x < fx) and R[5] or R[2], T) end
end)
-- radial grooves from the focus to the rim
for i = -3, 3 do
  local a = -pi / 2 + i * 0.38
  local pts = { { fx, fy - 4 }, { fx + cos(a) * 24, fy + sin(a) * 24 } }
  draw(c:line(pts, 1), i < 0 and R[6] or R[2], m)
end
-- iridescent pink-gold patch on the lower right
m:each(function(x, y) if x > 38 and y > 40 and (x - 38) + (y - 40) > 6 and X.hash(x, y, 4) > 0.15 then c:put(x, y, (x + y) % 2 == 0 and "#f0c8a8" or "#e8a8b8", T) end end)
-- sparkle + water drop quirk
dot(22, 17, "#fff6e0", m) dot(23, 17, "#fff6e0", m) dot(22, 18, "#fff6e0", m)
local drop = c:ellipse(46, 18, 2, 3)
body(drop, { "#2a6a8a", "#3f90b0", "#68b8d0", "#9adcea", "#c8f0f6", "#f0ffff" }, 2.5, "drop")
dot(45, 17, "#fff6e0")
G.save(c, NAME)

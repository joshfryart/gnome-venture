-- flowers/daisy : top-down daisy, 12 cream petals around a gold centre
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cx, cy = 31.5, 31.5
local RC, RY, RX = 12.5, 10.5, 4.3 -- petal centre radius, half length, half width
local N = 12

local petals = c:mask()
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x - cx, y - cy
  local ang = math.atan(dy, dx)
  local best = math.floor(ang / (2*math.pi/N) + 0.5) -- nearest petal index
  local a = best * 2*math.pi/N
  local al = dx*math.cos(a) + dy*math.sin(a) - RC
  local ac = -dx*math.sin(a) + dy*math.cos(a)
  local inside = (al/RY)^2 + (ac/RX)^2 <= 1
  -- 1 px notch along the bisector between neighbours
  local b = a + math.pi/N
  local b2 = a - math.pi/N
  local d1 = math.abs(-dx*math.sin(b) + dy*math.cos(b))
  local d2 = math.abs(-dx*math.sin(b2) + dy*math.cos(b2))
  if inside and math.min(d1, d2) >= 0.55 then petals:set(x, y) end
end end

c:build{
  { "petals", petals, "cream", { light = c:ellipse(cx, cy, 23), gloss = false } },
  { "centre", c:ellipse(cx, cy, 7.5), "gold", { contour = "#b8661a", gloss = { 28, 28 } } },
}
-- creases and tip ticks along each petal axis
local R = GV.ramp("cream")
for i = 0, N-1 do
  local a = i * 2*math.pi/N
  for r = 11, 15 do c:px(math.floor(cx + r*math.cos(a) + 0.5), math.floor(cy + r*math.sin(a) + 0.5), R.shade) end
  c:px(math.floor(cx + 19.5*math.cos(a) + 0.5), math.floor(cy + 19.5*math.sin(a) + 0.5), R.gloss)
end
-- seed dots
for _, p in ipairs({ {34, 34}, {30, 35}, {35, 30}, {31, 32} }) do c:px(p[1], p[2], "#8a4a1c") end

local t = c:save(O .. "aseprite/flowers/daisy.aseprite", O .. "png/flowers/daisy.png")
print(GV.report(t))

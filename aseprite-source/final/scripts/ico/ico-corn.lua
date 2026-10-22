local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function tilt(cx, cy, rx, ry, deg)
  local m = c:mask(); local a = math.rad(deg); local ca, sa = math.cos(a), math.sin(a)
  for y = 0, 63 do for x = 0, 63 do
    local dx, dy = x - cx, y - cy
    local u = dx * ca + dy * sa; local v = -dx * sa + dy * ca
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local L = GV.ramp("#f5cf6a"); local R = GV.ramp("#f0b42a")
local parts = { { "stalk", c:rrect(30, 40, 34, 57, 1), GV.ramp("#2f5a2a"), { gloss = false } } }
local rows = { 42, 35, 28, 21 }
for i, y in ipairs(rows) do
  local s = (i == 1) and 0.85 or 1
  parts[#parts + 1] = { "l" .. i, tilt(27, y, 5 * s, 5.5 * s, 15), L, { gloss = false } }
  parts[#parts + 1] = { "r" .. i, tilt(37, y, 5 * s, 5.5 * s, -15), R, { gloss = false } }
end
parts[#parts + 1] = { "top", c:ellipse(31.5, 14, 4.5, 7), L, { gloss = { 30, 10 } } }
local leaf = c:poly({ {34, 57}, {27, 52}, {21, 45}, {17, 37}, {18, 33}, {23, 38}, {29, 44}, {35, 48}, {38, 57} })
parts[#parts + 1] = { "husk", leaf, GV.ramp("#6a9a3a"), { gloss = { 20, 38 } } }
c:build(parts)
-- glints on light kernels
for _, y in ipairs({ 32, 25, 18 }) do c:px(25, y, "#fff1c8") end
c:ground(32, 58, 9, 1.5)
local t = c:save(O .. "aseprite/ico/ico-corn.aseprite", O .. "png/ico/ico-corn.png")
print(GV.report(t))

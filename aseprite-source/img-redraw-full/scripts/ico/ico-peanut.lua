local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local shell = GV.ramp("#d9b27a")
local m = c:ellipse(38, 21, 9, 9.5)
m:add(c:ellipse(26, 40, 11, 11.5))
m:add(c:poly({ {42, 24}, {34, 18}, {22, 37}, {30, 43} }))
c:build{ { "shell", m, shell } }
-- waist groove across the pinch
c:line({ {28, 28}, {35, 32} }, 2):clip(m)
c:fill(c:line({ {29, 28}, {35, 32} }, 2):clip(m), "#a8582f")
-- irregular shell pits (plus-shaped 3x3)
local dot = { ".x.", "xxx", ".x." }
for _, d in ipairs({ { 40, 14 }, { 37, 23 }, { 19, 38 }, { 27, 45 }, { 31, 37 } }) do
  c:paint(dot, d[1], d[2], { x = "#b98a52" })
end
local t = c:save(O .. "aseprite/ico/ico-peanut.aseprite", O .. "png/ico/ico-peanut.png")
print(GV.report(t))

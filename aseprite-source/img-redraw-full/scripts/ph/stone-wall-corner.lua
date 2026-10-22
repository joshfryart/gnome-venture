local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "rb" }
local L = GV.ramp("#d6c9b6")
local Dk = GV.ramp("#968f96")
local list = {}
-- right arm: two staggered courses of stones
local i = 0
for x = 36, 63, 8 do
  i = i + 1
  table.insert(list, { "r1_" .. i, c:rrect(x, 25, x + 8, 32, 2), (i % 2 == 0) and L or Dk })
end
i = 0
for x = 32, 63, 8 do
  i = i + 1
  table.insert(list, { "r2_" .. i, c:rrect(x, 32, x + 8, 39, 2), (i % 2 == 1) and L or Dk })
end
-- down arm: two staggered columns
i = 0
for y = 36, 63, 8 do
  i = i + 1
  table.insert(list, { "d1_" .. i, c:rrect(25, y, 32, y + 8, 2), (i % 2 == 0) and L or Dk })
end
i = 0
for y = 32, 63, 8 do
  i = i + 1
  table.insert(list, { "d2_" .. i, c:rrect(32, y, 39, y + 8, 2), (i % 2 == 1) and L or Dk })
end
table.insert(list, { "block", c:rrect(23, 23, 41, 41, 5), "#6a6070" })
table.insert(list, { "cap", c:ellipse(32, 32, 6, 6), Dk })
c:build(list)
local t = c:save(O .. "aseprite/ph/stone-wall-corner.aseprite", O .. "png/ph/stone-wall-corner.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- smooth teardrop: rounded bottom plus a curved taper to the point
local drop = c:ellipse(32, 42, 18, 14)
drop:add(c:poly({ {32, 9}, {34, 13}, {38, 20}, {44, 28}, {48, 34}, {16, 34}, {20, 28}, {26, 20}, {30, 13} }))
drop:add(c:poly({ {31, 9}, {33, 9}, {34, 13}, {30, 13} }))
local p = c:build{
  { "drop", drop, GV.ramp("#b0bc66"), { gloss = false } },
  { "pool", c:ellipse(32, 47, 10, 3), GV.ramp("#58a03e"), { rim = false, gloss = false } },
}
-- fold line across the shoulder
c:fill(c:line({ {19, 31}, {25, 28}, {32, 27} }, 1):clip(p.drop.m), "#17361c")
c:fill(c:line({ {32, 27}, {39, 27}, {45, 29} }, 1):clip(p.drop.m), "#17361c")
-- big enamel gloss comma, upper left
local g = GV.ramp("#b0bc66")
c:paint({
  "..gg",
  ".ggg",
  "ggg.",
  "gg..",
  "gg..",
  "g...",
}, 22, 15, { g = g.gloss })
c:px(23, 23, g.gloss); c:px(23, 25, g.dot)
local t = c:save(O .. "aseprite/ph/rubber-sap.aseprite", O .. "png/ph/rubber-sap.png")
print(GV.report(t))

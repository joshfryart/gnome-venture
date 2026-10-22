-- ico/ico-gnome-gardener
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

c:build{
  { "tunic",  c:poly({ {15,42}, {34,42}, {37,55}, {12,55} }), GV.ramp("#58a03e") },
  { "hat",    c:poly({ {24,10}, {26,10}, {37,27}, {12,27} }), GV.ramp("#dd3a2a", { shade = "#b8452f", deep = "#6b1b2c" }) },
  { "beard",  c:poly({ {13,30}, {37,30}, {26,49}, {24,49} }), GV.ramp("#f8eed2") },
  { "face",   c:ellipse(24.5, 31, 6, 5):cut(c:rect(0, 0, 63, 27)), "skin", { gloss = false } },
  { "handle", c:rrect(42, 40, 45, 55, 1), GV.ramp("#c4925f") },
  { "blade",  c:poly({ {43,13}, {45,13}, {53,29}, {45,44}, {43,44}, {35,29} }), GV.ramp("#968f96") },
}
c:seam({ {14, 26}, {35, 26} })
c:button(22, 24)
c:eye(20, 29, true); c:eye(27, 29, true)
-- beard tufts
c:paint({ "s..s..s" }, 21, 40, { s = GV.ramp("#f8eed2").shade })
-- blade centre ridge
c:line({ {44, 18}, {44, 39} }, 1)
for y = 18, 39 do c:px(44, y, GV.ramp("#968f96").shade) end
-- tunic belt
c:fill(c:rect(14, 49, 35, 50), "#5e2f1e")
c:fill(c:rect(23, 49, 26, 50), "#e8a317")

local t = c:save(O .. "aseprite/ico/ico-gnome-gardener.aseprite", O .. "png/ico/ico-gnome-gardener.png")
print(GV.report(t))

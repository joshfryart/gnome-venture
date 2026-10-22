local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local head = c:ellipse(32, 32, 20, 20):cut(c:ellipse(32, 38, 14, 18))
head:cut(c:rect(0, 33, 63, 63))
-- angle the tips so they point down-outward
head:cut(c:poly({ {0, 24}, {13, 33}, {0, 33} }))
head:cut(c:poly({ {64, 24}, {51, 33}, {64, 33} }))
local p = c:build{
  { "handle", c:line({ {33, 22}, {43, 46} }, 5), "#b6814d" },
  { "head", head, "#a39ca3", { cres = 3 } },
  { "collar", c:rrect(28, 17, 37, 24, 1), "#5b6470" },
  { "knob", c:ellipse(44, 48, 3.5, 3.5), "#8a4f2a" },
}
local t = c:save(O .. "aseprite/ico/ico-pick.aseprite", O .. "png/ico/ico-pick.png")
print(GV.report(t))

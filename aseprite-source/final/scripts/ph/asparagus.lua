local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- diagonal spear lower-left to upper-right
local stalk = c:line({ {11, 51}, {44, 23} }, 8)
local green = stalk:copy():clip(c:poly({ {24, 0}, {64, 0}, {64, 46}, {40, 46}, {24, 32} }))
local tipM = c:ellipse(48, 19, 6, 6)
tipM:add(c:poly({ {46, 13}, {54, 8}, {56, 9}, {54, 17} }))
tipM:add(c:ellipse(52, 13, 4, 4))
local p = c:build{
  { "stalk", stalk, GV.ramp("#dcb06a"), { light = stalk:copy():add(tipM) } },
  { "green", green, "moss", { light = stalk, contact = false } },
  { "tip", tipM, GV.ramp("#2f5a2a", { base = "#3e6e32" }), { contact = false } },
}
-- scale ticks on bud
c:paint({ "s.", ".s" }, 46, 18, { s = "#4a8a3e" })
c:paint({ "s.", ".s" }, 50, 14, { s = "#4a8a3e" })
c:paint({ "s.", ".s" }, 51, 19, { s = "#4a8a3e" })
-- scale bracts on stalk
c:paint({ "ss", ".s" }, 34, 31, { s = "#4a8a3e" })
c:paint({ "ss", ".s" }, 18, 44, { s = "#b07a45" })
local t = c:save(O .. "aseprite/ph/asparagus.aseprite", O .. "png/ph/asparagus.png")
print(GV.report(t))

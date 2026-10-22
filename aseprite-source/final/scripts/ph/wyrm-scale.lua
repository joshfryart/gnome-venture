local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local outer = c:poly({ {32, 7}, {54, 19}, {51, 46}, {32, 58}, {13, 46}, {10, 19} })
local inner = c:poly({ {32, 15}, {46, 23}, {44, 41}, {32, 49}, {20, 41}, {18, 23} })
local p = c:build{
  { "outer", outer, GV.ramp("#7a5cc0", { rim = "#7b66b4" }) },
  { "inner", inner, GV.ramp("#4e3a8a"), { gloss = false } },
}
-- centre ridge
c:fill(c:rect(31, 10, 32, 54), "#3e2f66")
c:fill(c:rect(31, 16, 31, 47), "#7b66b4")
-- scale arcs on inner plate (lit side)
c:paint({ "a...a", ".aaa." }, 22, 28, { a = "#a894dc" })
c:paint({ "a...a", ".aaa." }, 23, 34, { a = "#a894dc" })
c:paint({ "a...a", ".aaa." }, 36, 28, { a = "#7b66b4" })
local t = c:save(O .. "aseprite/ph/wyrm-scale.aseprite", O .. "png/ph/wyrm-scale.png")
print(GV.report(t))

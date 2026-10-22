local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- apple: two lobes on top with a dip, round bottom
local body = c:ellipse(31.5, 37, 18, 16)
body:add(c:ellipse(24, 30, 10, 9)):add(c:ellipse(39, 30, 10, 9))
body:cut(c:ellipse(31.5, 20, 3, 3))
local stem = c:line({ {31, 14}, {32, 24} }, 3)
local leaf = c:poly({ {34, 19}, {37, 13}, {42, 9}, {47, 8}, {46, 12}, {42, 17}, {37, 20} })
local p = c:build{
  { "body", body, "red", { gloss = { 22, 27 } } },
  { "stem", stem, GV.ramp("#5e2f1e", { base = "#5e2f1e" }), { flat = true } },
  { "leaf", leaf, "moss", { flat = true } },
}
-- leaf vein
c:paint({ "....v", "..vv.", ".v...", "v...." }, 37, 12, { v = "#4a8a3e" })
-- bottom dimple
c:paint({ "dd...dd", ".ddddd." }, 28, 50, { d = "#6b1b2c" })
local t = c:save(O .. "aseprite/ph/apple.aseprite", O .. "png/ph/apple.png")
print(GV.report(t))

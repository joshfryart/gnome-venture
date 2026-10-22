local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 36, 16, 15.5)
body:add(c:ellipse(26, 36, 10, 14)):add(c:ellipse(38, 36, 10, 14))
local stem = c:line({ {32, 23}, {32, 18}, {33, 14} }, 3)
local leaf = c:poly({ {35, 19}, {38, 15}, {42, 12}, {47, 11}, {45, 15}, {41, 18}, {37, 20} })
local p = c:build{
  { "stem", stem, "wood", { flat = true } },
  { "body", body, GV.ramp("#5b3e96"), { cres = 4 } },
  { "leaf", leaf, "moss", { cres = 2 } },
}
-- belly crease, curving gently
local crease = c:line({ {30, 23}, {28, 29}, {27, 36}, {28, 43}, {30, 49} }, 2):clip(body)
c:fill(crease, "#3e2f66")
-- bloom patch
c:fill(c:ellipse(39, 44, 3, 2.5):clip(body):cut(crease), "#7b66b4")
-- leaf mid-vein
c:fill(c:line({ {37, 19}, {41, 16}, {45, 12} }, 1):clip(leaf), "#2f5a2a")
local t = c:save(O .. "aseprite/ph/plum.aseprite", O .. "png/ph/plum.png")
print(GV.report(t))

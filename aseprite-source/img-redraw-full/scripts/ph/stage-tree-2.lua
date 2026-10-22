local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "mound",  c:ellipse(31.5, 47, 19, 5.5), GV.ramp("#8c4a1a") },
  { "top",    c:ellipse(31.5, 45, 14, 3), GV.ramp("#a5663a"), { flat = true } },
  { "trunk",  c:rrect(30, 28, 33, 46, 1), GV.ramp("#c4925f", { rim = "#d9a660" }) },
  { "lobeL",  c:ellipse(25, 28, 6.5, 6), GV.ramp("#58a03e") },
  { "lobeR",  c:ellipse(38, 28, 6.5, 6), GV.ramp("#58a03e") },
  { "crown",  c:ellipse(31.5, 22, 8, 7.5), "moss" },
}
c:paint({ "x.", ".x" }, 31, 37, { x = "#8a4f2a" })
local t = c:save(O .. "aseprite/ph/stage-tree-2.aseprite", O .. "png/ph/stage-tree-2.png")
print(GV.report(t))

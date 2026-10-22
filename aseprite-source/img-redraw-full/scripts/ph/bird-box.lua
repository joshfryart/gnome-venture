local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local loop = c:ellipse(32, 13, 3.5, 3.5):cut(c:ellipse(32, 13, 1.5, 1.5))
local roof = GV.ramp("#7a5cc0", { shade = "#3e2f66" })
c:build{
  { "loop", loop, GV.ramp("#5e2f1e"), { flat = true } },
  { "wall", c:rrect(18, 27, 46, 51, 3), "wood" },
  { "roof", c:poly({ {12, 31}, {32, 15}, {33, 15}, {53, 31} }), roof },
}
-- plank lines either side of the hole
c:fill(c:rect(20, 36, 25, 36), "#8a4f2a"); c:fill(c:rect(39, 36, 44, 36), "#8a4f2a")
c:fill(c:rect(20, 46, 25, 46), "#8a4f2a"); c:fill(c:rect(39, 46, 44, 46), "#8a4f2a")
-- entry hole
c:fill(c:ellipse(32, 39, 5, 5), "#2a1a10")
c:fill(c:ellipse(32, 39, 5, 5):cut(c:ellipse(31, 38, 5, 5)), "#5e2f1e")
-- perch peg
c:part(c:rect(30, 46, 34, 48), GV.ramp("#d9a660"), { flat = true })
c:seam({ {19, 32}, {45, 32} })
c:ground(32, 53, 15, 1.5)
local t = c:save(O .. "aseprite/ph/bird-box.aseprite", O .. "png/ph/bird-box.png")
print(GV.report(t))

local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blue = GV.ramp("#3f93b2")
local feet = c:ellipse(20.5, 54.5, 7.5, 2):add(c:ellipse(43.5, 54.5, 7.5, 2))
local body = c:ellipse(32, 44, 17, 12)
local head = c:ellipse(32, 36, 13, 6):add(c:ellipse(23, 29, 7, 7)):add(c:ellipse(41, 29, 7, 7))
local hands = c:ellipse(22, 52, 3.5, 2):add(c:ellipse(42, 52, 3.5, 2))
c:build{
  { "feet", feet, GV.ramp("#256a80") },
  { "body", body, blue, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 48, 9, 6), GV.ramp("#b8d8d2"), { pale = false } },
  { "head", head, blue },
  { "hands", hands, GV.ramp("#2f7f9c"), { flat = true } },
}
-- bean spots
c:spot(c:ellipse(18.5, 42, 2, 1.5)); c:spot(c:ellipse(45.5, 43, 1.5, 2))
c:spot(c:ellipse(25, 47, 1.5, 1)); c:spot(c:ellipse(39, 46, 1.5, 1))
c:spot(c:ellipse(32, 31.5, 1.5, 1))
-- smile
c:paint({ "m.................m",
          ".m...............m.",
          "..mm...........mm..",
          "....mmm.....mmm....",
          ".......mmmmm......." }, 23, 37, { m = "#2a1a10" })
c:eye(21, 26); c:eye(39, 26)
c:px(29, 44, "#f5cf6a"); c:px(30, 44, "#f5cf6a"); c:px(30, 45, "#f5cf6a")
c:ground(32, 56, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-poison-dart-frog.aseprite", O .. "png/ph/creature-poison-dart-frog.png")
print(GV.report(t))

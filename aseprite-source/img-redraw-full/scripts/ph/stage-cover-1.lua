local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"
local dark = GV.ramp("#58a03e")
c:build{
  { "mound", c:ellipse(31.5, 45, 20, 7), GV.ramp("#8c4a1a") },
  { "face",  c:ellipse(31.5, 43, 15, 4), GV.ramp("#a5663a"), { gloss = false, contact = false } },
  { "left",  c:ellipse(16.5, 40, 5, 5), dark },
  { "right", c:ellipse(46.5, 40, 5, 5), dark },
  { "centre",c:ellipse(31.5, 38, 5.5, 5), "moss" },
}
c:paint({ "ss" }, 23, 43, { s = "#5e2f1e" })
c:paint({ "s", "s" }, 26, 45, { s = "#5e2f1e" })
c:paint({ "ss" }, 38, 44, { s = "#5e2f1e" })
local t = c:save(O .. "aseprite/ph/stage-cover-1.aseprite", O .. "png/ph/stage-cover-1.png")
print(GV.report(t))
